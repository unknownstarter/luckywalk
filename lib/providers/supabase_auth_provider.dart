import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'dart:async';

import '../../core/logging/logger.dart';
import '../../core/env/env_loader.dart';

/// Supabase 인증 상태
class SupabaseAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final bool isOnboarded;
  final bool hasNetworkConnection;
  final bool isAppVersionSupported;
  final String? error;
  final User? user;

  const SupabaseAuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.isOnboarded = false,
    this.hasNetworkConnection = true,
    this.isAppVersionSupported = true,
    this.error,
    this.user,
  });

  SupabaseAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    bool? isOnboarded,
    bool? hasNetworkConnection,
    bool? isAppVersionSupported,
    String? error,
    User? user,
  }) {
    return SupabaseAuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      hasNetworkConnection: hasNetworkConnection ?? this.hasNetworkConnection,
      isAppVersionSupported: isAppVersionSupported ?? this.isAppVersionSupported,
      error: error ?? this.error,
      user: user ?? this.user,
    );
  }
}

/// Supabase 인증 Provider
class SupabaseAuthNotifier extends StateNotifier<SupabaseAuthState> {
  SupabaseAuthNotifier() : super(const SupabaseAuthState()) {
    _initialize();
  }

  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;

  void _initialize() async {
    try {
      // 네트워크 연결 상태 확인
      await _checkNetworkConnection();
      
      // 앱 버전 확인
      await _checkAppVersion();
      
      // Supabase 인증 상태 리스너 설정
      _authSubscription = Supabase.instance.client.auth.onAuthStateChange.listen(
        _handleAuthStateChange,
        onError: (error) {
          AppLogger.error('Auth state change error', error);
          state = state.copyWith(
            isLoading: false,
            error: '인증 상태 확인 중 오류가 발생했습니다.',
          );
        },
      );

      // 네트워크 연결 상태 리스너 설정
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        _handleConnectivityChange,
        onError: (error) {
          AppLogger.error('Connectivity change error', error);
        },
      );

      // 초기 세션 복원
      await _restoreSession();
      
    } catch (e, stackTrace) {
      AppLogger.error('Auth initialization error', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: '인증 초기화 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> _checkNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      
      state = state.copyWith(hasNetworkConnection: hasConnection);
      
      if (!hasConnection) {
        AppLogger.warning('No network connection');
      }
    } catch (e) {
      AppLogger.error('Network check error', e);
      state = state.copyWith(hasNetworkConnection: false);
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      final isSupported = _isVersionSupported(currentVersion, EnvLoader.minSupportedAppVersion);
      
      state = state.copyWith(isAppVersionSupported: isSupported);
      
      if (!isSupported) {
        AppLogger.warning('Unsupported app version: $currentVersion');
      }
    } catch (e) {
      AppLogger.error('App version check error', e);
      state = state.copyWith(isAppVersionSupported: false);
    }
  }

  bool _isVersionSupported(String currentVersion, String minVersion) {
    // 간단한 버전 비교 (실제로는 더 정교한 비교 필요)
    return currentVersion.compareTo(minVersion) >= 0;
  }

  void _handleAuthStateChange(AuthState authState) {
    final user = authState.session?.user;
    final isAuthenticated = user != null;
    
    AppLogger.info('Auth state changed - isAuthenticated: $isAuthenticated, userId: ${user?.id}');

    state = state.copyWith(
      isLoading: false,
      isAuthenticated: isAuthenticated,
      user: user,
      error: null,
    );

    // 온보딩 상태 확인 (인증된 경우)
    if (isAuthenticated) {
      _checkOnboardingStatus(user!);
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    
    AppLogger.info('Connectivity changed - hasConnection: $hasConnection, result: ${result.toString()}');

    state = state.copyWith(hasNetworkConnection: hasConnection);
  }

  Future<void> _restoreSession() async {
    try {
      AppLogger.info('Restoring Supabase session');
      
      // Supabase 세션 복원
      final session = Supabase.instance.client.auth.currentSession;
      
      if (session != null) {
        AppLogger.info('Session restored - userId: ${session.user.id}, expiresAt: ${session.expiresAt}');
        
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: true,
          user: session.user,
        );
        
        // 온보딩 상태 확인
        await _checkOnboardingStatus(session.user);
      } else {
        AppLogger.info('No existing session found');
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
        );
      }
    } catch (e, stackTrace) {
      AppLogger.error('Session restoration error', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: '세션 복원 중 오류가 발생했습니다.',
      );
    }
  }

  Future<void> _checkOnboardingStatus(User user) async {
    try {
      // 사용자 프로필에서 온보딩 상태 확인
      final response = await Supabase.instance.client
          .from('user_profiles')
          .select('nickname')
          .eq('uid', user.id)
          .single();

      final isOnboarded = response['nickname'] != null && response['nickname'].isNotEmpty;
      
      AppLogger.info('Onboarding status checked - userId: ${user.id}, isOnboarded: $isOnboarded');

      state = state.copyWith(isOnboarded: isOnboarded);
    } catch (e) {
      AppLogger.error('Onboarding status check error', e);
      // 온보딩 상태 확인 실패 시 기본값으로 설정
      state = state.copyWith(isOnboarded: false);
    }
  }

  /// Apple 로그인
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      AppLogger.info('Starting Apple sign in');
      
      final response = await Supabase.instance.client.auth.signInWithIdToken(
        provider: OAuthProvider.apple,
        idToken: '', // 실제 Apple ID 토큰
        nonce: '', // 실제 nonce
      );

      if (response.user != null) {
        AppLogger.info('Apple sign in successful - userId: ${response.user!.id}');
      }
    } catch (e, stackTrace) {
      AppLogger.error('Apple sign in error', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Apple 로그인 중 오류가 발생했습니다.',
      );
    }
  }

  /// Kakao 로그인
  Future<void> signInWithKakao() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      AppLogger.info('Starting Kakao sign in');
      
      // Kakao 로그인 구현 (실제로는 Kakao SDK 사용)
      // 임시로 Mock 로그인 처리
      await Future.delayed(const Duration(seconds: 2));
      
      AppLogger.info('Kakao sign in successful');
    } catch (e, stackTrace) {
      AppLogger.error('Kakao sign in error', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: 'Kakao 로그인 중 오류가 발생했습니다.',
      );
    }
  }

  /// 로그아웃
  Future<void> signOut() async {
    try {
      AppLogger.info('Starting sign out');
      
      await Supabase.instance.client.auth.signOut();
      
      state = state.copyWith(
        isAuthenticated: false,
        isOnboarded: false,
        user: null,
        error: null,
      );
      
      AppLogger.info('Sign out successful');
    } catch (e, stackTrace) {
      AppLogger.error('Sign out error', e, stackTrace);
      state = state.copyWith(
        error: '로그아웃 중 오류가 발생했습니다.',
      );
    }
  }

  /// 온보딩 완료
  Future<void> completeOnboarding(String nickname) async {
    try {
      final user = state.user;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      AppLogger.info('Completing onboarding - userId: ${user.id}, nickname: $nickname');

      // 사용자 프로필 업데이트
      await Supabase.instance.client
          .from('user_profiles')
          .update({'nickname': nickname})
          .eq('uid', user.id);

      state = state.copyWith(isOnboarded: true);
      
      AppLogger.info('Onboarding completed successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Onboarding completion error', e, stackTrace);
      state = state.copyWith(
        error: '온보딩 완료 중 오류가 발생했습니다.',
      );
    }
  }

  /// 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  @override
  void dispose() {
    _authSubscription?.cancel();
    _connectivitySubscription?.cancel();
    super.dispose();
  }
}

/// Supabase 인증 Provider
final supabaseAuthProvider = StateNotifierProvider<SupabaseAuthNotifier, SupabaseAuthState>((ref) {
  return SupabaseAuthNotifier();
});
