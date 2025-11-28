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
class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<OnboardingPage> _pages = [
    const OnboardingPage(
      title: '뽑기펫에 오신 것을 환영해요! 🐕',
      description: '매일 뭘 해야 할지 고민될 때,\n귀여운 펫이 대신 골라드려요!',
      emoji: '🎉',
      backgroundColor: AppColors.primary,
    ),
    const OnboardingPage(
      title: '덱 시스템으로 공정한 뽑기',
      description: '같은 항목이 연속으로 나오지 않아요.\n덱을 다 쓰면 다시 섞어드려요!',
      emoji: '🃏',
      backgroundColor: AppColors.foodColor,
    ),
    const OnboardingPage(
      title: '미션 완료하고 펫 키우기',
      description: '뽑은 미션을 완료하면\n펫이 레벨업하고 아이템을 얻어요!',
      emoji: '✨',
      backgroundColor: AppColors.exerciseColor,
    ),
    const OnboardingPage(
      title: '위젯으로 더 빠르게!',
      description: '홈 화면에 위젯을 추가하면\n앱을 열지 않아도 바로 뽑기 가능!',
      emoji: '📱',
      backgroundColor: AppColors.studyColor,
      showWidgetGuide: true,
    ),
  ];

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < _pages.length - 1) {
      _pageController.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
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
            },
            itemCount: _pages.length,
            itemBuilder: (context, index) {
              return _buildPage(_pages[index]);
            },
          ),
          
          // 하단 네비게이션
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: _buildBottomNavigation(),
          ),
          
          // 스킵 버튼
          if (_currentPage < _pages.length - 1)
            Positioned(
              top: MediaQuery.of(context).padding.top + 16,
              right: 16,
              child: TextButton(
                onPressed: _skipOnboarding,
                child: const Text(
                  '건너뛰기',
                  style: TextStyle(color: Colors.white70),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildPage(OnboardingPage page) {
    return Container(
      color: page.backgroundColor,
      child: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            
            // 이모지
            Text(
              page.emoji,
              style: const TextStyle(fontSize: 100),
            ),
            
            const SizedBox(height: 40),
            
            // 제목
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                page.title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            const SizedBox(height: 16),
            
            // 설명
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 32),
              child: Text(
                page.description,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
              ),
            ),
            
            // 위젯 가이드 (마지막 페이지)
            if (page.showWidgetGuide) ...[
              const SizedBox(height: 32),
              _buildWidgetGuide(),
            ],
            
            const Spacer(flex: 2),
          ],
        ),
      ),
    );
  }

  Widget _buildWidgetGuide() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Text(
            '위젯 추가 방법',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildGuideStep('1', '홈 화면을 길게 누르세요'),
          _buildGuideStep('2', '"위젯 추가" 또는 "+"를 탭하세요'),
          _buildGuideStep('3', '"뽑기펫"을 찾아 추가하세요'),
        ],
      ),
    );
  }

  Widget _buildGuideStep(String number, String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Container(
            width: 28,
            height: 28,
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  color: AppColors.studyColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBottomNavigation() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        32, 
        16, 
        32, 
        MediaQuery.of(context).padding.bottom + 32,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 페이지 인디케이터
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: List.generate(_pages.length, (index) {
              return AnimatedContainer(
                duration: const Duration(milliseconds: 300),
                margin: const EdgeInsets.symmetric(horizontal: 4),
                width: _currentPage == index ? 24 : 8,
                height: 8,
                decoration: BoxDecoration(
                  color: _currentPage == index 
                      ? Colors.white 
                      : Colors.white.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(4),
                ),
              );
            }),
          ),
          
          const SizedBox(height: 24),
          
          // 다음/시작 버튼
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              onPressed: _nextPage,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: _pages[_currentPage].backgroundColor,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                _currentPage == _pages.length - 1 ? '시작하기' : '다음',
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
