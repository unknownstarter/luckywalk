import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/supabase_auth_provider.dart';
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
      duration: const Duration(seconds: 3), // 3초 애니메이션
      vsync: this,
    );
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    // 즉시 애니메이션 시작 (하얀색 화면 방지)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _animationController.forward();
    });

    // 강제로 3초 대기 후 네비게이션 (스플래시 화면 확실히 표시)
    Future.delayed(const Duration(seconds: 3), () {
      if (mounted && !_hasNavigated) {
        AppLogger.info('Splash screen navigation starting...');
        final authState = ref.read(supabaseAuthProvider);
        _hasNavigated = true;
        _navigateBasedOnAuthState(authState);
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0089FF), // 즉시 표시할 배경색
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8DCAFF), // 라이트 블루
              Color(0xFF0089FF), // 다크 블루
            ],
          ),
        ),
        child: Center(
          child: FadeTransition(
            opacity: _fadeAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 앱 이름 (고해상도 이미지 사용)
                Image.asset(
                  'assets/images/App Title.png',
                  width: 300,
                  height: 80,
                  fit: BoxFit.contain,
                  filterQuality: FilterQuality.high, // 고품질 필터링
                ),
                const SizedBox(height: 48),

                // 로딩 상태 표시
                _buildLoadingState(authState),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLoadingState(SupabaseAuthState authState) {
    // 네트워크 연결 체크
    if (!authState.hasNetworkConnection) {
      return Column(
        children: [
          const Icon(Icons.wifi_off, color: Colors.orange, size: 32),
          const SizedBox(height: 16),
          const Text(
            '인터넷 연결을 확인해주세요',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 16),
          ElevatedButton(
            onPressed: () {
              ref.invalidate(supabaseAuthProvider);
              _hasNavigated = false;
            },
            child: const Text('다시 시도'),
          ),
        ],
      );
    }

    // 앱 버전 체크
    if (!authState.isAppVersionSupported) {
      return Column(
        children: [
          const Icon(Icons.system_update, color: Colors.orange, size: 32),
          const SizedBox(height: 16),
          const Text(
            '앱 업데이트가 필요합니다',
            style: TextStyle(color: Colors.white, fontSize: 16),
          ),
          const SizedBox(height: 8),
          const Text(
            '현재 버전: 1.0.0',
            style: TextStyle(color: Colors.white70, fontSize: 12),
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

  void _navigateBasedOnAuthState(SupabaseAuthState authState) {
    if (!mounted) return;

    AppLogger.info('Navigating based on auth state: $authState');

    // 간단한 로직: 로그인 여부만 확인
    if (authState.isAuthenticated) {
      // 로그인됨 → 홈으로 (온보딩은 홈에서 처리)
      context.go('/home');
    } else {
      // 로그인 안됨 → 로그인 화면으로
      context.go('/login');
    }
  }
}
