import 'package:flutter/material.dart';
import '../../index.dart';

class LottoInfoCard extends StatelessWidget {
  final String roundNumber;
  final String totalPrize;
  final String announcementTime;
  final String daysLeft;
  final VoidCallback? onHowToTap;

  const LottoInfoCard({
    super.key,
    required this.roundNumber,
    required this.totalPrize,
    required this.announcementTime,
    required this.daysLeft,
    this.onHowToTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 상단 정보
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: const Color(0xFFEFEFEF),
                  borderRadius: BorderRadius.circular(26),
                ),
                child: const Icon(
                  Icons.account_balance_wallet,
                  color: AppColors.primaryBlue,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      '진행 중인 로또6/45',
                      style: AppTextStyle.caption,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: 4),
                    AppText(
                      roundNumber,
                      style: AppTextStyle.title,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: AppText(
                  daysLeft,
                  style: AppTextStyle.caption,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: 16),
          
          // 당첨금 정보
          Center(
            child: Column(
              children: [
                AppText(
                  '이번주 총 당첨금',
                  style: AppTextStyle.subtitle,
                  color: const Color(0xFF9D9D9D),
                ),
                const SizedBox(height: 8),
                AppText(
                  totalPrize,
                  style: AppTextStyle.headline2,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 발표 시간
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFFF0F0F0),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.access_time,
                  size: 20,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 8),
                AppText(
                  announcementTime,
                  style: AppTextStyle.body,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
          
          const SizedBox(height: 16),
          
          // 어떻게 하는지 궁금해요
          if (onHowToTap != null)
            GestureDetector(
              onTap: onHowToTap,
              child: AppText(
                '어떻게 하는지 궁금해요 >',
                style: AppTextStyle.body,
                color: AppColors.primaryBlue,
              ),
            ),
        ],
      ),
    );
  }
}
