import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../domain/models/dashboard_summary.dart';

class TransactionFeedItem extends StatelessWidget {
  final DashboardFeedItem item;
  final VoidCallback? onTap;

  const TransactionFeedItem({
    super.key,
    required this.item,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currencyFormatter = NumberFormat('#,###');

    // Squircle & Text Coloring logic
    Color squircleBg;
    Color squircleText;
    Color trailingColor;
    String trailingText;

    if (item.isSettled) {
      squircleBg = isDark ? AppColors.indigo.withOpacity(0.18) : AppColors.indigoSquircleBg;
      squircleText = isDark ? AppColors.indigoTextDark : AppColors.indigoTextLight;
      trailingColor = squircleText;
      trailingText = 'Settled';
    } else if (item.amount != null && item.amount! > 0) {
      squircleBg = isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg;
      squircleText = isDark ? AppColors.mintTextDark : AppColors.mintTextLight;
      trailingColor = squircleText;
      trailingText = '+ ${currencyFormatter.format(item.amount)}';
    } else if (item.amount != null && item.amount! < 0) {
      squircleBg = isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg;
      squircleText = isDark ? AppColors.roseTextDark : AppColors.roseTextLight;
      trailingColor = squircleText;
      trailingText = '- ${currencyFormatter.format(item.amount!.abs())}';
    } else {
      squircleBg = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;
      squircleText = isDark ? AppColors.textDarkMuted : AppColors.textLightMuted;
      trailingColor = squircleText;
      trailingText = '0';
    }

    final Color dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    return InkWell(
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
            // Squircle Initials Container
            Container(
              width: AppDimensions.squircleSmallSize,
              height: AppDimensions.squircleSmallSize,
              decoration: BoxDecoration(
                color: squircleBg,
                borderRadius: BorderRadius.circular(AppDimensions.squircleSmallRadius),
              ),
              alignment: Alignment.center,
              child: Text(
                item.initials,
                style: AppTypography.cardTitle.copyWith(
                  color: squircleText,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ),

            const SizedBox(width: 14),

            // Title & Subtitle
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    item.title,
                    style: AppTypography.cardTitle.copyWith(
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.subtitle,
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),

            // Trailing Amount or Settled Status
            Text(
              trailingText,
              style: AppTypography.rupeeAmount.copyWith(
                color: trailingColor,
                fontWeight: FontWeight.w800,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
