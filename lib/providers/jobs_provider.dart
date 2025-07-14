import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/filter_criteria.dart';
import '../services/resilient_firestore_service.dart';
import '../utils/memory_management.dart';
import '../utils/filter_performance.dart';
import '../utils/concurrent_operations.dart';

/// Provider responsible for jobs data management
/// 
/// Features:
/// - Job data loading and pagination
/// - Advanced filtering with performance optimization
/// - Memory-efficient job list management
/// - Virtual scrolling support
/// - Filter performance tracking
/// - Concurrent operation management
class JobsProvider extends ChangeNotifier {
  final ResilientFirestoreService _firestoreService;
  final ConcurrentOperationManager _operationManager = ConcurrentOperationManager();
  final FilterPerformanceEngine _filterEngine = FilterPerformanceEngine();

  // Job data state
  final BoundedJobList _boundedJobList = BoundedJobList();
  final VirtualJobListState _virtualJobList = VirtualJobListState();
  JobFilterCriteria _activeFilter = JobFilterCriteria.empty();
  
  // Loading and error state
  bool _isLoadingJobs = false;
  String? _jobsError;
  
  // Pagination state
  DocumentSnapshot? _lastJobDocument;
  bool _hasMoreJobs = true;
  
  // Performance metrics
  final List<Duration> _loadTimes = [];
  final List<Duration> _filterTimes = [];
  int _totalJobsLoaded = 0;
  DateTime? _lastLoadTime;
  
  // Getters
  List<Job> get jobs => _boundedJobList.jobs;
  List<Job> get visibleJobs => _virtualJobList.visibleJobs;
  JobFilterCriteria get activeFilter => _activeFilter;
  bool get isLoadingJobs => _isLoadingJobs;
  String? get jobsError => _jobsError;
  bool get hasMoreJobs => _hasMoreJobs;
  int get totalJobsLoaded => _totalJobsLoaded;
  
  // Performance getters
  Duration? get averageLoadTime => _loadTimes.isNotEmpty 
      ? Duration(milliseconds: _loadTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ _loadTimes.length)
      : null;
  Duration? get averageFilterTime => _filterTimes.isNotEmpty
      ? Duration(milliseconds: _filterTimes.map((d) => d.inMilliseconds).reduce((a, b) => a + b) ~/ _filterTimes.length)
      : null;

  JobsProvider(this._firestoreService);

  /// Load jobs with optional refresh
  Future<void> loadJobs({bool isRefresh = false, String? userId}) async {
    if (isRefresh) {
      _resetPagination();
    }
    
    return _operationManager.queueOperation(
      type: OperationType.loadJobs,
      parameters: {'isRefresh': isRefresh, 'userId': userId},
      operation: () => _loadJobsInternal(isRefresh: isRefresh),
    );
  }

  /// Internal job loading implementation
  Future<void> _loadJobsInternal({bool isRefresh = false}) async {
    final startTime = DateTime.now();
    
    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestoreService.getJobsWithFilter(
        filter: _activeFilter,
        startAfter: _lastJobDocument,
        limit: 20,
      );
      
      final newJobs = snapshot.docs
          .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      
      if (isRefresh) {
        _boundedJobList.replaceJobs(newJobs);
      } else {
        _boundedJobList.addJobs(newJobs);
      }
      
      _lastJobDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreJobs = snapshot.docs.length == 20;
      _totalJobsLoaded += newJobs.length;
      _lastLoadTime = DateTime.now();
      
      // Track performance
      final loadDuration = DateTime.now().difference(startTime);
      _loadTimes.add(loadDuration);
      if (_loadTimes.length > 10) _loadTimes.removeAt(0); // Keep last 10
      
      if (kDebugMode) {
        print('JobsProvider: Loaded ${newJobs.length} jobs in ${loadDuration.inMilliseconds}ms (total: ${_boundedJobList.length})');
      }
    } catch (e) {
      _jobsError = e.toString();
      
      if (kDebugMode) {
        print('JobsProvider: Error loading jobs - $e');
      }
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (!_hasMoreJobs || _isLoadingJobs) return;
    await loadJobs(isRefresh: false);
  }

  /// Update job filter with performance optimization
  Future<void> updateJobFilter(JobFilterCriteria newFilter) async {
    final startTime = DateTime.now();
    
    _activeFilter = newFilter;
    
    if (kDebugMode) {
      print('JobsProvider: Filter updated with ${newFilter.activeFilterCount} active filters');
    }
    
    try {
      // Use filter engine for optimized filtering
      final filterResult = await _filterEngine.applyFilters(_boundedJobList.jobs, newFilter);
      
      // Update the bounded job list with filtered results
      _boundedJobList.replaceJobs(filterResult.jobs);
      
      // Reset pagination since we're showing filtered results
      _resetPagination();
      _hasMoreJobs = filterResult.jobs.length >= 20;
      
      // Track filter performance
      final filterDuration = DateTime.now().difference(startTime);
      _filterTimes.add(filterDuration);
      if (_filterTimes.length > 10) _filterTimes.removeAt(0); // Keep last 10
      
      if (kDebugMode) {
        print('JobsProvider: Filter applied in ${filterDuration.inMilliseconds}ms, ${filterResult.jobs.length} results');
      }
      
      notifyListeners();
    } catch (e) {
      _jobsError = 'Filter error: $e';
      
      if (kDebugMode) {
        print('JobsProvider: Filter error - $e');
      }
      
      notifyListeners();
    }
  }

  /// Apply quick filter for search queries
  Future<void> applyQuickFilter(String searchQuery) async {
    final quickFilter = _activeFilter.copyWith(searchQuery: searchQuery);
    await updateJobFilter(quickFilter);
  }

  /// Clear current filter
  Future<void> clearFilter() async {
    await updateJobFilter(JobFilterCriteria.empty());
  }

  /// Get smart filter suggestions
  List<JobFilterCriteria> getSmartFilterSuggestions() {
    final suggestions = _filterEngine.getSmartSuggestions();
    return suggestions.map((suggestion) => suggestion.criteria).whereType<JobFilterCriteria>().toList();
  }

  /// Update virtual job list for efficient scrolling
  void updateVirtualJobList(int startIndex) {
    _virtualJobList.updateJobs(_boundedJobList.jobs, startIndex);
    notifyListeners();
  }

  /// Refresh jobs data
  Future<void> refreshJobs() async {
    await loadJobs(isRefresh: true);
  }

  /// Search jobs by query
  Future<void> searchJobs(String query) async {
    if (query.trim().isEmpty) {
      await clearFilter();
      return;
    }
    
    final searchFilter = JobFilterCriteria(searchQuery: query);
    await updateJobFilter(searchFilter);
  }

  /// Get job by ID
  Job? getJobById(String jobId) {
    try {
      return _boundedJobList.jobs.firstWhere((job) => job.id == jobId);
    } catch (e) {
      return null;
    }
  }

  /// Get jobs by classification
  List<Job> getJobsByClassification(String classification) {
    return _boundedJobList.jobs.where((job) => job.classification == classification).toList();
  }

  /// Get jobs by local number
  List<Job> getJobsByLocal(int localNumber) {
    return _boundedJobList.jobs.where((job) => job.localNumber == localNumber).toList();
  }

  /// Clear jobs error
  void clearJobsError() {
    if (_jobsError != null) {
      _jobsError = null;
      notifyListeners();
    }
  }

  /// Reset pagination state
  void _resetPagination() {
    _lastJobDocument = null;
    _hasMoreJobs = true;
    _boundedJobList.clear();
  }

  /// Get performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'totalJobsLoaded': _totalJobsLoaded,
      'currentJobsCount': _boundedJobList.length,
      'averageLoadTime': averageLoadTime?.inMilliseconds,
      'averageFilterTime': averageFilterTime?.inMilliseconds,
      'lastLoadTime': _lastLoadTime?.toIso8601String(),
      'hasMoreJobs': _hasMoreJobs,
      'isCurrentlyLoading': _isLoadingJobs,
      'memoryStats': {
        'boundedListSize': _boundedJobList.length,
        'virtualListSize': _virtualJobList.visibleJobs.length,
        'memoryLimit': BoundedJobList.maxSize,
      },
      'filterStats': {
        'cacheHitRate': 'Not implemented',
        'avgFilterTime': averageFilterTime?.inMilliseconds,
      },
      'operationStats': _operationManager.getOperationStats(),
    };
  }

  /// Get current state snapshot
  Map<String, dynamic> getStateSnapshot() {
    return {
      'jobsCount': _boundedJobList.length,
      'visibleJobsCount': _virtualJobList.visibleJobs.length,
      'isLoading': _isLoadingJobs,
      'hasError': _jobsError != null,
      'errorMessage': _jobsError,
      'hasMoreJobs': _hasMoreJobs,
      'activeFilterCount': _activeFilter.activeFilterCount,
      'lastUpdate': DateTime.now().toIso8601String(),
    };
  }

  /// Perform memory cleanup
  void performMemoryCleanup() {
    if (MemoryMonitor.shouldPerformCleanup(
      jobList: _boundedJobList,
      localsCache: null,
      virtualList: _virtualJobList,
    )) {
      MemoryMonitor.performCleanup(
        jobList: _boundedJobList,
        localsCache: null,
        virtualList: _virtualJobList,
      );
      
      if (kDebugMode) {
        print('JobsProvider: Memory cleanup performed');
      }
      
      notifyListeners();
    }
  }

  @override
  void dispose() {
    // Dispose operation manager
    _operationManager.dispose();
    
    // Clear memory-managed structures
    _boundedJobList.clear();
    _virtualJobList.clear();
    
    if (kDebugMode) {
      print('JobsProvider: Disposed with performance metrics: ${getPerformanceMetrics()}');
    }
    
    super.dispose();
  }
}