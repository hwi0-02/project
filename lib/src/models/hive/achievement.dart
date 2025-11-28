import 'package:hive/hive.dart';

part 'achievement.g.dart';

/// 업적 타입
@HiveType(typeId: 13)
enum AchievementType {
  @HiveField(0)
  streak, // 연속 출석

  @HiveField(1)
  draw, // 뽑기 횟수

  @HiveField(2)
  gacha, // 가챠 횟수

  @HiveField(3)
  level, // 펫 레벨

  @HiveField(4)
  collection, // 아이템 수집

  @HiveField(5)
  special, // 특별 업적
}

/// 업적 정의
@HiveType(typeId: 14)
class Achievement extends HiveObject {
  /// 고유 ID
  @HiveField(0)
  final String id;

  /// 업적 이름
  @HiveField(1)
  final String name;

  /// 업적 설명
  @HiveField(2)
  final String description;

  /// 업적 타입
  @HiveField(3)
  final AchievementType type;

  /// 달성 조건 값
  @HiveField(4)
  final int targetValue;

  /// 보상 코인
  @HiveField(5)
  final int rewardCoins;

  /// 아이콘 경로
  @HiveField(6)
  final String iconPath;

  /// 숨김 업적 여부
  @HiveField(7)
  final bool isHidden;

  Achievement({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.targetValue,
    required this.rewardCoins,
    required this.iconPath,
    this.isHidden = false,
  });
}

/// 사용자 업적 진행 상황
@HiveType(typeId: 15)
class UserAchievement extends HiveObject {
  /// 업적 ID
  @HiveField(0)
  final String achievementId;

  /// 현재 진행 값
  @HiveField(1)
  int currentValue;

  /// 달성 여부
  @HiveField(2)
  bool isCompleted;

  /// 보상 수령 여부
  @HiveField(3)
  bool isRewardClaimed;

  /// 달성 일시
  @HiveField(4)
  DateTime? completedAt;

  UserAchievement({
    required this.achievementId,
    this.currentValue = 0,
    this.isCompleted = false,
    this.isRewardClaimed = false,
    this.completedAt,
  });

  /// 진행 업데이트
  void updateProgress(int value, int targetValue) {
    currentValue = value;
    if (currentValue >= targetValue && !isCompleted) {
      isCompleted = true;
      completedAt = DateTime.now();
    }
  }
}

/// 뱃지 데이터
@HiveType(typeId: 16)
class Badge extends HiveObject {
  /// 고유 ID
  @HiveField(0)
  final String id;

  /// 뱃지 이름
  @HiveField(1)
  final String name;

  /// 뱃지 설명
  @HiveField(2)
  final String description;

  /// 아이콘 경로
  @HiveField(3)
  final String iconPath;

  /// 획득 조건 (업적 ID)
  @HiveField(4)
  final String? achievementId;

  /// 특별 조건 설명
  @HiveField(5)
  final String? specialCondition;

  Badge({
    required this.id,
    required this.name,
    required this.description,
    required this.iconPath,
    this.achievementId,
    this.specialCondition,
  });
}

/// 사용자 업적 관리
@HiveType(typeId: 17)
class UserAchievementData extends HiveObject {
  /// 업적 진행 목록
  @HiveField(0)
  List<UserAchievement> achievements;

  /// 획득한 뱃지 ID 목록
  @HiveField(1)
  List<String> earnedBadges;

  /// 현재 표시 뱃지 ID
  @HiveField(2)
  String? displayBadgeId;

  UserAchievementData({
    List<UserAchievement>? achievements,
    List<String>? earnedBadges,
    this.displayBadgeId,
  })  : achievements = achievements ?? [],
        earnedBadges = earnedBadges ?? [];

  /// 업적 진행 조회
  UserAchievement? getProgress(String achievementId) {
    return achievements.where((a) => a.achievementId == achievementId).firstOrNull;
  }

  /// 업적 진행 업데이트
  void updateAchievement(String achievementId, int value, int targetValue) {
    var progress = getProgress(achievementId);
    if (progress == null) {
      progress = UserAchievement(achievementId: achievementId);
      achievements.add(progress);
    }
    progress.updateProgress(value, targetValue);
  }

  /// 뱃지 획득
  void earnBadge(String badgeId) {
    if (!earnedBadges.contains(badgeId)) {
      earnedBadges.add(badgeId);
    }
  }

  /// 뱃지 보유 여부
  bool hasBadge(String badgeId) => earnedBadges.contains(badgeId);
}
