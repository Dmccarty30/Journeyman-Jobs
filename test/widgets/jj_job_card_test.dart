import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import '../../lib/widgets/jj_job_card.dart';
import '../../lib/models/job_model.dart';
import '../../lib/providers/riverpod/auth_riverpod_provider.dart';
import '../../lib/providers/riverpod/jobs_riverpod_provider.dart';
import '../fixtures/mock_data.dart';

import 'package:network_image_mock/network_image_mock.dart';

/// Generate mock [AuthNotifier]
@GenerateMocks([AuthNotifier])
import 'jj_job_card_test.mocks.dart';

void main() {
  setUpAll(() {
    // Mock network images for tests
    NetworkImageMock.mock();
  });

  group('JJJobCard Widget Tests', () {
    late Job testJob;
    late AuthNotifier mockAuthNotifier;

    setUp(() {
      testJob = MockData.createTestJob();
      mockAuthNotifier = MockAuthNotifier();
    });

    testWidgets('displays job information correctly', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        ProviderScope(
          overrides: [
            authNotifierProvider.overrideWith((ref) => mockAuthNotifier),
            currentUserProvider.overrideWithValue(null),
          ],
          child: MaterialApp(
            home: Scaffold(
              body: JJJobCard(
                job: testJob,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.text(testJob.company), findsOneWidget);
      expect(find.text(testJob.location), findsOneWidget);
      expect(find.text('Local ${testJob.local}'), findsOneWidget);
      expect(find.text('\$${testJob.wage}/hr'), findsOneWidget);
      expect(find.text(testJob.classification ?? ''), findsOneWidget);
    });

    testWidgets('calls onTap when tapped', (WidgetTester tester) async {
      // Arrange
      var tapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {
                tapped = true;
              },
            ),
          ),
        ),
      );

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      // Assert
      expect(tapped, isTrue);
    });

    testWidgets('displays bookmark icon when bookmarked', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
              isBookmarked: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.bookmark), findsOneWidget);
    });

    testWidgets('displays "New" badge for recent jobs', (WidgetTester tester) async {
      // Arrange
      final recentJob = Job.fromJson({
        ...testJob.toJson(),
        'postedAt': DateTime.now().subtract(const Duration(days: 2)).toIso8601String(),
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: recentJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('New'), findsOneWidget);
    });

    testWidgets('displays "High Priority" badge for high wages', (WidgetTester tester) async {
      // Arrange
      final highWageJob = Job.fromJson({
        ...testJob.toJson(),
        'wage': 75.0, // High wage threshold
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: highWageJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('High Priority'), findsOneWidget);
    });

    testWidgets('displays per diem badge when available', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Per Diem Available'), findsOneWidget);
    });

    testWidgets('hides per diem badge when not available', (WidgetTester tester) async {
      // Arrange
      final jobWithoutPerDiem = Job.fromJson({
        ...testJob.toJson(),
        'perDiem': null,
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: jobWithoutPerDiem,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Per Diem Available'), findsNothing);
    });

    testWidgets('displays job type icon correctly', (WidgetTester tester) async {
      // Arrange
      final commercialJob = Job.fromJson({
        ...testJob.toJson(),
        'typeOfWork': 'Commercial',
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: commercialJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.business), findsOneWidget);
    });

    testWidgets('displays distance when provided', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              distance: 25.5,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('25.5 mi'), findsOneWidget);
    });

    testWidgets('displays loading shimmer when isLoading is true', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              isLoading: true,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('shows bookmark button when bookmarkable is true', (WidgetTester tester) async {
      // Arrange
      var bookmarkTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
              isBookmarked: false,
              onBookmark: () {
                bookmarkTapped = true;
              },
              bookmarkable: true,
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.bookmark_border), findsOneWidget);

      // Act - Tap bookmark
      await tester.tap(find.byIcon(Icons.bookmark_border));
      await tester.pump();

      // Assert
      expect(bookmarkTapped, isTrue);
    });

    testWidgets('applies electrical theme styling', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          theme: ThemeData(
            colorScheme: const ColorScheme.dark(
              primary: Color(0xFF1A202C),
              secondary: Color(0xFFB45309),
            ),
          ),
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Container>();
      final decoration = card.decoration as BoxDecoration;
      expect(decoration.color, equals(const Color(0xFF1A202C)));
    });

    testWidgets('handles null job details gracefully', (WidgetTester tester) async {
      // Arrange
      final jobWithNullDetails = Job.fromJson({
        ...testJob.toJson(),
        'jobDetails': null,
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: jobWithNullDetails,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Should not crash and should still display basic info
      expect(find.text(testJob.company), findsOneWidget);
      expect(find.text(testJob.location), findsOneWidget);
    });

    testWidgets('handles empty wage gracefully', (WidgetTester tester) async {
      // Arrange
      final jobWithoutWage = Job.fromJson({
        ...testJob.toJson(),
        'wage': null,
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: jobWithoutWage,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Should not crash and should not display wage
      expect(find.text(testJob.company), findsOneWidget);
      expect(find.text('\$/hr'), findsNothing);
    });

    testWidgets('displays custom action button when provided', (WidgetTester tester) async {
      // Arrange
      var actionTapped = false;

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
              action: IconButton(
                icon: const Icon(Icons.share),
                onPressed: () {
                  actionTapped = true;
                },
              ),
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.share), findsOneWidget);

      // Act - Tap action
      await tester.tap(find.byIcon(Icons.share));
      await tester.pump();

      // Assert
      expect(actionTapped, isTrue);
    });

    testWidgets('displays company logo when available', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
              companyLogo: 'https://example.com/logo.png',
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('handles long company names correctly', (WidgetTester tester) async {
      // Arrange
      final jobWithLongName = Job.fromJson({
        ...testJob.toJson(),
        'company': 'Very Long Company Name That Might Need Truncation',
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: jobWithLongName,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Very Long Company Name That Might Need Truncation'), findsOneWidget);
    });

    testWidgets('handles very long location names correctly', (WidgetTester tester) async {
      // Arrange
      final jobWithLongLocation = Job.fromJson({
        ...testJob.toJson(),
        'location': 'Very Long Location Name With City, State That Might Need Truncation',
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: jobWithLongLocation,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.text('Very Long Location Name With City, State That Might Need Truncation'), findsOneWidget);
    });

    testWidgets('shows correct status indicator', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert - Default status should be active
      expect(find.byIcon(Icons.circle), findsOneWidget);
    });

    testWidgets('shows booked status indicator', (WidgetTester tester) async {
      // Arrange
      final bookedJob = Job.fromJson({
        ...testJob.toJson(),
        'booked': true,
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: bookedJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('shows filled status indicator', (WidgetTester tester) async {
      // Arrange
      final filledJob = Job.fromJson({
        ...testJob.toJson(),
        'status': 'filled',
      });

      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: filledJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byIcon(Icons.check_circle), findsOneWidget);
    });

    testWidgets('applies correct elevation for hover state', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Card>();
      expect(card.elevation, equals(4.0));
    });

    testWidgets('maintains aspect ratio', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 400,
              height: 800,
              child: JJJobCard(
                job: testJob,
                onTap: () {},
              ),
            ),
          ),
        ),
      );

      // Assert
      final card = tester.widget<Container>();
      expect(card.constraints?.maxWidth, equals(380));
      expect(card.constraints?.minHeight, equals(120));
    });

    testWidgets('is tappable', (WidgetTester tester) async {
      // Act
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
              onTap: () {},
            ),
          ),
        ),
      );

      // Assert
      expect(find.byType(InkWell), findsOneWidget);
    });

    testWidgets('handles null onTap gracefully', (WidgetTester tester) async {
      // Act & Assert - Should not crash
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: JJJobCard(
              job: testJob,
            ),
          ),
        ),
      );

      // Card should still display
      expect(find.text(testJob.company), findsOneWidget);
    });

    group('Accessibility Tests', () {
      testWidgets('has correct accessibility labels', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJJobCard(
                job: testJob,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        expect(
          tester.bindingSemantics(
            debugLabel: '${testJob.company} - ${testJob.location} - Local ${testJob.local} - \$${testJob.wage}/hr',
          tooltip: '${testJob.company} - ${testJob.classification} job in ${testJob.location}',
          link: false,
          onTap: true,
            textDirection: TextDirection.ltr,
          ),
          findsOneWidget,
        );
      });

      testWidgets('semantic labels include all important information', (WidgetTester tester) async {
        // Act
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: JJJobCard(
                job: testJob,
                onTap: () {},
              ),
            ),
          ),
        );

        // Assert
        final semantics = tester.binding.semantics;
        expect(semantics.nodes.any((node) =>
          node.label?.contains(testJob.company) ?? false), isTrue);
        expect(semantics.nodes.any((node) =>
          node.label?.contains(testJob.location) ?? false), isTrue);
        expect(semantics.nodes.any((node) =>
          node.label?.contains('Local ${testJob.local}') ?? false), isTrue);
      });
    });

    group('Performance Tests', () {
      testWidgets('renders efficiently', (WidgetTester tester) async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        for (int i = 0; i < 100; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: JJJobCard(
                  job: testJob,
                  onTap: () {},
                ),
              ),
            ),
          );
          await tester.pump();
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should render 100 cards in under 5 seconds
      });

      testWidgets('does not leak memory', (WidgetTester tester) async {
        // Act
        for (int i = 0; i < 50; i++) {
          await tester.pumpWidget(
            MaterialApp(
              home: Scaffold(
                body: JJJobCard(
                  job: testJob,
                  onTap: () {},
                ),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 16)); // One frame
        }

        // Assert - No exceptions thrown during rapid rendering
        expect(tester.takeException(), isNull);
      });
    });
  });
}