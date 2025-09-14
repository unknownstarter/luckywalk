import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/mock_data_providers.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(mockHomeDataProvider);
    final currentRound = homeData['currentRound'] as MockRound;
    final userProfile = homeData['userProfile'] as MockUserProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text('LuckyWalk'),
        backgroundColor: const Color(0xFF1E3A8A),
        foregroundColor: Colors.white,
        actions: [
          Container(
            margin: const EdgeInsets.only(right: 16),
            child: const Icon(Icons.emoji_events, color: Colors.white),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 현재 회차 정보
            _buildRoundInfo(currentRound),
            const SizedBox(height: 24),

            // 매일 출석체크 복권
            _buildAttendanceCard(userProfile),
            const SizedBox(height: 16),

            // 광고 영역
            _buildAdBanner(),
            const SizedBox(height: 16),

            // 오늘 걸은만큼 받는 특권
            _buildStepsRewardCard(userProfile),
            const SizedBox(height: 16),

            // 광고보고 받는 보너스 복권
            _buildAdsRewardCard(userProfile),
            const SizedBox(height: 16),

            // 초대하기
            _buildReferralCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundInfo(MockRound currentRound) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                Icons.account_balance_wallet,
                color: Color(0xFF1E3A8A),
                size: 24,
              ),
              const SizedBox(width: 8),
              const Text(
                '진행 중인 로또6/45',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3일 남음',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Text(
                '진행 중인 로또6/45',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E3A8A),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text(
                  '3일 남음',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 4),
          Text(
            '${currentRound.roundNumber}회차',
            style: const TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '이번주 총 당첨금',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          Text(
            '${currentRound.totalPrize.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
            style: const TextStyle(
              fontSize: 24,
              fontWeight: FontWeight.bold,
              color: Color(0xFF1E3A8A),
            ),
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              const Icon(Icons.access_time, size: 16, color: Colors.grey),
              const SizedBox(width: 4),
              const Text(
                '2025.09.29 오후 9시 발표 예정',
                style: TextStyle(fontSize: 14, color: Colors.grey),
              ),
            ],
          ),
          const SizedBox(height: 16),
          GestureDetector(
            onTap: () {
              // TODO: 어떻게 하는지 궁금해요 페이지로 이동
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('어떻게 하는지 궁금해요 페이지로 이동')),
              );
            },
            child: const Text(
              '어떻게 하는지 궁금해요 >',
              style: TextStyle(
                fontSize: 14,
                color: Color(0xFF1E3A8A),
                decoration: TextDecoration.underline,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      width: double.infinity,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: Text(
          '광고 영역',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }

  Widget _buildAttendanceCard(MockUserProfile userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '매일 출석체크 복권',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                const Icon(
                  Icons.calendar_today,
                  color: Color(0xFF1E3A8A),
                  size: 20,
                ),
                const SizedBox(width: 8),
                const Expanded(
                  child: Text(
                    '하루 한번 출첵하고\n복권 3장 받기',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: userProfile.attendanceChecked ? null : () => _handleAttendanceCheck(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                  ),
                  child: Text(userProfile.attendanceChecked ? '완료' : '받기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsRewardCard(MockUserProfile userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '오늘 걸은만큼 받는 복권',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${userProfile.todaySteps}걸음',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildStepRewardItem('1,000 걸음 걷고', 1000, 1, userProfile.stepsRewards[1000] ?? false, userProfile.todaySteps >= 1000),
            _buildStepRewardItem('2,000 걸음 걷고', 2000, 1, userProfile.stepsRewards[2000] ?? false, userProfile.todaySteps >= 2000),
            _buildStepRewardItem('3,000 걸음 걷고', 3000, 1, userProfile.stepsRewards[3000] ?? false, userProfile.todaySteps >= 3000),
            _buildStepRewardItem('4,000 걸음 걷고', 4000, 3, userProfile.stepsRewards[4000] ?? false, userProfile.todaySteps >= 4000),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRewardItem(
    String title,
    int steps,
    int rewardCount,
    bool isClaimed,
    bool isAvailable,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: 복권 ${rewardCount}장 받기',
              style: TextStyle(color: isClaimed ? Colors.grey : Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: isClaimed ? null : (isAvailable ? () => _handleStepsReward(steps) : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClaimed
                  ? Colors.grey
                  : (isAvailable ? const Color(0xFF1E3A8A) : Colors.grey),
            ),
            child: Text(isClaimed ? '완료' : (isAvailable ? '받기' : '잠김')),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsRewardCard(MockUserProfile userProfile) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Text(
                  '광고보고 받는 보너스 복권',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                const Spacer(),
                Text(
                  '${userProfile.adsWatchedToday}/${userProfile.maxAdsToday}',
                  style: const TextStyle(
                    fontSize: 14,
                    color: Color(0xFF1E3A8A),
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildAdRewardItem('1번째 광고보고', 1, 1, userProfile.adsRewards[1] ?? false, true),
            _buildAdRewardItem('2번째 광고보고', 2, 1, userProfile.adsRewards[2] ?? false, userProfile.adsRewards[1] == true),
            _buildAdRewardItem('3번째 광고보고', 3, 1, userProfile.adsRewards[3] ?? false, userProfile.adsRewards[2] == true),
            _buildAdRewardItem('4번째 광고보고', 4, 3, userProfile.adsRewards[4] ?? false, userProfile.adsRewards[3] == true),
          ],
        ),
      ),
    );
  }

  Widget _buildAdRewardItem(
    String title,
    int sequence,
    int rewardCount,
    bool isClaimed,
    bool isAvailable,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          const Icon(Icons.card_giftcard, color: Colors.red, size: 20),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              '$title: 복권 ${rewardCount}장 받기',
              style: TextStyle(color: isClaimed ? Colors.grey : Colors.black),
            ),
          ),
          ElevatedButton(
            onPressed: isClaimed ? null : (isAvailable ? () => _handleAdReward(sequence) : null),
            style: ElevatedButton.styleFrom(
              backgroundColor: isClaimed
                  ? Colors.grey
                  : (isAvailable ? const Color(0xFF1E3A8A) : Colors.grey),
            ),
            child: Text(isClaimed ? '완료' : (isAvailable ? '받기' : '잠김')),
          ),
        ],
      ),
    );
  }

  Widget _buildReferralCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '친구 초대하고 복권 받기',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            ElevatedButton(
              onPressed: () => context.go('/referral'),
              child: const Text('친구 초대하기'),
            ),
          ],
        ),
      ),
    );
  }


  Future<void> _handleAttendanceCheck() async {
    try {
      await ref.read(mockUserProfileProvider.notifier).checkAttendance();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('출석체크 완료! 복권 3장을 받았습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('출석체크 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleStepsReward(int steps) async {
    try {
      await ref.read(mockUserProfileProvider.notifier).claimStepsReward(steps);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${steps}걸음 보상 완료! 복권을 받았습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('보상 수령 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _handleAdReward(int sequence) async {
    try {
      await ref.read(mockUserProfileProvider.notifier).claimAdReward(sequence);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('${sequence}번째 광고 보상 완료! 복권을 받았습니다.'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('광고 보상 수령 실패: $error'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }
}
