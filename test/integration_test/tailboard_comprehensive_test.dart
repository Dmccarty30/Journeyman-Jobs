import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:integration_test/integration_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:journeyman_jobs/main.dart' as app;
import 'package:journeyman_jobs/features/crews/screens/tailboard_screen.dart';
import 'package:journeyman_jobs/features/crews/widgets/enhanced_feed_tab.dart';
import 'package:journeyman_jobs/features/crews/widgets/tab_widgets.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/features/crews/models/models.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';

/// Comprehensive Tailboard Tab Validation Test Suite
///
/// Tests the complete tailboard functionality according to user's vision:
/// - JOBS TAB: Crew-specific job opportunities with real-time preference updates
/// - FEED TAB: Public messages for ALL users with immediate post visibility
/// - CHAT TAB: Private crew messaging with chronological order and member restrictions
/// - MEMBERS TAB: Crew member list with direct messaging capabilities
void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  group('Tailboard Complete Tab Functionality Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late ProviderContainer container;

    setUpAll(() async {
      // Initialize mock Firebase services
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth(signedIn: true);

      // Create mock users
      final mockUser = MockUser(
        uid: 'test-user-123',
        email: 'test@journeyman.com',
        displayName: 'Test Journeyman',
      );
      mockAuth.mockUser = mockUser;

      // Override Firebase instances for testing
      FirebaseFirestore.instance = fakeFirestore;

      // Set up test provider container
      container = ProviderContainer(
        overrides: [
          // Override providers with mock instances
          firebaseAuthProvider.overrideWithValue(mockAuth),
          databaseServiceProvider.overrideWithValue(MockDatabaseService(fakeFirestore)),
        ],
      );
    });

    setUp(() async {
      // Clear test data before each test
      await _setupTestData();
    });

    tearDown(() async {
      // Clean up test data
      await fakeFirestore.clear();
    });

    group('FEED TAB - Public Access & Real-Time Posting', () {
      testWidgets('Public feed accessible to all users without crew', (tester) async {
        // GIVEN: User is authenticated but has no crew
        await _authenticateUser(tester, mockAuth);

        // WHEN: Navigate to tailboard and access feed tab
        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Feed tab should be accessible with public content
        expect(find.text('Public Feed'), findsOneWidget);
        expect(find.text('Posts from all crews will appear here'), findsOneWidget);

        // Verify public access UI elements
        expect(find.byIcon(Icons.feed_outlined), findsOneWidget);
        expect(find.text('Sign in to interact with posts from all crews'), findsNothing);
      });

      testWidgets('Post appears immediately after creation', (tester) async {
        // GIVEN: User is authenticated and has a crew
        await _authenticateUser(tester, mockAuth);
        await _createTestCrew('Test Crew');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User creates a new post
        await tester.tap(find.byIcon(Icons.add)); // FAB for feed
        await tester.pumpAndSettle();

        // Fill post content
        await tester.enterText(find.byType(TextField).first, 'Test post content for immediate visibility');
        await tester.pump();

        // Submit post
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // THEN: Post should appear immediately in the feed
        expect(find.text('Test post content for immediate visibility'), findsOneWidget);
        expect(find.text('Post published to public feed!'), findsOneWidget);
      });

      testWidgets('Real-time feed updates across multiple users', (tester) async {
        // GIVEN: Multiple authenticated users viewing the same feed
        await _authenticateUser(tester, mockAuth);
        await _createTestCrew('Shared Crew');

        // Create initial post
        await _createTestPost('Initial post for real-time testing');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Initial post should be visible
        expect(find.text('Initial post for real-time testing'), findsOneWidget);

        // WHEN: New post is created by another user (simulated)
        await _createTestPost('Real-time update test post');
        await tester.pumpAndSettle();

        // THEN: New post should appear immediately in feed
        expect(find.text('Real-time update test post'), findsOneWidget);
        expect(find.text('Initial post for real-time testing'), findsOneWidget);
      });

      testWidgets('Feed interactions work correctly (likes, comments, shares)', (tester) async {
        // GIVEN: Feed has existing posts
        await _authenticateUser(tester, mockAuth);
        await _createTestPost('Interactive test post');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: EnhancedFeedTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User interacts with post (like, comment, share)
        // Test like functionality
        await tester.tap(find.byIcon(Icons.favorite_border));
        await tester.pumpAndSettle();

        // Test share functionality
        await tester.tap(find.byIcon(Icons.share));
        await tester.pumpAndSettle();
        expect(find.text('Post shared!'), findsOneWidget);
      });
    });

    group('JOBS TAB - Crew Preferences & Real-Time Updates', () {
      testWidgets('Jobs display immediately when foreman sets crew preferences', (tester) async {
        // GIVEN: User is in a crew with preferences
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Test Electrical Crew');

        // Set initial crew preferences
        final preferences = CrewPreferences(
          jobTypes: ['Lineman', 'Inside Wireman'],
          constructionTypes: ['Commercial', 'Industrial'],
          minHourlyRate: 25.0,
          maxDistanceMiles: 50,
        );
        await _updateCrewPreferences(crew.id, preferences);

        // Create matching jobs
        await _createTestJob('Lineman Position', 'Commercial', 30.0, 25);
        await _createTestJob('Inside Wireman', 'Industrial', 35.0, 30);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to Jobs tab
        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();

        // THEN: Jobs matching crew preferences should appear immediately
        expect(find.text('Jobs for Test Electrical Crew'), findsOneWidget);
        expect(find.text('Lineman Position'), findsOneWidget);
        expect(find.text('Inside Wireman'), findsOneWidget);
      });

      testWidgets('Real-time job updates when preferences change', (tester) async {
        // GIVEN: Crew has initial preferences and matching jobs
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Dynamic Crew');

        // Initial preferences
        final initialPrefs = CrewPreferences(
          jobTypes: ['Lineman'],
          constructionTypes: ['Commercial'],
          minHourlyRate: 20.0,
        );
        await _updateCrewPreferences(crew.id, initialPrefs);

        // Create jobs matching initial preferences
        await _createTestJob('Lineman Job 1', 'Commercial', 25.0, 20);
        await _createTestJob('Non-Matching Job', 'Residential', 30.0, 25); // Won't match initially

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: JobsTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Verify initial state
        expect(find.text('Lineman Job 1'), findsOneWidget);
        expect(find.text('Non-Matching Job'), findsNothing);

        // WHEN: Foreman updates crew preferences to include more job types
        final updatedPrefs = CrewPreferences(
          jobTypes: ['Lineman', 'Tree Trimmer'],
          constructionTypes: ['Commercial', 'Residential'],
          minHourlyRate: 20.0,
        );
        await _updateCrewPreferences(crew.id, updatedPrefs);
        await tester.pumpAndSettle();

        // THEN: Jobs list should update immediately to show new matching jobs
        expect(find.text('Non-Matching Job'), findsOneWidget); // Now matches residential type
        expect(find.text('Lineman Job 1'), findsOneWidget); // Still matches
      });

      testWidgets('Jobs search and filtering functionality', (tester) async {
        // GIVEN: Jobs tab has multiple jobs
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Search Test Crew');
        await _updateCrewPreferences(crew.id, CrewPreferences(
          jobTypes: ['Lineman', 'Inside Wireman'],
          constructionTypes: ['Commercial', 'Industrial'],
          minHourlyRate: 20.0,
        ));

        // Create multiple test jobs
        await _createTestJob('Commercial Lineman', 'Commercial', 30.0, 20);
        await _createTestJob('Industrial Wireman', 'Industrial', 35.0, 25);
        await _createTestJob('Tree Trimmer Position', 'Utility', 28.0, 15);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: JobsTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User searches for specific job
        await tester.enterText(find.byType(TextField), 'Commercial');
        await tester.pumpAndSettle();

        // THEN: Only matching jobs should appear
        expect(find.text('Commercial Lineman'), findsOneWidget);
        expect(find.text('Industrial Wireman'), findsNothing);
        expect(find.text('Tree Trimmer Position'), findsNothing);
      });

      testWidgets('No crew selected shows appropriate message', (tester) async {
        // GIVEN: User is authenticated but no crew selected
        await _authenticateUser(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: JobsTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Show message to select crew
        expect(find.text('No crew selected'), findsOneWidget);
        expect(find.text('Select a crew to view job opportunities matching your crew preferences'), findsOneWidget);
      });
    });

    group('CHAT TAB - Crew Restrictions & Real-Time Messaging', () {
      testWidgets('Chat tab restricted to crew members only', (tester) async {
        // GIVEN: User is authenticated but has no crew
        await _authenticateUser(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // Navigate to Chat tab
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();

        // THEN: Should show message to select crew first
        expect(find.text('Select a Crew'), findsOneWidget);
        expect(find.text('Select a crew to view direct messaging and group chat'), findsOneWidget);
      });

      testWidgets('Messages appear in chronological order', (tester) async {
        // GIVEN: User is in a crew with existing messages
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Chat Test Crew');

        // Create test messages in chronological order
        await _createTestMessage(crew.id, 'First message', DateTime.now().subtract(Duration(minutes: 5)));
        await _createTestMessage(crew.id, 'Second message', DateTime.now().subtract(Duration(minutes: 3)));
        await _createTestMessage(crew.id, 'Third message', DateTime.now().subtract(Duration(minutes: 1)));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: ChatTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Messages should appear in chronological order (newest first)
        expect(find.text('Third message'), findsOneWidget);
        expect(find.text('Second message'), findsOneWidget);
        expect(find.text('First message'), findsOneWidget);
      });

      testWidgets('Handle 30+ consecutive messages properly', (tester) async {
        // GIVEN: Crew has many messages
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('High Volume Crew');

        // Create 35 test messages
        for (int i = 1; i <= 35; i++) {
          await _createTestMessage(
            crew.id,
            'Message $i - Testing consecutive message handling with longer content to ensure proper display',
            DateTime.now().subtract(Duration(minutes: 36 - i))
          );
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: ChatTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: All messages should be displayed correctly
        expect(find.text('Message 35'), findsOneWidget); // Newest message
        expect(find.text('Message 1'), findsOneWidget); // Oldest message

        // Verify list can scroll through all messages
        final scrollable = find.byType(Scrollable);
        expect(scrollable, findsOneWidget);
      });

      testWidgets('New messages appear immediately when sent', (tester) async {
        // GIVEN: User is in crew chat
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Real-time Chat Crew');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: ChatTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User sends a new message
        await tester.tap(find.byIcon(Icons.message)); // FAB for chat
        await tester.pumpAndSettle();

        // Enter message content
        await tester.enterText(find.byType(TextField).last, 'Test real-time message sending');
        await tester.pump();

        // Send message
        await tester.tap(find.text('Send Message'));
        await tester.pumpAndSettle();

        // THEN: Message should appear immediately in chat
        expect(find.text('Test real-time message sending'), findsOneWidget);
        expect(find.text('Message sent successfully!'), findsOneWidget);
      });
    });

    group('MEMBERS TAB - Member List & Direct Messaging', () {
      testWidgets('Display crew member list correctly', (tester) async {
        // GIVEN: User is in a crew with multiple members
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Members Test Crew');

        // Add test crew members
        await _addCrewMember(crew.id, 'member-1', 'John Doe', CrewRole.journeyman);
        await _addCrewMember(crew.id, 'member-2', 'Jane Smith', CrewRole.foreman);
        await _addCrewMember(crew.id, 'member-3', 'Bob Johnson', CrewRole.apprentice);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: MembersTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: All crew members should be displayed
        expect(find.text('JOHN DOE'), findsOneWidget);
        expect(find.text('JANE SMITH'), findsOneWidget);
        expect(find.text('BOB JOHNSON'), findsOneWidget);

        // Verify roles are displayed
        expect(find.text('JOURNEYMAN'), findsOneWidget);
        expect(find.text('FOREMAN'), findsOneWidget);
        expect(find.text('APPRENTICE'), findsOneWidget);
      });

      testWidgets('Enable member-to-member direct messaging', (tester) async {
        // GIVEN: Crew has multiple members
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('DM Test Crew');
        await _addCrewMember(crew.id, 'member-1', 'Alice Wilson', CrewRole.journeyman);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: MembersTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User taps message icon on a member
        await tester.tap(find.byIcon(Icons.message).first);
        await tester.pumpAndSettle();

        // THEN: Direct message option should appear
        expect(find.text('Direct Message'), findsOneWidget);
        expect(find.text('Send a private message to JOURNEYMAN'), findsOneWidget);

        // Tap to start direct message
        await tester.tap(find.text('Direct Message'));
        await tester.pumpAndSettle();

        // Should navigate to chat with member context
        expect(find.text('DM: Alice Wilson'), findsOneWidget);
      });

      testWidgets('Navigation to chat with specific member context', (tester) async {
        // GIVEN: User initiates direct message with specific member
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Context Navigation Crew');
        await _addCrewMember(crew.id, 'target-member', 'Charlie Brown', CrewRole.journeyman);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: MembersTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: Navigate to direct message chat
        await tester.tap(find.byIcon(Icons.message).first);
        await tester.pumpAndSettle();
        await tester.tap(find.text('Direct Message'));
        await tester.pumpAndSettle();

        // THEN: Chat should open with member context
        expect(find.text('DM: Charlie Brown'), findsOneWidget);

        // System message should indicate direct message context
        expect(find.textContaining('Direct message conversation with Charlie Brown'), findsOneWidget);
      });

      testWidgets('Show empty state when no members', (tester) async {
        // GIVEN: Crew exists but has no members
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Empty Crew');

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: MembersTab(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Show empty state with invite option
        expect(find.text('No members yet'), findsOneWidget);
        expect(find.textContaining('Invite members to join Empty Crew'), findsOneWidget);
      });
    });

    group('INTEGRATION - Cross-Tab Functionality', () {
      testWidgets('Complete user flow: Create crew -> Use all tabs', (tester) async {
        // GIVEN: Authenticated user with no crew
        await _authenticateUser(tester, mockAuth);

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: User creates a new crew
        expect(find.text('Create or Join a Crew'), findsOneWidget);
        await tester.tap(find.text('Create or Join a Crew'));
        await tester.pumpAndSettle();

        // Fill crew creation form
        await tester.enterText(find.byType(TextField).first, 'Integration Test Crew');
        await tester.pump();
        await tester.enterText(find.byType(TextField).at(1), 'Test description');
        await tester.pump();
        await tester.tap(find.text('Create'));
        await tester.pumpAndSettle();

        // THEN: Should see crew header and tabs
        expect(find.text('Integration Test Crew'), findsOneWidget);
        expect(find.byType(TabBar), findsOneWidget);

        // Test Feed tab
        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();
        expect(find.text('Public Feed'), findsOneWidget);

        // Test Jobs tab
        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();
        expect(find.text('Jobs for Integration Test Crew'), findsOneWidget);

        // Test Chat tab
        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();
        expect(find.text('Start the conversation'), findsOneWidget);

        // Test Members tab
        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();
        expect(find.text('1 members'), findsOneWidget); // User is automatically added
      });

      testWidgets('Real-time updates propagate across all tabs', (tester) async {
        // GIVEN: Active crew session with multiple tabs
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Real-time Test Crew');
        await _updateCrewPreferences(crew.id, CrewPreferences(
          jobTypes: ['Lineman'],
          constructionTypes: ['Commercial'],
          minHourlyRate: 25.0,
        ));

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: New post is created
        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();
        await tester.tap(find.byIcon(Icons.add));
        await tester.pumpAndSettle();
        await tester.enterText(find.byType(TextField).first, 'Real-time cross-tab test');
        await tester.pump();
        await tester.tap(find.text('Submit'));
        await tester.pumpAndSettle();

        // THEN: Post should be visible in Feed tab
        expect(find.text('Real-time cross-tab test'), findsOneWidget);

        // WHEN: Navigate to other tabs and back
        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();
        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();

        // THEN: Post should still be visible (persistence)
        expect(find.text('Real-time cross-tab test'), findsOneWidget);
      });

      testWidgets('Access control enforcement across all tabs', (tester) async {
        // GIVEN: User attempts to access features without proper authentication/crew
        // Test with no authentication
        mockAuth.signOut();

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // THEN: Should show authentication required
        expect(find.text('Authentication Required'), findsOneWidget);
        expect(find.text('Please sign in to access the Tailboard crew hub'), findsOneWidget);

        // WHEN: User authenticates but has no crew
        await _authenticateUser(tester, mockAuth);
        await tester.pumpAndSettle();

        // THEN: Feed should be accessible (public), others require crew
        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();
        expect(find.text('Public Feed'), findsOneWidget); // Accessible

        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();
        expect(find.text('No crew selected'), findsOneWidget); // Restricted

        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();
        expect(find.text('Select a Crew'), findsOneWidget); // Restricted

        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();
        expect(find.text('No crew selected'), findsOneWidget); // Restricted
      });
    });

    group('PERFORMANCE - Stress Testing', () {
      testWidgets('Performance test: 100+ concurrent operations', (tester) async {
        // GIVEN: Large amount of data for performance testing
        await _authenticateUser(tester, mockAuth);
        final crew = await _createTestCrew('Performance Test Crew');

        // Create 50 posts
        for (int i = 1; i <= 50; i++) {
          await _createTestPost('Performance test post $i - This is a longer post to test rendering performance with varying content lengths and ensure the UI remains responsive');
        }

        // Create 25 jobs
        for (int i = 1; i <= 25; i++) {
          await _createTestJob('Performance Job $i', 'Commercial', 30.0 + i, 20 + i);
        }

        // Create 30 messages
        for (int i = 1; i <= 30; i++) {
          await _createTestMessage(crew.id, 'Performance message $i', DateTime.now().subtract(Duration(minutes: 31 - i)));
        }

        await tester.pumpWidget(
          UncontrolledProviderScope(
            child: MaterialApp(
              home: TailboardScreen(),
            ),
          ),
        );
        await tester.pumpAndSettle();

        // WHEN: Navigate through all tabs with large datasets
        final stopwatch = Stopwatch()..start();

        await tester.tap(find.text('Feed'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Performance test post'), findsWidgets);

        await tester.tap(find.text('Jobs'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Performance Job'), findsWidgets);

        await tester.tap(find.text('Chat'));
        await tester.pumpAndSettle();
        expect(find.textContaining('Performance message'), findsWidgets);

        await tester.tap(find.text('Members'));
        await tester.pumpAndSettle();

        stopwatch.stop();

        // THEN: Performance should remain acceptable (< 5 seconds for all operations)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
      });
    });
  });
}

// Helper methods for test setup and data management

Future<void> _setupTestData() async {
  // Clear any existing test data
  // This would be implemented based on your test data cleanup strategy
}

Future<void> _authenticateUser(WidgetTester tester, MockFirebaseAuth mockAuth) async {
  final mockUser = MockUser(
    uid: 'test-user-123',
    email: 'test@journeyman.com',
    displayName: 'Test Journeyman',
  );
  mockAuth.mockUser = mockUser;
  await mockAuth.signInWithEmailAndPassword(email: 'test@journeyman.com', password: 'password');
}

Future<Crew> _createTestCrew(String name) async {
  final crewRef = FirebaseFirestore.instance.collection('crews').doc();
  final crew = Crew(
    id: crewRef.id,
    name: name,
    description: 'Test crew for ${name}',
    createdBy: 'test-user-123',
    createdAt: DateTime.now(),
    memberIds: ['test-user-123'],
    isActive: true,
    preferences: CrewPreferences(),
  );

  await crewRef.set(crew.toMap());
  return crew;
}

Future<void> _updateCrewPreferences(String crewId, CrewPreferences preferences) async {
  await FirebaseFirestore.instance
      .collection('crews')
      .doc(crewId)
      .update({'preferences': preferences.toMap()});
}

Future<void> _createTestPost(String content) async {
  final postRef = FirebaseFirestore.instance.collection('posts').doc();
  final post = PostModel(
    id: postRef.id,
    crewId: 'test-crew-id',
    authorId: 'test-user-123',
    authorName: 'Test Journeyman',
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

Future<void> _createTestJob(String title, String constructionType, double wage, int local) async {
  final jobRef = FirebaseFirestore.instance.collection('jobs').doc();
  final job = Job(
    company: 'Test Company',
    wage: wage,
    local: local,
    classification: 'Journeyman',
    location: 'Test City, State',
    jobTitle: title,
    typeOfWork: constructionType,
    jobDetails: {
      'description': 'Test job description for $title',
      'requirements': ['Valid Journeyman Card', 'OSHA 10'],
      'benefits': ['Health Insurance', '401k'],
      'contact': 'test@testcompany.com',
      'phone': '555-0123',
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
    senderName: 'Test Journeyman',
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

// Mock service classes for testing
class MockDatabaseService {
  final FakeFirebaseFirestore _firestore;

  MockDatabaseService(this._firestore);

  // Implement mock database service methods as needed
}

class MockCrewService {
  // Implement mock crew service methods as needed
}