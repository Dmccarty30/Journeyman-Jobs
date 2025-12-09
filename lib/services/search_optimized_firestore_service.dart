import 'dart:async';
import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/locals_record.dart';
import 'resilient_firestore_service.dart';
import 'cache_service.dart';

/// Advanced search service optimized for full-text search with relevance ranking
/// 
/// Provides enhanced search capabilities including:
/// - Multi-term search functionality
/// - Geographic filtering integration  
/// - Result ranking by relevance
/// - Search response optimization (<300ms target)
/// - Fallback mechanisms for reliability
class SearchOptimizedFirestoreService extends ResilientFirestoreService {
  final CacheService _cacheService = CacheService();
  
  // Search configuration
  static const int maxSearchResults = 50;
  static const int minSearchLength = 2;
  static const Duration searchCacheTimeout = Duration(minutes: 10);
  
  // Search analytics tracking
  final Map<String, SearchMetrics> _searchMetrics = {};
  
  /// Enhanced locals search with full-text capabilities
  @override
  Future<QuerySnapshot> searchLocals(
    String query, {
    String? state,
    int limit = 20,
  }) async {
    // Delegate to parent for QuerySnapshot return type
    return await super.searchLocals(query, state: state, limit: limit);
  }

  /// Advanced search returning LocalsRecord list with enhanced capabilities
  Future<List<LocalsRecord>> searchLocalsEnhanced(
    String query, {
    String? state,
    int limit = 20,
  }) async {
    final stopwatch = Stopwatch()..start();
    
    try {
      // Validate input
      if (query.trim().length < minSearchLength) {
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
  Future<List<LocalsRecord>> _performAdvancedSearch(
    String query,
    String? state,
    int limit,
  ) async {
    final searchTerms = _extractSearchTerms(query);
    final results = <LocalsRecord, double>{};
    
    // Search across multiple fields with different weights
    final searchFields = {
      'localUnion': 1.0,      // Highest weight for exact union name match
      'city': 0.8,            // High weight for city matches
      'state': 0.6,           // Medium weight for state matches
      'searchTerms': 0.4,     // Lower weight for general search terms
    };
    
    for (final field in searchFields.keys) {
      final fieldWeight = searchFields[field]!;
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
    Query firestoreQuery = FirebaseFirestore.instance.collection('locals');
    
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
    Query query = FirebaseFirestore.instance.collection('locals');
    
    // Apply geographic filtering
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }
    
    // Search strategy based on field type
    if (field == 'searchTerms') {
      // Array contains search for searchTerms field
      final results = <LocalsRecord>[];
      for (final term in searchTerms.take(3)) { // Limit to 3 terms for performance
        final termQuery = query
            .where('searchTerms', arrayContains: term)
            .limit(maxSearchResults ~/ searchTerms.length);
        
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
          .limit(maxSearchResults);
      
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
        .where((term) => term.length >= minSearchLength)
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
        // Build search terms from available fields
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
    // Use advanced search for multi-word queries or complex patterns
    return query.contains(' ') || query.length >= 5;
  }
  
  /// Fallback search for error scenarios
  Future<List<LocalsRecord>> _performFallbackSearch(
    String query,
    String? state,
    int limit,
  ) async {
    try {
      // Simple, reliable prefix search
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
        ttl: searchCacheTimeout,
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
  
  /// Get search performance statistics
  Map<String, dynamic> getSearchStatistics() {
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
      'cacheHitRate': totalSearches > 0 ? (cacheHits / totalSearches * 100) : 0,
      'errorRate': totalSearches > 0 ? (errors / totalSearches * 100) : 0,
      'avgResponseTimeMs': avgResponseTime.round(),
      'maxResponseTimeMs': maxResponseTime,
      'sub300msCount': responseTimes.where((time) => time < 300).length,
      'performanceTarget': responseTimes.where((time) => time < 300).length / 
          responseTimes.length * 100,
    };
  }
  
  /// Clear search metrics (for testing/reset)
  void clearSearchMetrics() {
    _searchMetrics.clear();
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
}

/// Search metrics for analytics and optimization
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