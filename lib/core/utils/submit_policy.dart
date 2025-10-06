import 'lotto_datetime.dart';

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
    return LottoDateTime.getNextSubmissionDeadline().difference(LottoDateTime.nowKorea);
  }
  
  /// 응모 마감까지 남은 시간 (문자열)
  static String getTimeUntilDeadlineString() {
    final duration = getTimeUntilDeadline();
    final days = duration.inDays;
    final hours = duration.inHours % 24;
    final minutes = duration.inMinutes % 60;
    
    if (days > 0) {
      return '${days}일 ${hours}시간 ${minutes}분';
    } else if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
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
}
