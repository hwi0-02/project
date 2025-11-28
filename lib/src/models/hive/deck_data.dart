import 'package:hive/hive.dart';

part 'deck_data.g.dart';

/// 덱 카테고리 타입
@HiveType(typeId: 9)
enum DeckCategoryType {
  @HiveField(0)
  food, // 밥

  @HiveField(1)
  exercise, // 운동

  @HiveField(2)
  study, // 공부
}

/// 덱 데이터 모델 - Hive 저장용
@HiveType(typeId: 10)
class DeckData extends HiveObject {
  /// 덱 카테고리
  @HiveField(0)
  DeckCategoryType category;

  /// 원본 아이템 목록
  @HiveField(1)
  List<String> originalItems;

  /// 현재 남은 아이템 목록
  @HiveField(2)
  List<String> currentItems;

  /// 마지막 셔플 날짜
  @HiveField(3)
  DateTime lastShuffleDate;

  /// 오늘 뽑은 횟수
  @HiveField(4)
  int todayDrawCount;

  /// 마지막 뽑기 날짜
  @HiveField(5)
  DateTime? lastDrawDate;

  DeckData({
    required this.category,
    required List<String> originalItems,
    List<String>? currentItems,
    DateTime? lastShuffleDate,
    this.todayDrawCount = 0,
    this.lastDrawDate,
  })  : originalItems = List.from(originalItems),
        currentItems = currentItems != null
            ? List.from(currentItems)
            : List.from(originalItems),
        lastShuffleDate = lastShuffleDate ?? DateTime.now();

  /// 카드 뽑기
  String? draw() {
    _checkAndResetDaily();

    if (currentItems.isEmpty) {
      reshuffle();
    }

    if (currentItems.isEmpty) return null;

    currentItems.shuffle();
    final drawn = currentItems.removeLast();
    todayDrawCount++;
    lastDrawDate = DateTime.now();

    return drawn;
  }

  /// 덱 리셔플
  void reshuffle() {
    currentItems = List.from(originalItems);
    currentItems.shuffle();
    lastShuffleDate = DateTime.now();
  }

  /// 일일 리셋 체크
  void _checkAndResetDaily() {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);

    if (lastDrawDate != null) {
      final lastDate = DateTime(
        lastDrawDate!.year,
        lastDrawDate!.month,
        lastDrawDate!.day,
      );
      if (lastDate != today) {
        todayDrawCount = 0;
        reshuffle();
      }
    }
  }

  /// 남은 카드 수
  int get remainingCount => currentItems.length;

  /// 총 카드 수
  int get totalCount => originalItems.length;

  /// 덱이 비었는지
  bool get isEmpty => currentItems.isEmpty;

  /// 오늘 뽑기 가능 여부 (무료 유저: 3회, 프리미엄: 무제한)
  bool canDraw(bool isPremium) {
    _checkAndResetDaily();
    return isPremium || todayDrawCount < 3;
  }
}

/// 가챠 결과 데이터
@HiveType(typeId: 11)
class GachaResult extends HiveObject {
  /// 획득한 아이템 ID
  @HiveField(0)
  final String itemId;

  /// 희귀도
  @HiveField(1)
  final int rarity; // 0=common, 1=rare, 2=epic, 3=legendary

  /// 획득 일시
  @HiveField(2)
  final DateTime timestamp;

  /// 소비 코인
  @HiveField(3)
  final int coinSpent;

  GachaResult({
    required this.itemId,
    required this.rarity,
    required this.coinSpent,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now();
}

/// 가챠 히스토리
@HiveType(typeId: 12)
class GachaHistory extends HiveObject {
  /// 가챠 결과 목록 (최근 100개)
  @HiveField(0)
  List<GachaResult> results;

  /// 총 가챠 횟수
  @HiveField(1)
  int totalGachaCount;

  /// 피티 카운터 (10회마다 희귀 이상 보장)
  @HiveField(2)
  int pityCounter;

  GachaHistory({
    List<GachaResult>? results,
    this.totalGachaCount = 0,
    this.pityCounter = 0,
  }) : results = results ?? [];

  /// 가챠 결과 추가
  void addResult(GachaResult result) {
    results.insert(0, result);
    totalGachaCount++;

    // 희귀 이상이면 피티 리셋
    if (result.rarity >= 1) {
      pityCounter = 0;
    } else {
      pityCounter++;
    }

    // 최대 100개 유지
    if (results.length > 100) {
      results = results.sublist(0, 100);
    }
  }

  /// 피티 보장 적용 여부
  bool get isPityGuaranteed => pityCounter >= 9;
}
