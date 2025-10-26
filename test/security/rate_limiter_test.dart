import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/security/rate_limiter.dart';

/// Comprehensive unit tests for RateLimiter security layer.
///
/// Tests cover:
/// - Token bucket algorithm
/// - Rate limit enforcement
/// - Exponential backoff
/// - Bucket cleanup
/// - Per-user and per-IP limiting
/// - Custom configurations
void main() {
  group('RateLimiter - Basic Functionality', () {
    test('should allow requests under limit', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
          ),
        },
      );

      // Make 10 requests (should all succeed)
      for (var i = 0; i < 10; i++) {
        final allowed = await rateLimiter.isAllowed(
          'user123',
          operation: 'test',
        );
        expect(allowed, isTrue, reason: 'Request $i should be allowed');
      }

      rateLimiter.dispose();
    });

    test('should block requests over limit', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 5,
            windowSeconds: 60,
          ),
        },
      );

      // Make 5 requests (should succeed)
      for (var i = 0; i < 5; i++) {
        final allowed = await rateLimiter.isAllowed(
          'user123',
          operation: 'test',
        );
        expect(allowed, isTrue);
      }

      // Next request should fail
      final blocked = await rateLimiter.isAllowed(
        'user123',
        operation: 'test',
      );
      expect(blocked, isFalse);

      rateLimiter.dispose();
    });

    test('should throw RateLimitException when throwOnLimit is true', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 1,
            windowSeconds: 60,
          ),
        },
      );

      // First request succeeds
      await rateLimiter.isAllowed('user123', operation: 'test');

      // Second request should throw
      expect(
        () => rateLimiter.isAllowed(
          'user123',
          operation: 'test',
          throwOnLimit: true,
        ),
        throwsA(isA<RateLimitException>().having(
          (e) => e.operation,
          'operation',
          equals('test'),
        )),
      );

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Token Refill', () {
    test('should refill tokens over time', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 2,
            windowSeconds: 2, // 1 token per second
          ),
        },
      );

      // Consume all tokens
      await rateLimiter.isAllowed('user123', operation: 'test');
      await rateLimiter.isAllowed('user123', operation: 'test');

      // Should be blocked
      final blocked1 = await rateLimiter.isAllowed('user123', operation: 'test');
      expect(blocked1, isFalse);

      // Wait for refill (1 second = 1 token)
      await Future.delayed(const Duration(seconds: 1, milliseconds: 100));

      // Should have 1 token now
      final allowed = await rateLimiter.isAllowed('user123', operation: 'test');
      expect(allowed, isTrue);

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Token Cost', () {
    test('should consume custom token cost', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
            costPerRequest: 3, // Each request costs 3 tokens
          ),
        },
      );

      // Make 3 requests (3 * 3 = 9 tokens)
      for (var i = 0; i < 3; i++) {
        final allowed = await rateLimiter.isAllowed(
          'user123',
          operation: 'test',
        );
        expect(allowed, isTrue);
      }

      // 4th request should fail (would need 12 tokens total)
      final blocked = await rateLimiter.isAllowed(
        'user123',
        operation: 'test',
      );
      expect(blocked, isFalse);

      rateLimiter.dispose();
    });

    test('should allow override of token cost', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
            costPerRequest: 1,
          ),
        },
      );

      // Request with custom cost of 5 tokens
      final allowed1 = await rateLimiter.isAllowed(
        'user123',
        operation: 'test',
        cost: 5,
      );
      expect(allowed1, isTrue);

      // Request with custom cost of 5 tokens
      final allowed2 = await rateLimiter.isAllowed(
        'user123',
        operation: 'test',
        cost: 5,
      );
      expect(allowed2, isTrue);

      // Next request should fail (10 tokens used)
      final blocked = await rateLimiter.isAllowed(
        'user123',
        operation: 'test',
        cost: 1,
      );
      expect(blocked, isFalse);

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Per-User Isolation', () {
    test('should track limits separately per user', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 2,
            windowSeconds: 60,
          ),
        },
      );

      // User 1 makes 2 requests
      await rateLimiter.isAllowed('user1', operation: 'test');
      await rateLimiter.isAllowed('user1', operation: 'test');

      // User 1 should be blocked
      final user1Blocked = await rateLimiter.isAllowed('user1', operation: 'test');
      expect(user1Blocked, isFalse);

      // User 2 should still have tokens
      final user2Allowed1 = await rateLimiter.isAllowed('user2', operation: 'test');
      expect(user2Allowed1, isTrue);

      final user2Allowed2 = await rateLimiter.isAllowed('user2', operation: 'test');
      expect(user2Allowed2, isTrue);

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Operation Isolation', () {
    test('should use default config for unknown operations', () async {
      final rateLimiter = RateLimiter();

      // Unknown operation should use default config (100 requests/minute)
      for (var i = 0; i < 100; i++) {
        final allowed = await rateLimiter.isAllowed(
          'user123',
          operation: 'unknown',
        );
        expect(allowed, isTrue);
      }

      // 101st request should fail
      final blocked = await rateLimiter.isAllowed(
        'user123',
        operation: 'unknown',
      );
      expect(blocked, isFalse);

      rateLimiter.dispose();
    });

    test('should use auth config', () async {
      final rateLimiter = RateLimiter();

      // Auth operation: 5 requests/minute
      for (var i = 0; i < 5; i++) {
        final allowed = await rateLimiter.isAllowed(
          'user123',
          operation: 'auth',
        );
        expect(allowed, isTrue);
      }

      // 6th auth request should fail
      final blocked = await rateLimiter.isAllowed(
        'user123',
        operation: 'auth',
      );
      expect(blocked, isFalse);

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Exponential Backoff', () {
    test('should increase retry time with violations', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 1,
            windowSeconds: 10,
          ),
        },
      );

      // Consume token
      await rateLimiter.isAllowed('user123', operation: 'test');

      // Get initial retry time
      final retryAfter1 = rateLimiter.getRetryAfter('user123', operation: 'test');

      // Violate rate limit multiple times
      for (var i = 0; i < 3; i++) {
        await rateLimiter.isAllowed('user123', operation: 'test');
      }

      // Retry time should be longer after violations
      final retryAfter2 = rateLimiter.getRetryAfter('user123', operation: 'test');

      // With 3 violations, backoff should be applied
      expect(retryAfter2.inSeconds, greaterThan(retryAfter1.inSeconds));

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Remaining Tokens', () {
    test('should return correct remaining tokens', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
          ),
        },
      );

      // Initial state: full capacity
      var remaining = rateLimiter.getRemainingTokens('user123', operation: 'test');
      expect(remaining, equals(10));

      // Consume 3 tokens
      for (var i = 0; i < 3; i++) {
        await rateLimiter.isAllowed('user123', operation: 'test');
      }

      // Should have 7 tokens left
      remaining = rateLimiter.getRemainingTokens('user123', operation: 'test');
      expect(remaining, equals(7));

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Retry After', () {
    test('should return zero duration when tokens available', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
          ),
        },
      );

      final retryAfter = rateLimiter.getRetryAfter('user123', operation: 'test');
      expect(retryAfter, equals(Duration.zero));

      rateLimiter.dispose();
    });

    test('should return positive duration when tokens depleted', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 2,
            windowSeconds: 10, // 0.2 tokens/second
          ),
        },
      );

      // Consume all tokens
      await rateLimiter.isAllowed('user123', operation: 'test');
      await rateLimiter.isAllowed('user123', operation: 'test');

      final retryAfter = rateLimiter.getRetryAfter('user123', operation: 'test');
      expect(retryAfter.inSeconds, greaterThan(0));

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Reset', () {
    test('should reset rate limit for user and operation', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 1,
            windowSeconds: 60,
          ),
        },
      );

      // Consume token
      await rateLimiter.isAllowed('user123', operation: 'test');

      // Should be blocked
      var blocked = await rateLimiter.isAllowed('user123', operation: 'test');
      expect(blocked, isFalse);

      // Reset
      rateLimiter.reset('user123', operation: 'test');

      // Should be allowed again
      final allowed = await rateLimiter.isAllowed('user123', operation: 'test');
      expect(allowed, isTrue);

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Statistics', () {
    test('should return accurate statistics', () async {
      final rateLimiter = RateLimiter(
        customConfigs: {
          'test': const RateLimitConfig(
            maxRequests: 10,
            windowSeconds: 60,
          ),
        },
      );

      // Create buckets for 3 users
      await rateLimiter.isAllowed('user1', operation: 'test');
      await rateLimiter.isAllowed('user2', operation: 'test');
      await rateLimiter.isAllowed('user3', operation: 'test');

      final stats = rateLimiter.getStats();
      expect(stats['totalBuckets'], equals(3));

      final bucketDetails = stats['bucketDetails'] as Map<String, int>;
      expect(bucketDetails.keys, hasLength(3));

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Cleanup', () {
    test('should clean up idle buckets', () async {
      final rateLimiter = RateLimiter(
        cleanupInterval: const Duration(milliseconds: 100),
        idleThreshold: const Duration(milliseconds: 50),
      );

      // Create a bucket
      await rateLimiter.isAllowed('user123', operation: 'test');

      // Verify bucket exists
      var stats = rateLimiter.getStats();
      expect(stats['totalBuckets'], equals(1));

      // Wait for cleanup
      await Future.delayed(const Duration(milliseconds: 200));

      // Bucket should be cleaned up
      stats = rateLimiter.getStats();
      expect(stats['totalBuckets'], equals(0));

      rateLimiter.dispose();
    });
  });

  group('RateLimiter - Clear All', () {
    test('should clear all rate limit data', () async {
      final rateLimiter = RateLimiter();

      // Create buckets for multiple users
      await rateLimiter.isAllowed('user1', operation: 'test');
      await rateLimiter.isAllowed('user2', operation: 'test');
      await rateLimiter.isAllowed('user3', operation: 'test');

      var stats = rateLimiter.getStats();
      expect(stats['totalBuckets'], equals(3));

      // Clear all
      rateLimiter.clearAll();

      stats = rateLimiter.getStats();
      expect(stats['totalBuckets'], equals(0));

      rateLimiter.dispose();
    });
  });

  group('IpRateLimiter', () {
    test('should use stricter limits for IP-based rate limiting', () async {
      final ipRateLimiter = IpRateLimiter();

      // Auth operation for IP: 10 requests per 5 minutes
      for (var i = 0; i < 10; i++) {
        final allowed = await ipRateLimiter.isAllowed(
          '192.168.1.1',
          operation: 'auth',
        );
        expect(allowed, isTrue);
      }

      // 11th request should fail
      final blocked = await ipRateLimiter.isAllowed(
        '192.168.1.1',
        operation: 'auth',
      );
      expect(blocked, isFalse);

      ipRateLimiter.dispose();
    });

    test('should track different IPs separately', () async {
      final ipRateLimiter = IpRateLimiter();

      // IP 1 makes requests
      for (var i = 0; i < 10; i++) {
        await ipRateLimiter.isAllowed('192.168.1.1', operation: 'auth');
      }

      // IP 1 should be blocked
      final ip1Blocked = await ipRateLimiter.isAllowed('192.168.1.1', operation: 'auth');
      expect(ip1Blocked, isFalse);

      // IP 2 should still have tokens
      final ip2Allowed = await ipRateLimiter.isAllowed('192.168.1.2', operation: 'auth');
      expect(ip2Allowed, isTrue);

      ipRateLimiter.dispose();
    });
  });

  group('RateLimitException', () {
    test('should format message correctly', () {
      const exception = RateLimitException(
        'Too many requests',
        retryAfter: Duration(seconds: 30),
        operation: 'auth',
      );

      expect(
        exception.toString(),
        contains('Too many requests'),
      );
      expect(
        exception.toString(),
        contains('30s'),
      );
    });

    test('should contain retry duration', () {
      const exception = RateLimitException(
        'Rate limit exceeded',
        retryAfter: Duration(minutes: 2),
        operation: 'api',
      );

      expect(exception.retryAfter.inMinutes, equals(2));
      expect(exception.operation, equals('api'));
    });
  });

  group('RateLimitConfig', () {
    test('should calculate correct refill rate', () {
      const config = RateLimitConfig(
        maxRequests: 100,
        windowSeconds: 60,
      );

      expect(config.refillRate, closeTo(1.666, 0.001)); // 100/60 ≈ 1.666 tokens/second
    });

    test('should use default cost per request', () {
      const config = RateLimitConfig(
        maxRequests: 100,
        windowSeconds: 60,
      );

      expect(config.costPerRequest, equals(1));
    });

    test('should allow custom cost per request', () {
      const config = RateLimitConfig(
        maxRequests: 50,
        windowSeconds: 60,
        costPerRequest: 3,
      );

      expect(config.costPerRequest, equals(3));
    });
  });
}
