// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'user_wallet.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class UserWalletAdapter extends TypeAdapter<UserWallet> {
  @override
  final int typeId = 1;

  @override
  UserWallet read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return UserWallet(
      coins: fields[0] as int,
      totalEarned: fields[1] as int,
      totalSpent: fields[2] as int,
      lastDailyRewardDate: fields[3] as DateTime?,
      transactions: (fields[4] as List?)?.cast<CoinTransaction>(),
    );
  }

  @override
  void write(BinaryWriter writer, UserWallet obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.coins)
      ..writeByte(1)
      ..write(obj.totalEarned)
      ..writeByte(2)
      ..write(obj.totalSpent)
      ..writeByte(3)
      ..write(obj.lastDailyRewardDate)
      ..writeByte(4)
      ..write(obj.transactions);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is UserWalletAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class CoinTransactionAdapter extends TypeAdapter<CoinTransaction> {
  @override
  final int typeId = 3;

  @override
  CoinTransaction read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return CoinTransaction(
      amount: fields[0] as int,
      reason: fields[1] as String,
      type: fields[2] as TransactionType,
      timestamp: fields[3] as DateTime,
    );
  }

  @override
  void write(BinaryWriter writer, CoinTransaction obj) {
    writer
      ..writeByte(4)
      ..writeByte(0)
      ..write(obj.amount)
      ..writeByte(1)
      ..write(obj.reason)
      ..writeByte(2)
      ..write(obj.type)
      ..writeByte(3)
      ..write(obj.timestamp);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is CoinTransactionAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class TransactionTypeAdapter extends TypeAdapter<TransactionType> {
  @override
  final int typeId = 2;

  @override
  TransactionType read(BinaryReader reader) {
    switch (reader.readByte()) {
      case 0:
        return TransactionType.earn;
      case 1:
        return TransactionType.spend;
      default:
        return TransactionType.earn;
    }
  }

  @override
  void write(BinaryWriter writer, TransactionType obj) {
    switch (obj) {
      case TransactionType.earn:
        writer.writeByte(0);
        break;
      case TransactionType.spend:
        writer.writeByte(1);
        break;
    }
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is TransactionTypeAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
