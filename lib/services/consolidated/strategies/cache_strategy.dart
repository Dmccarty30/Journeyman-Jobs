import 'dart:async';

/// Strategy interface for caching in Firestore operations
///
/// Implementations provide different caching mechanisms:
/// - In-memory cache with TTL
/// - Persistent cache with storage
/// - No-cache for testing
/// - LRU cache with size limits
abstract class CacheStrategy {
  /// Get a value from cache
  ///
  /// [key] - Cache key
  ///
  /// Returns the cached value or null if not found/expired
  Future<T?> get<T>(String key);

  /// Set a value in cache
  ///
  /// [key] - Cache key
  /// [value] - Value to cache
  /// [ttl] - Time to live (optional, implementation-specific default if null)
  Future<void> set<T>(String key, T value, {Duration? ttl});

  /// Invalidate a specific cache entry
  ///
  /// [key] - Cache key to invalidate
  Future<void> invalidate(String key);

  /// Invalidate all entries matching a pattern
  ///
  /// [pattern] - Key pattern to match (supports wildcards)
  Future<void> invalidatePattern(String pattern);

  /// Clear all cache entries
  Future<void> clear();

  /// Get cache statistics
  ///
  /// Returns metrics like hit rate, size, entries, etc.
  Map<String, dynamic> getStatistics();
}

/// Cache entry with TTL support
class CacheEntry<T> {
  final T value;
  final DateTime createdAt;
  final DateTime? expiresAt;

  CacheEntry({
    required this.value,
    DateTime? createdAt,
    this.expiresAt,
  }) : createdAt = createdAt ?? DateTime.now();

  /// Check if this entry has expired
  bool get isExpired {
    if (expiresAt == null) return false;
    return DateTime.now().isAfter(expiresAt!);
  }

  /// Get remaining TTL
  Duration? get remainingTTL {
    if (expiresAt == null) return null;
    final remaining = expiresAt!.difference(DateTime.now());
    return remaining.isNegative ? Duration.zero : remaining;
  }

  /// Get age of this cache entry
  Duration get age => DateTime.now().difference(createdAt);
}

/// Cache statistics for monitoring and optimization
class CacheStatistics {
  final int totalRequests;
  final int hits;
  final int misses;
  final int evictions;
  final int entries;
  final int maxSize;
  final int sizeBytes;

  CacheStatistics({
    required this.totalRequests,
    required this.hits,
    required this.misses,
    required this.evictions,
    required this.entries,
    required this.maxSize,
    required this.sizeBytes,
  });

  /// Calculate hit rate percentage
  double get hitRate {
    if (totalRequests == 0) return 0.0;
    return (hits / totalRequests) * 100;
  }

  /// Calculate miss rate percentage
  double get missRate {
    if (totalRequests == 0) return 0.0;
    return (misses / totalRequests) * 100;
  }

  /// Calculate eviction rate percentage
  double get evictionRate {
    if (entries == 0) return 0.0;
    return (evictions / entries) * 100;
  }

  /// Calculate fill percentage
  double get fillPercentage {
    if (maxSize == 0) return 0.0;
    return (entries / maxSize) * 100;
  }

  Map<String, dynamic> toJson() {
    return {
      'totalRequests': totalRequests,
      'hits': hits,
      'misses': misses,
      'evictions': evictions,
      'entries': entries,
      'maxSize': maxSize,
      'sizeBytes': sizeBytes,
      'hitRate': hitRate,
      'missRate': missRate,
      'evictionRate': evictionRate,
      'fillPercentage': fillPercentage,
    };
  }
}

/// Cache key builder for consistent key generation
class CacheKeyBuilder {
  final String _prefix;

  CacheKeyBuilder(this._prefix);

  /// Build a cache key from components
  String build(List<String> components) {
    return '$_prefix:${components.join(':')}';
  }

  /// Build a user data cache key
  String userData(String userId) {
    return build(['user', userId]);
  }

  /// Build a job data cache key
  String jobData(String jobId) {
    return build(['job', jobId]);
  }

  /// Build a locals data cache key
  String localsData(String localId) {
    return build(['local', localId]);
  }

  /// Build a search results cache key
  String searchResults(String query, {String? filter}) {
    if (filter != null) {
      return build(['search', query, filter]);
    }
    return build(['search', query]);
  }

  /// Build a popular items cache key
  String popularItems(String collection, {int limit = 10}) {
    return build(['popular', collection, limit.toString()]);
  }

  /// Build a regional data cache key
  String regionalData(String collection, String region) {
    return build(['regional', collection, region]);
  }
}
