import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// 연속 달성 표시 위젯 - 프리미엄 디자인
class StreakIndicator extends StatefulWidget {
  final int streakCount;
  final bool animate;
  final bool compact;

  const StreakIndicator({
    super.key,
    required this.streakCount,
    this.animate = true,
    this.compact = false,
  });

  @override
  State<StreakIndicator> createState() => _StreakIndicatorState();
}

class _StreakIndicatorState extends State<StreakIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.15).animate(
      CurvedAnimation(parent: _controller, curve: Curves.easeInOut),
    );
    
    if (widget.animate && widget.streakCount > 0) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(StreakIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.streakCount > 0 && widget.animate) {
      _controller.repeat(reverse: true);
    } else {
      _controller.stop();
      _controller.reset();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isActive = widget.streakCount > 0;
    final tier = _getStreakTier();
    
    return Container(
      padding: EdgeInsets.symmetric(
        horizontal: widget.compact ? AppTheme.spacing12 : AppTheme.spacing16,
        vertical: widget.compact ? AppTheme.spacing6 : AppTheme.spacing8,
      ),
      decoration: BoxDecoration(
        color: tier.backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
        border: Border.all(
          color: tier.borderColor,
          width: 1.5,
        ),
        boxShadow: isActive ? [
          BoxShadow(
            color: tier.glowColor.withValues(alpha: 0.3),
            blurRadius: 8,
            spreadRadius: 0,
          ),
        ] : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // 불꽃 아이콘
          _buildFireIcon(isActive, tier),
          SizedBox(width: widget.compact ? AppTheme.spacing4 : AppTheme.spacing8),
          // 스트릭 카운트
          Text(
            '${widget.streakCount}일',
            style: AppTheme.textStyles.label.copyWith(
              color: tier.textColor,
              fontWeight: FontWeight.w700,
              fontSize: widget.compact ? 12.0 : 14.0,
            ),
          ),
          // 특별 마일스톤 이모지
          if (tier.emoji != null) ...[
            const SizedBox(width: 4),
            Text(
              tier.emoji!,
              style: TextStyle(fontSize: widget.compact ? 12.0 : 14.0),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildFireIcon(bool isActive, _StreakTier tier) {
    final icon = Icon(
      isActive ? Icons.local_fire_department_rounded : Icons.local_fire_department_outlined,
      color: tier.iconColor,
      size: widget.compact ? 18 : 22,
    );
    
    if (!widget.animate || !isActive) {
      return icon;
    }
    
    return AnimatedBuilder(
      animation: _scaleAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: icon,
        );
      },
    );
  }

  _StreakTier _getStreakTier() {
    if (widget.streakCount >= 30) {
      return _StreakTier(
        backgroundColor: const Color(0xFFFFF8E1),
        borderColor: const Color(0xFFFFD54F),
        textColor: const Color(0xFFFF8F00),
        iconColor: const Color(0xFFFFB300),
        glowColor: const Color(0xFFFFD54F),
        emoji: '👑',
      );
    } else if (widget.streakCount >= 14) {
      return _StreakTier(
        backgroundColor: const Color(0xFFFFF3E0),
        borderColor: const Color(0xFFFF9800),
        textColor: const Color(0xFFE65100),
        iconColor: const Color(0xFFFF6D00),
        glowColor: const Color(0xFFFF9800),
        emoji: '🔥',
      );
    } else if (widget.streakCount >= 7) {
      return _StreakTier(
        backgroundColor: const Color(0xFFFFEBEE),
        borderColor: const Color(0xFFEF5350),
        textColor: const Color(0xFFC62828),
        iconColor: const Color(0xFFE53935),
        glowColor: const Color(0xFFEF5350),
        emoji: '✨',
      );
    } else if (widget.streakCount > 0) {
      return _StreakTier(
        backgroundColor: AppColors.streakFire.withValues(alpha: 0.1),
        borderColor: AppColors.streakFire.withValues(alpha: 0.3),
        textColor: AppColors.streakFire,
        iconColor: AppColors.streakFire,
        glowColor: AppColors.streakFire,
        emoji: null,
      );
    } else {
      return _StreakTier(
        backgroundColor: AppTheme.neutral100,
        borderColor: AppTheme.neutral200,
        textColor: AppTheme.neutral500,
        iconColor: AppTheme.neutral400,
        glowColor: Colors.transparent,
        emoji: null,
      );
    }
  }
}

/// 스트릭 티어 데이터
class _StreakTier {
  final Color backgroundColor;
  final Color borderColor;
  final Color textColor;
  final Color iconColor;
  final Color glowColor;
  final String? emoji;
  
  const _StreakTier({
    required this.backgroundColor,
    required this.borderColor,
    required this.textColor,
    required this.iconColor,
    required this.glowColor,
    this.emoji,
  });
}

/// 미니 스트릭 뱃지 (헤더 등에서 사용)
class MiniStreakBadge extends StatelessWidget {
  final int streakCount;
  
  const MiniStreakBadge({
    super.key,
    required this.streakCount,
  });
  
  @override
  Widget build(BuildContext context) {
    final isActive = streakCount > 0;
    
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacing8,
        vertical: AppTheme.spacing4,
      ),
      decoration: BoxDecoration(
        color: isActive 
            ? AppColors.streakFire.withValues(alpha: 0.1)
            : AppTheme.neutral100,
        borderRadius: BorderRadius.circular(AppTheme.radiusFull),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isActive 
                ? Icons.local_fire_department_rounded 
                : Icons.local_fire_department_outlined,
            color: isActive ? AppColors.streakFire : AppTheme.neutral400,
            size: 14,
          ),
          const SizedBox(width: 2),
          Text(
            '$streakCount',
            style: AppTheme.textStyles.caption.copyWith(
              color: isActive ? AppColors.streakFire : AppTheme.neutral500,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
