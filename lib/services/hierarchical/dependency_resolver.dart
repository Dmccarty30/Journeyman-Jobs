import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';

import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_dependency_graph.dart';

/// Dependency resolver for topological sorting and parallel execution planning
///
/// This class handles the complex logic of determining execution order based on
/// dependencies, identifying parallel execution opportunities, and optimizing
/// the initialization pipeline for maximum performance.
class DependencyResolver {
  DependencyResolver({
    int maxParallelStages = 4,
    Duration parallelTimeout = const Duration(seconds: 60),
  }) : _maxParallelStages = maxParallelStages,
       _parallelTimeout = parallelTimeout;

  final int _maxParallelStages;
  final Duration _parallelTimeout;

  final InitializationDependencyGraph _dependencyGraph = InitializationDependencyGraph();

  /// Resolves execution plan for all stages
  ExecutionPlan resolveExecutionPlan({
    Set<InitializationStage>? excludeStages,
    Set<InitializationStage>? prioritizeStages,
    Map<InitializationStage, double>? stageWeights,
  }) async {
    debugPrint('[DependencyResolver] Resolving execution plan...');

    final allStages = InitializationStage.values.toSet();
    final excluded = excludeStages ?? <InitializationStage>{};
    final prioritized = prioritizeStages ?? <InitializationStage>{};
    final weights = stageWeights ?? <InitializationStage, double>{};

    // Filter stages
    final relevantStages = allStages.difference(excluded);

    // Create execution groups based on dependencies
    final groups = await _createExecutionGroups(relevantStages, prioritized, weights);

    // Optimize execution order
    final optimizedGroups = _optimizeExecutionOrder(groups, prioritized, weights);

    // Calculate timing estimates
    final timingEstimates = _calculateTimingEstimates(optimizedGroups);

    // Identify critical path
    final criticalPath = _identifyCriticalPath(optimizedGroups);

    final plan = ExecutionPlan(
      groups: optimizedGroups,
      totalEstimatedDuration: timingEstimates.totalDuration,
      parallelismLevel: _calculateParallelismLevel(optimizedGroups),
      criticalPath: criticalPath,
      excludedStages: excluded,
      prioritizedStages: prioritized,
    );

    debugPrint('[DependencyResolver] Execution plan resolved: '
              '${plan.groups.length} groups, '
              '${plan.totalEstimatedDuration.inMilliseconds}ms total, '
              '${plan.parallelismLevel.toStringAsFixed(1)}x parallelism');

    return plan;
  }

  /// Gets next executable stages given current state
  List<InitializationStage> getNextExecutableStages(
    Set<InitializationStage> completedStages,
    Set<InitializationStage> inProgressStages, {
    int maxStages = 4,
  }) {
    final readyStages = <InitializationStage>[];

    for (final stage in InitializationStage.values) {
      if (completedStages.contains(stage) || inProgressStages.contains(stage)) {
        continue;
      }

      // Check if all dependencies are completed
      if (_canExecuteStage(stage, completedStages)) {
        readyStages.add(stage);
      }
    }

    // Sort by priority and weight
    readyStages.sort((a, b) {
      // Critical stages first
      if (a.isCritical && !b.isCritical) return -1;
      if (!a.isCritical && b.isCritical) return 1;

      // Then by priority
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;

      // Finally by estimated duration (shorter first for better UX)
      return a.estimatedMs.compareTo(b.estimatedMs);
    });

    // Limit number of parallel stages
    return readyStages.take(maxStages).toList();
  }

  /// Checks if a stage can be executed given completed stages
  bool canExecuteStage(
    InitializationStage stage,
    Set<InitializationStage> completedStages,
  ) {
    return _canExecuteStage(stage, completedStages);
  }

  /// Gets stages that are blocked by incomplete dependencies
  Set<InitializationStage> getBlockedStages(
    Set<InitializationStage> completedStages,
  ) {
    final blocked = <InitializationStage>{};

    for (final stage in InitializationStage.values) {
      if (!completedStages.contains(stage) && !_canExecuteStage(stage, completedStages)) {
        blocked.add(stage);
      }
    }

    return blocked;
  }

  /// Gets dependency depth for a stage
  int getDependencyDepth(InitializationStage stage) {
    var maxDepth = 0;
    final visited = <InitializationStage>{};

    int calculateDepth(InitializationStage currentStage) {
      if (visited.contains(currentStage)) return 0;
      visited.add(currentStage);

      var depth = 0;
      for (final dependency in currentStage.dependsOn) {
        depth = math.max(depth, 1 + calculateDepth(dependency));
      }

      return depth;
    }

    return calculateDepth(stage);
  }

  /// Calculates stage impact score
  double calculateStageImpact(InitializationStage stage) {
    final dependents = stage.allDependents;
    final depth = getDependencyDepth(stage);

    // Impact = (number of dependents) * (inverse of depth) * (criticality multiplier)
    final dependentMultiplier = math.log(dependents.length + 1);
    final depthMultiplier = 1.0 / (depth + 1);
    final criticalityMultiplier = stage.isCritical ? 2.0 : 1.0;

    return dependentMultiplier * depthMultiplier * criticalityMultiplier;
  }

  /// Validates dependency graph for cycles and other issues
  ValidationResult validateDependencyGraph() {
    debugPrint('[DependencyResolver] Validating dependency graph...');

    final issues = <ValidationIssue>[];

    try {
      // Check for cycles
      final cycles = _detectCycles();
      if (cycles.isNotEmpty) {
        for (final cycle in cycles) {
          issues.add(ValidationIssue(
            type: ValidationIssueType.cycle,
            severity: ValidationSeverity.critical,
            description: 'Dependency cycle detected: ${cycle.map((s) => s.displayName).join(' -> ')}',
            stages: cycle,
          ));
        }
      }

      // Check for unreachable stages
      final unreachable = _findUnreachableStages();
      if (unreachable.isNotEmpty) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.unreachable,
          severity: ValidationSeverity.warning,
          description: 'Stages with no dependencies or dependents: ${unreachable.map((s) => s.displayName).join(', ')}',
          stages: unreachable,
        ));
      }

      // Check for single points of failure
      final singlePoints = _findSinglePointsOfFailure();
      if (singlePoints.isNotEmpty) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.singlePointOfFailure,
          severity: ValidationSeverity.medium,
          description: 'Single points of failure: ${singlePoints.map((s) => s.displayName).join(', ')}',
          stages: singlePoints,
        ));
      }

      // Check for overly deep dependencies
      final overlyDeep = _findOverlyDeepDependencies();
      if (overlyDeep.isNotEmpty) {
        issues.add(ValidationIssue(
          type: ValidationIssueType.overlyDeep,
          severity: ValidationSeverity.low,
          description: 'Stages with deep dependencies: ${overlyDeep.entries.map((e) => '${e.key.displayName} (${e.value})').join(', ')}',
          stages: overlyDeep.keys.toList(),
        ));
      }

    } catch (e) {
      issues.add(ValidationIssue(
        type: ValidationIssueType.error,
        severity: ValidationSeverity.critical,
        description: 'Error during validation: $e',
        stages: [],
      ));
    }

    final isValid = issues.every((issue) => issue.severity != ValidationSeverity.critical);

    debugPrint('[DependencyResolver] Validation completed: '
              '${isValid ? 'VALID' : 'INVALID'}, ${issues.length} issues found');

    return ValidationResult(
      isValid: isValid,
      issues: issues,
    );
  }

  /// Optimizes execution order based on historical data
  ExecutionPlan optimizeExecutionOrder(
    ExecutionPlan originalPlan,
    Map<InitializationStage, Duration>? historicalDurations,
  ) async {
    debugPrint('[DependencyResolver] Optimizing execution order...');

    if (historicalDurations == null || historicalDurations.isEmpty) {
      return originalPlan;
    }

    // Create new groups with optimized ordering
    final optimizedGroups = <ExecutionGroup>[];

    for (final group in originalPlan.groups) {
      if (group.stages.length <= 1) {
        optimizedGroups.add(group);
        continue;
      }

      // Sort stages by historical duration (longest first in parallel groups)
      final sortedStages = List<InitializationStage>.from(group.stages);
      sortedStages.sort((a, b) {
        final durationA = historicalDurations[a] ?? a.estimatedDuration;
        final durationB = historicalDurations[b] ?? b.estimatedDuration;
        return durationB.compareTo(durationA); // Longest first
      });

      optimizedGroups.add(group.copyWith(stages: sortedStages));
    }

    return originalPlan.copyWith(groups: optimizedGroups);
  }

  // Private methods

  /// Creates execution groups based on dependencies
  Future<List<ExecutionGroup>> _createExecutionGroups(
    Set<InitializationStage> stages,
    Set<InitializationStage> prioritizedStages,
    Map<InitializationStage, double> stageWeights,
  ) async {
    final groups = <ExecutionGroup>[];
    final remainingStages = Set<InitializationStage>.from(stages);
    final completedStages = <InitializationStage>{};

    while (remainingStages.isNotEmpty) {
      final readyStages = <InitializationStage>[];

      // Find stages ready for execution
      for (final stage in remainingStages) {
        if (_canExecuteStage(stage, completedStages)) {
          readyStages.add(stage);
        }
      }

      if (readyStages.isEmpty) {
        throw StateError('Circular dependency detected or invalid dependency graph');
      }

      // Sort by priority and weight
      readyStages.sort((a, b) {
        // Prioritized stages first
        final aPrioritized = prioritizedStages.contains(a);
        final bPrioritized = prioritizedStages.contains(b);
        if (aPrioritized && !bPrioritized) return -1;
        if (!aPrioritized && bPrioritized) return 1;

        // Then by weight
        final aWeight = stageWeights[a] ?? 1.0;
        final bWeight = stageWeights[b] ?? 1.0;
        final weightComparison = bWeight.compareTo(aWeight);
        if (weightComparison != 0) return weightComparison;

        // Then by priority
        final priorityComparison = b.priority.compareTo(a.priority);
        if (priorityComparison != 0) return priorityComparison;

        // Finally by estimated duration
        return a.estimatedMs.compareTo(b.estimatedMs);
      });

      // Determine if we can execute in parallel
      final canRunInParallel = readyStages.every((stage) => stage.canRunInParallel) &&
                               readyStages.length <= _maxParallelStages;

      if (canRunInParallel) {
        // Create parallel group
        final group = ExecutionGroup(
          id: groups.length,
          type: ExecutionGroupType.parallel,
          stages: readyStages,
          estimatedDuration: _calculateGroupDuration(readyStages, true),
          level: groups.length,
        );
        groups.add(group);

        // Mark all stages as completed for dependency resolution
        completedStages.addAll(readyStages);
        remainingStages.removeAll(readyStages);

      } else {
        // Create sequential group (take highest priority stage)
        final stage = readyStages.first;
        final group = ExecutionGroup(
          id: groups.length,
          type: ExecutionGroupType.sequential,
          stages: [stage],
          estimatedDuration: stage.estimatedDuration,
          level: groups.length,
        );
        groups.add(group);

        completedStages.add(stage);
        remainingStages.remove(stage);
      }
    }

    return groups;
  }

  /// Optimizes execution order within groups
  List<ExecutionGroup> _optimizeExecutionOrder(
    List<ExecutionGroup> groups,
    Set<InitializationStage> prioritizedStages,
    Map<InitializationStage, double> stageWeights,
  ) {
    // For now, return groups as-is
    // In the future, this could implement more sophisticated optimization
    return groups;
  }

  /// Calculates timing estimates for groups
  TimingEstimates _calculateTimingEstimates(List<ExecutionGroup> groups) {
    var totalDuration = Duration.zero;
    var totalEstimatedDuration = Duration.zero;

    for (final group in groups) {
      totalDuration += group.estimatedDuration;
      totalEstimatedDuration += _calculateGroupEstimatedDuration(group);
    }

    return TimingEstimates(
      totalDuration: totalDuration,
      totalEstimatedDuration: totalEstimatedDuration,
      averageGroupDuration: groups.isNotEmpty ?
          Duration(milliseconds: (totalDuration.inMilliseconds / groups.length).round()) :
          Duration.zero,
    );
  }

  /// Identifies critical path through execution groups
  List<InitializationStage> _identifyCriticalPath(List<ExecutionGroup> groups) {
    // For now, use the dependency graph's critical path
    return _dependencyGraph.getCriticalPath();
  }

  /// Calculates parallelism level
  double _calculateParallelismLevel(List<ExecutionGroup> groups) {
    if (groups.isEmpty) return 0.0;

    var totalStages = 0;
    var parallelGroups = 0;

    for (final group in groups) {
      totalStages += group.stages.length;
      if (group.type == ExecutionGroupType.parallel) {
        parallelGroups++;
      }
    }

    final sequentialDuration = _dependencyGraph.getSequentialDuration().inMilliseconds;
    final parallelDuration = groups.fold<int>(0, (sum, group) => sum + group.estimatedDuration.inMilliseconds);

    return sequentialDuration > 0 ? sequentialDuration / parallelDuration : 1.0;
  }

  /// Checks if a stage can be executed
  bool _canExecuteStage(InitializationStage stage, Set<InitializationStage> completedStages) {
    return stage.dependsOn.every((dependency) => completedStages.contains(dependency));
  }

  /// Calculates group duration
  Duration _calculateGroupDuration(List<InitializationStage> stages, bool isParallel) {
    if (!isParallel || stages.length == 1) {
      return stages.fold<Duration>(
        Duration.zero,
        (sum, stage) => sum + stage.estimatedDuration,
      );
    }

    // For parallel groups, use the longest stage duration
    return stages
        .map((stage) => stage.estimatedDuration)
        .reduce((a, b) => a > b ? a : b);
  }

  /// Calculates estimated group duration
  Duration _calculateGroupEstimatedDuration(ExecutionGroup group) {
    return group.estimatedDuration; // For now, use the estimated duration
  }

  /// Detects cycles in dependency graph
  List<List<InitializationStage>> _detectCycles() {
    // Use the dependency graph's cycle detection
    // This is a simplified implementation
    final cycles = <List<InitializationStage>>[];
    final visited = <InitializationStage, DFSState>{};
    final path = <InitializationStage>[];

    for (final stage in InitializationStage.values) {
      if (visited[stage] != DFSState.visited) {
        _detectCyclesDFS(stage, visited, path, cycles);
      }
    }

    return cycles;
  }

  /// DFS helper for cycle detection
  void _detectCyclesDFS(
    InitializationStage stage,
    Map<InitializationStage, DFSState> visited,
    List<InitializationStage> path,
    List<List<InitializationStage>> cycles,
  ) {
    visited[stage] = DFSState.visiting;
    path.add(stage);

    for (final dependency in stage.dependsOn) {
      final dependencyState = visited[dependency];

      if (dependencyState == DFSState.visiting) {
        // Found a cycle
        final cycleStart = path.indexOf(dependency);
        if (cycleStart != -1) {
          cycles.add(path.sublist(cycleStart));
        }
      } else if (dependencyState == null) {
        _detectCyclesDFS(dependency, visited, path, cycles);
      }
    }

    visited[stage] = DFSState.visited;
    path.removeLast();
  }

  /// Finds unreachable stages
  Set<InitializationStage> _findUnreachableStages() {
    final reachable = <InitializationStage>{};
    final toVisit = Queue<InitializationStage>();

    // Start with stages that have no dependencies
    for (final stage in InitializationStage.values) {
      if (stage.dependsOn.isEmpty) {
        toVisit.add(stage);
        reachable.add(stage);
      }
    }

    // BFS to find all reachable stages
    while (toVisit.isNotEmpty) {
      final current = toVisit.removeFirst();
      for (final dependent in current.requiredFor) {
        if (!reachable.contains(dependent)) {
          reachable.add(dependent);
          toVisit.add(dependent);
        }
      }
    }

    return InitializationStage.values.difference(reachable);
  }

  /// Finds single points of failure
  Set<InitializationStage> _findSinglePointsOfFailure() {
    final singlePoints = <InitializationStage>{};

    for (final stage in InitializationStage.values) {
      if (stage.requiredFor.length > 3) { // Heuristic threshold
        singlePoints.add(stage);
      }
    }

    return singlePoints;
  }

  /// Finds overly deep dependencies
  Map<InitializationStage, int> _findOverlyDeepDependencies() {
    final deepDependencies = <InitializationStage, int>{};

    for (final stage in InitializationStage.values) {
      final depth = getDependencyDepth(stage);
      if (depth > 3) { // Heuristic threshold
        deepDependencies[stage] = depth;
      }
    }

    return deepDependencies;
  }
}

/// Execution plan containing groups and timing information
@immutable
class ExecutionPlan {
  const ExecutionPlan({
    required this.groups,
    required this.totalEstimatedDuration,
    required this.parallelismLevel,
    required this.criticalPath,
    required this.excludedStages,
    required this.prioritizedStages,
  });

  final List<ExecutionGroup> groups;
  final Duration totalEstimatedDuration;
  final double parallelismLevel;
  final List<InitializationStage> criticalPath;
  final Set<InitializationStage> excludedStages;
  final Set<InitializationStage> prioritizedStages;

  int get totalStages => groups.fold<int>(0, (sum, group) => sum + group.stages.length);
  int get parallelGroups => groups.where((g) => g.type == ExecutionGroupType.parallel).length;
  int get sequentialGroups => groups.where((g) => g.type == ExecutionGroupType.sequential).length;

  ExecutionPlan copyWith({
    List<ExecutionGroup>? groups,
    Duration? totalEstimatedDuration,
    double? parallelismLevel,
    List<InitializationStage>? criticalPath,
    Set<InitializationStage>? excludedStages,
    Set<InitializationStage>? prioritizedStages,
  }) {
    return ExecutionPlan(
      groups: groups ?? this.groups,
      totalEstimatedDuration: totalEstimatedDuration ?? this.totalEstimatedDuration,
      parallelismLevel: parallelismLevel ?? this.parallelismLevel,
      criticalPath: criticalPath ?? this.criticalPath,
      excludedStages: excludedStages ?? this.excludedStages,
      prioritizedStages: prioritizedStages ?? this.prioritizedStages,
    );
  }

  @override
  String toString() {
    return 'ExecutionPlan('
        'groups: ${groups.length}, '
        'totalStages: $totalStages, '
        'duration: ${totalEstimatedDuration.inMilliseconds}ms, '
        'parallelism: ${parallelismLevel.toStringAsFixed(1)}x, '
        'criticalPath: ${criticalPath.length} stages'
        ')';
  }
}

/// Execution group containing stages that can be executed together
@immutable
class ExecutionGroup {
  const ExecutionGroup({
    required this.id,
    required this.type,
    required this.stages,
    required this.estimatedDuration,
    required this.level,
  });

  final int id;
  final ExecutionGroupType type;
  final List<InitializationStage> stages;
  final Duration estimatedDuration;
  final int level;

  bool get isParallel => type == ExecutionGroupType.parallel;
  bool get isSequential => type == ExecutionGroupType.sequential;
  bool get isCritical => stages.any((stage) => stage.isCritical);

  ExecutionGroup copyWith({
    int? id,
    ExecutionGroupType? type,
    List<InitializationStage>? stages,
    Duration? estimatedDuration,
    int? level,
  }) {
    return ExecutionGroup(
      id: id ?? this.id,
      type: type ?? this.type,
      stages: stages ?? this.stages,
      estimatedDuration: estimatedDuration ?? this.estimatedDuration,
      level: level ?? this.level,
    );
  }

  @override
  String toString() {
    return 'ExecutionGroup('
        'id: $id, '
        'type: $type, '
        'stages: ${stages.length}, '
        'level: $level, '
        'duration: ${estimatedDuration.inMilliseconds}ms'
        ')';
  }
}

/// Execution group types
enum ExecutionGroupType {
  sequential,  // Stages must execute one after another
  parallel,    // Stages can execute simultaneously
}

/// Timing estimates for execution plan
@immutable
class TimingEstimates {
  const TimingEstimates({
    required this.totalDuration,
    required this.totalEstimatedDuration,
    required this.averageGroupDuration,
  });

  final Duration totalDuration;
  final Duration totalEstimatedDuration;
  final Duration averageGroupDuration;

  @override
  String toString() {
    return 'TimingEstimates('
        'total: ${totalDuration.inMilliseconds}ms, '
        'estimated: ${totalEstimatedDuration.inMilliseconds}ms, '
        'average: ${averageGroupDuration.inMilliseconds}ms'
        ')';
  }
}

/// Validation result for dependency graph
@immutable
class ValidationResult {
  const ValidationResult({
    required this.isValid,
    required this.issues,
  });

  final bool isValid;
  final List<ValidationIssue> issues;

  bool get hasCriticalIssues => issues.any((issue) => issue.severity == ValidationSeverity.critical);
  bool get hasWarnings => issues.any((issue) => issue.severity == ValidationSeverity.warning);

  @override
  String toString() {
    return 'ValidationResult('
        'valid: $isValid, '
        'issues: ${issues.length}, '
        'critical: ${issues.where((i) => i.severity == ValidationSeverity.critical).length}'
        ')';
  }
}

/// Validation issue
@immutable
class ValidationIssue {
  const ValidationIssue({
    required this.type,
    required this.severity,
    required this.description,
    required this.stages,
  });

  final ValidationIssueType type;
  final ValidationSeverity severity;
  final String description;
  final List<InitializationStage> stages;

  @override
  String toString() {
    return 'ValidationIssue('
        'type: $type, '
        'severity: $severity, '
        'description: $description'
        ')';
  }
}

/// Validation issue types
enum ValidationIssueType {
  cycle,
  unreachable,
  singlePointOfFailure,
  overlyDeep,
  error,
}

/// Validation severity levels
enum ValidationSeverity {
  low,
  medium,
  warning,
  critical,
}

/// DFS state for cycle detection
enum DFSState {
  unvisited,
  visiting,
  visited,
}