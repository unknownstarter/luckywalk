import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/lotto_datetime.dart';
import '../../../providers/home_data_provider.dart';
import '../../shared/index.dart';

/// 응모결과 화면
class ResultsScreen extends ConsumerStatefulWidget {
  const ResultsScreen({super.key});

  @override
  ConsumerState<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends ConsumerState<ResultsScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const AppText('응모결과', style: AppTextStyle.title),
        backgroundColor: AppColors.primaryBlue,
        foregroundColor: AppColors.textInverse,
        centerTitle: true,
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

          // 광고 컨테이너
          _buildAdContainer(),
          const SizedBox(height: 24),

          // 당첨 번호 섹션
          _buildWinningNumbersSection(),
          const SizedBox(height: 24),

          // 내 당첨 결과 섹션
          _buildMyResultsSection(),
          const SizedBox(height: 24),

          // 전체 당첨 결과 섹션
          _buildTotalResultsSection(),
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

          // 발표 예정일
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.circular(8),
            ),
            child: AppText(
              '$announcementDate 발표 예정',
              style: AppTextStyle.caption,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdContainer() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        children: [
          // 광고 아이콘
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: AppColors.borderLight,
              borderRadius: BorderRadius.circular(26),
            ),
            child: const Icon(
              Icons.card_giftcard,
              color: AppColors.textSecondary,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // 광고 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                AppText(
                  '보너스 광고보고 복권 더 받기',
                  style: AppTextStyle.subtitle,
                ),
                const SizedBox(height: 4),
                AppText(
                  '복권 3장 추가 획득',
                  style: AppTextStyle.caption,
                  color: AppColors.textSecondary,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWinningNumbersSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '이번 회차 당첨 번호',
          style: AppTextStyle.title,
        ),
        const SizedBox(height: 8),
        AppText(
          '실제로 발표한 로또 6/45 번호와 같아요',
          style: AppTextStyle.body,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),

        // 당첨 번호 표시
        _buildWinningNumbersDisplay(),
      ],
    );
  }

  Widget _buildWinningNumbersDisplay() {
    // TODO: 실제 당첨 번호 데이터 연동
    final winningNumbers = [1, 2, 11, 21, 33, 45];

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: winningNumbers.map((number) {
          return Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: _getNumberColor(number),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Center(
              child: AppText(
                number.toString(),
                style: AppTextStyle.subtitle,
                color: AppColors.textInverse,
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildMyResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '내 당첨 결과',
          style: AppTextStyle.title,
        ),
        const SizedBox(height: 8),
        AppText(
          '내가 당첨된 복권을 모아서 보여드려요',
          style: AppTextStyle.body,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),

        // TODO: 실제 당첨 결과 데이터 연동
        _buildMyResultsList(),
      ],
    );
  }

  Widget _buildMyResultsList() {
    // TODO: 실제 당첨 결과 데이터로 교체
    final mockResults = [
      {
        'rank': 1,
        'rankText': '1등 당첨',
        'numbers': [1, 2, 11, 21, 33, 45],
        'prize': '1,000,000만원',
        'status': 'claimable',
        'buttonText': '당첨금 받기',
        'buttonColor': AppColors.primaryBlue,
      },
      {
        'rank': 2,
        'rankText': '2등 당첨',
        'numbers': [1, 2, 11, 21, 33, 45],
        'prize': '500,000만원',
        'status': 'claimable',
        'buttonText': '당첨금 받기',
        'buttonColor': AppColors.primaryBlue,
      },
      {
        'rank': 3,
        'rankText': '3등 당첨',
        'numbers': [1, 2, 11, 21, 33, 45],
        'prize': '복권 50장',
        'status': 'completed',
        'buttonText': '지급 완료',
        'buttonColor': AppColors.textSecondary,
      },
    ];

    return Column(
      children: mockResults.map((result) => _buildResultCard(result)).toList(),
    );
  }

  Widget _buildResultCard(Map<String, dynamic> result) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // 등수 배지
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: _getRankColor(result['rank']),
              borderRadius: BorderRadius.circular(16),
            ),
            child: AppText(
              result['rankText'],
              style: AppTextStyle.caption,
              color: AppColors.textInverse,
            ),
          ),
          const SizedBox(height: 16),

          // 당첨 번호들
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: (result['numbers'] as List<int>).map((number) {
              return Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: _getNumberColor(number),
                  borderRadius: BorderRadius.circular(18),
                ),
                child: Center(
                  child: AppText(
                    number.toString(),
                    style: AppTextStyle.subtitle,
                    color: AppColors.textInverse,
                  ),
                ),
              );
            }).toList(),
          ),
          const SizedBox(height: 16),

          // 당첨금과 버튼
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                result['prize'],
                style: AppTextStyle.subtitle,
              ),
              Container(
                width: 120,
                height: 35,
                decoration: BoxDecoration(
                  color: result['buttonColor'],
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: AppText(
                    result['buttonText'],
                    style: AppTextStyle.caption,
                    color: AppColors.textInverse,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTotalResultsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '전체 당첨 결과',
          style: AppTextStyle.title,
        ),
        const SizedBox(height: 8),
        AppText(
          '이번 회차의 등수별 당첨자 수와 당첨금이에요',
          style: AppTextStyle.body,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: 16),

        // 전체 당첨 결과 테이블
        _buildTotalResultsTable(),
        const SizedBox(height: 16),
        
        // 별들의 전당 구경하기 버튼
        PrimaryButton(
          text: '별들의 전당 구경하기',
          onPressed: () => context.go('/hall-of-fame'),
        ),
      ],
    );
  }

  Widget _buildTotalResultsTable() {
    // TODO: 실제 전체 당첨 결과 데이터 연동
    final mockTotalResults = [
      {'rank': '1등', 'winners': '1명', 'prize': '1,000,000원'},
      {'rank': '2등', 'winners': '1명', 'prize': '500,000원'},
      {'rank': '3등', 'winners': '1,000,000명', 'prize': '복권 50장'},
    ];

    return Container(
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          // 헤더
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.backgroundLight,
              borderRadius: BorderRadius.only(
                topLeft: Radius.circular(16),
                topRight: Radius.circular(16),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText(
                    '등수',
                    style: AppTextStyle.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    '당첨자 수',
                    style: AppTextStyle.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    '1인당 당첨금',
                    style: AppTextStyle.caption,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          ),

          // 데이터 행들
          ...mockTotalResults.map((result) => Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(
                top: BorderSide(color: AppColors.borderLight),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  flex: 1,
                  child: AppText(
                    result['rank']!,
                    style: AppTextStyle.caption,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    result['winners']!,
                    style: AppTextStyle.caption,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
                Expanded(
                  flex: 2,
                  child: AppText(
                    result['prize']!,
                    style: AppTextStyle.caption,
                    color: AppColors.textSecondary,
                    textAlign: TextAlign.center,
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Color _getNumberColor(int number) {
    if (number <= 10) return AppColors.lotteryRed;
    if (number <= 20) return AppColors.lotteryBlue;
    if (number <= 30) return AppColors.lotteryGreen;
    if (number <= 40) return AppColors.lotteryOrange;
    return AppColors.lotteryPurple;
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