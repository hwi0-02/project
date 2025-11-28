// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_state.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PetStateModelAdapter extends TypeAdapter<PetStateModel> {
  @override
  final int typeId = 0;

  @override
  PetStateModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PetStateModel(
      hungerPoint: fields[0] as int,
      moodPoint: fields[1] as int,
      lastAccessTime: fields[2] as DateTime?,
      level: fields[3] as int,
      experience: fields[4] as int,
      streakCount: fields[5] as int,
      equippedItems: (fields[6] as List?)?.cast<String>(),
      todayPetCount: fields[7] as int,
      lastPetDate: fields[8] as DateTime?,
      lastStreakDate: fields[9] as DateTime?,
      petName: fields[10] as String,
      petType: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, PetStateModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.hungerPoint)
      ..writeByte(1)
      ..write(obj.moodPoint)
      ..writeByte(2)
      ..write(obj.lastAccessTime)
      ..writeByte(3)
      ..write(obj.level)
      ..writeByte(4)
      ..write(obj.experience)
      ..writeByte(5)
      ..write(obj.streakCount)
      ..writeByte(6)
      ..write(obj.equippedItems)
      ..writeByte(7)
      ..write(obj.todayPetCount)
      ..writeByte(8)
      ..write(obj.lastPetDate)
      ..writeByte(9)
      ..write(obj.lastStreakDate)
      ..writeByte(10)
      ..write(obj.petName)
      ..writeByte(11)
      ..write(obj.petType);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PetStateModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
