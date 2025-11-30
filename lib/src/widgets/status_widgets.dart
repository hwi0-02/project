import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../providers/providers.dart';

/// 코인 표시 위젯 - 프리미엄 디자인
class CoinDisplayWidget extends ConsumerWidget {
  final bool showLabel;
  final double iconSize;
  final double fontSize;
  final bool compact;
  
  const CoinDisplayWidget({
    super.key,
    this.showLabel = true,
    this.iconSize = 20,
    this.fontSize = 14,
    this.compact = false,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: compact ? AppTheme.spacing8 : AppTheme.spacing12,
        vertical: compact ? AppTheme.spacing4 : AppTheme.spacing6,
      ),
      decoration: BoxDecoration(
        color: AppTheme.background,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: AppTheme.neutral200,
          width: 1,
        ),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 코인 아이콘 컨테이너
          Container(
            width: iconSize + 4,
            height: iconSize + 4,
            decoration: BoxDecoration(
              color: AppColors.coinGold.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.monetization_on_rounded,
              color: AppColors.coinGold,
              size: iconSize,
            ),
          ),
          SizedBox(width: compact ? AppTheme.spacing4 : AppTheme.spacing8),
          Text(
            _formatCoins(wallet.coins),
            style: AppTheme.textStyles.body.copyWith(
              color: AppTheme.neutral800,
              fontWeight: FontWeight.w600,
              fontSize: fontSize,
            ),
          ),
          if (showLabel && !compact) ...[
            const SizedBox(width: 2),
            Text(
              '코인',
              style: AppTheme.textStyles.caption.copyWith(
                color: AppTheme.neutral500,
                fontSize: fontSize * 0.85,
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
    } else if (coins >= 1000) {
      return '${(coins / 1000).toStringAsFixed(1)}K';
    }
    return coins.toString();
  }
}

/// 펫 상태 바 위젯 - 미니멀 프로그레스 디자인
class PetStatusBarWidget extends ConsumerWidget {
  final bool showLabels;
  
  const PetStatusBarWidget({
    super.key,
    this.showLabels = true,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing16),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
        boxShadow: AppTheme.shadowSm,
      ),
      child: Column(
        children: [
          // 포만감 바
          _StatusProgressBar(
            icon: Icons.restaurant_rounded,
            label: '포만감',
            value: petState.hungerPoint,
            maxValue: 100,
            color: _getStatusColor(petState.hungerPoint),
            isWarning: petState.isHungry,
            showLabel: showLabels,
          ),
          
          const SizedBox(height: AppTheme.spacing12),
          
          // 애정도 바
          _StatusProgressBar(
            icon: Icons.favorite_rounded,
            label: '애정도',
            value: petState.moodPoint,
            maxValue: 100,
            color: _getStatusColor(petState.moodPoint),
            isWarning: petState.isSulky,
            showLabel: showLabels,
          ),
        ],
      ),
    );
  }
  
  Color _getStatusColor(int value) {
    if (value >= 70) return AppTheme.success;
    if (value >= 40) return AppTheme.warning;
    return AppTheme.error;
  }
}

/// 상태 프로그레스 바 컴포넌트
class _StatusProgressBar extends StatelessWidget {
  final IconData icon;
  final String label;
  final int value;
  final int maxValue;
  final Color color;
  final bool isWarning;
  final bool showLabel;
  
  const _StatusProgressBar({
    required this.icon,
    required this.label,
    required this.value,
    required this.maxValue,
    required this.color,
    required this.isWarning,
    this.showLabel = true,
  });
  
  @override
  Widget build(BuildContext context) {
    final displayColor = isWarning ? AppTheme.error : color;
    final progress = (value / maxValue).clamp(0.0, 1.0);
    
    return Row(
      children: [
        // 아이콘
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(
            color: displayColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusS),
          ),
          child: Icon(
            icon,
            size: 18,
            color: displayColor,
          ),
        ),
        const SizedBox(width: AppTheme.spacing12),
        
        // 라벨과 프로그레스 바
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (showLabel)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      label,
                      style: AppTheme.textStyles.caption.copyWith(
                        color: AppTheme.neutral600,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    Text(
                      '$value%',
                      style: AppTheme.textStyles.caption.copyWith(
                        color: displayColor,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              if (showLabel) const SizedBox(height: AppTheme.spacing4),
              
              // 프로그레스 바
              Container(
                height: 6,
                decoration: BoxDecoration(
                  color: AppTheme.neutral100,
                  borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    return Stack(
                      children: [
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeOutCubic,
                          width: constraints.maxWidth * progress,
                          height: 6,
                          decoration: BoxDecoration(
                            color: displayColor,
                            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

/// 펫 정보 카드 위젯 - 현대적 카드 디자인
class PetInfoCardWidget extends ConsumerWidget {
  const PetInfoCardWidget({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final petState = ref.watch(petStateProvider);
    
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing20),
      decoration: BoxDecoration(
        color: AppTheme.surface,
        borderRadius: BorderRadius.circular(AppTheme.radiusXL),
        boxShadow: AppTheme.shadowMd,
      ),
      child: Row(
        children: [
          // 레벨 표시 - 원형 배지
          _LevelBadge(level: petState.level),
          
          const SizedBox(width: AppTheme.spacing16),
          
          // 펫 이름 및 경험치
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  petState.petName,
                  style: AppTheme.textStyles.title.copyWith(
                    color: AppTheme.neutral900,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                const SizedBox(height: AppTheme.spacing8),
                // 경험치 바
                _ExperienceBar(
                  current: petState.experience,
                  max: petState.level * 100,
                  progress: petState.levelProgress,
                ),
              ],
            ),
          ),
          
          const SizedBox(width: AppTheme.spacing12),
          
          // 연속 출석 (스트릭)
          _StreakBadge(count: petState.streakCount),
        ],
      ),
    );
  }
}

/// 레벨 배지 컴포넌트
class _LevelBadge extends StatelessWidget {
  final int level;
  
  const _LevelBadge({required this.level});
  
  @override
  Widget build(BuildContext context) {
    return Container(
      width: 56,
      height: 56,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppTheme.primary.withValues(alpha: 0.1),
        border: Border.all(
          color: AppTheme.primary.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            'Lv',
            style: AppTheme.textStyles.caption.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w500,
              fontSize: 10,
            ),
          ),
          Text(
            '$level',
            style: AppTheme.textStyles.headline.copyWith(
              color: AppTheme.primary,
              fontWeight: FontWeight.w700,
              fontSize: 20,
              height: 1,
            ),
          ),
        ],
      ),
    );
  }
}

/// 경험치 바 컴포넌트
class _ExperienceBar extends StatelessWidget {
  final int current;
  final int max;
  final double progress;
  
  const _ExperienceBar({
    required this.current,
    required this.max,
    required this.progress,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'EXP',
              style: AppTheme.textStyles.caption.copyWith(
                color: AppTheme.neutral500,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
            Text(
              '$current / $max',
              style: AppTheme.textStyles.caption.copyWith(
                color: AppTheme.neutral600,
                fontWeight: FontWeight.w500,
                fontSize: 10,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacing4),
        Container(
          height: 4,
          decoration: BoxDecoration(
            color: AppTheme.neutral100,
            borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          ),
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Stack(
                children: [
                  AnimatedContainer(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeOutCubic,
                    width: constraints.maxWidth * progress.clamp(0.0, 1.0),
                    height: 4,
                    decoration: BoxDecoration(
                      color: AppTheme.primary,
                      borderRadius: BorderRadius.circular(AppTheme.radiusFull),
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ],
    );
  }
}

/// 스트릭 배지 컴포넌트
class _StreakBadge extends StatelessWidget {
  final int count;
  
  const _StreakBadge({required this.count});
  
  @override
  Widget build(BuildContext context) {
    final isActive = count > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing12,
        vertical: AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.streakFire.withValues(alpha: 0.1)
            : AppTheme.neutral100,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.local_fire_department_rounded,
            size: 18,
            color: isActive ? AppColors.streakFire : AppTheme.neutral400,
          ),
          const SizedBox(width: AppTheme.spacing4),
          Text(
            '$count',
            style: AppTheme.textStyles.body.copyWith(
              fontWeight: FontWeight.w700,
              color: isActive ? AppColors.streakFire : AppTheme.neutral400,
            ),
          ),
        ],
      ),
    );
  }
}

/// 일일 보상 버튼 위젯 - 액션 버튼 스타일
class DailyRewardButton extends ConsumerWidget {
  const DailyRewardButton({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final wallet = ref.watch(walletProvider);
    final canClaim = wallet.canClaimDailyReward;
    
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: canClaim ? () => _claimReward(context, ref) : null,
        borderRadius: BorderRadius.circular(AppTheme.radiusM),
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacing16,
            vertical: AppTheme.spacing8,
          ),
          decoration: BoxDecoration(
            color: canClaim 
                ? AppTheme.success.withValues(alpha: 0.1)
                : AppTheme.neutral100,
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
            border: Border.all(
              color: canClaim 
                  ? AppTheme.success.withValues(alpha: 0.3)
                  : AppTheme.neutral200,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: canClaim 
                      ? AppTheme.success.withValues(alpha: 0.2)
                      : AppTheme.neutral200,
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  canClaim ? Icons.card_giftcard_rounded : Icons.check_rounded,
                  size: 14,
                  color: canClaim ? AppTheme.success : AppTheme.neutral500,
                ),
              ),
              const SizedBox(width: AppTheme.spacing8),
              Text(
                canClaim ? '일일 보상 받기' : '오늘 수령 완료',
                style: AppTheme.textStyles.label.copyWith(
                  fontWeight: FontWeight.w600,
                  color: canClaim ? AppTheme.success : AppTheme.neutral500,
                ),
              ),
            ],
          ),
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
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.monetization_on_rounded,
                  color: AppColors.coinGold,
                  size: 18,
                ),
              ),
              const SizedBox(width: AppTheme.spacing12),
              Text(
                '$reward 코인을 받았어요!',
                style: AppTheme.textStyles.body.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          backgroundColor: AppTheme.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppTheme.radiusM),
          ),
          margin: const EdgeInsets.all(AppTheme.spacing16),
        ),
      );
    }
  }
}
