import 'package:flutter/material.dart';
import '../constants/constants.dart';

/// 연속 달성 표시 위젯
/// 
/// 연속 달성 일수와 불꽃 애니메이션을 표시
class StreakIndicator extends StatefulWidget {
  final int streakCount;
  final bool animate;

  const StreakIndicator({
    super.key,
    required this.streakCount,
    this.animate = true,
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
      duration: const Duration(milliseconds: 1500),
    );
    
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
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
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        gradient: widget.streakCount >= 7
            ? const LinearGradient(
                colors: [
                  Color(0xFFFF6B6B),
                  Color(0xFFFFE66D),
                  Color(0xFF4ECDC4),
                  Color(0xFF45B7D1),
                  Color(0xFFDDA0DD),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              )
            : null,
        color: widget.streakCount >= 7 ? null : AppColors.streakBackground,
        borderRadius: BorderRadius.circular(20),
        boxShadow: widget.streakCount > 0
            ? [
                BoxShadow(
                  color: AppColors.streakFire.withValues(alpha: 0.3),
                  blurRadius: 10,
                  spreadRadius: 2,
                ),
              ]
            : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.streakCount > 0)
            AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform.scale(
                  scale: widget.animate ? _scaleAnimation.value : 1.0,
                  child: Icon(
                    Icons.local_fire_department,
                    color: _getFireColor(),
                    size: 24,
                  ),
                );
              },
            )
          else
            Icon(
              Icons.local_fire_department_outlined,
              color: AppColors.textSecondary,
              size: 24,
            ),
          const SizedBox(width: 8),
          Text(
            '${widget.streakCount}일',
            style: TextStyle(
              color: widget.streakCount >= 7 ? Colors.white : _getTextColor(),
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
          if (widget.streakCount >= 7) ...[
            const SizedBox(width: 4),
            const Text(
              '🌈',
              style: TextStyle(fontSize: 16),
            ),
          ],
        ],
      ),
    );
  }

  Color _getFireColor() {
    if (widget.streakCount >= 30) return const Color(0xFFFFD700); // 금색
    if (widget.streakCount >= 14) return AppColors.streakFire; // 주황색
    if (widget.streakCount >= 7) return Colors.white; // 무지개 배경이므로 흰색
    return AppColors.streakFire;
  }

  Color _getTextColor() {
    if (widget.streakCount >= 30) return const Color(0xFFFFD700);
    if (widget.streakCount >= 14) return AppColors.streakFire;
    if (widget.streakCount > 0) return AppColors.textPrimary;
    return AppColors.textSecondary;
  }
}
