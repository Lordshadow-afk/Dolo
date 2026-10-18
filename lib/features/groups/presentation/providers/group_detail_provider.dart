import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../core/algorithms/debt_simplifier.dart';
import '../../domain/models/group_expense_item.dart';

class GroupDetailState {
  final String groupId;
  final String groupName;
  final String membersLine;
  final int yourNetBalance; // e.g. -1850 (You owe Rs 1,850)
  final String activeTab; // 'Expenses', 'Balances', 'Members'
  final int simplifiedPaymentCount;
  final List<GroupExpenseItem> expenses;
  final List<GroupMemberDisplay> members;

  const GroupDetailState({
    required this.groupId,
    required this.groupName,
    required this.membersLine,
    required this.yourNetBalance,
    required this.activeTab,
    required this.simplifiedPaymentCount,
    required this.expenses,
    required this.members,
  });

  GroupDetailState copyWith({
    String? activeTab,
    List<GroupExpenseItem>? expenses,
    int? yourNetBalance,
  }) {
    return GroupDetailState(
      groupId: groupId,
      groupName: groupName,
      membersLine: membersLine,
      yourNetBalance: yourNetBalance ?? this.yourNetBalance,
      activeTab: activeTab ?? this.activeTab,
      simplifiedPaymentCount: simplifiedPaymentCount,
      expenses: expenses ?? this.expenses,
      members: members,
    );
  }
}

final groupDetailProvider = StateNotifierProvider.family<GroupDetailNotifier, GroupDetailState, String>(
  (ref, groupId) => GroupDetailNotifier(groupId),
);

class GroupDetailNotifier extends StateNotifier<GroupDetailState> {
  final String groupId;

  GroupDetailNotifier(this.groupId)
      : super(
          GroupDetailState(
            groupId: groupId,
            groupName: 'Hostel Gang',
            membersLine: 'You, Sheeda, Kaptaan, Hamza',
            yourNetBalance: -1850,
            activeTab: 'Expenses',
            simplifiedPaymentCount: 2,
            expenses: const [
              GroupExpenseItem(
                id: '1',
                title: 'Dinner',
                categoryTag: 'FD',
                subtitle: 'Paid by Sheeda, Equal',
                yourShare: -900,
              ),
              GroupExpenseItem(
                id: '2',
                title: 'Hostel dues',
                categoryTag: 'HS',
                subtitle: 'Paid by Kaptaan, Exact',
                yourShare: -700,
              ),
              GroupExpenseItem(
                id: '3',
                title: 'Printouts',
                categoryTag: 'PR',
                subtitle: 'Paid by Hamza, Percent',
                yourShare: -250,
              ),
            ],
            members: const [
              GroupMemberDisplay(
                id: 'user_self',
                name: 'You',
                nickname: 'Ali',
                initials: 'AL',
                netBalance: -1850,
              ),
              GroupMemberDisplay(
                id: 'sheeda',
                name: 'Sheeda',
                nickname: 'Sheeda',
                initials: 'SH',
                netBalance: 1200,
              ),
              GroupMemberDisplay(
                id: 'kaptaan',
                name: 'Kaptaan',
                nickname: 'Kaptaan',
                initials: 'KP',
                netBalance: 700,
              ),
              GroupMemberDisplay(
                id: 'hamza',
                name: 'Hamza',
                nickname: 'Hamza',
                initials: 'HM',
                netBalance: -50,
                isShadow: true, // Shadow member who hasn't downloaded app yet
              ),
            ],
          ),
        ) {
    _calculateSimplifiedDebt();
  }

  void _calculateSimplifiedDebt() {
    final netMap = {
      'user_self': state.yourNetBalance,
      'sheeda': 1200,
      'kaptaan': 700,
      'hamza': -50,
    };
    final simplified = DebtSimplifier.simplifyNetBalances(netMap);
    // simplified.length is the minimal number of payments
  }

  void setTab(String tab) {
    state = state.copyWith(activeTab: tab);
  }

  void clearAllDues() {
    state = state.copyWith(
      yourNetBalance: 0,
      expenses: state.expenses.map((e) => GroupExpenseItem(
        id: e.id,
        title: e.title,
        categoryTag: e.categoryTag,
        subtitle: e.subtitle,
        yourShare: 0,
        isSettled: true,
      )).toList(),
    );
  }
}
