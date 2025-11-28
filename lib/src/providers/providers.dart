import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../repositories/repositories.dart';

// Hive 관련 Provider들 export
export 'hive_providers.dart';
export 'deck_provider.dart';

/// 덱 리포지토리 Provider (싱글톤)
final deckRepositoryProvider = Provider<DeckRepository>((ref) {
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
