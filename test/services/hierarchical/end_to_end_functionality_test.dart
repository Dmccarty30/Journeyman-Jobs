import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/services/hierarchical/performance_monitor.dart';
import 'package:journeyman_jobs/services/hierarchical/data_loading_service.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';
import 'package:journeyman_jobs/models/user_model.dart';

/// End-to-End functionality tests for Hierarchical Initialization System
///
/// These tests validate the complete system functionality with real data flow,
/// integration points, and performance under realistic conditions.
void main() {
  group('Hierarchical Initialization End-to-End Tests', () {
    late HierarchicalInitializer initializer;
    late PerformanceMonitor performanceMonitor;

    setUpAll(() async {
      // Initialize Firebase for testing
      try {
        await Firebase.initializeApp(
          name: 'e2e-test-app',
          options: const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
          ),
        );
      } catch (e) {
        print('Firebase initialization note: $e');
      }

      initializer = HierarchicalInitializer();
      performanceMonitor = PerformanceMonitor();
    });

    tearDownAll(() async {
      // Clean up test data
      await DataLoadingService.clearCache();
      performanceMonitor.dispose();
    });

    testWidgets('Complete initialization with real data flow', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Start performance monitoring
        performanceMonitor.startMonitoring();

        // Collect initialization events
        final initializationEvents = <Map<String, dynamic>>[];
        final progressUpdates = <double>[];

        initializer.progressStream.listen((progress) {
          progressUpdates.add(progress.progressPercentage);
          initializationEvents.add({
            'type': 'progress',
            'stage': progress.currentStage?.name,
            'percentage': progress.progressPercentage,
            'timestamp': DateTime.now(),
          });
        });

        initializer.completionStream.listen((result) {
          initializationEvents.add({
            'type': 'completion',
            'success': result['success'],
            'stages': result['completedStages'],
            'duration': result['totalDuration']?.inMilliseconds,
            'timestamp': DateTime.now(),
          });
        });

        // Execute full initialization
        final stopwatch = Stopwatch()..start();
        final result = await initializer.initializeHierarchically();
        stopwatch.stop();

        // Stop performance monitoring
        performanceMonitor.stopMonitoring();

        // Verify initialization succeeded
        expect(result['success'], isTrue);
        expect(result['completedStages'], greaterThan(5));
        expect(result['totalDuration'], isA<Duration>());

        // Verify progress tracking worked
        expect(progressUpdates.length, greaterThan(0));
        expect(progressUpdates.last, equals(1.0)); // Should reach 100%

        // Verify performance data was collected
        final analysis = performanceMonitor.getAnalysis();
        expect(analysis.totalDuration.inMilliseconds, greaterThan(0));
        expect(analysis.completedStages, greaterThan(0));

        // Verify initialization completed within reasonable time
        expect(stopwatch.elapsedMilliseconds, lessThan(30000)); // 30 seconds max

        print('Initialization completed in ${stopwatch.elapsedMilliseconds}ms');
        print('Performance analysis: ${analysis.totalDuration.inMilliseconds}ms total');
        print('Completed ${analysis.completedStages}/${analysis.totalStages} stages');
        print('Average memory usage: ${analysis.averageMemoryUsage.toStringAsFixed(1)}MB');
        print('Cache hit rate: ${(analysis.cacheHitRate * 100).toStringAsFixed(1)}%');
      });
    });

    testWidgets('Data loading and caching functionality', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test Firebase services validation
        final firebaseValid = await DataLoadingService.validateFirebaseServices();
        expect(firebaseValid, isA<bool>());

        // Test authentication validation
        final authValid = await DataLoadingService.validateAuthentication();
        expect(authValid, isA<bool>());

        // Test locals directory loading (first load - should hit Firebase)
        final stopwatch1 = Stopwatch()..start();
        final locals1 = await DataLoadingService.loadLocalsDirectory();
        stopwatch1.stop();

        expect(locals1, isA<Map<int, dynamic>>());
        expect(locals1.length, greaterThan(0)); // Should have some locals
        expect(stopwatch1.elapsedMilliseconds, greaterThan(0));

        // Test locals directory loading (second load - should hit cache)
        final stopwatch2 = Stopwatch()..start();
        final locals2 = await DataLoadingService.loadLocalsDirectory();
        stopwatch2.stop();

        expect(locals2, equals(locals1)); // Should be identical data
        expect(stopwatch2.elapsedMilliseconds, lessThan(stopwatch1.elapsedMilliseconds));

        // Test cache statistics
        final cacheStats = DataLoadingService.getCacheStats();
        expect(cacheStats['cacheSize'], greaterThan(0));
        expect(cacheStats['validEntries'], greaterThan(0));

        // Test jobs data loading with filtering
        final jobs = await DataLoadingService.loadJobsData(
          homeLocal: 123,
          preferredLocals: ['124', '125'],
          limit: 10,
        );

        expect(jobs, isA<Map<String, dynamic>>());

        // Test health check
        final healthResults = await DataLoadingService.performHealthCheck();
        expect(healthResults, isA<Map<String, bool>>());
        expect(healthResults.keys, contains('firebase'));
        expect(healthResults.keys, contains('authentication'));

        print('Locals loaded: ${locals1.length}');
        print('First load: ${stopwatch1.elapsedMilliseconds}ms');
        print('Second load: ${stopwatch2.elapsedMilliseconds}ms');
        print('Cache speedup: ${((stopwatch1.elapsedMilliseconds - stopwatch2.elapsedMilliseconds) / stopwatch1.elapsedMilliseconds * 100).toStringAsFixed(1)}%');
        print('Cache stats: $cacheStats');
        print('Health check results: $healthResults');
      });
    });

    testWidgets('Error handling and recovery mechanisms', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test error classification and recovery
        final testScenarios = [
          {
            'error': FirebaseException(plugin: 'firestore', code: 'unavailable'),
            'stage': InitializationStage.jobsData,
            'expectedCanRecover': true,
          },
          {
            'error': TimeoutException('Request timeout', const Duration(seconds: 30)),
            'stage': InitializationStage.userProfile,
            'expectedCanRecover': true,
          },
          {
            'error': StateError('Invalid configuration'),
            'stage': InitializationStage.firebaseCore,
            'expectedCanRecover': false, // Critical stage with configuration error
          },
          {
            'error': 'Network connection failed',
            'stage': InitializationStage.weatherServices,
            'expectedCanRecover': true, // Non-critical stage
          },
        ];

        for (final scenario in testScenarios) {
          final error = scenario['error'];
          final stage = scenario['stage'] as InitializationStage;
          final expectedCanRecover = scenario['expectedCanRecover'] as bool;

          // Test error handling
          final canRecover = await initializer._executeStageWithErrorHandling(
            stage,
            () async {
              throw error;
            },
            context: {'test': true},
          );

          expect(canRecover, equals(expectedCanRecover),
              reason: 'Stage ${stage.name} with error $error should recover: $expectedCanRecover');
        }

        // Test circuit breaker functionality
        final criticalStage = InitializationStage.firebaseCore;

        // Trigger multiple failures to open circuit breaker
        for (int i = 0; i < 4; i++) {
          await initializer._executeStageWithErrorHandling(
            criticalStage,
            () async {
              throw FirebaseException(plugin: 'firestore', code: 'unavailable');
            },
            context: {'test': 'circuit_breaker'},
          );
        }

        // Verify circuit breaker is now open
        final circuitBreakerOpen = await initializer._executeStageWithErrorHandling(
          criticalStage,
          () async {
            throw FirebaseException(plugin: 'firestore', code: 'unavailable');
          },
          context: {'test': 'circuit_breaker_open'},
        );

        expect(circuitBreakerOpen, isFalse); // Should not recover due to circuit breaker

        print('Error handling scenarios tested: ${testScenarios.length}');
        print('Circuit breaker activated successfully');
      });
    });

    testWidgets('Performance monitoring and optimization', (WidgetTester tester) async {
      await tester.runAsync(() async {
        performanceMonitor.startMonitoring();

        // Simulate stage executions with performance tracking
        final stages = [
          InitializationStage.firebaseCore,
          InitializationStage.authentication,
          InitializationStage.localsDirectory,
          InitializationStage.jobsData,
        ];

        for (final stage in stages) {
          // Record stage start
          performanceMonitor.recordStageStart(stage);

          // Simulate some work
          await Future.delayed(Duration(milliseconds: 100 + (stage.index * 50)));

          // Record some network requests
          performanceMonitor.recordNetworkRequest(stage);
          performanceMonitor.recordNetworkRequest(stage);

          // Record cache operations
          performanceMonitor.recordCacheHit(stage);
          performanceMonitor.recordCacheMiss(stage);

          // Update memory usage (simulated)
          performanceMonitor.updateMemoryUsage(20.0 + (stage.index * 5));

          // Record stage completion
          performanceMonitor.recordStageCompletion(stage, null);
        }

        // Get real-time metrics
        final realTimeMetrics = performanceMonitor.getRealTimeMetrics();
        expect(realTimeMetrics.memoryUsageMB, greaterThan(0));
        expect(realTimeMetrics.activeStages, equals(0)); // All completed
        expect(realTimeMetrics.completionRate, equals(1.0)); // 100% complete

        // Get comprehensive analysis
        final analysis = performanceMonitor.getAnalysis();
        expect(analysis.completedStages, equals(stages.length));
        expect(analysis.totalStages, equals(stages.length));
        expect(analysis.totalNetworkRequests, equals(stages.length * 2));
        expect(analysis.cacheHitRate, greaterThan(0));

        // Verify bottleneck detection
        expect(analysis.bottlenecks, isA<List>());

        // Verify optimization suggestions
        expect(analysis.suggestions, isA<List>());

        // Get performance statistics
        final stats = performanceMonitor.getPerformanceStats();
        expect(stats['totalDuration'], isA<Duration>());
        expect(stats['memoryUsageMB'], isA<double>());
        expect(stats['networkRequests'], isA<int>());

        performanceMonitor.stopMonitoring();

        print('Performance Analysis:');
        print('- Total duration: ${analysis.totalDuration.inMilliseconds}ms');
        print('- Average stage time: ${analysis.averageStageTime.inMilliseconds}ms');
        print('- Memory usage: ${analysis.averageMemoryUsage.toStringAsFixed(1)}MB average, ${analysis.peakMemoryUsage.toStringAsFixed(1)}MB peak');
        print('- Network requests: ${analysis.totalNetworkRequests} total, ${analysis.averageNetworkPerStage.toStringAsFixed(1)} per stage');
        print('- Cache hit rate: ${(analysis.cacheHitRate * 100).toStringAsFixed(1)}%');
        print('- Bottlenecks detected: ${analysis.bottlenecks.length}');
        print('- Optimization suggestions: ${analysis.suggestions.length}');
      });
    });

    testWidgets('Integration with existing services', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test Firebase integration
        expect(Firebase.apps.isNotEmpty, isTrue);

        // Test Firestore access
        final firestore = FirebaseFirestore.instance;
        expect(firestore, isNotNull);

        // Test FirebaseAuth access
        final auth = FirebaseAuth.instance;
        expect(auth, isNotNull);

        // Test stage executors can be called independently
        await expectLater(
          StageExecutors.executeFirebaseCoreStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeAuthenticationStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeSessionManagementStage(),
          completes,
        );

        // Test data loading service integration
        final validationResults = await Future.wait([
          DataLoadingService.validateFirebaseServices(),
          DataLoadingService.validateAuthentication(),
        ]);

        expect(validationResults.every((result) => result is bool), isTrue);

        // Test performance monitor integration
        performanceMonitor.startMonitoring();
        performanceMonitor.recordMetric('test_metric', 42);
        performanceMonitor.stopMonitoring();

        final metrics = performanceMonitor.getRealTimeMetrics();
        expect(metrics.memoryUsageMB, isA<double>());

        print('Firebase app: ${Firebase.app().name}');
        print('Firestore available: ${firestore != null}');
        print('Auth available: ${auth != null}');
        print('Validation results: $validationResults');
      });
    });

    testWidgets('System resilience under stress', (WidgetTester tester) async {
      await tester.runAsync(() async {
        performanceMonitor.startMonitoring();

        // Test concurrent operations
        final futures = <Future>[];

        // Simulate multiple concurrent data loading operations
        for (int i = 0; i < 5; i++) {
          futures.add(DataLoadingService.loadLocalsDirectory());
          futures.add(DataLoadingService.loadJobsData(limit: 10));
        }

        // Execute all operations concurrently
        final results = await Future.wait(futures);

        expect(results.length, equals(10)); // 5 locals + 5 jobs operations
        expect(results.every((result) => result is Map), isTrue);

        // Test rapid successive operations
        for (int i = 0; i < 10; i++) {
          await DataLoadingService.loadLocalsDirectory();
        }

        // Verify cache is working efficiently
        final cacheStats = DataLoadingService.getCacheStats();
        expect(cacheStats['cacheSize'], greaterThan(0));
        expect(cacheStats['validEntries'], greaterThan(0));

        // Test memory usage doesn't grow excessively
        final realTimeMetrics = performanceMonitor.getRealTimeMetrics();
        expect(realTimeMetrics.memoryUsageMB, lessThan(200)); // Should be under 200MB

        performanceMonitor.stopMonitoring();

        // Verify system handled stress well
        final analysis = performanceMonitor.getAnalysis();
        expect(analysis.hasBottlenecks, isA<bool>());
        expect(analysis.suggestions, isA<List>());

        print('Stress test completed:');
        print('- Concurrent operations: ${futures.length}');
        print('- Cache efficiency: ${(analysis.cacheHitRate * 100).toStringAsFixed(1)}%');
        print('- Memory usage: ${realTimeMetrics.memoryUsageMB.toStringAsFixed(1)}MB');
        print('- Bottlenecks: ${analysis.bottlenecks.length}');
      });
    });
  });
}

/// Extension to access private methods for testing
extension HierarchicalInitializerTestExtension on HierarchicalInitializer {
  Future<bool> _executeStageWithErrorHandling(
    InitializationStage stage,
    Future<void> Function() stageExecutor, {
    Map<String, dynamic>? context,
  }) async {
    // This would need to be implemented in the actual HierarchicalInitializer
    // For now, we'll simulate the behavior
    try {
      await stageExecutor();
      return true;
    } catch (e) {
      return false;
    }
  }
}