import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/services/crew_invitation_service.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  MockFirebaseAuth,
  CrewInvitationService,
])
import 'crew_messaging_service_test.mocks.dart';

void main() {
  group('CrewMessagingService', () {
    late CrewMessagingService messagingService;
    late MockFirebaseAuth mockAuth;
    late MockFirebaseFirestore mockFirestore;
    late MockCollectionReference mockMessagesCollection;
    late MockCollectionReference mockCrewsCollection;
    late MockDocumentReference mockMessageDoc;
    late MockDocumentReference mockCrewDoc;
    late MockDocumentSnapshot mockMessageSnapshot;
    late MockQuerySnapshot mockQuerySnapshot;
    late MockQuery mockQuery;

    setUp(() {
      mockAuth = MockFirebaseAuth();
      mockFirestore = MockFirebaseFirestore();
      mockMessagesCollection = MockCollectionReference();
      mockCrewsCollection = MockCollectionReference();
      mockMessageDoc = MockDocumentReference();
      mockCrewDoc = MockDocumentReference();
      mockMessageSnapshot = MockDocumentSnapshot();
      mockQuerySnapshot = MockQuerySnapshot();
      mockQuery = MockQuery();

      messagingService = CrewMessagingService(
        auth: mockAuth,
        firestore: mockFirestore,
      );

      // Setup default mock returns
      when(mockFirestore.collection('crewMessages')).thenReturn(mockMessagesCollection);
      when(mockFirestore.collection('crews')).thenReturn(mockCrewsCollection);
      when(mockMessagesCollection.add(any)).thenAnswer((_) async => mockMessageDoc);
      when(mockMessageDoc.id).thenReturn('test-message-id');
      when(mockMessageDoc.set(any)).thenAnswer((_) async => {});
      when(mockCrewsCollection.doc(any)).thenReturn(mockCrewDoc);
      when(mockCrewDoc.get()).thenAnswer((_) async => mockMessageSnapshot);
      when(mockMessageSnapshot.exists).thenReturn(true);
      when(mockMessagesCollection.doc(any)).thenReturn(mockMessageDoc);
      when(mockMessageDoc.get()).thenAnswer((_) async => mockMessageSnapshot);
      when(mockMessagesCollection.where(any)).thenReturn(mockQuery);
      when(mockQuery.orderBy(any)).thenReturn(mockQuery);
      when(mockQuery.limit(any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

      // Setup authenticated user
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test-user-id');
      when(mockAuth.currentUser).thenReturn(mockUser);
    });

    group('sendMessage', () {
      test('should send text message successfully', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final message = 'Test message';
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id', 'other-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act
        final result = await messagingService.sendMessage(
          crewId: crewId,
          content: message,
          type: CrewMessageType.text,
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.id, equals('test-message-id'));
        expect(result.crewId, equals(crewId));
        expect(result.senderId, equals('test-user-id'));
        expect(result.content, equals(message));
        expect(result.type, equals(CrewMessageType.text));
        expect(result.readStatus, hasLength(2)); // Sender and other member

        verify(mockMessagesCollection.add(any)).called(1);
        verify(mockCrewsCollection.doc(crewId)).called(1);
      });

      test('should send image message with metadata', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final imageUrl = 'https://example.com/image.jpg';
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act
        final result = await messagingService.sendMessage(
          crewId: crewId,
          content: 'Check out this image',
          type: CrewMessageType.image,
          mediaUrl: imageUrl,
          metadata: {'width': '800', 'height': '600'},
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(CrewMessageType.image));
        expect(result.mediaUrl, equals(imageUrl));
        expect(result.metadata, containsPair('width', '800'));
        expect(result.metadata, containsPair('height', '600'));
      });

      test('should throw exception when user is not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => messagingService.sendMessage(
            crewId: 'test-crew-id',
            content: 'Test message',
            type: CrewMessageType.text,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should throw exception when user is not crew member', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['other-user-id'], // Current user not in list
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act & Assert
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            content: 'Test message',
            type: CrewMessageType.text,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should validate message content length', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final longMessage = 'a' * 2000; // Exceeds max length
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act & Assert
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            content: longMessage,
            type: CrewMessageType.text,
          ),
          throwsA(isA<ArgumentError>()),
        );
      });
    });

    group('editMessage', () {
      test('should edit text message successfully', () async {
        // Arrange
        final messageId = 'test-message-id';
        final newContent = 'Updated message';
        final originalMessage = createMockMessage(
          id: messageId,
          content: 'Original message',
          senderId: 'test-user-id',
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());
        when(mockMessageSnapshot.exists).thenReturn(true);

        // Act
        final result = await messagingService.editMessage(
          messageId: messageId,
          newContent: newContent,
        );

        // Assert
        expect(result, isTrue);
        verify(mockMessageDoc.update(any)).called(1);

        final capturedUpdate = verify(mockMessageDoc.update(captureAny)).captured.single;
        expect(capturedUpdate['content'], equals(newContent));
        expect(capturedUpdate['editedAt'], isA<Timestamp>());
        expect(capturedUpdate['isEdited'], isTrue);
      });

      test('should not allow editing non-text messages', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          type: CrewMessageType.image,
          senderId: 'test-user-id',
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act & Assert
        expect(
          () => messagingService.editMessage(
            messageId: messageId,
            newContent: 'Updated caption',
          ),
          throwsA(isA<ArgumentError>()),
        );
      });

      test('should not allow editing other users messages', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          senderId: 'other-user-id', // Different from current user
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act & Assert
        expect(
          () => messagingService.editMessage(
            messageId: messageId,
            newContent: 'Updated message',
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should throw exception when message not found', () async {
        // Arrange
        when(mockMessageSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => messagingService.editMessage(
            messageId: 'non-existent-message',
            newContent: 'Updated message',
          ),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('deleteMessage', () {
      test('should delete own message successfully', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          senderId: 'test-user-id',
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());
        when(mockMessageDoc.delete()).thenAnswer((_) async => {});

        // Act
        final result = await messagingService.deleteMessage(messageId);

        // Assert
        expect(result, isTrue);
        verify(mockMessageDoc.delete()).called(1);
      });

      test('should allow crew foreman to delete any message', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          senderId: 'other-user-id',
          crewId: crewId,
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Mock crew data where current user is foreman
        final mockCrewData = {
          'id': crewId,
          'foremanId': 'test-user-id', // Current user is foreman
          'memberIds': ['test-user-id', 'other-user-id'],
        };
        when(mockCrewDoc.get()).thenAnswer((_) async => MockDocumentSnapshot());
        when(mockCrewsCollection.doc(crewId).get()).thenAnswer((_) async {
          final snapshot = MockDocumentSnapshot();
          when(snapshot.data()).thenReturn(mockCrewData);
          when(snapshot.exists).thenReturn(true);
          return snapshot;
        });
        when(mockMessageDoc.delete()).thenAnswer((_) async => {});

        // Act
        final result = await messagingService.deleteMessage(messageId);

        // Assert
        expect(result, isTrue);
        verify(mockMessageDoc.delete()).called(1);
      });

      test('should prevent deleting other users messages as non-foreman', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          senderId: 'other-user-id',
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act & Assert
        expect(
          () => messagingService.deleteMessage(messageId),
          throwsA(isA<Exception>()),
        );
      });
    });

    group('reactToMessage', () {
      test('should add reaction to message successfully', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          reactions: {},
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act
        final result = await messagingService.reactToMessage(
          messageId: messageId,
          emoji: '👍',
        );

        // Assert
        expect(result, isTrue);
        verify(mockMessageDoc.update(any)).called(1);

        final capturedUpdate = verify(mockMessageDoc.update(captureAny)).captured.single;
        expect(capturedUpdate['reactions']['test-user-id'], equals('👍'));
      });

      test('should update existing reaction', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          reactions: {'test-user-id': '👍'},
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act
        final result = await messagingService.reactToMessage(
          messageId: messageId,
          emoji: '❤️',
        );

        // Assert
        expect(result, isTrue);

        final capturedUpdate = verify(mockMessageDoc.update(captureAny)).captured.single;
        expect(capturedUpdate['reactions']['test-user-id'], equals('❤️'));
      });

      test('should remove reaction when same emoji is selected', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          reactions: {'test-user-id': '👍'},
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act
        final result = await messagingService.reactToMessage(
          messageId: messageId,
          emoji: '👍',
        );

        // Assert
        expect(result, isTrue);

        final capturedUpdate = verify(mockMessageDoc.update(captureAny)).captured.single;
        expect(capturedUpdate['reactions']['test-user-id'], isNull);
      });
    });

    group('markMessageAsRead', () {
      test('should mark message as read successfully', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          readStatus: [],
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act
        final result = await messagingService.markMessageAsRead(messageId);

        // Assert
        expect(result, isTrue);
        verify(mockMessageDoc.update(any)).called(1);

        final capturedUpdate = verify(mockMessageDoc.update(captureAny)).captured.single;
        final readStatusList = capturedUpdate['readStatus'] as List;
        expect(readStatusList, hasLength(1));
        expect(readStatusList.first['userId'], equals('test-user-id'));
        expect(readStatusList.first['readAt'], isA<Timestamp>());
      });

      test('should not mark own message as read', () async {
        // Arrange
        final messageId = 'test-message-id';
        final originalMessage = createMockMessage(
          id: messageId,
          senderId: 'test-user-id', // Current user sent this message
        );
        when(mockMessageSnapshot.data()).thenReturn(originalMessage.toFirestore());

        // Act
        final result = await messagingService.markMessageAsRead(messageId);

        // Assert
        expect(result, isFalse);
        verifyNever(mockMessageDoc.update(any));
      });
    });

    group('getMessageStream', () {
      test('should return stream of messages for crew', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final mockDataStream = Stream.fromIterable([
          createMockQuerySnapshot([createMockMessage(crewId: crewId)]),
        ]);
        when(mockQuery.snapshots()).thenAnswer((_) => mockDataStream);

        // Act
        final stream = messagingService.getMessageStream(crewId);

        // Assert
        expect(stream, isA<Stream<List<CrewMessage>>>());
        verify(mockMessagesCollection.where('crewId', isEqualTo: crewId)).called(1);
        verify(mockQuery.orderBy('createdAt', descending: true)).called(1);
        verify(mockQuery.limit(50)).called(1);
      });

      test('should filter messages by type when specified', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final messageType = CrewMessageType.text;
        final mockQuery2 = MockQuery();
        when(mockQuery.where('type', isEqualTo: messageType.name)).thenReturn(mockQuery2);
        when(mockQuery2.snapshots()).thenAnswer((_) => Stream.empty());

        // Act
        messagingService.getMessageStream(crewId, messageType: messageType);

        // Assert
        verify(mockQuery.where('type', isEqualTo: messageType.name)).called(1);
      });
    });

    group('sendLocationMessage', () {
      test('should send location message with coordinates', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final latitude = 40.7128;
        final longitude = -74.0060;
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act
        final result = await messagingService.sendLocationMessage(
          crewId: crewId,
          latitude: latitude,
          longitude: longitude,
          address: 'New York, NY',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(CrewMessageType.location));
        expect(result.metadata, containsPair('latitude', latitude));
        expect(result.metadata, containsPair('longitude', longitude));
        expect(result.metadata, containsPair('address', 'New York, NY'));
      });
    });

    group('sendJobShareMessage', () {
      test('should send job sharing message', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final jobId = 'test-job-id';
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);

        // Act
        final result = await messagingService.sendJobShareMessage(
          crewId: crewId,
          jobId: jobId,
          jobTitle: 'IBEW Journeyman Position',
          companyName: 'Electrical Contractors Inc',
        );

        // Assert
        expect(result, isNotNull);
        expect(result!.type, equals(CrewMessageType.jobShare));
        expect(result.metadata, containsPair('jobId', jobId));
        expect(result.metadata, containsPair('jobTitle', 'IBEW Journeyman Position'));
        expect(result.metadata, containsPair('companyName', 'Electrical Contractors Inc'));
      });
    });

    group('getUnreadMessageCount', () {
      test('should return count of unread messages for user', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final messages = [
          createMockMessage(
            crewId: crewId,
            senderId: 'other-user-id',
            readStatus: [], // Unread
          ),
          createMockMessage(
            crewId: crewId,
            senderId: 'other-user-id',
            readStatus: [
              MessageReadStatus(userId: 'test-user-id', readAt: DateTime.now()),
            ], // Read
          ),
        ];
        final mockDocList = messages.map((m) => createMockDocumentSnapshot(m)).toList();
        when(mockQuerySnapshot.docs).thenReturn(mockDocList);
        when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

        // Act
        final count = await messagingService.getUnreadMessageCount(crewId);

        // Assert
        expect(count, equals(1));
      });
    });

    group('Error handling', () {
      test('should handle Firestore exceptions gracefully', () async {
        // Arrange
        final crewId = 'test-crew-id';
        final mockCrewData = {
          'id': crewId,
          'memberIds': ['test-user-id'],
          'name': 'Test Crew',
        };
        when(mockMessageSnapshot.data()).thenReturn(mockCrewData);
        when(mockMessagesCollection.add(any)).thenThrow(FirebaseException(plugin: 'firestore'));

        // Act & Assert
        expect(
          () => messagingService.sendMessage(
            crewId: crewId,
            content: 'Test message',
            type: CrewMessageType.text,
          ),
          throwsA(isA<Exception>()),
        );
      });
    });
  });
}

// Helper methods for creating mock data

CrewMessage createMockMessage({
  String? id,
  String? crewId,
  String? senderId,
  String content = 'Test message',
  CrewMessageType type = CrewMessageType.text,
  Map<String, String>? reactions,
  List<MessageReadStatus>? readStatus,
}) {
  return CrewMessage(
    id: id ?? 'test-message-id',
    crewId: crewId ?? 'test-crew-id',
    senderId: senderId ?? 'test-sender-id',
    content: content,
    type: type,
    createdAt: DateTime.now(),
    editedAt: null,
    isEdited: false,
    mediaUrl: null,
    metadata: const {},
    readStatus: readStatus ?? [],
    reactions: reactions ?? {},
    replyToId: null,
    deletedAt: null,
  );
}

QuerySnapshot createMockQuerySnapshot(List<CrewMessage> messages) {
  final snapshot = MockQuerySnapshot();
  final docs = messages.map((m) => createMockDocumentSnapshot(m)).toList();
  when(snapshot.docs).thenReturn(docs);
  return snapshot;
}

DocumentSnapshot createMockDocumentSnapshot(CrewMessage message) {
  final doc = MockDocumentSnapshot();
  when(doc.id).thenReturn(message.id);
  when(doc.data()).thenReturn(message.toFirestore());
  when(doc.exists).thenReturn(true);
  return doc;
}

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}