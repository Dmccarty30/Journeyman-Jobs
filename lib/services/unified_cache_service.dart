/// Unified Cache Service
///
/// Consolidated cache service combining:
/// - In-memory LRU cache with eviction
/// - Persistent storage with SharedPreferences
/// - Data compression for large payloads
/// - Memory usage monitoring
/// - Automatic cleanup and expiration
/// - Cache statistics and analytics
///
/// Replaces: CacheService, OptimizedCacheService
/// Original lines: 396 + 461 = 857 → Consolidated: ~550 lines (36% reduction)

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:crypto/crypto.dart';

class UnifiedCacheService {
  static UnifiedCacheService? _instance;
  static UnifiedCacheService get instance => _instance ??= UnifiedCacheService._();

  UnifiedCacheService._();

  // Cache storage
  late SharedPreferences _prefs;
  final Map<String, CacheEntry> _memoryCache = {};
  final List<String> _accessOrder = []; // LRU tracking

  // Configuration
  static const Duration _defaultTtl = Duration(minutes: 30);
  static const Duration _userDataTtl = Duration(hours: 2);
  static const Duration _localsTtl = Duration(days: 1);
  static const Duration _jobsTtl = Duration(minutes: 15);
  static const Duration _maxCacheAge = Duration(days: 7);
  static const int _maxMemoryEntries = 100;
  static const int _maxPersistentEntries = 500;
  static const int _maxCacheSizeBytes = 50 * 1024 * 1024; // 50MB
  static const int _compressionThreshold = 1024; // Compress data > 1KB

  // Statistics
  int _hitCount = 0;
  int _missCount = 0;
  int _evictionCount = 0;
  int _compressionCount = 0;
  DateTime? _lastCleanup;

  // Cache keys
  static const String _userDataPrefix = 'user_data_';
  static const String _localsPrefix = 'locals_';
  static const String _jobsPrefix = 'jobs_';
  static const String _popularJobsKey = 'popular_jobs';
  static const String _userPreferencesPrefix = 'user_prefs_';

  // Cleanup timer
  Timer? _cleanupTimer;

  /// Initialize the cache service
  Future<void> initialize() async {
    try {
      _prefs = await SharedPreferences.getInstance();
      await _loadExistingCache();
      _startCleanupTimer();
      debugPrint('[UnifiedCacheService] Initialized with ${_memoryCache.length} items');
    } catch (e) {
      debugPrint('[UnifiedCacheService] Initialization error: $e');
    }
  }

  /// Load existing cache from persistent storage
  Future<void> _loadExistingCache() async {
    try {
      final keys = _prefs.getKeys().where((key) =>
        key.startsWith(_userDataPrefix) ||
        key.startsWith(_localsPrefix) ||
        key.startsWith(_jobsPrefix) ||
        key.startsWith(_userPreferencesPrefix) ||
        key == _popularJobsKey
      ).toList();

      for (final key in keys) {
        final cachedJson = _prefs.getString(key);
        if (cachedJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
            final isCompressed = cachedData['compressed'] ?? false;
            final String dataStr = isCompressed
                ? _decompressData(cachedData['data'])
                : cachedData['data'];

            final Map<String, dynamic> data = jsonDecode(dataStr);
            final timestamp = DateTime.parse(cachedData['timestamp']);
            final ttl = Duration(milliseconds: cachedData['ttl']);

            if (DateTime.now().difference(timestamp) < ttl) {
              _memoryCache[key] = CacheEntry(
                data: data,
                timestamp: timestamp,
                ttl: ttl,
                compressed: isCompressed,
              );
              _accessOrder.add(key);
            } else {
              // Expired, remove from persistent cache
              await _prefs.remove(key);
            }
          } catch (e) {
            debugPrint('[UnifiedCacheService] Error loading cache entry $key: $e');
            await _prefs.remove(key);
          }
        }
      }

      debugPrint('[UnifiedCacheService] Loaded ${_memoryCache.length} cache entries from storage');
    } catch (e) {
      debugPrint('[UnifiedCacheService] Error loading existing cache: $e');
    }
  }

  /// Get data from cache (memory first, then persistent)
  Future<T?> get<T>(String key, {T Function(Map<String, dynamic>)? fromJson}) async {
    _performPeriodicCleanup();

    // Check memory cache first
    final memoryEntry = _memoryCache[key];
    if (memoryEntry != null && !memoryEntry.isExpired) {
      _hitCount++;
      _updateAccessOrder(key);

      if (kDebugMode) {
        print('Cache HIT (memory): $key');
      }
      return _deserializeData<T>(memoryEntry.data, fromJson);
    } else if (memoryEntry != null && memoryEntry.isExpired) {
      _removeFromMemoryCache(key);
    }

    // Check persistent cache
    try {
      final cachedJson = _prefs.getString(key);
      if (cachedJson != null) {
        final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
        final timestamp = DateTime.parse(cachedData['timestamp']);
        final ttl = Duration(milliseconds: cachedData['ttl']);

        if (DateTime.now().difference(timestamp) < ttl) {
          final isCompressed = cachedData['compressed'] ?? false;
          final String dataStr = isCompressed
              ? _decompressData(cachedData['data'])
              : cachedData['data'];
          final Map<String, dynamic> data = jsonDecode(dataStr);

          final result = _deserializeData<T>(data, fromJson);

          // Update memory cache with LRU enforcement
          _setMemoryCache(key, data, ttl, compressed: isCompressed);
          _hitCount++;

          if (kDebugMode) {
            print('Cache HIT (persistent): $key');
          }
          return result;
        } else {
          // Expired, remove from persistent cache
          await _prefs.remove(key);
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
    ttl ??= _defaultTtl;

    // Set in memory cache with LRU enforcement
    if (!persistentOnly) {
      _setMemoryCache(key, data, ttl);
    }

    // Set in persistent cache
    try {
      final serializedData = _serializeData(data);
      final shouldCompress = _shouldCompress(serializedData);
      final dataToStore = shouldCompress ? _compressData(serializedData) : serializedData;

      final cacheData = {
        'data': dataToStore,
        'timestamp': DateTime.now().toIso8601String(),
        'ttl': ttl.inMilliseconds,
        'compressed': shouldCompress,
        'size': dataToStore.length,
      };

      await _prefs.setString(key, jsonEncode(cacheData));

      if (shouldCompress) {
        _compressionCount++;
      }

      // Check overall cache size
      await _ensureCacheSizeLimit();

      if (kDebugMode) {
        final savedSize = (dataToStore.length / 1024).toStringAsFixed(1);
        print('Cache SET: $key (TTL: ${ttl.inMinutes}min, Size: ${savedSize}KB${shouldCompress ? ', compressed' : ''})');
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
      await _prefs.remove(key);

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
    _compressionCount = 0;

    try {
      final keys = _prefs.getKeys().where((key) =>
        key.startsWith(_userDataPrefix) ||
        key.startsWith(_localsPrefix) ||
        key.startsWith(_jobsPrefix) ||
        key.startsWith(_userPreferencesPrefix) ||
        key == _popularJobsKey
      ).toList();

      for (final key in keys) {
        await _prefs.remove(key);
      }

      debugPrint('[UnifiedCacheService] Cache CLEARED: ${keys.length} entries');
    } catch (e) {
      debugPrint('[UnifiedCacheService] Cache CLEAR ERROR: $e');
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
      _removeFromMemoryCache(key);
    }

    // Clear expired persistent cache entries
    try {
      final keys = _prefs.getKeys().where((key) =>
        key.startsWith(_userDataPrefix) ||
        key.startsWith(_localsPrefix) ||
        key.startsWith(_jobsPrefix) ||
        key.startsWith(_userPreferencesPrefix) ||
        key == _popularJobsKey
      ).toList();

      int expiredCount = 0;
      for (final key in keys) {
        final cachedJson = _prefs.getString(key);
        if (cachedJson != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(cachedJson);
            final timestamp = DateTime.parse(cachedData['timestamp']);
            final ttl = Duration(milliseconds: cachedData['ttl']);

            if (DateTime.now().difference(timestamp) >= ttl) {
              await _prefs.remove(key);
              expiredCount++;
            }
          } catch (e) {
            await _prefs.remove(key);
            expiredCount++;
          }
        }
      }

      if (kDebugMode) {
        print('Cache EXPIRED CLEARED: $expiredCount entries');
      }
    } catch (e) {
      debugPrint('[UnifiedCacheService] CLEAR EXPIRED ERROR: $e');
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
      'maxMemoryEntries': _maxMemoryEntries,
      'memoryUsagePercent': (memoryEntries / _maxMemoryEntries * 100).round(),
      'hitCount': _hitCount,
      'missCount': _missCount,
      'evictionCount': _evictionCount,
      'compressionCount': _compressionCount,
      'hitRate': hitRate.toStringAsFixed(1),
      'lastCleanup': _lastCleanup?.toIso8601String(),
      'accessOrderLength': _accessOrder.length,
    };
  }

  /// Dispose cache service
  void dispose() {
    _cleanupTimer?.cancel();
    _memoryCache.clear();
    _accessOrder.clear();
    debugPrint('[UnifiedCacheService] Disposed');
  }

  // Private helper methods

  T? _deserializeData<T>(dynamic data, T Function(Map<String, dynamic>)? fromJson) {
    if (fromJson != null && data is Map<String, dynamic>) {
      return fromJson(data);
    }
    return data as T?;
  }

  String _serializeData(dynamic data) {
    if (data is Map<String, dynamic>) {
      return jsonEncode(data);
    } else if (data is List) {
      return jsonEncode(data);
    } else if (data is String) {
      return data;
    }
    return data.toString();
  }

  void _setMemoryCache<T>(String key, T data, Duration ttl, {bool compressed = false}) {
    // Enforce LRU eviction if cache is full
    while (_memoryCache.length >= _maxMemoryEntries) {
      _evictLeastRecentlyUsed();
    }

    _memoryCache[key] = CacheEntry(
      data: data,
      timestamp: DateTime.now(),
      ttl: ttl,
      compressed: compressed,
    );

    _updateAccessOrder(key);
  }

  void _updateAccessOrder(String key) {
    _accessOrder.remove(key);
    _accessOrder.add(key);
  }

  void _removeFromMemoryCache(String key) {
    _memoryCache.remove(key);
    _accessOrder.remove(key);
  }

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

  void _performPeriodicCleanup() {
    final now = DateTime.now();
    _lastCleanup ??= now;

    if (now.difference(_lastCleanup!) > const Duration(minutes: 5)) {
      _cleanupExpiredMemoryEntries();
      _lastCleanup = now;
    }
  }

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

  bool _shouldCompress(String data) {
    return data.length > _compressionThreshold;
  }

  String _compressData(String data) {
    final bytes = utf8.encode(data);
    final compressed = gzip.encode(bytes);
    return base64.encode(compressed);
  }

  String _decompressData(String compressedData) {
    final compressed = base64.decode(compressedData);
    final bytes = gzip.decode(compressed);
    return utf8.decode(bytes);
  }

  Future<void> _ensureCacheSizeLimit() async {
    try {
      int totalSize = 0;
      final keys = _prefs.getKeys().where((key) =>
        key.startsWith(_userDataPrefix) ||
        key.startsWith(_localsPrefix) ||
        key.startsWith(_jobsPrefix) ||
        key.startsWith(_userPreferencesPrefix) ||
        key == _popularJobsKey
      ).toList();

      for (final key in keys) {
        final value = _prefs.getString(key);
        if (value != null) {
          totalSize += value.length;
        }
      }

      if (totalSize > _maxCacheSizeBytes) {
        await _cleanupOldestEntries(totalSize - _maxCacheSizeBytes + (1024 * 1024));
      }
    } catch (e) {
      debugPrint('[UnifiedCacheService] Error ensuring cache size limit: $e');
    }
  }

  Future<void> _cleanupOldestEntries(int bytesToFree) async {
    try {
      final keys = _prefs.getKeys().where((key) =>
        key.startsWith(_userDataPrefix) ||
        key.startsWith(_localsPrefix) ||
        key.startsWith(_jobsPrefix) ||
        key.startsWith(_userPreferencesPrefix) ||
        key == _popularJobsKey
      ).toList();

      final entries = <String, Map<String, dynamic>>{};
      for (final key in keys) {
        final jsonString = _prefs.getString(key);
        if (jsonString != null) {
          try {
            final Map<String, dynamic> cachedData = jsonDecode(jsonString);
            entries[key] = cachedData;
          } catch (e) {
            await _prefs.remove(key);
          }
        }
      }

      final sortedKeys = entries.keys.toList()
        ..sort((a, b) {
          final aTime = DateTime.parse(entries[a]!['timestamp']);
          final bTime = DateTime.parse(entries[b]!['timestamp']);
          return aTime.compareTo(bTime);
        });

      int freedBytes = 0;
      for (final key in sortedKeys) {
        if (freedBytes >= bytesToFree) break;

        final value = _prefs.getString(key);
        if (value != null) {
          freedBytes += value.length;
          await _prefs.remove(key);

          final shortKey = key.contains('_') ? key.substring(key.lastIndexOf('_') + 1) : key;
          _memoryCache.remove(shortKey);
          _accessOrder.remove(shortKey);
        }
      }

      debugPrint('[UnifiedCacheService] Cleaned up ${sortedKeys.length} entries, freed ${(freedBytes / (1024 * 1024)).toStringAsFixed(2)}MB');
    } catch (e) {
      debugPrint('[UnifiedCacheService] Error cleaning up oldest entries: $e');
    }
  }

  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(const Duration(minutes: 30), (timer) {
      _performCleanup();
    });
  }

  void _performCleanup() {
    debugPrint('[UnifiedCacheService] Performing periodic cleanup...');
    _cleanupExpiredMemoryEntries();
    clearExpired();
  }

  // Convenience methods for specific data types

  /// Cache user data
  Future<void> cacheUserData(String uid, Map<String, dynamic> userData) {
    return set('$_userDataPrefix$uid', userData, ttl: _userDataTtl);
  }

  /// Get cached user data
  Future<Map<String, dynamic>?> getCachedUserData(String uid) {
    return get<Map<String, dynamic>>('$_userDataPrefix$uid');
  }

  /// Cache locals data
  Future<void> cacheLocals(List<Map<String, dynamic>> locals) {
    return set('$_localsPrefix${DateTime.now().year}_${DateTime.now().month}', locals, ttl: _localsTtl);
  }

  /// Get cached locals
  Future<List<Map<String, dynamic>>?> getCachedLocals() async {
    // Try current month first
    final currentKey = '$_localsPrefix${DateTime.now().year}_${DateTime.now().month}';
    final result = await get<List<Map<String, dynamic>>>(currentKey);
    if (result != null) return result;

    // Fallback to previous month
    final lastMonth = DateTime(DateTime.now().year, DateTime.now().month - 1);
    final fallbackKey = '$_localsPrefix${lastMonth.year}_${lastMonth.month}';
    return await get<List<Map<String, dynamic>>>(fallbackKey);
  }

  /// Cache popular jobs
  Future<void> cachePopularJobs(List<Map<String, dynamic>> jobs) {
    return set(_popularJobsKey, jobs, ttl: _jobsTtl);
  }

  /// Get cached popular jobs
  Future<List<Map<String, dynamic>>?> getCachedPopularJobs() {
    return get<List<Map<String, dynamic>>>(_popularJobsKey);
  }

  /// Cache user preferences
  Future<void> cacheUserPreferences(String uid, Map<String, dynamic> preferences) {
    return set('$_userPreferencesPrefix$uid', preferences, ttl: _userDataTtl);
  }

  /// Get cached user preferences
  Future<Map<String, dynamic>?> getCachedUserPreferences(String uid) {
    return get<Map<String, dynamic>>('$_userPreferencesPrefix$uid');
  }
}

/// Cache entry with expiration and compression tracking
class CacheEntry {
  final dynamic data;
  final DateTime timestamp;
  final Duration ttl;
  final bool compressed;

  CacheEntry({
    required this.data,
    required this.timestamp,
    required this.ttl,
    this.compressed = false,
  });

  bool get isExpired => DateTime.now().difference(timestamp) >= ttl;
}