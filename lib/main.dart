import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/constants/constants.dart';
import 'src/screens/screens.dart';
import 'src/services/services.dart';
import 'src/providers/providers.dart';

/// 글로벌 NavigatorKey Provider
/// 딥링크 처리를 위해 필요하지만, Provider로 관리
final navigatorKeyProvider = Provider<GlobalKey<NavigatorState>>((ref) {
  return GlobalKey<NavigatorState>();
});

/// 앱 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 데이터베이스 초기화
  await HiveService.init();
  
  // 온보딩 완료 여부 확인
  final prefs = await SharedPreferences.getInstance();
  final isOnboardingComplete = prefs.getBool(StorageKeys.isOnboardingComplete) ?? false;
  
  // 홈 위젯에서 앱 실행 시 초기 URI 처리
  final initialUri = await HomeWidget.initiallyLaunchedFromHomeWidget();
  
  runApp(
    ProviderScope(
      child: FetchPetApp(
        initialUri: initialUri,
        isOnboardingComplete: isOnboardingComplete,
      ),
    ),
  );
}

/// 앱 위젯
class FetchPetApp extends ConsumerStatefulWidget {
  final Uri? initialUri;
  final bool isOnboardingComplete;
  
  const FetchPetApp({
    super.key, 
    this.initialUri,
    required this.isOnboardingComplete,
  });

  @override
  ConsumerState<FetchPetApp> createState() => _FetchPetAppState();
}

class _FetchPetAppState extends ConsumerState<FetchPetApp> {
  @override
  void initState() {
    super.initState();
    
    // 위젯 동기화 서비스 초기화
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final widgetSyncService = ref.read(widgetSyncServiceProvider);
      await widgetSyncService.initialize();
    });
    
    // 위젯 클릭 이벤트 리스너
    HomeWidget.widgetClicked.listen(_handleWidgetClick);
    
    // 초기 URI가 있으면 처리
    if (widget.initialUri != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _handleWidgetClick(widget.initialUri);
      });
    }
  }

  void _handleWidgetClick(Uri? uri) {
    if (uri == null) return;
    
    // 딥링크 액션 처리
    final action = uri.host;
    debugPrint('Widget clicked with action: $action');
    
    // 앱이 이미 MainScreen에 있으면, MainScreen 내부 콜백이 처리함
    // MainScreen에서 widgetSyncService.setDrawActionCallback / setCompleteActionCallback으로 등록됨
    
    // 위젯에서 앱을 열 때는 항상 MainScreen으로 이동
    final navigatorKey = ref.read(navigatorKeyProvider);
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final navigatorKey = ref.watch(navigatorKeyProvider);
    
    return MaterialApp(
      title: AppStrings.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppTheme.primary,
          brightness: Brightness.light,
          surface: AppTheme.surface,
        ),
        scaffoldBackgroundColor: AppTheme.background,
        useMaterial3: true,
        // AppBar 테마
        appBarTheme: AppBarTheme(
          backgroundColor: Colors.transparent,
          elevation: 0,
          scrolledUnderElevation: 0,
          centerTitle: true,
          iconTheme: IconThemeData(color: AppTheme.neutral800),
          titleTextStyle: TextStyle(
            color: AppTheme.neutral900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // 버튼 테마
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: AppTheme.primary,
            foregroundColor: Colors.white,
            elevation: 0,
            padding: EdgeInsets.symmetric(
              horizontal: AppTheme.spacing24,
              vertical: AppTheme.spacing12,
            ),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
            ),
          ),
        ),
        // TextButton 테마
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(
            foregroundColor: AppTheme.primary,
          ),
        ),
        // Dialog 테마
        dialogTheme: DialogThemeData(
          backgroundColor: AppTheme.surface,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusL),
          ),
          titleTextStyle: TextStyle(
            color: AppTheme.neutral900,
            fontSize: 18,
            fontWeight: FontWeight.w600,
          ),
        ),
        // SnackBar 테마
        snackBarTheme: SnackBarThemeData(
          backgroundColor: AppTheme.neutral800,
          contentTextStyle: TextStyle(color: Colors.white),
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
        ),
        // Divider 테마
        dividerTheme: DividerThemeData(
          color: AppTheme.neutral200,
          thickness: 1,
        ),
      ),
      initialRoute: widget.isOnboardingComplete ? '/main' : '/onboarding',
      routes: {
        '/onboarding': (context) => const OnboardingScreen(),
        '/main': (context) => const MainScreen(),
        '/settings': (context) => const SettingsScreen(),
        '/shop': (context) => const ShopScreen(),
      },
    );
  }
}
