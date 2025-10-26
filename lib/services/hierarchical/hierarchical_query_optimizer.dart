import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Optimizes Firebase queries for hierarchical data loading
///
/// This service provides intelligent query optimization strategies
/// for loading Union → Local → Members → Job hierarchy efficiently.
///
/// Features:
/// - Batch query optimization to avoid Firestore limits
/// - Query result caching and deduplication
/// - Progressive loading strategies
/// - Performance monitoring and metrics
/// - Adaptive query planning based on data characteristics
class HierarchicalQueryOptimizer {
  final FirebaseFirestore _firestore;

  // Query cache
  final Map<String, _CachedQueryResult> _queryCache = {};

  // Performance metrics
  final Map<String, _QueryMetrics> _queryMetrics = {};

  // Configuration
  final Duration _cacheTimeout = const Duration(minutes: 5);
  final int _maxCacheSize = 100;
  final int _maxBatchSize = 10; // Firestore 'in' query limit
  final int _maxDocumentsPerQuery = 100;

  HierarchicalQueryOptimizer({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Optimized query for loading locals
  Future<QuerySnapshot> getOptimizedLocalsQuery({
    List<int>? preferredLocals,
    String? locationFilter,
    bool? isActive,
    int limit = 100,
  }) async {
    debugPrint('[HierarchicalQueryOptimizer] Building optimized locals query...');

    final cacheKey = _buildLocalsCacheKey(preferredLocals, locationFilter, isActive, limit);

    // Check cache first
    final cachedResult = _getCachedQuery(cacheKey);
    if (cachedResult != null) {
      debugPrint('[HierarchicalQueryOptimizer] Returning cached locals query result');
      return cachedResult.snapshot;
    }

    final stopwatch = Stopwatch()..start();

    try {
      Query query = _firestore.collection('locals');

      // Add filters
      if (isActive != null) {
        query = query.where('isActive', isEqualTo: isActive);
      }

      if (preferredLocals != null && preferredLocals.isNotEmpty) {
        // Use batch queries for preferred locals
        return await _executeBatchLocalsQuery(
          query,
          preferredLocals,
          cacheKey,
          stopwatch,
        );
      }

      if (locationFilter != null && locationFilter.isNotEmpty) {
        // For location filtering, we'll need to query and filter client-side
        // since Firestore doesn't support full-text search
        query = query.orderBy('local_union').limit(limit);
      } else {
        query = query.orderBy('local_union').limit(limit);
      }

      final snapshot = await query.get();
      stopwatch.stop();

      // Apply location filter client-side if needed
      final filteredSnapshot = _applyLocationFilter(snapshot, locationFilter);

      // Cache the result
      _cacheQueryResult(cacheKey, filteredSnapshot, stopwatch.elapsed);

      _recordQueryMetrics('locals_query', stopwatch.elapsed, filteredSnapshot.size);

      debugPrint('[HierarchicalQueryOptimizer] Locals query completed in ${stopwatch.elapsedMilliseconds}ms');
      return filteredSnapshot;

    } catch (e) {
      stopwatch.stop();
      debugPrint('[HierarchicalQueryOptimizer] Locals query failed: $e');
      _recordQueryMetrics('locals_query', stopwatch.elapsed, 0, error: e.toString());
      rethrow;
    }
  }

  /// Optimized query for loading members
  Future<QuerySnapshot> getOptimizedMembersQuery({
    List<int>? localNumbers,
    String? classificationFilter,
    bool? isAvailable,
    int limit = 200,
  }) async {
    debugPrint('[HierarchicalQueryOptimizer] Building optimized members query...');

    final cacheKey = _buildMembersCacheKey(localNumbers, classificationFilter, isAvailable, limit);

    // Check cache first
    final cachedResult = _getCachedQuery(cacheKey);
    if (cachedResult != null) {
      debugPrint('[HierarchicalQueryOptimizer] Returning cached members query result');
      return cachedResult.snapshot;
    }

    final stopwatch = Stopwatch()..start();

    try {
      if (localNumbers == null || localNumbers.isEmpty) {
        // Return empty result if no locals specified
        return _createEmptySnapshot();
      }

      // Use batch queries for members by local
      final snapshots = await _executeBatchMembersQuery(
        localNumbers,
        classificationFilter,
        isAvailable,
        limit,
      );

      // Combine results from batch queries
      final combinedSnapshot = _combineSnapshots(snapshots);
      stopwatch.stop();

      // Cache the result
      _cacheQueryResult(cacheKey, combinedSnapshot, stopwatch.elapsed);

      _recordQueryMetrics('members_query', stopwatch.elapsed, combinedSnapshot.size);

      debugPrint('[HierarchicalQueryOptimizer] Members query completed in ${stopwatch.elapsedMilliseconds}ms');
      return combinedSnapshot;

    } catch (e) {
      stopwatch.stop();
      debugPrint('[HierarchicalQueryOptimizer] Members query failed: $e');
      _recordQueryMetrics('members_query', stopwatch.elapsed, 0, error: e.toString());
      rethrow;
    }
  }

  /// Optimized query for loading jobs
  Future<QuerySnapshot> getOptimizedJobsQuery({
    List<int>? localNumbers,
    String? classificationFilter,
    bool? onlyAvailable,
    DateTime? startDate,
    int limit = 200,
  }) async {
    debugPrint('[HierarchicalQueryOptimizer] Building optimized jobs query...');

    final cacheKey = _buildJobsCacheKey(localNumbers, classificationFilter, onlyAvailable, startDate, limit);

    // Check cache first
    final cachedResult = _getCachedQuery(cacheKey);
    if (cachedResult != null) {
      debugPrint('[HierarchicalQueryOptimizer] Returning cached jobs query result');
      return cachedResult.snapshot;
    }

    final stopwatch = Stopwatch()..start();

    try {
      if (localNumbers == null || localNumbers.isEmpty) {
        // Return empty result if no locals specified
        return _createEmptySnapshot();
      }

      // Use batch queries for jobs by local
      final snapshots = await _executeBatchJobsQuery(
        localNumbers,
        classificationFilter,
        onlyAvailable,
        startDate,
        limit,
      );

      // Combine results from batch queries
      final combinedSnapshot = _combineSnapshots(snapshots);
      stopwatch.stop();

      // Cache the result
      _cacheQueryResult(cacheKey, combinedSnapshot, stopwatch.elapsed);

      _recordQueryMetrics('jobs_query', stopwatch.elapsed, combinedSnapshot.size);

      debugPrint('[HierarchicalQueryOptimizer] Jobs query completed in ${stopwatch.elapsedMilliseconds}ms');
      return combinedSnapshot;

    } catch (e) {
      stopwatch.stop();
      debugPrint('[HierarchicalQueryOptimizer] Jobs query failed: $e');
      _recordQueryMetrics('jobs_query', stopwatch.elapsed, 0, error: e.toString());
      rethrow;
    }
  }

  /// Executes batch query for locals with 'in' clause
  Future<QuerySnapshot> _executeBatchLocalsQuery(
    Query baseQuery,
    List<int> localNumbers,
    String cacheKey,
    Stopwatch stopwatch,
  ) async {
    if (localNumbers.length <= _maxBatchSize) {
      // Single query if within batch size limit
      final query = baseQuery.where('local_union', whereIn: localNumbers.map((l) => l.toString()).toList());
      final snapshot = await query.get();

      _cacheQueryResult(cacheKey, snapshot, stopwatch.elapsed);
      return snapshot;
    }

    // Multiple batch queries for large lists
    final snapshots = <QuerySnapshot>[];

    for (int i = 0; i < localNumbers.length; i += _maxBatchSize) {
      final batch = localNumbers.skip(i).take(_maxBatchSize).toList();
      final query = baseQuery.where('local_union', whereIn: batch.map((l) => l.toString()).toList());
      final snapshot = await query.get();
      snapshots.add(snapshot);
    }

    final combinedSnapshot = _combineSnapshots(snapshots);
    _cacheQueryResult(cacheKey, combinedSnapshot, stopwatch.elapsed);
    return combinedSnapshot;
  }

  /// Executes batch query for members
  Future<List<QuerySnapshot>> _executeBatchMembersQuery(
    List<int> localNumbers,
    String? classificationFilter,
    bool? isAvailable,
    int limit,
  ) async {
    final snapshots = <QuerySnapshot>[];

    for (int i = 0; i < localNumbers.length; i += _maxBatchSize) {
      final batch = localNumbers.skip(i).take(_maxBatchSize).toList();

      Query query = _firestore.collection('users')
          .where('homeLocal', whereIn: batch)
          .where('isActive', isEqualTo: true);

      // Add optional filters
      if (classificationFilter != null && classificationFilter.isNotEmpty) {
        // Classification filtering would need to be done client-side
        // since Firestore doesn't support case-insensitive contains queries
      }

      if (isAvailable != null) {
        // Available filtering based on work status
        query = query.where('isWorking', isEqualTo: !isAvailable);
      }

      query = query.limit(_maxDocumentsPerQuery);

      final snapshot = await query.get();
      snapshots.add(snapshot);
    }

    return snapshots;
  }

  /// Executes batch query for jobs
  Future<List<QuerySnapshot>> _executeBatchJobsQuery(
    List<int> localNumbers,
    String? classificationFilter,
    bool? onlyAvailable,
    DateTime? startDate,
    int limit,
  ) async {
    final snapshots = <QuerySnapshot>[];

    for (int i = 0; i < localNumbers.length; i += _maxBatchSize) {
      final batch = localNumbers.skip(i).take(_maxBatchSize).toList();

      Query query = _firestore.collection('jobs')
          .where('local', whereIn: batch)
          .where('deleted', isEqualTo: false);

      // Add optional filters
      if (startDate != null) {
        query = query.where('timestamp', isGreaterThanOrEqualTo: Timestamp.fromDate(startDate));
      }

      query = query.orderBy('timestamp', descending: true)
                  .limit(_maxDocumentsPerQuery);

      final snapshot = await query.get();
      snapshots.add(snapshot);
    }

    return snapshots;
  }

  /// Applies location filter client-side
  QuerySnapshot _applyLocationFilter(QuerySnapshot snapshot, String? locationFilter) {
    if (locationFilter == null || locationFilter.trim().isEmpty) {
      return snapshot;
    }

    final lowerFilter = locationFilter.toLowerCase();
    final filteredDocs = snapshot.docs.where((doc) {
      final data = doc.data() as Map<String, dynamic>;

      // Check various location fields
      final city = (data['city'] as String?)?.toLowerCase() ?? '';
      final state = (data['state'] as String?)?.toLowerCase() ?? '';
      final location = (data['location'] as String?)?.toLowerCase() ?? '';
      final localName = (data['local_name'] as String?)?.toLowerCase() ?? '';

      return city.contains(lowerFilter) ||
             state.contains(lowerFilter) ||
             location.contains(lowerFilter) ||
             localName.contains(lowerFilter);
    }).toList();

    return QuerySnapshot(
      filteredDocs,
      snapshot.metadata,
      snapshot.docChanges,
    );
  }

  /// Combines multiple query snapshots
  QuerySnapshot _combineSnapshots(List<QuerySnapshot> snapshots) {
    final allDocs = <DocumentSnapshot>[];
    final allChanges = <DocumentChange>[];

    for (final snapshot in snapshots) {
      allDocs.addAll(snapshot.docs);
      allChanges.addAll(snapshot.docChanges);
    }

    // Remove duplicates (same document ID)
    final uniqueDocs = <String, DocumentSnapshot>{};
    for (final doc in allDocs) {
      uniqueDocs[doc.id] = doc;
    }

    return QuerySnapshot(
      uniqueDocs.values.toList(),
      snapshots.isNotEmpty ? snapshots.first.metadata : QueryMetadata(),
      allChanges,
    );
  }

  /// Creates empty query snapshot
  QuerySnapshot _createEmptySnapshot() {
    return QuerySnapshot(
      [],
      QueryMetadata(),
      [],
    );
  }

  /// Builds cache key for locals query
  String _buildLocalsCacheKey(
    List<int>? preferredLocals,
    String? locationFilter,
    bool? isActive,
    int limit,
  ) {
    return 'locals_${preferredLocals?.join(',') ?? 'all'}'
           '_${locationFilter ?? 'none'}'
           '_${isActive ?? true}'
           '_$limit';
  }

  /// Builds cache key for members query
  String _buildMembersCacheKey(
    List<int>? localNumbers,
    String? classificationFilter,
    bool? isAvailable,
    int limit,
  ) {
    return 'members_${localNumbers?.join(',') ?? 'all'}'
           '_${classificationFilter ?? 'none'}'
           '_${isAvailable ?? true}'
           '_$limit';
  }

  /// Builds cache key for jobs query
  String _buildJobsCacheKey(
    List<int>? localNumbers,
    String? classificationFilter,
    bool? onlyAvailable,
    DateTime? startDate,
    int limit,
  ) {
    return 'jobs_${localNumbers?.join(',') ?? 'all'}'
           '_${classificationFilter ?? 'none'}'
           '_${onlyAvailable ?? true}'
           '_${startDate?.millisecondsSinceEpoch ?? 'none'}'
           '_$limit';
  }

  /// Gets cached query result if fresh
  _CachedQueryResult? _getCachedQuery(String cacheKey) {
    final cached = _queryCache[cacheKey];
    if (cached == null) return null;

    if (DateTime.now().difference(cached.timestamp) > _cacheTimeout) {
      _queryCache.remove(cacheKey);
      return null;
    }

    return cached;
  }

  /// Caches query result
  void _cacheQueryResult(String cacheKey, QuerySnapshot snapshot, Duration queryTime) {
    // Remove oldest entries if cache is full
    if (_queryCache.length >= _maxCacheSize) {
      final oldestKey = _queryCache.keys.first;
      _queryCache.remove(oldestKey);
    }

    _queryCache[cacheKey] = _CachedQueryResult(
      snapshot: snapshot,
      timestamp: DateTime.now(),
      queryTime: queryTime,
    );
  }

  /// Records query metrics
  void _recordQueryMetrics(String queryType, Duration queryTime, int resultCount, {String? error}) {
    final metrics = _queryMetrics.putIfAbsent(
      queryType,
      () => _QueryMetrics(),
    );

    metrics.addQuery(queryTime, resultCount, error != null);

    if (kDebugMode) {
      debugPrint('[HierarchicalQueryOptimizer] Query metrics for $queryType: ${metrics.getSummary()}');
    }
  }

  /// Gets query performance summary
  Map<String, _QueryMetricsSummary> getPerformanceSummary() {
    final summary = <String, _QueryMetricsSummary>{};

    for (final entry in _queryMetrics.entries) {
      summary[entry.key] = entry.value.getSummary();
    }

    return summary;
  }

  /// Clears query cache
  void clearCache() {
    debugPrint('[HierarchicalQueryOptimizer] Clearing query cache...');
    _queryCache.clear();
  }

  /// Gets cache statistics
  Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _queryCache.length,
      'maxCacheSize': _maxCacheSize,
      'cacheHitRatio': _calculateCacheHitRatio(),
      'oldestEntryAge': _getOldestEntryAge(),
    };
  }

  /// Calculates cache hit ratio
  double _calculateCacheHitRatio() {
    if (_queryMetrics.isEmpty) return 0.0;

    int totalQueries = 0;
    int cacheHits = 0;

    for (final metrics in _queryMetrics.values) {
      totalQueries += metrics.totalQueries;
      // Assume cached queries are faster (less than 50ms)
      cacheHits += metrics.queryTimes.where((time) => time.inMilliseconds < 50).length;
    }

    return totalQueries > 0 ? cacheHits / totalQueries : 0.0;
  }

  /// Gets age of oldest cache entry
  Duration? _getOldestEntryAge() {
    if (_queryCache.isEmpty) return null;

    final oldestTimestamp = _queryCache.values
        .map((result) => result.timestamp)
        .reduce((a, b) => a.isBefore(b) ? a : b);

    return DateTime.now().difference(oldestTimestamp);
  }
}

/// Cached query result
class _CachedQueryResult {
  final QuerySnapshot snapshot;
  final DateTime timestamp;
  final Duration queryTime;

  const _CachedQueryResult({
    required this.snapshot,
    required this.timestamp,
    required this.queryTime,
  });
}

/// Query metrics for performance monitoring
class _QueryMetrics {
  final List<Duration> queryTimes = [];
  final List<int> resultCounts = [];
  int totalQueries = 0;
  int failedQueries = 0;

  void addQuery(Duration queryTime, int resultCount, bool failed) {
    queryTimes.add(queryTime);
    resultCounts.add(resultCount);
    totalQueries++;
    if (failed) failedQueries++;
  }

  _QueryMetricsSummary getSummary() {
    if (queryTimes.isEmpty) {
      return const _QueryMetricsSummary(
        totalQueries: 0,
        averageQueryTime: Duration.zero,
        fastestQueryTime: Duration.zero,
        slowestQueryTime: Duration.zero,
        averageResultCount: 0.0,
        failedQueryRatio: 0.0,
      );
    }

    final totalTime = queryTimes.fold<Duration>(
      Duration.zero,
      (sum, time) => sum + time,
    );

    final averageQueryTime = Duration(
      milliseconds: totalTime.inMilliseconds ~/ queryTimes.length,
    );

    final fastestQueryTime = queryTimes.reduce((a, b) => a < b ? a : b);
    final slowestQueryTime = queryTimes.reduce((a, b) => a > b ? a : b);

    final averageResultCount = resultCounts.reduce((a, b) => a + b) / resultCounts.length;
    final failedQueryRatio = totalQueries > 0 ? failedQueries / totalQueries : 0.0;

    return _QueryMetricsSummary(
      totalQueries: totalQueries,
      averageQueryTime: averageQueryTime,
      fastestQueryTime: fastestQueryTime,
      slowestQueryTime: slowestQueryTime,
      averageResultCount: averageResultCount,
      failedQueryRatio: failedQueryRatio,
    );
  }
}

/// Query metrics summary
@immutable
class _QueryMetricsSummary {
  final int totalQueries;
  final Duration averageQueryTime;
  final Duration fastestQueryTime;
  final Duration slowestQueryTime;
  final double averageResultCount;
  final double failedQueryRatio;

  const _QueryMetricsSummary({
    required this.totalQueries,
    required this.averageQueryTime,
    required this.fastestQueryTime,
    required this.slowestQueryTime,
    required this.averageResultCount,
    required this.failedQueryRatio,
  });

  @override
  String toString() {
    return 'QueryMetrics('
        'total: $totalQueries, '
        'avg: ${averageQueryTime.inMilliseconds}ms, '
        'fastest: ${fastestQueryTime.inMilliseconds}ms, '
        'slowest: ${slowestQueryTime.inMilliseconds}ms, '
        'avgResults: ${averageResultCount.toStringAsFixed(1)}, '
        'failureRate: ${(failedQueryRatio * 100).toStringAsFixed(1)}%'
        ')';
  }
}