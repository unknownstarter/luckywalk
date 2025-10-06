import 'package:permission_handler/permission_handler.dart';
import '../logging/logger.dart';

class PermissionManager {
  static final PermissionManager _instance = PermissionManager._internal();
  factory PermissionManager() => _instance;
  PermissionManager._internal();

  /// Notification 권한 요청
  static Future<bool> requestNotificationPermission() async {
    try {
      AppLogger.info('Requesting notification permission');
      
      final status = await Permission.notification.request();
      
      if (status.isGranted) {
        AppLogger.info('Notification permission granted');
        return true;
      } else {
        AppLogger.warning('Notification permission denied');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to request notification permission: $e');
      return false;
    }
  }

  /// 걸음수(Activity) 권한 요청
  static Future<bool> requestActivityPermission() async {
    try {
      AppLogger.info('Requesting activity permission');
      
      final status = await Permission.activityRecognition.request();
      
      if (status.isGranted) {
        AppLogger.info('Activity permission granted');
        return true;
      } else {
        AppLogger.warning('Activity permission denied');
        return false;
      }
    } catch (e) {
      AppLogger.error('Failed to request activity permission: $e');
      return false;
    }
  }

  /// 모든 권한 요청
  static Future<Map<String, bool>> requestAllPermissions() async {
    AppLogger.info('Requesting all permissions');
    
    final results = await Future.wait([
      requestNotificationPermission(),
      requestActivityPermission(),
    ]);
    
    return {
      'notification': results[0],
      'activity': results[1],
    };
  }

  /// 권한 상태 확인
  static Future<Map<String, bool>> checkPermissions() async {
    try {
      final notificationStatus = await Permission.notification.status;
      final activityStatus = await Permission.activityRecognition.status;
      
      return {
        'notification': notificationStatus.isGranted,
        'activity': activityStatus.isGranted,
      };
    } catch (e) {
      AppLogger.error('Failed to check permissions: $e');
      return {
        'notification': false,
        'activity': false,
      };
    }
  }

  /// 권한 설정 페이지로 이동
  static Future<void> openAppSettings() async {
    try {
      await openAppSettings();
      AppLogger.info('Opened app settings');
    } catch (e) {
      AppLogger.error('Failed to open app settings: $e');
    }
  }
}
