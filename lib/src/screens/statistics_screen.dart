import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../providers/providers.dart';
import '../models/hive/hive_models.dart';

/// 통계 및 업적 화면
class StatisticsScreen extends ConsumerWidget {
  const StatisticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    final wallet = ref.watch(walletProvider);
    final gachaHistory = ref.watch(gachaHistoryProvider);
    final inventory = ref.watch(inventoryProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          '통계 및 업적',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 펫 통계
          _buildPetStatsSection(petState),

          const SizedBox(height: 16),

          // 경제 통계
          _buildEconomySection(wallet),

          const SizedBox(height: 16),

          // 가챠 통계
          _buildGachaStatsSection(gachaHistory, inventory),

          const SizedBox(height: 16),

          // 업적
          _buildAchievementsSection(petState, wallet, gachaHistory),
        ],
      ),
    );
  }

  Widget _buildPetStatsSection(dynamic petState) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.2),
            AppColors.primaryLight.withValues(alpha: 0.1),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Text('🐕', style: TextStyle(fontSize: 32)),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '펫 통계',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildStatRow('레벨', 'Lv.${petState.level}'),
          _buildStatRow('경험치', '${petState.experience} XP'),
          _buildStatRow('연속 출석', '${petState.streakCount}일'),
          _buildStatRow('최고 연속 출석', '${petState.maxStreak}일'),
          _buildStatRow('총 먹이 준 횟수', '${petState.totalFeedCount}회'),
          _buildStatRow('총 쓰다듬은 횟수', '${petState.totalPetCount}회'),
        ],
      ),
    );
  }

  Widget _buildEconomySection(dynamic wallet) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.coinGold.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.monetization_on,
                  color: AppColors.coinGold,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '경제 통계',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildStatRow(
            '보유 코인',
            '${wallet.coins}',
            valueColor: AppColors.coinGold,
          ),
          _buildStatRow(
            '총 획득한 코인',
            '${wallet.totalEarned}',
            valueColor: AppColors.success,
          ),
          _buildStatRow(
            '총 사용한 코인',
            '${wallet.totalSpent}',
            valueColor: AppColors.error,
          ),
          _buildStatRow(
            '오늘 획득한 코인',
            '${_getTodayEarned(wallet)}',
          ),
        ],
      ),
    );
  }

  Widget _buildGachaStatsSection(dynamic gachaHistory, dynamic inventory) {
    final rarityCount = _getRarityCount(gachaHistory);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.primary.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.auto_awesome,
                  color: AppColors.primary,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '가챠 통계',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          _buildStatRow('총 뽑은 횟수', '${gachaHistory.results.length}회'),
          _buildStatRow('보유 아이템', '${inventory.items.length}개'),
          _buildStatRow('피티 카운터', '${gachaHistory.pityCounter}/10'),

          const SizedBox(height: 16),

          const Text(
            '희귀도별 획득',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),

          const SizedBox(height: 12),

          _buildRarityRow(
            '전설',
            rarityCount[ItemRarity.legendary] ?? 0,
            AppColors.gachaLegendary,
          ),
          _buildRarityRow(
            '에픽',
            rarityCount[ItemRarity.epic] ?? 0,
            AppColors.gachaEpic,
          ),
          _buildRarityRow(
            '희귀',
            rarityCount[ItemRarity.rare] ?? 0,
            AppColors.gachaRare,
          ),
          _buildRarityRow(
            '일반',
            rarityCount[ItemRarity.common] ?? 0,
            Colors.grey,
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementsSection(
    dynamic petState,
    dynamic wallet,
    dynamic gachaHistory,
  ) {
    final achievements = _getAchievements(petState, wallet, gachaHistory);

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.emoji_events,
                  color: AppColors.success,
                  size: 32,
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  '업적',
                  style: TextStyle(
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),

          ...achievements.map((achievement) => _buildAchievementCard(achievement)),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textSecondary,
            ),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRarityRow(String label, int count, Color color) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            label,
            style: const TextStyle(
              fontSize: 14,
              color: AppColors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(
            '$count개',
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(Achievement achievement) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: achievement.isUnlocked
            ? AppColors.success.withValues(alpha: 0.1)
            : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: achievement.isUnlocked
              ? AppColors.success.withValues(alpha: 0.3)
              : Colors.grey.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: achievement.isUnlocked
                  ? AppColors.success.withValues(alpha: 0.2)
                  : Colors.grey.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Center(
              child: Text(
                achievement.icon,
                style: TextStyle(
                  fontSize: 28,
                  color: achievement.isUnlocked ? null : Colors.grey,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  achievement.title,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: achievement.isUnlocked
                        ? AppColors.textPrimary
                        : Colors.grey,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  achievement.description,
                  style: TextStyle(
                    fontSize: 12,
                    color: achievement.isUnlocked
                        ? AppColors.textSecondary
                        : Colors.grey,
                  ),
                ),
                if (!achievement.isUnlocked && achievement.progress != null) ...[
                  const SizedBox(height: 8),
                  LinearProgressIndicator(
                    value: achievement.progress,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(AppColors.primary),
                  ),
                ],
              ],
            ),
          ),
          if (achievement.isUnlocked)
            const Icon(
              Icons.check_circle,
              color: AppColors.success,
              size: 24,
            ),
        ],
      ),
    );
  }

  int _getTodayEarned(dynamic wallet) {
    // 오늘 획득한 코인 계산
    final today = DateTime.now();
    final todayStart = DateTime(today.year, today.month, today.day);

    int todayEarned = 0;
    for (final transaction in wallet.transactions) {
      if (transaction.timestamp.isAfter(todayStart) && transaction.amount > 0) {
        todayEarned += (transaction.amount as num).toInt();
      }
    }

    return todayEarned;
  }

  Map<ItemRarity, int> _getRarityCount(dynamic gachaHistory) {
    final Map<ItemRarity, int> count = {
      ItemRarity.common: 0,
      ItemRarity.rare: 0,
      ItemRarity.epic: 0,
      ItemRarity.legendary: 0,
    };

    for (final result in gachaHistory.results) {
      final rarity = ItemRarity.values[result.rarity];
      count[rarity] = (count[rarity] ?? 0) + 1;
    }

    return count;
  }

  List<Achievement> _getAchievements(
    dynamic petState,
    dynamic wallet,
    dynamic gachaHistory,
  ) {
    return [
      Achievement(
        icon: '🔥',
        title: '7일 연속 출석',
        description: '7일 연속으로 출석하세요',
        isUnlocked: petState.streakCount >= 7,
        progress: petState.streakCount / 7,
      ),
      Achievement(
        icon: '💯',
        title: '레벨 10 달성',
        description: '펫을 레벨 10까지 키우세요',
        isUnlocked: petState.level >= 10,
        progress: petState.level / 10,
      ),
      Achievement(
        icon: '💰',
        title: '부자',
        description: '코인 1000개를 모으세요',
        isUnlocked: wallet.coins >= 1000,
        progress: wallet.coins / 1000,
      ),
      Achievement(
        icon: '🎰',
        title: '가챠 마스터',
        description: '가챠를 50번 뽑으세요',
        isUnlocked: gachaHistory.results.length >= 50,
        progress: gachaHistory.results.length / 50,
      ),
      Achievement(
        icon: '⭐',
        title: '전설의 컬렉터',
        description: '전설 등급 아이템을 획득하세요',
        isUnlocked: _getRarityCount(gachaHistory)[ItemRarity.legendary]! > 0,
        progress: _getRarityCount(gachaHistory)[ItemRarity.legendary]! > 0 ? 1.0 : 0.0,
      ),
      Achievement(
        icon: '❤️',
        title: '애정 듬뿍',
        description: '펫을 100번 쓰다듬으세요',
        isUnlocked: petState.totalPetCount >= 100,
        progress: petState.totalPetCount / 100,
      ),
    ];
  }
}

class Achievement {
  final String icon;
  final String title;
  final String description;
  final bool isUnlocked;
  final double? progress;

  Achievement({
    required this.icon,
    required this.title,
    required this.description,
    required this.isUnlocked,
    this.progress,
  });
}
