import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/khata_timeline_entry.dart';

class KhataTimelineTile extends StatelessWidget {
  final KhataTimelineEntry entry;
  final VoidCallback? onTap;
  final VoidCallback? onDelete;

  const KhataTimelineTile({
    super.key,
    required this.entry,
    this.onTap,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat('#,###');
    final dateFormatter = DateFormat('d MMM');

    final bool isLent = entry.isLent;
    final Color squircleBg = isLent
        ? (isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg)
        : (isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg);

    final Color squircleText = isLent
        ? (isDark ? AppColors.mintTextDark : AppColors.mintTextLight)
        : (isDark ? AppColors.roseTextDark : AppColors.roseTextLight);

    final Color amountColor = squircleText;
    final String amountPrefix = isLent ? '+ ' : '- ';
    final String signGlyph = isLent ? '+' : '–';

    final Color dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    String subtitle = '${dateFormatter.format(entry.date)}, ${entry.category}';
    if (entry.receiptPath != null) {
      subtitle += ' • receipt attached';
    }

    return Dismissible(
      key: Key(entry.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        color: AppColors.rose,
        child: const Icon(Icons.delete_outline_rounded, color: Colors.white),
      ),
      onDismissed: (_) {
        onDelete?.call();
      },
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 13),
          decoration: BoxDecoration(
            border: Border(
              bottom: BorderSide(color: dividerColor, width: 1),
            ),
          ),
          child: Row(
            children: [
              // Squircle badge (+ or -)
              Container(
                width: AppDimensions.squircleSmallSize,
                height: AppDimensions.squircleSmallSize,
                decoration: BoxDecoration(
                  color: squircleBg,
                  borderRadius: BorderRadius.circular(AppDimensions.squircleSmallRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  signGlyph,
                  style: TextStyle(
                    color: squircleText,
                    fontWeight: FontWeight.w800,
                    fontSize: 20,
                  ),
                ),
              ),

              const SizedBox(width: 14),

              // Title & Date / Tag
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      entry.title,
                      style: AppTypography.cardTitle.copyWith(
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),

              // Trailing Amount
              Text(
                '$amountPrefix${currencyFormatter.format(entry.amount)}',
                style: AppTypography.rupeeAmount.copyWith(
                  color: amountColor,
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
