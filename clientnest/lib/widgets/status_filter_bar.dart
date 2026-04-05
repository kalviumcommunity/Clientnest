import 'package:flutter/material.dart';
import 'package:clientnest/core/theme/nest_design_system.dart';
import 'package:clientnest/shared/widgets/nest_ui.dart';

class FilterBar<T> extends StatelessWidget {
  final T selectedStatus;
  final List<FilterOption<T>> options;
  final Function(T) onChanged;

  const FilterBar({
    super.key,
    required this.selectedStatus,
    required this.options,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      padding: const EdgeInsets.symmetric(horizontal: NestDesignSystem.spacingL, vertical: NestDesignSystem.spacingM),
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: options.map((option) {
          final isSelected = option.value == selectedStatus;
          final colorScheme = Theme.of(context).colorScheme;

          return Padding(
            padding: const EdgeInsets.only(right: NestDesignSystem.spacingXS),
            child: LayerContainer(
              onTap: () => onChanged(option.value),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              borderRadius: 20,
              color: isSelected ? colorScheme.primary : colorScheme.surface,
              child: Text(
                option.label.toUpperCase(),
                style: TextStyle(
                  color: isSelected ? Colors.white : colorScheme.onSurface.withValues(alpha: 0.5),
                  fontWeight: FontWeight.w900,
                  fontSize: 10,
                  letterSpacing: 0.5,
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}

class FilterOption<T> {
  final String label;
  final T value;

  FilterOption({required this.label, required this.value});
}
