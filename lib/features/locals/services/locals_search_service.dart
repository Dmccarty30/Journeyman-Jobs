import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../../../models/locals_record.dart';

/// Enhanced search service for IBEW Locals directory
///
/// Provides optimized search functionality with:
/// - Debounced search (300ms) to reduce Firestore queries
/// - Composite index support for efficient queries
/// - Local number and name search
/// - Result deduplication
/// - Automatic query cancellation
class LocalsSearchService {
  /// Firestore instance
  final FirebaseFirestore _firestore;

  /// Debounce timer for search queries
  Timer? _debounceTimer;

  /// Debounce duration (milliseconds)
  final int debounceDuration;

  /// Maximum search results to return
  final int maxResults;

  /// Creates a search service with configurable debounce duration
  ///
  /// [debounceDuration] - Milliseconds to wait before executing search (default: 300)
  /// [maxResults] - Maximum number of results to return (default: 20)
  /// [firestore] - Optional Firestore instance (defaults to FirebaseFirestore.instance)
  LocalsSearchService({
    this.debounceDuration = 300,
    this.maxResults = 20,
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;

  /// Performs a debounced search for locals
  ///
  /// Cancels any pending search and waits for [debounceDuration] before executing.
  /// This reduces the number of Firestore queries during typing.
  ///
  /// [query] - Search term (local number, name, city, etc.)
  /// [onResults] - Callback function to receive search results
  /// [stateFilter] - Optional state filter to narrow search
  ///
  /// Example:
  /// ```dart
  /// searchService.searchLocals('134', (results) {
  ///   setState(() => searchResults = results);
  /// });
  /// ```
  void searchLocals(
    String query,
    Function(List<LocalsRecord>) onResults, {
    String? stateFilter,
  }) {
    // Cancel previous search timer
    _debounceTimer?.cancel();

    // Return empty results immediately for empty query
    if (query.isEmpty) {
      onResults([]);
      return;
    }

    // Create new debounced search
    _debounceTimer = Timer(Duration(milliseconds: debounceDuration), () async {
      try {
        final results = await _executeSearch(query, stateFilter: stateFilter);
        onResults(results);
      } catch (e) {
        if (kDebugMode) {
          print('[LocalsSearchService] Search error: $e');
        }
        onResults([]);
      }
    });
  }

  /// Executes the actual search query without debouncing
  ///
  /// Use this for immediate searches (e.g., on search button press).
  ///
  /// Returns a list of matching [LocalsRecord] objects.
  Future<List<LocalsRecord>> searchImmediate(
    String query, {
    String? stateFilter,
  }) async {
    if (query.isEmpty) {
      return [];
    }

    return _executeSearch(query, stateFilter: stateFilter);
  }

  /// Internal method to execute search queries
  ///
  /// Searches by:
  /// 1. Local union number (exact match and prefix)
  /// 2. Local name (prefix match)
  /// 3. City (prefix match)
  ///
  /// Uses Firestore range queries with string prefix matching.
  /// Results are combined and deduplicated by document ID.
  Future<List<LocalsRecord>> _executeSearch(
    String query, {
    String? stateFilter,
  }) async {
    final queryLower = query.toLowerCase().trim();

    if (kDebugMode) {
      print('[LocalsSearchService] Executing search:');
      print('  - Query: $queryLower');
      print('  - State filter: ${stateFilter ?? "none"}');
      print('  - Max results: $maxResults');
    }

    try {
      // Execute searches in parallel for better performance
      final results = await Future.wait([
        _searchByLocalNumber(queryLower, stateFilter: stateFilter),
        _searchByName(queryLower, stateFilter: stateFilter),
        _searchByCity(queryLower, stateFilter: stateFilter),
      ]);

      // Combine and deduplicate results using Set
      final localsMap = <String, LocalsRecord>{};

      for (final resultList in results) {
        for (final local in resultList) {
          localsMap[local.id] = local;
        }
      }

      // Convert to list and sort by relevance
      final combinedResults = localsMap.values.toList();

      // Sort results by relevance (exact matches first, then prefix matches)
      combinedResults.sort((a, b) {
        // Exact local number match gets highest priority
        final aNumberMatch = a.localNumber.toLowerCase() == queryLower;
        final bNumberMatch = b.localNumber.toLowerCase() == queryLower;

        if (aNumberMatch && !bNumberMatch) return -1;
        if (!aNumberMatch && bNumberMatch) return 1;

        // Then prefix matches
        final aNumberPrefix = a.localNumber.toLowerCase().startsWith(queryLower);
        final bNumberPrefix = b.localNumber.toLowerCase().startsWith(queryLower);

        if (aNumberPrefix && !bNumberPrefix) return -1;
        if (!aNumberPrefix && bNumberPrefix) return 1;

        // Finally sort by local number
        return a.localNumber.compareTo(b.localNumber);
      });

      if (kDebugMode) {
        print('[LocalsSearchService] Found ${combinedResults.length} results');
      }

      return combinedResults.take(maxResults).toList();
    } catch (e) {
      if (kDebugMode) {
        print('[LocalsSearchService] Error executing search: $e');
      }
      rethrow;
    }
  }

  /// Searches by local union number
  ///
  /// Uses range query for prefix matching on local_union field.
  /// Requires composite index: (state + local_union) if state filter used.
  Future<List<LocalsRecord>> _searchByLocalNumber(
    String query, {
    String? stateFilter,
  }) async {
    Query firestoreQuery = _firestore.collection('locals');

    // Apply state filter if provided
    if (stateFilter != null && stateFilter.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('state', isEqualTo: stateFilter);
    }

    // Range query for prefix matching
    // \uf8ff is a very high Unicode character, making this a prefix search
    firestoreQuery = firestoreQuery
        .where('local_union', isGreaterThanOrEqualTo: query)
        .where('local_union', isLessThan: '$query\uf8ff')
        .limit(maxResults);

    final snapshot = await firestoreQuery.get();
    return snapshot.docs.map((doc) => LocalsRecord.fromFirestore(doc)).toList();
  }

  /// Searches by local name
  ///
  /// Uses range query on lowercased name field for case-insensitive search.
  /// Requires the Firestore documents to have a 'local_name_lowercase' field.
  Future<List<LocalsRecord>> _searchByName(
    String query, {
    String? stateFilter,
  }) async {
    Query firestoreQuery = _firestore.collection('locals');

    // Apply state filter if provided
    if (stateFilter != null && stateFilter.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('state', isEqualTo: stateFilter);
    }

    // Range query for prefix matching on lowercase name
    // This requires a 'local_name_lowercase' field in Firestore
    firestoreQuery = firestoreQuery
        .where('local_name_lowercase', isGreaterThanOrEqualTo: query)
        .where('local_name_lowercase', isLessThan: '$query\uf8ff')
        .limit(maxResults);

    final snapshot = await firestoreQuery.get();
    return snapshot.docs.map((doc) => LocalsRecord.fromFirestore(doc)).toList();
  }

  /// Searches by city name
  ///
  /// Uses range query on lowercased city field for case-insensitive search.
  /// Requires the Firestore documents to have a 'city_lowercase' field.
  Future<List<LocalsRecord>> _searchByCity(
    String query, {
    String? stateFilter,
  }) async {
    Query firestoreQuery = _firestore.collection('locals');

    // Apply state filter if provided
    if (stateFilter != null && stateFilter.isNotEmpty) {
      firestoreQuery = firestoreQuery.where('state', isEqualTo: stateFilter);
    }

    // Range query for prefix matching on lowercase city
    firestoreQuery = firestoreQuery
        .where('city_lowercase', isGreaterThanOrEqualTo: query)
        .where('city_lowercase', isLessThan: '$query\uf8ff')
        .limit(maxResults);

    final snapshot = await firestoreQuery.get();
    return snapshot.docs.map((doc) => LocalsRecord.fromFirestore(doc)).toList();
  }

  /// Cancels any pending debounced search
  void cancelPendingSearch() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }

  /// Disposes of the service and cancels timers
  void dispose() {
    _debounceTimer?.cancel();
    _debounceTimer = null;
  }
}
