import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../domain/models/settlement_bill.dart';

enum PaymentMethod { cash, online }

class SettleUpState {
  final List<SettlementBill> bills;
  final PaymentMethod paymentMethod;
  final String? receiptImagePath;
  final bool isLoading;

  const SettleUpState({
    required this.bills,
    this.paymentMethod = PaymentMethod.online,
    this.receiptImagePath,
    this.isLoading = false,
  });

  int get totalSelectedRs => bills
      .where((b) => b.isSelected)
      .fold(0, (sum, b) => sum + b.amountRs);

  int get counterDebtOffset => 0; // DebtOffsetCalculator integration point

  int get netPayableRs => (totalSelectedRs - counterDebtOffset).clamp(0, 999999);

  SettleUpState copyWith({
    List<SettlementBill>? bills,
    PaymentMethod? paymentMethod,
    String? receiptImagePath,
    bool? isLoading,
  }) =>
      SettleUpState(
        bills: bills ?? this.bills,
        paymentMethod: paymentMethod ?? this.paymentMethod,
        receiptImagePath: receiptImagePath ?? this.receiptImagePath,
        isLoading: isLoading ?? this.isLoading,
      );
}

class SettleUpNotifier extends StateNotifier<SettleUpState> {
  SettleUpNotifier(String peerId, String peerName)
      : super(SettleUpState(
          bills: SettlementBill.mock(peerId, peerName),
        ));

  void toggleBill(String billId) {
    state = state.copyWith(
      bills: state.bills
          .map((b) => b.id == billId ? b.copyWith(isSelected: !b.isSelected) : b)
          .toList(),
    );
  }

  void setPaymentMethod(PaymentMethod method) {
    state = state.copyWith(paymentMethod: method);
  }

  void setReceiptImage(String path) {
    state = state.copyWith(receiptImagePath: path);
  }
}

/// Family provider keyed by peerId
final settleUpProvider = StateNotifierProvider.family<SettleUpNotifier, SettleUpState, String>(
  (ref, peerId) => SettleUpNotifier(peerId, 'Sheeda'),
);
