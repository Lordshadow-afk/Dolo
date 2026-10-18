import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/features/expense/presentation/screens/add_expense_screen.dart';

void main() {
  testWidgets('AddExpenseScreen renders cockpit, hero amount, split tabs, members and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: AddExpenseScreen(),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Hero Amount
    expect(find.text('New expense'), findsOneWidget);
    expect(find.text('Rs '), findsOneWidget);
    expect(find.text('3600'), findsOneWidget);

    // Verify Categories
    expect(find.text('Food'), findsOneWidget);
    expect(find.text('Hostel'), findsOneWidget);
    expect(find.text('Fuel'), findsOneWidget);
    expect(find.text('Udhar'), findsOneWidget);

    // Verify Split Mode Tabs
    expect(find.text('Equal'), findsOneWidget);
    expect(find.text('Exact'), findsOneWidget);
    expect(find.text('Percent'), findsOneWidget);

    // Verify Members list
    expect(find.text('You'), findsWidgets);
    expect(find.text('Sheeda'), findsOneWidget);
    expect(find.text('Kaptaan'), findsOneWidget);
    expect(find.text('Hamza'), findsOneWidget);

    // Verify Actions
    expect(find.text('Attach receipt (auto-compressed)'), findsOneWidget);
    expect(find.text('Save expense'), findsOneWidget);
  });
}
