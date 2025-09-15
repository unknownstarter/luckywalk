import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'dart:async';

import '../core/logging/logger.dart';

// Mock User 모델
class MockUser {
  final String id;
  final String email;
  final String name;
  final String? avatarUrl;
  final DateTime createdAt;
  final DateTime lastLoginAt;

  const MockUser({
    required this.id,
    required this.email,
    required this.name,
    this.avatarUrl,
    required this.createdAt,
    required this.lastLoginAt,
  });

  @override
  String toString() {
    return 'MockUser(id: $id, email: $email, name: $name)';
  }
}

// Mock Auth State
class MockAuthState {
  final bool isLoading;
  final bool isAuthenticated;
  final MockUser? user;
  final String? error;
  final bool isOnboarded;
  final bool hasNetworkConnection;
  final String? appVersion;
  final bool isVersionSupported;

  const MockAuthState({
    this.isLoading = true,
    this.isAuthenticated = false,
    this.user,
    this.error,
    this.isOnboarded = false,
    this.hasNetworkConnection = true,
    this.appVersion,
    this.isVersionSupported = true,
  });

  MockAuthState copyWith({
    bool? isLoading,
    bool? isAuthenticated,
    MockUser? user,
    String? error,
    bool? isOnboarded,
    bool? hasNetworkConnection,
    String? appVersion,
    bool? isVersionSupported,
  }) {
    return MockAuthState(
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
    return 'MockAuthState(isLoading: $isLoading, isAuthenticated: $isAuthenticated, user: $user, error: $error, isOnboarded: $isOnboarded, hasNetworkConnection: $hasNetworkConnection, appVersion: $appVersion, isVersionSupported: $isVersionSupported)';
  }
}

// Mock Auth Provider
final mockAuthProvider = StateNotifierProvider<MockAuthNotifier, MockAuthState>((ref) {
  return MockAuthNotifier();
});

class MockAuthNotifier extends StateNotifier<MockAuthState> {
  StreamSubscription<ConnectivityResult>? _connectivitySubscription;
  Timer? _sessionTimer;

  MockAuthNotifier() : super(const MockAuthState()) {
    _initialize();
  }

  Future<void> _initialize() async {
    try {
      AppLogger.info('Mock Auth: Initializing...');
      
      // 앱 버전 체크
      await _checkAppVersion();
      
      // 네트워크 상태 체크
      await _checkNetworkConnection();
      
      // 네트워크 상태 구독
      _connectivitySubscription = Connectivity().onConnectivityChanged.listen(
        (ConnectivityResult result) => _handleConnectivityChange(result),
      );

      // Mock 세션 복원 (SharedPreferences 시뮬레이션)
      await _restoreMockSession();

      AppLogger.info('Mock Auth: Initialization completed');
    } catch (error) {
      AppLogger.error('Mock Auth initialization failed: $error');
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
      
      // Mock: 항상 최신 버전으로 처리
      state = state.copyWith(
        appVersion: currentVersion,
        isVersionSupported: true,
      );
      
      AppLogger.info('Mock Auth: App version: $currentVersion');
    } catch (error) {
      AppLogger.error('Mock Auth: App version check failed: $error');
      state = state.copyWith(
        appVersion: '1.0.0',
        isVersionSupported: true, // Mock에서는 항상 지원
      );
    }
  }

  Future<void> _checkNetworkConnection() async {
    try {
      final connectivityResult = await Connectivity().checkConnectivity();
      final hasConnection = connectivityResult != ConnectivityResult.none;
      
      state = state.copyWith(hasNetworkConnection: hasConnection);
      AppLogger.info('Mock Auth: Network connection: $hasConnection');
    } catch (error) {
      AppLogger.error('Mock Auth: Network check failed: $error');
      state = state.copyWith(hasNetworkConnection: true); // Mock에서는 항상 연결됨
    }
  }

  void _handleConnectivityChange(ConnectivityResult result) {
    final hasConnection = result != ConnectivityResult.none;
    
    state = state.copyWith(hasNetworkConnection: hasConnection);
    AppLogger.info('Mock Auth: Network connectivity changed: $hasConnection');
  }

  Future<void> _restoreMockSession() async {
    // Mock: 스플래시 화면을 보여주기 위해 2초 대기
    await Future.delayed(const Duration(seconds: 2));
    
    // Mock: 50% 확률로 기존 세션 복원
    final hasExistingSession = DateTime.now().millisecond % 2 == 0;
    
    if (hasExistingSession) {
      final mockUser = MockUser(
        id: 'mock_user_123',
        email: 'user@example.com',
        name: '홍길동',
        avatarUrl: null,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        lastLoginAt: DateTime.now().subtract(const Duration(hours: 2)),
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: mockUser,
        isOnboarded: true, // Mock에서는 온보딩 완료로 처리
      );
      
      _startSessionTimer();
      AppLogger.info('Mock Auth: Existing session restored for ${mockUser.email}');
    } else {
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        isOnboarded: false,
      );
      AppLogger.info('Mock Auth: No existing session found');
    }
  }

  void _startSessionTimer() {
    // Mock: 30일 세션 타이머 (실제로는 30초로 단축)
    _sessionTimer?.cancel();
    _sessionTimer = Timer(const Duration(seconds: 30), () {
      AppLogger.info('Mock Auth: Session expired, signing out');
      signOut();
    });
  }

  // Mock Apple Sign In
  Future<void> signInWithApple() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Mock: 2초 지연 후 성공
      await Future.delayed(const Duration(seconds: 2));
      
      final mockUser = MockUser(
        id: 'mock_apple_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'apple.user@privaterelay.appleid.com',
        name: 'Apple User',
        avatarUrl: null,
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: mockUser,
        isOnboarded: false, // 최초 로그인은 온보딩 필요
      );
      
      _startSessionTimer();
      AppLogger.info('Mock Auth: Apple Sign In successful for ${mockUser.email}');
    } catch (error) {
      AppLogger.error('Mock Auth: Apple Sign In failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: 'Apple 로그인에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  // Mock Kakao Sign In
  Future<void> signInWithKakao() async {
    try {
      state = state.copyWith(isLoading: true, error: null);
      
      // Mock: 2초 지연 후 성공
      await Future.delayed(const Duration(seconds: 2));
      
      final mockUser = MockUser(
        id: 'mock_kakao_user_${DateTime.now().millisecondsSinceEpoch}',
        email: 'kakao.user@kakao.com',
        name: '카카오 사용자',
        avatarUrl: 'https://via.placeholder.com/100',
        createdAt: DateTime.now(),
        lastLoginAt: DateTime.now(),
      );
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: true,
        user: mockUser,
        isOnboarded: false, // 최초 로그인은 온보딩 필요
      );
      
      _startSessionTimer();
      AppLogger.info('Mock Auth: Kakao Sign In successful for ${mockUser.email}');
    } catch (error) {
      AppLogger.error('Mock Auth: Kakao Sign In failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: '카카오 로그인에 실패했습니다. 다시 시도해주세요.',
      );
    }
  }

  // Mock 로그아웃
  Future<void> signOut() async {
    try {
      state = state.copyWith(isLoading: true);
      
      // Mock: 1초 지연 후 로그아웃
      await Future.delayed(const Duration(seconds: 1));
      
      _sessionTimer?.cancel();
      
      state = state.copyWith(
        isLoading: false,
        isAuthenticated: false,
        user: null,
        isOnboarded: false,
        error: null,
      );
      
      AppLogger.info('Mock Auth: User signed out');
    } catch (error) {
      AppLogger.error('Mock Auth: Sign out failed: $error');
      state = state.copyWith(
        isLoading: false,
        error: error.toString(),
      );
    }
  }

  // Mock 온보딩 완료
  Future<void> completeOnboarding() async {
    try {
      state = state.copyWith(isOnboarded: true);
      AppLogger.info('Mock Auth: Onboarding completed for ${state.user?.email}');
    } catch (error) {
      AppLogger.error('Mock Auth: Complete onboarding failed: $error');
      state = state.copyWith(error: error.toString());
    }
  }

  // Mock 에러 클리어
  void clearError() {
    state = state.copyWith(error: null);
  }

  // Mock 네트워크 재연결
  Future<void> retryConnection() async {
    await _checkNetworkConnection();
  }

  @override
  void dispose() {
    _connectivitySubscription?.cancel();
    _sessionTimer?.cancel();
    super.dispose();
  }
}
