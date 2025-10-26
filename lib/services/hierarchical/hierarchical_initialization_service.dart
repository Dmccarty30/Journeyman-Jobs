import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/hierarchical/hierarchical_data_model.dart';
import '../../models/user_model.dart';
import '../auth_service.dart';
import 'hierarchical_service.dart';

/// Service for managing the hierarchical initialization flow
///
/// This service orchestrates the initialization of the complete hierarchical
/// data structure based on user authentication and preferences.
///
/// Features:
/// - User-aware initialization (loads data based on user's home local and preferences)
/// - Progressive loading (loads critical data first, then enhances)
/// - Error recovery and fallback strategies
/// - Performance monitoring and optimization
/// - Integration with existing authentication system
class HierarchicalInitializationService {
  final HierarchicalService _hierarchicalService;
  final AuthService _authService;
  final FirebaseAuth _auth;

  // Initialization state
  HierarchicalInitializationState _state = HierarchicalInitializationState.idle;
  HierarchicalData? _lastKnownGoodData;

  // Stream controller for initialization state updates
  final StreamController<HierarchicalInitializationState> _stateController =
      StreamController<HierarchicalInitializationState>.broadcast();

  // Configuration
  final Duration _initializationTimeout = const Duration(seconds: 30);
  final Duration _progressiveLoadingDelay = const Duration(milliseconds: 100);

  HierarchicalInitializationService({
    HierarchicalService? hierarchicalService,
    AuthService? authService,
    FirebaseAuth? auth,
  }) : _hierarchicalService = hierarchicalService ?? HierarchicalService(),
       _authService = authService ?? AuthService(),
       _auth = auth ?? FirebaseAuth.instance;

  /// Stream of initialization state updates
  Stream<HierarchicalInitializationState> get initializationStateStream => _stateController.stream;

  /// Current initialization state
  HierarchicalInitializationState get currentState => _state;

  /// Last known good hierarchical data
  HierarchicalData? get lastKnownGoodData => _lastKnownGoodData;

  /// Initializes hierarchical data based on current user context
  ///
  /// This method automatically determines the appropriate initialization strategy
  /// based on the user's authentication status and preferences.
  Future<HierarchicalData> initializeForCurrentUser({
    bool forceRefresh = false,
    HierarchicalInitializationStrategy strategy = HierarchicalInitializationStrategy.adaptive,
  }) async {
    debugPrint('[HierarchicalInitializationService] Starting initialization for current user...');

    try {
      _updateState(HierarchicalInitializationState.initializing);

      // Get current user
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        debugPrint('[HierarchicalInitializationService] No authenticated user, initializing for guest');
        return await _initializeForGuest(forceRefresh: forceRefresh);
      }

      // Get user profile to determine preferences
      final userDoc = await _authService.getUserProfile(currentUser.uid);
      if (!userDoc.exists) {
        debugPrint('[HierarchicalInitializationService] User profile not found, initializing basic data');
        return await _initializeForGuest(forceRefresh: forceRefresh);
      }

      final user = UserModel.fromFirestore(userDoc);

      // Determine initialization strategy
      final effectiveStrategy = _determineStrategy(strategy, user);

      debugPrint('[HierarchicalInitializationService] Using strategy: $effectiveStrategy');

      switch (effectiveStrategy) {
        case HierarchicalInitializationStrategy.minimal:
          return await _initializeMinimal(user, forceRefresh: forceRefresh);

        case HierarchicalInitializationStrategy.homeLocalFirst:
          return await _initializeHomeLocalFirst(user, forceRefresh: forceRefresh);

        case HierarchicalInitializationStrategy.preferredLocalsFirst:
          return await _initializePreferredLocalsFirst(user, forceRefresh: forceRefresh);

        case HierarchicalInitializationStrategy.comprehensive:
          return await _initializeComprehensive(user, forceRefresh: forceRefresh);

        case HierarchicalInitializationStrategy.adaptive:
          return await _initializeAdaptive(user, forceRefresh: forceRefresh);
      }

    } catch (e, stackTrace) {
      debugPrint('[HierarchicalInitializationService] Initialization failed: $e');
      debugPrint('[HierarchicalInitializationService] Stack trace: $stackTrace');

      _updateState(HierarchicalInitializationState.error(
        'Failed to initialize: $e',
        stackTrace: stackTrace,
      ));

      // Return last known good data if available
      if (_lastKnownGoodData != null) {
        debugPrint('[HierarchicalInitializationService] Returning last known good data');
        return _lastKnownGoodData!;
      }

      rethrow;
    }
  }

  /// Initializes data for unauthenticated/guest users
  Future<HierarchicalData> _initializeForGuest({bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing for guest user...');

    _updateState(HierarchicalInitializationState.loadingGuestData);

    final hierarchicalData = await _hierarchicalService.initializeHierarchicalData(
      forceRefresh: forceRefresh,
    );

    _updateState(HierarchicalInitializationState.completed);
    _lastKnownGoodData = hierarchicalData;

    return hierarchicalData;
  }

  /// Initializes minimal data (basic locals and union info)
  Future<HierarchicalData> _initializeMinimal(UserModel user, {bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing minimal data...');

    _updateState(HierarchicalInitializationState.loadingMinimal);

    // Load only essential data: union and basic locals
    final hierarchicalData = await _hierarchicalService.initializeHierarchicalData(
      forceRefresh: forceRefresh,
    );

    // Add progressive loading delay for better UX
    await Future.delayed(_progressiveLoadingDelay);

    _updateState(HierarchicalInitializationState.completed);
    _lastKnownGoodData = hierarchicalData;

    return hierarchicalData;
  }

  /// Initializes data with focus on user's home local
  Future<HierarchicalData> _initializeHomeLocalFirst(UserModel user, {bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing home local first...');

    _updateState(HierarchicalInitializationState.loadingHomeLocal);

    final hierarchicalData = await _hierarchicalService.initializeHierarchicalData(
      preferredLocals: [user.homeLocal],
      forceRefresh: forceRefresh,
    );

    // Add progressive loading delay
    await Future.delayed(_progressiveLoadingDelay);

    // Then load additional data in background if needed
    _loadAdditionalDataInBackground(hierarchicalData);

    _updateState(HierarchicalInitializationState.completed);
    _lastKnownGoodData = hierarchicalData;

    return hierarchicalData;
  }

  /// Initializes data with focus on user's preferred locals
  Future<HierarchicalData> _initializePreferredLocalsFirst(UserModel user, {bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing preferred locals first...');

    _updateState(HierarchicalInitializationState.loadingPreferredLocals);

    // Parse preferred locals from user preferences
    final preferredLocals = _parsePreferredLocals(user.preferredLocals);

    // Always include home local
    if (!preferredLocals.contains(user.homeLocal)) {
      preferredLocals.add(user.homeLocal);
    }

    final hierarchicalData = await _hierarchicalService.initializeHierarchicalData(
      preferredLocals: preferredLocals,
      forceRefresh: forceRefresh,
    );

    // Add progressive loading delay
    await Future.delayed(_progressiveLoadingDelay);

    // Then load additional data in background
    _loadAdditionalDataInBackground(hierarchicalData);

    _updateState(HierarchicalInitializationState.completed);
    _lastKnownGoodData = hierarchicalData;

    return hierarchicalData;
  }

  /// Initializes comprehensive data (all available)
  Future<HierarchicalData> _initializeComprehensive(UserModel user, {bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing comprehensive data...');

    _updateState(HierarchicalInitializationState.loadingComprehensive);

    final hierarchicalData = await _hierarchicalService.initializeHierarchicalData(
      forceRefresh: forceRefresh,
    );

    _updateState(HierarchicalInitializationState.completed);
    _lastKnownGoodData = hierarchicalData;

    return hierarchicalData;
  }

  /// Initializes data with adaptive strategy based on context
  Future<HierarchicalData> _initializeAdaptive(UserModel user, {bool forceRefresh = false}) async {
    debugPrint('[HierarchicalInitializationService] Initializing with adaptive strategy...');

    // Determine adaptive strategy based on user context
    final adaptiveStrategy = _determineAdaptiveStrategy(user);

    switch (adaptiveStrategy) {
      case HierarchicalInitializationStrategy.minimal:
        return await _initializeMinimal(user, forceRefresh: forceRefresh);

      case HierarchicalInitializationStrategy.homeLocalFirst:
        return await _initializeHomeLocalFirst(user, forceRefresh: forceRefresh);

      case HierarchicalInitializationStrategy.preferredLocalsFirst:
        return await _initializePreferredLocalsFirst(user, forceRefresh: forceRefresh);

      case HierarchicalInitializationStrategy.comprehensive:
        return await _initializeComprehensive(user, forceRefresh: forceRefresh);
    }
  }

  /// Determines the most appropriate strategy based on user context
  HierarchicalInitializationStrategy _determineStrategy(
    HierarchicalInitializationStrategy requestedStrategy,
    UserModel user,
  ) {
    // If explicitly requested (not adaptive), use that strategy
    if (requestedStrategy != HierarchicalInitializationStrategy.adaptive) {
      return requestedStrategy;
    }

    return _determineAdaptiveStrategy(user);
  }

  /// Determines adaptive strategy based on user context and system conditions
  HierarchicalInitializationStrategy _determineAdaptiveStrategy(UserModel user) {
    // Strategy selection logic based on user characteristics

    // New users (less than 7 days old) get minimal initialization
    final accountAge = DateTime.now().difference(user.createdTime ?? DateTime.now());
    if (accountAge.inDays < 7) {
      debugPrint('[HierarchicalInitializationService] New user detected, using minimal strategy');
      return HierarchicalInitializationStrategy.minimal;
    }

    // Users with specific preferences get preferred locals first
    if (user.preferredLocals != null && user.preferredLocals!.isNotEmpty) {
      debugPrint('[HierarchicalInitializationService] User has preferred locals, using preferred locals strategy');
      return HierarchicalInitializationStrategy.preferredLocalsFirst;
    }

    // Working users get home local first (likely looking for jobs near home)
    if (user.isWorking) {
      debugPrint('[HierarchicalInitializationService] Working user detected, using home local first strategy');
      return HierarchicalInitializationStrategy.homeLocalFirst;
    }

    // Users seeking travel work get comprehensive data
    if (user.travelToNewLocation) {
      debugPrint('[HierarchicalInitializationService] Travel user detected, using comprehensive strategy');
      return HierarchicalInitializationStrategy.comprehensive;
    }

    // Default to home local first for most users
    debugPrint('[HierarchicalInitializationService] Using default home local first strategy');
    return HierarchicalInitializationStrategy.homeLocalFirst;
  }

  /// Parses preferred locals from user preference string
  List<int> _parsePreferredLocals(String? preferredLocalsString) {
    if (preferredLocalsString == null || preferredLocalsString.trim().isEmpty) {
      return [];
    }

    try {
      // Parse comma-separated local numbers
      final parts = preferredLocalsString.split(',');
      final locals = <int>[];

      for (final part in parts) {
        final trimmed = part.trim();
        final localNumber = int.tryParse(trimmed);
        if (localNumber != null && localNumber > 0) {
          locals.add(localNumber);
        }
      }

      return locals;
    } catch (e) {
      debugPrint('[HierarchicalInitializationService] Error parsing preferred locals: $e');
      return [];
    }
  }

  /// Loads additional data in background without blocking UI
  Future<void> _loadAdditionalDataInBackground(HierarchicalData currentData) async {
    debugPrint('[HierarchicalInitializationService] Loading additional data in background...');

    // Don't await this Future - let it run in background
    Future.microtask(() async {
      try {
        // Refresh data with comprehensive loading
        await _hierarchicalService.refreshHierarchicalData();
        debugPrint('[HierarchicalInitializationService] Background data loading completed');
      } catch (e) {
        debugPrint('[HierarchicalInitializationService] Background data loading failed: $e');
        // Don't update state - this is background enhancement
      }
    });
  }

  /// Reinitializes data when user preferences change
  Future<HierarchicalData> reinitializeForUserPreferences(UserModel updatedUser) async {
    debugPrint('[HierarchicalInitializationService] Reinitializing for updated user preferences...');

    // Clear cache to force fresh data
    _hierarchicalService.clearCache();

    // Initialize with new preferences
    return await initializeForCurrentUser(
      forceRefresh: true,
      strategy: HierarchicalInitializationStrategy.adaptive,
    );
  }

  /// Performs health check on hierarchical data
  Future<HierarchicalHealthCheckResult> performHealthCheck() async {
    debugPrint('[HierarchicalInitializationService] Performing health check...');

    try {
      final data = _hierarchicalService.cachedData;
      final isFresh = _hierarchicalService.isCacheFresh;

      return HierarchicalHealthCheckResult(
        isHealthy: data.isValid(),
        isFresh: isFresh,
        lastUpdated: data.lastUpdated,
        stats: data.stats,
        issues: _identifyHealthIssues(data),
      );
    } catch (e) {
      debugPrint('[HierarchicalInitializationService] Health check failed: $e');
      return HierarchicalHealthCheckResult(
        isHealthy: false,
        isFresh: false,
        lastUpdated: DateTime.now(),
        stats: const HierarchicalStats(
          totalLocals: 0,
          totalMembers: 0,
          totalJobs: 0,
          availableJobs: 0,
          availableMembers: 0,
          lastUpdated: null,
        ),
        issues: ['Health check failed: $e'],
      );
    }
  }

  /// Identifies health issues in hierarchical data
  List<String> _identifyHealthIssues(HierarchicalData data) {
    final issues = <String>[];

    if (data.union == null) {
      issues.add('No union data loaded');
    } else if (!data.union!.isValid()) {
      issues.add('Union data is invalid');
    }

    if (data.locals.isEmpty) {
      issues.add('No local data loaded');
    }

    if (data.members.isEmpty) {
      issues.add('No member data loaded');
    }

    if (data.jobs.isEmpty) {
      issues.add('No job data loaded');
    }

    // Check for stale data
    final age = DateTime.now().difference(data.lastUpdated);
    if (age.inHours > 1) {
      issues.add('Data is stale (${age.inMinutes} minutes old)');
    }

    return issues;
  }

  /// Updates initialization state and notifies listeners
  void _updateState(HierarchicalInitializationState newState) {
    _state = newState;
    _stateController.add(newState);
    debugPrint('[HierarchicalInitializationService] State updated to: $newState');
  }

  /// Resets the initialization service
  void reset() {
    debugPrint('[HierarchicalInitializationService] Resetting initialization service...');
    _updateState(HierarchicalInitializationState.idle);
    _lastKnownGoodData = null;
  }

  /// Disposes the initialization service
  void dispose() {
    debugPrint('[HierarchicalInitializationService] Disposing initialization service...');
    _stateController.close();
  }
}

/// Initialization state for hierarchical data loading
@immutable
class HierarchicalInitializationState {
  final HierarchicalInitializationPhase phase;
  final String? error;
  final StackTrace? stackTrace;
  final double? progress;

  const HierarchicalInitializationState._({
    required this.phase,
    this.error,
    this.stackTrace,
    this.progress,
  });

  factory HierarchicalInitializationState.idle() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.idle);

  factory HierarchicalInitializationState.initializing() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.initializing);

  factory HierarchicalInitializationState.loadingGuestData() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.loadingGuestData);

  factory HierarchicalInitializationState.loadingMinimal() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.loadingMinimal);

  factory HierarchicalInitializationState.loadingHomeLocal() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.loadingHomeLocal);

  factory HierarchicalInitializationState.loadingPreferredLocals() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.loadingPreferredLocals);

  factory HierarchicalInitializationState.loadingComprehensive() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.loadingComprehensive);

  factory HierarchicalInitializationState.completed() =>
      const HierarchicalInitializationState._(phase: HierarchicalInitializationPhase.completed);

  factory HierarchicalInitializationState.error(String error, {StackTrace? stackTrace}) =>
      HierarchicalInitializationState._(
        phase: HierarchicalInitializationPhase.error,
        error: error,
        stackTrace: stackTrace,
      );

  bool get isIdle => phase == HierarchicalInitializationPhase.idle;
  bool get isInitializing => phase.index >= HierarchicalInitializationPhase.initializing.index &&
                             phase.index <= HierarchicalInitializationPhase.loadingComprehensive.index;
  bool get isCompleted => phase == HierarchicalInitializationPhase.completed;
  bool get hasError => phase == HierarchicalInitializationPhase.error;

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is HierarchicalInitializationState &&
        other.phase == phase &&
        other.error == error;
  }

  @override
  int get hashCode => Object.hash(phase, error);

  @override
  String toString() {
    if (hasError) {
      return 'HierarchicalInitializationState.$phase(error: $error)';
    }
    return 'HierarchicalInitializationState.$phase';
  }
}

/// Initialization phase enumeration
enum HierarchicalInitializationPhase {
  idle,
  initializing,
  loadingGuestData,
  loadingMinimal,
  loadingHomeLocal,
  loadingPreferredLocals,
  loadingComprehensive,
  completed,
  error,
}

/// Initialization strategy enumeration
enum HierarchicalInitializationStrategy {
  /// Load only essential data (union, basic locals)
  minimal,

  /// Load user's home local first, then expand
  homeLocalFirst,

  /// Load user's preferred locals first, then expand
  preferredLocalsFirst,

  /// Load all available data
  comprehensive,

  /// Automatically determine best strategy based on context
  adaptive,
}

/// Result of a hierarchical health check
@immutable
class HierarchicalHealthCheckResult {
  final bool isHealthy;
  final bool isFresh;
  final DateTime lastUpdated;
  final HierarchicalStats stats;
  final List<String> issues;

  const HierarchicalHealthCheckResult({
    required this.isHealthy,
    required this.isFresh,
    required this.lastUpdated,
    required this.stats,
    required this.issues,
  });

  bool get hasIssues => issues.isNotEmpty;

  @override
  String toString() {
    return 'HierarchicalHealthCheckResult(healthy: $isHealthy, fresh: $isFresh, issues: ${issues.length})';
  }
}