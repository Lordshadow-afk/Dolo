import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';

class GlassTriadCard extends StatelessWidget {
  final int totalOwed;
  final int totalOwe;
  final int settledCount;

  const GlassTriadCard({
    super.key,
    required this.totalOwed,
    required this.totalOwe,
    required this.settledCount,
  });

  @override
  Widget build(BuildContext context) {
    final currencyFormatter = NumberFormat('#,###');

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppDimensions.screenHorizontalPadding,
      ),
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 8),
      decoration: BoxDecoration(
        color: AppColors.glassTriadBg,
        borderRadius: BorderRadius.circular(AppDimensions.glassTriadRadius),
        border: Border.all(
          color: AppColors.glassTriadBorder,
          width: 1,
        ),
      ),
      child: Row(
        children: [
          // 1. You Are Owed (Mint / Teal)
          Expanded(
            child: _TriadColumn(
              indicatorColor: AppColors.mint,
              label: 'OWED',
              value: currencyFormatter.format(totalOwed),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 38,
            color: AppColors.glassTriadBorder,
          ),

          // 2. You Owe (Rose / Coral)
          Expanded(
            child: _TriadColumn(
              indicatorColor: AppColors.rose,
              label: 'OWE',
              value: currencyFormatter.format(totalOwe),
            ),
          ),

          // Divider
          Container(
            width: 1,
            height: 38,
            color: AppColors.glassTriadBorder,
          ),

          // 3. Settled (Indigo / Purple)
          Expanded(
            child: _TriadColumn(
              indicatorColor: AppColors.indigo,
              label: 'SETTLED',
              value: settledCount.toString(),
            ),
          ),
        ],
      ),
    );
  }
}

class _TriadColumn extends StatelessWidget {
  final Color indicatorColor;
  final String label;
  final String value;

  const _TriadColumn({
    required this.indicatorColor,
    required this.label,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 7,
              height: 7,
              decoration: BoxDecoration(
                color: indicatorColor,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              label,
              style: AppTypography.sectionLabel.copyWith(
                color: AppColors.textDarkMuted,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          value,
          style: AppTypography.numericMetric.copyWith(
            color: AppColors.textDarkPrimary,
            fontSize: 17,
          ),
        ),
      ],
    );
  }
}
