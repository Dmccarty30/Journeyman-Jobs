import 'package:flutter_test/flutter_test.dart';

import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';

void main() {
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

    test('should calculate total estimated duration correctly', () {
      final totalDuration = InitializationStage.values
          .fold<int>(0, (sum, stage) => sum + stage.estimatedMs);

      expect(totalDuration, greaterThan(8000)); // Should be substantial
      expect(totalDuration, lessThan(20000)); // But not too large
    });

    test('should identify stages by level correctly', () {
      final level0 = InitializationStage.values.where((s) => s.level == 0).toList();
      final level1 = InitializationStage.values.where((s) => s.level == 1).toList();
      final level2 = InitializationStage.values.where((s) => s.level == 2).toList();
      final level3 = InitializationStage.values.where((s) => s.level == 3).toList();
      final level4 = InitializationStage.values.where((s) => s.level == 4).toList();

      expect(level0.length, equals(3)); // firebaseCore, authentication, sessionManagement
      expect(level1.length, equals(2)); // userProfile, userPreferences
      expect(level2.length, equals(2)); // localsDirectory, jobsData
      expect(level3.length, equals(3)); // crewFeatures, weatherServices, notifications
      expect(level4.length, equals(3)); // offlineSync, backgroundTasks, analytics
    });

    test('should have correct parallel execution capabilities', () {
      final parallelStages = InitializationStage.values
          .where((stage) => stage.canRunInParallel)
          .toList();

      expect(parallelStages.length, greaterThan(5));
      expect(parallelStages, contains(InitializationStage.userProfile));
      expect(parallelStages, contains(InitializationStage.userPreferences));
      expect(parallelStages, contains(InitializationStage.localsDirectory));
      expect(parallelStages, contains(InitializationStage.jobsData));
    });

    test('should validate execution order dependencies', () {
      // This test ensures the dependency graph is acyclic
      final allStages = InitializationStage.values;
      final visited = <InitializationStage>{};
      final recursionStack = <InitializationStage>{};

      bool hasCycle(InitializationStage stage) {
        if (recursionStack.contains(stage)) return true;
        if (visited.contains(stage)) return false;

        visited.add(stage);
        recursionStack.add(stage);

        for (final dependency in stage.dependsOn) {
          if (hasCycle(dependency)) return true;
        }

        recursionStack.remove(stage);
        return false;
      }

      for (final stage in allStages) {
        expect(hasCycle(stage), isFalse, reason: 'Cycle detected in dependencies for $stage');
      }
    });

    test('should calculate critical path correctly', () {
      final criticalStages = InitializationStage.values.where((s) => s.isCritical);

      // Critical stages should include core infrastructure
      expect(criticalStages, contains(InitializationStage.firebaseCore));
      expect(criticalStages, contains(InitializationStage.authentication));
      expect(criticalStages, contains(InitializationStage.sessionManagement));

      // Critical stages should include core data
      expect(criticalStages, contains(InitializationStage.userProfile));
      expect(criticalStages, contains(InitializationStage.localsDirectory));
      expect(criticalStages, contains(InitializationStage.jobsData));

      // Non-critical stages
      final nonCriticalStages = InitializationStage.values.where((s) => !s.isCritical);
      expect(nonCriticalStages, contains(InitializationStage.userPreferences));
      expect(nonCriticalStages, contains(InitializationStage.crewFeatures));
      expect(nonCriticalStages, contains(InitializationStage.weatherServices));
      expect(nonCriticalStages, contains(InitializationStage.notifications));
      expect(nonCriticalStages, contains(InitializationStage.offlineSync));
      expect(nonCriticalStages, contains(InitializationStage.backgroundTasks));
      expect(nonCriticalStages, contains(InitializationStage.analytics));
    });

    test('should provide meaningful string representations', () {
      for (final stage in InitializationStage.values) {
        expect(stage.displayName, isNotEmpty);
        expect(stage.description, isNotEmpty);
        expect(stage.toString(), equals(stage.displayName));
      }
    });

    test('should validate stage metadata consistency', () {
      for (final stage in InitializationStage.values) {
        // Validate estimated duration is positive
        expect(stage.estimatedMs, greaterThan(0));

        // Validate display name is not empty
        expect(stage.displayName, isNotEmpty);
        expect(stage.displayName.length, greaterThan(2));

        // Validate description is not empty
        expect(stage.description, isNotEmpty);
        expect(stage.description.length, greaterThan(10));

        // Validate level is within expected range
        expect(stage.level, greaterThanOrEqualTo(0));
        expect(stage.level, lessThanOrEqualTo(4));
      }
    });
  });

  group('Stage Execution Result Tests', () {
    test('should create successful result correctly', () {
      final startTime = DateTime.now().subtract(Duration(seconds: 1));
      final endTime = DateTime.now();

      final result = StageExecutionResult(
        stage: InitializationStage.firebaseCore,
        status: StageStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );

      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.isSkipped, isFalse);
      expect(result.stage, InitializationStage.firebaseCore);
      expect(result.duration.inMilliseconds, greaterThan(0));
    });

    test('should create failed result correctly', () {
      final startTime = DateTime.now().subtract(Duration(seconds: 1));
      final endTime = DateTime.now();

      final result = StageExecutionResult(
        stage: InitializationStage.authentication,
        status: StageStatus.failed,
        startTime: startTime,
        endTime: endTime,
        error: 'Authentication failed',
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isTrue);
      expect(result.isSkipped, isFalse);
      expect(result.stage, InitializationStage.authentication);
      expect(result.error, equals('Authentication failed'));
    });

    test('should create skipped result correctly', () {
      final startTime = DateTime.now().subtract(Duration(seconds: 1));
      final endTime = DateTime.now();

      final result = StageExecutionResult(
        stage: InitializationStage.crewFeatures,
        status: StageStatus.skipped,
        startTime: startTime,
        endTime: endTime,
      );

      expect(result.isSuccess, isFalse);
      expect(result.isFailure, isFalse);
      expect(result.isSkipped, isTrue);
      expect(result.stage, InitializationStage.crewFeatures);
    });
  });

  group('Stage Status Tests', () {
    test('should have correct status values', () {
      expect(StageStatus.pending.name, equals('pending'));
      expect(StageStatus.inProgress.name, equals('inProgress'));
      expect(StageStatus.completed.name, equals('completed'));
      expect(StageStatus.failed.name, equals('failed'));
      expect(StageStatus.skipped.name, equals('skipped'));
    });
  });
}