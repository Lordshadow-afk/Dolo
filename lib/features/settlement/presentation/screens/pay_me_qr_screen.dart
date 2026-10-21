import 'package:flutter/material.dart';
import 'package:qr_flutter/qr_flutter.dart';

class PayMeQrScreen extends StatelessWidget {
  final String accountTitle;
  final String bankName;
  final String raastId;

  const PayMeQrScreen({
    Key? key,
    required this.accountTitle,
    required this.bankName,
    required this.raastId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final String qrData = 'PK-RAAST:$raastId|$accountTitle|$bankName';

    return Scaffold(
      appBar: AppBar(title: const Text('Pay Me QR')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                accountTitle,
                style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              Text(
                '$bankName • Raast ID: $raastId',
                style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
              ),
              const SizedBox(height: 32),
              QrImageView(
                data: qrData,
                version: QrVersions.auto,
                size: 240.0,
              ),
              const SizedBox(height: 24),
              const Text(
                'Scan using SadaPay, NayaPay, or any Pakistani Bank App',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}