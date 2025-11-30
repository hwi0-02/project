import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

/// 앱 전체 디자인 시스템
/// 
/// Apple Human Interface Guidelines + Material Design 3 기반
/// 미니멀하고 모던한 디자인 철학
class AppTheme {
  AppTheme._();

  // ============================================
  // 색상 시스템 (Color System)
  // ============================================
  
  /// 주 색상 팔레트
  static const Color primary = Color(0xFF5B67CA);      // 차분한 인디고
  static const Color primaryLight = Color(0xFF8E97D9);
  static const Color primaryDark = Color(0xFF3D4A9E);
  
  /// 배경 색상 (뉴트럴 톤)
  static const Color background = Color(0xFFF8F9FC);   // 아주 옅은 그레이
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF1F3F8);
  
  /// 텍스트 색상
  static const Color textPrimary = Color(0xFF1A1D26);
  static const Color textSecondary = Color(0xFF6B7280);
  static const Color textTertiary = Color(0xFF9CA3AF);
  static const Color textOnPrimary = Color(0xFFFFFFFF);
  
  /// 상태 색상 (Status Colors)
  static const Color success = Color(0xFF10B981);      // 에메랄드
  static const Color error = Color(0xFFEF4444);        // 레드
  static const Color warning = Color(0xFFF59E0B);      // 앰버
  static const Color info = Color(0xFF3B82F6);         // 블루
  
  /// 카테고리 색상 (부드러운 파스텔 톤)
  static const Color foodColor = Color(0xFFFF8A80);    // 코랄 핑크
  static const Color exerciseColor = Color(0xFF69F0AE); // 민트 그린
  static const Color studyColor = Color(0xFF82B1FF);   // 스카이 블루
  
  /// 보조 색상
  static const Color coin = Color(0xFFFFB300);         // 골드
  static const Color streak = Color(0xFFFF6D00);       // 오렌지
  static const Color premium = Color(0xFF9C27B0);      // 퍼플
  
  /// 희귀도 색상
  static const Color rarityCommon = Color(0xFF9E9E9E);
  static const Color rarityRare = Color(0xFF42A5F5);
  static const Color rarityEpic = Color(0xFFAB47BC);
  static const Color rarityLegendary = Color(0xFFFFB300);
  
  /// 구분선 및 보더
  static const Color divider = Color(0xFFE5E7EB);
  static const Color border = Color(0xFFD1D5DB);
  static const Color borderLight = Color(0xFFE5E7EB);
  
  /// 뉴트럴 그레이 스케일
  static const Color neutral50 = Color(0xFFF9FAFB);
  static const Color neutral100 = Color(0xFFF3F4F6);
  static const Color neutral200 = Color(0xFFE5E7EB);
  static const Color neutral300 = Color(0xFFD1D5DB);
  static const Color neutral400 = Color(0xFF9CA3AF);
  static const Color neutral500 = Color(0xFF6B7280);
  static const Color neutral600 = Color(0xFF4B5563);
  static const Color neutral700 = Color(0xFF374151);
  static const Color neutral800 = Color(0xFF1F2937);
  static const Color neutral900 = Color(0xFF111827);
  
  // ============================================
  // 타이포그래피 (Typography)
  // ============================================
  
  static const String fontFamily = 'Pretendard';
  
  static const TextStyle displayLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: textPrimary,
    height: 1.2,
  );
  
  static const TextStyle displayMedium = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.w700,
    letterSpacing: -0.5,
    color: textPrimary,
    height: 1.25,
  );
  
  static const TextStyle headlineLarge = TextStyle(
    fontSize: 24,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.3,
    color: textPrimary,
    height: 1.3,
  );
  
  static const TextStyle headlineMedium = TextStyle(
    fontSize: 20,
    fontWeight: FontWeight.w600,
    letterSpacing: -0.2,
    color: textPrimary,
    height: 1.35,
  );
  
  static const TextStyle titleLarge = TextStyle(
    fontSize: 18,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle titleMedium = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
  );
  
  static const TextStyle bodyLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w400,
    color: textPrimary,
    height: 1.5,
  );
  
  static const TextStyle bodyMedium = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w400,
    color: textSecondary,
    height: 1.5,
  );
  
  static const TextStyle bodySmall = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w400,
    color: textTertiary,
    height: 1.5,
  );
  
  static const TextStyle labelLarge = TextStyle(
    fontSize: 14,
    fontWeight: FontWeight.w600,
    color: textPrimary,
    height: 1.4,
    letterSpacing: 0.1,
  );
  
  static const TextStyle labelMedium = TextStyle(
    fontSize: 12,
    fontWeight: FontWeight.w500,
    color: textSecondary,
    height: 1.4,
    letterSpacing: 0.2,
  );
  
  static const TextStyle labelSmall = TextStyle(
    fontSize: 11,
    fontWeight: FontWeight.w500,
    color: textTertiary,
    height: 1.4,
    letterSpacing: 0.3,
  );
  
  // ============================================
  // 간격 시스템 (Spacing)
  // ============================================
  
  static const double spacing2 = 2;
  static const double spacing4 = 4;
  static const double spacing6 = 6;
  static const double spacing8 = 8;
  static const double spacing12 = 12;
  static const double spacing16 = 16;
  static const double spacing20 = 20;
  static const double spacing24 = 24;
  static const double spacing32 = 32;
  static const double spacing40 = 40;
  static const double spacing48 = 48;
  static const double spacing56 = 56;
  static const double spacing64 = 64;
  
  // ============================================
  // 모서리 반경 (Border Radius)
  // ============================================
  
  static const double radiusXS = 4;
  static const double radiusS = 8;
  static const double radiusM = 12;
  static const double radiusL = 16;
  static const double radiusXL = 20;
  static const double radiusXXL = 24;
  static const double radiusFull = 999;
  
  static BorderRadius get borderRadiusXS => BorderRadius.circular(radiusXS);
  static BorderRadius get borderRadiusS => BorderRadius.circular(radiusS);
  static BorderRadius get borderRadiusM => BorderRadius.circular(radiusM);
  static BorderRadius get borderRadiusL => BorderRadius.circular(radiusL);
  static BorderRadius get borderRadiusXL => BorderRadius.circular(radiusXL);
  static BorderRadius get borderRadiusXXL => BorderRadius.circular(radiusXXL);
  static BorderRadius get borderRadiusFull => BorderRadius.circular(radiusFull);
  
  // ============================================
  // 그림자 (Shadows)
  // ============================================
  
  static List<BoxShadow> get shadowSm => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowMd => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.06),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 4,
      offset: const Offset(0, 1),
    ),
  ];
  
  static List<BoxShadow> get shadowLg => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.08),
      blurRadius: 16,
      offset: const Offset(0, 4),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 6,
      offset: const Offset(0, 2),
    ),
  ];
  
  static List<BoxShadow> get shadowXl => [
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.1),
      blurRadius: 24,
      offset: const Offset(0, 8),
    ),
    BoxShadow(
      color: const Color(0xFF000000).withValues(alpha: 0.04),
      blurRadius: 8,
      offset: const Offset(0, 2),
    ),
  ];
  
  /// 컬러 섀도우 (프라이머리 버튼용)
  static List<BoxShadow> primaryShadow(Color color) => [
    BoxShadow(
      color: color.withValues(alpha: 0.3),
      blurRadius: 12,
      offset: const Offset(0, 4),
    ),
  ];
  
  // ============================================
  // 애니메이션 (Animation)
  // ============================================
  
  static const Duration durationFast = Duration(milliseconds: 150);
  static const Duration durationNormal = Duration(milliseconds: 250);
  static const Duration durationSlow = Duration(milliseconds: 400);
  
  static const Curve curveEaseOut = Curves.easeOut;
  static const Curve curveEaseInOut = Curves.easeInOut;
  static const Curve curveSpring = Curves.elasticOut;
  
  // ============================================
  // 테마 데이터 (ThemeData)
  // ============================================
  
  static ThemeData get lightTheme => ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,
    
    // 색상 스킴
    colorScheme: const ColorScheme.light(
      primary: primary,
      primaryContainer: primaryLight,
      secondary: coin,
      secondaryContainer: Color(0xFFFFF3E0),
      surface: surface,
      error: error,
      onPrimary: textOnPrimary,
      onSecondary: textPrimary,
      onSurface: textPrimary,
      onError: textOnPrimary,
    ),
    
    // 배경
    scaffoldBackgroundColor: background,
    
    // 앱바
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      elevation: 0,
      scrolledUnderElevation: 0,
      centerTitle: true,
      titleTextStyle: titleLarge,
      iconTheme: IconThemeData(color: textPrimary, size: 24),
      systemOverlayStyle: SystemUiOverlayStyle.dark,
    ),
    
    // 카드
    cardTheme: CardThemeData(
      color: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: borderRadiusL,
        side: const BorderSide(color: borderLight, width: 1),
      ),
      margin: EdgeInsets.zero,
    ),
    
    // 버튼
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: primary,
        foregroundColor: textOnPrimary,
        elevation: 0,
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusM),
        textStyle: labelLarge.copyWith(color: textOnPrimary),
      ),
    ),
    
    outlinedButtonTheme: OutlinedButtonThemeData(
      style: OutlinedButton.styleFrom(
        foregroundColor: textPrimary,
        side: const BorderSide(color: border),
        padding: const EdgeInsets.symmetric(horizontal: spacing24, vertical: spacing16),
        shape: RoundedRectangleBorder(borderRadius: borderRadiusM),
        textStyle: labelLarge,
      ),
    ),
    
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(
        foregroundColor: primary,
        padding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing12),
        textStyle: labelLarge.copyWith(color: primary),
      ),
    ),
    
    // 입력 필드
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: surfaceVariant,
      border: OutlineInputBorder(
        borderRadius: borderRadiusM,
        borderSide: BorderSide.none,
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: borderRadiusM,
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: borderRadiusM,
        borderSide: const BorderSide(color: primary, width: 1.5),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: spacing16, vertical: spacing14),
      hintStyle: bodyMedium.copyWith(color: textTertiary),
    ),
    
    // 바텀 시트
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(radiusXXL)),
      ),
      elevation: 0,
    ),
    
    // 다이얼로그
    dialogTheme: DialogThemeData(
      backgroundColor: surface,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: borderRadiusXL),
    ),
    
    // 스낵바
    snackBarTheme: SnackBarThemeData(
      backgroundColor: textPrimary,
      contentTextStyle: bodyMedium.copyWith(color: Colors.white),
      shape: RoundedRectangleBorder(borderRadius: borderRadiusM),
      behavior: SnackBarBehavior.floating,
      elevation: 0,
    ),
    
    // 탭 바
    tabBarTheme: TabBarThemeData(
      labelColor: primary,
      unselectedLabelColor: textTertiary,
      labelStyle: labelLarge,
      unselectedLabelStyle: labelLarge,
      indicatorSize: TabBarIndicatorSize.label,
      indicator: const BoxDecoration(
        border: Border(
          bottom: BorderSide(color: primary, width: 2),
        ),
      ),
    ),
    
    // 구분선
    dividerTheme: const DividerThemeData(
      color: divider,
      thickness: 1,
      space: 1,
    ),
    
    // 칩
    chipTheme: ChipThemeData(
      backgroundColor: surfaceVariant,
      labelStyle: labelMedium,
      padding: const EdgeInsets.symmetric(horizontal: spacing12, vertical: spacing8),
      shape: RoundedRectangleBorder(borderRadius: borderRadiusFull),
      side: BorderSide.none,
    ),
  );
  
  static const double spacing14 = 14;
  
  // ============================================
  // 간격 별칭 (Spacing Aliases)
  // ============================================
  
  static const double spacingXs = spacing4;
  static const double spacingSm = spacing8;
  static const double spacingMd = spacing16;
  static const double spacingLg = spacing24;
  static const double spacingXl = spacing32;
  static const double spacingXxl = spacing48;
  
  // ============================================
  // 반경 별칭 (Radius Aliases)
  // ============================================
  
  static const double radiusSm = radiusS;
  static const double radiusMd = radiusM;
  static const double radiusLg = radiusL;
  
  // ============================================
  // 텍스트 스타일 게터 (Text Styles Getter)
  // ============================================
  
  static AppTextStyles get textStyles => const AppTextStyles();
}

/// 텍스트 스타일 컨테이너
/// 
/// AppTheme.textStyles를 통해 접근하여 일관된 타이포그래피 사용
class AppTextStyles {
  const AppTextStyles();
  
  TextStyle get display => AppTheme.displayLarge;
  TextStyle get displayMedium => AppTheme.displayMedium;
  TextStyle get headline => AppTheme.headlineLarge;
  TextStyle get headlineMedium => AppTheme.headlineMedium;
  TextStyle get title => AppTheme.titleLarge;
  TextStyle get titleMedium => AppTheme.titleMedium;
  TextStyle get body => AppTheme.bodyLarge;
  TextStyle get bodyMedium => AppTheme.bodyMedium;
  TextStyle get bodySmall => AppTheme.bodySmall;
  TextStyle get label => AppTheme.labelLarge;
  TextStyle get labelLarge => AppTheme.labelLarge;
  TextStyle get labelMedium => AppTheme.labelMedium;
  TextStyle get labelSmall => AppTheme.labelSmall;
  TextStyle get caption => AppTheme.bodySmall;
}

// ============================================
// 확장 메서드 (Extension Methods)
// ============================================

extension ColorExtension on Color {
  Color darken([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
    return hslDark.toColor();
  }

  Color lighten([double amount = 0.1]) {
    assert(amount >= 0 && amount <= 1);
    final hsl = HSLColor.fromColor(this);
    final hslLight = hsl.withLightness((hsl.lightness + amount).clamp(0.0, 1.0));
    return hslLight.toColor();
  }
}
