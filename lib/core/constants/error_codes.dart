/// LuckyWalk 에러코드 체계
/// 생성일: 2025-09-17 23:49:41 KST
/// 설명: 복권앱의 모든 에러코드를 체계적으로 관리

class ErrorCodes {
  // 인증 관련 에러 (AUTH_001 ~ AUTH_099)
  static const String authLoginFailed = 'AUTH_001';
  static const String authTokenExpired = 'AUTH_002';
  static const String authUserNotFound = 'AUTH_003';
  static const String authInvalidCredentials = 'AUTH_004';
  static const String authAccountSuspended = 'AUTH_005';
  static const String authAppleLoginFailed = 'AUTH_006';
  static const String authKakaoLoginFailed = 'AUTH_007';
  static const String authSessionExpired = 'AUTH_008';
  static const String authOnboardingRequired = 'AUTH_009';
  static const String authKycRequired = 'AUTH_010';

  // 복권 관련 에러 (TICKET_001 ~ TICKET_099)
  static const String ticketInsufficientBalance = 'TICKET_001';
  static const String ticketSubmissionFailed = 'TICKET_002';
  static const String ticketInvalidNumbers = 'TICKET_003';
  static const String ticketRoundClosed = 'TICKET_004';
  static const String ticketRoundNotFound = 'TICKET_005';
  static const String ticketMaxLimitExceeded = 'TICKET_006';
  static const String ticketDuplicateSubmission = 'TICKET_007';
  static const String ticketSystemMaintenance = 'TICKET_008';
  static const String ticketInvalidRound = 'TICKET_009';
  static const String ticketSubmissionTimeout = 'TICKET_010';

  // 보상 관련 에러 (REWARD_001 ~ REWARD_099)
  static const String rewardClaimFailed = 'REWARD_001';
  static const String rewardAlreadyClaimed = 'REWARD_002';
  static const String rewardInvalidSource = 'REWARD_003';
  static const String rewardStepsInsufficient = 'REWARD_004';
  static const String rewardAdSessionExpired = 'REWARD_005';
  static const String rewardAttendanceAlreadyDone = 'REWARD_006';
  static const String rewardReferralInvalid = 'REWARD_007';
  static const String rewardSystemError = 'REWARD_008';
  static const String rewardDailyLimitExceeded = 'REWARD_009';
  static const String rewardInvalidThreshold = 'REWARD_010';

  // 네트워크 관련 에러 (NETWORK_001 ~ NETWORK_099)
  static const String networkConnectionFailed = 'NETWORK_001';
  static const String networkTimeout = 'NETWORK_002';
  static const String networkServerError = 'NETWORK_003';
  static const String networkApiRateLimit = 'NETWORK_004';
  static const String networkMaintenance = 'NETWORK_005';
  static const String networkInvalidResponse = 'NETWORK_006';
  static const String networkOffline = 'NETWORK_007';
  static const String networkSlowConnection = 'NETWORK_008';
  static const String networkDnsError = 'NETWORK_009';
  static const String networkSslError = 'NETWORK_010';

  // 보안 관련 에러 (SECURITY_001 ~ SECURITY_099)
  static const String securityAbuseDetected = 'SECURITY_001';
  static const String securitySuspiciousActivity = 'SECURITY_002';
  static const String securityInvalidRequest = 'SECURITY_003';
  static const String securityRateLimitExceeded = 'SECURITY_004';
  static const String securityDeviceBlocked = 'SECURITY_005';
  static const String securityIpBlocked = 'SECURITY_006';
  static const String securityFingerprintMismatch = 'SECURITY_007';
  static const String securityUnauthorizedAccess = 'SECURITY_008';
  static const String securityDataTampering = 'SECURITY_009';
  static const String securitySessionHijack = 'SECURITY_010';

  // 데이터베이스 관련 에러 (DB_001 ~ DB_099)
  static const String dbConnectionFailed = 'DB_001';
  static const String dbQueryTimeout = 'DB_002';
  static const String dbConstraintViolation = 'DB_003';
  static const String dbTransactionFailed = 'DB_004';
  static const String dbDataNotFound = 'DB_005';
  static const String dbDuplicateEntry = 'DB_006';
  static const String dbLockTimeout = 'DB_007';
  static const String dbDeadlock = 'DB_008';
  static const String dbDiskSpaceFull = 'DB_009';
  static const String dbBackupFailed = 'DB_010';

  // KYC 관련 에러 (KYC_001 ~ KYC_099)
  static const String kycSubmissionFailed = 'KYC_001';
  static const String kycInvalidData = 'KYC_002';
  static const String kycAlreadySubmitted = 'KYC_003';
  static const String kycRejected = 'KYC_004';
  static const String kycPending = 'KYC_005';
  static const String kycExpired = 'KYC_006';
  static const String kycFileUploadFailed = 'KYC_007';
  static const String kycVerificationFailed = 'KYC_008';
  static const String kycRequiredForPrize = 'KYC_009';
  static const String kycDocumentInvalid = 'KYC_010';

  // 결제 관련 에러 (PAYMENT_001 ~ PAYMENT_099)
  static const String paymentFailed = 'PAYMENT_001';
  static const String paymentInsufficientFunds = 'PAYMENT_002';
  static const String paymentCardExpired = 'PAYMENT_003';
  static const String paymentCardDeclined = 'PAYMENT_004';
  static const String paymentProcessingError = 'PAYMENT_005';
  static const String paymentRefundFailed = 'PAYMENT_006';
  static const String paymentInvalidAmount = 'PAYMENT_007';
  static const String paymentCurrencyMismatch = 'PAYMENT_008';
  static const String paymentGatewayError = 'PAYMENT_009';
  static const String paymentTimeout = 'PAYMENT_010';

  // 시스템 관련 에러 (SYSTEM_001 ~ SYSTEM_099)
  static const String systemMaintenance = 'SYSTEM_001';
  static const String systemOverload = 'SYSTEM_002';
  static const String systemConfigurationError = 'SYSTEM_003';
  static const String systemResourceExhausted = 'SYSTEM_004';
  static const String systemServiceUnavailable = 'SYSTEM_005';
  static const String systemVersionMismatch = 'SYSTEM_006';
  static const String systemFeatureDisabled = 'SYSTEM_007';
  static const String systemCacheError = 'SYSTEM_008';
  static const String systemLoggingError = 'SYSTEM_009';
  static const String systemUnknownError = 'SYSTEM_010';

  // 앱 관련 에러 (APP_001 ~ APP_099)
  static const String appVersionNotSupported = 'APP_001';
  static const String appUpdateRequired = 'APP_002';
  static const String appStorageFull = 'APP_003';
  static const String appPermissionDenied = 'APP_004';
  static const String appLocationDisabled = 'APP_005';
  static const String appNotificationDisabled = 'APP_006';
  static const String appCameraPermissionDenied = 'APP_007';
  static const String appMicrophonePermissionDenied = 'APP_008';
  static const String appContactsPermissionDenied = 'APP_009';
  static const String appCalendarPermissionDenied = 'APP_010';

  // 광고 관련 에러 (AD_001 ~ AD_099)
  static const String adLoadFailed = 'AD_001';
  static const String adShowFailed = 'AD_002';
  static const String adRewardFailed = 'AD_003';
  static const String adNetworkError = 'AD_004';
  static const String adSdkNotInitialized = 'AD_005';
  static const String adInvalidUnitId = 'AD_006';
  static const String adFrequencyLimit = 'AD_007';
  static const String adUserCancelled = 'AD_008';
  static const String adTimeout = 'AD_009';
  static const String adInventoryEmpty = 'AD_010';

  /// 에러코드별 메시지 매핑
  static const Map<String, String> errorMessages = {
    // 인증 관련
    authLoginFailed: '로그인에 실패했습니다.',
    authTokenExpired: '로그인 세션이 만료되었습니다.',
    authUserNotFound: '사용자를 찾을 수 없습니다.',
    authInvalidCredentials: '잘못된 인증 정보입니다.',
    authAccountSuspended: '계정이 정지되었습니다.',
    authAppleLoginFailed: 'Apple 로그인에 실패했습니다.',
    authKakaoLoginFailed: 'Kakao 로그인에 실패했습니다.',
    authSessionExpired: '세션이 만료되었습니다.',
    authOnboardingRequired: '온보딩이 필요합니다.',
    authKycRequired: 'KYC 인증이 필요합니다.',

    // 복권 관련
    ticketInsufficientBalance: '복권이 부족합니다.',
    ticketSubmissionFailed: '복권 응모에 실패했습니다.',
    ticketInvalidNumbers: '잘못된 번호입니다.',
    ticketRoundClosed: '응모 기간이 종료되었습니다.',
    ticketRoundNotFound: '회차를 찾을 수 없습니다.',
    ticketMaxLimitExceeded: '최대 응모 한도를 초과했습니다.',
    ticketDuplicateSubmission: '중복 응모는 불가능합니다.',
    ticketSystemMaintenance: '시스템 점검 중입니다.',
    ticketInvalidRound: '유효하지 않은 회차입니다.',
    ticketSubmissionTimeout: '응모 시간이 초과되었습니다.',

    // 보상 관련
    rewardClaimFailed: '보상 수령에 실패했습니다.',
    rewardAlreadyClaimed: '이미 수령한 보상입니다.',
    rewardInvalidSource: '유효하지 않은 보상 소스입니다.',
    rewardStepsInsufficient: '걸음수가 부족합니다.',
    rewardAdSessionExpired: '광고 세션이 만료되었습니다.',
    rewardAttendanceAlreadyDone: '이미 출석체크를 완료했습니다.',
    rewardReferralInvalid: '유효하지 않은 추천코드입니다.',
    rewardSystemError: '보상 시스템 오류가 발생했습니다.',
    rewardDailyLimitExceeded: '일일 보상 한도를 초과했습니다.',
    rewardInvalidThreshold: '유효하지 않은 보상 기준입니다.',

    // 네트워크 관련
    networkConnectionFailed: '네트워크 연결에 실패했습니다.',
    networkTimeout: '네트워크 응답 시간이 초과되었습니다.',
    networkServerError: '서버 오류가 발생했습니다.',
    networkApiRateLimit: 'API 호출 한도를 초과했습니다.',
    networkMaintenance: '서버 점검 중입니다.',
    networkInvalidResponse: '잘못된 서버 응답입니다.',
    networkOffline: '인터넷 연결을 확인해주세요.',
    networkSlowConnection: '네트워크 연결이 느립니다.',
    networkDnsError: 'DNS 조회에 실패했습니다.',
    networkSslError: 'SSL 인증서 오류가 발생했습니다.',

    // 보안 관련
    securityAbuseDetected: '어뷰징이 감지되었습니다.',
    securitySuspiciousActivity: '의심스러운 활동이 감지되었습니다.',
    securityInvalidRequest: '유효하지 않은 요청입니다.',
    securityRateLimitExceeded: '요청 한도를 초과했습니다.',
    securityDeviceBlocked: '차단된 기기입니다.',
    securityIpBlocked: '차단된 IP입니다.',
    securityFingerprintMismatch: '기기 정보가 일치하지 않습니다.',
    securityUnauthorizedAccess: '권한이 없는 접근입니다.',
    securityDataTampering: '데이터 변조가 감지되었습니다.',
    securitySessionHijack: '세션 하이재킹이 감지되었습니다.',

    // 시스템 관련
    systemMaintenance: '시스템 점검 중입니다.',
    systemOverload: '시스템 과부하 상태입니다.',
    systemConfigurationError: '시스템 설정 오류가 발생했습니다.',
    systemResourceExhausted: '시스템 리소스가 부족합니다.',
    systemServiceUnavailable: '서비스가 일시적으로 중단되었습니다.',
    systemVersionMismatch: '버전이 일치하지 않습니다.',
    systemFeatureDisabled: '기능이 비활성화되었습니다.',
    systemCacheError: '캐시 오류가 발생했습니다.',
    systemLoggingError: '로깅 시스템 오류가 발생했습니다.',
    systemUnknownError: '알 수 없는 오류가 발생했습니다.',

    // 앱 관련
    appVersionNotSupported: '지원하지 않는 앱 버전입니다.',
    appUpdateRequired: '앱 업데이트가 필요합니다.',
    appStorageFull: '저장 공간이 부족합니다.',
    appPermissionDenied: '권한이 거부되었습니다.',
    appLocationDisabled: '위치 서비스가 비활성화되었습니다.',
    appNotificationDisabled: '알림이 비활성화되었습니다.',
    appCameraPermissionDenied: '카메라 권한이 거부되었습니다.',
    appMicrophonePermissionDenied: '마이크 권한이 거부되었습니다.',
    appContactsPermissionDenied: '연락처 권한이 거부되었습니다.',
    appCalendarPermissionDenied: '캘린더 권한이 거부되었습니다.',

    // 광고 관련
    adLoadFailed: '광고 로드에 실패했습니다.',
    adShowFailed: '광고 표시에 실패했습니다.',
    adRewardFailed: '광고 보상 지급에 실패했습니다.',
    adNetworkError: '광고 네트워크 오류가 발생했습니다.',
    adSdkNotInitialized: '광고 SDK가 초기화되지 않았습니다.',
    adInvalidUnitId: '유효하지 않은 광고 단위 ID입니다.',
    adFrequencyLimit: '광고 시청 한도를 초과했습니다.',
    adUserCancelled: '사용자가 광고를 취소했습니다.',
    adTimeout: '광고 로드 시간이 초과되었습니다.',
    adInventoryEmpty: '광고 재고가 없습니다.',
  };

  /// 에러코드별 심각도 매핑
  static const Map<String, String> errorSeverity = {
    // Critical (시스템 다운, 보안 위반)
    systemMaintenance: 'critical',
    securityAbuseDetected: 'critical',
    securitySuspiciousActivity: 'critical',
    securityDataTampering: 'critical',
    securitySessionHijack: 'critical',
    dbConnectionFailed: 'critical',
    systemOverload: 'critical',
    systemResourceExhausted: 'critical',

    // High (주요 기능 장애)
    authLoginFailed: 'high',
    ticketSubmissionFailed: 'high',
    rewardClaimFailed: 'high',
    paymentFailed: 'high',
    kycSubmissionFailed: 'high',
    networkServerError: 'high',
    systemServiceUnavailable: 'high',

    // Medium (일부 기능 장애)
    networkConnectionFailed: 'medium',
    networkTimeout: 'medium',
    ticketInsufficientBalance: 'medium',
    rewardAlreadyClaimed: 'medium',
    adLoadFailed: 'medium',
    appVersionNotSupported: 'medium',

    // Low (경고, 사용자 경험 저하)
    networkSlowConnection: 'low',
    adUserCancelled: 'low',
    appNotificationDisabled: 'low',
    appLocationDisabled: 'low',
  };

  /// 에러코드 검증
  static bool isValidErrorCode(String code) {
    return errorMessages.containsKey(code);
  }

  /// 에러 메시지 조회
  static String getErrorMessage(String code) {
    return errorMessages[code] ?? '알 수 없는 오류가 발생했습니다.';
  }

  /// 에러 심각도 조회
  static String getErrorSeverity(String code) {
    return errorSeverity[code] ?? 'medium';
  }

  /// 카테고리별 에러코드 조회
  static List<String> getErrorCodesByCategory(String category) {
    switch (category.toLowerCase()) {
      case 'auth':
        return [
          authLoginFailed, authTokenExpired, authUserNotFound,
          authInvalidCredentials, authAccountSuspended, authAppleLoginFailed,
          authKakaoLoginFailed, authSessionExpired, authOnboardingRequired, authKycRequired
        ];
      case 'ticket':
        return [
          ticketInsufficientBalance, ticketSubmissionFailed, ticketInvalidNumbers,
          ticketRoundClosed, ticketRoundNotFound, ticketMaxLimitExceeded,
          ticketDuplicateSubmission, ticketSystemMaintenance, ticketInvalidRound, ticketSubmissionTimeout
        ];
      case 'reward':
        return [
          rewardClaimFailed, rewardAlreadyClaimed, rewardInvalidSource,
          rewardStepsInsufficient, rewardAdSessionExpired, rewardAttendanceAlreadyDone,
          rewardReferralInvalid, rewardSystemError, rewardDailyLimitExceeded, rewardInvalidThreshold
        ];
      case 'network':
        return [
          networkConnectionFailed, networkTimeout, networkServerError,
          networkApiRateLimit, networkMaintenance, networkInvalidResponse,
          networkOffline, networkSlowConnection, networkDnsError, networkSslError
        ];
      case 'security':
        return [
          securityAbuseDetected, securitySuspiciousActivity, securityInvalidRequest,
          securityRateLimitExceeded, securityDeviceBlocked, securityIpBlocked,
          securityFingerprintMismatch, securityUnauthorizedAccess, securityDataTampering, securitySessionHijack
        ];
      case 'system':
        return [
          systemMaintenance, systemOverload, systemConfigurationError,
          systemResourceExhausted, systemServiceUnavailable, systemVersionMismatch,
          systemFeatureDisabled, systemCacheError, systemLoggingError, systemUnknownError
        ];
      default:
        return [];
    }
  }
}
