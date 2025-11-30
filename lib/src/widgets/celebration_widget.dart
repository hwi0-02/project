import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/constants.dart';

/// 축하 효과 위젯 - 프리미엄 애니메이션
class CelebrationWidget extends StatefulWidget {
  final Widget child;
  final bool isLegendary;
  final bool isEpic;
  final VoidCallback? onComplete;

  const CelebrationWidget({
    super.key,
    required this.child,
    this.isLegendary = false,
    this.isEpic = false,
    this.onComplete,
  });

  @override
  State<CelebrationWidget> createState() => _CelebrationWidgetState();
}

class _CelebrationWidgetState extends State<CelebrationWidget>
    with TickerProviderStateMixin {
  late AnimationController _scaleController;
  late AnimationController _glowController;
  late AnimationController _particleController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _glowAnimation;

  @override
  void initState() {
    super.initState();

    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 1200),
      vsync: this,
    );

    _particleController = AnimationController(
      duration: const Duration(milliseconds: 1800),
      vsync: this,
    );

    _scaleAnimation = CurvedAnimation(
      parent: _scaleController,
      curve: Curves.elasticOut,
    );

    _glowAnimation = Tween<double>(begin: 0.3, end: 0.8).animate(
      CurvedAnimation(parent: _glowController, curve: Curves.easeInOut),
    );

    if (widget.isLegendary || widget.isEpic) {
      _startAnimation();
    }
  }

  void _startAnimation() async {
    await _scaleController.forward();
    if (widget.isLegendary) {
      _glowController.repeat(reverse: true);
    }
    _particleController.forward();

    Future.delayed(const Duration(milliseconds: 2000), () {
      widget.onComplete?.call();
    });
  }

  @override
  void dispose() {
    _scaleController.dispose();
    _glowController.dispose();
    _particleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.isLegendary && !widget.isEpic) {
      return widget.child;
    }

    final effectColor = widget.isLegendary
        ? AppColors.gachaLegendary
        : AppColors.gachaEpic;

    return Stack(
      alignment: Alignment.center,
      children: [
        // 파티클 효과
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            return CustomPaint(
              painter: _ParticlePainter(
                progress: _particleController.value,
                color: effectColor,
                particleCount: widget.isLegendary ? 40 : 25,
              ),
              size: const Size(300, 300),
            );
          },
        ),

        // 글로우 효과 (전설만)
        if (widget.isLegendary)
          AnimatedBuilder(
            animation: _glowAnimation,
            builder: (context, child) {
              return Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: effectColor.withValues(alpha: _glowAnimation.value * 0.4),
                      blurRadius: 40,
                      spreadRadius: 10,
                    ),
                  ],
                ),
              );
            },
          ),

        // 스케일 애니메이션된 자식
        ScaleTransition(
          scale: _scaleAnimation,
          child: widget.child,
        ),

        // 초기 플래시 효과
        AnimatedBuilder(
          animation: _particleController,
          builder: (context, child) {
            final flashOpacity = (1.0 - _particleController.value * 3).clamp(0.0, 1.0);
            return Opacity(
              opacity: flashOpacity,
              child: Container(
                width: 220,
                height: 220,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white.withValues(alpha: 0.3),
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}

/// 파티클 페인터 - 개선된 버전
class _ParticlePainter extends CustomPainter {
  final double progress;
  final Color color;
  final int particleCount;
  final math.Random _random = math.Random(42);

  _ParticlePainter({
    required this.progress,
    required this.color,
    required this.particleCount,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final center = Offset(size.width / 2, size.height / 2);
    final maxDistance = math.min(size.width, size.height) / 2;

    for (int i = 0; i < particleCount; i++) {
      final angle = (i / particleCount) * 2 * math.pi + (i * 0.1);
      final speedVariation = 0.6 + _random.nextDouble() * 0.4;
      final distance = progress * maxDistance * speedVariation;
      
      final wobble = math.sin(progress * math.pi * 2 + i) * 10;
      final x = center.dx + math.cos(angle) * distance + wobble;
      final y = center.dy + math.sin(angle) * distance + wobble;

      final particleSize = (1.0 - progress) * 6 * (0.5 + _random.nextDouble() * 0.5);
      final alpha = (1.0 - progress * progress) * 0.9;
      
      // 색상 변형
      final hueShift = (i / particleCount) * 30;
      final particleColor = HSLColor.fromColor(color)
          .withHue((HSLColor.fromColor(color).hue + hueShift) % 360)
          .toColor();
      
      paint.color = particleColor.withValues(alpha: alpha);
      canvas.drawCircle(Offset(x, y), particleSize, paint);
    }
  }

  @override
  bool shouldRepaint(_ParticlePainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

/// 반짝이는 효과 위젯 - 개선된 버전
class ShimmerWidget extends StatefulWidget {
  final Widget child;
  final Color color;
  final Duration duration;
  final bool enabled;

  const ShimmerWidget({
    super.key,
    required this.child,
    this.color = const Color(0xFF5B67CA),
    this.duration = const Duration(milliseconds: 1500),
    this.enabled = true,
  });

  @override
  State<ShimmerWidget> createState() => _ShimmerWidgetState();
}

class _ShimmerWidgetState extends State<ShimmerWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    if (widget.enabled) {
      _controller.repeat();
    }
  }

  @override
  void didUpdateWidget(ShimmerWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat();
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return ShaderMask(
          shaderCallback: (bounds) {
            return LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                widget.color.withValues(alpha: 0.0),
                widget.color.withValues(alpha: 0.25),
                widget.color.withValues(alpha: 0.0),
              ],
              stops: [
                (_controller.value - 0.3).clamp(0.0, 1.0),
                _controller.value.clamp(0.0, 1.0),
                (_controller.value + 0.3).clamp(0.0, 1.0),
              ],
            ).createShader(bounds);
          },
          blendMode: BlendMode.srcATop,
          child: widget.child,
        );
      },
    );
  }
}

/// 펄스 효과 위젯 - 개선된 버전
class PulseWidget extends StatefulWidget {
  final Widget child;
  final Duration duration;
  final double minScale;
  final double maxScale;
  final bool enabled;

  const PulseWidget({
    super.key,
    required this.child,
    this.duration = const Duration(milliseconds: 1000),
    this.minScale = 0.97,
    this.maxScale = 1.03,
    this.enabled = true,
  });

  @override
  State<PulseWidget> createState() => _PulseWidgetState();
}

class _PulseWidgetState extends State<PulseWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: widget.minScale,
      end: widget.maxScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    if (widget.enabled) {
      _controller.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PulseWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.enabled && !_controller.isAnimating) {
      _controller.repeat(reverse: true);
    } else if (!widget.enabled && _controller.isAnimating) {
      _controller.stop();
      _controller.value = 0.5; // Reset to neutral scale
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.enabled) {
      return widget.child;
    }
    
    return ScaleTransition(
      scale: _scaleAnimation,
      child: widget.child,
    );
  }
}

/// 바운스 효과 위젯
class BounceWidget extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final double pressScale;

  const BounceWidget({
    super.key,
    required this.child,
    this.onTap,
    this.pressScale = 0.95,
  });

  @override
  State<BounceWidget> createState() => _BounceWidgetState();
}

class _BounceWidgetState extends State<BounceWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: ScaleTransition(
        scale: _scaleAnimation,
        child: widget.child,
      ),
    );
  }
}
