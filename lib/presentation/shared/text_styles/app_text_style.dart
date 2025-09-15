import 'package:flutter/material.dart';

/// LuckyWalk 앱의 텍스트 스타일 정의
/// 
/// 폰트 시스템:
/// - Baloo: 로고 및 브랜드 텍스트 전용
/// - Pretendard: 기본 UI 텍스트 (한국어 최적화)
class AppTextStyle {
  // Private constructor to prevent instantiation
  AppTextStyle._();

  // ===== Baloo 폰트 스타일 (로고 전용) =====
  
  /// 메인 로고 스타일
  static const TextStyle logoMain = TextStyle(
    fontFamily: 'Baloo',
    fontSize: 36,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.2,
  );

  /// 대형 로고 스타일 (필요시)
  static const TextStyle logoLarge = TextStyle(
    fontFamily: 'Baloo',
    fontSize: 50,
    fontWeight: FontWeight.bold,
    color: Colors.white,
    letterSpacing: 1.5,
  );

  // ===== Pretendard 폰트 스타일 (기본 UI) =====
  
  /// 상단 슬로건 ("매일 걸으면서 받는 공짜 복권")
  static const TextStyle slogan = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w500, // Medium
    color: Colors.white,
  );

  /// 서브 텍스트 ("로또6/45 숫자 기반 당첨")
  static const TextStyle subText = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w800, // ExtraBold
    color: Colors.white,
  );

  /// 중간 제목 ("매주 보너스 당첨금")
  static const TextStyle sectionTitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 30,
    fontWeight: FontWeight.w800, // ExtraBold
    color: Colors.white,
  );

  /// 대형 금액 표시 ("1,500,000원")
  static const TextStyle largeAmount = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 50,
    fontWeight: FontWeight.w800, // ExtraBold
    color: Colors.white,
  );

  /// 약관 동의 문구
  static const TextStyle termsText = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w300, // Light
    color: Colors.white70,
  );

  /// 버튼 텍스트
  static const TextStyle buttonText = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.white,
  );

  // ===== 레거시 스타일 (호환성 유지) =====
  
  /// Headline 1 - 메인 제목
  static const TextStyle headline1 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  /// Headline 2 - 섹션 제목
  static const TextStyle headline2 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 24,
    fontWeight: FontWeight.bold,
    color: Colors.black,
  );

  /// Headline 3 - 카드 제목
  static const TextStyle headline3 = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 20,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.black,
  );

  /// Title - 카드 제목
  static const TextStyle title = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 18,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.black,
  );

  /// Subtitle - 부제목
  static const TextStyle subtitle = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w500, // Medium
    color: Colors.black,
  );

  /// Body - 본문
  static const TextStyle body = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 14,
    fontWeight: FontWeight.w400, // Regular
    color: Colors.black,
  );

  /// Caption - 설명 텍스트
  static const TextStyle caption = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 12,
    fontWeight: FontWeight.w400, // Regular
    color: Colors.black,
  );

  /// Button - 버튼 텍스트
  static const TextStyle button = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 16,
    fontWeight: FontWeight.w600, // SemiBold
    color: Colors.white,
  );

  /// Overline - 라벨
  static const TextStyle overline = TextStyle(
    fontFamily: 'Pretendard',
    fontSize: 10,
    fontWeight: FontWeight.w500, // Medium
    letterSpacing: 1.5,
    color: Colors.black,
  );
}
