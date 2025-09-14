import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
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
            _buildRoundInfo(),
            const SizedBox(height: 24),

            // 매일 출석체크 복권
            _buildAttendanceCard(),
            const SizedBox(height: 16),

            // 광고 영역
            _buildAdBanner(),
            const SizedBox(height: 16),

            // 오늘 걸은만큼 받는 특권
            _buildStepsRewardCard(),
            const SizedBox(height: 16),

            // 광고보고 받는 보너스 복권
            _buildAdsRewardCard(),
            const SizedBox(height: 16),

            // 초대하기
            _buildReferralCard(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoundInfo() {
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
          const Text(
            '1234회차',
            style: TextStyle(fontSize: 18, color: Colors.grey),
          ),
          const SizedBox(height: 8),
          const Text(
            '이번주 총 당첨금',
            style: TextStyle(fontSize: 16, color: Colors.grey),
          ),
          const SizedBox(height: 4),
          const Text(
            '1,500,000원',
            style: TextStyle(
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
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () => context.go('/submit'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                    foregroundColor: Colors.white,
                  ),
                  child: const Text('응모하기'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: OutlinedButton(
                  onPressed: () => context.go('/how-it-works'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: const Color(0xFF1E3A8A),
                    side: const BorderSide(color: Color(0xFF1E3A8A)),
                  ),
                  child: const Text('어떻게 하는지 궁금해요 >'),
                ),
              ),
            ],
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

  Widget _buildAttendanceCard() {
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
                    '하루 한번 출첵하고 복권 3장 받기',
                    style: TextStyle(fontSize: 16),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => _claimAttendance(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF1E3A8A),
                  ),
                  child: const Text('받기'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStepsRewardCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '오늘 걸은만큼 받는 복권',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildStepRewardItem('1,000 걸음 걷고', 1000, 1, true),
            _buildStepRewardItem('2,000 걸음 걷고', 2000, 1, true),
            _buildStepRewardItem('3,000 걸음 걷고', 3000, 1, false),
            _buildStepRewardItem('4,000 걸음 걷고', 4000, 3, false),
          ],
        ),
      ),
    );
  }

  Widget _buildStepRewardItem(
    String title,
    int steps,
    int rewardCount,
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
              style: TextStyle(color: isAvailable ? Colors.black : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: isAvailable ? () => _claimStepsReward(steps) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey,
            ),
            child: const Text('받기'),
          ),
        ],
      ),
    );
  }

  Widget _buildAdsRewardCard() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              '광고보고 받는 보너스 복권',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            _buildAdRewardItem('1번째 광고보고', 1, 1, true),
            _buildAdRewardItem('2번째 광고보고', 2, 1, false),
            _buildAdRewardItem('3번째 광고보고', 3, 1, false),
            _buildAdRewardItem('4번째 광고보고', 4, 3, false),
          ],
        ),
      ),
    );
  }

  Widget _buildAdRewardItem(
    String title,
    int sequence,
    int rewardCount,
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
              style: TextStyle(color: isAvailable ? Colors.black : Colors.grey),
            ),
          ),
          ElevatedButton(
            onPressed: isAvailable ? () => _claimAdReward(sequence) : null,
            style: ElevatedButton.styleFrom(
              backgroundColor: isAvailable
                  ? const Color(0xFF1E3A8A)
                  : Colors.grey,
            ),
            child: const Text('받기'),
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      child: ElevatedButton(
        onPressed: () => context.go('/submit'),
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF1E3A8A),
          padding: const EdgeInsets.symmetric(vertical: 16),
        ),
        child: const Text(
          '복권 응모하기',
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  void _claimAttendance() {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(const SnackBar(content: Text('출석체크 완료! 3장의 복권을 받았습니다.')));
  }

  void _claimStepsReward(int steps) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text('${steps}걸음 보상 완료! 1장의 복권을 받았습니다.')));
  }

  void _claimAdReward(int sequence) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('${sequence}번째 광고 보상 완료! 1장의 복권을 받았습니다.')),
    );
  }
}
