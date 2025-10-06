import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../index.dart';

class AppBottomSheet extends StatelessWidget {
  final String title;
  final Widget content;
  final Widget? footer;
  final double? height;
  final bool showCloseButton;
  final VoidCallback? onClose;

  const AppBottomSheet({
    super.key,
    required this.title,
    required this.content,
    this.footer,
    this.height,
    this.showCloseButton = true,
    this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: height ?? MediaQuery.of(context).size.height * 0.7,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(32),
          topRight: Radius.circular(32),
        ),
      ),
      child: Column(
        children: [
          // 헤더
          _buildHeader(context),

          // 컨텐츠
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: content,
            ),
          ),

          // 푸터 (선택사항)
          if (footer != null) footer!,
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24.0),
      decoration: const BoxDecoration(
        border: Border(bottom: BorderSide(color: Color(0xFFF0F0F0), width: 1)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          const SizedBox(width: 24), // 중앙 정렬을 위한 공간
          AppText(
            title,
            style: AppTextStyle.title,
            color: AppColors.textPrimary,
          ),
          if (showCloseButton)
            GestureDetector(
              onTap: onClose ?? () => context.pop(),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: const Color(0xFFF5F5F5),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Icon(
                  Icons.close,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
        ],
      ),
    );
  }

  /// 바텀시트를 표시하는 정적 메서드
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required Widget content,
    Widget? footer,
    double? height,
    bool showCloseButton = true,
    VoidCallback? onClose,
    bool isDismissible = true,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      isDismissible: isDismissible,
      builder: (context) => AppBottomSheet(
        title: title,
        content: content,
        footer: footer,
        height: height,
        showCloseButton: showCloseButton,
        onClose: onClose,
      ),
    );
  }
}
