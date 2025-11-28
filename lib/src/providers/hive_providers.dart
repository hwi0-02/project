import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/hive_models.dart';
import '../services/hive_service.dart';

/// 펫 상태 Provider
/// 다마고치 시스템의 핵심 상태 관리
final petStateProvider = StateNotifierProvider<PetStateNotifier, PetStateModel>((ref) {
  return PetStateNotifier();
});

class PetStateNotifier extends StateNotifier<PetStateModel> {
  PetStateNotifier() : super(HiveService.getPetState()) {
    // 앱 시작 시 시간 경과에 따른 상태 감소 적용
    _applyTimeDecay();
  }

  /// 시간 감소 적용 및 저장
  void _applyTimeDecay() {
    state.applyTimeDecay();
    _save();
  }

  /// 상태 저장 및 UI 갱신
  Future<void> _save() async {
    await HiveService.savePetState(state);
    // StateNotifier가 변경을 감지하도록 새 인스턴스 생성
    state = _cloneState(state);
  }
  
  /// 상태 복제 (Hive 캐시 우회를 위해)
  PetStateModel _cloneState(PetStateModel source) {
    return PetStateModel(
      hungerPoint: source.hungerPoint,
      moodPoint: source.moodPoint,
      lastAccessTime: source.lastAccessTime,
      level: source.level,
      experience: source.experience,
      streakCount: source.streakCount,
      equippedItems: List.from(source.equippedItems),
      todayPetCount: source.todayPetCount,
      lastPetDate: source.lastPetDate,
      lastStreakDate: source.lastStreakDate,
      petName: source.petName,
      petType: source.petType,
    );
  }

  /// 밥 주기 (뽑기 완료 시)
  Future<void> feed() async {
    state.feed();
    await _save();
  }

  /// 쓰다듬기
  Future<bool> pet() async {
    final success = state.pet();
    if (success) {
      await _save();
    }
    return success;
  }

  /// 출석 체크
  Future<bool> checkStreak() async {
    final isNew = state.checkAndUpdateStreak();
    if (isNew) {
      await _save();
    }
    return isNew;
  }

  /// 아이템 장착/해제
  Future<void> toggleEquipItem(String itemId) async {
    if (state.equippedItems.contains(itemId)) {
      state.equippedItems.remove(itemId);
    } else {
      state.equippedItems.add(itemId);
    }
    await _save();
  }

  /// 펫 이름 변경
  Future<void> changeName(String newName) async {
    state.petName = newName;
    await _save();
  }

  /// 상태 새로고침 (시간 감소 재계산)
  Future<void> refresh() async {
    _applyTimeDecay();
  }
}

/// 지갑 Provider
/// 코인 시스템 관리
final walletProvider = StateNotifierProvider<WalletNotifier, UserWallet>((ref) {
  return WalletNotifier();
});

class WalletNotifier extends StateNotifier<UserWallet> {
  WalletNotifier() : super(HiveService.getWallet());

  /// 상태 저장 및 UI 갱신
  Future<void> _save() async {
    await HiveService.saveWallet(state);
    // StateNotifier가 변경을 감지하도록 새 인스턴스 생성
    state = _cloneState(state);
  }
  
  /// 상태 복제 (Hive 캐시 우회를 위해)
  UserWallet _cloneState(UserWallet source) {
    return UserWallet(
      coins: source.coins,
      totalEarned: source.totalEarned,
      totalSpent: source.totalSpent,
      lastDailyRewardDate: source.lastDailyRewardDate,
      transactions: List.from(source.transactions),
    );
  }

  /// 코인 획득
  Future<void> earnCoins(int amount, String reason) async {
    state.earnCoins(amount, reason);
    await _save();
  }

  /// 코인 소비
  Future<bool> spendCoins(int amount, String reason) async {
    final success = state.spendCoins(amount, reason);
    if (success) {
      await _save();
    }
    return success;
  }

  /// 일일 보상 수령
  Future<int> claimDailyReward(int streakCount) async {
    final reward = state.claimDailyReward(streakCount);
    if (reward > 0) {
      await _save();
    }
    return reward;
  }
}

/// 인벤토리 Provider
final inventoryProvider = StateNotifierProvider<InventoryNotifier, UserInventory>((ref) {
  return InventoryNotifier();
});

class InventoryNotifier extends StateNotifier<UserInventory> {
  InventoryNotifier() : super(HiveService.getInventory());

  Future<void> _save() async {
    await HiveService.saveInventory(state);
    // StateNotifier가 변경을 감지하도록 새 인스턴스 생성
    state = UserInventory(
      items: List.from(state.items),
    );
  }

  /// 아이템 추가
  Future<void> addItem(String itemId, String acquiredFrom) async {
    state.addItem(itemId, acquiredFrom);
    await _save();
  }

  /// 아이템 사용
  Future<bool> useItem(String itemId) async {
    final success = state.useItem(itemId);
    if (success) {
      await _save();
    }
    return success;
  }
}

/// 가챠 히스토리 Provider
final gachaHistoryProvider = StateNotifierProvider<GachaHistoryNotifier, GachaHistory>((ref) {
  return GachaHistoryNotifier();
});

class GachaHistoryNotifier extends StateNotifier<GachaHistory> {
  GachaHistoryNotifier() : super(HiveService.getGachaHistory());

  Future<void> _save() async {
    await HiveService.saveGachaHistory(state);
    // StateNotifier가 변경을 감지하도록 새 인스턴스 생성
    state = GachaHistory(
      results: List.from(state.results),
      pityCounter: state.pityCounter,
    );
  }

  /// 가챠 결과 추가
  Future<void> addResult(GachaResult result) async {
    state.addResult(result);
    await _save();
  }
}

/// 업적 데이터 Provider
final achievementProvider = StateNotifierProvider<AchievementNotifier, UserAchievementData>((ref) {
  return AchievementNotifier();
});

class AchievementNotifier extends StateNotifier<UserAchievementData> {
  AchievementNotifier() : super(HiveService.getAchievementData());

  Future<void> _save() async {
    await HiveService.saveAchievementData(state);
    // StateNotifier가 변경을 감지하도록 새 인스턴스 생성
    state = UserAchievementData(
      achievements: List.from(state.achievements),
      earnedBadges: List.from(state.earnedBadges),
      displayBadgeId: state.displayBadgeId,
    );
  }

  /// 업적 진행 업데이트
  Future<void> updateProgress(String achievementId, int value, int targetValue) async {
    state.updateAchievement(achievementId, value, targetValue);
    await _save();
  }

  /// 뱃지 획득
  Future<void> earnBadge(String badgeId) async {
    state.earnBadge(badgeId);
    await _save();
  }

  /// 표시 뱃지 설정
  Future<void> setDisplayBadge(String? badgeId) async {
    state.displayBadgeId = badgeId;
    await _save();
  }
}

/// 펫 행복도 계산 Provider (파생)
final petHappinessProvider = Provider<int>((ref) {
  final petState = ref.watch(petStateProvider);
  return petState.happiness;
});

/// 펫이 배고픈지 확인 Provider (파생)
final isPetHungryProvider = Provider<bool>((ref) {
  final petState = ref.watch(petStateProvider);
  return petState.isHungry;
});

/// 펫이 삐졌는지 확인 Provider (파생)
final isPetSulkyProvider = Provider<bool>((ref) {
  final petState = ref.watch(petStateProvider);
  return petState.isSulky;
});

/// 사용자 설정 Provider
final userSettingsProvider = StateNotifierProvider<UserSettingsNotifier, UserSettings>((ref) {
  return UserSettingsNotifier();
});

class UserSettingsNotifier extends StateNotifier<UserSettings> {
  UserSettingsNotifier() : super(HiveService.getSettings());

  Future<void> _save(UserSettings newSettings) async {
    // 먼저 상태 업데이트 (UI 즉시 반영)
    state = newSettings;
    // 그 다음 저장
    await HiveService.saveSettings(newSettings);
  }

  /// 음식 서브카테고리 변경
  Future<void> setFoodSubCategory(FoodSubCategory category) async {
    if (state.foodSubCategory == category) return; // 같은 값이면 무시
    final newSettings = state.copyWith(foodSubCategory: category);
    await _save(newSettings);
  }

  /// 운동 서브카테고리 변경
  Future<void> setExerciseSubCategory(ExerciseSubCategory category) async {
    if (state.exerciseSubCategory == category) return; // 같은 값이면 무시
    final newSettings = state.copyWith(exerciseSubCategory: category);
    await _save(newSettings);
  }

  /// 영단어 레벨 변경
  Future<void> setVocabularyLevel(VocabularyLevel level) async {
    if (state.vocabularyLevel == level) return; // 같은 값이면 무시
    final newSettings = state.copyWith(vocabularyLevel: level);
    await _save(newSettings);
  }
}
