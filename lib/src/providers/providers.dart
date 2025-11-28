import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';
import '../services/services.dart';

// Hive 관련 Provider들 export
export 'hive_providers.dart';
export 'deck_provider.dart';

/// 덱 리포지토리 Provider (인터페이스 기반)
/// 
/// IDeckRepository 인터페이스에 의존하여 테스트 용이성 확보
final deckRepositoryProvider = Provider<IDeckRepository>((ref) {
  return DeckRepository.instance;
});

/// 펫 리포지토리 Provider
final petRepositoryProvider = Provider<PetRepository>((ref) {
  return PetRepository();
});

/// 결제 리포지토리 Provider
/// 
/// UI 코드에서는 이 Provider를 통해서만 결제 기능에 접근합니다.
/// RevenueCatPurchaseRepository에 직접 의존하지 마세요.
final purchaseRepositoryProvider = Provider<PurchaseRepository>((ref) {
  return RevenueCatPurchaseRepository();
});

/// 프리미엄 상태 Provider
final isPremiumProvider = StateProvider<bool>((ref) {
  return false;
});

/// 프리미엄 상태 스트림 Provider
final premiumStreamProvider = StreamProvider<bool>((ref) {
  final purchaseRepo = ref.watch(purchaseRepositoryProvider);
  return purchaseRepo.premiumStatusStream;
});

// ============================================
// 서비스 Provider들 (전역 변수 대체)
// ============================================

/// 위젯 동기화 서비스 Provider
/// 
/// main.dart의 전역 widgetSyncService를 대체
final widgetSyncServiceProvider = Provider<WidgetSyncService>((ref) {
  return WidgetSyncService();
});

/// 리셋 서비스 Provider
final resetServiceProvider = Provider<ResetService>((ref) {
  return ResetService();
});

/// 광고 서비스 Provider
final adServiceProvider = Provider<AdService>((ref) {
  return AdService();
});

/// 가챠 서비스 Provider
final gachaServiceProvider = Provider<GachaService>((ref) {
  return GachaService();
});

/// Rive 펫 컨트롤러 Provider
/// 
/// RivePetService의 컨트롤러를 Provider로 노출
final rivePetControllerProvider = Provider<RivePetController>((ref) {
  return RivePetService.instance.controller;
});
