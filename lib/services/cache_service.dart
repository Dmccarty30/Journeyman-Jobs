import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service for caching frequently accessed data
/// 
/// This service provides in-memory and persistent caching capabilities
/// to improve app performance and reduce Firestore read operations.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // In-memory cache with LRU tracking
  final Map<String, CacheEntry> _memoryCache = {};
  final List<String> _accessOrder = []; // LRU tracking
  
  // Statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;
  DateTime? _lastCleanup;
  
  // Cache configuration
  static const Duration defaultTtl = Duration(minutes: 30);
  static const Duration userDataTtl = Duration(hours: 2);
  static const Duration localsTtl = Duration(days: 1);
  static const Duration jobsTtl = Duration(minutes: 15);
  static const int maxMemoryEntries = 100; // Reduced for better performance
  static const int maxPersistentEntries = 500;
  
  // Cache keys
  static const String userDataPrefix = 'user_data_';
  static const String localsPrefix = 'locals_';
  static const String jobsPrefix = 'jobs_';
  static const String popularJobsKey = 'popular_jobs';
  static const String userPreferencesPrefix = 'user_prefs_';
  
  /// Get data from cache (memory first, then persistent)
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    // Periodic cleanup to remove expired entries
    _performPeriodicCleanup();
    
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      _hitCount++;
      _updateAccessOrder(key); // Update LRU tracking
      
      if (kDebugMode) {
        print('Cache HIT (memory): $key');
      }
      return memoryEntry.data as T?;
    } else if (memoryEntry != null && memoryEntry.isExpired) {
      // Remove expired entry from memory
      _removeFromMemoryCache(key);
    }
    
    // Check persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cachedJson = prefs.getString(key);
      if (cachedJson != null) {
        final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
        final timestamp = DateTime.parse(cachedData['timestamp']);
        final ttl = Duration(milliseconds: cachedData['ttl']);
        
        if (DateTime.now().difference(timestamp) < ttl) {
          final data = cachedData['data'];
          T? result;
          
          if (fromJson != null && data is Map<String, dynamic>) {
            result = fromJson(data);
          } else {
            result = data as T?;
          }
          
          // Update memory cache with LRU enforcement
          _setMemoryCache(key, result, ttl);
          _hitCount++;
          
          if (kDebugMode) {
            print('Cache HIT (persistent): $key');
          }
          return result;
        } else {
          // Expired, remove from persistent cache
          await prefs.remove(key);
          if (kDebugMode) {
            print('Cache EXPIRED: $key');
          }
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache ERROR: $key - $e');
      }
    }
    
    _missCount++;
    
    if (kDebugMode) {
      print('Cache MISS: $key');
    }
    return null;
  }
  
  /// Set data in cache (both memory and persistent)
  Future<void> set<T>(
    String key, 
    T data, {
    Duration? ttl,
    bool persistentOnly = false,
  }) async {
    ttl ??= defaultTtl;
    
    // Set in memory cache with LRU enforcement
    if (!persistentOnly) {
      _setMemoryCache(key, data, ttl);
    }
    
    // Set in persistent cache
    try {
      final prefs = await SharedPreferences.getInstance();
      final cacheData = {
        'data': data,
        'timestamp': DateTime.now().toIso8601String(),
        'ttl': ttl.inMilliseconds,
      };
      await prefs.setString(key, jsonEncode(cacheData));
      
      if (kDebugMode) {
        print('Cache SET: $key (TTL: ${ttl.inMinutes}min)');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache SET ERROR: $key - $e');
      }
    }
  }
  
  /// Remove data from cache
  Future<void> remove(String key) async {
    _removeFromMemoryCache(key);
    
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(key);
      
      if (kDebugMode) {
        print('Cache REMOVE: $key');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache REMOVE ERROR: $key - $e');
      }
    }
  }
  
  /// Clear all cache data
  Future<void> clear() async {
    _memoryCache.clear();
    _accessOrder.clear();
    _hitCount = 0;
    _missCount = 0;
    _evictionCount = 0;
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith(userDataPrefix) ||
        key.startsWith(localsPrefix) ||
        key.startsWith(jobsPrefix) ||
        key.startsWith(userPreferencesPrefix) ||
        key == popularJobsKey
      ).toList();
      
      for (final key in keys) {
        await prefs.remove(key);
      }
      
      if (kDebugMode) {
        print('Cache CLEARED: ${keys.length} entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache CLEAR ERROR: $e');
      }
    }
  }
  
  /// Clear expired entries from cache
  Future<void> clearExpired() async {
    // Clear expired memory cache entries
    final expiredMemoryKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredMemoryKeys) {
      _memoryCache.remove(key);
    }
    
    // Clear expired persistent cache entries
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith(userDataPrefix) ||
        key.startsWith(localsPrefix) ||
        key.startsWith(jobsPrefix) ||
        key.startsWith(userPreferencesPrefix) ||
        key == popularJobsKey
      ).toList();
      
      int expiredCount = 0;
      for (final key in keys) {
        final cachedJson = prefs.getString(key);
        if (cachedJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
            final timestamp = DateTime.parse(cachedData['timestamp']);
            final ttl = Duration(milliseconds: cachedData['ttl']);
            
            if (DateTime.now().difference(timestamp) >= ttl) {
              await prefs.remove(key);
              expiredCount++;
            }
          } catch (e) {
            // Invalid cache entry, remove it
            await prefs.remove(key);
            expiredCount++;
          }
        }
      }
      
      if (kDebugMode) {
        print('Cache EXPIRED CLEARED: $expiredCount entries');
      }
    } catch (e) {
      if (kDebugMode) {
        print('Cache CLEAR EXPIRED ERROR: $e');
      }
    }
  }
  
  /// Set data in memory cache with LRU eviction
  void _setMemoryCache<T>(String key, T data, Duration ttl) {
    // Enforce LRU eviction if cache is full
    while (_memoryCache.length >= maxMemoryEntries) {
      _evictLeastRecentlyUsed();
    }
    
    _memoryCache[key] = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
    
    _updateAccessOrder(key);
  }
  
  /// Update LRU access order
  void _updateAccessOrder(String key) {
    _accessOrder.remove(key); // Remove if exists
    _accessOrder.add(key); // Add to end (most recent)
  }
  
  /// Remove from memory cache and update access order
  void _removeFromMemoryCache(String key) {
    _memoryCache.remove(key);
    _accessOrder.remove(key);
  }
  
  /// Evict least recently used entry
  void _evictLeastRecentlyUsed() {
    if (_accessOrder.isEmpty) return;
    
    final lruKey = _accessOrder.first;
    _memoryCache.remove(lruKey);
    _accessOrder.removeAt(0);
    _evictionCount++;
    
    if (kDebugMode) {
      print('Cache LRU EVICTED: $lruKey');
    }
  }
  
  /// Perform periodic cleanup of expired entries
  void _performPeriodicCleanup() {
    final now = DateTime.now();
    _lastCleanup ??= now;
    
    // Run cleanup every 5 minutes
    if (now.difference(_lastCleanup!) > const Duration(minutes: 5)) {
      _cleanupExpiredMemoryEntries();
      _lastCleanup = now;
    }
  }
  
  /// Clean up expired entries from memory cache
  void _cleanupExpiredMemoryEntries() {
    final expiredKeys = _memoryCache.entries
        .where((entry) => entry.value.isExpired)
        .map((entry) => entry.key)
        .toList();
    
    for (final key in expiredKeys) {
      _removeFromMemoryCache(key);
    }
    
    if (kDebugMode && expiredKeys.isNotEmpty) {
      print('Cache AUTO-CLEANUP: ${expiredKeys.length} expired entries removed');
    }
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final memoryEntries = _memoryCache.length;
    final expiredMemoryEntries = _memoryCache.values
        .where((entry) => entry.isExpired)
        .length;
    final totalRequests = _hitCount + _missCount;
    final hitRate = totalRequests > 0 ? (_hitCount / totalRequests * 100) : 0.0;
    
    return {
      'memoryEntries': memoryEntries,
      'expiredMemoryEntries': expiredMemoryEntries,
      'maxMemoryEntries': maxMemoryEntries,
      'memoryUsagePercent': (memoryEntries / maxMemoryEntries * 100).round(),
      'hitCount': _hitCount,
      'missCount': _missCount,
      'evictionCount': _evictionCount,
      'hitRate': hitRate.toStringAsFixed(1),
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'accessOrderLength': _accessOrder.length,
    };
  }
  
  // Convenience methods for specific data types
  
  /// Cache user data
  Future<void> cacheUserData(String uid, Map<String, dynamic> userData) {
    return set('$userDataPrefix$uid', userData, ttl: userDataTtl);
  }
  
  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData(String uid) {
    return get<Map<String, dynamic>>('$userDataPrefix$uid');
  }
  
  /// Cache locals data
  Future<void> cacheLocals(List<Map<String, dynamic>> locals) {
    return set('${localsPrefix}all', locals, ttl: localsTtl);
  }
  
  /// Get cached locals
  Future<List<Map<String, dynamic>>?> getCachedLocals() {
    return get<List<Map<String, dynamic>>>('${localsPrefix}all');
  }
  
  /// Cache popular jobs
  Future<void> cachePopularJobs(List<Map<String, dynamic>> jobs) {
    return set(popularJobsKey, jobs, ttl: jobsTtl);
  }
  
  /// Get cached popular jobs
  Future<List<Map<String, dynamic>>?> getCachedPopularJobs() {
    return get<List<Map<String, dynamic>>>(popularJobsKey);
  }
  
  /// Cache user preferences
  Future<void> cacheUserPreferences(String uid, Map<String, dynamic> preferences) {
    return set('$userPreferencesPrefix$uid', preferences, ttl: userDataTtl);
  }
  
  /// Get cached user preferences
  Future<Map<String, dynamic>?> getCachedUserPreferences(String uid) {
    return get<Map<String, dynamic>>('$userPreferencesPrefix$uid');
  }
}

/// Cache entry with expiration
class CacheEntry {
  final dynamic data;
  final DateTime createdAt;
  final Duration ttl;
  
  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
  });
  
  bool get isExpired => DateTime.now().difference(createdAt) >= ttl;
}
