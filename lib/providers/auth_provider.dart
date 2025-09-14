import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

import '../core/logging/logger.dart';

// Supabase 클라이언트
final supabaseClientProvider = Provider<SupabaseClient>((ref) {
  return Supabase.instance.client;
});

// 인증 상태 모델
class AuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final User? user;
  final String? error;
  final bool isOnboarded;
  final bool hasNetworkConnection;
  final String? appVersion;
  final bool isVersionSupported;

  const AuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isOnboarded = false,
    this.hasNetworkConnection = true,
    this.appVersion,
    this.isVersionSupported = true,
  });

  AuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    User? user,
    String? error,
    bool? isOnboarded,
    bool? hasNetworkConnection,
    String? appVersion,
    bool? isVersionSupported,
  }) {
    return AuthState(
      isLoading: isLoading ?? this.isLoading,
      isAuthenticated: isAuthenticated ?? this.isAuthenticated,
      user: user ?? this.user,
      error: error ?? this.error,
      isOnboarded: isOnboarded ?? this.isOnboarded,
      hasNetworkConnection: hasNetworkConnection ?? this.hasNetworkConnection,
      appVersion: appVersion ?? this.appVersion,
      isVersionSupported: isVersionSupported ?? this.isVersionSupported,
    );
  }

  @override
  String toString() {
    return 'AuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: $user, error: $error, isOnboarded: $isOnboarded, hasNetworkConnection: $hasNetworkConnection, appVersion: $appVersion, isVersionSupported: $isVersionSupported)';
  }
}

// 인증 상태 관리 Provider
final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final supabase = ref.watch(supabaseClientProvider);
  return AuthNotifier(supabase);
});

class AuthNotifier extends StateNotifier<AuthState> {
  final SupabaseClient _supabase;
  StreamSubscription<AuthState>? _authSubscription;
  StreamSubscription<List<ConnectivityResult>>? _connectivitySubscription;

  AuthNotifier(this._supabase) : super(const AuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      // 앱 버전 체크
      await _checkAppVersion();
      
      // 네트워크 상태 체크
      await _checkNetworkConnection();
      
      // 인증 상태 구독
      _authSubscription = _supabase.auth.onAuthStateChange.listen(
        (data) => _handleAuthStateChange(data),
        onError: (error) => _handleAuthError(error),
      );

      // 네트워크 상태 구독
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (List<ConnectivityResult> results) => _handleConnectivityChange(results),
      );

      // 초기 인증 상태 설정
      final session = _supabase.auth.currentSession;
      if (session != null) {
        await _handleAuthenticatedUser(session.user);
      } else {
        state = state.copyWith(
          isLoading: false,
          isAuthenticated: false,
          user: null,
        );
      }
    } catch (error) {
      AppLogger.error('Auth initialization failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  Future<void> _checkAppVersion() async {
    try {
      final packageInfo = await PackageInfo.fromPlatform();
      final currentVersion = packageInfo.version;
      
      // TODO: 서버에서 최소 지원 버전 체크
      // 현재는 항상 지원되는 것으로 처리
      state = state.copyWith(
        appVersion: currentVersion,
        isVersionSupported: true,
      );
      
      AppLogger.info('App version: $currentVersion');
    } catch (error) {
      AppLogger.error('App version check failed: $error');
      state = state.copyWith(
        appVersion: 'unknown',
        isVersionSupported: false,
      );
    }
  }

  Future<void> _checkNetworkConnection() async {
    try {
      final connectivityResults = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResults.any(
        (result) => result != ConnectivityResult.none,
      );
      
      state = state.copyWith(hasNetworkConnection: hasConnection);
      AppLogger.info('Network connection: $hasConnection');
    } catch (error) {
      AppLogger.error('Network check failed: $error');
      state = state.copyWith(hasNetworkConnection: false);
    }
  }

  void _handleAuthStateChange(AuthState authState) {
    AppLogger.info('Auth state changed: ${authState.event}');
    
    switch (authState.event) {
      case AuthChangeEvent.signedIn:
        _handleAuthenticatedUser(authState.session?.user);
        break;
      case AuthChangeEvent.signedOut:
        _handleSignedOut();
        break;
      case AuthChangeEvent.tokenRefreshed:
        _handleTokenRefreshed(authState.session?.user);
        break;
      case AuthChangeEvent.userUpdated:
        _handleUserUpdated(authState.session?.user);
        break;
      default:
        break;
    }
  }

  void _handleAuthError(dynamic error) {
    AppLogger.error('Auth error: $error');
    state = state.copyWith(
      isLoading: false,
      error: error.toString(),
    );
  }

  void _handleConnectivityChange(List<ConnectivityResult> results) {
    final hasConnection = results.any(
      (result) => result != ConnectivityResult.none,
    );
    
    state = state.copyWith(hasNetworkConnection: hasConnection);
    AppLogger.info('Network connectivity changed: $hasConnection');
  }

  Future<void> _handleAuthenticatedUser(User? user) async {
    if (user == null) return;

    try {
      // 세션 만료 체크 (30일)
      final session = _supabase.auth.currentSession;
      if (session != null) {
        final now = DateTime.now();
        final expiresAt = DateTime.fromMillisecondsSinceEpoch(
          session.expiresAt! * 1000,
        );
        final daysUntilExpiry = expiresAt.difference(now).inDays;
        
        if (daysUntilExpiry <= 0) {
          AppLogger.warning('Session expired, signing out');
          await signOut();
          return;
        }
        
        AppLogger.info('Session expires in $daysUntilExpiry days');
      }

      // 온보딩 상태 체크
      final isOnboarded = await _checkOnboardingStatus(user.id);

      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: user,
        isOnboarded: isOnboarded,
        error: null,
      );

      AppLogger.info('User authenticated: ${user.email}');
    } catch (error) {
      AppLogger.error('Handle authenticated user failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  void _handleSignedOut() {
    state = state.copyWith(
      isLoading: false,
      isAuthenticated: false,
      user: null,
      isOnboarded: false,
      error: null,
    );
    AppLogger.info('User signed out');
  }

  void _handleTokenRefreshed(User? user) {
    if (user != null) {
      state = state.copyWith(user: user);
      AppLogger.info('Token refreshed for user: ${user.email}');
    }
  }

  void _handleUserUpdated(User? user) {
    if (user != null) {
      state = state.copyWith(user: user);
      AppLogger.info('User updated: ${user.email}');
    }
  }

  Future<bool> _checkOnboardingStatus(String userId) async {
    try {
      // TODO: Supabase에서 사용자 온보딩 상태 확인
      // 현재는 항상 온보딩 완료로 처리
      return true;
    } catch (error) {
      AppLogger.error('Check onboarding status failed: $error');
      return false;
    }
  }

  // Apple Sign In
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // TODO: Apple Sign In 구현
      // final result = await SignInWithApple.getAppleIDCredential();
      // await _supabase.auth.signInWithIdToken(
      //   provider: OAuthProvider.apple,
      //   idToken: result.identityToken!,
      //   accessToken: result.authorizationCode,
      // );
      
      AppLogger.info('Apple Sign In initiated');
    } catch (error) {
      AppLogger.error('Apple Sign In failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  // Kakao Sign In
  Future<void> signInWithKakao() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // TODO: Kakao Sign In 구현
      // final result = await UserApi.instance.loginWithKakaoTalk();
      // await _supabase.auth.signInWithIdToken(
      //   provider: OAuthProvider.kakao,
      //   idToken: result.idToken,
      //   accessToken: result.accessToken,
      // );
      
      AppLogger.info('Kakao Sign In initiated');
    } catch (error) {
      AppLogger.error('Kakao Sign In failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  // 로그아웃
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      await _supabase.auth.signOut();
      AppLogger.info('User signed out');
    } catch (error) {
      AppLogger.error('Sign out failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  // 온보딩 완료 처리
  Future<void> completeOnboarding() async {
    try {
      state = state.copyWith(isOnboarded: true);
      AppLogger.info('Onboarding completed');
    } catch (error) {
      AppLogger.error('Complete onboarding failed: $error');
      state = state.copyWith(error: error.toString());
    }
  }

  // 에러 클리어
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
