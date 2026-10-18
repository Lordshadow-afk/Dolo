import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/features/home/presentation/widgets/glass_triad_card.dart';

void main() {
  testWidgets('GlassTriadCard renders 3 columns with exact values and labels', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: GlassTriadCard(
            totalOwed: 9100,
            totalOwe: 4850,
            settledCount: 12,
          ),
        ),
      ),
    );

    // Verify Labels
    expect(find.text('OWED'), findsOneWidget);
    expect(find.text('OWE'), findsOneWidget);
    expect(find.text('SETTLED'), findsOneWidget);

    // Verify Values (with tabular formatting)
    expect(find.text('9,100'), findsOneWidget);
    expect(find.text('4,850'), findsOneWidget);
    expect(find.text('12'), findsOneWidget);
  });
}
