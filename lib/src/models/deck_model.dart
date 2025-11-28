import 'dart:convert';
import 'dart:math';

/// 영단어 모델 (단어 + 뜻)
class VocabularyItem {
  final String word;
  final String meaning;

  VocabularyItem({required this.word, required this.meaning});

  factory VocabularyItem.fromJson(Map<String, dynamic> json) {
    return VocabularyItem(
      word: json['word'] as String,
      meaning: json['meaning'] as String,
    );
  }

  Map<String, dynamic> toJson() {
    return {'word': word, 'meaning': meaning};
  }

  /// 표시용 문자열
  String get display => '$word\n$meaning';

  @override
  String toString() => display;
}

/// 덱 모델 - 중복 없는 랜덤 뽑기 알고리즘
class Deck {
  final String category;
  final List<String> originalItems;
  List<String> items;

  Deck({
    required this.category,
    required this.originalItems,
    List<String>? initialItems,
  }) : items = initialItems != null
            ? List<String>.from(initialItems)
            : (List<String>.from(originalItems)..shuffle(Random()));

  /// 뽑기: 덱에서 첫 번째 아이템을 반환하고 제거
  String pop() {
    if (items.isEmpty) {
      refill();
    }
    return items.removeAt(0);
  }

  /// 미리보기: 덱에서 첫 번째 아이템 확인 (제거하지 않음)
  String? peek() {
    if (items.isEmpty) return null;
    return items.first;
  }

  /// 리필: 원본 데이터를 셔플하여 덱 채움
  void refill() {
    items = List.from(originalItems)..shuffle(Random());
  }

  /// 덱 초기화 (새로 섞기)
  void reset() {
    refill();
  }

  /// 남은 아이템 수
  int get remainingCount => items.length;

  /// 덱이 비었는지 확인
  bool get isEmpty => items.isEmpty;

  /// JSON으로 직렬화
  Map<String, dynamic> toJson() {
    return {
      'category': category,
      'originalItems': originalItems,
      'items': items,
    };
  }

  /// JSON에서 역직렬화
  factory Deck.fromJson(Map<String, dynamic> json) {
    return Deck(
      category: json['category'] as String,
      originalItems: List<String>.from(json['originalItems']),
      initialItems: List<String>.from(json['items']),
    );
  }

  /// 현재 아이템 목록을 JSON 문자열로 변환 (SharedPreferences 저장용)
  String itemsToJsonString() {
    return jsonEncode(items);
  }

  /// JSON 문자열에서 아이템 목록 복원 (SharedPreferences 로드용)
  static List<String> itemsFromJsonString(String jsonString) {
    return List<String>.from(jsonDecode(jsonString));
  }

  @override
  String toString() {
    return 'Deck(category: $category, remaining: $remainingCount/${originalItems.length})';
  }
}

/// 덱 카테고리 열거형
enum DeckCategory {
  food('food', '밥', '🍚'),
  exercise('exercise', '운동', '💪'),
  vocabulary('vocabulary', '오늘의 영단어', '📖');

  final String id;
  final String name;
  final String emoji;

  const DeckCategory(this.id, this.name, this.emoji);

  /// ID로 카테고리 찾기
  static DeckCategory fromId(String id) {
    // 구버전 호환성: 'study' → 'vocabulary'
    if (id == 'study') return DeckCategory.vocabulary;
    return DeckCategory.values.firstWhere(
      (category) => category.id == id,
      orElse: () => DeckCategory.food,
    );
  }
}
