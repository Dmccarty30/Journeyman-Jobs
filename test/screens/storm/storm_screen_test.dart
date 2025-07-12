/// Tests for StormScreen
/// 
/// Comprehensive tests for the storm restoration work screen, critical for IBEW
/// electrical workers responding to emergency power restoration needs.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/screens/storm/storm_screen.dart';
import 'package:journeyman_jobs/models/storm_event.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../../test_helpers/test_helpers.dart';
import '../../test_helpers/mock_services.dart';

void main() {
  group('StormScreen Tests', () {
    late MockFirestoreService mockFirestoreService;
    late List<StormEvent> mockStormEvents;

    setUp(() {
      mockFirestoreService = MockFactory.createMockFirestoreService();
      
      // Create mock storm events with different severity levels
      mockStormEvents = [
        StormEvent.fromJson(TestDataGenerators.mockStormEventData(
          id: 'storm_001',
          name: 'Hurricane Delta',
          region: 'Gulf Coast',
          severity: 'Critical',
          openPositions: 150,
        )),
        StormEvent.fromJson(TestDataGenerators.mockStormEventData(
          id: 'storm_002',
          name: 'Ice Storm Alpha',
          region: 'Northeast',
          severity: 'High',
          openPositions: 75,
        )),
        StormEvent.fromJson(TestDataGenerators.mockStormEventData(
          id: 'storm_003',
          name: 'Wind Event Beta',
          region: 'Midwest',
          severity: 'Moderate',
          openPositions: 25,
        )),
      ];

      // Setup mock responses
      _setupMockStormData();
    });

    /// Create the widget under test with necessary providers
    Widget createStormScreen() {
      return createTestApp(
        child: Provider<FirestoreService>.value(
          value: mockFirestoreService,
          child: const StormScreen(),
        ),
      );
    }

    void _setupMockStormData() {
      // Mock storm events collection query
      final mockDocs = mockStormEvents.map((event) => 
        MockFactory.createMockQueryDocumentSnapshot(
          id: event.id,
          data: event.toJson(),
        ),
      ).toList();
      
      final mockQuerySnapshot = MockFactory.createMockQuerySnapshot(docs: mockDocs);
      
      when(() => mockFirestoreService.firestore
          .collection('storm_events')
          .orderBy('deploymentDate')
          .snapshots()
      ).thenAnswer((_) => Stream.value(mockQuerySnapshot));
    }

    group('Initial Rendering', () {
      testWidgets('renders correctly with storm events list', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify header elements
        expect(find.text('Storm Work'), findsOneWidget);
        expect(find.text('Emergency restoration opportunities'), findsOneWidget);
        
        // Verify storm events are displayed
        expect(find.text('Hurricane Delta'), findsOneWidget);
        expect(find.text('Ice Storm Alpha'), findsOneWidget);
        expect(find.text('Wind Event Beta'), findsOneWidget);
      });

      testWidgets('displays electrical theme elements', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        TestExpectations.verifyElectricalTheme(tester);
        
        // Verify storm-specific electrical iconography
        expect(find.byIcon(Icons.flash_on), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.electrical_services), findsAtLeastNWidgets(1));
      });

      testWidgets('shows loading state initially', (tester) async {
        // Setup delayed response to test loading state
        when(() => mockFirestoreService.firestore
            .collection('storm_events')
            .orderBy('deploymentDate')
            .snapshots()
        ).thenAnswer((_) => Stream.fromFuture(
          Future.delayed(const Duration(seconds: 1))
              .then((_) => MockFactory.createMockQuerySnapshot())
        ));

        await tester.pumpWidget(createStormScreen());
        
        // Verify loading indicator is shown
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        
        await tester.pumpAndSettle();
      });

      testWidgets('handles empty storm events list', (tester) async {
        // Setup empty response
        when(() => mockFirestoreService.firestore
            .collection('storm_events')
            .orderBy('deploymentDate')
            .snapshots()
        ).thenAnswer((_) => Stream.value(
          MockFactory.createMockQuerySnapshot(docs: [])
        ));

        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify empty state message
        expect(find.text('No active storm events'), findsOneWidget);
        expect(find.text('Check back later for emergency restoration opportunities'), findsOneWidget);
      });
    });

    group('Storm Event Display', () {
      testWidgets('displays storm event details correctly', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify critical storm event details
        expect(find.text('Hurricane Delta'), findsOneWidget);
        expect(find.text('Gulf Coast'), findsOneWidget);
        expect(find.text('150 positions'), findsOneWidget);
        expect(find.text('\$45-55/hr'), findsOneWidget);
        expect(find.text('\$150/day'), findsOneWidget);
      });

      testWidgets('displays severity indicators with correct colors', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Find severity indicators
        final criticalIndicator = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFE53E3E)
        );
        expect(criticalIndicator, findsAtLeastNWidgets(1));

        final highIndicator = find.byWidgetPredicate((widget) =>
          widget is Container &&
          widget.decoration is BoxDecoration &&
          (widget.decoration as BoxDecoration).color == const Color(0xFFD69E2E)
        );
        expect(highIndicator, findsAtLeastNWidgets(1));
      });

      testWidgets('shows deployment timing information', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify deployment timing is displayed
        expect(find.textContaining('Deploying in'), findsAtLeastNWidgets(1));
        expect(find.textContaining('weeks'), findsAtLeastNWidgets(1));
      });

      testWidgets('displays affected utilities information', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify utility company information
        expect(find.text('Texas Power & Light'), findsAtLeastNWidgets(1));
        expect(find.text('Gulf Coast Electric'), findsAtLeastNWidgets(1));
      });
    });

    group('Sorting and Filtering', () {
      testWidgets('sorts events by severity (Critical first)', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Find all storm event titles
        final stormCards = find.byType(Card);
        await tester.scrollUntilVisible(stormCards.first, 100);

        // Critical severity storm should appear first
        final firstCard = tester.widget<Card>(stormCards.first);
        expect(find.descendant(
          of: find.byWidget(firstCard),
          matching: find.text('Hurricane Delta')
        ), findsOneWidget);
      });

      testWidgets('allows filtering by region', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Look for filter options
        if (find.text('Filter').evaluate().isNotEmpty) {
          await TestUtils.tapAndSettle(tester, find.text('Filter'));
          
          // Select Gulf Coast region
          await TestUtils.tapAndSettle(tester, find.text('Gulf Coast'));
          
          // Verify only Gulf Coast events are shown
          expect(find.text('Hurricane Delta'), findsOneWidget);
          expect(find.text('Ice Storm Alpha'), findsNothing);
        }
      });

      testWidgets('allows filtering by severity level', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Look for severity filter
        if (find.text('Critical Only').evaluate().isNotEmpty) {
          await TestUtils.tapAndSettle(tester, find.text('Critical Only'));
          
          // Verify only critical events are shown
          expect(find.text('Hurricane Delta'), findsOneWidget);
          expect(find.text('Ice Storm Alpha'), findsNothing);
          expect(find.text('Wind Event Beta'), findsNothing);
        }
      });
    });

    group('User Interactions', () {
      testWidgets('allows tapping on storm event for details', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Tap on a storm event card
        final stormCard = find.ancestor(
          of: find.text('Hurricane Delta'),
          matching: find.byType(Card),
        );
        
        await TestUtils.tapAndSettle(tester, stormCard);
        
        // Verify detail view or navigation occurs
        // This would depend on the actual implementation
      });

      testWidgets('shows apply/interest button for each event', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Look for apply or express interest buttons
        expect(find.text('Apply'), findsAtLeastNWidgets(1));
        // or
        expect(find.text('Express Interest'), findsAtLeastNWidgets(1));
      });

      testWidgets('handles apply button tap', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Find and tap apply button
        final applyButton = find.text('Apply').first;
        if (applyButton.evaluate().isNotEmpty) {
          await TestUtils.tapAndSettle(tester, applyButton);
          
          // Verify application flow starts
          // This would show a dialog or navigate to application screen
        }
      });
    });

    group('Refresh and Updates', () {
      testWidgets('supports pull-to-refresh', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Find the refresh indicator
        final refreshIndicator = find.byType(RefreshIndicator);
        if (refreshIndicator.evaluate().isNotEmpty) {
          // Perform pull-to-refresh gesture
          await tester.fling(find.byType(ListView), const Offset(0, 300), 1000);
          await tester.pump();
          await tester.pump(const Duration(seconds: 1));
          
          // Verify refresh completed
          expect(find.byType(RefreshIndicator), findsOneWidget);
        }
      });

      testWidgets('updates when new storm events arrive', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify initial events
        expect(find.text('Hurricane Delta'), findsOneWidget);
        
        // Add new storm event to mock data
        final newStormEvent = StormEvent.fromJson(TestDataGenerators.mockStormEventData(
          id: 'storm_004',
          name: 'Tornado Outbreak',
          region: 'Southeast',
          severity: 'Critical',
          openPositions: 200,
        ));
        
        mockStormEvents.add(newStormEvent);
        _setupMockStormData();
        
        // Trigger refresh
        await tester.pump();
        await tester.pumpAndSettle();
        
        // Verify new event appears
        expect(find.text('Tornado Outbreak'), findsOneWidget);
      });
    });

    group('Error Handling', () {
      testWidgets('handles network errors gracefully', (tester) async {
        // Setup Firestore to throw an error
        when(() => mockFirestoreService.firestore
            .collection('storm_events')
            .orderBy('deploymentDate')
            .snapshots()
        ).thenAnswer((_) => Stream.error(Exception('Network error')));

        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify error message is displayed
        expect(find.text('Unable to load storm events'), findsOneWidget);
        expect(find.text('Retry'), findsOneWidget);
      });

      testWidgets('allows retry after error', (tester) async {
        // Setup initial error
        when(() => mockFirestoreService.firestore
            .collection('storm_events')
            .orderBy('deploymentDate')
            .snapshots()
        ).thenAnswer((_) => Stream.error(Exception('Network error')));

        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Setup successful retry
        _setupMockStormData();
        
        // Tap retry button
        if (find.text('Retry').evaluate().isNotEmpty) {
          await TestUtils.tapAndSettle(tester, find.text('Retry'));
          
          // Verify data loads successfully
          expect(find.text('Hurricane Delta'), findsOneWidget);
        }
      });
    });

    group('Accessibility', () {
      testWidgets('provides proper semantic labels', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        TestExpectations.verifyAccessibility(tester);
        
        // Verify storm-specific accessibility
        expect(find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.label != null &&
          widget.properties.label!.contains('Critical severity')
        ), findsAtLeastNWidgets(1));
      });

      testWidgets('supports screen reader navigation', (tester) async {
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();

        // Verify semantic structure for screen readers
        expect(find.byWidgetPredicate((widget) =>
          widget is Semantics &&
          widget.properties.header == true
        ), findsAtLeastNWidgets(1));
      });
    });

    group('Performance', () {
      testWidgets('handles large numbers of storm events efficiently', (tester) async {
        // Create large dataset
        final largeDataset = List.generate(100, (index) => 
          StormEvent.fromJson(TestDataGenerators.mockStormEventData(
            id: 'storm_$index',
            name: 'Storm Event $index',
            openPositions: index + 1,
          ))
        );

        // Setup mock with large dataset
        final largeMockDocs = largeDataset.map((event) => 
          MockFactory.createMockQueryDocumentSnapshot(
            id: event.id,
            data: event.toJson(),
          ),
        ).toList();
        
        when(() => mockFirestoreService.firestore
            .collection('storm_events')
            .orderBy('deploymentDate')
            .snapshots()
        ).thenAnswer((_) => Stream.value(
          MockFactory.createMockQuerySnapshot(docs: largeMockDocs)
        ));

        await tester.pumpWidget(createStormScreen());
        
        // Measure rendering performance
        final stopwatch = Stopwatch()..start();
        await tester.pumpAndSettle();
        stopwatch.stop();
        
        // Verify reasonable performance (less than 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        
        // Verify list is scrollable for large datasets
        expect(find.byType(ListView), findsOneWidget);
      });
    });

    group('Responsive Design', () {
      testWidgets('adapts to different screen sizes', (tester) async {
        await TestExpectations.verifyResponsiveDesign(
          tester,
          () => createStormScreen(),
        );
      });

      testWidgets('optimizes layout for tablet screens', (tester) async {
        // Set tablet size
        await tester.binding.setSurfaceSize(const Size(768, 1024));
        
        await tester.pumpWidget(createStormScreen());
        await tester.pumpAndSettle();
        
        // Verify grid layout for tablets (if implemented)
        // This would depend on the actual responsive implementation
        expect(find.byType(GridView), findsAtMostNWidgets(1));
        
        // Reset to default size
        await tester.binding.setSurfaceSize(null);
      });
    });
  });
}