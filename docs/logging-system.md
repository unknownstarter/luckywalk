# LuckyWalk 로깅 시스템 가이드

**생성일**: 2025-09-17 23:49:41 KST  
**마지막 업데이트**: 2025-09-17 23:49:41 KST  
**버전**: v1.0.0

## 📋 개요

LuckyWalk 복권앱의 포괄적인 로깅 시스템입니다. 모든 사용자 행동, 시스템 이벤트, 보안 위협, 에러 등을 체계적으로 기록하고 분석합니다.

## 🏗️ 시스템 구조

### 1. 로깅 테이블 구조

#### **기본 로깅 테이블**
- `analytics_events` - 사용자 행동 분석
- `system_health_logs` - 시스템 상태 모니터링
- `admin_actions` - 관리자 액션 추적

#### **상세 로깅 테이블**
- `ticket_submission_logs` - 복권 응모 상세 로그
- `reward_issuance_logs` - 보상 지급 상세 로그
- `winning_result_logs` - 당첨 결과 상세 로그
- `security_event_logs` - 보안 이벤트 로그
- `api_call_logs` - API 호출 로그
- `error_logs` - 에러 로그

#### **코드 정의 테이블**
- `error_code_definitions` - 에러코드 정의
- `event_code_definitions` - 이벤트코드 정의
- `security_code_definitions` - 보안코드 정의

### 2. 코드 체계

#### **에러코드 체계**
```
AUTH_001 ~ AUTH_099    - 인증 관련 에러
TICKET_001 ~ TICKET_099 - 복권 관련 에러
REWARD_001 ~ REWARD_099 - 보상 관련 에러
NETWORK_001 ~ NETWORK_099 - 네트워크 관련 에러
SECURITY_001 ~ SECURITY_099 - 보안 관련 에러
DB_001 ~ DB_099        - 데이터베이스 관련 에러
KYC_001 ~ KYC_099      - KYC 관련 에러
PAYMENT_001 ~ PAYMENT_099 - 결제 관련 에러
SYSTEM_001 ~ SYSTEM_099 - 시스템 관련 에러
APP_001 ~ APP_099      - 앱 관련 에러
AD_001 ~ AD_099        - 광고 관련 에러
```

#### **이벤트코드 체계**
```
USER_AUTH_001 ~ USER_AUTH_099 - 사용자 인증 이벤트
TICKET_001 ~ TICKET_099       - 복권 관련 이벤트
REWARD_001 ~ REWARD_099       - 보상 관련 이벤트
WINNING_001 ~ WINNING_099     - 당첨 결과 이벤트
KYC_001 ~ KYC_099             - KYC 관련 이벤트
REFERRAL_001 ~ REFERRAL_099   - 추천 관련 이벤트
AD_001 ~ AD_099               - 광고 관련 이벤트
STEPS_001 ~ STEPS_099         - 걸음수 관련 이벤트
NAV_001 ~ NAV_099             - 네비게이션 이벤트
SETTINGS_001 ~ SETTINGS_099   - 설정 관련 이벤트
PAYMENT_001 ~ PAYMENT_099     - 결제 관련 이벤트
NOTIFICATION_001 ~ NOTIFICATION_099 - 알림 관련 이벤트
APP_001 ~ APP_099             - 앱 생명주기 이벤트
PERFORMANCE_001 ~ PERFORMANCE_099 - 성능 관련 이벤트
```

#### **보안코드 체계**
```
ABUSE_001 ~ ABUSE_099                    - 어뷰징 감지
SUSPICIOUS_001 ~ SUSPICIOUS_099          - 의심스러운 활동
LOGIN_ANOMALY_001 ~ LOGIN_ANOMALY_099    - 로그인 이상
DATA_INTEGRITY_001 ~ DATA_INTEGRITY_099  - 데이터 무결성
API_SECURITY_001 ~ API_SECURITY_099      - API 보안
DEVICE_SECURITY_001 ~ DEVICE_SECURITY_099 - 디바이스 보안
NETWORK_SECURITY_001 ~ NETWORK_SECURITY_099 - 네트워크 보안
FINANCIAL_SECURITY_001 ~ FINANCIAL_SECURITY_099 - 금융 보안
PRIVACY_SECURITY_001 ~ PRIVACY_SECURITY_099 - 개인정보 보안
SYSTEM_SECURITY_001 ~ SYSTEM_SECURITY_099 - 시스템 보안
```

## 🔧 로깅 함수들

### 1. 기본 로깅 함수

#### **복권 응모 로깅**
```sql
SELECT log_ticket_submission(
  'user-uuid',
  'round-uuid',
  5, -- 복권 수
  '{"numbers": [[1,2,3,4,5,6], [7,8,9,10,11,12]]}',
  '192.168.1.1',
  'Mozilla/5.0...',
  '{"device": "iPhone", "os": "iOS 15.0"}'
);
```

#### **보상 지급 로깅**
```sql
SELECT log_reward_issuance(
  'user-uuid',
  'steps', -- 보상 타입
  3, -- 보상 수량
  '{"steps": 10000, "threshold": 10000}',
  '192.168.1.1',
  'Mozilla/5.0...'
);
```

#### **당첨 결과 로깅**
```sql
SELECT log_winning_result(
  'user-uuid',
  'round-uuid',
  'ticket-uuid',
  '{1,2,3,4,5,6}', -- 당첨 번호
  '{1,2,3,4,5,7}', -- 사용자 번호
  5, -- 맞춘 개수
  false, -- 보너스 번호 맞춤 여부
  3, -- 등수
  5000 -- 당첨금
);
```

#### **보안 이벤트 로깅**
```sql
SELECT log_security_event(
  'user-uuid',
  'ABUSE_001', -- 보안 이벤트 코드
  'critical', -- 심각도
  '다중 계정 사용이 감지되었습니다.',
  '{"accounts": ["uuid1", "uuid2"], "ip": "192.168.1.1"}',
  '192.168.1.1',
  'Mozilla/5.0...'
);
```

#### **API 호출 로깅**
```sql
SELECT log_api_call(
  'user-uuid',
  '/api/tickets/submit',
  'POST',
  200, -- 상태 코드
  150, -- 응답 시간 (ms)
  1024, -- 요청 크기
  512, -- 응답 크기
  '192.168.1.1',
  'Mozilla/5.0...'
);
```

#### **에러 로깅**
```sql
SELECT log_error(
  'user-uuid',
  'TICKET_001', -- 에러 코드
  '복권이 부족합니다.',
  'Stack trace here...',
  '{"ticket_count": 5, "balance": 3}',
  '192.168.1.1',
  'Mozilla/5.0...'
);
```

### 2. 로그 정리 함수

#### **오래된 로그 삭제**
```sql
SELECT cleanup_old_logs(90); -- 90일 이상 된 로그 삭제
```

## 📊 로깅 모범 사례

### 1. 에러 로깅

#### **에러 발생 시**
```dart
try {
  // 복권 응모 로직
  await submitTickets(tickets);
  
  // 성공 로깅
  await logEvent(EventCodes.ticketSubmitSuccess, {
    'ticket_count': tickets.length,
    'round_id': roundId,
  });
} catch (e) {
  // 에러 로깅
  await logError(ErrorCodes.ticketSubmissionFailed, e.toString(), {
    'ticket_count': tickets.length,
    'round_id': roundId,
    'user_balance': userBalance,
  });
  
  // 사용자에게 에러 메시지 표시
  showError(ErrorCodes.getErrorMessage(ErrorCodes.ticketSubmissionFailed));
}
```

### 2. 보안 이벤트 로깅

#### **어뷰징 감지 시**
```dart
// 의심스러운 패턴 감지
if (isSuspiciousActivity(userId, activity)) {
  await logSecurityEvent(
    SecurityCodes.abuseMultipleAccounts,
    SecurityCodes.getSecuritySeverity(SecurityCodes.abuseMultipleAccounts),
    '다중 계정 사용이 감지되었습니다.',
    {
      'user_id': userId,
      'related_accounts': relatedAccounts,
      'activity_pattern': activityPattern,
    },
  );
  
  // 즉시 대응 조치
  await takeSecurityAction(userId, 'account_suspension');
}
```

### 3. 성능 모니터링

#### **API 응답 시간 로깅**
```dart
final stopwatch = Stopwatch()..start();
try {
  final response = await apiCall();
  stopwatch.stop();
  
  await logApiCall(
    endpoint: '/api/tickets/submit',
    method: 'POST',
    statusCode: response.statusCode,
    responseTimeMs: stopwatch.elapsedMilliseconds,
    requestSize: requestBody.length,
    responseSize: response.body.length,
  );
} catch (e) {
  stopwatch.stop();
  await logApiCall(
    endpoint: '/api/tickets/submit',
    method: 'POST',
    statusCode: 500,
    responseTimeMs: stopwatch.elapsedMilliseconds,
  );
}
```

## 🔍 로그 분석 및 모니터링

### 1. 실시간 모니터링

#### **Critical 에러 모니터링**
```sql
-- Critical 에러 발생 시 즉시 알림
SELECT * FROM error_logs 
WHERE error_type IN (
  SELECT code FROM error_code_definitions 
  WHERE severity = 'critical'
) 
AND created_at > NOW() - INTERVAL '1 hour';
```

#### **보안 이벤트 모니터링**
```sql
-- Critical 보안 이벤트 모니터링
SELECT * FROM security_event_logs 
WHERE severity = 'critical' 
AND created_at > NOW() - INTERVAL '1 hour';
```

### 2. 사용자 행동 분석

#### **일일 활성 사용자**
```sql
SELECT DATE(created_at) as date, COUNT(DISTINCT uid) as dau
FROM analytics_events 
WHERE event_name = 'USER_AUTH_001' -- 로그인 이벤트
AND created_at > NOW() - INTERVAL '30 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

#### **복권 응모 패턴 분석**
```sql
SELECT 
  DATE(created_at) as date,
  COUNT(*) as total_submissions,
  AVG(ticket_count) as avg_tickets_per_submission,
  COUNT(DISTINCT uid) as unique_users
FROM ticket_submission_logs 
WHERE created_at > NOW() - INTERVAL '7 days'
GROUP BY DATE(created_at)
ORDER BY date DESC;
```

### 3. 성능 분석

#### **API 응답 시간 분석**
```sql
SELECT 
  endpoint,
  AVG(response_time_ms) as avg_response_time,
  MAX(response_time_ms) as max_response_time,
  COUNT(*) as total_calls,
  COUNT(CASE WHEN status_code >= 400 THEN 1 END) as error_count
FROM api_call_logs 
WHERE created_at > NOW() - INTERVAL '24 hours'
GROUP BY endpoint
ORDER BY avg_response_time DESC;
```

## 🚨 알림 및 대응

### 1. 자동 알림 설정

#### **Critical 에러 알림**
```sql
-- Critical 에러 발생 시 Slack 알림
CREATE OR REPLACE FUNCTION notify_critical_error()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.error_type IN (
    SELECT code FROM error_code_definitions 
    WHERE severity = 'critical'
  ) THEN
    -- Slack 웹훅 호출
    PERFORM net.http_post(
      url := 'https://hooks.slack.com/services/YOUR/SLACK/WEBHOOK',
      headers := '{"Content-Type": "application/json"}'::jsonb,
      body := jsonb_build_object(
        'text', 'Critical Error: ' || NEW.error_message,
        'channel', '#alerts',
        'username', 'LuckyWalk Bot'
      )
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

### 2. 보안 대응

#### **어뷰징 자동 차단**
```sql
-- 어뷰징 감지 시 자동 차단
CREATE OR REPLACE FUNCTION auto_block_abuser()
RETURNS TRIGGER AS $$
BEGIN
  IF NEW.event_type LIKE 'ABUSE_%' AND NEW.severity = 'critical' THEN
    -- 사용자 계정 정지
    UPDATE user_profiles 
    SET abuse_flag = true, abuse_reason = NEW.description
    WHERE uid = NEW.uid;
    
    -- 관련 계정들도 정지
    UPDATE user_profiles 
    SET abuse_flag = true, abuse_reason = 'Related to abuse account'
    WHERE device_fingerprint = (
      SELECT device_fingerprint FROM user_profiles WHERE uid = NEW.uid
    );
  END IF;
  RETURN NEW;
END;
$$ LANGUAGE plpgsql;
```

## 📈 로그 보관 및 정리

### 1. 로그 보관 정책

- **Critical/High 심각도**: 1년 보관
- **Medium 심각도**: 6개월 보관
- **Low 심각도**: 3개월 보관
- **일반 이벤트**: 90일 보관

### 2. 자동 정리 스케줄

```sql
-- 매일 새벽 2시에 오래된 로그 정리
SELECT cron.schedule(
  'cleanup-old-logs',
  '0 2 * * *', -- 매일 새벽 2시
  'SELECT cleanup_old_logs(90);'
);
```

## 🔐 보안 고려사항

### 1. 개인정보 보호

- **민감한 데이터 마스킹**: 주민등록번호, 계좌번호 등
- **데이터 암호화**: 저장 시 AES-256 암호화
- **접근 권한 제어**: RLS 정책으로 데이터 접근 제한

### 2. 로그 무결성

- **체크섬 검증**: 로그 데이터 변조 감지
- **디지털 서명**: 중요 로그에 디지털 서명 적용
- **백업 및 복구**: 로그 데이터 정기 백업

## 📚 참고 자료

- [Supabase 로깅 가이드](https://supabase.com/docs/guides/logs)
- [PostgreSQL 로깅 설정](https://www.postgresql.org/docs/current/runtime-config-logging.html)
- [Flutter 로깅 모범 사례](https://docs.flutter.dev/development/tools/logging)

---

**문서 버전**: v1.0.0  
**마지막 업데이트**: 2025-09-17 23:49:41 KST  
**작성자**: LuckyWalk 개발팀
