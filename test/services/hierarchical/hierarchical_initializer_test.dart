import 'dart:async';
import 'dart:math' as math;

import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/services/hierarchical/initialization_progress_tracker.dart';
import 'package:journeyman_jobs/services/hierarchical/error_manager.dart';
import 'package:journeyman_jobs/services/hierarchical/performance_monitor.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_service.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_initialization_service.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_dependency_graph.dart';
import 'package:journeyman_jobs/models/user_model.dart';

import 'hierarchical_initializer_test.mocks.dart';

@GenerateMocks([
  HierarchicalService,
  HierarchicalInitializationService,
  AuthService,
  InitializationProgressTracker,
  ErrorManager,
  PerformanceMonitor,
  InitializationDependencyGraph,
])
void main() {
  group('HierarchicalInitializer', () {
    late HierarchicalInitializer initializer;
    late MockHierarchicalService mockHierarchicalService;
    late MockHierarchicalInitializationService mockInitializationService;
    late MockAuthService mockAuthService;
    late MockInitializationProgressTracker mockProgressTracker;
    late MockErrorManager mockErrorManager;
    late MockPerformanceMonitor mockPerformanceMonitor;

    setUp(() {
      mockHierarchicalService = MockHierarchicalService();
      mockInitializationService = MockHierarchicalInitializationService();
      mockAuthService = MockAuthService();
      mockProgressTracker = MockInitializationProgressTracker();
      mockErrorManager = MockErrorManager();
      mockPerformanceMonitor = MockPerformanceMonitor();

      initializer = HierarchicalInitializer(
        hierarchicalService: mockHierarchicalService,
        initializationService: mockInitializationService,
        authService: mockAuthService,
        progressTracker: mockProgressTracker,
        errorManager: mockErrorManager,
        performanceMonitor: mockPerformanceMonitor,
      );

      // Setup default mock behavior
      when(mockProgressTracker.currentProgress).thenReturn(InitializationProgress(
        strategy: InitializationStrategy.adaptive,
        progressPercentage: 0.0,
        completedStages: 0,
        totalStages: InitializationStage.values.length,
        inProgressStages: 0,
        failedStages: 0,
        elapsedTime: Duration.zero,
        estimatedRemainingTime: Duration.zero,
        currentPhase: InitializationPhase.starting,
        activeStages: [],
        stageProgress: {},
        isCompleted: false,
        hasError: false,
        error: '',
        startTime: DateTime.now(),
        endTime: null,
      ));

      when(mockErrorManager.canExecuteStage(any)).thenReturn(true);
      when(mockErrorManager.shouldRetryStage(any, any)).thenReturn(false);
      when(mockErrorManager.getRetryDelay(any)).thenReturn(Duration(milliseconds: 100));

      when(mockPerformanceMonitor.getStageMetrics(any)).thenReturn(null);
    });

    tearDown(() {
      initializer.dispose();
    });

    group('initialization', () {
      test('should initialize with minimal strategy successfully', () async {
        // Arrange
        final expectedStrategy = InitializationStrategy.minimal;
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: expectedStrategy,
          timeout: Duration(seconds: 10),
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(expectedStrategy));
        expect(initializer.strategy, equals(expectedStrategy));
        verify(mockProgressTracker.initialize(expectedStrategy, any)).called(1);
        verify(mockPerformanceMonitor.startMonitoring()).called(1);
        verify(mockPerformanceMonitor.stopMonitoring()).called(1);
      });

      test('should initialize with home local first strategy', () async {
        // Arrange
        final expectedStrategy = InitializationStrategy.homeLocalFirst;
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: expectedStrategy,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(expectedStrategy));
      });

      test('should initialize with comprehensive strategy', () async {
        // Arrange
        final expectedStrategy = InitializationStrategy.comprehensive;
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: expectedStrategy,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(expectedStrategy));
      });

      test('should initialize with adaptive strategy', () async {
        // Arrange
        final expectedStrategy = InitializationStrategy.adaptive;
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: expectedStrategy,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.strategy, equals(expectedStrategy));
      });

      test('should handle initialization timeout', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        initializer.timeout = Duration(milliseconds: 100);

        // Act & Assert
        expect(
          () => initializer.initialize(
            strategy: InitializationStrategy.comprehensive,
            timeout: Duration(milliseconds: 50),
          ),
          throwsA(isA<TimeoutException>()),
        );
      });

      test('should throw when already running', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        final initializationFuture = initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Act & Assert
        expect(
          () => initializer.initialize(strategy: InitializationStrategy.minimal),
          throwsA(isA<StateError>()),
        );

        // Wait for first initialization to complete
        await initializationFuture;
      });

      test('should throw when disposed', () async {
        // Arrange
        initializer.dispose();

        // Act & Assert
        expect(
          () => initializer.initialize(strategy: InitializationStrategy.minimal),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('error handling', () {
      test('should handle critical stage failure', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        when(mockErrorManager.canExecuteStage(InitializationStage.firebaseCore))
            .thenReturn(false);

        // Act & Assert
        expect(
          () => initializer.initialize(strategy: InitializationStrategy.minimal),
          throwsA(isA<StateError>()),
        );
      });

      test('should handle non-critical stage failure gracefully', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        when(mockErrorManager.canExecuteStage(InitializationStage.analytics))
            .thenReturn(false);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        // Analytics is non-critical, so initialization should succeed
      });

      test('should retry failed stages when configured', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        when(mockErrorManager.shouldRetryStage(any, any)).thenReturn(true);
        when(mockErrorManager.getRetryDelay(any)).thenReturn(Duration(milliseconds: 10));

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        verify(mockErrorManager.shouldRetryStage(any, any)).called(greaterThan(0));
      });

      test('should record stage failures and successes', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);

        // Assert
        verify(mockErrorManager.recordStageFailure(any, any)).called(greaterThan(0));
        verify(mockErrorManager.recordStageSuccess(any)).called(greaterThan(0));
      });
    });

    group('progress tracking', () {
      test('should update progress during initialization', () async {
        // Arrange
        final progressController = StreamController<InitializationProgress>();
        when(mockProgressTracker.progressStream).thenAnswer((_) => progressController.stream);
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        final progressUpdates = <InitializationProgress>[];
        final subscription = initializer.progressStream.listen(progressUpdates.add);

        // Act
        final initializationFuture = initializer.initialize(
          strategy: InitializationStrategy.minimal,
        );

        // Simulate progress updates
        progressController.add(InitializationProgress(
          strategy: InitializationStrategy.minimal,
          progressPercentage: 0.5,
          completedStages: 2,
          totalStages: 4,
          inProgressStages: 1,
          failedStages: 0,
          elapsedTime: Duration(milliseconds: 500),
          estimatedRemainingTime: Duration(milliseconds: 500),
          currentPhase: InitializationPhase.userData,
          activeStages: [InitializationStage.userProfile],
          stageProgress: {},
          isCompleted: false,
          hasError: false,
          error: '',
          startTime: DateTime.now(),
          endTime: null,
        ));

        await initializationFuture;
        await subscription.cancel();
        await progressController.close();

        // Assert
        expect(progressUpdates.isNotEmpty, isTrue);
        expect(progressUpdates.last.progressPercentage, equals(0.5));
      });

      test('should emit initialization events', () async {
        // Arrange
        final eventController = StreamController<InitializationEvent>();
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        final events = <InitializationEvent>[];
        final subscription = initializer.eventStream.listen(events.add);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        await subscription.cancel();

        // Assert
        expect(events.length, greaterThan(0));
        expect(events.first, isA<InitializationStartedEvent>());
        expect(events.last, isA<InitializationCompletedEvent>());
      });

      test('should emit stage events during initialization', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        final events = <InitializationEvent>[];
        final subscription = initializer.eventStream.listen(events.add);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        await subscription.cancel();

        // Assert
        final stageEvents = events.where((e) =>
          e is StageStartedEvent || e is StageCompletedEvent || e is StageFailedEvent);
        expect(stageEvents.length, greaterThan(0));
      });
    });

    group('performance monitoring', () {
      test('should track performance metrics', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        when(mockPerformanceMonitor.getRealTimeMetrics()).thenReturn(RealTimeMetrics(
          memoryUsageMB: 50.0,
          memoryTrendMBPerSec: 0.1,
          networkRequestsPerSec: 2.0,
          cacheHitRate: 0.8,
          activeStages: 1,
          completionRate: 0.5,
          estimatedTimeRemaining: Duration(seconds: 10),
        ));

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);

        // Assert
        verify(mockPerformanceMonitor.startMonitoring()).called(1);
        verify(mockPerformanceMonitor.stopMonitoring()).called(1);
      });

      test('should record stage timing', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);

        // Assert
        verify(mockPerformanceMonitor.recordStageStart(any)).called(greaterThan(0));
        verify(mockPerformanceMonitor.recordStageCompletion(any, any)).called(greaterThan(0));
      });
    });

    group('statistics and metrics', () {
      test('should provide initialization statistics', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        final stats = initializer.getStats();

        // Assert
        expect(stats.totalStages, equals(InitializationStage.values.length));
        expect(stats.completedStages, greaterThan(0));
        expect(stats.progressPercentage, greaterThan(0.0));
      });

      test('should track stage results', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        await initializer.initialize(strategy: InitializationStrategy.minimal);
        final results = initializer.stageResults;

        // Assert
        expect(results.isNotEmpty, isTrue);
        expect(results.keys.every((stage) => results[stage]!.isSuccess), isTrue);
      });
    });

    group('reset and dispose', () {
      test('should reset initialization state', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        await initializer.initialize(strategy: InitializationStrategy.minimal);

        // Act
        initializer.reset();

        // Assert
        expect(initializer.stageResults.isEmpty, isTrue);
        expect(initializer.isRunning, isFalse);
      });

      test('should dispose properly', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        await initializer.initialize(strategy: InitializationStrategy.minimal);

        // Act
        initializer.dispose();

        // Assert
        expect(initializer.isDisposed, isTrue);
        expect(
          () => initializer.initialize(strategy: InitializationStrategy.minimal),
          throwsA(isA<StateError>()),
        );
      });
    });

    group('configuration', () {
      test('should allow timeout configuration', () {
        // Arrange
        const expectedTimeout = Duration(seconds: 60);

        // Act
        initializer.timeout = expectedTimeout;

        // Assert
        expect(initializer.timeout, equals(expectedTimeout));
      });

      test('should allow strategy configuration', () {
        // Arrange
        const expectedStrategy = InitializationStrategy.comprehensive;

        // Act
        initializer.strategy = expectedStrategy;

        // Assert
        expect(initializer.strategy, equals(expectedStrategy));
      });
    });

    group('edge cases', () {
      test('should handle empty context', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
          context: {},
        );

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle force refresh', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.minimal,
          forceRefresh: true,
        );

        // Assert
        expect(result.isSuccess, isTrue);
      });

      test('should handle concurrent initialization attempts', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final future1 = initializer.initialize(strategy: InitializationStrategy.minimal);
        final future2 = initializer.initialize(strategy: InitializationStrategy.minimal);

        // Assert
        await expectLater(future1, completes);
        await expectLater(future2, throwsA(isA<StateError>()));
      });
    });

    group('integration scenarios', () {
      test('should complete full initialization with all stages', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.stageResults.length, equals(InitializationStage.values.length));
        expect(result.completedStages, equals(InitializationStage.values.length));
        expect(result.failedStages, equals(0));
      });

      test('should handle partial failure gracefully', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        when(mockErrorManager.canExecuteStage(InitializationStage.analytics))
            .thenReturn(false);

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
        );

        // Assert
        expect(result.isSuccess, isTrue);
        expect(result.failedStages, greaterThan(0));
        expect(result.completedStages, lessThan(InitializationStage.values.length));
      });

      test('should maintain performance under load', () async {
        // Arrange
        when(mockProgressTracker.initialize(any, any)).thenReturn(null);
        final stopwatch = Stopwatch()..start();

        // Act
        final result = await initializer.initialize(
          strategy: InitializationStrategy.adaptive,
        );
        stopwatch.stop();

        // Assert
        expect(result.isSuccess, isTrue);
        expect(stopwatch.elapsed.inMilliseconds, lessThan(5000)); // Should complete within 5 seconds
      });
    });
  });

  group('HierarchicalInitializer - Error Scenarios', () {
    late HierarchicalInitializer initializer;
    late MockErrorManager mockErrorManager;

    setUp(() {
      mockErrorManager = MockErrorManager();
      initializer = HierarchicalInitializer(errorManager: mockErrorManager);
    });

    test('should handle circuit breaker open', () async {
      // Arrange
      when(mockErrorManager.canExecuteStage(InitializationStage.firebaseCore))
          .thenReturn(false);

      // Act & Assert
      expect(
        () => initializer.initialize(strategy: InitializationStrategy.minimal),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle retry exhaustion', () async {
      // Arrange
      when(mockErrorManager.shouldRetryStage(any, any))
          .thenReturn(true)
          .thenReturn(true)
          .thenReturn(false); // Exhaust retries after 2 attempts

      // Act & Assert
      expect(
        () => initializer.initialize(strategy: InitializationStrategy.minimal),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('HierarchicalInitializer - Performance Tests', () {
    test('should handle rapid initialization calls', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

      // Act
      final stopwatch = Stopwatch()..start();
      final results = await Future.wait([
        initializer.initialize(strategy: InitializationStrategy.minimal),
        initializer.initialize(strategy: InitializationStrategy.minimal),
      ]);
      stopwatch.stop();

      // Assert
      expect(results.length, equals(2));
      expect(stopwatch.elapsed.inMilliseconds, lessThan(10000)); // Should complete within 10 seconds

      initializer.dispose();
    });
  });
}