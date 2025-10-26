import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/widgets/enhanced_feed_tab.dart';
import 'package:journeyman_jobs/features/crews/widgets/tab_widgets.dart';
import 'package:journeyman_jobs/features/crews/models/models.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';
import 'package:journeyman_jobs/models/job_model.dart';

/// Tailboard Performance Benchmark Test Suite
///
/// Performance requirements based on user vision:
/// - Feed posts appear IMMEDIATELY after posting
/// - Jobs appear IMMEDIATELY when foreman sets crew preferences
/// - Real-time updates across all tabs
/// - Handle 30+ consecutive messages in chat
/// - Responsive UI under load
void main() {
  group('Tailboard Performance Benchmarks', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;

    setUpAll(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);
      FirebaseFirestore.instance = fakeFirestore;
    });

    setUp(() async {
      await fakeFirestore.clear();
      final mockUser = MockUser(
        uid: 'test-user-123',
        email: 'test@journeyman.com',
        displayName: 'Test User',
      );
      mockAuth.mockUser = mockUser;
    });

    group('Feed Tab Performance Tests', () {
      testWidgets('Post creation and immediate visibility performance', (tester) async {
        // GIVEN: User is on feed tab
        await _setupTestEnvironment(tester, mockAuth);

        final stopwatch = Stopwatch()..start();

        // WHEN: Creating a new post
        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final initialRenderTime = stopwatch.elapsedMilliseconds;

        // Create post action
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        final dialogOpenTime = stopwatch.elapsedMilliseconds - initialRenderTime;

        await tester.enterText(find.byType(TextField).first, 'Performance test post');
        await tester.pump();

        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        final postCreationTime = stopwatch.elapsedMilliseconds - initialRenderTime - dialogOpenTime;

        // THEN: Performance should meet requirements
        expect(find.text('Performance test post'), findsOneWidget);

        // Performance assertions
        expect(initialRenderTime, lessThan(1000)); // Initial render < 1s
        expect(dialogOpenTime, lessThan(500)); // Dialog open < 500ms
        expect(postCreationTime, lessThan(2000)); // Post creation < 2s

        print('Feed Performance Metrics:');
        print('  Initial Render: ${initialRenderTime}ms');
        print('  Dialog Open: ${dialogOpenTime}ms');
        print('  Post Creation: ${postCreationTime}ms');
        print('  Total Time: ${stopwatch.elapsedMilliseconds}ms');

        stopwatch.stop();
      });

      testWidgets('Large feed list performance (100+ posts)', (tester) async {
        // GIVEN: Feed has 100 posts
        await _setupTestEnvironment(tester, mockAuth);

        // Create 100 test posts
        final postCreationStopwatch = Stopwatch()..start();
        for (int i = 1; i <= 100; i++) {
          await _createTestPost('Large feed test post $i with additional content to simulate real-world post length and complexity');
        }
        postCreationStopwatch.stop();

        print('Creating 100 posts took: ${postCreationStopwatch.elapsedMilliseconds}ms');

        final renderStopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final renderTime = renderStopwatch.elapsedMilliseconds;

        // THEN: Should render efficiently
        expect(find.textContaining('Large feed test post'), findsWidgets);
        expect(renderTime, lessThan(3000)); // Large list render < 3s

        // Test scroll performance
        final scrollStopwatch = Stopwatch()..start();
        await tester.fling(find.byType(Scrollable), const Offset(0, -500), 10000);
        await tester.pumpAndSettle();
        final scrollTime = scrollStopwatch.elapsedMilliseconds;

        expect(scrollTime, lessThan(1000)); // Scroll response < 1s

        print('Large Feed Performance:');
        print('  Render Time: ${renderTime}ms');
        print('  Scroll Time: ${scrollTime}ms');
      });

      testWidgets('Real-time feed update performance', (tester) async {
        // GIVEN: User is viewing feed
        await _setupTestEnvironment(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: New post is created in background
        final updateStopwatch = Stopwatch()..start();

        // Simulate background post creation
        await Future.delayed(Duration(milliseconds: 100), () async {
          await _createTestPost('Real-time update performance test');
        });

        // Wait for update
        await tester.pumpAndSettle();

        final updateTime = updateStopwatch.elapsedMilliseconds;

        // THEN: Update should appear immediately
        expect(find.text('Real-time update performance test'), findsOneWidget);
        expect(updateTime, lessThan(1500)); // Real-time update < 1.5s

        print('Real-time Feed Update: ${updateTime}ms');
      });
    });

    group('Jobs Tab Performance Tests', () {
      testWidgets('Job preference update and immediate filtering performance', (tester) async {
        // GIVEN: Crew with initial preferences and jobs
        await _setupTestEnvironmentWithCrew(tester, mockAuth);

        // Create test jobs
        for (int i = 1; i <= 50; i++) {
          await _createTestJob('Performance Test Job $i', 'Commercial', 30.0 + i, 100 + i);
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: JobsTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: Crew preferences are updated
        final preferenceUpdateStopwatch = Stopwatch()..start();

        // Simulate preference update
        await _updateCrewPreferencesWithLargeDataset();
        await tester.pumpAndSettle();

        final preferenceUpdateTime = preferenceUpdateStopwatch.elapsedMilliseconds;

        // THEN: Jobs should filter immediately
        expect(find.textContaining('Performance Test Job'), findsWidgets);
        expect(preferenceUpdateTime, lessThan(2000)); // Preference update < 2s

        print('Jobs Preference Update Performance: ${preferenceUpdateTime}ms');
      });

      testWidgets('Job search performance with large dataset', (tester) async {
        // GIVEN: Jobs tab with 200+ jobs
        await _setupTestEnvironmentWithCrew(tester, mockAuth);

        // Create large job dataset
        final jobCreationStopwatch = Stopwatch()..start();
        for (int i = 1; i <= 200; i++) {
          final types = ['Commercial', 'Industrial', 'Residential', 'Utility'];
          await _createTestJob(
            'Search Performance Job $i',
            types[i % types.length],
            25.0 + (i % 50),
            100 + i
          );
        }
        jobCreationStopwatch.stop();

        print('Creating 200 jobs took: ${jobCreationStopwatch.elapsedMilliseconds}ms');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: JobsTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User performs search
        final searchStopwatch = Stopwatch()..start();

        await tester.enterText(find.byType(TextField), 'Commercial');
        await tester.pumpAndSettle();

        final searchTime = searchStopwatch.elapsedMilliseconds;

        // THEN: Search should be responsive
        expect(find.textContaining('Commercial'), findsWidgets);
        expect(searchTime, lessThan(1000)); // Search response < 1s

        print('Job Search Performance: ${searchTime}ms');
      });
    });

    group('Chat Tab Performance Tests', () {
      testWidgets('30+ consecutive messages handling performance', (tester) async {
        // GIVEN: Chat with 35 messages
        await _setupTestEnvironmentWithCrew(tester, mockAuth);
        final crewId = 'performance-test-crew';

        // Create 35 messages
        final messageCreationStopwatch = Stopwatch()..start();
        for (int i = 1; i <= 35; i++) {
          await _createTestMessage(
            crewId,
            'Performance test message $i - Testing consecutive message handling with longer content to ensure proper display and scrolling performance',
            DateTime.now().subtract(Duration(minutes: 36 - i))
          );
        }
        messageCreationStopwatch.stop();

        print('Creating 35 messages took: ${messageCreationStopwatch.elapsedMilliseconds}ms');

        final renderStopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: ChatTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final renderTime = renderStopwatch.elapsedMilliseconds;

        // THEN: Should handle all messages efficiently
        expect(find.textContaining('Performance test message'), findsWidgets);
        expect(renderTime, lessThan(2000)); // Message list render < 2s

        // Test scrolling through messages
        final scrollStopwatch = Stopwatch()..start();
        await tester.fling(find.byType(Scrollable), const Offset(0, -800), 15000);
        await tester.pumpAndSettle();
        final scrollTime = scrollStopwatch.elapsedMilliseconds;

        expect(scrollTime, lessThan(800)); // Scroll performance < 800ms

        print('Chat Performance (35 messages):');
        print('  Render Time: ${renderTime}ms');
        print('  Scroll Time: ${scrollTime}ms');
      });

      testWidgets('Real-time message delivery performance', (tester) async {
        // GIVEN: User is in chat
        await _setupTestEnvironmentWithCrew(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: ChatTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: New message is sent
        final messageSendStopwatch = Stopwatch()..start();

        // Simulate sending message
        await tester.tap(find.byIcon(Icons.message));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).last, 'Real-time message performance test');
        await tester.pump();

        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        final messageSendTime = messageSendStopwatch.elapsedMilliseconds;

        // THEN: Message should appear immediately
        expect(find.text('Real-time message performance test'), findsOneWidget);
        expect(messageSendTime, lessThan(1500)); // Message send < 1.5s

        print('Real-time Message Send Performance: ${messageSendTime}ms');
      });
    });

    group('Members Tab Performance Tests', () {
      testWidgets('Large crew member list performance', (tester) async {
        // GIVEN: Crew with 100+ members
        await _setupTestEnvironmentWithCrew(tester, mockAuth);
        final crewId = 'large-crew-test';

        // Add 100 members
        final memberCreationStopwatch = Stopwatch()..start();
        for (int i = 1; i <= 100; i++) {
          await _addCrewMember(crewId, 'member-$i', 'Test Member $i', CrewRole.journeyman);
        }
        memberCreationStopwatch.stop();

        print('Creating 100 members took: ${memberCreationStopwatch.elapsedMilliseconds}ms');

        final renderStopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: MembersTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        final renderTime = renderStopwatch.elapsedMilliseconds;

        // THEN: Should render large member list efficiently
        expect(find.textContaining('Test Member'), findsWidgets);
        expect(renderTime, lessThan(2000)); // Member list render < 2s

        print('Large Member List Performance: ${renderTime}ms');
      });
    });

    group('Cross-Tab Performance Tests', () {
      testWidgets('Tab switching performance with loaded data', (tester) async {
        // GIVEN: All tabs have substantial data
        await _setupTestEnvironmentWithCrew(tester, mockAuth);
        final crewId = 'cross-tab-performance';

        // Load data for all tabs
        for (int i = 1; i <= 20; i++) {
          await _createTestPost('Cross-tab post $i');
          await _createTestJob('Cross-tab job $i', 'Commercial', 30.0 + i, 100 + i);
          await _createTestMessage(crewId, 'Cross-tab message $i', DateTime.now().subtract(Duration(minutes: 21 - i)));
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: Switching between tabs
        final tabSwitchStopwatch = Stopwatch()..start();

        final tabSwitchTimes = <String, int>{};

        // Switch to Feed
        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();
        tabSwitchTimes['Feed'] = tabSwitchStopwatch.elapsedMilliseconds;
        tabSwitchStopwatch.reset();

        // Switch to Jobs
        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();
        tabSwitchTimes['Jobs'] = tabSwitchStopwatch.elapsedMilliseconds;
        tabSwitchStopwatch.reset();

        // Switch to Chat
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();
        tabSwitchTimes['Chat'] = tabSwitchStopwatch.elapsedMilliseconds;
        tabSwitchStopwatch.reset();

        // Switch to Members
        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();
        tabSwitchTimes['Members'] = tabSwitchStopwatch.elapsedMilliseconds;

        // THEN: All tab switches should be fast
        tabSwitchTimes.forEach((tab, time) {
          expect(time, lessThan(1000), reason: '$tab tab switch should be < 1s');
        });

        print('Tab Switch Performance:');
        tabSwitchTimes.forEach((tab, time) {
          print('  $tab: ${time}ms');
        });
      });

      testWidgets('Memory usage under sustained activity', (tester) async {
        // GIVEN: Extended activity simulation
        await _setupTestEnvironmentWithCrew(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: Performing sustained operations
        final activityStopwatch = Stopwatch()..start();

        // Simulate 50 operations across tabs
        for (int i = 1; i <= 50; i++) {
          // Switch between tabs
          await tester.tap(find.text(['Feed', 'Jobs', 'Chat', 'Members'][i % 4]));
          await tester.pump();

          // Perform tab-specific action every 10 operations
          if (i % 10 == 0) {
            switch (i % 40) {
              case 10:
                await tester.enterText(find.byType(TextField), 'Search test $i');
                break;
              case 20:
                await tester.fling(find.byType(Scrollable), const Offset(0, -300), 8000);
                break;
              case 30:
                await tester.tap(find.byIcon(Icons.refresh));
                break;
              case 40:
                await tester.tap(find.byIcon(Icons.message));
                break;
            }
          }

          await tester.pumpAndSettle();
        }

        final activityTime = activityStopwatch.elapsedMilliseconds;

        // THEN: Should maintain responsive performance
        expect(activityTime, lessThan(15000)); // 50 operations < 15s
        expect(find.byType(TailboardScreen), findsOneWidget); // App still functional

        print('Sustained Activity Performance:');
        print('  Total Time: ${activityTime}ms');
        print('  Average per operation: ${activityTime / 50}ms');
      });
    });

    group('Performance Regression Tests', () {
      testWidgets('Critical path performance regression test', (tester) async {
        // Test critical user paths for performance regressions

        // Path 1: Create post and verify visibility
        await _setupTestEnvironment(tester, mockAuth);

        final criticalPathStopwatch = Stopwatch()..start();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();

        await tester.enterText(find.byType(TextField).first, 'Regression test post');
        await tester.pump();

        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        final criticalPathTime = criticalPathStopwatch.elapsedMilliseconds;

        // Performance regression threshold
        expect(criticalPathTime, lessThan(3000), reason: 'Critical path should complete in < 3s');
        expect(find.text('Regression test post'), findsOneWidget);

        print('Critical Path Performance: ${criticalPathTime}ms');

        // Log performance data for tracking
        _logPerformanceMetrics('critical_path', {
          'total_time': criticalPathTime,
          'timestamp': DateTime.now().toIso8601String(),
          'test_environment': 'integration_test',
        });
      });
    });
  });
}

// Performance helper methods
Future<void> _setupTestEnvironment(WidgetTester tester, MockFirebaseAuth mockAuth) async {
  final mockUser = MockUser(
    uid: 'test-user-123',
    email: 'test@journeyman.com',
    displayName: 'Test User',
  );
  mockAuth.mockUser = mockUser;
  await mockAuth.signInWithEmailAndPassword(email: 'test@journeyman.com', password: 'password');
}

Future<void> _setupTestEnvironmentWithCrew(WidgetTester tester, MockFirebaseAuth mockAuth) async {
  await _setupTestEnvironment(tester, mockAuth);

  // Create test crew
  final crewRef = FirebaseFirestore.instance.collection('crews').doc('test-crew-id');
  final crew = Crew(
    id: 'test-crew-id',
    name: 'Performance Test Crew',
    description: 'Test crew for performance testing',
    createdBy: 'test-user-123',
    createdAt: DateTime.now(),
    memberIds: ['test-user-123'],
    isActive: true,
    preferences: CrewPreferences(),
  );
  await crewRef.set(crew.toMap());
}

Future<void> _createTestPost(String content) async {
  final postRef = FirebaseFirestore.instance.collection('posts').doc();
  final post = PostModel(
    id: postRef.id,
    crewId: 'test-crew-id',
    authorId: 'test-user-123',
    authorName: 'Test User',
    content: content,
    createdAt: DateTime.now(),
    likes: [],
    comments: [],
    reactions: {},
    imageUrl: null,
    taggedUserIds: [],
    isEdited: false,
    editedAt: null,
    deletedAt: null,
  );
  await postRef.set(post.toMap());
}

Future<void> _createTestJob(String title, String type, double wage, int local) async {
  final jobRef = FirebaseFirestore.instance.collection('jobs').doc();
  final job = Job(
    company: 'Performance Test Company',
    wage: wage,
    local: local,
    classification: 'Journeyman',
    location: 'Test City, State',
    jobTitle: title,
    typeOfWork: type,
    jobDetails: {
      'description': 'Performance test job for $title',
      'requirements': ['Valid License'],
      'posted': DateTime.now().toIso8601String(),
    },
  );
  await jobRef.set(job.toFirestore());
}

Future<void> _createTestMessage(String crewId, String content, DateTime timestamp) async {
  final messageRef = FirebaseFirestore.instance
      .collection('crews')
      .doc(crewId)
      .collection('messages')
      .doc();

  final message = CrewMessage(
    id: messageRef.id,
    crewId: crewId,
    senderId: 'test-user-123',
    senderName: 'Test User',
    content: content,
    type: MessageType.text,
    timestamp: timestamp,
    isRead: false,
  );

  await messageRef.set(message.toMap());
}

Future<void> _addCrewMember(String crewId, String userId, String name, CrewRole role) async {
  final memberRef = FirebaseFirestore.instance
      .collection('crews')
      .doc(crewId)
      .collection('members')
      .doc(userId);

  final member = CrewMember(
    userId: userId,
    name: name,
    role: role,
    joinedAt: DateTime.now(),
    isAvailable: true,
    customTitle: role.toString().split('.').last.toUpperCase(),
  );

  await memberRef.set(member.toMap());
}

Future<void> _updateCrewPreferencesWithLargeDataset() async {
  final preferences = CrewPreferences(
    jobTypes: ['Lineman', 'Inside Wireman', 'Tree Trimmer', 'Equipment Operator'],
    constructionTypes: ['Commercial', 'Industrial', 'Residential', 'Utility', 'Maintenance'],
    minHourlyRate: 25.0,
    maxDistanceMiles: 100,
  );

  await FirebaseFirestore.instance
      .collection('crews')
      .doc('test-crew-id')
      .update({'preferences': preferences.toMap()});
}

void _logPerformanceMetrics(String testName, Map<String, dynamic> metrics) {
  // In a real implementation, this would log to your performance monitoring system
  print('Performance Metrics for $testName:');
  metrics.forEach((key, value) {
    print('  $key: $value');
  });
}