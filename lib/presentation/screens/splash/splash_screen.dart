import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/auth_provider.dart';
import '../../../core/logging/logger.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  ConsumerState<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends ConsumerState<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  bool _hasNavigated = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(authProvider);

    // 인증 상태 변화 감지 및 네비게이션
    ref.listen<AuthState>(authProvider, (previous, next) {
      if (!_hasNavigated && !next.isLoading) {
        _hasNavigated = true;
        _navigateBasedOnAuthState(next);
      }
    });

    return Scaffold(
      backgroundColor: const Color(0xFF1E3A8A),
      body: Center(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 앱 로고
              Container(
                width: 120,
                height: 120,
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.1),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                  ],
                ),
                child: const Icon(
                  Icons.directions_walk,
                  size: 60,
                  color: Color(0xFF1E3A8A),
                ),
              ),
              const SizedBox(height: 24),
              
              // 앱 이름
              const Text(
                'LuckyWalk',
                style: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),
              
              // 앱 설명
              const Text(
                '걸어서 받는 무료 복권',
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
              ),
              const SizedBox(height: 48),
              
              // 로딩 상태 표시
              _buildLoadingState(authState),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(AuthState authState) {
    if (authState.error != null) {
      return Column(
        children: [
          const Icon(
            Icons.error_outline,
            color: Colors.red,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            '오류가 발생했습니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            authState.error!,
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(authProvider);
              _hasNavigated = false;
            },
            child: const Text('다시 시도'),
          ),
        ],
      );
    }

    if (!authState.hasNetworkConnection) {
      return Column(
        children: [
          const Icon(
            Icons.wifi_off,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            '인터넷 연결을 확인해주세요',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(authProvider);
              _hasNavigated = false;
            },
            child: const Text('다시 시도'),
          ),
        ],
      );
    }

    if (!authState.isVersionSupported) {
      return Column(
        children: [
          const Icon(
            Icons.system_update,
            color: Colors.orange,
            size: 32,
          ),
          const SizedBox(height: 16),
          const Text(
            '앱 업데이트가 필요합니다',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '현재 버전: ${authState.appVersion ?? 'unknown'}',
            style: const TextStyle(
              color: Colors.white70,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              // TODO: 앱스토어로 이동
            },
            child: const Text('업데이트'),
          ),
        ],
      );
    }

    // 정상 로딩 상태
    return const CircularProgressIndicator(
      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
    );
  }

  void _navigateBasedOnAuthState(AuthState authState) {
    if (!mounted) return;

    AppLogger.info('Navigating based on auth state: $authState');

    if (authState.isAuthenticated) {
      if (authState.isOnboarded) {
        // 로그인됨 + 온보딩 완료 → 홈으로
        context.go('/home');
      } else {
        // 로그인됨 + 온보딩 미완료 → 온보딩으로
        context.go('/onboarding');
      }
    } else {
      // 로그인 안됨 → 로그인 화면으로
      context.go('/login');
    }
  }
}