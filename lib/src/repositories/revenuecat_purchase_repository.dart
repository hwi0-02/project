import 'dart:async';
import 'package:purchases_flutter/purchases_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/storage_keys.dart';
import 'purchase_repository.dart';

/// RevenueCat 기반 결제 리포지토리 구현체
/// 
/// 주의: 이 파일은 UI 코드에서 직접 import하지 마세요.
/// Provider를 통해 PurchaseRepository 인터페이스로만 접근하세요.
class RevenueCatPurchaseRepository implements PurchaseRepository {
  static const String _apiKey = 'YOUR_REVENUECAT_API_KEY'; // TODO: 실제 API 키로 교체
  static const String _premiumEntitlement = 'premium';
  static const String _premiumProductId = 'premium_lifetime';

  final StreamController<bool> _premiumStatusController =
      StreamController<bool>.broadcast();
  
  bool _isPremium = false;
  bool _isInitialized = false;

  @override
  bool get isPremium => _isPremium;

  @override
  Stream<bool> get premiumStatusStream => _premiumStatusController.stream;

  @override
  Future<void> initialize() async {
    if (_isInitialized) return;

    try {
      // RevenueCat SDK 초기화
      await Purchases.configure(
        PurchasesConfiguration(_apiKey),
      );

      // 구매 상태 리스너 설정
      Purchases.addCustomerInfoUpdateListener((customerInfo) {
        _updatePremiumStatus(customerInfo);
      });

      // 초기 상태 확인
      await checkPremiumStatus();
      _isInitialized = true;
    } catch (e) {
      // SDK 초기화 실패 시 로컬 캐시 사용
      await _loadLocalPremiumStatus();
      _isInitialized = true;
    }
  }

  @override
  Future<bool> purchasePremium() async {
    try {
      // 상품 정보 가져오기
      final offerings = await Purchases.getOfferings();
      final package = offerings.current?.lifetime;

      if (package == null) {
        // 패키지가 없으면 product ID로 직접 구매 시도
        final products = await Purchases.getProducts([_premiumProductId]);
        if (products.isEmpty) return false;

        final result = await Purchases.purchaseStoreProduct(products.first);
        return _updatePremiumStatus(result);
      }

      // 구매 실행
      final result = await Purchases.purchasePackage(package);
      return _updatePremiumStatus(result);
    } catch (e) {
      // 구매 취소 또는 오류
      return false;
    }
  }

  @override
  Future<bool> restorePurchase() async {
    try {
      final customerInfo = await Purchases.restorePurchases();
      return _updatePremiumStatus(customerInfo);
    } catch (e) {
      return false;
    }
  }

  @override
  Future<bool> checkPremiumStatus() async {
    try {
      final customerInfo = await Purchases.getCustomerInfo();
      return _updatePremiumStatus(customerInfo);
    } catch (e) {
      // 오류 시 로컬 캐시 사용
      await _loadLocalPremiumStatus();
      return _isPremium;
    }
  }

  bool _updatePremiumStatus(CustomerInfo customerInfo) {
    final hasEntitlement =
        customerInfo.entitlements.active.containsKey(_premiumEntitlement);
    
    if (_isPremium != hasEntitlement) {
      _isPremium = hasEntitlement;
      _premiumStatusController.add(_isPremium);
      _savePremiumStatusLocally(_isPremium);
    }
    
    return _isPremium;
  }

  Future<void> _savePremiumStatusLocally(bool isPremium) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(StorageKeys.isPremium, isPremium);
  }

  Future<void> _loadLocalPremiumStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _isPremium = prefs.getBool(StorageKeys.isPremium) ?? false;
    _premiumStatusController.add(_isPremium);
  }

  @override
  Future<void> dispose() async {
    await _premiumStatusController.close();
  }
}
