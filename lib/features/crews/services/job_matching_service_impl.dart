import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:rxdart/rxdart.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/services/job_sharing_service_impl.dart';
import 'package:journeyman_jobs/models/job_model.dart'; // Canonical Job model

/// Service responsible for matching jobs with crews based on preferences and performance
class JobMatchingService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final JobSharingService _jobSharingService;
  StreamSubscription<QuerySnapshot>? _jobListener;

  JobMatchingService(this._jobSharingService);

  /// Start listening for new jobs and auto-share with matching crews
  void startJobMatchingListener() {
    _jobListener?.cancel();
    _jobListener = _firestore
        .collection('jobs')
        .where('isActive', isEqualTo: true)
        .snapshots()
        .listen((snapshot) {
      for (final change in snapshot.docChanges) {
        if (change.type == DocumentChangeType.added) {
          final newJob = change.doc.data() as Map<String, dynamic>;
          _processNewJob(newJob);
        }
      }
    });
  }

  /// Stop listening for new jobs
  void stopJobMatchingListener() {
    _jobListener?.cancel();
    _jobListener = null;
  }

  /// Process a new job and match it with crews
  Future<void> _processNewJob(Map<String, dynamic> job) async {
    try {
      final jobId = job['id'] as String;
      
      // Get all crews with autoShareEnabled = true
      final crewsSnapshot = await _firestore
          .collection('crews')
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
      if (kDebugMode) {
        print('Error in job matching: $e');
      }
      // TODO: Implement proper error handling
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
    // Extract GeoPoint from jobDetails nested map
    final jobDetails = job['jobDetails'] as Map<String, dynamic>?;
    final jobLocation = jobDetails?['location'] as GeoPoint?;

    if (jobLocation != null && crew.location != null) {
      final distance = _calculateDistance(
        jobLocation.latitude,
        jobLocation.longitude,
        crew.location!.latitude,
        crew.location!.longitude
      );
      // Score inversely proportional to distance (up to 20%)
      final maxDistance = 100.0; // km
      final locationScore = ((maxDistance - distance) / maxDistance).clamp(0.0, 1.0) * 20.0;
      score += locationScore;
    }

    // Crew performance history (10%)
    final successRate = crew.stats.successfulPlacements /
                       (crew.stats.totalApplications > 0 ? crew.stats.totalApplications : 1);
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

  /// Get filtered jobs stream for a crew based on preferences with cascading fallback
  ///
  /// **IMPLEMENTATION:**
  /// - Listens to BOTH job changes AND crew preference changes in real-time
  /// - Uses simple orderBy query (NO composite index required)
  /// - Client-side filtering for all criteria
  /// - 4-level cascade with accumulation (max 20 jobs)
  /// - GUARANTEES jobs display when they exist in Firestore
  ///
  /// Architecture:
  /// 1. Listens to crew document for preference changes
  /// 2. Fetches 100 recent jobs with simple orderBy query
  /// 3. Implements 4-level cascade with accumulation:
  ///    - Level 1: Exact match (job types + construction types + wage + distance)
  ///    - Level 2: Relaxed match (job types + construction types only)
  ///    - Level 3: Minimal match (job types only)
  ///    - Level 4: Fallback to recent jobs (no filtering)
  /// 4. Each level adds unique jobs to results (Set-based deduplication)
  /// 5. Preserves timestamp descending order
  ///
  /// UX guarantee: Crews ALWAYS see jobs when jobs exist in Firestore
  /// UX guarantee: Jobs update IMMEDIATELY when foreman changes preferences
  Stream<List<Job>> getCrewFilteredJobsStream(String crewId) {
    const int kMaxSuggested = 20;

    if (kDebugMode) {
      print('\n🔍 DEBUG: Starting real-time crew filtered jobs stream for crew: $crewId');
    }

    // Listen to crew document for preference changes
    final crewStream = _firestore.collection('crews').doc(crewId).snapshots();

    // Listen to jobs collection for job changes
    final jobsStream = _firestore
        .collection('jobs')
        .orderBy('timestamp', descending: true)
        .limit(100)
        .snapshots();

    // Combine both streams to react to changes in either crew preferences or jobs
    return CombineLatestStream.combine2(
      crewStream,
      jobsStream,
      (crewDoc, jobsSnapshot) {
        // Parse updated crew data
        final crewData = crewDoc.data() as Map<String, dynamic>?;
        if (crewData == null || !crewDoc.exists) {
          if (kDebugMode) {
            print('⚠️ Crew document not found: $crewId');
          }
          return <Job>[];
        }

        crewData['id'] = crewDoc.id;
        final crew = Crew.fromFirestore(crewDoc);
        final prefs = crew.preferences;

        if (kDebugMode) {
          print('\n🔍 DEBUG: Processing real-time update for ${crew.name}');
          print('📋 Crew preferences:');
          print('  - Job types: ${prefs.jobTypes}');
          print('  - Construction types: ${prefs.constructionTypes}');
          print('  - Min hourly rate: \$${prefs.minHourlyRate}');
          print('  - Max distance: ${prefs.maxDistanceMiles} miles');
        }

        // Convert jobs to Job objects with client-side deleted filter
        final allJobs = jobsSnapshot.docs
            .map((doc) {
              final data = doc.data();
              data['id'] = doc.id;
              return Job.fromJson(data);
            })
            .where((job) => job.deleted != true) // Client-side deleted filter
            .toList();

        if (kDebugMode) {
          print('📊 Fetched ${allJobs.length} jobs from Firestore for crew ${crew.name}');
        }

        // 4-LEVEL CASCADE WITH ACCUMULATION

        final List<Job> results = [];
        final Set<String> seenIds = {}; // Deduplication

        /// Helper to add jobs from a tier without duplicates
        void addTier(List<Job> tier) {
          for (final job in tier) {
            if (seenIds.add(job.id)) {
              // Only add if new
              results.add(job);
              if (results.length >= kMaxSuggested) break;
            }
          }
        }

        // LEVEL 1: Exact match (all criteria)
        final l1 = _filterJobsExact(allJobs, prefs, crew);
        if (l1.isNotEmpty) {
          _logCascade(
            level: 'L1',
            matchedCount: l1.length,
            totalCount: allJobs.length,
            extraInfo: 'Exact match - ${crew.name}',
          );
          addTier(l1);
        }

        // LEVEL 2: Relaxed match (job types + construction types)
        if (results.length < kMaxSuggested) {
          final l2 = _filterJobsRelaxed(allJobs, prefs, crew);
          if (l2.isNotEmpty) {
            _logCascade(
              level: 'L2',
              matchedCount: l2.length,
              totalCount: allJobs.length,
              extraInfo: 'Relaxed match - ${crew.name}',
            );
            addTier(l2);
          }
        }

        // LEVEL 3: Job types only match
        if (results.length < kMaxSuggested) {
          final l3 = _filterJobsByTypes(allJobs, prefs);
          if (l3.isNotEmpty) {
            _logCascade(
              level: 'L3',
              matchedCount: l3.length,
              totalCount: allJobs.length,
              extraInfo: 'Job types only - ${crew.name}',
            );
            addTier(l3);
          }
        }

        // LEVEL 4: Fallback to recent (all remaining jobs)
        if (results.length < kMaxSuggested) {
          _logCascade(
            level: 'L4',
            matchedCount: allJobs.length,
            totalCount: allJobs.length,
            extraInfo: 'Fallback (recent jobs) - ${crew.name}',
          );
          addTier(allJobs);
        }

        _logCascade(
          level: 'FINAL',
          matchedCount: results.length,
          totalCount: allJobs.length,
          extraInfo: 'Total crew jobs - ${crew.name}',
        );

        return results;
      },
    );
  }

  /// Helper: Log cascade results for debugging
  /// Only logs in debug mode using assert() to ensure zero overhead in production
  void _logCascade({
    required String level,
    required int matchedCount,
    required int totalCount,
    String? extraInfo,
  }) {
    assert(() {
      if (kDebugMode) {
        final emoji = level == 'L1'
            ? '✅'
            : level == 'L2'
                ? '⚠️'
                : level == 'L3'
                    ? '🔵'
                    : level == 'L4'
                        ? '🔴'
                        : '📊';

        print('$emoji CREW CASCADE $level: $matchedCount/$totalCount jobs${extraInfo != null ? ' - $extraInfo' : ''}');
      }
      return true;
    }());
  }

  /// Helper: Check if job matches job types
  bool _matchesJobTypes(Job job, List<String> jobTypes) {
    if (jobTypes.isEmpty) return true;

    // Handle typeOfWork as String (nullable)
    if (job.typeOfWork == null || job.typeOfWork!.isEmpty) return false;

    final jobType = job.typeOfWork!.toLowerCase();

    // Check if any crew job type is contained in the job's type
    return jobTypes.any((type) => jobType.contains(type.toLowerCase()));
  }

  /// Helper: Check if job matches construction types
  bool _matchesConstructionTypes(Job job, List<String> constructionTypes) {
    if (constructionTypes.isEmpty) return true;

    // Handle typeOfWork as String (nullable)
    if (job.typeOfWork == null || job.typeOfWork!.isEmpty) return false;

    final jobType = job.typeOfWork!.toLowerCase();

    // Check if any construction type is contained in the job's type
    return constructionTypes.any((type) => jobType.contains(type.toLowerCase()));
  }

  /// Helper: Check if job meets minimum wage requirement
  bool _meetsWageRequirement(Job job, CrewPreferences prefs) {
    if (prefs.minHourlyRate == null) return true;

    final jobWage = job.wage;
    if (jobWage == null) return false;

    return jobWage >= prefs.minHourlyRate!;
  }

  /// Helper: Check if job is within distance range
  ///
  /// Extracts GeoPoint from job.jobDetails['location'] and compares with crew.location
  /// Returns true if within range, or if either location is missing (skip distance filter)
  bool _withinDistanceRange(Job job, CrewPreferences prefs, Crew crew) {
    if (prefs.maxDistanceMiles == null) return true;
    if (crew.location == null) return true;

    // Extract GeoPoint from jobDetails nested map
    final jobLocation = job.jobDetails['location'] as GeoPoint?;
    if (jobLocation == null) return true; // Skip distance filter if job has no coordinates

    final distance = _calculateDistance(
      jobLocation.latitude,
      jobLocation.longitude,
      crew.location!.latitude,
      crew.location!.longitude,
    );

    // Convert km to miles (1 km = 0.621371 miles)
    final distanceMiles = distance * 0.621371;

    return distanceMiles <= prefs.maxDistanceMiles!;
  }

  /// Helper: Filter jobs with exact match on ALL crew preferences
  /// Returns jobs matching: job types + construction types + wage + distance
  List<Job> _filterJobsExact(List<Job> jobs, CrewPreferences prefs, Crew crew) {
    return jobs.where((job) {
      final jobTypesOk = _matchesJobTypes(job, prefs.jobTypes);
      final constructionTypesOk = _matchesConstructionTypes(job, prefs.constructionTypes);
      final wageOk = _meetsWageRequirement(job, prefs);
      final distanceOk = _withinDistanceRange(job, prefs, crew);

      return jobTypesOk && constructionTypesOk && wageOk && distanceOk;
    }).toList();
  }

  /// Helper: Filter jobs with relaxed match (job types + construction types only)
  /// Ignores: wage and distance requirements
  List<Job> _filterJobsRelaxed(List<Job> jobs, CrewPreferences prefs, Crew crew) {
    return jobs.where((job) {
      final jobTypesOk = _matchesJobTypes(job, prefs.jobTypes);
      final constructionTypesOk = _matchesConstructionTypes(job, prefs.constructionTypes);

      return jobTypesOk && constructionTypesOk;
    }).toList();
  }

  /// Helper: Filter jobs by job types only
  /// Most minimal matching - just job type preference
  List<Job> _filterJobsByTypes(List<Job> jobs, CrewPreferences prefs) {
    if (prefs.jobTypes.isEmpty) return const [];
    return jobs.where((job) => _matchesJobTypes(job, prefs.jobTypes)).toList();
  }
}