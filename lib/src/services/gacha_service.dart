import 'dart:convert';
import 'dart:math';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/hive_models.dart';
import '../providers/hive_providers.dart';

/// 가챠 서비스
/// 기획서2.md 기반: 코인 소비 → 아이템 획득
/// 
/// OCP 원칙 적용: 아이템 데이터를 JSON에서 로드하여 코드 수정 없이 아이템 추가/수정 가능
class GachaService {
  final Random _random = Random();
  
  /// 가챠 비용
  static const int gachaCost = 50;
  
  /// JSON 파일 경로
  static const String _gachaItemsPath = 'assets/data/gacha_items.json';
  
  /// 로드된 아이템 목록
  List<ShopItem> _gachaItems = [];
  bool _isLoaded = false;
  
  /// 희귀도별 확률 (피티 미적용)
  static const Map<ItemRarity, double> _baseProbabilities = {
    ItemRarity.common: 0.70,     // 70%
    ItemRarity.rare: 0.20,       // 20%
    ItemRarity.epic: 0.08,       // 8%
    ItemRarity.legendary: 0.02,  // 2%
  };
  
  /// 피티 보장 시 확률
  static const Map<ItemRarity, double> _pityProbabilities = {
    ItemRarity.common: 0.00,     // 0%
    ItemRarity.rare: 0.80,       // 80%
    ItemRarity.epic: 0.15,       // 15%
    ItemRarity.legendary: 0.05,  // 5%
  };

  /// 아이템 데이터 로드 (JSON에서)
  Future<void> loadItems() async {
    if (_isLoaded) return;
    
    try {
      final jsonString = await rootBundle.loadString(_gachaItemsPath);
      final List<dynamic> jsonList = jsonDecode(jsonString);
      
      _gachaItems = jsonList.map((json) => _parseShopItem(json)).toList();
      _isLoaded = true;
    } catch (e) {
      // JSON 로드 실패 시 기본 아이템 사용
      _gachaItems = _getDefaultItems();
      _isLoaded = true;
    }
  }
  
  /// JSON에서 ShopItem 파싱
  ShopItem _parseShopItem(Map<String, dynamic> json) {
    return ShopItem(
      id: json['id'] as String,
      name: json['name'] as String,
      description: json['description'] as String,
      type: _parseItemType(json['type'] as String),
      price: json['price'] as int,
      rarity: _parseRarity(json['rarity'] as String),
      assetPath: json['assetPath'] as String,
      isGachaItem: true,
    );
  }
  
  /// 문자열을 ShopItemType으로 변환
  ShopItemType _parseItemType(String type) {
    switch (type) {
      case 'accessory':
        return ShopItemType.accessory;
      case 'background':
        return ShopItemType.background;
      case 'effect':
        return ShopItemType.effect;
      default:
        return ShopItemType.accessory;
    }
  }
  
  /// 문자열을 ItemRarity로 변환
  ItemRarity _parseRarity(String rarity) {
    switch (rarity) {
      case 'common':
        return ItemRarity.common;
      case 'rare':
        return ItemRarity.rare;
      case 'epic':
        return ItemRarity.epic;
      case 'legendary':
        return ItemRarity.legendary;
      default:
        return ItemRarity.common;
    }
  }
  
  /// 기본 아이템 (JSON 로드 실패 시 폴백)
  List<ShopItem> _getDefaultItems() {
    return [
      ShopItem(id: 'acc_ribbon', name: '리본', description: '귀여운 리본', 
        type: ShopItemType.accessory, price: 100, rarity: ItemRarity.common,
        assetPath: 'assets/items/ribbon.png', isGachaItem: true),
      ShopItem(id: 'acc_hat', name: '모자', description: '멋진 모자',
        type: ShopItemType.accessory, price: 150, rarity: ItemRarity.common,
        assetPath: 'assets/items/hat.png', isGachaItem: true),
      ShopItem(id: 'acc_glasses', name: '안경', description: '지적인 안경',
        type: ShopItemType.accessory, price: 200, rarity: ItemRarity.rare,
        assetPath: 'assets/items/glasses.png', isGachaItem: true),
    ];
  }

  /// 희귀도 결정
  ItemRarity _determineRarity(bool isPityGuaranteed) {
    final probabilities = isPityGuaranteed 
        ? _pityProbabilities 
        : _baseProbabilities;
    
    final roll = _random.nextDouble();
    double cumulative = 0;
    
    for (final entry in probabilities.entries) {
      cumulative += entry.value;
      if (roll < cumulative) {
        return entry.key;
      }
    }
    
    return ItemRarity.common;
  }

  /// 해당 희귀도의 랜덤 아이템 선택
  ShopItem _selectItem(ItemRarity rarity) {
    final itemsOfRarity = _gachaItems
        .where((item) => item.rarity == rarity)
        .toList();
    
    if (itemsOfRarity.isEmpty) {
      // 해당 희귀도가 없으면 common에서 선택
      return _gachaItems.firstWhere(
        (item) => item.rarity == ItemRarity.common,
        orElse: () => _gachaItems.first,
      );
    }
    
    return itemsOfRarity[_random.nextInt(itemsOfRarity.length)];
  }

  /// 가챠 뽑기 (비동기 - 아이템 로드 보장)
  Future<GachaResult?> pull(GachaHistory history) async {
    // 아이템이 로드되지 않았으면 로드
    if (!_isLoaded) {
      await loadItems();
    }
    
    final isPityGuaranteed = history.isPityGuaranteed;
    final rarity = _determineRarity(isPityGuaranteed);
    final item = _selectItem(rarity);
    
    return GachaResult(
      itemId: item.id,
      rarity: rarity.index,
      coinSpent: gachaCost,
    );
  }

  /// 아이템 ID로 아이템 정보 조회
  Future<ShopItem?> getItemById(String itemId) async {
    if (!_isLoaded) {
      await loadItems();
    }
    
    try {
      return _gachaItems.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// 전체 가챠 아이템 목록
  Future<List<ShopItem>> get allGachaItems async {
    if (!_isLoaded) {
      await loadItems();
    }
    return List.unmodifiable(_gachaItems);
  }
}

// 참고: gachaServiceProvider는 providers.dart에서 정의됨

/// 가챠 실행 Provider
final performGachaProvider = FutureProvider.family<GachaResult?, void>((ref, _) async {
  final wallet = ref.read(walletProvider.notifier);
  final inventory = ref.read(inventoryProvider.notifier);
  final historyNotifier = ref.read(gachaHistoryProvider.notifier);
  final history = ref.read(gachaHistoryProvider);
  // providers.dart의 gachaServiceProvider 사용
  final gachaService = GachaService();
  
  // 코인 확인 및 차감
  final success = await wallet.spendCoins(GachaService.gachaCost, '가챠');
  if (!success) return null;
  
  // 가챠 실행 (비동기)
  final result = await gachaService.pull(history);
  if (result == null) return null;
  
  // 결과 저장
  await historyNotifier.addResult(result);
  
  // 인벤토리에 아이템 추가
  await inventory.addItem(result.itemId, 'gacha');
  
  return result;
});
