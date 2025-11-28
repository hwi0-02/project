import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';

/// Lazy Evaluation 리셋 서비스
/// 
/// 유저가 앱/위젯을 보는 순간 날짜를 확인하고 필요시 리셋 수행
class ResetService {
  late SharedPreferences _prefs;
  bool _isInitialized = false;

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    _prefs = await SharedPreferences.getInstance();
    _isInitialized = true;
  }

  /// 날짜 확인 및 리셋 수행
  /// 
  /// Returns: 리셋이 수행되었으면 true
  Future<ResetResult> checkAndReset() async {
    if (!_isInitialized) await initialize();

    final lastActiveDate = _prefs.getString(StorageKeys.lastActiveDate);
    final today = _getTodayString();

    if (lastActiveDate == today) {
      // 오늘 이미 활동함 - 리셋 불필요
      return ResetResult(
        wasReset: false,
        isSulky: false,
        isFirstTimeToday: false,
      );
    }

    // 날짜가 바뀜 - 리셋 필요
    final isSulky = await _checkSulkyCondition(lastActiveDate);
    
    // 위젯 상태 리셋
    await _resetDailyState();
    
    // 활동 날짜 업데이트
    await _prefs.setString(StorageKeys.lastActiveDate, today);

    return ResetResult(
      wasReset: true,
      isSulky: isSulky,
      isFirstTimeToday: true,
    );
  }

  /// 삐침 조건 확인 (어제 미션 미완료)
  /// 
  /// 어제 앱을 사용했는데 미션을 완료하지 않았으면 삐침 상태
  Future<bool> _checkSulkyCondition(String? lastActiveDate) async {
    if (lastActiveDate == null) return false;

    final yesterday = _getYesterdayString();
    final lastCompletedDate = _prefs.getString(StorageKeys.lastCompletedDate);
    
    // 어제 활동했는지 확인
    if (lastActiveDate == yesterday) {
      // 어제 활동했는데 완료하지 않았으면 삐침
      if (lastCompletedDate == null) return true;
      return lastCompletedDate != yesterday;
    }
    
    // 어제보다 더 이전에 마지막 활동한 경우
    // 마지막 활동일에 완료했는지 확인
    if (lastCompletedDate == null) return true;
    return lastCompletedDate != lastActiveDate;
  }
  
  /// 어제 날짜 문자열 (yyyy-MM-dd)
  String _getYesterdayString() {
    final yesterday = DateTime.now().subtract(const Duration(days: 1));
    return DateFormat('yyyy-MM-dd').format(yesterday);
  }

  /// 일일 상태 리셋
  Future<void> _resetDailyState() async {
    // 오늘의 결과 초기화
    await _prefs.remove(StorageKeys.todayResult);
    await _prefs.remove(StorageKeys.todayCategory);
    await _prefs.remove(StorageKeys.todayVocabularyMeaning);
    await _prefs.setBool(StorageKeys.isCompleted, false);
    
    // 재뽑기 횟수 초기화
    await _prefs.setInt(StorageKeys.reDrawCount, 0);
  }

  /// 오늘 날짜 문자열 (yyyy-MM-dd)
  String _getTodayString() {
    return DateFormat('yyyy-MM-dd').format(DateTime.now());
  }

  /// 오늘 완료 여부 확인
  Future<bool> isCompletedToday() async {
    if (!_isInitialized) await initialize();
    return _prefs.getBool(StorageKeys.isCompleted) ?? false;
  }

  /// 오늘 완료 처리
  Future<void> markCompletedToday() async {
    if (!_isInitialized) await initialize();
    await _prefs.setBool(StorageKeys.isCompleted, true);
    await _prefs.setString(StorageKeys.lastCompletedDate, _getTodayString());
  }

  /// 오늘의 결과 저장
  Future<void> saveTodayResult(String result, String category, {String? vocabularyMeaning}) async {
    if (!_isInitialized) await initialize();
    await _prefs.setString(StorageKeys.todayResult, result);
    await _prefs.setString(StorageKeys.todayCategory, category);
    if (vocabularyMeaning != null) {
      await _prefs.setString(StorageKeys.todayVocabularyMeaning, vocabularyMeaning);
    } else {
      await _prefs.remove(StorageKeys.todayVocabularyMeaning);
    }
  }

  /// 오늘의 결과 로드
  Future<TodayResult?> getTodayResult() async {
    if (!_isInitialized) await initialize();
    
    final result = _prefs.getString(StorageKeys.todayResult);
    final category = _prefs.getString(StorageKeys.todayCategory);
    final vocabularyMeaning = _prefs.getString(StorageKeys.todayVocabularyMeaning);
    
    if (result == null || category == null) return null;
    
    return TodayResult(
      result: result,
      category: category,
      isCompleted: _prefs.getBool(StorageKeys.isCompleted) ?? false,
      vocabularyMeaning: vocabularyMeaning,
    );
  }

  /// 재뽑기 횟수 증가 및 반환
  Future<int> incrementReDrawCount() async {
    if (!_isInitialized) await initialize();
    final count = (_prefs.getInt(StorageKeys.reDrawCount) ?? 0) + 1;
    await _prefs.setInt(StorageKeys.reDrawCount, count);
    return count;
  }

  /// 현재 재뽑기 횟수
  Future<int> getReDrawCount() async {
    if (!_isInitialized) await initialize();
    return _prefs.getInt(StorageKeys.reDrawCount) ?? 0;
  }
}

/// 리셋 결과
class ResetResult {
  final bool wasReset;
  final bool isSulky;
  final bool isFirstTimeToday;

  ResetResult({
    required this.wasReset,
    required this.isSulky,
    required this.isFirstTimeToday,
  });
}

/// 오늘의 결과
class TodayResult {
  final String result;
  final String category;
  final bool isCompleted;
  final String? vocabularyMeaning;

  TodayResult({
    required this.result,
    required this.category,
    required this.isCompleted,
    this.vocabularyMeaning,
  });
}
