// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'deck_data.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class DeckDataAdapter extends TypeAdapter<DeckData> {
  @override
  final int typeId = 10;

  @override
  DeckData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return DeckData(
      category: fields[0] as DeckCategoryType,
      originalItems: (fields[1] as List).cast<String>(),
      currentItems: (fields[2] as List?)?.cast<String>(),
      lastShuffleDate: fields[3] as DateTime?,
      todayDrawCount: fields[4] as int,
      lastDrawDate: fields[5] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, DeckData obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.category)
      ..writeByte(1)
      ..write(obj.originalItems)
      ..writeByte(2)
      ..write(obj.currentItems)
      ..writeByte(3)
      ..write(obj.lastShuffleDate)
      ..writeByte(4)
      ..write(obj.todayDrawCount)
      ..writeByte(5)
      ..write(obj.lastDrawDate);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GachaResultAdapter extends TypeAdapter<GachaResult> {
  @override
  final int typeId = 11;

  @override
  GachaResult read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GachaResult(
      itemId: fields[0] as String,
      rarity: fields[1] as int,
      coinSpent: fields[3] as int,
      timestamp: fields[2] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, GachaResult obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.itemId)
      ..writeByte(1)
      ..write(obj.rarity)
      ..writeByte(2)
      ..write(obj.timestamp)
      ..writeByte(3)
      ..write(obj.coinSpent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GachaResultAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class GachaHistoryAdapter extends TypeAdapter<GachaHistory> {
  @override
  final int typeId = 12;

  @override
  GachaHistory read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GachaHistory(
      results: (fields[0] as List?)?.cast<GachaResult>(),
      totalGachaCount: fields[1] as int,
      pityCounter: fields[2] as int,
    );
  }

  @override
  void write(BinaryWriter writer, GachaHistory obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.results)
      ..writeByte(1)
      ..write(obj.totalGachaCount)
      ..writeByte(2)
      ..write(obj.pityCounter);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GachaHistoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class DeckCategoryTypeAdapter extends TypeAdapter<DeckCategoryType> {
  @override
  final int typeId = 9;

  @override
  DeckCategoryType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return DeckCategoryType.food;
      case 1:
        return DeckCategoryType.exercise;
      case 2:
        return DeckCategoryType.study;
      default:
        return DeckCategoryType.food;
    }
  }

  @override
  void write(BinaryWriter writer, DeckCategoryType obj) {
    switch (obj) {
      case DeckCategoryType.food:
        writer.writeByte(0);
        break;
      case DeckCategoryType.exercise:
        writer.writeByte(1);
        break;
      case DeckCategoryType.study:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is DeckCategoryTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
