import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../models/locals_record.dart';

/// Enhanced pagination service for IBEW Locals directory
///
/// Provides efficient cursor-based pagination with:
/// - Configurable page sizes
/// - State and classification filtering
/// - Automatic hasMore detection
/// - Memory-efficient document caching
class LocalsPaginationService {
  /// Page size for loading chunks of data
  final int pageSize;

  /// Last document snapshot from previous query (for cursor-based pagination)
  DocumentSnapshot? _lastDocument;

  /// Whether more documents are available to load
  bool _hasMore = true;

  /// Current filter state for consistent queries
  String? _currentStateFilter;
  String? _currentClassificationFilter;

  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Creates a pagination service with specified page size
  ///
  /// [pageSize] - Number of records to load per page (default: 50)
  /// [firestore] - Optional Firestore instance (defaults to FirebaseFirestore.instance)
  LocalsPaginationService({
    this.pageSize = 50,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Whether more data is available to load
  bool get hasMore => _hasMore;

  /// The last document snapshot from the previous query
  DocumentSnapshot? get lastDocument => _lastDocument;

  /// Loads the next page of locals data
  ///
  /// Returns a list of [LocalsRecord] objects for the next page.
  /// Returns empty list if no more data available.
  ///
  /// [stateFilter] - Optional state abbreviation to filter by (e.g., 'CA', 'TX')
  /// [classificationFilter] - Optional classification to filter by (e.g., 'Inside Wireman')
  ///
  /// Throws [FirebaseException] if query fails.
  Future<List<LocalsRecord>> loadNextPage({
    String? stateFilter,
    String? classificationFilter,
  }) async {
    // Check if we've reached the end
    if (!_hasMore) {
      if (kDebugMode) {
        print('[LocalsPaginationService] No more data to load');
      }
      return [];
    }

    // Check if filters changed - reset pagination if so
    if (stateFilter != _currentStateFilter ||
        classificationFilter != _currentClassificationFilter) {
      reset();
      _currentStateFilter = stateFilter;
      _currentClassificationFilter = classificationFilter;
    }

    try {
      // Build query with filters
      Query query = _firestore.collection('locals');

      // Apply state filter if provided
      if (stateFilter != null && stateFilter.isNotEmpty) {
        query = query.where('state', isEqualTo: stateFilter);
      }

      // Apply classification filter if provided
      if (classificationFilter != null && classificationFilter.isNotEmpty) {
        query = query.where('classification', isEqualTo: classificationFilter);
      }

      // Order by local_union number for consistent pagination
      query = query.orderBy('local_union');

      // Apply cursor pagination if we have a last document
      if (_lastDocument != null) {
        query = query.startAfterDocument(_lastDocument!);
      }

      // Limit results to page size
      query = query.limit(pageSize);

      if (kDebugMode) {
        print('[LocalsPaginationService] Loading page:');
        print('  - State filter: ${stateFilter ?? "none"}');
        print('  - Classification filter: ${classificationFilter ?? "none"}');
        print('  - Has last document: ${_lastDocument != null}');
        print('  - Page size: $pageSize');
      }

      // Execute query
      final snapshot = await query.get();

      // Check if we've reached the end (fewer results than page size)
      if (snapshot.docs.isEmpty || snapshot.docs.length < pageSize) {
        _hasMore = false;
        if (kDebugMode) {
          print('[LocalsPaginationService] Reached end of data (${snapshot.docs.length} docs)');
        }
      }

      // Update last document for next query
      if (snapshot.docs.isNotEmpty) {
        _lastDocument = snapshot.docs.last;
      }

      // Convert documents to LocalsRecord objects
      final locals = snapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();

      if (kDebugMode) {
        print('[LocalsPaginationService] Loaded ${locals.length} locals');
      }

      return locals;
    } catch (e) {
      if (kDebugMode) {
        print('[LocalsPaginationService] Error loading page: $e');
      }
      rethrow;
    }
  }

  /// Resets pagination to start from the beginning
  ///
  /// Call this when filters change or when refreshing data.
  void reset() {
    _lastDocument = null;
    _hasMore = true;
    _currentStateFilter = null;
    _currentClassificationFilter = null;

    if (kDebugMode) {
      print('[LocalsPaginationService] Pagination reset');
    }
  }

  /// Refreshes the current page by resetting and loading first page
  ///
  /// Useful for pull-to-refresh functionality.
  Future<List<LocalsRecord>> refresh({
    String? stateFilter,
    String? classificationFilter,
  }) async {
    reset();
    return loadNextPage(
      stateFilter: stateFilter,
      classificationFilter: classificationFilter,
    );
  }
}
