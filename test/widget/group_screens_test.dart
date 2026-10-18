import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:dolo/features/groups/presentation/screens/group_detail_screen.dart';
import 'package:dolo/features/groups/presentation/screens/new_group_screen.dart';

void main() {
  testWidgets('GroupDetailScreen renders cockpit, simplified debt banner, tabs and actions', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: GroupDetailScreen(groupId: 'hostel_gang'),
        ),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Members
    expect(find.text('Hostel Gang'), findsOneWidget);
    expect(find.text('You, Sheeda, Kaptaan, Hamza'), findsOneWidget);

    // Verify Net Standing Card
    expect(find.text('YOU OWE'), findsOneWidget);

    // Verify Module 13 Simplified Debt Banner
    expect(find.text('Simplified: 2 payments settle the whole group.'), findsOneWidget);

    // Verify Tabs
    expect(find.text('Expenses'), findsOneWidget);
    expect(find.text('Balances'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);

    // Verify CTAs
    expect(find.text('Clear all dues, Rs 1,850'), findsOneWidget);
    expect(find.text('Remind on WhatsApp'), findsOneWidget);
  });

  testWidgets('NewGroupScreen renders group name input, nicknames, shadow badge and CTA', (WidgetTester tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: NewGroupScreen(),
      ),
    );

    await tester.pumpAndSettle();

    // Verify Title & Subtitle
    expect(find.text('New group'), findsOneWidget);
    expect(find.text('Name it and set nicknames.'), findsOneWidget);

    // Verify Labels
    expect(find.text('GROUP NAME'), findsOneWidget);
    expect(find.text('MEMBERS AND NICKNAMES'), findsOneWidget);

    // Verify Nicknames
    expect(find.text('Ali'), findsOneWidget);
    expect(find.text('Sheeda'), findsWidgets);
    expect(find.text('Kaptaan'), findsOneWidget);

    // Verify Module 18 Shadow Member Tag
    expect(find.text('Shadow'), findsOneWidget);

    // Verify CTAs
    expect(find.text('+ Invite via WhatsApp'), findsOneWidget);
    expect(find.text('Create group'), findsOneWidget);
  });
}
