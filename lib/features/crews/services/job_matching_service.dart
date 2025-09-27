import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/services/job_sharing_service.dart';

class JobMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobSharingService _jobSharingService;
  StreamSubscription<QuerySnapshot>? _jobListener;

  JobMatchingService(this._jobSharingService);

  // Collections
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  CollectionReference get crewsCollection => _firestore.collection('crews');

  /// Start listening for new jobs and auto-share with matching crews
  void startJobMatchingListener() {
    _jobListener?.cancel();
    _jobListener = jobsCollection
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newJob = change.doc.data() as Map<String, dynamic>;
          _matchAndShareJob(newJob);
        }
      }
    });
  }

  /// Match the job with crews and auto-share if enabled
  Future<void> _matchAndShareJob(Map<String, dynamic> job) async {
    try {
      final jobId = job['id'] as String;
      
      // Get all crews with autoShareEnabled = true
      final crewsSnapshot = await crewsCollection
          .where('preferences.autoShareEnabled', isEqualTo: true)
          .where('isActive', isEqualTo: true)
          .get();

      // Store crew match scores
      final crewMatches = <String, double>{};

      // Calculate match scores for all eligible crews
      for (final crewDoc in crewsSnapshot.docs) {
        final crew = Crew.fromFirestore(crewDoc);
        final score = _calculateMatchScore(job, crew, crew.preferences);
        
        // Only consider crews with score above threshold
        if (score >= 60.0) {
          crewMatches[crew.id] = score;
        }
      }

      // Sort crews by match score and share job with top matches
      final sortedCrews = crewMatches.entries.toList()
        ..sort((a, b) => b.value.compareTo(a.value));

      // Share with top 5 matching crews
      for (var i = 0; i < sortedCrews.length && i < 5; i++) {
        final crewId = sortedCrews[i].key;
        final score = sortedCrews[i].value.toStringAsFixed(1);

        await _jobSharingService.shareToCrews(
          jobId: jobId,
          crewIds: [crewId],
          sharedByUserId: 'system',
          comment: 'Auto-shared: This job matches your crew preferences (Match Score: $score%)',
        );
      }
    } catch (e) {
      print('Error in job matching: $e');
      // TODO: Add proper error handling
    }
  }

  /// Calculate match score between job and crew preferences
  double _calculateMatchScore(
    Map<String, dynamic> job,
    Crew crew,
    CrewPreferences preferences,
  ) {
    double score = 0.0;
    
    // Job type match (40%)
    if (preferences.jobTypes.contains(job['jobType'])) {
      score += 40.0;
    }
    
    // Pay rate match (30%)
    final jobRate = (job['hourlyRate'] as num).toDouble();
    final prefRate = preferences.minHourlyRate ?? 0.0;
    if (jobRate >= prefRate) {
      // Score based on how much above minimum rate (up to 30%)
      final rateScore = ((jobRate - prefRate) / prefRate).clamp(0.0, 1.0) * 30.0;
      score += rateScore;
    }
    
    // Location proximity (20%)
    final jobLocation = job['location'] as GeoPoint?;
    final crewLocation = crew.location;
    if (jobLocation != null && crewLocation != null) {
      final distance = _calculateDistance(
        jobLocation.latitude,
        jobLocation.longitude,
        crewLocation.latitude,
        crewLocation.longitude
      );
      // Score inversely proportional to distance (up to 20%)
      final maxDistance = 100.0; // km
      final locationScore = ((maxDistance - distance) / maxDistance).clamp(0.0, 1.0) * 20.0;
      score += locationScore;
    }
    
    // Crew performance history (10%)
    final stats = crew.stats;
    // Score based on application success rate
    final successRate = stats.successfulPlacements / (stats.totalApplications > 0 ? stats.totalApplications : 1);
    score += successRate * 10.0;
      
    return score;
  }
  
  /// Calculate distance between two points using Haversine formula
  double _calculateDistance(double lat1, double lon1, double lat2, double lon2) {
    const R = 6371.0; // Earth's radius in km
    final dLat = _toRadians(lat2 - lat1);
    final dLon = _toRadians(lon2 - lon1);
    
    final a = sin(dLat / 2) * sin(dLat / 2) +
        cos(_toRadians(lat1)) * cos(_toRadians(lat2)) *
        sin(dLon / 2) * sin(dLon / 2);
    
    final c = 2 * atan2(sqrt(a), sqrt(1 - a));
    return R * c;
  }
  
  double _toRadians(double deg) => deg * pi / 180.0;

  /// Stop the job matching listener
  void stopJobMatchingListener() {
    _jobListener?.cancel();
    // TODO: Implement proper cleanup of listeners
  }
}