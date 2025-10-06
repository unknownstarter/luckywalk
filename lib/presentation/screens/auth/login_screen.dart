import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../providers/supabase_auth_provider.dart';
import '../../../core/logging/logger.dart';

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
      backgroundColor: const Color(0xFF0089FF), // 즉시 표시할 배경색
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF8DCAFF), // #8dcaff
              Color(0xFF0089FF), // #0089ff
            ],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: LayoutBuilder(
              builder: (context, constraints) {
                // 화면 높이에 따른 반응형 스케일 계산
                final screenHeight = constraints.maxHeight;
                final scaleFactor = (screenHeight / 800).clamp(
                  0.7,
                  1.2,
                ); // 0.7~1.2 범위로 제한

                return Column(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // 태그라인 (반응형)
                    Text(
                      '매일 걸으면서 받는 공짜 복권',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 20 * scaleFactor,
                        fontWeight: FontWeight.w500,
                        color: const Color(0xFFFFFFFF),
                        letterSpacing: 0,
                        height: 1.5,
                      ),
                    ),

                    // 앱 타이틀 (반응형) - 고해상도 이미지 사용
                    Image.asset(
                      'assets/images/App Title.png',
                      width: 300 * scaleFactor,
                      height: 80 * scaleFactor,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high, // 고품질 필터링
                    ),

                    // 서브타이틀 배경 (반응형)
                    Container(
                      width: 200 * scaleFactor,
                      height: 50 * scaleFactor,
                      decoration: BoxDecoration(
                        color: const Color(0xFF0088FF),
                        borderRadius: BorderRadius.circular(16 * scaleFactor),
                      ),
                      child: Center(
                        child: Text(
                          '로또6/45 숫자 기반 당첨',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Pretendard',
                            fontSize: 16 * scaleFactor,
                            fontWeight: FontWeight.w800,
                            color: const Color(0xFFFFFFFF),
                            letterSpacing: 0,
                            height: 1.875,
                          ),
                        ),
                      ),
                    ),

                    // crow-front-color 이미지 (반응형) - PNG 사용
                    Container(
                      width: 162 * scaleFactor,
                      height: 162 * scaleFactor,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8 * scaleFactor),
                        child: Image.asset(
                          'assets/images/crow-front-color.png',
                          width: 162 * scaleFactor,
                          height: 162 * scaleFactor,
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),

                    // 보너스 당첨금 텍스트 (반응형)
                    Text(
                      '매주 보너스 당첨금',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 30 * scaleFactor,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFFFFF),
                        letterSpacing: 0,
                        height: 1.0,
                      ),
                    ),

                    // 당첨금 금액 (반응형)
                    Text(
                      '1,500,000원',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 50 * scaleFactor,
                        fontWeight: FontWeight.w800,
                        color: const Color(0xFFFFFFFF),
                        letterSpacing: 0,
                        height: 1.0,
                      ),
                    ),

                    // Apple 로그인 버튼 (반응형)
                    SizedBox(
                      width: double.infinity,
                      height: 60 * scaleFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFF000000),
                          borderRadius: BorderRadius.circular(20 * scaleFactor),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              20 * scaleFactor,
                            ),
                            onTap: authState.isLoading
                                ? null
                                : () => _handleAppleLogin(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Apple 로고
                                Image.asset(
                                  'assets/images/apple_logo.png',
                                  width: 24 * scaleFactor,
                                  height: 24 * scaleFactor,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                // Apple 로그인 텍스트
                                Text(
                                  'Apple로 로그인',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 18 * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFFFFFFFF),
                                    letterSpacing: 0,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 카카오 로그인 버튼 (반응형)
                    SizedBox(
                      width: double.infinity,
                      height: 60 * scaleFactor,
                      child: Container(
                        decoration: BoxDecoration(
                          color: const Color(0xFFF6E24B),
                          borderRadius: BorderRadius.circular(20 * scaleFactor),
                        ),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            borderRadius: BorderRadius.circular(
                              20 * scaleFactor,
                            ),
                            onTap: authState.isLoading
                                ? null
                                : () => _handleKakaoLogin(context),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                // Kakao 로고
                                Image.asset(
                                  'assets/images/kakao_logo.png',
                                  width: 24 * scaleFactor,
                                  height: 24 * scaleFactor,
                                  fit: BoxFit.contain,
                                ),
                                SizedBox(width: 12 * scaleFactor),
                                // Kakao 로그인 텍스트
                                Text(
                                  '카카오로 로그인',
                                  style: TextStyle(
                                    fontFamily: 'Pretendard',
                                    fontSize: 18 * scaleFactor,
                                    fontWeight: FontWeight.w600,
                                    color: const Color(0xFF000000),
                                    letterSpacing: 0,
                                    height: 1.0,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),

                    // 약관 동의 텍스트 (반응형)
                    Text(
                      '회원가입 시 서비스 이용 약관 및 개인정보 수집 및 이용에 동의합니다.',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: 'Pretendard',
                        fontSize: 12 * scaleFactor,
                        fontWeight: FontWeight.w300,
                        color: const Color(0xFFFFFFFF),
                        letterSpacing: 0,
                        height: 1.67,
                      ),
                    ),
                  ],
                );
              },
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
