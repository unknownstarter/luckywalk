import 'package:flutter_dotenv/flutter_dotenv.dart';

/// 환경 변수 로더
/// 생성일: 2025-09-17 23:49:41 KST
/// 설명: .env 파일에서 환경 변수를 로드하고 관리

class EnvLoader {
  static bool _isLoaded = false;

  /// 환경 변수 로드
  static Future<void> load() async {
    if (_isLoaded) return;

    try {
      await dotenv.load(fileName: '.env');
      _isLoaded = true;
      print('✅ Environment variables loaded successfully');
    } catch (e) {
      print('⚠️ Failed to load .env file: $e');
      print('📝 Using default values from env.dart');
    }
  }

  /// 환경 변수 값 조회
  static String get(String key, {String defaultValue = ''}) {
    if (!_isLoaded) {
      print('⚠️ Environment variables not loaded yet');
      return defaultValue;
    }
    
    return dotenv.env[key] ?? defaultValue;
  }

  /// Supabase URL 조회
  static String get supabaseUrl => get('SUPABASE_URL', defaultValue: 'https://your-project.supabase.co');

  /// Supabase Anon Key 조회
  static String get supabaseAnonKey => get('SUPABASE_ANON_KEY', defaultValue: 'your-anon-key');

  /// Supabase Service Role Key 조회
  static String get supabaseServiceRoleKey => get('SUPABASE_SERVICE_ROLE_KEY', defaultValue: 'your-service-role-key');

  /// Apple Client ID 조회
  static String get appleClientId => get('APPLE_CLIENT_ID', defaultValue: 'your-apple-client-id');

  /// Apple Team ID 조회
  static String get appleTeamId => get('APPLE_TEAM_ID', defaultValue: 'your-apple-team-id');

  /// Apple Key ID 조회
  static String get appleKeyId => get('APPLE_KEY_ID', defaultValue: 'your-apple-key-id');

  /// Apple Private Key 조회
  static String get applePrivateKey => get('APPLE_PRIVATE_KEY', defaultValue: 'your-apple-private-key');

  /// Kakao Native App Key 조회
  static String get kakaoNativeAppKey => get('KAKAO_NATIVE_APP_KEY', defaultValue: 'your-kakao-native-app-key');

  /// Kakao REST API Key 조회
  static String get kakaoRestApiKey => get('KAKAO_REST_API_KEY', defaultValue: 'your-kakao-rest-api-key');

  /// 앱 버전 조회
  static String get appVersion => get('APP_VERSION', defaultValue: '1.0.0');

  /// 최소 지원 버전 조회
  static String get minSupportedVersion => get('MIN_SUPPORTED_VERSION', defaultValue: '1.0.0');

  /// 디버그 모드 여부
  static bool get debugMode => get('DEBUG_MODE', defaultValue: 'true').toLowerCase() == 'true';

  /// 로그 레벨 조회
  static String get logLevel => get('LOG_LEVEL', defaultValue: 'info');

  /// 분석 활성화 여부
  static bool get enableAnalytics => get('ENABLE_ANALYTICS', defaultValue: 'true').toLowerCase() == 'true';

  /// 크래시 리포팅 활성화 여부
  static bool get enableCrashReporting => get('ENABLE_CRASH_REPORTING', defaultValue: 'true').toLowerCase() == 'true';

  /// 암호화 키 조회
  static String get encryptionKey => get('ENCRYPTION_KEY', defaultValue: 'your-32-character-encryption-key');

  /// JWT 시크릿 조회
  static String get jwtSecret => get('JWT_SECRET', defaultValue: 'your-jwt-secret-key');

  /// 기본 복권 가격
  static int get defaultTicketPrice => int.tryParse(get('DEFAULT_TICKET_PRICE', defaultValue: '100')) ?? 100;

  /// 최대 복권 응모 수
  static int get maxTicketsPerSubmission => int.tryParse(get('MAX_TICKETS_PER_SUBMISSION', defaultValue: '1000')) ?? 1000;

  /// 추첨 시간 (UTC)
  static String get drawTimeUtc => get('DRAW_TIME_UTC', defaultValue: '11:50');

  /// 정산 시간 (UTC)
  static String get settlementTimeUtc => get('SETTLEMENT_TIME_UTC', defaultValue: '03:00');

  /// 최소 지원 앱 버전
  static String get minSupportedAppVersion => get('MIN_SUPPORTED_APP_VERSION', defaultValue: '1.0.0');

  /// 환경 변수 로드 상태 확인
  static bool get isLoaded => _isLoaded;

  /// 모든 환경 변수 출력 (디버그용)
  static void printAll() {
    if (!_isLoaded) {
      print('⚠️ Environment variables not loaded');
      return;
    }

    print('📋 Environment Variables:');
    print('SUPABASE_URL: ${supabaseUrl}');
    print('SUPABASE_ANON_KEY: ${supabaseAnonKey.substring(0, 20)}...');
    print('APP_VERSION: $appVersion');
    print('DEBUG_MODE: $debugMode');
    print('LOG_LEVEL: $logLevel');
    print('ENABLE_ANALYTICS: $enableAnalytics');
    print('ENABLE_CRASH_REPORTING: $enableCrashReporting');
  }
}
