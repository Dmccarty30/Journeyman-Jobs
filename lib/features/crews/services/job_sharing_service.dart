import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/tailboard.dart';

class JobSharingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Firestore collections
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  CollectionReference get crewsCollection => _firestore.collection('crews');

  /// Share a job to specific crews
  Future<void> shareToCrews({
    required String jobId,
    required List<String> crewIds,
    required String sharedByUserId,
    String? comment,
  }) async {
    try {
      // Get job details first
      final jobDoc = await jobsCollection.doc(jobId).get();
      if (!jobDoc.exists) {
        throw Exception('Job not found');
      }

      final jobData = jobDoc.data() as Map<String, dynamic>;
      final batch = _firestore.batch();

      for (final crewId in crewIds) {
        // Check if user is member of the crew
        final crewDoc = await crewsCollection.doc(crewId).get();
        if (!crewDoc.exists) continue;

        final crewData = crewDoc.data() as Map<String, dynamic>;
        final memberIds = List<String>.from(crewData['memberIds'] ?? []);
        
        if (!memberIds.contains(sharedByUserId)) {
          continue; // Skip if user is not a member of this crew
        }

        // Add suggested job to crew's tailboard
        final suggestedJob = SuggestedJob(
          jobId: jobId,
          matchScore: 100, // Manually shared jobs get max score
          matchReasons: [
            'Shared by crew member',
            if (comment != null && comment.isNotEmpty) comment,
            'Job ID: $jobId',
          ],
          viewedByMemberIds: [],
          appliedMemberIds: [],
          savedByMemberIds: [],
          suggestedAt: DateTime.now(),
          source: JobSuggestionSource.memberShare,
        );

        // Add to crew's job feed
        final jobFeedRef = crewsCollection
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('jobFeed')
            .doc();

        batch.set(jobFeedRef, suggestedJob.toMap());

        // Add activity item for job share
        final activityRef = crewsCollection
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('activity')
            .doc();

        final activityItem = ActivityItem(
          id: '',
          actorId: sharedByUserId,
          type: ActivityType.jobShared,
          data: {
            'jobId': jobId,
            'jobTitle': jobData['jobTitle'] ?? 'Unknown Job',
            'sharedToCrews': crewIds.length,
            'comment': comment ?? '',
          },
          timestamp: DateTime.now(),
          readByMemberIds: [],
        );

        batch.set(activityRef, activityItem.toFirestore());

        // Update crew stats
        final crewStatsRef = crewsCollection.doc(crewId);
        batch.update(crewStatsRef, {
          'stats.totalJobsShared': FieldValue.increment(1),
          'stats.lastActivityAt': Timestamp.fromDate(DateTime.now()),
        });
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error sharing job to crews: $e');
    }
  }

  /// Get jobs that have been shared to a specific crew
  Future<List<SuggestedJob>> getCrewSharedJobs(String crewId) async {
    try {
      final snapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('source', isEqualTo: 'memberShare')
          .orderBy('suggestedAt', descending: true)
          .get();

      return snapshot.docs
          .map((doc) => SuggestedJob.fromMap(doc.data()))
          .toList();
    } catch (e) {
      throw Exception('Error getting crew shared jobs: $e');
    }
  }

  /// Get crew-shared jobs stream for real-time updates
  Stream<List<SuggestedJob>> getCrewSharedJobsStream(String crewId) {
    return crewsCollection
        .doc(crewId)
        .collection('tailboard')
        .doc('main')
        .collection('jobFeed')
        .where('source', isEqualTo: 'memberShare')
        .orderBy('suggestedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs
          .map((doc) => SuggestedJob.fromMap(doc.data()))
          .toList();
    });
  }

  /// Get all jobs shared by a specific user across all crews
  Future<List<Map<String, dynamic>>> getUserSharedJobs(String userId) async {
    try {
      final List<Map<String, dynamic>> sharedJobs = [];

      // Get all crews where the user is a member
      final crewsSnapshot = await crewsCollection
          .where('memberIds', arrayContains: userId)
          .get();

      for (final crewDoc in crewsSnapshot.docs) {
        final crewId = crewDoc.id;
        
        // Get job shares by this user in this crew
        final jobSharesSnapshot = await crewsCollection
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('activity')
            .where('type', isEqualTo: 'jobShared')
            .where('actorId', isEqualTo: userId)
            .orderBy('timestamp', descending: true)
            .get();

        for (final activityDoc in jobSharesSnapshot.docs) {
          final activityData = activityDoc.data();
          final crewData = crewDoc.data() as Map<String, dynamic>?;
          sharedJobs.add({
            'crewId': crewId,
            'crewName': crewData?['name'] ?? 'Unknown Crew',
            'jobId': activityData['data']?['jobId'] ?? '',
            'jobTitle': activityData['data']?['jobTitle'] ?? 'Unknown Job',
            'sharedAt': activityData['timestamp'],
            'comment': activityData['data']?['comment'] ?? '',
          });
        }
      }

      return sharedJobs;
    } catch (e) {
      throw Exception('Error getting user shared jobs: $e');
    }
  }

  /// Get job sharing analytics for a crew
  Future<Map<String, dynamic>> getCrewJobSharingAnalytics(String crewId) async {
    try {
      // Get total job shares in the last 30 days
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final jobSharesSnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('activity')
          .where('type', isEqualTo: 'jobShared')
          .where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final memberShareCount = jobSharesSnapshot.docs.length;

      // Get total suggested jobs (including auto-shares and AI matches)
      final suggestedJobsSnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .get();

      final totalSuggestedJobs = suggestedJobsSnapshot.docs.length;

      // Get member share breakdown by source
      final memberSharesBySource = <String, int>{};
      for (final doc in jobSharesSnapshot.docs) {
        final data = doc.data();
        final source = data['data']?['source'] ?? 'unknown';
        memberSharesBySource[source] = (memberSharesBySource[source] ?? 0) + 1;
      }

      return {
        'totalMemberShares': memberShareCount,
        'totalSuggestedJobs': totalSuggestedJobs,
        'memberShareRate': totalSuggestedJobs > 0 ? (memberShareCount / totalSuggestedJobs) * 100 : 0,
        'memberSharesBySource': memberSharesBySource,
        'period': 'Last 30 days',
      };
    } catch (e) {
      throw Exception('Error getting crew job sharing analytics: $e');
    }
  }

  /// Remove a job share from a crew
  Future<void> removeJobShare({
    required String jobId,
    required String crewId,
    required String userId,
  }) async {
    try {
      // Check if user has permission to remove shares
      final crewDoc = await crewsCollection.doc(crewId).get();
      if (!crewDoc.exists) return;

      final crewData = crewDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(crewData['memberIds'] ?? []);
      final roles = Map<String, dynamic>.from(crewData['roles'] ?? {});
      final userRole = roles[userId];

      // Only allow removal by the person who shared it or crew admins
      final isForeman = userRole == 'foreman';
      final isLead = userRole == 'lead';

      if (!isForeman && !isLead && !memberIds.contains(userId)) {
        throw Exception('Insufficient permissions to remove job share');
      }

      // Remove from job feed
      final jobFeedSnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('jobFeed')
          .where('jobId', isEqualTo: jobId)
          .where('source', isEqualTo: 'memberShare')
          .get();

      final batch = _firestore.batch();
      for (final doc in jobFeedSnapshot.docs) {
        batch.delete(doc.reference);
      }

      // Remove related activity items
      final activitySnapshot = await crewsCollection
          .doc(crewId)
          .collection('tailboard')
          .doc('main')
          .collection('activity')
          .where('type', isEqualTo: 'jobShared')
          .where('actorId', isEqualTo: userId)
          .get();

      for (final doc in activitySnapshot.docs) {
        final activityData = doc.data();
        if (activityData['data']?['jobId'] == jobId) {
          batch.delete(doc.reference);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error removing job share: $e');
    }
  }

  /// Get trending jobs shared across multiple crews
  Future<List<Map<String, dynamic>>> getTrendingSharedJobs({
    int limit = 10,
    int minShareCount = 2,
  }) async {
    try {
      // This is a simplified implementation
      // In a real app, you might want to use Cloud Functions for complex aggregations
      
      final Map<String, Map<String, dynamic>> jobShareCounts = {};
      
      // Get all crews
      final crewsSnapshot = await crewsCollection.get();
      
      for (final crewDoc in crewsSnapshot.docs) {
        final crewId = crewDoc.id;
        
        // Get member shares for this crew
        final jobSharesSnapshot = await crewsCollection
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('jobFeed')
            .where('source', isEqualTo: 'memberShare')
            .get();

        for (final shareDoc in jobSharesSnapshot.docs) {
          final shareData = shareDoc.data();
          final jobId = shareData['jobId'] as String;
          
          if (jobShareCounts.containsKey(jobId)) {
            jobShareCounts[jobId]!['shareCount'] = jobShareCounts[jobId]!['shareCount'] + 1;
            jobShareCounts[jobId]!['crewIds'].add(crewId);
          } else {
            jobShareCounts[jobId] = {
              'jobId': jobId,
              'shareCount': 1,
              'crewIds': [crewId],
              'firstSharedAt': shareData['suggestedAt'],
            };
          }
        }
      }

      // Filter by minimum share count and sort
      final trendingJobs = jobShareCounts.values
          .where((job) => job['shareCount'] >= minShareCount)
          .toList()
        ..sort((a, b) => b['shareCount'].compareTo(a['shareCount']));

      return trendingJobs.take(limit).toList();
    } catch (e) {
      throw Exception('Error getting trending shared jobs: $e');
    }
  }

  /// Share a job with a comment to specific crews
  Future<void> shareJobWithComment({
    required String jobId,
    required List<String> crewIds,
    required String sharedByUserId,
    required String comment,
  }) async {
    return shareToCrews(
      jobId: jobId,
      crewIds: crewIds,
      sharedByUserId: sharedByUserId,
      comment: comment,
    );
  }

  /// Get job sharing history for a specific job
  Future<List<Map<String, dynamic>>> getJobSharingHistory(String jobId) async {
    try {
      final List<Map<String, dynamic>> sharingHistory = [];

      // Get all crews where this job was shared
      final crewsSnapshot = await crewsCollection.get();

      for (final crewDoc in crewsSnapshot.docs) {
        final crewId = crewDoc.id;
        
        // Get job share activities for this job in this crew
        final activitySnapshot = await crewsCollection
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('activity')
            .where('type', isEqualTo: 'jobShared')
            .where('data.jobId', isEqualTo: jobId)
            .orderBy('timestamp', descending: true)
            .get();

        for (final activityDoc in activitySnapshot.docs) {
          final activityData = activityDoc.data();
          final crewData = crewDoc.data() as Map<String, dynamic>?;
          sharingHistory.add({
            'crewId': crewId,
            'crewName': crewData?['name'] ?? 'Unknown Crew',
            'sharedBy': activityData['actorId'],
            'sharedAt': activityData['timestamp'],
            'comment': activityData['data']?['comment'] ?? '',
          });
        }
      }

      return sharingHistory;
    } catch (e) {
      throw Exception('Error getting job sharing history: $e');
    }
  }
}
