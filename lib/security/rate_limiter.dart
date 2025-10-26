/// Rate limiting service for Journeyman Jobs app.
///
/// Implements token bucket algorithm for rate limiting with:
/// - Per-user rate limits (100 requests/minute by default)
/// - Per-IP tracking (for unauthenticated requests)
/// - Exponential backoff for violations
/// - Automatic cleanup of expired buckets
/// - Configurable limits per operation type
///
/// Example usage:
/// ```dart
/// final rateLimiter = RateLimiter();
///
/// // Check if request is allowed
/// if (await rateLimiter.isAllowed('user123', operation: 'auth')) {
///   // Proceed with operation
/// } else {
///   // Show rate limit error
///   throw RateLimitException('Too many requests');
/// }
/// ```
library;

import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

/// Exception thrown when rate limit is exceeded.
///
/// Contains information about:
/// - Remaining time until limit resets
/// - Current operation being rate limited
/// - Suggested retry time
class RateLimitException implements Exception {
  final String message;
  final Duration retryAfter;
  final String operation;

  const RateLimitException(
    this.message, {
    required this.retryAfter,
    this.operation = 'unknown',
  });

  @override
  String toString() => 'RateLimitException: $message (retry after ${retryAfter.inSeconds}s)';
}

/// Token bucket implementation for rate limiting.
///
/// Each bucket has:
/// - Maximum capacity (max tokens)
/// - Current token count
/// - Refill rate (tokens per second)
/// - Last refill timestamp
/// - Violation count (for exponential backoff)
@immutable
class _TokenBucket {
  final int capacity;
  final double refillRate; // tokens per second
  final double currentTokens;
  final DateTime lastRefill;
  final int violationCount;

  const _TokenBucket({
    required this.capacity,
    required this.refillRate,
    required this.currentTokens,
    required this.lastRefill,
    this.violationCount = 0,
  });

  /// Creates a new bucket with full capacity.
  factory _TokenBucket.create({
    required int capacity,
    required double refillRate,
  }) {
    return _TokenBucket(
      capacity: capacity,
      refillRate: refillRate,
      currentTokens: capacity.toDouble(),
      lastRefill: DateTime.now(),
      violationCount: 0,
    );
  }

  /// Refills the bucket based on time elapsed since last refill.
  ///
  /// Tokens are added at the configured refill rate, up to capacity.
  _TokenBucket refill() {
    final now = DateTime.now();
    final elapsed = now.difference(lastRefill).inMilliseconds / 1000.0;
    final tokensToAdd = elapsed * refillRate;
    final newTokens = (currentTokens + tokensToAdd).clamp(0.0, capacity.toDouble());

    return _TokenBucket(
      capacity: capacity,
      refillRate: refillRate,
      currentTokens: newTokens,
      lastRefill: now,
      violationCount: violationCount,
    );
  }

  /// Attempts to consume tokens from the bucket.
  ///
  /// Returns a tuple of (success, updatedBucket).
  /// If successful, returns bucket with reduced token count.
  /// If failed, returns bucket with incremented violation count.
  (bool, _TokenBucket) tryConsume(int tokens) {
    final refilled = refill();

    if (refilled.currentTokens >= tokens) {
      // Success: consume tokens
      return (
        true,
        _TokenBucket(
          capacity: refilled.capacity,
          refillRate: refilled.refillRate,
          currentTokens: refilled.currentTokens - tokens,
          lastRefill: refilled.lastRefill,
          violationCount: 0, // Reset violation count on success
        ),
      );
    } else {
      // Failure: increment violation count
      return (
        false,
        _TokenBucket(
          capacity: refilled.capacity,
          refillRate: refilled.refillRate,
          currentTokens: refilled.currentTokens,
          lastRefill: refilled.lastRefill,
          violationCount: refilled.violationCount + 1,
        ),
      );
    }
  }

  /// Calculates time until bucket has enough tokens.
  Duration timeUntilAvailable(int tokens) {
    final refilled = refill();
    final tokensNeeded = tokens - refilled.currentTokens;

    if (tokensNeeded <= 0) {
      return Duration.zero;
    }

    final secondsNeeded = tokensNeeded / refillRate;
    return Duration(milliseconds: (secondsNeeded * 1000).ceil());
  }

  /// Checks if bucket has been idle (for cleanup).
  bool isIdle(Duration idleDuration) {
    final now = DateTime.now();
    return now.difference(lastRefill) > idleDuration;
  }
}

/// Rate limiter configuration for different operation types.
@immutable
class RateLimitConfig {
  /// Maximum requests allowed in the time window
  final int maxRequests;

  /// Time window in seconds
  final int windowSeconds;

  /// Token cost per request (default: 1)
  final int costPerRequest;

  const RateLimitConfig({
    required this.maxRequests,
    required this.windowSeconds,
    this.costPerRequest = 1,
  });

  /// Calculates refill rate (tokens per second).
  double get refillRate => maxRequests / windowSeconds;
}

/// Comprehensive rate limiter using token bucket algorithm.
///
/// Features:
/// - Per-user and per-IP rate limiting
/// - Configurable limits per operation type
/// - Exponential backoff for repeat violations
/// - Automatic cleanup of expired buckets
/// - Thread-safe bucket management
class RateLimiter {
  /// Stores token buckets per identifier (user ID or IP)
  final Map<String, _TokenBucket> _buckets = {};

  /// Cleanup timer for removing idle buckets
  Timer? _cleanupTimer;

  /// Default rate limit configurations
  static final Map<String, RateLimitConfig> _defaultConfigs = {
    'auth': const RateLimitConfig(
      maxRequests: 5, // 5 auth attempts
      windowSeconds: 60, // per minute
      costPerRequest: 1,
    ),
    'firestore_read': const RateLimitConfig(
      maxRequests: 100, // 100 reads
      windowSeconds: 60, // per minute
      costPerRequest: 1,
    ),
    'firestore_write': const RateLimitConfig(
      maxRequests: 50, // 50 writes
      windowSeconds: 60, // per minute
      costPerRequest: 2, // Writes cost 2 tokens
    ),
    'api': const RateLimitConfig(
      maxRequests: 100, // 100 API calls
      windowSeconds: 60, // per minute
      costPerRequest: 1,
    ),
    'default': const RateLimitConfig(
      maxRequests: 100, // 100 requests
      windowSeconds: 60, // per minute
      costPerRequest: 1,
    ),
  };

  /// Custom configurations (can be overridden)
  final Map<String, RateLimitConfig> _customConfigs;

  /// Idle bucket cleanup interval (default: 5 minutes)
  final Duration _cleanupInterval;

  /// Bucket idle threshold for cleanup (default: 10 minutes)
  final Duration _idleThreshold;

  RateLimiter({
    Map<String, RateLimitConfig>? customConfigs,
    Duration cleanupInterval = const Duration(minutes: 5),
    Duration idleThreshold = const Duration(minutes: 10),
  })  : _customConfigs = customConfigs ?? {},
        _cleanupInterval = cleanupInterval,
        _idleThreshold = idleThreshold {
    _startCleanupTimer();
  }

  /// Starts periodic cleanup of idle buckets.
  void _startCleanupTimer() {
    _cleanupTimer?.cancel();
    _cleanupTimer = Timer.periodic(_cleanupInterval, (_) => _cleanup());
  }

  /// Removes idle buckets to prevent memory leaks.
  void _cleanup() {
    final keysToRemove = <String>[];

    for (final entry in _buckets.entries) {
      if (entry.value.isIdle(_idleThreshold)) {
        keysToRemove.add(entry.key);
      }
    }

    for (final key in keysToRemove) {
      _buckets.remove(key);
    }

    if (keysToRemove.isNotEmpty) {
      debugPrint('[RateLimiter] Cleaned up ${keysToRemove.length} idle buckets');
    }
  }

  /// Gets configuration for an operation type.
  RateLimitConfig _getConfig(String operation) {
    return _customConfigs[operation] ??
        _defaultConfigs[operation] ??
        _defaultConfigs['default']!;
  }

  /// Gets or creates a token bucket for an identifier.
  _TokenBucket _getBucket(String identifier, RateLimitConfig config) {
    if (!_buckets.containsKey(identifier)) {
      _buckets[identifier] = _TokenBucket.create(
        capacity: config.maxRequests,
        refillRate: config.refillRate,
      );
    }

    return _buckets[identifier]!;
  }

  /// Checks if a request is allowed for the given identifier and operation.
  ///
  /// Parameters:
  /// - identifier: User ID, IP address, or other unique identifier
  /// - operation: Type of operation (auth, firestore_read, firestore_write, api, etc.)
  /// - cost: Token cost for this request (default: config.costPerRequest)
  ///
  /// Returns true if request is allowed, false if rate limit exceeded.
  ///
  /// Throws [RateLimitException] if limit is exceeded (when throwOnLimit is true).
  ///
  /// Example:
  /// ```dart
  /// if (await rateLimiter.isAllowed('user123', operation: 'auth')) {
  ///   // Proceed with auth
  /// } else {
  ///   // Show error
  /// }
  /// ```
  Future<bool> isAllowed(
    String identifier, {
    String operation = 'default',
    int? cost,
    bool throwOnLimit = false,
  }) async {
    final config = _getConfig(operation);
    final tokenCost = cost ?? config.costPerRequest;

    final bucket = _getBucket(identifier, config);
    final (allowed, updatedBucket) = bucket.tryConsume(tokenCost);

    _buckets[identifier] = updatedBucket;

    if (!allowed) {
      final retryAfter = bucket.timeUntilAvailable(tokenCost);

      // Apply exponential backoff based on violation count
      final backoffMultiplier = _calculateBackoff(updatedBucket.violationCount);
      final adjustedRetryAfter = retryAfter * backoffMultiplier;

      debugPrint(
        '[RateLimiter] Rate limit exceeded for $identifier ($operation) - '
        'retry after ${adjustedRetryAfter.inSeconds}s '
        '(violations: ${updatedBucket.violationCount})',
      );

      if (throwOnLimit) {
        throw RateLimitException(
          'Rate limit exceeded for $operation',
          retryAfter: adjustedRetryAfter,
          operation: operation,
        );
      }
    }

    return allowed;
  }

  /// Calculates exponential backoff multiplier based on violation count.
  ///
  /// Formula: 2^(violations - 1), capped at 32x
  /// - 1 violation: 1x (no backoff)
  /// - 2 violations: 2x
  /// - 3 violations: 4x
  /// - 4 violations: 8x
  /// - 5+ violations: 16-32x
  int _calculateBackoff(int violations) {
    if (violations <= 1) return 1;

    final multiplier = 1 << (violations - 1); // 2^(violations-1)
    return multiplier.clamp(1, 32); // Cap at 32x
  }

  /// Gets remaining tokens for an identifier and operation.
  ///
  /// Useful for showing users how many requests they have left.
  ///
  /// Returns the number of available tokens (rounded down).
  ///
  /// Example:
  /// ```dart
  /// final remaining = rateLimiter.getRemainingTokens('user123', operation: 'auth');
  /// print('You have $remaining login attempts remaining');
  /// ```
  int getRemainingTokens(String identifier, {String operation = 'default'}) {
    final config = _getConfig(operation);
    final bucket = _getBucket(identifier, config).refill();

    return bucket.currentTokens.floor();
  }

  /// Gets time until tokens are available for an identifier and operation.
  ///
  /// Parameters:
  /// - identifier: User ID, IP address, or other unique identifier
  /// - operation: Type of operation
  /// - tokensNeeded: Number of tokens needed (default: config.costPerRequest)
  ///
  /// Returns Duration until tokens are available, or Duration.zero if already available.
  ///
  /// Example:
  /// ```dart
  /// final wait = rateLimiter.getRetryAfter('user123', operation: 'auth');
  /// if (wait > Duration.zero) {
  ///   print('Please wait ${wait.inSeconds} seconds');
  /// }
  /// ```
  Duration getRetryAfter(
    String identifier, {
    String operation = 'default',
    int? tokensNeeded,
  }) {
    final config = _getConfig(operation);
    final tokens = tokensNeeded ?? config.costPerRequest;

    final bucket = _getBucket(identifier, config);
    return bucket.timeUntilAvailable(tokens);
  }

  /// Resets rate limit for an identifier and operation.
  ///
  /// This should be used sparingly, typically only for:
  /// - Testing
  /// - Admin operations
  /// - Successful 2FA verification after failed attempts
  ///
  /// Example:
  /// ```dart
  /// // Reset auth limit after successful 2FA
  /// rateLimiter.reset('user123', operation: 'auth');
  /// ```
  void reset(String identifier, {String? operation}) {
    if (operation != null) {
      final key = identifier;
      _buckets.remove(key);
    } else {
      // Reset all operations for this identifier
      _buckets.removeWhere((key, _) => key.startsWith(identifier));
    }

    debugPrint('[RateLimiter] Reset rate limit for $identifier${operation != null ? " ($operation)" : ""}');
  }

  /// Clears all rate limit data.
  ///
  /// USE WITH CAUTION: This resets all rate limits for all users.
  ///
  /// Typically only used for:
  /// - Testing
  /// - Emergency situations
  /// - System maintenance
  void clearAll() {
    _buckets.clear();
    debugPrint('[RateLimiter] Cleared all rate limit data');
  }

  /// Disposes of the rate limiter and cancels cleanup timer.
  ///
  /// Call this when the rate limiter is no longer needed to prevent memory leaks.
  void dispose() {
    _cleanupTimer?.cancel();
    _buckets.clear();
  }

  /// Gets statistics about current rate limiting state.
  ///
  /// Returns a map with:
  /// - totalBuckets: Number of active buckets
  /// - bucketDetails: Map of identifier -> remaining tokens
  ///
  /// Useful for monitoring and debugging.
  Map<String, dynamic> getStats() {
    final bucketDetails = <String, int>{};

    for (final entry in _buckets.entries) {
      bucketDetails[entry.key] = entry.value.refill().currentTokens.floor();
    }

    return {
      'totalBuckets': _buckets.length,
      'bucketDetails': bucketDetails,
    };
  }
}

/// Per-IP rate limiter for unauthenticated requests.
///
/// Uses IP address as identifier. Typically used for:
/// - Login page rate limiting
/// - Public API endpoints
/// - Password reset requests
///
/// Example:
/// ```dart
/// final ipRateLimiter = IpRateLimiter();
///
/// if (await ipRateLimiter.isAllowed('192.168.1.1', operation: 'auth')) {
///   // Allow login attempt
/// }
/// ```
class IpRateLimiter extends RateLimiter {
  IpRateLimiter({
    Map<String, RateLimitConfig>? customConfigs,
  }) : super(
          customConfigs: customConfigs ??
              {
                // More restrictive limits for IP-based rate limiting
                'auth': const RateLimitConfig(
                  maxRequests: 10, // 10 attempts
                  windowSeconds: 300, // per 5 minutes
                  costPerRequest: 1,
                ),
                'api': const RateLimitConfig(
                  maxRequests: 50, // 50 requests
                  windowSeconds: 60, // per minute
                  costPerRequest: 1,
                ),
              },
          cleanupInterval: const Duration(minutes: 10),
          idleThreshold: const Duration(minutes: 30),
        );
}
