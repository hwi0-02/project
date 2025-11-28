import 'package:flutter_test/flutter_test.dart';
import 'package:fetch_pet_widget/src/models/hive/hive_models.dart';

void main() {
  group('PetStateModel Tests', () {
    test('기본 생성 시 초기값 확인', () {
      final pet = PetStateModel();
      
      expect(pet.hungerPoint, 100);
      expect(pet.moodPoint, 100);
      expect(pet.level, 1);
      expect(pet.experience, 0);
      expect(pet.streakCount, 0);
      expect(pet.petName, '뽑기펫');
      expect(pet.isHungry, false);
      expect(pet.isSulky, false);
    });

    test('feed()가 포만감과 경험치를 증가시킴', () {
      final pet = PetStateModel(hungerPoint: 50);
      
      pet.feed();
      
      expect(pet.hungerPoint, 70); // 50 + 20
      expect(pet.experience, 10); // +10 exp
    });

    test('feed()가 최대 포만감을 초과하지 않음', () {
      final pet = PetStateModel(hungerPoint: 90);
      
      pet.feed();
      
      expect(pet.hungerPoint, 100); // clamp to 100
    });

    test('pet()이 하루 최대 5회 제한', () {
      final pet = PetStateModel();
      
      // 5회 성공
      for (int i = 0; i < 5; i++) {
        expect(pet.pet(), true);
      }
      
      // 6회째 실패
      expect(pet.pet(), false);
      expect(pet.todayPetCount, 5);
    });

    test('pet()이 애정도와 경험치를 증가시킴', () {
      final pet = PetStateModel(moodPoint: 50);
      
      pet.pet();
      
      expect(pet.moodPoint, 60); // 50 + 10
      expect(pet.experience, 5); // +5 exp
    });

    test('addExperience()가 레벨업 처리', () {
      final pet = PetStateModel(experience: 95);
      
      pet.addExperience(10);
      
      expect(pet.level, 2); // 레벨업
      expect(pet.experience, 5); // 100 - 95 + 10 = 15 -> 레벨업 후 5
    });

    test('isHungry가 30 이하일 때 true', () {
      final pet = PetStateModel(hungerPoint: 30);
      expect(pet.isHungry, true);
      
      final pet2 = PetStateModel(hungerPoint: 31);
      expect(pet2.isHungry, false);
    });

    test('isSulky가 30 이하일 때 true', () {
      final pet = PetStateModel(moodPoint: 30);
      expect(pet.isSulky, true);
      
      final pet2 = PetStateModel(moodPoint: 31);
      expect(pet2.isSulky, false);
    });

    test('happiness가 포만감과 애정도의 평균', () {
      final pet = PetStateModel(hungerPoint: 80, moodPoint: 60);
      expect(pet.happiness, 70);
    });

    test('applyTimeDecay()가 시간에 따라 감소', () {
      final twoHoursAgo = DateTime.now().subtract(const Duration(hours: 2));
      final pet = PetStateModel(lastAccessTime: twoHoursAgo);
      
      pet.applyTimeDecay();
      
      expect(pet.hungerPoint, 90); // 100 - (2 * 5)
      expect(pet.moodPoint, 94); // 100 - (2 * 3)
    });

    test('checkAndUpdateStreak()가 연속 출석 관리', () {
      final pet = PetStateModel();
      
      // 첫 출석
      final firstCheck = pet.checkAndUpdateStreak();
      expect(firstCheck, true);
      expect(pet.streakCount, 1);
      
      // 같은 날 다시 체크 - 중복 방지
      final secondCheck = pet.checkAndUpdateStreak();
      expect(secondCheck, false);
      expect(pet.streakCount, 1);
    });
  });

  group('UserWallet Tests', () {
    test('기본 생성 시 초기값 확인', () {
      final wallet = UserWallet();
      
      expect(wallet.coins, 0);
      expect(wallet.totalEarned, 0);
      expect(wallet.totalSpent, 0);
    });

    test('earnCoins()가 코인과 총 획득량 증가', () {
      final wallet = UserWallet();
      
      wallet.earnCoins(50, '테스트');
      
      expect(wallet.coins, 50);
      expect(wallet.totalEarned, 50);
      expect(wallet.transactions.length, 1);
    });

    test('spendCoins()가 코인 부족 시 실패', () {
      final wallet = UserWallet(coins: 30);
      
      final result = wallet.spendCoins(50, '테스트');
      
      expect(result, false);
      expect(wallet.coins, 30); // 변화 없음
    });

    test('spendCoins()가 충분한 코인 시 성공', () {
      final wallet = UserWallet(coins: 100);
      
      final result = wallet.spendCoins(50, '테스트');
      
      expect(result, true);
      expect(wallet.coins, 50);
      expect(wallet.totalSpent, 50);
    });

    test('claimDailyReward()가 보상 지급', () {
      final wallet = UserWallet();
      
      final reward = wallet.claimDailyReward(5);
      
      expect(reward, 20); // 10 + (5 * 2)
      expect(wallet.coins, 20);
    });

    test('claimDailyReward()가 같은 날 중복 불가', () {
      final wallet = UserWallet();
      
      wallet.claimDailyReward(1);
      final secondReward = wallet.claimDailyReward(1);
      
      expect(secondReward, 0);
    });
  });

  group('DeckData Tests', () {
    test('기본 생성 및 뽑기', () {
      final deck = DeckData(
        category: DeckCategoryType.food,
        originalItems: ['A', 'B', 'C'],
      );
      
      expect(deck.remainingCount, 3);
      expect(deck.totalCount, 3);
    });

    test('draw()가 카드를 뽑고 제거', () {
      final deck = DeckData(
        category: DeckCategoryType.food,
        originalItems: ['A', 'B', 'C'],
      );
      
      final drawn = deck.draw();
      
      expect(drawn, isNotNull);
      expect(['A', 'B', 'C'].contains(drawn), true);
      expect(deck.remainingCount, 2);
      expect(deck.todayDrawCount, 1);
    });

    test('reshuffle()이 덱을 초기화', () {
      final deck = DeckData(
        category: DeckCategoryType.food,
        originalItems: ['A', 'B', 'C'],
      );
      
      deck.draw();
      deck.draw();
      expect(deck.remainingCount, 1);
      
      deck.reshuffle();
      expect(deck.remainingCount, 3);
    });

    test('canDraw()가 무료 유저 일일 제한 체크', () {
      final deck = DeckData(
        category: DeckCategoryType.food,
        originalItems: ['A', 'B', 'C', 'D', 'E'],
      );
      
      // 무료 유저 3회 제한
      deck.draw();
      deck.draw();
      deck.draw();
      
      expect(deck.canDraw(false), false); // 무료 유저
      expect(deck.canDraw(true), true); // 프리미엄 유저
    });
  });

  group('GachaHistory Tests', () {
    test('기본 생성', () {
      final history = GachaHistory();
      
      expect(history.totalGachaCount, 0);
      expect(history.pityCounter, 0);
      expect(history.isPityGuaranteed, false);
    });

    test('addResult()가 피티 카운터 증가', () {
      final history = GachaHistory();
      
      // 일반 등급 추가
      history.addResult(GachaResult(
        itemId: 'test',
        rarity: 0, // common
        coinSpent: 50,
      ));
      
      expect(history.totalGachaCount, 1);
      expect(history.pityCounter, 1);
    });

    test('addResult()가 희귀 등급 시 피티 리셋', () {
      final history = GachaHistory(pityCounter: 5);
      
      // 희귀 등급 추가
      history.addResult(GachaResult(
        itemId: 'test',
        rarity: 1, // rare
        coinSpent: 50,
      ));
      
      expect(history.pityCounter, 0); // 리셋
    });

    test('isPityGuaranteed가 9회 이상일 때 true', () {
      final history = GachaHistory(pityCounter: 9);
      expect(history.isPityGuaranteed, true);
      
      final history2 = GachaHistory(pityCounter: 8);
      expect(history2.isPityGuaranteed, false);
    });
  });

  group('UserInventory Tests', () {
    test('addItem()이 새 아이템 추가', () {
      final inventory = UserInventory();
      
      inventory.addItem('item1', 'gacha');
      
      expect(inventory.items.length, 1);
      expect(inventory.hasItem('item1'), true);
    });

    test('addItem()이 기존 아이템 수량 증가', () {
      final inventory = UserInventory();
      
      inventory.addItem('item1', 'gacha');
      inventory.addItem('item1', 'gacha');
      
      expect(inventory.items.length, 1);
      expect(inventory.getQuantity('item1'), 2);
    });

    test('useItem()이 수량 감소', () {
      final inventory = UserInventory();
      inventory.addItem('item1', 'gacha');
      inventory.addItem('item1', 'gacha');
      
      final result = inventory.useItem('item1');
      
      expect(result, true);
      expect(inventory.getQuantity('item1'), 1);
    });

    test('useItem()이 없는 아이템 시 실패', () {
      final inventory = UserInventory();
      
      final result = inventory.useItem('item1');
      
      expect(result, false);
    });
  });

  group('UserAchievementData Tests', () {
    test('updateAchievement()가 진행 추적', () {
      final data = UserAchievementData();
      
      data.updateAchievement('streak_7', 5, 7);
      
      final progress = data.getProgress('streak_7');
      expect(progress, isNotNull);
      expect(progress!.currentValue, 5);
      expect(progress.isCompleted, false);
    });

    test('updateAchievement()가 목표 달성 시 완료 처리', () {
      final data = UserAchievementData();
      
      data.updateAchievement('streak_7', 7, 7);
      
      final progress = data.getProgress('streak_7');
      expect(progress!.isCompleted, true);
      expect(progress.completedAt, isNotNull);
    });

    test('earnBadge()가 뱃지 추가', () {
      final data = UserAchievementData();
      
      data.earnBadge('badge1');
      
      expect(data.hasBadge('badge1'), true);
      expect(data.hasBadge('badge2'), false);
    });
  });
}
