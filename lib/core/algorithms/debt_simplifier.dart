import 'dart:math' as math;

/// Min-Cash-Flow Greedy Debt Simplification Algorithm.
/// Reduces an N*(N-1) web of pairwise group debts to at most N-1 transactions.
class DebtSimplifier {
  DebtSimplifier._();

  /// Calculates the minimal list of payment transfers needed to fully settle a group.
  /// [netBalances]: Map of contactId to their net standing in the group
  /// (+ve means they are owed money, -ve means they owe money).
  static List<({String fromMemberId, String toMemberId, int amount})> simplifyNetBalances(
    Map<String, int> netBalances,
  ) {
    final Map<String, int> balances = Map.from(netBalances);
    // Remove zero balances
    balances.removeWhere((_, balance) => balance == 0);

    final List<({String fromMemberId, String toMemberId, int amount})> settlements = [];

    while (balances.isNotEmpty) {
      // Find max creditor (+ve) and max debtor (-ve)
      String? maxCreditorId;
      int maxCredit = 0;

      String? maxDebtorId;
      int maxDebit = 0; // Stored as positive absolute value for comparison

      for (final entry in balances.entries) {
        if (entry.value > maxCredit) {
          maxCredit = entry.value;
          maxCreditorId = entry.key;
        } else if (entry.value < 0 && entry.value.abs() > maxDebit) {
          maxDebit = entry.value.abs();
          maxDebtorId = entry.key;
        }
      }

      // If no creditors or debtors left, break
      if (maxCreditorId == null || maxDebtorId == null || maxCredit == 0 || maxDebit == 0) {
        break;
      }

      // Transfer amount is the minimum of what debtor owes and creditor is owed
      final int transferAmount = math.min(maxCredit, maxDebit);

      settlements.add((
        fromMemberId: maxDebtorId,
        toMemberId: maxCreditorId,
        amount: transferAmount,
      ));

      // Update balances
      final int newCreditorBalance = balances[maxCreditorId]! - transferAmount;
      final int newDebtorBalance = balances[maxDebtorId]! + transferAmount;

      if (newCreditorBalance == 0) {
        balances.remove(maxCreditorId);
      } else {
        balances[maxCreditorId] = newCreditorBalance;
      }

      if (newDebtorBalance == 0) {
        balances.remove(maxDebtorId);
      } else {
        balances[maxDebtorId] = newDebtorBalance;
      }
    }

    return settlements;
  }

  /// Helper to convert a list of raw pairwise expenses into net member balances.
  static Map<String, int> computeNetBalances({
    required List<({String payerId, Map<String, int> memberShares})> transactions,
  }) {
    final Map<String, int> netBalances = {};

    for (final txn in transactions) {
      final String payerId = txn.payerId;

      for (final entry in txn.memberShares.entries) {
        final String memberId = entry.key;
        final int share = entry.value;

        if (memberId == payerId) continue;

        // Payer is owed `share`
        netBalances[payerId] = (netBalances[payerId] ?? 0) + share;
        // Member owes `share`
        netBalances[memberId] = (netBalances[memberId] ?? 0) - share;
      }
    }

    return netBalances;
  }
}
