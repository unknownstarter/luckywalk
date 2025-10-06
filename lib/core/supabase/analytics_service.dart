import 'package:supabase_flutter/supabase_flutter.dart';
import 'supabase_client.dart';

class AnalyticsService {
  static final SupabaseClient _supabase = SupabaseClient.instance;

  // User Activity Logging
  static Future<void> logStepCount({
    required String userId,
    required int stepCount,
    String source = 'health_kit',
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'step_count',
      activityValue: stepCount,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'source': source,
      },
    );
  }

  static Future<void> logAdView({
    required String userId,
    required String adId,
    required int duration,
    String adType = 'rewarded_video',
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'ad_view',
      activityValue: duration,
      activityData: {
        'ad_id': adId,
        'ad_type': adType,
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logAttendance({
    required String userId,
    int? streakCount,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'attendance',
      activityValue: 1,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'streak_count': streakCount,
      },
    );
  }

  static Future<void> logTicketPurchase({
    required String userId,
    required int ticketCount,
    String purchaseMethod = 'free',
    String? roundId,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'ticket_purchase',
      activityValue: ticketCount,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'purchase_method': purchaseMethod,
        'round_id': roundId,
      },
    );
  }

  static Future<void> logTicketWin({
    required String userId,
    required int prizeTier,
    required int prizeAmount,
    String? roundId,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'ticket_win',
      activityValue: prizeAmount,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'prize_tier': prizeTier,
        'round_id': roundId,
      },
    );
  }

  static Future<void> logLogin({
    required String userId,
    required String loginMethod,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'login',
      activityValue: 1,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'login_method': loginMethod,
      },
    );
  }

  static Future<void> logLogout({
    required String userId,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'logout',
      activityValue: 1,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
      },
    );
  }

  static Future<void> logAppOpen({
    required String userId,
    String? appVersion,
    String? osVersion,
    String? deviceType,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'app_open',
      activityValue: 1,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
      },
      appVersion: appVersion,
      osVersion: osVersion,
      deviceType: deviceType,
    );
  }

  static Future<void> logAppClose({
    required String userId,
    int? sessionDuration,
  }) async {
    await _supabase.logUserActivity(
      userId: userId,
      activityType: 'app_close',
      activityValue: sessionDuration ?? 0,
      activityData: {
        'timestamp': DateTime.now().toIso8601String(),
        'session_duration': sessionDuration,
      },
    );
  }

  // App Event Logging
  static Future<void> logScreenView({
    String? userId,
    required String screenName,
    required String screenPath,
    String? sessionId,
  }) async {
    await _supabase.logAppEvent(
      userId: userId,
      eventName: 'screen_view',
      eventCategory: 'navigation',
      eventData: {
        'screen_name': screenName,
        'screen_path': screenPath,
        'timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: sessionId,
      screenName: screenName,
      screenPath: screenPath,
    );
  }

  static Future<void> logButtonClick({
    String? userId,
    required String buttonName,
    required String screenName,
    String? sessionId,
  }) async {
    await _supabase.logAppEvent(
      userId: userId,
      eventName: 'button_click',
      eventCategory: 'interaction',
      eventData: {
        'button_name': buttonName,
        'screen_name': screenName,
        'timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: sessionId,
      screenName: screenName,
    );
  }

  static Future<void> logError({
    String? userId,
    required String errorMessage,
    String? errorStack,
    required String context,
    String? sessionId,
  }) async {
    await _supabase.logAppEvent(
      userId: userId,
      eventName: 'error',
      eventCategory: 'error',
      eventData: {
        'error_message': errorMessage,
        'error_stack': errorStack,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: sessionId,
    );
  }

  static Future<void> logPerformance({
    String? userId,
    required String eventName,
    required int duration,
    String? context,
    String? sessionId,
  }) async {
    await _supabase.logAppEvent(
      userId: userId,
      eventName: eventName,
      eventCategory: 'performance',
      eventData: {
        'duration': duration,
        'context': context,
        'timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: sessionId,
    );
  }

  static Future<void> logBusinessEvent({
    String? userId,
    required String eventName,
    required Map<String, dynamic> eventData,
    String? sessionId,
  }) async {
    await _supabase.logAppEvent(
      userId: userId,
      eventName: eventName,
      eventCategory: 'business',
      eventData: {
        ...eventData,
        'timestamp': DateTime.now().toIso8601String(),
      },
      sessionId: sessionId,
    );
  }

  // Batch logging for performance
  static Future<void> logBatchEvents({
    String? userId,
    required List<Map<String, dynamic>> events,
    String? sessionId,
  }) async {
    try {
      final batchData = events.map((event) => {
        'user_id': userId,
        'event_name': event['event_name'],
        'event_category': event['event_category'],
        'event_data': event['event_data'] ?? {},
        'session_id': sessionId,
        'screen_name': event['screen_name'],
        'screen_path': event['screen_path'],
        'timestamp': DateTime.now().toIso8601String(),
      }).toList();

      await _supabase.client.from('app_events').insert(batchData);
    } catch (e) {
      print('❌ Failed to log batch events: $e');
    }
  }

  // Analytics queries
  static Future<List<Map<String, dynamic>>> getUserActivityHistory({
    required String userId,
    String? activityType,
    DateTime? startDate,
    DateTime? endDate,
    int? limit,
  }) async {
    try {
      var query = _supabase.client
          .from('user_activities')
          .select()
          .eq('user_id', userId);

      if (activityType != null) {
        query = query.eq('activity_type', activityType);
      }

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      if (limit != null) {
        query = query.limit(limit);
      }

      final response = await query.order('created_at', ascending: false);
      return List<Map<String, dynamic>>.from(response);
    } catch (e) {
      print('❌ Failed to get user activity history: $e');
      return [];
    }
  }

  static Future<Map<String, dynamic>> getUserActivitySummary({
    required String userId,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      var query = _supabase.client
          .from('user_activities')
          .select('activity_type, activity_value, created_at')
          .eq('user_id', userId);

      if (startDate != null) {
        query = query.gte('created_at', startDate.toIso8601String());
      }

      if (endDate != null) {
        query = query.lte('created_at', endDate.toIso8601String());
      }

      final response = await query;
      final activities = List<Map<String, dynamic>>.from(response);

      // Calculate summary
      final summary = <String, dynamic>{
        'total_activities': activities.length,
        'step_count': 0,
        'ad_views': 0,
        'attendance_days': 0,
        'ticket_purchases': 0,
        'ticket_wins': 0,
      };

      for (final activity in activities) {
        final type = activity['activity_type'] as String;
        final value = activity['activity_value'] as int;

        switch (type) {
          case 'step_count':
            summary['step_count'] = (summary['step_count'] as int) + value;
            break;
          case 'ad_view':
            summary['ad_views'] = (summary['ad_views'] as int) + 1;
            break;
          case 'attendance':
            summary['attendance_days'] = (summary['attendance_days'] as int) + 1;
            break;
          case 'ticket_purchase':
            summary['ticket_purchases'] = (summary['ticket_purchases'] as int) + value;
            break;
          case 'ticket_win':
            summary['ticket_wins'] = (summary['ticket_wins'] as int) + 1;
            break;
        }
      }

      return summary;
    } catch (e) {
      print('❌ Failed to get user activity summary: $e');
      return {};
    }
  }
}
