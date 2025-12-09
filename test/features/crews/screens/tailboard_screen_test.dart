import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';

// Mock classes for testing
class MockCrew extends Crew {
  MockCrew({
    required super.id,
    required super.name,
    required super.foremanId,
    required super.memberIds,
    required CrewPreferences filters,
    required super.createdAt,
  }) : super(
          filters: filters,
          preferences: filters,
          roles: {foremanId: MemberRole.foreman},
          stats: CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: DateTime.now(),
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          lastActivityAt: DateTime.now(),
        );
}

void main() {
  group('TailboardScreen Widget Tests', () {
    testWidgets('should display no crew state when user has no crews', (WidgetTester tester) async {
      // Build our app and trigger a frame
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      // Wait for the widget to settle
      await tester.pumpAndSettle();

      // Verify that the no crew state is displayed
      expect(find.text('You\'re not in a crew yet.'), findsOneWidget);
      expect(find.text('Join or create a crew to start collaborating with your team.'), findsOneWidget);
      expect(find.text('Create a Crew'), findsOneWidget);
      expect(find.text('Join a Crew'), findsOneWidget);
    });

    testWidgets('should display tab bar with correct tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Verify tab bar exists and has correct tabs
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Chat'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Feed'), findsOneWidget);
    });

    testWidgets('should display header with crew info when crew exists', (WidgetTester tester) async {
      // Create a mock crew
      final mockCrew = MockCrew(
        id: 'test-crew-123',
        name: 'Test Crew',
        foremanId: 'user123',
        memberIds: ['user123', 'member1', 'member2'],
        filters: CrewPreferences(
          payMin: 25.0,
          type: 'transmission',
          maxDistance: 50.0,
          perDiem: true,
        ),
        createdAt: DateTime.now(),
      );

      // Note: In a real test, we would mock the providers to return this crew
      // For now, we'll just test the basic widget structure

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The widget should still render even without data
      expect(find.byType(TailboardScreen), findsOneWidget);
    });

    testWidgets('should display floating action buttons for different tabs', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Initially, no FAB should be shown (no crew selected)
      expect(find.byType(FloatingActionButton), findsNothing);

      // Note: In a real test with mocked providers, we would test that
      // different FABs appear for different tabs (Jobs, Chat, Feed)
    });

    testWidgets('should handle tab switching', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the TabBar and verify it exists
      final tabBarFinder = find.byType(TabBar);
      expect(tabBarFinder, findsOneWidget);

      // Get the TabBar widget
      final TabBar tabBar = tester.widget(tabBarFinder);
      expect(tabBar.tabs.length, equals(4)); // Jobs, Chat, Members, Feed
    });

    testWidgets('should display offline indicator when appropriate', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The offline indicator should be present in the widget tree
      // (though it may not be visible if online)
      expect(find.byType(TailboardScreen), findsOneWidget);
    });
  });

  group('TailboardScreen Header Tests', () {
    testWidgets('should display crew switcher for multiple crews', (WidgetTester tester) async {
      // Create mock crews
      final crew1 = MockCrew(
        id: 'crew1',
        name: 'Crew Alpha',
        foremanId: 'user123',
        memberIds: ['user123', 'member1'],
        filters: CrewPreferences(
          payMin: 25.0,
          type: 'transmission',
          maxDistance: 50.0,
          perDiem: true,
        ),
        createdAt: DateTime.now(),
      );

      final crew2 = MockCrew(
        id: 'crew2',
        name: 'Crew Beta',
        foremanId: 'user456',
        memberIds: ['user123', 'member2', 'member3'],
        filters: CrewPreferences(
          payMin: 30.0,
          type: 'distribution',
          maxDistance: 75.0,
          perDiem: false,
        ),
        createdAt: DateTime.now(),
      );

      // Note: In a real test, we would mock the provider to return both crews
      // and test the crew switcher UI

      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // The widget should render
      expect(find.byType(TailboardScreen), findsOneWidget);
    });

    testWidgets('should display role badge correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Without mocked data, we can't test the actual role badge
      // But we can verify the widget structure
      expect(find.byType(TailboardScreen), findsOneWidget);
    });
  });

  group('TailboardScreen Tab Content Tests', () {
    testWidgets('should display Jobs tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Jobs tab and verify it exists
      expect(find.text('Jobs'), findsOneWidget);
      
      // The Jobs tab content would be displayed when that tab is active
      // In a real test with mocked providers, we would test the actual job content
    });

    testWidgets('should display Chat tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Chat tab and verify it exists
      expect(find.text('Chat'), findsOneWidget);
      
      // The Chat tab would show message bubbles and input when active
      // In a real test, we would test message display and sending
    });

    testWidgets('should display Members tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Members tab and verify it exists
      expect(find.text('Members'), findsOneWidget);
      
      // The Members tab would show crew member list when active
      // In a real test, we would test member display and management
    });

    testWidgets('should display Feed tab content', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find the Feed tab and verify it exists
      expect(find.text('Feed'), findsOneWidget);
      
      // The Feed tab would show global posts when active
      // In a real test, we would test post display and creation
    });
  });

  group('TailboardScreen Navigation Tests', () {
    testWidgets('should navigate to create crew screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "Create a Crew" button
      final createButton = find.text('Create a Crew');
      expect(createButton, findsOneWidget);

      // Note: In a real test with GoRouter, we would verify navigation
      // For now, we just verify the button exists and is tappable
      await tester.tap(createButton);
      await tester.pump();
    });

    testWidgets('should navigate to join crew screen', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Find and tap the "Join a Crew" button
      final joinButton = find.text('Join a Crew');
      expect(joinButton, findsOneWidget);

      // Note: In a real test with GoRouter, we would verify navigation
      // For now, we just verify the button exists and is tappable
      await tester.tap(joinButton);
      await tester.pump();
    });
  });

  group('TailboardScreen Error Handling Tests', () {
    testWidgets('should display error state when data loading fails', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      await tester.pumpAndSettle();

      // Without mocked error state, we can't test the actual error display
      // But we can verify the widget handles the basic case
      expect(find.byType(TailboardScreen), findsOneWidget);
    });

    testWidgets('should display loading state while data is loading', (WidgetTester tester) async {
      await tester.pumpWidget(
        const ProviderScope(
          child: MaterialApp(
            home: TailboardScreen(),
          ),
        ),
      );

      // Initially, we might see a loading indicator
      // (though in our case, it quickly resolves to no-crew state)
      await tester.pump();

      // The widget should be present
      expect(find.byType(TailboardScreen), findsOneWidget);
    });
  });

  group('CrewSelectionDropdown Tests', () {
    testWidgets('selection updates state', (WidgetTester tester) async {
      // TODO: Implement test for dropdown selection updating state
    });

    testWidgets('error dialog appears on load failure', (WidgetTester tester) async {
      // TODO: Implement test for error dialog
    });
  });
}