import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/dashboard_provider.dart';
import '../widgets/dark_cockpit_header.dart';
import '../widgets/filter_pill_bar.dart';
import '../widgets/transaction_feed_item.dart';
import '../../../khata_1on1/presentation/screens/khata_detail_screen.dart';

class HomeScreen extends ConsumerWidget {
  final VoidCallback? onAddExpenseTap;
  final VoidCallback? onSettleUpTap;
  final VoidCallback? onProfileTap;

  const HomeScreen({
    super.key,
    this.onAddExpenseTap,
    this.onSettleUpTap,
    this.onProfileTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final summaryAsync = ref.watch(dashboardSummaryProvider);
    final activeFilter = ref.watch(activeFilterProvider);
    final feedItems = ref.watch(filteredFeedProvider);

    final cockpitGradient = LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: isDark
          ? [AppColors.darkCockpitGradientStart, AppColors.darkCockpitGradientEnd]
          : [AppColors.cockpitGradientStart, AppColors.cockpitGradientEnd],
    );

    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(gradient: cockpitGradient),
        child: summaryAsync.when(
          loading: () => const Center(
            child: CircularProgressIndicator(color: AppColors.mint),
          ),
          error: (err, stack) => Center(
            child: Text(
              'Error loading dashboard: $err',
              style: const TextStyle(color: Colors.white),
            ),
          ),
          data: (summary) {
            return Column(
              children: [
                // Top 35% Cockpit Header
                DarkCockpitHeader(
                  userName: summary.userName,
                  netStanding: summary.netStanding,
                  totalOwed: summary.totalOwed,
                  totalOwe: summary.totalOwe,
                  settledCount: summary.settledCount,
                  onProfileTap: onProfileTap,
                ),

                // Bottom 65% Surface Sheet
                Expanded(
                  child: Container(
                    decoration: BoxDecoration(
                      color: surfaceColor,
                      borderRadius: const BorderRadius.only(
                        topLeft: Radius.circular(AppDimensions.surfaceSheetRadius),
                        topRight: Radius.circular(AppDimensions.surfaceSheetRadius),
                      ),
                    ),
                    padding: const EdgeInsets.only(
                      top: 22,
                      left: AppDimensions.screenHorizontalPadding,
                      right: AppDimensions.screenHorizontalPadding,
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Action CTAs (+ Add expense, Settle up)
                        Row(
                          children: [
                            Expanded(
                              child: _PrimaryCta(
                                text: '+ Add expense',
                                backgroundColor: AppColors.mint,
                                textColor: AppColors.textLightPrimary,
                                onTap: onAddExpenseTap,
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: _PrimaryCta(
                                text: 'Settle up',
                                backgroundColor: isDark
                                    ? AppColors.darkPillInactive
                                    : AppColors.lightPillInactive,
                                textColor: isDark
                                    ? AppColors.textDarkPrimary
                                    : AppColors.textLightPrimary,
                                onTap: onSettleUpTap,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 16),

                        // Horizontal Filter Pill Bar
                        FilterPillBar(
                          activeFilter: activeFilter,
                          onFilterChanged: (filter) {
                            ref.read(activeFilterProvider.notifier).state = filter;
                          },
                        ),

                        const SizedBox(height: 8),

                        // Transaction Feed
                        Expanded(
                          child: feedItems.isEmpty
                              ? Center(
                                  child: Text(
                                    'No transactions in this view',
                                    style: AppTypography.caption.copyWith(
                                      color: isDark
                                          ? AppColors.textDarkMuted
                                          : AppColors.textLightMuted,
                                    ),
                                  ),
                                )
                              : ListView.builder(
                                  padding: const EdgeInsets.only(bottom: 24, top: 4),
                                  physics: const BouncingScrollPhysics(),
                                  itemCount: feedItems.length,
                                  itemBuilder: (context, index) {
                                    final item = feedItems[index];
                                    return TransactionFeedItem(
                                      item: item,
                                      onTap: () {
                                        Navigator.of(context).push(
                                          MaterialPageRoute(
                                            builder: (ctx) => KhataDetailScreen(
                                              peerId: item.title.toLowerCase(),
                                            ),
                                          ),
                                        );
                                      },
                                    );
                                  },
                                ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _PrimaryCta extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _PrimaryCta({
    required this.text,
    required this.backgroundColor,
    required this.textColor,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
        child: Container(
          height: AppDimensions.ctaHeight,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: backgroundColor,
            borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
          ),
          child: Text(
            text,
            style: AppTypography.cardTitle.copyWith(
              color: textColor,
              fontWeight: FontWeight.w800,
              fontSize: 15,
            ),
          ),
        ),
      ),
    );
  }
}