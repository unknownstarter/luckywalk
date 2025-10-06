import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../core/supabase/supabase_client.dart';
import '../core/logging/logger.dart';

/// 홈 화면 데이터 상태
class HomeDataState {
  final bool isLoading;
  final Map<String, dynamic>? currentRound;
  final Map<String, dynamic>? userProfile;
  final String? error;

  const HomeDataState({
    this.isLoading = true,
    this.currentRound,
    this.userProfile,
    this.error,
  });

  HomeDataState copyWith({
    bool? isLoading,
    Map<String, dynamic>? currentRound,
    Map<String, dynamic>? userProfile,
    String? error,
  }) {
    return HomeDataState(
      isLoading: isLoading ?? this.isLoading,
      currentRound: currentRound ?? this.currentRound,
      userProfile: userProfile ?? this.userProfile,
      error: error ?? this.error,
    );
  }
}

/// 홈 화면 데이터 Notifier
class HomeDataNotifier extends StateNotifier<HomeDataState> {
  HomeDataNotifier() : super(const HomeDataState()) {
    _loadHomeData();
  }

  /// 홈 화면 데이터 로드
  Future<void> _loadHomeData() async {
    try {
      state = state.copyWith(isLoading: true, error: null);

      AppLogger.info('Loading home data...');

      // 현재 라운드 정보 조회
      final rounds = await LuckyWalkSupabaseClient.instance.getLotteryRounds(
        limit: 1,
        status: 'scheduled',
      );

      // 라운드 데이터가 없으면 기본 데이터 사용
      if (rounds.isEmpty) {
        AppLogger.warning('No scheduled rounds found, using default data');
      }

      // 사용자 프로필 조회 (임시로 기본값 사용)
      final userProfile = await _getUserProfile();

      state = state.copyWith(
        isLoading: false,
        currentRound: rounds.isNotEmpty ? rounds.first : _getDefaultRound(),
        userProfile: userProfile,
      );

      AppLogger.info('Home data loaded successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to load home data', e, stackTrace);
      state = state.copyWith(
        isLoading: false,
        error: '데이터를 불러오는데 실패했습니다.',
        currentRound: _getDefaultRound(),
        userProfile: _getDefaultUserProfile(),
      );
    }
  }

  /// 사용자 프로필 조회
  Future<Map<String, dynamic>> _getUserProfile() async {
    try {
      // 현재 인증된 사용자 ID 가져오기
      final currentUser =
          LuckyWalkSupabaseClient.instance.client.auth.currentUser;
      if (currentUser == null) {
        AppLogger.warning('No authenticated user found');
        return _getDefaultUserProfile();
      }

      // 실제 사용자 프로필 조회
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('user_profiles')
          .select()
          .eq('uid', currentUser.id)
          .single();

      // Supabase 데이터를 앱 형식으로 변환
      return {
        'user_id': response['uid'],
        'total_tickets': response['total_tickets'] ?? 0,
        'today_steps': await _getTodaySteps(currentUser.id),
        'attendance_checked': await _isAttendanceCheckedToday(currentUser.id),
        'attendance_count': await _getAttendanceCount(currentUser.id),
        'steps_rewards': await _getStepsRewards(currentUser.id),
        'ads_rewards': await _getAdsRewards(currentUser.id),
      };
    } catch (e) {
      AppLogger.error('Failed to get user profile', e);
      return _getDefaultUserProfile();
    }
  }

  /// 오늘 걸음수 조회
  Future<int> _getTodaySteps(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('user_activities')
          .select('activity_data')
          .eq('user_id', userId)
          .eq('activity_type', 'steps')
          .eq('date', today)
          .single();

      return response['activity_data']['steps'] ?? 0;
    } catch (e) {
      AppLogger.error('Failed to get today steps', e);
      return 0;
    }
  }

  /// 오늘 출석체크 여부 확인
  Future<bool> _isAttendanceCheckedToday(String userId) async {
    try {
      final today = DateTime.now().toIso8601String().split('T')[0];
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('daily_progress')
          .select('attendance_checked')
          .eq('user_id', userId)
          .eq('date', today)
          .single();

      return response['attendance_checked'] ?? false;
    } catch (e) {
      AppLogger.error('Failed to check attendance status', e);
      return false;
    }
  }

  /// 출석체크 횟수 조회
  Future<int> _getAttendanceCount(String userId) async {
    try {
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('daily_progress')
          .select('date')
          .eq('user_id', userId)
          .eq('attendance_checked', true)
          .order('date', ascending: false)
          .limit(5);

      return response.length;
    } catch (e) {
      AppLogger.error('Failed to get attendance count', e);
      return 0;
    }
  }

  /// 걸음수 보상 상태 조회
  Future<Map<int, bool>> _getStepsRewards(String userId) async {
    try {
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('user_rewards')
          .select('reward_data')
          .eq('user_id', userId)
          .eq('reward_type', 'steps')
          .eq('is_claimed', true);

      final rewards = <int, bool>{};
      for (final item in response) {
        final steps = item['reward_data']['steps'] as int;
        rewards[steps] = true;
      }

      return rewards;
    } catch (e) {
      AppLogger.error('Failed to get steps rewards', e);
      return <int, bool>{};
    }
  }

  /// 광고 보상 상태 조회
  Future<Map<int, bool>> _getAdsRewards(String userId) async {
    try {
      final response = await LuckyWalkSupabaseClient.instance.client
          .from('user_rewards')
          .select('reward_data')
          .eq('user_id', userId)
          .eq('reward_type', 'ad')
          .eq('is_claimed', true);

      final rewards = <int, bool>{};
      for (final item in response) {
        final sequence = item['reward_data']['sequence'] as int;
        rewards[sequence] = true;
      }

      return rewards;
    } catch (e) {
      AppLogger.error('Failed to get ads rewards', e);
      return <int, bool>{};
    }
  }

  /// 기본 라운드 데이터
  Map<String, dynamic> _getDefaultRound() {
    return {
      'id': 'default_round',
      'round_number': 1,
      'draw_date': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
      'total_prize': 1500000,
      'status': 'scheduled',
      'winning_numbers': null,
      'announcement_date': DateTime.now()
          .add(const Duration(days: 7))
          .toIso8601String(),
    };
  }

  /// 기본 사용자 프로필 데이터
  Map<String, dynamic> _getDefaultUserProfile() {
    return {
      'user_id': 'default_user',
      'total_tickets': 0,
      'today_steps': 0,
      'attendance_checked': false,
      'attendance_count': 0,
      'steps_rewards': <int, bool>{},
      'ads_rewards': <int, bool>{},
    };
  }

  /// 출석체크
  Future<void> checkAttendance() async {
    try {
      AppLogger.info('Checking attendance...');

      // 현재 인증된 사용자 ID 가져오기
      final currentUser =
          LuckyWalkSupabaseClient.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      final today = DateTime.now().toIso8601String().split('T')[0];

      // 실제 출석체크 API 호출
      await LuckyWalkSupabaseClient.instance.client
          .from('daily_progress')
          .upsert({
            'user_id': currentUser.id,
            'date': today,
            'attendance_checked': true,
            'updated_at': DateTime.now().toIso8601String(),
          });

      // 보상 지급 (복권 3장)
      await _grantAttendanceReward(currentUser.id);

      // 상태 업데이트
      final currentProfile = state.userProfile ?? _getDefaultUserProfile();
      final newProfile = Map<String, dynamic>.from(currentProfile);
      newProfile['attendance_checked'] = true;
      newProfile['attendance_count'] =
          (newProfile['attendance_count'] as int) + 1;

      state = state.copyWith(userProfile: newProfile);

      AppLogger.info('Attendance checked successfully');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to check attendance', e, stackTrace);
      rethrow;
    }
  }

  /// 출석체크 보상 지급
  Future<void> _grantAttendanceReward(String userId) async {
    try {
      await LuckyWalkSupabaseClient.instance.client.from('user_rewards').insert(
        {
          'user_id': userId,
          'reward_type': 'attendance',
          'reward_data': {'tickets': 3},
          'tickets_earned': 3,
          'is_claimed': true,
          'earned_at': DateTime.now().toIso8601String(),
        },
      );

      // 사용자 총 티켓 수 업데이트
      await LuckyWalkSupabaseClient.instance.client
          .from('user_profiles')
          .update({
            'total_tickets': LuckyWalkSupabaseClient.instance.client
                .from('user_profiles')
                .select('total_tickets')
                .eq('uid', userId)
                .single()
                .then((response) => (response['total_tickets'] ?? 0) + 3),
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uid', userId);

      AppLogger.info('Attendance reward granted: 3 tickets');
    } catch (e) {
      AppLogger.error('Failed to grant attendance reward', e);
      // 보상 지급 실패해도 출석체크는 성공으로 처리
    }
  }

  /// 걸음수 보상 수령
  Future<void> claimStepsReward(int steps) async {
    try {
      AppLogger.info('Claiming steps reward for $steps steps...');

      // 현재 인증된 사용자 ID 가져오기
      final currentUser =
          LuckyWalkSupabaseClient.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // 걸음수 보상 티켓 수 계산
      final tickets = _getStepsRewardTickets(steps);

      // 실제 걸음수 보상 API 호출
      await LuckyWalkSupabaseClient.instance.client.from('user_rewards').insert(
        {
          'user_id': currentUser.id,
          'reward_type': 'steps',
          'reward_data': {'steps': steps, 'tickets': tickets},
          'tickets_earned': tickets,
          'is_claimed': true,
          'earned_at': DateTime.now().toIso8601String(),
        },
      );

      // 사용자 총 티켓 수 업데이트
      await _updateUserTickets(currentUser.id, tickets);

      // 상태 업데이트
      final currentProfile = state.userProfile ?? _getDefaultUserProfile();
      final newProfile = Map<String, dynamic>.from(currentProfile);
      final stepsRewards = Map<int, bool>.from(
        newProfile['steps_rewards'] as Map<int, bool>,
      );
      stepsRewards[steps] = true;
      newProfile['steps_rewards'] = stepsRewards;

      state = state.copyWith(userProfile: newProfile);

      AppLogger.info('Steps reward claimed successfully: $tickets tickets');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to claim steps reward', e, stackTrace);
      rethrow;
    }
  }

  /// 걸음수별 보상 티켓 수 계산
  int _getStepsRewardTickets(int steps) {
    if (steps >= 10000) return 10;
    if (steps >= 9000) return 5;
    if (steps >= 8000) return 5;
    if (steps >= 7000) return 5;
    if (steps >= 6000) return 3;
    if (steps >= 5000) return 3;
    if (steps >= 4000) return 3;
    if (steps >= 3000) return 1;
    if (steps >= 2000) return 1;
    if (steps >= 1000) return 1;
    return 0;
  }

  /// 광고 보상 수령
  Future<void> claimAdReward(int sequence) async {
    try {
      AppLogger.info('Claiming ad reward for sequence $sequence...');

      // 현재 인증된 사용자 ID 가져오기
      final currentUser =
          LuckyWalkSupabaseClient.instance.client.auth.currentUser;
      if (currentUser == null) {
        throw Exception('User not authenticated');
      }

      // 광고 보상 티켓 수 계산
      final tickets = _getAdRewardTickets(sequence);

      // 실제 광고 보상 API 호출
      await LuckyWalkSupabaseClient.instance.client.from('user_rewards').insert(
        {
          'user_id': currentUser.id,
          'reward_type': 'ad',
          'reward_data': {'sequence': sequence, 'tickets': tickets},
          'tickets_earned': tickets,
          'is_claimed': true,
          'earned_at': DateTime.now().toIso8601String(),
        },
      );

      // 사용자 총 티켓 수 업데이트
      await _updateUserTickets(currentUser.id, tickets);

      // 상태 업데이트
      final currentProfile = state.userProfile ?? _getDefaultUserProfile();
      final newProfile = Map<String, dynamic>.from(currentProfile);
      final adsRewards = Map<int, bool>.from(
        newProfile['ads_rewards'] as Map<int, bool>,
      );
      adsRewards[sequence] = true;
      newProfile['ads_rewards'] = adsRewards;

      state = state.copyWith(userProfile: newProfile);

      AppLogger.info('Ad reward claimed successfully: $tickets tickets');
    } catch (e, stackTrace) {
      AppLogger.error('Failed to claim ad reward', e, stackTrace);
      rethrow;
    }
  }

  /// 광고 시퀀스별 보상 티켓 수 계산
  int _getAdRewardTickets(int sequence) {
    if (sequence >= 10) return 10;
    if (sequence >= 9) return 5;
    if (sequence >= 8) return 5;
    if (sequence >= 7) return 5;
    if (sequence >= 6) return 3;
    if (sequence >= 5) return 3;
    if (sequence >= 4) return 3;
    if (sequence >= 3) return 1;
    if (sequence >= 2) return 1;
    if (sequence >= 1) return 1;
    return 0;
  }

  /// 사용자 티켓 수 업데이트
  Future<void> _updateUserTickets(String userId, int additionalTickets) async {
    try {
      // 현재 총 티켓 수 조회
      final currentResponse = await LuckyWalkSupabaseClient.instance.client
          .from('user_profiles')
          .select('total_tickets')
          .eq('uid', userId)
          .single();

      final currentTickets = currentResponse['total_tickets'] ?? 0;
      final newTotalTickets = currentTickets + additionalTickets;

      // 총 티켓 수 업데이트
      await LuckyWalkSupabaseClient.instance.client
          .from('user_profiles')
          .update({
            'total_tickets': newTotalTickets,
            'updated_at': DateTime.now().toIso8601String(),
          })
          .eq('uid', userId);

      AppLogger.info(
        'User tickets updated: +$additionalTickets = $newTotalTickets',
      );
    } catch (e) {
      AppLogger.error('Failed to update user tickets', e);
      // 티켓 업데이트 실패해도 보상 수령은 성공으로 처리
    }
  }

  /// 데이터 새로고침
  Future<void> refresh() async {
    await _loadHomeData();
  }
}

/// 홈 화면 데이터 Provider
final homeDataProvider = StateNotifierProvider<HomeDataNotifier, HomeDataState>(
  (ref) {
    return HomeDataNotifier();
  },
);
