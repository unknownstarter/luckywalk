# LuckyWalk 라우팅 트리 (GoRouter)

## 1. 라우트 구조 개요

### 1.1 전체 라우트 트리
```dart
GoRouter(
  initialLocation: '/',
  routes: [
    // 스플래시
    GoRoute(
      path: '/',
      name: 'splash',
      builder: (context, state) => const SplashScreen(),
    ),
    
    // 인증
    GoRoute(
      path: '/login',
      name: 'login',
      builder: (context, state) => const LoginScreen(),
    ),
    
    // 온보딩
    GoRoute(
      path: '/onboarding',
      name: 'onboarding',
      builder: (context, state) => const OnboardingScreen(),
    ),
    
    // 메인 앱 (Shell Route)
    ShellRoute(
      builder: (context, state, child) => MainShell(child: child),
      routes: [
        // 홈
        GoRoute(
          path: '/home',
          name: 'home',
          builder: (context, state) => const HomeScreen(),
        ),
        
        // 응모하기 (모달 라우트)
        GoRoute(
          path: '/submit',
          name: 'submit',
          builder: (context, state) => const SubmitModalScreen(),
        ),
        
        // 내 응모
        GoRoute(
          path: '/my-tickets',
          name: 'my-tickets',
          builder: (context, state) => const MyTicketsScreen(),
        ),
        
        // 응모 결과
        GoRoute(
          path: '/results',
          name: 'results',
          builder: (context, state) => const ResultsScreen(),
        ),
        
        // 설정
        GoRoute(
          path: '/settings',
          name: 'settings',
          builder: (context, state) => const SettingsScreen(),
        ),
      ],
    ),
    
    // 보상 관련
    GoRoute(
      path: '/rewards/ads',
      name: 'rewards-ads',
      builder: (context, state) => const AdsRewardScreen(),
    ),
    GoRoute(
      path: '/rewards/steps',
      name: 'rewards-steps',
      builder: (context, state) => const StepsRewardScreen(),
    ),
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    GoRoute(
      path: '/referral',
      name: 'referral',
      builder: (context, state) => const ReferralScreen(),
    ),
    
    // 이용방법
    GoRoute(
      path: '/how-it-works',
      name: 'how-it-works',
      builder: (context, state) => const HowItWorksScreen(),
    ),
    
    // 응모 결과 상세
    GoRoute(
      path: '/results/:roundId',
      name: 'result-detail',
      builder: (context, state) {
        final roundId = state.pathParameters['roundId']!;
        return ResultDetailScreen(roundId: roundId);
      },
    ),
    
    // KYC 제출
    GoRoute(
      path: '/results/:roundId/kyc',
      name: 'kyc-form',
      builder: (context, state) {
        final roundId = state.pathParameters['roundId']!;
        return KycFormScreen(roundId: roundId);
      },
    ),
    
    // 어드민
    GoRoute(
      path: '/admin',
      name: 'admin',
      builder: (context, state) => const AdminScreen(),
      routes: [
        GoRoute(
          path: 'rounds',
          name: 'admin-rounds',
          builder: (context, state) => const AdminRoundsScreen(),
        ),
        GoRoute(
          path: 'rounds/:roundId',
          name: 'admin-round-detail',
          builder: (context, state) {
            final roundId = state.pathParameters['roundId']!;
            return AdminRoundDetailScreen(roundId: roundId);
          },
        ),
      ],
    ),
  ],
  
  // 리다이렉트 로직
  redirect: (context, state) {
    final authState = ref.read(authProvider);
    final isOnboardingComplete = ref.read(onboardingProvider).isComplete;
    
    // 인증되지 않은 사용자
    if (!authState.isAuthenticated) {
      if (state.subloc == '/login') return null;
      return '/login';
    }
    
    // 온보딩 미완료
    if (!isOnboardingComplete) {
      if (state.subloc == '/onboarding') return null;
      return '/onboarding';
    }
    
    // 스플래시에서 홈으로 리다이렉트
    if (state.subloc == '/') {
      return '/home';
    }
    
    return null;
  },
  
  // 에러 처리
  errorBuilder: (context, state) => const NotFoundScreen(),
)
```

## 2. 라우트 가드 (Guards)

### 2.1 AuthGuard
```dart
class AuthGuard {
  static String? check(BuildContext context, GoRouterState state) {
    final authState = ref.read(authProvider);
    
    if (!authState.isAuthenticated) {
      return '/login';
    }
    
    // 세션 만료 확인 (30일)
    if (authState.isSessionExpired) {
      return '/login';
    }
    
    return null;
  }
}
```

### 2.2 KycEligibilityGuard
```dart
class KycEligibilityGuard {
  static String? check(BuildContext context, GoRouterState state) {
    final roundId = state.pathParameters['roundId'];
    if (roundId == null) return '/results';
    
    final result = ref.read(resultProvider(roundId));
    
    // 1등 또는 2등 당첨자만 접근 가능
    if (result?.tier != 1 && result?.tier != 2) {
      return '/results/$roundId';
    }
    
    return null;
  }
}
```

### 2.3 AdminGuard
```dart
class AdminGuard {
  static String? check(BuildContext context, GoRouterState state) {
    final userRole = ref.read(userRoleProvider);
    
    if (userRole != UserRole.admin) {
      return '/home';
    }
    
    return null;
  }
}
```

## 3. 딥링크 처리

### 3.1 초대 링크
```dart
// luckywalk://ref/join?code=XXXX
GoRoute(
  path: '/ref/join',
  name: 'referral-join',
  builder: (context, state) {
    final code = state.uri.queryParameters['code'];
    return ReferralJoinScreen(code: code);
  },
)
```

### 3.2 결과 공유 링크
```dart
// luckywalk://results/:roundId
GoRoute(
  path: '/results/:roundId',
  name: 'result-detail',
  builder: (context, state) {
    final roundId = state.pathParameters['roundId']!;
    return ResultDetailScreen(roundId: roundId);
  },
)
```

## 4. 라우터 설정 코드

### 4.1 router.dart
```dart
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../features/auth/providers/auth_provider.dart';
import '../features/onboarding/providers/onboarding_provider.dart';
import '../features/results/providers/result_provider.dart';
import '../features/admin/providers/user_role_provider.dart';

import '../presentation/screens/splash/splash_screen.dart';
import '../presentation/screens/auth/login_screen.dart';
import '../presentation/screens/onboarding/onboarding_screen.dart';
import '../presentation/screens/home/home_screen.dart';
import '../presentation/screens/my_tickets/my_tickets_screen.dart';
import '../presentation/screens/results/results_screen.dart';
import '../presentation/screens/results/result_detail_screen.dart';
import '../presentation/screens/results/kyc_form_screen.dart';
import '../presentation/screens/settings/settings_screen.dart';
import '../presentation/screens/rewards/ads_reward_screen.dart';
import '../presentation/screens/rewards/steps_reward_screen.dart';
import '../presentation/screens/attendance/attendance_screen.dart';
import '../presentation/screens/referral/referral_screen.dart';
import '../presentation/screens/referral/referral_join_screen.dart';
import '../presentation/screens/how_it_works/how_it_works_screen.dart';
import '../presentation/screens/admin/admin_screen.dart';
import '../presentation/screens/admin/admin_rounds_screen.dart';
import '../presentation/screens/admin/admin_round_detail_screen.dart';
import '../presentation/screens/not_found/not_found_screen.dart';
import '../presentation/widgets/main_shell.dart';

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    debugLogDiagnostics: true,
    routes: [
      // 스플래시
      GoRoute(
        path: '/',
        name: 'splash',
        builder: (context, state) => const SplashScreen(),
      ),
      
      // 인증
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      
      // 온보딩
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      
      // 메인 앱 (Shell Route)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 홈
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => const HomeScreen(),
          ),
          
          // 내 응모
          GoRoute(
            path: '/my-tickets',
            name: 'my-tickets',
            builder: (context, state) => const MyTicketsScreen(),
          ),
          
          // 응모 결과
          GoRoute(
            path: '/results',
            name: 'results',
            builder: (context, state) => const ResultsScreen(),
          ),
          
          // 설정
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsScreen(),
          ),
        ],
      ),
      
      // 보상 관련
      GoRoute(
        path: '/rewards/ads',
        name: 'rewards-ads',
        builder: (context, state) => const AdsRewardScreen(),
      ),
      GoRoute(
        path: '/rewards/steps',
        name: 'rewards-steps',
        builder: (context, state) => const StepsRewardScreen(),
      ),
      GoRoute(
        path: '/attendance',
        name: 'attendance',
        builder: (context, state) => const AttendanceScreen(),
      ),
      GoRoute(
        path: '/referral',
        name: 'referral',
        builder: (context, state) => const ReferralScreen(),
      ),
      
      // 이용방법
      GoRoute(
        path: '/how-it-works',
        name: 'how-it-works',
        builder: (context, state) => const HowItWorksScreen(),
      ),
      
      // 응모 결과 상세
      GoRoute(
        path: '/results/:roundId',
        name: 'result-detail',
        builder: (context, state) {
          final roundId = state.pathParameters['roundId']!;
          return ResultDetailScreen(roundId: roundId);
        },
      ),
      
      // KYC 제출
      GoRoute(
        path: '/results/:roundId/kyc',
        name: 'kyc-form',
        builder: (context, state) {
          final roundId = state.pathParameters['roundId']!;
          return KycFormScreen(roundId: roundId);
        },
      ),
      
      // 초대 링크
      GoRoute(
        path: '/ref/join',
        name: 'referral-join',
        builder: (context, state) {
          final code = state.uri.queryParameters['code'];
          return ReferralJoinScreen(code: code);
        },
      ),
      
      // 어드민
      GoRoute(
        path: '/admin',
        name: 'admin',
        builder: (context, state) => const AdminScreen(),
        routes: [
          GoRoute(
            path: 'rounds',
            name: 'admin-rounds',
            builder: (context, state) => const AdminRoundsScreen(),
          ),
          GoRoute(
            path: 'rounds/:roundId',
            name: 'admin-round-detail',
            builder: (context, state) {
              final roundId = state.pathParameters['roundId']!;
              return AdminRoundDetailScreen(roundId: roundId);
            },
          ),
        ],
      ),
    ],
    
    // 리다이렉트 로직
    redirect: (context, state) {
      final authState = ref.read(authProvider);
      final isOnboardingComplete = ref.read(onboardingProvider).isComplete;
      
      // 인증되지 않은 사용자
      if (!authState.isAuthenticated) {
        if (state.subloc == '/login') return null;
        return '/login';
      }
      
      // 온보딩 미완료
      if (!isOnboardingComplete) {
        if (state.subloc == '/onboarding') return null;
        return '/onboarding';
      }
      
      // 스플래시에서 홈으로 리다이렉트
      if (state.subloc == '/') {
        return '/home';
      }
      
      return null;
    },
    
    // 에러 처리
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
```

## 5. 네비게이션 헬퍼

### 5.1 NavigationHelper
```dart
class NavigationHelper {
  static void goToHome(BuildContext context) {
    context.goNamed('home');
  }
  
  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }
  
  static void goToOnboarding(BuildContext context) {
    context.goNamed('onboarding');
  }
  
  static void goToMyTickets(BuildContext context) {
    context.goNamed('my-tickets');
  }
  
  static void goToResults(BuildContext context) {
    context.goNamed('results');
  }
  
  static void goToResultDetail(BuildContext context, String roundId) {
    context.goNamed('result-detail', pathParameters: {'roundId': roundId});
  }
  
  static void goToKycForm(BuildContext context, String roundId) {
    context.goNamed('kyc-form', pathParameters: {'roundId': roundId});
  }
  
  static void goToSettings(BuildContext context) {
    context.goNamed('settings');
  }
  
  static void goToAdsReward(BuildContext context) {
    context.goNamed('rewards-ads');
  }
  
  static void goToStepsReward(BuildContext context) {
    context.goNamed('rewards-steps');
  }
  
  static void goToAttendance(BuildContext context) {
    context.goNamed('attendance');
  }
  
  static void goToReferral(BuildContext context) {
    context.goNamed('referral');
  }
  
  static void goToHowItWorks(BuildContext context) {
    context.goNamed('how-it-works');
  }
  
  static void goToAdmin(BuildContext context) {
    context.goNamed('admin');
  }
  
  static void goToAdminRounds(BuildContext context) {
    context.goNamed('admin-rounds');
  }
  
  static void goToAdminRoundDetail(BuildContext context, String roundId) {
    context.goNamed('admin-round-detail', pathParameters: {'roundId': roundId});
  }
  
  static void goToReferralJoin(BuildContext context, String code) {
    context.goNamed('referral-join', queryParameters: {'code': code});
  }
  
  static void pop(BuildContext context) {
    context.pop();
  }
  
  static void popUntil(BuildContext context, String routeName) {
    context.popUntil(routeName);
  }
}
```

## 6. 라우트 테스트

### 6.1 라우트 테스트 코드
```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';

void main() {
  group('Router Tests', () {
    testWidgets('should navigate to login when not authenticated', (tester) async {
      // 테스트 코드
    });
    
    testWidgets('should navigate to home when authenticated', (tester) async {
      // 테스트 코드
    });
    
    testWidgets('should redirect to onboarding when not completed', (tester) async {
      // 테스트 코드
    });
    
    testWidgets('should handle deep links correctly', (tester) async {
      // 테스트 코드
    });
  });
}
```

## 7. 라우트 보안

### 7.1 보안 정책
- **인증 필수**: 모든 보호된 라우트는 인증 확인
- **권한 확인**: 어드민 라우트는 관리자 권한 확인
- **KYC 접근 제어**: 1,2등 당첨자만 KYC 제출 가능
- **세션 관리**: 30일 세션 만료 시 자동 로그아웃

### 7.2 감사 로그
- **라우트 접근**: 모든 라우트 접근 로깅
- **권한 위반**: 권한 없는 접근 시도 로깅
- **에러 발생**: 라우트 에러 발생 시 로깅
