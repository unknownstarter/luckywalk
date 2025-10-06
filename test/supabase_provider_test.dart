import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:luckywalk/providers/supabase_auth_provider.dart';
import 'package:luckywalk/core/logging/logger.dart';

void main() {
  group('SupabaseAuthProvider Tests', () {
    late ProviderContainer container;

    setUp(() {
      // Initialize AppLogger for tests
      AppLogger.init();
      container = ProviderContainer();
    });

    tearDown(() {
      container.dispose();
    });

    test('초기 상태는 로딩 중이어야 함', () {
      final authState = container.read(supabaseAuthProvider);
      
      expect(authState.isLoading, true);
      expect(authState.isAuthenticated, false);
      expect(authState.isOnboarded, false);
      expect(authState.hasNetworkConnection, true);
      expect(authState.isAppVersionSupported, true);
      expect(authState.error, null);
      expect(authState.user, null);
    });

    test('에러 상태 설정 테스트', () {
      final notifier = container.read(supabaseAuthProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        isLoading: false,
        error: '테스트 에러',
      );
      
      final authState = container.read(supabaseAuthProvider);
      expect(authState.isLoading, false);
      expect(authState.error, '테스트 에러');
    });

    test('인증 상태 설정 테스트', () {
      final notifier = container.read(supabaseAuthProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        isOnboarded: true,
      );
      
      final authState = container.read(supabaseAuthProvider);
      expect(authState.isLoading, false);
      expect(authState.isAuthenticated, true);
      expect(authState.isOnboarded, true);
    });

    test('네트워크 연결 상태 테스트', () {
      final notifier = container.read(supabaseAuthProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        hasNetworkConnection: false,
      );
      
      final authState = container.read(supabaseAuthProvider);
      expect(authState.hasNetworkConnection, false);
    });

    test('앱 버전 지원 상태 테스트', () {
      final notifier = container.read(supabaseAuthProvider.notifier);
      
      notifier.state = notifier.state.copyWith(
        isAppVersionSupported: false,
      );
      
      final authState = container.read(supabaseAuthProvider);
      expect(authState.isAppVersionSupported, false);
    });

    test('에러 클리어 테스트', () {
      final notifier = container.read(supabaseAuthProvider.notifier);
      
      // 에러 설정
      notifier.state = notifier.state.copyWith(
        error: '테스트 에러',
      );
      
      // 에러 클리어
      notifier.clearError();
      
      final authState = container.read(supabaseAuthProvider);
      expect(authState.error, null);
    });
  });
}
