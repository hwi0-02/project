import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../models/models.dart';

/// 펫 상태 리포지토리
/// 
/// SharedPreferences를 통해 펫 상태를 관리
class PetRepository {
  late SharedPreferences _prefs;
  bool _isInitialized = false;
  Pet _pet = Pet();

  Pet get pet => _pet;

  /// 리포지토리 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;

    _prefs = await SharedPreferences.getInstance();
    await _loadPet();
    _isInitialized = true;
  }

  /// 펫 정보 로드
  Future<void> _loadPet() async {
    final level = _prefs.getInt(StorageKeys.petLevel) ?? 1;
    final experience = _prefs.getInt(StorageKeys.petExperience) ?? 0;
    final streakCount = _prefs.getInt(StorageKeys.streakCount) ?? 0;

    _pet = Pet(
      level: level,
      experience: experience,
      streakCount: streakCount,
      state: PetState.waiting,
      equippedItems: PetLevels.getUnlockedItems(level, streakCount),
    );
  }

  /// 펫 정보 저장
  Future<void> _savePet() async {
    await _prefs.setInt(StorageKeys.petLevel, _pet.level);
    await _prefs.setInt(StorageKeys.petExperience, _pet.experience);
    await _prefs.setInt(StorageKeys.streakCount, _pet.streakCount);
  }

  /// 미션 완료 처리
  Future<Pet> completeMission() async {
    final previousLevel = _pet.level;
    _pet = _pet.addExperience();
    
    // 연속 달성 처리
    final lastCompletedDate = _prefs.getString(StorageKeys.lastCompletedDate);
    final today = _getTodayString();
    
    if (lastCompletedDate != null) {
      final lastDate = DateTime.parse(lastCompletedDate);
      final todayDate = DateTime.parse(today);
      final difference = todayDate.difference(lastDate).inDays;
      
      if (difference == 1) {
        // 어제 완료 → 연속 달성 증가
        _pet = _pet.incrementStreak();
      } else if (difference > 1) {
        // 하루 이상 건너뜀 → 연속 달성 리셋
        _pet = _pet.resetStreak();
      }
      // difference == 0: 오늘 이미 완료, 연속 달성 유지
    } else {
      // 첫 완료
      _pet = _pet.incrementStreak();
    }

    await _prefs.setString(StorageKeys.lastCompletedDate, today);
    await _savePet();

    // 레벨업 여부 확인
    final isLevelUp = _pet.level > previousLevel;
    if (isLevelUp) {
      // 레벨업 이벤트 처리 (Provider에서 감지)
    }

    return _pet;
  }

  /// 펫 상태 변경
  Future<Pet> updateState(PetState state) async {
    _pet = _pet.copyWithState(state);
    return _pet;
  }

  /// 삐침 상태 확인 (어제 미션 미완료)
  Future<bool> checkSulkyState() async {
    final lastCompletedDate = _prefs.getString(StorageKeys.lastCompletedDate);
    final lastActiveDate = _prefs.getString(StorageKeys.lastActiveDate);
    
    if (lastActiveDate == null) return false;
    
    final today = _getTodayString();
    if (lastActiveDate == today) return false;
    
    // 어제 활동했지만 완료하지 않았으면 삐침
    if (lastCompletedDate == null) return true;
    return lastCompletedDate != lastActiveDate;
  }

  /// 연속 달성 리셋 (미션 미완료로 인한)
  Future<void> resetStreakDueToMiss() async {
    _pet = _pet.resetStreak();
    await _savePet();
  }

  String _getTodayString() {
    final now = DateTime.now();
    return '${now.year}-${now.month.toString().padLeft(2, '0')}-${now.day.toString().padLeft(2, '0')}';
  }
}
