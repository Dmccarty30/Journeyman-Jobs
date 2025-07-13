import 'dart:collection';
import '../models/job_model.dart';
import '../models/locals_record.dart';

/// Bounded list implementation to prevent memory exhaustion
class BoundedJobList {
  static const int maxSize = 200;
  final List<Job> _jobs = [];
  
  /// Add new jobs while maintaining size limit
  void addJobs(List<Job> newJobs) {
    _jobs.addAll(newJobs);
    if (_jobs.length > maxSize) {
      _jobs.removeRange(0, _jobs.length - maxSize);
    }
  }
  
  /// Add a single job
  void addJob(Job job) {
    _jobs.add(job);
    if (_jobs.length > maxSize) {
      _jobs.removeAt(0);
    }
  }
  
  /// Replace all jobs with new list
  void replaceJobs(List<Job> newJobs) {
    _jobs.clear();
    addJobs(newJobs);
  }
  
  /// Get all jobs
  List<Job> get jobs => List.unmodifiable(_jobs);
  
  /// Get jobs count
  int get length => _jobs.length;
  
  /// Check if empty
  bool get isEmpty => _jobs.isEmpty;
  
  /// Clear all jobs
  void clear() => _jobs.clear();
  
  /// Get memory usage estimate in bytes
  int get estimatedMemoryUsage {
    // Rough estimate: each job ~2KB
    return _jobs.length * 2048;
  }
}

/// LRU (Least Recently Used) cache for IBEW locals management
class LocalsLRUCache {
  static const int maxSize = 100; // Manage 797+ locals efficiently
  final int maxCacheSize;
  
  final LinkedHashMap<String, LocalsRecord> _cache = LinkedHashMap();
  final Map<String, DateTime> _accessTimes = {};
  
  LocalsLRUCache({this.maxCacheSize = maxSize});
  
  /// Add or update a local in the cache
  void put(String localNumber, LocalsRecord local) {
    if (_cache.containsKey(localNumber)) {
      // Update existing entry
      _cache.remove(localNumber);
    } else if (_cache.length >= maxCacheSize) {
      // Remove least recently used
      _removeLRU();
    }
    
    _cache[localNumber] = local;
    _accessTimes[localNumber] = DateTime.now();
  }
  
  /// Get a local from cache
  LocalsRecord? get(String localNumber) {
    final local = _cache[localNumber];
    if (local != null) {
      // Move to end (most recently used)
      _cache.remove(localNumber);
      _cache[localNumber] = local;
      _accessTimes[localNumber] = DateTime.now();
    }
    return local;
  }
  
  /// Check if local exists in cache
  bool containsKey(String localNumber) {
    return _cache.containsKey(localNumber);
  }
  
  /// Get all cached locals
  List<LocalsRecord> get allLocals => _cache.values.toList();
  
  /// Get cached locals by state
  List<LocalsRecord> getLocalsByState(String state) {
    return _cache.values
        .where((local) => local.state == state)
        .toList();
  }
  
  /// Search cached locals by name
  List<LocalsRecord> searchByName(String query) {
    final queryLower = query.toLowerCase();
    return _cache.values
        .where((local) => local.localName.toLowerCase().contains(queryLower))
        .toList();
  }
  
  /// Remove least recently used entry
  void _removeLRU() {
    if (_cache.isEmpty) return;
    
    // Find the entry with oldest access time
    String? oldestKey;
    DateTime? oldestTime;
    
    for (final entry in _accessTimes.entries) {
      if (oldestTime == null || entry.value.isBefore(oldestTime)) {
        oldestTime = entry.value;
        oldestKey = entry.key;
      }
    }
    
    if (oldestKey != null) {
      _cache.remove(oldestKey);
      _accessTimes.remove(oldestKey);
    }
  }
  
  /// Clear all entries
  void clear() {
    _cache.clear();
    _accessTimes.clear();
  }
  
  /// Get current cache size
  int get size => _cache.length;
  
  /// Get memory usage estimate in bytes
  int get estimatedMemoryUsage {
    // Rough estimate: each local ~1KB
    return _cache.length * 1024;
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStats() {
    return {
      'size': _cache.length,
      'maxSize': maxCacheSize,
      'utilizationPercent': (_cache.length / maxCacheSize * 100).round(),
      'estimatedMemoryMB': (estimatedMemoryUsage / (1024 * 1024)).toStringAsFixed(2),
      'oldestEntry': _accessTimes.values.isEmpty ? null : 
          _accessTimes.values.reduce((a, b) => a.isBefore(b) ? a : b).toIso8601String(),
      'newestEntry': _accessTimes.values.isEmpty ? null :
          _accessTimes.values.reduce((a, b) => a.isAfter(b) ? a : b).toIso8601String(),
    };
  }
}

/// Virtual list state management for large datasets
class VirtualJobListState {
  static const int maxRenderedItems = 50;
  static const int preloadBuffer = 10;
  
  final Map<String, Job> _jobCache = {};
  final List<String> _visibleJobIds = [];
  int _totalCount = 0;
  int _startIndex = 0;
  
  /// Update the virtual list with new jobs
  void updateJobs(List<Job> allJobs, int startIndex) {
    _totalCount = allJobs.length;
    _startIndex = startIndex;
    
    // Cache only visible and buffer items
    final endIndex = (startIndex + maxRenderedItems + preloadBuffer)
        .clamp(0, allJobs.length);
    
    _visibleJobIds.clear();
    for (int i = startIndex; i < endIndex; i++) {
      final job = allJobs[i];
      _jobCache[job.id] = job;
      if (i < startIndex + maxRenderedItems) {
        _visibleJobIds.add(job.id);
      }
    }
    
    // Clean up jobs outside the visible range and buffer
    final idsToKeep = Set<String>.from(_jobCache.keys);
    final bufferStart = (startIndex - preloadBuffer).clamp(0, allJobs.length);
    final bufferEnd = (startIndex + maxRenderedItems + preloadBuffer)
        .clamp(0, allJobs.length);
    
    for (int i = 0; i < allJobs.length; i++) {
      if (i < bufferStart || i >= bufferEnd) {
        idsToKeep.remove(allJobs[i].id);
      }
    }
    
    // Remove jobs outside buffer
    _jobCache.removeWhere((id, job) => !idsToKeep.contains(id));
  }
  
  /// Get currently visible jobs
  List<Job> get visibleJobs {
    return _visibleJobIds
        .map((id) => _jobCache[id])
        .where((job) => job != null)
        .cast<Job>()
        .toList();
  }
  
  /// Get total count
  int get totalCount => _totalCount;
  
  /// Get start index
  int get startIndex => _startIndex;
  
  /// Get cached job by ID
  Job? getCachedJob(String id) => _jobCache[id];
  
  /// Clear all cached data
  void clear() {
    _jobCache.clear();
    _visibleJobIds.clear();
    _totalCount = 0;
    _startIndex = 0;
  }
  
  /// Get memory usage estimate in bytes
  int get estimatedMemoryUsage {
    // Rough estimate: each cached job ~2KB
    return _jobCache.length * 2048;
  }
  
  /// Get virtual list statistics
  Map<String, dynamic> getStats() {
    return {
      'cachedItems': _jobCache.length,
      'visibleItems': _visibleJobIds.length,
      'totalItems': _totalCount,
      'startIndex': _startIndex,
      'estimatedMemoryMB': (estimatedMemoryUsage / (1024 * 1024)).toStringAsFixed(2),
      'memoryEfficiencyPercent': _totalCount > 0 ? 
          ((_jobCache.length / _totalCount) * 100).toStringAsFixed(1) : '0.0',
    };
  }
}

/// Memory monitoring and cleanup utilities
class MemoryMonitor {
  static const Duration monitoringInterval = Duration(minutes: 5);
  static const int memoryWarningThresholdMB = 55; // Target from 80MB to 55MB
  static const int memoryCriticalThresholdMB = 70;
  
  static int _peakMemoryUsage = 0;
  static DateTime? _lastCleanup;
  
  /// Get current memory usage estimate from all managed components
  static int getTotalMemoryUsage({
    BoundedJobList? jobList,
    LocalsLRUCache? localsCache,
    VirtualJobListState? virtualList,
  }) {
    int total = 0;
    
    if (jobList != null) {
      total += jobList.estimatedMemoryUsage;
    }
    
    if (localsCache != null) {
      total += localsCache.estimatedMemoryUsage;
    }
    
    if (virtualList != null) {
      total += virtualList.estimatedMemoryUsage;
    }
    
    // Update peak usage
    if (total > _peakMemoryUsage) {
      _peakMemoryUsage = total;
    }
    
    return total;
  }
  
  /// Check if memory cleanup is needed
  static bool shouldPerformCleanup({
    BoundedJobList? jobList,
    LocalsLRUCache? localsCache,
    VirtualJobListState? virtualList,
  }) {
    final totalUsageMB = getTotalMemoryUsage(
      jobList: jobList,
      localsCache: localsCache,
      virtualList: virtualList,
    ) / (1024 * 1024);
    
    // Clean up if over warning threshold or if it's been a while
    final timeSinceLastCleanup = _lastCleanup != null ? 
        DateTime.now().difference(_lastCleanup!) : Duration(hours: 1);
    
    return totalUsageMB > memoryWarningThresholdMB || 
           timeSinceLastCleanup > monitoringInterval;
  }
  
  /// Perform memory cleanup
  static void performCleanup({
    BoundedJobList? jobList,
    LocalsLRUCache? localsCache,
    VirtualJobListState? virtualList,
  }) {
    _lastCleanup = DateTime.now();
    
    // For now, we rely on the data structures' built-in limits
    // In the future, we could implement more aggressive cleanup strategies
    
    // Memory cleanup performed - logged in debug mode by caller
  }
  
  /// Get memory statistics
  static Map<String, dynamic> getMemoryStats({
    BoundedJobList? jobList,
    LocalsLRUCache? localsCache,
    VirtualJobListState? virtualList,
  }) {
    final currentUsage = getTotalMemoryUsage(
      jobList: jobList,
      localsCache: localsCache,
      virtualList: virtualList,
    );
    
    return {
      'currentUsageMB': (currentUsage / (1024 * 1024)).toStringAsFixed(2),
      'peakUsageMB': (_peakMemoryUsage / (1024 * 1024)).toStringAsFixed(2),
      'warningThresholdMB': memoryWarningThresholdMB,
      'criticalThresholdMB': memoryCriticalThresholdMB,
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'shouldCleanup': shouldPerformCleanup(
        jobList: jobList,
        localsCache: localsCache,
        virtualList: virtualList,
      ),
      'components': {
        if (jobList != null) 'jobList': {
          'itemCount': jobList.length,
          'memoryMB': (jobList.estimatedMemoryUsage / (1024 * 1024)).toStringAsFixed(2),
        },
        if (localsCache != null) 'localsCache': localsCache.getStats(),
        if (virtualList != null) 'virtualList': virtualList.getStats(),
      },
    };
  }
}