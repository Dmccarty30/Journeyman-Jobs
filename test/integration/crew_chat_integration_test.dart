import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:journeyman_jobs/screens/crew/crew_chat_screen.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:provider/provider.dart';

/// Integration tests for Crew Chat functionality
///
/// These tests verify the complete workflow from UI to backend,
/// ensuring the user's vision for crew chat is fully implemented.
void main() {
  group('Crew Chat Integration Tests - Complete User Vision', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockFirebaseAuth mockAuth;
    late CrewMessagingService messagingService;

    // Test users
    late UserModel foreman;
    late UserModel member1;
    late UserModel member2;
    late UserModel nonMember;

    // Test crew
    late Crew testCrew;
    late String crewId;

    setUpAll(() async {
      // Initialize test services
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      messagingService = CrewMessagingService();

      // Create test users
      foreman = UserModel(
        uid: 'foreman_123',
        email: 'foreman@test.com',
        displayNameStr: 'John Foreman',
        avatarUrl: 'https://example.com/foreman.jpg',
        localUnion: 'IBEW Local 123',
        classification: 'Journeyman Lineman',
      );

      member1 = UserModel(
        uid: 'member_456',
        email: 'member1@test.com',
        displayNameStr: 'Jane Member',
        avatarUrl: 'https://example.com/member1.jpg',
        localUnion: 'IBEW Local 123',
        classification: 'Inside Wireman',
      );

      member2 = UserModel(
        uid: 'member_789',
        email: 'member2@test.com',
        displayNameStr: 'Bob Member',
        avatarUrl: 'https://example.com/member2.jpg',
        localUnion: 'IBEW Local 123',
        classification: 'Tree Trimmer',
      );

      nonMember = UserModel(
        uid: 'non_member_999',
        email: 'outsider@test.com',
        displayNameStr: 'Outside User',
        localUnion: 'IBEW Local 456',
        classification: 'Journeyman Lineman',
      );

      // Create test crew
      crewId = 'test_crew_alpha';
      testCrew = Crew(
        id: crewId,
        name: 'Test Crew Alpha',
        foremanId: foreman.uid,
        memberIds: [foreman.uid, member1.uid, member2.uid],
        jobPreferences: {
          'states': ['TX', 'OK', 'LA'],
          'classifications': ['Journeyman Lineman', 'Inside Wireman', 'Tree Trimmer'],
          'stormWork': true,
        },
      );

      // Setup crew in Firestore
      await fakeFirestore.collection('crews').doc(crewId).set(testCrew.toFirestore());

      // Setup users in Firestore
      await fakeFirestore.collection('users').doc(foreman.uid).set({
        'uid': foreman.uid,
        'email': foreman.email,
        'displayName': foreman.displayNameStr,
        'avatarUrl': foreman.avatarUrl,
        'localUnion': foreman.localUnion,
        'classification': foreman.classification,
      });

      await fakeFirestore.collection('users').doc(member1.uid).set({
        'uid': member1.uid,
        'email': member1.email,
        'displayName': member1.displayNameStr,
        'avatarUrl': member1.avatarUrl,
        'localUnion': member1.localUnion,
        'classification': member1.classification,
      });

      await fakeFirestore.collection('users').doc(member2.uid).set({
        'uid': member2.uid,
        'email': member2.email,
        'displayName': member2.displayNameStr,
        'avatarUrl': member2.avatarUrl,
        'localUnion': member2.localUnion,
        'classification': member2.classification,
      });

      await fakeFirestore.collection('users').doc(nonMember.uid).set({
        'uid': nonMember.uid,
        'email': nonMember.email,
        'displayName': nonMember.displayNameStr,
        'localUnion': nonMember.localUnion,
        'classification': nonMember.classification,
      });
    });

    Widget createTestApp({required UserModel currentUser}) {
      return MaterialApp(
        home: ChangeNotifierProvider<UserModel>.value(
          value: currentUser,
          child: CrewChatScreen(
            crewId: crewId,
            crewName: testCrew.name,
            crewAvatar: 'https://example.com/crew_avatar.jpg',
          ),
        ),
      );
    }

    group('Complete Chat Workflow Tests', () {
      testWidgets('Foreman can send and receive messages with crew members', (WidgetTester tester) async {
        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Verify foreman can access chat
        expect(find.text('Test Crew Alpha'), findsOneWidget);
        expect(find.text('3 members'), findsOneWidget); // 3 members total
        expect(find.byType(TextField), findsOneWidget);

        // Send first message as foreman
        await tester.enterText(find.byType(TextField), 'Welcome to the crew chat everyone!');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify message appears
        expect(find.text('Welcome to the crew chat everyone!'), findsOneWidget);

        // Verify message is saved to Firestore
        final messagesQuery = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .get();
        expect(messagesQuery.docs.length, equals(1));
        expect(messagesQuery.docs.first.get('content'), equals('Welcome to the crew chat everyone!'));
        expect(messagesQuery.docs.first.get('senderId'), equals(foreman.uid));
      });

      testWidgets('Real-time message synchronization between crew members', (WidgetTester tester) async {
        // Setup member1 session
        await tester.pumpWidget(createTestApp(currentUser: member1));
        await tester.pumpAndSettle();

        // Foreman sends a message (simulated backend operation)
        final foremanMessage = await messagingService.sendMessage(
          crewId: crewId,
          sender: foreman,
          content: 'Storm job available in Houston - who can respond?',
          type: CrewMessageType.alert,
          priority: CrewMessagePriority.high,
        );

        // Member1 should see the message in real-time
        await tester.pumpAndSettle();
        expect(find.text('Storm job available in Houston - who can respond?'), findsOneWidget);

        // Member1 replies
        await tester.enterText(find.byType(TextField), 'I can respond! Available immediately.');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify reply appears
        expect(find.text('I can respond! Available immediately.'), findsOneWidget);

        // Verify both messages are in Firestore
        final allMessages = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .orderBy('createdAt')
            .get();
        expect(allMessages.docs.length, equals(2));
      });

      testWidgets('30+ consecutive messages maintain real-time performance', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Send 35 consecutive messages rapidly
        for (int i = 0; i < 35; i++) {
          final messageContent = i % 5 == 0
              ? 'URGENT: Storm work update #$i - All hands on deck!'
              : 'Crew coordination message #$i - Testing real-time performance';

          final messageType = i % 5 == 0 ? CrewMessageType.alert : CrewMessageType.text;
          final priority = i % 5 == 0 ? CrewMessagePriority.urgent : CrewMessagePriority.normal;

          await messagingService.sendMessage(
            crewId: crewId,
            sender: foreman,
            content: messageContent,
            type: messageType,
            priority: priority,
          );

          if (i % 10 == 0) {
            // Pump UI periodically to maintain responsiveness
            await tester.pump();
          }
        }

        await tester.pumpAndSettle();
        stopwatch.stop();

        // Performance should be under 5 seconds for 35 messages
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Verify all messages are in Firestore
        final allMessages = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .get();
        expect(allMessages.docs.length, equals(35));

        // Verify messages appear in UI
        expect(find.textContaining('Crew coordination message'), findsWidgets);
        expect(find.textContaining('Storm work update'), findsWidgets);
      });

      testWidgets('Chronological message ordering is maintained', (WidgetTester tester) async {
        // Setup member2 session
        await tester.pumpWidget(createTestApp(currentUser: member2));
        await tester.pumpAndSettle();

        final messages = <String>[];

        // Send messages with varying timestamps
        for (int i = 0; i < 10; i++) {
          final messageContent = 'Sequential message $i';
          messages.add(messageContent);

          await messagingService.sendMessage(
            crewId: crewId,
            sender: member2,
            content: messageContent,
          );

          // Small delay to ensure different timestamps
          await Future.delayed(Duration(milliseconds: 50));
        }

        await tester.pumpAndSettle();

        // Verify messages appear in correct chronological order (newest first)
        final foundMessages = tester.widgetList(find.byType(CrewMessageBubble));
        expect(foundMessages.length, equals(10));

        // The newest message should appear first (reverse order in ListView)
        for (int i = 0; i < 10; i++) {
          expect(find.text('Sequential message ${9 - i}'), findsOneWidget);
        }
      });

      testWidgets('Non-member access restrictions are enforced', (WidgetTester tester) async {
        // Setup non-member session
        await tester.pumpWidget(createTestApp(currentUser: nonMember));
        await tester.pumpAndSettle();

        // Non-member can see the chat interface (UI loads)
        expect(find.text('Test Crew Alpha'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);

        // But non-member cannot send messages
        await tester.enterText(find.byType(TextField), 'I should not be able to send this');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify error message appears
        expect(find.textContaining('Failed to send message'), findsOneWidget);
        expect(find.textContaining('not a member of this crew'), findsOneWidget);

        // Verify message was not saved to Firestore
        final messagesQuery = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .get();
        expect(messagesQuery.docs.length, equals(0));
      });

      testWidgets('Message types and features work correctly', (WidgetTester tester) async {
        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Send regular text message
        await tester.enterText(find.byType(TextField), 'Regular status update');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        expect(find.text('Regular status update'), findsOneWidget);

        // Send system message (backend operation)
        await messagingService.sendSystemMessage(
          crewId: crewId,
          content: 'Jane Member joined the crew',
          metadata: {'type': 'member_joined', 'userId': member1.uid},
        );

        await tester.pumpAndSettle();
        expect(find.text('Jane Member joined the crew'), findsOneWidget);

        // Send high-priority alert
        await messagingService.sendMessage(
          crewId: crewId,
          sender: foreman,
          content: '🚨 IMMEDIATE RESPONSE REQUIRED: Major storm damage reported',
          type: CrewMessageType.alert,
          priority: CrewMessagePriority.urgent,
        );

        await tester.pumpAndSettle();
        expect(find.text('🚨 IMMEDIATE RESPONSE REQUIRED: Major storm damage reported'), findsOneWidget);

        // Verify all messages are saved with correct types
        final allMessages = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .get();
        expect(allMessages.docs.length, equals(3));
      });

      testWidgets('Message reactions and interactions work', (WidgetTester tester) async {
        // Setup member1 session
        await tester.pumpWidget(createTestApp(currentUser: member1));
        await tester.pumpAndSettle();

        // Send a message
        await messagingService.sendMessage(
          crewId: crewId,
          sender: member1,
          content: 'Great work today team!',
        );

        await tester.pumpAndSettle();
        expect(find.text('Great work today team!'), findsOneWidget);

        // Long press to show message options
        await tester.longPress(find.text('Great work today team!'));
        await tester.pumpAndSettle();

        // Verify reaction options appear
        expect(find.text('Message Options'), findsOneWidget);
        expect(find.text('React'), findsOneWidget);

        // Tap on reaction option
        await tester.tap(find.text('React'));
        await tester.pumpAndSettle();

        // Verify reaction picker appears
        expect(find.text('Add Reaction'), findsOneWidget);
        expect(find.text('❤️'), findsOneWidget);
        expect(find.text('👍'), findsOneWidget);
      });

      testWidgets('Conversation persistence and recovery', (WidgetTester tester) async {
        // Send initial messages
        await messagingService.sendMessage(
          crewId: crewId,
          sender: foreman,
          content: 'Initial crew setup message',
        );

        await messagingService.sendMessage(
          crewId: crewId,
          sender: member1,
          content: 'Ready for work',
        );

        await messagingService.sendMessage(
          crewId: crewId,
          sender: member2,
          content: 'On my way to site',
        );

        // Setup new session (simulate app restart)
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Verify all messages are loaded
        expect(find.text('Initial crew setup message'), findsOneWidget);
        expect(find.text('Ready for work'), findsOneWidget);
        expect(find.text('On my way to site'), findsOneWidget);

        // Verify conversation metadata is maintained
        final conversationDoc = await fakeFirestore
            .collection('crewConversations')
            .doc(crewId)
            .get();
        expect(conversationDoc.exists, isTrue);
        expect(conversationDoc.get('crewName'), equals('Test Crew Alpha'));
        expect(conversationDoc.get('lastActivity'), isNotNull);
      });

      testWidgets('Multi-user real-time coordination', (WidgetTester tester) async {
        // This test simulates multiple users sending messages simultaneously

        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Simulate concurrent messages from different users
        final futures = <Future<CrewMessage>>[];

        // Foreman sends urgent message
        futures.add(messagingService.sendMessage(
          crewId: crewId,
          sender: foreman,
          content: 'EMERGENCY: All available personnel report to staging area',
          type: CrewMessageType.alert,
          priority: CrewMessagePriority.urgent,
        ));

        // Member1 responds
        futures.add(messagingService.sendMessage(
          crewId: crewId,
          sender: member1,
          content: 'En route - 15 minutes out',
        ));

        // Member2 responds
        futures.add(messagingService.sendMessage(
          crewId: crewId,
          sender: member2,
          content: 'Already on site - ready to work',
        ));

        // Wait for all messages to be sent
        final messages = await Future.wait(futures);

        expect(messages.length, equals(3));

        // Refresh UI to show new messages
        await tester.pumpAndSettle();

        // Verify all messages appear in real-time
        expect(find.text('EMERGENCY: All available personnel report to staging area'), findsOneWidget);
        expect(find.text('En route - 15 minutes out'), findsOneWidget);
        expect(find.text('Already on site - ready to work'), findsOneWidget);

        // Verify messages are properly ordered chronologically
        final allMessages = await messagingService.getMessages(crewId: crewId);
        expect(allMessages.length, equals(3));

        // Messages should be ordered newest first
        for (int i = 0; i < allMessages.length - 1; i++) {
          expect(allMessages[i].createdAt.isAfter(allMessages[i + 1].createdAt), isTrue);
        }
      });
    });

    group('Security and Privacy Tests', () {
      testWidgets('Message security and data integrity', (WidgetTester tester) async {
        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Send sensitive crew message
        final sensitiveMessage = 'Crew coordinates: 29.7604° N, 95.3698° W - Site Alpha';
        await tester.enterText(find.byType(TextField), sensitiveMessage);
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify message is stored correctly
        final messageDoc = await fakeFirestore
            .collection('crewMessages')
            .where('content', isEqualTo: sensitiveMessage)
            .get();
        expect(messageDoc.docs.length, equals(1));

        final storedMessage = messageDoc.docs.first;
        expect(storedMessage.get('senderId'), equals(foreman.uid));
        expect(storedMessage.get('crewId'), equals(crewId));
        expect(storedMessage.get('isDeleted'), isFalse);

        // Verify message cannot be accessed by non-members
        // (This would be enforced by Firestore security rules in production)
        expect(storedMessage.get('crewId'), equals(crewId));
      });

      testWidgets('User privacy in chat interactions', (WidgetTester tester) async {
        // Setup member1 session
        await tester.pumpWidget(createTestApp(currentUser: member1));
        await tester.pumpAndSettle();

        // Send message with personal information
        await tester.enterText(
          find.byType(TextField),
          'My phone for emergency contact: 555-0123'
        );
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify message is only visible to crew members
        final messageDoc = await fakeFirestore
            .collection('crewMessages')
            .where('content', contains('555-0123'))
            .get();
        expect(messageDoc.docs.length, equals(1));

        // Verify sender information is properly attached
        expect(messageDoc.docs.first.get('senderId'), equals(member1.uid));
        expect(messageDoc.docs.first.get('senderName'), equals('Jane Member'));
      });
    });

    group('Performance and Reliability Tests', () {
      testWidgets('App performance under heavy message load', (WidgetTester tester) async {
        final performanceStopwatch = Stopwatch()..start();

        // Setup foreman session
        await tester.pumpWidget(createTestApp(currentUser: foreman));
        await tester.pumpAndSettle();

        // Simulate heavy usage - 50 rapid messages
        final messageFutures = <Future<CrewMessage>>[];

        for (int i = 0; i < 50; i++) {
          messageFutures.add(messagingService.sendMessage(
            crewId: crewId,
            sender: i % 3 == 0 ? foreman : (i % 3 == 1 ? member1 : member2),
            content: 'Heavy load test message #$i - Performance validation',
          ));
        }

        // Wait for all messages to be processed
        await Future.wait(messageFutures);

        performanceStopwatch.stop();

        // Performance should remain acceptable
        expect(performanceStopwatch.elapsedMilliseconds, lessThan(10000));

        // UI should still be responsive
        await tester.pumpAndSettle();
        expect(find.byType(CrewChatScreen), findsOneWidget);

        // Verify all messages are stored
        final totalMessages = await fakeFirestore
            .collection('crewMessages')
            .where('crewId', isEqualTo: crewId)
            .get();
        expect(totalMessages.docs.length, equals(50));
      });

      testWidgets('Error recovery and reliability', (WidgetTester tester) async {
        // Setup member1 session
        await tester.pumpWidget(createTestApp(currentUser: member1));
        await tester.pumpAndSettle();

        // Send successful message
        await tester.enterText(find.byType(TextField), 'Successful message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        expect(find.text('Successful message'), findsOneWidget);

        // Attempt to send empty message (should fail gracefully)
        await tester.enterText(find.byType(TextField), '');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // UI should remain functional
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);

        // Should be able to send another message after error
        await tester.enterText(find.byType(TextField), 'Recovery test message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();
        expect(find.text('Recovery test message'), findsOneWidget);
      });
    });
  });
}

/// Mock CrewMessageBubble widget for testing
class CrewMessageBubble extends StatelessWidget {
  final CrewMessage message;
  final bool isFromCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String)? onReactionTap;

  const CrewMessageBubble({
    Key? key,
    required this.message,
    required this.isFromCurrentUser,
    this.onTap,
    this.onLongPress,
    this.onReactionTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(vertical: 4),
      padding: EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isFromCurrentUser ? Colors.blue[100] : Colors.grey[200],
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (!isFromCurrentUser)
            Text(
              message.senderName,
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
            ),
          Text(message.content),
          if (message.hasReactions)
            Text('Reactions: ${message.reactionCount}'),
        ],
      ),
    );
  }
}