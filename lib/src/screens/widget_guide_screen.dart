import 'package:flutter/material.dart';
import 'dart:io';
import '../constants/constants.dart';

/// 위젯 설치 가이드 화면
///
/// Android와 iOS에 따라 다른 설치 방법을 제공
/// Design: Clean, informative layout with step-by-step instructions
class WidgetGuideScreen extends StatelessWidget {
  const WidgetGuideScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final textStyles = AppTheme.textStyles;
    
    return Scaffold(
      backgroundColor: AppTheme.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppTheme.neutral800),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '위젯 설치 가이드',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(AppTheme.spacing24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 헤더
            _buildHeader(textStyles),

            SizedBox(height: AppTheme.spacing32),

            // 플랫폼별 가이드
            if (Platform.isAndroid)
              _buildAndroidGuide(textStyles)
            else if (Platform.isIOS)
              _buildIOSGuide(textStyles)
            else
              _buildGenericGuide(textStyles),

            SizedBox(height: AppTheme.spacing32),

            // 팁 섹션
            _buildTipsSection(textStyles),

            SizedBox(height: AppTheme.spacing32),

            // 문제 해결
            _buildTroubleshootingSection(textStyles),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        children: [
          Container(
            padding: EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusL),
            ),
            child: const Text(
              '📱',
              style: TextStyle(fontSize: 36),
            ),
          ),
          SizedBox(width: AppTheme.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '홈 화면에 추가하기',
                  style: textStyles.title.copyWith(
                    color: AppTheme.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  '앱을 열지 않고도 바로 뽑기!',
                  style: textStyles.body.copyWith(
                    color: AppTheme.neutral600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAndroidGuide(dynamic textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Android 설치 방법',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildGuideStep(
          number: '1',
          title: '홈 화면 길게 누르기',
          description: '위젯을 추가하고 싶은 홈 화면의 빈 공간을 길게 누르세요.',
          icon: Icons.touch_app,
          color: AppTheme.primary,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '2',
          title: '위젯 메뉴 선택',
          description: '화면 하단이나 팝업 메뉴에서 "위젯" 또는 "Widgets"를 탭하세요.',
          icon: Icons.widgets,
          color: AppTheme.exerciseColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '3',
          title: '뽑기펫 찾기',
          description: '위젯 목록에서 "뽑기펫"을 찾아 선택하세요.',
          icon: Icons.search,
          color: AppTheme.studyColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '4',
          title: '위젯 배치',
          description: '원하는 위치에 위젯을 드래그하여 배치하세요.',
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildIOSGuide(dynamic textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'iOS 설치 방법',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildGuideStep(
          number: '1',
          title: '홈 화면 길게 누르기',
          description: '홈 화면의 앱 아이콘이나 빈 공간을 길게 누르세요.',
          icon: Icons.touch_app,
          color: AppTheme.primary,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '2',
          title: '+ 버튼 탭',
          description: '화면 좌측 상단의 "+" 버튼을 탭하세요.',
          icon: Icons.add_circle,
          color: AppTheme.exerciseColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '3',
          title: '뽑기펫 찾기',
          description: '위젯 목록에서 "뽑기펫"을 검색하거나 스크롤하여 찾으세요.',
          icon: Icons.search,
          color: AppTheme.studyColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '4',
          title: '위젯 크기 선택',
          description: '원하는 위젯 크기를 좌우로 스와이프하여 선택하세요.',
          icon: Icons.aspect_ratio,
          color: AppTheme.foodColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '5',
          title: '위젯 추가',
          description: '"위젯 추가" 버튼을 탭하고 완료를 누르세요.',
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildGenericGuide(dynamic textStyles) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '위젯 설치 방법',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w700,
          ),
        ),
        SizedBox(height: AppTheme.spacing16),
        _buildGuideStep(
          number: '1',
          title: '홈 화면 길게 누르기',
          description: '홈 화면의 빈 공간을 길게 누르세요.',
          icon: Icons.touch_app,
          color: AppTheme.primary,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '2',
          title: '위젯 메뉴 찾기',
          description: '"위젯" 또는 "+" 버튼을 찾아 탭하세요.',
          icon: Icons.widgets,
          color: AppTheme.exerciseColor,
        ),
        SizedBox(height: AppTheme.spacing12),
        _buildGuideStep(
          number: '3',
          title: '뽑기펫 추가',
          description: '"뽑기펫" 위젯을 찾아 홈 화면에 추가하세요.',
          icon: Icons.check_circle,
          color: AppTheme.success,
        ),
      ],
    );
  }

  Widget _buildGuideStep({
    required String number,
    required String title,
    required String description,
    required IconData icon,
    required Color color,
  }) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: color.withValues(alpha: 0.25),
          width: 1.5,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // 번호 아이콘
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                number,
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: color,
                ),
              ),
            ),
          ),
          SizedBox(width: AppTheme.spacing16),
          // 텍스트
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(icon, color: color, size: 18),
                    SizedBox(width: AppTheme.spacing8),
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                        color: AppTheme.neutral800,
                      ),
                    ),
                  ],
                ),
                SizedBox(height: AppTheme.spacing4),
                Text(
                  description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.neutral600,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTipsSection(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.success.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.success.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.lightbulb_outline,
                color: AppTheme.success,
                size: 22,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                '유용한 팁',
                style: textStyles.title.copyWith(
                  color: AppTheme.neutral900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildTipItem('위젯을 탭하면 앱이 바로 열려요'),
          _buildTipItem('위젯에서 바로 뽑기 버튼을 눌러 사용할 수 있어요'),
          _buildTipItem('여러 개의 위젯을 추가할 수 있어요'),
          _buildTipItem('위젯은 실시간으로 펫 상태를 표시해요'),
        ],
      ),
    );
  }

  Widget _buildTipItem(String text) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: EdgeInsets.only(top: AppTheme.spacing4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.success,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.spacing12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                fontSize: 14,
                color: AppTheme.neutral700,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingSection(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.warning.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        border: Border.all(
          color: AppTheme.warning.withValues(alpha: 0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.help_outline,
                color: AppTheme.warning,
                size: 22,
              ),
              SizedBox(width: AppTheme.spacing8),
              Text(
                '문제 해결',
                style: textStyles.title.copyWith(
                  color: AppTheme.neutral900,
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing16),
          _buildTroubleshootingItem(
            '위젯이 목록에 없어요',
            '앱을 다시 시작하거나, 기기를 재부팅해보세요.',
          ),
          _buildTroubleshootingItem(
            '위젯이 업데이트되지 않아요',
            '위젯을 제거하고 다시 추가해보세요.',
          ),
          _buildTroubleshootingItem(
            '위젯을 탭해도 반응이 없어요',
            '앱 권한을 확인하고, 앱을 다시 설치해보세요.',
          ),
        ],
      ),
    );
  }

  Widget _buildTroubleshootingItem(String problem, String solution) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.error_outline,
                size: 16,
                color: AppTheme.warning,
              ),
              SizedBox(width: AppTheme.spacing8),
              Expanded(
                child: Text(
                  problem,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.neutral800,
                  ),
                ),
              ),
            ],
          ),
          SizedBox(height: AppTheme.spacing4),
          Padding(
            padding: EdgeInsets.only(left: AppTheme.spacing24),
            child: Text(
              solution,
              style: TextStyle(
                fontSize: 13,
                color: AppTheme.neutral600,
                height: 1.5,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
