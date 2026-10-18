import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/constants/app_typography.dart';
import '../providers/khata_detail_provider.dart';
import '../widgets/khata_timeline_tile.dart';
import '../widgets/quick_lend_borrow_sheet.dart';

class KhataDetailScreen extends ConsumerWidget {
  final String peerId;

  const KhataDetailScreen({
    super.key,
    required this.peerId,
  });

  void _showQuickLendBorrowSheet(BuildContext context, WidgetRef ref, {required bool isLent}) {
    final notifier = ref.read(khataDetailProvider(peerId).notifier);
    final state = ref.read(khataDetailProvider(peerId));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => QuickLendBorrowSheet(
        peerName: state.peerName,
        isLent: isLent,
        onConfirm: (data) {
          notifier.addEntry(
            amount: data.amount,
            title: data.title,
            category: data.category,
            isLent: isLent,
          );
        },
      ),
    );
  }

  Future<void> _sendWhatsAppReminder(KhataState state) async {
    final net = state.netStanding;
    if (net <= 0) return;

    final currencyFormatter = NumberFormat('#,###');
    final message =
        'Salaam ${state.peerName}, friendly reminder: Rs ${currencyFormatter.format(net)} from our khata is pending. Pay whenever you can, thanks!';
    final encoded = Uri.encodeComponent(message);
    final url = Uri.parse('whatsapp://send?phone=${state.peerPhone ?? ''}&text=$encoded');
    final fallbackUrl = Uri.parse('https://wa.me/${state.peerPhone ?? ''}?text=$encoded');

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
    final state = ref.watch(khataDetailProvider(peerId));
    final notifier = ref.read(khataDetailProvider(peerId).notifier);
    final currencyFormatter = NumberFormat('#,###');

    final isPeerOwesYou = state.netStanding >= 0;
    final statusColor = isPeerOwesYou ? AppColors.mint : AppColors.rose;
    final statusText = isPeerOwesYou
        ? '${state.peerName.toUpperCase()} OWES YOU'
        : 'YOU OWE ${state.peerName.toUpperCase()}';

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
              // Cockpit Header: Back, Avatar, Name & Privacy Badge
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                child: Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                      onPressed: () => Navigator.of(context).pop(),
                    ),
                    Container(
                      width: 52,
                      height: 52,
                      decoration: BoxDecoration(
                        color: isDark ? AppColors.mint.withOpacity(0.16) : AppColors.mintSquircleBg,
                        borderRadius: BorderRadius.circular(18),
                      ),
                      alignment: Alignment.center,
                      child: Text(
                        state.peerInitials,
                        style: TextStyle(
                          color: isDark ? AppColors.mintTextDark : AppColors.mintTextLight,
                          fontWeight: FontWeight.w800,
                          fontSize: 18,
                        ),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            state.peerName,
                            style: AppTypography.screenTitle.copyWith(
                              color: Colors.white,
                              fontSize: 22,
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            'Private khata, on this phone only',
                            style: AppTypography.caption.copyWith(
                              color: AppColors.textDarkMuted,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 6),

              // Net Standing Glass Card
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
                            fontSize: 11,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      'Rs ${currencyFormatter.format(state.netStanding.abs())}',
                      style: AppTypography.heroBalance.copyWith(
                        color: Colors.white,
                        fontSize: 34,
                      ),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Bottom Surface Sheet
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
                      // "I lent" vs "I borrowed" CTAs
                      Row(
                        children: [
                          Expanded(
                            child: _ActionCta(
                              text: 'I lent',
                              backgroundColor: isDark ? AppColors.darkPillActive : AppColors.cockpitGradientStart,
                              textColor: Colors.white,
                              onTap: () => _showQuickLendBorrowSheet(context, ref, isLent: true),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: _ActionCta(
                              text: 'I borrowed',
                              backgroundColor: isDark
                                  ? AppColors.rose.withOpacity(0.18)
                                  : AppColors.roseSquircleBg,
                              textColor: isDark ? AppColors.roseTextDark : AppColors.roseTextLight,
                              onTap: () => _showQuickLendBorrowSheet(context, ref, isLent: false),
                            ),
                          ),
                        ],
                      ),

                      const SizedBox(height: 14),

                      // Filter Pills (Open vs Cleared)
                      Row(
                        children: ['Open', 'Cleared'].map((tab) {
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
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 8),
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

                      // Timeline Feed List
                      Expanded(
                        child: state.filteredEntries.isEmpty
                            ? Center(
                                child: Text(
                                  state.activeTab == 'Open' ? 'All dues are settled!' : 'No cleared entries',
                                  style: AppTypography.caption.copyWith(
                                    color: isDark ? AppColors.textDarkMuted : AppColors.textLightMuted,
                                  ),
                                ),
                              )
                            : ListView.builder(
                                padding: const EdgeInsets.only(bottom: 90, top: 4),
                                physics: const BouncingScrollPhysics(),
                                itemCount: state.filteredEntries.length,
                                itemBuilder: (context, index) {
                                  final entry = state.filteredEntries[index];
                                  return KhataTimelineTile(
                                    entry: entry,
                                    onDelete: () => notifier.deleteEntry(entry.id),
                                  );
                                },
                              ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),

      // Sticky Bottom Settle Up & Remind CTAs
      bottomNavigationBar: Container(
        color: surfaceColor,
        padding: const EdgeInsets.only(left: 20, right: 20, bottom: 24, top: 10),
        child: Row(
          children: [
            Expanded(
              child: _ActionCta(
                text: 'Settle up',
                backgroundColor: AppColors.mint,
                textColor: AppColors.textLightPrimary,
                onTap: () {
                  notifier.settleAll();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Khata settled successfully!')),
                  );
                },
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _ActionCta(
                text: 'Remind',
                backgroundColor: isDark ? AppColors.darkPillInactive : AppColors.lightPillInactive,
                textColor: isDark ? AppColors.textDarkPrimary : AppColors.textLightPrimary,
                onTap: () => _sendWhatsAppReminder(state),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionCta extends StatelessWidget {
  final String text;
  final Color backgroundColor;
  final Color textColor;
  final VoidCallback? onTap;

  const _ActionCta({
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
