import 'package:hive/hive.dart';

part 'user_wallet.g.dart';

/// 사용자 지갑 모델 - 코인 시스템
/// 기획서2.md 기반: 코인 획득/소비/거래 내역 관리
@HiveType(typeId: 1)
class UserWallet extends HiveObject {
  /// 현재 보유 코인
  @HiveField(0)
  int coins;

  /// 총 획득 코인
  @HiveField(1)
  int totalEarned;

  /// 총 소비 코인
  @HiveField(2)
  int totalSpent;

  /// 마지막 일일 보상 수령일
  @HiveField(3)
  DateTime? lastDailyRewardDate;

  /// 거래 내역 (최근 100개)
  @HiveField(4)
  List<CoinTransaction> transactions;

  UserWallet({
    this.coins = 0,
    this.totalEarned = 0,
    this.totalSpent = 0,
    this.lastDailyRewardDate,
    List<CoinTransaction>? transactions,
  }) : transactions = transactions ?? [];

  /// 코인 획득
  void earnCoins(int amount, String reason) {
    coins += amount;
    totalEarned += amount;
    _addTransaction(CoinTransaction(
      amount: amount,
      reason: reason,
      type: TransactionType.earn,
      timestamp: DateTime.now(),
    ));
  }

  /// 코인 소비
  bool spendCoins(int amount, String reason) {
    if (coins < amount) return false;

    coins -= amount;
    totalSpent += amount;
    _addTransaction(CoinTransaction(
      amount: amount,
      reason: reason,
      type: TransactionType.spend,
      timestamp: DateTime.now(),
    ));
    return true;
  }

  /// 일일 보상 수령 가능 여부
  bool get canClaimDailyReward {
    if (lastDailyRewardDate == null) return true;

    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final lastDate = DateTime(
      lastDailyRewardDate!.year,
      lastDailyRewardDate!.month,
      lastDailyRewardDate!.day,
    );

    return lastDate != today;
  }

  /// 일일 보상 수령
  int claimDailyReward(int streakCount) {
    if (!canClaimDailyReward) return 0;

    // 기본 10코인 + 연속 출석 보너스 (streak * 2)
    final reward = 10 + (streakCount * 2);
    earnCoins(reward, '일일 보상 (연속 $streakCount일)');
    lastDailyRewardDate = DateTime.now();
    return reward;
  }

  /// 거래 내역 추가 (최대 100개 유지)
  void _addTransaction(CoinTransaction transaction) {
    transactions.insert(0, transaction);
    if (transactions.length > 100) {
      transactions = transactions.sublist(0, 100);
    }
  }

  /// 오늘 특정 미션 완료 횟수 확인
  int todayMissionCount(String missionType) {
    final now = DateTime.now();
    final todayStart = DateTime(now.year, now.month, now.day);
    
    return transactions.where((t) {
      final isSameDay = t.timestamp.isAfter(todayStart);
      final isMatchingMission = t.reason.contains(missionType) || 
                                (missionType == 'exercise' && t.reason.contains('운동')) ||
                                (missionType == 'study' && t.reason.contains('공부'));
      return isSameDay && t.type == TransactionType.earn && isMatchingMission;
    }).length;
  }
}

/// 거래 타입
@HiveType(typeId: 2)
enum TransactionType {
  @HiveField(0)
  earn,

  @HiveField(1)
  spend,
}

/// 코인 거래 내역
@HiveType(typeId: 3)
class CoinTransaction extends HiveObject {
  @HiveField(0)
  final int amount;

  @HiveField(1)
  final String reason;

  @HiveField(2)
  final TransactionType type;

  @HiveField(3)
  final DateTime timestamp;

  CoinTransaction({
    required this.amount,
    required this.reason,
    required this.type,
    required this.timestamp,
  });
}
