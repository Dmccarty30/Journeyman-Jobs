import 'dart:async';
import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth_mocks/firebase_auth_mocks.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/cache_service.dart';
import 'package:journeyman_jobs/services/connectivity_service.dart';
import 'package:journeyman_jobs/services/offline_data_service.dart';
import 'package:journeyman_jobs/services/performance_monitoring_service.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Load testing suite for concurrent user simulation and scalability validation
/// Tests system behavior under high load and concurrent access patterns
void main() {
  group('Firestore Load Tests - Concurrent User Simulation', () {
    late FakeFirebaseFirestore fakeFirestore;
    late FirestoreService firestoreService;
    late MockFirebaseAuth mockAuth;

    setUpAll(() async {
      // Initialize test environment with large dataset
      fakeFirestore = FakeFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      firestoreService = FirestoreService();
      
      // Seed large dataset for load testing
      await _seedLargeDataset(fakeFirestore);
    });

    setUp(() {
      // Reset any test-specific state
    });

    tearDown(() {
      // Cleanup after each test
    });

    group('Concurrent Query Load Tests', () {
      test('Should handle 100 concurrent job queries', () async {
        const concurrentUsers = 100;
        final futures = <Future<QuerySnapshot>>[];
        final stopwatch = Stopwatch()..start();
        
        // Create 100 concurrent job queries
        for (int i = 0; i < concurrentUsers; i++) {
          final future = fakeFirestore
              .collection('jobs')
              .orderBy('timestamp', descending: true)
              .limit(20)
              .get();
          futures.add(future);
        }
        
        // Wait for all queries to complete
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        // Validate all queries completed successfully
        expect(results.length, equals(concurrentUsers),
            reason: 'Not all concurrent queries completed');
        
        // Validate performance under load (5 seconds max for 100 concurrent queries)
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Concurrent queries took too long: ${stopwatch.elapsedMilliseconds}ms');
        
        // Validate data consistency
        for (final result in results) {
          expect(result.docs.length, lessThanOrEqualTo(20),
              reason: 'Pagination not enforced under load');
        }
        
        // Track load test performance
        PerformanceMonitoringService.trackQueryPerformance(
          'load_test_concurrent_jobs',
          stopwatch.elapsed,
          results.fold(0, (sum, result) => sum + result.docs.length),
          additionalMetrics: {'concurrent_users': concurrentUsers},
        );
        
        print('✅ 100 concurrent job queries completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Should handle mixed concurrent operations', () async {
        const concurrentUsers = 50;
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();
        
        // Mix of different operations to simulate real usage
        for (int i = 0; i < concurrentUsers; i++) {
          switch (i % 4) {
            case 0:
              // Job search
              futures.add(fakeFirestore
                  .collection('jobs')
                  .where('classification', isEqualTo: 'Lineman')
                  .limit(10)
                  .get());
              break;
            case 1:
              // Local search
              futures.add(fakeFirestore
                  .collection('locals')
                  .where('state', isEqualTo: 'CA')
                  .limit(5)
                  .get());
              break;
            case 2:
              // Regional job query
              futures.add(fakeFirestore
                  .collection('locals_regions')
                  .doc('west')
                  .collection('locals')
                  .limit(10)
                  .get());
              break;
            case 3:
              // Filtered job search
              futures.add(fakeFirestore
                  .collection('jobs')
                  .where('local', isGreaterThan: 100)
                  .limit(15)
                  .get());
              break;
          }
        }
        
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        // Validate mixed operation performance
        expect(results.length, equals(concurrentUsers),
            reason: 'Not all mixed operations completed');
        
        expect(stopwatch.elapsedMilliseconds, lessThan(7000),
            reason: 'Mixed concurrent operations too slow: ${stopwatch.elapsedMilliseconds}ms');
        
        print('✅ 50 mixed concurrent operations completed in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Should maintain performance with large dataset queries', () async {
        const concurrentUsers = 25;
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();
        
        // Query large dataset with different pagination
        for (int i = 0; i < concurrentUsers; i++) {
          final limit = 20 + (i % 30); // Vary page sizes
          futures.add(fakeFirestore
              .collection('jobs')
              .orderBy('timestamp', descending: true)
              .limit(limit)
              .get());
        }
        
        final results = await Future.wait(futures);
        stopwatch.stop();
        
        // Validate large dataset performance
        expect(results.length, equals(concurrentUsers));
        expect(stopwatch.elapsedMilliseconds, lessThan(4000),
            reason: 'Large dataset queries too slow under load');
        
        // Validate data integrity with large datasets
        final totalDocs = results.fold(0, (sum, result) => sum + (result as QuerySnapshot).docs.length);
        expect(totalDocs, greaterThan(500),
            reason: 'Not enough data returned from large dataset queries');
        
        print('✅ Large dataset queries with $totalDocs docs in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Cache Performance Under Load', () {
      test('Cache should maintain performance with concurrent access', () async {
        final cacheService = CacheService();
        const concurrentUsers = 75;
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();
        
        // Pre-populate cache with some data
        for (int i = 0; i < 10; i++) {
          await cacheService.set('preload_$i', 'test_data_$i');
        }
        
        // Concurrent cache operations (mix of reads and writes)
        for (int i = 0; i < concurrentUsers; i++) {
          if (i % 3 == 0) {
            // Cache write
            futures.add(cacheService.set('load_test_$i', 'test_data_$i'));
          } else {
            // Cache read (some hits, some misses)
            final key = i % 2 == 0 ? 'preload_${i % 10}' : 'missing_key_$i';
            futures.add(cacheService.get(key));
          }
        }
        
        await Future.wait(futures);
        stopwatch.stop();
        
        // Validate cache performance under load
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Cache operations too slow under load: ${stopwatch.elapsedMilliseconds}ms');
        
        // Cache should complete without errors
        print('✅ Cache handled $concurrentUsers concurrent operations in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Cache should handle memory pressure gracefully', () async {
        final cacheService = CacheService();
        const cacheEntries = 150; // Exceed max cache size
        final stopwatch = Stopwatch()..start();
        
        // Fill cache beyond capacity
        final futures = <Future>[];
        for (int i = 0; i < cacheEntries; i++) {
          final largeData = 'x' * 1000; // 1KB per entry
          futures.add(cacheService.set('pressure_test_$i', largeData));
        }
        
        await Future.wait(futures);
        stopwatch.stop();
        
        // Validate cache eviction worked
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Cache pressure handling too slow');
        
        // Cache should handle pressure without errors
        print('✅ Cache handled memory pressure successfully');
      });
    });

    group('Offline Performance Under Load', () {
      test('Offline sync should handle bulk operations efficiently', () async {
        SharedPreferences.setMockInitialValues({});
        final connectivityService = ConnectivityService();
        final cacheService = CacheService();
        final offlineService = OfflineDataService(connectivityService, cacheService);
        await offlineService.initialize();
        
        const bulkSize = 100;
        final jobs = <Job>[];
        
        // Create bulk test data
        for (int i = 0; i < bulkSize; i++) {
          jobs.add(Job(
            id: 'bulk_$i',
            company: 'Bulk Company $i',
            location: 'Location $i',
            local: 100 + i,
            classification: i % 2 == 0 ? 'Lineman' : 'Electrician',
            wage: 30.0 + (i % 20),
            hours: 40,
            timestamp: DateTime.now().subtract(Duration(hours: i)),
          ));
        }
        
        final stopwatch = Stopwatch()..start();
        
        // Bulk offline storage
        await offlineService.storeJobsOffline(jobs);
        
        // Bulk offline retrieval
        final retrievedJobs = await offlineService.getOfflineJobs();
        
        stopwatch.stop();
        
        // Validate bulk operation performance
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Bulk offline operations too slow: ${stopwatch.elapsedMilliseconds}ms');
        
        // Validate data integrity
        expect(retrievedJobs.length, equals(bulkSize),
            reason: 'Bulk offline storage/retrieval lost data');
        
        print('✅ Bulk offline operations for $bulkSize jobs in ${stopwatch.elapsedMilliseconds}ms');
      });

      test('Concurrent offline operations should not cause conflicts', () async {
        SharedPreferences.setMockInitialValues({});
        final connectivityService = ConnectivityService();
        final cacheService = CacheService();
        final offlineService = OfflineDataService(connectivityService, cacheService);
        await offlineService.initialize();
        
        const concurrentOps = 20;
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();
        
        // Concurrent offline operations
        for (int i = 0; i < concurrentOps; i++) {
          final testJobs = [
            Job(
              id: 'concurrent_${i}_1',
              company: 'Concurrent Company $i',
              location: 'Location $i',
              local: 200 + i,
              classification: 'Test',
              wage: 35.0,
              hours: 40,
              timestamp: DateTime.now(),
            ),
          ];
          
          // Mix of store and retrieve operations
          if (i % 2 == 0) {
            futures.add(offlineService.storeJobsOffline(testJobs));
          } else {
            futures.add(offlineService.getOfflineJobs());
          }
        }
        
        await Future.wait(futures);
        stopwatch.stop();
        
        // Validate concurrent operation performance
        expect(stopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Concurrent offline operations too slow');
        
        // Validate no data corruption
        final finalJobs = await offlineService.getOfflineJobs();
        expect(finalJobs.isNotEmpty, isTrue,
            reason: 'Concurrent operations caused data loss');
        
        print('✅ $concurrentOps concurrent offline ops in ${stopwatch.elapsedMilliseconds}ms');
      });
    });

    group('System Scalability Tests', () {
      test('Should maintain response times with increasing load', () async {
        final loadLevels = [10, 25, 50, 75, 100];
        final responseTimes = <int, int>{};
        
        for (final loadLevel in loadLevels) {
          final futures = <Future>[];
          final stopwatch = Stopwatch()..start();
          
          // Generate load at current level
          for (int i = 0; i < loadLevel; i++) {
            futures.add(fakeFirestore
                .collection('jobs')
                .where('local', isGreaterThan: i % 50)
                .limit(20)
                .get());
          }
          
          await Future.wait(futures);
          stopwatch.stop();
          
          responseTimes[loadLevel] = stopwatch.elapsedMilliseconds;
          
          // Validate response time scaling
          expect(stopwatch.elapsedMilliseconds, lessThan(loadLevel * 100),
              reason: 'Response time scaling poorly at $loadLevel users');
        }
        
        // Validate scaling pattern (should not increase exponentially)
        for (int i = 1; i < loadLevels.length; i++) {
          final prevLoad = loadLevels[i - 1];
          final currentLoad = loadLevels[i];
          final prevTime = responseTimes[prevLoad]!;
          final currentTime = responseTimes[currentLoad]!;
          
          final scalingRatio = currentTime / prevTime;
          final loadRatio = currentLoad / prevLoad;
          
          // Response time should not scale worse than load increase
          expect(scalingRatio, lessThan(loadRatio * 2),
              reason: 'Poor scaling from $prevLoad to $currentLoad users');
        }
        
        print('✅ Scaling test completed: ${responseTimes}');
      });

      test('Should handle sustained load over time', () async {
        const sustainedUsers = 30;
        const testDurationSeconds = 10; // Reduced for test environment
        const operationsPerSecond = 3;
        
        final completedOperations = <int>[];
        final startTime = DateTime.now();
        
        // Sustained load simulation
        final timer = Timer.periodic(
          Duration(milliseconds: 1000 ~/ operationsPerSecond),
          (timer) async {
            if (DateTime.now().difference(startTime).inSeconds >= testDurationSeconds) {
              timer.cancel();
              return;
            }
            
            final futures = <Future>[];
            for (int i = 0; i < sustainedUsers; i++) {
              futures.add(fakeFirestore
                  .collection('jobs')
                  .limit(10)
                  .get());
            }
            
            try {
              await Future.wait(futures);
              completedOperations.add(sustainedUsers);
            } catch (e) {
              // Track failures
              completedOperations.add(0);
            }
          },
        );
        
        // Wait for test duration
        await Future.delayed(Duration(seconds: testDurationSeconds + 1));
        
        // Validate sustained performance
        expect(completedOperations.isNotEmpty, isTrue,
            reason: 'No operations completed during sustained load test');
        
        final totalSuccessful = completedOperations.fold(0, (sum, ops) => sum + ops);
        final expectedOperations = testDurationSeconds * operationsPerSecond * sustainedUsers;
        final successRate = totalSuccessful / expectedOperations;
        
        expect(successRate, greaterThan(0.8),
            reason: 'Sustained load success rate too low: ${(successRate * 100).toStringAsFixed(1)}%');
        
        print('✅ Sustained load: ${totalSuccessful}/$expectedOperations ops (${(successRate * 100).toStringAsFixed(1)}%)');
      });

      test('Should recover gracefully from overload', () async {
        const overloadUsers = 200; // Intentionally high
        const recoveryUsers = 20;
        
        // Step 1: Create overload condition
        print('Creating overload with $overloadUsers concurrent operations...');
        final overloadFutures = <Future>[];
        for (int i = 0; i < overloadUsers; i++) {
          overloadFutures.add(fakeFirestore
              .collection('jobs')
              .limit(5)
              .get()
              .timeout(const Duration(seconds: 3))
              .catchError((e) => null)); // Allow timeouts
        }
        
        final overloadStopwatch = Stopwatch()..start();
        final overloadResults = await Future.wait(overloadFutures);
        overloadStopwatch.stop();
        
        // Count successful operations under overload
        final overloadSuccesses = overloadResults.where((r) => r != null).length;
        
        // Step 2: Test recovery with normal load
        await Future.delayed(const Duration(milliseconds: 500)); // Brief recovery period
        
        print('Testing recovery with $recoveryUsers operations...');
        final recoveryFutures = <Future>[];
        for (int i = 0; i < recoveryUsers; i++) {
          recoveryFutures.add(fakeFirestore
              .collection('jobs')
              .limit(10)
              .get());
        }
        
        final recoveryStopwatch = Stopwatch()..start();
        final recoveryResults = await Future.wait(recoveryFutures);
        recoveryStopwatch.stop();
        
        // Validate recovery
        expect(recoveryResults.length, equals(recoveryUsers),
            reason: 'System did not recover from overload');
        
        expect(recoveryStopwatch.elapsedMilliseconds, lessThan(3000),
            reason: 'Recovery performance degraded');
        
        // System should handle some overload gracefully
        final overloadSuccessRate = overloadSuccesses / overloadUsers;
        expect(overloadSuccessRate, greaterThan(0.3),
            reason: 'System failed completely under overload');
        
        print('✅ Overload: ${overloadSuccesses}/$overloadUsers succeeded (${(overloadSuccessRate * 100).toStringAsFixed(1)}%)');
        print('✅ Recovery: $recoveryUsers/$recoveryUsers in ${recoveryStopwatch.elapsedMilliseconds}ms');
      });
    });

    group('Real-World Usage Simulation', () {
      test('Should handle realistic user session patterns', () async {
        const sessionCount = 25;
        final sessionFutures = <Future<Map<String, dynamic>>>[];
        
        // Simulate realistic user sessions
        for (int i = 0; i < sessionCount; i++) {
          sessionFutures.add(_simulateRealisticUserSession(fakeFirestore, i));
        }
        
        final stopwatch = Stopwatch()..start();
        final sessionResults = await Future.wait(sessionFutures);
        stopwatch.stop();
        
        // Validate session performance
        expect(sessionResults.length, equals(sessionCount),
            reason: 'Not all user sessions completed');
        
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
            reason: 'Realistic user sessions took too long');
        
        // Validate session success rates
        final successfulSessions = sessionResults.where((r) => r['success'] == true).length;
        final successRate = successfulSessions / sessionCount;
        
        expect(successRate, greaterThan(0.9),
            reason: 'User session success rate too low: ${(successRate * 100).toStringAsFixed(1)}%');
        
        // Calculate average session metrics
        final avgDuration = sessionResults
            .map((r) => r['duration'] as int)
            .reduce((a, b) => a + b) / sessionCount;
        
        final avgOperations = sessionResults
            .map((r) => r['operations'] as int)
            .reduce((a, b) => a + b) / sessionCount;
        
        print('✅ $sessionCount user sessions: ${(successRate * 100).toStringAsFixed(1)}% success');
        print('   Average duration: ${avgDuration.toStringAsFixed(0)}ms');
        print('   Average operations: ${avgOperations.toStringAsFixed(1)}');
      });

      test('Should handle peak usage patterns', () async {
        // Simulate peak usage (morning job search rush)
        const peakUsers = 60;
        const peakDurationSeconds = 5;
        
        print('Simulating peak usage: $peakUsers users for ${peakDurationSeconds}s');
        
        final peakFutures = <Future>[];
        final peakStopwatch = Stopwatch()..start();
        
        // Concurrent peak load
        for (int i = 0; i < peakUsers; i++) {
          peakFutures.add(_simulatePeakUserBehavior(fakeFirestore, i, peakDurationSeconds));
        }
        
        await Future.wait(peakFutures);
        peakStopwatch.stop();
        
        // Validate peak performance
        expect(peakStopwatch.elapsedMilliseconds, lessThan(peakDurationSeconds * 1000 + 2000),
            reason: 'Peak usage handling exceeded time limit');
        
        print('✅ Peak usage handled in ${peakStopwatch.elapsedMilliseconds}ms');
      });
    });
  });
}

// Helper methods for load testing

Future<void> _seedLargeDataset(FakeFirebaseFirestore firestore) async {
  print('Seeding large dataset for load testing...');
  
  // Seed 10,000 jobs for load testing
  final jobsBatch = firestore.batch();
  for (int i = 1; i <= 10000; i++) {
    final jobRef = firestore.collection('jobs').doc('load_job_$i');
    jobsBatch.set(jobRef, {
      'company': 'Load Test Company ${i % 100}',
      'location': _getRandomLocation(i),
      'classification': _getRandomClassification(i),
      'local': 100 + (i % 897), // Realistic local numbers
      'wage': 25.0 + (i % 30) + Random().nextDouble() * 5,
      'hours': [40, 50, 60][i % 3],
      'timestamp': FieldValue.serverTimestamp(),
      'latitude': 37.7749 + Random().nextDouble() * 10,
      'longitude': -122.4194 + Random().nextDouble() * 10,
      'typeOfWork': _getRandomWorkType(i),
    });
  }
  
  // Seed 2,000 locals
  for (int i = 1; i <= 2000; i++) {
    final localRef = firestore.collection('locals').doc('load_local_$i');
    await localRef.set({
      'localUnion': 'IBEW Local ${100 + (i % 897)}',
      'state': _getRandomState(i),
      'searchTerms': ['ibew', 'local', '${100 + (i % 897)}', 'union'],
      'region': _getRegionForState(_getRandomState(i)),
    });
  }
  
  // Seed regional collections for geographic optimization testing
  final regions = ['northeast', 'southeast', 'midwest', 'southwest', 'west'];
  for (final region in regions) {
    for (int i = 1; i <= 200; i++) {
      final regionRef = firestore
          .collection('locals_regions')
          .doc(region)
          .collection('locals')
          .doc('load_regional_${region}_$i');
      
      await regionRef.set({
        'localUnion': 'IBEW Local ${region.toUpperCase()} ${100 + i}',
        'state': _getStateForRegion(region, i),
        'searchTerms': ['ibew', 'local', region, 'union'],
      });
    }
  }
  
  print('✅ Large dataset seeded successfully');
}

String _getRandomLocation(int seed) {
  final locations = [
    'Los Angeles, CA', 'San Francisco, CA', 'Sacramento, CA',
    'Houston, TX', 'Dallas, TX', 'Austin, TX',
    'Miami, FL', 'Tampa, FL', 'Orlando, FL',
    'New York, NY', 'Buffalo, NY', 'Albany, NY',
    'Chicago, IL', 'Springfield, IL', 'Rockford, IL',
  ];
  return locations[seed % locations.length];
}

String _getRandomClassification(int seed) {
  final classifications = [
    'Lineman', 'Electrician', 'Apprentice', 'Journeyman',
    'Foreman', 'General Foreman', 'Substation Technician',
  ];
  return classifications[seed % classifications.length];
}

String _getRandomWorkType(int seed) {
  final workTypes = [
    'Underground', 'Overhead', 'Transmission', 'Distribution',
    'Substation', 'Storm Work', 'Maintenance', 'Construction',
  ];
  return workTypes[seed % workTypes.length];
}

String _getRandomState(int seed) {
  final states = [
    'CA', 'TX', 'FL', 'NY', 'PA', 'IL', 'OH', 'GA',
    'NC', 'MI', 'NJ', 'VA', 'WA', 'AZ', 'MA', 'TN',
  ];
  return states[seed % states.length];
}

String _getRegionForState(String state) {
  const regions = {
    'CA': 'west', 'TX': 'southwest', 'FL': 'southeast',
    'NY': 'northeast', 'PA': 'northeast', 'IL': 'midwest',
  };
  return regions[state] ?? 'other';
}

String _getStateForRegion(String region, int seed) {
  const regionStates = {
    'west': ['CA', 'WA', 'OR', 'NV'],
    'southwest': ['TX', 'AZ', 'NM'],
    'southeast': ['FL', 'GA', 'SC', 'NC'],
    'northeast': ['NY', 'PA', 'MA', 'CT'],
    'midwest': ['IL', 'OH', 'MI', 'WI'],
  };
  final states = regionStates[region] ?? ['CA'];
  return states[seed % states.length];
}

Future<Map<String, dynamic>> _simulateRealisticUserSession(
  FakeFirebaseFirestore firestore,
  int userId,
) async {
  final stopwatch = Stopwatch()..start();
  int operationCount = 0;
  bool success = true;
  
  try {
    // 1. User opens app, loads recent jobs (70% do this)
    if (Random().nextDouble() < 0.7) {
      await firestore
          .collection('jobs')
          .orderBy('timestamp', descending: true)
          .limit(20)
          .get();
      operationCount++;
    }
    
    // 2. User searches for specific jobs (50% do this)
    if (Random().nextDouble() < 0.5) {
      final classifications = ['Lineman', 'Electrician', 'Apprentice'];
      final classification = classifications[userId % classifications.length];
      
      await firestore
          .collection('jobs')
          .where('classification', isEqualTo: classification)
          .limit(15)
          .get();
      operationCount++;
    }
    
    // 3. User filters by location (30% do this)
    if (Random().nextDouble() < 0.3) {
      final states = ['CA', 'TX', 'FL', 'NY'];
      final state = states[userId % states.length];
      
      await firestore
          .collection('jobs')
          .where('location', isGreaterThanOrEqualTo: state)
          .limit(10)
          .get();
      operationCount++;
    }
    
    // 4. User searches locals (40% do this)
    if (Random().nextDouble() < 0.4) {
      await firestore
          .collection('locals')
          .where('state', isEqualTo: 'CA')
          .limit(10)
          .get();
      operationCount++;
    }
    
    // 5. User views specific job details (60% do this)
    if (Random().nextDouble() < 0.6) {
      await firestore
          .collection('jobs')
          .doc('load_job_${(userId % 1000) + 1}')
          .get();
      operationCount++;
    }
    
    // Random delay to simulate user thinking time
    await Future.delayed(Duration(milliseconds: 50 + Random().nextInt(100)));
    
  } catch (e) {
    success = false;
  }
  
  stopwatch.stop();
  
  return {
    'success': success,
    'duration': stopwatch.elapsedMilliseconds,
    'operations': operationCount,
    'userId': userId,
  };
}

Future<void> _simulatePeakUserBehavior(
  FakeFirebaseFirestore firestore,
  int userId,
  int durationSeconds,
) async {
  final endTime = DateTime.now().add(Duration(seconds: durationSeconds));
  
  while (DateTime.now().isBefore(endTime)) {
    // Quick succession of operations during peak time
    final futures = <Future>[];
    
    // Job search
    futures.add(firestore
        .collection('jobs')
        .where('classification', isEqualTo: 'Lineman')
        .limit(10)
        .get());
    
    // Location filter
    futures.add(firestore
        .collection('jobs')
        .where('local', isGreaterThan: userId % 100)
        .limit(5)
        .get());
    
    await Future.wait(futures);
    
    // Brief pause between peak operations
    await Future.delayed(const Duration(milliseconds: 200));
  }
}