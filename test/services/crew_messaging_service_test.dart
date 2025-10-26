import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';

import 'crew_messaging_service_test.mocks.dart';

@GenerateMocks([
  UserModel,
  Crew,
])
void main() {
  group('CrewMessagingService Tests - User Vision Compliance', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CrewMessagingService messagingService;
    late MockUserModel mockForeman;
    late MockUserModel mockMember;
    late MockUserModel mockNonMember;
    late MockCrew mockCrew;
    late String crewId;
    late String foremanId;
    late String memberId;
    late String nonMemberId;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      messagingService = CrewMessagingService();
      mockForeman = MockUserModel();
      mockMember = MockUserModel();
      mockNonMember = MockUserModel();
      mockCrew = MockCrew();

      foremanId = 'foreman_123';
      memberId = 'member_456';
      nonMemberId = 'non_member_789';
      crewId = 'test_crew_123';

      // Setup foreman
      when(mockForeman.uid).thenReturn(foremanId);
      when(mockForeman.displayNameStr).thenReturn('John Foreman');
      when(mockForeman.avatarUrl).thenReturn('https://example.com/foreman.jpg');

      // Setup member
      when(mockMember.uid).thenReturn(memberId);
      when(mockMember.displayNameStr).thenReturn('Jane Member');
      when(mockMember.avatarUrl).thenReturn('https://example.com/member.jpg');

      // Setup non-member
      when(mockNonMember.uid).thenReturn(nonMemberId);
      when(mockNonMember.displayNameStr).thenReturn('Outside User');

      // Setup crew
      when(mockCrew.id).thenReturn(crewId);
      when(mockCrew.name).thenReturn('Test Crew Alpha');
      when(mockCrew.foremanId).thenReturn(foremanId);
      when(mockCrew.memberIds).thenReturn([foremanId, memberId]);

      // Create crew in fake Firestore
      await fakeFirestore.collection('crews').doc(crewId).set({
        'name': 'Test Crew Alpha',
        'foremanId': foremanId,
        'memberIds': [foremanId, memberId],
        'jobPreferences': {},
        'stats': {'totalJobsShared': 0, 'totalApplications': 0, 'averageMatchScore': 0.0},
      });
    });

    group('Crew Member Access Validation', () {
      test('Foreman can send messages to crew', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Test message from foreman',
        );

        expect(message.content, equals('Test message from foreman'));
        expect(message.senderId, equals(foremanId));
        expect(message.senderName, equals('John Foreman'));
        expect(message.crewId, equals(crewId));
        expect(message.type, equals(CrewMessageType.text));

        // Verify message is saved to Firestore
        final messageDoc = await fakeFirestore
            .collection('crewMessages')
            .doc(message.id)
            .get();
        expect(messageDoc.exists, isTrue);
        expect(messageDoc.get('content'), equals('Test message from foreman'));
      });

      test('Crew member can send messages to crew', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockMember,
          content: 'Test message from member',
        );

        expect(message.content, equals('Test message from member'));
        expect(message.senderId, equals(memberId));
        expect(message.senderName, equals('Jane Member'));
        expect(message.crewId, equals(crewId));
      });

      test('Non-member cannot send messages to crew', () async {
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            sender: mockNonMember,
            content: 'I should not be able to send this',
          ),
          throwsException,
        );
      });

      test('Access control works with empty crew', () async {
        await fakeFirestore.collection('crews').doc(crewId).update({
          'memberIds': [],
        });

        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: 'Should fail with empty crew',
          ),
          throwsException,
        );
      });

      test('Access control fails for non-existent crew', () async {
        expect(
          () => messagingService.sendMessage(
            crewId: 'non_existent_crew',
            sender: mockForeman,
            content: 'Should fail for non-existent crew',
          ),
          throwsException,
        );
      });
    });

    group('Real-time Message Streaming', () {
      test('Messages stream in real-time for crew members', () async {
        // Create initial messages
        final message1 = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'First message',
        );

        final message2 = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockMember,
          content: 'Second message',
        );

        // Stream messages
        final messageStream = messagingService.streamMessages(crewId);
        final messages = await messageStream.first;

        expect(messages.length, equals(2));
        expect(messages.first.content, equals('Second message')); // Newest first
        expect(messages.last.content, equals('First message'));
      });

      test('New messages appear instantly in stream', () async {
        // Start streaming
        final messageStream = messagingService.streamMessages(crewId);

        // Send initial message
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Initial message',
        );

        // Get first batch of messages
        final initialMessages = await messageStream.first;
        expect(initialMessages.length, equals(1));

        // Send another message
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockMember,
          content: 'Real-time message',
        );

        // Get updated messages
        final updatedMessages = await messageStream.first;
        expect(updatedMessages.length, equals(2));
        expect(updatedMessages.first.content, equals('Real-time message'));
      });

      test('Deleted messages do not appear in stream', () async {
        // Send messages
        final message1 = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Message to keep',
        );

        final message2 = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockMember,
          content: 'Message to delete',
        );

        // Delete one message
        await messagingService.deleteMessage(message2.id, memberId);

        // Stream messages
        final messageStream = messagingService.streamMessages(crewId);
        final messages = await messageStream.first;

        expect(messages.length, equals(1));
        expect(messages.first.content, equals('Message to keep'));
      });
    });

    group('Message Ordering and Chronology', () {
      test('Messages are ordered chronologically (newest first)', () async {
        final messages = <CrewMessage>[];

        // Send messages with different timestamps
        for (int i = 0; i < 10; i++) {
          final message = await messagingService.sendMessage(
            crewId: crewId,
            sender: i % 2 == 0 ? mockForeman : mockMember,
            content: 'Message $i',
          );
          messages.add(message);

          // Small delay to ensure different timestamps
          await Future.delayed(Duration(milliseconds: 10));
        }

        // Get messages from service
        final retrievedMessages = await messagingService.getMessages(crewId: crewId);

        expect(retrievedMessages.length, equals(10));

        // Verify chronological order (newest first)
        for (int i = 0; i < retrievedMessages.length - 1; i++) {
          expect(retrievedMessages[i].createdAt.isAfter(retrievedMessages[i + 1].createdAt), isTrue);
        }
      });

      test('Messages maintain order in real-time stream', () async {
        final messageContents = <String>[];

        // Start streaming
        final messageStream = messagingService.streamMessages(crewId);

        // Send multiple messages rapidly
        for (int i = 0; i < 5; i++) {
          final content = 'Rapid message $i';
          messageContents.add(content);

          await messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: content,
          );
        }

        // Get streamed messages
        final streamedMessages = await messageStream.first;

        expect(streamedMessages.length, equals(5));

        // Verify order is maintained
        for (int i = 0; i < messageContents.length; i++) {
          expect(streamedMessages[i].content, equals(messageContents[messageContents.length - 1 - i]));
        }
      });
    });

    group('High-Volume Message Performance', () {
      test('Can handle 30+ consecutive messages efficiently', () async {
        final stopwatch = Stopwatch()..start();

        final messages = <CrewMessage>[];

        // Send 35 messages
        for (int i = 0; i < 35; i++) {
          final message = await messagingService.sendMessage(
            crewId: crewId,
            sender: i % 2 == 0 ? mockForeman : mockMember,
            content: 'High volume test message $i - Testing performance with many messages',
          );
          messages.add(message);
        }

        stopwatch.stop();

        // Should complete within reasonable time (under 5 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000));
        expect(messages.length, equals(35));

        // Verify all messages were created successfully
        for (int i = 0; i < 35; i++) {
          expect(messages[i].content, contains('High volume test message $i'));
        }
      });

      test('Message retrieval scales with volume', () async {
        // Send 50 messages
        for (int i = 0; i < 50; i++) {
          await messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: 'Scalability test message $i',
          );
        }

        final stopwatch = Stopwatch()..start();

        // Retrieve all messages
        final retrievedMessages = await messagingService.getMessages(crewId: crewId, limit: 50);

        stopwatch.stop();

        // Retrieval should be fast (under 1 second)
        expect(stopwatch.elapsedMilliseconds, lessThan(1000));
        expect(retrievedMessages.length, equals(50));

        // Verify pagination works
        final firstBatch = await messagingService.getMessages(crewId: crewId, limit: 20);
        final secondBatch = await messagingService.getMessages(
          crewId: crewId,
          limit: 20,
          lastMessage: firstBatch.last,
        );

        expect(firstBatch.length, equals(20));
        expect(secondBatch.length, equals(20));

        // Verify no duplicates
        final firstBatchIds = firstBatch.map((m) => m.id).toSet();
        final secondBatchIds = secondBatch.map((m) => m.id).toSet();
        expect(firstBatchIds.intersection(secondBatchIds).isEmpty, isTrue);
      });

      test('Real-time stream performance with high volume', () async {
        // Send 25 messages
        for (int i = 0; i < 25; i++) {
          await messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: 'Stream performance test $i',
          );
        }

        final stopwatch = Stopwatch()..start();

        // Start streaming
        final messageStream = messagingService.streamMessages(crewId);
        final streamedMessages = await messageStream.first;

        stopwatch.stop();

        // Stream should be fast (under 2 seconds)
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));
        expect(streamedMessages.length, equals(25));
      });
    });

    group('Message Features and Types', () {
      test('Can send different message types', () async {
        // Text message
        final textMessage = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Text message',
          type: CrewMessageType.text,
        );
        expect(textMessage.type, equals(CrewMessageType.text));

        // Alert message
        final alertMessage = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Urgent alert',
          type: CrewMessageType.alert,
          priority: CrewMessagePriority.urgent,
        );
        expect(alertMessage.type, equals(CrewMessageType.alert));
        expect(alertMessage.priority, equals(CrewMessagePriority.urgent));
        expect(alertMessage.isUrgent, isTrue);

        // System message (bypasses member validation)
        final systemMessage = await messagingService.sendSystemMessage(
          crewId: crewId,
          content: 'System notification',
        );
        expect(systemMessage.type, equals(CrewMessageType.system));
        expect(systemMessage.senderId, equals('system'));
      });

      test('Message reactions work correctly', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'React to this message',
        );

        // Add reaction
        final reactionAdded = await messagingService.addReaction(
          message.id,
          memberId,
          '👍',
        );
        expect(reactionAdded, isTrue);

        // Verify reaction is saved
        final updatedDoc = await fakeFirestore
            .collection('crewMessages')
            .doc(message.id)
            .get();
        final reactions = Map<String, String>.from(updatedDoc.get('reactions') ?? {});
        expect(reactions[memberId], equals('👍'));

        // Remove reaction
        final reactionRemoved = await messagingService.removeReaction(
          message.id,
          memberId,
        );
        expect(reactionRemoved, isTrue);
      });

      test('Message read status tracking', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Track read status',
        );

        // Mark as read by member
        final markedAsRead = await messagingService.markMessageAsRead(
          message.id,
          memberId,
        );
        expect(markedAsRead, isTrue);

        // Verify read status is saved
        final updatedDoc = await fakeFirestore
            .collection('crewMessages')
            .doc(message.id)
            .get();
        final readStatus = List<Map<String, dynamic>>.from(
          updatedDoc.get('readStatus') ?? [],
        );
        expect(readStatus.any((status) => status['userId'] == memberId), isTrue);
      });

      test('Message editing functionality', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Original message',
        );

        // Edit message
        final edited = await messagingService.editMessage(
          message.id,
          foremanId,
          'Edited message content',
        );
        expect(edited, isTrue);

        // Verify message is updated
        final updatedDoc = await fakeFirestore
            .collection('crewMessages')
            .doc(message.id)
            .get();
        expect(updatedDoc.get('content'), equals('Edited message content'));
        expect(updatedDoc.get('editedAt'), isNotNull);
      });

      test('Message deletion (soft delete)', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Message to delete',
        );

        // Delete message
        final deleted = await messagingService.deleteMessage(message.id, foremanId);
        expect(deleted, isTrue);

        // Verify message is soft-deleted
        final updatedDoc = await fakeFirestore
            .collection('crewMessages')
            .doc(message.id)
            .get();
        expect(updatedDoc.get('isDeleted'), isTrue);
        expect(updatedDoc.get('content'), equals('[Message deleted]'));
      });
    });

    group('Conversation Management', () {
      test('Conversations are created and updated correctly', () async {
        // Send a message
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'First message',
        );

        // Check conversation was created
        final conversationDoc = await fakeFirestore
            .collection('crewConversations')
            .doc(crewId)
            .get();
        expect(conversationDoc.exists, isTrue);
        expect(conversationDoc.get('crewName'), equals('Test Crew Alpha'));
        expect(conversationDoc.get('lastMessage.content'), equals('First message'));
      });

      test('Unread count calculation works correctly', () async {
        // Send messages from foreman
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Message 1',
        );

        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Message 2',
        );

        // Get conversations for member (should have 2 unread)
        final conversations = await messagingService.getConversationsForUser(memberId);
        expect(conversations.length, equals(1));
        expect(conversations.first.unreadCount, equals(2));

        // Get conversations for foreman (should have 0 unread - they sent them)
        final foremanConversations = await messagingService.getConversationsForUser(foremanId);
        expect(foremanConversations.first.unreadCount, equals(0));
      });

      test('Real-time conversation updates', () async {
        // Start streaming conversations for member
        final conversationStream = messagingService.streamConversationsForUser(memberId);

        // Send initial message
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Initial message',
        );

        // Get initial conversations
        final initialConversations = await conversationStream.first;
        expect(initialConversations.first.unreadCount, equals(1));

        // Mark message as read
        final messages = await messagingService.getMessages(crewId: crewId);
        await messagingService.markMessageAsRead(messages.first.id, memberId);

        // Get updated conversations
        final updatedConversations = await conversationStream.first;
        expect(updatedConversations.first.unreadCount, equals(0));
      });
    });

    group('Security and Validation', () {
      test('Input validation works correctly', () async {
        // Empty content should fail
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: '',
          ),
          throwsArgumentError,
        );

        // Whitespace-only content should fail
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            sender: mockForeman,
            content: '   ',
          ),
          throwsArgumentError,
        );

        // Empty crew ID should fail
        expect(
          () => messagingService.sendMessage(
            crewId: '',
            sender: mockForeman,
            content: 'Valid content',
          ),
          throwsArgumentError,
        );

        // Empty user ID should fail
        final invalidUser = MockUserModel();
        when(invalidUser.uid).thenReturn('');
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            sender: invalidUser,
            content: 'Valid content',
          ),
          throwsArgumentError,
        );
      });

      test('Message ownership validation', () async {
        final message = await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'My message',
        );

        // Non-member cannot edit message
        expect(
          () => messagingService.editMessage(
            message.id,
            nonMemberId,
            'Hacked content',
          ),
          throwsException,
        );

        // Member cannot edit foreman's message
        expect(
          () => messagingService.editMessage(
            message.id,
            memberId,
            'Cannot edit this',
          ),
          throwsException,
        );

        // Foreman can edit their own message
        final canEdit = await messagingService.editMessage(
          message.id,
          foremanId,
          'Edited by owner',
        );
        expect(canEdit, isTrue);
      });

      test('Message search functionality', () async {
        // Send searchable messages
        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Storm job available in Texas',
        );

        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockMember,
          content: 'Regular work update',
        );

        await messagingService.sendMessage(
          crewId: crewId,
          sender: mockForeman,
          content: 'Another storm opportunity',
        );

        // Search for "storm"
        final stormResults = await messagingService.searchMessages(
          crewId: crewId,
          query: 'storm',
        );
        expect(stormResults.length, equals(2));
        expect(stormResults.every((m) => m.content.toLowerCase().contains('storm')), isTrue);

        // Search for "regular"
        final regularResults = await messagingService.searchMessages(
          crewId: crewId,
          query: 'regular',
        );
        expect(regularResults.length, equals(1));
        expect(regularResults.first.content, contains('Regular work update'));
      });
    });
  });
}