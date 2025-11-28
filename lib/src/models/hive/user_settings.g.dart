// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserSettingsAdapter extends TypeAdapter<UserSettings> {
  @override
  final int typeId = 21;

  @override
  UserSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserSettings(
      foodSubCategory: fields[0] as FoodSubCategory,
      exerciseSubCategory: fields[1] as ExerciseSubCategory,
      vocabularyLevel: fields[2] as VocabularyLevel,
    );
  }

  @override
  void write(BinaryWriter writer, UserSettings obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.foodSubCategory)
      ..writeByte(1)
      ..write(obj.exerciseSubCategory)
      ..writeByte(2)
      ..write(obj.vocabularyLevel);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class FoodSubCategoryAdapter extends TypeAdapter<FoodSubCategory> {
  @override
  final int typeId = 18;

  @override
  FoodSubCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return FoodSubCategory.korean;
      case 1:
        return FoodSubCategory.chinese;
      case 2:
        return FoodSubCategory.japanese;
      case 3:
        return FoodSubCategory.western;
      default:
        return FoodSubCategory.korean;
    }
  }

  @override
  void write(BinaryWriter writer, FoodSubCategory obj) {
    switch (obj) {
      case FoodSubCategory.korean:
        writer.writeByte(0);
        break;
      case FoodSubCategory.chinese:
        writer.writeByte(1);
        break;
      case FoodSubCategory.japanese:
        writer.writeByte(2);
        break;
      case FoodSubCategory.western:
        writer.writeByte(3);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is FoodSubCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class ExerciseSubCategoryAdapter extends TypeAdapter<ExerciseSubCategory> {
  @override
  final int typeId = 19;

  @override
  ExerciseSubCategory read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return ExerciseSubCategory.stretching;
      case 1:
        return ExerciseSubCategory.strength;
      case 2:
        return ExerciseSubCategory.cardio;
      default:
        return ExerciseSubCategory.stretching;
    }
  }

  @override
  void write(BinaryWriter writer, ExerciseSubCategory obj) {
    switch (obj) {
      case ExerciseSubCategory.stretching:
        writer.writeByte(0);
        break;
      case ExerciseSubCategory.strength:
        writer.writeByte(1);
        break;
      case ExerciseSubCategory.cardio:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ExerciseSubCategoryAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class VocabularyLevelAdapter extends TypeAdapter<VocabularyLevel> {
  @override
  final int typeId = 20;

  @override
  VocabularyLevel read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return VocabularyLevel.beginner;
      case 1:
        return VocabularyLevel.intermediate;
      case 2:
        return VocabularyLevel.advanced;
      default:
        return VocabularyLevel.beginner;
    }
  }

  @override
  void write(BinaryWriter writer, VocabularyLevel obj) {
    switch (obj) {
      case VocabularyLevel.beginner:
        writer.writeByte(0);
        break;
      case VocabularyLevel.intermediate:
        writer.writeByte(1);
        break;
      case VocabularyLevel.advanced:
        writer.writeByte(2);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is VocabularyLevelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
