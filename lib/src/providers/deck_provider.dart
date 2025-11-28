import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/hive_models.dart';
import '../services/hive_service.dart';

/// 덱 데이터 상태
class DeckState {
  final Map<DeckCategoryType, DeckData> decks;
  
  DeckState({Map<DeckCategoryType, DeckData>? decks}) 
      : decks = decks ?? {};
  
  DeckData? getDeck(DeckCategoryType category) => decks[category];
  
  DeckState copyWith({Map<DeckCategoryType, DeckData>? decks}) {
    return DeckState(decks: decks ?? this.decks);
  }
}

/// 덱 Provider
final deckProvider = StateNotifierProvider<DeckNotifier, DeckState>((ref) {
  return DeckNotifier();
});

class DeckNotifier extends StateNotifier<DeckState> {
  DeckNotifier() : super(DeckState()) {
    _loadDecks();
  }

  /// 기본 덱 데이터
  static const Map<DeckCategoryType, List<String>> _defaultItems = {
    DeckCategoryType.food: [
      '김치찌개', '된장찌개', '순두부찌개', '부대찌개',
      '비빔밥', '불고기', '삼겹살', '치킨',
      '짜장면', '짬뽕', '탕수육', '볶음밥',
      '초밥', '라멘', '돈카츠', '우동',
      '피자', '파스타', '햄버거', '샌드위치',
      '쌀국수', '팟타이', '똠얌꿍', '카레',
      '샐러드', '도시락', '편의점', '배달음식',
    ],
    DeckCategoryType.exercise: [
      '걷기 30분', '조깅 20분', '런닝 15분', '자전거 30분',
      '수영 30분', '줄넘기 10분', '스쿼트 50개', '푸쉬업 30개',
      '플랭크 3분', '버피 20개', '런지 40개', '팔굽혀펴기 25개',
      '요가 20분', '필라테스 30분', '스트레칭 15분', '명상 10분',
      '계단 오르기', '댄스 20분', '복근 운동', '등 운동',
      '팔 운동', '하체 운동', '전신 운동', '고강도 인터벌',
    ],
    DeckCategoryType.study: [
      '영어 단어 30개', '영어 문법 1챕터', '영어 듣기 30분', '영어 회화 20분',
      '독서 30분', '기사 읽기 3개', '뉴스 시청 20분', '다큐 시청 1편',
      '코딩 연습 1시간', '알고리즘 2문제', '새 기술 학습', '프로젝트 작업',
      '자격증 공부 1시간', '온라인 강의 1강', '노트 정리', '복습 30분',
      '글쓰기 연습', '일기 쓰기', '블로그 포스팅', '아이디어 브레인스토밍',
      '악기 연습 30분', '외국어 앱 20분', '팟캐스트 듣기', '강연 시청',
    ],
  };

  /// 덱 불러오기
  void _loadDecks() {
    final loadedDecks = <DeckCategoryType, DeckData>{};
    
    for (final category in DeckCategoryType.values) {
      var deck = HiveService.getDeck(category);
      
      // 덱이 없으면 기본값으로 생성
      if (deck == null) {
        deck = DeckData(
          category: category,
          originalItems: _defaultItems[category] ?? [],
        );
        HiveService.saveDeck(deck);
      }
      
      loadedDecks[category] = deck;
    }
    
    state = DeckState(decks: loadedDecks);
  }

  /// 카드 뽑기
  Future<String?> draw(DeckCategoryType category, {bool isPremium = false}) async {
    final deck = state.decks[category];
    if (deck == null) return null;
    
    // 뽑기 가능 여부 확인
    if (!deck.canDraw(isPremium)) {
      return null; // 일일 제한 초과
    }
    
    final drawn = deck.draw();
    if (drawn != null) {
      await HiveService.saveDeck(deck);
      _refreshState();
    }
    
    return drawn;
  }

  /// 덱 리셔플
  Future<void> reshuffle(DeckCategoryType category) async {
    final deck = state.decks[category];
    if (deck == null) return;
    
    deck.reshuffle();
    await HiveService.saveDeck(deck);
    _refreshState();
  }

  /// 덱 아이템 업데이트 (사용자 커스텀)
  Future<void> updateDeckItems(DeckCategoryType category, List<String> items) async {
    final currentDeck = state.decks[category];
    
    final newDeck = DeckData(
      category: category,
      originalItems: items,
      todayDrawCount: currentDeck?.todayDrawCount ?? 0,
      lastDrawDate: currentDeck?.lastDrawDate,
    );
    
    await HiveService.saveDeck(newDeck);
    _loadDecks(); // 전체 다시 로드
  }

  /// 남은 카드 수 조회
  int getRemainingCount(DeckCategoryType category) {
    return state.decks[category]?.remainingCount ?? 0;
  }

  /// 오늘 뽑은 횟수 조회
  int getTodayDrawCount(DeckCategoryType category) {
    return state.decks[category]?.todayDrawCount ?? 0;
  }

  /// 뽑기 가능 여부 조회
  bool canDraw(DeckCategoryType category, bool isPremium) {
    return state.decks[category]?.canDraw(isPremium) ?? false;
  }

  /// 상태 새로고침
  void _refreshState() {
    state = state.copyWith(decks: Map.from(state.decks));
  }
}

/// 특정 카테고리의 덱 데이터 Provider (파생)
final foodDeckProvider = Provider<DeckData?>((ref) {
  final deckState = ref.watch(deckProvider);
  return deckState.getDeck(DeckCategoryType.food);
});

final exerciseDeckProvider = Provider<DeckData?>((ref) {
  final deckState = ref.watch(deckProvider);
  return deckState.getDeck(DeckCategoryType.exercise);
});

final studyDeckProvider = Provider<DeckData?>((ref) {
  final deckState = ref.watch(deckProvider);
  return deckState.getDeck(DeckCategoryType.study);
});
