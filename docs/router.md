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
    
    // 출석체크
    GoRoute(
      path: '/attendance',
      name: 'attendance',
      builder: (context, state) => const AttendanceScreen(),
    ),
    
    // 초대
    GoRoute(
      path: '/referral',
      name: 'referral',
      builder: (context, state) => const ReferralScreen(),
    ),
    GoRoute(
      path: '/referral/join',
      name: 'referral-join',
      builder: (context, state) {
        final code = state.uri.queryParameters['code'];
        return ReferralJoinScreen(code: code);
      },
    ),
    
    // 이용방법
    GoRoute(
      path: '/how-it-works',
      name: 'how-it-works',
      builder: (context, state) => const HowItWorksScreen(),
    ),
    
    // 결과 상세
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
    
    // 404
    GoRoute(
      path: '/404',
      name: 'not-found',
      builder: (context, state) => const NotFoundScreen(),
    ),
  ],
  
  // 리다이렉트 로직
  redirect: (context, state) {
    // TODO: 인증 상태 확인 로직 구현
    // final authState = ref.read(authProvider);
    // if (authState.isLoading) return null;
    // if (!authState.isAuthenticated && state.location != '/login') {
    //   return '/login';
    // }
    return null;
  },
  
  // 에러 처리
  errorBuilder: (context, state) => const NotFoundScreen(),
);
```

## 2. 가드 (Guards)

### 2.1 AuthGuard
**목적**: 인증된 사용자만 접근 허용
**구현**:
```dart
class AuthGuard {
  static bool canAccess(BuildContext context) {
    final authState = context.read(authProvider);
    if (!authState.isAuthenticated) {
      context.go('/login');
      return false;
    }
    return true;
  }
}
```

### 2.2 KycEligibilityGuard
**목적**: 해당 회차 1·2등 당첨자만 KYC 접근 허용
**구현**:
```dart
class KycEligibilityGuard {
  static bool canAccess(BuildContext context, String roundId) {
    final userResult = context.read(userResultProvider(roundId));
    if (userResult == null || userResult.rank > 2) {
      context.go('/results');
      return false;
    }
    return true;
  }
}
```

## 3. 딥링크 지원

### 3.1 초대 링크
```
luckywalk://referral/join?code=XXXX
```

### 3.2 결과 공유 링크
```
luckywalk://results/1234
```

## 4. 라우트 트리(최종)

```
/ (Splash)
/login
/onboarding
/home
/how-it-works
/submit                // modal route - 응모 바텀시트
/my-tickets
/results
/results/:roundId
/results/:roundId/kyc  // KycEligibilityGuard
/settings
/referral
```

### 4.1 탭 구조 (Bottom Navigation)
1. **Home** (`/home`) - 메인 대시보드
2. **응모하기** (`/submit`) - 응모 바텀시트 모달
3. **내 응모** (`/my-tickets`) - 응모 내역
4. **응모 결과** (`/results`) - 당첨 결과
5. **설정** (`/settings`) - 앱 설정

## 5. 네비게이션 헬퍼

### 5.1 라우트 이동
```dart
class AppRouter {
  // 홈으로 이동
  static void goToHome(BuildContext context) {
    context.goNamed('home');
  }
  
  // 로그인으로 이동
  static void goToLogin(BuildContext context) {
    context.goNamed('login');
  }
  
  // 응모하기 모달 열기
  static void goToSubmit(BuildContext context) {
    context.goNamed('submit');
  }
  
  // 결과 상세로 이동
  static void goToResultDetail(BuildContext context, String roundId) {
    context.goNamed('result-detail', pathParameters: {'roundId': roundId});
  }
  
  // KYC 폼으로 이동
  static void goToKycForm(BuildContext context, String roundId) {
    context.goNamed('kyc-form', pathParameters: {'roundId': roundId});
  }
}
```

### 5.2 딥링크 처리
```dart
class DeepLinkHandler {
  static void handleReferralLink(String code) {
    // 초대 코드 처리 로직
  }
  
  static void handleResultLink(String roundId) {
    // 결과 공유 처리 로직
  }
}
```

## 6. 상태 관리 연동

### 6.1 인증 상태
- 로그인/로그아웃 상태에 따른 자동 리다이렉트
- 세션 만료 시 자동 로그아웃

### 6.2 온보딩 상태
- 최초 로그인 시 온보딩 화면 표시
- 온보딩 완료 후 홈으로 이동

### 6.3 권한 상태
- 푸시 알림 권한
- 건강/활동 권한
- 권한 거부 시 설정 화면 안내