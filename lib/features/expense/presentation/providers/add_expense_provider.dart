import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/algorithms/split_calculator.dart';
import '../../../../core/models/expense_model.dart';

class MemberShareItem {
  final String id;
  final String name;
  final String initials;
  final String colorHex;
  final int shareAmount;

  const MemberShareItem({
    required this.id,
    required this.name,
    required this.initials,
    required this.colorHex,
    required this.shareAmount,
  });

  MemberShareItem copyWith({int? shareAmount}) {
    return MemberShareItem(
      id: id,
      name: name,
      initials: initials,
      colorHex: colorHex,
      shareAmount: shareAmount ?? this.shareAmount,
    );
  }
}

class AddExpenseState {
  final int totalAmount;
  final String title;
  final String category;
  final String payerName;
  final String groupName;
  final SplitMode splitMode;
  final List<MemberShareItem> members;
  final String? receiptPath;
  final bool isSaving;

  const AddExpenseState({
    required this.totalAmount,
    required this.title,
    required this.category,
    required this.payerName,
    required this.groupName,
    required this.splitMode,
    required this.members,
    this.receiptPath,
    this.isSaving = false,
  });

  bool get hasRemainder => (totalAmount % members.length) != 0;

  AddExpenseState copyWith({
    int? totalAmount,
    String? title,
    String? category,
    String? payerName,
    String? groupName,
    SplitMode? splitMode,
    List<MemberShareItem>? members,
    String? receiptPath,
    bool? isSaving,
  }) {
    return AddExpenseState(
      totalAmount: totalAmount ?? this.totalAmount,
      title: title ?? this.title,
      category: category ?? this.category,
      payerName: payerName ?? this.payerName,
      groupName: groupName ?? this.groupName,
      splitMode: splitMode ?? this.splitMode,
      members: members ?? this.members,
      receiptPath: receiptPath ?? this.receiptPath,
      isSaving: isSaving ?? this.isSaving,
    );
  }
}

final addExpenseProvider = StateNotifierProvider<AddExpenseNotifier, AddExpenseState>((ref) {
  return AddExpenseNotifier();
});

class AddExpenseNotifier extends StateNotifier<AddExpenseState> {
  AddExpenseNotifier()
      : super(
          AddExpenseState(
            totalAmount: 3600,
            title: 'Dinner at Bundu Khan',
            category: 'Food',
            payerName: 'You',
            groupName: 'Hostel Gang',
            splitMode: SplitMode.equal,
            members: const [
              MemberShareItem(
                id: 'user_self',
                name: 'You',
                initials: 'AL',
                colorHex: '#09121F',
                shareAmount: 900,
              ),
              MemberShareItem(
                id: 'sheeda',
                name: 'Sheeda',
                initials: 'SH',
                colorHex: '#DDF7F2',
                shareAmount: 900,
              ),
              MemberShareItem(
                id: 'kaptaan',
                name: 'Kaptaan',
                initials: 'KP',
                colorHex: '#E8E6FF',
                shareAmount: 900,
              ),
              MemberShareItem(
                id: 'hamza',
                name: 'Hamza',
                initials: 'HM',
                colorHex: '#FFE4EA',
                shareAmount: 900,
              ),
            ],
          ),
        ) {
    _recalculateShares();
  }

  void setTotalAmount(int amount) {
    state = state.copyWith(totalAmount: amount);
    _recalculateShares();
  }

  void setTitle(String title) {
    state = state.copyWith(title: title);
  }

  void setCategory(String category) {
    state = state.copyWith(category: category);
  }

  void setSplitMode(SplitMode mode) {
    state = state.copyWith(splitMode: mode);
    _recalculateShares();
  }

  void setReceiptPath(String? path) {
    state = state.copyWith(receiptPath: path);
  }

  void _recalculateShares() {
    if (state.members.isEmpty) return;

    if (state.splitMode == SplitMode.equal) {
      final shares = SplitCalculator.calculateEqualSplit(
        totalAmount: state.totalAmount,
        memberCount: state.members.length,
        payerIndex: 0, // 'You' absorbs the remainder if any
      );

      final updatedMembers = <MemberShareItem>[];
      for (int i = 0; i < state.members.length; i++) {
        updatedMembers.add(state.members[i].copyWith(shareAmount: shares[i]));
      }

      state = state.copyWith(members: updatedMembers);
    }
  }

  Future<bool> saveExpense() async {
    state = state.copyWith(isSaving: true);
    // Simulate instant SQLite save
    await Future.delayed(const Duration(milliseconds: 200));
    state = state.copyWith(isSaving: false);
    return true;
  }
}
