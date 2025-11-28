import 'dart:async';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../providers/providers.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

/// MainScreen 상태 클래스
class MainScreenState {
  final DeckCategory selectedCategory;
  final String? currentResult;
  final VocabularyItem? currentVocabularyItem;
  final bool isLoading;
  final bool isPremium;
  final Pet pet;
  final bool isInitialized;

  MainScreenState({
    this.selectedCategory = DeckCategory.food,
    this.currentResult,
    this.currentVocabularyItem,
    this.isLoading = false,
    this.isPremium = false,
    Pet? pet,
    this.isInitialized = false,
  }) : pet = pet ?? Pet();

  MainScreenState copyWith({
    DeckCategory? selectedCategory,
    String? currentResult,
    VocabularyItem? currentVocabularyItem,
    bool? isLoading,
    bool? isPremium,
    Pet? pet,
    bool? isInitialized,
    bool clearResult = false,
    bool clearVocabulary = false,
  }) {
    return MainScreenState(
      selectedCategory: selectedCategory ?? this.selectedCategory,
      currentResult: clearResult ? null : (currentResult ?? this.currentResult),
      currentVocabularyItem: clearVocabulary ? null : (currentVocabularyItem ?? this.currentVocabularyItem),
      isLoading: isLoading ?? this.isLoading,
      isPremium: isPremium ?? this.isPremium,
      pet: pet ?? this.pet,
      isInitialized: isInitialized ?? this.isInitialized,
    );
  }
}

/// Pet 불변 클래스 (const 생성자 지원)
class Pet {
  final int level;
  final int experience;
  final int streakCount;
  final PetState state;

  const Pet({
    this.level = 1,
    this.experience = 0,
    this.streakCount = 0,
    this.state = PetState.waiting,
  });

  Pet copyWith({
    int? level,
    int? experience,
    int? streakCount,
    PetState? state,
  }) {
    return Pet(
      level: level ?? this.level,
      experience: experience ?? this.experience,
      streakCount: streakCount ?? this.streakCount,
      state: state ?? this.state,
    );
  }

  Pet copyWithState(PetState newState) => copyWith(state: newState);
}

/// MainScreen 컨트롤러
/// 
/// UI 로직과 비즈니스 로직을 분리하여 테스트 용이성과 유지보수성을 높임
class MainScreenController extends StateNotifier<MainScreenState> {
  final Ref _ref;
  final IDeckRepository _deckRepository;
  final PetRepository _petRepository;
  final ResetService _resetService;
  final AdService _adService;
  final PurchaseRepository _purchaseRepository;
  final WidgetSyncService _widgetSyncService;
  
  StreamSubscription<bool>? _premiumSubscription;

  MainScreenController({
    required Ref ref,
    required IDeckRepository deckRepository,
    required PetRepository petRepository,
    required ResetService resetService,
    required AdService adService,
    required PurchaseRepository purchaseRepository,
    required WidgetSyncService widgetSyncService,
  })  : _ref = ref,
        _deckRepository = deckRepository,
        _petRepository = petRepository,
        _resetService = resetService,
        _adService = adService,
        _purchaseRepository = purchaseRepository,
        _widgetSyncService = widgetSyncService,
        super(MainScreenState());

  /// 컨트롤러 초기화
  Future<void> initialize() async {
    // 서비스 초기화
    await _deckRepository.initialize();
    await _petRepository.initialize();
    await _resetService.initialize();
    await _adService.initialize();
    
    // 프리미엄 상태 로드
    await _loadPremiumStatus();
    
    // 프리미엄 상태 스트림 구독
    _premiumSubscription = _purchaseRepository.premiumStatusStream.listen((isPremium) {
      state = state.copyWith(isPremium: isPremium);
    });

    // 리셋 체크
    final resetResult = await _resetService.checkAndReset();
    
    // 펫 상태 로드
    var pet = Pet(
      level: _petRepository.pet.level,
      experience: _petRepository.pet.experience,
      streakCount: _petRepository.pet.streakCount,
      state: _petRepository.pet.state,
    );
    
    // 삐침 상태 처리
    if (resetResult.isSulky) {
      pet = pet.copyWithState(PetState.sulky);
      await _petRepository.resetStreakDueToMiss();
    }

    // 오늘의 결과 복원
    final todayResult = await _resetService.getTodayResult();
    if (todayResult != null) {
      final category = DeckCategory.fromId(todayResult.category);
      VocabularyItem? vocabItem;
      
      if (category == DeckCategory.vocabulary && todayResult.vocabularyMeaning != null) {
        vocabItem = VocabularyItem(
          word: todayResult.result,
          meaning: todayResult.vocabularyMeaning!,
        );
      }
      
      state = state.copyWith(
        currentResult: todayResult.result,
        selectedCategory: category,
        currentVocabularyItem: vocabItem,
        pet: pet.copyWithState(PetState.result),
        isInitialized: true,
      );
    } else {
      state = state.copyWith(
        pet: pet,
        isInitialized: true,
      );
    }

    // 위젯 동기화
    await syncWidget();
  }

  /// 프리미엄 상태 로드
  Future<void> _loadPremiumStatus() async {
    try {
      await _purchaseRepository.initialize();
      final isPremium = await _purchaseRepository.checkPremiumStatus();
      state = state.copyWith(isPremium: isPremium);
    } catch (e) {
      // 오류 시 기본값 유지
    }
  }

  /// 위젯 동기화
  Future<void> syncWidget() async {
    FetchPetWidgetState widgetState;
    String message;
    
    if (state.currentResult != null) {
      widgetState = FetchPetWidgetState.result;
      message = composeResultMessage();
    } else if (state.pet.state == PetState.sulky) {
      widgetState = FetchPetWidgetState.sulky;
      message = AppStrings.widgetSulky;
    } else {
      widgetState = FetchPetWidgetState.waiting;
      message = AppStrings.widgetWaiting;
    }
    
    await _widgetSyncService.updateAllWidgetData(
      state: widgetState,
      message: message,
      result: state.currentResult,
      petState: state.pet.state.id,
      streak: state.pet.streakCount,
      level: state.pet.level,
    );
  }

  /// 결과 메시지 구성
  String composeResultMessage() {
    if (state.selectedCategory == DeckCategory.vocabulary && 
        state.currentVocabularyItem != null) {
      return '${state.currentVocabularyItem!.word}\n${state.currentVocabularyItem!.meaning}';
    }
    return state.currentResult ?? AppStrings.widgetWaiting;
  }

  /// 카테고리에서 뽑기
  Future<void> drawFromCategory(DeckCategory category) async {
    // 햅틱 피드백
    HapticFeedback.selectionClick();
    
    // Rive 애니메이션 트리거
    final riveController = _ref.read(rivePetControllerProvider);
    riveController.trigger(PetAnimationTrigger.fetch);

    state = state.copyWith(
      isLoading: true,
      selectedCategory: category,
      pet: state.pet.copyWithState(PetState.loading),
    );

    // 위젯에 로딩 상태 전달
    await _widgetSyncService.updateWidgetState(FetchPetWidgetState.loading);
    await _widgetSyncService.updateWidgetMessage(AppStrings.widgetLoading);

    // 로딩 딜레이 (UX)
    await Future.delayed(const Duration(milliseconds: 800));

    // 뽑기
    String result;
    VocabularyItem? vocabItem;
    
    if (category == DeckCategory.vocabulary) {
      vocabItem = await _deckRepository.drawVocabulary();
      result = vocabItem.word;
    } else {
      result = await _deckRepository.draw(category);
    }
    
    await _resetService.saveTodayResult(
      result,
      category.id,
      vocabularyMeaning: vocabItem?.meaning,
    );
    
    // Rive 애니메이션 완료
    riveController.completeFetch();

    state = state.copyWith(
      currentResult: result,
      currentVocabularyItem: vocabItem,
      isLoading: false,
      pet: state.pet.copyWithState(PetState.result),
    );

    await syncWidget();
  }

  /// 다시 뽑기
  Future<void> reDraw() async {
    await drawFromCategory(state.selectedCategory);
  }

  /// 돌아가기 (결과 초기화)
  void goBack() {
    HapticFeedback.lightImpact();
    state = state.copyWith(
      clearResult: true,
      clearVocabulary: true,
      pet: state.pet.copyWithState(PetState.waiting),
    );
  }

  /// 미션 완료 처리
  Future<void> completeMission(String missionType, int coinReward) async {
    // Hive 펫 상태 업데이트
    await _ref.read(petStateProvider.notifier).feed();
    
    // 코인 지급
    await _ref.read(walletProvider.notifier).earnCoins(coinReward, '$missionType 완료');
    
    // Rive 애니메이션
    final riveController = _ref.read(rivePetControllerProvider);
    riveController.trigger(PetAnimationTrigger.feed);
    
    // 햅틱 피드백
    HapticFeedback.heavyImpact();
  }

  /// 위젯 콜백 - 뽑기
  Future<void> onWidgetDrawAction() async {
    await drawFromCategory(DeckCategory.food);
  }

  /// AdService getter (View에서 사용)
  AdService get adService => _adService;

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _adService.dispose();
    super.dispose();
  }
}

/// MainScreenController Provider
final mainScreenControllerProvider = 
    StateNotifierProvider.autoDispose<MainScreenController, MainScreenState>((ref) {
  final controller = MainScreenController(
    ref: ref,
    deckRepository: ref.watch(deckRepositoryProvider),
    petRepository: ref.watch(petRepositoryProvider),
    resetService: ref.watch(resetServiceProvider),
    adService: ref.watch(adServiceProvider),
    purchaseRepository: ref.watch(purchaseRepositoryProvider),
    widgetSyncService: ref.watch(widgetSyncServiceProvider),
  );
  
  // 컨트롤러 초기화
  controller.initialize();
  
  return controller;
});
