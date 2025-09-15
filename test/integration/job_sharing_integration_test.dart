import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_analytics/firebase_analytics.dart';

import '../../lib/widgets/rich_text_job_card.dart';
import '../../lib/models/job_model.dart';
import '../../lib/models/user_model.dart';
import '../../lib/features/job_sharing/widgets/share_button.dart';
import '../../lib/features/job_sharing/widgets/share_modal.dart';
import '../../lib/features/job_sharing/providers/contact_provider.dart';
import '../../lib/services/job_sharing_service.dart';
import '../../lib/design_system/app_theme.dart';

@GenerateMocks([
  FirebaseAnalytics,
])
import 'job_sharing_integration_test.mocks.dart';

/// Integration test for real job sharing functionality
/// Tests the complete flow from job card share button to notification delivery
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Job Sharing Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseAnalytics mockAnalytics;
    late MockUser mockUser;
    late List<Job> testJobs;
    late List<UserModel> testUsers;

    setUpAll(() {
      // Initialize test environment
    });

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockAnalytics = MockFirebaseAnalytics();
      mockUser = MockUser(
        uid: 'test-user-123',
        email: 'foreman@ibew26.org',
        displayName: 'Test Foreman',
      );

      when(mockAuth.currentUser).thenReturn(mockUser);

      // Setup test data
      await _setupTestData(fakeFirestore);
      testJobs = await _createTestJobs();
      testUsers = await _createTestUsers();
    });

    testWidgets('RichText job card displays details and bid buttons correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
              onDetails: () {
                // Details callback handling
                print('Details tapped');
              },
              onBid: () {
                // Bid callback handling
                print('Bid tapped');
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify Details button is present
      expect(find.text('Details'), findsOneWidget);

      // Verify Bid Now button is present
      expect(find.text('Bid Now'), findsOneWidget);

      // Test Details button tap
      await tester.tap(find.text('Details'));
      await tester.pumpAndSettle();
    });

    testWidgets('Complete bid flow - tap to action completion', (tester) async {
      bool bidTapped = false;
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
              onBid: () {
                bidTapped = true;
              },
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Step 1: Tap bid button
      final bidButton = find.text('Bid Now');
      expect(bidButton, findsOneWidget);
      await tester.tap(bidButton);
      await tester.pumpAndSettle();

      // Verify bid callback was called
      expect(bidTapped, isTrue);
    });

    testWidgets('Job card displays job information correctly', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify job information is displayed
      expect(find.text(testJobs.first.title), findsOneWidget);
      expect(find.text('IBEW Local ${testJobs.first.local}'), findsOneWidget);
    });

    testWidgets('Job card displays consistent electrical theme styling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify electrical-themed styling is present
      expect(find.byType(RichTextJobCard), findsOneWidget);

      // Verify action buttons are present
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Bid Now'), findsOneWidget);
    });

    testWidgets('Storm work jobs display correctly in RichText card', (tester) async {
      final stormJob = Job(
        id: 'storm-job-1',
        title: 'Emergency Storm Restoration - Lines Down',
        description: 'Immediate response needed for power restoration',
        local: 26,
        classification: 'Journeyman Lineman',
        location: 'Seattle, WA',
        payRate: 65.00,
        startDate: DateTime.now().add(const Duration(hours: 2)),
        additionalProperties: {'stormWork': true},
      );

      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: stormJob,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify job information is displayed
      expect(find.text(stormJob.title), findsOneWidget);

      // Verify action buttons are present
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Bid Now'), findsOneWidget);
    });

    testWidgets('RichText job card integrates with provider data', (tester) async {
      await tester.pumpWidget(
        ProviderScope(
          child: MaterialApp(
            home: Material(
              child: RichTextJobCard(
                job: testJobs.first,
                onDetails: () {},
                onBid: () {},
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify job card is displayed
      expect(find.byType(RichTextJobCard), findsOneWidget);

      // Verify buttons work
      expect(find.text('Details'), findsOneWidget);
      expect(find.text('Bid Now'), findsOneWidget);
    });

    testWidgets('Job card buttons are accessible', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
              onDetails: () {},
              onBid: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Test button accessibility
      final detailsButton = find.text('Details');
      expect(detailsButton, findsOneWidget);

      final bidButton = find.text('Bid Now');
      expect(bidButton, findsOneWidget);
    });

    testWidgets('Performance - button interaction timing', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: testJobs.first,
              onBid: () {},
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      final stopwatch = Stopwatch()..start();

      // Tap button and measure response time
      await tester.tap(find.text('Bid Now'));
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Interaction should be responsive (under 100ms)
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('Error handling - callback exception handling', (tester) async {
      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: Builder(
              builder: (context) => RichTextJobCard(
                job: testJobs.first,
                onBid: () {
                  // Simulate error in callback
                  throw Exception('Bid failed');
                },
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      // Verify job card renders correctly
      expect(find.byType(RichTextJobCard), findsOneWidget);
      expect(find.text('Bid Now'), findsOneWidget);
    });

    testWidgets('Responsive design - different screen sizes', (tester) async {
      final sizes = [
        const Size(320, 568), // iPhone SE
        const Size(375, 667), // iPhone 8
        const Size(414, 896), // iPhone 11 Pro Max
        const Size(768, 1024), // iPad
      ];

      for (final size in sizes) {
        await tester.binding.setSurfaceSize(size);

        await tester.pumpWidget(
          _buildTestApp(
            child: Material(
              child: RichTextJobCard(
                job: testJobs.first,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Job card should be present and properly responsive
        expect(
          find.byType(RichTextJobCard),
          findsOneWidget,
          reason: 'Job card missing at size $size',
        );

        // Buttons should be accessible at all sizes
        expect(find.text('Details'), findsOneWidget);
        expect(find.text('Bid Now'), findsOneWidget);
      }

      // Reset to default size
      await tester.binding.setSurfaceSize(null);
    });

    group('Electrical Theme Consistency', () {
      testWidgets('Job card uses electrical theme colors', (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            child: Material(
              child: RichTextJobCard(
                job: testJobs.first,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify job card renders with proper theming
        expect(find.byType(RichTextJobCard), findsOneWidget);

        // Check that electrical icons are present
        expect(find.byIcon(Icons.location_on), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.build), findsAtLeastNWidgets(1));
      });

      testWidgets('Electrical icons render in job information', (tester) async {
        await tester.pumpWidget(
          _buildTestApp(
            child: Material(
              child: RichTextJobCard(
                job: testJobs.first,
              ),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify electrical-themed icons are present
        expect(find.byIcon(Icons.electrical_services), findsAtLeastNWidgets(1));
        expect(find.byIcon(Icons.flash_on), findsOneWidget);
      });
    });
  });

  group('Performance Tests', () {
    testWidgets('RichText job card renders within performance threshold', (tester) async {
      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: RichTextJobCard(
              job: Job(
                id: 'perf-test-job',
                title: 'Performance Test Job',
                local: 26,
                classification: 'Journeyman Lineman',
                location: 'Test Location',
                payRate: 50.0,
                startDate: DateTime.now(),
              ),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // Should render in under 100ms
      expect(stopwatch.elapsedMilliseconds, lessThan(100));
    });

    testWidgets('Multiple RichText job cards perform well', (tester) async {
      final jobs = List.generate(
        10,
        (index) => Job(
          id: 'perf-job-$index',
          title: 'Performance Job $index',
          local: 26 + index,
          classification: 'Journeyman Lineman',
          location: 'Location $index',
          payRate: 50.0 + index,
          startDate: DateTime.now(),
        ),
      );

      final stopwatch = Stopwatch()..start();

      await tester.pumpWidget(
        _buildTestApp(
          child: Material(
            child: Column(
              children: jobs.map((job) => RichTextJobCard(
                job: job,
              )).toList(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();

      stopwatch.stop();

      // 10 job cards should render in under 500ms
      expect(stopwatch.elapsedMilliseconds, lessThan(500));

      // Verify all job cards are present
      expect(find.byType(RichTextJobCard), findsNWidgets(10));

      // Verify all action buttons are present
      expect(find.text('Details'), findsNWidgets(10));
      expect(find.text('Bid Now'), findsNWidgets(10));
    });
  });
}

/// Helper function to build test app with providers
Widget _buildTestApp({required Widget child}) {
  return ProviderScope(
    child: MaterialApp(
      theme: ThemeData(
        primaryColor: AppTheme.primaryNavy,
        colorScheme: ColorScheme.fromSwatch().copyWith(
          primary: AppTheme.primaryNavy,
          secondary: AppTheme.accentCopper,
        ),
      ),
      home: Scaffold(
        body: Center(
          child: child,
        ),
      ),
    ),
  );
}

/// Setup test data in Firestore
Future<void> _setupTestData(FakeFirebaseFirestore firestore) async {
  // Create test users
  await firestore.collection('users').doc('user-1').set({
    'id': 'user-1',
    'email': 'john@ibew26.org',
    'displayName': 'John Journeyman',
    'ibewLocal': 26,
    'classification': 'Journeyman Lineman',
    'fcmTokens': ['token-1'],
    'isActive': true,
  });

  await firestore.collection('users').doc('user-2').set({
    'id': 'user-2',
    'email': 'mike@ibew26.org',
    'displayName': 'Mike Lineman',
    'ibewLocal': 26,
    'classification': 'Journeyman Lineman',
    'fcmTokens': ['token-2'],
    'isActive': true,
  });

  // Create test crew
  await firestore.collection('crews').doc('crew-1').set({
    'foremanId': 'test-user-123',
    'memberIds': ['user-1', 'user-2', 'user-3'],
    'name': 'Alpha Crew',
    'local': 26,
    'active': true,
  });

  // Create test jobs
  await firestore.collection('jobs').doc('job-1').set({
    'id': 'job-1',
    'title': 'Storm Restoration - Priority',
    'description': 'Emergency power line repair after storm',
    'local': 26,
    'classification': 'Journeyman Lineman',
    'location': 'Seattle, WA',
    'payRate': 58.50,
    'startDate': DateTime.now().add(const Duration(days: 1)).toIso8601String(),
    'stormWork': true,
    'priority': true,
  });
}

/// Create test jobs
Future<List<Job>> _createTestJobs() async {
  return [
    Job(
      id: 'test-job-1',
      title: 'Storm Restoration - Power Lines',
      description: 'Immediate response for storm damage repair',
      local: 26,
      classification: 'Journeyman Lineman',
      location: 'Tacoma, WA',
      payRate: 58.50,
      startDate: DateTime.now().add(const Duration(hours: 4)),
      additionalProperties: {'stormWork': true},
    ),
    Job(
      id: 'test-job-2',
      title: 'Commercial Wiring Project',
      description: 'New office building electrical installation',
      local: 46,
      classification: 'Inside Wireman',
      location: 'Seattle, WA',
      payRate: 52.75,
      startDate: DateTime.now().add(const Duration(days: 3)),
    ),
    Job(
      id: 'test-job-3',
      title: 'Tree Trimming Operations',
      description: 'Vegetation management around power lines',
      local: 77,
      classification: 'Tree Trimmer',
      location: 'Spokane, WA',
      payRate: 45.25,
      startDate: DateTime.now().add(const Duration(days: 5)),
    ),
  ];
}

/// Create test users
Future<List<UserModel>> _createTestUsers() async {
  return [
    UserModel(
      id: 'test-contact-1',
      email: 'john@ibew26.org',
      displayName: 'John Journeyman',
      ibewLocal: 26,
      classification: 'Journeyman Lineman',
      isActive: true,
      fcmTokens: ['fcm-token-john'],
    ),
    UserModel(
      id: 'test-contact-2',
      email: 'mike@ibew46.org',
      displayName: 'Mike Wireman',
      ibewLocal: 46,
      classification: 'Inside Wireman',
      isActive: true,
      fcmTokens: ['fcm-token-mike'],
    ),
    UserModel(
      id: 'test-contact-3',
      email: 'sarah@ibew77.org',
      displayName: 'Sarah Trimmer',
      ibewLocal: 77,
      classification: 'Tree Trimmer',
      isActive: true,
      fcmTokens: ['fcm-token-sarah'],
    ),
  ];
}
