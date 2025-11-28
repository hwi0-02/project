import 'dart:async';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import '../models/deck_model.dart';

/// 위젯 액션 콜백 타입
typedef WidgetActionCallback = Future<void> Function();

/// 위젯 동기화 서비스
/// 
/// 앱과 홈 화면 위젯 간의 데이터 동기화를 담당
class WidgetSyncService {
  // Android 위젯 Provider 클래스명
  static const String _androidWidgetProvider = 'FetchPetWidgetProvider';
  
  // iOS App Group ID
  static const String _iOSAppGroupId = 'group.com.fetchpet.widget';
  
  // 위젯에 전달할 데이터 키
  static const String _widgetStateKey = 'widget_state';
  static const String _widgetMessageKey = 'widget_message';
  static const String _widgetResultKey = 'widget_result';
  static const String _widgetPetStateKey = 'widget_pet_state';
  static const String _widgetStreakKey = 'widget_streak';
  static const String _widgetLevelKey = 'widget_level';

  bool _isInitialized = false;
  
  // 위젯 액션 콜백
  WidgetActionCallback? _onDrawAction;
  WidgetActionCallback? _onCompleteAction;

  /// 뽑기 액션 콜백 등록
  void setDrawActionCallback(WidgetActionCallback callback) {
    _onDrawAction = callback;
  }

  /// 완료 액션 콜백 등록
  void setCompleteActionCallback(WidgetActionCallback callback) {
    _onCompleteAction = callback;
  }

  /// 서비스 초기화
  Future<void> initialize() async {
    if (_isInitialized) return;
    
    // iOS App Group 설정
    await HomeWidget.setAppGroupId(_iOSAppGroupId);
    
    // 위젯 클릭 콜백 등록
    HomeWidget.widgetClicked.listen(_onWidgetClicked);
    
    _isInitialized = true;
  }

  /// 위젯 클릭 이벤트 핸들러
  void _onWidgetClicked(Uri? uri) {
    if (uri == null) return;
    
    // URI scheme에 따라 액션 처리
    final action = uri.host;
    switch (action) {
      case 'draw':
        // 뽑기 액션 - 앱에서 처리하도록 콜백
        _handleDrawAction();
        break;
      case 'complete':
        // 완료 액션
        _handleCompleteAction();
        break;
      case 'open':
        // 앱 열기
        break;
    }
  }

  void _handleDrawAction() {
    // 등록된 뽑기 콜백 호출
    if (_onDrawAction != null) {
      _onDrawAction!();
    }
  }

  void _handleCompleteAction() {
    // 등록된 완료 콜백 호출
    if (_onCompleteAction != null) {
      _onCompleteAction!();
    }
  }

  /// 위젯 상태 업데이트
  Future<void> updateWidgetState(FetchPetWidgetState state) async {
    await HomeWidget.saveWidgetData<String>(_widgetStateKey, state.name);
    await _updateWidget();
  }

  /// 위젯 메시지 업데이트
  Future<void> updateWidgetMessage(String message) async {
    await HomeWidget.saveWidgetData<String>(_widgetMessageKey, message);
    await _updateWidget();
  }

  /// 위젯 결과 업데이트
  Future<void> updateWidgetResult(String? result) async {
    await HomeWidget.saveWidgetData<String?>(_widgetResultKey, result);
    await _updateWidget();
  }

  /// 펫 상태 업데이트
  Future<void> updatePetState(String petState) async {
    await HomeWidget.saveWidgetData<String>(_widgetPetStateKey, petState);
    await _updateWidget();
  }

  /// 연속 달성 업데이트
  Future<void> updateStreak(int streak) async {
    await HomeWidget.saveWidgetData<int>(_widgetStreakKey, streak);
    await _updateWidget();
  }

  /// 레벨 업데이트
  Future<void> updateLevel(int level) async {
    await HomeWidget.saveWidgetData<int>(_widgetLevelKey, level);
    await _updateWidget();
  }

  /// 전체 위젯 데이터 업데이트
  Future<void> updateAllWidgetData({
    required FetchPetWidgetState state,
    required String message,
    String? result,
    required String petState,
    required int streak,
    required int level,
  }) async {
    await HomeWidget.saveWidgetData<String>(_widgetStateKey, state.name);
    await HomeWidget.saveWidgetData<String>(_widgetMessageKey, message);
    await HomeWidget.saveWidgetData<String?>(_widgetResultKey, result);
    await HomeWidget.saveWidgetData<String>(_widgetPetStateKey, petState);
    await HomeWidget.saveWidgetData<int>(_widgetStreakKey, streak);
    await HomeWidget.saveWidgetData<int>(_widgetLevelKey, level);
    await _updateWidget();
  }

  /// 앱 데이터를 위젯으로 동기화
  Future<void> syncFromApp() async {
    final prefs = await SharedPreferences.getInstance();
    
    final result = prefs.getString(StorageKeys.todayResult);
    final category = prefs.getString(StorageKeys.todayCategory);
    final vocabularyMeaning = prefs.getString(StorageKeys.todayVocabularyMeaning);
    final isCompleted = prefs.getBool(StorageKeys.isCompleted) ?? false;
    final streak = prefs.getInt(StorageKeys.streakCount) ?? 0;
    final level = prefs.getInt(StorageKeys.petLevel) ?? 1;
    
    FetchPetWidgetState state;
    String message;
    
    if (isCompleted) {
      state = FetchPetWidgetState.completed;
      message = '잘했어요! 💕';
    } else if (result != null) {
      state = FetchPetWidgetState.result;
      if (category == DeckCategory.vocabulary.id && vocabularyMeaning != null) {
        message = '$result\n$vocabularyMeaning';
      } else {
        message = result;
      }
    } else {
      state = FetchPetWidgetState.waiting;
      message = '주인님, 오늘 뭐 할까?';
    }
    
    await updateAllWidgetData(
      state: state,
      message: message,
      result: result,
      petState: isCompleted ? 'happy' : 'default',
      streak: streak,
      level: level,
    );
  }

  /// 위젯 갱신 요청
  Future<void> _updateWidget() async {
    await HomeWidget.updateWidget(
      androidName: _androidWidgetProvider,
      iOSName: 'FetchPetWidget',
    );
  }

  /// 초기 위젯 데이터 로드 (위젯에서 앱 데이터 요청 시)
  Future<Map<String, dynamic>> getWidgetData() async {
    return {
      'state': await HomeWidget.getWidgetData<String>(_widgetStateKey),
      'message': await HomeWidget.getWidgetData<String>(_widgetMessageKey),
      'result': await HomeWidget.getWidgetData<String?>(_widgetResultKey),
      'petState': await HomeWidget.getWidgetData<String>(_widgetPetStateKey),
      'streak': await HomeWidget.getWidgetData<int>(_widgetStreakKey),
      'level': await HomeWidget.getWidgetData<int>(_widgetLevelKey),
    };
  }
}

/// 위젯 상태 열거형
enum FetchPetWidgetState {
  waiting,   // 대기: "주인님, 오늘 뭐 할까?"
  loading,   // 로딩: "킁킁... (탐색 중)"
  result,    // 결과: 뼈다귀 물고 있음
  completed, // 완료: 하트 뿅뿅
  sulky,     // 삐침: "어제 굶었어..."
}
