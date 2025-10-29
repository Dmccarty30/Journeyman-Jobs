import 'dart:async';
import 'dart:collection';
import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:meta/meta.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../models/hierarchical/hierarchical_types.dart';
import '../../models/hierarchical/initialization_stage.dart';
import '../../models/hierarchical/initialization_dependency_graph.dart';
import '../../models/hierarchical/initialization_metadata.dart';
import '../../models/hierarchical/initialization_strategy.dart';
import '../../models/hierarchical/initialization_progress_tracker.dart';
import '../../models/hierarchical/error_manager.dart';
import 'error_recovery_manager.dart';
import 'performance_monitor.dart' as perf_service;
import '../../models/user_model.dart';
import '../auth_service.dart';
import 'hierarchical_service.dart';
import 'hierarchical_initialization_service.dart';
import 'stage_executors.dart';

/// Main hierarchical initialization coordinator that orchestrates all stages
///
/// This coordinator manages the complete app initialization process with:
/// - Dependency-aware stage execution
/// - Parallel execution of independent stages
/// - Real-time progress tracking with time estimates
/// - Error containment and retry mechanisms
/// - Multiple initialization strategies
/// - Performance monitoring and optimization
///
/// Architecture:
/// - Level 0: Core Infrastructure (Firebase, Auth, Sessions)
/// - Level 1: User Data (Profile, Preferences)
/// - Level 2: Core Data (Locals, Jobs)
/// - Level 3: Features (Crew, Weather, Notifications)
/// - Level 4: Advanced (Sync, Background, Analytics)
 // InitializationStrategy is defined in:
 //   lib/models/hierarchical/initialization_strategy.dart
 // Use the centralized definition from the hierarchical barrel export.

/// Main hierarchical initialization coordinator that orchestrates all stages
class HierarchicalInitializer {
  HierarchicalInitializer({
    HierarchicalService? hierarchicalService,
    HierarchicalInitializationService? initializationService,
    AuthService? authService,
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
    InitializationProgressTracker? progressTracker,
    ErrorManager? errorManager,
    PerformanceMonitor? performanceMonitor,
  }) : _hierarchicalService = hierarchicalService ?? HierarchicalService(),
       _initializationService = initializationService ?? HierarchicalInitializationService(),
       _authService = authService ?? AuthService(),
       _auth = auth ?? FirebaseAuth.instance,
       _firestore = firestore ?? FirebaseFirestore.instance,
       _progressTracker = progressTracker ?? InitializationProgressTracker(),
       _errorManager = errorManager ?? ErrorManager(),
       _performanceMonitor = performanceMonitor ?? perf_service.PerformanceMonitor(),
       _dependencyGraph = InitializationDependencyGraph();

  final HierarchicalService _hierarchicalService;
  final HierarchicalInitializationService _initializationService;
  final AuthService _authService;
  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  final InitializationProgressTracker _progressTracker;
  final ErrorManager _errorManager;
  final perf_service.PerformanceMonitor _performanceMonitor;
  final InitializationDependencyGraph _dependencyGraph;

  // Initialization state
  final Map<InitializationStage, StageExecutionResult> _stageResults = {};
  final Set<InitializationStage> _completedStages = {};
  final Set<InitializationStage> _inProgressStages = {};
  final Map<InitializationStage, Completer<void>> _stageCompleters = {};

  // Stream controllers
  final StreamController<InitializationProgress> _progressController =
      StreamController<InitializationProgress>.broadcast();
  final StreamController<InitializationEvent> _eventController =
      StreamController<InitializationEvent>.broadcast();

  // Configuration
  Duration _timeout = const Duration(seconds: 30);
  InitializationStrategy _strategy = InitializationStrategy.adaptive;
  bool _isDisposed = false;
  bool _isRunning = false;

  /// Stream of initialization progress updates
  Stream<InitializationProgress> get progressStream => _progressController.stream;

  /// Stream of initialization events
  Stream<InitializationEvent> get eventStream => _eventController.stream;

  /// Current initialization progress
  InitializationProgress get currentProgress => _progressTracker.currentProgress;

  /// Whether initialization is currently running
  bool get isRunning => _isRunning;

  /// Whether the initializer has been disposed
  bool get isDisposed => _isDisposed;

  /// Gets results of completed stages
  Map<InitializationStage, StageExecutionResult> get stageResults =>
      Map.unmodifiable(_stageResults);

  /// Sets initialization timeout
  set timeout(Duration duration) {
    _timeout = duration;
  }

  /// Sets initialization strategy
  set strategy(InitializationStrategy strategy) {
    _strategy = strategy;
  }

  /// Executes the complete hierarchical initialization process
  ///
  /// This method orchestrates all initialization stages based on the dependency
  /// graph and selected strategy. It supports parallel execution of independent
  /// stages and provides real-time progress tracking.
  ///
  /// Returns [InitializationResult] containing the final state and any errors.
  Future<InitializationResult> initialize({
    InitializationStrategy? strategy,
    Duration? timeout,
    bool forceRefresh = false,
    Map<String, dynamic>? context,
  }) async {
    if (_isDisposed) {
      throw StateError('Initializer has been disposed');
    }

    if (_isRunning) {
      throw StateError('Initialization is already running');
    }

    _isRunning = true;
    _strategy = strategy ?? _strategy;
    if (timeout != null) _timeout = timeout;

    debugPrint('[HierarchicalInitializer] Starting initialization with strategy: $_strategy');

    final stopwatch = Stopwatch()..start();
    final initContext = context ?? {};

    try {
      // Initialize progress tracking
      _progressTracker.initialize(_strategy, _dependencyGraph);
      _performanceMonitor.startMonitoring();

      // Emit initialization started event
      _emitEvent(InitializationEvent.initializationStarted(
        strategy: _strategy,
        estimatedDuration: _dependencyGraph.getParallelDuration(),
      ));

      // Get current user to determine initialization context
      final currentUser = _auth.currentUser;
      final UserModel? user = currentUser != null ? await _loadUserProfile(currentUser.uid) : null;

      // Determine initialization strategy if adaptive
      final effectiveStrategy = _determineEffectiveStrategy(user);

      // Execute initialization based on strategy
      switch (effectiveStrategy) {
        case InitializationStrategy.sequential:
          await _executeSequentialInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.parallel:
          await _executeParallelInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.criticalOnly:
          await _executeCriticalOnlyInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.minimal:
          await _executeMinimalInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.homeLocalFirst:
          await _executeHomeLocalFirstInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.comprehensive:
          await _executeComprehensiveInitialization(user, forceRefresh, initContext);
          break;
        case InitializationStrategy.adaptive:
          await _executeAdaptiveInitialization(user, forceRefresh, initContext);
          break;
      }

      // Complete initialization
      stopwatch.stop();
      final duration = stopwatch.elapsed;

      _progressTracker.complete();
      _performanceMonitor.stopMonitoring();

      final result = InitializationResult.success(
        duration: duration,
        strategy: effectiveStrategy,
        stageResults: Map.unmodifiable(_stageResults),
        context: initContext,
      );

      _emitEvent(InitializationEvent.initializationCompleted(
        strategy: effectiveStrategy,
        duration: duration,
        result: result,
      ));

      debugPrint('[HierarchicalInitializer] Initialization completed in ${duration.inMilliseconds}ms');
      return result;

    } catch (e, stackTrace) {
      stopwatch.stop();
      final duration = stopwatch.elapsed;

      debugPrint('[HierarchicalInitializer] Initialization failed: $e');
      debugPrint('[HierarchicalInitializer] Stack trace: $stackTrace');

      _progressTracker.error(e.toString());
      _performanceMonitor.stopMonitoring();

      final result = InitializationResult.failure(
        duration: duration,
        strategy: _strategy,
        error: e.toString(),
        stackTrace: stackTrace,
        stageResults: Map.unmodifiable(_stageResults),
        context: initContext,
      );

      _emitEvent(InitializationEvent.initializationFailed(
        strategy: _strategy,
        duration: duration,
        error: e.toString(),
        result: result,
      ));

      rethrow;
    } finally {
      _isRunning = false;
    }
  }

  /// Executes minimal initialization strategy (critical stages only)
  Future<void> _executeMinimalInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing minimal initialization');

    // Define minimal stages (critical infrastructure only)
    final minimalStages = [
      InitializationStage.firebaseCore,
      InitializationStage.authentication,
      InitializationStage.sessionManagement,
      InitializationStage.userProfile,
    ];

    await _executeStagesSequentially(minimalStages, forceRefresh, context);
  }

  /// Executes sequential initialization strategy
  Future<void> _executeSequentialInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing sequential initialization');

    // Execute all stages in sequence, respecting dependencies
    final allStages = InitializationStage.values;
    await _executeStagesSequentially(allStages, forceRefresh, context);
  }

  /// Executes parallel initialization strategy
  Future<void> _executeParallelInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing parallel initialization');

    // Execute stages in parallel where possible, respecting dependencies
    final executionPlan = _dependencyGraph.getParallelExecutionPlan();
    final sortedLevels = executionPlan.keys.toList()..sort();
    for (final level in sortedLevels) {
      final stageBatch = executionPlan[level] ?? [];
      if (stageBatch.isNotEmpty) {
        await _executeStagesInParallel(stageBatch, forceRefresh, context);
      }
    }
  }

  /// Executes critical only initialization strategy
  Future<void> _executeCriticalOnlyInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing critical only initialization');

    // Define critical stages only
    final criticalStages = InitializationStage.values.where((stage) => stage.isCritical).toList();
    await _executeStagesSequentially(criticalStages, forceRefresh, context);
  }

  /// Executes home local first initialization strategy
  Future<void> _executeHomeLocalFirstInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing home local first initialization');

    // Stage 1: Core infrastructure (sequential)
    await _executeStagesSequentially([
      InitializationStage.firebaseCore,
      InitializationStage.authentication,
      InitializationStage.sessionManagement,
    ], forceRefresh, context);

    // Stage 2: User data (parallel)
    await _executeStagesInParallel([
      InitializationStage.userProfile,
      InitializationStage.userPreferences,
    ], forceRefresh, context);

    // Stage 3: Core data focused on home local
    if (user != null) {
      await _executeStage(InitializationStage.localsDirectory, forceRefresh, {
        ...context,
        'homeLocal': user.homeLocal,
        'focusMode': 'homeLocal',
      });
    }

    // Stage 4: Essential features (parallel)
    await _executeStagesInParallel([
      InitializationStage.jobsData,
      InitializationStage.notifications,
    ], forceRefresh, context);
  }

  /// Executes comprehensive initialization strategy
  Future<void> _executeComprehensiveInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing comprehensive initialization');

    // Execute all stages using dependency graph for optimal parallelization
    await _executeDependencyGraphInitialization(forceRefresh, context);
  }

  /// Executes adaptive initialization strategy based on context
  Future<void> _executeAdaptiveInitialization(
    UserModel? user,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    debugPrint('[HierarchicalInitializer] Executing adaptive initialization');

    // Analyze current conditions to determine optimal approach
    final conditions = await _analyzeInitializationConditions(user);

    if (conditions.isFirstLaunch) {
      // First launch - use minimal to get user started quickly
      await _executeMinimalInitialization(user, forceRefresh, context);

      // Then continue with background loading
      _scheduleBackgroundInitialization([
        InitializationStage.localsDirectory,
        InitializationStage.jobsData,
        InitializationStage.crewFeatures,
        InitializationStage.weatherServices,
      ], forceRefresh, context);

    } else if (conditions.isLowBattery || conditions.isOnMeteredConnection) {
      // Conservative initialization
      await _executeHomeLocalFirstInitialization(user, forceRefresh, context);

    } else if (conditions.isHighPerformanceDevice) {
      // Full initialization with parallelization
      await _executeComprehensiveInitialization(user, forceRefresh, context);

    } else {
      // Balanced approach
      await _executeHomeLocalFirstInitialization(user, forceRefresh, context);
    }
  }

  /// Executes initialization using the dependency graph for optimal parallelization
  Future<void> _executeDependencyGraphInitialization(
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    final executionPlan = _dependencyGraph.getParallelExecutionPlan();

    for (final level in executionPlan.keys.toList()..sort()) {
      final stages = executionPlan[level]!;

      debugPrint('[HierarchicalInitializer] Executing level $level with ${stages.length} stages');

      if (stages.length == 1) {
        // Single stage - execute sequentially
        await _executeStage(stages.first, forceRefresh, context);
      } else {
        // Multiple stages - execute in parallel
        await _executeStagesInParallel(stages, forceRefresh, context);
      }
    }
  }

  /// Executes a list of stages sequentially
  Future<void> _executeStagesSequentially(
    List<InitializationStage> stages,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    for (final stage in stages) {
      await _executeStage(stage, forceRefresh, context);
    }
  }

  /// Executes multiple stages in parallel
  Future<void> _executeStagesInParallel(
    List<InitializationStage> stages,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    final futures = stages.map((stage) => _executeStage(stage, forceRefresh, context));
    await Future.wait(futures, eagerError: false);
  }

  /// Executes a single initialization stage with error handling and progress tracking
  Future<void> _executeStage(
    InitializationStage stage,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    if (_completedStages.contains(stage)) {
      debugPrint('[HierarchicalInitializer] Stage $stage already completed, skipping');
      return;
    }

    if (_inProgressStages.contains(stage)) {
      debugPrint('[HierarchicalInitializer] Stage $stage already in progress, waiting');
      return _stageCompleters[stage]?.future;
    }

    debugPrint('[HierarchicalInitializer] Executing stage: $stage');

    final completer = Completer<void>();
    _stageCompleters[stage] = completer;
    _inProgressStages.add(stage);

    try {
      // Update progress
      _progressTracker.startStage(stage);
      _emitEvent(InitializationEvent.stageStarted(stage: stage));

      // Execute the stage with timeout and error handling
      final result = await _executeStageWithErrorHandling(stage, forceRefresh, context);

      // Record successful result
      _stageResults[stage] = result;
      _completedStages.add(stage);
      _progressTracker.completeStage(stage, result);

      _emitEvent(InitializationEvent.stageCompleted(
        stage: stage,
        result: result,
      ));

      debugPrint('[HierarchicalInitializer] Stage $stage completed in ${result.duration.inMilliseconds}ms');

    } catch (e, stackTrace) {
      debugPrint('[HierarchicalInitializer] Stage $stage failed: $e');

      final errorResult = StageExecutionResult(
        stage: stage,
        status: StageStatus.failed,
        startTime: DateTime.now(),
        endTime: DateTime.now(),
        error: e.toString(),
        stackTrace: stackTrace,
      );

      _stageResults[stage] = errorResult;
      _progressTracker.failStage(stage, e.toString());

      _emitEvent(InitializationEvent.stageFailed(
        stage: stage,
        error: e.toString(),
        result: errorResult,
      ));

      // Handle stage failure based on criticality
      await _errorManager.handleStageFailure(stage, e, stackTrace, context);

      if (stage.isCritical) {
        completer.completeError(e, stackTrace);
        rethrow;
      } else {
        debugPrint('[HierarchicalInitializer] Non-critical stage $stage failed, continuing...');
        completer.complete();
      }

    } finally {
      _inProgressStages.remove(stage);
      _stageCompleters.remove(stage);
    }

    return completer.future;
  }

  /// Executes a stage with timeout, retry logic, and performance monitoring
  Future<StageExecutionResult> _executeStageWithErrorHandling(
    InitializationStage stage,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    final startTime = DateTime.now();

    try {
      // Check circuit breaker status
      if (!_errorManager.canExecuteStage(stage)) {
        throw Exception('Circuit breaker is open for stage $stage');
      }

      // Execute with timeout
      await _executeStageInternal(stage, forceRefresh, context)
          .timeout(_timeout, onTimeout: () {
        throw TimeoutException('Stage $stage timed out after $_timeout', _timeout);
      });

      final endTime = DateTime.now();

      // Cache successful result for potential fallback use
      final stageData = _getStageData(stage, context);
      ErrorRecoveryManager.cacheResult(stage, stageData);

      final stageResult = StageExecutionResult(
        stage: stage,
        status: StageStatus.completed,
        startTime: startTime,
        endTime: endTime,
        data: stageData,
        metrics: _performanceMonitor.getStageMetrics(stage),
      );

      // Record success for circuit breaker and reset error recovery
      _errorManager.recordStageSuccess(stage);
      ErrorRecoveryManager.resetStage(stage);

      return stageResult;

    } catch (e, stackTrace) {
      final endTime = DateTime.now();

      debugPrint('[HierarchicalInitializer] Error in stage $stage: $e');

      // Record error metrics
      _performanceMonitor.recordStageError(stage, e);

      // Use real error recovery manager instead of abstract error manager
      final canRecover = await ErrorRecoveryManager.handleStageError(
        stage,
        e,
        stackTrace,
        context: context,
      );

      if (canRecover) {
        debugPrint('[HierarchicalInitializer] Stage $stage recovered from error');

        // Use fallback or cached data
        final fallbackData = _getStageData(stage, context) ??
                            ErrorRecoveryManager.getCachedResult(stage);

        final recoveryResult = StageExecutionResult(
          stage: stage,
          status: StageStatus.completed,
          startTime: startTime,
          endTime: endTime,
          data: fallbackData,
          metrics: _performanceMonitor.getStageMetrics(stage),
        );

        _errorManager.recordStageSuccess(stage);
        ErrorRecoveryManager.resetStage(stage);

        return recoveryResult;
      } else {
        debugPrint('[HierarchicalInitializer] Stage $stage failed permanently: $e');

        // Record failure for circuit breaker
        _errorManager.recordStageFailure(stage, e);
        rethrow;
      }
    }
  }

  /// Gets stage data based on the stage type and context
  dynamic _getStageData(InitializationStage stage, Map<String, dynamic> context) {
    // Return appropriate data based on stage
    switch (stage) {
      case InitializationStage.firebaseCore:
        return {'initialized': true, 'timestamp': DateTime.now().toIso8601String()};
      case InitializationStage.authentication:
        return {'authenticated': true, 'userId': _auth.currentUser?.uid};
      case InitializationStage.sessionManagement:
        return {'session': 'managed', 'active': true};
      case InitializationStage.userProfile:
        return {'profile': 'loaded', 'source': 'firestore'};
      case InitializationStage.userPreferences:
        return {'preferences': 'loaded', 'cacheHits': context['cacheHits'] ?? 0};
      case InitializationStage.localsDirectory:
        return {'locals': 'loaded', 'count': context['localsCount'] ?? 797};
      case InitializationStage.jobsData:
        return {'jobs': 'loaded', 'count': context['jobsCount'] ?? 0};
      case InitializationStage.crewFeatures:
        return {'crew': 'initialized', 'feature': 'enabled'};
      case InitializationStage.weatherServices:
        return {'weather': 'enabled', 'location': context['location'] ?? 'unknown'};
      case InitializationStage.notifications:
        return {'notifications': 'enabled', 'permissions': context['notificationPermissions'] ?? false};
      case InitializationStage.offlineSync:
        return {'sync': 'enabled', 'interval': context['syncInterval'] ?? 300};
      case InitializationStage.backgroundTasks:
        return {'backgroundTasks': 'enabled', 'interval': context['taskInterval'] ?? 600};
      case InitializationStage.analytics:
        return {'analytics': 'enabled', 'collection': context['analyticsEnabled'] ?? true};
      default:
        return {'stage': stage.displayName, 'completed': true};
    }
  }

  /// Internal stage execution implementation
  Future<void> _executeStageInternal(
    InitializationStage stage,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) async {
    switch (stage) {
      case InitializationStage.firebaseCore:
        // Firebase Core is already initialized in main.dart
        await _verifyFirebaseInitialization();
        break;

      case InitializationStage.authentication:
        await _initializeAuthentication();
        break;

      case InitializationStage.sessionManagement:
        await _initializeSessionManagement(context);
        break;

      case InitializationStage.userProfile:
        await _initializeUserProfile(forceRefresh, context);
        break;

      case InitializationStage.userPreferences:
        await _initializeUserPreferences(forceRefresh, context);
        break;

      case InitializationStage.localsDirectory:
        await _initializeLocalsDirectory(forceRefresh, context);
        break;

      case InitializationStage.jobsData:
        await _initializeJobsData(forceRefresh, context);
        break;

      case InitializationStage.crewFeatures:
        await _initializeCrewFeatures(forceRefresh, context);
        break;

      case InitializationStage.weatherServices:
        await _initializeWeatherServices(forceRefresh, context);
        break;

      case InitializationStage.notifications:
        await _initializeNotifications(forceRefresh, context);
        break;

      case InitializationStage.offlineSync:
        await _initializeOfflineSync(forceRefresh, context);
        break;

      case InitializationStage.backgroundTasks:
        await _initializeBackgroundTasks(forceRefresh, context);
        break;

      case InitializationStage.analytics:
        await _initializeAnalytics(forceRefresh, context);
        break;
    }
  }

  // Individual stage implementations with real Firebase operations
  Future<void> _verifyFirebaseInitialization() async {
    await StageExecutors.executeFirebaseCoreStage();
  }

  Future<void> _initializeAuthentication() async {
    await StageExecutors.executeAuthenticationStage();
  }

  Future<void> _initializeSessionManagement(Map<String, dynamic> context) async {
    await StageExecutors.executeSessionManagementStage();
  }

  Future<void> _initializeUserProfile(bool forceRefresh, Map<String, dynamic> context) async {
    final userProfile = await StageExecutors.executeUserProfileStage();
    context['userProfile'] = userProfile;
  }

  Future<void> _initializeUserPreferences(bool forceRefresh, Map<String, dynamic> context) async {
    final userProfile = context['userProfile'] as UserModel?;
    await StageExecutors.executeUserPreferencesStage(userProfile);
  }

  Future<void> _initializeLocalsDirectory(bool forceRefresh, Map<String, dynamic> context) async {
    final locals = await StageExecutors.executeLocalsDirectoryStage();
    context['locals'] = locals;

    // Also initialize the existing hierarchical service for compatibility
    await _hierarchicalService.initializeHierarchicalData(
      forceRefresh: forceRefresh,
      preferredLocals: context['homeLocal'] != null ? [context['homeLocal']] : null,
    );
  }

  Future<void> _initializeJobsData(bool forceRefresh, Map<String, dynamic> context) async {
    final userProfile = context['userProfile'] as UserModel?;
    final jobs = await StageExecutors.executeJobsDataStage(
      homeLocal: userProfile?.homeLocal,
      preferredLocals: userProfile?.preferredLocals?.split(',').map((s) => s.trim()).toList(),
    );
    context['jobs'] = jobs;
  }

  Future<void> _initializeCrewFeatures(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeCrewFeaturesStage();
  }

  Future<void> _initializeWeatherServices(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeWeatherServicesStage();
  }

  Future<void> _initializeNotifications(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeNotificationsStage();
  }

  Future<void> _initializeOfflineSync(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeOfflineSyncStage();
  }

  Future<void> _initializeBackgroundTasks(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeBackgroundTasksStage();
  }

  Future<void> _initializeAnalytics(bool forceRefresh, Map<String, dynamic> context) async {
    await StageExecutors.executeAnalyticsStage();
  }

  // Helper methods
  Future<UserModel?> _loadUserProfile(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (userDoc.exists) {
        return UserModel.fromFirestore(userDoc);
      }
    } catch (e) {
      debugPrint('[HierarchicalInitializer] Error loading user profile: $e');
    }
    return null;
  }

  InitializationStrategy _determineEffectiveStrategy(UserModel? user) {
    if (_strategy != InitializationStrategy.adaptive) {
      return _strategy;
    }

    // Adaptive strategy selection logic
    if (user == null) {
      return InitializationStrategy.minimal;
    }

    // New users get minimal initialization
    final accountAge = DateTime.now().difference(user.createdTime ?? DateTime.now());
    if (accountAge.inDays < 7) {
      return InitializationStrategy.minimal;
    }

    // Users with preferences get comprehensive
    if (user.preferredLocals != null && user.preferredLocals!.isNotEmpty) {
      return InitializationStrategy.comprehensive;
    }

    // Default to home local first
    return InitializationStrategy.homeLocalFirst;
  }

  Future<InitializationConditions> _analyzeInitializationConditions(UserModel? user) async {
    return InitializationConditions(
      isFirstLaunch: false, // Would check local storage
      isLowBattery: false, // Would check battery level
      isOnMeteredConnection: false, // Would check network type
      isHighPerformanceDevice: true, // Would check device capabilities
    );
  }

  void _scheduleBackgroundInitialization(
    List<InitializationStage> stages,
    bool forceRefresh,
    Map<String, dynamic> context,
  ) {
    debugPrint('[HierarchicalInitializer] Scheduling background initialization for ${stages.length} stages');

    Future.microtask(() async {
      try {
        for (final stage in stages) {
          if (!_completedStages.contains(stage)) {
            await _executeStage(stage, forceRefresh, context);
          }
        }
        debugPrint('[HierarchicalInitializer] Background initialization completed');
      } catch (e) {
        debugPrint('[HierarchicalInitializer] Background initialization failed: $e');
      }
    });
  }

  void _emitEvent(InitializationEvent event) {
    if (!_isDisposed) {
      _eventController.add(event);
    }
  }

  /// Gets initialization statistics
  InitializationStats getStats() {
    return InitializationStats(
      totalStages: InitializationStage.values.length,
      completedStages: _completedStages.length,
      inProgressStages: _inProgressStages.length,
      failedStages: _stageResults.values.where((r) => r.isFailure).length,
      estimatedDuration: _dependencyGraph.getParallelDuration(),
      actualDuration: _performanceMonitor.elapsedTime,
      progressPercentage: _progressTracker.currentProgress.progressPercentage,
    );
  }

  /// Resets the initializer state
  void reset() {
    debugPrint('[HierarchicalInitializer] Resetting initializer state...');

    _stageResults.clear();
    _completedStages.clear();
    _inProgressStages.clear();
    _stageCompleters.clear();

    _progressTracker.reset();
    _errorManager.reset();
    _performanceMonitor.reset();

    _isRunning = false;
  }

  /// Disposes the initializer and cleans up resources
  void dispose() {
    if (_isDisposed) return;

    debugPrint('[HierarchicalInitializer] Disposing...');

    _isDisposed = true;
    _isRunning = false;

    // Cancel any in-progress operations
    for (final completer in _stageCompleters.values) {
      if (!completer.isCompleted) {
        completer.completeError(StateError('Initializer disposed'));
      }
    }

    _progressController.close();
    _eventController.close();

    _progressTracker.dispose();
    _errorManager.dispose();
    _performanceMonitor.dispose();

    debugPrint('[HierarchicalInitializer] Disposed');
  }
}


/// Initialization result containing final state and metadata
@immutable
class InitializationResult {
  const InitializationResult({
    required this.success,
    required this.duration,
    required this.strategy,
    required this.stageResults,
    required this.context,
    this.error,
    this.stackTrace,
  });

  final bool success;
  final Duration duration;
  final InitializationStrategy strategy;
  final Map<InitializationStage, StageExecutionResult> stageResults;
  final Map<String, dynamic> context;
  final String? error;
  final StackTrace? stackTrace;

  factory InitializationResult.success({
    required Duration duration,
    required InitializationStrategy strategy,
    required Map<InitializationStage, StageExecutionResult> stageResults,
    required Map<String, dynamic> context,
  }) {
    return InitializationResult(
      success: true,
      duration: duration,
      strategy: strategy,
      stageResults: stageResults,
      context: context,
    );
  }

  factory InitializationResult.failure({
    required Duration duration,
    required InitializationStrategy strategy,
    required String error,
    required StackTrace stackTrace,
    required Map<InitializationStage, StageExecutionResult> stageResults,
    required Map<String, dynamic> context,
  }) {
    return InitializationResult(
      success: false,
      duration: duration,
      strategy: strategy,
      stageResults: stageResults,
      context: context,
      error: error,
      stackTrace: stackTrace,
    );
  }

  bool get isSuccess => success;
  bool get isFailure => !success;
  int get completedStages => stageResults.values.where((r) => r.isSuccess).length;
  int get failedStages => stageResults.values.where((r) => r.isFailure).length;

  @override
  String toString() {
    return 'InitializationResult('
        'success: $success, '
        'duration: ${duration.inMilliseconds}ms, '
        'strategy: $strategy, '
        'completed: $completedStages, '
        'failed: $failedStages'
        ')';
  }
}

/// Initialization conditions for adaptive strategy
@immutable
class InitializationConditions {
  const InitializationConditions({
    required this.isFirstLaunch,
    required this.isLowBattery,
    required this.isOnMeteredConnection,
    required this.isHighPerformanceDevice,
  });

  final bool isFirstLaunch;
  final bool isLowBattery;
  final bool isOnMeteredConnection;
  final bool isHighPerformanceDevice;
}

/// Initialization statistics
@immutable
class InitializationStats {
  const InitializationStats({
    required this.totalStages,
    required this.completedStages,
    required this.inProgressStages,
    required this.failedStages,
    required this.estimatedDuration,
    required this.actualDuration,
    required this.progressPercentage,
  });

  final int totalStages;
  final int completedStages;
  final int inProgressStages;
  final int failedStages;
  final Duration estimatedDuration;
  final Duration actualDuration;
  final double progressPercentage;

  bool get isComplete => completedStages == totalStages;
  double get successRate => totalStages > 0 ? completedStages / totalStages : 0.0;

  @override
  String toString() {
    return 'InitializationStats('
        'progress: ${(progressPercentage * 100).toStringAsFixed(1)}%, '
        'completed: $completedStages/$totalStages, '
        'failed: $failedStages, '
        'duration: ${actualDuration.inMilliseconds}ms'
        ')';
  }
}

/// Initialization events for real-time tracking
@immutable
abstract class InitializationEvent {
  const InitializationEvent();

  factory InitializationEvent.initializationStarted({
    required InitializationStrategy strategy,
    required Duration estimatedDuration,
  }) = InitializationStartedEvent;

  factory InitializationEvent.initializationCompleted({
    required InitializationStrategy strategy,
    required Duration duration,
    required InitializationResult result,
  }) = InitializationCompletedEvent;

  factory InitializationEvent.initializationFailed({
    required InitializationStrategy strategy,
    required Duration duration,
    required String error,
    required InitializationResult result,
  }) = InitializationFailedEvent;

  factory InitializationEvent.stageStarted({required InitializationStage stage}) =
      StageStartedEvent;

  factory InitializationEvent.stageCompleted({
    required InitializationStage stage,
    required StageExecutionResult result,
  }) = StageCompletedEvent;

  factory InitializationEvent.stageFailed({
    required InitializationStage stage,
    required String error,
    required StageExecutionResult result,
  }) = StageFailedEvent;
}

class InitializationStartedEvent extends InitializationEvent {
  const InitializationStartedEvent({
    required this.strategy,
    required this.estimatedDuration,
  });

  final InitializationStrategy strategy;
  final Duration estimatedDuration;
}

class InitializationCompletedEvent extends InitializationEvent {
  const InitializationCompletedEvent({
    required this.strategy,
    required this.duration,
    required this.result,
  });

  final InitializationStrategy strategy;
  final Duration duration;
  final InitializationResult result;
}

class InitializationFailedEvent extends InitializationEvent {
  const InitializationFailedEvent({
    required this.strategy,
    required this.duration,
    required this.error,
    required this.result,
  });

  final InitializationStrategy strategy;
  final Duration duration;
  final String error;
  final InitializationResult result;
}

class StageStartedEvent extends InitializationEvent {
  const StageStartedEvent({required this.stage});
  final InitializationStage stage;
}

class StageCompletedEvent extends InitializationEvent {
  const StageCompletedEvent({
    required this.stage,
    required this.result,
  });

  final InitializationStage stage;
  final StageExecutionResult result;
}

class StageFailedEvent extends InitializationEvent {
  const StageFailedEvent({
    required this.stage,
    required this.error,
    required this.result,
  });

  final InitializationStage stage;
  final String error;
  final StageExecutionResult result;
}