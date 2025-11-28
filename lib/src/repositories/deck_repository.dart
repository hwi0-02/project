import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../models/deck_model.dart';
import '../services/hive_service.dart';

/// 덱 데이터 리포지토리
/// 
/// JSON 데이터 로드 및 SharedPreferences 상태 관리
/// 설정에 따라 서브카테고리별 데이터 로드
class DeckRepository {
  // 싱글톤 인스턴스
  static final DeckRepository _instance = DeckRepository._internal();
  static DeckRepository get instance => _instance;
  
  // private 생성자
  DeckRepository._internal();
  
  // 기존 코드 호환을 위한 factory 생성자
  factory DeckRepository() => _instance;
  
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  // 카테고리별 덱 캐시
  final Map<DeckCategory, Deck> _decks = {};
  
  // 영단어 덱 (VocabularyItem 리스트)
  List<VocabularyItem> _vocabularyItems = [];
  List<VocabularyItem> _currentVocabularyDeck = [];

  /// 리포지토리 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    
    // 모든 카테고리 덱 로드
    for (final category in DeckCategory.values) {
      await _loadOrCreateDeck(category);
    }

    _isInitialized = true;
  }

  /// 카테고리별 덱 가져오기
  Deck getDeck(DeckCategory category) {
    return _decks[category]!;
  }

  /// 카테고리에서 아이템 뽑기
  Future<String> draw(DeckCategory category) async {
    if (category == DeckCategory.vocabulary) {
      return _drawVocabularyString();
    }
    
    final deck = _decks[category]!;
    final result = deck.pop();
    await _saveDeck(category);
    return result;
  }

  /// 영단어 뽑기 (VocabularyItem 반환)
  Future<VocabularyItem> drawVocabulary() async {
    if (_currentVocabularyDeck.isEmpty) {
      _refillVocabularyDeck();
    }
    
    final item = _currentVocabularyDeck.removeAt(0);
    await _saveVocabularyDeckState();
    return item;
  }

  /// 영단어 뽑기 (단어 + 뜻 문자열 반환)
  String _drawVocabularyString() {
    if (_currentVocabularyDeck.isEmpty) {
      _refillVocabularyDeck();
    }
    
    final item = _currentVocabularyDeck.removeAt(0);
    _saveVocabularyDeckState();
    return item.display;
  }

  /// 영단어 덱 리필
  void _refillVocabularyDeck() {
    _currentVocabularyDeck = List.from(_vocabularyItems)..shuffle();
  }

  /// 영단어 덱 상태 저장
  Future<void> _saveVocabularyDeckState() async {
    final items = _currentVocabularyDeck.map((e) => jsonEncode(e.toJson())).toList();
    await _prefs.setStringList(StorageKeys.deckVocabulary, items);
  }

  /// 덱 리셋 (새로 섞기)
  Future<void> resetDeck(DeckCategory category) async {
    if (category == DeckCategory.vocabulary) {
      _refillVocabularyDeck();
      await _saveVocabularyDeckState();
      return;
    }
    _decks[category]!.reset();
    await _saveDeck(category);
  }

  /// 모든 덱 리셋
  Future<void> resetAllDecks() async {
    for (final category in DeckCategory.values) {
      await resetDeck(category);
    }
  }

  /// 설정 변경 시 덱 재로드
  Future<void> reloadDecksWithSettings() async {
    // 초기화가 안 되어 있으면 initialize만 호출
    if (!_isInitialized) {
      await initialize();
      return;
    }
    
    _isInitialized = false;
    _decks.clear();
    _vocabularyItems.clear();
    _currentVocabularyDeck.clear();
    
    // 저장된 덱 상태 초기화
    await _prefs.remove(StorageKeys.deckFood);
    await _prefs.remove(StorageKeys.deckExercise);
    await _prefs.remove(StorageKeys.deckVocabulary);
    
    await initialize();
  }

  /// JSON 파일에서 원본 데이터 로드 (설정 반영)
  Future<List<String>> _loadOriginalData(DeckCategory category) async {
    try {
      final settings = HiveService.getSettings();
      final String jsonPath;
      
      switch (category) {
        case DeckCategory.food:
          jsonPath = 'assets/data/food_${settings.foodSubCategory.id}.json';
          break;
        case DeckCategory.exercise:
          jsonPath = 'assets/data/exercise_${settings.exerciseSubCategory.id}.json';
          break;
        case DeckCategory.vocabulary:
          // 영단어는 별도 처리
          return [];
      }
      
      final jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      return jsonList.cast<String>();
    } catch (e) {
      // 기본 데이터 반환
      return _getDefaultData(category);
    }
  }

  /// 영단어 데이터 로드
  Future<void> _loadVocabularyData() async {
    try {
      final settings = HiveService.getSettings();
      final jsonPath = 'assets/data/vocabulary_${settings.vocabularyLevel.id}.json';
      
      final jsonString = await rootBundle.loadString(jsonPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      _vocabularyItems = jsonList
          .map((e) => VocabularyItem.fromJson(e as Map<String, dynamic>))
          .toList();
      
      // 저장된 덱 상태 복원 또는 새로 생성
      final savedDeck = _prefs.getStringList(StorageKeys.deckVocabulary);
      if (savedDeck != null && savedDeck.isNotEmpty) {
        _currentVocabularyDeck = savedDeck
            .map((e) => VocabularyItem.fromJson(jsonDecode(e)))
            .toList();
      } else {
        _refillVocabularyDeck();
      }
    } catch (e) {
      // 기본 영단어 데이터
      _vocabularyItems = [
        VocabularyItem(word: 'apple', meaning: '사과'),
        VocabularyItem(word: 'book', meaning: '책'),
        VocabularyItem(word: 'cat', meaning: '고양이'),
        VocabularyItem(word: 'dog', meaning: '개'),
        VocabularyItem(word: 'happy', meaning: '행복한'),
      ];
      _refillVocabularyDeck();
    }
  }

  /// 기본 데이터 (JSON 로드 실패 시)
  List<String> _getDefaultData(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return [
          '김치찌개', '된장찌개', '비빔밥', '냉면', '치킨',
          '피자', '햄버거', '초밥', '라면', '떡볶이',
          '파스타', '샐러드', '샌드위치', '국밥', '칼국수',
        ];
      case DeckCategory.exercise:
        return [
          '스쿼트 20개', '팔굽혀펴기 15개', '플랭크 1분', '버피 10개',
          '런지 20개', '크런치 30개', '점핑잭 50개', '마운틴클라이머 30개',
          '덤벨 컬 15개', '레그레이즈 20개', '스트레칭 10분', '조깅 15분',
        ];
      case DeckCategory.vocabulary:
        return [];
    }
  }

  /// 덱 로드 또는 생성
  Future<void> _loadOrCreateDeck(DeckCategory category) async {
    if (category == DeckCategory.vocabulary) {
      await _loadVocabularyData();
      return;
    }

    final key = _getStorageKey(category);
    final savedItems = _prefs.getString(key);

    final originalData = await _loadOriginalData(category);

    if (savedItems != null) {
      // 저장된 덱 복원
      final items = Deck.itemsFromJsonString(savedItems);
      _decks[category] = Deck(
        category: category.id,
        originalItems: originalData,
        initialItems: items,
      );
    } else {
      // 새 덱 생성
      _decks[category] = Deck(
        category: category.id,
        originalItems: originalData,
      );
      await _saveDeck(category);
    }
  }

  /// 덱 상태 저장
  Future<void> _saveDeck(DeckCategory category) async {
    if (category == DeckCategory.vocabulary) return;
    
    final key = _getStorageKey(category);
    final deck = _decks[category]!;
    await _prefs.setString(key, deck.itemsToJsonString());
  }

  /// 스토리지 키 생성
  String _getStorageKey(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return StorageKeys.deckFood;
      case DeckCategory.exercise:
        return StorageKeys.deckExercise;
      case DeckCategory.vocabulary:
        return StorageKeys.deckVocabulary;
    }
  }
}
