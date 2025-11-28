import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/models.dart';

/// 카테고리 탭 위젯
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
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: DeckCategory.values.map((category) {
          final isSelected = category == selectedCategory;
          return _buildCategoryTab(category, isSelected);
        }).toList(),
      ),
    );
  }

  Widget _buildCategoryTab(DeckCategory category, bool isSelected) {
    return GestureDetector(
      onTap: () => onCategoryChanged(category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        decoration: BoxDecoration(
          color: isSelected ? _getCategoryColor(category) : Colors.transparent,
          borderRadius: BorderRadius.circular(24),
          border: Border.all(
            color: _getCategoryColor(category),
            width: 2,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              category.emoji,
              style: const TextStyle(fontSize: 20),
            ),
            const SizedBox(width: 8),
            Text(
              category.name,
              style: TextStyle(
                color: isSelected ? Colors.white : _getCategoryColor(category),
                fontWeight: FontWeight.bold,
                fontSize: 16,
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
