import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import 'group_detail_screen.dart';
import 'new_group_screen.dart';

class GroupsListScreen extends StatelessWidget {
  const GroupsListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final surfaceColor = isDark ? AppColors.darkSurface : AppColors.lightSurface;

    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: isDark
                ? [AppColors.darkCockpitGradientStart, AppColors.darkCockpitGradientEnd]
                : [AppColors.cockpitGradientStart, AppColors.cockpitGradientEnd],
          ),
        ),
        child: SafeArea(
          bottom: false,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cockpit Header
              Padding(
                padding: const EdgeInsets.only(top: 20, left: 24, right: 24, bottom: 20),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Groups',
                          style: AppTypography.screenTitle.copyWith(
                            color: Colors.white,
                            fontSize: 28,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Shared splits and roommate balances',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textDarkMuted,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const NewGroupScreen()),
                        );
                      },
                      borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                        decoration: BoxDecoration(
                          color: AppColors.mint,
                          borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                        ),
                        child: Text(
                          '+ New',
                          style: AppTypography.caption.copyWith(
                            color: AppColors.textLightPrimary,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),

              // Surface Sheet
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: surfaceColor,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(AppDimensions.surfaceSheetRadius),
                      topRight: Radius.circular(AppDimensions.surfaceSheetRadius),
                    ),
                  ),
                  padding: const EdgeInsets.all(AppDimensions.screenHorizontalPadding),
                  child: ListView(
                    physics: const BouncingScrollPhysics(),
                    children: [
                      _GroupCard(
                        name: 'Hostel Gang',
                        membersLine: 'You, Sheeda, Kaptaan, Hamza',
                        initials: 'HG',
                        netBalance: -1850,
                        simplifiedPayments: 2,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GroupDetailScreen(groupId: 'hostel_gang'),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),
                      _GroupCard(
                        name: 'Trip to Murree',
                        membersLine: 'You, Bilal, Farhan',
                        initials: 'TM',
                        netBalance: 3200,
                        simplifiedPayments: 1,
                        isDark: isDark,
                        onTap: () {
                          Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const GroupDetailScreen(groupId: 'trip_murree'),
                            ),
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupCard extends StatelessWidget {
  final String name;
  final String membersLine;
  final String initials;
  final int netBalance;
  final int simplifiedPayments;
  final bool isDark;
  final VoidCallback onTap;

  const _GroupCard({
    required this.name,
    required this.membersLine,
    required this.initials,
    required this.netBalance,
    required this.simplifiedPayments,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final youOwe = netBalance < 0;
    final balanceColor = youOwe
        ? (isDark ? AppColors.roseTextDark : AppColors.roseTextLight)
        : (isDark ? AppColors.mintTextDark : AppColors.mintTextLight);

    final cardBg = isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final cardBorder = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardBg,
          borderRadius: BorderRadius.circular(AppDimensions.cardRadius),
          border: Border.all(color: cardBorder, width: 1),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: AppDimensions.squircleSmallSize,
                  height: AppDimensions.squircleSmallSize,
                  decoration: BoxDecoration(
                    color: youOwe
                        ? (isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg)
                        : (isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg),
                    borderRadius: BorderRadius.circular(AppDimensions.squircleSmallRadius),
                  ),
                  alignment: Alignment.center,
                  child: Text(
                    initials,
                    style: TextStyle(
                      color: balanceColor,
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        name,
                        style: AppTypography.cardTitle.copyWith(
                          color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                          fontSize: 16,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        membersLine,
                        style: AppTypography.caption.copyWith(
                          color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                Text(
                  youOwe ? '- Rs ${netBalance.abs()}' : '+ Rs $netBalance',
                  style: AppTypography.rupeeAmount.copyWith(
                    color: balanceColor,
                    fontSize: 16,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: isDark ? AppColors.indigo.withOpacity(0.18) : AppColors.indigoSquircleBg,
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Simplified: $simplifiedPayments payments settle the whole group',
                style: AppTypography.caption.copyWith(
                  color: isDark ? AppColors.indigoTextDark : AppColors.indigoNotice,
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
