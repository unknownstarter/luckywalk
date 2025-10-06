-- LuckyWalk 통합 스키마
-- Migration: 005_integrated_schema.sql
-- Created: 2025-01-17 01:45:00 KST
-- Description: 기존 스키마와 새로운 스키마를 통합한 완전한 데이터베이스

-- ========================================
-- 1. 기존 테이블과 새 테이블 통합
-- ========================================

-- 기존 user_profiles 테이블을 확장하여 새 스키마와 통합
ALTER TABLE user_profiles 
ADD COLUMN IF NOT EXISTS email TEXT,
ADD COLUMN IF NOT EXISTS phone TEXT,
ADD COLUMN IF NOT EXISTS last_login_at TIMESTAMPTZ DEFAULT NOW(),
ADD COLUMN IF NOT EXISTS is_active BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS is_verified BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS kakao_id TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS apple_id TEXT UNIQUE,
ADD COLUMN IF NOT EXISTS status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
ADD COLUMN IF NOT EXISTS kyc_data JSONB,
ADD COLUMN IF NOT EXISTS kyc_verified_at TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS marketing_consent BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS push_notification_consent BOOLEAN DEFAULT true,
ADD COLUMN IF NOT EXISTS profile_image_url TEXT,
ADD COLUMN IF NOT EXISTS birth_year INTEGER,
ADD COLUMN IF NOT EXISTS gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
ADD COLUMN IF NOT EXISTS language TEXT DEFAULT 'ko' CHECK (language IN ('ko', 'en')),
ADD COLUMN IF NOT EXISTS timezone TEXT DEFAULT 'Asia/Seoul',
ADD COLUMN IF NOT EXISTS notification_settings JSONB DEFAULT '{}',
ADD COLUMN IF NOT EXISTS total_steps BIGINT DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_ad_views INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_attendance_days INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_tickets_purchased INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_tickets_won INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_prize_amount BIGINT DEFAULT 0,
ADD COLUMN IF NOT EXISTS current_level INTEGER DEFAULT 1,
ADD COLUMN IF NOT EXISTS current_exp BIGINT DEFAULT 0,
ADD COLUMN IF NOT EXISTS next_level_exp BIGINT DEFAULT 1000;

-- 기존 rounds 테이블을 lottery_rounds와 통합
ALTER TABLE rounds 
ADD COLUMN IF NOT EXISTS submission_deadline TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS announcement_time TIMESTAMPTZ,
ADD COLUMN IF NOT EXISTS total_tickets_sold INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_participants INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS total_prize_pool BIGINT DEFAULT 0;

-- 기존 tickets 테이블을 user_tickets와 통합
ALTER TABLE tickets 
ADD COLUMN IF NOT EXISTS ticket_type TEXT DEFAULT 'manual' CHECK (ticket_type IN ('manual', 'auto')),
ADD COLUMN IF NOT EXISTS purchase_price BIGINT DEFAULT 0,
ADD COLUMN IF NOT EXISTS purchase_method TEXT DEFAULT 'free' CHECK (purchase_method IN ('free', 'paid', 'reward')),
ADD COLUMN IF NOT EXISTS is_winner BOOLEAN DEFAULT false,
ADD COLUMN IF NOT EXISTS prize_tier INTEGER DEFAULT 0,
ADD COLUMN IF NOT EXISTS prize_amount BIGINT DEFAULT 0,
ADD COLUMN IF NOT EXISTS matched_numbers INTEGER DEFAULT 0;

-- ========================================
-- 2. 새 테이블 생성 (기존과 중복되지 않는 것들)
-- ========================================

-- Rewards 테이블 (기존에 없음)
CREATE TABLE IF NOT EXISTS rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  name TEXT NOT NULL,
  description TEXT,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('steps', 'ad_view', 'attendance', 'purchase', 'referral')),
  required_value INTEGER NOT NULL,
  reward_value INTEGER NOT NULL,
  order_index INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT rewards_required_value_positive CHECK (required_value > 0),
  CONSTRAINT rewards_reward_value_positive CHECK (reward_value > 0)
);

-- User rewards 테이블 (기존에 없음)
CREATE TABLE IF NOT EXISTS user_rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  reward_id UUID NOT NULL REFERENCES rewards(id) ON DELETE CASCADE,
  reward_type TEXT NOT NULL,
  reward_value INTEGER NOT NULL,
  earned_at TIMESTAMPTZ DEFAULT NOW(),
  is_claimed BOOLEAN DEFAULT false,
  claimed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT user_rewards_reward_value_positive CHECK (reward_value > 0)
);

-- User activities 테이블 (기존 analytics_events와 통합)
CREATE TABLE IF NOT EXISTS user_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'step_count', 'ad_view', 'attendance', 'ticket_purchase', 
    'ticket_win', 'login', 'logout', 'app_open', 'app_close'
  )),
  activity_value INTEGER DEFAULT 0,
  activity_data JSONB DEFAULT '{}',
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location_accuracy DECIMAL(8, 2),
  device_type TEXT,
  app_version TEXT,
  os_version TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT user_activities_activity_value_positive CHECK (activity_value >= 0)
);

-- App events 테이블 (기존 analytics_events 확장)
CREATE TABLE IF NOT EXISTS app_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  uid UUID REFERENCES user_profiles(uid) ON DELETE SET NULL,
  event_name TEXT NOT NULL,
  event_category TEXT NOT NULL CHECK (event_category IN (
    'navigation', 'interaction', 'error', 'performance', 'business'
  )),
  event_data JSONB DEFAULT '{}',
  session_id TEXT,
  screen_name TEXT,
  screen_path TEXT,
  user_agent TEXT,
  ip_address INET,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT app_events_event_name_not_empty CHECK (LENGTH(event_name) > 0)
);

-- Admin users 테이블 (기존 user_roles 확장)
CREATE TABLE IF NOT EXISTS admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  admin_role TEXT NOT NULL CHECK (admin_role IN ('super_admin', 'admin', 'moderator')),
  permissions JSONB DEFAULT '{}',
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW(),
  CONSTRAINT admin_users_uid_unique UNIQUE (uid)
);

-- Lottery results 테이블 (기존 results_user 확장)
CREATE TABLE IF NOT EXISTS lottery_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  total_winners INTEGER DEFAULT 0,
  total_prize_amount BIGINT DEFAULT 0,
  tier_1_winners INTEGER DEFAULT 0,
  tier_1_prize_amount BIGINT DEFAULT 0,
  tier_2_winners INTEGER DEFAULT 0,
  tier_2_prize_amount BIGINT DEFAULT 0,
  tier_3_winners INTEGER DEFAULT 0,
  tier_3_prize_amount BIGINT DEFAULT 0,
  tier_4_winners INTEGER DEFAULT 0,
  tier_4_prize_amount BIGINT DEFAULT 0,
  tier_5_winners INTEGER DEFAULT 0,
  tier_5_prize_amount BIGINT DEFAULT 0,
  tier_6_winners INTEGER DEFAULT 0,
  tier_6_prize_amount BIGINT DEFAULT 0,
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  processed_at TIMESTAMPTZ,
  created_at TIMESTAMPTZ DEFAULT NOW(),
  updated_at TIMESTAMPTZ DEFAULT NOW()
);

-- ========================================
-- 3. 인덱스 생성
-- ========================================

-- User activities 인덱스
CREATE INDEX IF NOT EXISTS idx_user_activities_uid ON user_activities(uid);
CREATE INDEX IF NOT EXISTS idx_user_activities_activity_type ON user_activities(activity_type);
CREATE INDEX IF NOT EXISTS idx_user_activities_created_at ON user_activities(created_at);

-- App events 인덱스
CREATE INDEX IF NOT EXISTS idx_app_events_uid ON app_events(uid);
CREATE INDEX IF NOT EXISTS idx_app_events_event_name ON app_events(event_name);
CREATE INDEX IF NOT EXISTS idx_app_events_event_category ON app_events(event_category);
CREATE INDEX IF NOT EXISTS idx_app_events_created_at ON app_events(created_at);
CREATE INDEX IF NOT EXISTS idx_app_events_session_id ON app_events(session_id);

-- User rewards 인덱스
CREATE INDEX IF NOT EXISTS idx_user_rewards_uid ON user_rewards(uid);
CREATE INDEX IF NOT EXISTS idx_user_rewards_earned_at ON user_rewards(earned_at);
CREATE INDEX IF NOT EXISTS idx_user_rewards_is_claimed ON user_rewards(is_claimed);

-- ========================================
-- 4. RLS 정책 업데이트
-- ========================================

-- Rewards 테이블 RLS
ALTER TABLE rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active rewards" ON rewards
  FOR SELECT USING (is_active = true);

CREATE POLICY "Only admins can modify rewards" ON rewards
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE uid = auth.uid() AND is_active = true
    )
  );

-- User rewards 테이블 RLS
ALTER TABLE user_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own rewards" ON user_rewards
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can update own rewards" ON user_rewards
  FOR UPDATE USING (auth.uid() = uid);

-- User activities 테이블 RLS
ALTER TABLE user_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activities" ON user_activities
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can insert own activities" ON user_activities
  FOR INSERT WITH CHECK (auth.uid() = uid);

-- App events 테이블 RLS
ALTER TABLE app_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own events" ON app_events
  FOR SELECT USING (auth.uid() = uid OR uid IS NULL);

CREATE POLICY "Users can insert events" ON app_events
  FOR INSERT WITH CHECK (auth.uid() = uid OR uid IS NULL);

-- Admin users 테이블 RLS
ALTER TABLE admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can view admin users" ON admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE uid = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Only super admins can modify admin users" ON admin_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE uid = auth.uid() AND admin_role = 'super_admin' AND is_active = true
    )
  );

-- Lottery results 테이블 RLS
ALTER TABLE lottery_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lottery results" ON lottery_results
  FOR SELECT USING (true);

CREATE POLICY "Only admins can modify lottery results" ON lottery_results
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM admin_users 
      WHERE uid = auth.uid() AND is_active = true
    )
  );

-- ========================================
-- 5. 함수 및 트리거 업데이트
-- ========================================

-- 사용자 프로필 통계 업데이트 함수
CREATE OR REPLACE FUNCTION update_user_profile_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update user profile statistics based on activity type
  IF NEW.activity_type = 'step_count' THEN
    UPDATE user_profiles 
    SET total_steps = total_steps + NEW.activity_value,
        updated_at = NOW()
    WHERE uid = NEW.uid;
  ELSIF NEW.activity_type = 'ad_view' THEN
    UPDATE user_profiles 
    SET total_ad_views = total_ad_views + 1,
        updated_at = NOW()
    WHERE uid = NEW.uid;
  ELSIF NEW.activity_type = 'attendance' THEN
    UPDATE user_profiles 
    SET total_attendance_days = total_attendance_days + 1,
        updated_at = NOW()
    WHERE uid = NEW.uid;
  ELSIF NEW.activity_type = 'ticket_purchase' THEN
    UPDATE user_profiles 
    SET total_tickets_purchased = total_tickets_purchased + NEW.activity_value,
        updated_at = NOW()
    WHERE uid = NEW.uid;
  ELSIF NEW.activity_type = 'ticket_win' THEN
    UPDATE user_profiles 
    SET total_tickets_won = total_tickets_won + 1,
        total_prize_amount = total_prize_amount + NEW.activity_value,
        updated_at = NOW()
    WHERE uid = NEW.uid;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- User activities 트리거
DROP TRIGGER IF EXISTS trigger_update_user_profile_stats ON user_activities;
CREATE TRIGGER trigger_update_user_profile_stats
  AFTER INSERT ON user_activities
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_stats();

-- 당첨번호 매칭 함수
CREATE OR REPLACE FUNCTION calculate_matched_numbers(
  ticket_numbers INTEGER[],
  winning_numbers INTEGER[]
)
RETURNS INTEGER AS $$
DECLARE
  matched_count INTEGER := 0;
  i INTEGER;
BEGIN
  FOR i IN 1..array_length(ticket_numbers, 1) LOOP
    IF ticket_numbers[i] = ANY(winning_numbers) THEN
      matched_count := matched_count + 1;
    END IF;
  END LOOP;
  
  RETURN matched_count;
END;
$$ LANGUAGE plpgsql;

-- 당첨 등급 계산 함수
CREATE OR REPLACE FUNCTION calculate_prize_tier(
  matched_numbers INTEGER,
  bonus_number INTEGER,
  ticket_numbers INTEGER[]
)
RETURNS INTEGER AS $$
BEGIN
  -- 1st place: 6 numbers match
  IF matched_numbers = 6 THEN
    RETURN 1;
  -- 2nd place: 5 numbers match + bonus number
  ELSIF matched_numbers = 5 AND bonus_number = ANY(ticket_numbers) THEN
    RETURN 2;
  -- 3rd place: 5 numbers match
  ELSIF matched_numbers = 5 THEN
    RETURN 3;
  -- 4th place: 4 numbers match
  ELSIF matched_numbers = 4 THEN
    RETURN 4;
  -- 5th place: 3 numbers match
  ELSIF matched_numbers = 3 THEN
    RETURN 5;
  -- 6th place: 2 numbers match
  ELSIF matched_numbers = 2 THEN
    RETURN 6;
  ELSE
    RETURN 0; -- No win
  END IF;
END;
$$ LANGUAGE plpgsql;

-- ========================================
-- 6. 뷰 생성
-- ========================================

-- 복권 통계 뷰
CREATE OR REPLACE VIEW lottery_statistics AS
SELECT 
  r.round_no as round_number,
  r.draw_datetime as draw_date,
  r.total_tickets_sold,
  r.total_participants,
  r.total_prize_pool,
  r.result_nums as winning_numbers,
  r.result_bonus as bonus_number,
  lr.tier_1_winners,
  lr.tier_1_prize_amount,
  lr.tier_2_winners,
  lr.tier_2_prize_amount,
  lr.tier_3_winners,
  lr.tier_3_prize_amount,
  lr.tier_4_winners,
  lr.tier_4_prize_amount,
  lr.tier_5_winners,
  lr.tier_5_prize_amount,
  lr.tier_6_winners,
  lr.tier_6_prize_amount
FROM rounds r
LEFT JOIN lottery_results lr ON r.id = lr.round_id
WHERE r.status = 'drawn' OR r.status = 'settled';

-- 사용자 통계 뷰
CREATE OR REPLACE VIEW user_statistics AS
SELECT 
  up.uid as id,
  up.email,
  up.nickname,
  up.total_steps,
  up.total_ad_views,
  up.total_attendance_days,
  up.total_tickets_purchased,
  up.total_tickets_won,
  up.total_prize_amount,
  up.current_level,
  up.current_exp,
  COUNT(t.id) as total_tickets,
  COUNT(CASE WHEN t.is_winner = true THEN 1 END) as winning_tickets,
  SUM(t.prize_amount) as total_prize_won
FROM user_profiles up
LEFT JOIN tickets t ON up.uid = t.uid
GROUP BY up.uid, up.email, up.nickname, up.total_steps, up.total_ad_views, 
         up.total_attendance_days, up.total_tickets_purchased, up.total_tickets_won, 
         up.total_prize_amount, up.current_level, up.current_exp;

-- ========================================
-- 7. 초기 데이터 삽입
-- ========================================

-- 기본 보상 데이터 삽입 (기존에 없으면)
INSERT INTO rewards (name, description, reward_type, required_value, reward_value, order_index, is_active) 
SELECT * FROM (VALUES
('걸음수 1,000보', '1,000보를 걸으면 복권 1장을 받을 수 있어요', 'steps', 1000, 1, 1, true),
('걸음수 2,000보', '2,000보를 걸으면 복권 2장을 받을 수 있어요', 'steps', 2000, 2, 2, true),
('걸음수 3,000보', '3,000보를 걸으면 복권 3장을 받을 수 있어요', 'steps', 3000, 3, 3, true),
('걸음수 4,000보', '4,000보를 걸으면 복권 4장을 받을 수 있어요', 'steps', 4000, 4, 4, true),
('걸음수 5,000보', '5,000보를 걸으면 복권 5장을 받을 수 있어요', 'steps', 5000, 5, 5, true),
('걸음수 6,000보', '6,000보를 걸으면 복권 6장을 받을 수 있어요', 'steps', 6000, 6, 6, true),
('걸음수 7,000보', '7,000보를 걸으면 복권 7장을 받을 수 있어요', 'steps', 7000, 7, 7, true),
('걸음수 8,000보', '8,000보를 걸으면 복권 8장을 받을 수 있어요', 'steps', 8000, 8, 8, true),
('걸음수 9,000보', '9,000보를 걸으면 복권 9장을 받을 수 있어요', 'steps', 9000, 9, 9, true),
('걸음수 10,000보', '10,000보를 걸으면 복권 10장을 받을 수 있어요', 'steps', 10000, 10, 10, true),
('광고 1회 시청', '광고를 1회 시청하면 복권 1장을 받을 수 있어요', 'ad_view', 1, 1, 11, true),
('광고 2회 시청', '광고를 2회 시청하면 복권 2장을 받을 수 있어요', 'ad_view', 2, 2, 12, true),
('광고 3회 시청', '광고를 3회 시청하면 복권 3장을 받을 수 있어요', 'ad_view', 3, 3, 13, true),
('광고 4회 시청', '광고를 4회 시청하면 복권 4장을 받을 수 있어요', 'ad_view', 4, 4, 14, true),
('광고 5회 시청', '광고를 5회 시청하면 복권 5장을 받을 수 있어요', 'ad_view', 5, 5, 15, true),
('광고 6회 시청', '광고를 6회 시청하면 복권 6장을 받을 수 있어요', 'ad_view', 6, 6, 16, true),
('광고 7회 시청', '광고를 7회 시청하면 복권 7장을 받을 수 있어요', 'ad_view', 7, 7, 17, true),
('광고 8회 시청', '광고를 8회 시청하면 복권 8장을 받을 수 있어요', 'ad_view', 8, 8, 18, true),
('광고 9회 시청', '광고를 9회 시청하면 복권 9장을 받을 수 있어요', 'ad_view', 9, 9, 19, true),
('광고 10회 시청', '광고를 10회 시청하면 복권 10장을 받을 수 있어요', 'ad_view', 10, 10, 20, true),
('출석체크 1일', '1일 연속 출석하면 복권 1장을 받을 수 있어요', 'attendance', 1, 1, 21, true),
('출석체크 2일', '2일 연속 출석하면 복권 2장을 받을 수 있어요', 'attendance', 2, 2, 22, true),
('출석체크 3일', '3일 연속 출석하면 복권 3장을 받을 수 있어요', 'attendance', 3, 3, 23, true),
('출석체크 4일', '4일 연속 출석하면 복권 4장을 받을 수 있어요', 'attendance', 4, 4, 24, true),
('출석체크 5일', '5일 연속 출석하면 복권 5장을 받을 수 있어요', 'attendance', 5, 5, 25, true)
) AS t(name, description, reward_type, required_value, reward_value, order_index, is_active)
WHERE NOT EXISTS (SELECT 1 FROM rewards WHERE name = t.name);

-- ========================================
-- 8. 기존 테이블과 새 테이블 연결
-- ========================================

-- 기존 user_roles를 admin_users와 연결
INSERT INTO admin_users (uid, admin_role, is_active)
SELECT uid, 'admin', true
FROM user_roles 
WHERE role = 'admin'
AND NOT EXISTS (SELECT 1 FROM admin_users WHERE uid = user_roles.uid);

-- 기존 analytics_events를 app_events로 마이그레이션
INSERT INTO app_events (uid, event_name, event_category, event_data, created_at)
SELECT 
  uid,
  event_name,
  CASE 
    WHEN event_name LIKE '%login%' OR event_name LIKE '%auth%' THEN 'navigation'
    WHEN event_name LIKE '%click%' OR event_name LIKE '%tap%' THEN 'interaction'
    WHEN event_name LIKE '%error%' THEN 'error'
    WHEN event_name LIKE '%performance%' THEN 'performance'
    ELSE 'business'
  END as event_category,
  COALESCE(parameters, '{}'::jsonb) as event_data,
  created_at
FROM analytics_events
WHERE NOT EXISTS (SELECT 1 FROM app_events WHERE app_events.uid = analytics_events.uid);

-- ========================================
-- 9. 댓글 및 문서화
-- ========================================

COMMENT ON TABLE rewards IS 'Reward definitions and conditions for user activities';
COMMENT ON TABLE user_rewards IS 'User reward history and claims';
COMMENT ON TABLE user_activities IS 'User activity logging (steps, ads, attendance)';
COMMENT ON TABLE app_events IS 'App event logging (navigation, interactions, errors)';
COMMENT ON TABLE admin_users IS 'Admin user management with role-based permissions';
COMMENT ON TABLE lottery_results IS 'Lottery results and statistics by tier';

-- ========================================
-- MIGRATION COMPLETE
-- ========================================
