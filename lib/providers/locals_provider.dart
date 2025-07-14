import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/locals_record.dart';
import '../services/resilient_firestore_service.dart';
import '../utils/memory_management.dart';
import '../utils/concurrent_operations.dart';

/// Provider responsible for IBEW locals data management
/// 
/// Features:
/// - IBEW locals data loading and caching
/// - Geographic filtering by state
/// - Search functionality with fuzzy matching
/// - LRU cache management for 797+ locals
/// - Performance optimization for large datasets
/// - Memory-efficient pagination
class LocalsProvider extends ChangeNotifier {
  final ResilientFirestoreService _firestoreService;
  final ConcurrentOperationManager _operationManager = ConcurrentOperationManager();

  // Locals data state
  final LocalsLRUCache _localsCache = LocalsLRUCache();
  List<LocalsRecord> _filteredLocals = [];
  String _currentSearchQuery = '';
  String? _currentStateFilter;
  
  // Loading and error state
  bool _isLoadingLocals = false;
  String? _localsError;
  
  // Pagination state
  DocumentSnapshot? _lastLocalDocument;
  bool _hasMoreLocals = true;
  
  // Performance metrics
  final List<Duration> _loadTimes = [];
  final List<Duration> _searchTimes = [];
  int _totalLocalsLoaded = 0;
  int _cacheHits = 0;
  int _cacheMisses = 0;
  DateTime? _lastLoadTime;
  
  // Getters
  List<LocalsRecord> get locals => _filteredLocals.isNotEmpty ? _filteredLocals : _localsCache.allLocals;
  List<LocalsRecord> get allLocals => _localsCache.allLocals;
  bool get isLoadingLocals => _isLoadingLocals;
  String? get localsError => _localsError;
  bool get hasMoreLocals => _hasMoreLocals;
  int get totalLocalsLoaded => _totalLocalsLoaded;
  int get cacheSize => _localsCache.size;
  String get currentSearchQuery => _currentSearchQuery;
  String? get currentStateFilter => _currentStateFilter;
  
  // Performance getters
  Duration? get averageLoadTime => _loadTimes.isNotEmpty 
      ? Duration(milliseconds: _loadTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ _loadTimes.length)
      : null;
  Duration? get averageSearchTime => _searchTimes.isNotEmpty
      ? Duration(milliseconds: _searchTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ _searchTimes.length)
      : null;
  double get cacheHitRate => (_cacheHits + _cacheMisses) > 0 ? _cacheHits / (_cacheHits + _cacheMisses) : 0.0;

  LocalsProvider(this._firestoreService);

  /// Load locals with optional refresh and state filtering
  Future<void> loadLocals({bool isRefresh = false, String? state}) async {
    if (isRefresh) {
      _resetPagination();
      _currentStateFilter = state;
    }
    
    return _operationManager.queueOperation(
      type: OperationType.loadLocals,
      parameters: {'isRefresh': isRefresh, 'state': state},
      operation: () => _loadLocalsInternal(isRefresh: isRefresh, state: state),
    );
  }

  /// Internal locals loading implementation
  Future<void> _loadLocalsInternal({bool isRefresh = false, String? state}) async {
    final startTime = DateTime.now();
    
    _isLoadingLocals = true;
    _localsError = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestoreService.getLocals(
        state: state,
        startAfter: _lastLocalDocument,
        limit: 50,
      ).first;
      
      final newLocals = snapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();
      
      // Add locals to LRU cache
      for (final local in newLocals) {
        _localsCache.put(local.localNumber.toString(), local);
      }
      
      _lastLocalDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreLocals = snapshot.docs.length == 50;
      _totalLocalsLoaded += newLocals.length;
      _lastLoadTime = DateTime.now();
      
      // Update filtered locals if we have active filters
      _applyCurrentFilters();
      
      // Track performance
      final loadDuration = DateTime.now().difference(startTime);
      _loadTimes.add(loadDuration);
      if (_loadTimes.length > 10) _loadTimes.removeAt(0); // Keep last 10
      
      if (kDebugMode) {
        print('LocalsProvider: Loaded ${newLocals.length} locals in ${loadDuration.inMilliseconds}ms (cached: ${_localsCache.size})');
      }
    } catch (e) {
      _localsError = e.toString();
      
      if (kDebugMode) {
        print('LocalsProvider: Error loading locals - $e');
      }
    } finally {
      _isLoadingLocals = false;
      notifyListeners();
    }
  }

  /// Load more locals (pagination)
  Future<void> loadMoreLocals() async {
    if (!_hasMoreLocals || _isLoadingLocals) return;
    await loadLocals(isRefresh: false, state: _currentStateFilter);
  }

  /// Search locals by name or number with fuzzy matching
  Future<void> searchLocals(String query) async {
    final startTime = DateTime.now();
    _currentSearchQuery = query.trim();
    
    if (_currentSearchQuery.isEmpty) {
      _filteredLocals = [];
      notifyListeners();
      return;
    }
    
    try {
      _filteredLocals = _searchLocalsInternal(_currentSearchQuery);
      
      // Track search performance
      final searchDuration = DateTime.now().difference(startTime);
      _searchTimes.add(searchDuration);
      if (_searchTimes.length > 10) _searchTimes.removeAt(0); // Keep last 10
      
      if (kDebugMode) {
        print('LocalsProvider: Search for "$_currentSearchQuery" completed in ${searchDuration.inMilliseconds}ms, ${_filteredLocals.length} results');
      }
      
      notifyListeners();
    } catch (e) {
      _localsError = 'Search error: $e';
      
      if (kDebugMode) {
        print('LocalsProvider: Search error - $e');
      }
      
      notifyListeners();
    }
  }

  /// Internal search implementation with fuzzy matching
  List<LocalsRecord> _searchLocalsInternal(String query) {
    final queryLower = query.toLowerCase();
    final queryNumber = int.tryParse(query);
    
    return _localsCache.allLocals.where((local) {
      // Exact number match (highest priority)
      if (queryNumber != null && local.localNumber == queryNumber) {
        return true;
      }
      
      // Local number contains query
      if (local.localNumber.toString().contains(query)) {
        return true;
      }
      
      // Local name contains query (case-insensitive)
      if (local.localName.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // City contains query (case-insensitive)
      if (local.city.toLowerCase().contains(queryLower)) {
        return true;
      }
      
      // State matches (exact, case-insensitive)
      if (local.state.toLowerCase() == queryLower) {
        return true;
      }
      
      return false;
    }).toList();
  }

  /// Filter locals by state
  Future<void> filterByState(String? state) async {
    _currentStateFilter = state;
    _applyCurrentFilters();
    notifyListeners();
    
    if (kDebugMode) {
      print('LocalsProvider: Filtered by state "$state", ${_filteredLocals.length} results');
    }
  }

  /// Clear current search and filters
  void clearFilters() {
    _currentSearchQuery = '';
    _currentStateFilter = null;
    _filteredLocals = [];
    notifyListeners();
    
    if (kDebugMode) {
      print('LocalsProvider: Filters cleared');
    }
  }

  /// Apply current search and state filters
  void _applyCurrentFilters() {
    List<LocalsRecord> results = _localsCache.allLocals;
    
    // Apply state filter first
    if (_currentStateFilter != null && _currentStateFilter!.isNotEmpty) {
      results = results.where((local) => local.state == _currentStateFilter).toList();
    }
    
    // Apply search filter
    if (_currentSearchQuery.isNotEmpty) {
      results = _searchLocalsInternal(_currentSearchQuery);
      // If we have a state filter, apply it to search results
      if (_currentStateFilter != null && _currentStateFilter!.isNotEmpty) {
        results = results.where((local) => local.state == _currentStateFilter).toList();
      }
    }
    
    _filteredLocals = results;
  }

  /// Get local by number with caching
  LocalsRecord? getLocalByNumber(int localNumber) {
    final key = localNumber.toString();
    
    // Check cache first
    final cached = _localsCache.get(key);
    if (cached != null) {
      _cacheHits++;
      return cached;
    }
    
    _cacheMisses++;
    
    // If not in cache, try to find in filtered results
    try {
      return _filteredLocals.isNotEmpty 
          ? _filteredLocals.firstWhere((local) => local.localNumber == localNumber)
          : _localsCache.allLocals.firstWhere((local) => local.localNumber == localNumber);
    } catch (e) {
      return null;
    }
  }

  /// Get locals by state
  List<LocalsRecord> getLocalsByState(String state) {
    return _localsCache.allLocals.where((local) => local.state == state).toList();
  }

  /// Get all unique states
  List<String> getAllStates() {
    final states = _localsCache.allLocals.map((local) => local.state).toSet().toList();
    states.sort();
    return states;
  }

  /// Get locals count by state
  Map<String, int> getLocalsCountByState() {
    final Map<String, int> counts = {};
    for (final local in _localsCache.allLocals) {
      counts[local.state] = (counts[local.state] ?? 0) + 1;
    }
    return counts;
  }

  /// Refresh locals data
  Future<void> refreshLocals() async {
    await loadLocals(isRefresh: true, state: _currentStateFilter);
  }

  /// Clear locals error
  void clearLocalsError() {
    if (_localsError != null) {
      _localsError = null;
      notifyListeners();
    }
  }

  /// Reset pagination state
  void _resetPagination() {
    _lastLocalDocument = null;
    _hasMoreLocals = true;
    _localsCache.clear();
    _filteredLocals = [];
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalLocalsLoaded': _totalLocalsLoaded,
      'currentLocalsCount': _localsCache.size,
      'filteredLocalsCount': _filteredLocals.length,
      'averageLoadTime': averageLoadTime?.inMilliseconds,
      'averageSearchTime': averageSearchTime?.inMilliseconds,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'hasMoreLocals': _hasMoreLocals,
      'isCurrentlyLoading': _isLoadingLocals,
      'cacheStats': {
        'size': _localsCache.size,
        'maxSize': LocalsLRUCache.maxSize,
        'hitRate': cacheHitRate,
        'hits': _cacheHits,
        'misses': _cacheMisses,
      },
      'operationStats': _operationManager.getOperationStats(),
    };
  }

  /// Get current state snapshot
  Map<String, dynamic> getStateSnapshot() {
    return {
      'localsCount': _localsCache.size,
      'filteredCount': _filteredLocals.length,
      'isLoading': _isLoadingLocals,
      'hasError': _localsError != null,
      'errorMessage': _localsError,
      'hasMoreLocals': _hasMoreLocals,
      'currentSearchQuery': _currentSearchQuery,
      'currentStateFilter': _currentStateFilter,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  /// Perform memory cleanup
  void performMemoryCleanup() {
    if (MemoryMonitor.shouldPerformCleanup(
      jobList: null,
      localsCache: _localsCache,
      virtualList: null,
    )) {
      MemoryMonitor.performCleanup(
        jobList: null,
        localsCache: _localsCache,
        virtualList: null,
      );
      
      // Reapply filters after cleanup
      _applyCurrentFilters();
      
      if (kDebugMode) {
        print('LocalsProvider: Memory cleanup performed');
      }
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Dispose operation manager
    _operationManager.dispose();
    
    // Clear cache
    _localsCache.clear();
    
    if (kDebugMode) {
      print('LocalsProvider: Disposed with performance metrics: ${getPerformanceMetrics()}');
    }
    
    super.dispose();
  }
}