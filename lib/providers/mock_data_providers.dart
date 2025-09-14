import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'dart:math';

import '../core/logging/logger.dart';

// Mock 데이터 모델들
class MockRound {
  final String id;
  final int roundNumber;
  final DateTime drawDate;
  final int totalPrize;
  final String status; // 'scheduled', 'drawn', 'settled'
  final List<int>? winningNumbers;
  final DateTime? announcementDate;

  const MockRound({
    required this.id,
    required this.roundNumber,
    required this.drawDate,
    required this.totalPrize,
    required this.status,
    this.winningNumbers,
    this.announcementDate,
  });
}

class MockUserProfile {
  final String userId;
  final int totalTickets;
  final int todaySteps;
  final bool attendanceChecked;
  final int adsWatchedToday;
  final int maxAdsToday;
  final Map<int, bool> stepsRewards; // step threshold -> claimed
  final Map<int, bool> adsRewards; // ad sequence -> claimed
  final DateTime lastResetDate;

  const MockUserProfile({
    required this.userId,
    required this.totalTickets,
    required this.todaySteps,
    required this.attendanceChecked,
    required this.adsWatchedToday,
    required this.maxAdsToday,
    required this.stepsRewards,
    required this.adsRewards,
    required this.lastResetDate,
  });

  MockUserProfile copyWith({
    int? totalTickets,
    int? todaySteps,
    bool? attendanceChecked,
    int? adsWatchedToday,
    int? maxAdsToday,
    Map<int, bool>? stepsRewards,
    Map<int, bool>? adsRewards,
    DateTime? lastResetDate,
  }) {
    return MockUserProfile(
      userId: userId,
      totalTickets: totalTickets ?? this.totalTickets,
      todaySteps: todaySteps ?? this.todaySteps,
      attendanceChecked: attendanceChecked ?? this.attendanceChecked,
      adsWatchedToday: adsWatchedToday ?? this.adsWatchedToday,
      maxAdsToday: maxAdsToday ?? this.maxAdsToday,
      stepsRewards: stepsRewards ?? this.stepsRewards,
      adsRewards: adsRewards ?? this.adsRewards,
      lastResetDate: lastResetDate ?? this.lastResetDate,
    );
  }
}

class MockTicket {
  final String id;
  final String userId;
  final String roundId;
  final List<int> numbers;
  final DateTime createdAt;
  final int? rank;
  final int? prize;

  const MockTicket({
    required this.id,
    required this.userId,
    required this.roundId,
    required this.numbers,
    required this.createdAt,
    this.rank,
    this.prize,
  });
}

// Mock 데이터 Provider들
final mockCurrentRoundProvider = Provider<MockRound>((ref) {
  final now = DateTime.now();
  final nextSaturday = _getNextSaturday(now);
  
  return MockRound(
    id: 'round_1234',
    roundNumber: 1234,
    drawDate: nextSaturday,
    totalPrize: 1500000,
    status: 'scheduled',
    announcementDate: nextSaturday.add(const Duration(hours: 1)),
  );
});

final mockUserProfileProvider = StateNotifierProvider<MockUserProfileNotifier, MockUserProfile>((ref) {
  return MockUserProfileNotifier();
});

final mockTicketsProvider = StateNotifierProvider<MockTicketsNotifier, List<MockTicket>>((ref) {
  return MockTicketsNotifier();
});

// Mock User Profile Notifier
class MockUserProfileNotifier extends StateNotifier<MockUserProfile> {
  MockUserProfileNotifier() : super(_createInitialProfile()) {
    _initializeMockData();
  }

  static MockUserProfile _createInitialProfile() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    return MockUserProfile(
      userId: 'mock_user_123',
      totalTickets: 1250,
      todaySteps: 7500,
      attendanceChecked: false,
      adsWatchedToday: 3,
      maxAdsToday: 10,
      stepsRewards: {
        1000: true,  // 1k 걸음 완료
        2000: true,  // 2k 걸음 완료
        3000: true,  // 3k 걸음 완료
        4000: false, // 4k 걸음 미완료
        5000: false,
        6000: false,
        7000: false,
        8000: false,
        9000: false,
        10000: false,
      },
      adsRewards: {
        1: true,  // 1번째 광고 완료
        2: true,  // 2번째 광고 완료
        3: true,  // 3번째 광고 완료
        4: false, // 4번째 광고 미완료
        5: false,
        6: false,
        7: false,
        8: false,
        9: false,
        10: false,
      },
      lastResetDate: today,
    );
  }

  void _initializeMockData() {
    AppLogger.info('Mock User Profile initialized');
  }

  // 출석체크
  Future<void> checkAttendance() async {
    if (state.attendanceChecked) {
      throw Exception('이미 출석체크를 완료했습니다.');
    }

    // Mock: 1초 지연
    await Future.delayed(const Duration(seconds: 1));

    state = state.copyWith(
      attendanceChecked: true,
      totalTickets: state.totalTickets + 3, // 출석체크 보상 3장
    );

    AppLogger.info('Attendance checked, received 3 tickets');
  }

  // 걸음수 보상 수령
  Future<void> claimStepsReward(int steps) async {
    if (!state.stepsRewards.containsKey(steps)) {
      throw Exception('유효하지 않은 걸음수 임계값입니다.');
    }

    if (state.stepsRewards[steps] == true) {
      throw Exception('이미 수령한 보상입니다.');
    }

    if (state.todaySteps < steps) {
      throw Exception('아직 ${steps}걸음을 달성하지 못했습니다.');
    }

    // Mock: 1초 지연
    await Future.delayed(const Duration(seconds: 1));

    final newStepsRewards = Map<int, bool>.from(state.stepsRewards);
    newStepsRewards[steps] = true;

    int rewardTickets = 1;
    if (steps >= 4000) rewardTickets = 3; // 4k 이상은 3장

    state = state.copyWith(
      stepsRewards: newStepsRewards,
      totalTickets: state.totalTickets + rewardTickets,
    );

    AppLogger.info('Steps reward claimed: ${steps} steps -> ${rewardTickets} tickets');
  }

  // 광고 보상 수령
  Future<void> claimAdReward(int sequence) async {
    if (!state.adsRewards.containsKey(sequence)) {
      throw Exception('유효하지 않은 광고 순서입니다.');
    }

    if (state.adsRewards[sequence] == true) {
      throw Exception('이미 수령한 보상입니다.');
    }

    if (sequence > 1 && state.adsRewards[sequence - 1] != true) {
      throw Exception('이전 광고를 먼저 시청해야 합니다.');
    }

    // Mock: 2초 지연 (광고 시청 시뮬레이션)
    await Future.delayed(const Duration(seconds: 2));

    final newAdsRewards = Map<int, bool>.from(state.adsRewards);
    newAdsRewards[sequence] = true;

    int rewardTickets = 1;
    if (sequence >= 4 && sequence <= 6) rewardTickets = 3; // 4-6번째는 3장
    if (sequence >= 7 && sequence <= 9) rewardTickets = 5; // 7-9번째는 5장
    if (sequence == 10) rewardTickets = 10; // 10번째는 10장

    state = state.copyWith(
      adsRewards: newAdsRewards,
      adsWatchedToday: state.adsWatchedToday + 1,
      totalTickets: state.totalTickets + rewardTickets,
    );

    AppLogger.info('Ad reward claimed: sequence ${sequence} -> ${rewardTickets} tickets');
  }

  // 복권 응모
  Future<void> submitTickets(int ticketCount) async {
    if (ticketCount < 100) {
      throw Exception('최소 100장부터 응모할 수 있습니다.');
    }

    if (ticketCount % 100 != 0) {
      throw Exception('100장 단위로 응모해야 합니다.');
    }

    if (state.totalTickets < ticketCount) {
      throw Exception('보유 복권이 부족합니다.');
    }

    // Mock: 2초 지연
    await Future.delayed(const Duration(seconds: 2));

    state = state.copyWith(
      totalTickets: state.totalTickets - ticketCount,
    );

    AppLogger.info('Tickets submitted: ${ticketCount} tickets');
  }

  // 걸음수 업데이트
  void updateSteps(int steps) {
    state = state.copyWith(todaySteps: steps);
    AppLogger.info('Steps updated: ${steps}');
  }

  // 일일 리셋 (자정에 호출)
  void dailyReset() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (state.lastResetDate.isBefore(today)) {
      state = state.copyWith(
        todaySteps: 0,
        attendanceChecked: false,
        adsWatchedToday: 0,
        stepsRewards: {
          1000: false,
          2000: false,
          3000: false,
          4000: false,
          5000: false,
          6000: false,
          7000: false,
          8000: false,
          9000: false,
          10000: false,
        },
        adsRewards: {
          1: false,
          2: false,
          3: false,
          4: false,
          5: false,
          6: false,
          7: false,
          8: false,
          9: false,
          10: false,
        },
        lastResetDate: today,
      );
      
      AppLogger.info('Daily reset completed');
    }
  }
}

// Mock Tickets Notifier
class MockTicketsNotifier extends StateNotifier<List<MockTicket>> {
  MockTicketsNotifier() : super([]) {
    _initializeMockTickets();
  }

  void _initializeMockTickets() {
    // Mock 응모 내역 생성
    final mockTickets = <MockTicket>[
      MockTicket(
        id: 'ticket_1',
        userId: 'mock_user_123',
        roundId: 'round_1233',
        numbers: [1, 7, 15, 23, 31, 45],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        rank: 4,
        prize: null,
      ),
      MockTicket(
        id: 'ticket_2',
        userId: 'mock_user_123',
        roundId: 'round_1233',
        numbers: [3, 12, 18, 25, 33, 42],
        createdAt: DateTime.now().subtract(const Duration(days: 7)),
        rank: null,
        prize: null,
      ),
      MockTicket(
        id: 'ticket_3',
        userId: 'mock_user_123',
        roundId: 'round_1234',
        numbers: [5, 14, 21, 28, 35, 44],
        createdAt: DateTime.now().subtract(const Duration(days: 2)),
        rank: null,
        prize: null,
      ),
    ];

    state = mockTickets;
    AppLogger.info('Mock tickets initialized: ${mockTickets.length} tickets');
  }

  // 새 복권 응모
  void addTickets(String roundId, int ticketCount) {
    final newTickets = <MockTicket>[];
    final random = Random();

    for (int i = 0; i < ticketCount; i++) {
      final numbers = <int>[];
      while (numbers.length < 6) {
        final number = random.nextInt(45) + 1;
        if (!numbers.contains(number)) {
          numbers.add(number);
        }
      }
      numbers.sort();

      newTickets.add(MockTicket(
        id: 'ticket_${DateTime.now().millisecondsSinceEpoch}_$i',
        userId: 'mock_user_123',
        roundId: roundId,
        numbers: numbers,
        createdAt: DateTime.now(),
      ));
    }

    state = [...state, ...newTickets];
    AppLogger.info('Added ${ticketCount} tickets for round $roundId');
  }

  // 특정 회차의 응모 내역 조회
  List<MockTicket> getTicketsByRound(String roundId) {
    return state.where((ticket) => ticket.roundId == roundId).toList();
  }

  // 당첨 결과 업데이트
  void updateTicketResults(String roundId, List<int> winningNumbers) {
    final updatedTickets = state.map((ticket) {
      if (ticket.roundId == roundId) {
        final matchedCount = _countMatchedNumbers(ticket.numbers, winningNumbers);
        final rank = _getRankFromMatchedCount(matchedCount);
        final prize = _getPrizeFromRank(rank);

        return MockTicket(
          id: ticket.id,
          userId: ticket.userId,
          roundId: ticket.roundId,
          numbers: ticket.numbers,
          createdAt: ticket.createdAt,
          rank: rank,
          prize: prize,
        );
      }
      return ticket;
    }).toList();

    state = updatedTickets;
    AppLogger.info('Updated ticket results for round $roundId');
  }

  int _countMatchedNumbers(List<int> userNumbers, List<int> winningNumbers) {
    int count = 0;
    for (int number in userNumbers) {
      if (winningNumbers.contains(number)) {
        count++;
      }
    }
    return count;
  }

  int? _getRankFromMatchedCount(int matchedCount) {
    switch (matchedCount) {
      case 6: return 1; // 1등
      case 5: return 2; // 2등 (보너스 번호 고려 안함)
      case 4: return 3; // 3등
      case 3: return 4; // 4등
      case 2: return 5; // 5등
      default: return null; // 미당첨
    }
  }

  int? _getPrizeFromRank(int? rank) {
    switch (rank) {
      case 1: return 1000000; // 1등 100만원
      case 2: return 500000;  // 2등 50만원
      case 3: return null;    // 3등은 복권 50장 (별도 처리)
      case 4: return null;    // 4등은 복권 10장 (별도 처리)
      case 5: return null;    // 5등은 복권 5장 (별도 처리)
      default: return null;
    }
  }
}

// 유틸리티 함수들
DateTime _getNextSaturday(DateTime from) {
  final daysUntilSaturday = (6 - from.weekday) % 7;
  if (daysUntilSaturday == 0) {
    return from.add(const Duration(days: 7));
  }
  return from.add(Duration(days: daysUntilSaturday));
}

// Provider 조합
final mockHomeDataProvider = Provider<Map<String, dynamic>>((ref) {
  final currentRound = ref.watch(mockCurrentRoundProvider);
  final userProfile = ref.watch(mockUserProfileProvider);
  final tickets = ref.watch(mockTicketsProvider);

  return {
    'currentRound': currentRound,
    'userProfile': userProfile,
    'recentTickets': tickets.take(3).toList(),
  };
});
