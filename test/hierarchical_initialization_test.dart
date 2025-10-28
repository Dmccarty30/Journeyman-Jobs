import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_types.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_progress_tracker.dart';
import 'package:journeyman_jobs/models/hierarchical/error_manager.dart';
import 'package:journeyman_jobs/models/hierarchical/performance_monitor.dart';

import 'hierarchical_initialization_test.mocks.dart';

@GenerateMocks([
  HierarchicalService,
  HierarchicalInitializationService,
  AuthService,
  InitializationProgressTracker,
  ErrorManager,
  PerformanceMonitor,
])
void main() {
  group('Hierarchical Initialization System Tests', () {
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
    });

    test('should create hierarchical initializer successfully', () {
      expect(initializer, isNotNull);
      expect(initializer.isRunning, isFalse);
      expect(initializer.isDisposed, isFalse);
    });

    test('should initialize with minimal strategy', () async {
      // Arrange
      when(mockProgressTracker.currentProgress).thenReturn(
        InitializationProgress(
          totalStages: 4,
          completedStages: 0,
          inProgressStages: 0,
          failedStages: 0,
          progressPercentage: 0.0,
          elapsedDuration: Duration.zero,
          estimatedTotalDuration: Duration(seconds: 2),
          estimatedRemainingDuration: Duration(seconds: 2),
        ),
      );

      // Act
      final result = await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.strategy, InitializationStrategy.minimal);
      expect(result.completedStages, greaterThan(0));
      expect(result.duration.inMilliseconds, lessThan(10000));
    });

    test('should initialize with home local first strategy', () async {
      // Arrange
      when(mockProgressTracker.currentProgress).thenReturn(
        InitializationProgress(
          totalStages: 6,
          completedStages: 0,
          inProgressStages: 0,
          failedStages: 0,
          progressPercentage: 0.0,
          elapsedDuration: Duration.zero,
          estimatedTotalDuration: Duration(seconds: 4),
          estimatedRemainingDuration: Duration(seconds: 4),
        ),
      );

      // Act
      final result = await initializer.initialize(
        strategy: InitializationStrategy.homeLocalFirst,
        timeout: Duration(seconds: 15),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.strategy, InitializationStrategy.homeLocalFirst);
      expect(result.completedStages, greaterThan(4));
    });

    test('should handle timeout gracefully', () async {
      // Act & Assert
      expect(
        () => initializer.initialize(
          strategy: InitializationStrategy.comprehensive,
          timeout: Duration(milliseconds: 100), // Very short timeout
        ),
        throwsA(isA<TimeoutException>()),
      );
    });

    test('should track progress correctly', () async {
      // Arrange
      final progressEvents = <InitializationProgress>[];
      initializer.progressStream.listen(progressEvents.add);

      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      // Assert
      expect(progressEvents.isNotEmpty, isTrue);
      expect(progressEvents.last.progressPercentage, equals(1.0));
    });

    test('should emit events during initialization', () async {
      // Arrange
      final events = <InitializationEvent>[];
      initializer.eventStream.listen(events.add);

      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      // Assert
      expect(events.length, greaterThan(2));
      expect(events.first, isA<InitializationStartedEvent>());
      expect(events.last, isA<InitializationCompletedEvent>());
    });

    test('should handle stage failures gracefully', () async {
      // Arrange - Mock a stage failure
      when(mockErrorManager.canExecuteStage(any))
          .thenReturn(false); // Circuit breaker is open

      // Act & Assert
      final result = await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      // Should still complete but with some failures
      expect(result.isSuccess, isTrue); // Overall success despite some failures
      expect(result.completedStages, greaterThan(0));
    });

    test('should get initialization statistics', () async {
      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      final stats = initializer.getStats();

      // Assert
      expect(stats.totalStages, equals(InitializationStage.values.length));
      expect(stats.completedStages, greaterThan(0));
      expect(stats.progressPercentage, equals(1.0));
      expect(stats.successRate, greaterThan(0.0));
    });

    test('should reset correctly', () async {
      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      expect(initializer.stageResults.isNotEmpty, isTrue);

      initializer.reset();

      // Assert
      expect(initializer.stageResults.isEmpty, isTrue);
      expect(initializer.isRunning, isFalse);
    });

    test('should dispose correctly', () async {
      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      initializer.dispose();

      // Assert
      expect(initializer.isDisposed, isTrue);
      expect(initializer.isRunning, isFalse);
    });

    test('should prevent multiple concurrent initializations', () async {
      // Act & Assert
      final future1 = initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      expect(
        () => initializer.initialize(
          strategy: InitializationStrategy.minimal,
          timeout: Duration(seconds: 10),
        ),
        throwsA(isA<StateError>()),
      );

      await future1;
    });

    test('should throw error when disposed', () async {
      // Act
      initializer.dispose();

      // Assert
      expect(
        () => initializer.initialize(
          strategy: InitializationStrategy.minimal,
          timeout: Duration(seconds: 10),
        ),
        throwsA(isA<StateError>()),
      );
    });
  });

  group('Initialization Stage Tests', () {
    test('should have correct dependency relationships', () {
      // Test Firebase Core dependencies
      expect(InitializationStage.authentication.dependsOn,
             contains(InitializationStage.firebaseCore));

      // Test session management dependencies
      expect(InitializationStage.sessionManagement.dependsOn,
             contains(InitializationStage.authentication));

      // Test user profile dependencies
      expect(InitializationStage.userProfile.dependsOn,
             contains(InitializationStage.sessionManagement));
    });

    test('should identify critical stages correctly', () {
      final criticalStages = InitializationStage.values
          .where((stage) => stage.isCritical)
          .toList();

      expect(criticalStages, contains(InitializationStage.firebaseCore));
      expect(criticalStages, contains(InitializationStage.authentication));
      expect(criticalStages, contains(InitializationStage.sessionManagement));
      expect(criticalStages, contains(InitializationStage.userProfile));
      expect(criticalStages, contains(InitializationStage.localsDirectory));
      expect(criticalStages, contains(InitializationStage.jobsData));
    });

    test('should calculate parallel execution correctly', () {
      final userProfileParallel = InitializationStage.userProfile.parallelStages;
      expect(userProfileParallel, contains(InitializationStage.userPreferences));

      final jobsDataParallel = InitializationStage.jobsData.parallelStages;
      expect(jobsDataParallel.length, greaterThan(0));
    });

    test('should check execution readiness correctly', () {
      final completedStages = {
        InitializationStage.firebaseCore,
        InitializationStage.authentication,
        InitializationStage.sessionManagement,
      };

      expect(InitializationStage.userProfile.canExecute(completedStages), isTrue);
      expect(InitializationStage.userPreferences.canExecute(completedStages), isTrue);
      expect(InitializationStage.localsDirectory.canExecute(completedStages), isFalse);
    });
  });

  group('Performance Integration Tests', () {
    test('should complete initialization within performance targets', () async {
      final initializer = HierarchicalInitializer();

      final stopwatch = Stopwatch()..start();

      await initializer.initialize(
        strategy: InitializationStrategy.adaptive,
        timeout: Duration(seconds: 5),
      );

      stopwatch.stop();

      // Should complete within 3 seconds target
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      initializer.dispose();
    });

    test('should handle network failure scenarios', () async {
      // This test would require mocking network failures
      // For now, we'll test the system's ability to handle timeouts

      final initializer = HierarchicalInitializer();

      // Use a very short timeout to simulate network issues
      final result = await initializer.initialize(
        strategy: InitializationStrategy.comprehensive,
        timeout: Duration(milliseconds: 100),
      );

      // Should handle gracefully even with timeout
      expect(result, isNotNull);

      initializer.dispose();
    });
  });
}