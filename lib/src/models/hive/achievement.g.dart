// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'achievement.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class AchievementAdapter extends TypeAdapter<Achievement> {
  @override
  final int typeId = 14;

  @override
  Achievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Achievement(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      type: fields[3] as AchievementType,
      targetValue: fields[4] as int,
      rewardCoins: fields[5] as int,
      iconPath: fields[6] as String,
      isHidden: fields[7] as bool,
    );
  }

  @override
  void write(BinaryWriter writer, Achievement obj) {
    writer
      ..writeByte(8)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.type)
      ..writeByte(4)
      ..write(obj.targetValue)
      ..writeByte(5)
      ..write(obj.rewardCoins)
      ..writeByte(6)
      ..write(obj.iconPath)
      ..writeByte(7)
      ..write(obj.isHidden);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAchievementAdapter extends TypeAdapter<UserAchievement> {
  @override
  final int typeId = 15;

  @override
  UserAchievement read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAchievement(
      achievementId: fields[0] as String,
      currentValue: fields[1] as int,
      isCompleted: fields[2] as bool,
      isRewardClaimed: fields[3] as bool,
      completedAt: fields[4] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievement obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.achievementId)
      ..writeByte(1)
      ..write(obj.currentValue)
      ..writeByte(2)
      ..write(obj.isCompleted)
      ..writeByte(3)
      ..write(obj.isRewardClaimed)
      ..writeByte(4)
      ..write(obj.completedAt);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAchievementAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class BadgeAdapter extends TypeAdapter<Badge> {
  @override
  final int typeId = 16;

  @override
  Badge read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Badge(
      id: fields[0] as String,
      name: fields[1] as String,
      description: fields[2] as String,
      iconPath: fields[3] as String,
      achievementId: fields[4] as String?,
      specialCondition: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, Badge obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.description)
      ..writeByte(3)
      ..write(obj.iconPath)
      ..writeByte(4)
      ..write(obj.achievementId)
      ..writeByte(5)
      ..write(obj.specialCondition);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BadgeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class UserAchievementDataAdapter extends TypeAdapter<UserAchievementData> {
  @override
  final int typeId = 17;

  @override
  UserAchievementData read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserAchievementData(
      achievements: (fields[0] as List?)?.cast<UserAchievement>(),
      earnedBadges: (fields[1] as List?)?.cast<String>(),
      displayBadgeId: fields[2] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, UserAchievementData obj) {
    writer
      ..writeByte(3)
      ..writeByte(0)
      ..write(obj.achievements)
      ..writeByte(1)
      ..write(obj.earnedBadges)
      ..writeByte(2)
      ..write(obj.displayBadgeId);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserAchievementDataAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AchievementTypeAdapter extends TypeAdapter<AchievementType> {
  @override
  final int typeId = 13;

  @override
  AchievementType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return AchievementType.streak;
      case 1:
        return AchievementType.draw;
      case 2:
        return AchievementType.gacha;
      case 3:
        return AchievementType.level;
      case 4:
        return AchievementType.collection;
      case 5:
        return AchievementType.special;
      default:
        return AchievementType.streak;
    }
  }

  @override
  void write(BinaryWriter writer, AchievementType obj) {
    switch (obj) {
      case AchievementType.streak:
        writer.writeByte(0);
        break;
      case AchievementType.draw:
        writer.writeByte(1);
        break;
      case AchievementType.gacha:
        writer.writeByte(2);
        break;
      case AchievementType.level:
        writer.writeByte(3);
        break;
      case AchievementType.collection:
        writer.writeByte(4);
        break;
      case AchievementType.special:
        writer.writeByte(5);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AchievementTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
