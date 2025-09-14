-- LuckyWalk 초기 스키마
-- 생성일: 2025-01-01
-- 설명: LuckyWalk 앱의 기본 데이터베이스 스키마

-- 확장 기능 활성화
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- 사용자 프로필 테이블
CREATE TABLE user_profiles (
  uid UUID PRIMARY KEY REFERENCES auth.users(id) ON DELETE CASCADE,
  nickname VARCHAR(50) NOT NULL,
  photo_url TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  last_login_at TIMESTAMPTZ DEFAULT NOW(),
  device_fingerprint TEXT,
  abuse_flag BOOLEAN DEFAULT FALSE,
  abuse_reason TEXT,
  abuse_score DECIMAL(3,2) DEFAULT 0.0,
  fcm_token TEXT,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 사용자 역할 테이블
CREATE TABLE user_roles (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  role VARCHAR(20) NOT NULL DEFAULT 'user' CHECK (role IN ('user', 'admin')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(uid, role)
);

-- 회차 테이블
CREATE TABLE rounds (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  round_no INTEGER NOT NULL UNIQUE,
  draw_datetime TIMESTAMPTZ NOT NULL,
  result_nums INTEGER[6],
  result_bonus INTEGER,
  prize_tier1_krw INTEGER DEFAULT 1000000,
  prize_tier2_krw INTEGER DEFAULT 500000,
  status VARCHAR(20) NOT NULL DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'drawn', 'settled')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 복권 테이블
CREATE TABLE tickets (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  numbers INTEGER[6] NOT NULL,
  source VARCHAR(20) NOT NULL CHECK (source IN ('steps', 'ad', 'attendance', 'referral')),
  ad_seq INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 일일 진행 상황 테이블
CREATE TABLE daily_progress (
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  date DATE NOT NULL,
  step_claimed_flags JSONB DEFAULT '{}',
  ad_claimed_seq INTEGER DEFAULT 0,
  attendance_done BOOLEAN DEFAULT FALSE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  PRIMARY KEY (uid, date)
);

-- 지갑 테이블 (보유 복권 수 캐시)
CREATE TABLE wallets (
  uid UUID PRIMARY KEY REFERENCES user_profiles(uid) ON DELETE CASCADE,
  ticket_balance INTEGER DEFAULT 0,
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- 보상 원장 테이블
CREATE TABLE reward_ledger (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  delta INTEGER NOT NULL,
  reason VARCHAR(50) NOT NULL,
  meta JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 사용자 결과 테이블
CREATE TABLE results_user (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  tier INTEGER NOT NULL CHECK (tier BETWEEN 1 AND 5),
  share_amount_krw INTEGER,
  notified_at TIMESTAMPTZ,
  kyc_required BOOLEAN DEFAULT FALSE,
  kyc_status VARCHAR(20) DEFAULT 'none' CHECK (kyc_status IN ('none', 'pending', 'approved', 'rejected')),
  created_at TIMESTAMPTZ DEFAULT NOW(),
  UNIQUE(uid, round_id)
);

-- KYC 제출 테이블
CREATE TABLE kyc_submissions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  real_name VARCHAR(50) NOT NULL,
  rrn_encrypted TEXT NOT NULL,
  bank_name VARCHAR(50) NOT NULL,
  bank_account_encrypted TEXT NOT NULL,
  rrn_verified BOOLEAN DEFAULT FALSE,
  files JSONB,
  submitted_at TIMESTAMPTZ DEFAULT NOW(),
  reviewed_at TIMESTAMPTZ,
  reviewed_by UUID REFERENCES user_profiles(uid),
  status VARCHAR(20) DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  rejection_reason TEXT,
  UNIQUE(uid, round_id)
);

-- 초대 코드 테이블
CREATE TABLE referral_codes (
  uid UUID PRIMARY KEY REFERENCES user_profiles(uid) ON DELETE CASCADE,
  code VARCHAR(20) NOT NULL UNIQUE,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 초대 이벤트 테이블
CREATE TABLE referral_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  inviter_uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  invitee_uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  rewarded BOOLEAN DEFAULT FALSE,
  UNIQUE(inviter_uid, invitee_uid)
);

-- 관리자 액션 테이블
CREATE TABLE admin_actions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  admin_uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  action_type VARCHAR(50) NOT NULL,
  payload JSONB,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 광고 세션 테이블
CREATE TABLE ad_sessions (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  ad_unit_id VARCHAR(100) NOT NULL,
  seq INTEGER NOT NULL,
  nonce VARCHAR(100) NOT NULL,
  issued_at TIMESTAMPTZ DEFAULT NOW(),
  expires_at TIMESTAMPTZ NOT NULL,
  completed_at TIMESTAMPTZ,
  status VARCHAR(20) DEFAULT 'issued' CHECK (status IN ('issued', 'completed', 'expired')),
  UNIQUE(uid, ad_unit_id, seq, nonce)
);

-- 분석 이벤트 테이블
CREATE TABLE analytics_events (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  event_name VARCHAR(100) NOT NULL,
  uid UUID REFERENCES user_profiles(uid) ON DELETE SET NULL,
  device_id VARCHAR(100),
  app_version VARCHAR(20),
  platform VARCHAR(20),
  timezone VARCHAR(50),
  network VARCHAR(20),
  parameters JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 시스템 상태 로그 테이블
CREATE TABLE system_health_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  health_checks JSONB NOT NULL,
  overall_status BOOLEAN NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_tickets_uid_round ON tickets(uid, round_id);
CREATE INDEX idx_tickets_round_id ON tickets(round_id);
CREATE INDEX idx_tickets_created_at ON tickets(created_at);
CREATE INDEX idx_daily_progress_uid_date ON daily_progress(uid, date);
CREATE INDEX idx_results_user_uid ON results_user(uid);
CREATE INDEX idx_results_user_round_id ON results_user(round_id);
CREATE INDEX idx_kyc_submissions_uid ON kyc_submissions(uid);
CREATE INDEX idx_kyc_submissions_round_id ON kyc_submissions(round_id);
CREATE INDEX idx_kyc_submissions_status ON kyc_submissions(status);
CREATE INDEX idx_referral_events_inviter ON referral_events(inviter_uid);
CREATE INDEX idx_referral_events_invitee ON referral_events(invitee_uid);
CREATE INDEX idx_ad_sessions_uid ON ad_sessions(uid);
CREATE INDEX idx_ad_sessions_expires_at ON ad_sessions(expires_at);
CREATE INDEX idx_analytics_events_uid ON analytics_events(uid);
CREATE INDEX idx_analytics_events_created_at ON analytics_events(created_at);
CREATE INDEX idx_analytics_events_event_name ON analytics_events(event_name);

-- RLS (Row Level Security) 활성화
ALTER TABLE user_profiles ENABLE ROW LEVEL SECURITY;
ALTER TABLE user_roles ENABLE ROW LEVEL SECURITY;
ALTER TABLE rounds ENABLE ROW LEVEL SECURITY;
ALTER TABLE tickets ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_progress ENABLE ROW LEVEL SECURITY;
ALTER TABLE wallets ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_ledger ENABLE ROW LEVEL SECURITY;
ALTER TABLE results_user ENABLE ROW LEVEL SECURITY;
ALTER TABLE kyc_submissions ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_codes ENABLE ROW LEVEL SECURITY;
ALTER TABLE referral_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE admin_actions ENABLE ROW LEVEL SECURITY;
ALTER TABLE ad_sessions ENABLE ROW LEVEL SECURITY;
ALTER TABLE analytics_events ENABLE ROW LEVEL SECURITY;
ALTER TABLE system_health_logs ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성
-- 사용자 프로필: 본인 데이터만 접근
CREATE POLICY "Users can view own profile" ON user_profiles
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own profile" ON user_profiles
  FOR UPDATE USING (auth.uid() = uid);

-- 사용자 역할: 본인 역할만 접근
CREATE POLICY "Users can view own role" ON user_roles
  FOR SELECT USING (auth.uid() = uid);

-- 회차: 모든 사용자 읽기 가능
CREATE POLICY "Users can view rounds" ON rounds
  FOR SELECT USING (true);

-- 복권: 본인 복권만 접근
CREATE POLICY "Users can view own tickets" ON tickets
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can insert own tickets" ON tickets
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- 일일 진행 상황: 본인 데이터만 접근
CREATE POLICY "Users can view own progress" ON daily_progress
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own progress" ON daily_progress
  FOR UPDATE USING (auth.uid() = uid);

CREATE POLICY "Users can insert own progress" ON daily_progress
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- 지갑: 본인 지갑만 접근
CREATE POLICY "Users can view own wallet" ON wallets
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own wallet" ON wallets
  FOR UPDATE USING (auth.uid() = uid);

-- 보상 원장: 본인 원장만 접근
CREATE POLICY "Users can view own ledger" ON reward_ledger
  FOR SELECT USING (auth.uid() = uid);

-- 사용자 결과: 본인 결과만 접근
CREATE POLICY "Users can view own results" ON results_user
  FOR SELECT USING (auth.uid() = uid);

-- KYC 제출: 본인 제출만 접근
CREATE POLICY "Users can view own kyc" ON kyc_submissions
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can insert own kyc" ON kyc_submissions
  FOR INSERT WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update own kyc" ON kyc_submissions
  FOR UPDATE USING (auth.uid() = uid);

-- 초대 코드: 본인 코드만 접근
CREATE POLICY "Users can view own referral code" ON referral_codes
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can insert own referral code" ON referral_codes
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- 초대 이벤트: 본인 관련 이벤트만 접근
CREATE POLICY "Users can view own referral events" ON referral_events
  FOR SELECT USING (auth.uid() = inviter_uid OR auth.uid() = invitee_uid);

-- 광고 세션: 본인 세션만 접근
CREATE POLICY "Users can view own ad sessions" ON ad_sessions
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can insert own ad sessions" ON ad_sessions
  FOR INSERT WITH CHECK (auth.uid() = uid);

CREATE POLICY "Users can update own ad sessions" ON ad_sessions
  FOR UPDATE USING (auth.uid() = uid);

-- 분석 이벤트: 본인 이벤트만 접근
CREATE POLICY "Users can view own analytics" ON analytics_events
  FOR SELECT USING (auth.uid() = uid);

-- 관리자 정책 (관리자는 모든 데이터 접근 가능)
CREATE POLICY "Admins can view all profiles" ON user_profiles
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can update all profiles" ON user_profiles
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all rounds" ON rounds
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all tickets" ON tickets
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all results" ON results_user
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can manage kyc" ON kyc_submissions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all analytics" ON analytics_events
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

-- 관리자 액션: 관리자만 접근
CREATE POLICY "Admins can manage admin actions" ON admin_actions
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

-- 시스템 상태 로그: 관리자만 접근
CREATE POLICY "Admins can view system logs" ON system_health_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

-- 함수 생성
-- 사용자 프로필 생성 함수
CREATE OR REPLACE FUNCTION create_user_profile()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO user_profiles (uid, nickname, created_at, last_login_at)
  VALUES (NEW.id, COALESCE(NEW.raw_user_meta_data->>'nickname', 'User'), NOW(), NOW());
  
  INSERT INTO user_roles (uid, role)
  VALUES (NEW.id, 'user');
  
  INSERT INTO wallets (uid, ticket_balance)
  VALUES (NEW.id, 0);
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 사용자 프로필 생성 트리거
CREATE TRIGGER on_auth_user_created
  AFTER INSERT ON auth.users
  FOR EACH ROW EXECUTE FUNCTION create_user_profile();

-- 지갑 잔액 업데이트 함수
CREATE OR REPLACE FUNCTION update_wallet_balance()
RETURNS TRIGGER AS $$
BEGIN
  INSERT INTO wallets (uid, ticket_balance, updated_at)
  VALUES (NEW.uid, NEW.delta, NOW())
  ON CONFLICT (uid) DO UPDATE SET
    ticket_balance = wallets.ticket_balance + NEW.delta,
    updated_at = NOW();
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 보상 원장 트리거
CREATE TRIGGER on_reward_ledger_insert
  AFTER INSERT ON reward_ledger
  FOR EACH ROW EXECUTE FUNCTION update_wallet_balance();

-- 복권 응모 시 지갑 잔액 차감 함수
CREATE OR REPLACE FUNCTION deduct_tickets_on_submit()
RETURNS TRIGGER AS $$
BEGIN
  UPDATE wallets 
  SET ticket_balance = ticket_balance - 1,
      updated_at = NOW()
  WHERE uid = NEW.uid;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 복권 삽입 트리거
CREATE TRIGGER on_ticket_insert
  AFTER INSERT ON tickets
  FOR EACH ROW EXECUTE FUNCTION deduct_tickets_on_submit();

-- 초기 데이터 삽입
-- 첫 번째 회차 생성
INSERT INTO rounds (round_no, draw_datetime, status) VALUES
(1, NOW() + INTERVAL '7 days', 'scheduled');

-- 기본 관리자 계정 생성 (실제 운영 시에는 별도로 생성)
-- INSERT INTO user_roles (uid, role) VALUES ('admin-uid-here', 'admin');
