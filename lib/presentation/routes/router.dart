import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../guards/auth_guard.dart';
import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/onboarding/onboarding_screen.dart';
import '../screens/home/home_screen.dart';
import '../screens/submit/submit_modal_screen.dart';
import '../screens/submit/submit_loading_screen.dart';
import '../screens/submit/submit_confirm_screen.dart';
import '../screens/submit/submit_edit_screen.dart';
import '../screens/submit/submit_complete_screen.dart';
import '../screens/my_tickets/my_tickets_screen.dart';
import '../screens/results/results_screen.dart';
import '../screens/rewards/ads_reward_screen.dart';
import '../screens/rewards/steps_reward_screen.dart';
import '../screens/attendance/attendance_screen.dart';
import '../screens/referral/referral_screen.dart';
import '../screens/referral/referral_join_screen.dart';
import '../screens/how_it_works/how_it_works_screen.dart';
import '../screens/results/result_detail_screen.dart';
import '../screens/results/kyc_form_screen.dart';
import '../screens/not_found/not_found_screen.dart';
import '../widgets/main_shell.dart';
import '../../providers/supabase_auth_provider.dart';
import '../screens/test/supabase_api_test_screen.dart';
import '../screens/my_entries/my_entries_screen.dart';
import '../screens/hall_of_fame/hall_of_fame_screen.dart';
import '../screens/settings/settings_screen.dart';

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
        builder: (context, state) => AuthGuardWidget(
          requireUnauthenticated: true,
          child: const LoginScreen(),
        ),
      ),

      // 온보딩
      GoRoute(
        path: '/onboarding',
        name: 'onboarding',
        builder: (context, state) => AuthGuardWidget(
          requireOnboardingOnly: true,
          child: const OnboardingScreen(),
        ),
      ),

      // 메인 앱 (Shell Route)
      ShellRoute(
        builder: (context, state, child) => MainShell(child: child),
        routes: [
          // 홈
          GoRoute(
            path: '/home',
            name: 'home',
            builder: (context, state) => AuthGuardWidget(
              requireOnboarding: true,
              child: const HomeScreen(),
            ),
          ),

          // 응모하기 (모달 라우트)
          GoRoute(
            path: '/submit',
            name: 'submit',
            builder: (context, state) => AuthGuardWidget(
              requireOnboarding: true,
              child: const SubmitModalScreen(),
            ),
          ),

          // 응모하기 플로우
          GoRoute(
            path: '/submit/loading',
            name: 'submit-loading',
            builder: (context, state) {
              final ticketCount = state.extra as int? ?? 100;
              return SubmitLoadingScreen(ticketCount: ticketCount);
            },
          ),
          GoRoute(
            path: '/submit/confirm',
            name: 'submit-confirm',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final ticketCount = extra['ticketCount'] as int? ?? 100;
              return SubmitConfirmScreen(ticketCount: ticketCount);
            },
          ),
          GoRoute(
            path: '/submit/edit',
            name: 'submit-edit',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final ticketIndex = extra['ticketIndex'] as int? ?? 0;
              final ticketNumbers = extra['ticketNumbers'] as List<int>? ?? [];
              final ticketCount = extra['ticketCount'] as int? ?? 100;
              return SubmitEditScreen(
                ticketIndex: ticketIndex,
                ticketNumbers: ticketNumbers,
                ticketCount: ticketCount,
              );
            },
          ),
          GoRoute(
            path: '/submit/complete',
            name: 'submit-complete',
            builder: (context, state) {
              final extra = state.extra as Map<String, dynamic>? ?? {};
              final ticketCount = extra['ticketCount'] as int? ?? 100;
              return SubmitCompleteScreen(ticketCount: ticketCount);
            },
          ),

          // 내 응모
          GoRoute(
            path: '/my-tickets',
            name: 'my-tickets',
            builder: (context, state) => AuthGuardWidget(
              requireOnboarding: true,
              child: const MyTicketsScreen(),
            ),
          ),

          // 응모 결과
          GoRoute(
            path: '/results',
            name: 'results',
            builder: (context, state) => AuthGuardWidget(
              requireOnboarding: true,
              child: const ResultsScreen(),
            ),
          ),

          // 설정
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => AuthGuardWidget(
              requireOnboarding: true,
              child: const SettingsScreen(),
            ),
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

      // 테스트 화면 (개발용)
      GoRoute(
        path: '/test/supabase',
        name: 'supabase-test',
        builder: (context, state) => const SupabaseApiTestScreen(),
      ),

      // 내 응모 화면
      GoRoute(
        path: '/my-entries',
        name: 'my-entries',
        builder: (context, state) => const MyEntriesScreen(),
      ),

      // 응모결과 화면
      GoRoute(
        path: '/results',
        name: 'results',
        builder: (context, state) => const ResultsScreen(),
      ),

      // 별들의 전당 화면
      GoRoute(
        path: '/hall-of-fame',
        name: 'hall-of-fame',
        builder: (context, state) => const HallOfFameScreen(),
      ),

      // 설정 화면
      GoRoute(
        path: '/settings',
        name: 'settings',
        builder: (context, state) => const SettingsScreen(),
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
    ],

    // 리다이렉트 로직
    redirect: (context, state) {
      final authState = ref.read(supabaseAuthProvider);

      // 인증되지 않은 사용자
      if (!authState.isAuthenticated) {
        if (state.uri.path == '/login') return null;
        return '/login';
      }

      // 온보딩 미완료
      if (!authState.isOnboarded) {
        if (state.uri.path == '/onboarding') return null;
        return '/onboarding';
      }

      // 스플래시에서 홈으로 리다이렉트
      if (state.uri.path == '/') {
        return '/home';
      }

      return null;
    },

    // 에러 처리
    errorBuilder: (context, state) => const NotFoundScreen(),
  );
});
