import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/database/app_database.dart';
import '../../../../core/database/tables.dart';
import '../widgets/donut_chart_painter.dart';

/// Category totals keyed by category name, amounts in whole rupees (int).
final spendsCategoryProvider = FutureProvider<Map<String, int>>((ref) async {
  final db = await AppDatabase.instance.database;

  // Use correct schema column: total_amount (INTEGER, whole rupees)
  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT category, SUM(total_amount) as total 
    FROM ${DbTables.expenses}
    WHERE is_trashed = 0 
    GROUP BY category
    ORDER BY total DESC
  ''');

  final Map<String, int> spends = {};
  for (final row in result) {
    final String category = row['category'] as String? ?? 'Other';
    final int total = (row['total'] as num?)?.toInt() ?? 0;
    if (total > 0) spends[category] = total;
  }

  return spends;
});

class SpendsScreen extends ConsumerWidget {
  const SpendsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final spendsAsync = ref.watch(spendsCategoryProvider);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Spends & Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: spendsAsync.when(
        data: (categorySpends) {
          if (categorySpends.isEmpty) {
            return const Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text('📊', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 12),
                  Text(
                    'No expenses logged yet.',
                    style: TextStyle(
                        color: AppColors.textLightMuted, fontSize: 16),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Add expenses to see your spending breakdown.',
                    style: TextStyle(
                        color: AppColors.textLightSecondary, fontSize: 13),
                  ),
                ],
              ),
            );
          }

          // All arithmetic stays in whole rupees (int)
          final int totalSpends =
              categorySpends.values.fold(0, (sum, item) => sum + item);

          return SingleChildScrollView(
            padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Donut chart card
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        isDark ? AppColors.darkSurface : AppColors.lightSurface,
                    borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
                    border: Border.all(
                      color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    ),
                  ),
                  child: Column(
                    children: [
                      SpendsDonutChart(
                        categories: categorySpends
                            .map((k, v) => MapEntry(k, v.toDouble())),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Total Spent: Rs $totalSpends',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: isDark
                              ? AppColors.textDarkPrimary
                              : AppColors.textLightPrimary,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),

                // Legend tiles — whole-rupee display
                ...categorySpends.entries.map((entry) => _CategoryLegendTile(
                      category: entry.key,
                      amountRs: entry.value,
                      percentage: totalSpends > 0
                          ? (entry.value / totalSpends) * 100
                          : 0,
                      isDark: isDark,
                    )),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, _) =>
            Center(child: Text('Error loading spends: $err')),
      ),
    );
  }
}

class _CategoryLegendTile extends StatelessWidget {
  final String category;
  final int amountRs;
  final double percentage;
  final bool isDark;

  const _CategoryLegendTile({
    required this.category,
    required this.amountRs,
    required this.percentage,
    required this.isDark,
  });

  static const _categoryColors = {
    'Food': AppColors.categoryFood,
    'Hostel': AppColors.categoryHostel,
    'Fuel': AppColors.categoryFuel,
    'Printouts': AppColors.categoryPrintouts,
    'Udhar': AppColors.categoryUdhar,
  };

  @override
  Widget build(BuildContext context) {
    final color =
        _categoryColors[category] ?? AppColors.indigo;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
        border: Border.all(
          color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              category,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark
                    ? AppColors.textDarkPrimary
                    : AppColors.textLightPrimary,
              ),
            ),
          ),
          Text(
            'Rs $amountRs (${percentage.toStringAsFixed(1)}%)',
            style: TextStyle(
              fontWeight: FontWeight.bold,
              color: isDark
                  ? AppColors.textDarkPrimary
                  : AppColors.textLightPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
