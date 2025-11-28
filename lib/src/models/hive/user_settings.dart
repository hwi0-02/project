import 'package:hive/hive.dart';

part 'user_settings.g.dart';

/// 음식 서브카테고리
@HiveType(typeId: 18)
enum FoodSubCategory {
  @HiveField(0)
  korean('korean', '한식', '🍚'),
  @HiveField(1)
  chinese('chinese', '중식', '🥟'),
  @HiveField(2)
  japanese('japanese', '일식', '🍣'),
  @HiveField(3)
  western('western', '양식', '🍝');

  final String id;
  final String name;
  final String emoji;

  const FoodSubCategory(this.id, this.name, this.emoji);

  static FoodSubCategory fromId(String id) {
    return FoodSubCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => FoodSubCategory.korean,
    );
  }
}

/// 운동 서브카테고리
@HiveType(typeId: 19)
enum ExerciseSubCategory {
  @HiveField(0)
  stretching('stretching', '스트레칭', '🧘'),
  @HiveField(1)
  strength('strength', '근력 운동', '💪'),
  @HiveField(2)
  cardio('cardio', '유산소 운동', '🏃');

  final String id;
  final String name;
  final String emoji;

  const ExerciseSubCategory(this.id, this.name, this.emoji);

  static ExerciseSubCategory fromId(String id) {
    return ExerciseSubCategory.values.firstWhere(
      (c) => c.id == id,
      orElse: () => ExerciseSubCategory.stretching,
    );
  }
}

/// 영단어 레벨
@HiveType(typeId: 20)
enum VocabularyLevel {
  @HiveField(0)
  beginner('beginner', '초급', '🌱'),
  @HiveField(1)
  intermediate('intermediate', '중급', '🌿'),
  @HiveField(2)
  advanced('advanced', '고급', '🌳');

  final String id;
  final String name;
  final String emoji;

  const VocabularyLevel(this.id, this.name, this.emoji);

  static VocabularyLevel fromId(String id) {
    return VocabularyLevel.values.firstWhere(
      (c) => c.id == id,
      orElse: () => VocabularyLevel.beginner,
    );
  }
}

/// 사용자 설정 모델
@HiveType(typeId: 21)
class UserSettings extends HiveObject {
  /// 선택된 음식 서브카테고리
  @HiveField(0)
  FoodSubCategory foodSubCategory;

  /// 선택된 운동 서브카테고리
  @HiveField(1)
  ExerciseSubCategory exerciseSubCategory;

  /// 선택된 영단어 레벨
  @HiveField(2)
  VocabularyLevel vocabularyLevel;

  UserSettings({
    this.foodSubCategory = FoodSubCategory.korean,
    this.exerciseSubCategory = ExerciseSubCategory.stretching,
    this.vocabularyLevel = VocabularyLevel.beginner,
  });

  /// 설정 복사본 생성
  UserSettings copyWith({
    FoodSubCategory? foodSubCategory,
    ExerciseSubCategory? exerciseSubCategory,
    VocabularyLevel? vocabularyLevel,
  }) {
    return UserSettings(
      foodSubCategory: foodSubCategory ?? this.foodSubCategory,
      exerciseSubCategory: exerciseSubCategory ?? this.exerciseSubCategory,
      vocabularyLevel: vocabularyLevel ?? this.vocabularyLevel,
    );
  }
}
