import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../../../../core/constants/app_icons_config.dart';
import 'glass_triad_card.dart';

class DarkCockpitHeader extends StatelessWidget {
  final String userName;
  final int netStanding;
  final int totalOwed;
  final int totalOwe;
  final int settledCount;
  final VoidCallback? onProfileTap;

  const DarkCockpitHeader({
    super.key,
    required this.userName,
    required this.netStanding,
    required this.totalOwed,
    required this.totalOwe,
    required this.settledCount,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');
    final isPositive = netStanding >= 0;
    final prefix = isPositive ? '+ ' : '- ';
    final formattedAmount = '$prefix Rs ${currencyFormatter.format(netStanding.abs())}';

    return Container(
      padding: const EdgeInsets.only(
        top: AppDimensions.cockpitTopPadding + 14,
        bottom: 24,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Greeting & Profile Avatar
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenHorizontalPadding + 4,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Salaam, $userName',
                  style: AppTypography.bodySemiBold.copyWith(
                    color: AppColors.textDarkMuted,
                    fontSize: 14,
                  ),
                ),
                GestureDetector(
                  onTap: onProfileTap,
                  child: Container(
                    width: 38,
                    height: 38,
                    decoration: BoxDecoration(
                      color: AppColors.glassTriadBg,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppColors.glassTriadBorder,
                        width: 1,
                      ),
                    ),
                    padding: const EdgeInsets.all(6),
                    child: SvgPicture.asset(
                      AppIconsConfig.defaultIcon.assetPath,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 14),

          // NET STANDING Label
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenHorizontalPadding + 4,
            ),
            child: Text(
              'NET STANDING',
              style: AppTypography.sectionLabel.copyWith(
                color: AppColors.textDarkMuted,
                fontSize: 12,
              ),
            ),
          ),

          const SizedBox(height: 4),

          // Hero Balance Figure
          Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppDimensions.screenHorizontalPadding + 4,
            ),
            child: Text(
              formattedAmount,
              style: AppTypography.heroBalance.copyWith(
                color: AppColors.textDarkPrimary,
                fontSize: 40,
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Encapsulated Glass Triad
          GlassTriadCard(
            totalOwed: totalOwed,
            totalOwe: totalOwe,
            settledCount: settledCount,
          ),
        ],
      ),
    );
  }
}
