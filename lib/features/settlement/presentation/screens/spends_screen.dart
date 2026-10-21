import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/database/app_database.dart';
import '../widgets/donut_chart_painter.dart';

final spendsCategoryProvider = FutureProvider<Map<String, double>>((ref) async {
  final db = await AppDatabase.instance.database;

  final List<Map<String, dynamic>> result = await db.rawQuery('''
    SELECT category, SUM(amount_rs) as total 
    FROM expenses 
    WHERE is_deleted = 0 
    GROUP BY category
  ''');

  final Map<String, double> spends = {};
  for (var row in result) {
    final String category = row['category'] as String? ?? 'Other';
    final double total = (row['total'] as num?)?.toDouble() ?? 0.0;
    spends[category] = total;
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
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
      appBar: AppBar(
        title: const Text('Spends & Analytics'),
        elevation: 0,
        backgroundColor: Colors.transparent,
      ),
      body: spendsAsync.when(
        data: (categorySpends) {
          final double totalSpends =
              categorySpends.values.fold(0, (sum, item) => sum + item);

          if (categorySpends.isEmpty) {
            return const Center(
              child: Text(
                'No expenses logged yet.',
                style: TextStyle(color: AppColors.textLightMuted),
              ),
            );
          }

          return SingleChildScrollView(
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
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (err, stack) => Center(child: Text('Error loading spends: $err')),
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