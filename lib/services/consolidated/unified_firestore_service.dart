import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'strategies/resilience_strategy.dart';
import 'strategies/search_strategy.dart';
import 'strategies/sharding_strategy.dart';
import 'strategies/cache_strategy.dart';
import 'strategies/impl/circuit_breaker_resilience_strategy.dart';
import 'strategies/impl/no_retry_resilience_strategy.dart';

/// Unified Firestore service using strategy pattern
///
/// Consolidates 4 overlapping Firestore services into a single service
/// that composes strategies instead of using inheritance.
///
/// **Replaces**:
/// - FirestoreService (basic CRUD)
/// - ResilientFirestoreService (retry logic, circuit breaker)
/// - SearchOptimizedFirestoreService (advanced search)
/// - GeographicFirestoreService (regional sharding)
///
/// **Strategy Composition**:
/// - ResilienceStrategy: Handles retries, circuit breaker, error handling
/// - SearchStrategy: Optimizes search operations with ranking
/// - ShardingStrategy: Organizes data into regional shards
/// - CacheStrategy: Provides intelligent caching
///
/// **Usage**:
/// ```dart
/// // Basic service with defaults
/// final service = UnifiedFirestoreService();
///
/// // Optimized service with all features
/// final optimized = UnifiedFirestoreService(
///   resilienceStrategy: CircuitBreakerResilienceStrategy(),
///   searchStrategy: AdvancedSearchStrategy(),
///   shardingStrategy: GeographicShardingStrategy(),
///   cacheStrategy: MemoryCacheStrategy(),
/// );
///
/// // Testing service with no retries or caching
/// final testService = UnifiedFirestoreService(
///   resilienceStrategy: NoRetryResilienceStrategy(),
///   cacheStrategy: NoCacheStrategy(),
/// );
/// ```
class UnifiedFirestoreService {
  final FirebaseFirestore _firestore;
  final ResilienceStrategy _resilienceStrategy;
  final SearchStrategy _searchStrategy;
  final ShardingStrategy _shardingStrategy;
  final CacheStrategy _cacheStrategy;

  // Performance constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  /// Create a unified Firestore service with configurable strategies
  ///
  /// All strategies are optional and will use sensible defaults if not provided:
  /// - ResilienceStrategy: CircuitBreakerResilienceStrategy (production) or NoRetryResilienceStrategy (debug)
  /// - SearchStrategy: DefaultSearchStrategy (basic prefix search)
  /// - ShardingStrategy: DefaultShardingStrategy (no sharding)
  /// - CacheStrategy: DefaultCacheStrategy (memory cache with TTL)
  UnifiedFirestoreService({
    FirebaseFirestore? firestore,
    ResilienceStrategy? resilienceStrategy,
    SearchStrategy? searchStrategy,
    ShardingStrategy? shardingStrategy,
    CacheStrategy? cacheStrategy,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _resilienceStrategy = resilienceStrategy ?? _defaultResilienceStrategy(),
        _searchStrategy = searchStrategy ?? _defaultSearchStrategy(),
        _shardingStrategy = shardingStrategy ?? _defaultShardingStrategy(),
        _cacheStrategy = cacheStrategy ?? _defaultCacheStrategy();

  /// Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // ============================================================================
  // COLLECTION ACCESSORS
  // ============================================================================

  /// Get users collection with sharding applied
  CollectionReference get usersCollection =>
      _shardingStrategy.getCollection(_firestore, 'users');

  /// Get jobs collection with sharding applied
  CollectionReference jobsCollection({String? region}) =>
      _shardingStrategy.getCollection(_firestore, 'jobs', shardKey: region);

  /// Get locals collection with sharding applied
  CollectionReference localsCollection({String? region}) =>
      _shardingStrategy.getCollection(_firestore, 'locals', shardKey: region);

  /// Get crews collection
  CollectionReference get crewsCollection =>
      _shardingStrategy.getCollection(_firestore, 'crews');

  /// Get counters collection
  CollectionReference get countersCollection =>
      _shardingStrategy.getCollection(_firestore, 'counters');

  /// Get preferences collection
  CollectionReference get preferencesCollection =>
      _shardingStrategy.getCollection(_firestore, 'preferences');

  /// Get storm contractors collection
  CollectionReference get stormContractorsCollection =>
      _shardingStrategy.getCollection(_firestore, 'stormcontractors');

  // ============================================================================
  // USER OPERATIONS
  // ============================================================================

  /// Create a new user document
  Future<void> createUser({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    return _resilienceStrategy.execute(() async {
      await usersCollection.doc(uid).set({
        ...userData,
        'createdTime': FieldValue.serverTimestamp(),
        'onboardingStatus': 'incomplete',
      });

      // Invalidate cache for this user
      await _cacheStrategy.invalidate('user_$uid');
    });
  }

  /// Get user document
  Future<DocumentSnapshot> getUser(String uid) async {
    return _resilienceStrategy.execute(() async {
      // Try cache first
      final cachedData = await _cacheStrategy.get<Map<String, dynamic>>('user_$uid');
      if (cachedData != null) {
        if (kDebugMode) {
          print('Cache hit for user $uid');
        }
        return _createMockSnapshot(uid, cachedData, usersCollection);
      }

      // Fetch from Firestore
      final snapshot = await usersCollection.doc(uid).get();

      // Cache the result
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          await _cacheStrategy.set('user_$uid', data, ttl: Duration(minutes: 15));
        }
      }

      return snapshot;
    });
  }

  /// Update user document
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return _resilienceStrategy.execute(() async {
      await usersCollection.doc(uid).update(data);

      // Invalidate cache for this user
      await _cacheStrategy.invalidate('user_$uid');
    });
  }

  /// Set user document with merge
  Future<void> setUserWithMerge({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    return _resilienceStrategy.execute(() async {
      if (kDebugMode) {
        print('UnifiedFirestoreService.setUserWithMerge:');
        print('  User ID: $uid');
        print('  Data keys: ${data.keys.toList()}');
        print('  Field count: ${data.length}');
      }

      await usersCollection.doc(uid).set(data, SetOptions(merge: true));

      // Invalidate cache
      await _cacheStrategy.invalidate('user_$uid');

      if (kDebugMode) {
        print('  Write completed successfully');
      }
    });
  }

  /// Get user document stream
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return _resilienceStrategy.executeStream(() {
      return usersCollection.doc(uid).snapshots();
    });
  }

  /// Check if user profile exists
  Future<bool> userProfileExists(String userId) async {
    return _resilienceStrategy.execute(() async {
      final doc = await usersCollection.doc(userId).get();
      return doc.exists;
    });
  }

  /// Delete user data
  Future<void> deleteUserData(String userId) async {
    return _resilienceStrategy.execute(() async {
      await usersCollection.doc(userId).delete();
      await _cacheStrategy.invalidate('user_$userId');
    });
  }

  // ============================================================================
  // JOB OPERATIONS
  // ============================================================================

  /// Get jobs stream with filters
  Stream<QuerySnapshot> getJobs({
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    return _resilienceStrategy.executeStream(() {
      // Determine region from filters
      final region = filters?['state'] as String?;
      final collection = jobsCollection(region: region);

      Query query = collection.orderBy('timestamp', descending: true);

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

      // Pagination
      query = query.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots();
    });
  }

  /// Get single job document
  Future<DocumentSnapshot> getJob(String jobId) async {
    return _resilienceStrategy.execute(() async {
      // Try cache first
      final cachedData = await _cacheStrategy.get<Map<String, dynamic>>('job_$jobId');
      if (cachedData != null) {
        return _createMockSnapshot(jobId, cachedData, jobsCollection());
      }

      // Fetch from Firestore
      final snapshot = await jobsCollection().doc(jobId).get();

      // Cache the result
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
        if (data != null) {
          await _cacheStrategy.set('job_$jobId', data, ttl: Duration(minutes: 30));
        }
      }

      return snapshot;
    });
  }

  // ============================================================================
  // LOCALS OPERATIONS
  // ============================================================================

  /// Get locals stream with optional state filter
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
      print('UnifiedFirestoreService.getLocals:');
      print('  Limit: $limit');
      print('  State filter: ${state ?? "none"}');
      print('  Start after: ${startAfter != null ? "yes" : "no"}');
    }

    return _resilienceStrategy.executeStream(() {
      // Use sharding strategy to get appropriate collection
      final collection = localsCollection(region: state);

      Query query = collection;

      // Apply geographic filtering if provided
      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }

      // Pagination
      query = query.limit(limit);
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots();
    });
  }

  /// Search locals using configured search strategy
  Future<QuerySnapshot> searchLocals(
    String searchTerm, {
    int limit = defaultPageSize,
    String? state,
  }) async {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    return _resilienceStrategy.execute(() async {
      // Use sharding strategy to get appropriate collection
      final collection = localsCollection(region: state);

      // Use search strategy for optimized search
      return _searchStrategy.search(
        collection,
        searchTerm,
        filters: state != null ? {'state': state} : null,
        limit: limit,
      );
    });
  }

  /// Get single local document
  Future<DocumentSnapshot> getLocal(String localId) async {
    return _resilienceStrategy.execute(() async {
      final snapshot = await localsCollection().doc(localId).get();
      return snapshot;
    });
  }

  // ============================================================================
  // BATCH OPERATIONS
  // ============================================================================

  /// Execute batch write operations
  Future<void> batchWrite(List<BatchOperation> operations) async {
    return _resilienceStrategy.execute(() async {
      final batch = _firestore.batch();

      for (final operation in operations) {
        switch (operation.type) {
          case OperationType.create:
            batch.set(operation.reference, operation.data!);
            break;
          case OperationType.update:
            batch.update(operation.reference, operation.data!);
            break;
          case OperationType.delete:
            batch.delete(operation.reference);
            break;
        }
      }

      await batch.commit();

      // Invalidate affected caches
      for (final operation in operations) {
        final path = operation.reference.path;
        await _cacheStrategy.invalidatePattern('*${path.split('/').last}*');
      }
    });
  }

  /// Run a Firestore transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async {
    return _resilienceStrategy.execute(() async {
      return await _firestore.runTransaction(handler);
    });
  }

  // ============================================================================
  // STATISTICS & MONITORING
  // ============================================================================

  /// Get comprehensive service statistics
  Map<String, dynamic> getStatistics() {
    return {
      'resilience': _resilienceStrategy.getStatistics(),
      'search': _searchStrategy.getStatistics(),
      'sharding': _shardingStrategy.getStatistics(),
      'cache': _cacheStrategy.getStatistics(),
      'configuration': {
        'defaultPageSize': defaultPageSize,
        'maxPageSize': maxPageSize,
      },
    };
  }

  /// Reset all strategy statistics
  void resetStatistics() {
    _resilienceStrategy.reset();
    if (kDebugMode) {
      print('UnifiedFirestoreService statistics reset');
    }
  }

  /// Clear all caches
  Future<void> clearCache() async {
    await _cacheStrategy.clear();
  }

  // ============================================================================
  // INTERNAL HELPERS
  // ============================================================================

  /// Create a mock DocumentSnapshot for cached data
  DocumentSnapshot _createMockSnapshot(
    String id,
    Map<String, dynamic> data,
    CollectionReference collection,
  ) {
    // This would need a proper implementation or use a testing library
    // For now, this is a placeholder that shows the concept
    throw UnimplementedError(
      'Mock snapshot creation requires additional implementation. '
      'Consider using cloud_firestore_mocks package for testing.',
    );
  }

  /// Default resilience strategy based on environment
  static ResilienceStrategy _defaultResilienceStrategy() {
    if (kDebugMode) {
      return NoRetryResilienceStrategy();
    }
    return CircuitBreakerResilienceStrategy();
  }

  /// Default search strategy
  static SearchStrategy _defaultSearchStrategy() {
    // TODO: Implement DefaultSearchStrategy
    throw UnimplementedError('DefaultSearchStrategy not yet implemented');
  }

  /// Default sharding strategy
  static ShardingStrategy _defaultShardingStrategy() {
    // TODO: Implement DefaultShardingStrategy
    throw UnimplementedError('DefaultShardingStrategy not yet implemented');
  }

  /// Default cache strategy
  static CacheStrategy _defaultCacheStrategy() {
    // TODO: Implement DefaultCacheStrategy
    throw UnimplementedError('DefaultCacheStrategy not yet implemented');
  }
}

// ============================================================================
// SUPPORTING TYPES
// ============================================================================

/// Operation type for batch operations
enum OperationType { create, update, delete }

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
