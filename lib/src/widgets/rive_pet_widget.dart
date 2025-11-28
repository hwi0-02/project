import 'package:flutter/material.dart' hide LinearGradient;
import 'package:flutter/material.dart' as material show LinearGradient;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:rive/rive.dart';

import '../services/rive_pet_service.dart';
import '../providers/hive_providers.dart';

/// Rive 펫 위젯
/// 기획서2.md: Rive 인터랙티브 애니메이션 표시
/// - Idle (대기): 숨쉬기, 눈 깜빡임, 귀 쫑긋
/// - Touch (반응): 터치 시 하트 발사
/// - Fetch (결과): Bool IsFetching = true -> 물어오기 모션
/// - State Mixing: 액세서리 레이어 합성
class RivePetWidget extends ConsumerStatefulWidget {
  const RivePetWidget({
    super.key,
    this.width = 200,
    this.height = 200,
    this.onTap,
    this.showStatusOverlay = true,
  });
  
  final double width;
  final double height;
  final VoidCallback? onTap;
  final bool showStatusOverlay;
  
  @override
  ConsumerState<RivePetWidget> createState() => _RivePetWidgetState();
}

class _RivePetWidgetState extends ConsumerState<RivePetWidget>
    with TickerProviderStateMixin {
  late RivePetController _controller;
  bool _hasRiveFile = false;
  
  // 대체 애니메이션용 컨트롤러
  late AnimationController _bounceController;
  late Animation<double> _bounceAnimation;
  late AnimationController _breathController;
  late Animation<double> _breathAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = RivePetService.instance.controller;
    _initializeAnimation();
    _setupFallbackAnimations();
  }
  
  void _setupFallbackAnimations() {
    // 바운스 애니메이션 (터치 반응)
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _bounceAnimation = Tween<double>(begin: 1.0, end: 1.1).animate(
      CurvedAnimation(parent: _bounceController, curve: Curves.elasticOut),
    );
    
    // 숨쉬기 애니메이션 (Idle)
    _breathController = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat(reverse: true);
    _breathAnimation = Tween<double>(begin: 0.98, end: 1.02).animate(
      CurvedAnimation(parent: _breathController, curve: Curves.easeInOut),
    );
  }
  
  Future<void> _initializeAnimation() async {
    if (!_controller.isInitialized) {
      await _controller.initialize();
    }
    
    if (mounted) {
      setState(() {
        _hasRiveFile = _controller.isInitialized && _controller.artboard != null;
      });
    }
  }
  
  @override
  void dispose() {
    _bounceController.dispose();
    _breathController.dispose();
    super.dispose();
  }
  
  void _handleTap() {
    // 바운스 애니메이션 재생
    _bounceController.forward().then((_) => _bounceController.reverse());
    
    // Rive 트리거
    _controller.trigger(PetAnimationTrigger.touch);
    
    // 외부 콜백
    widget.onTap?.call();
  }
  
  @override
  Widget build(BuildContext context) {
    final petState = ref.watch(petStateProvider);
    
    // 펫 상태 업데이트
    _controller.updatePetStatus(
      hungerPoint: petState.hungerPoint,
      moodPoint: petState.moodPoint,
    );
    
    return GestureDetector(
      onTap: _handleTap,
      child: SizedBox(
        width: widget.width,
        height: widget.height,
        child: Stack(
          alignment: Alignment.center,
          children: [
            // 펫 애니메이션
            _buildPetAnimation(petState),
            
            // 상태 오버레이
            if (widget.showStatusOverlay) 
              _buildStatusOverlay(petState),
          ],
        ),
      ),
    );
  }
  
  Widget _buildPetAnimation(dynamic petState) {
    // Rive 파일이 있으면 Rive 애니메이션 사용
    if (_hasRiveFile && _controller.artboard != null) {
      return AnimatedBuilder(
        animation: _bounceController,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Rive(
              artboard: _controller.artboard!,
              fit: BoxFit.contain,
            ),
          );
        },
      );
    }
    
    // Rive 파일이 없으면 대체 애니메이션 (귀여운 이모지 펫)
    return AnimatedBuilder(
      animation: Listenable.merge([_bounceController, _breathController]),
      builder: (context, child) {
        return Transform.scale(
          scale: _bounceAnimation.value * _breathAnimation.value,
          child: _buildFallbackPet(petState),
        );
      },
    );
  }
  
  /// 대체 펫 (Rive 없을 때)
  Widget _buildFallbackPet(dynamic petState) {
    final state = _controller.currentState;
    final isHungry = petState.isHungry;
    final isSulky = petState.isSulky;
    
    String emoji;
    Color? overlayColor;
    double saturation = 1.0;
    
    switch (state) {
      case PetAnimationState.happy:
        emoji = '🐕';
        break;
      case PetAnimationState.sad:
        emoji = '🐶';
        saturation = 0.5; // 채도 감소
        overlayColor = Colors.grey.withValues(alpha: 0.3);
        break;
      case PetAnimationState.sulky:
        emoji = '😤'; // 삐짐
        break;
      case PetAnimationState.hungry:
        emoji = '🥺';
        saturation = 0.7;
        break;
      case PetAnimationState.eating:
        emoji = '😋';
        break;
      case PetAnimationState.fetching:
        emoji = '🏃';
        break;
      case PetAnimationState.sleeping:
        emoji = '😴';
        break;
      case PetAnimationState.excited:
        emoji = '🎉';
        break;
      default:
        emoji = isHungry ? '🥺' : (isSulky ? '😤' : '🐕');
    }
    
    return Stack(
      alignment: Alignment.center,
      children: [
        // 배경 원
        Container(
          width: widget.width * 0.8,
          height: widget.height * 0.8,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: material.LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [
                _getPetBackgroundColor(petState).withValues(alpha: 0.3),
                _getPetBackgroundColor(petState).withValues(alpha: 0.1),
              ],
            ),
          ),
        ),
        
        // 펫 이모지
        ColorFiltered(
          colorFilter: ColorFilter.matrix(_getSaturationMatrix(saturation)),
          child: Text(
            emoji,
            style: TextStyle(
              fontSize: widget.width * 0.5,
            ),
          ),
        ),
        
        // 오버레이 (상태에 따른)
        if (overlayColor != null)
          Container(
            width: widget.width * 0.6,
            height: widget.height * 0.6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: overlayColor,
            ),
          ),
        
        // 액세서리
        _buildAccessoryOverlay(),
        
        // 상태 아이콘 (배고픔, 삐짐)
        if (isHungry || isSulky)
          Positioned(
            top: 10,
            right: 10,
            child: _buildStateIcon(isHungry, isSulky),
          ),
      ],
    );
  }
  
  Color _getPetBackgroundColor(dynamic petState) {
    final happiness = petState.happiness;
    if (happiness >= 70) {
      return Colors.green;
    } else if (happiness >= 40) {
      return Colors.orange;
    } else {
      return Colors.red;
    }
  }
  
  /// 채도 조절 매트릭스
  List<double> _getSaturationMatrix(double saturation) {
    final double invSat = 1 - saturation;
    final double r = 0.213 * invSat;
    final double g = 0.715 * invSat;
    final double b = 0.072 * invSat;
    
    return [
      r + saturation, g, b, 0, 0,
      r, g + saturation, b, 0, 0,
      r, g, b + saturation, 0, 0,
      0, 0, 0, 1, 0,
    ];
  }
  
  /// 액세서리 오버레이
  Widget _buildAccessoryOverlay() {
    final accessory = _controller.currentAccessory;
    if (accessory == AccessoryType.none) return const SizedBox.shrink();
    
    String accessoryEmoji;
    double top;
    
    switch (accessory) {
      case AccessoryType.crown:
        accessoryEmoji = '👑';
        top = -widget.height * 0.15;
        break;
      case AccessoryType.glasses:
        accessoryEmoji = '🕶️';
        top = widget.height * 0.05;
        break;
      case AccessoryType.scarf:
        accessoryEmoji = '🧣';
        top = widget.height * 0.25;
        break;
      case AccessoryType.hat:
        accessoryEmoji = '🎩';
        top = -widget.height * 0.18;
        break;
      case AccessoryType.bow:
        accessoryEmoji = '🎀';
        top = -widget.height * 0.12;
        break;
      default:
        return const SizedBox.shrink();
    }
    
    return Positioned(
      top: widget.height * 0.3 + top,
      child: Text(
        accessoryEmoji,
        style: TextStyle(fontSize: widget.width * 0.2),
      ),
    );
  }
  
  /// 상태 아이콘 (배고픔/삐짐 표시)
  Widget _buildStateIcon(bool isHungry, bool isSulky) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isHungry)
            const Tooltip(
              message: '배고파요!',
              child: Text('🍖', style: TextStyle(fontSize: 16)),
            ),
          if (isSulky)
            const Tooltip(
              message: '삐쳤어요!',
              child: Text('💢', style: TextStyle(fontSize: 16)),
            ),
        ],
      ),
    );
  }
  
  /// 상태 오버레이
  Widget _buildStatusOverlay(dynamic petState) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: Colors.black.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            // 포만감
            _buildMiniBar(
              icon: '🍖',
              value: petState.hungerPoint,
              color: Colors.orange,
            ),
            // 애정도
            _buildMiniBar(
              icon: '❤️',
              value: petState.moodPoint,
              color: Colors.pink,
            ),
          ],
        ),
      ),
    );
  }
  
  Widget _buildMiniBar({
    required String icon,
    required int value,
    required Color color,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(icon, style: const TextStyle(fontSize: 12)),
        const SizedBox(width: 4),
        SizedBox(
          width: 40,
          height: 6,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(3),
            child: LinearProgressIndicator(
              value: value / 100,
              backgroundColor: Colors.grey[600],
              valueColor: AlwaysStoppedAnimation<Color>(color),
            ),
          ),
        ),
      ],
    );
  }
}

/// Rive 펫 컨트롤러 Provider
final rivePetControllerProvider = Provider<RivePetController>((ref) {
  return RivePetService.instance.controller;
});

/// 간단한 펫 미리보기 위젯 (상점용)
class PetPreviewWidget extends StatelessWidget {
  const PetPreviewWidget({
    super.key,
    required this.accessory,
    this.size = 100,
  });
  
  final AccessoryType accessory;
  final double size;
  
  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Text('🐕', style: TextStyle(fontSize: size * 0.5)),
          if (accessory != AccessoryType.none)
            Positioned(
              top: size * 0.1,
              child: Text(
                _getAccessoryEmoji(accessory),
                style: TextStyle(fontSize: size * 0.25),
              ),
            ),
        ],
      ),
    );
  }
  
  String _getAccessoryEmoji(AccessoryType accessory) {
    switch (accessory) {
      case AccessoryType.crown:
        return '👑';
      case AccessoryType.glasses:
        return '🕶️';
      case AccessoryType.scarf:
        return '🧣';
      case AccessoryType.hat:
        return '🎩';
      case AccessoryType.bow:
        return '🎀';
      default:
        return '';
    }
  }
}
