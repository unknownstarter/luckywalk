import 'package:flutter/material.dart';
import '../../index.dart';

class RewardCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final String buttonText;
  final bool isEnabled;
  final VoidCallback? onPressed;

  const RewardCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.buttonText,
    this.isEnabled = true,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Row(
        children: [
          // 아이콘 컨테이너
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: const Color(0xFFEFEFEF),
              borderRadius: BorderRadius.circular(26),
            ),
            child: Icon(
              icon,
              color: Colors.black,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          
          // 텍스트 컨테이너
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  title,
                  style: AppTextStyle.title,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: 4),
                AppText(
                  subtitle,
                  style: AppTextStyle.caption,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
          
          // 버튼
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: isEnabled ? AppColors.primaryBlue : const Color(0xFFD9D9D9),
              borderRadius: BorderRadius.circular(8),
            ),
            child: GestureDetector(
              onTap: isEnabled ? onPressed : null,
              child: AppText(
                buttonText,
                style: AppTextStyle.caption,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
