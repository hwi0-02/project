import 'package:flutter_test/flutter_test.dart';
import 'package:fetch_pet_widget/src/services/rive_pet_service.dart';

void main() {
  group('RivePetController Tests', () {
    late RivePetController controller;
    
    setUp(() {
      controller = RivePetController();
    });
    
    tearDown(() {
      controller.dispose();
    });
    
    test('초기 상태 확인', () {
      expect(controller.isInitialized, false);
      expect(controller.currentState, PetAnimationState.idle);
      expect(controller.currentAccessory, AccessoryType.none);
      expect(controller.artboard, isNull);
    });
    
    test('updatePetStatus()가 idle 상태로 설정 (행복한 경우)', () {
      controller.updatePetStatus(hungerPoint: 100, moodPoint: 100);
      
      expect(controller.currentState, PetAnimationState.idle);
    });
    
    test('updatePetStatus()가 hungry 상태로 설정 (포만감 <= 30)', () {
      controller.updatePetStatus(hungerPoint: 30, moodPoint: 100);
      
      expect(controller.currentState, PetAnimationState.hungry);
    });
    
    test('updatePetStatus()가 sulky 상태로 설정 (애정도 <= 30)', () {
      controller.updatePetStatus(hungerPoint: 100, moodPoint: 30);
      
      expect(controller.currentState, PetAnimationState.sulky);
    });
    
    test('updatePetStatus()가 sad 상태로 설정 (포만감, 애정도 모두 <= 30)', () {
      controller.updatePetStatus(hungerPoint: 20, moodPoint: 20);
      
      expect(controller.currentState, PetAnimationState.sad);
    });
    
    test('trigger()가 상태 변경', () {
      // Touch 트리거는 상태를 변경하지 않음 (일회성)
      controller.trigger(PetAnimationTrigger.touch);
      expect(controller.currentState, PetAnimationState.idle);
      
      // Pet 트리거는 happy로 변경
      controller.trigger(PetAnimationTrigger.pet);
      expect(controller.currentState, PetAnimationState.happy);
      
      // Feed 트리거는 eating으로 변경
      controller.trigger(PetAnimationTrigger.feed);
      expect(controller.currentState, PetAnimationState.eating);
      
      // Fetch 트리거는 fetching으로 변경
      controller.trigger(PetAnimationTrigger.fetch);
      expect(controller.currentState, PetAnimationState.fetching);
      
      // Celebrate 트리거는 excited로 변경
      controller.trigger(PetAnimationTrigger.celebrate);
      expect(controller.currentState, PetAnimationState.excited);
      
      // Sleep 트리거는 sleeping으로 변경
      controller.trigger(PetAnimationTrigger.sleep);
      expect(controller.currentState, PetAnimationState.sleeping);
      
      // WakeUp 트리거는 idle로 변경
      controller.trigger(PetAnimationTrigger.wakeUp);
      expect(controller.currentState, PetAnimationState.idle);
    });
    
    test('completeFetch()가 idle 상태로 복원', () {
      controller.trigger(PetAnimationTrigger.fetch);
      expect(controller.currentState, PetAnimationState.fetching);
      
      controller.completeFetch();
      expect(controller.currentState, PetAnimationState.idle);
    });
    
    test('equipAccessory()가 액세서리 장착', () {
      expect(controller.currentAccessory, AccessoryType.none);
      
      controller.equipAccessory(AccessoryType.crown);
      expect(controller.currentAccessory, AccessoryType.crown);
      
      controller.equipAccessory(AccessoryType.glasses);
      expect(controller.currentAccessory, AccessoryType.glasses);
    });
    
    test('unequipAccessory()가 액세서리 해제', () {
      controller.equipAccessory(AccessoryType.crown);
      expect(controller.currentAccessory, AccessoryType.crown);
      
      controller.unequipAccessory();
      expect(controller.currentAccessory, AccessoryType.none);
    });
  });
  
  group('RivePetService Singleton Tests', () {
    test('instance가 동일한 객체 반환', () {
      final service1 = RivePetService.instance;
      final service2 = RivePetService.instance;
      
      expect(identical(service1, service2), true);
    });
    
    test('controller가 동일한 객체 반환', () {
      final controller1 = RivePetService.instance.controller;
      final controller2 = RivePetService.instance.controller;
      
      expect(identical(controller1, controller2), true);
    });
  });
  
  group('PetAnimationState Enum Tests', () {
    test('모든 애니메이션 상태가 정의됨', () {
      expect(PetAnimationState.values.length, 9);
      expect(PetAnimationState.values.contains(PetAnimationState.idle), true);
      expect(PetAnimationState.values.contains(PetAnimationState.happy), true);
      expect(PetAnimationState.values.contains(PetAnimationState.sad), true);
      expect(PetAnimationState.values.contains(PetAnimationState.sulky), true);
      expect(PetAnimationState.values.contains(PetAnimationState.hungry), true);
      expect(PetAnimationState.values.contains(PetAnimationState.eating), true);
      expect(PetAnimationState.values.contains(PetAnimationState.fetching), true);
      expect(PetAnimationState.values.contains(PetAnimationState.sleeping), true);
      expect(PetAnimationState.values.contains(PetAnimationState.excited), true);
    });
  });
  
  group('AccessoryType Enum Tests', () {
    test('모든 액세서리 타입이 정의됨', () {
      expect(AccessoryType.values.length, 6);
      expect(AccessoryType.values.contains(AccessoryType.none), true);
      expect(AccessoryType.values.contains(AccessoryType.glasses), true);
      expect(AccessoryType.values.contains(AccessoryType.scarf), true);
      expect(AccessoryType.values.contains(AccessoryType.crown), true);
      expect(AccessoryType.values.contains(AccessoryType.hat), true);
      expect(AccessoryType.values.contains(AccessoryType.bow), true);
    });
    
    test('AccessoryType.none의 index가 0', () {
      expect(AccessoryType.none.index, 0);
    });
  });
}
