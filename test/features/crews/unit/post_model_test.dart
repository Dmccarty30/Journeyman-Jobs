import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import '../../../../lib/models/post_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
  });

  group('PostModel Tests', () {
    test('fromFirestore creates valid PostModel from complete Firestore data', () async {
      final testData = {
        'authorId': 'author123',
        'content': 'Test post content',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'likes': ['like1', 'like2'],
        'mediaUrls': ['https://example.com/image1.jpg', 'https://example.com/image2.jpg'],
        'deleted': false,
      };

      final docRef = fakeFirestore.collection('posts').doc('post123');
      await docRef.set(testData);

      final doc = await docRef.get();
      final post = PostModel.fromFirestore(doc);

      expect(post.id, 'post123');
      expect(post.authorId, 'author123');
      expect(post.content, 'Test post content');
      expect(post.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(post.likes, ['like1', 'like2']);
      expect(post.mediaUrls, ['https://example.com/image1.jpg', 'https://example.com/image2.jpg']);
      expect(post.deleted, false);
      expect(post.isValid(), true);
    });

    test('fromFirestore handles missing optional fields with defaults', () async {
      final incompleteData = {
        'authorId': 'author123',
        'content': 'Test post content',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
      };

      final docRef = fakeFirestore.collection('posts').doc('post123');
      await docRef.set(incompleteData);

      final doc = await docRef.get();
      final post = PostModel.fromFirestore(doc);

      expect(post.id, 'post123');
      expect(post.authorId, 'author123');
      expect(post.content, 'Test post content');
      expect(post.timestamp, Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(post.likes, []);
      expect(post.mediaUrls, []);
      expect(post.deleted, false);
      expect(post.isValid(), true);
    });

    test('toFirestore serializes PostModel correctly including deleted field', () {
      final post = PostModel(
        id: 'post123',
        authorId: 'author123',
        content: 'Test post content',
        timestamp: Timestamp.fromDate(DateTime(2023, 1, 1)),
        likes: ['like1', 'like2'],
        mediaUrls: ['https://example.com/image1.jpg'],
        deleted: true,
      );

      final firestoreData = post.toFirestore();

      expect(firestoreData['authorId'], 'author123');
      expect(firestoreData['content'], 'Test post content');
      expect(firestoreData['timestamp'], Timestamp.fromDate(DateTime(2023, 1, 1)));
      expect(firestoreData['likes'], ['like1', 'like2']);
      expect(firestoreData['mediaUrls'], ['https://example.com/image1.jpg']);
      expect(firestoreData['deleted'], true);
    });

    test('isValid returns true for valid data', () {
      final post = PostModel(
        id: 'post123',
        authorId: 'author123',
        content: 'Valid content',
        timestamp: Timestamp.now(),
      );

      expect(post.isValid(), true);
    });

    test('isValid returns false for empty authorId', () {
      final post = PostModel(
        id: 'post123',
        authorId: '',
        content: 'Valid content',
        timestamp: Timestamp.now(),
      );

      expect(post.isValid(), false);
    });

    test('isValid returns false for empty content', () {
      final post = PostModel(
        id: 'post123',
        authorId: 'author123',
        content: '',
        timestamp: Timestamp.now(),
      );

      expect(post.isValid(), false);
    });

    test('fromFirestore handles deleted post', () async {
      final testData = {
        'authorId': 'author123',
        'content': 'Deleted post',
        'timestamp': Timestamp.fromDate(DateTime(2023, 1, 1)),
        'deleted': true,
      };

      final docRef = fakeFirestore.collection('posts').doc('post123');
      await docRef.set(testData);

      final doc = await docRef.get();
      final post = PostModel.fromFirestore(doc);

      expect(post.deleted, true);
      expect(post.isValid(), true); // Still valid even if deleted
    });
  });
}