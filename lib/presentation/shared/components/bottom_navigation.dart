import 'package:flutter/material.dart';
import '../index.dart';

class AppBottomNavigation extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const AppBottomNavigation({
    super.key,
    required this.currentIndex,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 96,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(
          top: BorderSide(color: const Color(0xFFD9D9D9), width: 1),
        ),
      ),
      child: Row(
        children: [
          _buildNavItem(
            icon: Icons.home,
            label: 'Home',
            index: 0,
            isActive: currentIndex == 0,
          ),
          _buildNavItem(
            icon: Icons.list_alt,
            label: '내 응모',
            index: 1,
            isActive: currentIndex == 1,
          ),
          _buildNavItem(
            icon: Icons.emoji_events,
            label: '응모 결과',
            index: 2,
            isActive: currentIndex == 2,
          ),
          _buildNavItem(
            icon: Icons.settings,
            label: '설정',
            index: 3,
            isActive: currentIndex == 3,
          ),
        ],
      ),
    );
  }

  Widget _buildNavItem({
    required IconData icon,
    required String label,
    required int index,
    required bool isActive,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: () => onTap(index),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isActive ? AppColors.primaryBlue : const Color(0xFF9D9D9D),
              size: 24,
            ),
            const SizedBox(height: 4),
            AppText(
              label,
              style: AppTextStyle.caption,
              color: isActive ? AppColors.primaryBlue : const Color(0xFF9D9D9D),
            ),
          ],
        ),
      ),
    );
  }
}

class EnterButton extends StatelessWidget {
  final int ticketCount;
  final VoidCallback? onPressed;

  const EnterButton({
    super.key,
    required this.ticketCount,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(29),
        border: Border.all(color: const Color(0xFFD9D9D9)),
      ),
      child: Stack(
        children: [
          // 메인 버튼
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
                AppText(
                  '응모하기',
                  style: AppTextStyle.caption,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          
          // 티켓 카운트 배지
          Positioned(
            top: 8,
            right: 8,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.primaryBlue,
                borderRadius: BorderRadius.circular(4),
              ),
              child: AppText(
                '${ticketCount}장',
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
