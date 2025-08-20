import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:journeyman_jobs/services/cache_service.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

// Generate mocks
@GenerateMocks([SharedPreferences])
import 'cache_service_test.mocks.dart';

void main() {
  late CacheService cacheService;
  late MockSharedPreferences mockSharedPreferences;

  setUp(() {
    mockSharedPreferences = MockSharedPreferences();
    cacheService = CacheService();
    
    // Reset cache between tests
    cacheService.clearMemoryCache();
  });

  group('CacheService - Memory Cache Operations', () {
    test('should store and retrieve data from memory cache', () async {
      // Arrange
      const key = 'test-key';
      final testData = MockData.createJob();

      // Act
      await cacheService.setMemoryCache(key, testData.toJson());
      final result = await cacheService.getMemoryCache(key);

      // Assert
      expect(result, isNotNull);
      expect(result, equals(testData.toJson()));
    });

    test('should return null for non-existent cache key', () async {
      // Act
      final result = await cacheService.getMemoryCache('non-existent-key');

      // Assert
      expect(result, isNull);
    });

    test('should handle cache expiration', () async {
      // Arrange
      const key = 'expiring-key';
      final testData = {'test': 'data'};
      const shortTtl = Duration(milliseconds: 100);

      // Act
      await cacheService.setMemoryCache(key, testData, ttl: shortTtl);
      
      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 150));
      
      final result = await cacheService.getMemoryCache(key);

      // Assert
      expect(result, isNull);
    });

    test('should update LRU order on cache access', () async {
      // Arrange
      const key1 = 'key1';
      const key2 = 'key2';
      final data1 = {'data': '1'};
      final data2 = {'data': '2'};

      // Act
      await cacheService.setMemoryCache(key1, data1);
      await cacheService.setMemoryCache(key2, data2);
      
      // Access key1 to make it most recently used
      await cacheService.getMemoryCache(key1);

      // Assert - Both should still be cached
      expect(await cacheService.getMemoryCache(key1), equals(data1));
      expect(await cacheService.getMemoryCache(key2), equals(data2));
    });

    test('should evict least recently used items when cache is full', () async {
      // Arrange - Fill cache beyond limit
      final entries = <String, Map<String, dynamic>>{};
      for (int i = 0; i < CacheService.maxMemoryEntries + 10; i++) {
        entries['key$i'] = {'data': 'value$i'};
      }

      // Act
      for (final entry in entries.entries) {
        await cacheService.setMemoryCache(entry.key, entry.value);
      }

      // Assert - Should not exceed max entries
      final stats = cacheService.getCacheStats();
      expect(stats['memorySize'], lessThanOrEqualTo(CacheService.maxMemoryEntries));
      expect(stats['evictionCount'], greaterThan(0));
    });
  });

  group('CacheService - Persistent Cache Operations', () {
    test('should store and retrieve data from persistent cache', () async {
      // Arrange
      const key = 'persistent-key';
      final testData = MockData.createUser().toJson();
      final encodedData = json.encode(testData);
      
      when(mockSharedPreferences.setString(any, any))
          .thenAnswer((_) async => true);
      when(mockSharedPreferences.getString(key))
          .thenReturn(encodedData);

      // Act
      await cacheService.setPersistentCache(key, testData);
      final result = await cacheService.getPersistentCache(key);

      // Assert
      expect(result, isNotNull);
      expect(result, equals(testData));
      verify(mockSharedPreferences.setString(key, encodedData)).called(1);
    });

    test('should handle persistent cache miss', () async {
      // Arrange
      const key = 'missing-key';
      when(mockSharedPreferences.getString(key)).thenReturn(null);

      // Act
      final result = await cacheService.getPersistentCache(key);

      // Assert
      expect(result, isNull);
    });

    test('should handle malformed JSON in persistent cache', () async {
      // Arrange
      const key = 'malformed-key';
      when(mockSharedPreferences.getString(key))
          .thenReturn('invalid-json{');

      // Act & Assert
      expect(
        () => cacheService.getPersistentCache(key),
        throwsA(isA<FormatException>()),
      );
    });

    test('should remove expired persistent cache entries', () async {
      // Arrange
      const key = 'expired-key';
      final expiredEntry = {
        'data': {'test': 'data'},
        'expiry': DateTime.now().subtract(const Duration(hours: 1)).toIso8601String(),
      };
      
      when(mockSharedPreferences.getString(key))
          .thenReturn(json.encode(expiredEntry));
      when(mockSharedPreferences.remove(key))
          .thenAnswer((_) async => true);

      // Act
      final result = await cacheService.getPersistentCache(key);

      // Assert
      expect(result, isNull);
      verify(mockSharedPreferences.remove(key)).called(1);
    });
  });

  group('CacheService - IBEW Specific Caching', () {
    test('should cache IBEW local data with appropriate TTL', () async {
      // Arrange
      final localData = MockData.createLocal().toJson();
      const key = 'local-123';

      // Act
      await cacheService.cacheLocalData(key, localData);
      final result = await cacheService.getLocalData(key);

      // Assert
      expect(result, isNotNull);
      expect(result, equals(localData));
    });

    test('should cache job data with shorter TTL', () async {
      // Arrange
      final jobData = MockData.createJob().toJson();
      const key = 'job-456';

      // Act
      await cacheService.cacheJobData(key, jobData);
      final result = await cacheService.getJobData(key);

      // Assert
      expect(result, isNotNull);
      expect(result, equals(jobData));
    });

    test('should cache user preference data', () async {
      // Arrange
      final userPrefs = {
        'classifications': MockData.electricalClassifications.take(2).toList(),
        'maxDistance': 50,
        'minWage': 35.0,
        'availableForStormWork': true,
      };
      const userId = TestConstants.testUserId;

      // Act
      await cacheService.cacheUserPreferences(userId, userPrefs);
      final result = await cacheService.getUserPreferences(userId);

      // Assert
      expect(result, isNotNull);
      expect(result!['availableForStormWork'], isTrue);
      expect(result['classifications'], contains('Inside Wireman'));
    });

    test('should handle large IBEW local directory caching', () async {
      // Arrange
      final largeDirectory = MockData.createLocalsList(count: 100);
      const key = 'ibew-directory';
      final directoryJson = largeDirectory.map((l) => l.toJson()).toList();

      // Act
      await cacheService.setMemoryCache(key, directoryJson);
      final result = await cacheService.getMemoryCache(key);

      // Assert
      expect(result, isNotNull);
      expect(result, hasLength(100));
    });

    test('should cache storm work job data separately', () async {
      // Arrange
      final stormJob = MockData.createJob(
        constructionType: 'Storm Work',
        wage: 55.0, // Premium storm work rate
      );
      const key = 'storm-job-789';

      // Act
      await cacheService.cacheJobData(key, stormJob.toJson());
      final result = await cacheService.getJobData(key);

      // Assert
      expect(result, isNotNull);
      expect(result!['typeOfWork'], equals('Storm Work'));
      expect(result['wage'], equals(55.0));
    });
  });

  group('CacheService - Performance and Statistics', () {
    test('should track cache hit and miss statistics', () async {
      // Arrange
      const key = 'stats-test';
      final testData = {'test': 'data'};

      // Act
      await cacheService.setMemoryCache(key, testData);
      await cacheService.getMemoryCache(key); // Hit
      await cacheService.getMemoryCache('non-existent'); // Miss

      // Assert
      final stats = cacheService.getCacheStats();
      expect(stats['hitCount'], greaterThan(0));
      expect(stats['missCount'], greaterThan(0));
      expect(stats['hitRate'], isA<double>());
    });

    test('should provide cache size information', () async {
      // Arrange
      for (int i = 0; i < 5; i++) {
        await cacheService.setMemoryCache('key$i', {'data': i});
      }

      // Act
      final stats = cacheService.getCacheStats();

      // Assert
      expect(stats['memorySize'], equals(5));
      expect(stats['maxMemoryEntries'], equals(CacheService.maxMemoryEntries));
    });

    test('should track cleanup operations', () async {
      // Arrange
      final expiredData = {'test': 'data'};
      await cacheService.setMemoryCache(
        'expired-key',
        expiredData,
        ttl: const Duration(milliseconds: 50),
      );

      // Act
      await Future.delayed(const Duration(milliseconds: 100));
      await cacheService.cleanupExpiredEntries();

      // Assert
      final stats = cacheService.getCacheStats();
      expect(stats['lastCleanup'], isNotNull);
    });

    test('should handle cache warming for frequently accessed data', () async {
      // Arrange
      final localsList = MockData.createLocalsList(count: 20);
      final localsJson = localsList.map((l) => l.toJson()).toList();

      // Act - Warm cache with IBEW locals
      await cacheService.warmCache('ibew-locals', localsJson);
      final result = await cacheService.getMemoryCache('ibew-locals');

      // Assert
      expect(result, isNotNull);
      expect(result, hasLength(20));
    });
  });

  group('CacheService - Error Handling and Edge Cases', () {
    test('should handle cache clearing operations', () async {
      // Arrange
      await cacheService.setMemoryCache('key1', {'data': '1'});
      await cacheService.setMemoryCache('key2', {'data': '2'});

      // Act
      cacheService.clearMemoryCache();

      // Assert
      expect(await cacheService.getMemoryCache('key1'), isNull);
      expect(await cacheService.getMemoryCache('key2'), isNull);
      
      final stats = cacheService.getCacheStats();
      expect(stats['memorySize'], equals(0));
    });

    test('should handle null data gracefully', () async {
      // Act & Assert
      expect(
        () => cacheService.setMemoryCache('null-key', null),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle empty string keys', () async {
      // Act & Assert
      expect(
        () => cacheService.setMemoryCache('', {'data': 'test'}),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('should handle concurrent cache operations', () async {
      // Arrange
      final futures = <Future>[];
      
      // Act - Multiple concurrent cache operations
      for (int i = 0; i < 10; i++) {
        futures.add(cacheService.setMemoryCache('concurrent-$i', {'data': i}));
      }
      
      await Future.wait(futures);

      // Assert - All operations should complete successfully
      for (int i = 0; i < 10; i++) {
        final result = await cacheService.getMemoryCache('concurrent-$i');
        expect(result, isNotNull);
        expect(result!['data'], equals(i));
      }
    });
  });

  group('CacheService - TTL Configuration', () {
    test('should use appropriate TTL for different data types', () {
      expect(CacheService.defaultTtl, equals(const Duration(minutes: 30)));
      expect(CacheService.userDataTtl, equals(const Duration(hours: 2)));
      expect(CacheService.localsTtl, equals(const Duration(days: 1)));
      expect(CacheService.jobsTtl, equals(const Duration(minutes: 15)));
    });

    test('should respect custom TTL values', () async {
      // Arrange
      const key = 'custom-ttl';
      final data = {'test': 'data'};
      const customTtl = Duration(seconds: 1);

      // Act
      await cacheService.setMemoryCache(key, data, ttl: customTtl);
      
      // Immediate access should work
      expect(await cacheService.getMemoryCache(key), isNotNull);
      
      // Wait for expiration
      await Future.delayed(const Duration(milliseconds: 1100));
      
      // Should be expired
      expect(await cacheService.getMemoryCache(key), isNull);
    });
  });
}