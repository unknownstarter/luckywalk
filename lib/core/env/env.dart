class Env {
  // Supabase Configuration
  static const String supabaseUrl = 'https://your-project.supabase.co';
  static const String supabaseAnonKey = 'your-anon-key';
  
  // AdMob Configuration
  static const String admobAppId = 'ca-app-pub-3940256099942544~3347511713';
  static const String admobRewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static const String admobInterstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static const String admobBannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  
  // Firebase Configuration
  static const String fcmServerKey = 'your-fcm-server-key';
  
  // App Configuration
  static const String appName = 'LuckyWalk';
  static const String appVersion = '1.0.0';
  static const String appBuildNumber = '1';
  static const String minSupportedAppVersion = '1.0.0';
  
  // API Configuration
  static const String apiBaseUrl = 'https://your-project.supabase.co/functions/v1';
  static const int apiTimeout = 30000; // 30 seconds
  
  // Feature Flags
  static const bool enableAds = true;
  static const bool enableAnalytics = true;
  static const bool enableCrashlytics = true;
  static const bool enablePushNotifications = true;
  
  // Reward Configuration
  static const int maxDailyAds = 10;
  static const int maxStepsThreshold = 10000;
  static const int attendanceReward = 3;
  static const int referralReward = 100;
  
  // Prize Configuration
  static const int tier1Prize = 1000000; // 1등 상금 (원)
  static const int tier2Prize = 500000;  // 2등 상금 (원)
  static const int tier3Reward = 50;     // 3등 보상 (복권 장수)
  static const int tier4Reward = 10;     // 4등 보상 (복권 장수)
  static const int tier5Reward = 5;      // 5등 보상 (복권 장수)
  
  // Time Configuration
  static const String timezone = 'Asia/Seoul';
  static const int sessionTimeout = 30; // days
  
  // Security Configuration
  static const String encryptionKey = 'your-encryption-key';
  static const int maxLoginAttempts = 5;
  static const int lockoutDuration = 15; // minutes
}
