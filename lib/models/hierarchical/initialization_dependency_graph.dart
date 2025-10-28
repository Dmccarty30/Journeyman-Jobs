import 'dart:collection';
import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'initialization_stage.dart';

/// Dependency graph utility for managing initialization stage relationships
///
/// This class provides utilities for:
/// - Building and managing dependency graphs
/// - Critical path analysis
/// - Parallel execution planning
/// - Cycle detection and validation
/// - Execution order calculation
class InitializationDependencyGraph {
  InitializationDependencyGraph() {
    _buildGraph();
  }

  /// Internal adjacency list representation of the graph
  final Map<InitializationStage, Set<InitializationStage>> _adjacencyList = {};

  /// Reverse adjacency list for efficient dependent lookups
  final Map<InitializationStage, Set<InitializationStage>> _reverseAdjacencyList = {};

  /// Cache for computed values
  final Map<String, dynamic> _cache = {};

  /// Build the dependency graph from stage definitions
  void _buildGraph() {
    _adjacencyList.clear();
    _reverseAdjacencyList.clear();

    // Initialize adjacency lists for all stages
    for (final stage in InitializationStage.values) {
      _adjacencyList[stage] = <InitializationStage>{};
      _reverseAdjacencyList[stage] = <InitializationStage>{};
    }

    // Build edges based on dependencies
    for (final stage in InitializationStage.values) {
      for (final dependency in stage.dependsOn) {
        _addEdge(dependency, stage);
      }
    }

    // Validate the graph for cycles
    _validateGraph();
  }

  /// Add a directed edge from 'from' to 'to' (from → to)
  void _addEdge(InitializationStage from, InitializationStage to) {
    _adjacencyList[from]!.add(to);
    _reverseAdjacencyList[to]!.add(from);
  }

  /// Validate the graph for dependency cycles
  void _validateGraph() {
    final cycles = _detectCycles();
    if (cycles.isNotEmpty) {
      throw StateError('Dependency graph contains cycles: $cycles');
    }
  }

  /// Detect cycles in the dependency graph using DFS
  List<List<InitializationStage>> _detectCycles() {
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

    for (final neighbor in _adjacencyList[stage]!) {
      final neighborState = visited[neighbor];

      if (neighborState == DFSState.visiting) {
        // Found a cycle
        final cycleStart = path.indexOf(neighbor);
        final cycle = path.sublist(cycleStart);
        cycles.add([...cycle, neighbor]); // Close the cycle
      } else if (neighborState == null) {
        _detectCyclesDFS(neighbor, visited, path, cycles);
      }
    }

    visited[stage] = DFSState.visited;
    path.removeLast();
  }

  /// Get topological order of stages (dependency-respecting order)
  List<InitializationStage> getTopologicalOrder() {
    final cacheKey = 'topological_order';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<InitializationStage>;
    }

    final inDegree = <InitializationStage, int>{};
    final queue = Queue<InitializationStage>();
    final result = <InitializationStage>[];

    // Calculate in-degrees
    for (final stage in InitializationStage.values) {
      inDegree[stage] = _reverseAdjacencyList[stage]!.length;
      if (inDegree[stage] == 0) {
        queue.add(stage);
      }
    }

    // Process nodes with no dependencies
    while (queue.isNotEmpty) {
      final current = queue.removeFirst();
      result.add(current);

      for (final neighbor in _adjacencyList[current]!) {
        inDegree[neighbor] = inDegree[neighbor]! - 1;
        if (inDegree[neighbor] == 0) {
          queue.add(neighbor);
        }
      }
    }

    // Verify all stages were processed (no cycles)
    if (result.length != InitializationStage.values.length) {
      throw StateError('Dependency graph contains cycles');
    }

    _cache[cacheKey] = result;
    return result;
  }

  /// Get stages that can be executed in parallel at each level
  Map<int, List<InitializationStage>> getParallelExecutionPlan() {
    final cacheKey = 'parallel_plan';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Map<int, List<InitializationStage>>;
    }

    final plan = <int, List<InitializationStage>>{};
    final topologicalOrder = getTopologicalOrder();
    final stageLevels = <InitializationStage, int>{};

    // Calculate levels using longest path algorithm
    for (final stage in topologicalOrder) {
      if (stage.dependsOn.isEmpty) {
        stageLevels[stage] = 0;
      } else {
        var maxDepLevel = -1;
        for (final dependency in stage.dependsOn) {
          maxDepLevel = maxDepLevel > stageLevels[dependency]!
              ? maxDepLevel
              : stageLevels[dependency]!;
        }
        stageLevels[stage] = maxDepLevel + 1;
      }

      // Add to appropriate level in plan
      final level = stageLevels[stage]!;
      plan[level] = (plan[level] ?? [])..add(stage);
    }

    // Sort stages within each level by priority
    for (final level in plan.keys) {
      plan[level]!.sort((a, b) => b.priority.compareTo(a.priority));
    }

    _cache[cacheKey] = plan;
    return plan;
  }

  /// Get critical path (longest path through the graph)
  List<InitializationStage> getCriticalPath() {
    final cacheKey = 'critical_path';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as List<InitializationStage>;
    }

    final topologicalOrder = getTopologicalOrder();
    final longestPath = <InitializationStage>[];
    final stageDurations = <InitializationStage, Duration>{};

    // Calculate longest duration to each stage
    for (final stage in topologicalOrder) {
      if (stage.dependsOn.isEmpty) {
        stageDurations[stage] = stage.estimatedDuration;
      } else {
        Duration maxDepDuration = Duration.zero;
        for (final dependency in stage.dependsOn) {
          if (stageDurations[dependency]! > maxDepDuration) {
            maxDepDuration = stageDurations[dependency]!;
          }
        }
        stageDurations[stage] = maxDepDuration + stage.estimatedDuration;
      }
    }

    // Find stage with maximum duration (end of critical path)
    InitializationStage? endStage;
    Duration maxTotalDuration = Duration.zero;

    for (final stage in InitializationStage.values) {
      if (stageDurations[stage]! > maxTotalDuration) {
        maxTotalDuration = stageDurations[stage]!;
        endStage = stage;
      }
    }

    if (endStage == null) {
      return [];
    }

    // Trace back from end stage to find critical path
    var currentStage = endStage;
    longestPath.add(currentStage);

    while (currentStage!.dependsOn.isNotEmpty) {
      InitializationStage? nextStage;
      Duration maxPrevDuration = Duration.zero;

      for (final dependency in currentStage.dependsOn) {
        if (stageDurations[dependency]! > maxPrevDuration) {
          maxPrevDuration = stageDurations[dependency]!;
          nextStage = dependency;
        }
      }

      if (nextStage == null) break;
      longestPath.insert(0, nextStage);
      currentStage = nextStage;
    }

    _cache[cacheKey] = longestPath;
    return longestPath;
  }

  /// Get estimated total duration for sequential execution
  Duration getSequentialDuration() {
    final cacheKey = 'sequential_duration';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Duration;
    }

    Duration totalDuration = Duration.zero;
    for (final stage in InitializationStage.values) {
      totalDuration += stage.estimatedDuration;
    }

    _cache[cacheKey] = totalDuration;
    return totalDuration;
  }

  /// Get estimated total duration for parallel execution
  Duration getParallelDuration() {
    final cacheKey = 'parallel_duration';
    if (_cache.containsKey(cacheKey)) {
      return _cache[cacheKey] as Duration;
    }

    final plan = getParallelExecutionPlan();
    Duration totalDuration = Duration.zero;

    for (final level in plan.keys) {
      // For parallel execution, each level takes as long as its longest stage
      Duration maxLevelDuration = Duration.zero;
      for (final stage in plan[level]!) {
        if (stage.estimatedDuration > maxLevelDuration) {
          maxLevelDuration = stage.estimatedDuration;
        }
      }
      totalDuration += maxLevelDuration;
    }

    _cache[cacheKey] = totalDuration;
    return totalDuration;
  }

  /// Get stages that are ready to execute given completed stages
  List<InitializationStage> getReadyStages(Set<InitializationStage> completedStages) {
    final readyStages = <InitializationStage>[];

    for (final stage in InitializationStage.values) {
      if (!completedStages.contains(stage)) {
        final dependencies = stage.dependsOn;
        if (dependencies.every((dep) => completedStages.contains(dep))) {
          readyStages.add(stage);
        }
      }
    }

    // Sort by priority
    readyStages.sort((a, b) => b.priority.compareTo(a.priority));
    return readyStages;
  }

  /// Get stages that can be executed in parallel at the current moment
  List<InitializationStage> getParallelReadyStages(
    Set<InitializationStage> completedStages,
    Set<InitializationStage> inProgressStages,
  ) {
    final readyStages = getReadyStages(completedStages);
    final parallelStages = <InitializationStage>[];

    for (final stage in readyStages) {
      // Check if stage can run in parallel with currently running stages
      bool canRunInParallel = true;

      for (final inProgressStage in inProgressStages) {
        if (!canStagesRunInParallel(stage, inProgressStage)) {
          canRunInParallel = false;
          break;
        }
      }

      if (canRunInParallel && stage.canRunInParallel) {
        parallelStages.add(stage);
      } else if (!stage.canRunInParallel && inProgressStages.isEmpty) {
        // Non-parallel stage can run if nothing else is running
        parallelStages.add(stage);
      }
    }

    // Sort by priority and duration
    parallelStages.sort((a, b) {
      final priorityComparison = b.priority.compareTo(a.priority);
      if (priorityComparison != 0) return priorityComparison;
      return a.estimatedMs.compareTo(b.estimatedMs);
    });

    return parallelStages;
  }

  /// Check if two stages can run in parallel
  bool canStagesRunInParallel(
    InitializationStage stage1,
    InitializationStage stage2,
  ) {
    // Same stage can't run in parallel with itself
    if (stage1 == stage2) return false;

    // Check if either stage disallows parallel execution
    if (!stage1.canRunInParallel || !stage2.canRunInParallel) {
      return false;
    }

    // Check if they're at the same level
    if (stage1.level != stage2.level) {
      return false;
    }

    // Check for dependency relationships
    if (stage1.dependsOnStage(stage2) || stage2.dependsOnStage(stage1)) {
      return false;
    }

    return true;
  }

  /// Get bottleneck stages (stages with many dependents)
  List<InitializationStage> getBottleneckStages() {
    final bottlenecks = <InitializationStage>[];
    final averageDependents = InitializationStage.values
        .fold(0, (sum, stage) => sum + stage.requiredFor.length) /
        InitializationStage.values.length;

    for (final stage in InitializationStage.values) {
      if (stage.requiredFor.length > averageDependents * 1.5) {
        bottlenecks.add(stage);
      }
    }

    return bottlenecks;
  }

  /// Get stage statistics
  Map<String, dynamic> getStatistics() {
    return {
      'totalStages': InitializationStage.values.length,
      'levels': 5,
      'criticalStages': InitializationStage.values.where((s) => s.isCritical).length,
      'parallelStages': InitializationStage.values.where((s) => s.canRunInParallel).length,
      'sequentialDuration': getSequentialDuration().inMilliseconds,
      'parallelDuration': getParallelDuration().inMilliseconds,
      'speedupRatio': getSequentialDuration().inMilliseconds /
                     getParallelDuration().inMilliseconds,
      'bottleneckStages': getBottleneckStages().length,
      'criticalPathLength': getCriticalPath().length,
    };
  }

  /// Clear the cache (useful for testing or when dependencies change)
  void clearCache() {
    _cache.clear();
  }

  /// Generate a visual representation of the graph (for debugging)
  String generateGraphViz() {
    final buffer = StringBuffer();
    buffer.writeln('digraph InitializationDependencies {');
    buffer.writeln('  rankdir=TB;');
    buffer.writeln('  node [shape=box, style=filled];');

    // Add nodes with styling
    for (final stage in InitializationStage.values) {
      String color = 'lightgray';
      if (stage.isCritical) color = 'lightcoral';
      else if (stage.isInfrastructure) color = 'lightblue';
      else if (stage.isDataStage) color = 'lightgreen';
      else if (stage.isFeatureStage) color = 'lightyellow';
      else if (stage.isAdvancedStage) color = 'lightpink';

      buffer.writeln('  "${stage.name}" [label="${stage.displayName}", fillcolor=$color];');
    }

    // Add edges
    for (final stage in InitializationStage.values) {
      for (final dependency in stage.dependsOn) {
        buffer.writeln('  "${dependency.name}" -> "${stage.name}";');
      }
    }

    buffer.writeln('}');
    return buffer.toString();
  }

  /// Print detailed analysis of the dependency graph
  void printAnalysis() {
    debugPrint('=== Initialization Dependency Graph Analysis ===');

    final stats = getStatistics();
    debugPrint('Total Stages: ${stats['totalStages']}');
    debugPrint('Critical Stages: ${stats['criticalStages']}');
    debugPrint('Parallel Capable: ${stats['parallelStages']}');
    debugPrint('Sequential Duration: ${stats['sequentialDuration']}ms');
    debugPrint('Parallel Duration: ${stats['parallelDuration']}ms');
    debugPrint('Speedup Ratio: ${stats['speedupRatio'].toStringAsFixed(2)}x');

    debugPrint('\n=== Critical Path ===');
    final criticalPath = getCriticalPath();
    for (var i = 0; i < criticalPath.length; i++) {
      final stage = criticalPath[i];
      debugPrint('${i + 1}. ${stage.displayName} (${stage.estimatedDuration.inMilliseconds}ms)');
    }

    debugPrint('\n=== Parallel Execution Plan ===');
    final plan = getParallelExecutionPlan();
    for (final level in plan.keys.toList()..sort()) {
      debugPrint('Level $level:');
      for (final stage in plan[level]!) {
        debugPrint('  - ${stage.displayName} (${stage.estimatedDuration.inMilliseconds}ms)');
      }
    }

    final bottlenecks = getBottleneckStages();
    if (bottlenecks.isNotEmpty) {
      debugPrint('\n=== Bottleneck Stages ===');
      for (final stage in bottlenecks) {
        debugPrint('- ${stage.displayName} (${stage.requiredFor.length} dependents)');
      }
    }

    debugPrint('=== End Analysis ===');
  }
}

/// DFS traversal states for cycle detection
enum DFSState {
  unvisited,
  visiting,
  visited,
}

/// Extension methods for working with dependency graphs
extension InitializationStageGraphExtensions on InitializationStage {
  /// Get all stages in the same level that can run in parallel
  List<InitializationStage> getParallelCompatibleStages() {
    return InitializationStage.values
        .where((other) => other != this)
        .where((other) => other.level == this.level)
        .where((other) => canRunInParallel && other.canRunInParallel)
        .where((other) => !dependsOnStage(other) && !other.dependsOnStage(this))
        .toList();
  }

  /// Get stages that are blocked by this stage
  List<InitializationStage> getBlockedStages() {
    return InitializationStage.values
        .where((other) => other.dependsOnStage(this))
        .toList();
  }

  /// Get stages that block this stage
  List<InitializationStage> getBlockingStages() {
    return InitializationStage.values
        .where((other) => this.dependsOnStage(other))
        .toList();
  }

  /// Get dependency depth (how many levels of dependencies this stage has)
  int get dependencyDepth {
    var maxDepth = 0;
    for (final dependency in dependsOn) {
      final depDepth = dependency.dependencyDepth;
      if (depDepth > maxDepth) {
        maxDepth = depDepth;
      }
    }
    return maxDepth + 1;
  }

  /// Get impact score (based on number of dependents and criticality)
  double get impactScore {
    final dependentCount = allDependents.length;
    final criticalMultiplier = isCritical ? 2.0 : 1.0;
    final levelMultiplier = (5 - level).toDouble() / 5.0;

    return dependentCount * criticalMultiplier * levelMultiplier;
  }
}