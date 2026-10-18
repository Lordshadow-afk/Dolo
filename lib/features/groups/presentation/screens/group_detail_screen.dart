import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/group_detail_provider.dart';

class GroupDetailScreen extends ConsumerWidget {
  final String groupId;

  const GroupDetailScreen({
    super.key,
    required this.groupId,
  });

  Future<void> _sendGroupWhatsAppReminder(GroupDetailState state) async {
    final currencyFormatter = NumberFormat('#,###');
    final message =
        'Salaam all! Dolo group update for *${state.groupName}*: Total pending settlement is Rs ${currencyFormatter.format(state.yourNetBalance.abs())}. Let\'s clear the dues whenever you can, thanks!';
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('whatsapp://send?text=$encoded');
    final fallbackUrl = Uri.parse('https://wa.me/?text=$encoded');

    try {
      if (await canLaunchUrl(url)) {
        await launchUrl(url);
      } else {
        await launchUrl(fallbackUrl, mode: LaunchMode.externalApplication);
      }
    } catch (_) {
      // Fallback
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final state = ref.watch(groupDetailProvider(groupId));
    final notifier = ref.read(groupDetailProvider(groupId).notifier);
    final currencyFormatter = NumberFormat('#,###');

    final bool youOwe = state.yourNetBalance < 0;
    final statusColor = youOwe ? AppColors.rose : AppColors.mint;
    final statusText = youOwe ? 'YOU OWE' : 'YOU ARE OWED';

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
            children: [
              // Cockpit Header: Back, Group Title, Members List
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.groupName,
                            style: AppTypography.screenTitle.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            state.membersLine,
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textDarkMuted,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Group Net Standing Card
              Container(
                margin: const EdgeInsets.symmetric(
                  horizontal: AppDimensions.screenHorizontalPadding,
                ),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.glassTriadBg,
                  borderRadius: BorderRadius.circular(AppDimensions.glassTriadRadius),
                  border: Border.all(
                    color: AppColors.glassTriadBorder,
                    width: 1,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: statusColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 6),
                        Text(
                          statusText,
                          style: AppTypography.sectionLabel.copyWith(
                            color: AppColors.textDarkMuted,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rs ${currencyFormatter.format(state.yourNetBalance.abs())}',
                      style: AppTypography.heroBalance.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 18),

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
                    children: [
                      // Module 13: Simplified Debt Minimization Banner
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                        decoration: BoxDecoration(
                          color: isDark
                              ? AppColors.indigo.withOpacity(0.18)
                              : AppColors.indigoSquircleBg,
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Text(
                          'Simplified: ${state.simplifiedPaymentCount} payments settle the whole group.',
                          style: AppTypography.caption.copyWith(
                            color: isDark ? AppColors.indigoTextDark : AppColors.indigoNotice,
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),

                      const SizedBox(height: 14),

                      // Tabs: Expenses, Balances, Members
                      Row(
                        children: ['Expenses', 'Balances', 'Members'].map((tab) {
                          final isSelected = tab == state.activeTab;
                          final Color bgColor = isSelected
                              ? AppColors.mint
                              : (isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive);
                          final Color txtColor = isSelected
                              ? AppColors.textLightPrimary
                              : (isDark ? AppColors.textDarkMuted : AppColors.textLightMuted);

                          return Padding(
                            padding: const EdgeInsets.only(right: 8),
                            child: InkWell(
                              onTap: () => notifier.setTab(tab),
                              borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                                decoration: BoxDecoration(
                                  color: bgColor,
                                  borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                                ),
                                child: Text(
                                  tab,
                                  style: AppTypography.caption.copyWith(
                                    color: txtColor,
                                    fontWeight: isSelected ? FontWeight.w800 : FontWeight.w600,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      ),

                      const SizedBox(height: 10),

                      // Content Views according to active tab
                      Expanded(
                        child: state.activeTab == 'Expenses'
                            ? _buildExpensesList(context, state, isDark, currencyFormatter)
                            : state.activeTab == 'Balances'
                                ? _buildBalancesList(context, state, isDark, currencyFormatter)
                                : _buildMembersList(context, state, isDark),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Sticky Bottom Clearance & WhatsApp Action Bar
      bottomNavigationBar: Container(
        color: surfaceColor,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 28, top: 10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            InkWell(
              onTap: () {
                notifier.clearAllDues();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('All group dues cleared!')),
                );
              },
              borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
              child: Container(
                height: AppDimensions.ctaHeight,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.mint,
                  borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                ),
                child: Text(
                  state.yourNetBalance != 0
                      ? 'Clear all dues, Rs ${currencyFormatter.format(state.yourNetBalance.abs())}'
                      : 'All dues cleared!',
                  style: AppTypography.cardTitle.copyWith(
                    color: AppColors.textLightPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () => _sendGroupWhatsAppReminder(state),
              borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
              child: Container(
                height: AppDimensions.ctaHeight,
                width: double.infinity,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive,
                  borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
                ),
                child: Text(
                  'Remind on WhatsApp',
                  style: AppTypography.cardTitle.copyWith(
                    color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildExpensesList(
    BuildContext context,
    GroupDetailState state,
    bool isDark,
    NumberFormat formatter,
  ) {
    final dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: state.expenses.length,
      itemBuilder: (context, index) {
        final expense = state.expenses[index];
        final isOwed = expense.yourShare > 0;
        final shareColor = expense.isSettled
            ? AppColors.indigoTextLight
            : (isOwed ? AppColors.mintTextLight : (isDark ? AppColors.roseTextDark : AppColors.roseTextLight));
        final shareText = expense.isSettled
            ? 'Settled'
            : (isOwed
                ? '+ ${formatter.format(expense.yourShare)}'
                : '- ${formatter.format(expense.yourShare.abs())}');

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: AppDimensions.squircleSmallSize,
                height: AppDimensions.squircleSmallSize,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.rose.withOpacity(0.18) : AppColors.roseSquircleBg,
                  borderRadius: BorderRadius.circular(AppDimensions.squircleSmallRadius),
                ),
                alignment: Alignment.center,
                child: Text(
                  expense.categoryTag,
                  style: TextStyle(
                    color: isDark ? AppColors.roseTextDark : AppColors.roseTextLight,
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                  ),
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      expense.title,
                      style: AppTypography.cardTitle.copyWith(
                        fontSize: 15,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      expense.subtitle,
                      style: AppTypography.caption.copyWith(
                        color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                        fontSize: 12,
                      ),
                    ),
                  ],
                ),
              ),
              Text(
                shareText,
                style: AppTypography.rupeeAmount.copyWith(
                  color: shareColor,
                  fontWeight: FontWeight.w800,
                  fontSize: 15,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildBalancesList(
    BuildContext context,
    GroupDetailState state,
    bool isDark,
    NumberFormat formatter,
  ) {
    final dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final m = state.members[index];
        final isOwed = m.netBalance >= 0;
        final color = isOwed
            ? (isDark ? AppColors.mintTextDark : AppColors.mintTextLight)
            : (isDark ? AppColors.roseTextDark : AppColors.roseTextLight);

        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
          ),
          child: Row(
            children: [
              Text(
                m.nickname,
                style: AppTypography.cardTitle.copyWith(
                  fontWeight: FontWeight.w700,
                  color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                ),
              ),
              const Spacer(),
              Text(
                isOwed
                    ? 'gets back Rs ${formatter.format(m.netBalance)}'
                    : 'owes Rs ${formatter.format(m.netBalance.abs())}',
                style: AppTypography.caption.copyWith(
                  color: color,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildMembersList(
    BuildContext context,
    GroupDetailState state,
    bool isDark,
  ) {
    final dividerColor = isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive;

    return ListView.builder(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(bottom: 20),
      itemCount: state.members.length,
      itemBuilder: (context, index) {
        final m = state.members[index];
        return Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            border: Border(bottom: BorderSide(color: dividerColor, width: 1)),
          ),
          child: Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkPillActive : AppColors.lightPillInactive,
                  borderRadius: BorderRadius.circular(10),
                ),
                alignment: Alignment.center,
                child: Text(
                  m.initials,
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    color: isDark ? Colors.white : AppColors.textLightPrimary,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    m.name,
                    style: AppTypography.cardTitle.copyWith(
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                      color: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                    ),
                  ),
                  Text(
                    'Nickname: ${m.nickname}',
                    style: AppTypography.caption.copyWith(
                      color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
              const Spacer(),
              if (m.isShadow)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.indigo.withOpacity(0.18) : AppColors.indigoSquircleBg,
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Shadow Member',
                    style: AppTypography.caption.copyWith(
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: isDark ? AppColors.indigoTextDark : AppColors.indigoNotice,
                    ),
                  ),
                ),
            ],
          ),
        );
      },
    );
  }
}
