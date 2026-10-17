import 'dart:math' as math;

/// Cross-Khata Counter-Debt Reconciliation Engine.
/// Reconciles debts between shared group dues and private 1-on-1 personal loans.
class DebtOffsetCalculator {
  DebtOffsetCalculator._();

  /// Calculates net payable amount after deducting any counter-debt with the same peer.
  /// [grossDue]: What you currently owe the peer for selected bill(s).
  /// [peerOwesYou]: Personal counter-debt peer owes you (from 1-on-1 khata).
  /// [applyOffset]: Whether user has opted-in to offset.
  static ({
    int grossDue,
    int offsetCredit,
    int netPayable,
    int remainingPeerDebt,
    String explanation,
  }) calculateOffset({
    required int grossDue,
    required int peerOwesYou,
    required bool applyOffset,
    String peerName = 'peer',
  }) {
    if (!applyOffset || peerOwesYou <= 0 || grossDue <= 0) {
      return (
        grossDue: grossDue,
        offsetCredit: 0,
        netPayable: grossDue,
        remainingPeerDebt: peerOwesYou,
        explanation: 'No counter-debt offset applied.',
      );
    }

    final int offsetCredit = math.min(grossDue, peerOwesYou);
    final int netPayable = grossDue - offsetCredit;
    final int remainingPeerDebt = peerOwesYou - offsetCredit;

    final String explanation = 'Offset applied: $peerName owes you Rs $offsetCredit, so you pay Rs $netPayable.';

    return (
      grossDue: grossDue,
      offsetCredit: offsetCredit,
      netPayable: netPayable,
      remainingPeerDebt: remainingPeerDebt,
      explanation: explanation,
    );
  }
}
