import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

/// 카테고리 탭 위젯 - Pill 스타일 세그먼트 컨트롤
class CategoryTabs extends StatelessWidget {
  final DeckCategory selectedCategory;
  final ValueChanged<DeckCategory> onCategoryChanged;

  const CategoryTabs({
    super.key,
    required this.selectedCategory,
    required this.onCategoryChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacing4),
      decoration: BoxDecoration(
        color: AppTheme.neutral100,
        borderRadius: BorderRadius.circular(AppTheme.radiusL),
      ),
      child: Row(
        children: DeckCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return Expanded(
            child: _CategoryTab(
              category: category,
              isSelected: isSelected,
              onTap: () => onCategoryChanged(category),
            ),
          );
        }).toList(),
      ),
    );
  }
}

/// 개별 카테고리 탭
class _CategoryTab extends StatelessWidget {
  final DeckCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  
  const _CategoryTab({
    required this.category,
    required this.isSelected,
    required this.onTap,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeOutCubic,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacing12,
          vertical: AppTheme.spacing12,
        ),
        decoration: BoxDecoration(
          color: isSelected ? AppTheme.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          boxShadow: isSelected ? AppTheme.shadowSm : null,
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // 이모지 아이콘
            Container(
              width: 28,
              height: 28,
              decoration: BoxDecoration(
                color: isSelected 
                    ? color.withValues(alpha: 0.15)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(AppTheme.radiusS),
              ),
              child: Center(
                child: Text(
                  category.emoji,
                  style: TextStyle(
                    fontSize: isSelected ? 16.0 : 14.0,
                  ),
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacing6),
            // 카테고리 이름
            Flexible(
              child: Text(
                category.name,
                style: AppTheme.textStyles.label.copyWith(
                  color: isSelected ? color : AppTheme.neutral500,
                  fontWeight: isSelected ? FontWeight.w600 : FontWeight.w500,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return AppColors.foodColor;
      case DeckCategory.exercise:
        return AppColors.exerciseColor;
      case DeckCategory.vocabulary:
        return AppColors.studyColor;
    }
  }
}

/// 컴팩트 카테고리 칩 (작은 공간용)
class CategoryChip extends StatelessWidget {
  final DeckCategory category;
  final bool isSelected;
  final VoidCallback? onTap;
  final bool compact;
  
  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
    this.compact = false,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: EdgeInsets.symmetric(
          horizontal: compact ? AppTheme.spacing8 : AppTheme.spacing12,
          vertical: compact ? AppTheme.spacing4 : AppTheme.spacing8,
        ),
        decoration: BoxDecoration(
          color: isSelected ? color : color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusFull),
          border: Border.all(
            color: isSelected ? color : color.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji,
              style: TextStyle(fontSize: compact ? 12.0 : 14.0),
            ),
            if (!compact) ...[
              const SizedBox(width: AppTheme.spacing4),
              Text(
                category.name,
                style: AppTheme.textStyles.label.copyWith(
                  color: isSelected ? Colors.white : color,
                  fontWeight: FontWeight.w600,
                  fontSize: compact ? 11.0 : 13.0,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
  
  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return AppColors.foodColor;
      case DeckCategory.exercise:
        return AppColors.exerciseColor;
      case DeckCategory.vocabulary:
        return AppColors.studyColor;
    }
  }
}

/// 세로 카테고리 선택 리스트
class CategorySelectionList extends StatelessWidget {
  final DeckCategory? selectedCategory;
  final ValueChanged<DeckCategory> onCategoryChanged;
  final bool showDescription;
  
  const CategorySelectionList({
    super.key,
    this.selectedCategory,
    required this.onCategoryChanged,
    this.showDescription = true,
  });
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: DeckCategory.values.map((category) {
        final isSelected = category == selectedCategory;
        return _CategorySelectionTile(
          category: category,
          isSelected: isSelected,
          onTap: () => onCategoryChanged(category),
          showDescription: showDescription,
        );
      }).toList(),
    );
  }
}

class _CategorySelectionTile extends StatelessWidget {
  final DeckCategory category;
  final bool isSelected;
  final VoidCallback onTap;
  final bool showDescription;
  
  const _CategorySelectionTile({
    required this.category,
    required this.isSelected,
    required this.onTap,
    required this.showDescription,
  });
  
  @override
  Widget build(BuildContext context) {
    final color = _getCategoryColor(category);
    
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacing8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(AppTheme.radiusM),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            padding: const EdgeInsets.all(AppTheme.spacing16),
            decoration: BoxDecoration(
              color: isSelected 
                  ? color.withValues(alpha: 0.1)
                  : AppTheme.surface,
              borderRadius: BorderRadius.circular(AppTheme.radiusM),
              border: Border.all(
                color: isSelected ? color : AppTheme.neutral200,
                width: isSelected ? 2 : 1,
              ),
            ),
            child: Row(
              children: [
                // 카테고리 아이콘
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppTheme.radiusM),
                  ),
                  child: Center(
                    child: Text(
                      category.emoji,
                      style: const TextStyle(fontSize: 24),
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacing16),
                // 카테고리 정보
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        category.name,
                        style: AppTheme.textStyles.body.copyWith(
                          fontWeight: FontWeight.w600,
                          color: isSelected ? color : AppTheme.neutral800,
                        ),
                      ),
                      if (showDescription) ...[
                        const SizedBox(height: AppTheme.spacing4),
                        Text(
                          _getCategoryDescription(category),
                          style: AppTheme.textStyles.caption.copyWith(
                            color: AppTheme.neutral500,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
                // 선택 표시
                if (isSelected)
                  Container(
                    width: 24,
                    height: 24,
                    decoration: BoxDecoration(
                      color: color,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.check_rounded,
                      size: 16,
                      color: Colors.white,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
  
  Color _getCategoryColor(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return AppColors.foodColor;
      case DeckCategory.exercise:
        return AppColors.exerciseColor;
      case DeckCategory.vocabulary:
        return AppColors.studyColor;
    }
  }
  
  String _getCategoryDescription(DeckCategory category) {
    switch (category) {
      case DeckCategory.food:
        return '매일 새로운 음식 메뉴를 추천받아요';
      case DeckCategory.exercise:
        return '건강한 하루를 위한 운동을 추천받아요';
      case DeckCategory.vocabulary:
        return '매일 새로운 단어를 학습해요';
    }
  }
}
