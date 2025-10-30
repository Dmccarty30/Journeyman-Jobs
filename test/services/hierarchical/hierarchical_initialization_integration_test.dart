import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/services/hierarchical/stage_executors.dart';
import 'package:journeyman_jobs/services/hierarchical/data_loading_service.dart';
import 'package:journeyman_jobs/services/hierarchical/error_recovery_manager.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';

/// Integration tests for Hierarchical Initialization System
///
/// These tests validate the complete initialization flow with real Firebase services.
/// They ensure all components work together correctly and handle real-world scenarios.
void main() {
  group('Hierarchical Initialization Integration Tests', () {
    late HierarchicalInitializer initializer;

    setUpAll(() async {
      // Initialize Firebase for testing
      try {
        await Firebase.initializeApp(
          name: 'test-app',
          options: const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project-id',
          ),
        );
      } catch (e) {
        // Firebase already initialized or test environment
        print('Firebase initialization note: $e');
      }

      initializer = HierarchicalInitializer();
    });

    tearDownAll(() async {
      // Clean up test data
      await DataLoadingService.clearCache();
      ErrorRecoveryManager.resetAll();
    });

    testWidgets('Complete initialization flow executes all stages', (WidgetTester tester) async {
      // Arrange
      final progressListener = <InitializationStage>[];
      final completionListener = <Map<String, dynamic>>[];

      initializer.progressStream.listen((stage) {
        progressListener.add(stage);
      });

      initializer.completionStream.listen((result) {
        completionListener.add(result);
      });

      // Act
      await tester.runAsync(() async {
        final result = await initializer.initializeHierarchically();

        // Wait for async operations
        await tester.pumpAndSettle(const Duration(seconds: 10));

        // Assert
        expect(result['success'], isTrue);
        expect(result['completedStages'], isNotEmpty);
        expect(result['totalDuration'], isA<Duration>());

        // Verify all critical stages were attempted
        expect(progressListener.length, greaterThan(5));
        expect(progressListener, contains(InitializationStage.firebaseCore));
        expect(progressListener, contains(InitializationStage.authentication));

        // Verify completion was called
        expect(completionListener.length, 1);
        expect(completionListener.first['success'], isTrue);
      });
    });

    testWidgets('Stage executors perform real Firebase operations', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test Firebase Core validation
        await expectLater(
          StageExecutors.executeFirebaseCoreStage(),
          completes,
        );

        // Test authentication validation (guest mode)
        await expectLater(
          StageExecutors.executeAuthenticationStage(),
          completes,
        );

        // Test session management
        await expectLater(
          StageExecutors.executeSessionManagementStage(),
          completes,
        );

        // Test locals directory loading
        final locals = await StageExecutors.executeLocalsDirectoryStage();
        expect(locals, isA<Map<int, dynamic>>());

        // Test jobs data loading
        final jobs = await StageExecutors.executeJobsDataStage();
        expect(jobs, isA<Map<String, dynamic>>());

        // Test non-critical stages complete without throwing
        await expectLater(
          StageExecutors.executeWeatherServicesStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeNotificationsStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeOfflineSyncStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeBackgroundTasksStage(),
          completes,
        );

        await expectLater(
          StageExecutors.executeAnalyticsStage(),
          completes,
        );
      });
    });

    testWidgets('Data loading service handles Firebase operations with caching', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test Firebase services validation
        final isValid = await DataLoadingService.validateFirebaseServices();
        expect(isValid, isA<bool>());

        // Test authentication validation
        final authValid = await DataLoadingService.validateAuthentication();
        expect(authValid, isA<bool>());

        // Test locals directory loading with cache
        final locals1 = await DataLoadingService.loadLocalsDirectory();
        expect(locals1, isA<Map<int, dynamic>>());

        // Test cache hit (second load should be faster)
        final stopwatch = Stopwatch()..start();
        final locals2 = await DataLoadingService.loadLocalsDirectory();
        stopwatch.stop();

        expect(locals2, equals(locals1));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be cached

        // Test force refresh
        final locals3 = await DataLoadingService.loadLocalsDirectory(forceRefresh: true);
        expect(locals3, isA<Map<int, dynamic>>());

        // Test jobs data loading with filtering
        final jobs = await DataLoadingService.loadJobsData(
          homeLocal: 123,
          preferredLocals: ['124', '125'],
          limit: 10,
        );
        expect(jobs, isA<Map<String, dynamic>>());

        // Test cache statistics
        final cacheStats = DataLoadingService.getCacheStats();
        expect(cacheStats, isA<Map<String, dynamic>>());
        expect(cacheStats['cacheSize'], greaterThan(0));
      });
    });

    testWidgets('Error recovery manager handles real Firebase errors', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test circuit breaker functionality
        final stage = InitializationStage.firebaseCore;

        // Simulate multiple failures to trigger circuit breaker
        for (int i = 0; i < 5; i++) {
          final canRecover = await ErrorRecoveryManager.handleStageError(
            stage,
            FirebaseException(plugin: 'firestore', code: 'unavailable'),
            StackTrace.current,
          );
          expect(canRecover, isA<bool>());
        }

        // Verify error statistics are tracked
        final errorStats = ErrorRecoveryManager.getErrorStats();
        expect(errorStats, isA<Map<String, dynamic>>());
        expect(errorStats['retryAttempts'], isA<Map>());

        // Test health check
        final healthCheck = ErrorRecoveryManager.performHealthCheck();
        expect(healthCheck, isA<Map<String, bool>>());
        expect(healthCheck['retryMechanism'], isA<bool>());
        expect(healthCheck['maxRetriesConfigured'], isTrue);

        // Test cache operations
        ErrorRecoveryManager.cacheResult(stage, {'test': 'data'});
        expect(ErrorRecoveryManager.hasCachedResult(stage), isTrue);

        final cachedResult = ErrorRecoveryManager.getCachedResult(stage);
        expect(cachedResult, isA<Map>());
        expect(cachedResult['test'], equals('data'));

        // Reset for other tests
        ErrorRecoveryManager.resetStage(stage);
      });
    });

    testWidgets('Performance monitoring tracks actual execution times', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Get initial stats
        final initialStats = StageExecutors.getExecutionStats();
        expect(initialStats, isA<Map<InitializationStage, Duration>>());

        // Execute stages to generate timing data
        await StageExecutors.executeFirebaseCoreStage();
        await StageExecutors.executeAuthenticationStage();
        await StageExecutors.executeLocalsDirectoryStage();

        // Get updated stats
        final finalStats = StageExecutors.getExecutionStats();

        // Verify timing data was collected
        expect(finalStats[InitializationStage.firebaseCore], isA<Duration>());
        expect(finalStats[InitializationStage.authentication], isA<Duration>());
        expect(finalStats[InitializationStage.localsDirectory], isA<Duration>());

        // Verify durations are reasonable (not zero, not excessive)
        expect(finalStats[InitializationStage.firebaseCore]!.inMilliseconds,
               greaterThan(0));
        expect(finalStats[InitializationStage.firebaseCore]!.inMilliseconds,
               lessThan(30000)); // Should complete within 30 seconds

        // Clear stats for other tests
        StageExecutors.clearStats();
        final clearedStats = StageExecutors.getExecutionStats();
        expect(clearedStats[InitializationStage.firebaseCore]!.inMilliseconds, equals(0));
      });
    });

    testWidgets('System handles network failures gracefully', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Test with invalid Firebase configuration to simulate network issues
        // This would typically require mocking network failures

        // Verify error recovery manager handles different error types
        final networkError = await ErrorRecoveryManager.handleStageError(
          InitializationStage.jobsData,
          'Network connection failed',
          StackTrace.current,
        );
        expect(networkError, isA<bool>());

        final timeoutError = await ErrorRecoveryManager.handleStageError(
          InitializationStage.userProfile,
          TimeoutException('Request timed out', const Duration(seconds: 30)),
          StackTrace.current,
        );
        expect(timeoutError, isA<bool>());

        final permissionError = await ErrorRecoveryManager.handleStageError(
          InitializationStage.crewFeatures,
          FirebaseException(plugin: 'firestore', code: 'permission-denied'),
          StackTrace.current,
        );
        expect(permissionError, isA<bool>());
      });
    });

    testWidgets('Progress tracking provides real-time updates', (WidgetTester tester) async {
      await tester.runAsync(() async {
        final progressEvents = <InitializationStage>[];
        final progressValues = <double>[];

        initializer.progressStream.listen((stage) {
          progressEvents.add(stage);
        });

        initializer.progressStream.listen((progress) {
          progressValues.add(progress.progressPercentage);
        });

        // Start initialization
        final initFuture = initializer.initializeHierarchically();

        // Listen for progress updates
        await Future.doWhile(() async {
          await Future.delayed(const Duration(milliseconds: 100));
          return !initFuture.isCompleted;
        });

        final result = await initFuture;

        // Verify progress was tracked
        expect(progressEvents.length, greaterThan(0));
        expect(progressValues.length, greaterThan(0));

        // Verify final progress value
        expect(progressValues.last, equals(1.0));

        // Verify result contains progress information
        expect(result['progressInfo'], isA<Map<String, dynamic>>());
        expect(result['progressInfo']['totalStages'], greaterThan(0));
        expect(result['progressInfo']['completedStages'], greaterThan(0));
      });
    });

    testWidgets('Dependency management ensures correct execution order', (WidgetTester tester) async {
      await tester.runAsync(() async {
        // Get the execution plan
        final plan = await initializer.createExecutionPlan();

        // Verify dependency structure
        expect(plan.stages, isNotEmpty);
        expect(plan.executionOrder, isNotEmpty);

        // Verify critical dependencies are respected
        final firebaseCoreIndex = plan.executionOrder.indexOf(InitializationStage.firebaseCore);
        final authIndex = plan.executionOrder.indexOf(InitializationStage.authentication);
        final userProfileIndex = plan.executionOrder.indexOf(InitializationStage.userProfile);

        // Firebase Core should come before Authentication
        expect(firebaseCoreIndex, lessThan(authIndex));

        // Authentication should come before User Profile
        expect(authIndex, lessThan(userProfileIndex));

        // Verify parallel stages are identified
        expect(plan.parallelStages, isNotEmpty);

        // Verify critical path is calculated
        expect(plan.criticalPath.length, greaterThan(0));
      });
    });
  });
}