import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:share_plus/share_plus.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';

class TicketReceiptScreen extends StatefulWidget {
  final String title;
  final double amount;
  final String paidBy;
  final String recipient;
  final List<Map<String, String>> shares;

  const TicketReceiptScreen({
    Key? key,
    required this.title,
    required this.amount,
    required this.paidBy,
    required this.recipient,
    required this.shares,
  }) : super(key: key);

  @override
  State<TicketReceiptScreen> createState() => _TicketReceiptScreenState();
}

class _TicketReceiptScreenState extends State<TicketReceiptScreen> {
  final GlobalKey _boundaryKey = GlobalKey();

  Future<void> _exportAndSharePng() async {
    try {
      RenderRepaintBoundary boundary =
          _boundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
      ui.Image image = await boundary.toImage(pixelRatio: 3.0);
      var byteData = await image.toByteData(format: ui.ImageByteFormat.png);
      var pngBytes = byteData!.buffer.asUint8List();

      final tempDir = await getTemporaryDirectory();
      final file = await File('${tempDir.path}/settlement_ticket.png').create();
      await file.writeAsBytes(pngBytes);

      await Share.shareXFiles([XFile(file.path)], text: 'Settlement Ticket for ${widget.title}');
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to share ticket: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Digital Ticket Receipt')),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            children: [
              RepaintBoundary(
                key: _boundaryKey,
                child: Container(
                  width: 320,
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.08),
                        blurRadius: 10,
                        spreadRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'SETTLEMENT RECEIPT',
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          letterSpacing: 2,
                          color: Colors.grey.shade600,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Rs ${widget.amount.toStringAsFixed(0)}',
                        style: const TextStyle(
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      const Divider(thickness: 1, color: Colors.grey),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Paid By:', style: TextStyle(color: Colors.grey.shade600)),
                          Text(widget.paidBy, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('Recipient:', style: TextStyle(color: Colors.grey.shade600)),
                          Text(widget.recipient, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      ...widget.shares.map(
                        (item) => Padding(
                          padding: const EdgeInsets.vertical: 4.0,
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(item['name'] ?? ''),
                              Text('Rs ${item['share']}'),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
                        decoration: BoxDecoration(
                          color: const Color(0xFF10B981).withOpacity(0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: const Text(
                          '✔ SETTLED',
                          style: TextStyle(
                            color: Color(0xFF059669),
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton.icon(
                onPressed: _exportAndSharePng,
                icon: const Icon(Icons.share),
                label: const Text('Share Ticket to WhatsApp'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}