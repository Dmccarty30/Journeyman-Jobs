import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/shared_job.dart';
import 'package:journeyman_jobs/models/job_model.dart'; // Canonical Job model


class JobSharingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  JobSharingService();

  /// Share a job with specific crews
  Future<void> shareToCrews({
    required String jobId,
    required List<String> crewIds,
    required String sharedByUserId,
    String? comment,
    String shareType = 'manual', // 'manual' or 'auto'
  }) async {
    try {
      final batch = _firestore.batch();
      final now = DateTime.now();
      final shareId = _generateShareId(jobId, now);

      for (final crewId in crewIds) {
        // Check if share already exists to prevent duplicates
        final existingShare = await _getExistingShare(jobId, crewId);
        if (existingShare != null) {
          continue;
        }

        // Create shared job document
        final sharedJobRef = _firestore
            .collection('crews')
            .doc(crewId)
            .collection('shared_jobs')
            .doc(shareId);

        final sharedJobData = {
          'id': shareId,
          'jobId': jobId,
          'sharedByUserId': sharedByUserId,
          'sharedByCrewId': null, // Will be set by the calling code
          'shareType': shareType,
          'comment': comment ?? '',
          'sharedAt': Timestamp.fromDate(now),
          'isRead': false,
          'status': 'pending', // pending, accepted, rejected, expired
        };

        batch.set(sharedJobRef, sharedJobData);

        // Add to crew's activity feed
        final activityRef = _firestore
            .collection('crews')
            .doc(crewId)
            .collection('tailboard')
            .doc('main')
            .collection('activity')
            .doc();

        final activityData = {
          'id': activityRef.id,
          'type': 'job_shared',
          'jobId': jobId,
          'sharedByUserId': sharedByUserId,
          'comment': comment ?? 'Job shared with your crew',
          'timestamp': Timestamp.fromDate(now),
          'isRead': false,
        };

        batch.set(activityRef, activityData);

        // Update sharing crew's stats
        // Crew ID should be passed as a parameter to this method
        // await _crewService.incrementJobShared(crewId);
      }

      await batch.commit();

      // Update analytics
      await _updateSharingAnalytics(jobId, crewIds.length, shareType);
    } catch (e) {
      rethrow;
    }
  }

  /// Get existing share to prevent duplicates
  Future<DocumentSnapshot?> _getExistingShare(String jobId, String crewId) async {
    final query = _firestore
        .collection('crews')
        .doc(crewId)
        .collection('shared_jobs')
        .where('jobId', isEqualTo: jobId)
        .limit(1);

    final snapshot = await query.get();
    return snapshot.docs.isNotEmpty ? snapshot.docs.first : null;
  }

  /// Generate unique share ID
  String _generateShareId(String jobId, DateTime timestamp) {
    final timeStr = timestamp.millisecondsSinceEpoch.toString();
    return '${jobId}_$timeStr';
  }

  /// Update sharing analytics
  Future<void> _updateSharingAnalytics(String jobId, int shareCount, String shareType) async {
    final analyticsRef = _firestore.collection('analytics').doc('job_shares');
    
    await _firestore.runTransaction((transaction) async {
      final snapshot = await transaction.get(analyticsRef);
      final data = snapshot.data() ?? {};
      
      final totalShares = (data['totalShares'] ?? 0) + 1;
      final typeShares = Map<String, int>.from(data['typeShares'] ?? {});
      typeShares[shareType] = (typeShares[shareType] ?? 0) + 1;
      
      final jobShares = Map<String, int>.from(data['jobShares'] ?? {});
      jobShares[jobId] = (jobShares[jobId] ?? 0) + shareCount;
      
      transaction.set(analyticsRef, {
        'totalShares': totalShares,
        'typeShares': typeShares,
        'jobShares': jobShares,
        'lastUpdated': Timestamp.now(),
      });
    });
  }

  /// Get shared jobs for a crew
  Stream<List<SharedJob>> getSharedJobsStream(String crewId) {
    return _firestore
        .collection('crews')
        .doc(crewId)
        .collection('shared_jobs')
        .orderBy('sharedAt', descending: true)
        .snapshots()
        .asyncMap((snapshot) async {
      final sharedJobs = <SharedJob>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final jobId = data['jobId'] as String;
        
        // Fetch full job details
        final jobDoc = await _firestore.collection('jobs').doc(jobId).get();
        if (jobDoc.exists) {
          final job = Job.fromFirestore(jobDoc);
          
          sharedJobs.add(SharedJob(
            id: doc.id,
            job: job,
            sharedByUserId: data['sharedByUserId'],
            sharedAt: (data['sharedAt'] as Timestamp).toDate(),
            comment: data['comment'],
            matchScore: 0.0, // For shared jobs, no match score
            source: 'shared',
          ));
        }
      }
      return sharedJobs;
    });
  }

  /// Mark a shared job as read
  Future<void> markSharedJobAsRead(String crewId, String shareId) async {
    await _firestore
        .collection('crews')
        .doc(crewId)
        .collection('shared_jobs')
        .doc(shareId)
        .update({'isRead': true});
  }

  /// Get sharing analytics for a crew
  Future<Map<String, dynamic>> getCrewSharingAnalytics(String crewId) async {
    final crewDoc = await _firestore.collection('crews').doc(crewId).get();
    if (!crewDoc.exists) return {};

    final crew = Crew.fromFirestore(crewDoc);
    final sortedBreakdown = crew.stats.jobTypeBreakdown.entries
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return {
      'totalShares': crew.stats.totalJobsShared,
      'uniqueJobsShared': crew.stats.jobTypeBreakdown.length,
      'mostSharedJobTypes': sortedBreakdown.take(3).toList(),
    };
  }

  /// Clean up expired shares (older than 30 days)
  Future<void> cleanupExpiredShares() async {
    final cutoff = Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 30)));
    
    // This would typically be run as a scheduled function
    final crewsQuery = await _firestore.collection('crews').get();
    
    for (final crewDoc in crewsQuery.docs) {
      final crewId = crewDoc.id;
      final expiredQuery = _firestore
          .collection('crews')
          .doc(crewId)
          .collection('shared_jobs')
          .where('sharedAt', isLessThan: cutoff);
      
      final expiredSnapshot = await expiredQuery.get();
      if (expiredSnapshot.docs.isNotEmpty) {
        final batch = _firestore.batch();
        for (final doc in expiredSnapshot.docs) {
          batch.delete(doc.reference);
        }
        await batch.commit();
      }
    }
  }

  /// Check if user has permission to share jobs for their crew
  Future<bool> hasSharingPermission(String userId) async {
    // Need to implement a way to get the current crew for the user
    // For now, we'll assume the user has permission if they're in any crew
    // This should be updated to check the actual crew and user role
    return true;
  }
}