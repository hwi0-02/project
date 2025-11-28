/// 펫 상태 서비스
/// 
/// PetStateModel의 비즈니스 로직을 분리하여 SRP(단일 책임 원칙) 적용
/// 모델은 순수 데이터만 보유하고, 로직은 서비스에서 처리
class PetStateService {
  /// 시간당 포만감 감소량
  static const int hungerDecayPerHour = 5;
  
  /// 시간당 애정도 감소량
  static const int moodDecayPerHour = 3;
  
  /// 밥 주기 시 포만감 증가량
  static const int feedHungerIncrease = 20;
  
  /// 밥 주기 시 경험치 증가량
  static const int feedExpIncrease = 10;
  
  /// 쓰다듬기 시 애정도 증가량
  static const int petMoodIncrease = 10;
  
  /// 쓰다듬기 시 경험치 증가량
  static const int petExpIncrease = 5;
  
  /// 하루 최대 쓰다듬기 횟수
  static const int maxPetCountPerDay = 5;
  
  /// 배고픔 기준치
  static const int hungryThreshold = 30;
  
  /// 삐침 기준치
  static const int sulkyThreshold = 30;

  /// 시간 경과에 따른 상태 감소 계산
  /// 
  /// Returns: (포만감 감소량, 애정도 감소량)
  static (int hungerDecay, int moodDecay) calculateTimeDecay(DateTime lastAccessTime) {
    final now = DateTime.now();
    final hoursPassed = now.difference(lastAccessTime).inHours;
    
    if (hoursPassed <= 0) {
      return (0, 0);
    }
    
    return (
      hoursPassed * hungerDecayPerHour,
      hoursPassed * moodDecayPerHour,
    );
  }

  /// 밥 주기 적용
  /// 
  /// Returns: 새로운 포만감 값
  static int applyFeed(int currentHunger) {
    return (currentHunger + feedHungerIncrease).clamp(0, 100);
  }

  /// 쓰다듬기 가능 여부 확인
  static bool canPet(int todayPetCount, DateTime? lastPetDate) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    // 날짜가 바뀌었으면 가능
    if (lastPetDate == null) return true;
    
    final lastDate = DateTime(
      lastPetDate.year, 
      lastPetDate.month, 
      lastPetDate.day
    );
    
    if (lastDate != today) return true;
    
    // 같은 날이면 횟수 체크
    return todayPetCount < maxPetCountPerDay;
  }

  /// 쓰다듬기 적용
  /// 
  /// Returns: 새로운 애정도 값
  static int applyPet(int currentMood) {
    return (currentMood + petMoodIncrease).clamp(0, 100);
  }

  /// 레벨업 필요 경험치 계산
  static int expRequiredForLevel(int level) {
    return level * 100;
  }

  /// 경험치 추가 및 레벨업 계산
  /// 
  /// Returns: (새 레벨, 남은 경험치)
  static (int newLevel, int newExp) addExperience(int currentLevel, int currentExp, int expToAdd) {
    var level = currentLevel < 1 ? 1 : currentLevel;
    var exp = currentExp + expToAdd;
    
    if (exp < 0) exp = 0;
    
    // 레벨업 체크
    while (exp >= expRequiredForLevel(level)) {
      exp -= expRequiredForLevel(level);
      level++;
    }
    
    return (level, exp);
  }

  /// 연속 출석 계산
  /// 
  /// Returns: (새 연속 출석 일수, 오늘 이미 체크했는지 여부)
  static (int newStreak, bool alreadyCheckedToday) calculateStreak(
    int currentStreak, 
    DateTime? lastStreakDate
  ) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    
    if (lastStreakDate == null) {
      return (1, false);
    }
    
    final lastDate = DateTime(
      lastStreakDate.year,
      lastStreakDate.month,
      lastStreakDate.day,
    );
    
    if (lastDate == today) {
      return (currentStreak, true); // 이미 체크함
    }
    
    final yesterday = today.subtract(const Duration(days: 1));
    if (lastDate == yesterday) {
      return (currentStreak + 1, false); // 연속 출석
    }
    
    return (1, false); // 연속 끊김
  }

  /// 펫이 배고픈지 확인
  static bool isHungry(int hungerPoint) => hungerPoint <= hungryThreshold;

  /// 펫이 삐친 상태인지 확인
  static bool isSulky(int moodPoint) => moodPoint <= sulkyThreshold;

  /// 행복도 계산 (포만감 + 애정도 평균)
  static int calculateHappiness(int hungerPoint, int moodPoint) {
    return ((hungerPoint + moodPoint) / 2).round();
  }

  /// 레벨업 진행률 계산 (0.0 ~ 1.0)
  static double calculateLevelProgress(int level, int experience) {
    return experience / expRequiredForLevel(level);
  }

  /// 다음 레벨까지 필요한 경험치
  static int expToNextLevel(int level, int experience) {
    return expRequiredForLevel(level) - experience;
  }
}
