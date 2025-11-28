import 'package:hive/hive.dart';

/// Hive 어댑터 등록 인터페이스
/// 
/// OCP(개방-폐쇄 원칙) 적용: 새 어댑터 추가 시 기존 코드 수정 없이 확장 가능
abstract class HiveAdapterRegistration {
  /// 어댑터의 typeId
  int get typeId;
  
  /// 어댑터 등록 수행
  void register();
}

/// 어댑터 레지스트리
/// 
/// 모든 Hive 어댑터를 중앙에서 관리
class HiveAdapterRegistry {
  static final List<HiveAdapterRegistration> _registrations = [];
  
  /// 어댑터 등록 추가
  static void add(HiveAdapterRegistration registration) {
    _registrations.add(registration);
  }
  
  /// 모든 어댑터 등록 수행
  static void registerAll() {
    for (final registration in _registrations) {
      if (!Hive.isAdapterRegistered(registration.typeId)) {
        registration.register();
      }
    }
  }
  
  /// 레지스트리 초기화 (테스트용)
  static void clear() {
    _registrations.clear();
  }
}

/// 기본 어댑터 등록 헬퍼
/// 
/// 간단한 어댑터 등록을 위한 제네릭 클래스
class SimpleAdapterRegistration<T> implements HiveAdapterRegistration {
  @override
  final int typeId;
  final TypeAdapter<T> adapter;
  
  SimpleAdapterRegistration({
    required this.typeId,
    required this.adapter,
  });
  
  @override
  void register() {
    Hive.registerAdapter(adapter);
  }
}
