import 'dart:math';

/// 셔플 관련 유틸리티
class ShuffleUtils {
  static final Random _random = Random();
  
  /// Fisher-Yates 셔플 알고리즘
  /// 
  /// 균등한 확률로 리스트의 모든 순열을 생성
  static List<T> shuffle<T>(List<T> list) {
    final result = List<T>.from(list);
    
    for (int i = result.length - 1; i > 0; i--) {
      final j = _random.nextInt(i + 1);
      final temp = result[i];
      result[i] = result[j];
      result[j] = temp;
    }
    
    return result;
  }
  
  /// 리스트에서 랜덤하게 하나 선택
  static T? pickRandom<T>(List<T> list) {
    if (list.isEmpty) return null;
    return list[_random.nextInt(list.length)];
  }
  
  /// 리스트에서 랜덤하게 n개 선택 (중복 없음)
  static List<T> pickRandomN<T>(List<T> list, int n) {
    if (n >= list.length) return shuffle(list);
    
    final result = <T>[];
    final indices = <int>{};
    
    while (result.length < n) {
      final index = _random.nextInt(list.length);
      if (!indices.contains(index)) {
        indices.add(index);
        result.add(list[index]);
      }
    }
    
    return result;
  }
  
  /// 가중치 기반 랜덤 선택
  /// 
  /// weights 리스트의 값이 클수록 해당 인덱스가 선택될 확률이 높음
  static int weightedRandom(List<double> weights) {
    final totalWeight = weights.reduce((a, b) => a + b);
    var random = _random.nextDouble() * totalWeight;
    
    for (int i = 0; i < weights.length; i++) {
      random -= weights[i];
      if (random <= 0) return i;
    }
    
    return weights.length - 1;
  }
  
  /// 확률 기반 boolean 반환
  static bool chance(double probability) {
    return _random.nextDouble() < probability;
  }
  
  /// 범위 내 랜덤 정수
  static int randomInt(int min, int max) {
    return min + _random.nextInt(max - min + 1);
  }
  
  /// 범위 내 랜덤 실수
  static double randomDouble(double min, double max) {
    return min + _random.nextDouble() * (max - min);
  }
}
