// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'shop_item.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ShopItemAdapter extends TypeAdapter<ShopItem> {
  @override
  final int typeId = 6;

  @override
  ShopItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ShopItem(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as ShopItemType,
      price: fields[4] as int,
      rarity: fields[5] as ItemRarity,
      assetPath: fields[6] as String,
      unlockLevel: fields[7] as int,
      isGachaItem: fields[8] as bool,
      isPurchasable: fields[9] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, ShopItem obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.price)
      ..writeByte(5)
      ..write(obj.rarity)
      ..writeByte(6)
      ..write(obj.assetPath)
      ..writeByte(7)
      ..write(obj.unlockLevel)
      ..writeByte(8)
      ..write(obj.isGachaItem)
      ..writeByte(9)
      ..write(obj.isPurchasable);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class InventoryItemAdapter extends TypeAdapter<InventoryItem> {
  @override
  final int typeId = 7;

  @override
  InventoryItem read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return InventoryItem(
      itemId: fields[0] as String,
      quantity: fields[1] as int,
      acquiredAt: fields[2] as DateTime?,
      acquiredFrom: fields[3] as String,
    );
  }

  @override
  void write(BinaryWriter writer, InventoryItem obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.quantity)
      ..writeByte(2)
      ..write(obj.acquiredAt)
      ..writeByte(3)
      ..write(obj.acquiredFrom);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is InventoryItemAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserInventoryAdapter extends TypeAdapter<UserInventory> {
  @override
  final int typeId = 8;

  @override
  UserInventory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserInventory(
      items: (fields[0] as List?)?.cast<InventoryItem>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserInventory obj) {
    writer
      ..writeByte(1)
      ..writeByte(0)
      ..write(obj.items);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserInventoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ShopItemTypeAdapter extends TypeAdapter<ShopItemType> {
  @override
  final int typeId = 4;

  @override
  ShopItemType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ShopItemType.accessory;
      case 1:
        return ShopItemType.background;
      case 2:
        return ShopItemType.effect;
      case 3:
        return ShopItemType.food;
      case 4:
        return ShopItemType.toy;
      default:
        return ShopItemType.accessory;
    }
  }

  @override
  void write(BinaryWriter writer, ShopItemType obj) {
    switch (obj) {
      case ShopItemType.accessory:
        writer.writeByte(0);
        break;
      case ShopItemType.background:
        writer.writeByte(1);
        break;
      case ShopItemType.effect:
        writer.writeByte(2);
        break;
      case ShopItemType.food:
        writer.writeByte(3);
        break;
      case ShopItemType.toy:
        writer.writeByte(4);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ShopItemTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ItemRarityAdapter extends TypeAdapter<ItemRarity> {
  @override
  final int typeId = 5;

  @override
  ItemRarity read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ItemRarity.common;
      case 1:
        return ItemRarity.rare;
      case 2:
        return ItemRarity.epic;
      case 3:
        return ItemRarity.legendary;
      default:
        return ItemRarity.common;
    }
  }

  @override
  void write(BinaryWriter writer, ItemRarity obj) {
    switch (obj) {
      case ItemRarity.common:
        writer.writeByte(0);
        break;
      case ItemRarity.rare:
        writer.writeByte(1);
        break;
      case ItemRarity.epic:
        writer.writeByte(2);
        break;
      case ItemRarity.legendary:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ItemRarityAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
