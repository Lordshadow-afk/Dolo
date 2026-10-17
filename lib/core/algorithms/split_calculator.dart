/// Pure calculation engine handling 4 split modes with whole-Rupee remainder allocation.
class SplitCalculator {
  SplitCalculator._();

  /// 1. Equal Split with Automated Whole-Rupee Remainder Allocation.
  /// Solves the odd-rupee problem (e.g., Rs 1,000 divided by 3 members = 334, 333, 333).
  /// [totalAmount]: Total expense in Rupees (integer).
  /// [memberCount]: Total participating members.
  /// [payerIndex]: Index of member who paid, who absorbs/receives remainder (default 0).
  static List<int> calculateEqualSplit({
    required int totalAmount,
    required int memberCount,
    int payerIndex = 0,
  }) {
    if (memberCount <= 0 || totalAmount <= 0) {
      return List.filled(memberCount, 0);
    }

    final int baseShare = totalAmount ~/ memberCount;
    final int remainder = totalAmount % memberCount;

    final List<int> shares = List.filled(memberCount, baseShare);

    // Distribute remainder 1 Rupee at a time starting from payerIndex
    for (int i = 0; i < remainder; i++) {
      final targetIndex = (payerIndex + i) % memberCount;
      shares[targetIndex] += 1;
    }

    assert(
      shares.reduce((a, b) => a + b) == totalAmount,
      'Equal split sum must match total amount exactly',
    );

    return shares;
  }

  /// 2. Exact Rupee Split Validator.
  /// Checks whether manually entered individual shares sum up to total amount.
  static ({bool isValid, int difference}) validateExactSplit({
    required int totalAmount,
    required List<int> individualShares,
  }) {
    final int sum = individualShares.isEmpty
        ? 0
        : individualShares.reduce((a, b) => a + b);
    return (
      isValid: sum == totalAmount,
      difference: totalAmount - sum,
    );
  }

  /// 3. Percentage Split Calculator with Whole-Rupee Rounding.
  /// Converts percentages to integer Rupees and resolves any 1-rupee rounding variance.
  static ({bool isValid, List<int> shares, double totalPercentage}) calculatePercentageSplit({
    required int totalAmount,
    required List<double> percentages,
    int payerIndex = 0,
  }) {
    final double totalPercentage = percentages.isEmpty
        ? 0.0
        : percentages.reduce((a, b) => a + b);

    // Allow slight float variance around 100%
    final bool is100Percent = (totalPercentage - 100.0).abs() < 0.01;
    if (!is100Percent || totalAmount <= 0) {
      return (
        isValid: false,
        shares: List.filled(percentages.length, 0),
        totalPercentage: totalPercentage,
      );
    }

    // Initial integer rounding per share
    final List<int> shares = percentages.map((pct) {
      return ((pct / 100.0) * totalAmount).round();
    }).toList();

    // Reconcile rounding gap with totalAmount
    final int currentSum = shares.reduce((a, b) => a + b);
    final int diff = totalAmount - currentSum;

    if (diff != 0 && shares.isNotEmpty) {
      final targetIndex = payerIndex.clamp(0, shares.length - 1);
      shares[targetIndex] += diff;
    }

    return (
      isValid: true,
      shares: shares,
      totalPercentage: totalPercentage,
    );
  }

  /// 4. Dhaba & Canteen Itemized Tally Mode.
  /// Aggregates individual food/item lines into per-person totals.
  /// Input: Map of item prices to assigned member IDs.
  static ({int totalAmount, Map<String, int> perMemberShares}) calculateItemizedTally({
    required List<({String title, int price, List<String> memberIds})> items,
  }) {
    final Map<String, int> memberTotals = {};
    int grandTotal = 0;

    for (final item in items) {
      grandTotal += item.price;
      if (item.memberIds.isEmpty) continue;

      // Split item price equally among assigned eaters with remainder
      final itemShares = calculateEqualSplit(
        totalAmount: item.price,
        memberCount: item.memberIds.length,
      );

      for (int i = 0; i < item.memberIds.length; i++) {
        final memberId = item.memberIds[i];
        memberTotals[memberId] = (memberTotals[memberId] ?? 0) + itemShares[i];
      }
    }

    return (
      totalAmount: grandTotal,
      perMemberShares: memberTotals,
    );
  }
}
