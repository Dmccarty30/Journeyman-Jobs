import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_stage.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_dependency_graph.dart';
import 'package:journeyman_jobs/models/hierarchical/initialization_metadata.dart';

void main() {
  group('InitializationStage Enum Tests', () {
    test('should have correct number of stages', () {
      expect(InitializationStage.values.length, equals(12));
    });

    test('should have correct hierarchy levels', () {
      // Level 0: Core infrastructure
      final level0Stages = InitializationStage.values.where((s) => s.level == 0);
      expect(level0Stages.length, equals(3));
      expect(level0Stages.contains(InitializationStage.firebaseCore), isTrue);
      expect(level0Stages.contains(InitializationStage.authentication), isTrue);
      expect(level0Stages.contains(InitializationStage.sessionManagement), isTrue);

      // Level 1: User data
      final level1Stages = InitializationStage.values.where((s) => s.level == 1);
      expect(level1Stages.length, equals(2));
      expect(level1Stages.contains(InitializationStage.userProfile), isTrue);
      expect(level1Stages.contains(InitializationStage.userPreferences), isTrue);

      // Level 2: Core data
      final level2Stages = InitializationStage.values.where((s) => s.level == 2);
      expect(level2Stages.length, equals(2));
      expect(level2Stages.contains(InitializationStage.localsDirectory), isTrue);
      expect(level2Stages.contains(InitializationStage.jobsData), isTrue);

      // Level 3: Features
      final level3Stages = InitializationStage.values.where((s) => s.level == 3);
      expect(level3Stages.length, equals(3));
      expect(level3Stages.contains(InitializationStage.crewFeatures), isTrue);
      expect(level3Stages.contains(InitializationStage.weatherServices), isTrue);
      expect(level3Stages.contains(InitializationStage.notifications), isTrue);

      // Level 4: Advanced
      final level4Stages = InitializationStage.values.where((s) => s.level == 4);
      expect(level4Stages.length, equals(3));
      expect(level4Stages.contains(InitializationStage.offlineSync), isTrue);
      expect(level4Stages.contains(InitializationStage.backgroundTasks), isTrue);
      expect(level4Stages.contains(InitializationStage.analytics), isTrue);
    });

    test('should have correct critical stages', () {
      final criticalStages = InitializationStage.values.where((s) => s.isCritical);
      expect(criticalStages.length, equals(5));

      expect(criticalStages.contains(InitializationStage.firebaseCore), isTrue);
      expect(criticalStages.contains(InitializationStage.authentication), isTrue);
      expect(criticalStages.contains(InitializationStage.sessionManagement), isTrue);
      expect(criticalStages.contains(InitializationStage.userProfile), isTrue);
      expect(criticalStages.contains(InitializationStage.localsDirectory), isTrue);
      expect(criticalStages.contains(InitializationStage.jobsData), isTrue);
    });

    test('should have correct parallel execution capabilities', () {
      final parallelStages = InitializationStage.values.where((s) => s.canRunInParallel);
      expect(parallelStages.length, equals(9));

      // Non-parallel stages
      expect(InitializationStage.firebaseCore.canRunInParallel, isFalse);
      expect(InitializationStage.authentication.canRunInParallel, isFalse);
      expect(InitializationStage.sessionManagement.canRunInParallel, isFalse);
    });

    test('should have correct dependencies', () {
      // Core infrastructure dependencies
      expect(InitializationStage.authentication.dependsOn,
             contains(InitializationStage.firebaseCore));
      expect(InitializationStage.sessionManagement.dependsOn,
             contains(InitializationStage.authentication));

      // User data dependencies
      expect(InitializationStage.userProfile.dependsOn,
             contains(InitializationStage.sessionManagement));
      expect(InitializationStage.userPreferences.dependsOn,
             contains(InitializationStage.sessionManagement));

      // Core data dependencies
      expect(InitializationStage.localsDirectory.dependsOn,
             contains(InitializationStage.userProfile));
      expect(InitializationStage.jobsData.dependsOn,
             contains(InitializationStage.userProfile));
      expect(InitializationStage.jobsData.dependsOn,
             contains(InitializationStage.userPreferences));

      // Feature dependencies
      expect(InitializationStage.crewFeatures.dependsOn,
             contains(InitializationStage.localsDirectory));
      expect(InitializationStage.crewFeatures.dependsOn,
             contains(InitializationStage.jobsData));
      expect(InitializationStage.notifications.dependsOn,
             contains(InitializationStage.userPreferences));
    });

    test('should compute priority correctly', () {
      // Critical stages should have higher priority
      expect(InitializationStage.firebaseCore.priority, greaterThan(90));
      expect(InitializationStage.authentication.priority, greaterThan(90));
      expect(InitializationStage.sessionManagement.priority, greaterThan(90));

      // Non-critical stages should have lower priority
      expect(InitializationStage.analytics.priority, lessThan(50));
      expect(InitializationStage.backgroundTasks.priority, lessThan(50));
    });
  });

  group('InitializationStage Extensions Tests', () {
    test('should compute all dependencies correctly', () {
      final firebaseDeps = InitializationStage.firebaseCore.allDependencies;
      expect(firebaseDeps.isEmpty, isTrue);

      final sessionDeps = InitializationStage.sessionManagement.allDependencies;
      expect(sessionDeps.length, equals(2));
      expect(sessionDeps.contains(InitializationStage.firebaseCore), isTrue);
      expect(sessionDeps.contains(InitializationStage.authentication), isTrue);

      final crewDeps = InitializationStage.crewFeatures.allDependencies;
      expect(crewDeps.length, greaterThan(4));
      expect(crewDeps.contains(InitializationStage.firebaseCore), isTrue);
      expect(crewDeps.contains(InitializationStage.authentication), isTrue);
      expect(crewDeps.contains(InitializationStage.sessionManagement), isTrue);
      expect(crewDeps.contains(InitializationStage.userProfile), isTrue);
    });

    test('should compute all dependents correctly', () {
      final firebaseDependents = InitializationStage.firebaseCore.allDependents;
      expect(firebaseDependents.length, greaterThan(8));
      expect(firebaseDependents.contains(InitializationStage.authentication), isTrue);

      final analyticsDependents = InitializationStage.analytics.allDependents;
      expect(analyticsDependents.isEmpty, isTrue);
    });

    test('should check dependency relationships correctly', () {
      expect(InitializationStage.authentication.dependsOnStage(InitializationStage.firebaseCore), isTrue);
      expect(InitializationStage.firebaseCore.dependsOnStage(InitializationStage.authentication), isFalse);

      expect(InitializationStage.firebaseCore.isRequiredForStage(InitializationStage.authentication), isTrue);
      expect(InitializationStage.authentication.isRequiredForStage(InitializationStage.firebaseCore), isFalse);
    });

    test('should generate status strings correctly', () {
      final completedStatus = InitializationStage.userProfile.getStatusString(true, false);
      expect(completedStatus, contains('✅'));
      expect(completedStatus, contains('Complete'));

      final inProgressStatus = InitializationStage.userProfile.getStatusString(false, true);
      expect(inProgressStatus, contains('🔄'));
      expect(inProgressStatus, contains('in Progress'));

      final pendingStatus = InitializationStage.userProfile.getStatusString(false, false);
      expect(pendingStatus, contains('⏳'));
      expect(pendingStatus, contains('Pending'));
    });

    test('should compute progress percentages correctly', () {
      expect(InitializationStage.userProfile.getProgressPercentage(true, false), equals(1.0));
      expect(InitializationStage.userProfile.getProgressPercentage(false, true), equals(0.5));
      expect(InitializationStage.userProfile.getProgressPercentage(false, false), equals(0.0));
    });
  });

  group('Static Methods Tests', () {
    test('should get all stages ordered correctly', () {
      final orderedStages = InitializationStage.allStagesOrdered;
      expect(orderedStages.length, equals(InitializationStage.values.length));

      // Should be ordered by level first
      for (var i = 1; i < orderedStages.length; i++) {
        expect(orderedStages[i].level,
               greaterThanOrEqualTo(orderedStages[i - 1].level));
      }

      // First stage should be firebaseCore (no dependencies)
      expect(orderedStages.first, equals(InitializationStage.firebaseCore));
    });

    test('should get parallel stages by level', () {
      final level0Parallel = InitializationStage.getParallelStages(0);
      expect(level0Parallel.isEmpty, isTrue); // Level 0 stages can't run in parallel

      final level1Parallel = InitializationStage.getParallelStages(1);
      expect(level1Parallel.length, equals(2));
      expect(level1Parallel.contains(InitializationStage.userProfile), isTrue);
      expect(level1Parallel.contains(InitializationStage.userPreferences), isTrue);

      final level2Parallel = InitializationStage.getParallelStages(2);
      expect(level2Parallel.length, equals(2));
      expect(level2Parallel.contains(InitializationStage.localsDirectory), isTrue);
      expect(level2Parallel.contains(InitializationStage.jobsData), isTrue);
    });

    test('should compute critical path correctly', () {
      final criticalPath = InitializationStage.criticalPath;
      expect(criticalPath.isNotEmpty, isTrue);

      // Should include all critical stages
      final criticalStages = InitializationStage.values.where((s) => s.isCritical);
      for (final stage in criticalStages) {
        expect(criticalPath.contains(stage), isTrue, reason: '$stage should be in critical path');
      }

      // Should be in dependency order
      for (var i = 1; i < criticalPath.length; i++) {
        final current = criticalPath[i];
        final previous = criticalPath[i - 1];
        expect(current.dependsOnStage(previous), isTrue,
               reason: '$current should depend on $previous in critical path');
      }
    });

    test('should determine executable stages correctly', () {
      // Empty completed set
      final emptyCompleted = <InitializationStage>{};
      final readyStages = InitializationStage.getNextExecutableStages(emptyCompleted);
      expect(readyStages.length, equals(1));
      expect(readyStages.first, equals(InitializationStage.firebaseCore));

      // After firebaseCore is completed
      final firebaseCompleted = {InitializationStage.firebaseCore};
      final afterFirebase = InitializationStage.getNextExecutableStages(firebaseCompleted);
      expect(afterFirebase.length, equals(1));
      expect(afterFirebase.first, equals(InitializationStage.authentication));

      // Can execute stage with all dependencies met
      final sessionCompleted = {
        InitializationStage.firebaseCore,
        InitializationStage.authentication,
        InitializationStage.sessionManagement,
      };
      final afterSession = InitializationStage.getNextExecutableStages(sessionCompleted);
      expect(afterSession.length, equals(2));
      expect(afterSession.contains(InitializationStage.userProfile), isTrue);
      expect(afterSession.contains(InitializationStage.userPreferences), isTrue);
    });

    test('should check stage execution eligibility correctly', () {
      final completed = {InitializationStage.firebaseCore};

      expect(InitializationStage.canExecuteStage(InitializationStage.firebaseCore, completed), isFalse);
      expect(InitializationStage.canExecuteStage(InitializationStage.authentication, completed), isTrue);
      expect(InitializationStage.canExecuteStage(InitializationStage.sessionManagement, completed), isFalse);
      expect(InitializationStage.canExecuteStage(InitializationStage.userProfile, completed), isFalse);
    });
  });

  group('InitializationDependencyGraph Tests', () {
    late InitializationDependencyGraph graph;

    setUp(() {
      graph = InitializationDependencyGraph();
    });

    test('should build graph without cycles', () {
      // Should not throw during construction
      expect(graph, isNotNull);
    });

    test('should compute topological order correctly', () {
      final order = graph.getTopologicalOrder();
      expect(order.length, equals(InitializationStage.values.length));

      // firebaseCore should be first
      expect(order.first, equals(InitializationStage.firebaseCore));

      // Dependencies should come before dependents
      for (var i = 0; i < order.length; i++) {
        final stage = order[i];
        for (final dependency in stage.dependsOn) {
          final depIndex = order.indexOf(dependency);
          expect(depIndex, lessThan(i),
                 reason: '$dependency should come before $stage in topological order');
        }
      }
    });

    test('should create parallel execution plan correctly', () {
      final plan = graph.getParallelExecutionPlan();
      expect(plan.isNotEmpty, isTrue);

      // Should have levels 0-4
      for (var level = 0; level <= 4; level++) {
        expect(plan.containsKey(level), isTrue, reason: 'Plan should contain level $level');
      }

      // Level 0 should have only firebaseCore
      expect(plan[0]!.length, equals(1));
      expect(plan[0]!.first, equals(InitializationStage.firebaseCore));

      // Level 1 should have authentication only (can't run in parallel)
      expect(plan[1]!.length, equals(1));
      expect(plan[1]!.first, equals(InitializationStage.authentication));

      // Higher levels should have multiple stages where possible
      expect(plan[2]!.length, equals(1)); // sessionManagement
      expect(plan[3]!.length, equals(2)); // userProfile and userPreferences
    });

    test('should compute critical path correctly', () {
      final criticalPath = graph.getCriticalPath();
      expect(criticalPath.isNotEmpty, isTrue);

      // Should start with firebaseCore
      expect(criticalPath.first, equals(InitializationStage.firebaseCore));

      // Should be in dependency order
      for (var i = 1; i < criticalPath.length; i++) {
        final current = criticalPath[i];
        final previous = criticalPath[i - 1];
        expect(current.dependsOnStage(previous), isTrue);
      }
    });

    test('should estimate durations correctly', () {
      final sequentialDuration = graph.getSequentialDuration();
      final parallelDuration = graph.getParallelDuration();

      expect(sequentialDuration.inMilliseconds, greaterThan(0));
      expect(parallelDuration.inMilliseconds, greaterThan(0));
      expect(parallelDuration.inMilliseconds, lessThan(sequentialDuration.inMilliseconds));

      final speedupRatio = sequentialDuration.inMilliseconds / parallelDuration.inMilliseconds;
      expect(speedupRatio, greaterThan(1.0));
    });

    test('should identify ready stages correctly', () {
      final completed = <InitializationStage>{};
      final ready = graph.getReadyStages(completed);
      expect(ready.length, equals(1));
      expect(ready.first, equals(InitializationStage.firebaseCore));

      final afterFirebase = {InitializationStage.firebaseCore};
      final readyAfterFirebase = graph.getReadyStages(afterFirebase);
      expect(readyAfterFirebase.length, equals(1));
      expect(readyAfterFirebase.first, equals(InitializationStage.authentication));
    });

    test('should identify parallel ready stages correctly', () {
      final completed = {
        InitializationStage.firebaseCore,
        InitializationStage.authentication,
        InitializationStage.sessionManagement,
      };

      // No stages in progress
      final parallelReady = graph.getParallelReadyStages(completed, {});
      expect(parallelReady.length, equals(2)); // userProfile and userPreferences
      expect(parallelReady.contains(InitializationStage.userProfile), isTrue);
      expect(parallelReady.contains(InitializationStage.userPreferences), isTrue);

      // One stage in progress (non-parallel)
      final withInProgress = graph.getParallelReadyStages(
        completed,
        {InitializationStage.userProfile}
      );
      expect(withInProgress.length, equals(1)); // Only userPreferences ready
      expect(withInProgress.first, equals(InitializationStage.userPreferences));
    });

    test('should check parallel execution compatibility', () {
      // Same stage can't run in parallel with itself
      expect(graph.canStagesRunInParallel(InitializationStage.userProfile, InitializationStage.userProfile), isFalse);

      // Stages at different levels can't run in parallel
      expect(graph.canStagesRunInParallel(InitializationStage.userProfile, InitializationStage.firebaseCore), isFalse);

      // Dependent stages can't run in parallel
      expect(graph.canStagesRunInParallel(InitializationStage.userProfile, InitializationStage.sessionManagement), isFalse);

      // Compatible stages can run in parallel
      expect(graph.canStagesRunInParallel(InitializationStage.userProfile, InitializationStage.userPreferences), isTrue);
    });

    test('should identify bottleneck stages', () {
      final bottlenecks = graph.getBottleneckStages();
      expect(bottlenecks.isNotEmpty, isTrue);

      // userProfile should be a bottleneck (many dependents)
      expect(bottlenecks.contains(InitializationStage.userProfile), isTrue);

      // sessionManagement should be a bottleneck
      expect(bottlenecks.contains(InitializationStage.sessionManagement), isTrue);
    });

    test('should generate statistics correctly', () {
      final stats = graph.getStatistics();
      expect(stats['totalStages'], equals(12));
      expect(stats['levels'], equals(5));
      expect(stats['criticalStages'], equals(5));
      expect(stats['parallelStages'], equals(9));
      expect(stats['sequentialDuration'], greaterThan(0));
      expect(stats['parallelDuration'], greaterThan(0));
      expect(stats['speedupRatio'], greaterThan(1.0));
    });
  });

  group('InitializationMetadata Tests', () {
    late InitializationMetadata metadata;

    setUp(() {
      metadata = InitializationMetadata.instance;
      metadata.initialize();
    });

    test('should initialize metadata for all stages', () {
      for (final stage in InitializationStage.values) {
        final stageMetadata = metadata.getMetadata(stage);
        expect(stageMetadata.stage, equals(stage));
        expect(stageMetadata.estimatedDuration, equals(stage.estimatedDuration));
        expect(stageMetadata.isCritical, equals(stage.isCritical));
        expect(stageMetadata.canRunInParallel, equals(stage.canRunInParallel));
      }
    });

    test('should create appropriate retry policies', () {
      final firebaseRetry = metadata.getMetadata(InitializationStage.firebaseCore).retryPolicy;
      expect(firebaseRetry.maxRetries, equals(3));
      expect(firebaseRetry.backoffStrategy, equals(BackoffStrategy.exponential));

      final analyticsRetry = metadata.getMetadata(InitializationStage.analytics).retryPolicy;
      expect(analyticsRetry.maxRetries, equals(1));
      expect(analyticsRetry.backoffStrategy, equals(BackoffStrategy.linear));
    });

    test('should create appropriate timeout policies', () {
      final firebaseTimeout = metadata.getMetadata(InitializationStage.firebaseCore).timeoutPolicy;
      expect(firebaseTimeout.timeout.inMilliseconds,
             equals(InitializationStage.firebaseCore.estimatedMs * 3));

      final userProfileTimeout = metadata.getMetadata(InitializationStage.userProfile).timeoutPolicy;
      expect(userProfileTimeout.timeout.inMilliseconds,
             equals(InitializationStage.userProfile.estimatedMs * 3));
    });

    test('should record execution history correctly', () {
      final execution = StageExecutionHistory(
        stage: InitializationStage.userProfile,
        startTime: DateTime.now().subtract(Duration(seconds: 2)),
        endTime: DateTime.now(),
        isSuccess: true,
        retryCount: 0,
      );

      metadata.recordExecution(execution);

      final stageMetadata = metadata.getMetadata(InitializationStage.userProfile);
      expect(stageMetadata.performanceMetrics.totalExecutions, equals(1));
      expect(stageMetadata.performanceMetrics.lastExecution, isNotNull);
    });

    test('should update performance metrics based on history', () {
      // Record multiple successful executions
      final baseTime = DateTime.now();
      for (var i = 0; i < 5; i++) {
        final execution = StageExecutionHistory(
          stage: InitializationStage.userProfile,
          startTime: baseTime.add(Duration(seconds: i * 10)),
          endTime: baseTime.add(Duration(seconds: i * 10 + 1)),
          isSuccess: true,
          retryCount: 0,
        );
        metadata.recordExecution(execution);
      }

      final stageMetadata = metadata.getMetadata(InitializationStage.userProfile);
      expect(stageMetadata.performanceMetrics.totalExecutions, equals(5));
      expect(stageMetadata.successRate, equals(1.0));
    });

    test('should compute progress estimates correctly', () {
      final elapsed = Duration(milliseconds: 500);
      final progress = metadata.getProgressEstimate(InitializationStage.userProfile, elapsed);
      expect(progress, greaterThan(0.0));
      expect(progress, lessThan(1.0));
    });

    test('should generate timing estimates', () {
      final estimates = metadata.getTimingEstimates(useHistoricalData: false);
      expect(estimates.sequential.inMilliseconds, greaterThan(0));
      expect(estimates.parallel.inMilliseconds, greaterThan(0));
      expect(estimates.speedupRatio, greaterThan(1.0));
      expect(estimates.stageEstimates.length, equals(InitializationStage.values.length));
    });

    test('should generate execution recommendations', () {
      // Record some failed executions to trigger recommendations
      for (var i = 0; i < 5; i++) {
        final execution = StageExecutionHistory(
          stage: InitializationStage.userProfile,
          startTime: DateTime.now().subtract(Duration(seconds: i * 10)),
          endTime: DateTime.now().subtract(Duration(seconds: i * 10 - 1)),
          isSuccess: false, // Failed execution
          error: 'Test error',
          retryCount: 0,
        );
        metadata.recordExecution(execution);
      }

      final recommendations = metadata.getExecutionRecommendations();
      expect(recommendations.hasRecommendations, isTrue);
    });
  });

  group('Stage Execution Result Tests', () {
    test('should create execution results correctly', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(seconds: 1));

      final result = StageExecutionResult(
        stage: InitializationStage.userProfile,
        status: StageStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );

      expect(result.stage, equals(InitializationStage.userProfile));
      expect(result.status, equals(StageStatus.completed));
      expect(result.isSuccess, isTrue);
      expect(result.isFailure, isFalse);
      expect(result.duration.inSeconds, equals(1));
    });

    test('should compare execution results correctly', () {
      final startTime = DateTime.now();
      final endTime = startTime.add(Duration(seconds: 1));

      final result1 = StageExecutionResult(
        stage: InitializationStage.userProfile,
        status: StageStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );

      final result2 = StageExecutionResult(
        stage: InitializationStage.userProfile,
        status: StageStatus.completed,
        startTime: startTime,
        endTime: endTime,
      );

      expect(result1, equals(result2));
      expect(result1.hashCode, equals(result2.hashCode));
    });
  });

  group('Stage Metrics Tests', () {
    test('should compute cache hit rate correctly', () {
      final metrics = StageMetrics(
        memoryUsageMB: 50.0,
        networkRequests: 10,
        cacheHits: 8,
        cacheMisses: 2,
        errorCount: 0,
      );

      expect(metrics.cacheHitRate, equals(0.8));
    });

    test('should handle edge cases in cache hit rate', () {
      final noCacheMetrics = StageMetrics(
        memoryUsageMB: 50.0,
        networkRequests: 10,
        cacheHits: 0,
        cacheMisses: 0,
        errorCount: 0,
      );

      expect(noCacheMetrics.cacheHitRate, equals(0.0));
    });
  });
}