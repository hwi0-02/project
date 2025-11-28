import 'package:hive_flutter/hive_flutter.dart';
import '../models/hive/hive_models.dart';
import 'hive_adapter_registry.dart';

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
    
    // 각 모델의 어댑터를 레지스트리에 등록
    // OCP 원칙: 새 모델 추가 시 여기에 등록만 추가하면 됨
    final adapters = <(int, dynamic)>[
      (0, PetStateModelAdapter()),
      (1, UserWalletAdapter()),
      (2, TransactionTypeAdapter()),
      (3, CoinTransactionAdapter()),
      (4, ShopItemTypeAdapter()),
      (5, ItemRarityAdapter()),
      (6, ShopItemAdapter()),
      (7, InventoryItemAdapter()),
      (8, UserInventoryAdapter()),
      (9, DeckCategoryTypeAdapter()),
      (10, DeckDataAdapter()),
      (11, GachaResultAdapter()),
      (12, GachaHistoryAdapter()),
      (13, AchievementTypeAdapter()),
      (14, AchievementAdapter()),
      (15, UserAchievementAdapter()),
      (16, BadgeAdapter()),
      (17, UserAchievementDataAdapter()),
      (18, FoodSubCategoryAdapter()),
      (19, ExerciseSubCategoryAdapter()),
      (20, VocabularyLevelAdapter()),
      (21, UserSettingsAdapter()),
    ];
    
    for (final (typeId, adapter) in adapters) {
      HiveAdapterRegistry.add(
        SimpleAdapterRegistration(typeId: typeId, adapter: adapter),
      );
    }
    
    _adaptersSetup = true;
  }

  /// Hive 초기화
  static Future<void> init() async {
    if (_initialized) return;

    await Hive.initFlutter();

    // 어댑터 레지스트리 설정 및 등록
    _setupAdapterRegistry();
    HiveAdapterRegistry.registerAll();

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
