import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/hive_models.dart';

/// Hive 데이터베이스 서비스
/// 기획서2.md 기반: 로컬 데이터 영속화 담당
class HiveService {
  static const String petStateBoxName = 'petState';
  static const String walletBoxName = 'wallet';
  static const String inventoryBoxName = 'inventory';
  static const String deckBoxName = 'deck';
  static const String gachaBoxName = 'gacha';
  static const String achievementBoxName = 'achievement';
  static const String settingsBoxName = 'settings';

  static bool _initialized = false;

  /// Hive 초기화
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // 어댑터 등록
    _registerAdapters();

    // Box 열기
    await _openBoxes();

    _initialized = true;
  }

  /// 어댑터 등록
  static void _registerAdapters() {
    // Pet State (typeId: 0)
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter(PetStateModelAdapter());
    }

    // User Wallet (typeId: 1)
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter(UserWalletAdapter());
    }

    // Transaction Type (typeId: 2)
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter(TransactionTypeAdapter());
    }

    // Coin Transaction (typeId: 3)
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter(CoinTransactionAdapter());
    }

    // Shop Item Type (typeId: 4)
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter(ShopItemTypeAdapter());
    }

    // Item Rarity (typeId: 5)
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter(ItemRarityAdapter());
    }

    // Shop Item (typeId: 6)
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter(ShopItemAdapter());
    }

    // Inventory Item (typeId: 7)
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter(InventoryItemAdapter());
    }

    // User Inventory (typeId: 8)
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter(UserInventoryAdapter());
    }

    // Deck Category Type (typeId: 9)
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter(DeckCategoryTypeAdapter());
    }

    // Deck Data (typeId: 10)
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter(DeckDataAdapter());
    }

    // Gacha Result (typeId: 11)
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter(GachaResultAdapter());
    }

    // Gacha History (typeId: 12)
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter(GachaHistoryAdapter());
    }

    // Achievement Type (typeId: 13)
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter(AchievementTypeAdapter());
    }

    // Achievement (typeId: 14)
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter(AchievementAdapter());
    }

    // User Achievement (typeId: 15)
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter(UserAchievementAdapter());
    }

    // Badge (typeId: 16)
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter(BadgeAdapter());
    }

    // User Achievement Data (typeId: 17)
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter(UserAchievementDataAdapter());
    }

    // Food SubCategory (typeId: 18)
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter(FoodSubCategoryAdapter());
    }

    // Exercise SubCategory (typeId: 19)
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter(ExerciseSubCategoryAdapter());
    }

    // Vocabulary Level (typeId: 20)
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter(VocabularyLevelAdapter());
    }

    // User Settings (typeId: 21)
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter(UserSettingsAdapter());
    }
  }

  /// Box 열기
  static Future<void> _openBoxes() async {
    await Hive.openBox<PetStateModel>(petStateBoxName);
    await Hive.openBox<UserWallet>(walletBoxName);
    await Hive.openBox<UserInventory>(inventoryBoxName);
    await Hive.openBox<DeckData>(deckBoxName);
    await Hive.openBox<GachaHistory>(gachaBoxName);
    await Hive.openBox<UserAchievementData>(achievementBoxName);
    await Hive.openBox<UserSettings>(settingsBoxName);
  }

  // ===== Pet State =====
  static Box<PetStateModel> get petStateBox =>
      Hive.box<PetStateModel>(petStateBoxName);

  static PetStateModel getPetState() {
    final box = petStateBox;
    if (box.isEmpty) {
      final defaultState = PetStateModel();
      box.put('current', defaultState);
      return defaultState;
    }
    return box.get('current')!;
  }

  static Future<void> savePetState(PetStateModel state) async {
    await petStateBox.put('current', state);
  }

  // ===== Wallet =====
  static Box<UserWallet> get walletBox => Hive.box<UserWallet>(walletBoxName);

  static UserWallet getWallet() {
    final box = walletBox;
    if (box.isEmpty) {
      final defaultWallet = UserWallet(coins: 100); // 초기 지급 100코인
      box.put('current', defaultWallet);
      return defaultWallet;
    }
    return box.get('current')!;
  }

  static Future<void> saveWallet(UserWallet wallet) async {
    await walletBox.put('current', wallet);
  }

  // ===== Inventory =====
  static Box<UserInventory> get inventoryBox =>
      Hive.box<UserInventory>(inventoryBoxName);

  static UserInventory getInventory() {
    final box = inventoryBox;
    if (box.isEmpty) {
      final defaultInventory = UserInventory();
      box.put('current', defaultInventory);
      return defaultInventory;
    }
    return box.get('current')!;
  }

  static Future<void> saveInventory(UserInventory inventory) async {
    await inventoryBox.put('current', inventory);
  }

  // ===== Deck =====
  static Box<DeckData> get deckBox => Hive.box<DeckData>(deckBoxName);

  static DeckData? getDeck(DeckCategoryType category) {
    return deckBox.get(category.name);
  }

  static Future<void> saveDeck(DeckData deck) async {
    await deckBox.put(deck.category.name, deck);
  }

  static List<DeckData> getAllDecks() {
    return deckBox.values.toList();
  }

  // ===== Gacha =====
  static Box<GachaHistory> get gachaBox =>
      Hive.box<GachaHistory>(gachaBoxName);

  static GachaHistory getGachaHistory() {
    final box = gachaBox;
    if (box.isEmpty) {
      final defaultHistory = GachaHistory();
      box.put('current', defaultHistory);
      return defaultHistory;
    }
    return box.get('current')!;
  }

  static Future<void> saveGachaHistory(GachaHistory history) async {
    await gachaBox.put('current', history);
  }

  // ===== Achievement =====
  static Box<UserAchievementData> get achievementBox =>
      Hive.box<UserAchievementData>(achievementBoxName);

  static UserAchievementData getAchievementData() {
    final box = achievementBox;
    if (box.isEmpty) {
      final defaultData = UserAchievementData();
      box.put('current', defaultData);
      return defaultData;
    }
    return box.get('current')!;
  }

  static Future<void> saveAchievementData(UserAchievementData data) async {
    await achievementBox.put('current', data);
  }

  // ===== Settings =====
  static Box<UserSettings> get settingsBox =>
      Hive.box<UserSettings>(settingsBoxName);

  static UserSettings getSettings() {
    final box = settingsBox;
    if (box.isEmpty) {
      final defaultSettings = UserSettings();
      box.put('current', defaultSettings);
      return defaultSettings;
    }
    return box.get('current')!;
  }

  static Future<void> saveSettings(UserSettings settings) async {
    await settingsBox.put('current', settings);
  }

  // ===== 유틸리티 =====

  /// 모든 데이터 초기화 (디버그/테스트용)
  static Future<void> clearAllData() async {
    await petStateBox.clear();
    await walletBox.clear();
    await inventoryBox.clear();
    await deckBox.clear();
    await gachaBox.clear();
    await achievementBox.clear();
    await settingsBox.clear();
  }

  /// Hive 종료
  static Future<void> close() async {
    await Hive.close();
    _initialized = false;
  }
}
