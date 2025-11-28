import 'package:intl/intl.dart';

/// 날짜 관련 유틸리티
class AppDateUtils {
  /// 오늘 날짜 문자열 (yyyy-MM-dd)
  static String getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }
  
  /// 어제 날짜 문자열 (yyyy-MM-dd)
  static String getYesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }
  
  /// 날짜 문자열로부터 DateTime 파싱
  static DateTime? parseDate(String? dateString) {
    if (dateString == null) return null;
    try {
      return DateFormat('yyyy-MM-dd').parse(dateString);
    } catch (e) {
      return null;
    }
  }
  
  /// 두 날짜가 같은 날인지 확인
  static bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
  
  /// 어제 날짜인지 확인
  static bool isYesterday(DateTime date) {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return isSameDay(date, yesterday);
  }
  
  /// 오늘 날짜인지 확인
  static bool isToday(DateTime date) {
    return isSameDay(date, DateTime.now());
  }
  
  /// 월의 시작일 가져오기
  static DateTime getMonthStart(DateTime date) {
    return DateTime(date.year, date.month, 1);
  }
  
  /// 월의 마지막일 가져오기
  static DateTime getMonthEnd(DateTime date) {
    return DateTime(date.year, date.month + 1, 0);
  }
  
  /// 해당 월의 총 일수 가져오기
  static int getDaysInMonth(DateTime date) {
    return getMonthEnd(date).day;
  }
  
  /// 해당 월의 첫째 날 요일 (1=월요일, 7=일요일)
  static int getFirstWeekdayOfMonth(DateTime date) {
    return getMonthStart(date).weekday;
  }
  
  /// 날짜 범위 내 날짜 목록 생성
  static List<DateTime> getDateRange(DateTime start, DateTime end) {
    final days = <DateTime>[];
    var current = start;
    while (current.isBefore(end) || isSameDay(current, end)) {
      days.add(current);
      current = current.add(const Duration(days: 1));
    }
    return days;
  }
  
  /// 연속 일수 계산 (주어진 날짜 목록에서)
  static int calculateStreak(List<DateTime> completedDates) {
    if (completedDates.isEmpty) return 0;
    
    // 날짜 정렬 (내림차순)
    final sorted = List<DateTime>.from(completedDates)
      ..sort((a, b) => b.compareTo(a));
    
    // 오늘 또는 어제부터 시작해야 연속 인정
    final today = DateTime.now();
    final yesterday = today.subtract(const Duration(days: 1));
    
    final latest = sorted.first;
    if (!isSameDay(latest, today) && !isSameDay(latest, yesterday)) {
      return 0; // 오늘/어제 완료 기록 없으면 연속 끊김
    }
    
    int streak = 1;
    var current = latest;
    
    for (int i = 1; i < sorted.length; i++) {
      final prev = sorted[i];
      final expectedPrev = current.subtract(const Duration(days: 1));
      
      if (isSameDay(prev, expectedPrev)) {
        streak++;
        current = prev;
      } else if (!isSameDay(prev, current)) {
        // 같은 날 중복 기록이 아니면 연속 끊김
        break;
      }
    }
    
    return streak;
  }
  
  /// 이번 달 완료 날짜들 필터링
  static List<DateTime> getThisMonthCompletions(List<DateTime> allCompletions) {
    final now = DateTime.now();
    return allCompletions.where((date) {
      return date.year == now.year && date.month == now.month;
    }).toList();
  }
  
  /// 요일 이름 가져오기 (짧은 형식)
  static String getWeekdayShort(int weekday) {
    const weekdays = ['월', '화', '수', '목', '금', '토', '일'];
    return weekdays[(weekday - 1) % 7];
  }
  
  /// 월 이름 가져오기
  static String getMonthName(int month) {
    const months = [
      '1월', '2월', '3월', '4월', '5월', '6월',
      '7월', '8월', '9월', '10월', '11월', '12월'
    ];
    return months[(month - 1) % 12];
  }
}
