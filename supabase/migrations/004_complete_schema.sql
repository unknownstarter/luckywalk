-- LuckyWalk Complete Database Schema
-- Migration: 004_complete_schema.sql
-- Created: 2025-01-17 01:30:00 KST
-- Description: Complete database schema for LuckyWalk application

-- Enable necessary extensions
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";
CREATE EXTENSION IF NOT EXISTS "pgcrypto";

-- ========================================
-- 1. USERS MANAGEMENT TABLES
-- ========================================

-- Users table (extends Supabase Auth)
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  
  -- Social login information
  kakao_id TEXT UNIQUE,
  apple_id TEXT UNIQUE,
  
  -- User status
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
  
  -- KYC information (encrypted)
  kyc_data JSONB,
  kyc_verified_at TIMESTAMP WITH TIME ZONE,
  
  -- Marketing consent
  marketing_consent BOOLEAN DEFAULT false,
  push_notification_consent BOOLEAN DEFAULT true,
  
  -- Constraints
  CONSTRAINT users_email_unique UNIQUE (email),
  CONSTRAINT users_phone_unique UNIQUE (phone)
);

-- User profiles table
CREATE TABLE public.user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Basic information
  nickname TEXT NOT NULL,
  profile_image_url TEXT,
  birth_year INTEGER,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  
  -- App settings
  language TEXT DEFAULT 'ko' CHECK (language IN ('ko', 'en')),
  timezone TEXT DEFAULT 'Asia/Seoul',
  notification_settings JSONB DEFAULT '{}',
  
  -- Game statistics
  total_steps BIGINT DEFAULT 0,
  total_ad_views INTEGER DEFAULT 0,
  total_attendance_days INTEGER DEFAULT 0,
  total_tickets_purchased INTEGER DEFAULT 0,
  total_tickets_won INTEGER DEFAULT 0,
  total_prize_amount BIGINT DEFAULT 0,
  
  -- Level system
  current_level INTEGER DEFAULT 1,
  current_exp BIGINT DEFAULT 0,
  next_level_exp BIGINT DEFAULT 1000,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT user_profiles_user_id_unique UNIQUE (user_id),
  CONSTRAINT user_profiles_nickname_length CHECK (LENGTH(nickname) >= 2 AND LENGTH(nickname) <= 20)
);

-- ========================================
-- 2. LOTTERY SYSTEM TABLES
-- ========================================

-- Lottery rounds table
CREATE TABLE public.lottery_rounds (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  round_number INTEGER NOT NULL UNIQUE,
  
  -- Round information
  draw_date DATE NOT NULL,
  submission_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  announcement_time TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- Winning numbers
  winning_numbers INTEGER[] DEFAULT '{}',
  bonus_number INTEGER,
  
  -- Statistics
  total_tickets_sold INTEGER DEFAULT 0,
  total_participants INTEGER DEFAULT 0,
  total_prize_pool BIGINT DEFAULT 0,
  
  -- Status
  status TEXT DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'closed', 'completed')),
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT lottery_rounds_round_number_positive CHECK (round_number > 0),
  CONSTRAINT lottery_rounds_winning_numbers_length CHECK (array_length(winning_numbers, 1) = 6),
  CONSTRAINT lottery_rounds_winning_numbers_range CHECK (
    array_length(winning_numbers, 1) = 6 AND
    winning_numbers <@ ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45]
  )
);

-- User tickets table
CREATE TABLE public.user_tickets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  round_id UUID REFERENCES public.lottery_rounds(id) ON DELETE CASCADE,
  
  -- Ticket information
  ticket_numbers INTEGER[] NOT NULL,
  ticket_type TEXT DEFAULT 'manual' CHECK (ticket_type IN ('manual', 'auto')),
  
  -- Purchase information
  purchase_price BIGINT DEFAULT 0,
  purchase_method TEXT DEFAULT 'free' CHECK (purchase_method IN ('free', 'paid', 'reward')),
  
  -- Winning information
  is_winner BOOLEAN DEFAULT false,
  prize_tier INTEGER DEFAULT 0, -- 0: no win, 1: 1st place, 2: 2nd place, ..., 6: 6th place
  prize_amount BIGINT DEFAULT 0,
  matched_numbers INTEGER DEFAULT 0,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT user_tickets_numbers_length CHECK (array_length(ticket_numbers, 1) = 6),
  CONSTRAINT user_tickets_numbers_range CHECK (
    array_length(ticket_numbers, 1) = 6 AND
    ticket_numbers <@ ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45]
  ),
  CONSTRAINT user_tickets_prize_tier_range CHECK (prize_tier >= 0 AND prize_tier <= 6)
);

-- ========================================
-- 3. REWARD SYSTEM TABLES
-- ========================================

-- Rewards definition table
CREATE TABLE public.rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- Reward information
  name TEXT NOT NULL,
  description TEXT,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('steps', 'ad_view', 'attendance', 'purchase', 'referral')),
  
  -- Reward conditions
  required_value INTEGER NOT NULL, -- steps, ad views, attendance days, etc.
  reward_value INTEGER NOT NULL, -- number of lottery tickets to give
  
  -- Order and activation
  order_index INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT rewards_required_value_positive CHECK (required_value > 0),
  CONSTRAINT rewards_reward_value_positive CHECK (reward_value > 0)
);

-- User rewards table
CREATE TABLE public.user_rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE,
  
  -- Reward information
  reward_type TEXT NOT NULL,
  reward_value INTEGER NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Status
  is_claimed BOOLEAN DEFAULT false,
  claimed_at TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT user_rewards_reward_value_positive CHECK (reward_value > 0)
);

-- ========================================
-- 4. LOGGING SYSTEM TABLES
-- ========================================

-- User activities table
CREATE TABLE public.user_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Activity information
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'step_count', 'ad_view', 'attendance', 'ticket_purchase', 
    'ticket_win', 'login', 'logout', 'app_open', 'app_close'
  )),
  activity_value INTEGER DEFAULT 0,
  activity_data JSONB DEFAULT '{}',
  
  -- Location information (optional)
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location_accuracy DECIMAL(8, 2),
  
  -- Device information
  device_type TEXT, -- 'ios', 'android', 'web'
  app_version TEXT,
  os_version TEXT,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT user_activities_activity_value_positive CHECK (activity_value >= 0)
);

-- App events table
CREATE TABLE public.app_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  
  -- Event information
  event_name TEXT NOT NULL,
  event_category TEXT NOT NULL CHECK (event_category IN (
    'navigation', 'interaction', 'error', 'performance', 'business'
  )),
  event_data JSONB DEFAULT '{}',
  
  -- Session information
  session_id TEXT,
  screen_name TEXT,
  screen_path TEXT,
  
  -- User information
  user_agent TEXT,
  ip_address INET,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT app_events_event_name_not_empty CHECK (LENGTH(event_name) > 0)
);

-- ========================================
-- 5. ADMIN SYSTEM TABLES
-- ========================================

-- Admin users table
CREATE TABLE public.admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- Admin information
  admin_role TEXT NOT NULL CHECK (admin_role IN ('super_admin', 'admin', 'moderator')),
  permissions JSONB DEFAULT '{}',
  
  -- Status
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- Constraints
  CONSTRAINT admin_users_user_id_unique UNIQUE (user_id)
);

-- Lottery results table
CREATE TABLE public.lottery_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  round_id UUID REFERENCES public.lottery_rounds(id) ON DELETE CASCADE,
  
  -- Winning statistics
  total_winners INTEGER DEFAULT 0,
  total_prize_amount BIGINT DEFAULT 0,
  
  -- Tier-wise winning statistics
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
  
  -- Processing status
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  processed_at TIMESTAMP WITH TIME ZONE,
  
  -- Metadata
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- ========================================
-- 6. INDEXES
-- ========================================

-- User tickets indexes
CREATE INDEX idx_user_tickets_user_id ON public.user_tickets(user_id);
CREATE INDEX idx_user_tickets_round_id ON public.user_tickets(round_id);
CREATE INDEX idx_user_tickets_created_at ON public.user_tickets(created_at);
CREATE INDEX idx_user_tickets_is_winner ON public.user_tickets(is_winner);

-- User activities indexes
CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_activity_type ON public.user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON public.user_activities(created_at);

-- App events indexes
CREATE INDEX idx_app_events_user_id ON public.app_events(user_id);
CREATE INDEX idx_app_events_event_name ON public.app_events(event_name);
CREATE INDEX idx_app_events_event_category ON public.app_events(event_category);
CREATE INDEX idx_app_events_created_at ON public.app_events(created_at);
CREATE INDEX idx_app_events_session_id ON public.app_events(session_id);

-- User rewards indexes
CREATE INDEX idx_user_rewards_user_id ON public.user_rewards(user_id);
CREATE INDEX idx_user_rewards_earned_at ON public.user_rewards(earned_at);
CREATE INDEX idx_user_rewards_is_claimed ON public.user_rewards(is_claimed);

-- ========================================
-- 7. ROW LEVEL SECURITY (RLS) POLICIES
-- ========================================

-- Users table RLS
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);

-- User profiles table RLS
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- Lottery rounds table RLS
ALTER TABLE public.lottery_rounds ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lottery rounds" ON public.lottery_rounds
  FOR SELECT USING (true);

CREATE POLICY "Only admins can modify lottery rounds" ON public.lottery_rounds
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- User tickets table RLS
ALTER TABLE public.user_tickets ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own tickets" ON public.user_tickets
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own tickets" ON public.user_tickets
  FOR INSERT WITH CHECK (auth.uid() = user_id);

CREATE POLICY "Only admins can update tickets" ON public.user_tickets
  FOR UPDATE USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- Rewards table RLS
ALTER TABLE public.rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view active rewards" ON public.rewards
  FOR SELECT USING (is_active = true);

CREATE POLICY "Only admins can modify rewards" ON public.rewards
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- User rewards table RLS
ALTER TABLE public.user_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own rewards" ON public.user_rewards
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own rewards" ON public.user_rewards
  FOR UPDATE USING (auth.uid() = user_id);

-- User activities table RLS
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activities" ON public.user_activities
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities" ON public.user_activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);

-- App events table RLS
ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own events" ON public.app_events
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert events" ON public.app_events
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);

-- Admin users table RLS
ALTER TABLE public.admin_users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Only admins can view admin users" ON public.admin_users
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

CREATE POLICY "Only super admins can modify admin users" ON public.admin_users
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND admin_role = 'super_admin' AND is_active = true
    )
  );

-- Lottery results table RLS
ALTER TABLE public.lottery_results ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Anyone can view lottery results" ON public.lottery_results
  FOR SELECT USING (true);

CREATE POLICY "Only admins can modify lottery results" ON public.lottery_results
  FOR ALL USING (
    EXISTS (
      SELECT 1 FROM public.admin_users 
      WHERE user_id = auth.uid() AND is_active = true
    )
  );

-- ========================================
-- 8. FUNCTIONS AND TRIGGERS
-- ========================================

-- Function to update user profile statistics
CREATE OR REPLACE FUNCTION update_user_profile_stats()
RETURNS TRIGGER AS $$
BEGIN
  -- Update user profile statistics based on activity type
  IF NEW.activity_type = 'step_count' THEN
    UPDATE public.user_profiles 
    SET total_steps = total_steps + NEW.activity_value,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF NEW.activity_type = 'ad_view' THEN
    UPDATE public.user_profiles 
    SET total_ad_views = total_ad_views + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF NEW.activity_type = 'attendance' THEN
    UPDATE public.user_profiles 
    SET total_attendance_days = total_attendance_days + 1,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF NEW.activity_type = 'ticket_purchase' THEN
    UPDATE public.user_profiles 
    SET total_tickets_purchased = total_tickets_purchased + NEW.activity_value,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  ELSIF NEW.activity_type = 'ticket_win' THEN
    UPDATE public.user_profiles 
    SET total_tickets_won = total_tickets_won + 1,
        total_prize_amount = total_prize_amount + NEW.activity_value,
        updated_at = NOW()
    WHERE user_id = NEW.user_id;
  END IF;
  
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- Trigger to update user profile statistics
CREATE TRIGGER trigger_update_user_profile_stats
  AFTER INSERT ON public.user_activities
  FOR EACH ROW
  EXECUTE FUNCTION update_user_profile_stats();

-- Function to calculate matched numbers
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

-- Function to calculate prize tier
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
-- 9. VIEWS
-- ========================================

-- Lottery statistics view
CREATE VIEW lottery_statistics AS
SELECT 
  lr.round_number,
  lr.draw_date,
  lr.total_tickets_sold,
  lr.total_participants,
  lr.total_prize_pool,
  lr.winning_numbers,
  lr.bonus_number,
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
FROM lottery_rounds lr
JOIN lottery_results lres ON lr.id = lres.round_id
WHERE lr.status = 'completed';

-- User statistics view
CREATE VIEW user_statistics AS
SELECT 
  u.id,
  u.email,
  up.nickname,
  up.total_steps,
  up.total_ad_views,
  up.total_attendance_days,
  up.total_tickets_purchased,
  up.total_tickets_won,
  up.total_prize_amount,
  up.current_level,
  up.current_exp,
  COUNT(ut.id) as total_tickets,
  COUNT(CASE WHEN ut.is_winner = true THEN 1 END) as winning_tickets,
  SUM(ut.prize_amount) as total_prize_won
FROM users u
JOIN user_profiles up ON u.id = up.user_id
LEFT JOIN user_tickets ut ON u.id = ut.user_id
GROUP BY u.id, u.email, up.nickname, up.total_steps, up.total_ad_views, 
         up.total_attendance_days, up.total_tickets_purchased, up.total_tickets_won, 
         up.total_prize_amount, up.current_level, up.current_exp;

-- ========================================
-- 10. INITIAL DATA
-- ========================================

-- Insert default rewards
INSERT INTO public.rewards (name, description, reward_type, required_value, reward_value, order_index, is_active) VALUES
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
('출석체크 5일', '5일 연속 출석하면 복권 5장을 받을 수 있어요', 'attendance', 5, 5, 25, true);

-- ========================================
-- 11. COMMENTS
-- ========================================

COMMENT ON TABLE public.users IS 'Extended user information from Supabase Auth';
COMMENT ON TABLE public.user_profiles IS 'User profile and game statistics';
COMMENT ON TABLE public.lottery_rounds IS 'Lottery round information and winning numbers';
COMMENT ON TABLE public.user_tickets IS 'User lottery tickets and winning information';
COMMENT ON TABLE public.rewards IS 'Reward definitions and conditions';
COMMENT ON TABLE public.user_rewards IS 'User reward history and claims';
COMMENT ON TABLE public.user_activities IS 'User activity logging (steps, ads, attendance)';
COMMENT ON TABLE public.app_events IS 'App event logging (navigation, interactions, errors)';
COMMENT ON TABLE public.admin_users IS 'Admin user management';
COMMENT ON TABLE public.lottery_results IS 'Lottery results and statistics';

-- ========================================
-- MIGRATION COMPLETE
-- ========================================
