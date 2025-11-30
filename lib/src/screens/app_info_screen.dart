import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:url_launcher/url_launcher.dart';
import '../constants/constants.dart';

/// 앱 정보 화면
///
/// 앱 버전, 개발자 정보, 오픈소스 라이선스 등을 표시
/// Design: Clean, professional layout with consistent styling
class AppInfoScreen extends StatefulWidget {
  const AppInfoScreen({super.key});

  @override
  State<AppInfoScreen> createState() => _AppInfoScreenState();
}

class _AppInfoScreenState extends State<AppInfoScreen> {
  String _appVersion = '1.0.0';
  String _buildNumber = '1';

  @override
  void initState() {
    super.initState();
    _loadAppInfo();
  }

  Future<void> _loadAppInfo() async {
    try {
      // package_info_plus를 사용하지 않고 pubspec.yaml에서 버전 정보 가져오기
      // 실제 앱에서는 package_info_plus 패키지를 추천
      setState(() {
        _appVersion = '1.0.0';
        _buildNumber = '1';
      });
    } catch (e) {
      // 오류 처리
    }
  }

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
          '앱 정보',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: ListView(
        padding: EdgeInsets.all(AppTheme.spacing16),
        children: [
          // 앱 로고 및 정보
          _buildAppHeader(textStyles),

          SizedBox(height: AppTheme.spacing32),

          // 버전 정보
          _buildVersionSection(textStyles),

          SizedBox(height: AppTheme.spacing16),

          Divider(color: AppTheme.neutral200, height: 1),

          SizedBox(height: AppTheme.spacing8),

          // 개발자 정보
          _buildInfoTile(
            icon: Icons.code,
            title: '개발자',
            subtitle: 'Fetch Pet Team',
            onTap: () {
              // 개발자 웹사이트나 이메일 열기
            },
            textStyles: textStyles,
          ),

          _buildInfoTile(
            icon: Icons.email_outlined,
            title: '문의하기',
            subtitle: 'support@fetchpet.app',
            onTap: () {
              _launchEmail('support@fetchpet.app');
            },
            textStyles: textStyles,
          ),

          _buildInfoTile(
            icon: Icons.bug_report_outlined,
            title: '버그 제보',
            subtitle: '문제를 발견하셨나요?',
            onTap: () {
              _launchEmail('bugs@fetchpet.app', subject: '버그 제보');
            },
            textStyles: textStyles,
          ),

          SizedBox(height: AppTheme.spacing8),
          Divider(color: AppTheme.neutral200, height: 1),
          SizedBox(height: AppTheme.spacing8),

          _buildInfoTile(
            icon: Icons.article_outlined,
            title: '서비스 이용약관',
            onTap: () {
              _launchURL('https://fetchpet.app/terms');
            },
            textStyles: textStyles,
          ),

          _buildInfoTile(
            icon: Icons.privacy_tip_outlined,
            title: '개인정보처리방침',
            onTap: () {
              _launchURL('https://fetchpet.app/privacy');
            },
            textStyles: textStyles,
          ),

          _buildInfoTile(
            icon: Icons.gavel_outlined,
            title: '오픈소스 라이선스',
            onTap: () {
              _showLicensesDialog(textStyles);
            },
            textStyles: textStyles,
          ),

          SizedBox(height: AppTheme.spacing8),
          Divider(color: AppTheme.neutral200, height: 1),
          SizedBox(height: AppTheme.spacing16),

          // 소셜 미디어
          _buildSocialSection(textStyles),

          SizedBox(height: AppTheme.spacing32),

          // 저작권
          _buildCopyrightSection(textStyles),
        ],
      ),
    );
  }

  Widget _buildAppHeader(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing24),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        border: Border.all(color: AppTheme.neutral200),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // 앱 아이콘
          Container(
            padding: EdgeInsets.all(AppTheme.spacing20),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.08),
              borderRadius: BorderRadius.circular(AppTheme.radiusXL),
              boxShadow: AppTheme.shadowMd,
            ),
            child: const Text(
              '🐕',
              style: TextStyle(fontSize: 56),
            ),
          ),

          SizedBox(height: AppTheme.spacing16),

          // 앱 이름
          Text(
            AppStrings.appName,
            style: textStyles.headline.copyWith(
              color: AppTheme.neutral900,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(height: AppTheme.spacing4),

          // 앱 부제
          Text(
            AppStrings.appSubtitle,
            style: textStyles.body.copyWith(
              color: AppTheme.neutral600,
            ),
          ),

          SizedBox(height: AppTheme.spacing8),

          // 앱 설명
          Text(
            AppStrings.appDescription,
            style: textStyles.caption.copyWith(
              color: AppTheme.neutral500,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildVersionSection(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              Icon(
                Icons.info_outline,
                color: AppTheme.primary,
                size: 22,
              ),
              SizedBox(width: AppTheme.spacing12),
              Text(
                '버전 정보',
                style: textStyles.body.copyWith(
                  color: AppTheme.neutral800,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          Container(
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing12,
              vertical: AppTheme.spacing4,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primary.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusFull),
            ),
            child: Text(
              'v$_appVersion ($_buildNumber)',
              style: textStyles.label.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile({
    required IconData icon,
    required String title,
    String? subtitle,
    required VoidCallback onTap,
    required dynamic textStyles,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Padding(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          child: Row(
            children: [
              Icon(icon, color: AppTheme.primary, size: 22),
              SizedBox(width: AppTheme.spacing16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: textStyles.body.copyWith(
                        color: AppTheme.neutral800,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    if (subtitle != null) ...[
                      SizedBox(height: AppTheme.spacing2),
                      Text(
                        subtitle,
                        style: textStyles.caption.copyWith(
                          color: AppTheme.neutral500,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: AppTheme.neutral400,
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSocialSection(dynamic textStyles) {
    return Container(
      padding: EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        border: Border.all(color: AppTheme.neutral200),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '소셜 미디어',
            style: textStyles.title.copyWith(
              color: AppTheme.neutral900,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          SizedBox(height: AppTheme.spacing16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildSocialButton(
                icon: Icons.language,
                label: '웹사이트',
                onTap: () => _launchURL('https://fetchpet.app'),
              ),
              _buildSocialButton(
                icon: Icons.facebook,
                label: 'Facebook',
                onTap: () => _launchURL('https://facebook.com/fetchpet'),
              ),
              _buildSocialButton(
                icon: Icons.camera_alt_outlined,
                label: 'Instagram',
                onTap: () => _launchURL('https://instagram.com/fetchpet'),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSocialButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing12,
          ),
          decoration: BoxDecoration(
            border: Border.all(color: AppTheme.neutral200),
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: AppTheme.primary, size: 26),
              SizedBox(height: AppTheme.spacing4),
              Text(
                label,
                style: TextStyle(
                  fontSize: 11,
                  color: AppTheme.neutral600,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCopyrightSection(dynamic textStyles) {
    return Column(
      children: [
        Text(
          '© ${DateTime.now().year} Fetch Pet Team',
          style: textStyles.caption.copyWith(
            color: AppTheme.neutral500,
          ),
          textAlign: TextAlign.center,
        ),
        SizedBox(height: AppTheme.spacing4),
        Text(
          'Made with ❤️ for pet lovers',
          style: textStyles.caption.copyWith(
            color: AppTheme.neutral500,
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Future<void> _launchURL(String urlString) async {
    try {
      final uri = Uri.parse(urlString);
      if (await canLaunchUrl(uri)) {
        await launchUrl(uri, mode: LaunchMode.externalApplication);
      } else {
        if (mounted) {
          _showErrorDialog('링크를 열 수 없습니다');
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('오류가 발생했습니다: $e');
      }
    }
  }

  Future<void> _launchEmail(String email, {String? subject}) async {
    final Uri emailUri = Uri(
      scheme: 'mailto',
      path: email,
      query: subject != null ? 'subject=$subject' : null,
    );

    try {
      if (await canLaunchUrl(emailUri)) {
        await launchUrl(emailUri);
      } else {
        // 이메일 클라이언트가 없으면 클립보드에 복사
        await Clipboard.setData(ClipboardData(text: email));
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(
                '이메일 주소가 복사되었습니다: $email',
                style: TextStyle(color: Colors.white),
              ),
              backgroundColor: AppTheme.success,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusM),
              ),
            ),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        _showErrorDialog('이메일 앱을 열 수 없습니다');
      }
    }
  }

  void _showLicensesDialog(dynamic textStyles) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Text(
          '오픈소스 라이선스',
          style: textStyles.title.copyWith(
            color: AppTheme.neutral900,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '이 앱은 다음 오픈소스 라이브러리를 사용합니다:',
                style: textStyles.body.copyWith(
                  color: AppTheme.neutral700,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: AppTheme.spacing16),
              _buildLicenseItem('Flutter', 'BSD License'),
              _buildLicenseItem('Riverpod', 'MIT License'),
              _buildLicenseItem('Hive', 'Apache License 2.0'),
              _buildLicenseItem('RevenueCat', 'MIT License'),
              _buildLicenseItem('Google Mobile Ads', 'Google License'),
              _buildLicenseItem('Rive', 'MIT License'),
              SizedBox(height: AppTheme.spacing16),
              Text(
                '자세한 라이선스 정보는 각 패키지의 저장소를 참고하세요.',
                style: textStyles.caption.copyWith(
                  color: AppTheme.neutral500,
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
            ),
            child: Text(
              '확인',
              style: textStyles.label.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLicenseItem(String name, String license) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Row(
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.primary,
              shape: BoxShape.circle,
            ),
          ),
          SizedBox(width: AppTheme.spacing8),
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: name,
                    style: TextStyle(
                      color: AppTheme.neutral800,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  TextSpan(
                    text: ' ($license)',
                    style: TextStyle(
                      color: AppTheme.neutral500,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showErrorDialog(String message) {
    final textStyles = AppTheme.textStyles;
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusL),
        ),
        title: Row(
          children: [
            Icon(Icons.error_outline, color: AppTheme.error, size: 24),
            SizedBox(width: AppTheme.spacing8),
            Text(
              '오류',
              style: textStyles.title.copyWith(
                color: AppTheme.neutral900,
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        content: Text(
          message,
          style: textStyles.body.copyWith(
            color: AppTheme.neutral700,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.primary,
            ),
            child: Text(
              '확인',
              style: textStyles.label.copyWith(
                color: AppTheme.primary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
