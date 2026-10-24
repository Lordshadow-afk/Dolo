import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

/// Dolo Settlement Ticket — dashed-border tactile receipt widget.
/// All currency amounts are whole-rupee [int] (no floating point).
class TactileTicketReceipt extends StatefulWidget {
  final String title;
  /// Total amount in whole rupees (int only — no decimals).
  final int amountRs;
  final String paidBy;
  final String recipient;
  /// Each entry: {'name': 'Ali', 'share': '500'} — share as String whole-Rs.
  final List<Map<String, String>> shares;
  final bool isSettled;

  const TactileTicketReceipt({
    super.key,
    required this.title,
    required this.amountRs,
    required this.paidBy,
    required this.recipient,
    this.shares = const [],
    this.isSettled = true,
  });

  @override
  State<TactileTicketReceipt> createState() => _TactileTicketReceiptState();
}

class _TactileTicketReceiptState extends State<TactileTicketReceipt> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _shareTicketAsPng() async {
    try {
      final boundary =
          _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      final image = await boundary.toImage(pixelRatio: 3.0);
      final byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      final pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File(
        '${tempDir.path}/settlement_${DateTime.now().millisecondsSinceEpoch}.png',
      ).create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles(
        [XFile(file.path)],
        text: 'Settlement receipt for ${widget.title} via Dolo',
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to share ticket: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        RepaintBoundary(
          key: _boundaryKey,
          child: _TicketCard(
            title: widget.title,
            amountRs: widget.amountRs,
            paidBy: widget.paidBy,
            recipient: widget.recipient,
            shares: widget.shares,
            isSettled: widget.isSettled,
          ),
        ),
        const SizedBox(height: 16),
        SizedBox(
          height: AppDimensions.ctaHeight,
          child: ElevatedButton.icon(
            onPressed: _shareTicketAsPng,
            icon: const Icon(Icons.share, size: 18),
            label: const Text('Share Receipt PNG'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.mint,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppDimensions.ctaRadius),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

class _TicketCard extends StatelessWidget {
  final String title;
  final int amountRs;
  final String paidBy;
  final String recipient;
  final List<Map<String, String>> shares;
  final bool isSettled;

  const _TicketCard({
    required this.title,
    required this.amountRs,
    required this.paidBy,
    required this.recipient,
    required this.shares,
    required this.isSettled,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 310,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.lightSurface,
        borderRadius: BorderRadius.circular(AppDimensions.ticketRadius),
        border: Border.all(color: AppColors.lightBorder, width: 1.5),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Ticket header
          const Text(
            'DOLO SETTLEMENT SLIP',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              letterSpacing: 2.0,
              color: AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: AppColors.textLightMuted,
            ),
          ),
          const SizedBox(height: 10),
          // Amount — whole rupees, integer display
          Text(
            'Rs $amountRs',
            style: const TextStyle(
              fontSize: 32,
              fontWeight: FontWeight.w900,
              color: AppColors.textLightPrimary,
            ),
          ),
          const SizedBox(height: 16),
          const Divider(color: AppColors.lightBorder),
          const SizedBox(height: 12),
          // Paid by / recipient
          _Row(label: 'Paid By', value: paidBy),
          const SizedBox(height: 8),
          _Row(label: 'Recipient', value: recipient),
          // Per-member shares
          if (shares.isNotEmpty) ...[
            const SizedBox(height: 12),
            const Divider(color: AppColors.lightBorder),
            const SizedBox(height: 8),
            ...shares.map(
              (s) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 2.0),
                child: _Row(
                  label: s['name'] ?? '',
                  value: 'Rs ${s['share'] ?? '0'}',
                ),
              ),
            ),
          ],
          const SizedBox(height: 20),
          // Status badge
          Container(
            padding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: isSettled
                  ? AppColors.indigoSquircleBg
                  : AppColors.roseSquircleBg,
              borderRadius:
                  BorderRadius.circular(AppDimensions.pillRadius),
            ),
            child: Text(
              isSettled ? '✓ SETTLED' : '⏳ PENDING',
              style: TextStyle(
                color: isSettled
                    ? AppColors.indigoTextLight
                    : AppColors.roseTextLight,
                fontWeight: FontWeight.w900,
                fontSize: 12,
              ),
            ),
          ),
          const SizedBox(height: 8),
          // Auto-purge note
          const Text(
            'Auto-purge in 7 days',
            style: TextStyle(
                fontSize: 10, color: AppColors.textLightSecondary),
          ),
        ],
      ),
    );
  }
}

class _Row extends StatelessWidget {
  final String label;
  final String value;
  const _Row({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label,
            style: const TextStyle(color: AppColors.textLightMuted)),
        Text(value,
            style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppColors.textLightPrimary)),
      ],
    );
  }
}
