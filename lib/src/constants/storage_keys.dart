/// SharedPreferences 키 상수 정의
class StorageKeys {
  StorageKeys._();

  // 덱 데이터 (List<String> JSON 형태로 저장)
  static const String deckFood = 'deck_food';
  static const String deckExercise = 'deck_exercise';
  static const String deckStudy = 'deck_study'; // 구버전 호환
  static const String deckVocabulary = 'deck_vocabulary';

  // 펫 상태
  static const String petLevel = 'pet_level';
  static const String petExperience = 'pet_experience'; // 총 완료 횟수

  // 연속 달성
  static const String streakCount = 'streak_count';

  // 날짜 추적
  static const String lastActiveDate = 'last_active_date';
  static const String lastCompletedDate = 'last_completed_date';

  // 프리미엄 상태
  static const String isPremium = 'is_premium';

  // 세션별 재뽑기 횟수
  static const String reDrawCount = 'redraw_count';

  // 오늘의 결과
  static const String todayResult = 'today_result';
  static const String todayCategory = 'today_category';
  static const String todayVocabularyMeaning = 'today_vocabulary_meaning';
  static const String isCompleted = 'is_completed';

  // 온보딩 완료 여부
  static const String onboardingCompleted = 'onboarding_completed';
  static const String isOnboardingComplete = 'is_onboarding_complete';
}
