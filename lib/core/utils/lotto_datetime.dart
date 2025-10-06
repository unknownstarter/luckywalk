import 'package:intl/intl.dart';

/// 한국 로또 발표 시간 관련 유틸리티
class LottoDateTime {
  // 한국 시간대 (UTC+9)
  static const int koreaTimeZoneOffset = 9;

  // 로또 발표 시간: 매주 토요일 밤 9시 (한국시간)
  static const int announcementHour = 21; // 9 PM
  static const int announcementMinute = 0;

  // 응모 마감 시간: 매주 토요일 오후 8시 30분 (한국시간)
  static const int submissionDeadlineHour = 20; // 8 PM
  static const int submissionDeadlineMinute = 30; // 30분

  /// 현재 한국 시간을 반환
  static DateTime get nowKorea {
    final utcNow = DateTime.now().toUtc();
    return utcNow.add(const Duration(hours: koreaTimeZoneOffset));
  }

  /// 다음 토요일 밤 9시 (발표 시간)을 계산
  static DateTime getNextAnnouncementTime() {
    final now = nowKorea;

    // 현재 요일 (1=월요일, 7=일요일)
    final currentWeekday = now.weekday;

    // 토요일까지 남은 일수 계산 (토요일 = 6)
    int daysUntilSaturday = (6 - currentWeekday) % 7;
    if (daysUntilSaturday == 0) {
      // 오늘이 토요일인 경우
      final todayAnnouncement = DateTime(
        now.year,
        now.month,
        now.day,
        announcementHour,
        announcementMinute,
      );

      // 오늘 발표 시간이 지났으면 다음 주 토요일
      if (now.isAfter(todayAnnouncement)) {
        daysUntilSaturday = 7;
      }
    }

    final nextSaturday = now.add(Duration(days: daysUntilSaturday));
    return DateTime(
      nextSaturday.year,
      nextSaturday.month,
      nextSaturday.day,
      announcementHour,
      announcementMinute,
    );
  }

  /// 다음 토요일 오후 8시 30분 (응모 마감 시간)을 계산
  static DateTime getNextSubmissionDeadline() {
    final announcementTime = getNextAnnouncementTime();
    return DateTime(
      announcementTime.year,
      announcementTime.month,
      announcementTime.day,
      submissionDeadlineHour,
      submissionDeadlineMinute,
    );
  }

  /// 현재 응모 가능 여부 확인
  static bool get canSubmitNow {
    final now = nowKorea;
    final deadline = getNextSubmissionDeadline();
    return now.isBefore(deadline);
  }

  /// 다음 발표까지 남은 시간을 "n일 n시간 n분" 형식으로 반환
  static String getTimeUntilAnnouncement() {
    final now = nowKorea;
    final announcement = getNextAnnouncementTime();

    final difference = announcement.difference(now);
    final days = difference.inDays;
    final hours = difference.inHours % 24;
    final minutes = difference.inMinutes % 60;

    if (days > 0) {
      return '${days}일 ${hours}시간 ${minutes}분';
    } else if (hours > 0) {
      return '${hours}시간 ${minutes}분';
    } else {
      return '${minutes}분';
    }
  }

  /// 다음 발표까지 남은 일수만 반환
  static int getDaysUntilAnnouncement() {
    final now = nowKorea;
    final announcement = getNextAnnouncementTime();
    return announcement.difference(now).inDays;
  }

  /// 발표 예정 시간을 "YYYY.MM.DD 오후 9시" 형식으로 반환
  static String getAnnouncementTimeString() {
    final announcement = getNextAnnouncementTime();
    final formatter = DateFormat('yyyy.MM.dd');
    return '${formatter.format(announcement)} 오후 9시';
  }

  /// 응모 마감 시간을 "YYYY.MM.DD 오후 8시 30분" 형식으로 반환
  static String getSubmissionDeadlineString() {
    final deadline = getNextSubmissionDeadline();
    final formatter = DateFormat('yyyy.MM.dd');
    return '${formatter.format(deadline)} 오후 8시 30분';
  }

  /// 현재 회차 번호 계산 (2024년 1월 6일 1회차 기준)
  static int getCurrentRoundNumber() {
    final now = nowKorea;
    final firstRoundDate = DateTime(2024, 1, 6); // 2024년 1월 6일 1회차
    final weeksSinceFirstRound = now.difference(firstRoundDate).inDays ~/ 7;
    return weeksSinceFirstRound + 1;
  }

  /// 다음 회차 번호 계산
  static int getNextRoundNumber() {
    return getCurrentRoundNumber() + 1;
  }
}
