/// 펫 레벨 및 아이템 해금 조건 정의
class PetLevels {
  PetLevels._();

  // 레벨 임계값 (총 완료 횟수 기준)
  static const int level1Threshold = 0;   // 기본 펫
  static const int level5Threshold = 15;  // 빨간 스카프 해금
  static const int level10Threshold = 30; // 검은 뿔테 안경 해금
  static const int level20Threshold = 60; // 황금 왕관 해금

  // 연속 달성 보상
  static const int rainbowAuraStreak = 7; // 무지개 오라 (7일 연속)

  /// 완료 횟수로 레벨 계산
  static int calculateLevel(int completionCount) {
    if (completionCount >= level20Threshold) return 20;
    if (completionCount >= level10Threshold) return 10;
    if (completionCount >= level5Threshold) return 5;
    return 1;
  }

  /// 레벨에 따른 해금된 아이템 목록 반환
  static List<PetItem> getUnlockedItems(int level, int streakCount) {
    final items = <PetItem>[];

    if (level >= 5) items.add(PetItem.scarf);
    if (level >= 10) items.add(PetItem.glasses);
    if (level >= 20) items.add(PetItem.crown);
    if (streakCount >= rainbowAuraStreak) items.add(PetItem.rainbowAura);

    return items;
  }

  /// 다음 레벨까지 필요한 완료 횟수
  static int getNextLevelThreshold(int currentLevel) {
    switch (currentLevel) {
      case 1:
        return level5Threshold;
      case 5:
        return level10Threshold;
      case 10:
        return level20Threshold;
      default:
        return -1; // 최대 레벨
    }
  }
}

/// 펫 아이템 열거형
enum PetItem {
  scarf('scarf', '빨간 스카프', 'assets/images/items/scarf.png'),
  glasses('glasses', '검은 뿔테 안경', 'assets/images/items/glasses.png'),
  crown('crown', '황금 왕관', 'assets/images/items/crown.png'),
  rainbowAura('rainbow_aura', '무지개 오라', 'assets/images/items/rainbow_aura.png');

  final String id;
  final String name;
  final String assetPath;

  const PetItem(this.id, this.name, this.assetPath);
}

/// 펫 상태 열거형
enum PetState {
  waiting('waiting', '대기'),
  loading('loading', '로딩'),
  result('result', '결과'),
  completed('completed', '완료'),
  sulky('sulky', '삐침');

  final String id;
  final String name;

  const PetState(this.id, this.name);
}
