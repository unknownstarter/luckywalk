/// LuckyWalk 이벤트코드 체계
/// 생성일: 2025-09-17 23:49:41 KST
/// 설명: 복권앱의 모든 이벤트코드를 체계적으로 관리

class EventCodes {
  // 사용자 인증 이벤트 (USER_AUTH_001 ~ USER_AUTH_099)
  static const String userLogin = 'USER_AUTH_001';
  static const String userLogout = 'USER_AUTH_002';
  static const String userSignup = 'USER_AUTH_003';
  static const String userOnboardingComplete = 'USER_AUTH_004';
  static const String userProfileUpdate = 'USER_AUTH_005';
  static const String userAppleLogin = 'USER_AUTH_006';
  static const String userKakaoLogin = 'USER_AUTH_007';
  static const String userSessionRefresh = 'USER_AUTH_008';
  static const String userPasswordReset = 'USER_AUTH_009';
  static const String userAccountDeletion = 'USER_AUTH_010';

  // 복권 관련 이벤트 (TICKET_001 ~ TICKET_099)
  static const String ticketSubmit = 'TICKET_001';
  static const String ticketSubmitSuccess = 'TICKET_002';
  static const String ticketSubmitFailed = 'TICKET_003';
  static const String ticketView = 'TICKET_004';
  static const String ticketHistoryView = 'TICKET_005';
  static const String ticketNumbersGenerate = 'TICKET_006';
  static const String ticketNumbersManual = 'TICKET_007';
  static const String ticketRoundView = 'TICKET_008';
  static const String ticketRoundChange = 'TICKET_009';
  static const String ticketSubmissionCancel = 'TICKET_010';

  // 보상 관련 이벤트 (REWARD_001 ~ REWARD_099)
  static const String rewardClaim = 'REWARD_001';
  static const String rewardClaimSuccess = 'REWARD_002';
  static const String rewardClaimFailed = 'REWARD_003';
  static const String rewardStepsClaim = 'REWARD_004';
  static const String rewardAdWatch = 'REWARD_005';
  static const String rewardAdComplete = 'REWARD_006';
  static const String rewardAttendance = 'REWARD_007';
  static const String rewardReferral = 'REWARD_008';
  static const String rewardHistoryView = 'REWARD_009';
  static const String rewardBalanceCheck = 'REWARD_010';

  // 당첨 결과 이벤트 (WINNING_001 ~ WINNING_099)
  static const String winningResultView = 'WINNING_001';
  static const String winningResultCheck = 'WINNING_002';
  static const String winningResultShare = 'WINNING_003';
  static const String winningResultKycRequired = 'WINNING_004';
  static const String winningResultKycSubmit = 'WINNING_005';
  static const String winningResultPrizeClaim = 'WINNING_006';
  static const String winningResultHistoryView = 'WINNING_007';
  static const String winningResultNotification = 'WINNING_008';
  static const String winningResultCelebration = 'WINNING_009';
  static const String winningResultNoWin = 'WINNING_010';

  // KYC 관련 이벤트 (KYC_001 ~ KYC_099)
  static const String kycStart = 'KYC_001';
  static const String kycSubmit = 'KYC_002';
  static const String kycApprove = 'KYC_003';
  static const String kycReject = 'KYC_004';
  static const String kycDocumentUpload = 'KYC_005';
  static const String kycDocumentVerify = 'KYC_006';
  static const String kycStatusCheck = 'KYC_007';
  static const String kycResubmit = 'KYC_008';
  static const String kycComplete = 'KYC_009';
  static const String kycCancel = 'KYC_010';

  // 추천 관련 이벤트 (REFERRAL_001 ~ REFERRAL_099)
  static const String referralCodeGenerate = 'REFERRAL_001';
  static const String referralCodeShare = 'REFERRAL_002';
  static const String referralCodeUse = 'REFERRAL_003';
  static const String referralInvite = 'REFERRAL_004';
  static const String referralInviteAccept = 'REFERRAL_005';
  static const String referralRewardClaim = 'REFERRAL_006';
  static const String referralHistoryView = 'REFERRAL_007';
  static const String referralStatsView = 'REFERRAL_008';
  static const String referralLinkCopy = 'REFERRAL_009';
  static const String referralSocialShare = 'REFERRAL_010';

  // 광고 관련 이벤트 (AD_001 ~ AD_099)
  static const String adLoad = 'AD_001';
  static const String adShow = 'AD_002';
  static const String adClick = 'AD_003';
  static const String adComplete = 'AD_004';
  static const String adSkip = 'AD_005';
  static const String adError = 'AD_006';
  static const String adRewardEarned = 'AD_007';
  static const String adRewardFailed = 'AD_008';
  static const String adFrequencyLimit = 'AD_009';
  static const String adInventoryEmpty = 'AD_010';

  // 걸음수 관련 이벤트 (STEPS_001 ~ STEPS_099)
  static const String stepsSync = 'STEPS_001';
  static const String stepsPermissionRequest = 'STEPS_002';
  static const String stepsPermissionGranted = 'STEPS_003';
  static const String stepsPermissionDenied = 'STEPS_004';
  static const String stepsThresholdReached = 'STEPS_005';
  static const String stepsRewardClaim = 'STEPS_006';
  static const String stepsHistoryView = 'STEPS_007';
  static const String stepsGoalSet = 'STEPS_008';
  static const String stepsGoalAchieved = 'STEPS_009';
  static const String stepsDataCorrupted = 'STEPS_010';

  // 네비게이션 이벤트 (NAV_001 ~ NAV_099)
  static const String navHome = 'NAV_001';
  static const String navSubmit = 'NAV_002';
  static const String navHistory = 'NAV_003';
  static const String navProfile = 'NAV_004';
  static const String navSettings = 'NAV_005';
  static const String navRewards = 'NAV_006';
  static const String navReferral = 'NAV_007';
  static const String navKyc = 'NAV_008';
  static const String navHelp = 'NAV_009';
  static const String navAbout = 'NAV_010';

  // 설정 관련 이벤트 (SETTINGS_001 ~ SETTINGS_099)
  static const String settingsOpen = 'SETTINGS_001';
  static const String settingsNotificationToggle = 'SETTINGS_002';
  static const String settingsPrivacyUpdate = 'SETTINGS_003';
  static const String settingsAccountDelete = 'SETTINGS_004';
  static const String settingsDataExport = 'SETTINGS_005';
  static const String settingsLanguageChange = 'SETTINGS_006';
  static const String settingsThemeChange = 'SETTINGS_007';
  static const String settingsBackupToggle = 'SETTINGS_008';
  static const String settingsSyncToggle = 'SETTINGS_009';
  static const String settingsReset = 'SETTINGS_010';

  // 결제 관련 이벤트 (PAYMENT_001 ~ PAYMENT_099)
  static const String paymentStart = 'PAYMENT_001';
  static const String paymentSuccess = 'PAYMENT_002';
  static const String paymentFailed = 'PAYMENT_003';
  static const String paymentCancel = 'PAYMENT_004';
  static const String paymentRefund = 'PAYMENT_005';
  static const String paymentMethodAdd = 'PAYMENT_006';
  static const String paymentMethodRemove = 'PAYMENT_007';
  static const String paymentHistoryView = 'PAYMENT_008';
  static const String paymentReceiptView = 'PAYMENT_009';
  static const String paymentDispute = 'PAYMENT_010';

  // 알림 관련 이벤트 (NOTIFICATION_001 ~ NOTIFICATION_099)
  static const String notificationReceived = 'NOTIFICATION_001';
  static const String notificationClick = 'NOTIFICATION_002';
  static const String notificationDismiss = 'NOTIFICATION_003';
  static const String notificationPermissionRequest = 'NOTIFICATION_004';
  static const String notificationPermissionGranted = 'NOTIFICATION_005';
  static const String notificationPermissionDenied = 'NOTIFICATION_006';
  static const String notificationSettingsUpdate = 'NOTIFICATION_007';
  static const String notificationSchedule = 'NOTIFICATION_008';
  static const String notificationCancel = 'NOTIFICATION_009';
  static const String notificationError = 'NOTIFICATION_010';

  // 앱 생명주기 이벤트 (APP_001 ~ APP_099)
  static const String appLaunch = 'APP_001';
  static const String appResume = 'APP_002';
  static const String appPause = 'APP_003';
  static const String appBackground = 'APP_004';
  static const String appForeground = 'APP_005';
  static const String appTerminate = 'APP_006';
  static const String appUpdate = 'APP_007';
  static const String appCrash = 'APP_008';
  static const String appMemoryWarning = 'APP_009';
  static const String appNetworkChange = 'APP_010';

  // 성능 관련 이벤트 (PERFORMANCE_001 ~ PERFORMANCE_099)
  static const String performanceSlowLoad = 'PERFORMANCE_001';
  static const String performanceMemoryHigh = 'PERFORMANCE_002';
  static const String performanceBatteryLow = 'PERFORMANCE_003';
  static const String performanceStorageFull = 'PERFORMANCE_004';
  static const String performanceNetworkSlow = 'PERFORMANCE_005';
  static const String performanceCpuHigh = 'PERFORMANCE_006';
  static const String performanceGpuHigh = 'PERFORMANCE_007';
  static const String performanceDiskFull = 'PERFORMANCE_008';
  static const String performanceCacheFull = 'PERFORMANCE_009';
  static const String performanceQueueFull = 'PERFORMANCE_010';

  /// 이벤트코드별 설명 매핑
  static const Map<String, String> eventDescriptions = {
    // 사용자 인증
    userLogin: '사용자 로그인',
    userLogout: '사용자 로그아웃',
    userSignup: '사용자 회원가입',
    userOnboardingComplete: '온보딩 완료',
    userProfileUpdate: '프로필 업데이트',
    userAppleLogin: 'Apple 로그인',
    userKakaoLogin: 'Kakao 로그인',
    userSessionRefresh: '세션 갱신',
    userPasswordReset: '비밀번호 재설정',
    userAccountDeletion: '계정 삭제',

    // 복권 관련
    ticketSubmit: '복권 응모',
    ticketSubmitSuccess: '복권 응모 성공',
    ticketSubmitFailed: '복권 응모 실패',
    ticketView: '복권 조회',
    ticketHistoryView: '복권 이력 조회',
    ticketNumbersGenerate: '번호 자동 생성',
    ticketNumbersManual: '번호 수동 입력',
    ticketRoundView: '회차 조회',
    ticketRoundChange: '회차 변경',
    ticketSubmissionCancel: '복권 응모 취소',

    // 보상 관련
    rewardClaim: '보상 수령',
    rewardClaimSuccess: '보상 수령 성공',
    rewardClaimFailed: '보상 수령 실패',
    rewardStepsClaim: '걸음수 보상 수령',
    rewardAdWatch: '광고 시청',
    rewardAdComplete: '광고 시청 완료',
    rewardAttendance: '출석체크',
    rewardReferral: '추천 보상',
    rewardHistoryView: '보상 이력 조회',
    rewardBalanceCheck: '보상 잔액 확인',

    // 당첨 결과
    winningResultView: '당첨 결과 조회',
    winningResultCheck: '당첨 결과 확인',
    winningResultShare: '당첨 결과 공유',
    winningResultKycRequired: 'KYC 인증 필요',
    winningResultKycSubmit: 'KYC 인증 제출',
    winningResultPrizeClaim: '당첨금 수령',
    winningResultHistoryView: '당첨 이력 조회',
    winningResultNotification: '당첨 알림',
    winningResultCelebration: '당첨 축하',
    winningResultNoWin: '미당첨',

    // KYC 관련
    kycStart: 'KYC 시작',
    kycSubmit: 'KYC 제출',
    kycApprove: 'KYC 승인',
    kycReject: 'KYC 거부',
    kycDocumentUpload: 'KYC 서류 업로드',
    kycDocumentVerify: 'KYC 서류 검증',
    kycStatusCheck: 'KYC 상태 확인',
    kycResubmit: 'KYC 재제출',
    kycComplete: 'KYC 완료',
    kycCancel: 'KYC 취소',

    // 추천 관련
    referralCodeGenerate: '추천코드 생성',
    referralCodeShare: '추천코드 공유',
    referralCodeUse: '추천코드 사용',
    referralInvite: '추천 초대',
    referralInviteAccept: '추천 수락',
    referralRewardClaim: '추천 보상 수령',
    referralHistoryView: '추천 이력 조회',
    referralStatsView: '추천 통계 조회',
    referralLinkCopy: '추천 링크 복사',
    referralSocialShare: '추천 소셜 공유',

    // 광고 관련
    adLoad: '광고 로드',
    adShow: '광고 표시',
    adClick: '광고 클릭',
    adComplete: '광고 완료',
    adSkip: '광고 건너뛰기',
    adError: '광고 오류',
    adRewardEarned: '광고 보상 획득',
    adRewardFailed: '광고 보상 실패',
    adFrequencyLimit: '광고 시청 한도',
    adInventoryEmpty: '광고 재고 없음',

    // 걸음수 관련
    stepsSync: '걸음수 동기화',
    stepsPermissionRequest: '걸음수 권한 요청',
    stepsPermissionGranted: '걸음수 권한 허용',
    stepsPermissionDenied: '걸음수 권한 거부',
    stepsThresholdReached: '걸음수 기준 달성',
    stepsRewardClaim: '걸음수 보상 수령',
    stepsHistoryView: '걸음수 이력 조회',
    stepsGoalSet: '걸음수 목표 설정',
    stepsGoalAchieved: '걸음수 목표 달성',
    stepsDataCorrupted: '걸음수 데이터 오류',

    // 네비게이션
    navHome: '홈 화면 이동',
    navSubmit: '응모 화면 이동',
    navHistory: '이력 화면 이동',
    navProfile: '프로필 화면 이동',
    navSettings: '설정 화면 이동',
    navRewards: '보상 화면 이동',
    navReferral: '추천 화면 이동',
    navKyc: 'KYC 화면 이동',
    navHelp: '도움말 화면 이동',
    navAbout: '앱 정보 화면 이동',

    // 설정
    settingsOpen: '설정 화면 열기',
    settingsNotificationToggle: '알림 설정 변경',
    settingsPrivacyUpdate: '개인정보 설정 변경',
    settingsAccountDelete: '계정 삭제',
    settingsDataExport: '데이터 내보내기',
    settingsLanguageChange: '언어 변경',
    settingsThemeChange: '테마 변경',
    settingsBackupToggle: '백업 설정 변경',
    settingsSyncToggle: '동기화 설정 변경',
    settingsReset: '설정 초기화',

    // 결제
    paymentStart: '결제 시작',
    paymentSuccess: '결제 성공',
    paymentFailed: '결제 실패',
    paymentCancel: '결제 취소',
    paymentRefund: '결제 환불',
    paymentMethodAdd: '결제 수단 추가',
    paymentMethodRemove: '결제 수단 제거',
    paymentHistoryView: '결제 이력 조회',
    paymentReceiptView: '결제 영수증 조회',
    paymentDispute: '결제 분쟁',

    // 알림
    notificationReceived: '알림 수신',
    notificationClick: '알림 클릭',
    notificationDismiss: '알림 해제',
    notificationPermissionRequest: '알림 권한 요청',
    notificationPermissionGranted: '알림 권한 허용',
    notificationPermissionDenied: '알림 권한 거부',
    notificationSettingsUpdate: '알림 설정 업데이트',
    notificationSchedule: '알림 예약',
    notificationCancel: '알림 취소',
    notificationError: '알림 오류',

    // 앱 생명주기
    appLaunch: '앱 실행',
    appResume: '앱 재개',
    appPause: '앱 일시정지',
    appBackground: '앱 백그라운드',
    appForeground: '앱 포그라운드',
    appTerminate: '앱 종료',
    appUpdate: '앱 업데이트',
    appCrash: '앱 크래시',
    appMemoryWarning: '메모리 부족 경고',
    appNetworkChange: '네트워크 상태 변경',

    // 성능
    performanceSlowLoad: '느린 로딩',
    performanceMemoryHigh: '메모리 사용량 높음',
    performanceBatteryLow: '배터리 부족',
    performanceStorageFull: '저장공간 부족',
    performanceNetworkSlow: '네트워크 속도 느림',
    performanceCpuHigh: 'CPU 사용량 높음',
    performanceGpuHigh: 'GPU 사용량 높음',
    performanceDiskFull: '디스크 공간 부족',
    performanceCacheFull: '캐시 공간 부족',
    performanceQueueFull: '큐 공간 부족',
  };

  /// 이벤트코드별 카테고리 매핑
  static const Map<String, String> eventCategories = {
    // 사용자 인증
    userLogin: 'authentication',
    userLogout: 'authentication',
    userSignup: 'authentication',
    userOnboardingComplete: 'authentication',
    userProfileUpdate: 'authentication',
    userAppleLogin: 'authentication',
    userKakaoLogin: 'authentication',
    userSessionRefresh: 'authentication',
    userPasswordReset: 'authentication',
    userAccountDeletion: 'authentication',

    // 복권 관련
    ticketSubmit: 'lottery',
    ticketSubmitSuccess: 'lottery',
    ticketSubmitFailed: 'lottery',
    ticketView: 'lottery',
    ticketHistoryView: 'lottery',
    ticketNumbersGenerate: 'lottery',
    ticketNumbersManual: 'lottery',
    ticketRoundView: 'lottery',
    ticketRoundChange: 'lottery',
    ticketSubmissionCancel: 'lottery',

    // 보상 관련
    rewardClaim: 'reward',
    rewardClaimSuccess: 'reward',
    rewardClaimFailed: 'reward',
    rewardStepsClaim: 'reward',
    rewardAdWatch: 'reward',
    rewardAdComplete: 'reward',
    rewardAttendance: 'reward',
    rewardReferral: 'reward',
    rewardHistoryView: 'reward',
    rewardBalanceCheck: 'reward',

    // 당첨 결과
    winningResultView: 'winning',
    winningResultCheck: 'winning',
    winningResultShare: 'winning',
    winningResultKycRequired: 'winning',
    winningResultKycSubmit: 'winning',
    winningResultPrizeClaim: 'winning',
    winningResultHistoryView: 'winning',
    winningResultNotification: 'winning',
    winningResultCelebration: 'winning',
    winningResultNoWin: 'winning',

    // KYC 관련
    kycStart: 'kyc',
    kycSubmit: 'kyc',
    kycApprove: 'kyc',
    kycReject: 'kyc',
    kycDocumentUpload: 'kyc',
    kycDocumentVerify: 'kyc',
    kycStatusCheck: 'kyc',
    kycResubmit: 'kyc',
    kycComplete: 'kyc',
    kycCancel: 'kyc',

    // 추천 관련
    referralCodeGenerate: 'referral',
    referralCodeShare: 'referral',
    referralCodeUse: 'referral',
    referralInvite: 'referral',
    referralInviteAccept: 'referral',
    referralRewardClaim: 'referral',
    referralHistoryView: 'referral',
    referralStatsView: 'referral',
    referralLinkCopy: 'referral',
    referralSocialShare: 'referral',

    // 광고 관련
    adLoad: 'advertisement',
    adShow: 'advertisement',
    adClick: 'advertisement',
    adComplete: 'advertisement',
    adSkip: 'advertisement',
    adError: 'advertisement',
    adRewardEarned: 'advertisement',
    adRewardFailed: 'advertisement',
    adFrequencyLimit: 'advertisement',
    adInventoryEmpty: 'advertisement',

    // 걸음수 관련
    stepsSync: 'steps',
    stepsPermissionRequest: 'steps',
    stepsPermissionGranted: 'steps',
    stepsPermissionDenied: 'steps',
    stepsThresholdReached: 'steps',
    stepsRewardClaim: 'steps',
    stepsHistoryView: 'steps',
    stepsGoalSet: 'steps',
    stepsGoalAchieved: 'steps',
    stepsDataCorrupted: 'steps',

    // 네비게이션
    navHome: 'navigation',
    navSubmit: 'navigation',
    navHistory: 'navigation',
    navProfile: 'navigation',
    navSettings: 'navigation',
    navRewards: 'navigation',
    navReferral: 'navigation',
    navKyc: 'navigation',
    navHelp: 'navigation',
    navAbout: 'navigation',

    // 설정
    settingsOpen: 'settings',
    settingsNotificationToggle: 'settings',
    settingsPrivacyUpdate: 'settings',
    settingsAccountDelete: 'settings',
    settingsDataExport: 'settings',
    settingsLanguageChange: 'settings',
    settingsThemeChange: 'settings',
    settingsBackupToggle: 'settings',
    settingsSyncToggle: 'settings',
    settingsReset: 'settings',

    // 결제
    paymentStart: 'payment',
    paymentSuccess: 'payment',
    paymentFailed: 'payment',
    paymentCancel: 'payment',
    paymentRefund: 'payment',
    paymentMethodAdd: 'payment',
    paymentMethodRemove: 'payment',
    paymentHistoryView: 'payment',
    paymentReceiptView: 'payment',
    paymentDispute: 'payment',

    // 알림
    notificationReceived: 'notification',
    notificationClick: 'notification',
    notificationDismiss: 'notification',
    notificationPermissionRequest: 'notification',
    notificationPermissionGranted: 'notification',
    notificationPermissionDenied: 'notification',
    notificationSettingsUpdate: 'notification',
    notificationSchedule: 'notification',
    notificationCancel: 'notification',
    notificationError: 'notification',

    // 앱 생명주기
    appLaunch: 'app_lifecycle',
    appResume: 'app_lifecycle',
    appPause: 'app_lifecycle',
    appBackground: 'app_lifecycle',
    appForeground: 'app_lifecycle',
    appTerminate: 'app_lifecycle',
    appUpdate: 'app_lifecycle',
    appCrash: 'app_lifecycle',
    appMemoryWarning: 'app_lifecycle',
    appNetworkChange: 'app_lifecycle',

    // 성능
    performanceSlowLoad: 'performance',
    performanceMemoryHigh: 'performance',
    performanceBatteryLow: 'performance',
    performanceStorageFull: 'performance',
    performanceNetworkSlow: 'performance',
    performanceCpuHigh: 'performance',
    performanceGpuHigh: 'performance',
    performanceDiskFull: 'performance',
    performanceCacheFull: 'performance',
    performanceQueueFull: 'performance',
  };

  /// 이벤트코드 검증
  static bool isValidEventCode(String code) {
    return eventDescriptions.containsKey(code);
  }

  /// 이벤트 설명 조회
  static String getEventDescription(String code) {
    return eventDescriptions[code] ?? '알 수 없는 이벤트';
  }

  /// 이벤트 카테고리 조회
  static String getEventCategory(String code) {
    return eventCategories[code] ?? 'unknown';
  }

  /// 카테고리별 이벤트코드 조회
  static List<String> getEventCodesByCategory(String category) {
    return eventCategories.entries
        .where((entry) => entry.value == category)
        .map((entry) => entry.key)
        .toList();
  }

  /// 모든 카테고리 목록
  static List<String> getAllCategories() {
    return eventCategories.values.toSet().toList();
  }
}
