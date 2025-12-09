import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/models/message_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('MessageModel Tests', () {
    test('fromFirestore creates valid MessageModel from complete Firestore data', () async {
      final testData = {
        'authorId': 'author123',
        'content': 'Test message content',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'readBy': ['user1', 'user2'],
        'mediaUrls': ['https://example.com/image1.jpg'],
        'deleted': false,
      };

      final docRef = fakeFirestore.collection('messages').doc('msg123');
      await docRef.set(testData);

      final doc = await docRef.get();
      final message = MessageModel.fromFirestore(doc);

      expect(message.id, 'msg123');
      expect(message.authorId, 'author123');
      expect(message.content, 'Test message content');
      expect(message.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(message.readBy, ['user1', 'user2']);
      expect(message.mediaUrls, ['https://example.com/image1.jpg']);
      expect(message.deleted, false);
      expect(message.isValid(), true);
    });

    test('fromFirestore handles missing optional fields with defaults', () async {
      final incompleteData = {
        'authorId': 'author123',
        'content': 'Test message content',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      final docRef = fakeFirestore.collection('messages').doc('msg123');
      await docRef.set(incompleteData);

      final doc = await docRef.get();
      final message = MessageModel.fromFirestore(doc);

      expect(message.id, 'msg123');
      expect(message.authorId, 'author123');
      expect(message.content, 'Test message content');
      expect(message.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(message.readBy, []);
      expect(message.mediaUrls, []);
      expect(message.deleted, false);
      expect(message.isValid(), true);
    });

    test('toFirestore serializes MessageModel correctly including deleted field', () {
      final message = MessageModel(
        id: 'msg123',
        authorId: 'author123',
        content: 'Test message content',
        timestamp: Timestamp.fromDate(DateTime(2023, 1, 1)),
        readBy: ['user1'],
        mediaUrls: ['https://example.com/image1.jpg'],
        deleted: true,
      );

      final firestoreData = message.toFirestore();

      expect(firestoreData['authorId'], 'author123');
      expect(firestoreData['content'], 'Test message content');
      expect(firestoreData['timestamp'], Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(firestoreData['readBy'], ['user1']);
      expect(firestoreData['mediaUrls'], ['https://example.com/image1.jpg']);
      expect(firestoreData['deleted'], true);
    });

    test('isValid returns true for valid data', () {
      final message = MessageModel(
        id: 'msg123',
        authorId: 'author123',
        content: 'Valid content',
        timestamp: Timestamp.now(),
      );

      expect(message.isValid(), true);
    });

    test('isValid returns false for empty authorId', () {
      final message = MessageModel(
        id: 'msg123',
        authorId: '',
        content: 'Valid content',
        timestamp: Timestamp.now(),
      );

      expect(message.isValid(), false);
    });

    test('isValid returns false for empty content', () {
      final message = MessageModel(
        id: 'msg123',
        authorId: 'author123',
        content: '',
        timestamp: Timestamp.now(),
      );

      expect(message.isValid(), false);
    });

    test('fromFirestore handles deleted message', () async {
      final testData = {
        'authorId': 'author123',
        'content': 'Deleted message',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'deleted': true,
      };

      final docRef = fakeFirestore.collection('messages').doc('msg123');
      await docRef.set(testData);

      final doc = await docRef.get();
      final message = MessageModel.fromFirestore(doc);

      expect(message.deleted, true);
      expect(message.isValid(), true); // Still valid even if deleted
    });
  });
}