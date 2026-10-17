import 'expense_model.dart';

class SettlementModel {
  final String id;
  final String payerId;
  final String payeeId;
  final int totalPaid; // In whole Rupees
  final PaymentMethod paymentMethod;
  final int offsetAmount; // Amount offset from counter-debt
  final String? screenshotPath;
  final DateTime settledAt;

  const SettlementModel({
    required this.id,
    required this.payerId,
    required this.payeeId,
    required this.totalPaid,
    required this.paymentMethod,
    this.offsetAmount = 0,
    this.screenshotPath,
    required this.settledAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'payer_id': payerId,
      'payee_id': payeeId,
      'total_paid': totalPaid,
      'payment_method': paymentMethod.name.toUpperCase(),
      'offset_amount': offsetAmount,
      'screenshot_path': screenshotPath,
      'settled_at': settledAt.toIso8601String(),
    };
  }

  factory SettlementModel.fromMap(Map<String, dynamic> map) {
    final methodStr = (map['payment_method'] as String? ?? 'CASH').toLowerCase();
    return SettlementModel(
      id: map['id'] as String,
      payerId: map['payer_id'] as String,
      payeeId: map['payee_id'] as String,
      totalPaid: map['total_paid'] as int,
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == methodStr,
        orElse: () => PaymentMethod.cash,
      ),
      offsetAmount: map['offset_amount'] as int? ?? 0,
      screenshotPath: map['screenshot_path'] as String?,
      settledAt: DateTime.parse(map['settled_at'] as String),
    );
  }
}
