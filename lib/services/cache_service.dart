import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A service for caching frequently accessed data.
///
/// This service provides a two-tiered caching mechanism: a fast in-memory cache
/// with LRU (Least Recently Used) eviction and a persistent cache using
/// `shared_preferences`. It aims to improve app performance and reduce backend
/// read operations.
class CacheService {
  static final CacheService _instance = CacheService._internal();

  /// Provides a singleton instance of the [CacheService].
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
  /// The default time-to-live for cache entries.
  static const Duration defaultTtl = Duration(minutes: 30);
  /// The time-to-live for user data cache entries.
  static const Duration userDataTtl = Duration(hours: 2);
  /// The time-to-live for IBEW local union data.
  static const Duration localsTtl = Duration(days: 1);
  /// The time-to-live for job postings.
  static const Duration jobsTtl = Duration(minutes: 15);
  /// The maximum number of entries to store in the in-memory cache.
  static const int maxMemoryEntries = 100; // Reduced for better performance
  /// The maximum number of entries to store in the persistent cache.
  static const int maxPersistentEntries = 500;
  
  // Cache keys
  /// Prefix for user data cache keys.
  static const String userDataPrefix = 'user_data_';
  /// Prefix for IBEW local union data cache keys.
  static const String localsPrefix = 'locals_';
  /// Prefix for job data cache keys.
  static const String jobsPrefix = 'jobs_';
  /// Key for caching popular jobs.
  static const String popularJobsKey = 'popular_jobs';
  /// Prefix for user preferences cache keys.
  static const String userPreferencesPrefix = 'user_prefs_';
  
  /// Retrieves data from the cache.
  ///
  /// It checks the in-memory cache first. If not found or expired, it checks
  /// the persistent cache. If found there, it's loaded back into memory.
  ///
  /// - [key]: The unique key for the cached item.
  /// - [fromJson]: An optional function to deserialize JSON data into an object of type `T`.
  ///
  /// Returns the cached data as type `T`, or `null` if not found or expired.
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
  
  /// Saves or updates data in the cache.
  ///
  /// The data is stored in both the in-memory and persistent caches by default.
  ///
  /// - [key]: The unique key for the item to be cached.
  /// - [data]: The data to cache.
  /// - [ttl]: The time-to-live for this cache entry. Uses [defaultTtl] if not specified.
  /// - [persistentOnly]: If `true`, only stores the data in the persistent cache.
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
  
  /// Removes an item from both the in-memory and persistent caches.
  ///
  /// - [key]: The key of the item to remove.
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
  
  /// Clears all data from both the in-memory and persistent caches.
  ///
  /// This also resets all cache statistics.
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
  
  /// Removes all expired entries from both the in-memory and persistent caches.
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
  
  /// Retrieves statistics about the cache's performance.
  ///
  /// Returns a map containing metrics like hit rate, memory usage, and counts
  /// for hits, misses, and evictions.
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
  
  /// Caches user-specific data.
  ///
  /// - [uid]: The user's unique ID.
  /// - [userData]: A map containing the user's data.
  Future<void> cacheUserData(String uid, Map<String, dynamic> userData) {
    return set('$userDataPrefix$uid', userData, ttl: userDataTtl);
  }
  
  /// Retrieves cached user data.
  ///
  /// - [uid]: The user's unique ID.
  ///
  /// Returns a `Map<String, dynamic>` of user data, or `null` if not cached.
  Future<Map<String, dynamic>?> getCachedUserData(String uid) {
    return get<Map<String, dynamic>>('$userDataPrefix$uid');
  }
  
  /// Caches a list of IBEW local unions.
  ///
  /// - [locals]: A list of maps, where each map represents a local union.
  Future<void> cacheLocals(List<Map<String, dynamic>> locals) {
    return set('${localsPrefix}all', locals, ttl: localsTtl);
  }
  
  /// Retrieves the cached list of IBEW local unions.
  ///
  /// Returns a list of local union data, or `null` if not cached.
  Future<List<Map<String, dynamic>>?> getCachedLocals() {
    return get<List<Map<String, dynamic>>>('${localsPrefix}all');
  }
  
  /// Caches a list of popular jobs.
  ///
  /// - [jobs]: A list of maps, where each map represents a job.
  Future<void> cachePopularJobs(List<Map<String, dynamic>> jobs) {
    return set(popularJobsKey, jobs, ttl: jobsTtl);
  }
  
  /// Retrieves the cached list of popular jobs.
  ///
  /// Returns a list of job data, or `null` if not cached.
  Future<List<Map<String, dynamic>>?> getCachedPopularJobs() {
    return get<List<Map<String, dynamic>>>(popularJobsKey);
  }
  
  /// Caches user-specific preferences.
  ///
  /// - [uid]: The user's unique ID.
  /// - [preferences]: A map containing the user's preferences.
  Future<void> cacheUserPreferences(String uid, Map<String, dynamic> preferences) {
    return set('$userPreferencesPrefix$uid', preferences, ttl: userDataTtl);
  }
  
  /// Retrieves a user's cached preferences.
  ///
  /// - [uid]: The user's unique ID.
  ///
  /// Returns a map of user preferences, or `null` if not cached.
  Future<Map<String, dynamic>?> getCachedUserPreferences(String uid) {
    return get<Map<String, dynamic>>('$userPreferencesPrefix$uid');
  }
}

/// Represents an entry in the in-memory cache.
class CacheEntry {
  /// The cached data.
  final dynamic data;
  /// The timestamp when the entry was created.
  final DateTime createdAt;
  /// The duration for which this entry is considered valid.
  final Duration ttl;
  
  /// Creates a new cache entry.
  CacheEntry({
    required this.data,
    required this.createdAt,
    required this.ttl,
  });
  
  /// Returns `true` if the cache entry has expired.
  bool get isExpired => DateTime.now().difference(createdAt) >= ttl;
}
