import 'package:flutter/services.dart';
import 'package:rive/rive.dart';

/// 펫 애니메이션 상태 enum
/// 기획서2.md: Idle(대기), Touch(반응), Fetch(결과), State Mixing 지원
enum PetAnimationState {
  idle,      // 기본 대기: 숨쉬기, 눈 깜빡임, 귀 쫑긋
  happy,     // 기쁨: 하트 발사, 꺄르륵 웃음
  sad,       // 슬픔: 힘없이 축 쳐짐 (포만감/애정도 낮음)
  sulky,     // 삐침: 등을 돌림 (애정도 < 30)
  hungry,    // 배고픔: 눈이 쳐지고 힘없음 (포만감 < 30)
  eating,    // 먹는 모션: 결정(밥) 완료 시
  fetching,  // 물어오기: 화면 밖으로 달려갔다가 아이템을 물고 옴
  sleeping,  // 자는 중 (야간 또는 오랜 미접속)
  excited,   // 흥분: 가챠 당첨, 새 아이템 획득
}

/// 펫 애니메이션 이벤트 (일회성 트리거)
enum PetAnimationTrigger {
  touch,      // 유저 터치
  pet,        // 쓰다듬기
  feed,       // 밥주기
  fetch,      // 뽑기 시작
  celebrate,  // 축하 (레벨업, 업적 달성)
  sleep,      // 잠들기
  wakeUp,     // 깨어나기
}

/// 장착 가능한 액세서리 타입
enum AccessoryType {
  none,
  glasses,    // 안경
  scarf,      // 스카프
  crown,      // 왕관
  hat,        // 모자
  bow,        // 리본
}

/// Rive 펫 애니메이션 컨트롤러
/// 기획서2.md에 따른 상태 머신 기반 인터랙티브 애니메이션 제어
class RivePetController {
  Artboard? _artboard;
  StateMachineController? _stateMachineController;
  
  // 상태 입력들 (State Machine Inputs)
  SMITrigger? _touchTrigger;
  SMITrigger? _petTrigger;
  SMITrigger? _feedTrigger;
  SMITrigger? _fetchTrigger;
  SMITrigger? _celebrateTrigger;
  
  SMIBool? _isHungry;
  SMIBool? _isSulky;
  SMIBool? _isSleeping;
  SMIBool? _isFetching;
  
  SMINumber? _hungerLevel;
  SMINumber? _moodLevel;
  SMINumber? _accessoryId;
  
  bool _isInitialized = false;
  PetAnimationState _currentState = PetAnimationState.idle;
  AccessoryType _currentAccessory = AccessoryType.none;
  
  bool get isInitialized => _isInitialized;
  Artboard? get artboard => _artboard;
  PetAnimationState get currentState => _currentState;
  AccessoryType get currentAccessory => _currentAccessory;
  
  /// Rive 파일 로드 및 초기화
  /// [assetPath]는 assets/rive/ 내의 파일 경로
  Future<void> initialize({String assetPath = 'assets/rive/fetch_pet.riv'}) async {
    try {
      final data = await rootBundle.load(assetPath);
      final file = RiveFile.import(data);
      
      _artboard = file.mainArtboard.instance();
      _stateMachineController = StateMachineController.fromArtboard(
        _artboard!,
        'PetStateMachine', // Rive에서 정의된 State Machine 이름
      );
      
      if (_stateMachineController != null) {
        _artboard!.addController(_stateMachineController!);
        _setupInputs();
        _isInitialized = true;
      }
    } catch (e) {
      // Rive 파일이 없는 경우 기본 상태로 유지 (개발 중)
      _isInitialized = false;
    }
  }
  
  /// State Machine 입력 설정
  void _setupInputs() {
    if (_stateMachineController == null) return;
    
    // Triggers (일회성 이벤트)
    _touchTrigger = _stateMachineController!.findInput<bool>('Touch') as SMITrigger?;
    _petTrigger = _stateMachineController!.findInput<bool>('Pet') as SMITrigger?;
    _feedTrigger = _stateMachineController!.findInput<bool>('Feed') as SMITrigger?;
    _fetchTrigger = _stateMachineController!.findInput<bool>('Fetch') as SMITrigger?;
    _celebrateTrigger = _stateMachineController!.findInput<bool>('Celebrate') as SMITrigger?;
    
    // Boolean 상태
    _isHungry = _stateMachineController!.findInput<bool>('IsHungry') as SMIBool?;
    _isSulky = _stateMachineController!.findInput<bool>('IsSulky') as SMIBool?;
    _isSleeping = _stateMachineController!.findInput<bool>('IsSleeping') as SMIBool?;
    _isFetching = _stateMachineController!.findInput<bool>('IsFetching') as SMIBool?;
    
    // Number 값
    _hungerLevel = _stateMachineController!.findInput<double>('HungerLevel') as SMINumber?;
    _moodLevel = _stateMachineController!.findInput<double>('MoodLevel') as SMINumber?;
    _accessoryId = _stateMachineController!.findInput<double>('AccessoryId') as SMINumber?;
  }
  
  /// 펫 상태 업데이트 (PetStateModel과 연동)
  /// [hungerPoint]: 포만감 (0~100)
  /// [moodPoint]: 애정도 (0~100)
  void updatePetStatus({
    required int hungerPoint,
    required int moodPoint,
  }) {
    // 상태 수치 업데이트
    _hungerLevel?.value = hungerPoint.toDouble();
    _moodLevel?.value = moodPoint.toDouble();
    
    // 상태 조건 체크
    final isHungry = hungerPoint <= 30;
    final isSulky = moodPoint <= 30;
    
    _isHungry?.value = isHungry;
    _isSulky?.value = isSulky;
    
    // 현재 상태 결정
    if (isHungry && isSulky) {
      _currentState = PetAnimationState.sad;
    } else if (isHungry) {
      _currentState = PetAnimationState.hungry;
    } else if (isSulky) {
      _currentState = PetAnimationState.sulky;
    } else {
      _currentState = PetAnimationState.idle;
    }
  }
  
  /// 애니메이션 트리거 발동
  void trigger(PetAnimationTrigger event) {
    switch (event) {
      case PetAnimationTrigger.touch:
        _touchTrigger?.fire();
        break;
      case PetAnimationTrigger.pet:
        _petTrigger?.fire();
        _currentState = PetAnimationState.happy;
        break;
      case PetAnimationTrigger.feed:
        _feedTrigger?.fire();
        _currentState = PetAnimationState.eating;
        break;
      case PetAnimationTrigger.fetch:
        _fetchTrigger?.fire();
        _isFetching?.value = true;
        _currentState = PetAnimationState.fetching;
        break;
      case PetAnimationTrigger.celebrate:
        _celebrateTrigger?.fire();
        _currentState = PetAnimationState.excited;
        break;
      case PetAnimationTrigger.sleep:
        _isSleeping?.value = true;
        _currentState = PetAnimationState.sleeping;
        break;
      case PetAnimationTrigger.wakeUp:
        _isSleeping?.value = false;
        _currentState = PetAnimationState.idle;
        break;
    }
  }
  
  /// 뽑기(Fetch) 완료 처리
  void completeFetch() {
    _isFetching?.value = false;
    _currentState = PetAnimationState.idle;
  }
  
  /// 액세서리 장착
  /// [accessory]: 장착할 액세서리 타입
  void equipAccessory(AccessoryType accessory) {
    _currentAccessory = accessory;
    _accessoryId?.value = accessory.index.toDouble();
  }
  
  /// 액세서리 해제
  void unequipAccessory() {
    _currentAccessory = AccessoryType.none;
    _accessoryId?.value = 0;
  }
  
  /// 리소스 해제
  void dispose() {
    _stateMachineController?.dispose();
    _artboard = null;
    _isInitialized = false;
  }
}

/// Rive 펫 서비스 (싱글톤 패턴)
class RivePetService {
  RivePetService._internal();
  static final RivePetService _instance = RivePetService._internal();
  static RivePetService get instance => _instance;
  
  RivePetController? _controller;
  
  RivePetController get controller {
    _controller ??= RivePetController();
    return _controller!;
  }
  
  /// 서비스 초기화
  Future<void> init() async {
    await controller.initialize();
  }
  
  /// 서비스 종료
  void dispose() {
    _controller?.dispose();
    _controller = null;
  }
}
