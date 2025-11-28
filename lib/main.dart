import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:home_widget/home_widget.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'src/constants/constants.dart';
import 'src/screens/screens.dart';
import 'src/services/services.dart';

/// 글로벌 키 (딥링크 처리용)
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

/// 위젯 동기화 서비스 인스턴스
final widgetSyncService = WidgetSyncService();

/// 앱 진입점
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Hive 데이터베이스 초기화
  await HiveService.init();
  
  // 홈 위젯 초기화
  await widgetSyncService.initialize();
  
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
class FetchPetApp extends StatefulWidget {
  final Uri? initialUri;
  final bool isOnboardingComplete;
  
  const FetchPetApp({
    super.key, 
    this.initialUri,
    required this.isOnboardingComplete,
  });

  @override
  State<FetchPetApp> createState() => _FetchPetAppState();
}

class _FetchPetAppState extends State<FetchPetApp> {
  @override
  void initState() {
    super.initState();
    
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
    if (navigatorKey.currentState != null) {
      navigatorKey.currentState!.pushNamedAndRemoveUntil('/main', (route) => false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: AppStrings.appName,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.primary,
          brightness: Brightness.light,
        ),
        useMaterial3: true,
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
