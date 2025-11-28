import 'package:hive/hive.dart';

part 'shop_item.g.dart';

/// 상점 아이템 타입
@HiveType(typeId: 4)
enum ShopItemType {
  /// 악세서리 (펫에게 장착)
  @HiveField(0)
  accessory,

  /// 배경 (메인 화면 배경)
  @HiveField(1)
  background,

  /// 이펙트 (뽑기 시 이펙트)
  @HiveField(2)
  effect,

  /// 음식 (포만감 증가 아이템)
  @HiveField(3)
  food,

  /// 장난감 (애정도 증가 아이템)
  @HiveField(4)
  toy,
}

/// 아이템 희귀도
@HiveType(typeId: 5)
enum ItemRarity {
  @HiveField(0)
  common, // 일반 (70%)

  @HiveField(1)
  rare, // 희귀 (20%)

  @HiveField(2)
  epic, // 에픽 (8%)

  @HiveField(3)
  legendary, // 전설 (2%)
}

/// 상점 아이템 모델
@HiveType(typeId: 6)
class ShopItem extends HiveObject {
  /// 고유 ID
  @HiveField(0)
  final String id;

  /// 아이템 이름
  @HiveField(1)
  final String name;

  /// 아이템 설명
  @HiveField(2)
  final String description;

  /// 아이템 타입
  @HiveField(3)
  final ShopItemType type;

  /// 가격 (코인)
  @HiveField(4)
  final int price;

  /// 희귀도
  @HiveField(5)
  final ItemRarity rarity;

  /// 에셋 경로 (이미지/Rive 파일)
  @HiveField(6)
  final String assetPath;

  /// 해금 필요 레벨 (0 = 제한 없음)
  @HiveField(7)
  final int unlockLevel;

  /// 가챠에서 획득 가능 여부
  @HiveField(8)
  final bool isGachaItem;

  /// 상점에서 구매 가능 여부
  @HiveField(9)
  final bool isPurchasable;

  ShopItem({
    required this.id,
    required this.name,
    required this.description,
    required this.type,
    required this.price,
    required this.rarity,
    required this.assetPath,
    this.unlockLevel = 0,
    this.isGachaItem = false,
    this.isPurchasable = true,
  });
}

/// 사용자 인벤토리 아이템
@HiveType(typeId: 7)
class InventoryItem extends HiveObject {
  /// 아이템 ID (ShopItem.id 참조)
  @HiveField(0)
  final String itemId;

  /// 보유 수량
  @HiveField(1)
  int quantity;

  /// 획득 일시
  @HiveField(2)
  final DateTime acquiredAt;

  /// 획득 방법 (구매/가챠/보상)
  @HiveField(3)
  final String acquiredFrom;

  InventoryItem({
    required this.itemId,
    this.quantity = 1,
    DateTime? acquiredAt,
    required this.acquiredFrom,
  }) : acquiredAt = acquiredAt ?? DateTime.now();
}

/// 사용자 인벤토리
@HiveType(typeId: 8)
class UserInventory extends HiveObject {
  /// 보유 아이템 목록
  @HiveField(0)
  List<InventoryItem> items;

  UserInventory({List<InventoryItem>? items}) : items = items ?? [];

  /// 아이템 추가
  void addItem(String itemId, String acquiredFrom) {
    final existing = items.where((i) => i.itemId == itemId).firstOrNull;
    if (existing != null) {
      existing.quantity++;
    } else {
      items.add(InventoryItem(itemId: itemId, acquiredFrom: acquiredFrom));
    }
  }

  /// 아이템 보유 여부
  bool hasItem(String itemId) {
    return items.any((i) => i.itemId == itemId && i.quantity > 0);
  }

  /// 아이템 수량 조회
  int getQuantity(String itemId) {
    return items.where((i) => i.itemId == itemId).firstOrNull?.quantity ?? 0;
  }

  /// 아이템 사용 (수량 감소)
  bool useItem(String itemId) {
    final item = items.where((i) => i.itemId == itemId).firstOrNull;
    if (item == null || item.quantity <= 0) return false;

    item.quantity--;
    return true;
  }
}
