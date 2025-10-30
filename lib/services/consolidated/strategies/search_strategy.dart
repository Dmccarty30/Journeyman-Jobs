import 'package:cloud_firestore/cloud_firestore.dart';

/// Strategy interface for search optimization in Firestore
///
/// Implementations provide different search capabilities:
/// - Basic prefix search
/// - Multi-term search with relevance ranking
/// - Full-text search integration
/// - Geographic search optimization
abstract class SearchStrategy {
  /// Perform a search operation on a Firestore collection
  ///
  /// [collection] - The collection to search
  /// [query] - The search query string
  /// [filters] - Optional filters to apply (state, classification, etc.)
  /// [limit] - Maximum number of results to return
  ///
  /// Returns a QuerySnapshot with search results
  Future<QuerySnapshot> search(
    CollectionReference collection,
    String query, {
    Map<String, dynamic>? filters,
    int limit = 20,
  });

  /// Get search performance statistics
  ///
  /// Returns metrics like average response time, cache hit rate, etc.
  Map<String, dynamic> getStatistics();

  /// Clear any cached search data
  Future<void> clearCache();
}

/// Search result with relevance score
class ScoredSearchResult {
  final DocumentSnapshot document;
  final double relevanceScore;
  final Map<String, dynamic> matchDetails;

  ScoredSearchResult({
    required this.document,
    required this.relevanceScore,
    required this.matchDetails,
  });

  /// Get the document data
  Map<String, dynamic>? get data => document.data() as Map<String, dynamic>?;

  /// Get the document ID
  String get id => document.id;
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
