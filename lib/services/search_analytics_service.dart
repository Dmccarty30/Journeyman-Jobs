import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for tracking search analytics and providing optimization insights
/// 
/// Provides comprehensive search behavior analytics including:
/// - Search performance tracking
/// - User behavior analytics  
/// - Search optimization insights
/// - A/B testing capability for search algorithms
class SearchAnalyticsService {
  static final SearchAnalyticsService _instance = SearchAnalyticsService._internal();
  factory SearchAnalyticsService() => _instance;
  SearchAnalyticsService._internal();

  // Analytics interface - can be Firebase Analytics or local implementation
  final _AnalyticsInterface _analytics = _LocalAnalyticsImplementation();
  
  // Local storage keys
  static const String _searchHistoryKey = 'search_history';
  static const String _searchMetricsKey = 'search_metrics';
  static const String _popularSearchesKey = 'popular_searches';
  
  // Analytics configuration
  static const int maxHistoryEntries = 1000;
  static const Duration metricsRetentionPeriod = Duration(days: 30);
  
  // In-memory cache for performance
  final List<SearchEvent> _recentSearches = [];
  final Map<String, SearchTrendData> _searchTrends = {};
  Timer? _analyticsFlushTimer;
  
  /// Track a search event with comprehensive metrics
  static void trackSearch({
    required String query,
    required int resultCount,
    required Duration responseTime,
    String? filter,
    String? location,
    bool wasCached = false,
  }) {
    final instance = SearchAnalyticsService();
    instance._trackSearchInternal(
      query: query,
      resultCount: resultCount,
      responseTime: responseTime,
      filter: filter,
      location: location,
      wasCached: wasCached,
    );
  }
  
  /// Track search result selection for relevance analysis
  static void trackSearchResult({
    required String query,
    required String selectedResult,
    required int resultPosition,
    required String resultType,
    Duration? timeToSelection,
  }) {
    final instance = SearchAnalyticsService();
    instance._trackSearchResultInternal(
      query: query,
      selectedResult: selectedResult,
      resultPosition: resultPosition,
      resultType: resultType,
      timeToSelection: timeToSelection,
    );
  }
  
  /// Track search abandonment (when user searches but doesn't select any result)
  static void trackSearchAbandonment({
    required String query,
    required int resultCount,
    required Duration sessionTime,
    String? reason,
  }) {
    final instance = SearchAnalyticsService();
    instance._trackSearchAbandonmentInternal(
      query: query,
      resultCount: resultCount,
      sessionTime: sessionTime,
      reason: reason,
    );
  }
  
  /// Internal search tracking implementation
  void _trackSearchInternal({
    required String query,
    required int resultCount,
    required Duration responseTime,
    String? filter,
    String? location,
    bool wasCached = false,
  }) {
    final event = SearchEvent(
      query: query.trim().toLowerCase(),
      resultCount: resultCount,
      responseTime: responseTime,
      filter: filter,
      location: location,
      wasCached: wasCached,
      timestamp: DateTime.now(),
    );
    
    // Add to recent searches
    _recentSearches.add(event);
    if (_recentSearches.length > maxHistoryEntries) {
      _recentSearches.removeAt(0);
    }
    
    // Update search trends
    _updateSearchTrends(event);
    
    // Firebase Analytics tracking
    _analytics.logEvent(
      name: 'search_performed',
      parameters: {
        'search_query_length': query.length,
        'result_count': resultCount,
        'response_time_ms': responseTime.inMilliseconds,
        'has_filter': filter != null,
        'search_type': _classifySearchType(query),
        'was_cached': wasCached,
        'performance_tier': _getPerformanceTier(responseTime),
        'result_quality': _getResultQuality(resultCount),
      },
    );
    
    // Schedule analytics flush
    _scheduleAnalyticsFlush();
    
    if (kDebugMode) {
      print('Search tracked: "$query" -> $resultCount results in ${responseTime.inMilliseconds}ms');
    }
  }
  
  /// Internal search result tracking
  void _trackSearchResultInternal({
    required String query,
    required String selectedResult,
    required int resultPosition,
    required String resultType,
    Duration? timeToSelection,
  }) {
    _analytics.logEvent(
      name: 'search_result_selected',
      parameters: {
        'query_length': query.length,
        'result_position': resultPosition,
        'result_type': resultType,
        'time_to_selection_ms': timeToSelection?.inMilliseconds ?? 0,
        'selection_speed': _getSelectionSpeed(timeToSelection),
        'position_quality': _getPositionQuality(resultPosition),
      },
    );
    
    // Update click-through rate data
    _updateClickThroughRates(query, resultPosition);
  }
  
  /// Internal search abandonment tracking
  void _trackSearchAbandonmentInternal({
    required String query,
    required int resultCount,
    required Duration sessionTime,
    String? reason,
  }) {
    _analytics.logEvent(
      name: 'search_abandoned',
      parameters: {
        'query_length': query.length,
        'result_count': resultCount,
        'session_time_ms': sessionTime.inMilliseconds,
        'abandonment_reason': reason ?? 'unknown',
        'had_results': resultCount > 0,
      },
    );
  }
  
  /// Update search trend data
  void _updateSearchTrends(SearchEvent event) {
    final normalizedQuery = event.query.toLowerCase().trim();
    
    if (_searchTrends.containsKey(normalizedQuery)) {
      _searchTrends[normalizedQuery]!.addEvent(event);
    } else {
      _searchTrends[normalizedQuery] = SearchTrendData(normalizedQuery)..addEvent(event);
    }
  }
  
  /// Update click-through rate analytics
  void _updateClickThroughRates(String query, int position) {
    // Implementation for CTR tracking
    // This would update position-based performance metrics
  }
  
  /// Classify search type for analytics
  String _classifySearchType(String query) {
    if (query.length < 3) return 'short';
    if (query.contains(' ')) return 'multi_word';
    if (RegExp(r'^\d+$').hasMatch(query)) return 'numeric';
    if (query.length > 20) return 'long';
    return 'standard';
  }
  
  /// Get performance tier classification
  String _getPerformanceTier(Duration responseTime) {
    final ms = responseTime.inMilliseconds;
    if (ms < 100) return 'excellent';
    if (ms < 300) return 'good';
    if (ms < 1000) return 'acceptable';
    return 'poor';
  }
  
  /// Get result quality classification
  String _getResultQuality(int resultCount) {
    if (resultCount == 0) return 'no_results';
    if (resultCount < 5) return 'few_results';
    if (resultCount < 20) return 'moderate_results';
    return 'many_results';
  }
  
  /// Get selection speed classification
  String _getSelectionSpeed(Duration? timeToSelection) {
    if (timeToSelection == null) return 'unknown';
    final seconds = timeToSelection.inSeconds;
    if (seconds < 2) return 'immediate';
    if (seconds < 10) return 'quick';
    if (seconds < 30) return 'deliberate';
    return 'slow';
  }
  
  /// Get position quality for relevance analysis
  String _getPositionQuality(int position) {
    if (position == 0) return 'top_result';
    if (position < 3) return 'top_three';
    if (position < 10) return 'first_page';
    return 'deep_result';
  }
  
  /// Schedule periodic analytics data flush
  void _scheduleAnalyticsFlush() {
    _analyticsFlushTimer?.cancel();
    _analyticsFlushTimer = Timer(const Duration(minutes: 5), () {
      _flushAnalyticsData();
    });
  }
  
  /// Flush analytics data to persistent storage
  Future<void> _flushAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Save search history
      final historyJson = _recentSearches.map((e) => e.toJson()).toList();
      await prefs.setString(_searchHistoryKey, jsonEncode(historyJson));
      
      // Save search trends
      final trendsJson = _searchTrends.map((key, value) => MapEntry(key, value.toJson()));
      await prefs.setString(_searchMetricsKey, jsonEncode(trendsJson));
      
      if (kDebugMode) {
        print('Analytics data flushed: ${_recentSearches.length} searches, ${_searchTrends.length} trends');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to flush analytics data: $e');
      }
    }
  }
  
  /// Get comprehensive search analytics report
  Future<SearchAnalyticsReport> getAnalyticsReport({
    Duration? period,
  }) async {
    final reportPeriod = period ?? const Duration(days: 7);
    final cutoffTime = DateTime.now().subtract(reportPeriod);
    
    final relevantSearches = _recentSearches
        .where((search) => search.timestamp.isAfter(cutoffTime))
        .toList();
    
    if (relevantSearches.isEmpty) {
      return SearchAnalyticsReport.empty();
    }
    
    // Calculate metrics
    final totalSearches = relevantSearches.length;
    final totalResponseTime = relevantSearches
        .map((s) => s.responseTime.inMilliseconds)
        .fold(0, (sum, time) => sum + time);
    final avgResponseTime = totalResponseTime / totalSearches;
    
    final cacheHits = relevantSearches.where((s) => s.wasCached).length;
    final cacheHitRate = (cacheHits / totalSearches) * 100;
    
    final noResultSearches = relevantSearches.where((s) => s.resultCount == 0).length;
    final noResultRate = (noResultSearches / totalSearches) * 100;
    
    final sub300msSearches = relevantSearches
        .where((s) => s.responseTime.inMilliseconds < 300)
        .length;
    final performanceTargetRate = (sub300msSearches / totalSearches) * 100;
    
    // Popular searches
    final searchFrequency = <String, int>{};
    for (final search in relevantSearches) {
      searchFrequency[search.query] = (searchFrequency[search.query] ?? 0) + 1;
    }
    
    final popularSearches = searchFrequency.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    
    return SearchAnalyticsReport(
      period: reportPeriod,
      totalSearches: totalSearches,
      avgResponseTime: avgResponseTime,
      cacheHitRate: cacheHitRate,
      noResultRate: noResultRate,
      performanceTargetRate: performanceTargetRate,
      popularSearches: popularSearches.take(10).toList(),
      searchTrends: _getSearchTrends(cutoffTime),
    );
  }
  
  /// Get search trends within period
  List<SearchTrendData> _getSearchTrends(DateTime cutoffTime) {
    return _searchTrends.values
        .where((trend) => trend.lastSearchTime.isAfter(cutoffTime))
        .toList()
      ..sort((a, b) => b.searchCount.compareTo(a.searchCount));
  }
  
  /// Get optimization suggestions based on analytics
  List<SearchOptimizationSuggestion> getOptimizationSuggestions() {
    final suggestions = <SearchOptimizationSuggestion>[];
    
    // Analyze recent performance
    final recentSearches = _recentSearches.length > 100 
        ? _recentSearches.sublist(_recentSearches.length - 100)
        : _recentSearches;
    
    if (recentSearches.isEmpty) return suggestions;
    
    // Performance suggestions
    final avgResponseTime = recentSearches
        .map((s) => s.responseTime.inMilliseconds)
        .fold(0, (sum, time) => sum + time) / recentSearches.length;
    
    if (avgResponseTime > 500) {
      suggestions.add(SearchOptimizationSuggestion(
        type: OptimizationType.performance,
        priority: Priority.high,
        title: 'Improve Search Performance',
        description: 'Average response time is ${avgResponseTime.round()}ms, target is <300ms',
        recommendation: 'Consider implementing search result caching or query optimization',
      ));
    }
    
    // Cache hit rate suggestions
    final cacheHits = recentSearches.where((s) => s.wasCached).length;
    final cacheHitRate = (cacheHits / recentSearches.length) * 100;
    
    if (cacheHitRate < 30) {
      suggestions.add(SearchOptimizationSuggestion(
        type: OptimizationType.caching,
        priority: Priority.medium,
        title: 'Improve Cache Strategy',
        description: 'Cache hit rate is ${cacheHitRate.round()}%, target is >50%',
        recommendation: 'Extend cache TTL or implement smarter cache warming',
      ));
    }
    
    // No results suggestions
    final noResultSearches = recentSearches.where((s) => s.resultCount == 0).length;
    final noResultRate = (noResultSearches / recentSearches.length) * 100;
    
    if (noResultRate > 10) {
      suggestions.add(SearchOptimizationSuggestion(
        type: OptimizationType.relevance,
        priority: Priority.high,
        title: 'Reduce No-Result Searches',
        description: '${noResultRate.round()}% of searches return no results',
        recommendation: 'Implement fuzzy search or better search suggestions',
      ));
    }
    
    return suggestions;
  }
  
  /// Clear analytics data (for testing/privacy)
  Future<void> clearAnalyticsData() async {
    _recentSearches.clear();
    _searchTrends.clear();
    _analyticsFlushTimer?.cancel();
    
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_searchHistoryKey);
    await prefs.remove(_searchMetricsKey);
    await prefs.remove(_popularSearchesKey);
  }
  
  /// Load persisted analytics data
  Future<void> loadAnalyticsData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Load search history
      final historyJson = prefs.getString(_searchHistoryKey);
      if (historyJson != null) {
        final historyList = jsonDecode(historyJson) as List;
        _recentSearches.clear();
        _recentSearches.addAll(
          historyList.map((json) => SearchEvent.fromJson(json)),
        );
      }
      
      // Load search trends
      final trendsJson = prefs.getString(_searchMetricsKey);
      if (trendsJson != null) {
        final trendsMap = jsonDecode(trendsJson) as Map<String, dynamic>;
        _searchTrends.clear();
        trendsMap.forEach((key, value) {
          _searchTrends[key] = SearchTrendData.fromJson(value);
        });
      }
      
      if (kDebugMode) {
        print('Analytics data loaded: ${_recentSearches.length} searches, ${_searchTrends.length} trends');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Failed to load analytics data: $e');
      }
    }
  }
}

/// Individual search event data
class SearchEvent {
  final String query;
  final int resultCount;
  final Duration responseTime;
  final String? filter;
  final String? location;
  final bool wasCached;
  final DateTime timestamp;
  
  SearchEvent({
    required this.query,
    required this.resultCount,
    required this.responseTime,
    this.filter,
    this.location,
    required this.wasCached,
    required this.timestamp,
  });
  
  Map<String, dynamic> toJson() => {
    'query': query,
    'resultCount': resultCount,
    'responseTimeMs': responseTime.inMilliseconds,
    'filter': filter,
    'location': location,
    'wasCached': wasCached,
    'timestamp': timestamp.toIso8601String(),
  };
  
  factory SearchEvent.fromJson(Map<String, dynamic> json) => SearchEvent(
    query: json['query'],
    resultCount: json['resultCount'],
    responseTime: Duration(milliseconds: json['responseTimeMs']),
    filter: json['filter'],
    location: json['location'],
    wasCached: json['wasCached'],
    timestamp: DateTime.parse(json['timestamp']),
  );
}

/// Search trend analysis data
class SearchTrendData {
  final String query;
  int searchCount = 0;
  double avgResponseTime = 0.0;
  double avgResultCount = 0.0;
  DateTime firstSearchTime = DateTime.now();
  DateTime lastSearchTime = DateTime.now();
  
  SearchTrendData(this.query);
  
  void addEvent(SearchEvent event) {
    searchCount++;
    avgResponseTime = ((avgResponseTime * (searchCount - 1)) + event.responseTime.inMilliseconds) / searchCount;
    avgResultCount = ((avgResultCount * (searchCount - 1)) + event.resultCount) / searchCount;
    lastSearchTime = event.timestamp;
    
    if (searchCount == 1) {
      firstSearchTime = event.timestamp;
    }
  }
  
  Map<String, dynamic> toJson() => {
    'query': query,
    'searchCount': searchCount,
    'avgResponseTime': avgResponseTime,
    'avgResultCount': avgResultCount,
    'firstSearchTime': firstSearchTime.toIso8601String(),
    'lastSearchTime': lastSearchTime.toIso8601String(),
  };
  
  factory SearchTrendData.fromJson(Map<String, dynamic> json) {
    final trend = SearchTrendData(json['query']);
    trend.searchCount = json['searchCount'];
    trend.avgResponseTime = json['avgResponseTime'];
    trend.avgResultCount = json['avgResultCount'];
    trend.firstSearchTime = DateTime.parse(json['firstSearchTime']);
    trend.lastSearchTime = DateTime.parse(json['lastSearchTime']);
    return trend;
  }
}

/// Comprehensive analytics report
class SearchAnalyticsReport {
  final Duration period;
  final int totalSearches;
  final double avgResponseTime;
  final double cacheHitRate;
  final double noResultRate;
  final double performanceTargetRate;
  final List<MapEntry<String, int>> popularSearches;
  final List<SearchTrendData> searchTrends;
  
  SearchAnalyticsReport({
    required this.period,
    required this.totalSearches,
    required this.avgResponseTime,
    required this.cacheHitRate,
    required this.noResultRate,
    required this.performanceTargetRate,
    required this.popularSearches,
    required this.searchTrends,
  });
  
  factory SearchAnalyticsReport.empty() => SearchAnalyticsReport(
    period: Duration.zero,
    totalSearches: 0,
    avgResponseTime: 0.0,
    cacheHitRate: 0.0,
    noResultRate: 0.0,
    performanceTargetRate: 0.0,
    popularSearches: [],
    searchTrends: [],
  );
}

/// Search optimization suggestion
class SearchOptimizationSuggestion {
  final OptimizationType type;
  final Priority priority;
  final String title;
  final String description;
  final String recommendation;
  
  SearchOptimizationSuggestion({
    required this.type,
    required this.priority,
    required this.title,
    required this.description,
    required this.recommendation,
  });
}

enum OptimizationType { performance, caching, relevance, userExperience }
enum Priority { low, medium, high, critical }
/// Analytics interface for abstraction
abstract class _AnalyticsInterface {
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  });
}

/// Local analytics implementation for fallback
class _LocalAnalyticsImplementation implements _AnalyticsInterface {
  @override
  Future<void> logEvent({
    required String name,
    Map<String, Object?>? parameters,
  }) async {
    if (kDebugMode) {
      print('Analytics Event: $name ${parameters ?? {}}');
    }
    // In a real implementation, this could send to a custom analytics service
  }
}
