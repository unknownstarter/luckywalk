import 'lotto_datetime.dart';
import 'lotto_generator.dart';

class SubmitPolicy {
  // 최소/최대 응모 수량
  static const int minTickets = 100;
  static const int maxTickets = 10000;

  // 응모 단위 (100장 단위)
  static const int ticketUnit = 100;

  // 응모 마감 시간 (토요일 오후 8시 30분)
  static const int deadlineHour = 20;
  static const int deadlineMinute = 30;

  /// 응모 가능 여부 확인
  static bool canSubmit() {
    return LottoDateTime.canSubmitNow;
  }

  /// 응모 마감까지 남은 시간
  static Duration getTimeUntilDeadline() {
    return LottoDateTime.getNextSubmissionDeadline().difference(
      LottoDateTime.nowKorea,
    );
  }

  /// 응모 마감까지 남은 시간 (문자열)
  static String getTimeUntilDeadlineString() {
    final duration = getTimeUntilDeadline();
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;

    if (days > 0) {
      return '$days일 $hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간 $minutes분';
    } else {
      return '$minutes분';
    }
  }

  /// 응모 수량 유효성 검증
  static bool isValidTicketCount(int count) {
    return count >= minTickets &&
        count <= maxTickets &&
        count % ticketUnit == 0;
  }

  /// 응모 수량 정규화 (100장 단위로 조정)
  static int normalizeTicketCount(int count) {
    if (count < minTickets) return minTickets;
    if (count > maxTickets) return maxTickets;
    return (count ~/ ticketUnit) * ticketUnit;
  }

  /// 응모 가능한 최대 수량
  static int getMaxAvailableTickets(int userTicketBalance) {
    final maxByBalance = (userTicketBalance ~/ ticketUnit) * ticketUnit;
    return maxByBalance < minTickets ? 0 : maxByBalance;
  }

  /// 응모 수량별 예상 비용 (티켓)
  static int getTicketCost(int count) {
    return count;
  }

  /// 응모 수량별 예상 당첨 확률 (1등)
  static double getWinningProbability(int count) {
    // 로또 6/45 1등 당첨 확률: 1/8,145,060
    const double singleTicketProbability = 1.0 / 8145060.0;
    return singleTicketProbability * count;
  }

  /// 응모 수량별 예상 당첨 확률 (문자열)
  static String getWinningProbabilityString(int count) {
    final probability = getWinningProbability(count);
    if (probability < 0.0001) {
      return '${(probability * 10000).toStringAsFixed(2)}만분의 1';
    } else if (probability < 0.01) {
      return '${(probability * 100).toStringAsFixed(2)}%';
    } else {
      return '${(probability * 100).toStringAsFixed(1)}%';
    }
  }

  /// 응모 완료 기준: 실제 응모 버튼을 눌렀을 때
  /// 이 시점에서 시간을 다시 한번 검증
  static bool canSubmitAtCompletion() {
    return LottoDateTime.canSubmitNow;
  }

  /// 응모 완료 시점의 시간 검증
  /// true: 응모 가능, false: 시간 초과
  static bool validateSubmissionTime() {
    final now = LottoDateTime.nowKorea;
    final deadline = LottoDateTime.getNextSubmissionDeadline();

    // 현재 시간이 마감 시간보다 이전이면 응모 가능
    return now.isBefore(deadline);
  }

  /// 시간 초과 시 사용자에게 보여줄 메시지
  static String getTimeExceededMessage() {
    final nextDeadline = LottoDateTime.getNextSubmissionDeadline();

    return '응모 마감 시간이 지났습니다.\n다음 회차(${LottoDateTime.getNextRoundNumber()}회차) 응모는 ${nextDeadline.toString().substring(0, 16)}부터 가능합니다.';
  }

  /// 응모 완료까지 남은 시간 (실시간)
  static String getRemainingTimeString() {
    final duration = getTimeUntilDeadline();

    if (duration.isNegative) {
      return '응모 마감';
    }

    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    final seconds = duration.inSeconds % 60;

    if (days > 0) {
      return '$days일 $hours시간 $minutes분';
    } else if (hours > 0) {
      return '$hours시간 $minutes분';
    } else if (minutes > 0) {
      return '$minutes분 $seconds초';
    } else {
      return '$seconds초';
    }
  }

  /// 응모 완료 시점에서의 최종 검증
  /// 모든 조건을 만족하는지 확인
  static Map<String, dynamic> validateFinalSubmission({
    required int ticketCount,
    required List<List<int>> tickets,
  }) {
    final results = <String, dynamic>{
      'isValid': true,
      'errors': <String>[],
      'warnings': <String>[],
    };

    // 1. 시간 검증
    if (!validateSubmissionTime()) {
      results['isValid'] = false;
      results['errors'].add('응모 마감 시간이 지났습니다.');
    }

    // 2. 수량 검증
    if (!isValidTicketCount(ticketCount)) {
      results['isValid'] = false;
      results['errors'].add('응모 수량이 올바르지 않습니다.');
    }

    // 3. 복권 번호 검증
    for (int i = 0; i < tickets.length; i++) {
      if (!LottoGenerator.isValidNumbers(tickets[i])) {
        results['isValid'] = false;
        results['errors'].add('${i + 1}번째 복권의 번호가 올바르지 않습니다.');
      }
    }

    // 4. 경고사항
    if (ticketCount > 1000) {
      results['warnings'].add('대량 응모 시 당첨 확률이 높아집니다.');
    }

    return results;
  }
}
