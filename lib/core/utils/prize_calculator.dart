import '../../../core/logging/logger.dart';

/// 당첨금 계산 유틸리티
/// 생성일: 2025-01-17 03:30:00 KST
/// 설명: 당첨금 분배 정책에 따른 계산 로직

class PrizeCalculator {
  /// 1등 당첨금 계산
  /// 총 당첨금의 75%를 1등 당첨자 수로 나눔
  static int calculateFirstPrize(int totalPrize, int firstPlaceWinners) {
    if (firstPlaceWinners <= 0) return 0;
    return (totalPrize * 0.75 / firstPlaceWinners).round();
  }

  /// 2등 당첨금 계산
  /// 총 당첨금의 25%를 2등 당첨자 수로 나눔
  static int calculateSecondPrize(int totalPrize, int secondPlaceWinners) {
    if (secondPlaceWinners <= 0) return 0;
    return (totalPrize * 0.25 / secondPlaceWinners).round();
  }

  /// 3등 보상 (복권 50장)
  static int getThirdPrizeTickets() => 50;

  /// 4등 보상 (복권 20장)
  static int getFourthPrizeTickets() => 20;

  /// 5등 보상 (복권 10장)
  static int getFifthPrizeTickets() => 10;

  /// 등수별 보상 계산
  static Map<String, dynamic> calculatePrizeByRank({
    required int totalPrize,
    required int rank,
    required int winners,
  }) {
    switch (rank) {
      case 1:
        return {
          'type': 'cash',
          'amount': calculateFirstPrize(totalPrize, winners),
          'description': '${calculateFirstPrize(totalPrize, winners).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
        };
      case 2:
        return {
          'type': 'cash',
          'amount': calculateSecondPrize(totalPrize, winners),
          'description': '${calculateSecondPrize(totalPrize, winners).toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (Match m) => '${m[1]},')}원',
        };
      case 3:
        return {
          'type': 'tickets',
          'amount': getThirdPrizeTickets(),
          'description': '복권 ${getThirdPrizeTickets()}장',
        };
      case 4:
        return {
          'type': 'tickets',
          'amount': getFourthPrizeTickets(),
          'description': '복권 ${getFourthPrizeTickets()}장',
        };
      case 5:
        return {
          'type': 'tickets',
          'amount': getFifthPrizeTickets(),
          'description': '복권 ${getFifthPrizeTickets()}장',
        };
      default:
        return {
          'type': 'none',
          'amount': 0,
          'description': '꽝',
        };
    }
  }

  /// 전체 당첨금 분배 정보
  static Map<String, dynamic> getPrizeDistribution(int totalPrize) {
    return {
      'total_prize': totalPrize,
      'first_prize_per_person': calculateFirstPrize(totalPrize, 1),
      'second_prize_per_person': calculateSecondPrize(totalPrize, 1),
      'third_prize_tickets': getThirdPrizeTickets(),
      'fourth_prize_tickets': getFourthPrizeTickets(),
      'fifth_prize_tickets': getFifthPrizeTickets(),
      'distribution': {
        '1등': '총 당첨금의 75% ÷ 1등 당첨자 수',
        '2등': '총 당첨금의 25% ÷ 2등 당첨자 수',
        '3등': '복권 50장 (고정)',
        '4등': '복권 20장 (고정)',
        '5등': '복권 10장 (고정)',
      },
    };
  }

  /// 당첨금 포맷팅
  static String formatPrize(int amount) {
    return amount.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  /// 로그 기록
  static void logPrizeCalculation({
    required int totalPrize,
    required int rank,
    required int winners,
    required Map<String, dynamic> result,
  }) {
    AppLogger.info(
      '당첨금 계산: $rank등, 총 당첨금: ${formatPrize(totalPrize)}원, '
      '당첨자: $winners명, 결과: ${result['description']}',
    );
  }
}
