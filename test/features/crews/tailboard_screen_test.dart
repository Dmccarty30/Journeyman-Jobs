import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:mocktail/mocktail.dart';

void main() {
  testWidgets('TailboardScreen renders no crew header when no crew is selected',
      (WidgetTester tester) async {
    // Create a simple test environment
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          selectedCrewProvider.overrideWithValue(null),
        ],
        child: const MaterialApp(
          home: TailboardScreen(),
        ),
      ),
    );

    // Verify no crew header is shown
    expect(find.text('Welcome to the Tailboard'), findsOneWidget);
    expect(find.text('Create or Join a Crew'), findsOneWidget);
    expect(find.byIcon(Icons.group_outlined), findsOneWidget);
  });

  testWidgets('TailboardScreen has all four tabs', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: TailboardScreen(),
        ),
      ),
    );

    // Verify all tabs are present
    expect(find.text('Feed'), findsOneWidget);
    expect(find.text('Jobs'), findsOneWidget);
    expect(find.text('Chat'), findsOneWidget);
    expect(find.text('Members'), findsOneWidget);
  });

  testWidgets('FeedTab renders feed items', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: FeedTab(),
        ),
      ),
    );

    // Verify feed items are rendered
    expect(find.text('[Username]'), findsWidgets);
    expect(find.text('Nice outdoor courts, solid concrete and good hoops for the neighborhood.'), findsWidgets);
  });

  testWidgets('JobsTab renders job cards', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: JobsTab(),
        ),
      ),
    );

    // Verify job cards are rendered
    expect(find.text('Local 1'), findsOneWidget);
    expect(find.text('Classification 1'), findsOneWidget);
    expect(find.text('View Details'), findsWidgets);
    expect(find.text('Bid now'), findsWidgets);
  });

  testWidgets('MembersTab renders member list', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: MaterialApp(
          home: MembersTab(),
        ),
      ),
    );

    // Verify member list is rendered
    expect(find.text('Total: 2'), findsOneWidget);
    expect(find.text('Foreman'), findsOneWidget);
  });
}
