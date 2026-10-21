import 'dart:io';
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:path_provider/path_provider.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../core/constants/app_dimensions.dart';

class TactileTicketReceipt extends StatefulWidget {
  final String title;
  final double amount;
  final String paidBy;
  final String recipient;
  final List<Map<String, String>> shares;

  const TactileTicketReceipt({
    super.key,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.recipient,
    required this.shares,
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
          child: Container(
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
                const Text(
                  'DOLO SETTLEMENT SLIP',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 2.0,
                    color: AppColors.textLightMuted,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Rs ${widget.amount.toStringAsFixed(0)}',
                  style: const TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: AppColors.textLightPrimary,
                  ),
                ),
                const SizedBox(height: 16),
                const Divider(color: AppColors.lightBorder),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Paid By', style: TextStyle(color: AppColors.textLightMuted)),
                    Text(widget.paidBy, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLightPrimary)),
                  ],
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Recipient', style: TextStyle(color: AppColors.textLightMuted)),
                    Text(widget.recipient, style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.textLightPrimary)),
                  ],
                ),
                if (widget.shares.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  const Divider(color: AppColors.lightBorder),
                  const SizedBox(height: 8),
                  ...widget.shares.map(
                    (s) => Padding(
                      padding: const EdgeInsets.symmetric(vertical: 2.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(s['name'] ?? '', style: const TextStyle(fontSize: 12, color: AppColors.textLightMuted)),
                          Text('Rs ${s['share'] ?? '0'}', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textLightPrimary)),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.mintSquircleBg,
                    borderRadius: BorderRadius.circular(AppDimensions.pillRadius),
                  ),
                  child: const Text(
                    '✔ SETTLED',
                    style: TextStyle(
                      color: AppColors.mintTextLight,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                    ),
                  ),
                ),
              ],
            ),
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