# LuckyWalk 분석/로그 설계

## 1. 분석 이벤트 개요

### 1.1 이벤트 분류
- **사용자 행동**: 앱 사용, 화면 이동, 버튼 클릭
- **보상 시스템**: 광고 시청, 걸음수 달성, 출석체크, 초대
- **응모 시스템**: 복권 응모, 번호 생성, 응모 완료
- **결과 시스템**: 당첨 확인, KYC 제출, 당첨금 수령
- **시스템 이벤트**: 앱 시작, 세션 시작, 에러 발생

### 1.2 공통 필드
모든 이벤트에 포함되는 공통 필드:
```json
{
  "uid": "user_id",
  "device_id": "device_identifier",
  "app_version": "1.0.0",
  "platform": "ios|android",
  "timezone": "Asia/Seoul",
  "network": "wifi|cellular|offline",
  "timestamp": "2025-01-01T00:00:00Z"
}
```

## 2. 핵심 이벤트 명세

### 2.1 앱 생명주기 이벤트

#### app_open
```json
{
  "event_name": "app_open",
  "session_id": "session_identifier",
  "is_first_open": true,
  "is_background": false,
  "app_state": "foreground"
}
```

#### session_start
```json
{
  "event_name": "session_start",
  "session_id": "session_identifier",
  "session_duration": 0,
  "previous_session_duration": 300
}
```

#### session_end
```json
{
  "event_name": "session_end",
  "session_id": "session_identifier",
  "session_duration": 300,
  "screen_count": 5,
  "action_count": 12
}
```

### 2.2 인증 이벤트

#### login_attempt
```json
{
  "event_name": "login_attempt",
  "provider": "apple|kakao",
  "method": "oauth"
}
```

#### login_success
```json
{
  "event_name": "login_success",
  "provider": "apple|kakao",
  "user_id": "user_identifier",
  "is_new_user": true
}
```

#### login_failure
```json
{
  "event_name": "login_failure",
  "provider": "apple|kakao",
  "error_code": "auth_failed",
  "error_message": "Authentication failed"
}
```

#### logout
```json
{
  "event_name": "logout",
  "session_duration": 1800,
  "reason": "user_initiated|session_expired"
}
```

### 2.3 권한 이벤트

#### permission_prompt_shown
```json
{
  "event_name": "permission_prompt_shown",
  "permission_type": "notification|health|activity",
  "context": "onboarding|settings"
}
```

#### permission_granted
```json
{
  "event_name": "permission_granted",
  "permission_type": "notification|health|activity",
  "context": "onboarding|settings"
}
```

#### permission_denied
```json
{
  "event_name": "permission_denied",
  "permission_type": "notification|health|activity",
  "context": "onboarding|settings"
}
```

### 2.4 화면 이동 이벤트

#### screen_view
```json
{
  "event_name": "screen_view",
  "screen_name": "home|my_tickets|results",
  "previous_screen": "splash|login",
  "navigation_method": "tab|button|deep_link"
}
```

#### screen_exit
```json
{
  "event_name": "screen_exit",
  "screen_name": "home|my_tickets|results",
  "time_spent": 30,
  "exit_method": "back_button|tab_switch|app_background"
}
```

### 2.5 광고 이벤트

#### ad_start
```json
{
  "event_name": "ad_start",
  "ad_unit_id": "rewarded_video_unit_id",
  "ad_sequence": 1,
  "session_id": "ad_session_identifier",
  "ad_type": "rewarded_video"
}
```

#### ad_complete
```json
{
  "event_name": "ad_complete",
  "ad_unit_id": "rewarded_video_unit_id",
  "ad_sequence": 1,
  "session_id": "ad_session_identifier",
  "reward_tickets": 1,
  "ad_duration": 30
}
```

#### ad_fail
```json
{
  "event_name": "ad_fail",
  "ad_unit_id": "rewarded_video_unit_id",
  "ad_sequence": 1,
  "session_id": "ad_session_identifier",
  "error_code": "load_failed|playback_failed",
  "error_message": "Ad failed to load"
}
```

#### ad_skip
```json
{
  "event_name": "ad_skip",
  "ad_unit_id": "rewarded_video_unit_id",
  "ad_sequence": 1,
  "session_id": "ad_session_identifier",
  "skip_reason": "user_skipped|app_backgrounded"
}
```

### 2.6 걸음수 이벤트

#### steps_data_loaded
```json
{
  "event_name": "steps_data_loaded",
  "steps_count": 5000,
  "data_source": "healthkit|google_fit|activity_recognition",
  "is_accurate": true
}
```

#### steps_threshold_reached
```json
{
  "event_name": "steps_threshold_reached",
  "threshold": 1000,
  "steps_count": 1000,
  "is_first_time": true
}
```

#### steps_reward_claim_attempt
```json
{
  "event_name": "steps_reward_claim_attempt",
  "threshold": 1000,
  "steps_count": 1000
}
```

#### steps_reward_claim_success
```json
{
  "event_name": "steps_reward_claim_success",
  "threshold": 1000,
  "reward_tickets": 1,
  "steps_count": 1000
}
```

#### steps_reward_claim_fail
```json
{
  "event_name": "steps_reward_claim_fail",
  "threshold": 1000,
  "error_code": "insufficient_steps|already_claimed",
  "error_message": "Insufficient steps"
}
```

### 2.7 출석체크 이벤트

#### attendance_checkin_attempt
```json
{
  "event_name": "attendance_checkin_attempt",
  "is_first_time": true
}
```

#### attendance_checkin_success
```json
{
  "event_name": "attendance_checkin_success",
  "reward_tickets": 3,
  "consecutive_days": 1
}
```

#### attendance_checkin_fail
```json
{
  "event_name": "attendance_checkin_fail",
  "error_code": "already_checked|network_error",
  "error_message": "Already checked in today"
}
```

### 2.8 초대 이벤트

#### referral_code_generated
```json
{
  "event_name": "referral_code_generated",
  "referral_code": "ABC123",
  "referral_link": "luckywalk://ref/join?code=ABC123"
}
```

#### referral_share_clicked
```json
{
  "event_name": "referral_share_clicked",
  "referral_code": "ABC123",
  "share_method": "kakao|sms|copy_link"
}
```

#### referral_join_attempt
```json
{
  "event_name": "referral_join_attempt",
  "referral_code": "ABC123",
  "inviter_id": "inviter_identifier"
}
```

#### referral_join_success
```json
{
  "event_name": "referral_join_success",
  "referral_code": "ABC123",
  "inviter_id": "inviter_identifier",
  "invitee_id": "invitee_identifier",
  "reward_tickets": 100
}
```

#### referral_join_fail
```json
{
  "event_name": "referral_join_fail",
  "referral_code": "ABC123",
  "error_code": "invalid_code|already_used|self_referral",
  "error_message": "Invalid referral code"
}
```

### 2.9 응모 이벤트

#### tickets_submit_attempt
```json
{
  "event_name": "tickets_submit_attempt",
  "ticket_count": 100,
  "round_id": "round_identifier",
  "round_number": 1234
}
```

#### tickets_submit_success
```json
{
  "event_name": "tickets_submit_success",
  "ticket_count": 100,
  "round_id": "round_identifier",
  "round_number": 1234,
  "total_tickets": 1000
}
```

#### tickets_submit_fail
```json
{
  "event_name": "tickets_submit_fail",
  "ticket_count": 100,
  "round_id": "round_identifier",
  "error_code": "insufficient_tickets|round_closed",
  "error_message": "Insufficient tickets"
}
```

#### ticket_numbers_generated
```json
{
  "event_name": "ticket_numbers_generated",
  "ticket_count": 100,
  "generation_method": "auto|manual",
  "round_id": "round_identifier"
}
```

#### ticket_numbers_modified
```json
{
  "event_name": "ticket_numbers_modified",
  "ticket_count": 100,
  "modified_count": 5,
  "round_id": "round_identifier"
}
```

### 2.10 결과 이벤트

#### round_draw_input_by_admin
```json
{
  "event_name": "round_draw_input_by_admin",
  "round_id": "round_identifier",
  "round_number": 1234,
  "winning_numbers": [1, 2, 11, 21, 33, 45],
  "admin_id": "admin_identifier"
}
```

#### results_generated
```json
{
  "event_name": "results_generated",
  "round_id": "round_identifier",
  "round_number": 1234,
  "total_participants": 1000,
  "winners_by_tier": {
    "1": 5,
    "2": 10,
    "3": 50,
    "4": 100,
    "5": 200
  }
}
```

#### results_viewed
```json
{
  "event_name": "results_viewed",
  "round_id": "round_identifier",
  "round_number": 1234,
  "user_tier": 3,
  "user_prize": 50
}
```

#### push_sent
```json
{
  "event_name": "push_sent",
  "push_type": "winners|round_start|round_end",
  "round_id": "round_identifier",
  "recipient_count": 1000,
  "success_count": 950,
  "failure_count": 50
}
```

### 2.11 KYC 이벤트

#### kyc_form_opened
```json
{
  "event_name": "kyc_form_opened",
  "round_id": "round_identifier",
  "user_tier": 1,
  "user_prize": 1000000
}
```

#### kyc_submit_attempt
```json
{
  "event_name": "kyc_submit_attempt",
  "round_id": "round_identifier",
  "form_completion": 0.8
}
```

#### kyc_submit_success
```json
{
  "event_name": "kyc_submit_success",
  "round_id": "round_identifier",
  "submission_id": "submission_identifier"
}
```

#### kyc_submit_fail
```json
{
  "event_name": "kyc_submit_fail",
  "round_id": "round_identifier",
  "error_code": "validation_failed|upload_failed",
  "error_message": "Validation failed"
}
```

#### kyc_approved
```json
{
  "event_name": "kyc_approved",
  "round_id": "round_identifier",
  "submission_id": "submission_identifier",
  "admin_id": "admin_identifier"
}
```

#### kyc_rejected
```json
{
  "event_name": "kyc_rejected",
  "round_id": "round_identifier",
  "submission_id": "submission_identifier",
  "admin_id": "admin_identifier",
  "rejection_reason": "invalid_documents|incomplete_info"
}
```

### 2.12 어뷰징 이벤트

#### abuse_flag_set
```json
{
  "event_name": "abuse_flag_set",
  "user_id": "user_identifier",
  "abuse_type": "multiple_accounts|fake_steps|ad_fraud",
  "abuse_score": 0.8,
  "reason": "Multiple accounts from same device"
}
```

#### abuse_review_required
```json
{
  "event_name": "abuse_review_required",
  "user_id": "user_identifier",
  "abuse_type": "multiple_accounts|fake_steps|ad_fraud",
  "abuse_score": 0.8
}
```

#### abuse_action_taken
```json
{
  "event_name": "abuse_action_taken",
  "user_id": "user_identifier",
  "action": "suspend|ban|warning",
  "admin_id": "admin_identifier",
  "reason": "Confirmed abuse"
}
```

### 2.13 에러 이벤트

#### error_occurred
```json
{
  "event_name": "error_occurred",
  "error_type": "network|validation|server|client",
  "error_code": "NETWORK_ERROR",
  "error_message": "Network connection failed",
  "screen_name": "home",
  "user_action": "ad_start"
}
```

#### crash_occurred
```json
{
  "event_name": "crash_occurred",
  "crash_type": "fatal|non_fatal",
  "error_message": "Null pointer exception",
  "stack_trace": "stack_trace_string",
  "screen_name": "home"
}
```

## 3. 분석 구현

### 3.1 AnalyticsService
```dart
class AnalyticsService {
  static final _instance = AnalyticsService._internal();
  factory AnalyticsService() => _instance;
  AnalyticsService._internal();
  
  Future<void> trackEvent(String eventName, Map<String, dynamic> parameters) async {
    // Firebase Analytics
    await FirebaseAnalytics.instance.logEvent(
      name: eventName,
      parameters: parameters,
    );
    
    // Supabase Analytics
    await _trackToSupabase(eventName, parameters);
  }
  
  Future<void> _trackToSupabase(String eventName, Map<String, dynamic> parameters) async {
    final supabase = Supabase.instance.client;
    
    await supabase.from('analytics_events').insert({
      'event_name': eventName,
      'parameters': parameters,
      'created_at': DateTime.now().toIso8601String(),
    });
  }
}
```

### 3.2 이벤트 트래킹 헬퍼
```dart
class EventTracker {
  static Future<void> trackAppOpen() async {
    await AnalyticsService().trackEvent('app_open', {
      'session_id': _generateSessionId(),
      'is_first_open': await _isFirstOpen(),
      'is_background': false,
      'app_state': 'foreground',
    });
  }
  
  static Future<void> trackAdStart(String adUnitId, int sequence) async {
    await AnalyticsService().trackEvent('ad_start', {
      'ad_unit_id': adUnitId,
      'ad_sequence': sequence,
      'session_id': _generateAdSessionId(),
      'ad_type': 'rewarded_video',
    });
  }
  
  static Future<void> trackAdComplete(String adUnitId, int sequence, int rewardTickets) async {
    await AnalyticsService().trackEvent('ad_complete', {
      'ad_unit_id': adUnitId,
      'ad_sequence': sequence,
      'session_id': _generateAdSessionId(),
      'reward_tickets': rewardTickets,
      'ad_duration': _getAdDuration(),
    });
  }
  
  static Future<void> trackStepsThresholdReached(int threshold, int stepsCount) async {
    await AnalyticsService().trackEvent('steps_threshold_reached', {
      'threshold': threshold,
      'steps_count': stepsCount,
      'is_first_time': await _isFirstTimeThreshold(threshold),
    });
  }
  
  static Future<void> trackTicketsSubmit(int ticketCount, String roundId) async {
    await AnalyticsService().trackEvent('tickets_submit_attempt', {
      'ticket_count': ticketCount,
      'round_id': roundId,
      'round_number': await _getRoundNumber(roundId),
    });
  }
  
  static Future<void> trackKycSubmit(String roundId) async {
    await AnalyticsService().trackEvent('kyc_submit_attempt', {
      'round_id': roundId,
      'form_completion': await _getFormCompletion(),
    });
  }
  
  static Future<void> trackError(String errorType, String errorCode, String errorMessage) async {
    await AnalyticsService().trackEvent('error_occurred', {
      'error_type': errorType,
      'error_code': errorCode,
      'error_message': errorMessage,
      'screen_name': _getCurrentScreen(),
      'user_action': _getLastUserAction(),
    });
  }
}
```

## 4. BigQuery Export (옵션)

### 4.1 BigQuery 스키마
```sql
CREATE TABLE `luckywalk.analytics_events` (
  event_name STRING,
  uid STRING,
  device_id STRING,
  app_version STRING,
  platform STRING,
  timezone STRING,
  network STRING,
  timestamp TIMESTAMP,
  parameters JSON,
  created_at TIMESTAMP
);
```

### 4.2 데이터 파이프라인
```dart
class BigQueryExporter {
  static Future<void> exportToBigQuery() async {
    final supabase = Supabase.instance.client;
    
    // 최근 24시간 이벤트 조회
    final events = await supabase
        .from('analytics_events')
        .select()
        .gte('created_at', DateTime.now().subtract(Duration(days: 1)).toIso8601String());
    
    // BigQuery로 전송
    await _sendToBigQuery(events);
  }
  
  static Future<void> _sendToBigQuery(List<Map<String, dynamic>> events) async {
    // BigQuery 클라이언트 구현
  }
}
```

## 5. 분석 대시보드

### 5.1 핵심 지표
- **DAU/MAU**: 일일/월간 활성 사용자
- **리텐션**: D1, D7, D30 리텐션
- **참여도**: 평균 세션 시간, 화면 조회 수
- **보상 수령**: 광고 완료율, 걸음수 달성률
- **응모 참여**: 응모 참여율, 평균 응모 장수
- **당첨률**: 당첨자 비율, 평균 당첨금

### 5.2 사용자 세그먼트
- **신규 사용자**: 가입 7일 이내
- **활성 사용자**: 주 3회 이상 사용
- **비활성 사용자**: 7일 이상 미사용
- **고액 응모자**: 평균 응모 장수 상위 20%
- **보상 수령자**: 주간 보상 수령 완료

### 5.3 A/B 테스트
- **보상 정책**: 광고 보상량, 걸음수 임계값
- **UI/UX**: 버튼 위치, 색상, 텍스트
- **알림**: 푸시 알림 타이밍, 내용
- **온보딩**: 권한 요청 순서, 설명 방식
