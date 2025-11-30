import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

/// 펫 표시 위젯 - 프리미엄 애니메이션 버전
class PetDisplayWidget extends StatefulWidget {
  final Pet pet;
  final double size;
  final bool enableAnimation;
  final bool showShadow;

  const PetDisplayWidget({
    super.key,
    required this.pet,
    this.size = 200,
    this.enableAnimation = true,
    this.showShadow = true,
  });

  @override
  State<PetDisplayWidget> createState() => _PetDisplayWidgetState();
}

class _PetDisplayWidgetState extends State<PetDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _rainbowController;
  late AnimationController _pulseController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _rainbowAnimation;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // 부드러운 바운스 애니메이션
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1800),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 8).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // 미세한 회전 애니메이션
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
    _rotateAnimation = Tween<double>(begin: -0.03, end: 0.03).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
    
    // 무지개 오라 애니메이션
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    );
    _rainbowAnimation = Tween<double>(begin: 0, end: 1).animate(_rainbowController);
    
    // 펄스 애니메이션 (행복할 때)
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _pulseAnimation = Tween<double>(begin: 1.0, end: 1.05).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  void _startAnimations() {
    if (!widget.enableAnimation) return;
    
    _bounceController.repeat(reverse: true);
    _rotateController.repeat(reverse: true);
    
    if (widget.pet.hasRainbowAura) {
      _rainbowController.repeat();
    }
    
    if (widget.pet.state == PetState.completed) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(PetDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // 무지개 오라 상태 변경
    if (widget.pet.hasRainbowAura && !oldWidget.pet.hasRainbowAura) {
      _rainbowController.repeat();
    } else if (!widget.pet.hasRainbowAura && oldWidget.pet.hasRainbowAura) {
      _rainbowController.stop();
      _rainbowController.reset();
    }
    
    // 완료 상태 변경
    if (widget.pet.state == PetState.completed && oldWidget.pet.state != PetState.completed) {
      _pulseController.repeat(reverse: true);
    } else if (widget.pet.state != PetState.completed) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotateController.dispose();
    _rainbowController.dispose();
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([
          _bounceAnimation, 
          _rotateAnimation,
          _pulseAnimation,
        ]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Transform.scale(
                scale: widget.pet.state == PetState.completed 
                    ? _pulseAnimation.value 
                    : 1.0,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // 그림자
                    if (widget.showShadow) _buildShadow(),
                    
                    // 무지개 오라 (가장 뒤)
                    if (widget.pet.hasRainbowAura) _buildRainbowAura(),
                    
                    // 상태 글로우
                    _buildStateGlow(),
                    
                    // 펫 이미지
                    _buildPetImage(),
                    
                    // 아이템 레이어들
                    ..._buildItemLayers(),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShadow() {
    return Positioned(
      bottom: widget.size * 0.05,
      child: Container(
        width: widget.size * 0.5,
        height: widget.size * 0.08,
        decoration: BoxDecoration(
          color: AppTheme.neutral900.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(widget.size * 0.04),
        ),
      ),
    );
  }

  Widget _buildStateGlow() {
    final petColor = _getPetColor();
    
    return Container(
      width: widget.size * 0.85,
      height: widget.size * 0.85,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: petColor.withValues(alpha: 0.2),
            blurRadius: 30,
            spreadRadius: 5,
          ),
        ],
      ),
    );
  }

  Widget _buildRainbowAura() {
    return AnimatedBuilder(
      animation: _rainbowAnimation,
      builder: (context, child) {
        return Transform.rotate(
          angle: _rainbowAnimation.value * 2 * 3.14159,
          child: Container(
            width: widget.size * 1.2,
            height: widget.size * 1.2,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: SweepGradient(
                colors: const [
                  Color(0xFFFF6B6B),
                  Color(0xFFFFE66D),
                  Color(0xFF4ECDC4),
                  Color(0xFF45B7D1),
                  Color(0xFFDDA0DD),
                  Color(0xFFFF6B6B),
                ],
                stops: const [0.0, 0.2, 0.4, 0.6, 0.8, 1.0],
              ),
            ),
            child: Center(
              child: Container(
                width: widget.size * 1.0,
                height: widget.size * 1.0,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.background,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetImage() {
    final petColor = _getPetColor();
    final expression = _getPetExpression();
    
    return Container(
      width: widget.size * 0.75,
      height: widget.size * 0.75,
      decoration: BoxDecoration(
        color: petColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: petColor.withValues(alpha: 0.3),
          width: 3,
        ),
        boxShadow: [
          BoxShadow(
            color: petColor.withValues(alpha: 0.25),
            blurRadius: 15,
            spreadRadius: 2,
          ),
        ],
      ),
      child: Center(
        child: Text(
          expression,
          style: TextStyle(fontSize: widget.size * 0.35),
        ),
      ),
    );
  }

  Color _getPetColor() {
    switch (widget.pet.state) {
      case PetState.completed:
        return AppColors.petHappy;
      case PetState.sulky:
        return AppColors.petSulky;
      case PetState.loading:
        return AppTheme.primary.withValues(alpha: 0.8);
      default:
        return AppColors.petDefault;
    }
  }

  String _getPetExpression() {
    switch (widget.pet.state) {
      case PetState.waiting:
        return '🐕';
      case PetState.loading:
        return '🐕‍🦺';
      case PetState.result:
        return '🦴';
      case PetState.completed:
        return '😊';
      case PetState.sulky:
        return '😢';
    }
  }

  List<Widget> _buildItemLayers() {
    final items = <Widget>[];
    
    for (final item in widget.pet.equippedItems) {
      items.add(_buildItemWidget(item));
    }
    
    return items;
  }

  Widget _buildItemWidget(PetItem item) {
    switch (item) {
      case PetItem.scarf:
        return Positioned(
          bottom: widget.size * 0.18,
          child: Text('🧣', style: TextStyle(fontSize: widget.size * 0.18)),
        );
      case PetItem.glasses:
        return Positioned(
          top: widget.size * 0.28,
          child: Text('🤓', style: TextStyle(fontSize: widget.size * 0.14)),
        );
      case PetItem.crown:
        return Positioned(
          top: widget.size * 0.08,
          child: Text('👑', style: TextStyle(fontSize: widget.size * 0.18)),
        );
      case PetItem.rainbowAura:
        return const SizedBox.shrink();
    }
  }
}

/// 미니 펫 아바타 (리스트 등에서 사용)
class MiniPetAvatar extends StatelessWidget {
  final Pet pet;
  final double size;
  
  const MiniPetAvatar({
    super.key,
    required this.pet,
    this.size = 48,
  });
  
  @override
  Widget build(BuildContext context) {
    final petColor = _getPetColor();
    
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: petColor,
        shape: BoxShape.circle,
        border: Border.all(
          color: petColor.withValues(alpha: 0.3),
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: petColor.withValues(alpha: 0.2),
            blurRadius: 8,
            spreadRadius: 1,
          ),
        ],
      ),
      child: Center(
        child: Text(
          _getPetExpression(),
          style: TextStyle(fontSize: size * 0.5),
        ),
      ),
    );
  }
  
  Color _getPetColor() {
    switch (pet.state) {
      case PetState.completed:
        return AppColors.petHappy;
      case PetState.sulky:
        return AppColors.petSulky;
      default:
        return AppColors.petDefault;
    }
  }
  
  String _getPetExpression() {
    switch (pet.state) {
      case PetState.waiting:
        return '🐕';
      case PetState.completed:
        return '😊';
      case PetState.sulky:
        return '😢';
      default:
        return '🐕';
    }
  }
}
