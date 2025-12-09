import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeyman_jobs/services/database_service.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/post_model.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/message_model.dart';

void main() {
  late FakeFirebaseFirestore fakeFirestore;
  late DatabaseService databaseService;
  late User mockUser;

  setUp(() {
    fakeFirestore = FakeFirebaseFirestore();
    databaseService = DatabaseService();
    mockUser = User(
      uid: 'test-user',
      username: 'testuser',
      classification: 'Journeyman',
      homeLocal: 123,
      role: 'member',
      email: 'test@example.com',
      lastActive: Timestamp.now(),
      firstName: 'Test',
      lastName: 'User',
    );
  });

  group('TailboardService Integration Tests - End-to-End with Mock Firestore', () {
    setUp(() async {
      // Setup test user
      await fakeFirestore.collection('users').doc('test-user').set(mockUser.toFirestore());

      // Setup test crew
      final testCrew = Crew(
        id: 'test-crew',
        name: 'Test Crew',
        foremanId: 'test-user',
        memberIds: ['test-user'],
        jobPreferences: {},
        stats: CrewStats(),
      );
      await fakeFirestore.collection('crews').doc('test-crew').set(testCrew.toFirestore());
    });

    test('streamFeedPosts returns paginated posts with real-time updates', () async {
      // Create initial posts
      final post1 = PostModel(
        id: '',
        authorId: 'test-user',
        content: 'First post',
        timestamp: Timestamp.now(),
      );
      final postRef1 = await fakeFirestore.collection('crews').doc('test-crew').collection('feedPosts').add(post1.toFirestore());

      final post2 = PostModel(
        id: '',
        authorId: 'test-user',
        content: 'Second post',
        timestamp: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 5))),
      );
      await fakeFirestore.collection('crews').doc('test-crew').collection('feedPosts').add(post2.toFirestore());

      // Test stream
      final stream = databaseService.streamFeedPosts('test-crew', limit: 1);
      final completer = expectLater(stream, emitsInOrder([
        emitsInOrder([isA<PostModel>()]), // First page with 1 post
        emitsInOrder([isA<PostModel>()]), // Still 1, as limit=1
      ]));

      // Wait for initial load
      await Future.delayed(Duration(milliseconds: 100));

      // Add new post for real-time update
      final post3 = PostModel(
        id: '',
        authorId: 'test-user',
        content: 'Third post - real-time',
        timestamp: Timestamp.now(),
      );
      await fakeFirestore.collection('crews').doc('test-crew').collection('feedPosts').add(post3.toFirestore());

      await Future.delayed(Duration(milliseconds: 100));
      completer.complete();

      // Verify pagination with startAfter
      final firstPostDoc = await fakeFirestore.collection('crews').doc('test-crew').collection('feedPosts').doc(postRef1.id).get();
      final paginatedStream = databaseService.streamFeedPosts('test-crew', limit: 1, startAfter: firstPostDoc);
      await expectLater(paginatedStream, emitsInOrder([isA<List<PostModel>>().having((l) => l.isNotEmpty, 'has posts', true)]));
    });

    test('CRUD operations with auth - create, read, update, delete post', () async {
      // Create post
      final testPost = PostModel(
        id: '',
        authorId: 'test-user',
        content: 'CRUD test post',
        timestamp: Timestamp.now(),
      );
      await databaseService.createPost('test-crew', testPost);

      // Read post via stream
      final stream = databaseService.streamFeedPosts('test-crew');
      final posts = await stream.first;
      final createdPost = posts.firstWhere((p) => p.content == 'CRUD test post');
      expect(createdPost.content, 'CRUD test post');

      // Update post (like it)
      await databaseService.likePost('test-crew', createdPost.id);

      // Verify update
      final updatedPosts = await stream.first;
      final likedPost = updatedPosts.firstWhere((p) => p.id == createdPost.id);
      expect(likedPost.likes, contains('test-user'));

      // Delete post
      await databaseService.deletePost('test-crew', likedPost.id, 'test-user');

      // Verify deletion (deleted flag set)
      final deletedPosts = await stream.first;
      final deletedPost = deletedPosts.firstWhere((p) => p.id == likedPost.id);
      expect(deletedPost.deleted, true);
    });

    test('streamJobs returns paginated matching jobs with real-time updates', () async {
      // Create matching job
      final matchingJob = JobModel(
        id: '',
        authorId: 'test-user',
        content: 'Matching job',
        timestamp: Timestamp.now(),
        deleted: false,
      );
      await fakeFirestore.collection('crews').doc('test-crew').collection('jobs').add({
        ...matchingJob.toFirestore(),
        'matchesCriteria': true,
      });

      // Create non-matching job
      final nonMatchingJob = JobModel(
        id: '',
        authorId: 'test-user',
        content: 'Non-matching job',
        timestamp: Timestamp.now(),
        deleted: false,
      );
      await fakeFirestore.collection('crews').doc('test-crew').collection('jobs').add({
        ...nonMatchingJob.toFirestore(),
        'matchesCriteria': false,
      });

      // Test stream - should only get matching
      final stream = databaseService.streamJobs('test-crew', limit: 10);
      final jobs = await stream.first;
      expect(jobs.length, 1); // Only matching
      expect(jobs.first.content, 'Matching job');

      // Add new matching job for real-time
      final newMatchingJob = JobModel(
        id: '',
        authorId: 'test-user',
        content: 'New matching job',
        timestamp: Timestamp.now(),
        deleted: false,
      );
      await fakeFirestore.collection('crews').doc('test-crew').collection('jobs').add({
        ...newMatchingJob.toFirestore(),
        'matchesCriteria': true,
      });

      // Wait for real-time update
      await Future.delayed(Duration(milliseconds: 100));
      final updatedJobs = await stream.first;
      expect(updatedJobs.length, 2);
    });

    test('CRUD operations for jobs with auth', () async {
      // Create job
      final testJob = JobModel(
        id: '',
        authorId: 'test-user',
        content: 'Test job',
        timestamp: Timestamp.now(),
        deleted: false,
      );
      await databaseService.createJob('test-crew', testJob);

      // Read via stream
      final stream = databaseService.streamJobs('test-crew');
      final jobs = await stream.first;
      final createdJob = jobs.first;
      expect(createdJob.content, 'Test job');

      // Update job (e.g., mark as deleted)
      await databaseService.deleteJob('test-crew', createdJob.id, 'test-user');

      // Verify
      final deletedJobs = await stream.first;
      expect(deletedJobs.length, 0); // Should not show deleted
    });
  });
}