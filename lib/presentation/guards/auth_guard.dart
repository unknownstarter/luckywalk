import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../providers/supabase_auth_provider.dart';
import '../../core/logging/logger.dart';

class AuthGuard {
  /// 인증된 사용자만 접근 허용
  static bool canAccess(BuildContext context, WidgetRef ref) {
    final authState = ref.read(supabaseAuthProvider);

    if (authState.isLoading) {
      AppLogger.info('Auth guard: Still loading, allowing access');
      return true;
    }

    if (!authState.isAuthenticated) {
      AppLogger.info(
        'Auth guard: User not authenticated, redirecting to login',
      );
      context.go('/login');
      return false;
    }

    AppLogger.info('Auth guard: User authenticated, allowing access');
    return true;
  }

  /// 온보딩 완료된 사용자만 접근 허용
  static bool canAccessWithOnboarding(BuildContext context, WidgetRef ref) {
    final authState = ref.read(supabaseAuthProvider);

    if (authState.isLoading) {
      AppLogger.info('Auth guard: Still loading, allowing access');
      return true;
    }

    if (!authState.isAuthenticated) {
      AppLogger.info(
        'Auth guard: User not authenticated, redirecting to login',
      );
      context.go('/login');
      return false;
    }

    if (!authState.isOnboarded) {
      AppLogger.info(
        'Auth guard: User not onboarded, redirecting to onboarding',
      );
      context.go('/onboarding');
      return false;
    }

    AppLogger.info(
      'Auth guard: User authenticated and onboarded, allowing access',
    );
    return true;
  }

  /// 로그인되지 않은 사용자만 접근 허용 (로그인 화면용)
  static bool canAccessUnauthenticated(BuildContext context, WidgetRef ref) {
    final authState = ref.read(supabaseAuthProvider);

    if (authState.isLoading) {
      AppLogger.info('Auth guard: Still loading, allowing access');
      return true;
    }

    if (authState.isAuthenticated) {
      if (authState.isOnboarded) {
        AppLogger.info(
          'Auth guard: User authenticated and onboarded, redirecting to home',
        );
        context.go('/home');
      } else {
        AppLogger.info(
          'Auth guard: User authenticated but not onboarded, redirecting to onboarding',
        );
        context.go('/onboarding');
      }
      return false;
    }

    AppLogger.info(
      'Auth guard: User not authenticated, allowing access to login',
    );
    return true;
  }

  /// 온보딩 완료되지 않은 사용자만 접근 허용 (온보딩 화면용)
  static bool canAccessOnboarding(BuildContext context, WidgetRef ref) {
    final authState = ref.read(supabaseAuthProvider);

    if (authState.isLoading) {
      AppLogger.info('Auth guard: Still loading, allowing access');
      return true;
    }

    if (!authState.isAuthenticated) {
      AppLogger.info(
        'Auth guard: User not authenticated, redirecting to login',
      );
      context.go('/login');
      return false;
    }

    if (authState.isOnboarded) {
      AppLogger.info('Auth guard: User already onboarded, redirecting to home');
      context.go('/home');
      return false;
    }

    AppLogger.info(
      'Auth guard: User authenticated but not onboarded, allowing access to onboarding',
    );
    return true;
  }
}

/// AuthGuard를 사용하는 위젯
class AuthGuardWidget extends ConsumerWidget {
  final Widget child;
  final bool requireOnboarding;
  final bool requireUnauthenticated;
  final bool requireOnboardingOnly;

  const AuthGuardWidget({
    super.key,
    required this.child,
    this.requireOnboarding = false,
    this.requireUnauthenticated = false,
    this.requireOnboardingOnly = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    bool canAccess = false;

    if (requireUnauthenticated) {
      canAccess = AuthGuard.canAccessUnauthenticated(context, ref);
    } else if (requireOnboardingOnly) {
      canAccess = AuthGuard.canAccessOnboarding(context, ref);
    } else if (requireOnboarding) {
      canAccess = AuthGuard.canAccessWithOnboarding(context, ref);
    } else {
      canAccess = AuthGuard.canAccess(context, ref);
    }

    if (!canAccess) {
      // 리다이렉트 중일 때는 로딩 표시
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return child;
  }
}
