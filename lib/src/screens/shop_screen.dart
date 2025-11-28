import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../models/hive/hive_models.dart';
import '../providers/providers.dart';
import '../services/gacha_service.dart';
import '../widgets/widgets.dart';

/// 상점 화면
class ShopScreen extends ConsumerStatefulWidget {
  const ShopScreen({super.key});

  @override
  ConsumerState<ShopScreen> createState() => _ShopScreenState();
}

class _ShopScreenState extends ConsumerState<ShopScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  
  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          '상점',
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        actions: const [
          Padding(
            padding: EdgeInsets.only(right: 16),
            child: CoinDisplayWidget(),
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          labelColor: AppColors.primary,
          unselectedLabelColor: AppColors.textSecondary,
          indicatorColor: AppColors.primary,
          tabs: const [
            Tab(text: '가챠'),
            Tab(text: '인벤토리'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          const _GachaTab(),
          const _InventoryTab(),
        ],
      ),
    );
  }
}

/// 가챠 탭
class _GachaTab extends ConsumerStatefulWidget {
  const _GachaTab();

  @override
  ConsumerState<_GachaTab> createState() => _GachaTabState();
}

class _GachaTabState extends ConsumerState<_GachaTab> {
  bool _isAnimating = false;
  GachaResult? _lastResult;
  ShopItem? _lastItem;

  Future<void> _performGacha() async {
    final wallet = ref.read(walletProvider);
    
    if (wallet.coins < GachaService.gachaCost) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('코인이 부족해요!'),
          backgroundColor: AppColors.error,
        ),
      );
      return;
    }

    setState(() {
      _isAnimating = true;
      _lastResult = null;
      _lastItem = null;
    });

    // 코인 차감
    await ref.read(walletProvider.notifier).spendCoins(
      GachaService.gachaCost, 
      '가챠',
    );

    // 가챠 실행
    final gachaService = ref.read(gachaServiceProvider);
    final history = ref.read(gachaHistoryProvider);
    final result = await gachaService.pull(history);

    if (result != null) {
      // 결과 저장
      await ref.read(gachaHistoryProvider.notifier).addResult(result);
      
      // 인벤토리에 추가
      await ref.read(inventoryProvider.notifier).addItem(result.itemId, 'gacha');

      final item = await gachaService.getItemById(result.itemId);

      // 애니메이션 딜레이
      await Future.delayed(const Duration(milliseconds: 1500));

      setState(() {
        _lastResult = result;
        _lastItem = item;
        _isAnimating = false;
      });
    } else {
      setState(() {
        _isAnimating = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final wallet = ref.watch(walletProvider);
    final history = ref.watch(gachaHistoryProvider);
    
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // 가챠 머신
          Container(
            height: 300,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.primary.withValues(alpha: 0.3),
                  AppColors.primaryLight.withValues(alpha: 0.2),
                ],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppColors.primary.withValues(alpha: 0.5),
                width: 2,
              ),
            ),
            child: Center(
              child: _buildGachaContent(),
            ),
          ),

          const SizedBox(height: 24),

          // 가챠 버튼
          ElevatedButton(
            onPressed: _isAnimating ? null : _performGacha,
            style: ElevatedButton.styleFrom(
              backgroundColor: wallet.coins >= GachaService.gachaCost
                  ? AppColors.primary
                  : Colors.grey,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.auto_awesome, color: Colors.white),
                const SizedBox(width: 8),
                Text(
                  '가챠 뽑기 (${GachaService.gachaCost} 코인)',
                  style: const TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // 피티 정보
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardBackground,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  '피티 카운터',
                  style: TextStyle(
                    color: AppColors.textSecondary,
                  ),
                ),
                Row(
                  children: [
                    Text(
                      '${history.pityCounter}/10',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: history.isPityGuaranteed
                            ? AppColors.success
                            : AppColors.textPrimary,
                      ),
                    ),
                    if (history.isPityGuaranteed) ...[
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.success.withValues(alpha: 0.2),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Text(
                          '희귀↑ 보장!',
                          style: TextStyle(
                            fontSize: 12,
                            color: AppColors.success,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          // 확률 안내
          _buildProbabilityInfo(),
        ],
      ),
    );
  }

  Widget _buildGachaContent() {
    if (_isAnimating) {
      return Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(
            width: 80,
            height: 80,
            child: CircularProgressIndicator(
              color: AppColors.primary,
              strokeWidth: 4,
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            '두근두근...',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      );
    }

    if (_lastResult != null && _lastItem != null) {
      return _buildResultDisplay();
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          Icons.inventory_2,
          size: 80,
          color: AppColors.primary.withValues(alpha: 0.5),
        ),
        const SizedBox(height: 16),
        const Text(
          '가챠를 뽑아보세요!',
          style: TextStyle(
            fontSize: 18,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildResultDisplay() {
    final rarity = ItemRarity.values[_lastResult!.rarity];
    final rarityColor = _getRarityColor(rarity);
    final rarityName = _getRarityName(rarity);

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // 희귀도 배경
        Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: rarityColor.withValues(alpha: 0.2),
            border: Border.all(
              color: rarityColor,
              width: 3,
            ),
            boxShadow: [
              BoxShadow(
                color: rarityColor.withValues(alpha: 0.5),
                blurRadius: 20,
                spreadRadius: 2,
              ),
            ],
          ),
          child: Icon(
            _getItemTypeIcon(_lastItem!.type),
            size: 50,
            color: rarityColor,
          ),
        ),
        const SizedBox(height: 16),
        // 희귀도
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
          decoration: BoxDecoration(
            color: rarityColor.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            rarityName,
            style: TextStyle(
              color: rarityColor,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
        const SizedBox(height: 8),
        // 아이템 이름
        Text(
          _lastItem!.name,
          style: const TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: AppColors.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        // 아이템 설명
        Text(
          _lastItem!.description,
          style: const TextStyle(
            fontSize: 14,
            color: AppColors.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildProbabilityInfo() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '획득 확률',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 12),
          _buildProbabilityRow('일반', '70%', Colors.grey),
          _buildProbabilityRow('희귀', '20%', AppColors.gachaRare),
          _buildProbabilityRow('에픽', '8%', AppColors.gachaEpic),
          _buildProbabilityRow('전설', '2%', AppColors.gachaLegendary),
          const SizedBox(height: 8),
          const Text(
            '※ 10회 연속 일반 등급 시 희귀 이상 보장',
            style: TextStyle(
              fontSize: 12,
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProbabilityRow(String name, String prob, Color color) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(name, style: const TextStyle(color: AppColors.textPrimary)),
          const Spacer(),
          Text(prob, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.rare:
        return AppColors.gachaRare;
      case ItemRarity.epic:
        return AppColors.gachaEpic;
      case ItemRarity.legendary:
        return AppColors.gachaLegendary;
    }
  }

  String _getRarityName(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return '일반';
      case ItemRarity.rare:
        return '희귀';
      case ItemRarity.epic:
        return '에픽';
      case ItemRarity.legendary:
        return '★전설★';
    }
  }

  IconData _getItemTypeIcon(ShopItemType type) {
    switch (type) {
      case ShopItemType.accessory:
        return Icons.auto_awesome;
      case ShopItemType.background:
        return Icons.wallpaper;
      case ShopItemType.effect:
        return Icons.blur_on;
      case ShopItemType.food:
        return Icons.restaurant;
      case ShopItemType.toy:
        return Icons.toys;
    }
  }
}

/// 인벤토리 탭
class _InventoryTab extends ConsumerWidget {
  const _InventoryTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final inventory = ref.watch(inventoryProvider);
    final gachaService = ref.read(gachaServiceProvider);

    if (inventory.items.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.inventory_2,
              size: 80,
              color: Colors.grey.withValues(alpha: 0.5),
            ),
            const SizedBox(height: 16),
            const Text(
              '아직 아이템이 없어요',
              style: TextStyle(
                fontSize: 18,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '가챠를 뽑아서 아이템을 모아보세요!',
              style: TextStyle(
                color: AppColors.textHint,
              ),
            ),
          ],
        ),
      );
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.8,
      ),
      itemCount: inventory.items.length,
      itemBuilder: (context, index) {
        final inventoryItem = inventory.items[index];
        
        return FutureBuilder<ShopItem?>(
          future: gachaService.getItemById(inventoryItem.itemId),
          builder: (context, snapshot) {
            if (!snapshot.hasData || snapshot.data == null) {
              return const SizedBox();
            }
            
            return _InventoryItemCard(
              item: snapshot.data!,
              quantity: inventoryItem.quantity,
            );
          },
        );
      },
    );
  }
}

class _InventoryItemCard extends StatelessWidget {
  final ShopItem item;
  final int quantity;

  const _InventoryItemCard({
    required this.item,
    required this.quantity,
  });

  @override
  Widget build(BuildContext context) {
    final rarityColor = _getRarityColor(item.rarity);

    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBackground,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: rarityColor.withValues(alpha: 0.5),
          width: 2,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // 아이콘
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: rarityColor.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              _getItemTypeIcon(item.type),
              size: 30,
              color: rarityColor,
            ),
          ),
          const SizedBox(height: 8),
          // 이름
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Text(
              item.name,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
          // 수량
          if (quantity > 1) ...[
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.textSecondary.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'x$quantity',
                style: const TextStyle(
                  fontSize: 10,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  Color _getRarityColor(ItemRarity rarity) {
    switch (rarity) {
      case ItemRarity.common:
        return Colors.grey;
      case ItemRarity.rare:
        return AppColors.gachaRare;
      case ItemRarity.epic:
        return AppColors.gachaEpic;
      case ItemRarity.legendary:
        return AppColors.gachaLegendary;
    }
  }

  IconData _getItemTypeIcon(ShopItemType type) {
    switch (type) {
      case ShopItemType.accessory:
        return Icons.auto_awesome;
      case ShopItemType.background:
        return Icons.wallpaper;
      case ShopItemType.effect:
        return Icons.blur_on;
      case ShopItemType.food:
        return Icons.restaurant;
      case ShopItemType.toy:
        return Icons.toys;
    }
  }
}
