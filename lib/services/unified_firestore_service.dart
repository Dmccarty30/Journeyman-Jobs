import 'dart:io';
import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'cache_service.dart';
import '../models/filter_criteria.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';
import '../models/user_model.dart';
import '../features/crews/models/post_model.dart';
import '../models/conversation_model.dart' as conv;
import '../features/crews/models/message.dart';
import '../models/contractor_model.dart';
import 'package:geolocator/geolocator.dart';

// ============================================================================
// UNIFIED FIRESTORE SERVICE - STRATEGY PATTERN IMPLEMENTATION
// ============================================================================
//
// This service consolidates 4 existing Firestore services into a unified
// architecture using the Strategy Pattern:
//
// 1. FirestoreService (base CRUD)
// 2. ResilientFirestoreService (retry logic, circuit breaker)
// 3. SearchOptimizedFirestoreService (search optimization)
// 4. GeographicFirestoreService (geographic sharding)
//
// Architecture:
// - UnifiedFirestoreService: Main service coordinating all strategies
// - ResilienceStrategy: Automatic retry, circuit breaker, error handling
// - SearchStrategy: Multi-term search, relevance ranking, caching
// - ShardingStrategy: Geographic optimization, regional queries
//
// Benefits:
// - Single point of integration for all Firestore operations
// - Pluggable strategies (enable/disable as needed)
// - Improved testability and maintainability
// - Backward compatible with existing code
// - Comprehensive monitoring and observability
//
// Usage:
//   final service = UnifiedFirestoreService(
//     enableResilience: true,
//     enableSearch: true,
//     enableSharding: true,
//   );
//
//   // All operations automatically use enabled strategies
//   final jobs = await service.getJobs(limit: 20);
//   final searchResults = await service.searchLocalsEnhanced('local 123');
//
// ============================================================================

// ============================================================================
// STRATEGY INTERFACES
// ============================================================================

/// Base strategy interface for Firestore operations
///
/// All strategies must implement this interface to participate in the
/// unified service architecture.
abstract class FirestoreStrategy {
  /// Strategy name for identification and logging
  String get name;

  /// Initialize strategy with service dependencies
  void initialize(UnifiedFirestoreService service);

  /// Get strategy-specific statistics for monitoring
  Map<String, dynamic> getStatistics();

  /// Reset strategy state (useful for testing)
  void reset();
}

/// Configuration for resilience strategy
class ResilienceConfig {
  /// Maximum number of retry attempts for transient failures
  final int maxRetries;

  /// Initial delay before first retry (exponential backoff base)
  final Duration initialRetryDelay;

  /// Maximum delay between retries (caps exponential backoff)
  final Duration maxRetryDelay;

  /// Number of consecutive failures before opening circuit breaker
  final int circuitBreakerThreshold;

  /// Time to wait before attempting to close circuit breaker
  final Duration circuitBreakerTimeout;

  const ResilienceConfig({
    this.maxRetries = 3,
    this.initialRetryDelay = const Duration(seconds: 1),
    this.maxRetryDelay = const Duration(seconds: 10),
    this.circuitBreakerThreshold = 5,
    this.circuitBreakerTimeout = const Duration(minutes: 5),
  });
}

/// Configuration for search strategy
class SearchConfig {
  /// Maximum number of search results to return
  final int maxSearchResults;

  /// Minimum search query length
  final int minSearchLength;

  /// Cache timeout for search results
  final Duration searchCacheTimeout;

  /// Field weights for relevance ranking
  final Map<String, double> fieldWeights;

  const SearchConfig({
    this.maxSearchResults = 50,
    this.minSearchLength = 2,
    this.searchCacheTimeout = const Duration(minutes: 10),
    this.fieldWeights = const {
      'localUnion': 1.0,
      'city': 0.8,
      'state': 0.6,
      'searchTerms': 0.4,
    },
  });
}

/// Configuration for sharding strategy
class ShardingConfig {
  /// US regions for geographic data sharding
  final Map<String, List<String>> regions;

  /// Whether to enable cross-regional search fallback
  final bool enableCrossRegionalSearch;

  const ShardingConfig({
    this.regions = const {
      'northeast': ['NY', 'NJ', 'CT', 'MA', 'PA', 'VT', 'NH', 'ME', 'RI', 'DE', 'MD'],
      'southeast': ['FL', 'GA', 'SC', 'NC', 'VA', 'WV', 'TN', 'KY', 'AL', 'MS', 'AR', 'LA'],
      'midwest': ['OH', 'IN', 'MI', 'IL', 'WI', 'MN', 'IA', 'MO', 'ND', 'SD', 'NE', 'KS'],
      'southwest': ['TX', 'OK', 'NM', 'AZ', 'NV', 'UT', 'CO'],
      'west': ['CA', 'OR', 'WA', 'ID', 'MT', 'WY', 'AK', 'HI'],
    },
    this.enableCrossRegionalSearch = true,
  });
}

// ============================================================================
// RESILIENCE STRATEGY
// ============================================================================

/// Resilience strategy providing automatic retry logic and circuit breaker
///
/// Features:
/// - Automatic retry with exponential backoff and jitter
/// - Circuit breaker pattern to prevent cascading failures
/// - Intelligent error classification (retryable vs non-retryable)
/// - Comprehensive monitoring and observability
///
/// Configuration:
/// - maxRetries: Maximum retry attempts (default: 3)
/// - initialRetryDelay: Base delay for exponential backoff (default: 1s)
/// - maxRetryDelay: Maximum delay cap (default: 10s)
/// - circuitBreakerThreshold: Failures before opening circuit (default: 5)
/// - circuitBreakerTimeout: Time before attempting reset (default: 5min)
class ResilienceStrategy implements FirestoreStrategy {
  final ResilienceConfig config;
  late UnifiedFirestoreService service;

  // Circuit breaker state
  bool _circuitOpen = false;
  DateTime? _circuitOpenTime;
  int _failureCount = 0;

  // Statistics
  int _totalRetries = 0;
  int _successfulRetries = 0;
  int _failedRetries = 0;

  ResilienceStrategy({this.config = const ResilienceConfig()});

  @override
  String get name => 'ResilienceStrategy';

  @override
  void initialize(UnifiedFirestoreService service) {
    service = service;
  }

  /// Execute a Future operation with retry logic and circuit breaker
  ///
  /// Automatically retries transient failures with exponential backoff.
  /// Opens circuit breaker after threshold failures to prevent cascading issues.
  ///
  /// Throws [FirestoreException] if circuit is open or max retries exceeded.
  Future<T> executeWithRetry<T>(
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
      if (_isRetryableError(error) && retryCount < config.maxRetries) {
        _totalRetries++;
        final delay = _calculateRetryDelay(retryCount);

        if (kDebugMode) {
          print('$operationName failed (attempt ${retryCount + 1}/${config.maxRetries}), '
              'retrying in ${delay.inMilliseconds}ms: $error');
        }

        await Future.delayed(delay);
        return executeWithRetry(
          operation,
          operationName: operationName,
          retryCount: retryCount + 1,
        );
      } else {
        if (retryCount > 0) {
          _failedRetries++;
        }
        _onFailure();
        throw _wrapError(error, operationName);
      }
    }
  }

  /// Execute a Stream operation with retry logic
  ///
  /// Wraps stream operations with error handling and automatic retry.
  /// On retryable errors, recreates the stream after delay.
  Stream<T> executeStreamWithRetry<T>(
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
      if (_isRetryableError(error) && retryCount < config.maxRetries) {
        _totalRetries++;
        final delay = _calculateRetryDelay(retryCount);

        if (kDebugMode) {
          print('$operationName stream failed (attempt ${retryCount + 1}/${config.maxRetries}), '
              'retrying in ${delay.inMilliseconds}ms: $error');
        }

        return Future.delayed(delay).then((_) {
          return executeStreamWithRetry(
            operation,
            operationName: operationName,
            retryCount: retryCount + 1,
          );
        });
      } else {
        if (retryCount > 0) {
          _failedRetries++;
        }
        _onFailure();
        throw _wrapError(error, operationName);
      }
    });
  }

  /// Check if the circuit breaker is currently open
  bool _isCircuitOpen() {
    if (!_circuitOpen) return false;

    if (_circuitOpenTime != null &&
        DateTime.now().difference(_circuitOpenTime!) > config.circuitBreakerTimeout) {
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

    if (_failureCount >= config.circuitBreakerThreshold) {
      _circuitOpen = true;
      _circuitOpenTime = DateTime.now();

      if (kDebugMode) {
        print('Circuit breaker opened due to $_failureCount consecutive failures');
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

  /// Check if an error is retryable based on error type and code
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
    final exponentialDelay = config.initialRetryDelay * pow(2, retryCount);
    final cappedDelay = Duration(
      milliseconds: min(exponentialDelay.inMilliseconds, config.maxRetryDelay.inMilliseconds),
    );

    // Add jitter to prevent thundering herd (±10% jitter)
    final jitter = Random().nextDouble() * 0.1;
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

  @override
  Map<String, dynamic> getStatistics() {
    final totalAttempts = _totalRetries + _successfulRetries + _failedRetries;
    return {
      'circuitBreaker': {
        'isOpen': _circuitOpen,
        'openSince': _circuitOpenTime?.toIso8601String(),
        'failureCount': _failureCount,
        'threshold': config.circuitBreakerThreshold,
        'timeUntilReset': _circuitOpen && _circuitOpenTime != null
            ? config.circuitBreakerTimeout.inSeconds -
              DateTime.now().difference(_circuitOpenTime!).inSeconds
            : null,
      },
      'retries': {
        'total': _totalRetries,
        'successful': _successfulRetries,
        'failed': _failedRetries,
        'maxRetries': config.maxRetries,
        'successRate': totalAttempts > 0 ? (_successfulRetries / totalAttempts * 100).toStringAsFixed(2) : '0.00',
      },
      'config': {
        'maxRetries': config.maxRetries,
        'initialRetryDelay': config.initialRetryDelay.inMilliseconds,
        'maxRetryDelay': config.maxRetryDelay.inMilliseconds,
        'circuitBreakerTimeout': config.circuitBreakerTimeout.inMinutes,
      },
    };
  }

  @override
  void reset() {
    _resetCircuitBreaker();
    _totalRetries = 0;
    _successfulRetries = 0;
    _failedRetries = 0;
  }
}

// ============================================================================
// SEARCH STRATEGY
// ============================================================================

/// Search strategy providing optimized full-text search with relevance ranking
///
/// Features:
/// - Multi-term search across multiple fields
/// - Relevance scoring with configurable field weights
/// - Intelligent caching for performance (<300ms target)
/// - Advanced and basic search modes
/// - Search analytics and popular terms tracking
///
/// Configuration:
/// - maxSearchResults: Maximum results per query (default: 50)
/// - minSearchLength: Minimum query length (default: 2)
/// - searchCacheTimeout: Cache TTL (default: 10min)
/// - fieldWeights: Relevance weights per field
class SearchStrategy implements FirestoreStrategy {
  final SearchConfig config;
  final CacheService _cacheService = CacheService();
  late UnifiedFirestoreService _service;

  // Search analytics
  final Map<String, SearchMetrics> _searchMetrics = {};

  SearchStrategy({this.config = const SearchConfig()});

  @override
  String get name => 'SearchStrategy';

  @override
  void initialize(UnifiedFirestoreService service) {
    _service = service;
  }

  /// Enhanced locals search with full-text capabilities and relevance ranking
  ///
  /// Performs multi-term search across multiple fields with weighted relevance scoring.
  /// Results are cached for performance optimization (<300ms target).
  ///
  /// Parameters:
  /// - query: Search query (min length: 2)
  /// - state: Optional state filter for geographic narrowing
  /// - limit: Maximum results to return
  ///
  /// Returns list of LocalsRecord sorted by relevance score.
  Future<List<LocalsRecord>> searchLocalsEnhanced(
    String query, {
    String? state,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      // Validate input
      if (query.trim().length < config.minSearchLength) {
        return [];
      }

      final searchQuery = query.trim().toLowerCase();
      final cacheKey = _buildSearchCacheKey(searchQuery, state, limit);

      // Try cache first for performance
      final cachedResults = await _getCachedSearchResults(cacheKey);
      if (cachedResults != null) {
        stopwatch.stop();
        _trackSearchMetrics(searchQuery, cachedResults.length, stopwatch.elapsed, true);
        return cachedResults;
      }

      // Perform enhanced search
      List<LocalsRecord> results;
      if (_shouldUseAdvancedSearch(searchQuery)) {
        results = await _performAdvancedSearch(searchQuery, state, limit);
      } else {
        results = await _performBasicSearch(searchQuery, state, limit);
      }

      // Cache results for future use
      await _cacheSearchResults(cacheKey, results);

      stopwatch.stop();
      _trackSearchMetrics(searchQuery, results.length, stopwatch.elapsed, false);

      return results;
    } catch (e) {
      stopwatch.stop();
      _trackSearchMetrics(query, 0, stopwatch.elapsed, false, error: e.toString());

      if (kDebugMode) {
        print('Search error for "$query": $e');
      }

      // Fallback to basic search on error
      return await _performFallbackSearch(query, state, limit);
    }
  }

  /// Advanced multi-term search with relevance ranking
  ///
  /// Searches across multiple fields with different weights, calculating
  /// relevance scores for each result and ranking accordingly.
  Future<List<LocalsRecord>> _performAdvancedSearch(
    String query,
    String? state,
    int limit,
  ) async {
    final searchTerms = _extractSearchTerms(query);
    final results = <LocalsRecord, double>{};

    for (final field in config.fieldWeights.keys) {
      final fieldWeight = config.fieldWeights[field]!;
      final fieldResults = await _searchByField(field, searchTerms, state);

      for (final result in fieldResults) {
        final relevanceScore = _calculateRelevanceScore(
          result,
          searchTerms,
          field,
          fieldWeight,
        );

        if (results.containsKey(result)) {
          results[result] = results[result]! + relevanceScore;
        } else {
          results[result] = relevanceScore;
        }
      }
    }

    // Sort by relevance and return top results
    final sortedResults = results.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedResults
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  /// Basic prefix search fallback
  Future<List<LocalsRecord>> _performBasicSearch(
    String query,
    String? state,
    int limit,
  ) async {
    Query firestoreQuery = _service.firestore.collection('locals');

    // Apply geographic filtering first for better performance
    if (state != null && state.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('state', isEqualTo: state);
    }

    // Prefix search on localUnion field
    firestoreQuery = firestoreQuery
        .where('localUnion', isGreaterThanOrEqualTo: query)
        .where('localUnion', isLessThanOrEqualTo: '$query\uf8ff')
        .limit(limit);

    final snapshot = await firestoreQuery.get();
    return snapshot.docs
        .map((doc) => LocalsRecord.fromFirestore(doc))
        .toList();
  }

  /// Search within a specific field
  Future<List<LocalsRecord>> _searchByField(
    String field,
    List<String> searchTerms,
    String? state,
  ) async {
    Query query = _service.firestore.collection('locals');

    // Apply geographic filtering
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }

    // Search strategy based on field type
    if (field == 'searchTerms') {
      // Array contains search for searchTerms field
      final results = <LocalsRecord>[];
      for (final term in searchTerms.take(3)) {
        final termQuery = query
            .where('searchTerms', arrayContains: term)
            .limit(config.maxSearchResults ~/ searchTerms.length);

        final snapshot = await termQuery.get();
        results.addAll(
          snapshot.docs.map((doc) => LocalsRecord.fromFirestore(doc)),
        );
      }
      return results;
    } else {
      // Prefix search for other fields
      final primaryTerm = searchTerms.first;
      query = query
          .where(field, isGreaterThanOrEqualTo: primaryTerm)
          .where(field, isLessThanOrEqualTo: '$primaryTerm\uf8ff')
          .limit(config.maxSearchResults);

      final snapshot = await query.get();
      return snapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();
    }
  }

  /// Calculate relevance score for search results
  double _calculateRelevanceScore(
    LocalsRecord local,
    List<String> searchTerms,
    String field,
    double fieldWeight,
  ) {
    double score = 0.0;
    final fieldValue = _getFieldValue(local, field).toLowerCase();

    for (final term in searchTerms) {
      if (fieldValue.contains(term)) {
        // Exact match bonus
        if (fieldValue == term) {
          score += 10.0;
        }
        // Start-of-word bonus
        else if (fieldValue.startsWith(term)) {
          score += 5.0;
        }
        // Contains bonus
        else {
          score += 2.0;
        }

        // Length ratio bonus (shorter matches are more relevant)
        final lengthRatio = term.length / fieldValue.length;
        score += lengthRatio * 3.0;
      }
    }

    return score * fieldWeight;
  }

  /// Extract meaningful search terms from query
  List<String> _extractSearchTerms(String query) {
    return query
        .toLowerCase()
        .split(RegExp(r'\s+'))
        .where((term) => term.length >= config.minSearchLength)
        .take(5) // Limit to 5 terms for performance
        .toList();
  }

  /// Get field value from LocalsRecord
  String _getFieldValue(LocalsRecord local, String field) {
    switch (field) {
      case 'localUnion':
        return local.localUnion;
      case 'city':
        return local.city;
      case 'state':
        return local.state;
      case 'searchTerms':
        return [
          local.localName,
          local.localNumber,
          local.classification ?? '',
          local.city,
          local.state,
          ...local.specialties,
        ].where((term) => term.isNotEmpty).join(' ').toLowerCase();
      default:
        return '';
    }
  }

  /// Determine if advanced search should be used
  bool _shouldUseAdvancedSearch(String query) {
    return query.contains(' ') || query.length >= 5;
  }

  /// Fallback search for error scenarios
  Future<List<LocalsRecord>> _performFallbackSearch(
    String query,
    String? state,
    int limit,
  ) async {
    try {
      return await _performBasicSearch(query, state, limit);
    } catch (e) {
      if (kDebugMode) {
        print('Fallback search also failed: $e');
      }
      return [];
    }
  }

  /// Build cache key for search results
  String _buildSearchCacheKey(String query, String? state, int limit) {
    final stateParam = state ?? 'all';
    return 'search_${query.hashCode}_${stateParam}_$limit';
  }

  /// Get cached search results
  Future<List<LocalsRecord>?> _getCachedSearchResults(String cacheKey) async {
    try {
      final cached = await _cacheService.get<List<dynamic>>(cacheKey);
      if (cached != null) {
        return cached.map((json) => LocalsRecord.fromJson(json)).toList();
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache retrieval error: $e');
      }
    }
    return null;
  }

  /// Cache search results
  Future<void> _cacheSearchResults(String cacheKey, List<LocalsRecord> results) async {
    try {
      final jsonResults = results.map((local) => local.toJson()).toList();
      await _cacheService.set(
        cacheKey,
        jsonResults,
        ttl: config.searchCacheTimeout,
      );
    } catch (e) {
      if (kDebugMode) {
        print('Cache storage error: $e');
      }
    }
  }

  /// Track search metrics for analytics
  void _trackSearchMetrics(
    String query,
    int resultCount,
    Duration responseTime,
    bool cacheHit, {
    String? error,
  }) {
    final metrics = SearchMetrics(
      query: query,
      resultCount: resultCount,
      responseTime: responseTime,
      cacheHit: cacheHit,
      timestamp: DateTime.now(),
      error: error,
    );

    _searchMetrics[query] = metrics;

    if (kDebugMode) {
      print('Search: "$query" -> $resultCount results in ${responseTime.inMilliseconds}ms '
          '${cacheHit ? '(cached)' : '(fresh)'}');
    }
  }

  /// Get popular search terms
  List<String> getPopularSearchTerms({int limit = 10}) {
    final termFrequency = <String, int>{};

    for (final metrics in _searchMetrics.values) {
      final terms = _extractSearchTerms(metrics.query);
      for (final term in terms) {
        termFrequency[term] = (termFrequency[term] ?? 0) + 1;
      }
    }

    final sortedTerms = termFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));

    return sortedTerms
        .take(limit)
        .map((entry) => entry.key)
        .toList();
  }

  @override
  Map<String, dynamic> getStatistics() {
    if (_searchMetrics.isEmpty) {
      return {'message': 'No search data available'};
    }

    final totalSearches = _searchMetrics.length;
    final cacheHits = _searchMetrics.values.where((m) => m.cacheHit).length;
    final errors = _searchMetrics.values.where((m) => m.error != null).length;

    final responseTimes = _searchMetrics.values
        .where((m) => m.error == null)
        .map((m) => m.responseTime.inMilliseconds)
        .toList();

    final avgResponseTime = responseTimes.isNotEmpty
        ? responseTimes.reduce((a, b) => a + b) / responseTimes.length
        : 0.0;

    final maxResponseTime = responseTimes.isNotEmpty
        ? responseTimes.reduce(max)
        : 0;

    return {
      'totalSearches': totalSearches,
      'cacheHitRate': totalSearches > 0 ? (cacheHits / totalSearches * 100).toStringAsFixed(2) : '0.00',
      'errorRate': totalSearches > 0 ? (errors / totalSearches * 100).toStringAsFixed(2) : '0.00',
      'avgResponseTimeMs': avgResponseTime.round(),
      'maxResponseTimeMs': maxResponseTime,
      'sub300msCount': responseTimes.where((time) => time < 300).length,
      'performanceTarget': responseTimes.isNotEmpty
          ? (responseTimes.where((time) => time < 300).length / responseTimes.length * 100).toStringAsFixed(2)
          : '0.00',
      'popularTerms': getPopularSearchTerms(limit: 5),
    };
  }

  @override
  void reset() {
    _searchMetrics.clear();
  }
}

// ============================================================================
// SHARDING STRATEGY
// ============================================================================

/// Sharding strategy providing geographic data optimization
///
/// Features:
/// - Geographic data organization into 5 US regions
/// - Regional subcollections for 70% query scope reduction
/// - Automatic region detection from state codes
/// - Cross-regional search support
/// - Migration utilities for existing data
///
/// Configuration:
/// - regions: US region to state mappings
/// - enableCrossRegionalSearch: Allow fallback to nearby regions
class ShardingStrategy implements FirestoreStrategy {
  final ShardingConfig config;
  late UnifiedFirestoreService _service;

  // Statistics
  int _regionalQueries = 0;
  int _crossRegionalQueries = 0;

  ShardingStrategy({this.config = const ShardingConfig()});

  @override
  String get name => 'ShardingStrategy';

  @override
  void initialize(UnifiedFirestoreService service) {
    _service = service;
  }

  /// Get locals with geographic optimization
  ///
  /// Uses regional subcollections when state filter is provided,
  /// reducing query scope by ~70%.
  Stream<QuerySnapshot> getLocalsOptimized({
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? state,
  }) {
    final targetRegion = getRegionFromState(state);

    if (targetRegion == 'all') {
      // Cross-regional query - use main collection
      Query query = _service.firestore.collection('locals');

      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }

      query = query.limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots();
    }

    // Regional query - use optimized subcollection
    _regionalQueries++;
    return _getRegionalLocalsStream(
      region: targetRegion,
      limit: limit,
      startAfter: startAfter,
      state: state,
    );
  }

  /// Get jobs with geographic optimization
  Stream<QuerySnapshot> getJobsOptimized({
    int limit = 20,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    String? state;
    if (filters != null && filters.containsKey('state')) {
      state = filters['state'] as String?;
    }

    final targetRegion = getRegionFromState(state);

    if (targetRegion == 'all') {
      // Cross-regional query - use main collection
      Query query = _service.firestore.collection('jobs')
          .orderBy('timestamp', descending: true);

      // Apply filters
      if (filters != null) {
        if (filters['local'] != null) {
          query = query.where('local', isEqualTo: filters['local']);
        }
        if (filters['classification'] != null) {
          query = query.where('classification', isEqualTo: filters['classification']);
        }
        if (filters['state'] != null) {
          query = query.where('state', isEqualTo: filters['state']);
        }
        if (filters['typeOfWork'] != null) {
          query = query.where('typeOfWork', isEqualTo: filters['typeOfWork']);
        }
      }

      query = query.limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots();
    }

    // Regional query - use optimized subcollection
    _regionalQueries++;
    return _getRegionalJobsStream(
      region: targetRegion,
      limit: limit,
      startAfter: startAfter,
      filters: filters,
    );
  }

  /// Get region-specific locals stream
  Stream<QuerySnapshot> _getRegionalLocalsStream({
    required String region,
    int limit = 20,
    DocumentSnapshot? startAfter,
    String? state,
  }) {
    final collection = _getRegionalLocalsCollection(region);
    Query query = collection.orderBy('localUnion');

    // Apply state filtering within region
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }

    // Apply pagination
    query = query.limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Get region-specific jobs stream
  Stream<QuerySnapshot> _getRegionalJobsStream({
    required String region,
    int limit = 20,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    final collection = _getRegionalJobsCollection(region);
    Query query = collection.orderBy('timestamp', descending: true);

    // Apply filters
    if (filters != null) {
      if (filters['local'] != null) {
        query = query.where('local', isEqualTo: filters['local']);
      }
      if (filters['classification'] != null) {
        query = query.where('classification', isEqualTo: filters['classification']);
      }
      if (filters['state'] != null) {
        query = query.where('state', isEqualTo: filters['state']);
      }
      if (filters['typeOfWork'] != null) {
        query = query.where('typeOfWork', isEqualTo: filters['typeOfWork']);
      }
    }

    // Apply pagination
    query = query.limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Get regional locals collection reference
  CollectionReference _getRegionalLocalsCollection(String region) {
    return _service.firestore
        .collection('locals_regions')
        .doc(region)
        .collection('locals');
  }

  /// Get regional jobs collection reference
  CollectionReference _getRegionalJobsCollection(String region) {
    return _service.firestore
        .collection('jobs_regions')
        .doc(region)
        .collection('jobs');
  }

  /// Get region from state code with automatic detection
  String getRegionFromState(String? state) {
    if (state == null || state.isEmpty) return 'all';

    final upperState = state.toUpperCase();

    for (final entry in config.regions.entries) {
      if (entry.value.contains(upperState)) {
        return entry.key;
      }
    }

    return 'all';
  }

  /// Get all states in a region
  List<String> getStatesInRegion(String region) {
    return config.regions[region] ?? [];
  }

  /// Get nearby regions for cross-regional searches
  List<String> getNearbyRegions(String primaryRegion) {
    const adjacency = {
      'northeast': ['southeast', 'midwest'],
      'southeast': ['northeast', 'midwest', 'southwest'],
      'midwest': ['northeast', 'southeast', 'southwest', 'west'],
      'southwest': ['southeast', 'midwest', 'west'],
      'west': ['midwest', 'southwest'],
    };

    return adjacency[primaryRegion] ?? [];
  }

  /// Perform cross-regional search when needed
  Future<List<LocalsRecord>> searchLocalsAcrossRegions({
    required String query,
    String? primaryState,
    int limit = 20,
  }) async {
    _crossRegionalQueries++;

    final primaryRegion = getRegionFromState(primaryState);
    final searchRegions = [primaryRegion, ...getNearbyRegions(primaryRegion)]
        .where((region) => region != 'all')
        .toSet()
        .toList();

    final allResults = <LocalsRecord>[];
    final regionLimit = (limit / searchRegions.length).ceil();

    for (final region in searchRegions) {
      try {
        final regionResults = await _searchRegionalLocals(
          region: region,
          query: query,
          limit: regionLimit,
        );
        allResults.addAll(regionResults);

        if (allResults.length >= limit) break;
      } catch (e) {
        if (kDebugMode) {
          print('Error searching region $region: $e');
        }
      }
    }

    return allResults.take(limit).toList();
  }

  /// Search within a specific region
  Future<List<LocalsRecord>> _searchRegionalLocals({
    required String region,
    required String query,
    int limit = 20,
  }) async {
    final collection = _getRegionalLocalsCollection(region);
    final searchQuery = query.toLowerCase();

    final snapshot = await collection
        .where('localUnion', isGreaterThanOrEqualTo: searchQuery)
        .where('localUnion', isLessThanOrEqualTo: '$searchQuery\uf8ff')
        .limit(limit)
        .get();

    return snapshot.docs
        .map((doc) => LocalsRecord.fromFirestore(doc))
        .toList();
  }

  @override
  Map<String, dynamic> getStatistics() {
    final totalQueries = _regionalQueries + _crossRegionalQueries;
    return {
      'queries': {
        'regional': _regionalQueries,
        'crossRegional': _crossRegionalQueries,
        'total': totalQueries,
        'regionalPercentage': totalQueries > 0
            ? (_regionalQueries / totalQueries * 100).toStringAsFixed(2)
            : '0.00',
      },
      'regions': config.regions.map((region, states) => MapEntry(region, {
        'stateCount': states.length,
        'states': states,
      })),
      'optimization': {
        'estimatedQueryReduction': '70%',
        'regionalCollections': config.regions.length,
        'crossRegionalFallback': config.enableCrossRegionalSearch,
      },
    };
  }

  @override
  void reset() {
    _regionalQueries = 0;
    _crossRegionalQueries = 0;
  }
}

// ============================================================================
// UNIFIED FIRESTORE SERVICE
// ============================================================================

/// Unified Firestore service coordinating all strategies
///
/// This service provides a single point of integration for all Firestore
/// operations, automatically applying enabled strategies to optimize
/// performance, reliability, and functionality.
///
/// Features:
/// - Pluggable strategy architecture (enable/disable as needed)
/// - Automatic strategy coordination and fallback
/// - Backward compatible with existing FirestoreService API
/// - Comprehensive monitoring and observability
/// - Caching integration for frequently accessed data
///
/// Usage:
/// ```dart
/// final service = UnifiedFirestoreService(
///   enableResilience: true,
///   enableSearch: true,
///   enableSharding: true,
///   resilienceConfig: ResilienceConfig(maxRetries: 5),
/// );
///
/// // Resilience strategy automatically applies retry logic
/// final user = await service.getUser('user123');
///
/// // Search strategy provides enhanced search
/// final results = await service.searchLocalsEnhanced('local 123');
///
/// // Sharding strategy optimizes geographic queries
/// final jobs = await service.getJobs(filters: {'state': 'NY'});
/// ```
class UnifiedFirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final CacheService _cacheService = CacheService();

  // Strategy instances
  final ResilienceStrategy? _resilienceStrategy;
  final SearchStrategy? _searchStrategy;
  final ShardingStrategy? _shardingStrategy;

  // Performance constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Create unified service with optional strategies
  ///
  /// Parameters:
  /// - enableResilience: Enable retry logic and circuit breaker
  /// - enableSearch: Enable optimized search capabilities
  /// - enableSharding: Enable geographic optimization
  /// - resilienceConfig: Configuration for resilience strategy
  /// - searchConfig: Configuration for search strategy
  /// - shardingConfig: Configuration for sharding strategy
  UnifiedFirestoreService({
    bool enableResilience = true,
    bool enableSearch = true,
    bool enableSharding = false,
    ResilienceConfig? resilienceConfig,
    SearchConfig? searchConfig,
    ShardingConfig? shardingConfig,
  })  : _resilienceStrategy = enableResilience
            ? ResilienceStrategy(config: resilienceConfig ?? const ResilienceConfig())
            : null,
        _searchStrategy = enableSearch
            ? SearchStrategy(config: searchConfig ?? const SearchConfig())
            : null,
        _shardingStrategy = enableSharding
            ? ShardingStrategy(config: shardingConfig ?? const ShardingConfig())
            : null {
    // Initialize strategies with service reference
    _resilienceStrategy?.initialize(this);
    _searchStrategy?.initialize(this);
    _shardingStrategy?.initialize(this);
  }

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // ============================================================================
  // COLLECTION REFERENCES
  // ============================================================================

  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  CollectionReference get localsCollection => _firestore.collection('locals');
  CollectionReference get crewsCollection => _firestore.collection('crews');
  CollectionReference get countersCollection => _firestore.collection('counters');
  CollectionReference get preferencesCollection => _firestore.collection('preferences');
  CollectionReference get stormContractorsCollection => _firestore.collection('stormcontractors');

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Create a new user document with initial data
  ///
  /// Automatically applies resilience strategy if enabled.
  /// Sets createdTime and onboardingStatus fields.
  Future<void> createUser({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    Future<void> operation() async {
      await usersCollection.doc(uid).set({
        ...userData,
        'createdTime': FieldValue.serverTimestamp(),
        'onboardingStatus': 'incomplete',
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'createUser',
      );
    } else {
      return operation();
    }
  }

  /// Create user profile (alias for createUser)
  Future<void> createUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    Future<void> operation() => usersCollection.doc(userId).set(data);

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'createUserProfile',
      );
    } else {
      return operation();
    }
  }

  /// Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    Future<bool> operation() async {
      final doc = await usersCollection.doc(userId).get();
      return doc.exists;
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'userProfileExists',
      );
    } else {
      return operation();
    }
  }

  /// Delete user data
  Future<void> deleteUserData(String userId) async {
    Future<void> operation() async {
      await usersCollection.doc(userId).delete();
      await _cacheService.remove('${CacheService.userDataPrefix}$userId');
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'deleteUserData',
      );
    } else {
      return operation();
    }
  }

  /// Update user email
  Future<void> updateUserEmail(String userId, String newEmail) async {
    Future<void> operation() => usersCollection.doc(userId).update({'email': newEmail});

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'updateUserEmail',
      );
    } else {
      return operation();
    }
  }

  /// Get user document
  Future<DocumentSnapshot> getUser(String uid) async {
    Future<DocumentSnapshot<Object?>> operation() => usersCollection.doc(uid).get();

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'getUser',
      );
    } else {
      return operation();
    }
  }

  /// Update user data
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    Future<void> operation() async {
      await usersCollection.doc(uid).update(data);
      await _cacheService.remove('${CacheService.userDataPrefix}$uid');
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'updateUser',
      );
    } else {
      return operation();
    }
  }

  /// Set user data with merge option
  Future<void> setUserWithMerge({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    Future<void> operation() async {
      if (kDebugMode) {
        print('\n🔧 DEBUG UnifiedFirestoreService.setUserWithMerge:');
        print('  - User ID: $uid');
        print('  - Data keys: ${data.keys.toList()}');
        print('  - Field count: ${data.length}');
        print('  - Merge: true');
      }

      await usersCollection.doc(uid).set(data, SetOptions(merge: true));

      if (kDebugMode) {
        print('✅ DEBUG: Firestore write completed successfully');
      }
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'setUserWithMerge',
      );
    } else {
      return operation();
    }
  }

  /// Get user document stream for real-time updates
  Stream<DocumentSnapshot> getUserStream(String uid) {
    Stream<DocumentSnapshot<Object?>> operation() => usersCollection.doc(uid).snapshots();

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeStreamWithRetry(
        operation,
        operationName: 'getUserStream',
      );
    } else {
      return operation();
    }
  }

  /// Get user data with caching
  Future<Map<String, dynamic>?> getCachedUserData(String uid) async {
    // Try cache first
    final cachedData = await _cacheService.getCachedUserData(uid);
    if (cachedData != null) {
      return cachedData;
    }

    // Fetch from Firestore
    try {
      final doc = await getUser(uid);
      if (doc.exists) {
        final userData = doc.data() as Map<String, dynamic>?;
        if (userData != null) {
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

  /// Get user profile document
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

  /// Set user online status
  Future<void> setOnlineStatus(bool status) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      await usersCollection.doc(uid).update({
        'onlineStatus': status,
        'lastActive': FieldValue.serverTimestamp(),
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'setOnlineStatus',
      );
    } else {
      return operation();
    }
  }

  // ============================================================================
  // JOB OPERATIONS
  // ============================================================================

  /// Get jobs stream with optional filters and pagination
  ///
  /// Automatically applies sharding strategy if enabled and state filter provided.
  /// Enforces pagination limits for performance.
  Stream<QuerySnapshot> getJobs({
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    // Use sharding strategy if enabled and state filter provided
    if (_shardingStrategy != null && filters != null && filters.containsKey('state')) {
      Stream<QuerySnapshot<Object?>> operation() => _shardingStrategy.getJobsOptimized(
        limit: limit,
        startAfter: startAfter,
        filters: filters,
      );

      if (_resilienceStrategy != null) {
        return _resilienceStrategy.executeStreamWithRetry(
          operation,
          operationName: 'getJobs',
        );
      } else {
        return operation();
      }
    }

    // Default implementation
    Stream<QuerySnapshot<Object?>> operation() {
      Query query = jobsCollection
          .where('deleted', isEqualTo: false)
          .where('matchesCriteria', isEqualTo: true)
          .orderBy('timestamp', descending: true);

      // Apply filters
      if (filters != null) {
        if (filters['local'] != null) {
          query = query.where('local', isEqualTo: filters['local']);
        }
        if (filters['classification'] != null) {
          query = query.where('classification', isEqualTo: filters['classification']);
        }
        if (filters['location'] != null) {
          query = query.where('location', isEqualTo: filters['location']);
        }
        if (filters['typeOfWork'] != null) {
          query = query.where('typeOfWork', isEqualTo: filters['typeOfWork']);
        }
      }

      // Always enforce pagination
      query = query.limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeStreamWithRetry(
        operation,
        operationName: 'getJobs',
      );
    } else {
      return operation();
    }
  }

  /// Get single job document
  Future<DocumentSnapshot> getJob(String jobId) async {
    Future<DocumentSnapshot<Object?>> operation() => jobsCollection.doc(jobId).get();

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'getJob',
      );
    } else {
      return operation();
    }
  }

  /// Get jobs with advanced filtering capabilities
  Future<QuerySnapshot> getJobsWithFilter({
    required JobFilterCriteria filter,
    DocumentSnapshot? startAfter,
    int limit = defaultPageSize,
  }) async {
    Future<QuerySnapshot<Object?>> operation() async {
      Query query = _firestore.collection('jobs');

      // Apply filters based on criteria
      if (filter.classifications.isNotEmpty) {
        query = query.where('classification', whereIn: filter.classifications);
      }

      if (filter.localNumbers.isNotEmpty) {
        query = query.where('local', whereIn: filter.localNumbers);
      }

      if (filter.constructionTypes.isNotEmpty) {
        query = query.where('constructionType', whereIn: filter.constructionTypes);
      }

      if (filter.companies.isNotEmpty) {
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
        query = query.where('startDate', isGreaterThan: filter.startDateAfter);
      }

      if (filter.startDateBefore != null) {
        query = query.where('startDate', isLessThan: filter.startDateBefore);
      }

      // Search query
      if (filter.searchQuery != null && filter.searchQuery!.isNotEmpty) {
        final searchTerm = filter.searchQuery!.toLowerCase();
        query = query.where('searchTerms', arrayContains: searchTerm);
      }

      // Sorting
      switch (filter.sortBy) {
        case JobSortOption.datePosted:
          query = query.orderBy('timestamp', descending: filter.sortDescending);
          break;
        case JobSortOption.startDate:
          query = query.orderBy('startDate', descending: filter.sortDescending);
          break;
        case JobSortOption.wage:
          query = query.orderBy('wage', descending: filter.sortDescending);
          break;
        case JobSortOption.distance:
          // Distance sorting requires location-based queries
          query = query.orderBy('timestamp', descending: true);
          break;
      }

      // Pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      query = query.limit(limit);

      return await query.get();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'getJobsWithFilter',
      );
    } else {
      return operation();
    }
  }

  /// Get popular jobs with caching
  Future<List<Map<String, dynamic>>> getCachedPopularJobs() async {
    // Try cache first
    final cachedJobs = await _cacheService.getCachedPopularJobs();
    if (cachedJobs != null) {
      return cachedJobs;
    }

    // Fetch from Firestore
    try {
      final snapshot = await getJobs(limit: 10).first;
      final jobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      await _cacheService.cachePopularJobs(jobs);
      return jobs;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching popular jobs for caching: $e');
      }
      return [];
    }
  }

  /// Share a job with a crew
  Future<void> shareJob(String crewId, Job job) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      final crew = await getCrew(crewId);
      final jobToShare = job.copyWith(matchesCriteria: _computeJobMatch(job.jobDetails, (crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {}));

      // Calculate match score as weighted average of individual criteria
      double score = 0.0;

      // Hours match
      double jobHours = jobToShare.jobDetails['hours']?.toDouble() ?? 0.0;
      double prefHours = ((crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {})['hoursWorked']?.toDouble() ?? 0.0;
      bool hoursMatch = jobHours >= prefHours;
      score += hoursMatch ? 0.3 : 0.0;

      // Pay rate match
      double jobPay = jobToShare.jobDetails['payRate']?.toDouble() ?? 0.0;
      double prefPay = ((crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {})['payRate']?.toDouble() ?? 0.0;
      bool payMatch = jobPay >= prefPay;
      score += payMatch ? 0.3 : 0.0;

      // Per diem match
      double jobPerDiem = jobToShare.jobDetails['perDiem']?.toDouble() ?? 0.0;
      double prefPerDiem = ((crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {})['perDiem']?.toDouble() ?? 0.0;
      bool perDiemMatch = jobPerDiem >= prefPerDiem;
      score += perDiemMatch ? 0.2 : 0.0;

      // Contractor match
      bool jobContractor = jobToShare.jobDetails['contractor'] ?? false;
      bool prefContractor = ((crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {})['contractor'] ?? false;
      bool contractorMatch = jobContractor == prefContractor;
      score += contractorMatch ? 0.1 : 0.0;

      // Location match
      GeoPoint? jobLoc = jobToShare.jobDetails['location'];
      GeoPoint? prefLoc = ((crew?.data() as Map<String, dynamic>)['jobPreferences'] ?? {})['location'];
      bool locationMatch = true;
      if (jobLoc != null && prefLoc != null) {
        double distance = Geolocator.distanceBetween(
          jobLoc.latitude,
          jobLoc.longitude,
          prefLoc.latitude,
          prefLoc.longitude,
        ) / 1000.0; // Convert to km
        locationMatch = distance <= 100;
      }
      score += locationMatch ? 0.1 : 0.0;

      final batch = _firestore.batch();
      final jobRef = crewsCollection.doc(crewId).collection('jobs').doc();
      batch.set(jobRef, jobToShare.toFirestore());

      // Always increment total jobs shared
      Map<String, dynamic> crewUpdates = {
        'stats.totalJobsShared': FieldValue.increment(1),
      };

      // If matches criteria, update match stats
      if (jobToShare.matchesCriteria) {
        crewUpdates['stats.totalMatchScore'] = FieldValue.increment(score);
        crewUpdates['stats.matchCount'] = FieldValue.increment(1);
      }

      batch.update(crewsCollection.doc(crewId), crewUpdates);
      await batch.commit();

      final jobId = jobRef.id;

      // // Send notifications to crew members
      // if (crew != null) {
      //   final members = await usersCollection.where('crewIds', arrayContains: crewId).get();
      //   for (var memberDoc in members.docs) {
      //     final memberId = memberDoc.id;
      //     if (memberId != uid) { // Exclude sharer
      //       final user = UserModel.fromFirestore(memberDoc);
      //       final token = user.fcmToken;
      //       if (token != null && token.isNotEmpty) {
      //         await NotificationService.sendNotification(
      //           token: token,
      //           title: 'New Job Shared in Crew',
      //           body: '${jobToShare.jobTitle} at ${jobToShare.company}',
      //           data: {
      //             'type': 'job',
      //             'jobId': jobId,
      //             'crewId': crewId,
      //           },
      //         );
      //       }
      //     }
      //   }
      // }
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'shareJob',
      );
    } else {
      return operation();
    }
  }

  bool _computeJobMatch(Map<String, dynamic> jobDetails, Map<String, dynamic> prefs) {
    // Hours check
    double jobHours = jobDetails['hours']?.toDouble() ?? 0.0;
    double prefHours = prefs['hoursWorked']?.toDouble() ?? 0.0;
    if (jobHours < prefHours) return false;

    // Pay rate check
    double jobPay = jobDetails['payRate']?.toDouble() ?? 0.0;
    double prefPay = prefs['payRate']?.toDouble() ?? 0.0;
    if (jobPay < prefPay) return false;

    // Per diem check
    double jobPerDiem = jobDetails['perDiem']?.toDouble() ?? 0.0;
    double prefPerDiem = prefs['perDiem']?.toDouble() ?? 0.0;
    if (jobPerDiem < prefPerDiem) return false;

    // Contractor check
    bool jobContractor = jobDetails['contractor'] ?? false;
    bool prefContractor = prefs['contractor'] ?? false;
    if (jobContractor != prefContractor) return false;

    // Location check
    GeoPoint? jobLoc = jobDetails['location'];
    GeoPoint? prefLoc = prefs['location'];
    if (jobLoc != null && prefLoc != null) {
      double distance = Geolocator.distanceBetween(
        jobLoc.latitude,
        jobLoc.longitude,
        prefLoc.latitude,
        prefLoc.longitude,
      ) / 1000.0; // Convert to km
      if (distance > 100) return false;
    }
    // If no locations, assume match

    return true;
  }

  String _generateDirectConvId(List<String> participants) {
    participants.sort();
    return participants.join('_');
  }
  
  // ============================================================================
  // LOCAL UNION OPERATIONS
  // ============================================================================

  // ============================================================================
  // CREW OPERATIONS
  // ============================================================================

  /// Get crew document
  Future<DocumentSnapshot?> getCrew(String crewId) async {
    Future<DocumentSnapshot> operation() => crewsCollection.doc(crewId).get();

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'getCrew',
      );
    } else {
      return operation();
    }
  }

  /// Create a new crew
  Future<String> createCrew(Map<String, dynamic> crewData) async {
    Future<String> operation() async {
      final ref = await crewsCollection.add(crewData);
      // Add to foreman's crewIds
      await usersCollection.doc(crewData['foremanId']).update({
        'crewIds': FieldValue.arrayUnion([ref.id]),
      });
    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'createCrew',
      );
    } else {
      return operation();
    }
  }

  /// Join a crew
  Future<void> joinCrew(String crewId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([uid]),
      });
      await usersCollection.doc(uid).update({
        'crewIds': FieldValue.arrayUnion([crewId]),
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'joinCrew',
      );
    } else {
      return operation();
    }
  }

  /// Remove a member from a crew
  Future<void> removeMember(String crewId, String memberId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      final crew = await getCrew(crewId);
      if ((crew?.data() as Map<String, dynamic>)['foremanId'] != uid) {
        throw Exception('Not authorized to remove member');
      }
      await crewsCollection.doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
      });
      await usersCollection.doc(memberId).update({
        'crewIds': FieldValue.arrayRemove([crewId]),
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'removeMember',
      );
    } else {
      return operation();
    }
  }

  /// Update job preferences for a crew
  Future<void> updateJobPreferences(String crewId, Map<String, dynamic> prefs) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      final crew = await getCrew(crewId);
      if ((crew?.data() as Map<String, dynamic>)['foremanId'] != uid) {
        throw Exception('Not authorized to update job preferences');
      }
      await crewsCollection.doc(crewId).update({'jobPreferences': prefs});
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'updateJobPreferences',
      );
    } else {
      return operation();
    }
  }

  // ============================================================================
  // FEED POSTS
  // ============================================================================

  /// Get feed posts stream
  Stream<QuerySnapshot> streamFeedPosts(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Stream<QuerySnapshot> operation() {
      Query query = crewsCollection.doc(crewId).collection('feedPosts')
          .where('deleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      return query.snapshots();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'streamFeedPosts',
      );
    } else {
      return operation();
    }
  }

  /// Create a new feed post
  Future<void> createPost(String crewId, Map<String, dynamic> postData, {List<File>? mediaFiles}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      // List<String> mediaUrls = [];
      // if (mediaFiles != null && mediaFiles.isNotEmpty) {
      //   final connectivity = ConnectivityService();
      //   try {
      //     for (var file in mediaFiles) {
      //       final timestamp = DateTime.now().millisecondsSinceEpoch;
      //       final path = 'crews/$crewId/posts/${postData['id']}/media/$timestamp';
      //       final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
      //       if (url != null) {
      //         mediaUrls.add(url);
      //       }
      //     }
      //     postData['mediaUrls'] = mediaUrls;
      //   } on AppException {
      //     // Log error, continue without media
      //   } catch (e) {
      //     throw AppException('Failed to upload media: $e');
      //   }
      // }

      final postRef = await crewsCollection.doc(crewId).collection('feedPosts').add(postData);
      final postId = postRef.id;

      // // Send notifications to crew members except author
      // final crew = await getCrew(crewId);
      // if (crew != null) {
      //   final members = await usersCollection.where('crewIds', arrayContains: crewId).get();
      //   for (var memberDoc in members.docs) {
      //     final memberId = memberDoc.id;
      //     if (memberId != uid) {
      //       final user = UserModel.fromFirestore(memberDoc);
      //       final token = user.fcmToken;
      //       if (token != null && token.isNotEmpty) {
      //         await NotificationService.sendNotification(
      //           token: token,
      //           title: 'New Post in Crew',
      //           body: postData['content'],
      //           data: {
      //             'type': 'post',
      //             'postId': postId,
      //             'crewId': crewId,
      //           },
      //         );
      //       }
      //     }
      //   }
      // }
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'addPost',
      );
    } else {
      return operation();
    }
  }

  /// Like a feed post
  Future<void> likePost(String crewId, String postId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      await crewsCollection.doc(crewId).collection('feedPosts').doc(postId).update({
        'likes': FieldValue.arrayUnion([uid]),
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'likePost',
      );
    } else {
      return operation();
    }
  }

  /// Delete a feed post
  Future<void> deletePost(String crewId, String postId, String authorId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    if (uid != authorId) {
      throw Exception('Not authorized to delete post');
    }

    Future<void> operation() async {
      await crewsCollection.doc(crewId).collection('feedPosts').doc(postId).update({'deleted': true});
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'deletePost',
      );
    } else {
      return operation();
    }
  }

  /// Get locals stream with optional state filter and pagination
  ///
  /// Automatically applies sharding strategy if enabled and state filter provided.
  Stream<QuerySnapshot> getLocals({
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    String? state,
  }) {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    if (kDebugMode) {
      print('🔍 UnifiedFirestoreService.getLocals called:');
      print('  - Collection: locals');
      print('  - Limit: $limit');
      print('  - State filter: ${state ?? "none"}');
      print('  - Start after: ${startAfter != null ? "yes" : "no"}');
      print('  - Sharding enabled: ${_shardingStrategy != null}');
    }

    // Use sharding strategy if enabled and state filter provided
    if (_shardingStrategy != null && state != null && state.isNotEmpty) {
      Stream<QuerySnapshot<Object?>> operation() => _shardingStrategy.getLocalsOptimized(
        limit: limit,
        startAfter: startAfter,
        state: state,
      );

      if (_resilienceStrategy != null) {
        return _resilienceStrategy.executeStreamWithRetry(
          operation,
          operationName: 'getLocals',
        );
      } else {
        return operation();
      }
    }

    // Default implementation
    Stream<QuerySnapshot<Object?>> operation() {
      Query query = localsCollection;

      // Apply geographic filtering if provided
      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }

      // Always enforce pagination
      query = query.limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      if (kDebugMode) {
        print('📡 Executing query on locals collection...');
      }

      return query.snapshots();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeStreamWithRetry(
        operation,
        operationName: 'getLocals',
      );
    } else {
      return operation();
    }
  }

  /// Search locals with basic prefix matching
  ///
  /// For enhanced search with relevance ranking, use searchLocalsEnhanced().
  Future<QuerySnapshot> searchLocals(
    String searchTerm, {
    int limit = defaultPageSize,
    String? state,
  }) async {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    Future<QuerySnapshot<Object?>> operation() async {
      Query query = localsCollection;

      // Apply geographic filtering first (most selective)
      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }

      // Apply search filter
      query = query
          .where('local_union', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where('local_union', isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff')
          .limit(limit);

      return await query.get();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'searchLocals',
      );
    } else {
      return operation();
    }
  }

  /// Enhanced locals search with full-text capabilities and relevance ranking
  ///
  /// Uses search strategy if enabled for optimized multi-term search.
  /// Falls back to basic search if strategy disabled.
  Future<List<LocalsRecord>> searchLocalsEnhanced(
    String query, {
    String? state,
    int limit = 20,
  }) async {
    if (_searchStrategy != null) {
      return _searchStrategy.searchLocalsEnhanced(
        query,
        state: state,
        limit: limit,
      );
    } else {
      // Fallback to basic search
      final snapshot = await searchLocals(query, state: state, limit: limit);
      return snapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();
    }
  }

  /// Get single local document
  Future<DocumentSnapshot> getLocal(String localId) async {
    Future<DocumentSnapshot<Object?>> operation() => localsCollection.doc(localId).get();

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'getLocal',
      );
    } else {
      return operation();
    }
  }

  /// Get locals with caching
  Future<List<Map<String, dynamic>>> getCachedLocals() async {
    // Try cache first
    final cachedLocals = await _cacheService.getCachedLocals();
    if (cachedLocals != null) {
      return cachedLocals;
    }

    // Fetch from Firestore
    try {
      final snapshot = await getLocals(limit: 100).first;
      final locals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        data['id'] = doc.id;
        return data;
      }).toList();

      await _cacheService.cacheLocals(locals);
      return locals;
    } catch (e) {
      if (kDebugMode) {
        print('Error fetching locals for caching: $e');
      }
      return [];
    }
  }

  // ============================================================================
  // CHAT OPERATIONS
  // ============================================================================

  /// Get or create a conversation
  Future<String> getOrCreateConversation(String crewId, {bool isDirect = false, List<String>? participants}) async {
    Future<String> operation() async {
      final convId = isDirect ? _generateDirectConvId(participants!) : 'crew_chat';
      final ref = crewsCollection.doc(crewId).collection('conversations').doc(convId);
      final doc = await ref.get();
      if (!doc.exists) {
        await ref.set({
          'type': isDirect ? 'direct' : 'crew',
          'participantIds': isDirect ? participants : [],
          'lastMessage': '',
          'lastMessageTime': FieldValue.serverTimestamp(),
        });
      }
      return convId;
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'getOrCreateConversation',
      );
    } else {
      return operation();
    }
  }

  /// Get messages stream
  Stream<QuerySnapshot> streamMessages(String crewId, String conversationId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Stream<QuerySnapshot> operation() {
      Query query = crewsCollection.doc(crewId).collection('conversations').doc(conversationId)
          .collection('messages')
          .where('deleted', isEqualTo: false)
          .orderBy('timestamp', descending: false)
          .limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }
      return query.snapshots();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'streamMessages',
      );
    } else {
      return operation();
    }
  }

  /// Send a message
  Future<void> sendMessage(String crewId, String conversationId, Message message, {List<File>? mediaFiles}) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      // if (mediaFiles != null && mediaFiles.isNotEmpty) {
      //   final connectivity = ConnectivityService();
      //   try {
      //     List<Attachment> attachments = [];
      //     for (var file in mediaFiles) {
      //       final timestamp = DateTime.now().millisecondsSinceEpoch;
      //       final path = 'crews/$crewId/conversations/$conversationId/messages/${message.id}/media/$timestamp';
      //       final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
      //       if (url != null) {
      //         // Create an Attachment object instead of just storing the URL
      //         final attachment = Attachment(
      //           url: url,
      //           filename: file.path.split('/').last,
      //           type: _getAttachmentTypeFromFile(file),
      //           sizeBytes: await file.length(),
      //         );
      //         attachments.add(attachment);
      //       }
      //     }
      //     // Update message with attachments instead of mediaUrls
      //     message = message.copyWith(attachments: attachments);
      //   } on AppException {
      //     // Log error, continue without media
      //   } catch (e) {
      //     throw AppException('Failed to upload media: $e');
      //   }
      // }
      final batch = _firestore.batch();
      final messageRef = crewsCollection.doc(crewId).collection('conversations').doc(conversationId)
          .collection('messages').doc();
      batch.set(messageRef, message.toFirestore());
      batch.update(crewsCollection.doc(crewId).collection('conversations').doc(conversationId), {
        'lastMessage': message.content,
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
      await batch.commit();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'sendMessage',
      );
    } else {
      return operation();
    }
  }

  /// Mark a message as read
  Future<void> markAsRead(String crewId, String conversationId, String messageId) async {
    final uid = _auth.currentUser?.uid;
    if (uid == null) return;

    Future<void> operation() async {
      await crewsCollection.doc(crewId).collection('conversations').doc(conversationId)
          .collection('messages').doc(messageId).update({
        'readBy': FieldValue.arrayUnion([uid]),
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'markAsRead',
      );
    } else {
      return operation();
    }
  }

  /// Get conversation stream
  Stream<DocumentSnapshot> streamConversation(String crewId, String convId) {
    Stream<DocumentSnapshot> operation() {
      return crewsCollection.doc(crewId).collection('conversations').doc(convId).snapshots();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'streamConversation',
      );
    } else {
      return operation();
    }
  }

  /// Get conversations stream
  Stream<List<conv.Conversation>> streamConversations(String crewId) {
    Stream<List<conv.Conversation>> operation() {
      return crewsCollection.doc(crewId).collection('conversations')
          .where('deleted', isEqualTo: false)
          .snapshots()
          .map((snap) => snap.docs.map((doc) => conv.Conversation.fromFirestore(doc)).toList());
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'streamConversations',
      );
    } else {
      return operation();
    }
  }

  /// Update typing status
  Future<void> updateTyping(String crewId, String convId, String userId, bool typing) async {
    Future<void> operation() async {
      final updateData = typing
          ? {'typingUsers': FieldValue.arrayUnion([userId])}
          : {'typingUsers': FieldValue.arrayRemove([userId])};
      await crewsCollection.doc(crewId).collection('conversations').doc(convId).update(updateData);
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'updateTyping',
      );
    } else {
      return operation();
    }
  }

  /// Batch create a new feed post and notify crew members
  Future<void> batchCreatePostAndNotify(String crewId, PostModel post, {List<File>? mediaFiles}) async {
    Future<void> operation() async {
      // List<String> mediaUrls = [];
      // if (mediaFiles != null && mediaFiles.isNotEmpty) {
      //   final connectivity = ConnectivityService();
      //   try {
      //     for (var file in mediaFiles) {
      //       final timestamp = DateTime.now().millisecondsSinceEpoch;
      //       final path = 'crews/$crewId/posts/${post.id}/media/$timestamp';
      //       final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
      //       if (url != null) {
      //         mediaUrls.add(url);
      //       }
      //     }
      //     post = post.copyWith(mediaUrls: mediaUrls);
      //   } on AppException {
      //     // Log error, continue without media
      //   } catch (e) {
      //     throw AppException('Failed to upload media: $e');
      //   }
      // }
      final batch = _firestore.batch();
      final postRef = crewsCollection.doc(crewId).collection('feedPosts').doc();
      batch.set(postRef, post.toFirestore());
      batch.update(crewsCollection.doc(crewId), {
        'stats.totalPosts': FieldValue.increment(1),
      });
      await batch.commit();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'batchCreatePostAndNotify',
      );
    } else {
      return operation();
    }
  }

  AttachmentType _getAttachmentTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return AttachmentType.image;
      case 'mp4':
      case 'mov':
      case 'avi':
      case 'mkv':
        return AttachmentType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'm4a':
        return AttachmentType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'xls':
      case 'xlsx':
        return AttachmentType.document;
      default:
        return AttachmentType.file;
    }
  }

  // ============================================================================
  // CONTRACTOR OPERATIONS
  // ============================================================================

  /// Get contractors stream
  Stream<List<Contractor>> streamContractors({int limit = 50, DocumentSnapshot? startAfter}) {
    Stream<List<Contractor>> operation() {
      Query query = stormContractorsCollection
          .orderBy('company')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Contractor.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'streamContractors',
      );
    } else {
      return operation();
    }
  }


  /// Get a single contractor
  Future<Contractor?> getContractor(String contractorId) async {
    Future<Contractor?> operation() async {
      final doc = await stormContractorsCollection.doc(contractorId).get();
      if (!doc.exists) return null;
      return Contractor.fromJson(doc.data() as Map<String, dynamic>);
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'getContractor',
      );
    } else {
      return operation();
    }
  }

  /// Search for contractors
  Stream<List<Contractor>> searchContractors(String searchQuery) {
    Stream<List<Contractor>> operation() {
      if (searchQuery.isEmpty) {
        return streamContractors();
      }

      // Firestore doesn't support full-text search, so we'll get all and filter
      return stormContractorsCollection
          .orderBy('company')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Contractor.fromJson(doc.data() as Map<String, dynamic>))
            .where((contractor) =>
                contractor.company.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      });
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeStreamWithRetry(
        operation,
        operationName: 'searchContractors',
      );
    } else {
      return operation();
    }
  }

  /// Create a new contractor
  Future<String> createContractor(Contractor contractor) async {
    Future<String> operation() async {
      final docRef = stormContractorsCollection.doc();
      final newContractor = contractor.copyWith(id: docRef.id);
      await docRef.set(newContractor.toFirestore());
      return docRef.id;
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'createContractor',
      );
    } else {
      return operation();
    }
  }

  /// Update a contractor
  Future<void> updateContractor(Contractor contractor) async {
    Future<void> operation() async {
      await stormContractorsCollection
          .doc(contractor.id)
          .update(contractor.toFirestore());
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'updateContractor',
      );
    } else {
      return operation();
    }
  }

  /// Delete a contractor
  Future<void> deleteContractor(String contractorId) async {
    Future<void> operation() async {
      await stormContractorsCollection.doc(contractorId).delete();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy!.executeWithRetry(
        operation,
        operationName: 'deleteContractor',
      );
    } else {
      return operation();
    }
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Execute batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    Future<void> operation() async {
      final batch = _firestore.batch();

      for (final op in operations) {
        switch (op.type) {
          case OperationType.create:
            batch.set(op.reference, op.data!);
            break;
          case OperationType.update:
            batch.update(op.reference, op.data!);
            break;
          case OperationType.delete:
            batch.delete(op.reference);
            break;
        }
      }

      await batch.commit();
    }

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'batchWrite',
      );
    } else {
      return operation();
    }
  }

  /// Execute transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async {
    Future<T> operation() => _firestore.runTransaction(handler);

    if (_resilienceStrategy != null) {
      return _resilienceStrategy.executeWithRetry(
        operation,
        operationName: 'runTransaction',
      );
    } else {
      return operation();
    }
  }

  // ============================================================================
  // CACHE MANAGEMENT
  // ============================================================================

  /// Clear all caches
  Future<void> clearCache() async {
    await _cacheService.clear();
  }

  /// Get cache statistics
  Map<String, dynamic> getCacheStats() {
    return _cacheService.getStats();
  }

  // ============================================================================
  // MONITORING & OBSERVABILITY
  // ============================================================================

  /// Get comprehensive service statistics
  ///
  /// Returns aggregated statistics from all enabled strategies plus
  /// overall service health metrics.
  Map<String, dynamic> getServiceStatistics() {
    final stats = <String, dynamic>{
      'service': 'UnifiedFirestoreService',
      'timestamp': DateTime.now().toIso8601String(),
      'strategies': {
        'resilience': _resilienceStrategy != null ? 'enabled' : 'disabled',
        'search': _searchStrategy != null ? 'enabled' : 'disabled',
        'sharding': _shardingStrategy != null ? 'enabled' : 'disabled',
      },
    };

    if (_resilienceStrategy != null) {
      stats['resilience'] = _resilienceStrategy.getStatistics();
    }

    if (_searchStrategy != null) {
      stats['search'] = _searchStrategy.getStatistics();
    }

    if (_shardingStrategy != null) {
      stats['sharding'] = _shardingStrategy.getStatistics();
    }

    stats['cache'] = getCacheStats();

    return stats;
  }

  /// Get circuit breaker status (resilience strategy)
  Map<String, dynamic>? getCircuitBreakerStatus() {
    if (_resilienceStrategy != null) {
      final stats = _resilienceStrategy.getStatistics();
      return stats['circuitBreaker'] as Map<String, dynamic>?;
    }
    return null;
  }

  /// Get search statistics (search strategy)
  Map<String, dynamic>? getSearchStatistics() {
    return _searchStrategy?.getStatistics();
  }

  /// Get sharding statistics (sharding strategy)
  Map<String, dynamic>? getShardingStatistics() {
    return _shardingStrategy?.getStatistics();
  }

  /// Reset all strategies (useful for testing)
  void resetStrategies() {
    _resilienceStrategy?.reset();
    _searchStrategy?.reset();
    _shardingStrategy?.reset();
  }

  /// Manually reset circuit breaker
  void resetCircuitBreaker() {
    _resilienceStrategy?.reset();
  }
}

// ============================================================================
// HELPER CLASSES
// ============================================================================

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

/// Batch operation types
enum OperationType { create, update, delete, loadJobs }

/// Batch operation descriptor
class BatchOperation {
  final DocumentReference reference;
  final OperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.reference,
    required this.type,
    this.data,
  });
}

/// Search metrics for analytics
class SearchMetrics {
  final String query;
  final int resultCount;
  final Duration responseTime;
  final bool cacheHit;
  final DateTime timestamp;
  final String? error;

  SearchMetrics({
    required this.query,
    required this.resultCount,
    required this.responseTime,
    required this.cacheHit,
    required this.timestamp,
    this.error,
  });

  Map<String, dynamic> toJson() {
    return {
      'query': query,
      'resultCount': resultCount,
      'responseTimeMs': responseTime.inMilliseconds,
      'cacheHit': cacheHit,
      'timestamp': timestamp.toIso8601String(),
      'error': error,
    };
  }
}
