import 'package:flutter_test/flutter_test.dart';

import 'package:journeyman_jobs/services/hierarchical/hierarchical_initializer.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_types.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';

void main() {
  group('Hierarchical Initialization Simple Tests', () {
    test('should create hierarchical initializer successfully', () {
      // Act
      final initializer = HierarchicalInitializer();

      // Assert
      expect(initializer, isNotNull);
      expect(initializer.isRunning, isFalse);
      expect(initializer.isDisposed, isFalse);
    });

    test('should initialize with minimal strategy', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

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

      // Cleanup
      initializer.dispose();
    });

    test('should initialize with home local first strategy', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

      // Act
      final result = await initializer.initialize(
        strategy: InitializationStrategy.homeLocalFirst,
        timeout: Duration(seconds: 15),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.strategy, InitializationStrategy.homeLocalFirst);
      expect(result.completedStages, greaterThan(4));

      // Cleanup
      initializer.dispose();
    });

    test('should initialize with adaptive strategy', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

      // Act
      final result = await initializer.initialize(
        strategy: InitializationStrategy.adaptive,
        timeout: Duration(seconds: 20),
      );

      // Assert
      expect(result.isSuccess, isTrue);
      expect(result.strategy, InitializationStrategy.adaptive);
      expect(result.completedStages, greaterThan(0));

      // Cleanup
      initializer.dispose();
    });

    test('should track progress correctly', () async {
      // Arrange
      final initializer = HierarchicalInitializer();
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

      // Cleanup
      initializer.dispose();
    });

    test('should emit events during initialization', () async {
      // Arrange
      final initializer = HierarchicalInitializer();
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

      // Cleanup
      initializer.dispose();
    });

    test('should get initialization statistics', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

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

      // Cleanup
      initializer.dispose();
    });

    test('should reset correctly', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

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

      // Cleanup
      initializer.dispose();
    });

    test('should dispose correctly', () async {
      // Arrange
      final initializer = HierarchicalInitializer();

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
      // Arrange
      final initializer = HierarchicalInitializer();

      // Act
      final future1 = initializer.initialize(
        strategy: InitializationStrategy.minimal,
        timeout: Duration(seconds: 10),
      );

      // Assert
      expect(
        () => initializer.initialize(
          strategy: InitializationStrategy.minimal,
          timeout: Duration(seconds: 10),
        ),
        throwsA(isA<StateError>()),
      );

      await future1;

      // Cleanup
      initializer.dispose();
    });

    test('should throw error when disposed', () async {
      // Arrange
      final initializer = HierarchicalInitializer();
      initializer.dispose();

      // Act & Assert
      expect(
        () => initializer.initialize(
          strategy: InitializationStrategy.minimal,
          timeout: Duration(seconds: 10),
        ),
        throwsA(isA<StateError>()),
      );
    });

    test('should complete initialization within performance targets', () async {
      // Arrange
      final initializer = HierarchicalInitializer();
      final stopwatch = Stopwatch()..start();

      // Act
      await initializer.initialize(
        strategy: InitializationStrategy.adaptive,
        timeout: Duration(seconds: 5),
      );

      stopwatch.stop();

      // Assert
      // Should complete within 3 seconds target
      expect(stopwatch.elapsedMilliseconds, lessThan(3000));

      // Cleanup
      initializer.dispose();
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

    test('should have correct estimated durations', () {
      expect(InitializationStage.firebaseCore.estimatedMs, equals(800));
      expect(InitializationStage.authentication.estimatedMs, equals(1200));
      expect(InitializationStage.localsDirectory.estimatedMs, equals(1500));
      expect(InitializationStage.jobsData.estimatedMs, equals(2000));
    });

    test('should categorize stages correctly', () {
      expect(InitializationStage.firebaseCore.level, equals(0));
      expect(InitializationStage.userProfile.level, equals(1));
      expect(InitializationStage.localsDirectory.level, equals(2));
      expect(InitializationStage.crewFeatures.level, equals(3));
      expect(InitializationStage.analytics.level, equals(4));
    });

    test('should have proper display names', () {
      expect(InitializationStage.firebaseCore.displayName, equals('Firebase Services'));
      expect(InitializationStage.authentication.displayName, equals('Authentication'));
      expect(InitializationStage.userProfile.displayName, equals('User Profile'));
      expect(InitializationStage.localsDirectory.displayName, equals('Locals Directory'));
    });

    test('should have proper group names', () {
      expect(InitializationStage.firebaseCore.groupName, equals('Core Infrastructure'));
      expect(InitializationStage.userProfile.groupName, equals('User Data'));
      expect(InitializationStage.localsDirectory.groupName, equals('Core Data'));
      expect(InitializationStage.crewFeatures.groupName, equals('Features'));
      expect(InitializationStage.analytics.groupName, equals('Advanced'));
    });
  });

  group('Initialization Result Tests', () {
    test('should create successful result correctly', () {
      final result = InitializationResult.success(
        duration: Duration(milliseconds: 1500),
        strategy: InitializationStrategy.adaptive,
        stageResults: {},
        context: {},
      );

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.duration.inMilliseconds, equals(1500));
      expect(result.strategy, InitializationStrategy.adaptive);
    });

    test('should create failure result correctly', () {
      final result = InitializationResult.failure(
        duration: Duration(milliseconds: 500),
        strategy: InitializationStrategy.minimal,
        error: 'Test error',
        stackTrace: StackTrace.current,
        stageResults: {},
        context: {},
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.duration.inMilliseconds, equals(500));
      expect(result.error, equals('Test error'));
    });
  });
}