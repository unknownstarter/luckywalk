# LuckyWalk Supabase 백엔드 아키텍처 설계

**작성일**: 2025-01-17 01:30:00 KST  
**버전**: v1.0.0  
**상태**: 설계 완료  

## 📋 개요

LuckyWalk 앱의 백엔드 시스템을 위한 Supabase 데이터베이스 스키마, 인증 시스템, 로깅 시스템, 백오피스 기능을 종합적으로 설계합니다.

## 🏗️ 전체 아키텍처

```
┌─────────────────────────────────────────────────────────────┐
│                    LuckyWalk Backend                        │
├─────────────────────────────────────────────────────────────┤
│  Frontend (Flutter)                                         │
│  ├── 인증 (카카오, 애플)                                      │
│  ├── 사용자 행동 추적                                        │
│  ├── 복권 응모                                              │
│  └── 당첨 결과 확인                                         │
├─────────────────────────────────────────────────────────────┤
│  Supabase Backend                                           │
│  ├── PostgreSQL Database                                    │
│  │   ├── 사용자 관리 (users, profiles)                      │
│  │   ├── 복권 시스템 (lottery_rounds, tickets)               │
│  │   ├── 보상 시스템 (rewards, user_rewards)                │
│  │   ├── 로깅 시스템 (logs, events, analytics)              │
│  │   └── 백오피스 (admin_users, lottery_results)            │
│  ├── Authentication                                         │
│  │   ├── 카카오 로그인                                       │
│  │   ├── 애플 로그인                                         │
│  │   └── 세션 관리                                           │
│  ├── Row Level Security (RLS)                               │
│  │   ├── 사용자별 데이터 접근 제어                           │
│  │   ├── 관리자 권한 분리                                   │
│  │   └── API 보안                                           │
│  └── Edge Functions                                          │
│      ├── 복권 생성 로직                                      │
│      ├── 당첨자 선정 로직                                    │
│      ├── 보상 지급 로직                                      │
│      └── 통계 생성 로직                                      │
└─────────────────────────────────────────────────────────────┘
```

## 🗄️ 데이터베이스 스키마

### **1. 사용자 관리 테이블**

#### **users (Supabase Auth 기본 테이블 확장)**
```sql
-- Supabase Auth의 auth.users 테이블을 확장
CREATE TABLE public.users (
  id UUID REFERENCES auth.users(id) PRIMARY KEY,
  email TEXT,
  phone TEXT,
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  last_login_at TIMESTAMP WITH TIME ZONE,
  is_active BOOLEAN DEFAULT true,
  is_verified BOOLEAN DEFAULT false,
  
  -- 소셜 로그인 정보
  kakao_id TEXT UNIQUE,
  apple_id TEXT UNIQUE,
  
  -- 사용자 상태
  status TEXT DEFAULT 'active' CHECK (status IN ('active', 'suspended', 'deleted')),
  
  -- KYC 정보 (암호화)
  kyc_data JSONB,
  kyc_verified_at TIMESTAMP WITH TIME ZONE,
  
  -- 마케팅 동의
  marketing_consent BOOLEAN DEFAULT false,
  push_notification_consent BOOLEAN DEFAULT true,
  
  -- 인덱스
  CONSTRAINT users_email_unique UNIQUE (email),
  CONSTRAINT users_phone_unique UNIQUE (phone)
);

-- RLS 정책
ALTER TABLE public.users ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.users
  FOR SELECT USING (auth.uid() = id);

CREATE POLICY "Users can update own profile" ON public.users
  FOR UPDATE USING (auth.uid() = id);
```

#### **user_profiles (사용자 프로필)**
```sql
CREATE TABLE public.user_profiles (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- 기본 정보
  nickname TEXT NOT NULL,
  profile_image_url TEXT,
  birth_year INTEGER,
  gender TEXT CHECK (gender IN ('male', 'female', 'other', 'prefer_not_to_say')),
  
  -- 앱 설정
  language TEXT DEFAULT 'ko' CHECK (language IN ('ko', 'en')),
  timezone TEXT DEFAULT 'Asia/Seoul',
  notification_settings JSONB DEFAULT '{}',
  
  -- 게임 통계
  total_steps BIGINT DEFAULT 0,
  total_ad_views INTEGER DEFAULT 0,
  total_attendance_days INTEGER DEFAULT 0,
  total_tickets_purchased INTEGER DEFAULT 0,
  total_tickets_won INTEGER DEFAULT 0,
  total_prize_amount BIGINT DEFAULT 0,
  
  -- 레벨 시스템
  current_level INTEGER DEFAULT 1,
  current_exp BIGINT DEFAULT 0,
  next_level_exp BIGINT DEFAULT 1000,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT user_profiles_user_id_unique UNIQUE (user_id),
  CONSTRAINT user_profiles_nickname_length CHECK (LENGTH(nickname) >= 2 AND LENGTH(nickname) <= 20)
);

-- RLS 정책
ALTER TABLE public.user_profiles ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own profile" ON public.user_profiles
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own profile" ON public.user_profiles
  FOR UPDATE USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own profile" ON public.user_profiles
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

### **2. 복권 시스템 테이블**

#### **lottery_rounds (로또 회차)**
```sql
CREATE TABLE public.lottery_rounds (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  round_number INTEGER NOT NULL UNIQUE,
  
  -- 회차 정보
  draw_date DATE NOT NULL,
  submission_deadline TIMESTAMP WITH TIME ZONE NOT NULL,
  announcement_time TIMESTAMP WITH TIME ZONE NOT NULL,
  
  -- 당첨 번호
  winning_numbers INTEGER[] DEFAULT '{}',
  bonus_number INTEGER,
  
  -- 통계
  total_tickets_sold INTEGER DEFAULT 0,
  total_participants INTEGER DEFAULT 0,
  total_prize_pool BIGINT DEFAULT 0,
  
  -- 상태
  status TEXT DEFAULT 'upcoming' CHECK (status IN ('upcoming', 'active', 'closed', 'completed')),
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT lottery_rounds_round_number_positive CHECK (round_number > 0),
  CONSTRAINT lottery_rounds_winning_numbers_length CHECK (array_length(winning_numbers, 1) = 6),
  CONSTRAINT lottery_rounds_winning_numbers_range CHECK (
    array_length(winning_numbers, 1) = 6 AND
    winning_numbers <@ ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45]
  )
);

-- RLS 정책
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
```

#### **user_tickets (사용자 복권)**
```sql
CREATE TABLE public.user_tickets (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  round_id UUID REFERENCES public.lottery_rounds(id) ON DELETE CASCADE,
  
  -- 복권 정보
  ticket_numbers INTEGER[] NOT NULL,
  ticket_type TEXT DEFAULT 'manual' CHECK (ticket_type IN ('manual', 'auto')),
  
  -- 구매 정보
  purchase_price BIGINT DEFAULT 0,
  purchase_method TEXT DEFAULT 'free' CHECK (purchase_method IN ('free', 'paid', 'reward')),
  
  -- 당첨 정보
  is_winner BOOLEAN DEFAULT false,
  prize_tier INTEGER DEFAULT 0, -- 0: 미당첨, 1: 1등, 2: 2등, ..., 6: 6등
  prize_amount BIGINT DEFAULT 0,
  matched_numbers INTEGER DEFAULT 0,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT user_tickets_numbers_length CHECK (array_length(ticket_numbers, 1) = 6),
  CONSTRAINT user_tickets_numbers_range CHECK (
    array_length(ticket_numbers, 1) = 6 AND
    ticket_numbers <@ ARRAY[1,2,3,4,5,6,7,8,9,10,11,12,13,14,15,16,17,18,19,20,21,22,23,24,25,26,27,28,29,30,31,32,33,34,35,36,37,38,39,40,41,42,43,44,45]
  ),
  CONSTRAINT user_tickets_prize_tier_range CHECK (prize_tier >= 0 AND prize_tier <= 6)
);

-- 인덱스
CREATE INDEX idx_user_tickets_user_id ON public.user_tickets(user_id);
CREATE INDEX idx_user_tickets_round_id ON public.user_tickets(round_id);
CREATE INDEX idx_user_tickets_created_at ON public.user_tickets(created_at);
CREATE INDEX idx_user_tickets_is_winner ON public.user_tickets(is_winner);

-- RLS 정책
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
```

### **3. 보상 시스템 테이블**

#### **rewards (보상 정의)**
```sql
CREATE TABLE public.rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  
  -- 보상 정보
  name TEXT NOT NULL,
  description TEXT,
  reward_type TEXT NOT NULL CHECK (reward_type IN ('steps', 'ad_view', 'attendance', 'purchase', 'referral')),
  
  -- 보상 조건
  required_value INTEGER NOT NULL, -- 걸음수, 광고 시청 횟수, 출석일수 등
  reward_value INTEGER NOT NULL, -- 지급되는 복권 수량
  
  -- 순서 및 활성화
  order_index INTEGER NOT NULL,
  is_active BOOLEAN DEFAULT true,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT rewards_required_value_positive CHECK (required_value > 0),
  CONSTRAINT rewards_reward_value_positive CHECK (reward_value > 0)
);

-- RLS 정책
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
```

#### **user_rewards (사용자 보상 기록)**
```sql
CREATE TABLE public.user_rewards (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  reward_id UUID REFERENCES public.rewards(id) ON DELETE CASCADE,
  
  -- 보상 정보
  reward_type TEXT NOT NULL,
  reward_value INTEGER NOT NULL,
  earned_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 상태
  is_claimed BOOLEAN DEFAULT false,
  claimed_at TIMESTAMP WITH TIME ZONE,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT user_rewards_reward_value_positive CHECK (reward_value > 0)
);

-- 인덱스
CREATE INDEX idx_user_rewards_user_id ON public.user_rewards(user_id);
CREATE INDEX idx_user_rewards_earned_at ON public.user_rewards(earned_at);
CREATE INDEX idx_user_rewards_is_claimed ON public.user_rewards(is_claimed);

-- RLS 정책
ALTER TABLE public.user_rewards ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own rewards" ON public.user_rewards
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can update own rewards" ON public.user_rewards
  FOR UPDATE USING (auth.uid() = user_id);
```

### **4. 로깅 시스템 테이블**

#### **user_activities (사용자 활동 로그)**
```sql
CREATE TABLE public.user_activities (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- 활동 정보
  activity_type TEXT NOT NULL CHECK (activity_type IN (
    'step_count', 'ad_view', 'attendance', 'ticket_purchase', 
    'ticket_win', 'login', 'logout', 'app_open', 'app_close'
  )),
  activity_value INTEGER DEFAULT 0,
  activity_data JSONB DEFAULT '{}',
  
  -- 위치 정보 (선택적)
  latitude DECIMAL(10, 8),
  longitude DECIMAL(11, 8),
  location_accuracy DECIMAL(8, 2),
  
  -- 디바이스 정보
  device_type TEXT, -- 'ios', 'android', 'web'
  app_version TEXT,
  os_version TEXT,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT user_activities_activity_value_positive CHECK (activity_value >= 0)
);

-- 인덱스
CREATE INDEX idx_user_activities_user_id ON public.user_activities(user_id);
CREATE INDEX idx_user_activities_activity_type ON public.user_activities(activity_type);
CREATE INDEX idx_user_activities_created_at ON public.user_activities(created_at);

-- RLS 정책
ALTER TABLE public.user_activities ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own activities" ON public.user_activities
  FOR SELECT USING (auth.uid() = user_id);

CREATE POLICY "Users can insert own activities" ON public.user_activities
  FOR INSERT WITH CHECK (auth.uid() = user_id);
```

#### **app_events (앱 이벤트 로그)**
```sql
CREATE TABLE public.app_events (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE SET NULL,
  
  -- 이벤트 정보
  event_name TEXT NOT NULL,
  event_category TEXT NOT NULL CHECK (event_category IN (
    'navigation', 'interaction', 'error', 'performance', 'business'
  )),
  event_data JSONB DEFAULT '{}',
  
  -- 세션 정보
  session_id TEXT,
  screen_name TEXT,
  screen_path TEXT,
  
  -- 사용자 정보
  user_agent TEXT,
  ip_address INET,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT app_events_event_name_not_empty CHECK (LENGTH(event_name) > 0)
);

-- 인덱스
CREATE INDEX idx_app_events_user_id ON public.app_events(user_id);
CREATE INDEX idx_app_events_event_name ON public.app_events(event_name);
CREATE INDEX idx_app_events_event_category ON public.app_events(event_category);
CREATE INDEX idx_app_events_created_at ON public.app_events(created_at);
CREATE INDEX idx_app_events_session_id ON public.app_events(session_id);

-- RLS 정책
ALTER TABLE public.app_events ENABLE ROW LEVEL SECURITY;

CREATE POLICY "Users can view own events" ON public.app_events
  FOR SELECT USING (auth.uid() = user_id OR user_id IS NULL);

CREATE POLICY "Users can insert events" ON public.app_events
  FOR INSERT WITH CHECK (auth.uid() = user_id OR user_id IS NULL);
```

### **5. 백오피스 시스템 테이블**

#### **admin_users (관리자 사용자)**
```sql
CREATE TABLE public.admin_users (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  user_id UUID REFERENCES public.users(id) ON DELETE CASCADE,
  
  -- 관리자 정보
  admin_role TEXT NOT NULL CHECK (admin_role IN ('super_admin', 'admin', 'moderator')),
  permissions JSONB DEFAULT '{}',
  
  -- 상태
  is_active BOOLEAN DEFAULT true,
  last_login_at TIMESTAMP WITH TIME ZONE,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  
  -- 제약조건
  CONSTRAINT admin_users_user_id_unique UNIQUE (user_id)
);

-- RLS 정책
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
```

#### **lottery_results (당첨 결과)**
```sql
CREATE TABLE public.lottery_results (
  id UUID DEFAULT gen_random_uuid() PRIMARY KEY,
  round_id UUID REFERENCES public.lottery_rounds(id) ON DELETE CASCADE,
  
  -- 당첨 통계
  total_winners INTEGER DEFAULT 0,
  total_prize_amount BIGINT DEFAULT 0,
  
  -- 등급별 당첨 통계
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
  
  -- 처리 상태
  status TEXT DEFAULT 'pending' CHECK (status IN ('pending', 'processing', 'completed', 'failed')),
  processed_at TIMESTAMP WITH TIME ZONE,
  
  -- 메타데이터
  created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
  updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- RLS 정책
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
```

## 🔐 인증 시스템 설계

### **1. 카카오 로그인 플로우**
```typescript
// Edge Function: /auth/kakao
export default async function handler(req: Request) {
  const { code, state } = await req.json();
  
  // 1. 카카오 토큰 교환
  const kakaoToken = await exchangeKakaoCode(code);
  
  // 2. 카카오 사용자 정보 조회
  const kakaoUser = await getKakaoUserInfo(kakaoToken);
  
  // 3. Supabase 사용자 생성/업데이트
  const { data: user, error } = await supabase.auth.signInWithPassword({
    email: kakaoUser.email,
    password: generateRandomPassword(),
  });
  
  // 4. 사용자 프로필 업데이트
  await supabase
    .from('users')
    .update({
      kakao_id: kakaoUser.id,
      last_login_at: new Date().toISOString(),
    })
    .eq('id', user.user.id);
  
  return new Response(JSON.stringify({ user, session }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
```

### **2. 애플 로그인 플로우**
```typescript
// Edge Function: /auth/apple
export default async function handler(req: Request) {
  const { identityToken, authorizationCode } = await req.json();
  
  // 1. 애플 ID 토큰 검증
  const appleUser = await verifyAppleToken(identityToken);
  
  // 2. Supabase 사용자 생성/업데이트
  const { data: user, error } = await supabase.auth.signInWithPassword({
    email: appleUser.email,
    password: generateRandomPassword(),
  });
  
  // 3. 사용자 프로필 업데이트
  await supabase
    .from('users')
    .update({
      apple_id: appleUser.sub,
      last_login_at: new Date().toISOString(),
    })
    .eq('id', user.user.id);
  
  return new Response(JSON.stringify({ user, session }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
```

## 📊 로깅 시스템 설계

### **1. 사용자 행동 추적**
```typescript
// Flutter에서 사용할 로깅 함수들
class AnalyticsService {
  // 걸음수 로깅
  static async logStepCount(userId: string, stepCount: number) {
    await supabase.from('user_activities').insert({
      user_id: userId,
      activity_type: 'step_count',
      activity_value: stepCount,
      activity_data: {
        timestamp: new Date().toISOString(),
        source: 'health_kit', // 또는 'google_fit'
      },
    });
  }
  
  // 광고 시청 로깅
  static async logAdView(userId: string, adId: string, duration: number) {
    await supabase.from('user_activities').insert({
      user_id: userId,
      activity_type: 'ad_view',
      activity_value: duration,
      activity_data: {
        ad_id: adId,
        ad_type: 'rewarded_video',
        timestamp: new Date().toISOString(),
      },
    });
  }
  
  // 출석체크 로깅
  static async logAttendance(userId: string) {
    await supabase.from('user_activities').insert({
      user_id: userId,
      activity_type: 'attendance',
      activity_value: 1,
      activity_data: {
        timestamp: new Date().toISOString(),
        streak_count: await getCurrentStreak(userId),
      },
    });
  }
}
```

### **2. 앱 이벤트 추적**
```typescript
// 앱 이벤트 로깅
class EventLogger {
  // 화면 조회 이벤트
  static async logScreenView(screenName: string, screenPath: string) {
    await supabase.from('app_events').insert({
      event_name: 'screen_view',
      event_category: 'navigation',
      event_data: {
        screen_name: screenName,
        screen_path: screenPath,
        timestamp: new Date().toISOString(),
      },
    });
  }
  
  // 버튼 클릭 이벤트
  static async logButtonClick(buttonName: string, screenName: string) {
    await supabase.from('app_events').insert({
      event_name: 'button_click',
      event_category: 'interaction',
      event_data: {
        button_name: buttonName,
        screen_name: screenName,
        timestamp: new Date().toISOString(),
      },
    });
  }
  
  // 에러 이벤트
  static async logError(error: Error, context: string) {
    await supabase.from('app_events').insert({
      event_name: 'error',
      event_category: 'error',
      event_data: {
        error_message: error.message,
        error_stack: error.stack,
        context: context,
        timestamp: new Date().toISOString(),
      },
    });
  }
}
```

## 🏢 백오피스 시스템 설계

### **1. 당첨번호 관리**
```typescript
// Edge Function: /admin/lottery/update-winning-numbers
export default async function handler(req: Request) {
  const { roundNumber, winningNumbers, bonusNumber } = await req.json();
  
  // 1. 관리자 권한 확인
  const adminUser = await verifyAdminUser(req);
  if (!adminUser) {
    return new Response('Unauthorized', { status: 401 });
  }
  
  // 2. 당첨번호 업데이트
  const { error } = await supabase
    .from('lottery_rounds')
    .update({
      winning_numbers: winningNumbers,
      bonus_number: bonusNumber,
      status: 'completed',
      updated_at: new Date().toISOString(),
    })
    .eq('round_number', roundNumber);
  
  if (error) {
    return new Response(JSON.stringify({ error: error.message }), {
      status: 400,
      headers: { 'Content-Type': 'application/json' },
    });
  }
  
  // 3. 당첨자 선정 프로세스 시작
  await processWinners(roundNumber, winningNumbers, bonusNumber);
  
  return new Response(JSON.stringify({ success: true }), {
    headers: { 'Content-Type': 'application/json' },
  });
}
```

### **2. 당첨자 선정 로직**
```typescript
// Edge Function: /admin/lottery/process-winners
async function processWinners(roundNumber: number, winningNumbers: number[], bonusNumber: number) {
  // 1. 해당 회차의 모든 복권 조회
  const { data: tickets, error } = await supabase
    .from('user_tickets')
    .select('*')
    .eq('round_id', roundNumber);
  
  if (error) throw error;
  
  // 2. 각 복권의 당첨 등급 계산
  const winners = tickets.map(ticket => {
    const matchedNumbers = calculateMatchedNumbers(ticket.ticket_numbers, winningNumbers);
    const prizeTier = calculatePrizeTier(matchedNumbers, bonusNumber);
    
    return {
      ...ticket,
      is_winner: prizeTier > 0,
      prize_tier: prizeTier,
      matched_numbers: matchedNumbers,
      prize_amount: calculatePrizeAmount(prizeTier),
    };
  });
  
  // 3. 당첨자 정보 업데이트
  for (const winner of winners) {
    await supabase
      .from('user_tickets')
      .update({
        is_winner: winner.is_winner,
        prize_tier: winner.prize_tier,
        matched_numbers: winner.matched_numbers,
        prize_amount: winner.prize_amount,
        updated_at: new Date().toISOString(),
      })
      .eq('id', winner.id);
  }
  
  // 4. 당첨 통계 생성
  await generateLotteryResults(roundNumber, winners);
}
```

### **3. 통계 및 분석**
```sql
-- 당첨 통계 뷰
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

-- 사용자 통계 뷰
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
```

## 🔒 보안 및 권한 관리

### **1. RLS 정책 요약**
- **사용자 데이터**: 본인 데이터만 접근 가능
- **복권 데이터**: 본인 복권만 조회 가능
- **관리자 기능**: admin_users 테이블의 활성 관리자만 접근
- **공개 데이터**: 복권 회차, 당첨 결과 등은 모든 사용자 조회 가능

### **2. API 보안**
- **JWT 토큰**: Supabase Auth의 JWT 토큰 사용
- **세션 관리**: 30일 세션 만료
- **권한 검증**: 각 API 호출 시 사용자 권한 확인
- **데이터 암호화**: 민감한 정보는 암호화 저장

### **3. 데이터 보호**
- **개인정보**: KYC 데이터 암호화
- **로그 데이터**: 사용자 행동 데이터는 익명화
- **백업**: 정기적인 데이터 백업
- **감사**: 모든 관리자 작업 로그 기록

## 📈 성능 최적화

### **1. 인덱스 전략**
- **사용자 ID**: 모든 사용자 관련 테이블에 인덱스
- **시간 기반**: created_at, updated_at 컬럼에 인덱스
- **복합 인덱스**: 자주 함께 조회되는 컬럼들에 복합 인덱스
- **부분 인덱스**: 특정 조건의 데이터만 인덱싱

### **2. 쿼리 최적화**
- **뷰 활용**: 복잡한 조인 쿼리는 뷰로 생성
- **페이지네이션**: 대용량 데이터는 페이지네이션 적용
- **캐싱**: 자주 조회되는 데이터는 Redis 캐싱
- **비동기 처리**: 무거운 작업은 백그라운드에서 처리

### **3. 확장성 고려**
- **파티셔닝**: 시간 기반으로 테이블 파티셔닝
- **읽기 전용 복제**: 읽기 전용 쿼리는 복제본 사용
- **CDN**: 정적 자원은 CDN 사용
- **로드 밸런싱**: 트래픽 분산

---

**마지막 업데이트**: 2025-01-17 01:30:00 KST  
**다음 검토 예정일**: 2025-01-24  
**문서 버전**: v1.0.0
