import 'package:flutter/material.dart';

class FilterSortBar<T> extends StatelessWidget {
  final List<FilterOption<T>> filters;
  final T? selectedFilter;
  final Function(T?) onFilterChanged;
  final List<SortOption> sortOptions;
  final String selectedSortField;
  final bool isDescending;
  final Function(String, bool) onSortChanged;

  const FilterSortBar({
    super.key,
    required this.filters,
    required this.selectedFilter,
    required this.onFilterChanged,
    required this.sortOptions,
    required this.selectedSortField,
    required this.isDescending,
    required this.onSortChanged,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Filter Chips
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                FilterChip(
                  label: const Text('All'),
                  selected: selectedFilter == null,
                  onSelected: (selected) => onFilterChanged(null),
                  backgroundColor: colorScheme.surface,
                  selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                  labelStyle: TextStyle(
                    color: selectedFilter == null ? colorScheme.primary : colorScheme.onSurface,
                    fontWeight: selectedFilter == null ? FontWeight.bold : FontWeight.normal,
                  ),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  side: BorderSide(
                    color: selectedFilter == null ? colorScheme.primary : colorScheme.outlineVariant,
                  ),
                ),
                const SizedBox(width: 8),
                ...filters.map((filter) {
                  final isSelected = selectedFilter == filter.value;
                  return Padding(
                    padding: const EdgeInsets.only(right: 8),
                    child: FilterChip(
                      label: Text(filter.label),
                      selected: isSelected,
                      onSelected: (selected) => onFilterChanged(filter.value),
                      backgroundColor: colorScheme.surface,
                      selectedColor: colorScheme.primary.withValues(alpha: 0.15),
                      labelStyle: TextStyle(
                        color: isSelected ? colorScheme.primary : colorScheme.onSurface,
                        fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                      ),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      side: BorderSide(
                        color: isSelected ? colorScheme.primary : colorScheme.outlineVariant,
                      ),
                    ),
                  );
                }),
              ],
            ),
          ),
          
          const SizedBox(height: 8),
          
          // Sort Options
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Icon(Icons.sort_rounded, size: 18, color: colorScheme.onSurface.withValues(alpha: 0.5)),
                const SizedBox(width: 8),
                Text(
                  'Sort by:',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: colorScheme.onSurface.withValues(alpha: 0.5),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String>(
                  initialValue: selectedSortField,
                  onSelected: (field) => onSortChanged(field, isDescending),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: colorScheme.surface,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: colorScheme.outlineVariant),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          sortOptions.firstWhere((opt) => opt.field == selectedSortField).label,
                          style: theme.textTheme.bodySmall?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: colorScheme.primary,
                          ),
                        ),
                        const Icon(Icons.arrow_drop_down, size: 16),
                      ],
                    ),
                  ),
                  itemBuilder: (context) => sortOptions.map((opt) {
                    return PopupMenuItem<String>(
                      value: opt.field,
                      child: Text(opt.label),
                    );
                  }).toList(),
                ),
                const Spacer(),
                IconButton(
                  onPressed: () => onSortChanged(selectedSortField, !isDescending),
                  icon: Icon(
                    isDescending ? Icons.arrow_downward_rounded : Icons.arrow_upward_rounded,
                    size: 18,
                    color: colorScheme.primary,
                  ),
                  style: IconButton.styleFrom(
                    backgroundColor: colorScheme.primary.withValues(alpha: 0.1),
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class FilterOption<T> {
  final String label;
  final T value;

  FilterOption({required this.label, required this.value});
}

class SortOption {
  final String label;
  final String field;

  SortOption({required this.label, required this.field});
}
