import '../constants/pet_levels.dart';

/// 펫 모델 - 펫 상태 및 아이템 관리
class Pet {
  final int level;
  final int experience; // 총 완료 횟수
  final int streakCount; // 연속 달성 일수
  final PetState state;
  final List<PetItem> equippedItems;

  Pet({
    this.level = 1,
    this.experience = 0,
    this.streakCount = 0,
    this.state = PetState.waiting,
    this.equippedItems = const [],
  });

  /// 완료 횟수 증가 및 레벨 계산
  Pet addExperience() {
    final newExperience = experience + 1;
    final newLevel = PetLevels.calculateLevel(newExperience);
    final unlockedItems = PetLevels.getUnlockedItems(newLevel, streakCount);

    return Pet(
      level: newLevel,
      experience: newExperience,
      streakCount: streakCount,
      state: state,
      equippedItems: unlockedItems,
    );
  }

  /// 연속 달성 증가
  Pet incrementStreak() {
    final newStreak = streakCount + 1;
    final unlockedItems = PetLevels.getUnlockedItems(level, newStreak);

    return Pet(
      level: level,
      experience: experience,
      streakCount: newStreak,
      state: state,
      equippedItems: unlockedItems,
    );
  }

  /// 연속 달성 리셋
  Pet resetStreak() {
    final unlockedItems = PetLevels.getUnlockedItems(level, 0);

    return Pet(
      level: level,
      experience: experience,
      streakCount: 0,
      state: state,
      equippedItems: unlockedItems,
    );
  }

  /// 펫 상태 변경
  Pet copyWithState(PetState newState) {
    return Pet(
      level: level,
      experience: experience,
      streakCount: streakCount,
      state: newState,
      equippedItems: equippedItems,
    );
  }

  /// 다음 레벨까지 진행도 (0.0 ~ 1.0)
  double get progressToNextLevel {
    final nextThreshold = PetLevels.getNextLevelThreshold(level);
    if (nextThreshold == -1) return 1.0; // 최대 레벨

    final currentThreshold = _getCurrentThreshold();
    final progress = (experience - currentThreshold) / (nextThreshold - currentThreshold);
    return progress.clamp(0.0, 1.0);
  }

  int _getCurrentThreshold() {
    if (level >= 20) return PetLevels.level20Threshold;
    if (level >= 10) return PetLevels.level10Threshold;
    if (level >= 5) return PetLevels.level5Threshold;
    return PetLevels.level1Threshold;
  }

  /// 다음 레벨까지 남은 완료 횟수
  int get remainingToNextLevel {
    final nextThreshold = PetLevels.getNextLevelThreshold(level);
    if (nextThreshold == -1) return 0;
    return nextThreshold - experience;
  }

  /// 레벨업 가능 여부
  bool get canLevelUp {
    final nextThreshold = PetLevels.getNextLevelThreshold(level);
    return nextThreshold != -1 && experience >= nextThreshold;
  }

  /// 무지개 오라 활성화 여부
  bool get hasRainbowAura => streakCount >= PetLevels.rainbowAuraStreak;

  /// JSON 직렬화
  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'experience': experience,
      'streakCount': streakCount,
      'state': state.id,
      'equippedItems': equippedItems.map((item) => item.id).toList(),
    };
  }

  /// JSON 역직렬화
  factory Pet.fromJson(Map<String, dynamic> json) {
    final level = json['level'] as int? ?? 1;
    final streakCount = json['streakCount'] as int? ?? 0;

    return Pet(
      level: level,
      experience: json['experience'] as int? ?? 0,
      streakCount: streakCount,
      state: PetState.values.firstWhere(
        (s) => s.id == json['state'],
        orElse: () => PetState.waiting,
      ),
      equippedItems: PetLevels.getUnlockedItems(level, streakCount),
    );
  }

  @override
  String toString() {
    return 'Pet(level: $level, exp: $experience, streak: $streakCount, state: ${state.name})';
  }
}
