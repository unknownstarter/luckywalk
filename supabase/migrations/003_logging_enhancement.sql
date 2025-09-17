-- LuckyWalk 로깅 시스템 강화
-- 생성일: 2025-09-17 23:44:44 KST
-- 설명: 복권앱을 위한 상세 로깅 시스템

-- 복권 응모 로그 테이블
CREATE TABLE ticket_submission_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  ticket_count INTEGER NOT NULL,
  numbers JSONB NOT NULL, -- 응모한 번호들
  ip_address INET,
  user_agent TEXT,
  device_info JSONB,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 보상 지급 로그 테이블
CREATE TABLE reward_issuance_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  reward_type VARCHAR(50) NOT NULL, -- 'steps', 'ad', 'attendance', 'referral'
  reward_amount INTEGER NOT NULL,
  source_data JSONB, -- 걸음수, 광고 정보 등
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 당첨 결과 로그 테이블
CREATE TABLE winning_result_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID NOT NULL REFERENCES user_profiles(uid) ON DELETE CASCADE,
  round_id UUID NOT NULL REFERENCES rounds(id) ON DELETE CASCADE,
  ticket_id UUID NOT NULL REFERENCES tickets(id) ON DELETE CASCADE,
  winning_numbers INTEGER[6] NOT NULL,
  user_numbers INTEGER[6] NOT NULL,
  match_count INTEGER NOT NULL,
  bonus_match BOOLEAN NOT NULL,
  tier INTEGER NOT NULL,
  prize_amount INTEGER,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 보안 이벤트 로그 테이블
CREATE TABLE security_event_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID REFERENCES user_profiles(uid) ON DELETE SET NULL,
  event_type VARCHAR(50) NOT NULL, -- 'suspicious_activity', 'abuse_detected', 'login_anomaly'
  severity VARCHAR(20) NOT NULL DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  description TEXT NOT NULL,
  metadata JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- API 호출 로그 테이블
CREATE TABLE api_call_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID REFERENCES user_profiles(uid) ON DELETE SET NULL,
  endpoint VARCHAR(200) NOT NULL,
  method VARCHAR(10) NOT NULL,
  status_code INTEGER NOT NULL,
  response_time_ms INTEGER,
  request_size INTEGER,
  response_size INTEGER,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 에러 로그 테이블
CREATE TABLE error_logs (
  id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
  uid UUID REFERENCES user_profiles(uid) ON DELETE SET NULL,
  error_type VARCHAR(100) NOT NULL,
  error_message TEXT NOT NULL,
  stack_trace TEXT,
  context JSONB,
  ip_address INET,
  user_agent TEXT,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 인덱스 생성
CREATE INDEX idx_ticket_submission_logs_uid ON ticket_submission_logs(uid);
CREATE INDEX idx_ticket_submission_logs_round_id ON ticket_submission_logs(round_id);
CREATE INDEX idx_ticket_submission_logs_created_at ON ticket_submission_logs(created_at);

CREATE INDEX idx_reward_issuance_logs_uid ON reward_issuance_logs(uid);
CREATE INDEX idx_reward_issuance_logs_reward_type ON reward_issuance_logs(reward_type);
CREATE INDEX idx_reward_issuance_logs_created_at ON reward_issuance_logs(created_at);

CREATE INDEX idx_winning_result_logs_uid ON winning_result_logs(uid);
CREATE INDEX idx_winning_result_logs_round_id ON winning_result_logs(round_id);
CREATE INDEX idx_winning_result_logs_tier ON winning_result_logs(tier);

CREATE INDEX idx_security_event_logs_uid ON security_event_logs(uid);
CREATE INDEX idx_security_event_logs_event_type ON security_event_logs(event_type);
CREATE INDEX idx_security_event_logs_severity ON security_event_logs(severity);
CREATE INDEX idx_security_event_logs_created_at ON security_event_logs(created_at);

CREATE INDEX idx_api_call_logs_uid ON api_call_logs(uid);
CREATE INDEX idx_api_call_logs_endpoint ON api_call_logs(endpoint);
CREATE INDEX idx_api_call_logs_status_code ON api_call_logs(status_code);
CREATE INDEX idx_api_call_logs_created_at ON api_call_logs(created_at);

CREATE INDEX idx_error_logs_uid ON error_logs(uid);
CREATE INDEX idx_error_logs_error_type ON error_logs(error_type);
CREATE INDEX idx_error_logs_created_at ON error_logs(created_at);

-- RLS 활성화
ALTER TABLE ticket_submission_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE reward_issuance_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE winning_result_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_event_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE api_call_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE error_logs ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성
-- 사용자는 본인 관련 로그만 조회 가능
CREATE POLICY "Users can view own ticket submission logs" ON ticket_submission_logs
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can view own reward issuance logs" ON reward_issuance_logs
  FOR SELECT USING (auth.uid() = uid);

CREATE POLICY "Users can view own winning result logs" ON winning_result_logs
  FOR SELECT USING (auth.uid() = uid);

-- 관리자는 모든 로그 조회 가능
CREATE POLICY "Admins can view all ticket submission logs" ON ticket_submission_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all reward issuance logs" ON reward_issuance_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all winning result logs" ON winning_result_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all security event logs" ON security_event_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all api call logs" ON api_call_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

CREATE POLICY "Admins can view all error logs" ON error_logs
  FOR SELECT USING (
    EXISTS (
      SELECT 1 FROM user_roles 
      WHERE uid = auth.uid() AND role = 'admin'
    )
  );

-- 에러코드 및 이벤트코드 체계 추가
-- 에러코드 테이블
CREATE TABLE error_code_definitions (
  code VARCHAR(20) PRIMARY KEY,
  category VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  description TEXT NOT NULL,
  message TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 이벤트코드 테이블
CREATE TABLE event_code_definitions (
  code VARCHAR(20) PRIMARY KEY,
  category VARCHAR(50) NOT NULL,
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 보안코드 테이블
CREATE TABLE security_code_definitions (
  code VARCHAR(20) PRIMARY KEY,
  category VARCHAR(50) NOT NULL,
  severity VARCHAR(20) NOT NULL CHECK (severity IN ('low', 'medium', 'high', 'critical')),
  description TEXT NOT NULL,
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 에러코드 데이터 삽입
INSERT INTO error_code_definitions (code, category, severity, description, message) VALUES
-- 인증 관련 에러
('AUTH_001', 'authentication', 'high', '로그인 실패', '로그인에 실패했습니다.'),
('AUTH_002', 'authentication', 'medium', '토큰 만료', '로그인 세션이 만료되었습니다.'),
('AUTH_003', 'authentication', 'medium', '사용자 없음', '사용자를 찾을 수 없습니다.'),
('AUTH_004', 'authentication', 'high', '잘못된 인증 정보', '잘못된 인증 정보입니다.'),
('AUTH_005', 'authentication', 'critical', '계정 정지', '계정이 정지되었습니다.'),

-- 복권 관련 에러
('TICKET_001', 'lottery', 'medium', '복권 부족', '복권이 부족합니다.'),
('TICKET_002', 'lottery', 'high', '복권 응모 실패', '복권 응모에 실패했습니다.'),
('TICKET_003', 'lottery', 'medium', '잘못된 번호', '잘못된 번호입니다.'),
('TICKET_004', 'lottery', 'medium', '응모 기간 종료', '응모 기간이 종료되었습니다.'),
('TICKET_005', 'lottery', 'medium', '회차 없음', '회차를 찾을 수 없습니다.'),

-- 보상 관련 에러
('REWARD_001', 'reward', 'high', '보상 수령 실패', '보상 수령에 실패했습니다.'),
('REWARD_002', 'reward', 'low', '이미 수령한 보상', '이미 수령한 보상입니다.'),
('REWARD_003', 'reward', 'medium', '유효하지 않은 보상 소스', '유효하지 않은 보상 소스입니다.'),
('REWARD_004', 'reward', 'medium', '걸음수 부족', '걸음수가 부족합니다.'),
('REWARD_005', 'reward', 'medium', '광고 세션 만료', '광고 세션이 만료되었습니다.'),

-- 네트워크 관련 에러
('NETWORK_001', 'network', 'high', '네트워크 연결 실패', '네트워크 연결에 실패했습니다.'),
('NETWORK_002', 'network', 'medium', '네트워크 타임아웃', '네트워크 응답 시간이 초과되었습니다.'),
('NETWORK_003', 'network', 'high', '서버 오류', '서버 오류가 발생했습니다.'),
('NETWORK_004', 'network', 'medium', 'API 호출 한도 초과', 'API 호출 한도를 초과했습니다.'),
('NETWORK_005', 'network', 'medium', '서버 점검', '서버 점검 중입니다.'),

-- 보안 관련 에러
('SECURITY_001', 'security', 'critical', '어뷰징 감지', '어뷰징이 감지되었습니다.'),
('SECURITY_002', 'security', 'high', '의심스러운 활동', '의심스러운 활동이 감지되었습니다.'),
('SECURITY_003', 'security', 'medium', '유효하지 않은 요청', '유효하지 않은 요청입니다.'),
('SECURITY_004', 'security', 'medium', '요청 한도 초과', '요청 한도를 초과했습니다.'),
('SECURITY_005', 'security', 'high', '기기 차단', '차단된 기기입니다.'),

-- 시스템 관련 에러
('SYSTEM_001', 'system', 'critical', '시스템 점검', '시스템 점검 중입니다.'),
('SYSTEM_002', 'system', 'critical', '시스템 과부하', '시스템 과부하 상태입니다.'),
('SYSTEM_003', 'system', 'high', '시스템 설정 오류', '시스템 설정 오류가 발생했습니다.'),
('SYSTEM_004', 'system', 'critical', '시스템 리소스 부족', '시스템 리소스가 부족합니다.'),
('SYSTEM_005', 'system', 'high', '서비스 중단', '서비스가 일시적으로 중단되었습니다.');

-- 이벤트코드 데이터 삽입
INSERT INTO event_code_definitions (code, category, description) VALUES
-- 사용자 인증 이벤트
('USER_AUTH_001', 'authentication', '사용자 로그인'),
('USER_AUTH_002', 'authentication', '사용자 로그아웃'),
('USER_AUTH_003', 'authentication', '사용자 회원가입'),
('USER_AUTH_004', 'authentication', '온보딩 완료'),
('USER_AUTH_005', 'authentication', '프로필 업데이트'),

-- 복권 관련 이벤트
('TICKET_001', 'lottery', '복권 응모'),
('TICKET_002', 'lottery', '복권 응모 성공'),
('TICKET_003', 'lottery', '복권 응모 실패'),
('TICKET_004', 'lottery', '복권 조회'),
('TICKET_005', 'lottery', '복권 이력 조회'),

-- 보상 관련 이벤트
('REWARD_001', 'reward', '보상 수령'),
('REWARD_002', 'reward', '보상 수령 성공'),
('REWARD_003', 'reward', '보상 수령 실패'),
('REWARD_004', 'reward', '걸음수 보상 수령'),
('REWARD_005', 'reward', '광고 시청'),

-- 당첨 결과 이벤트
('WINNING_001', 'winning', '당첨 결과 조회'),
('WINNING_002', 'winning', '당첨 결과 확인'),
('WINNING_003', 'winning', '당첨 결과 공유'),
('WINNING_004', 'winning', 'KYC 인증 필요'),
('WINNING_005', 'winning', 'KYC 인증 제출'),

-- KYC 관련 이벤트
('KYC_001', 'kyc', 'KYC 시작'),
('KYC_002', 'kyc', 'KYC 제출'),
('KYC_003', 'kyc', 'KYC 승인'),
('KYC_004', 'kyc', 'KYC 거부'),
('KYC_005', 'kyc', 'KYC 서류 업로드'),

-- 추천 관련 이벤트
('REFERRAL_001', 'referral', '추천코드 생성'),
('REFERRAL_002', 'referral', '추천코드 공유'),
('REFERRAL_003', 'referral', '추천코드 사용'),
('REFERRAL_004', 'referral', '추천 초대'),
('REFERRAL_005', 'referral', '추천 수락'),

-- 광고 관련 이벤트
('AD_001', 'advertisement', '광고 로드'),
('AD_002', 'advertisement', '광고 표시'),
('AD_003', 'advertisement', '광고 클릭'),
('AD_004', 'advertisement', '광고 완료'),
('AD_005', 'advertisement', '광고 건너뛰기'),

-- 걸음수 관련 이벤트
('STEPS_001', 'steps', '걸음수 동기화'),
('STEPS_002', 'steps', '걸음수 권한 요청'),
('STEPS_003', 'steps', '걸음수 권한 허용'),
('STEPS_004', 'steps', '걸음수 권한 거부'),
('STEPS_005', 'steps', '걸음수 기준 달성'),

-- 네비게이션 이벤트
('NAV_001', 'navigation', '홈 화면 이동'),
('NAV_002', 'navigation', '응모 화면 이동'),
('NAV_003', 'navigation', '이력 화면 이동'),
('NAV_004', 'navigation', '프로필 화면 이동'),
('NAV_005', 'navigation', '설정 화면 이동'),

-- 앱 생명주기 이벤트
('APP_001', 'app_lifecycle', '앱 실행'),
('APP_002', 'app_lifecycle', '앱 재개'),
('APP_003', 'app_lifecycle', '앱 일시정지'),
('APP_004', 'app_lifecycle', '앱 백그라운드'),
('APP_005', 'app_lifecycle', '앱 포그라운드');

-- 보안코드 데이터 삽입
INSERT INTO security_code_definitions (code, category, severity, description) VALUES
-- 어뷰징 감지
('ABUSE_001', 'abuse', 'critical', '다중 계정 사용 감지'),
('ABUSE_002', 'abuse', 'high', '빠른 연속 액션 감지'),
('ABUSE_003', 'abuse', 'high', '가짜 걸음수 감지'),
('ABUSE_004', 'abuse', 'high', '광고 조작 감지'),
('ABUSE_005', 'abuse', 'high', '추천 사기 감지'),

-- 의심스러운 활동
('SUSPICIOUS_001', 'suspicious', 'high', '의심스러운 로그인 패턴'),
('SUSPICIOUS_002', 'suspicious', 'medium', '의심스러운 디바이스 변경'),
('SUSPICIOUS_003', 'suspicious', 'medium', '의심스러운 위치 변경'),
('SUSPICIOUS_004', 'suspicious', 'high', '의심스러운 행동 패턴'),
('SUSPICIOUS_005', 'suspicious', 'medium', '의심스러운 네트워크 패턴'),

-- 로그인 이상
('LOGIN_ANOMALY_001', 'login_anomaly', 'high', '다중 디바이스 로그인'),
('LOGIN_ANOMALY_002', 'login_anomaly', 'high', '빠른 로그인 시도'),
('LOGIN_ANOMALY_003', 'login_anomaly', 'medium', '로그인 실패 시도'),
('LOGIN_ANOMALY_004', 'login_anomaly', 'medium', '비정상적 위치 로그인'),
('LOGIN_ANOMALY_005', 'login_anomaly', 'medium', '비정상적 시간 로그인'),

-- 데이터 무결성
('DATA_INTEGRITY_001', 'data_integrity', 'critical', '데이터 변조 감지'),
('DATA_INTEGRITY_002', 'data_integrity', 'high', '데이터 손상 감지'),
('DATA_INTEGRITY_003', 'data_integrity', 'high', '데이터 불일치 감지'),
('DATA_INTEGRITY_004', 'data_integrity', 'medium', '데이터 검증 실패'),
('DATA_INTEGRITY_005', 'data_integrity', 'medium', '체크섬 불일치'),

-- API 보안
('API_SECURITY_001', 'api_security', 'medium', 'API 호출 한도 초과'),
('API_SECURITY_002', 'api_security', 'medium', '유효하지 않은 토큰'),
('API_SECURITY_003', 'api_security', 'medium', '만료된 토큰'),
('API_SECURITY_004', 'api_security', 'high', '권한 없는 접근'),
('API_SECURITY_005', 'api_security', 'high', '금지된 접근'),

-- 디바이스 보안
('DEVICE_SECURITY_001', 'device_security', 'critical', '루팅된 디바이스'),
('DEVICE_SECURITY_002', 'device_security', 'critical', '탈옥된 디바이스'),
('DEVICE_SECURITY_003', 'device_security', 'high', '에뮬레이터 사용'),
('DEVICE_SECURITY_004', 'device_security', 'medium', '디버그 모드'),
('DEVICE_SECURITY_005', 'device_security', 'high', '후킹 감지'),

-- 네트워크 보안
('NETWORK_SECURITY_001', 'network_security', 'critical', '중간자 공격'),
('NETWORK_SECURITY_002', 'network_security', 'high', 'SSL 우회'),
('NETWORK_SECURITY_003', 'network_security', 'high', '인증서 핀닝 실패'),
('NETWORK_SECURITY_004', 'network_security', 'medium', '프록시 감지'),
('NETWORK_SECURITY_005', 'network_security', 'medium', 'VPN 감지'),

-- 금융 보안
('FINANCIAL_SECURITY_001', 'financial_security', 'critical', '자금 세탁'),
('FINANCIAL_SECURITY_002', 'financial_security', 'critical', '사기 거래'),
('FINANCIAL_SECURITY_003', 'financial_security', 'medium', '결제 취소'),
('FINANCIAL_SECURITY_004', 'financial_security', 'medium', '환불 사기'),
('FINANCIAL_SECURITY_005', 'financial_security', 'high', '결제 사기'),

-- 개인정보 보안
('PRIVACY_SECURITY_001', 'privacy_security', 'critical', '데이터 유출'),
('PRIVACY_SECURITY_002', 'privacy_security', 'critical', '무단 접근'),
('PRIVACY_SECURITY_003', 'privacy_security', 'high', '데이터 유출'),
('PRIVACY_SECURITY_004', 'privacy_security', 'high', '개인정보 노출'),
('PRIVACY_SECURITY_005', 'privacy_security', 'high', 'GDPR 위반'),

-- 시스템 보안
('SYSTEM_SECURITY_001', 'system_security', 'critical', '시스템 침입'),
('SYSTEM_SECURITY_002', 'system_security', 'high', '권한 상승'),
('SYSTEM_SECURITY_003', 'system_security', 'high', '백도어'),
('SYSTEM_SECURITY_004', 'system_security', 'critical', '악성코드'),
('SYSTEM_SECURITY_005', 'system_security', 'critical', '랜섬웨어');

-- 인덱스 생성
CREATE INDEX idx_error_code_definitions_category ON error_code_definitions(category);
CREATE INDEX idx_error_code_definitions_severity ON error_code_definitions(severity);
CREATE INDEX idx_event_code_definitions_category ON event_code_definitions(category);
CREATE INDEX idx_security_code_definitions_category ON security_code_definitions(category);
CREATE INDEX idx_security_code_definitions_severity ON security_code_definitions(severity);

-- RLS 활성화
ALTER TABLE error_code_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE event_code_definitions ENABLE ROW LEVEL SECURITY;
ALTER TABLE security_code_definitions ENABLE ROW LEVEL SECURITY;

-- RLS 정책 생성 (모든 사용자가 읽기 가능)
CREATE POLICY "Anyone can view error codes" ON error_code_definitions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view event codes" ON event_code_definitions
  FOR SELECT USING (true);

CREATE POLICY "Anyone can view security codes" ON security_code_definitions
  FOR SELECT USING (true);

-- 로깅 함수들
-- 복권 응모 로깅 함수
CREATE OR REPLACE FUNCTION log_ticket_submission(
  p_uid UUID,
  p_round_id UUID,
  p_ticket_count INTEGER,
  p_numbers JSONB,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL,
  p_device_info JSONB DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO ticket_submission_logs (
    uid, round_id, ticket_count, numbers, 
    ip_address, user_agent, device_info
  )
  VALUES (
    p_uid, p_round_id, p_ticket_count, p_numbers,
    p_ip_address, p_user_agent, p_device_info
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 보상 지급 로깅 함수
CREATE OR REPLACE FUNCTION log_reward_issuance(
  p_uid UUID,
  p_reward_type VARCHAR(50),
  p_reward_amount INTEGER,
  p_source_data JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO reward_issuance_logs (
    uid, reward_type, reward_amount, source_data,
    ip_address, user_agent
  )
  VALUES (
    p_uid, p_reward_type, p_reward_amount, p_source_data,
    p_ip_address, p_user_agent
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 당첨 결과 로깅 함수
CREATE OR REPLACE FUNCTION log_winning_result(
  p_uid UUID,
  p_round_id UUID,
  p_ticket_id UUID,
  p_winning_numbers INTEGER[6],
  p_user_numbers INTEGER[6],
  p_match_count INTEGER,
  p_bonus_match BOOLEAN,
  p_tier INTEGER,
  p_prize_amount INTEGER DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO winning_result_logs (
    uid, round_id, ticket_id, winning_numbers, user_numbers,
    match_count, bonus_match, tier, prize_amount
  )
  VALUES (
    p_uid, p_round_id, p_ticket_id, p_winning_numbers, p_user_numbers,
    p_match_count, p_bonus_match, p_tier, p_prize_amount
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 보안 이벤트 로깅 함수
CREATE OR REPLACE FUNCTION log_security_event(
  p_uid UUID,
  p_event_type VARCHAR(50),
  p_severity VARCHAR(20),
  p_description TEXT,
  p_metadata JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO security_event_logs (
    uid, event_type, severity, description, metadata,
    ip_address, user_agent
  )
  VALUES (
    p_uid, p_event_type, p_severity, p_description, p_metadata,
    p_ip_address, p_user_agent
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- API 호출 로깅 함수
CREATE OR REPLACE FUNCTION log_api_call(
  p_uid UUID,
  p_endpoint VARCHAR(200),
  p_method VARCHAR(10),
  p_status_code INTEGER,
  p_response_time_ms INTEGER DEFAULT NULL,
  p_request_size INTEGER DEFAULT NULL,
  p_response_size INTEGER DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO api_call_logs (
    uid, endpoint, method, status_code, response_time_ms,
    request_size, response_size, ip_address, user_agent
  )
  VALUES (
    p_uid, p_endpoint, p_method, p_status_code, p_response_time_ms,
    p_request_size, p_response_size, p_ip_address, p_user_agent
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 에러 로깅 함수
CREATE OR REPLACE FUNCTION log_error(
  p_uid UUID,
  p_error_type VARCHAR(100),
  p_error_message TEXT,
  p_stack_trace TEXT DEFAULT NULL,
  p_context JSONB DEFAULT NULL,
  p_ip_address INET DEFAULT NULL,
  p_user_agent TEXT DEFAULT NULL
)
RETURNS UUID AS $$
DECLARE
  v_log_id UUID;
BEGIN
  INSERT INTO error_logs (
    uid, error_type, error_message, stack_trace, context,
    ip_address, user_agent
  )
  VALUES (
    p_uid, p_error_type, p_error_message, p_stack_trace, p_context,
    p_ip_address, p_user_agent
  )
  RETURNING id INTO v_log_id;
  
  RETURN v_log_id;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;

-- 로그 정리 함수 (오래된 로그 삭제)
CREATE OR REPLACE FUNCTION cleanup_old_logs(p_days_to_keep INTEGER DEFAULT 90)
RETURNS VOID AS $$
BEGIN
  -- 90일 이상 된 로그 삭제
  DELETE FROM ticket_submission_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM reward_issuance_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM winning_result_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM security_event_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM api_call_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM error_logs WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
  DELETE FROM analytics_events WHERE created_at < NOW() - INTERVAL '1 day' * p_days_to_keep;
END;
$$ LANGUAGE plpgsql SECURITY DEFINER;
