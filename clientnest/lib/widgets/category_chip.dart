import 'package:flutter/material.dart';

class CategoryData {
  final String label;
  final IconData icon;
  final Color color;

  const CategoryData({
    required this.label,
    required this.icon,
    required this.color,
  });
}

class CategoryChip extends StatelessWidget {
  final CategoryData category;
  final bool isSelected;
  final VoidCallback? onTap;

  const CategoryChip({
    super.key,
    required this.category,
    this.isSelected = false,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final colorScheme = Theme.of(context).colorScheme;
    final effectiveColor = isSelected ? colorScheme.primary : category.color;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected
              ? colorScheme.primary
              : effectiveColor.withValues(alpha: 0.08),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isSelected
                ? colorScheme.primary
                : effectiveColor.withValues(alpha: 0.25),
            width: 1.5,
          ),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              category.icon,
              size: 16,
              color: isSelected ? colorScheme.onPrimary : effectiveColor,
            ),
            const SizedBox(width: 8),
            Text(
              category.label,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: isSelected ? colorScheme.onPrimary : effectiveColor,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
