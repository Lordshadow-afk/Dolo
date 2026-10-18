import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/features/khata_1on1/presentation/screens/khata_detail_screen.dart';

void main() {
  testWidgets('KhataDetailScreen renders cockpit, net card, timeline and action CTAs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: KhataDetailScreen(peerId: 'sheeda'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Peer Name & Privacy Badge
    expect(find.text('Sheeda'), findsWidgets);
    expect(find.text('Private khata, on this phone only'), findsOneWidget);

    // Verify Net Standing
    expect(find.text('SHEEDA OWES YOU'), findsOneWidget);

    // Verify Top Action CTAs
    expect(find.text('I lent'), findsOneWidget);
    expect(find.text('I borrowed'), findsOneWidget);

    // Verify Sub-navigation Pills
    expect(find.text('Open'), findsOneWidget);
    expect(find.text('Cleared'), findsOneWidget);

    // Verify Sticky Bottom CTAs
    expect(find.text('Settle up'), findsOneWidget);
    expect(find.text('Remind'), findsOneWidget);
  });
}
