import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/crew_visibility.dart';

// Generate mocks
@GenerateMocks([CrewService])
import 'crew_name_display_test.mocks.dart';

void main() {
  group('CrewScreen - Crew Name Display Tests', () {
    late MockCrewService mockCrewService;
    late Crew testCrew;

    setUp(() {
      mockCrewService = MockCrewService();
      testCrew = Crew(
        id: 'test-crew-123',
        name: 'Test Crew Alpha',
        foremanId: 'foreman-123',
        memberIds: ['foreman-123'],
        preferences: const CrewPreferences(
          jobTypes: ['Journeyman Lineman'],
          constructionTypes: ['Commercial'],
          autoShareEnabled: false,
        ),
        stats: const CrewStats(
          totalJobsShared: 0,
          totalApplications: 0,
          applicationRate: 0.0,
          averageMatchScore: 0.0,
          successfulPlacements: 0,
          responseTime: 0.0,
          jobTypeBreakdown: {},
          lastActivityAt: null,
          matchScores: [],
          successRate: 0.0,
        ),
        isActive: true,
        createdAt: DateTime.now(),
        roles: {'foreman-123': MemberRole.foreman},
        memberCount: 1,
        lastActivityAt: DateTime.now(),
        visibility: CrewVisibility.private,
        maxMembers: 50,
        inviteCodeCounter: 0,
      );
    });

    testWidgets('CrewScreen displays loading state initially', (WidgetTester tester) async {
      // Arrange
      when(mockCrewService.getCrew(any)).thenAnswer((_) async {
        // Simulate network delay
        await Future.delayed(const Duration(milliseconds: 100));
        return testCrew;
      });

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: CrewScreen(
            crewId: 'test-crew-123',
            crewService: mockCrewService,
          ),
        ),
      );

      // Assert - Should show loading state initially
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('CrewScreen displays crew name after successful fetch', (WidgetTester tester) async {
      // Arrange
      when(mockCrewService.getCrew('test-crew-123')).thenAnswer((_) async {
        return testCrew;
      });

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: CrewScreen(
            crewId: 'test-crew-123',
            crewService: mockCrewService,
          ),
        ),
      );

      // Wait for async operation to complete
      await tester.pumpAndSettle();

      // Assert - Should display the actual crew name
      expect(find.text('Test Crew Alpha'), findsOneWidget);
      expect(find.text('Loading...'), findsNothing);
    });

    testWidgets('CrewScreen displays loading state when crew fetch fails', (WidgetTester tester) async {
      // Arrange
      when(mockCrewService.getCrew('test-crew-123')).thenThrow(Exception('Network error'));

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: CrewScreen(
            crewId: 'test-crew-123',
            crewService: mockCrewService,
          ),
        ),
      );

      // Wait for async operation to complete
      await tester.pumpAndSettle();

      // Assert - Should fall back to loading state when fetch fails
      expect(find.text('Loading...'), findsOneWidget);
    });

    testWidgets('JobsContent displays crew name in header', (WidgetTester tester) async {
      // Build widget with crew name
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JobsContent(crewName: 'Test Crew Beta'),
          ),
        ),
      );

      // Assert - Should display the crew name in Jobs header
      expect(find.text('Jobs for Test Crew Beta'), findsOneWidget);
    });

    testWidgets('JobsContent displays loading state when crewName is null', (WidgetTester tester) async {
      // Build widget without crew name
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const JobsContent(crewName: null),
          ),
        ),
      );

      // Assert - Should display loading state
      expect(find.text('Jobs for Loading...'), findsOneWidget);
    });

    testWidgets('CrewName fetch method handles success correctly', (WidgetTester tester) async {
      // Arrange
      when(mockCrewService.getCrew('test-crew-123')).thenAnswer((_) async {
        return testCrew;
      });

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: CrewScreen(
            crewId: 'test-crew-123',
            crewService: mockCrewService,
          ),
        ),
      );

      // Wait for fetch to complete
      await tester.pumpAndSettle();

      // Verify the service was called with correct crew ID
      verify(mockCrewService.getCrew('test-crew-123')).called(1);

      // Assert crew name is displayed
      expect(find.text('Test Crew Alpha'), findsOneWidget);
    });

    testWidgets('CrewName fetch method handles mounted check correctly', (WidgetTester tester) async {
      // Arrange - Return crew but simulate widget being unmounted
      when(mockCrewService.getCrew('test-crew-123')).thenAnswer((_) async {
        // Simulate delay that might occur after widget is unmounted
        await Future.delayed(const Duration(milliseconds: 50));
        return testCrew;
      });

      // Build widget
      await tester.pumpWidget(
        MaterialApp(
          home: CrewScreen(
            crewId: 'test-crew-123',
            crewService: mockCrewService,
          ),
        ),
      );

      // Immediately unmount the widget (simulate navigation away)
      await tester.pumpWidget(Container());

      // Wait for async operation to complete
      await tester.pumpAndSettle();

      // Should not throw error even though widget was unmounted
      expect(find.byType(CrewScreen), findsNothing);
    });
  });

  group('JobsContent - Standalone Tests', () {
    testWidgets('JobsContent handles empty crew name gracefully', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const JobsContent(crewName: ''),
          ),
        ),
      );

      expect(find.text('Jobs for '), findsOneWidget);
    });

    testWidgets('JobsContent displays crew name with special characters', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: const JobsContent(crewName: 'Crew-123_Alpha & Beta'),
          ),
        ),
      );

      expect(find.text('Jobs for Crew-123_Alpha & Beta'), findsOneWidget);
    });
  });
}
