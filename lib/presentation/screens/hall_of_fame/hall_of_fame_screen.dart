import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/lotto_datetime.dart';
import '../../../providers/home_data_provider.dart';
import '../../shared/index.dart';

/// 별들의 전당 화면
class HallOfFameScreen extends ConsumerStatefulWidget {
  const HallOfFameScreen({super.key});

  @override
  ConsumerState<HallOfFameScreen> createState() => _HallOfFameScreenState();
}

class _HallOfFameScreenState extends ConsumerState<HallOfFameScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const AppText('별들의 전당', style: AppTextStyle.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios),
          onPressed: () => context.pop(),
        ),
      ),
      body: homeData.isLoading
          ? const Center(child: CircularProgressIndicator())
          : homeData.error != null
              ? Center(
                  child: AppText(
                    '에러가 발생했습니다: $homeData.error',
                    style: AppTextStyle.body,
                  ),
                )
              : _buildContent(homeData),
    );
  }

  Widget _buildContent(HomeDataState homeData) {
    final currentRound = homeData.currentRound!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 회차 정보
          _buildCurrentRoundInfo(currentRound),
          const SizedBox(height: 24),

          // 당첨자 목록
          _buildWinnersList(),
        ],
      ),
    );
  }

  Widget _buildCurrentRoundInfo(Map<String, dynamic> currentRound) {
    final roundNumber = currentRound['round_number'] ?? 1101;
    final announcementTime = LottoDateTime.getNextAnnouncementTime();
    final announcementDate = announcementTime.toString().substring(0, 10).replaceAll('-', '.');

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.primaryBlue,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          // 회차 정보
          AppText(
            '$roundNumber회차',
            style: AppTextStyle.title,
            color: AppColors.textInverse,
          ),
          const SizedBox(height: 8),

          // 발표 완료일
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              '$announcementDate 발표 완료',
              style: AppTextStyle.caption,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinnersList() {
    // TODO: 실제 당첨자 데이터 연동
    final mockWinners = _getMockWinners();

    return Column(
      children: mockWinners.map((winner) => _buildWinnerCard(winner)).toList(),
    );
  }

  Widget _buildWinnerCard(Map<String, dynamic> winner) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 당첨자 정보 헤더
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // 사용자 이름
              AppText(
                winner['userName'],
                style: AppTextStyle.subtitle,
                color: AppColors.textPrimary,
              ),
              // 응모 수량
              AppText(
                '${winner['entriesCount']}장 응모',
                style: AppTextStyle.caption,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 당첨 등수 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRankColor(winner['rank']),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppText(
              winner['rankText'],
              style: AppTextStyle.caption,
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 16),

          // 당첨금 정보
          Row(
            children: [
              AppText(
                '당첨금',
                style: AppTextStyle.subtitle,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: 16),
              AppText(
                winner['prizeAmount'],
                style: AppTextStyle.title,
                color: AppColors.textPrimary,
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 사용자 코멘트
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.borderLight),
            ),
            child: AppText(
              winner['comment'],
              style: AppTextStyle.body,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  List<Map<String, dynamic>> _getMockWinners() {
    // TODO: 실제 당첨자 데이터로 교체
    return [
      {
        'userName': '황*하',
        'entriesCount': 500,
        'rank': 1,
        'rankText': '1등 당첨',
        'prizeAmount': '1,000,000원',
        'comment': '이게 진짜 가능할지 몰랐어요 ㅋㅋㅋㅋㅋ\n내가 당첨이 되다니~ \n이번에 당첨된 기분으로 다음 회차 고고!',
      },
      {
        'userName': '김*수',
        'entriesCount': 500,
        'rank': 2,
        'rankText': '2등 당첨',
        'prizeAmount': '500,000원',
        'comment': '이게 진짜 가능할지 몰랐어요 ㅋㅋㅋㅋㅋ\n내가 당첨이 되다니~ \n이번에 당첨된 기분으로 다음 회차 고고!',
      },
      {
        'userName': '박*영',
        'entriesCount': 500,
        'rank': 3,
        'rankText': '3등 당첨',
        'prizeAmount': '복권 50장',
        'comment': '이게 진짜 가능할지 몰랐어요 ㅋㅋㅋㅋㅋ\n내가 당첨이 되다니~ \n이번에 당첨된 기분으로 다음 회차 고고!',
      },
    ];
  }

  Color _getRankColor(int rank) {
    switch (rank) {
      case 1:
        return AppColors.errorRed;
      case 2:
        return AppColors.warningOrange;
      case 3:
        return AppColors.primaryBlue;
      default:
        return AppColors.textSecondary;
    }
  }
}
