import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../widgets/donut_chart_painter.dart';

class SpendsScreen extends StatelessWidget {
  const SpendsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    // Student category spends summary
    final Map<String, double> categorySpends = {
      'Food': 4500,
      'Hostel': 3200,
      'Fuel': 1800,
      'Printouts': 600,
      'Udhar': 1200,
    };

    final double totalSpends =
        categorySpends.values.fold(0, (sum, item) => sum + item);

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Spends & Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
                borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              child: Column(
                children: [
                  SpendsDonutChart(categories: categorySpends),
                  const SizedBox(height: 16),
                  Text(
                    'Total Spent: Rs ${totalSpends.toStringAsFixed(0)}',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ...categorySpends.entries.map((entry) => _CategoryLegendTile(
                  category: entry.key,
                  amount: entry.value,
                  percentage: totalSpends > 0 ? (entry.value / totalSpends) * 100 : 0,
                  isDark: isDark,
                )),
          ],
        ),
      ),
    );
  }
}

class _CategoryLegendTile extends StatelessWidget {
  final String category;
  final double amount;
  final double percentage;
  final bool isDark;

  const _CategoryLegendTile({
    required this.category,
    required this.amount,
    required this.percentage,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            category,
            style: TextStyle(
              fontWeight: FontWeight.w600,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
          Text(
            'Rs ${amount.toStringAsFixed(0)} (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}