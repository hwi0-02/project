import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';
import '../models/models.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';
import '../widgets/widgets.dart';
import '../providers/providers.dart';

/// 메인 화면
class MainScreen extends ConsumerStatefulWidget {
  const MainScreen({super.key});

  @override
  ConsumerState<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends ConsumerState<MainScreen> {
  late final IDeckRepository _deckRepository;
  final PetRepository _petRepository = PetRepository();
  final ResetService _resetService = ResetService();
  final AdService _adService = AdService();
  late final PurchaseRepository _purchaseRepository;
  late final WidgetSyncService _widgetSyncService;
  StreamSubscription<bool>? _premiumSubscription;

  DeckCategory _selectedCategory = DeckCategory.food;
  String? _currentResult;
  VocabularyItem? _currentVocabularyItem; // 영단어 결과
  bool _isLoading = false;
  bool _isPremium = false;
  Pet _pet = Pet();

  @override
  void initState() {
    super.initState();
    _deckRepository = ref.read(deckRepositoryProvider);
    _purchaseRepository = ref.read(purchaseRepositoryProvider);
    _widgetSyncService = ref.read(widgetSyncServiceProvider);
    _initializeApp();
    _registerWidgetCallbacks();
  }

  /// 위젯 액션 콜백 등록
  void _registerWidgetCallbacks() {
    _widgetSyncService.setDrawActionCallback(() async {
      await _onDrawCategory(DeckCategory.food);
    });
    _widgetSyncService.setCompleteActionCallback(() async {
      // 미션 다이얼로그 표시
      _showMissionDialog();
    });
  }

  Future<void> _initializeApp() async {
    // 서비스 초기화
    await _deckRepository.initialize();
    await _petRepository.initialize();
    await _resetService.initialize();
    await _adService.initialize();
    
    // 프리미엄 상태 로드
    await _loadPremiumStatus();
    
    // 프리미엄 상태 스트림 구독
    _premiumSubscription = _purchaseRepository.premiumStatusStream.listen((isPremium) {
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
        });
      }
    });

    // 리셋 체크 (Lazy Evaluation)
    final resetResult = await _resetService.checkAndReset();
    
    // 펫 상태 로드
    _pet = _petRepository.pet;
    
    // 삐침 상태 처리
    if (resetResult.isSulky) {
      _pet = _pet.copyWithState(PetState.sulky);
      await _petRepository.resetStreakDueToMiss();
    }

    // 오늘의 결과 복원
    final todayResult = await _resetService.getTodayResult();
    if (todayResult != null) {
      _currentResult = todayResult.result;
      _selectedCategory = DeckCategory.fromId(todayResult.category);
      _pet = _pet.copyWithState(PetState.result);
      if (_selectedCategory == DeckCategory.vocabulary && todayResult.vocabularyMeaning != null) {
        _currentVocabularyItem = VocabularyItem(
          word: todayResult.result,
          meaning: todayResult.vocabularyMeaning!,
        );
      } else {
        _currentVocabularyItem = null;
      }
    }

    // 위젯 동기화
    await _syncWidget();

    if (mounted) setState(() {});
  }

  /// 위젯 데이터 동기화
  Future<void> _syncWidget() async {
    final petState = ref.read(petStateProvider);
    FetchPetWidgetState widgetState;
    String message;
    
    if (_currentResult != null) {
      widgetState = FetchPetWidgetState.result;
      message = _composeResultMessage();
    } else if (petState.isSulky) {
      widgetState = FetchPetWidgetState.sulky;
      message = AppStrings.widgetSulky;
    } else {
      widgetState = FetchPetWidgetState.waiting;
      message = AppStrings.widgetWaiting;
    }
    
    await _widgetSyncService.updateAllWidgetData(
      state: widgetState,
      message: message,
      result: _currentResult,
      petState: _pet.state.id,
      streak: petState.streakCount,
      level: petState.level,
    );
  }

  Future<void> _onDrawCategory(DeckCategory category) async {
    // 햅틱 피드백: 선택 클릭
    HapticFeedback.selectionClick();
    
    // Rive 애니메이션: 뽑기 시작 (물어오기 모션)
    final riveController = ref.read(rivePetControllerProvider);
    riveController.trigger(PetAnimationTrigger.fetch);

    setState(() {
      _isLoading = true;
      _selectedCategory = category;
      _pet = _pet.copyWithState(PetState.loading);
    });

    // 위젯에 로딩 상태 전달
    await _widgetSyncService.updateWidgetState(FetchPetWidgetState.loading);
    await _widgetSyncService.updateWidgetMessage(AppStrings.widgetLoading);

    // 로딩 딜레이 (UX)
    await Future.delayed(const Duration(milliseconds: 800));

    // 뽑기 (영단어일 경우 별도 처리)
    String result;
    if (category == DeckCategory.vocabulary) {
      final vocabItem = await _deckRepository.drawVocabulary();
      _currentVocabularyItem = vocabItem;
      result = vocabItem.word; // 저장용 결과는 단어만
    } else {
      result = await _deckRepository.draw(category);
      _currentVocabularyItem = null;
    }
    await _resetService.saveTodayResult(
      result,
      category.id,
      vocabularyMeaning: _currentVocabularyItem?.meaning,
    );
    
    // Rive 애니메이션: 뽑기 완료
    riveController.completeFetch();

    setState(() {
      _currentResult = result;
      _isLoading = false;
      _pet = _pet.copyWithState(PetState.result);
    });

    // 위젯에 결과 전달
    await _syncWidget();
  }

  Future<void> _onReDraw() async {
    // 같은 카테고리에서 다시 뽑기는 무제한
    await _onDrawCategory(_selectedCategory);
  }

  /// 돌아가기: 결과 초기화하고 카테고리 선택 화면으로
  void _onGoBack() {
    HapticFeedback.lightImpact();
    setState(() {
      _currentResult = null;
      _currentVocabularyItem = null;
      _pet = _pet.copyWithState(PetState.waiting);
    });
  }

  /// 미션 완료 처리
  Future<void> _completeMission(String missionType, int coinReward) async {
    // Hive 펫 상태 업데이트: 밥 주기 (포만감 +20, 경험치 +10)
    await ref.read(petStateProvider.notifier).feed();
    
    // 코인 지급 (미션 타입별로 reason에 기록)
    await ref.read(walletProvider.notifier).earnCoins(coinReward, '$missionType 완료');
    
    // Rive 애니메이션: 먹는 모션
    final riveController = ref.read(rivePetControllerProvider);
    riveController.trigger(PetAnimationTrigger.feed);
    
    // 햅틱 피드백
    HapticFeedback.heavyImpact();

    // 알림 표시
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.celebration, color: Colors.white),
              const SizedBox(width: 8),
              Text('$missionType 완료! +$coinReward코인 🪙'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// 미션 다이얼로그 표시
  void _showMissionDialog() {
    final wallet = ref.read(walletProvider);
    
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _MissionBottomSheet(
        onExerciseComplete: () async {
          Navigator.pop(context);
          await _completeMission('운동', 30);
        },
        onStudyComplete: () async {
          Navigator.pop(context);
          await _completeMission('공부', 30);
        },
        exerciseCompletedToday: wallet.todayMissionCount('exercise') >= 3,
        studyCompletedToday: wallet.todayMissionCount('study') >= 3,
        todayExerciseCount: wallet.todayMissionCount('exercise'),
        todayStudyCount: wallet.todayMissionCount('study'),
      ),
    );
  }

  void _onSettingsPressed() {
    Navigator.pushNamed(context, '/settings');
  }

  void _onShopPressed() {
    Navigator.pushNamed(context, '/shop');
  }

  /// 프리미엄 상태 로드
  Future<void> _loadPremiumStatus() async {
    try {
      await _purchaseRepository.initialize();
      final isPremium = await _purchaseRepository.checkPremiumStatus();
      if (mounted) {
        setState(() {
          _isPremium = isPremium;
        });
      }
    } catch (e) {
      // RevenueCat 오류 시 로컬 캐시 사용
      final prefs = await SharedPreferences.getInstance();
      final cachedPremium = prefs.getBool(StorageKeys.isPremium) ?? false;
      if (mounted) {
        setState(() {
          _isPremium = cachedPremium;
        });
      }
    }
  }

  @override
  void dispose() {
    _premiumSubscription?.cancel();
    _adService.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          AppStrings.appName,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.store, color: AppColors.textPrimary),
            onPressed: _onShopPressed,
          ),
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.textPrimary),
            onPressed: _onSettingsPressed,
          ),
        ],
      ),
      body: SafeArea(
        child: Column(
          children: [
            // 상단: 트래커 (캘린더, 연속 달성)
            _buildTrackerSection(),

            // 중앙: 펫 표시
            Expanded(
              child: _buildPetSection(),
            ),

            // 버튼 영역
            _buildActionButtons(),

            // 하단: 배너 광고
            BannerAdWidget(
              adService: _adService,
              isPremium: _isPremium,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrackerSection() {
    // Hive 데이터 (펫 상태)
    final hivePetState = ref.watch(petStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // 레벨 표시
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppColors.primary.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              children: [
                Text(
                  'Lv.${hivePetState.level}',
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '${hivePetState.experience}/100 XP',
                  style: TextStyle(
                    color: AppColors.primary.withValues(alpha: 0.7),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          
          // 코인 표시 (내부에서 walletProvider 사용)
          const CoinDisplayWidget(),
          
          // 연속 달성
          Row(
            children: [
              Icon(
                Icons.local_fire_department,
                color: hivePetState.streakCount > 0 ? AppColors.streakFire : Colors.grey,
              ),
              const SizedBox(width: 4),
              Text(
                '${hivePetState.streakCount}일',
                style: TextStyle(
                  color: hivePetState.streakCount > 0 ? AppColors.streakFire : Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildPetSection() {
    final riveController = ref.watch(rivePetControllerProvider);
    
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Rive 펫 표시 (터치 시 햅틱 피드백)
        GestureDetector(
          onTap: () async {
            HapticFeedback.lightImpact();
            riveController.trigger(PetAnimationTrigger.touch);
            
            // 쓰다듬기 처리 (하루 5회 제한)
            final success = await ref.read(petStateProvider.notifier).pet();
            if (success && mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('쓰다듬기! 애정도 +5 ❤️'),
                  duration: Duration(seconds: 1),
                ),
              );
            }
          },
          child: const RivePetWidget(
            width: 180,
            height: 180,
            showStatusOverlay: false, // 상태 바는 아래에 별도 표시
          ),
        ),
        
        const SizedBox(height: 16),
        
        // 상태 바 (포만감/애정도)
        const PetStatusBarWidget(),
        
        const SizedBox(height: 24),
        
        // 메시지/결과 표시
        _buildMessageSection(),
      ],
    );
  }

  Widget _buildMessageSection() {
    String message;
    
    if (_isLoading) {
      message = AppStrings.widgetLoading;
    } else if (_pet.state == PetState.sulky) {
      message = AppStrings.widgetSulky;
    } else if (_currentResult != null) {
      // 영단어일 경우 별도 표시
      if (_selectedCategory == DeckCategory.vocabulary && _currentVocabularyItem != null) {
        return _buildVocabularyResult();
      }
      message = _currentResult!;
    } else {
      message = AppStrings.widgetWaiting;
    }

    return Column(
      children: [
        // 카테고리 뱃지 (결과가 있을 때만 표시)
        if (_currentResult != null && !_isLoading) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: _getCategoryColor(_selectedCategory).withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  _selectedCategory.emoji,
                  style: const TextStyle(fontSize: 18),
                ),
                const SizedBox(width: 6),
                Text(
                  _selectedCategory.name,
                  style: TextStyle(
                    color: _getCategoryColor(_selectedCategory),
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
        ],
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Text(
            message,
            style: TextStyle(
              fontSize: _currentResult != null && !_isLoading ? 24.0 : 18.0,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      ],
    );
  }

  /// 위젯 및 기타 영역에서 사용할 결과 메시지 구성
  String _composeResultMessage() {
    if (_selectedCategory == DeckCategory.vocabulary && _currentVocabularyItem != null) {
      return '${_currentVocabularyItem!.word}\n${_currentVocabularyItem!.meaning}';
    }
    return _currentResult ?? AppStrings.widgetWaiting;
  }

  /// 영단어 결과 위젯 (단어 + 뜻)
  Widget _buildVocabularyResult() {
    final item = _currentVocabularyItem!;
    final color = _getCategoryColor(DeckCategory.vocabulary);
    
    return Column(
      children: [
        // 카테고리 뱃지
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                DeckCategory.vocabulary.emoji,
                style: const TextStyle(fontSize: 18),
              ),
              const SizedBox(width: 6),
              Text(
                DeckCategory.vocabulary.name,
                style: TextStyle(
                  color: color,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        
        // 영단어 카드
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 24),
          margin: const EdgeInsets.symmetric(horizontal: 32),
          decoration: BoxDecoration(
            color: AppColors.cardBackground,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              // 영단어
              Text(
                item.word,
                style: const TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.bold,
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              // 구분선
              Container(
                width: 60,
                height: 2,
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.5),
                  borderRadius: BorderRadius.circular(1),
                ),
              ),
              const SizedBox(height: 12),
              // 뜻
              Text(
                item.meaning,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w500,
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ],
    );
  }

  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return AppColors.foodColor;
      case DeckCategory.exercise:
        return AppColors.exerciseColor;
      case DeckCategory.vocabulary:
        return AppColors.studyColor;
    }
  }

  Widget _buildCategoryDrawButton(DeckCategory category) {
    final color = _getCategoryColor(category);
    return ElevatedButton(
      onPressed: _isLoading ? null : () => _onDrawCategory(category),
      style: ElevatedButton.styleFrom(
        backgroundColor: color,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            category.emoji,
            style: const TextStyle(fontSize: 28),
          ),
          const SizedBox(height: 4),
          Text(
            category.name,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 뽑기 버튼 영역
          if (_currentResult == null) ...[
            // 카테고리별 뽑기 버튼 3개
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: DeckCategory.values.map((category) {
                return _buildCategoryDrawButton(category);
              }).toList(),
            ),
          ] else ...[
            // 결과가 있을 때: 돌아가기 + 다시 뽑기
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // 돌아가기 버튼 (다른 카테고리 선택)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _onGoBack,
                  icon: const Icon(Icons.arrow_back, size: 18),
                  label: const Text('돌아가기'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: const BorderSide(color: Colors.grey),
                    foregroundColor: Colors.grey[700],
                  ),
                ),
                
                const SizedBox(width: 12),
                
                // 다시 뽑기 버튼 (같은 카테고리, 무제한)
                OutlinedButton.icon(
                  onPressed: _isLoading ? null : _onReDraw,
                  icon: const Icon(Icons.refresh, size: 18),
                  label: Text('다시 ${_selectedCategory.emoji}'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                    side: BorderSide(color: _getCategoryColor(_selectedCategory)),
                    foregroundColor: _getCategoryColor(_selectedCategory),
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: 16),
          
          // 미션 버튼 (항상 표시)
          _buildMissionButton(),
        ],
      ),
    );
  }

  /// 미션 버튼 (운동/공부 완료하면 코인!)
  Widget _buildMissionButton() {
    return ElevatedButton.icon(
      onPressed: _showMissionDialog,
      icon: const Icon(Icons.emoji_events, color: Colors.white),
      label: const Text(
        '미션 완료하고 코인 받기!',
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.bold,
          color: Colors.white,
        ),
      ),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppColors.primary,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        elevation: 4,
      ),
    );
  }
}

/// 미션 바텀시트
class _MissionBottomSheet extends StatelessWidget {
  final VoidCallback onExerciseComplete;
  final VoidCallback onStudyComplete;
  final bool exerciseCompletedToday;
  final bool studyCompletedToday;
  final int todayExerciseCount;
  final int todayStudyCount;

  const _MissionBottomSheet({
    required this.onExerciseComplete,
    required this.onStudyComplete,
    required this.exerciseCompletedToday,
    required this.studyCompletedToday,
    required this.todayExerciseCount,
    required this.todayStudyCount,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 핸들
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          const SizedBox(height: 20),
          
          // 타이틀
          const Text(
            '🎯 오늘의 미션',
            style: TextStyle(
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          
          const SizedBox(height: 8),
          
          Text(
            '미션을 완료하면 코인을 받을 수 있어요!\n(각 미션 하루 3회까지)',
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[600],
            ),
          ),
          
          const SizedBox(height: 24),
          
          // 운동 미션
          _buildMissionCard(
            context: context,
            emoji: '🏃',
            title: '운동 완료',
            subtitle: '오늘 운동했어요!',
            reward: 30,
            completed: exerciseCompletedToday,
            count: todayExerciseCount,
            maxCount: 3,
            color: AppColors.exerciseColor,
            onTap: onExerciseComplete,
          ),
          
          const SizedBox(height: 12),
          
          // 영단어 학습 미션
          _buildMissionCard(
            context: context,
            emoji: '📖',
            title: '영단어 학습',
            subtitle: '오늘 영단어 공부했어요!',
            reward: 30,
            completed: studyCompletedToday,
            count: todayStudyCount,
            maxCount: 3,
            color: AppColors.studyColor,
            onTap: onStudyComplete,
          ),
          
          const SizedBox(height: 24),
          
          // 닫기 버튼
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('닫기'),
          ),
          
          SizedBox(height: MediaQuery.of(context).padding.bottom),
        ],
      ),
    );
  }

  Widget _buildMissionCard({
    required BuildContext context,
    required String emoji,
    required String title,
    required String subtitle,
    required int reward,
    required bool completed,
    required int count,
    required int maxCount,
    required Color color,
    required VoidCallback onTap,
  }) {
    final canComplete = count < maxCount;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canComplete ? onTap : null,
        borderRadius: BorderRadius.circular(16),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: canComplete ? color.withValues(alpha: 0.1) : Colors.grey[100],
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: canComplete ? color.withValues(alpha: 0.3) : Colors.grey[300]!,
            ),
          ),
          child: Row(
            children: [
              // 이모지
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: canComplete ? color.withValues(alpha: 0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    emoji,
                    style: TextStyle(
                      fontSize: 28,
                      color: canComplete ? null : Colors.grey,
                    ),
                  ),
                ),
              ),
              
              const SizedBox(width: 16),
              
              // 텍스트
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: canComplete ? AppColors.textPrimary : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: TextStyle(
                        fontSize: 12,
                        color: canComplete ? Colors.grey[600] : Colors.grey,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '오늘 $count/$maxCount 완료',
                      style: TextStyle(
                        fontSize: 11,
                        color: canComplete ? color : Colors.grey,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              
              // 보상
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: canComplete ? AppColors.coinGold.withValues(alpha: 0.2) : Colors.grey[200],
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      canComplete ? Icons.monetization_on : Icons.check_circle,
                      size: 18,
                      color: canComplete ? AppColors.coinGold : Colors.grey,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      canComplete ? '+$reward' : '완료',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        color: canComplete ? AppColors.coinGold : Colors.grey,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
