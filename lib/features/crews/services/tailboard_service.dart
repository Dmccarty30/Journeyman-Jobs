import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/tailboard.dart';

class TailboardService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Firestore collections
  CollectionReference get crewsCollection => _firestore.collection('crews');

  // Get Tailboard data for a crew
  Future<Tailboard?> getTailboard(String crewId) async {
    try {
      final doc = await crewsCollection.doc(crewId).collection('tailboard').doc('main').get();
      if (doc.exists) {
        return Tailboard.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      throw Exception('Error getting tailboard: $e');
    }
  }

  // Stream Tailboard data for real-time updates
  Stream<Tailboard?> getTailboardStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('tailboard')
        .doc('main')
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        return Tailboard.fromMap(snapshot.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Get job feed stream
  Stream<List<SuggestedJob>> getJobFeedStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('tailboard')
        .doc('main')
        .collection('jobFeed')
        .orderBy('suggestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => SuggestedJob.fromMap(doc.data())).toList();
    });
  }

  // Get activity stream
  Stream<List<ActivityItem>> getActivityStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('tailboard')
        .doc('main')
        .collection('activity')
        .orderBy('timestamp', descending: true)
        .limit(50) // Limit to recent activities
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => ActivityItem.fromFirestore(doc)).toList();
    });
  }

  // Get posts stream
  Stream<List<TailboardPost>> getPostsStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('tailboard')
        .doc('main')
        .collection('posts')
        .orderBy('postedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => TailboardPost.fromMap(doc.data())).toList();
    });
  }

  // Add a suggested job to the feed
  Future<void> addSuggestedJob({
    required String crewId,
    required String jobId,
    required int matchScore,
    required List<String> matchReasons,
    required JobSuggestionSource source,
  }) async {
    try {
      final suggestedJob = SuggestedJob(
        jobId: jobId,
        matchScore: matchScore,
        matchReasons: matchReasons,
        viewedByMemberIds: [],
        appliedMemberIds: [],
        savedByMemberIds: [],
        suggestedAt: DateTime.now(),
        source: source,
      );

      await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .add(suggestedJob.toMap());
    } catch (e) {
      throw Exception('Error adding suggested job: $e');
    }
  }

  // Mark a suggested job as viewed by a member
  Future<void> markJobAsViewed({
    required String crewId,
    required String jobId,
    required String memberId,
  }) async {
    try {
      final querySnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (final doc in querySnapshot.docs) {
        final suggestedJob = SuggestedJob.fromMap(doc.data());
        final updatedJob = suggestedJob.markAsViewed(memberId);
        await doc.reference.update(updatedJob.toMap());
      }
    } catch (e) {
      throw Exception('Error marking job as viewed: $e');
    }
  }

  // Mark a suggested job as applied by a member
  Future<void> markJobAsApplied({
    required String crewId,
    required String jobId,
    required String memberId,
  }) async {
    try {
      final querySnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (final doc in querySnapshot.docs) {
        final suggestedJob = SuggestedJob.fromMap(doc.data());
        final updatedJob = suggestedJob.markAsApplied(memberId);
        await doc.reference.update(updatedJob.toMap());
      }
    } catch (e) {
      throw Exception('Error marking job as applied: $e');
    }
  }

  // Mark a suggested job as saved by a member
  Future<void> markJobAsSaved({
    required String crewId,
    required String jobId,
    required String memberId,
  }) async {
    try {
      final querySnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('jobId', isEqualTo: jobId)
          .get();

      for (final doc in querySnapshot.docs) {
        final suggestedJob = SuggestedJob.fromMap(doc.data());
        final updatedJob = suggestedJob.markAsSaved(memberId);
        await doc.reference.update(updatedJob.toMap());
      }
    } catch (e) {
      throw Exception('Error marking job as saved: $e');
    }
  }

  // Add an activity item
  Future<void> addActivityItem({
    required String crewId,
    required String actorId,
    required ActivityType type,
    required Map<String, dynamic> data,
  }) async {
    try {
      final activityItem = ActivityItem(
        id: '', // Will be set by Firestore
        actorId: actorId,
        type: type,
        data: data,
        timestamp: DateTime.now(),
        readByMemberIds: [],
      );

      await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('activity')
          .add(activityItem.toFirestore());
    } catch (e) {
      throw Exception('Error adding activity item: $e');
    }
  }

  // Post an announcement
  Future<void> postAnnouncement({
    required String crewId,
    required String authorId,
    required String content,
    List<String> attachmentUrls = const [],
  }) async {
    try {
      final post = TailboardPost(
        id: '', // Will be set by Firestore
        authorId: authorId,
        content: content,
        attachmentUrls: attachmentUrls,
        isPinned: false,
        reactions: {},
        comments: [],
        postedAt: DateTime.now(),
      );

      await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('posts')
          .add(post.toMap());

      // Also add as activity
      await addActivityItem(
        crewId: crewId,
        actorId: authorId,
        type: ActivityType.announcementPosted,
        data: {
          'content': content,
          'hasAttachments': attachmentUrls.isNotEmpty,
        },
      );
    } catch (e) {
      throw Exception('Error posting announcement: $e');
    }
  }

  // Add a reaction to a post
  Future<void> addReactionToPost({
    required String crewId,
    required String postId,
    required String memberId,
    required ReactionType reaction,
  }) async {
    try {
      final postDoc = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('posts')
          .doc(postId)
          .get();

      if (postDoc.exists) {
        final post = TailboardPost.fromMap(postDoc.data()!);
        final updatedPost = post.addReaction(memberId, reaction);
        await postDoc.reference.update(updatedPost.toMap());
      }
    } catch (e) {
      throw Exception('Error adding reaction: $e');
    }
  }

  // Remove a reaction from a post
  Future<void> removeReactionFromPost({
    required String crewId,
    required String postId,
    required String memberId,
  }) async {
    try {
      final postDoc = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('posts')
          .doc(postId)
          .get();

      if (postDoc.exists) {
        final post = TailboardPost.fromMap(postDoc.data()!);
        final updatedPost = post.removeReaction(memberId);
        await postDoc.reference.update(updatedPost.toMap());
      }
    } catch (e) {
      throw Exception('Error removing reaction: $e');
    }
  }

  // Add a comment to a post
  Future<void> addCommentToPost({
    required String crewId,
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      final comment = Comment(
        id: '', // Will be set by Firestore
        authorId: authorId,
        content: content,
        postedAt: DateTime.now(),
      );

      final postDoc = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('posts')
          .doc(postId)
          .get();

      if (postDoc.exists) {
        final post = TailboardPost.fromMap(postDoc.data()!);
        final updatedPost = post.addComment(comment);
        await postDoc.reference.update(updatedPost.toMap());
      }
    } catch (e) {
      throw Exception('Error adding comment: $e');
    }
  }

  // Toggle pin status of a post
  Future<void> togglePinPost({
    required String crewId,
    required String postId,
  }) async {
    try {
      final postDoc = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('posts')
          .doc(postId)
          .get();

      if (postDoc.exists) {
        final post = TailboardPost.fromMap(postDoc.data()!);
        final updatedPost = post.togglePin();
        await postDoc.reference.update(updatedPost.toMap());
      }
    } catch (e) {
      throw Exception('Error toggling pin status: $e');
    }
  }

  // Mark activity as read by member
  Future<void> markActivityAsRead({
    required String crewId,
    required String activityId,
    required String memberId,
  }) async {
    try {
      final activityDoc = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('activity')
          .doc(activityId)
          .get();

      if (activityDoc.exists) {
        final activity = ActivityItem.fromFirestore(activityDoc);
        final updatedActivity = activity.markAsRead(memberId);
        await activityDoc.reference.update(updatedActivity.toFirestore());
      }
    } catch (e) {
      throw Exception('Error marking activity as read: $e');
    }
  }

  // Get unread activity count for member
  Future<int> getUnreadActivityCount({
    required String crewId,
    required String memberId,
  }) async {
    try {
      final snapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('activity')
          .get();

      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final activity = ActivityItem.fromFirestore(doc);
        if (!activity.isReadBy(memberId)) {
          unreadCount++;
        }
      }
      return unreadCount;
    } catch (e) {
      return 0;
    }
  }

  // Update tailboard analytics
  Future<void> updateAnalytics({
    required String crewId,
    required TailboardAnalytics analytics,
  }) async {
    try {
      await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .update({
        'analytics': analytics.toMap(),
        'lastUpdated': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Error updating analytics: $e');
    }
  }

  // Clean up old suggested jobs (older than 30 days)
  Future<void> cleanupOldSuggestedJobs(String crewId) async {
    try {
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final snapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('suggestedAt', isLessThan: thirtyDaysAgo.toIso8601String())
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }
      await batch.commit();
    } catch (e) {
      // Log error but don't throw - cleanup is not critical
    }
  }
}
