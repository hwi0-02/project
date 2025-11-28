// 뽑기펫 유닛 테스트

import 'package:flutter_test/flutter_test.dart';
import 'package:fetch_pet_widget/src/models/deck_model.dart';
import 'package:fetch_pet_widget/src/models/pet_model.dart';
import 'package:fetch_pet_widget/src/models/streak_model.dart';
import 'package:fetch_pet_widget/src/constants/pet_levels.dart';

void main() {
  group('Deck Model Tests', () {
    test('Deck - pop removes and returns first item', () {
      final deck = Deck(
        category: 'food',
        originalItems: ['A', 'B', 'C'],
        initialItems: ['A', 'B', 'C'],
      );
      
      final item = deck.pop();
      expect(item, equals('A'));
      expect(deck.remainingCount, equals(2));
    });

    test('Deck - peek returns first item without removing', () {
      final deck = Deck(
        category: 'food',
        originalItems: ['A', 'B', 'C'],
        initialItems: ['A', 'B', 'C'],
      );
      
      final item = deck.peek();
      expect(item, equals('A'));
      expect(deck.remainingCount, equals(3));
    });

    test('Deck - refills when empty after pop', () {
      final deck = Deck(
        category: 'food',
        originalItems: ['A', 'B'],
        initialItems: ['A'],
      );
      
      deck.pop(); // removes 'A', deck is now empty
      final item = deck.pop(); // should refill and return an item
      
      expect(['A', 'B'].contains(item), isTrue);
      expect(deck.remainingCount, greaterThanOrEqualTo(0));
    });

    test('Deck - reset shuffles deck', () {
      final deck = Deck(
        category: 'food',
        originalItems: ['A', 'B', 'C'],
        initialItems: [],
      );
      
      expect(deck.isEmpty, isTrue);
      deck.reset();
      expect(deck.isEmpty, isFalse);
      expect(deck.remainingCount, equals(3));
    });

    test('Deck - fromJson and toJson work correctly', () {
      final original = Deck(
        category: 'food',
        originalItems: ['A', 'B', 'C'],
        initialItems: ['B', 'C'],
      );
      
      final json = original.toJson();
      final restored = Deck.fromJson(json);
      
      expect(restored.category, equals('food'));
      expect(restored.originalItems, equals(['A', 'B', 'C']));
      expect(restored.items, equals(['B', 'C']));
    });

    test('DeckCategory - fromId returns correct category', () {
      expect(DeckCategory.fromId('food'), equals(DeckCategory.food));
      expect(DeckCategory.fromId('exercise'), equals(DeckCategory.exercise));
      expect(DeckCategory.fromId('vocabulary'), equals(DeckCategory.vocabulary));
      expect(DeckCategory.fromId('invalid'), equals(DeckCategory.food)); // default
    });
  });

  group('Pet Model Tests', () {
    test('Pet - initial state', () {
      final pet = Pet();
      
      expect(pet.level, equals(1));
      expect(pet.experience, equals(0));
      expect(pet.streakCount, equals(0));
      expect(pet.state, equals(PetState.waiting));
    });

    test('Pet - addExperience increases experience', () {
      final pet = Pet(experience: 5);
      final newPet = pet.addExperience();
      
      expect(newPet.experience, equals(6));
    });

    test('Pet - incrementStreak increases streak count', () {
      final pet = Pet(streakCount: 3);
      final newPet = pet.incrementStreak();
      
      expect(newPet.streakCount, equals(4));
    });

    test('Pet - resetStreak sets streak to 0', () {
      final pet = Pet(streakCount: 10);
      final newPet = pet.resetStreak();
      
      expect(newPet.streakCount, equals(0));
    });

    test('Pet - copyWithState changes only state', () {
      final pet = Pet(level: 5, experience: 10, streakCount: 3);
      final newPet = pet.copyWithState(PetState.completed);
      
      expect(newPet.level, equals(5));
      expect(newPet.experience, equals(10));
      expect(newPet.streakCount, equals(3));
      expect(newPet.state, equals(PetState.completed));
    });

    test('Pet - hasRainbowAura for 7+ streak', () {
      final pet = Pet(streakCount: 7);
      expect(pet.hasRainbowAura, isTrue);
      
      final pet2 = Pet(streakCount: 6);
      expect(pet2.hasRainbowAura, isFalse);
    });

    test('Pet - fromJson and toJson work correctly', () {
      final original = Pet(
        level: 5,
        experience: 25,
        streakCount: 3,
        state: PetState.completed,
      );
      
      final json = original.toJson();
      final restored = Pet.fromJson(json);
      
      expect(restored.level, equals(5));
      expect(restored.experience, equals(25));
      expect(restored.streakCount, equals(3));
      expect(restored.state, equals(PetState.completed));
    });
  });

  group('Streak Model Tests', () {
    test('Streak - initial state', () {
      final streak = Streak();
      
      expect(streak.count, equals(0));
      expect(streak.lastCompletedDate, isNull);
    });

    test('Streak - increment increases count', () {
      final streak = Streak(count: 5);
      final newStreak = streak.increment();
      
      expect(newStreak.count, equals(6));
      expect(newStreak.lastCompletedDate, isNotNull);
    });

    test('Streak - reset sets count to 0', () {
      final streak = Streak(count: 10, lastCompletedDate: DateTime.now());
      final newStreak = streak.reset();
      
      expect(newStreak.count, equals(0));
      expect(newStreak.lastCompletedDate, isNull);
    });

    test('Streak - canContinueStreak returns true for null lastCompleted', () {
      final streak = Streak();
      expect(streak.canContinueStreak(), isTrue);
    });

    test('Streak - isCompletedToday returns false for null lastCompleted', () {
      final streak = Streak();
      expect(streak.isCompletedToday(), isFalse);
    });

    test('Streak - isCompletedToday returns true for today', () {
      final streak = Streak(count: 1, lastCompletedDate: DateTime.now());
      expect(streak.isCompletedToday(), isTrue);
    });

    test('Streak - isCompletedToday returns false for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final streak = Streak(count: 1, lastCompletedDate: yesterday);
      expect(streak.isCompletedToday(), isFalse);
    });

    test('Streak - canContinueStreak returns true for yesterday', () {
      final yesterday = DateTime.now().subtract(const Duration(days: 1));
      final streak = Streak(count: 5, lastCompletedDate: yesterday);
      expect(streak.canContinueStreak(), isTrue);
    });

    test('Streak - canContinueStreak returns false for 2 days ago', () {
      final twoDaysAgo = DateTime.now().subtract(const Duration(days: 2));
      final streak = Streak(count: 5, lastCompletedDate: twoDaysAgo);
      expect(streak.canContinueStreak(), isFalse);
    });

    test('Streak - fromJson and toJson work correctly', () {
      final now = DateTime.now();
      final original = Streak(count: 5, lastCompletedDate: now);
      
      final json = original.toJson();
      final restored = Streak.fromJson(json);
      
      expect(restored.count, equals(5));
      expect(restored.lastCompletedDate?.day, equals(now.day));
    });
  });
}
