import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/core/algorithms/split_calculator.dart';
import 'package:dolo/core/algorithms/debt_offset_calculator.dart';

void main() {
  group('SplitCalculator - Equal Split Remainder Allocation', () {
    test('splits Rs 1,000 evenly among 3 people without losing the odd rupee', () {
      final shares = SplitCalculator.calculateEqualSplit(
        totalAmount: 1000,
        memberCount: 3,
        payerIndex: 0,
      );

      expect(shares.length, 3);
      expect(shares[0], 334); // Payer absorbs the 1-rupee remainder
      expect(shares[1], 333);
      expect(shares[2], 333);
      expect(shares.reduce((a, b) => a + b), 1000);
    });

    test('splits Rs 3,600 evenly among 4 members with zero remainder', () {
      final shares = SplitCalculator.calculateEqualSplit(
        totalAmount: 3600,
        memberCount: 4,
      );

      expect(shares, [900, 900, 900, 900]);
      expect(shares.reduce((a, b) => a + b), 3600);
    });

    test('splits Rs 10 among 3 members (remainder 1)', () {
      final shares = SplitCalculator.calculateEqualSplit(
        totalAmount: 10,
        memberCount: 3,
        payerIndex: 1,
      );

      expect(shares, [3, 4, 3]); // Index 1 absorbs remainder
      expect(shares.reduce((a, b) => a + b), 10);
    });
  });

  group('SplitCalculator - Percentage & Itemized', () {
    test('validates 100% percentage split with whole-rupee rounding', () {
      final result = SplitCalculator.calculatePercentageSplit(
        totalAmount: 18400,
        percentages: [40.0, 25.0, 15.0, 10.0, 10.0], // Food, Hostel, Fuel, Print, Udhar
      );

      expect(result.isValid, isTrue);
      expect(result.shares, [7360, 4600, 2760, 1840, 1840]);
      expect(result.shares.reduce((a, b) => a + b), 18400);
    });

    test('aggregates Dhaba itemized tally correctly', () {
      final result = SplitCalculator.calculateItemizedTally(
        items: [
          (title: 'Biryani', price: 350, memberIds: ['ali']),
          (title: 'Roll Paratha', price: 220, memberIds: ['sheeda']),
          (title: 'Chai', price: 80, memberIds: ['hamza']),
          (title: 'Shared Fries', price: 150, memberIds: ['ali', 'sheeda']), // 75 each
        ],
      );

      expect(result.totalAmount, 800);
      expect(result.perMemberShares['ali'], 350 + 75); // 425
      expect(result.perMemberShares['sheeda'], 220 + 75); // 295
      expect(result.perMemberShares['hamza'], 80);
      expect(
        result.perMemberShares.values.reduce((a, b) => a + b),
        800,
      );
    });
  });

  group('DebtOffsetCalculator', () {
    test('applies counter-debt deduction accurately', () {
      final result = DebtOffsetCalculator.calculateOffset(
        grossDue: 1850,
        peerOwesYou: 250,
        applyOffset: true,
        peerName: 'Sheeda',
      );

      expect(result.grossDue, 1850);
      expect(result.offsetCredit, 250);
      expect(result.netPayable, 1600);
      expect(result.remainingPeerDebt, 0);
      expect(result.explanation, contains('Rs 250, so you pay Rs 1600'));
    });

    test('does not apply offset when toggle is false', () {
      final result = DebtOffsetCalculator.calculateOffset(
        grossDue: 1850,
        peerOwesYou: 250,
        applyOffset: false,
        peerName: 'Sheeda',
      );

      expect(result.offsetCredit, 0);
      expect(result.netPayable, 1850);
      expect(result.remainingPeerDebt, 250);
    });
  });
}
