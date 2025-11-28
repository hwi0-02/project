/// 연속 달성 모델
class Streak {
  final int count;
  final DateTime? lastCompletedDate;

  Streak({
    this.count = 0,
    this.lastCompletedDate,
  });

  /// 연속 달성 증가
  Streak increment() {
    return Streak(
      count: count + 1,
      lastCompletedDate: DateTime.now(),
    );
  }

  /// 연속 달성 리셋
  Streak reset() {
    return Streak(
      count: 0,
      lastCompletedDate: null,
    );
  }

  /// 오늘 연속 달성 유지 가능 여부
  bool canContinueStreak() {
    if (lastCompletedDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );

    // 어제 완료했으면 연속 달성 유지 가능
    final difference = today.difference(lastDate).inDays;
    return difference <= 1;
  }

  /// 오늘 이미 완료했는지 확인
  bool isCompletedToday() {
    if (lastCompletedDate == null) return false;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastCompletedDate!.year,
      lastCompletedDate!.month,
      lastCompletedDate!.day,
    );

    return today.isAtSameMomentAs(lastDate);
  }

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'count': count,
      'lastCompletedDate': lastCompletedDate?.toIso8601String(),
    };
  }

  /// JSON 역직렬화
  factory Streak.fromJson(Map<String, dynamic> json) {
    return Streak(
      count: json['count'] as int? ?? 0,
      lastCompletedDate: json['lastCompletedDate'] != null
          ? DateTime.parse(json['lastCompletedDate'] as String)
          : null,
    );
  }

  @override
  String toString() {
    return 'Streak(count: $count, lastCompleted: $lastCompletedDate)';
  }
}
