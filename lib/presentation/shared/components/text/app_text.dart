import 'package:flutter/material.dart';

/// 앱 전용 텍스트 스타일 컴포넌트
class AppText extends StatelessWidget {
  final String text;
  final AppTextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    required this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: _getTextStyle(context).copyWith(color: color),
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }

  TextStyle _getTextStyle(BuildContext context) {
    switch (style) {
      case AppTextStyle.headline1:
        return const TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          height: 1.2,
        );
      case AppTextStyle.headline2:
        return const TextStyle(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          height: 1.3,
        );
      case AppTextStyle.headline3:
        return const TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          height: 1.3,
        );
      case AppTextStyle.title:
        return const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          height: 1.4,
        );
      case AppTextStyle.subtitle:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w500,
          height: 1.4,
        );
      case AppTextStyle.body:
        return const TextStyle(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          height: 1.5,
        );
      case AppTextStyle.caption:
        return const TextStyle(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          height: 1.4,
        );
      case AppTextStyle.button:
        return const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          height: 1.2,
        );
      case AppTextStyle.overline:
        return const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w500,
          height: 1.2,
          letterSpacing: 1.5,
        );
    }
  }
}

enum AppTextStyle {
  headline1,
  headline2,
  headline3,
  title,
  subtitle,
  body,
  caption,
  button,
  overline,
}
