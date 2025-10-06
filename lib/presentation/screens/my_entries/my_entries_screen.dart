import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/utils/lotto_datetime.dart';
import '../../../providers/home_data_provider.dart';
import '../../shared/index.dart';

/// 내 응모 화면
class MyEntriesScreen extends ConsumerStatefulWidget {
  const MyEntriesScreen({super.key});

  @override
  ConsumerState<MyEntriesScreen> createState() => _MyEntriesScreenState();
}

class _MyEntriesScreenState extends ConsumerState<MyEntriesScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(homeDataProvider);

    return Scaffold(
      backgroundColor: AppColors.backgroundLight,
      appBar: AppBar(
        title: const AppText('내 응모', style: AppTextStyle.title),
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
    final userProfile = homeData.userProfile!;

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 현재 회차 정보
          _buildCurrentRoundInfo(currentRound),
          const SizedBox(height: 24),

          // 응모 히스토리 섹션
          _buildEntryHistorySection(userProfile),
          const SizedBox(height: 24),

          // 응모 내역이 없을 때
          if (_getTotalEntries(userProfile) == 0) _buildNoEntriesState(),

          // 응모 내역이 있을 때
          if (_getTotalEntries(userProfile) > 0) _buildEntriesList(userProfile),
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

  Widget _buildEntryHistorySection(Map<String, dynamic> userProfile) {
    final totalEntries = _getTotalEntries(userProfile);

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          '내 응모 히스토리',
          style: AppTextStyle.title,
        ),
        const SizedBox(height: 8),
        AppText(
          '이번 회차에 총 ${totalEntries.toString().replaceAllMapped(
            RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
            (Match m) => '${m[1]},',
          )}장을 응모했어요',
          style: AppTextStyle.body,
          color: AppColors.textSecondary,
        ),
      ],
    );
  }

  Widget _buildNoEntriesState() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(40),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        children: [
          Icon(
            Icons.receipt_long_outlined,
            size: 64,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          AppText(
            '아직 응모한 복권이 없어요',
            style: AppTextStyle.title,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 8),
          AppText(
            '홈 화면에서 응모하기 버튼을 눌러\n복권을 응모해보세요!',
            style: AppTextStyle.body,
            color: AppColors.textSecondary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          PrimaryButton(
            text: '응모하러 가기',
            onPressed: () => context.go('/'),
          ),
        ],
      ),
    );
  }

  Widget _buildEntriesList(Map<String, dynamic> userProfile) {
    // TODO: 실제 응모 내역 데이터 연동
    final mockEntries = _getMockEntries();

    return Column(
      children: mockEntries.map((entry) => _buildEntryCard(entry)).toList(),
    );
  }

  Widget _buildEntryCard(Map<String, dynamic> entry) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.backgroundLight,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.borderLight),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 응모 정보
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                '${entry['ticket_count']}장 응모',
                style: AppTextStyle.subtitle,
              ),
              AppText(
                entry['submitted_at'],
                style: AppTextStyle.caption,
                color: AppColors.textSecondary,
              ),
            ],
          ),
          const SizedBox(height: 12),

          // 복권 번호들
          _buildLotteryNumbers(entry['numbers']),
          const SizedBox(height: 12),

          // 상태
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _buildStatusBadge(entry['status']),
              if (entry['status'] == 'pending')
                AppText(
                  '결과 대기 중',
                  style: AppTextStyle.caption,
                  color: AppColors.textSecondary,
                ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLotteryNumbers(List<Map<String, dynamic>> numbers) {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: numbers.map((numberData) {
        return Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: numberData['color'],
            borderRadius: BorderRadius.circular(16),
          ),
          child: Center(
            child: AppText(
              numberData['number'].toString(),
              style: AppTextStyle.caption,
              color: AppColors.textInverse,
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildStatusBadge(String status) {
    Color backgroundColor;
    String text;

    switch (status) {
      case 'pending':
        backgroundColor = AppColors.warningOrange;
        text = '대기 중';
        break;
      case 'won':
        backgroundColor = AppColors.successGreen;
        text = '당첨';
        break;
      case 'lost':
        backgroundColor = AppColors.textSecondary;
        text = '낙첨';
        break;
      default:
        backgroundColor = AppColors.textSecondary;
        text = '알 수 없음';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
      ),
      child: AppText(
        text,
        style: AppTextStyle.caption,
        color: AppColors.textInverse,
      ),
    );
  }

  int _getTotalEntries(Map<String, dynamic> userProfile) {
    // TODO: 실제 응모 내역 데이터에서 계산
    return 0; // 임시로 0 반환
  }

  List<Map<String, dynamic>> _getMockEntries() {
    // TODO: 실제 응모 내역 데이터로 교체
    return [
      {
        'ticket_count': 100,
        'submitted_at': '2025.01.17 14:30',
        'numbers': [
          {'number': 7, 'color': AppColors.lotteryRed},
          {'number': 12, 'color': AppColors.lotteryBlue},
          {'number': 23, 'color': AppColors.lotteryGreen},
          {'number': 31, 'color': AppColors.lotteryOrange},
          {'number': 38, 'color': AppColors.lotteryPurple},
          {'number': 42, 'color': AppColors.lotteryYellow},
        ],
        'status': 'pending',
      },
    ];
  }
}
