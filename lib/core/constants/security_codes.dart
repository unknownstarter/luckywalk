/// LuckyWalk 보안 이벤트 코드 체계
/// 생성일: 2025-09-17 23:49:41 KST
/// 설명: 복권앱의 보안 관련 이벤트 코드를 체계적으로 관리

class SecurityCodes {
  // 어뷰징 감지 (ABUSE_001 ~ ABUSE_099)
  static const String abuseMultipleAccounts = 'ABUSE_001';
  static const String abuseRapidActions = 'ABUSE_002';
  static const String abuseFakeSteps = 'ABUSE_003';
  static const String abuseAdManipulation = 'ABUSE_004';
  static const String abuseReferralFraud = 'ABUSE_005';
  static const String abuseTicketManipulation = 'ABUSE_006';
  static const String abuseRewardFarming = 'ABUSE_007';
  static const String abuseDeviceSpoofing = 'ABUSE_008';
  static const String abuseLocationSpoofing = 'ABUSE_009';
  static const String abuseTimeManipulation = 'ABUSE_010';

  // 의심스러운 활동 (SUSPICIOUS_001 ~ SUSPICIOUS_099)
  static const String suspiciousLoginPattern = 'SUSPICIOUS_001';
  static const String suspiciousDeviceChange = 'SUSPICIOUS_002';
  static const String suspiciousLocationChange = 'SUSPICIOUS_003';
  static const String suspiciousBehaviorPattern = 'SUSPICIOUS_004';
  static const String suspiciousNetworkPattern = 'SUSPICIOUS_005';
  static const String suspiciousTimePattern = 'SUSPICIOUS_006';
  static const String suspiciousDataPattern = 'SUSPICIOUS_007';
  static const String suspiciousApiUsage = 'SUSPICIOUS_008';
  static const String suspiciousBulkActions = 'SUSPICIOUS_009';
  static const String suspiciousAutomation = 'SUSPICIOUS_010';

  // 로그인 이상 (LOGIN_ANOMALY_001 ~ LOGIN_ANOMALY_099)
  static const String loginAnomalyMultipleDevices = 'LOGIN_ANOMALY_001';
  static const String loginAnomalyRapidAttempts = 'LOGIN_ANOMALY_002';
  static const String loginAnomalyFailedAttempts = 'LOGIN_ANOMALY_003';
  static const String loginAnomalyUnusualLocation = 'LOGIN_ANOMALY_004';
  static const String loginAnomalyUnusualTime = 'LOGIN_ANOMALY_005';
  static const String loginAnomalyDeviceFingerprint = 'LOGIN_ANOMALY_006';
  static const String loginAnomalyIpAddress = 'LOGIN_ANOMALY_007';
  static const String loginAnomalyUserAgent = 'LOGIN_ANOMALY_008';
  static const String loginAnomalySessionHijack = 'LOGIN_ANOMALY_009';
  static const String loginAnomalyBruteForce = 'LOGIN_ANOMALY_010';

  // 데이터 무결성 (DATA_INTEGRITY_001 ~ DATA_INTEGRITY_099)
  static const String dataIntegrityTampering = 'DATA_INTEGRITY_001';
  static const String dataIntegrityCorruption = 'DATA_INTEGRITY_002';
  static const String dataIntegrityInconsistency = 'DATA_INTEGRITY_003';
  static const String dataIntegrityValidationFailed = 'DATA_INTEGRITY_004';
  static const String dataIntegrityChecksumMismatch = 'DATA_INTEGRITY_005';
  static const String dataIntegrityTimestampManipulation = 'DATA_INTEGRITY_006';
  static const String dataIntegritySequenceViolation = 'DATA_INTEGRITY_007';
  static const String dataIntegrityConstraintViolation = 'DATA_INTEGRITY_008';
  static const String dataIntegrityDuplicateEntry = 'DATA_INTEGRITY_009';
  static const String dataIntegrityOrphanedData = 'DATA_INTEGRITY_010';

  // API 보안 (API_SECURITY_001 ~ API_SECURITY_099)
  static const String apiSecurityRateLimitExceeded = 'API_SECURITY_001';
  static const String apiSecurityInvalidToken = 'API_SECURITY_002';
  static const String apiSecurityExpiredToken = 'API_SECURITY_003';
  static const String apiSecurityUnauthorizedAccess = 'API_SECURITY_004';
  static const String apiSecurityForbiddenAccess = 'API_SECURITY_005';
  static const String apiSecurityMaliciousRequest = 'API_SECURITY_006';
  static const String apiSecuritySqlInjection = 'API_SECURITY_007';
  static const String apiSecurityXssAttempt = 'API_SECURITY_008';
  static const String apiSecurityCsrfAttempt = 'API_SECURITY_009';
  static const String apiSecurityDdosAttempt = 'API_SECURITY_010';

  // 디바이스 보안 (DEVICE_SECURITY_001 ~ DEVICE_SECURITY_099)
  static const String deviceSecurityRooted = 'DEVICE_SECURITY_001';
  static const String deviceSecurityJailbroken = 'DEVICE_SECURITY_002';
  static const String deviceSecurityEmulator = 'DEVICE_SECURITY_003';
  static const String deviceSecurityDebugMode = 'DEVICE_SECURITY_004';
  static const String deviceSecurityHooking = 'DEVICE_SECURITY_005';
  static const String deviceSecurityTampering = 'DEVICE_SECURITY_006';
  static const String deviceSecurityFakeDevice = 'DEVICE_SECURITY_007';
  static const String deviceSecurityVirtualDevice = 'DEVICE_SECURITY_008';
  static const String deviceSecurityProxy = 'DEVICE_SECURITY_009';
  static const String deviceSecurityVpn = 'DEVICE_SECURITY_010';

  // 네트워크 보안 (NETWORK_SECURITY_001 ~ NETWORK_SECURITY_099)
  static const String networkSecurityManInTheMiddle = 'NETWORK_SECURITY_001';
  static const String networkSecuritySslBypass = 'NETWORK_SECURITY_002';
  static const String networkSecurityCertificatePinning = 'NETWORK_SECURITY_003';
  static const String networkSecurityProxyDetection = 'NETWORK_SECURITY_004';
  static const String networkSecurityVpnDetection = 'NETWORK_SECURITY_005';
  static const String networkSecurityTorDetection = 'NETWORK_SECURITY_006';
  static const String networkSecuritySuspiciousIp = 'NETWORK_SECURITY_007';
  static const String networkSecurityGeoBlocking = 'NETWORK_SECURITY_008';
  static const String networkSecurityDnsHijacking = 'NETWORK_SECURITY_009';
  static const String networkSecurityTrafficAnalysis = 'NETWORK_SECURITY_010';

  // 금융 보안 (FINANCIAL_SECURITY_001 ~ FINANCIAL_SECURITY_099)
  static const String financialSecurityMoneyLaundering = 'FINANCIAL_SECURITY_001';
  static const String financialSecurityFraudulentTransaction = 'FINANCIAL_SECURITY_002';
  static const String financialSecurityChargeback = 'FINANCIAL_SECURITY_003';
  static const String financialSecurityRefundFraud = 'FINANCIAL_SECURITY_004';
  static const String financialSecurityPaymentFraud = 'FINANCIAL_SECURITY_005';
  static const String financialSecurityKycFraud = 'FINANCIAL_SECURITY_006';
  static const String financialSecurityIdentityTheft = 'FINANCIAL_SECURITY_007';
  static const String financialSecurityAccountTakeover = 'FINANCIAL_SECURITY_008';
  static const String financialSecuritySyntheticIdentity = 'FINANCIAL_SECURITY_009';
  static const String financialSecurityPonziScheme = 'FINANCIAL_SECURITY_010';

  // 개인정보 보안 (PRIVACY_SECURITY_001 ~ PRIVACY_SECURITY_099)
  static const String privacySecurityDataLeak = 'PRIVACY_SECURITY_001';
  static const String privacySecurityUnauthorizedAccess = 'PRIVACY_SECURITY_002';
  static const String privacySecurityDataExfiltration = 'PRIVACY_SECURITY_003';
  static const String privacySecurityPiiExposure = 'PRIVACY_SECURITY_004';
  static const String privacySecurityGdprViolation = 'PRIVACY_SECURITY_005';
  static const String privacySecurityConsentViolation = 'PRIVACY_SECURITY_006';
  static const String privacySecurityDataRetention = 'PRIVACY_SECURITY_007';
  static const String privacySecurityDataPortability = 'PRIVACY_SECURITY_008';
  static const String privacySecurityDataAnonymization = 'PRIVACY_SECURITY_009';
  static const String privacySecurityDataMinimization = 'PRIVACY_SECURITY_010';

  // 시스템 보안 (SYSTEM_SECURITY_001 ~ SYSTEM_SECURITY_099)
  static const String systemSecurityIntrusion = 'SYSTEM_SECURITY_001';
  static const String systemSecurityPrivilegeEscalation = 'SYSTEM_SECURITY_002';
  static const String systemSecurityBackdoor = 'SYSTEM_SECURITY_003';
  static const String systemSecurityMalware = 'SYSTEM_SECURITY_004';
  static const String systemSecurityRansomware = 'SYSTEM_SECURITY_005';
  static const String systemSecurityBotnet = 'SYSTEM_SECURITY_006';
  static const String systemSecurityCryptojacking = 'SYSTEM_SECURITY_007';
  static const String systemSecurityKeylogger = 'SYSTEM_SECURITY_008';
  static const String systemSecuritySpyware = 'SYSTEM_SECURITY_009';
  static const String systemSecurityTrojan = 'SYSTEM_SECURITY_010';

  /// 보안 이벤트 코드별 설명 매핑
  static const Map<String, String> securityDescriptions = {
    // 어뷰징 감지
    abuseMultipleAccounts: '다중 계정 사용 감지',
    abuseRapidActions: '빠른 연속 액션 감지',
    abuseFakeSteps: '가짜 걸음수 감지',
    abuseAdManipulation: '광고 조작 감지',
    abuseReferralFraud: '추천 사기 감지',
    abuseTicketManipulation: '복권 조작 감지',
    abuseRewardFarming: '보상 파밍 감지',
    abuseDeviceSpoofing: '디바이스 스푸핑 감지',
    abuseLocationSpoofing: '위치 스푸핑 감지',
    abuseTimeManipulation: '시간 조작 감지',

    // 의심스러운 활동
    suspiciousLoginPattern: '의심스러운 로그인 패턴',
    suspiciousDeviceChange: '의심스러운 디바이스 변경',
    suspiciousLocationChange: '의심스러운 위치 변경',
    suspiciousBehaviorPattern: '의심스러운 행동 패턴',
    suspiciousNetworkPattern: '의심스러운 네트워크 패턴',
    suspiciousTimePattern: '의심스러운 시간 패턴',
    suspiciousDataPattern: '의심스러운 데이터 패턴',
    suspiciousApiUsage: '의심스러운 API 사용',
    suspiciousBulkActions: '의심스러운 대량 액션',
    suspiciousAutomation: '의심스러운 자동화',

    // 로그인 이상
    loginAnomalyMultipleDevices: '다중 디바이스 로그인',
    loginAnomalyRapidAttempts: '빠른 로그인 시도',
    loginAnomalyFailedAttempts: '로그인 실패 시도',
    loginAnomalyUnusualLocation: '비정상적 위치 로그인',
    loginAnomalyUnusualTime: '비정상적 시간 로그인',
    loginAnomalyDeviceFingerprint: '디바이스 지문 이상',
    loginAnomalyIpAddress: 'IP 주소 이상',
    loginAnomalyUserAgent: 'User Agent 이상',
    loginAnomalySessionHijack: '세션 하이재킹',
    loginAnomalyBruteForce: '무차별 대입 공격',

    // 데이터 무결성
    dataIntegrityTampering: '데이터 변조 감지',
    dataIntegrityCorruption: '데이터 손상 감지',
    dataIntegrityInconsistency: '데이터 불일치 감지',
    dataIntegrityValidationFailed: '데이터 검증 실패',
    dataIntegrityChecksumMismatch: '체크섬 불일치',
    dataIntegrityTimestampManipulation: '타임스탬프 조작',
    dataIntegritySequenceViolation: '시퀀스 위반',
    dataIntegrityConstraintViolation: '제약 조건 위반',
    dataIntegrityDuplicateEntry: '중복 데이터',
    dataIntegrityOrphanedData: '고아 데이터',

    // API 보안
    apiSecurityRateLimitExceeded: 'API 호출 한도 초과',
    apiSecurityInvalidToken: '유효하지 않은 토큰',
    apiSecurityExpiredToken: '만료된 토큰',
    apiSecurityUnauthorizedAccess: '권한 없는 접근',
    apiSecurityForbiddenAccess: '금지된 접근',
    apiSecurityMaliciousRequest: '악의적 요청',
    apiSecuritySqlInjection: 'SQL 인젝션 시도',
    apiSecurityXssAttempt: 'XSS 공격 시도',
    apiSecurityCsrfAttempt: 'CSRF 공격 시도',
    apiSecurityDdosAttempt: 'DDoS 공격 시도',

    // 디바이스 보안
    deviceSecurityRooted: '루팅된 디바이스',
    deviceSecurityJailbroken: '탈옥된 디바이스',
    deviceSecurityEmulator: '에뮬레이터 사용',
    deviceSecurityDebugMode: '디버그 모드',
    deviceSecurityHooking: '후킹 감지',
    deviceSecurityTampering: '디바이스 조작',
    deviceSecurityFakeDevice: '가짜 디바이스',
    deviceSecurityVirtualDevice: '가상 디바이스',
    deviceSecurityProxy: '프록시 사용',
    deviceSecurityVpn: 'VPN 사용',

    // 네트워크 보안
    networkSecurityManInTheMiddle: '중간자 공격',
    networkSecuritySslBypass: 'SSL 우회',
    networkSecurityCertificatePinning: '인증서 핀닝 실패',
    networkSecurityProxyDetection: '프록시 감지',
    networkSecurityVpnDetection: 'VPN 감지',
    networkSecurityTorDetection: 'Tor 감지',
    networkSecuritySuspiciousIp: '의심스러운 IP',
    networkSecurityGeoBlocking: '지역 차단',
    networkSecurityDnsHijacking: 'DNS 하이재킹',
    networkSecurityTrafficAnalysis: '트래픽 분석',

    // 금융 보안
    financialSecurityMoneyLaundering: '자금 세탁',
    financialSecurityFraudulentTransaction: '사기 거래',
    financialSecurityChargeback: '결제 취소',
    financialSecurityRefundFraud: '환불 사기',
    financialSecurityPaymentFraud: '결제 사기',
    financialSecurityKycFraud: 'KYC 사기',
    financialSecurityIdentityTheft: '신원 도용',
    financialSecurityAccountTakeover: '계정 탈취',
    financialSecuritySyntheticIdentity: '합성 신원',
    financialSecurityPonziScheme: '폰지 사기',

    // 개인정보 보안
    privacySecurityDataLeak: '데이터 유출',
    privacySecurityUnauthorizedAccess: '무단 접근',
    privacySecurityDataExfiltration: '데이터 유출',
    privacySecurityPiiExposure: '개인정보 노출',
    privacySecurityGdprViolation: 'GDPR 위반',
    privacySecurityConsentViolation: '동의 위반',
    privacySecurityDataRetention: '데이터 보관 위반',
    privacySecurityDataPortability: '데이터 이식성 위반',
    privacySecurityDataAnonymization: '데이터 익명화 위반',
    privacySecurityDataMinimization: '데이터 최소화 위반',

    // 시스템 보안
    systemSecurityIntrusion: '시스템 침입',
    systemSecurityPrivilegeEscalation: '권한 상승',
    systemSecurityBackdoor: '백도어',
    systemSecurityMalware: '악성코드',
    systemSecurityRansomware: '랜섬웨어',
    systemSecurityBotnet: '봇넷',
    systemSecurityCryptojacking: '크립토재킹',
    systemSecurityKeylogger: '키로거',
    systemSecuritySpyware: '스파이웨어',
    systemSecurityTrojan: '트로이 목마',
  };

  /// 보안 이벤트 코드별 심각도 매핑
  static const Map<String, String> securitySeverity = {
    // Critical (즉시 대응 필요)
    abuseMultipleAccounts: 'critical',
    abuseTicketManipulation: 'critical',
    abuseRewardFarming: 'critical',
    loginAnomalySessionHijack: 'critical',
    loginAnomalyBruteForce: 'critical',
    dataIntegrityTampering: 'critical',
    apiSecuritySqlInjection: 'critical',
    apiSecurityXssAttempt: 'critical',
    apiSecurityDdosAttempt: 'critical',
    deviceSecurityRooted: 'critical',
    deviceSecurityJailbroken: 'critical',
    networkSecurityManInTheMiddle: 'critical',
    financialSecurityMoneyLaundering: 'critical',
    financialSecurityFraudulentTransaction: 'critical',
    privacySecurityDataLeak: 'critical',
    systemSecurityIntrusion: 'critical',
    systemSecurityMalware: 'critical',
    systemSecurityRansomware: 'critical',

    // High (빠른 대응 필요)
    abuseRapidActions: 'high',
    abuseFakeSteps: 'high',
    abuseAdManipulation: 'high',
    abuseReferralFraud: 'high',
    suspiciousLoginPattern: 'high',
    suspiciousBehaviorPattern: 'high',
    loginAnomalyMultipleDevices: 'high',
    loginAnomalyRapidAttempts: 'high',
    dataIntegrityCorruption: 'high',
    apiSecurityRateLimitExceeded: 'high',
    apiSecurityUnauthorizedAccess: 'high',
    deviceSecurityEmulator: 'high',
    deviceSecurityHooking: 'high',
    networkSecuritySslBypass: 'high',
    financialSecurityPaymentFraud: 'high',
    financialSecurityKycFraud: 'high',
    privacySecurityUnauthorizedAccess: 'critical',
    systemSecurityPrivilegeEscalation: 'high',

    // Medium (모니터링 필요)
    abuseDeviceSpoofing: 'medium',
    abuseLocationSpoofing: 'medium',
    abuseTimeManipulation: 'medium',
    suspiciousDeviceChange: 'medium',
    suspiciousLocationChange: 'medium',
    suspiciousNetworkPattern: 'medium',
    loginAnomalyUnusualLocation: 'medium',
    loginAnomalyUnusualTime: 'medium',
    dataIntegrityInconsistency: 'medium',
    apiSecurityInvalidToken: 'medium',
    deviceSecurityDebugMode: 'medium',
    deviceSecurityTampering: 'medium',
    networkSecurityProxyDetection: 'medium',
    networkSecurityVpnDetection: 'medium',
    financialSecurityChargeback: 'medium',
    privacySecurityPiiExposure: 'medium',
    systemSecurityBackdoor: 'medium',

    // Low (로그 기록)
    suspiciousTimePattern: 'low',
    suspiciousDataPattern: 'low',
    suspiciousApiUsage: 'low',
    loginAnomalyDeviceFingerprint: 'low',
    loginAnomalyIpAddress: 'low',
    dataIntegrityValidationFailed: 'low',
    apiSecurityExpiredToken: 'low',
    deviceSecurityFakeDevice: 'low',
    deviceSecurityVirtualDevice: 'low',
    networkSecurityTorDetection: 'low',
    financialSecurityRefundFraud: 'low',
    privacySecurityConsentViolation: 'low',
    systemSecurityBotnet: 'low',
  };

  /// 보안 이벤트 코드별 카테고리 매핑
  static const Map<String, String> securityCategories = {
    // 어뷰징 감지
    abuseMultipleAccounts: 'abuse',
    abuseRapidActions: 'abuse',
    abuseFakeSteps: 'abuse',
    abuseAdManipulation: 'abuse',
    abuseReferralFraud: 'abuse',
    abuseTicketManipulation: 'abuse',
    abuseRewardFarming: 'abuse',
    abuseDeviceSpoofing: 'abuse',
    abuseLocationSpoofing: 'abuse',
    abuseTimeManipulation: 'abuse',

    // 의심스러운 활동
    suspiciousLoginPattern: 'suspicious',
    suspiciousDeviceChange: 'suspicious',
    suspiciousLocationChange: 'suspicious',
    suspiciousBehaviorPattern: 'suspicious',
    suspiciousNetworkPattern: 'suspicious',
    suspiciousTimePattern: 'suspicious',
    suspiciousDataPattern: 'suspicious',
    suspiciousApiUsage: 'suspicious',
    suspiciousBulkActions: 'suspicious',
    suspiciousAutomation: 'suspicious',

    // 로그인 이상
    loginAnomalyMultipleDevices: 'login_anomaly',
    loginAnomalyRapidAttempts: 'login_anomaly',
    loginAnomalyFailedAttempts: 'login_anomaly',
    loginAnomalyUnusualLocation: 'login_anomaly',
    loginAnomalyUnusualTime: 'login_anomaly',
    loginAnomalyDeviceFingerprint: 'login_anomaly',
    loginAnomalyIpAddress: 'login_anomaly',
    loginAnomalyUserAgent: 'login_anomaly',
    loginAnomalySessionHijack: 'login_anomaly',
    loginAnomalyBruteForce: 'login_anomaly',

    // 데이터 무결성
    dataIntegrityTampering: 'data_integrity',
    dataIntegrityCorruption: 'data_integrity',
    dataIntegrityInconsistency: 'data_integrity',
    dataIntegrityValidationFailed: 'data_integrity',
    dataIntegrityChecksumMismatch: 'data_integrity',
    dataIntegrityTimestampManipulation: 'data_integrity',
    dataIntegritySequenceViolation: 'data_integrity',
    dataIntegrityConstraintViolation: 'data_integrity',
    dataIntegrityDuplicateEntry: 'data_integrity',
    dataIntegrityOrphanedData: 'data_integrity',

    // API 보안
    apiSecurityRateLimitExceeded: 'api_security',
    apiSecurityInvalidToken: 'api_security',
    apiSecurityExpiredToken: 'api_security',
    apiSecurityUnauthorizedAccess: 'api_security',
    apiSecurityForbiddenAccess: 'api_security',
    apiSecurityMaliciousRequest: 'api_security',
    apiSecuritySqlInjection: 'api_security',
    apiSecurityXssAttempt: 'api_security',
    apiSecurityCsrfAttempt: 'api_security',
    apiSecurityDdosAttempt: 'api_security',

    // 디바이스 보안
    deviceSecurityRooted: 'device_security',
    deviceSecurityJailbroken: 'device_security',
    deviceSecurityEmulator: 'device_security',
    deviceSecurityDebugMode: 'device_security',
    deviceSecurityHooking: 'device_security',
    deviceSecurityTampering: 'device_security',
    deviceSecurityFakeDevice: 'device_security',
    deviceSecurityVirtualDevice: 'device_security',
    deviceSecurityProxy: 'device_security',
    deviceSecurityVpn: 'device_security',

    // 네트워크 보안
    networkSecurityManInTheMiddle: 'network_security',
    networkSecuritySslBypass: 'network_security',
    networkSecurityCertificatePinning: 'network_security',
    networkSecurityProxyDetection: 'network_security',
    networkSecurityVpnDetection: 'network_security',
    networkSecurityTorDetection: 'network_security',
    networkSecuritySuspiciousIp: 'network_security',
    networkSecurityGeoBlocking: 'network_security',
    networkSecurityDnsHijacking: 'network_security',
    networkSecurityTrafficAnalysis: 'network_security',

    // 금융 보안
    financialSecurityMoneyLaundering: 'financial_security',
    financialSecurityFraudulentTransaction: 'financial_security',
    financialSecurityChargeback: 'financial_security',
    financialSecurityRefundFraud: 'financial_security',
    financialSecurityPaymentFraud: 'financial_security',
    financialSecurityKycFraud: 'financial_security',
    financialSecurityIdentityTheft: 'financial_security',
    financialSecurityAccountTakeover: 'financial_security',
    financialSecuritySyntheticIdentity: 'financial_security',
    financialSecurityPonziScheme: 'financial_security',

    // 개인정보 보안
    privacySecurityDataLeak: 'privacy_security',
    privacySecurityUnauthorizedAccess: 'privacy_security',
    privacySecurityDataExfiltration: 'privacy_security',
    privacySecurityPiiExposure: 'privacy_security',
    privacySecurityGdprViolation: 'privacy_security',
    privacySecurityConsentViolation: 'privacy_security',
    privacySecurityDataRetention: 'privacy_security',
    privacySecurityDataPortability: 'privacy_security',
    privacySecurityDataAnonymization: 'privacy_security',
    privacySecurityDataMinimization: 'privacy_security',

    // 시스템 보안
    systemSecurityIntrusion: 'system_security',
    systemSecurityPrivilegeEscalation: 'system_security',
    systemSecurityBackdoor: 'system_security',
    systemSecurityMalware: 'system_security',
    systemSecurityRansomware: 'system_security',
    systemSecurityBotnet: 'system_security',
    systemSecurityCryptojacking: 'system_security',
    systemSecurityKeylogger: 'system_security',
    systemSecuritySpyware: 'system_security',
    systemSecurityTrojan: 'system_security',
  };

  /// 보안 이벤트 코드 검증
  static bool isValidSecurityCode(String code) {
    return securityDescriptions.containsKey(code);
  }

  /// 보안 이벤트 설명 조회
  static String getSecurityDescription(String code) {
    return securityDescriptions[code] ?? '알 수 없는 보안 이벤트';
  }

  /// 보안 이벤트 심각도 조회
  static String getSecuritySeverity(String code) {
    return securitySeverity[code] ?? 'medium';
  }

  /// 보안 이벤트 카테고리 조회
  static String getSecurityCategory(String code) {
    return securityCategories[code] ?? 'unknown';
  }

  /// 카테고리별 보안 이벤트 코드 조회
  static List<String> getSecurityCodesByCategory(String category) {
    return securityCategories.entries
        .where((entry) => entry.value == category)
        .map((entry) => entry.key)
        .toList();
  }

  /// 심각도별 보안 이벤트 코드 조회
  static List<String> getSecurityCodesBySeverity(String severity) {
    return securitySeverity.entries
        .where((entry) => entry.value == severity)
        .map((entry) => entry.key)
        .toList();
  }

  /// 모든 보안 카테고리 목록
  static List<String> getAllSecurityCategories() {
    return securityCategories.values.toSet().toList();
  }

  /// 모든 보안 심각도 목록
  static List<String> getAllSecuritySeverities() {
    return securitySeverity.values.toSet().toList();
  }
}
