import '../models/deck_model.dart';
import '../models/hive/user_settings.dart';

/// 덱 데이터 리포지토리 인터페이스
/// 
/// DIP(의존성 역전 원칙) 적용: UI 코드는 이 인터페이스에만 의존합니다.
/// 테스트 시 Mock 구현체로 쉽게 교체 가능합니다.
abstract class IDeckRepository {
  /// 리포지토리 초기화
  Future<void> initialize();

  /// 카테고리별 덱 가져오기
  Deck getDeck(DeckCategory category);

  /// 카테고리에서 아이템 뽑기
  Future<String> draw(DeckCategory category);

  /// 영단어 뽑기 (VocabularyItem 반환)
  Future<VocabularyItem> drawVocabulary();

  /// 덱 리셋 (새로 섞기)
  Future<void> resetDeck(DeckCategory category);

  /// 모든 덱 리셋
  Future<void> resetAllDecks();

  /// 설정 변경 시 덱 재로드
  Future<void> reloadDecksWithSettings([UserSettings? settings]);
}
