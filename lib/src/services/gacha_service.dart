import 'dart:math';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/hive/hive_models.dart';
import '../providers/hive_providers.dart';

/// 가챠 서비스
/// 기획서2.md 기반: 코인 소비 → 아이템 획득
class GachaService {
  final Random _random = Random();
  
  /// 가챠 비용
  static const int gachaCost = 50;
  
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

  /// 가챠 가능한 아이템 목록 (기본 제공)
  static final List<ShopItem> _gachaItems = [
    // 악세서리
    ShopItem(id: 'acc_ribbon', name: '리본', description: '귀여운 리본', 
      type: ShopItemType.accessory, price: 100, rarity: ItemRarity.common,
      assetPath: 'assets/items/ribbon.png', isGachaItem: true),
    ShopItem(id: 'acc_hat', name: '모자', description: '멋진 모자',
      type: ShopItemType.accessory, price: 150, rarity: ItemRarity.common,
      assetPath: 'assets/items/hat.png', isGachaItem: true),
    ShopItem(id: 'acc_glasses', name: '안경', description: '지적인 안경',
      type: ShopItemType.accessory, price: 200, rarity: ItemRarity.rare,
      assetPath: 'assets/items/glasses.png', isGachaItem: true),
    ShopItem(id: 'acc_crown', name: '왕관', description: '화려한 왕관',
      type: ShopItemType.accessory, price: 500, rarity: ItemRarity.epic,
      assetPath: 'assets/items/crown.png', isGachaItem: true),
    ShopItem(id: 'acc_wings', name: '천사 날개', description: '신비로운 날개',
      type: ShopItemType.accessory, price: 1000, rarity: ItemRarity.legendary,
      assetPath: 'assets/items/wings.png', isGachaItem: true),
    
    // 배경
    ShopItem(id: 'bg_sky', name: '하늘 배경', description: '맑은 하늘',
      type: ShopItemType.background, price: 100, rarity: ItemRarity.common,
      assetPath: 'assets/backgrounds/sky.png', isGachaItem: true),
    ShopItem(id: 'bg_forest', name: '숲 배경', description: '푸른 숲',
      type: ShopItemType.background, price: 150, rarity: ItemRarity.common,
      assetPath: 'assets/backgrounds/forest.png', isGachaItem: true),
    ShopItem(id: 'bg_beach', name: '해변 배경', description: '시원한 해변',
      type: ShopItemType.background, price: 200, rarity: ItemRarity.rare,
      assetPath: 'assets/backgrounds/beach.png', isGachaItem: true),
    ShopItem(id: 'bg_space', name: '우주 배경', description: '신비로운 우주',
      type: ShopItemType.background, price: 500, rarity: ItemRarity.epic,
      assetPath: 'assets/backgrounds/space.png', isGachaItem: true),
    ShopItem(id: 'bg_rainbow', name: '무지개 배경', description: '환상의 무지개',
      type: ShopItemType.background, price: 1000, rarity: ItemRarity.legendary,
      assetPath: 'assets/backgrounds/rainbow.png', isGachaItem: true),
    
    // 이펙트
    ShopItem(id: 'fx_sparkle', name: '반짝이 이펙트', description: '반짝반짝',
      type: ShopItemType.effect, price: 100, rarity: ItemRarity.common,
      assetPath: 'assets/effects/sparkle.riv', isGachaItem: true),
    ShopItem(id: 'fx_hearts', name: '하트 이펙트', description: '사랑의 하트',
      type: ShopItemType.effect, price: 150, rarity: ItemRarity.common,
      assetPath: 'assets/effects/hearts.riv', isGachaItem: true),
    ShopItem(id: 'fx_stars', name: '별 이펙트', description: '빛나는 별',
      type: ShopItemType.effect, price: 200, rarity: ItemRarity.rare,
      assetPath: 'assets/effects/stars.riv', isGachaItem: true),
    ShopItem(id: 'fx_fire', name: '불꽃 이펙트', description: '타오르는 불꽃',
      type: ShopItemType.effect, price: 500, rarity: ItemRarity.epic,
      assetPath: 'assets/effects/fire.riv', isGachaItem: true),
    ShopItem(id: 'fx_aurora', name: '오로라 이펙트', description: '신비로운 오로라',
      type: ShopItemType.effect, price: 1000, rarity: ItemRarity.legendary,
      assetPath: 'assets/effects/aurora.riv', isGachaItem: true),
  ];

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

  /// 가챠 뽑기
  GachaResult? pull(GachaHistory history) {
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
  ShopItem? getItemById(String itemId) {
    try {
      return _gachaItems.firstWhere((item) => item.id == itemId);
    } catch (_) {
      return null;
    }
  }

  /// 전체 가챠 아이템 목록
  List<ShopItem> get allGachaItems => List.unmodifiable(_gachaItems);
}

/// 가챠 서비스 Provider
final gachaServiceProvider = Provider<GachaService>((ref) {
  return GachaService();
});

/// 가챠 실행 Provider
final performGachaProvider = FutureProvider.family<GachaResult?, void>((ref, _) async {
  final wallet = ref.read(walletProvider.notifier);
  final inventory = ref.read(inventoryProvider.notifier);
  final historyNotifier = ref.read(gachaHistoryProvider.notifier);
  final history = ref.read(gachaHistoryProvider);
  final gachaService = ref.read(gachaServiceProvider);
  
  // 코인 확인 및 차감
  final success = await wallet.spendCoins(GachaService.gachaCost, '가챠');
  if (!success) return null;
  
  // 가챠 실행
  final result = gachaService.pull(history);
  if (result == null) return null;
  
  // 결과 저장
  await historyNotifier.addResult(result);
  
  // 인벤토리에 아이템 추가
  await inventory.addItem(result.itemId, 'gacha');
  
  return result;
});
