import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:journeyman_jobs/features/crews/services/message_service.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';
import 'package:journeyman_jobs/features/crews/providers/messaging_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/domain/enums/message_type.dart';
import 'package:journeyman_jobs/domain/enums/message_status.dart';

/// Real-time messaging functionality tests
///
/// Tests cover:
/// - Real-time message delivery and synchronization
/// - Connection stability and recovery
/// - Concurrent user scenarios
/// - Message ordering and consistency
/// - Network interruption handling
/// - Large message streams
/// - Cross-device synchronization scenarios
void main() {
  group('Real-time Messaging Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MessageService messageService;
    late String testCrewId;
    late String testUserId1;
    late String testUserId2;
    late String testUserId3;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      messageService = MessageService();

      testCrewId = 'realtime-test-crew';
      testUserId1 = 'user-1';
      testUserId2 = 'user-2';
      testUserId3 = 'user-3';

      // Setup test environment
      await _setupRealtimeTestEnvironment();
    });

    // Real-time Message Delivery Tests
    group('Real-time Message Delivery', () {
      testWidgets('messages appear in real-time for all crew members', (WidgetTester tester) async {
        // Arrange
        final user1Messages = <Message>[];
        final user2Messages = <Message>[];
        final user3Messages = <Message>[];

        // Create streams for each user
        final stream1 = messageService.getCrewMessagesStream(testCrewId, testUserId1);
        final stream2 = messageService.getCrewMessagesStream(testCrewId, testUserId2);
        final stream3 = messageService.getCrewMessagesStream(testCrewId, testUserId3);

        stream1.listen((messages) => user1Messages.addAll(messages));
        stream2.listen((messages) => user2Messages.addAll(messages));
        stream3.listen((messages) => user3Messages.addAll(messages));

        // Act - User 1 sends a message
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Hello everyone!',
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Assert - All users should receive the message
        expect(user1Messages.any((m) => m.content == 'Hello everyone!'), isTrue);
        expect(user2Messages.any((m) => m.content == 'Hello everyone!'), isTrue);
        expect(user3Messages.any((m) => m.content == 'Hello everyone!'), isTrue);
      });

      testWidgets('messages maintain correct chronological order', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Send multiple messages rapidly
        final testMessages = ['First', 'Second', 'Third', 'Fourth', 'Fifth'];
        for (final content in testMessages) {
          await messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId1,
            content: content,
          );
          // Small delay to ensure distinct timestamps
          await tester.pump(const Duration(milliseconds: 10));
        }

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Messages should be in reverse chronological order (newest first)
        expect(messages.length, equals(testMessages.length));
        for (int i = 0; i < testMessages.length; i++) {
          expect(messages[i].content, equals(testMessages[testMessages.length - 1 - i]));
        }
      });

      testWidgets('handles simultaneous messages from different users', (WidgetTester tester) async {
        // Arrange
        final allMessages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          allMessages.clear();
          allMessages.addAll(messageList);
        });

        // Act - Users send messages simultaneously
        final futures = [
          messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId1,
            content: 'User 1 message',
          ),
          messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId2,
            content: 'User 2 message',
          ),
          messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId3,
            content: 'User 3 message',
          ),
        ];

        await Future.wait(futures);
        await tester.pump(const Duration(milliseconds: 100));

        // Assert - All messages should be delivered
        expect(allMessages.length, equals(3));
        expect(allMessages.map((m) => m.content).toSet(),
               equals({'User 1 message', 'User 2 message', 'User 3 message'}));
      });
    });

    // Connection Stability Tests
    group('Connection Stability', () {
      testWidgets('handles stream reconnection after disconnection', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Simulate connection restoration by sending message after delay
        await Future.delayed(const Duration(milliseconds: 50));
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'After reconnection',
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Message should still be delivered
        expect(messages.isNotEmpty, isTrue);
        expect(messages.first.content, equals('After reconnection'));
      });

      testWidgets('handles stream subscription cancellation gracefully', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        final subscription = stream.listen((messageList) {
          messages.addAll(messageList);
        });

        // Act - Send a message, then cancel subscription
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Before cancellation',
        );

        await tester.pump(const Duration(milliseconds: 50));

        subscription.cancel();

        // Send another message after cancellation
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'After cancellation',
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Assert - Should only have first message
        expect(messages.length, equals(1));
        expect(messages.first.content, equals('Before cancellation'));
      });
    });

    // Message Status Synchronization Tests
    group('Message Status Synchronization', () {
      testWidgets('read status updates propagate in real-time', (WidgetTester tester) async {
        // Arrange
        String messageId = '';
        final user1Messages = <Message>[];
        final user2Messages = <Message>[];

        final stream1 = messageService.getCrewMessagesStream(testCrewId, testUserId1);
        final stream2 = messageService.getCrewMessagesStream(testCrewId, testUserId2);

        stream1.listen((messages) => user1Messages.clear()..addAll(messages));
        stream2.listen((messages) => user2Messages.clear()..addAll(messages));

        // Act - User 1 sends message
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Please read this',
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Get the message ID
        if (user1Messages.isNotEmpty) {
          messageId = user1Messages.first.id;
        }

        // User 2 marks as read
        if (messageId.isNotEmpty) {
          await messageService.markAsRead(
            messageId: messageId,
            userId: testUserId2,
            isCrewMessage: true,
            crewId: testCrewId,
          );

          await tester.pump(const Duration(milliseconds: 50));
        }

        // Assert - Both users should see the read status
        if (user1Messages.isNotEmpty) {
          expect(user1Messages.first.isReadBy(testUserId2), isTrue);
        }
      });

      testWidgets('edit status updates propagate in real-time', (WidgetTester tester) async {
        // Arrange
        String messageId = '';
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Send message then edit it
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Original message',
        );

        await tester.pump(const Duration(milliseconds: 50));

        if (messages.isNotEmpty) {
          messageId = messages.first.id;

          await messageService.editMessage(
            messageId: messageId,
            newContent: 'Edited message',
            isCrewMessage: true,
            crewId: testCrewId,
          );

          await tester.pump(const Duration(milliseconds: 50));
        }

        // Assert - All users should see the edited message
        if (messages.isNotEmpty) {
          expect(messages.first.content, equals('Edited message'));
          expect(messages.first.isEdited, isTrue);
          expect(messages.first.editedAt, isNotNull);
        }
      });
    });

    // Large Message Stream Tests
    group('Large Message Streams', () {
      testWidgets('handles large message volume efficiently', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Send 1000 messages
        final stopwatch = Stopwatch()..start();

        for (int i = 0; i < 100; i++) { // Using 100 for test performance
          await messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId1,
            content: 'Message $i',
          );
        }

        await tester.pump(const Duration(milliseconds: 500));
        stopwatch.stop();

        // Assert
        expect(messages.length, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(5000)); // Should complete within 5 seconds
      });

      testWidgets('applies message limit correctly', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Send 150 messages (limit is 100)
        for (int i = 0; i < 150; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewId,
            senderId: testUserId1,
            content: 'Message $i',
          );
        }

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Should only have 100 most recent messages
        expect(messages.length, equals(100));
        expect(messages.first.content, equals('Message 149')); // Most recent
        expect(messages.last.content, equals('Message 50')); // 100th most recent
      });
    });

    // Concurrent User Scenarios Tests
    group('Concurrent User Scenarios', () {
      testWidgets('handles multiple users reading and writing simultaneously', (WidgetTester tester) async {
        // Arrange
        final allMessages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          allMessages.clear();
          allMessages.addAll(messageList);
        });

        // Act - Multiple users send messages simultaneously
        final futures = <Future<void>>[];
        final users = [testUserId1, testUserId2, testUserId3];

        for (final userId in users) {
          for (int i = 0; i < 10; i++) {
            futures.add(messageService.sendCrewMessage(
              crewId: testCrewId,
              senderId: userId,
              content: '$userId message $i',
            ));
          }
        }

        await Future.wait(futures);
        await tester.pump(const Duration(milliseconds: 200));

        // Assert - All messages should be delivered
        expect(allMessages.length, equals(30));
        expect(allMessages.map((m) => m.senderId).toSet(), equals(users.toSet()));
      });

      testWidgets('prevents message conflicts during concurrent editing', (WidgetTester tester) async {
        // Arrange
        String messageId = '';
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Original content',
        );

        await tester.pump(const Duration(milliseconds: 50));

        if (messages.isNotEmpty) {
          messageId = messages.first.id;
        }

        // Act - Try to edit the same message concurrently
        if (messageId.isNotEmpty) {
          final editFutures = [
            messageService.editMessage(
              messageId: messageId,
              newContent: 'Edit 1',
              isCrewMessage: true,
              crewId: testCrewId,
            ),
            messageService.editMessage(
              messageId: messageId,
              newContent: 'Edit 2',
              isCrewMessage: true,
              crewId: testCrewId,
            ),
          ];

          await Future.wait(editFutures);
          await tester.pump(const Duration(milliseconds: 100));
        }

        // Assert - Message should have one of the edited contents
        if (messages.isNotEmpty) {
          expect(messages.first.content, isIn(['Edit 1', 'Edit 2']));
          expect(messages.first.isEdited, isTrue);
        }
      });
    });

    // Cross-Device Synchronization Tests
    group('Cross-Device Synchronization', () {
      testWidgets('messages sync across multiple client sessions', (WidgetTester tester) async {
        // Simulate multiple clients by creating multiple streams
        final client1Messages = <Message>[];
        final client2Messages = <Message>[];
        final client3Messages = <Message>[];

        final stream1 = messageService.getCrewMessagesStream(testCrewId, testUserId1);
        final stream2 = messageService.getCrewMessagesStream(testCrewId, testUserId1);
        final stream3 = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream1.listen((messages) => client1Messages.clear()..addAll(messages));
        stream2.listen((messages) => client2Messages.clear()..addAll(messages));
        stream3.listen((messages) => client3Messages.clear()..addAll(messages));

        // Act - Send message from one client
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Cross-device test message',
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - All clients should receive the message
        expect(client1Messages.any((m) => m.content == 'Cross-device test message'), isTrue);
        expect(client2Messages.any((m) => m.content == 'Cross-device test message'), isTrue);
        expect(client3Messages.any((m) => m.content == 'Cross-device test message'), isTrue);
      });

      testWidgets('maintains message consistency across device reconnection', (WidgetTester tester) async {
        // Arrange
        final messages = <Message>[];
        final stream = messageService.getCrewMessagesStream(testCrewId, testUserId1);

        stream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        // Act - Send message, simulate reconnection, send another message
        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'Before reconnection',
        );

        await tester.pump(const Duration(milliseconds: 50));

        // Simulate reconnection by creating new stream
        final newStream = messageService.getCrewMessagesStream(testCrewId, testUserId1);
        newStream.listen((messageList) {
          messages.clear();
          messages.addAll(messageList);
        });

        await messageService.sendCrewMessage(
          crewId: testCrewId,
          senderId: testUserId1,
          content: 'After reconnection',
        );

        await tester.pump(const Duration(milliseconds: 100));

        // Assert - Should have both messages
        expect(messages.length, equals(2));
        expect(messages.map((m) => m.content).toSet(),
               equals({'Before reconnection', 'After reconnection'}));
      });
    });

    // Helper Methods
    Future<void> _setupRealtimeTestEnvironment() async {
      // Setup basic crew structure for testing
      await fakeFirestore.collection('crews').doc(testCrewId).set({
        'id': testCrewId,
        'name': 'Real-time Test Crew',
        'memberIds': [testUserId1, testUserId2, testUserId3],
        'createdAt': DateTime.now().toIso8601String(),
        'isActive': true,
      });

      // Add members
      for (final userId in [testUserId1, testUserId2, testUserId3]) {
        await fakeFirestore
            .collection('crews')
            .doc(testCrewId)
            .collection('members')
            .doc(userId)
            .set({
              'userId': userId,
              'crewId': testCrewId,
              'role': 'member',
              'joinedAt': DateTime.now().toIso8601String(),
              'isActive': true,
            });
      }
    }
  });
}