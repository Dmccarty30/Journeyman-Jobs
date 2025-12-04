import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'firestore_service.dart';
import 'cache_service.dart';
import '../models/filter_criteria.dart';
import '../models/user_model.dart';

/// A resilient wrapper around FirestoreService that provides:
/// - Automatic retry logic for transient failures
/// - Exponential backoff for retry delays
/// - Proper error handling and classification
/// - Circuit breaker pattern for persistent failures
/// - Intelligent caching for frequently accessed data
class ResilientFirestoreService extends FirestoreService {
  final CacheService _cacheService = CacheService();
  static const int maxRetries = 3;
  static const Duration initialRetryDelay = Duration(seconds: 1);
  static const Duration maxRetryDelay = Duration(seconds: 10);
  static const Duration circuitBreakerTimeout = Duration(minutes: 5);

  // Circuit breaker state
  bool _circuitOpen = false;
  DateTime? _circuitOpenTime;
  int _failureCount = 0;

  @override
  Stream<QuerySnapshot> getJobs({
    int limit = FirestoreService.defaultPageSize,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    return _executeWithRetryStream(
      () => super.getJobs(
        limit: limit,
        startAfter: startAfter,
        filters: filters,
      ),
      operationName: 'getJobs',
    );
  }

  @override
  Stream<QuerySnapshot> getLocals({
    int limit = FirestoreService.defaultPageSize,
    DocumentSnapshot? startAfter,
    String? state,
  }) {
    return _executeWithRetryStream(
      () => super.getLocals(
        limit: limit,
        startAfter: startAfter,
        state: state,
      ),
      operationName: 'getLocals',
    );
  }

  @override
  Future<QuerySnapshot> searchLocals(
    String searchTerm, {
    int limit = FirestoreService.defaultPageSize,
    String? state,
  }) {
    return _executeWithRetryFuture(
      () => super.searchLocals(
        searchTerm,
        limit: limit,
        state: state,
      ),
      operationName: 'searchLocals',
    );
  }

  @override
  Future<DocumentSnapshot> getUser(String uid) {
    return _executeWithRetryFuture(
      () => super.getUser(uid),
      operationName: 'getUser',
    );
  }

  @override
  Future<void> createUser({
    required String uid,
    required Map<String, dynamic> userData,
  }) {
    return _executeWithRetryFuture(
      () => super.createUser(uid: uid, userData: userData),
      operationName: 'createUser',
    );
  }

  @override
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    final result = await _executeWithRetryFuture(
      () => super.updateUser(uid: uid, data: data),
      operationName: 'updateUser',
    );

    // Invalidate user cache after update
    await _cacheService.remove('${CacheService.userDataPrefix}$uid');

    return result;
  }

  @override
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _executeWithRetryStream(
      () => super.getUserStream(uid),
      operationName: 'getUserStream',
    );
  }

  /// Get user data with caching
  Future<Map<String, dynamic>?> getCachedUserData(String uid) async {
    // Try to get from cache first
    final cachedData = await _cacheService.getCachedUserData(uid);
    if (cachedData != null) {
      return cachedData;
    }

    // If not in cache, fetch from Firestore
    try {
      final doc = await getUser(uid);
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
          // Cache for future use
          await _cacheService.cacheUserData(uid, userData);
          return userData;
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching user data for caching: $e');
      }
    }

    return null;
  }

  /// Get jobs with advanced filtering capabilities
  Future<QuerySnapshot> getJobsWithFilter({
    required JobFilterCriteria filter,
    DocumentSnapshot? startAfter,
    int limit = FirestoreService.defaultPageSize,
  }) async {
    return _executeWithRetryFuture(
      () async {
        Query query = FirebaseFirestore.instance.collection('jobs');

        // Apply filters based on criteria
        if (filter.classifications?.isNotEmpty ?? false) {
          query =
              query.where('classification', whereIn: filter.classifications);
        }

        if (filter.localNumbers?.isNotEmpty ?? false) {
          query = query.where('local', whereIn: filter.localNumbers);
        }

        if (filter.constructionTypes?.isNotEmpty ?? false) {
          query = query.where('constructionType',
              whereIn: filter.constructionTypes);
        }

        if (filter.companies?.isNotEmpty ?? false) {
          query = query.where('company', whereIn: filter.companies);
        }

        if (filter.hasPerDiem != null) {
          query = query.where('hasPerDiem', isEqualTo: filter.hasPerDiem);
        }

        if (filter.state != null) {
          query = query.where('state', isEqualTo: filter.state);
        }

        if (filter.city != null) {
          query = query.where('city', isEqualTo: filter.city);
        }

        // Date filters
        if (filter.postedAfter != null) {
          query = query.where('timestamp', isGreaterThan: filter.postedAfter);
        }

        if (filter.startDateAfter != null) {
          query =
              query.where('startDate', isGreaterThan: filter.startDateAfter);
        }

        if (filter.startDateBefore != null) {
          query = query.where('startDate', isLessThan: filter.startDateBefore);
        }

        // Search query (basic text search on job title and description)
        if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
          final searchTerm = filter.searchQuery!.toLowerCase();
          query = query.where('searchTerms', arrayContains: searchTerm);
        }

        // Sorting
        switch (filter.sortBy) {
          case JobSortOption.datePosted:
            query =
                query.orderBy('timestamp', descending: filter.sortDescending);
            break;
          case JobSortOption.startDate:
            query =
                query.orderBy('startDate', descending: filter.sortDescending);
            break;
          case JobSortOption.wage:
            query = query.orderBy('wage', descending: filter.sortDescending);
            break;
          case JobSortOption.distance:
            // Distance sorting would require location-based queries
            // For now, default to timestamp sorting
            query = query.orderBy('timestamp', descending: true);
            break;
          default:
            query = query.orderBy('timestamp', descending: true);
            break;
        }

        // Pagination
        if (startAfter != null) {
          query = query.startAfterDocument(startAfter);
        }

        query = query.limit(limit);

        return await query.get();
      },
      operationName: 'getJobsWithFilter',
    );
  }

  /// Get jobs based on a list of suggested job IDs.
  /// This method simulates an optimized query for jobs directly relevant to AI suggestions.
  Future<QuerySnapshot> getJobsBySuggestionIds(
      List<String> suggestedJobIds) async {
    return _executeWithRetryFuture(
      () async {
        if (suggestedJobIds.isEmpty) {
          // Return an empty snapshot if no IDs are provided
          return await FirebaseFirestore.instance
              .collection('jobs')
              .limit(0)
              .get();
        }
        // Firestore 'whereIn' clause is limited to 10 items.
        // For more than 10, multiple queries or a backend function would be needed.
        // For this placeholder, we'll take the first 10.
        Query query = FirebaseFirestore.instance.collection('jobs').where(
            FieldPath.documentId,
            whereIn: suggestedJobIds.take(10).toList());

        return await query.get();
      },
      operationName: 'getJobsBySuggestionIds',
    );
  }

  /// Get user profile document (alias for getUser with better semantics)
  Future<DocumentSnapshot?> getUserProfile(String uid) async {
    try {
      final doc = await getUser(uid);
      return doc.exists ? doc : null;
    } catch (e) {
      if (kDebugMode) {
        print('Error getting user profile: $e');
      }
      return null;
    }
  }

  /// Update user profile with UserModel
  Future<void> updateUserProfile(String uid, UserModel userModel) async {
    return updateUser(uid: uid, data: userModel.toJson());
  }

  /// Execute a Future operation with retry logic
  Future<T> _executeWithRetryFuture<T>(
    Future<T> Function() operation, {
    required String operationName,
    int retryCount = 0,
  }) async {
    if (_isCircuitOpen()) {
      throw FirestoreException(
        'Service temporarily unavailable (circuit breaker open)',
        'circuit-breaker-open',
      );
    }

    try {
      final result = await operation();
      _onSuccess();
      return result;
    } catch (error) {
      if (_isRetryableError(error) && retryCount < maxRetries) {
        final delay = _calculateRetryDelay(retryCount);

        if (kDebugMode) {
          print(
              '$operationName failed (attempt ${retryCount + 1}/$maxRetries), retrying in ${delay.inMilliseconds}ms: $error');
        }

        await Future.delayed(delay);
        return _executeWithRetryFuture(
          operation,
          operationName: operationName,
          retryCount: retryCount + 1,
        );
      } else {
        _onFailure();
        throw _wrapError(error, operationName);
      }
    }
  }

  /// Execute a Stream operation with retry logic
  Stream<T> _executeWithRetryStream<T>(
    Stream<T> Function() operation, {
    required String operationName,
    int retryCount = 0,
  }) {
    if (_isCircuitOpen()) {
      return Stream.error(FirestoreException(
        'Service temporarily unavailable (circuit breaker open)',
        'circuit-breaker-open',
      ));
    }

    return operation().handleError((error) {
      if (_isRetryableError(error) && retryCount < maxRetries) {
        final delay = _calculateRetryDelay(retryCount);

        if (kDebugMode) {
          print(
              '$operationName stream failed (attempt ${retryCount + 1}/$maxRetries), retrying in ${delay.inMilliseconds}ms: $error');
        }

        return Future.delayed(delay).then((_) {
          return _executeWithRetryStream(
            operation,
            operationName: operationName,
            retryCount: retryCount + 1,
          );
        });
      } else {
        _onFailure();
        throw _wrapError(error, operationName);
      }
    });
  }

  /// Check if the circuit breaker is open
  bool _isCircuitOpen() {
    if (!_circuitOpen) return false;

    if (_circuitOpenTime != null &&
        DateTime.now().difference(_circuitOpenTime!) > circuitBreakerTimeout) {
      _resetCircuitBreaker();
      return false;
    }

    return true;
  }

  /// Handle successful operation
  void _onSuccess() {
    if (_circuitOpen) {
      _resetCircuitBreaker();
    }
    _failureCount = 0;
  }

  /// Handle failed operation
  void _onFailure() {
    _failureCount++;

    // Open circuit breaker after 5 consecutive failures
    if (_failureCount >= 5) {
      _circuitOpen = true;
      _circuitOpenTime = DateTime.now();

      if (kDebugMode) {
        print(
            'Circuit breaker opened due to $_failureCount consecutive failures');
      }
    }
  }

  /// Reset circuit breaker to closed state
  void _resetCircuitBreaker() {
    _circuitOpen = false;
    _circuitOpenTime = null;
    _failureCount = 0;

    if (kDebugMode) {
      print('Circuit breaker reset to closed state');
    }
  }

  /// Check if an error is retryable
  bool _isRetryableError(dynamic error) {
    if (error is FirebaseException) {
      switch (error.code) {
        case 'unavailable':
        case 'deadline-exceeded':
        case 'internal':
        case 'cancelled':
        case 'resource-exhausted':
        case 'aborted':
          return true;
        case 'permission-denied':
        case 'not-found':
        case 'already-exists':
        case 'failed-precondition':
        case 'out-of-range':
        case 'unimplemented':
        case 'data-loss':
        case 'unauthenticated':
          return false;
        default:
          return false;
      }
    }

    // Network-related errors are generally retryable
    if (error is TimeoutException ||
        error.toString().contains('network') ||
        error.toString().contains('connection')) {
      return true;
    }

    return false;
  }

  /// Calculate retry delay with exponential backoff and jitter
  Duration _calculateRetryDelay(int retryCount) {
    final exponentialDelay = initialRetryDelay * pow(2, retryCount);
    final cappedDelay = Duration(
      milliseconds:
          min(exponentialDelay.inMilliseconds, maxRetryDelay.inMilliseconds),
    );

    // Add jitter to prevent thundering herd
    final jitter = Random().nextDouble() * 0.1; // ±10% jitter
    final jitterMs = (cappedDelay.inMilliseconds * jitter).round();

    return Duration(milliseconds: cappedDelay.inMilliseconds + jitterMs);
  }

  /// Wrap errors with additional context
  Exception _wrapError(dynamic error, String operationName) {
    if (error is FirebaseException) {
      return FirestoreException(
        'Firestore operation "$operationName" failed: ${error.message}',
        error.code,
        originalError: error,
      );
    }

    return FirestoreException(
      'Operation "$operationName" failed: $error',
      'unknown-error',
      originalError: error,
    );
  }

  /// Get circuit breaker status for monitoring
  Map<String, dynamic> getCircuitBreakerStatus() {
    return {
      'isOpen': _circuitOpen,
      'openSince': _circuitOpenTime?.toIso8601String(),
      'failureCount': _failureCount,
      'timeUntilReset': _circuitOpen && _circuitOpenTime != null
          ? circuitBreakerTimeout.inSeconds -
              DateTime.now().difference(_circuitOpenTime!).inSeconds
          : null,
    };
  }

  /// Manually reset circuit breaker (for testing/admin purposes)
  void resetCircuitBreaker() {
    _resetCircuitBreaker();
  }

  /// Get retry statistics for monitoring
  Map<String, dynamic> getRetryStatistics() {
    return {
      'maxRetries': maxRetries,
      'initialRetryDelay': initialRetryDelay.inMilliseconds,
      'maxRetryDelay': maxRetryDelay.inMilliseconds,
      'circuitBreakerTimeout': circuitBreakerTimeout.inMinutes,
    };
  }

  /// Get popular jobs with caching
  Future<List<Map<String, dynamic>>> getCachedPopularJobs() async {
    // Try to get from cache first
    final cachedJobs = await _cacheService.getCachedPopularJobs();
    if (cachedJobs != null) {
      return cachedJobs;
    }

    // If not in cache, fetch from Firestore
    try {
      final snapshot = await getJobs(limit: 10).first;
      final jobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Cache for future use
      await _cacheService.cachePopularJobs(jobs);
      return jobs;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching popular jobs for caching: $e');
      }
      return [];
    }
  }

  /// Get locals with caching
  Future<List<Map<String, dynamic>>> getCachedLocals() async {
    // Try to get from cache first
    final cachedLocals = await _cacheService.getCachedLocals();
    if (cachedLocals != null) {
      return cachedLocals;
    }

    // If not in cache, fetch from Firestore
    try {
      final snapshot = await getLocals(limit: 100).first;
      final locals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      // Cache for future use (locals don't change often)
      await _cacheService.cacheLocals(locals);
      return locals;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching locals for caching: $e');
      }
      return [];
    }
  }

  /// Clear all caches
  Future<void> clearCache() async {
    await _cacheService.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getStats();
  }
}

/// Custom exception class for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String code;
  final dynamic originalError;

  const FirestoreException(
    this.message,
    this.code, {
    this.originalError,
  });

  @override
  String toString() => 'FirestoreException: $message (code: $code)';
}

/// Extension to add resilience methods to any FirestoreService
extension FirestoreServiceResilience on FirestoreService {
  /// Create a resilient wrapper around this service
  ResilientFirestoreService withResilience() {
    return ResilientFirestoreService();
  }
}
