import 'contact_model.dart';

enum SplitMode {
  equal,
  exact,
  percent,
  itemized,
}

enum PaymentMethod {
  cash,
  online,
}

class ExpenseSplitModel {
  final String id;
  final String expenseId;
  final String contactId;
  final int shareAmount; // Stored in whole Rupees (integer)
  final bool isPaid;
  final ContactModel? contact;

  const ExpenseSplitModel({
    required this.id,
    required this.expenseId,
    required this.contactId,
    required this.shareAmount,
    this.isPaid = false,
    this.contact,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'expense_id': expenseId,
      'contact_id': contactId,
      'share_amount': shareAmount,
      'is_paid': isPaid ? 1 : 0,
    };
  }

  factory ExpenseSplitModel.fromMap(Map<String, dynamic> map, {ContactModel? contact}) {
    return ExpenseSplitModel(
      id: map['id'] as String,
      expenseId: map['expense_id'] as String,
      contactId: map['contact_id'] as String,
      shareAmount: map['share_amount'] as int,
      isPaid: (map['is_paid'] as int? ?? 0) == 1,
      contact: contact,
    );
  }
}

class ExpenseModel {
  final String id;
  final String? groupId; // null indicates 1-on-1 private khata
  final String payerId;
  final String title;
  final String category; // Food, Hostel, Fuel, Printouts, Udhar
  final int totalAmount; // In whole Rupees
  final SplitMode splitMode;
  final PaymentMethod paymentMethod;
  final String? receiptImagePath;
  final bool isSettled;
  final DateTime? settledAt;
  final bool isTrashed;
  final DateTime? trashedAt;
  final DateTime createdAt;
  final List<ExpenseSplitModel> splits;
  final ContactModel? payer;

  const ExpenseModel({
    required this.id,
    this.groupId,
    required this.payerId,
    required this.title,
    required this.category,
    required this.totalAmount,
    required this.splitMode,
    required this.paymentMethod,
    this.receiptImagePath,
    this.isSettled = false,
    this.settledAt,
    this.isTrashed = false,
    this.trashedAt,
    required this.createdAt,
    this.splits = const [],
    this.payer,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'group_id': groupId,
      'payer_id': payerId,
      'title': title,
      'category': category,
      'total_amount': totalAmount,
      'split_mode': splitMode.name.toUpperCase(),
      'payment_method': paymentMethod.name.toUpperCase(),
      'receipt_image_path': receiptImagePath,
      'is_settled': isSettled ? 1 : 0,
      'settled_at': settledAt?.toIso8601String(),
      'is_trashed': isTrashed ? 1 : 0,
      'trashed_at': trashedAt?.toIso8601String(),
      'created_at': createdAt.toIso8601String(),
    };
  }

  factory ExpenseModel.fromMap(
    Map<String, dynamic> map, {
    List<ExpenseSplitModel> splits = const [],
    ContactModel? payer,
  }) {
    final splitModeStr = (map['split_mode'] as String? ?? 'EQUAL').toLowerCase();
    final paymentMethodStr = (map['payment_method'] as String? ?? 'CASH').toLowerCase();

    return ExpenseModel(
      id: map['id'] as String,
      groupId: map['group_id'] as String?,
      payerId: map['payer_id'] as String,
      title: map['title'] as String,
      category: map['category'] as String,
      totalAmount: map['total_amount'] as int,
      splitMode: SplitMode.values.firstWhere(
        (e) => e.name.toLowerCase() == splitModeStr,
        orElse: () => SplitMode.equal,
      ),
      paymentMethod: PaymentMethod.values.firstWhere(
        (e) => e.name.toLowerCase() == paymentMethodStr,
        orElse: () => PaymentMethod.cash,
      ),
      receiptImagePath: map['receipt_image_path'] as String?,
      isSettled: (map['is_settled'] as int? ?? 0) == 1,
      settledAt: map['settled_at'] != null ? DateTime.parse(map['settled_at'] as String) : null,
      isTrashed: (map['is_trashed'] as int? ?? 0) == 1,
      trashedAt: map['trashed_at'] != null ? DateTime.parse(map['trashed_at'] as String) : null,
      createdAt: DateTime.parse(map['created_at'] as String),
      splits: splits,
      payer: payer,
    );
  }
}
