import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:journeyman_jobs/features/crews/services/message_service.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/crew_visibility.dart';
import 'package:journeyman_jobs/domain/enums/message_type.dart';

/// Comprehensive integration tests for messaging system
///
/// Tests cover:
/// - Crew message sending and receiving
/// - Direct message functionality
/// - Real-time updates via streams
/// - Message status tracking (sent, delivered, read)
/// - Message editing and deletion
/// - Search functionality
/// - Error handling and edge cases
/// - Performance under load
/// - Concurrent operations
void main() {
  group('Messaging System Integration Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MessageService messageService;
    late CrewService crewService;
    late String testCrewId;
    late String testUserId;
    late String testSenderId;
    late String testRecipientId;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      messageService = MessageService();
      crewService = CrewService(
        jobSharingService: MockJobSharingService(),
        offlineDataService: MockOfflineDataService(),
        connectivityService: MockConnectivityService(),
      );

      testCrewId = 'test-crew-123';
      testUserId = 'user-123';
      testSenderId = 'sender-123';
      testRecipientId = 'recipient-123';

      // Setup test crew
      await _setupTestCrew();
    });

    tearDown(() {
      reset(mocktail);
    });

    // Crew Messaging Tests
    group('Crew Messaging', () {
      testWidgets('sends crew message successfully', (WidgetTester tester) async {
        // Arrange
        final testMessage = Message(
          id: 'test-message-1',
          senderId: testSenderId,
          crewId: testCrewId,
          content: 'Hello crew!',
          type: MessageType.text,
          sentAt: DateTime.now(),
          readBy: {},
          isEdited: false,
        );

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Hello crew!',
        );

        // Assert
        final crewDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(crewDoc.docs.length, equals(1));
        final messageData = crewDoc.docs.first.data();
        expect(messageData['content'], equals('Hello crew!'));
        expect(messageData['senderId'], equals(testSenderId));
        expect(messageData['crewId'], equals(testCrewId));
        expect(messageData['type'], equals('text'));
        expect(messageData['isEdited'], equals(false));
      });

      testWidgets('receives crew messages via stream', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId);

        stream.listen((messageList) {
          messages.addAll(messageList);
        });

        // Act - Send message
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Stream test message',
        );

        // Wait for stream to update
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(messages.isNotEmpty, isTrue);
        expect(messages.first.content, equals('Stream test message'));
      });

      testWidgets('handles crew message with attachments', (WidgetTester tester) async {
        // Arrange
        final attachment = Attachment(
          url: 'https://example.com/image.jpg',
          filename: 'test-image.jpg',
          type: AttachmentType.image,
          sizeBytes: 1024,
        );

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Check out this image',
          attachments: [attachment],
        );

        // Assert
        final crewDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(crewDoc.docs.length, equals(1));
        final messageData = crewDoc.docs.first.data();
        expect(messageData['content'], equals('Check out this image'));
        expect(messageData['attachments'], isNotNull);
        expect(messageData['attachments'].length, equals(1));
        expect(messageData['attachments'][0]['filename'], equals('test-image.jpg'));
      });
    });

    // Direct Messaging Tests
    group('Direct Messaging', () {
      testWidgets('sends direct message successfully', (WidgetTester tester) async {
        // Act
        await messageService.sendDirectMessage(
          senderId: testSenderId,
          recipientId: testRecipientId,
          content: 'Hello there!',
        );

        // Assert
        final conversationId = _getConversationId(testSenderId, testRecipientId);
        final messageDoc = await fakeFirestore
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(1));
        final messageData = messageDoc.docs.first.data();
        expect(messageData['content'], equals('Hello there!'));
        expect(messageData['senderId'], equals(testSenderId));
        expect(messageData['recipientId'], equals(testRecipientId));
      });

      testWidgets('receives direct messages via stream', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getDirectMessagesStream(testSenderId, testRecipientId, testUserId);

        stream.listen((messageList) {
          messages.addAll(messageList);
        });

        // Act - Send message
        await messageService.sendDirectMessage(
          senderId: testSenderId,
          recipientId: testRecipientId,
          content: 'Direct message test',
        );

        // Wait for stream to update
        await tester.pump(const Duration(milliseconds: 100));

        // Assert
        expect(messages.isNotEmpty, isTrue);
        expect(messages.first.content, equals('Direct message test'));
      });

      testWidgets('maintains consistent conversation ID regardless of sender', (WidgetTester tester) async {
        // Act - Send message from sender to recipient
        await messageService.sendDirectMessage(
          senderId: testSenderId,
          recipientId: testRecipientId,
          content: 'Message from sender',
        );

        // Act - Send message from recipient to sender
        await messageService.sendDirectMessage(
          senderId: testRecipientId,
          recipientId: testSenderId,
          content: 'Message from recipient',
        );

        // Assert - Both messages should be in same conversation
        final conversationId = _getConversationId(testSenderId, testRecipientId);
        final messageDoc = await fakeFirestore
            .collection('messages')
            .doc(conversationId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(2));
        expect(messageDoc.docs.map((doc) => doc.data()['content']).toSet(),
               equals({'Message from sender', 'Message from recipient'}));
      });
    });

    // Message Status Tests
    group('Message Status Tracking', () {
      testWidgets('marks message as read successfully', (WidgetTester tester) async {
        // Arrange - Send a message first
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Unread message',
        );

        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();
        final messageId = messageDoc.docs.first.id;

        // Act - Mark as read
        await messageService.markAsRead(
          messageId: messageId,
          userId: testUserId,
          isCrewMessage: true,
          crewId: testCrewId,
        );

        // Assert
        final updatedDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .doc(messageId)
            .get();

        final messageData = updatedDoc.data() as Map<String, dynamic>;
        expect(messageData['readBy'], isNotNull);
        expect(messageData['readBy'][testUserId], isNotNull);
      });

      testWidgets('edits message content successfully', (WidgetTester tester) async {
        // Arrange - Send a message first
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Original message',
        );

        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();
        final messageId = messageDoc.docs.first.id;

        // Act - Edit message
        await messageService.editMessage(
          messageId: messageId,
          newContent: 'Edited message',
          isCrewMessage: true,
          crewId: testCrewId,
        );

        // Assert
        final updatedDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .doc(messageId)
            .get();

        final messageData = updatedDoc.data() as Map<String, dynamic>;
        expect(messageData['content'], equals('Edited message'));
        expect(messageData['isEdited'], equals(true));
        expect(messageData['editedAt'], isNotNull);
      });

      testWidgets('deletes message successfully (soft delete)', (WidgetTester tester) async {
        // Arrange - Send a message first
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Message to delete',
        );

        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();
        final messageId = messageDoc.docs.first.id;

        // Act - Delete message
        await messageService.deleteMessage(
          messageId: messageId,
          isCrewMessage: true,
          crewId: testCrewId,
        );

        // Assert
        final updatedDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .doc(messageId)
            .get();

        final messageData = updatedDoc.data() as Map<String, dynamic>;
        expect(messageData['content'], equals('[Message deleted]'));
        expect(messageData['type'], equals('systemNotification'));
        expect(messageData['attachments'], isNull);
      });
    });

    // Search Functionality Tests
    group('Message Search', () {
      testWidgets('searches crew messages successfully', (WidgetTester tester) async {
        // Arrange - Send multiple messages
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Important update about the project',
        );

        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: 'Random chat message',
        );

        // Act - Search for specific term
        final results = await messageService.searchMessages(
          query: 'project',
          crewId: testCrewId,
        );

        // Assert
        expect(results.length, equals(1));
        expect(results.first.content, contains('project'));
      });

      testWidgets('searches direct messages successfully', (WidgetTester tester) async {
        // Arrange - Send direct message
        final conversationId = _getConversationId(testSenderId, testRecipientId);
        await messageService.sendDirectMessage(
          senderId: testSenderId,
          recipientId: testRecipientId,
          content: 'Direct message about meeting',
        );

        // Act - Search
        final results = await messageService.searchMessages(
          query: 'meeting',
          conversationId: conversationId,
        );

        // Assert
        expect(results.length, equals(1));
        expect(results.first.content, contains('meeting'));
      });
    });

    // Error Handling Tests
    group('Error Handling', () {
      testWidgets('handles invalid crew ID gracefully', (WidgetTester tester) async {
        // Act & Assert
        expect(
          () => messageService.sendCrewMessage(
            crewId: '',
            senderId: testSenderId,
            content: 'Test message',
          ),
          throwsA(isA<Exception>()),
        );
      });

      testWidgets('handles empty message content gracefully', (WidgetTester tester) async {
        // Act & Assert
        expect(
          () => messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testSenderId,
            content: '',
          ),
          throwsA(isA<Exception>()),
        );
      });

      testWidgets('handles invalid message ID operations gracefully', (WidgetTester tester) async {
        // Act & Assert - Try to mark non-existent message as read
        expect(
          () => messageService.markAsRead(
            messageId: 'non-existent-message',
            userId: testUserId,
            isCrewMessage: true,
            crewId: testCrewId,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    // Performance Tests
    group('Performance', () {
      testWidgets('handles high volume of messages efficiently', (WidgetTester tester) async {
        final stopwatch = Stopwatch()..start();

        // Act - Send 100 messages
        for (int i = 0; i < 100; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testSenderId,
            content: 'Message $i',
          );
        }

        stopwatch.stop();

        // Assert - Should complete within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));

        // Verify all messages were sent
        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(100));
      });

      testWidgets('handles concurrent message operations', (WidgetTester tester) async {
        // Act - Send multiple messages concurrently
        final futures = <Future<void>>[];
        for (int i = 0; i < 10; i++) {
          futures.add(messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testSenderId,
            content: 'Concurrent message $i',
          ));
        }

        await Future.wait(futures);

        // Assert - All messages should be sent
        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(10));
      });
    });

    // Edge Cases Tests
    group('Edge Cases', () {
      testWidgets('handles very long message content', (WidgetTester tester) async {
        // Arrange
        final longContent = 'A' * 10000; // 10KB message

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: longContent,
        );

        // Assert
        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(1));
        expect(messageDoc.docs.first.data()['content'], equals(longContent));
      });

      testWidgets('handles special characters in messages', (WidgetTester tester) async {
        // Arrange
        final specialContent = 'Special chars: !@#$%^&*()_+-=[]{}|;:,.<>?/~`"\'';

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: specialContent,
        );

        // Assert
        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(1));
        expect(messageDoc.docs.first.data()['content'], equals(specialContent));
      });

      testWidgets('handles unicode characters in messages', (WidgetTester tester) async {
        // Arrange
        final unicodeContent = 'Unicode: ñáéíóú 中文 日本語 العربية';

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testSenderId,
          content: unicodeContent,
        );

        // Assert
        final messageDoc = await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('messages')
            .get();

        expect(messageDoc.docs.length, equals(1));
        expect(messageDoc.docs.first.data()['content'], equals(unicodeContent));
      });
    });

    // Helper Methods
    Future<void> _setupTestCrew() async {
      final crew = Crew(
        id: testCrewId,
        name: 'Test Crew',
        foremanId: testSenderId,
        memberIds: [testSenderId, testUserId],
        preferences: const CrewPreferences(
          jobTypes: [],
          constructionTypes: [],
          autoShareEnabled: false,
        ),
        roles: {
          testSenderId: MemberRole.foreman,
          testUserId: MemberRole.member,
        },
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
        lastActivityAt: DateTime.now(),
        visibility: CrewVisibility.private,
        maxMembers: 50,
        inviteCodeCounter: 0,
      );

      await fakeFirestore
          .collection('crews')
          .doc(testCrewId)
          .set(crew.toFirestore());

      // Add crew members
      for (final member in [testSenderId, testUserId]) {
        final crewMember = CrewMember(
          userId: member,
          crewId: testCrewId,
          role: crew.roles[member]!,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions.fromRole(crew.roles[member]!),
          isAvailable: true,
          lastActive: DateTime.now(),
          isActive: true,
        );

        await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('members')
            .doc(member)
            .set(crewMember.toFirestore());
      }
    }

    String _getConversationId(String userId1, String userId2) {
      final sortedIds = [userId1, userId2]..sort();
      return '${sortedIds[0]}_${sortedIds[1]}';
    }
  });
}

// Mock classes for testing
class MockJobSharingService extends Mock implements JobSharingService {}
class MockOfflineDataService extends Mock implements OfflineDataService {}
class MockConnectivityService extends Mock implements ConnectivityService {}