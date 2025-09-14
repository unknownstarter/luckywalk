-- LuckyWalk 함수 및 프로시저
-- 생성일: 2025-01-01
-- 설명: 광고 보상 처리 및 기타 비즈니스 로직 함수

-- 광고 보상 완료 함수
CREATE OR REPLACE FUNCTION complete_ad_reward(
  p_session_id UUID,
  p_uid UUID,
  p_reward_tickets INTEGER,
  p_seq INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- 광고 세션 상태 업데이트
  UPDATE ad_sessions 
  SET status = 'completed', completed_at = NOW()
  WHERE id = p_session_id AND uid = p_uid AND status = 'issued';
  
  -- 보상 원장에 기록
  INSERT INTO reward_ledger (uid, delta, reason, meta)
  VALUES (p_uid, p_reward_tickets, 'ad_reward', 
          jsonb_build_object('session_id', p_session_id, 'seq', p_seq));
  
  -- 일일 진행 상황 업데이트
  INSERT INTO daily_progress (uid, date, ad_claimed_seq, updated_at)
  VALUES (p_uid, CURRENT_DATE, p_seq, NOW())
  ON CONFLICT (uid, date) DO UPDATE SET
    ad_claimed_seq = p_seq,
    updated_at = NOW();
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 걸음수 보상 완료 함수
CREATE OR REPLACE FUNCTION complete_steps_reward(
  p_uid UUID,
  p_threshold INTEGER,
  p_reward_tickets INTEGER
)
RETURNS VOID AS $$
DECLARE
  v_flags JSONB;
BEGIN
  -- 현재 일일 진행 상황 조회
  SELECT step_claimed_flags INTO v_flags
  FROM daily_progress
  WHERE uid = p_uid AND date = CURRENT_DATE;
  
  -- 플래그 업데이트
  v_flags := COALESCE(v_flags, '{}'::jsonb);
  v_flags := v_flags || jsonb_build_object(p_threshold::text, true);
  
  -- 보상 원장에 기록
  INSERT INTO reward_ledger (uid, delta, reason, meta)
  VALUES (p_uid, p_reward_tickets, 'steps_reward', 
          jsonb_build_object('threshold', p_threshold));
  
  -- 일일 진행 상황 업데이트
  INSERT INTO daily_progress (uid, date, step_claimed_flags, updated_at)
  VALUES (p_uid, CURRENT_DATE, v_flags, NOW())
  ON CONFLICT (uid, date) DO UPDATE SET
    step_claimed_flags = v_flags,
    updated_at = NOW();
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 출석체크 완료 함수
CREATE OR REPLACE FUNCTION complete_attendance(
  p_uid UUID,
  p_reward_tickets INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- 보상 원장에 기록
  INSERT INTO reward_ledger (uid, delta, reason, meta)
  VALUES (p_uid, p_reward_tickets, 'attendance', 
          jsonb_build_object('date', CURRENT_DATE));
  
  -- 일일 진행 상황 업데이트
  INSERT INTO daily_progress (uid, date, attendance_done, updated_at)
  VALUES (p_uid, CURRENT_DATE, true, NOW())
  ON CONFLICT (uid, date) DO UPDATE SET
    attendance_done = true,
    updated_at = NOW();
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 초대 보상 완료 함수
CREATE OR REPLACE FUNCTION complete_referral_reward(
  p_inviter_uid UUID,
  p_invitee_uid UUID,
  p_reward_tickets INTEGER
)
RETURNS VOID AS $$
BEGIN
  -- 초대 이벤트 기록
  INSERT INTO referral_events (inviter_uid, invitee_uid, rewarded)
  VALUES (p_inviter_uid, p_invitee_uid, true)
  ON CONFLICT (inviter_uid, invitee_uid) DO UPDATE SET
    rewarded = true;
  
  -- 초대자 보상
  INSERT INTO reward_ledger (uid, delta, reason, meta)
  VALUES (p_inviter_uid, p_reward_tickets, 'referral_inviter', 
          jsonb_build_object('invitee_uid', p_invitee_uid));
  
  -- 피초대자 보상
  INSERT INTO reward_ledger (uid, delta, reason, meta)
  VALUES (p_invitee_uid, p_reward_tickets, 'referral_invitee', 
          jsonb_build_object('inviter_uid', p_inviter_uid));
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 복권 응모 함수
CREATE OR REPLACE FUNCTION submit_tickets(
  p_uid UUID,
  p_round_id UUID,
  p_ticket_count INTEGER,
  p_numbers INTEGER[][]
)
RETURNS VOID AS $$
DECLARE
  v_ticket INTEGER[];
  v_balance INTEGER;
BEGIN
  -- 보유 복권 수 확인
  SELECT ticket_balance INTO v_balance
  FROM wallets
  WHERE uid = p_uid;
  
  IF v_balance < p_ticket_count THEN
    RAISE EXCEPTION 'Insufficient tickets: required %, available %', p_ticket_count, v_balance;
  END IF;
  
  -- 복권 생성
  FOR i IN 1..p_ticket_count LOOP
    v_ticket := p_numbers[i];
    
    INSERT INTO tickets (uid, round_id, numbers, source)
    VALUES (p_uid, p_round_id, v_ticket, 'manual');
  END LOOP;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- KYC 제출 함수
CREATE OR REPLACE FUNCTION submit_kyc(
  p_uid UUID,
  p_round_id UUID,
  p_real_name VARCHAR(50),
  p_rrn_encrypted TEXT,
  p_bank_name VARCHAR(50),
  p_bank_account_encrypted TEXT,
  p_files JSONB
)
RETURNS UUID AS $$
DECLARE
  v_submission_id UUID;
BEGIN
  -- KYC 제출
  INSERT INTO kyc_submissions (
    uid, round_id, real_name, rrn_encrypted, 
    bank_name, bank_account_encrypted, files
  )
  VALUES (
    p_uid, p_round_id, p_real_name, p_rrn_encrypted,
    p_bank_name, p_bank_account_encrypted, p_files
  )
  RETURNING id INTO v_submission_id;
  
  -- 결과 상태 업데이트
  UPDATE results_user
  SET kyc_status = 'pending'
  WHERE uid = p_uid AND round_id = p_round_id;
  
  RETURN v_submission_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- KYC 승인 함수
CREATE OR REPLACE FUNCTION approve_kyc(
  p_submission_id UUID,
  p_admin_uid UUID
)
RETURNS VOID AS $$
DECLARE
  v_uid UUID;
  v_round_id UUID;
BEGIN
  -- KYC 승인
  UPDATE kyc_submissions
  SET status = 'approved', reviewed_at = NOW(), reviewed_by = p_admin_uid
  WHERE id = p_submission_id
  RETURNING uid, round_id INTO v_uid, v_round_id;
  
  -- 결과 상태 업데이트
  UPDATE results_user
  SET kyc_status = 'approved'
  WHERE uid = v_uid AND round_id = v_round_id;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- KYC 거부 함수
CREATE OR REPLACE FUNCTION reject_kyc(
  p_submission_id UUID,
  p_admin_uid UUID,
  p_rejection_reason TEXT
)
RETURNS VOID AS $$
DECLARE
  v_uid UUID;
  v_round_id UUID;
BEGIN
  -- KYC 거부
  UPDATE kyc_submissions
  SET status = 'rejected', reviewed_at = NOW(), reviewed_by = p_admin_uid,
      rejection_reason = p_rejection_reason
  WHERE id = p_submission_id
  RETURNING uid, round_id INTO v_uid, v_round_id;
  
  -- 결과 상태 업데이트
  UPDATE results_user
  SET kyc_status = 'rejected'
  WHERE uid = v_uid AND round_id = v_round_id;
    
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 사용자 통계 조회 함수
CREATE OR REPLACE FUNCTION get_user_stats(p_uid UUID)
RETURNS JSONB AS $$
DECLARE
  v_stats JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_tickets', COALESCE(w.ticket_balance, 0),
    'total_rewards', COALESCE(SUM(rl.delta), 0),
    'ad_rewards', COALESCE(SUM(CASE WHEN rl.reason = 'ad_reward' THEN rl.delta ELSE 0 END), 0),
    'steps_rewards', COALESCE(SUM(CASE WHEN rl.reason = 'steps_reward' THEN rl.delta ELSE 0 END), 0),
    'attendance_rewards', COALESCE(SUM(CASE WHEN rl.reason = 'attendance' THEN rl.delta ELSE 0 END), 0),
    'referral_rewards', COALESCE(SUM(CASE WHEN rl.reason LIKE 'referral_%' THEN rl.delta ELSE 0 END), 0),
    'total_submissions', COALESCE(COUNT(t.id), 0),
    'total_winnings', COALESCE(SUM(ru.share_amount_krw), 0)
  ) INTO v_stats
  FROM wallets w
  LEFT JOIN reward_ledger rl ON w.uid = rl.uid
  LEFT JOIN tickets t ON w.uid = t.uid
  LEFT JOIN results_user ru ON w.uid = ru.uid
  WHERE w.uid = p_uid;
  
  RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 회차 통계 조회 함수
CREATE OR REPLACE FUNCTION get_round_stats(p_round_id UUID)
RETURNS JSONB AS $$
DECLARE
  v_stats JSONB;
BEGIN
  SELECT jsonb_build_object(
    'total_tickets', COALESCE(COUNT(t.id), 0),
    'total_participants', COALESCE(COUNT(DISTINCT t.uid), 0),
    'total_winners', COALESCE(COUNT(ru.id), 0),
    'winners_by_tier', jsonb_build_object(
      'tier_1', COALESCE(COUNT(CASE WHEN ru.tier = 1 THEN 1 END), 0),
      'tier_2', COALESCE(COUNT(CASE WHEN ru.tier = 2 THEN 1 END), 0),
      'tier_3', COALESCE(COUNT(CASE WHEN ru.tier = 3 THEN 1 END), 0),
      'tier_4', COALESCE(COUNT(CASE WHEN ru.tier = 4 THEN 1 END), 0),
      'tier_5', COALESCE(COUNT(CASE WHEN ru.tier = 5 THEN 1 END), 0)
    ),
    'total_prize_amount', COALESCE(SUM(ru.share_amount_krw), 0)
  ) INTO v_stats
  FROM rounds r
  LEFT JOIN tickets t ON r.id = t.round_id
  LEFT JOIN results_user ru ON r.id = ru.round_id
  WHERE r.id = p_round_id;
  
  RETURN v_stats;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
