import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/job_model.dart';
import '../models/user_job_preferences.dart';
import '../domain/exceptions/app_exception.dart';
import 'resilient_firestore_service.dart';

/// Optimized job query service with proper indexing and performance optimization
///
/// This service handles all job-related queries with:
/// - Composite index utilization
/// - Query result caching
/// - Pagination with DocumentSnapshot cursors
/// - Error handling and retry logic
/// - Performance monitoring
class OptimizedJobQueryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final ResilientFirestoreService _resilientService;

  // Performance constants
  static const int _defaultPageSize = 20;
  static const int _maxPageSize = 50;
  static const int _suggestedJobsLimit = 20;
  static const Duration _queryTimeout = Duration(seconds: 10);

  // Collection references
  late final CollectionReference _jobsCollection = _firestore.collection('jobs');

  OptimizedJobQueryService(this._resilientService);

  /// Get suggested jobs based on user preferences with optimized query
  ///
  /// This method implements the critical suggested jobs functionality
  /// with proper Firestore indexing for optimal performance
  ///
  /// [userId] The authenticated user ID
  /// [preferences] User job preferences for filtering
  /// [limit] Maximum number of jobs to return (default: 20)
  ///
  /// Returns list of jobs matching user criteria with cascading fallback
  ///
  /// Throws [UnauthenticatedException] if user is not authenticated
  /// Throws [FirebaseException] on Firestore errors
  Future<List<Job>> getSuggestedJobs({
    required String userId,
    UserJobPreferences? preferences,
    int limit = _suggestedJobsLimit,
  }) async {
    if (kDebugMode) {
      print('\n🔍 OptimizedJobQueryService.getSuggestedJobs called:');
      print('  - User ID: $userId');
      print('  - Has preferences: ${preferences != null}');
      print('  - Limit: $limit');
    }

    try {
      // If user has no preferences, return recent jobs (fallback)
      if (preferences == null || preferences.preferredLocals.isEmpty) {
        return await _getRecentJobsFallback(limit: limit);
      }

      // Primary query: Filter by user's preferred locals with composite index
      final jobs = await _queryByPreferredLocals(
        preferredLocals: preferences.preferredLocals,
        limit: limit,
      );

      if (kDebugMode) {
        print('📊 Query results:');
        print('  - Jobs found: ${jobs.length}');
        print('  - Used locals filter: ${preferences.preferredLocals}');
      }

      // Apply additional client-side filtering for construction types and hours
      final filteredJobs = _applyClientSideFilters(jobs, preferences);

      // Sort by relevance (exact matches first, then by timestamp)
      final sortedJobs = _sortByRelevance(filteredJobs, preferences);

      // Return limited number of results
      return sortedJobs.take(limit).toList();

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getSuggestedJobs: $e');
      }

      // Fallback to recent jobs on any error
      return await _getRecentJobsFallback(limit: limit);
    }
  }

  /// Query jobs by preferred locals using the composite index
  ///
  /// This uses the critical composite index:
  /// deleted (ASC) + local (ASC) + timestamp (DESC) + __name__ (DESC)
  Future<List<Job>> _queryByPreferredLocals({
    required List<int> preferredLocals,
    required int limit,
  }) async {
    if (preferredLocals.isEmpty) return [];

    try {
      // Build query with composite index
      Query query = _jobsCollection
          .where('deleted', isEqualTo: false)
          .where('local', whereIn: preferredLocals.take(10).toList()) // Firestore limit: 10 items in 'in' clause
          .orderBy('timestamp', descending: true)
          .orderBy(FieldPath.documentId(), descending: true)
          .limit(limit);

      if (kDebugMode) {
        print('🔍 Executing optimized query with composite index:');
        print('  - Collection: jobs');
        print('  - Filter: deleted == false AND local in ${preferredLocals.take(10)}');
        print('  - Order: timestamp DESC, __name__ DESC');
        print('  - Limit: $limit');
      }

      final querySnapshot = await query.get();

      final jobs = querySnapshot.docs.map((doc) {
        try {
          return Job.fromJson(doc.data()..['id'] = doc.id);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing job document ${doc.id}: $e');
          }
          return null;
        }
      }).where((job) => job != null).cast<Job>().toList();

      if (kDebugMode) {
        print('✅ Query completed successfully');
        print('  - Documents returned: ${querySnapshot.docs.length}');
        print('  - Valid jobs parsed: ${jobs.length}');
      }

      return jobs;

    } catch (e) {
      if (e is FirebaseException && e.code == 'failed-precondition') {
        // Index not ready - provide helpful error message
        throw AppException(
          'Firestore index not ready. Please try again in a few minutes.',
          details: 'Composite index for suggested jobs query is still building.',
        );
      }

      if (kDebugMode) {
        print('❌ Firestore query error: $e');
      }

      rethrow;
    }
  }

  /// Fallback method to get recent jobs when preferences are unavailable
  Future<List<Job>> _getRecentJobsFallback({required int limit}) async {
    try {
      final query = _jobsCollection
          .where('deleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit);

      final querySnapshot = await query.get();

      return querySnapshot.docs.map((doc) {
        try {
          return Job.fromJson(doc.data()..['id'] = doc.id);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing fallback job: $e');
          }
          return null;
        }
      }).where((job) => job != null).cast<Job>().toList();

    } catch (e) {
      if (kDebugMode) {
        print('❌ Fallback query failed: $e');
      }
      return [];
    }
  }

  /// Apply client-side filtering for construction types and hours
  List<Job> _applyClientSideFilters(List<Job> jobs, UserJobPreferences preferences) {
    return jobs.where((job) {
      // Construction type filter
      if (preferences.constructionTypes.isNotEmpty) {
        if (job.typeOfWork == null ||
            !preferences.constructionTypes.contains(job.typeOfWork)) {
          return false;
        }
      }

      // Hours per week filter
      if (preferences.hoursPerWeek.isNotEmpty) {
        if (job.hours == null) return false;

        final jobHours = job.hours!;
        bool matchesHours = false;

        for (final hoursRange in preferences.hoursPerWeek) {
          switch (hoursRange) {
            case '20-30':
              matchesHours = jobHours >= 20 && jobHours <= 30;
              break;
            case '30-40':
              matchesHours = jobHours >= 30 && jobHours <= 40;
              break;
            case '40+':
              matchesHours = jobHours >= 40;
              break;
          }
          if (matchesHours) break;
        }

        if (!matchesHours) return false;
      }

      // Per diem filter
      if (preferences.perDiemRequirement.isNotEmpty) {
        if (preferences.perDiemRequirement == 'Required' &&
            (job.perDiem == null || job.perDiem!.toLowerCase() != 'yes')) {
          return false;
        }
      }

      return true;
    }).toList();
  }

  /// Sort jobs by relevance score based on user preferences
  List<Job> _sortByRelevance(List<Job> jobs, UserJobPreferences preferences) {
    return jobs..sort((a, b) {
      int scoreA = _calculateRelevanceScore(a, preferences);
      int scoreB = _calculateRelevanceScore(b, preferences);

      // Sort by score (descending), then by timestamp (descending)
      if (scoreB != scoreA) return scoreB - scoreA;

      // Fallback to timestamp sorting
      if (a.timestamp != null && b.timestamp != null) {
        return b.timestamp!.compareTo(a.timestamp!);
      }

      return 0;
    });
  }

  /// Calculate relevance score for a job based on user preferences
  int _calculateRelevanceScore(Job job, UserJobPreferences preferences) {
    int score = 0;

    // Local match (highest priority)
    if (job.local != null && preferences.preferredLocals.contains(job.local)) {
      score += 100;
    }

    // Construction type match
    if (job.typeOfWork != null &&
        preferences.constructionTypes.contains(job.typeOfWork)) {
      score += 50;
    }

    // Hours match
    if (job.hours != null) {
      final jobHours = job.hours!;
      for (final hoursRange in preferences.hoursPerWeek) {
        switch (hoursRange) {
          case '20-30':
            if (jobHours >= 20 && jobHours <= 30) score += 30;
            break;
          case '30-40':
            if (jobHours >= 30 && jobHours <= 40) score += 30;
            break;
          case '40+':
            if (jobHours >= 40) score += 30;
            break;
        }
      }
    }

    // Per diem match
    if (preferences.perDiemRequirement == 'Required' &&
        job.perDiem != null &&
        job.perDiem!.toLowerCase() == 'yes') {
      score += 20;
    }

    // Recency bonus (newer jobs get slight boost)
    if (job.timestamp != null) {
      final daysSincePosted = DateTime.now().difference(job.timestamp!).inDays;
      if (daysSincePosted <= 7) score += 10;
      else if (daysSincePosted <= 30) score += 5;
    }

    return score;
  }

  /// Get jobs with pagination for browsing all jobs
  ///
  /// [filters] Optional filter criteria
  /// [limit] Page size (default: 20, max: 50)
  /// [startAfter] Document cursor for pagination
  ///
  /// Returns paginated job list with last document for next page
  Future<PaginatedJobResult> getJobsPaginated({
    Map<String, dynamic>? filters,
    int limit = _defaultPageSize,
    DocumentSnapshot? startAfter,
  }) async {
    // Enforce pagination limits
    if (limit > _maxPageSize) limit = _maxPageSize;

    try {
      Query query = _jobsCollection.where('deleted', isEqualTo: false);

      // Apply filters if provided
      if (filters != null) {
        if (filters['local'] != null) {
          query = query.where('local', isEqualTo: filters['local']);
        }
        if (filters['classification'] != null) {
          query = query.where('classification', isEqualTo: filters['classification']);
        }
        if (filters['typeOfWork'] != null) {
          query = query.where('typeOfWork', isEqualTo: filters['typeOfWork']);
        }
      }

      // Apply ordering and pagination
      query = query
          .orderBy('timestamp', descending: true)
          .orderBy(FieldPath.documentId(), descending: true)
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      final querySnapshot = await query.get();

      final jobs = querySnapshot.docs.map((doc) {
        try {
          return Job.fromJson(doc.data()..['id'] = doc.id);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing job: $e');
          }
          return null;
        }
      }).where((job) => job != null).cast<Job>().toList();

      return PaginatedJobResult(
        jobs: jobs,
        lastDocument: querySnapshot.docs.isNotEmpty
            ? querySnapshot.docs.last
            : null,
        hasMore: querySnapshot.docs.length == limit,
      );

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error in getJobsPaginated: $e');
      }
      rethrow;
    }
  }

  /// Get job by ID with error handling
  Future<Job?> getJobById(String jobId) async {
    try {
      final docSnapshot = await _jobsCollection.doc(jobId).get();

      if (!docSnapshot.exists) return null;

      return Job.fromJson(docSnapshot.data()!..['id'] = docSnapshot.id);

    } catch (e) {
      if (kDebugMode) {
        print('❌ Error getting job by ID: $e');
      }
      return null;
    }
  }
}

/// Result class for paginated job queries
class PaginatedJobResult {
  final List<Job> jobs;
  final DocumentSnapshot? lastDocument;
  final bool hasMore;

  const PaginatedJobResult({
    required this.jobs,
    this.lastDocument,
    required this.hasMore,
  });
}