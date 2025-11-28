import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../constants/constants.dart';
import '../providers/providers.dart';
import '../models/hive/hive_models.dart';

/// 설정 화면
class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  bool _isPremium = false;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _loadPremiumStatus();
  }

  Future<void> _loadPremiumStatus() async {
    final purchaseRepository = ref.read(purchaseRepositoryProvider);
    final isPremium = await purchaseRepository.checkPremiumStatus();
    if (mounted) {
      setState(() {
        _isPremium = isPremium;
      });
    }
  }

  Future<void> _handlePurchase() async {
    setState(() => _isLoading = true);
    
    try {
      final purchaseRepository = ref.read(purchaseRepositoryProvider);
      final success = await purchaseRepository.purchasePremium();
      
      if (mounted) {
        if (success) {
          setState(() => _isPremium = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('프리미엄 구매 완료! 🎉')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('구매에 실패했습니다. 다시 시도해주세요.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  Future<void> _handleRestore() async {
    setState(() => _isLoading = true);
    
    try {
      final purchaseRepository = ref.read(purchaseRepositoryProvider);
      final success = await purchaseRepository.restorePurchase();
      
      if (mounted) {
        if (success) {
          setState(() => _isPremium = true);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('구매 복원 완료! 🎉')),
          );
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('복원할 구매 내역이 없습니다.')),
          );
        }
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('오류가 발생했습니다: $e')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// 설정 변경 후 덱 리로드
  Future<void> _onSettingChanged() async {
    final deckRepo = ref.read(deckRepositoryProvider);
    await deckRepo.reloadDecksWithSettings();
    
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('설정이 저장되었습니다! 🎯'),
          duration: Duration(seconds: 1),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(userSettingsProvider);
    
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: AppColors.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          AppStrings.settingsTitle,
          style: TextStyle(
            color: AppColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // 카테고리 설정 섹션
          _buildSectionHeader('🎯 카테고리 설정'),
          const SizedBox(height: 12),
          
          // 밥 카테고리 설정
          _buildCategorySettingCard<FoodSubCategory>(
            emoji: '🍚',
            title: '밥',
            subtitle: '어떤 종류의 음식을 추천받을까요?',
            currentValue: settings.foodSubCategory.name,
            options: FoodSubCategory.values,
            selectedOption: settings.foodSubCategory,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier)
                  .setFoodSubCategory(value);
              await _onSettingChanged();
            },
            optionBuilder: (option) => Text(option.name),
          ),
          
          const SizedBox(height: 12),
          
          // 운동 카테고리 설정
          _buildCategorySettingCard<ExerciseSubCategory>(
            emoji: '💪',
            title: '운동',
            subtitle: '어떤 종류의 운동을 추천받을까요?',
            currentValue: settings.exerciseSubCategory.name,
            options: ExerciseSubCategory.values,
            selectedOption: settings.exerciseSubCategory,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier)
                  .setExerciseSubCategory(value);
              await _onSettingChanged();
            },
            optionBuilder: (option) => Text(option.name),
          ),
          
          const SizedBox(height: 12),
          
          // 영단어 레벨 설정
          _buildCategorySettingCard<VocabularyLevel>(
            emoji: '📖',
            title: '오늘의 영단어',
            subtitle: '어떤 난이도의 영단어를 공부할까요?',
            currentValue: settings.vocabularyLevel.name,
            options: VocabularyLevel.values,
            selectedOption: settings.vocabularyLevel,
            onChanged: (value) async {
              await ref.read(userSettingsProvider.notifier)
                  .setVocabularyLevel(value);
              await _onSettingChanged();
            },
            optionBuilder: (option) => Text(option.name),
          ),
          
          const SizedBox(height: 24),
          const Divider(),
          const SizedBox(height: 16),
          
          // 위젯 설치 가이드
          _buildSettingsTile(
            icon: Icons.widgets_outlined,
            title: AppStrings.settingsWidgetGuide,
            onTap: () {
              // TODO: 위젯 설치 가이드 화면으로 이동
            },
          ),
          
          const Divider(),
          
          // 프리미엄 섹션
          _buildPremiumSection(context),
          
          const Divider(),
          
          // 개인정보처리방침
          _buildSettingsTile(
            icon: Icons.privacy_tip_outlined,
            title: AppStrings.settingsPrivacy,
            onTap: () {
              // TODO: 개인정보처리방침 URL 열기
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildCategorySettingCard<T>({
    required String emoji,
    required String title,
    required String subtitle,
    required String currentValue,
    required List<T> options,
    required T selectedOption,
    required Function(T) onChanged,
    required Widget Function(T) optionBuilder,
  }) {
    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Text(emoji, style: const TextStyle(fontSize: 24)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: options.map((option) {
                final isSelected = option == selectedOption;
                return ChoiceChip(
                  label: optionBuilder(option),
                  selected: isSelected,
                  onSelected: (_) => onChanged(option),
                  selectedColor: AppColors.primary.withValues(alpha: 0.2),
                  backgroundColor: Colors.grey[100],
                  labelStyle: TextStyle(
                    color: isSelected ? AppColors.primary : Colors.grey[700],
                    fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                  side: BorderSide(
                    color: isSelected ? AppColors.primary : Colors.grey[300]!,
                  ),
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Widget? trailing,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary),
      title: Text(
        title,
        style: const TextStyle(
          color: AppColors.textPrimary,
          fontWeight: FontWeight.w500,
        ),
      ),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
    );
  }

  Widget _buildPremiumSection(BuildContext context) {
    if (_isPremium) {
      return Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: AppColors.primary.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: const Row(
          children: [
            Icon(Icons.star, color: AppColors.primary),
            SizedBox(width: 12),
            Text(
              '프리미엄 회원입니다 ✨',
              style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [AppColors.primary, AppColors.primaryLight],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            AppStrings.premiumTitle,
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          const Text(
            AppStrings.premiumBenefit1,
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            AppStrings.premiumBenefit2,
            style: TextStyle(color: Colors.white),
          ),
          const Text(
            AppStrings.premiumBenefit3,
            style: TextStyle(color: Colors.white),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: _isLoading ? null : _handlePurchase,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.white,
                    foregroundColor: AppColors.primary,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Text(
                          '${AppStrings.buttonPurchase} ${AppStrings.premiumPrice}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Center(
            child: TextButton(
              onPressed: _isLoading ? null : _handleRestore,
              child: const Text(
                AppStrings.buttonRestore,
                style: TextStyle(color: Colors.white70),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
