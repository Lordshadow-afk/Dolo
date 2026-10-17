import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/core/algorithms/debt_simplifier.dart';

void main() {
  group('DebtSimplifier - Min-Cash-Flow Algorithm', () {
    test('simplifies a 3-way circular debt chain into minimal payments', () {
      // Sheeda owes Ali Rs 1,000
      // Kaptaan owes Sheeda Rs 1,000
      // Net balances: Ali = +1000, Sheeda = 0, Kaptaan = -1000
      final netBalances = {
        'ali': 1000,
        'sheeda': 0,
        'kaptaan': -1000,
      };

      final settlements = DebtSimplifier.simplifyNetBalances(netBalances);

      // Should bypass Sheeda completely: Kaptaan pays Ali directly!
      expect(settlements.length, 1);
      expect(settlements[0].fromMemberId, 'kaptaan');
      expect(settlements[0].toMemberId, 'ali');
      expect(settlements[0].amount, 1000);
    });

    test('reconciles multi-member hostel dues (4 members)', () {
      // Ali is owed 9,100
      // Sheeda owes 4,850
      // Kaptaan owes 4,250
      final netBalances = {
        'ali': 9100,
        'sheeda': -4850,
        'kaptaan': -4250,
      };

      final settlements = DebtSimplifier.simplifyNetBalances(netBalances);

      expect(settlements.length, 2);
      final totalTransferred = settlements.fold<int>(0, (sum, s) => sum + s.amount);
      expect(totalTransferred, 9100);
    });
  });
}
