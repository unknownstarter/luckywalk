import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../providers/mock_data_providers.dart';
import '../../../core/permissions/permission_manager.dart';
import '../../../core/utils/index.dart';
import '../../shared/index.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _permissionsRequested = false;

  @override
  void initState() {
    super.initState();
    _requestPermissions();
  }

  Future<void> _requestPermissions() async {
    if (_permissionsRequested) return;
    _permissionsRequested = true;

    try {
      final permissions = await PermissionManager.requestAllPermissions();

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(
              '권한 요청 완료: 알림 ${permissions['notification']! ? '허용' : '거부'}, '
              '걸음수 ${permissions['activity']! ? '허용' : '거부'}',
            ),
            backgroundColor:
                permissions['notification']! && permissions['activity']!
                ? Colors.green
                : Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('권한 요청 실패: $e'), backgroundColor: Colors.red),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final homeData = ref.watch(mockHomeDataProvider);
    final currentRound = homeData['currentRound'] as MockRound;
    final userProfile = homeData['userProfile'] as MockUserProfile;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F6),
      body: Column(
        children: [
          // 상단 블루 배경 영역
          _buildTopSection(currentRound),

          // 메인 콘텐츠 영역
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: [
                  // 매일 출석체크 복권
                  _buildAttendanceSection(userProfile),
                  const SizedBox(height: 16),

                  // 광고 영역
                  _buildAdBanner(),
                  const SizedBox(height: 16),

                  // 오늘 걸은만큼 받는 복권
                  _buildStepsSection(userProfile),
                  const SizedBox(height: 16),

                  // 광고보고 받는 보너스 복권
                  _buildAdsSection(userProfile),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopSection(MockRound currentRound) {
    return Container(
      height: 435,
      decoration: const BoxDecoration(color: Color(0xFF5DB4FF)),
      child: SafeArea(
        child: Column(
          children: [
            // 상태바
            const SizedBox(height: 44),

            // 앱 이름
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                children: [
                  AppText(
                    'LuckyWalk',
                    style: AppTextStyle.logoMain,
                    color: Colors.white,
                  ),
                  const Spacer(),
                  const Icon(Icons.emoji_events, color: Colors.white, size: 24),
                ],
              ),
            ),

            const SizedBox(height: 16),

            // 로또 정보 카드
            LottoInfoCard(
              roundNumber: '${LottoDateTime.getNextRoundNumber()}회차',
              totalPrize:
                  '${currentRound.totalPrize.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
              announcementTime: LottoDateTime.getAnnouncementTimeString(),
              daysLeft: '${LottoDateTime.getDaysUntilAnnouncement()}일 남음',
              onHowToTap: () {
                context.go('/how-it-works');
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAttendanceSection(MockUserProfile userProfile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '매일 출석체크 복권',
            style: AppTextStyle.title,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),

          RewardCard(
            title: '하루 한번 출첵하고',
            subtitle: '복권 3장 받기 (${userProfile.attendanceCount}/5)',
            icon: Icons.calendar_today,
            buttonText: userProfile.attendanceCount >= 5 ? '완료' : '받기',
            isEnabled: userProfile.attendanceCount < 5,
            onPressed: userProfile.attendanceCount < 5
                ? _handleAttendanceCheck
                : null,
          ),
        ],
      ),
    );
  }

  Widget _buildAdBanner() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      height: 60,
      decoration: BoxDecoration(
        color: const Color(0xFF121313),
        borderRadius: BorderRadius.circular(20),
      ),
      child: const Center(
        child: AppText('광고 영역', style: AppTextStyle.title, color: Colors.red),
      ),
    );
  }

  Widget _buildStepsSection(MockUserProfile userProfile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '오늘 걸은만큼 받는 복권',
            style: AppTextStyle.title,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),

          // 10단계 걸음수 보상
          ..._buildStepsRewards(userProfile),
        ],
      ),
    );
  }

  Widget _buildAdsSection(MockUserProfile userProfile) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFFF0F0F0)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '광고보고 받는 보너스 복권',
            style: AppTextStyle.title,
            color: AppColors.textPrimary,
          ),
          const SizedBox(height: 16),

          // 10단계 광고 보상
          ..._buildAdsRewards(userProfile),
        ],
      ),
    );
  }

  // Helper methods
  List<Widget> _buildStepsRewards(MockUserProfile userProfile) {
    final stepsConfig = [
      {'steps': 1000, 'tickets': 1},
      {'steps': 2000, 'tickets': 1},
      {'steps': 3000, 'tickets': 1},
      {'steps': 4000, 'tickets': 3},
      {'steps': 5000, 'tickets': 3},
      {'steps': 6000, 'tickets': 3},
      {'steps': 7000, 'tickets': 5},
      {'steps': 8000, 'tickets': 5},
      {'steps': 9000, 'tickets': 5},
      {'steps': 10000, 'tickets': 10},
    ];

    return stepsConfig.map((config) {
      final steps = config['steps'] as int;
      final tickets = config['tickets'] as int;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RewardCard(
          title:
              '${steps.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')} 걸음 걷고',
          subtitle: '복권 $tickets장 받기',
          icon: Icons.emoji_events,
          buttonText: _getStepsButtonText(steps, userProfile),
          isEnabled: _isStepsRewardEnabled(steps, userProfile),
          onPressed: _isStepsRewardEnabled(steps, userProfile)
              ? () => _handleStepsReward(steps)
              : null,
        ),
      );
    }).toList();
  }

  List<Widget> _buildAdsRewards(MockUserProfile userProfile) {
    final adsConfig = [
      {'sequence': 1, 'tickets': 1},
      {'sequence': 2, 'tickets': 1},
      {'sequence': 3, 'tickets': 1},
      {'sequence': 4, 'tickets': 3},
      {'sequence': 5, 'tickets': 3},
      {'sequence': 6, 'tickets': 3},
      {'sequence': 7, 'tickets': 5},
      {'sequence': 8, 'tickets': 5},
      {'sequence': 9, 'tickets': 5},
      {'sequence': 10, 'tickets': 10},
    ];

    return adsConfig.map((config) {
      final sequence = config['sequence'] as int;
      final tickets = config['tickets'] as int;

      return Padding(
        padding: const EdgeInsets.only(bottom: 8),
        child: RewardCard(
          title: '${sequence}번째 광고보고',
          subtitle: '복권 $tickets장 받기',
          icon: Icons.card_giftcard,
          buttonText: _getAdsButtonText(sequence, userProfile),
          isEnabled: _isAdsRewardEnabled(sequence, userProfile),
          onPressed: _isAdsRewardEnabled(sequence, userProfile)
              ? () => _handleAdReward(sequence)
              : null,
        ),
      );
    }).toList();
  }

  String _getStepsButtonText(int steps, MockUserProfile userProfile) {
    if (userProfile.stepsRewards[steps] == true) return '완료';
    if (userProfile.todaySteps >= steps) return '받기';
    return '잠김';
  }

  bool _isStepsRewardEnabled(int steps, MockUserProfile userProfile) {
    return userProfile.stepsRewards[steps] != true &&
        userProfile.todaySteps >= steps;
  }

  String _getAdsButtonText(int sequence, MockUserProfile userProfile) {
    if (userProfile.adsRewards[sequence] == true) return '완료';
    if (sequence == 1) return '받기';
    if (userProfile.adsRewards[sequence - 1] == true) return '받기';
    return '잠김';
  }

  bool _isAdsRewardEnabled(int sequence, MockUserProfile userProfile) {
    if (userProfile.adsRewards[sequence] == true) return false;
    if (sequence == 1) return true;
    return userProfile.adsRewards[sequence - 1] == true;
  }

  // Event handlers
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
            content: Text('$steps걸음 보상 완료! 복권을 받았습니다.'),
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
            content: Text('$sequence번째 광고 보상 완료! 복권을 받았습니다.'),
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
