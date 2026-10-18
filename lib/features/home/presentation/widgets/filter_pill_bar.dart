import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

class FilterPillBar extends StatelessWidget {
  final String activeFilter;
  final ValueChanged<String> onFilterChanged;

  static const List<String> filters = ['All', 'Friends', 'Groups', 'Pending'];

  const FilterPillBar({
    super.key,
    required this.activeFilter,
    required this.onFilterChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      physics: const BouncingScrollPhysics(),
      child: Row(
        children: filters.map((filter) {
          final isSelected = filter == activeFilter;

          final Color bgColor = isSelected
              ? AppColors.mint
              : (isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive);

          final Color textColor = isSelected
              ? AppColors.textLightPrimary
              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted);

          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                onTap: () => onFilterChanged(filter),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 180),
                  height: 38,
                  padding: const EdgeInsets.symmetric(horizontal: 18),
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                  ),
                  child: Text(
                    filter,
                    style: AppTypography.bodySemiBold.copyWith(
                      color: textColor,
                      fontSize: 13,
                      fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
