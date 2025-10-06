import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../../providers/supabase_auth_provider.dart';
import '../../../core/logging/logger.dart';
import '../../shared/text_styles/app_text_style.dart';

class LoginScreen extends ConsumerStatefulWidget {
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  @override
  Widget build(BuildContext context) {
    final authState = ref.watch(supabaseAuthProvider);

    // 로딩 상태 처리
    if (authState.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    // 에러 상태 처리
    if (authState.error != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authState.error!),
            backgroundColor: Colors.red,
            action: SnackBarAction(
              label: '닫기',
              textColor: Colors.white,
              onPressed: () {
                ref.read(supabaseAuthProvider.notifier).clearError();
              },
            ),
          ),
        );
      });
    }
    return Scaffold(
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
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Spacer(),

                // 상단 슬로건
                const Text(
                  '매일 걸으면서 받는 공짜 복권',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.slogan,
                ),
                const SizedBox(height: 16),

                // 앱 이름 (Baloo 폰트)
                const Text(
                  'LuckyWalk',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.logoMain,
                ),
                const SizedBox(height: 16),

                // 로또6/45 정보 뱃지
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Text(
                    '로또6/45 숫자 기반 당첨',
                    textAlign: TextAlign.center,
                    style: AppTextStyle.subText,
                  ),
                ),
                const SizedBox(height: 48),

                // 왕관 이미지
                SvgPicture.asset(
                  'assets/images/crown.svg',
                  width: 100,
                  height: 100,
                ),
                const SizedBox(height: 24),

                // 보너스 당첨금 안내
                const Text(
                  '매주 보너스 당첨금',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.sectionTitle,
                ),
                const SizedBox(height: 8),
                const Text(
                  '1,500,000원',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.largeAmount,
                ),
                const SizedBox(height: 64),

                // Apple 로그인 버튼
                ElevatedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () => _handleAppleLogin(context),
                  icon: const Icon(Icons.apple, color: Colors.white),
                  label: const Text(
                    'Apple로 로그인',
                    style: AppTextStyle.buttonText,
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.black,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 16),

                // Kakao 로그인 버튼
                ElevatedButton.icon(
                  onPressed: authState.isLoading
                      ? null
                      : () => _handleKakaoLogin(context),
                  icon: const Icon(Icons.chat, color: Colors.black),
                  label: const Text('카카오로 로그인', style: AppTextStyle.buttonText),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFF6E24B),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 32),

                // 약관 동의
                const Text(
                  '회원가입 시 서비스 이용 약관 및 개인정보 수집 및 이용에 동의합니다.',
                  textAlign: TextAlign.center,
                  style: AppTextStyle.termsText,
                ),

                const Spacer(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Future<void> _handleAppleLogin(BuildContext context) async {
    try {
      AppLogger.info('Apple Sign In initiated');
      await ref.read(supabaseAuthProvider.notifier).signInWithApple();
    } catch (error) {
      AppLogger.error('Apple Sign In failed: $error');
    }
  }

  Future<void> _handleKakaoLogin(BuildContext context) async {
    try {
      AppLogger.info('Kakao Sign In initiated');
      await ref.read(supabaseAuthProvider.notifier).signInWithKakao();
    } catch (error) {
      AppLogger.error('Kakao Sign In failed: $error');
    }
  }
}
