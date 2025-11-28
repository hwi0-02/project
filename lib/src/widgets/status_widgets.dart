import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../providers/providers.dart';

/// 코인 표시 위젯
class CoinDisplayWidget extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;
  final double fontSize;
  
  const CoinDisplayWidget({
    super.key,
    this.showLabel = true,
    this.iconSize = 24,
    this.fontSize = 16,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.coinGold.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.coinGold.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.monetization_on,
            color: AppColors.coinGold,
            size: iconSize,
          ),
          const SizedBox(width: 4),
          Text(
            _formatCoins(wallet.coins),
            style: TextStyle(
              color: AppColors.coinGold,
              fontWeight: FontWeight.bold,
              fontSize: fontSize,
            ),
          ),
          if (showLabel) ...[
            const SizedBox(width: 4),
            Text(
              '코인',
              style: TextStyle(
                color: AppColors.coinGold.withValues(alpha: 0.8),
                fontSize: fontSize * 0.8,
              ),
            ),
          ],
        ],
      ),
    );
  }
  
  String _formatCoins(int coins) {
    if (coins >= 10000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}

/// 펫 상태 바 위젯 (포만감/애정도)
class PetStatusBarWidget extends ConsumerWidget {
  const PetStatusBarWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(12),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // 포만감 바
          _buildStatusRow(
            icon: Icons.restaurant,
            label: '포만감',
            value: petState.hungerPoint,
            color: _getStatusColor(petState.hungerPoint),
            isLow: petState.isHungry,
          ),
          
          const SizedBox(height: 8),
          
          // 애정도 바
          _buildStatusRow(
            icon: Icons.favorite,
            label: '애정도',
            value: petState.moodPoint,
            color: _getStatusColor(petState.moodPoint),
            isLow: petState.isSulky,
          ),
        ],
      ),
    );
  }
  
  Widget _buildStatusRow({
    required IconData icon,
    required String label,
    required int value,
    required Color color,
    required bool isLow,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: isLow ? AppColors.error : color,
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 50,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 12,
              color: isLow ? AppColors.error : AppColors.textSecondary,
            ),
          ),
        ),
        Expanded(
          child: Stack(
            children: [
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.grey.shade200,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
              FractionallySizedBox(
                widthFactor: value / 100,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        SizedBox(
          width: 30,
          child: Text(
            '$value',
            textAlign: TextAlign.right,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.bold,
              color: isLow ? AppColors.error : color,
            ),
          ),
        ),
      ],
    );
  }
  
  Color _getStatusColor(int value) {
    if (value >= 70) return AppColors.success;
    if (value >= 40) return AppColors.warning;
    return AppColors.error;
  }
}

/// 펫 정보 카드 위젯
class PetInfoCardWidget extends ConsumerWidget {
  const PetInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(16),
      margin: const EdgeInsets.symmetric(horizontal: 16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.primary.withValues(alpha: 0.1),
            AppColors.primary.withValues(alpha: 0.05),
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppColors.primary.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          // 레벨 표시
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppColors.primary.withValues(alpha: 0.2),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Text(
                  'Lv.',
                  style: TextStyle(
                    fontSize: 10,
                    color: AppColors.primary,
                  ),
                ),
                Text(
                  '${petState.level}',
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.primary,
                  ),
                ),
              ],
            ),
          ),
          
          const SizedBox(width: 16),
          
          // 펫 이름 및 경험치
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petState.petName,
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textPrimary,
                  ),
                ),
                const SizedBox(height: 4),
                // 경험치 바
                Row(
                  children: [
                    Expanded(
                      child: Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.grey.shade200,
                              borderRadius: BorderRadius.circular(3),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: petState.levelProgress,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(3),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      '${petState.experience}/${petState.level * 100}',
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          
          // 연속 출석
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.streakFire.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.local_fire_department,
                  size: 18,
                  color: petState.streakCount > 0 
                      ? AppColors.streakFire 
                      : Colors.grey,
                ),
                const SizedBox(width: 4),
                Text(
                  '${petState.streakCount}',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: petState.streakCount > 0 
                        ? AppColors.streakFire 
                        : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// 일일 보상 버튼 위젯
class DailyRewardButton extends ConsumerWidget {
  const DailyRewardButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final canClaim = wallet.canClaimDailyReward;
    
    return InkWell(
      onTap: canClaim ? () => _claimReward(context, ref) : null,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: canClaim 
              ? AppColors.success.withValues(alpha: 0.2)
              : Colors.grey.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: canClaim 
                ? AppColors.success.withValues(alpha: 0.5)
                : Colors.grey.withValues(alpha: 0.3),
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              canClaim ? Icons.card_giftcard : Icons.check,
              size: 18,
              color: canClaim ? AppColors.success : Colors.grey,
            ),
            const SizedBox(width: 4),
            Text(
              canClaim ? '보상 받기' : '수령 완료',
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: canClaim ? AppColors.success : Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  Future<void> _claimReward(BuildContext context, WidgetRef ref) async {
    final petState = ref.read(petStateProvider);
    final walletNotifier = ref.read(walletProvider.notifier);
    
    final reward = await walletNotifier.claimDailyReward(petState.streakCount);
    
    if (reward > 0 && context.mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              const Icon(Icons.monetization_on, color: AppColors.coinGold),
              const SizedBox(width: 8),
              Text('$reward 코인을 받았어요!'),
            ],
          ),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }
}
