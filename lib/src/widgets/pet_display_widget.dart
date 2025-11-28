import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

/// 펫 표시 위젯
/// 
/// 펫 이미지와 아이템을 Stack으로 레이어링하여 표시
/// 애니메이션으로 생동감 있는 펫 표현
class PetDisplayWidget extends StatefulWidget {
  final Pet pet;
  final double size;
  final bool enableAnimation;

  const PetDisplayWidget({
    super.key,
    required this.pet,
    this.size = 200,
    this.enableAnimation = true,
  });

  @override
  State<PetDisplayWidget> createState() => _PetDisplayWidgetState();
}

class _PetDisplayWidgetState extends State<PetDisplayWidget>
    with TickerProviderStateMixin {
  late AnimationController _bounceController;
  late AnimationController _rotateController;
  late AnimationController _rainbowController;
  
  late Animation<double> _bounceAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _rainbowAnimation;

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startAnimations();
  }

  void _initAnimations() {
    // 통통 튀는 애니메이션
    _bounceController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
    _bounceAnimation = Tween<double>(begin: 0, end: 10).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.easeInOut),
    );
    
    // 살짝 흔들리는 애니메이션
    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000),
    );
    _rotateAnimation = Tween<double>(begin: -0.05, end: 0.05).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.easeInOut),
    );
    
    // 무지개 오라 애니메이션
    _rainbowController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    );
    _rainbowAnimation = Tween<double>(begin: 0, end: 1).animate(_rainbowController);
  }

  void _startAnimations() {
    if (!widget.enableAnimation) return;
    
    _bounceController.repeat(reverse: true);
    _rotateController.repeat(reverse: true);
    
    if (widget.pet.hasRainbowAura) {
      _rainbowController.repeat();
    }
  }

  @override
  void didUpdateWidget(PetDisplayWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.pet.hasRainbowAura && !oldWidget.pet.hasRainbowAura) {
      _rainbowController.repeat();
    } else if (!widget.pet.hasRainbowAura && oldWidget.pet.hasRainbowAura) {
      _rainbowController.stop();
      _rainbowController.reset();
    }
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _rotateController.dispose();
    _rainbowController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: Listenable.merge([_bounceAnimation, _rotateAnimation]),
        builder: (context, child) {
          return Transform.translate(
            offset: Offset(0, -_bounceAnimation.value),
            child: Transform.rotate(
              angle: _rotateAnimation.value,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // 무지개 오라 (가장 뒤)
                  if (widget.pet.hasRainbowAura) _buildRainbowAura(),
                  
                  // 펫 이미지
                  _buildPetImage(),
                  
                  // 아이템 레이어들
                  ..._buildItemLayers(),
                ],
              ),
            ),
          );
        },
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
            width: widget.size * 1.3,
            height: widget.size * 1.3,
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
                width: widget.size * 1.1,
                height: widget.size * 1.1,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppColors.background,
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildPetImage() {
    // TODO: 실제 펫 이미지 에셋으로 교체
    final petColor = _getPetColor();
    final expression = _getPetExpression();
    
    return Container(
      width: widget.size * 0.8,
      height: widget.size * 0.8,
      decoration: BoxDecoration(
        color: petColor,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(
            color: petColor.withValues(alpha: 0.3),
            blurRadius: 20,
            spreadRadius: 5,
          ),
        ],
      ),
      child: Center(
        child: Text(
          expression,
          style: TextStyle(fontSize: widget.size * 0.4),
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
    // TODO: 실제 아이템 이미지 에셋으로 교체
    switch (item) {
      case PetItem.scarf:
        return Positioned(
          bottom: widget.size * 0.15,
          child: Text('🧣', style: TextStyle(fontSize: widget.size * 0.2)),
        );
      case PetItem.glasses:
        return Positioned(
          top: widget.size * 0.25,
          child: Text('🤓', style: TextStyle(fontSize: widget.size * 0.15)),
        );
      case PetItem.crown:
        return Positioned(
          top: widget.size * 0.05,
          child: Text('👑', style: TextStyle(fontSize: widget.size * 0.2)),
        );
      case PetItem.rainbowAura:
        return const SizedBox.shrink(); // 이미 _buildRainbowAura에서 처리
    }
  }
}
