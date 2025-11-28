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
  static bool _adaptersSetup = false;

  /// 어댑터 레지스트리 설정 (최초 1회)
  static void _setupAdapterRegistry() {
    if (_adaptersSetup) return;
    
    // 각 모델의 어댑터를 타입 명시하여 직접 등록
    // 타입을 명시하지 않으면 Hive에서 올바른 어댑터를 찾지 못함
    if (!Hive.isAdapterRegistered(0)) {
      Hive.registerAdapter<PetStateModel>(PetStateModelAdapter());
    }
    if (!Hive.isAdapterRegistered(1)) {
      Hive.registerAdapter<UserWallet>(UserWalletAdapter());
    }
    if (!Hive.isAdapterRegistered(2)) {
      Hive.registerAdapter<TransactionType>(TransactionTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(3)) {
      Hive.registerAdapter<CoinTransaction>(CoinTransactionAdapter());
    }
    if (!Hive.isAdapterRegistered(4)) {
      Hive.registerAdapter<ShopItemType>(ShopItemTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(5)) {
      Hive.registerAdapter<ItemRarity>(ItemRarityAdapter());
    }
    if (!Hive.isAdapterRegistered(6)) {
      Hive.registerAdapter<ShopItem>(ShopItemAdapter());
    }
    if (!Hive.isAdapterRegistered(7)) {
      Hive.registerAdapter<InventoryItem>(InventoryItemAdapter());
    }
    if (!Hive.isAdapterRegistered(8)) {
      Hive.registerAdapter<UserInventory>(UserInventoryAdapter());
    }
    if (!Hive.isAdapterRegistered(9)) {
      Hive.registerAdapter<DeckCategoryType>(DeckCategoryTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(10)) {
      Hive.registerAdapter<DeckData>(DeckDataAdapter());
    }
    if (!Hive.isAdapterRegistered(11)) {
      Hive.registerAdapter<GachaResult>(GachaResultAdapter());
    }
    if (!Hive.isAdapterRegistered(12)) {
      Hive.registerAdapter<GachaHistory>(GachaHistoryAdapter());
    }
    if (!Hive.isAdapterRegistered(13)) {
      Hive.registerAdapter<AchievementType>(AchievementTypeAdapter());
    }
    if (!Hive.isAdapterRegistered(14)) {
      Hive.registerAdapter<Achievement>(AchievementAdapter());
    }
    if (!Hive.isAdapterRegistered(15)) {
      Hive.registerAdapter<UserAchievement>(UserAchievementAdapter());
    }
    if (!Hive.isAdapterRegistered(16)) {
      Hive.registerAdapter<Badge>(BadgeAdapter());
    }
    if (!Hive.isAdapterRegistered(17)) {
      Hive.registerAdapter<UserAchievementData>(UserAchievementDataAdapter());
    }
    if (!Hive.isAdapterRegistered(18)) {
      Hive.registerAdapter<FoodSubCategory>(FoodSubCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(19)) {
      Hive.registerAdapter<ExerciseSubCategory>(ExerciseSubCategoryAdapter());
    }
    if (!Hive.isAdapterRegistered(20)) {
      Hive.registerAdapter<VocabularyLevel>(VocabularyLevelAdapter());
    }
    if (!Hive.isAdapterRegistered(21)) {
      Hive.registerAdapter<UserSettings>(UserSettingsAdapter());
    }
    
    _adaptersSetup = true;
  }

  /// Hive 초기화
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // 어댑터 등록
    _setupAdapterRegistry();

    // Box 열기
    await _openBoxes();

    _initialized = true;
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
