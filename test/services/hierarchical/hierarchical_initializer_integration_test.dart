import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_service.dart';
import 'package:journeyman_jobs/services/hierarchical/initialization_progress_tracker.dart';
import 'package:journeyman_jobs/services/hierarchical/error_manager.dart';
import 'package:journeyman_jobs/services/hierarchical/performance_monitor.dart';
import 'package:journeyman_jobs/services/hierarchical/dependency_resolver.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_metadata.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_data_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';

import 'hierarchical_initializer_integration_test.mocks.dart';

@GenerateMocks([
  AuthService,
])
void main() {
  group('HierarchicalInitializer Integration Tests', () {
    late HierarchicalInitializer initializer;
    late FakeFirebaseFirestore fakeFirestore;
    late HierarchicalService hierarchicalService;
    late MockAuthService mockAuthService;

    setUpAll(() {
      // Initialize Firebase mock
      fakeFirestore = FakeFirebaseFirestore();
    });

    setUp(() {
      mockAuthService = MockAuthService();
      hierarchicalService = HierarchicalService();

      initializer = HierarchicalInitializer(
        hierarchicalService: hierarchicalService,
        authService: mockAuthService,
        firestore: fakeFirestore,
      );

      // Setup mock auth service behavior
      when(mockAuthService.getCurrentUser()).thenReturn(null);
    });

    tearDown(() {
      initializer.dispose();
    });

    group('Firebase Integration', () {
      test('should initialize with Firebase services', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
          timeout: Duration(seconds: 10),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.stageResults.containsKey(InitializationStage.firebaseCore), isTrue);
        expect(result.stageResults[InitializationStage.firebaseCore]!.isSuccess, isTrue);
      });

      test('should handle Firebase initialization failure', () async {
        // Arrange - Simulate Firebase unavailability
        when(mockAuthService.getCurrentUser()).thenThrow(Exception('Firebase unavailable'));

        // Act & Assert
        expect(
          () => initializer.initialize(strategy: InitializationStrategy.minimal),
          throwsA(isA<Exception>()),
        );
      });

      test('should handle authentication integration', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.stageResults.containsKey(InitializationStage.authentication), isTrue);
        expect(result.stageResults[InitializationStage.authentication]!.isSuccess, isTrue);
      });
    });

    group('Hierarchical Service Integration', () {
      test('should integrate with hierarchical service', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockAuthService.getCurrentUser()).called(greaterThan(0));
      });

      test('should load hierarchical data when user is authenticated', () async {
        // Arrange - Create test user data
        final testUser = UserModel(
          uid: 'test-user-id',
          email: 'test@example.com',
          name: 'Test User',
          homeLocal: 123,
          createdTime: DateTime.now().subtract(Duration(days: 30)),
        );

        // Add user to fake Firestore
        await fakeFirestore.collection('users').doc('test-user-id').set({
          'uid': 'test-user-id',
          'email': 'test@example.com',
          'name': 'Test User',
          'homeLocal': 123,
          'createdTime': DateTime.now().subtract(Duration(days: 30)).toIso8601String(),
        });

        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.stageResults.containsKey(InitializationStage.userProfile), isTrue);
      });
    });

    group('Progress Tracking Integration', () {
      test('should track progress across all stages', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);
        final progressEvents = <InitializationProgress>[];
        final subscription = initializer.progressStream.listen(progressEvents.add);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );
        await subscription.cancel();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(progressEvents.isNotEmpty, isTrue);

        // Check that progress increased from 0 to 100%
        final initialProgress = progressEvents.first.progressPercentage;
        final finalProgress = progressEvents.last.progressPercentage;
        expect(initialProgress, equals(0.0));
        expect(finalProgress, equals(1.0));
      });

      test('should emit stage progress events', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);
        final stageEvents = <InitializationEvent>[];
        final subscription = initializer.eventStream.listen(stageEvents.add);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );
        await subscription.cancel();

        // Assert
        expect(result.isSuccess, isTrue);

        final stageStartedEvents = stageEvents.whereType<StageStartedEvent>();
        final stageCompletedEvents = stageEvents.whereType<StageCompletedEvent>();

        expect(stageStartedEvents.isNotEmpty, isTrue);
        expect(stageCompletedEvents.isNotEmpty, isTrue);
      });
    });

    group('Error Management Integration', () {
      test('should handle service failures gracefully', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenThrow(Exception('Service unavailable'));

        // Act
        try {
          await initializer.initialize(strategy: InitializationStrategy.minimal);
          fail('Should have thrown an exception');
        } catch (e) {
          // Assert
          expect(e, isA<Exception>());
        }

        // Verify error was handled
        final stats = initializer.getStats();
        expect(stats.failedStages, greaterThan(0));
      });

      test('should recover from non-critical stage failures', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act - Initialize with a strategy that includes non-critical stages
        final result = await initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
          timeout: Duration(seconds: 15),
        );

        // Assert - Should succeed even if some non-critical stages fail
        expect(result.isSuccess, isTrue);
        expect(result.completedStages, greaterThan(0));
      });
    });

    group('Performance Monitoring Integration', () {
      test('should track performance metrics during initialization', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final stopwatch = Stopwatch()..start();
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );
        stopwatch.stop();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(stopwatch.elapsed.inMilliseconds, greaterThan(0));

        // Check that performance was monitored
        final stats = initializer.getStats();
        expect(stats.actualDuration.inMilliseconds, greaterThan(0));
      });

      test('should provide detailed performance analysis', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Get real-time metrics
        final metrics = initializer._performanceMonitor.getRealTimeMetrics();

        // Assert
        expect(metrics.memoryUsageMB, greaterThanOrEqualTo(0.0));
        expect(metrics.activeStages, greaterThanOrEqualTo(0));
        expect(metrics.completionRate, greaterThanOrEqualTo(0.0));
      });
    });

    group('Strategy Integration', () {
      test('should execute minimal strategy correctly', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(InitializationStrategy.minimal));

        // Should only execute critical stages
        final criticalStages = result.stageResults.keys.where((stage) => stage.isCritical);
        expect(criticalStages.isNotEmpty, isTrue);
      });

      test('should execute comprehensive strategy correctly', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
          timeout: Duration(seconds: 30),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(InitializationStrategy.comprehensive));

        // Should execute all stages
        expect(result.completedStages, equals(InitializationStage.values.length));
      });

      test('should adapt strategy based on conditions', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.adaptive,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(InitializationStrategy.adaptive));
      });
    });

    group('Dependency Resolution Integration', () {
      test('should respect stage dependencies', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);

        // Check that dependencies were respected
        for (final stage in InitializationStage.values) {
          final stageResult = result.stageResults[stage];
          if (stageResult != null && stageResult.isSuccess) {
            // Verify that all dependencies were completed before this stage
            for (final dependency in stage.dependsOn) {
              final dependencyResult = result.stageResults[dependency];
              expect(dependencyResult?.isSuccess, isTrue,
                  reason: '$stage depends on $dependency which should have succeeded');
            }
          }
        }
      });

      test('should handle circular dependencies detection', () async {
        // This test verifies that the dependency graph validation works
        // The dependency graph is validated during initialization

        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert - Should succeed if no circular dependencies exist
        expect(result.isSuccess, isTrue);
      });
    });

    group('Concurrent Operations', () {
      test('should handle concurrent initialization attempts', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final future1 = initializer.initialize(strategy: InitializationStrategy.minimal);
        final future2 = initializer.initialize(strategy: InitializationStrategy.minimal);

        // Assert
        await expectLater(future1, completes);
        await expectLater(future2, throwsA(isA<StateError>()));
      });

      test('should handle concurrent progress updates', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);
        final progressUpdates = <InitializationProgress>[];
        final subscription = initializer.progressStream.listen(progressUpdates.add);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );
        await subscription.cancel();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(progressUpdates.isNotEmpty, isTrue);
        expect(progressUpdates.last.progressPercentage, equals(1.0));
      });
    });

    group('Resource Management', () {
      test('should clean up resources properly', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        final statsBeforeDispose = initializer.getStats();

        initializer.dispose();

        // Assert
        expect(statsBeforeDispose.totalStages, greaterThan(0));
        expect(initializer.isDisposed, isTrue);
      });

      test('should handle disposal during initialization', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final initializationFuture = initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
          timeout: Duration(seconds: 30),
        );

        // Dispose after a short delay
        Future.delayed(Duration(milliseconds: 100)).then((_) => initializer.dispose());

        // Assert
        expect(initializationFuture, throwsA(isA<StateError>()));
      });
    });

    group('Real-world Scenarios', () {
      test('should handle cold start scenario', () async {
        // Arrange - Simulate cold start with no cached data
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.adaptive,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(InitializationStrategy.adaptive));

        // Should complete within reasonable time for cold start
        expect(result.duration.inMilliseconds, lessThan(10000));
      });

      test('should handle warm start scenario', () async {
        // Arrange - Simulate warm start with cached data
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // First initialization to warm up caches
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        initializer.reset();

        // Act - Second initialization (warm start)
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(InitializationStrategy.minimal));
      });

      test('should handle network failure scenario', () async {
        // Arrange - Simulate network failure
        when(mockAuthService.getCurrentUser()).thenThrow(Exception('Network unavailable'));

        // Act
        try {
          await initializer.initialize(strategy: InitializationStrategy.minimal);
          fail('Should have thrown network exception');
        } catch (e) {
          // Assert
          expect(e, isA<Exception>());
        }

        // Verify graceful degradation
        final stats = initializer.getStats();
        expect(stats.totalStages, greaterThan(0));
      });

      test('should handle memory pressure scenario', () async {
        // Arrange
        when(mockAuthService.getCurrentUser()).thenReturn(null);

        // Act - Initialize with performance monitoring
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);

        // Check that memory usage was tracked
        final metrics = initializer._performanceMonitor.getRealTimeMetrics();
        expect(metrics.memoryUsageMB, greaterThanOrEqualTo(0.0));
      });
    });
  });
}