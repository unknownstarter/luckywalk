import 'package:supabase_flutter/supabase_flutter.dart';
import '../env/env_loader.dart';
import '../logging/logger.dart';

class LuckyWalkSupabaseClient {
  static LuckyWalkSupabaseClient? _instance;
  static LuckyWalkSupabaseClient get instance =>
      _instance ??= LuckyWalkSupabaseClient._();

  LuckyWalkSupabaseClient._();

  late SupabaseClient _client;

  SupabaseClient get client => _client;

  Future<void> initialize() async {
    try {
      // Load environment variables
      await EnvLoader.load();

      final supabaseUrl = EnvLoader.supabaseUrl;
      final supabaseAnonKey = EnvLoader.supabaseAnonKey;

      if (supabaseUrl.isEmpty || supabaseAnonKey.isEmpty) {
        throw Exception(
          'Supabase URL or Anon Key not found in environment variables',
        );
      }

      await Supabase.initialize(
        url: supabaseUrl,
        anonKey: supabaseAnonKey,
        authOptions: const FlutterAuthClientOptions(
          authFlowType: AuthFlowType.pkce,
        ),
        realtimeClientOptions: const RealtimeClientOptions(
          logLevel: RealtimeLogLevel.info,
        ),
        storageOptions: const StorageClientOptions(retryAttempts: 3),
      );

      _client = Supabase.instance.client;

      AppLogger.info('Supabase initialized successfully');
    } catch (e) {
      AppLogger.error('Failed to initialize Supabase: $e');
      rethrow;
    }
  }

  // Auth methods
  User? get currentUser => _client.auth.currentUser;
  Session? get currentSession => _client.auth.currentSession;
  bool get isLoggedIn => currentUser != null;

  // Database methods
  SupabaseQueryBuilder from(String table) => _client.from(table);

  // Storage methods
  SupabaseStorageClient get storage => _client.storage;

  // Realtime methods
  RealtimeChannel channel(String name) => _client.realtime.channel(name);

  // Auth methods
  Future<AuthResponse> signInWithPassword({
    required String email,
    required String password,
  }) => _client.auth.signInWithPassword(email: email, password: password);

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    Map<String, dynamic>? data,
  }) => _client.auth.signUp(email: email, password: password, data: data);

  Future<void> signOut() => _client.auth.signOut();

  // Social login methods
  Future<AuthResponse> signInWithKakao({
    required String code,
    required String redirectUri,
  }) async {
    final response = await _client.functions.invoke(
      'auth-kakao',
      body: {'code': code, 'redirect_uri': redirectUri},
    );

    if (response.data != null) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Kakao login failed');
    }
  }

  Future<AuthResponse> signInWithApple({
    required String identityToken,
    String? authorizationCode,
    Map<String, dynamic>? user,
  }) async {
    final response = await _client.functions.invoke(
      'auth-apple',
      body: {
        'identityToken': identityToken,
        'authorizationCode': authorizationCode,
        'user': user,
      },
    );

    if (response.data != null) {
      return AuthResponse.fromJson(response.data);
    } else {
      throw Exception('Apple login failed');
    }
  }

  // Analytics methods
  Future<void> logUserActivity({
    required String userId,
    required String activityType,
    required int activityValue,
    Map<String, dynamic>? activityData,
    double? latitude,
    double? longitude,
    double? locationAccuracy,
    String? deviceType,
    String? appVersion,
    String? osVersion,
  }) async {
    try {
      await _client.from('user_activities').insert({
        'user_id': userId,
        'activity_type': activityType,
        'activity_value': activityValue,
        'activity_data': activityData ?? {},
        'latitude': latitude,
        'longitude': longitude,
        'location_accuracy': locationAccuracy,
        'device_type': deviceType,
        'app_version': appVersion,
        'os_version': osVersion,
      });
    } catch (e) {
      AppLogger.error('Failed to log user activity: $e');
    }
  }

  Future<void> logAppEvent({
    String? userId,
    required String eventName,
    required String eventCategory,
    Map<String, dynamic>? eventData,
    String? sessionId,
    String? screenName,
    String? screenPath,
    String? userAgent,
    String? ipAddress,
  }) async {
    try {
      await _client.from('app_events').insert({
        'user_id': userId,
        'event_name': eventName,
        'event_category': eventCategory,
        'event_data': eventData ?? {},
        'session_id': sessionId,
        'screen_name': screenName,
        'screen_path': screenPath,
        'user_agent': userAgent,
        'ip_address': ipAddress,
      });
    } catch (e) {
      AppLogger.error('Failed to log app event: $e');
    }
  }

  // Lottery methods
  Future<List<Map<String, dynamic>>> getLotteryRounds({
    int? limit,
    String? status,
  }) async {
    try {
      dynamic query = _client.from('lottery_rounds').select();

      if (status != null) {
        query = query.eq('status', status);
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query.order('round_number', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get lottery rounds: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> getCurrentLotteryRound() async {
    try {
      final response = await _client
          .from('lottery_rounds')
          .select()
          .eq('status', 'active')
          .single();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get current lottery round: $e');
      return null;
    }
  }

  Future<List<Map<String, dynamic>>> getUserTickets({
    required String userId,
    String? roundId,
  }) async {
    try {
      var query = _client.from('user_tickets').select().eq('user_id', userId);

      if (roundId != null) {
        query = query.eq('round_id', roundId);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get user tickets: $e');
      return [];
    }
  }

  Future<Map<String, dynamic>?> submitTickets({
    required String userId,
    required String roundId,
    required List<List<int>> tickets,
    String ticketType = 'manual',
    String purchaseMethod = 'free',
  }) async {
    try {
      final ticketData = tickets
          .map(
            (ticket) => {
              'user_id': userId,
              'round_id': roundId,
              'ticket_numbers': ticket,
              'ticket_type': ticketType,
              'purchase_method': purchaseMethod,
            },
          )
          .toList();

      final response = await _client
          .from('user_tickets')
          .insert(ticketData)
          .select();

      return response.first;
    } catch (e) {
      AppLogger.error('Failed to submit tickets: $e');
      return null;
    }
  }

  // Reward methods
  Future<List<Map<String, dynamic>>> getRewards({
    String? rewardType,
    bool? isActive,
  }) async {
    try {
      var query = _client.from('rewards').select();

      if (rewardType != null) {
        query = query.eq('reward_type', rewardType);
      }

      if (isActive != null) {
        query = query.eq('is_active', isActive);
      }

      final response = await query.order('order_index', ascending: true);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get rewards: $e');
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> getUserRewards({
    required String userId,
    bool? isClaimed,
  }) async {
    try {
      var query = _client.from('user_rewards').select().eq('user_id', userId);

      if (isClaimed != null) {
        query = query.eq('is_claimed', isClaimed);
      }

      final response = await query.order('earned_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      AppLogger.error('Failed to get user rewards: $e');
      return [];
    }
  }

  // User profile methods
  Future<Map<String, dynamic>?> getUserProfile(String userId) async {
    try {
      final response = await _client
          .from('user_profiles')
          .select()
          .eq('user_id', userId)
          .single();

      return response;
    } catch (e) {
      AppLogger.error('Failed to get user profile: $e');
      return null;
    }
  }

  Future<Map<String, dynamic>?> updateUserProfile({
    required String userId,
    String? nickname,
    String? profileImageUrl,
    int? birthYear,
    String? gender,
    String? language,
    String? timezone,
    Map<String, dynamic>? notificationSettings,
  }) async {
    try {
      final updateData = <String, dynamic>{
        'updated_at': DateTime.now().toIso8601String(),
      };

      if (nickname != null) updateData['nickname'] = nickname;
      if (profileImageUrl != null) {
        updateData['profile_image_url'] = profileImageUrl;
      }
      if (birthYear != null) updateData['birth_year'] = birthYear;
      if (gender != null) updateData['gender'] = gender;
      if (language != null) updateData['language'] = language;
      if (timezone != null) updateData['timezone'] = timezone;
      if (notificationSettings != null) {
        updateData['notification_settings'] = notificationSettings;
      }

      final response = await _client
          .from('user_profiles')
          .update(updateData)
          .eq('user_id', userId)
          .select()
          .single();

      return response;
    } catch (e) {
      AppLogger.error('Failed to update user profile: $e');
      return null;
    }
  }
}
