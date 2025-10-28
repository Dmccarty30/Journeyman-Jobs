import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../models/hierarchical/hierarchical_types.dart';
import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_metadata.dart';
import '../../services/hierarchical/hierarchical_initializer.dart';
import '../../services/hierarchical/initialization_progress_tracker.dart';
import '../../services/hierarchical/error_manager.dart';
import '../../services/hierarchical/performance_monitor.dart';
import '../../services/hierarchical/dependency_resolver.dart';
import 'auth_riverpod_provider.dart';

/// Provider for the hierarchical initializer coordinator
final hierarchicalInitializerProvider = Provider<HierarchicalInitializer>((ref) {
  final initializer = HierarchicalInitializer(
    progressTracker: InitializationProgressTracker(),
    errorManager: ErrorManager(),
    performanceMonitor: PerformanceMonitor(),
  );

  // Dispose the initializer when provider is disposed
  ref.onDispose(() {
    initializer.dispose();
  });

  return initializer;
});

/// Provider for initialization progress stream
final initializationProgressProvider = StreamProvider<InitializationProgress>((ref) {
  final initializer = ref.watch(hierarchicalInitializerProvider);
  return initializer.progressStream;
});

/// Provider for initialization events stream
final initializationEventProvider = StreamProvider<InitializationEvent>((ref) {
  final initializer = ref.watch(hierarchicalInitializerProvider);
  return initializer.eventStream;
});

/// Provider for initialization statistics
final initializationStatsProvider = Provider<InitializationStats>((ref) {
  final initializer = ref.watch(hierarchicalInitializerProvider);
  return initializer.getStats();
});

/// State for hierarchical initialization management
@immutable
class HierarchicalInitializationState {
  const HierarchicalInitializationState({
    required this.isInitializing,
    required this.progress,
    required this.result,
    required this.error,
    required this.lastUpdated,
  });

  final bool isInitializing;
  final InitializationProgress? progress;
  final InitializationResult? result;
  final String? error;
  final DateTime lastUpdated;

  bool get isIdle => !isInitializing && result == null && error == null;
  bool get isCompleted => result != null && result!.isSuccess;
  bool get hasFailed => result != null && result!.isFailure || error != null;
  bool get hasProgress => progress != null;

  HierarchicalInitializationState copyWith({
    bool? isInitializing,
    InitializationProgress? progress,
    InitializationResult? result,
    String? error,
    DateTime? lastUpdated,
  }) {
    return HierarchicalInitializationState(
      isInitializing: isInitializing ?? this.isInitializing,
      progress: progress ?? this.progress,
      result: result ?? this.result,
      error: error,
      lastUpdated: lastUpdated ?? this.lastUpdated,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HierarchicalInitializationState &&
        other.isInitializing == isInitializing &&
        other.progress == progress &&
        other.result == result &&
        other.error == error;
  }

  @override
  int get hashCode {
    return Object.hash(isInitializing, progress, result, error);
  }

  @override
  String toString() {
    return 'HierarchicalInitializationState('
        'isInitializing: $isInitializing, '
        'isCompleted: $isCompleted, '
        'hasFailed: $hasFailed, '
        'hasProgress: $hasProgress'
        ')';
  }
}

/// Notifier for managing hierarchical initialization state
class HierarchicalInitializationNotifier extends Notifier<HierarchicalInitializationState> {
  late final HierarchicalInitializer _initializer;
  StreamSubscription<InitializationProgress>? _progressSubscription;
  StreamSubscription<InitializationEvent>? _eventSubscription;

  @override
  HierarchicalInitializationState build() {
    _initializer = ref.watch(hierarchicalInitializerProvider);

    // Listen to progress updates
    _progressSubscription = _initializer.progressStream.listen(
      (progress) {
        state = state.copyWith(
          progress: progress,
          lastUpdated: DateTime.now(),
        );
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          lastUpdated: DateTime.now(),
        );
      },
    );

    // Listen to initialization events
    _eventSubscription = _initializer.eventStream.listen(
      (event) {
        _handleInitializationEvent(event);
      },
      onError: (error) {
        state = state.copyWith(
          error: error.toString(),
          lastUpdated: DateTime.now(),
        );
      },
    );

    // Clean up on provider disposal
    ref.onDispose(() {
      _progressSubscription?.cancel();
      _eventSubscription?.cancel();
    });

    return HierarchicalInitializationState(
      isInitializing: false,
      progress: null,
      result: null,
      error: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Starts hierarchical initialization
  Future<InitializationResult> initialize({
    InitializationStrategy? strategy,
    Duration? timeout,
    bool forceRefresh = false,
    Map<String, dynamic>? context,
  }) async {
    if (state.isInitializing) {
      throw StateError('Initialization is already in progress');
    }

    state = state.copyWith(
      isInitializing: true,
      error: null,
      lastUpdated: DateTime.now(),
    );

    try {
      final result = await _initializer.initialize(
        strategy: strategy,
        timeout: timeout,
        forceRefresh: forceRefresh,
        context: context,
      );

      state = state.copyWith(
        isInitializing: false,
        result: result,
        lastUpdated: DateTime.now(),
      );

      return result;

    } catch (e, stackTrace) {
      state = state.copyWith(
        isInitializing: false,
        error: e.toString(),
        lastUpdated: DateTime.now(),
      );

      debugPrint('[HierarchicalInitializationNotifier] Initialization failed: $e');
      debugPrint('[HierarchicalInitializationNotifier] Stack trace: $stackTrace');

      rethrow;
    }
  }

  /// Resets the initialization state
  void reset() {
    _initializer.reset();
    state = state.copyWith(
      isInitializing: false,
      progress: null,
      result: null,
      error: null,
      lastUpdated: DateTime.now(),
    );
  }

  /// Handles initialization events
  void _handleInitializationEvent(InitializationEvent event) {
    switch (event.runtimeType) {
      case InitializationStartedEvent:
        debugPrint('[HierarchicalInitializationNotifier] Initialization started');
        break;

      case InitializationCompletedEvent:
        final completedEvent = event as InitializationCompletedEvent;
        debugPrint('[HierarchicalInitializationNotifier] Initialization completed: '
                  '${completedEvent.duration.inMilliseconds}ms');
        break;

      case InitializationFailedEvent:
        final failedEvent = event as InitializationFailedEvent;
        debugPrint('[HierarchicalInitializationNotifier] Initialization failed: ${failedEvent.error}');
        break;

      case StageStartedEvent:
        final stageEvent = event as StageStartedEvent;
        debugPrint('[HierarchicalInitializationNotifier] Stage started: ${stageEvent.stage.displayName}');
        break;

      case StageCompletedEvent:
        final stageEvent = event as StageCompletedEvent;
        debugPrint('[HierarchicalInitializationNotifier] Stage completed: ${stageEvent.stage.displayName} '
                  'in ${stageEvent.result.duration.inMilliseconds}ms');
        break;

      case StageFailedEvent:
        final stageEvent = event as StageFailedEvent;
        debugPrint('[HierarchicalInitializationNotifier] Stage failed: ${stageEvent.stage.displayName} - ${stageEvent.error}');
        break;
    }
  }

  /// Gets initialization statistics
  InitializationStats getStats() {
    return _initializer.getStats();
  }

  /// Gets real-time performance metrics
  RealTimeMetrics getRealTimeMetrics() {
    return _initializer._performanceMonitor.getRealTimeMetrics();
  }

  /// Gets error statistics
  ErrorStatistics getErrorStatistics() {
    return _initializer._errorManager.getStatistics();
  }
}

/// Provider for hierarchical initialization state management
final hierarchicalInitializationProvider =
    NotifierProvider<HierarchicalInitializationNotifier, HierarchicalInitializationState>(
  HierarchicalInitializationNotifier.new,
);

/// Provider for initialization configuration
final initializationConfigProvider = Provider<InitializationConfig>((ref) {
  return InitializationConfig(
    defaultStrategy: InitializationStrategy.adaptive,
    timeout: const Duration(seconds: 30),
    maxRetries: 3,
    enablePerformanceMonitoring: true,
    enableErrorRecovery: true,
    enableProgressTracking: true,
    maxParallelStages: 4,
    cacheThreshold: const Duration(minutes: 5),
    enableBackgroundInitialization: true,
  );
});

/// Provider for initialization context
final initializationContextProvider = Provider<InitializationContext>((ref) {
  final authState = ref.watch(authStateStreamProvider);
  final user = authState.value;

  return InitializationContext(
    userId: user?.uid,
    isFirstLaunch: false, // Would check local storage
    networkType: NetworkType.wifi, // Would detect actual network type
    batteryLevel: 0.8, // Would get actual battery level
    devicePerformance: DevicePerformance.high, // Would detect device capabilities
    previousLaunchData: null, // Would load from storage
    userPreferences: {}, // Would load user preferences
    location: null, // Would get user location
  );
});

/// Provider for initialization strategies based on context
final initializationStrategyProvider = Provider<InitializationStrategy>((ref) {
  final config = ref.watch(initializationConfigProvider);
  final context = ref.watch(initializationContextProvider);
  final authState = ref.watch(authStateStreamProvider);
  final user = authState.value;

  // Adaptive strategy selection based on context
  if (user == null) {
    return InitializationStrategy.minimal;
  }

  if (context.isFirstLaunch) {
    return InitializationStrategy.minimal;
  }

  if (context.isLowBattery || context.isOnMeteredNetwork) {
    return InitializationStrategy.homeLocalFirst;
  }

  if (context.isHighPerformanceDevice) {
    return InitializationStrategy.comprehensive;
  }

  return config.defaultStrategy;
});

/// Convenience providers for common initialization states

final isInitializingProvider = Provider<bool>((ref) {
  return ref.watch(hierarchicalInitializationProvider.select((state) => state.isInitializing));
});

final initializationProgressProvider = Provider<InitializationProgress?>((ref) {
  return ref.watch(hierarchicalInitializationProvider.select((state) => state.progress));
});

final initializationErrorProvider = Provider<String?>((ref) {
  return ref.watch(hierarchicalInitializationProvider.select((state) => state.error));
});

final isInitializationCompletedProvider = Provider<bool>((ref) {
  return ref.watch(hierarchicalInitializationProvider.select((state) => state.isCompleted));
});

final hasInitializationFailedProvider = Provider<bool>((ref) {
  return ref.watch(hierarchicalInitializationProvider.select((state) => state.hasFailed));
});

/// Extension methods for easier access to initialization functionality
extension HierarchicalInitializationRef on WidgetRef {
  /// Initialize the app with hierarchical coordination
  Future<InitializationResult> initializeHierarchically({
    InitializationStrategy? strategy,
    Duration? timeout,
    bool forceRefresh = false,
  }) async {
    final notifier = read(hierarchicalInitializationProvider.notifier);
    final context = read(initializationContextProvider);

    return await notifier.initialize(
      strategy: strategy,
      timeout: timeout,
      forceRefresh: forceRefresh,
      context: {
        'userId': context.userId,
        'isFirstLaunch': context.isFirstLaunch,
        'networkType': context.networkType.name,
        'batteryLevel': context.batteryLevel,
        'devicePerformance': context.devicePerformance.name,
      },
    );
  }

  /// Reset initialization state
  void resetInitialization() {
    read(hierarchicalInitializationProvider.notifier).reset();
  }

  /// Get initialization statistics
  InitializationStats getInitializationStats() {
    return read(hierarchicalInitializationProvider.notifier).getStats();
  }

  /// Get real-time performance metrics
  RealTimeMetrics getRealTimeMetrics() {
    return read(hierarchicalInitializationProvider.notifier).getRealTimeMetrics();
  }

  /// Get error statistics
  ErrorStatistics getErrorStatistics() {
    return read(hierarchicalInitializationProvider.notifier).getErrorStatistics();
  }
}