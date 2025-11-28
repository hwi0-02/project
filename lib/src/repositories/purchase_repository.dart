/// 결제 리포지토리 추상 인터페이스
/// 
/// UI 코드는 이 인터페이스만 의존하며, RevenueCat SDK에 직접 의존하지 않습니다.
/// 추후 자체 서버로 변경 시, 새로운 구현체를 만들어 교체하면 됩니다.
abstract class PurchaseRepository {
  /// 프리미엄 구매
  /// 
  /// Returns: 구매 성공 여부
  Future<bool> purchasePremium();

  /// 구매 복원 (기기 변경 시)
  /// 
  /// Returns: 복원 성공 여부
  Future<bool> restorePurchase();

  /// 현재 구독/구매 상태 확인
  /// 
  /// Returns: 프리미엄 활성화 여부
  Future<bool> checkPremiumStatus();

  /// 프리미엄 상태 실시간 스트림
  /// 
  /// 구매 상태가 변경될 때마다 새 값을 방출합니다.
  Stream<bool> get premiumStatusStream;

  /// 현재 프리미엄 상태 (동기)
  /// 
  /// 캐시된 상태를 반환합니다. 정확한 상태는 checkPremiumStatus()를 사용하세요.
  bool get isPremium;

  /// 리포지토리 초기화
  /// 
  /// 앱 시작 시 호출하여 SDK 초기화 및 상태 복원을 수행합니다.
  Future<void> initialize();

  /// 리소스 정리
  Future<void> dispose();
}
