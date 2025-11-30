import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/constants.dart';

/// 온보딩 페이지 데이터
class OnboardingPage {
  final String title;
  final String description;
  final String emoji;
  final Color backgroundColor;
  final bool showWidgetGuide;

  const OnboardingPage({
    required this.title,
    required this.description,
    required this.emoji,
    required this.backgroundColor,
    this.showWidgetGuide = false,
  });
}

/// 온보딩 화면
/// 
/// 첫 실행 시 앱 소개 및 위젯 설치 가이드 제공
/// 
/// Design: Modern onboarding with subtle animations and clean typography
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> 
    with SingleTickerProviderStateMixin {
  final PageController _pageController = PageController();
  int _currentPage = 0;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<double> _scaleAnimation;

  // 새로운 디자인 시스템 색상 사용
  final List<OnboardingPage> _pages = [
    OnboardingPage(
      title: '뽑기펫에 오신 것을 환영해요!',
      description: '매일 뭘 해야 할지 고민될 때,\n귀여운 펫이 대신 골라드려요!',
      emoji: '🎉',
      backgroundColor: AppTheme.primary,
    ),
    OnboardingPage(
      title: '덱 시스템으로 공정한 뽑기',
      description: '같은 항목이 연속으로 나오지 않아요.\n덱을 다 쓰면 다시 섞어드려요!',
      emoji: '🃏',
      backgroundColor: AppTheme.foodColor,
    ),
    OnboardingPage(
      title: '미션 완료하고 펫 키우기',
      description: '뽑은 미션을 완료하면\n펫이 레벨업하고 아이템을 얻어요!',
      emoji: '✨',
      backgroundColor: AppTheme.exerciseColor,
    ),
    OnboardingPage(
      title: '위젯으로 더 빠르게!',
      description: '홈 화면에 위젯을 추가하면\n앱을 열지 않아도 바로 뽑기 가능!',
      emoji: '📱',
      backgroundColor: AppTheme.studyColor,
      showWidgetGuide: true,
    ),
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _pageController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 400),
        curve: Curves.easeInOutCubic,
      );
    } else {
      _completeOnboarding();
    }
  }

  void _skipOnboarding() {
    _completeOnboarding();
  }

  Future<void> _completeOnboarding() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isOnboardingComplete, true);
    
    if (mounted) {
      Navigator.of(context).pushReplacementNamed('/main');
    }
  }

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTheme.textStyles;
    
    return Scaffold(
      body: Stack(
        children: [
          // 페이지 뷰
          PageView.builder(
            controller: _pageController,
            onPageChanged: (index) {
              setState(() {
                _currentPage = index;
              });
              _animationController.reset();
              _animationController.forward();
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index], textStyles);
            },
          ),
          
          // 하단 네비게이션
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(textStyles),
          ),
          
          // 스킵 버튼
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + AppTheme.spacing16,
              right: AppTheme.spacing16,
              child: TextButton(
                onPressed: _skipOnboarding,
                style: TextButton.styleFrom(
                  foregroundColor: Colors.white.withValues(alpha: 0.8),
                  padding: EdgeInsets.symmetric(
                    horizontal: AppTheme.spacing16,
                    vertical: AppTheme.spacing8,
                  ),
                ),
                child: Text(
                  '건너뛰기',
                  style: textStyles.label.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page, AppTextStyles textStyles) {
    return Container(
      color: page.backgroundColor,
      child: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: ScaleTransition(
            scale: _scaleAnimation,
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Spacer(),
                
                // 이모지 with subtle shadow
                Container(
                  padding: EdgeInsets.all(AppTheme.spacing24),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    page.emoji,
                    style: const TextStyle(fontSize: 80),
                  ),
                ),
                
                SizedBox(height: AppTheme.spacing40),
                
                // 제목
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
                  child: Text(
                    page.title,
                    style: textStyles.headline.copyWith(
                      color: Colors.white,
                      fontSize: 26.0,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                SizedBox(height: AppTheme.spacing16),
                
                // 설명
                Padding(
                  padding: EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
                  child: Text(
                    page.description,
                    style: textStyles.body.copyWith(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 16.0,
                      height: 1.6,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                
                // 위젯 가이드 (마지막 페이지)
                if (page.showWidgetGuide) ...[
                  SizedBox(height: AppTheme.spacing32),
                  _buildWidgetGuide(textStyles),
                ],
                
                const Spacer(flex: 2),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWidgetGuide(AppTextStyles textStyles) {
    return Container(
      margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing32),
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Text(
            '위젯 추가 방법',
            style: textStyles.title.copyWith(
              color: Colors.white,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildGuideStep('1', '홈 화면을 길게 누르세요'),
          _buildGuideStep('2', '"위젯 추가" 또는 "+"를 탭하세요'),
          _buildGuideStep('3', '"뽑기펫"을 찾아 추가하세요'),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.1),
                  blurRadius: 4,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppTheme.studyColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14.0,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.95),
                fontSize: 14.0,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation(AppTextStyles textStyles) {
    return Container(
      padding: EdgeInsets.fromLTRB(
        AppTheme.spacing32, 
        AppTheme.spacing16, 
        AppTheme.spacing32, 
        MediaQuery.of(context).padding.bottom + AppTheme.spacing32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 페이지 인디케이터 - 모던 pill 스타일
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              final isActive = _currentPage == index;
              return AnimatedContainer(
                duration: const Duration(milliseconds: 350),
                curve: Curves.easeOutCubic,
                margin: EdgeInsets.symmetric(horizontal: AppTheme.spacing4),
                width: isActive ? 28 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: isActive 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.35),
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
              );
            }),
          ),
          
          SizedBox(height: AppTheme.spacing24),
          
          // 다음/시작 버튼 - 모던 스타일
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _pages[_currentPage].backgroundColor,
                elevation: 0,
                padding: EdgeInsets.symmetric(vertical: AppTheme.spacing16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusM),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                style: textStyles.title.copyWith(
                  color: _pages[_currentPage].backgroundColor,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
