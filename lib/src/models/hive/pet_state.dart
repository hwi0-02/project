import 'package:hive/hive.dart';

part 'pet_state.g.dart';

/// 펫 상태 모델 - 다마고치 시스템의 핵심 데이터
/// 기획서2.md 기반: 포만감/애정도 시간 감소, 레벨업 시스템
@HiveType(typeId: 0)
class PetStateModel extends HiveObject {
  /// 포만감 (0-100, 시간당 -5)
  @HiveField(0)
  int hungerPoint;

  /// 애정도 (0-100, 시간당 -3)
  @HiveField(1)
  int moodPoint;

  /// 마지막 접속 시간 (시간 감소 계산용)
  @HiveField(2)
  DateTime lastAccessTime;

  /// 펫 레벨 (경험치 누적으로 레벨업)
  @HiveField(3)
  int level;

  /// 현재 경험치
  @HiveField(4)
  int experience;

  /// 연속 출석 일수
  @HiveField(5)
  int streakCount;

  /// 장착된 아이템 ID 목록
  @HiveField(6)
  List<String> equippedItems;

  /// 오늘 쓰다듬기 횟수
  @HiveField(7)
  int todayPetCount;

  /// 마지막 쓰다듬기 날짜
  @HiveField(8)
  DateTime? lastPetDate;

  /// 마지막 출석 체크 날짜
  @HiveField(9)
  DateTime? lastStreakDate;

  /// 펫 이름
  @HiveField(10)
  String petName;

  /// 펫 타입 (기본, 희귀, 전설 등)
  @HiveField(11)
  String petType;

  PetStateModel({
    this.hungerPoint = 100,
    this.moodPoint = 100,
    DateTime? lastAccessTime,
    this.level = 1,
    this.experience = 0,
    this.streakCount = 0,
    List<String>? equippedItems,
    this.todayPetCount = 0,
    this.lastPetDate,
    this.lastStreakDate,
    this.petName = '뽑기펫',
    this.petType = 'default',
  })  : lastAccessTime = lastAccessTime ?? DateTime.now(),
        equippedItems = equippedItems ?? [];

  /// 시간 경과에 따른 상태 감소 적용
  /// hungerPoint: 시간당 -5
  /// moodPoint: 시간당 -3
  void applyTimeDecay() {
    final now = DateTime.now();
    final hoursPassed = now.difference(lastAccessTime).inHours;

    if (hoursPassed > 0) {
      hungerPoint = (hungerPoint - (hoursPassed * 5)).clamp(0, 100);
      moodPoint = (moodPoint - (hoursPassed * 3)).clamp(0, 100);
      lastAccessTime = now;
    }
  }

  /// 밥 주기 (뽑기 완료 시 호출)
  /// 포만감 +20, 경험치 +10
  void feed() {
    hungerPoint = (hungerPoint + 20).clamp(0, 100);
    addExperience(10);
    lastAccessTime = DateTime.now();
  }

  /// 쓰다듬기 (하루 최대 5회)
  /// 애정도 +10, 경험치 +5
  bool pet() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    // 날짜가 바뀌면 카운트 리셋
    if (lastPetDate == null ||
        DateTime(lastPetDate!.year, lastPetDate!.month, lastPetDate!.day) !=
            today) {
      todayPetCount = 0;
      lastPetDate = now;
    }

    // 하루 최대 5회
    if (todayPetCount >= 5) {
      return false;
    }

    todayPetCount++;
    moodPoint = (moodPoint + 10).clamp(0, 100);
    addExperience(5);
    lastAccessTime = now;
    return true;
  }

  /// 경험치 추가 및 레벨업 체크
  /// 레벨업 필요 경험치: level * 100
  void addExperience(int exp) {
    experience += exp;
    final requiredExp = level * 100;

    while (experience >= requiredExp) {
      experience -= requiredExp;
      level++;
    }
  }

  /// 출석 체크 및 연속 출석 업데이트
  bool checkAndUpdateStreak() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastStreakDate == null) {
      streakCount = 1;
      lastStreakDate = now;
      return true;
    }

    final lastDate = DateTime(
      lastStreakDate!.year,
      lastStreakDate!.month,
      lastStreakDate!.day,
    );

    if (lastDate == today) {
      return false; // 이미 오늘 체크함
    }

    final yesterday = today.subtract(const Duration(days: 1));
    if (lastDate == yesterday) {
      streakCount++;
    } else {
      streakCount = 1; // 연속 끊김
    }

    lastStreakDate = now;
    return true;
  }

  /// 펫이 배고픈 상태인지 (포만감 30 이하)
  bool get isHungry => hungerPoint <= 30;

  /// 펫이 삐친 상태인지 (애정도 30 이하)
  bool get isSulky => moodPoint <= 30;

  /// 펫 행복도 (포만감 + 애정도 평균)
  int get happiness => ((hungerPoint + moodPoint) / 2).round();

  /// 다음 레벨까지 필요한 경험치
  int get expToNextLevel => (level * 100) - experience;

  /// 레벨업 진행률 (0.0 ~ 1.0)
  double get levelProgress => experience / (level * 100);
}
