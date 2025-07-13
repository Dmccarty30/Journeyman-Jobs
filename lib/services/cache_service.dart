import 'dart:async';
import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Service for caching frequently accessed data
/// 
/// This service provides in-memory and persistent caching capabilities
/// to improve app performance and reduce Firestore read operations.
class CacheService {
  static final CacheService _instance = CacheService._internal();
  factory CacheService() => _instance;
  CacheService._internal();

  // In-memory cache
  final Map<String, CacheEntry> _memoryCache = {};
  
  // Cache configuration
  static const Duration DEFAULT_TTL = Duration(minutes: 30);
  static const Duration USER_DATA_TTL = Duration(hours: 2);
  static const Duration LOCALS_TTL = Duration(days: 1);
  static const Duration JOBS_TTL = Duration(minutes: 15);
  static const int MAX_MEMORY_ENTRIES = 500;
  
  // Cache keys
  static const String USER_DATA_PREFIX = 'user_data_';
  static const String LOCALS_PREFIX = 'locals_';
  static const String JOBS_PREFIX = 'jobs_';
  static const String POPULAR_JOBS_KEY = 'popular_jobs';
  static const String USER_PREFERENCES_PREFIX = 'user_prefs_';
  
  /// Get data from cache (memory first, then persistent)
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      if (kDebugMode) {
        print('Cache HIT (memory): $key');
      }
      return memoryEntry.data as T?;
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
          
          // Update memory cache
          _setMemoryCache(key, result, ttl);
          
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
    ttl ??= DEFAULT_TTL;
    
    // Set in memory cache
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
    _memoryCache.remove(key);
    
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
    
    try {
      final prefs = await SharedPreferences.getInstance();
      final keys = prefs.getKeys().where((key) => 
        key.startsWith(USER_DATA_PREFIX) ||
        key.startsWith(LOCALS_PREFIX) ||
        key.startsWith(JOBS_PREFIX) ||
        key.startsWith(USER_PREFERENCES_PREFIX) ||
        key == POPULAR_JOBS_KEY
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
        key.startsWith(USER_DATA_PREFIX) ||
        key.startsWith(LOCALS_PREFIX) ||
        key.startsWith(JOBS_PREFIX) ||
        key.startsWith(USER_PREFERENCES_PREFIX) ||
        key == POPULAR_JOBS_KEY
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
    // Remove oldest entries if cache is full
    if (_memoryCache.length >= MAX_MEMORY_ENTRIES) {
      final oldestKey = _memoryCache.entries
          .reduce((a, b) => a.value.createdAt.isBefore(b.value.createdAt) ? a : b)
          .key;
      _memoryCache.remove(oldestKey);
    }
    
    _memoryCache[key] = CacheEntry(
      data: data,
      createdAt: DateTime.now(),
      ttl: ttl,
    );
  }
  
  /// Get cache statistics
  Map<String, dynamic> getStats() {
    final memoryEntries = _memoryCache.length;
    final expiredMemoryEntries = _memoryCache.values
        .where((entry) => entry.isExpired)
        .length;
    
    return {
      'memoryEntries': memoryEntries,
      'expiredMemoryEntries': expiredMemoryEntries,
      'maxMemoryEntries': MAX_MEMORY_ENTRIES,
      'memoryUsagePercent': (memoryEntries / MAX_MEMORY_ENTRIES * 100).round(),
    };
  }
  
  // Convenience methods for specific data types
  
  /// Cache user data
  Future<void> cacheUserData(String uid, Map<String, dynamic> userData) {
    return set('${USER_DATA_PREFIX}$uid', userData, ttl: USER_DATA_TTL);
  }
  
  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData(String uid) {
    return get<Map<String, dynamic>>('${USER_DATA_PREFIX}$uid');
  }
  
  /// Cache locals data
  Future<void> cacheLocals(List<Map<String, dynamic>> locals) {
    return set('${LOCALS_PREFIX}all', locals, ttl: LOCALS_TTL);
  }
  
  /// Get cached locals
  Future<List<Map<String, dynamic>>?> getCachedLocals() {
    return get<List<Map<String, dynamic>>>('${LOCALS_PREFIX}all');
  }
  
  /// Cache popular jobs
  Future<void> cachePopularJobs(List<Map<String, dynamic>> jobs) {
    return set(POPULAR_JOBS_KEY, jobs, ttl: JOBS_TTL);
  }
  
  /// Get cached popular jobs
  Future<List<Map<String, dynamic>>?> getCachedPopularJobs() {
    return get<List<Map<String, dynamic>>>(POPULAR_JOBS_KEY);
  }
  
  /// Cache user preferences
  Future<void> cacheUserPreferences(String uid, Map<String, dynamic> preferences) {
    return set('${USER_PREFERENCES_PREFIX}$uid', preferences, ttl: USER_DATA_TTL);
  }
  
  /// Get cached user preferences
  Future<Map<String, dynamic>?> getCachedUserPreferences(String uid) {
    return get<Map<String, dynamic>>('${USER_PREFERENCES_PREFIX}$uid');
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