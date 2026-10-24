import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';
import '../../../../core/utils/image_compressor_helper.dart';
import '../../domain/models/settlement_bill.dart';
import '../providers/settle_up_provider.dart';

class SettleUpSheet extends ConsumerWidget {
  final String peerId;
  final String peerName;

  const SettleUpSheet({
    super.key,
    required this.peerId,
    required this.peerName,
  });

  static Future<void> show(
    BuildContext context, {
    required String peerId,
    required String peerName,
  }) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      useSafeArea: true,
      builder: (_) => SettleUpSheet(peerId: peerId, peerName: peerName),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(settleUpProvider(peerId));
    final notifier = ref.read(settleUpProvider(peerId).notifier);
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bg = isDark ? AppColors.darkSurface : Colors.white;

    return DraggableScrollableSheet(
      initialChildSize: 0.88,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) {
        return Container(
          decoration: BoxDecoration(
            color: bg,
            borderRadius:
                const BorderRadius.vertical(top: Radius.circular(AppDimensions.radiusXL)),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              _SheetHeader(peerName: peerName),
              const Divider(height: 1),
              Expanded(
                child: ListView(
                  controller: scrollController,
                  padding: const EdgeInsets.all(20),
                  children: [
                    // Counter-debt offset banner (if any)
                    if (state.counterDebtOffset > 0)
                      _CounterDebtBanner(offset: state.counterDebtOffset),

                    // Bill checklist
                    const _SectionLabel('Outstanding bills'),
                    const SizedBox(height: 8),
                    ...state.bills.map((bill) => _BillCheckTile(
                          bill: bill,
                          onToggle: () => notifier.toggleBill(bill.id),
                        )),
                    const SizedBox(height: 20),

                    // Payment method toggle
                    const _SectionLabel('How are you paying?'),
                    const SizedBox(height: 8),
                    _PaymentMethodToggle(
                      selected: state.paymentMethod,
                      onChanged: notifier.setPaymentMethod,
                    ),
                    const SizedBox(height: 16),

                    // Wallet quick launchers (online only)
                    if (state.paymentMethod == PaymentMethod.online) ...[
                      const _SectionLabel('Pay with'),
                      const SizedBox(height: 10),
                      const _WalletLaunchersRow(),
                      const SizedBox(height: 20),
                    ],

                    // Receipt attachment
                    _AttachReceiptPill(
                      imagePath: state.receiptImagePath,
                      onAttach: () async {
                        final path = await ImageCompressorHelper.pickAndCompressImage(
                          source: ImageSource.gallery,
                        );
                        if (path != null) notifier.setReceiptImage(path);
                      },
                    ),
                    const SizedBox(height: 24),

                    // Summary row
                    _SummaryRow(netRs: state.netPayableRs),
                    const SizedBox(height: 24),
                  ],
                ),
              ),

              // CTA
              _ConfirmCTA(
                netRs: state.netPayableRs,
                onConfirm: () {
                  HapticFeedback.mediumImpact();
                  Navigator.pop(context);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text('Settlement of Rs ${state.netPayableRs} recorded ✓'),
                      backgroundColor: AppColors.mint,
                      duration: const Duration(seconds: 3),
                    ),
                  );
                },
              ),
            ],
          ),
        );
      },
    );
  }
}

// ─── Sub-widgets ─────────────────────────────────────────────────────────────

class _SheetHeader extends StatelessWidget {
  final String peerName;
  const _SheetHeader({required this.peerName});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 16),
      child: Row(
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: const BoxDecoration(
              color: AppColors.indigoSquircleBg,
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.handshake_rounded, color: AppColors.indigoDeep, size: 20),
          ),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Settle up',
                  style: TextStyle(fontSize: 17, fontWeight: FontWeight.w700)),
              Text('with $peerName',
                  style: const TextStyle(fontSize: 13, color: AppColors.textLightMuted)),
            ],
          ),
          const Spacer(),
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
        ],
      ),
    );
  }
}

class _CounterDebtBanner extends StatelessWidget {
  final int offset;
  const _CounterDebtBanner({required this.offset});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppColors.mintSquircleBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
        border: Border.all(color: AppColors.mint.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          const Icon(Icons.swap_horiz_rounded, color: AppColors.mint),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              'Counter-debt offset: -Rs $offset applied automatically',
              style: const TextStyle(
                  color: AppColors.mintTextLight,
                  fontSize: 13,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String text;
  const _SectionLabel(this.text);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 2),
      child: Text(
        text.toUpperCase(),
        style: const TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.w700,
            letterSpacing: 0.8,
            color: AppColors.textLightMuted),
      ),
    );
  }
}

class _BillCheckTile extends StatelessWidget {
  final SettlementBill bill;
  final VoidCallback onToggle;
  const _BillCheckTile({required this.bill, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        margin: const EdgeInsets.only(bottom: 8),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppColors.darkBackground : AppColors.lightBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(
            color: bill.isSelected
                ? AppColors.indigo.withOpacity(0.4)
                : Colors.transparent,
          ),
        ),
        child: Row(
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 150),
              width: 22,
              height: 22,
              decoration: BoxDecoration(
                color: bill.isSelected ? AppColors.indigo : Colors.transparent,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(
                  color:
                      bill.isSelected ? AppColors.indigo : AppColors.lightBorder,
                  width: 2,
                ),
              ),
              child: bill.isSelected
                  ? const Icon(Icons.check, color: Colors.white, size: 14)
                  : null,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(bill.description,
                      style: const TextStyle(
                          fontWeight: FontWeight.w600, fontSize: 14)),
                  Text(
                    '${bill.date.day}/${bill.date.month}/${bill.date.year}',
                    style: const TextStyle(
                        color: AppColors.textLightMuted, fontSize: 12),
                  ),
                ],
              ),
            ),
            Text(
              'Rs ${bill.amountRs}',
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 14,
                color: bill.isSelected
                    ? AppColors.roseTextLight
                    : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _PaymentMethodToggle extends StatelessWidget {
  final PaymentMethod selected;
  final ValueChanged<PaymentMethod> onChanged;
  const _PaymentMethodToggle(
      {required this.selected, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        _MethodChip(
          label: '💵 Cash',
          isSelected: selected == PaymentMethod.cash,
          onTap: () => onChanged(PaymentMethod.cash),
        ),
        const SizedBox(width: 10),
        _MethodChip(
          label: '📱 Online',
          isSelected: selected == PaymentMethod.online,
          onTap: () => onChanged(PaymentMethod.online),
        ),
      ],
    );
  }
}

class _MethodChip extends StatelessWidget {
  final String label;
  final bool isSelected;
  final VoidCallback onTap;
  const _MethodChip(
      {required this.label, required this.isSelected, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? AppColors.indigoDeep : AppColors.lightPillInactive,
          borderRadius: BorderRadius.circular(30),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: 14,
            color: isSelected ? Colors.white : AppColors.textLightPrimary,
          ),
        ),
      ),
    );
  }
}

class _WalletLaunchersRow extends StatelessWidget {
  const _WalletLaunchersRow();

  static const _wallets = [
    {'name': 'SadaPay', 'emoji': '🟣', 'scheme': 'sadapay://'},
    {'name': 'NayaPay', 'emoji': '🟢', 'scheme': 'nayapay://'},
    {'name': 'Easypaisa', 'emoji': '🟠', 'scheme': 'easypaisa://'},
    {'name': 'JazzCash', 'emoji': '🔴', 'scheme': 'jazzcash://'},
  ];

  Future<void> _launch(String scheme) async {
    final uri = Uri.parse(scheme);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: _wallets
              .map((w) => Expanded(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: _WalletButton(
                        emoji: w['emoji']!,
                        name: w['name']!,
                        onTap: () => _launch(w['scheme']!),
                      ),
                    ),
                  ))
              .toList(),
        ),
        const SizedBox(height: 10),
        _CopyRaastRow(),
      ],
    );
  }
}

class _WalletButton extends StatelessWidget {
  final String emoji;
  final String name;
  final VoidCallback onTap;
  const _WalletButton(
      {required this.emoji, required this.name, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.lightBackground,
          borderRadius: BorderRadius.circular(AppDimensions.radiusSM),
          border: Border.all(color: AppColors.lightBorder),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 22)),
            const SizedBox(height: 4),
            Text(name,
                style: const TextStyle(
                    fontSize: 11, fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }
}

class _CopyRaastRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Clipboard.setData(const ClipboardData(text: '03001234567'));
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Raast ID copied!'),
              duration: Duration(seconds: 2)),
        );
      },
      child: Container(
        padding:
            const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: AppColors.mintSquircleBg,
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border:
              Border.all(color: AppColors.mint.withOpacity(0.3)),
        ),
        child: const Row(
          children: [
            Icon(Icons.copy_rounded, color: AppColors.mint, size: 18),
            SizedBox(width: 10),
            Text('Copy Raast ID to pay manually',
                style: TextStyle(
                    color: AppColors.mintTextLight,
                    fontWeight: FontWeight.w600,
                    fontSize: 13)),
          ],
        ),
      ),
    );
  }
}

class _AttachReceiptPill extends StatelessWidget {
  final String? imagePath;
  final VoidCallback onAttach;
  const _AttachReceiptPill(
      {required this.imagePath, required this.onAttach});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAttach,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
          border: Border.all(color: AppColors.lightBorder, width: 2),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              imagePath != null
                  ? Icons.check_circle_rounded
                  : Icons.attach_file_rounded,
              color: imagePath != null
                  ? AppColors.mint
                  : AppColors.textLightMuted,
            ),
            const SizedBox(width: 8),
            Text(
              imagePath != null
                  ? 'Payment screenshot attached ✓'
                  : 'Attach payment screenshot',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: imagePath != null
                    ? AppColors.mintTextLight
                    : AppColors.textLightMuted,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SummaryRow extends StatelessWidget {
  final int netRs;
  const _SummaryRow({required this.netRs});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.indigoSquircleBg,
        borderRadius: BorderRadius.circular(AppDimensions.radiusMD),
      ),
      child: Row(
        children: [
          const Expanded(
            child: Text('You pay',
                style: TextStyle(
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                    color: AppColors.indigoTextLight)),
          ),
          Text(
            'Rs $netRs',
            style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 22,
                color: AppColors.indigoDeep),
          ),
        ],
      ),
    );
  }
}

class _ConfirmCTA extends StatelessWidget {
  final int netRs;
  final VoidCallback onConfirm;
  const _ConfirmCTA({required this.netRs, required this.onConfirm});

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
        child: SizedBox(
          width: double.infinity,
          height: 56,
          child: ElevatedButton(
            onPressed: onConfirm,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.indigo,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppDimensions.radiusLG)),
              elevation: 0,
            ),
            child: Text(
              'Confirm & send slip  •  Rs $netRs',
              style: const TextStyle(
                  fontSize: 16, fontWeight: FontWeight.w700),
            ),
          ),
        ),
      ),
    );
  }
}
