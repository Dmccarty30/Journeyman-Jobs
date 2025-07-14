import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';
import '../models/filter_criteria.dart';
import '../services/auth_service.dart';
import '../services/resilient_firestore_service.dart';
import '../utils/compressed_state_manager.dart';
import 'auth_provider.dart' as auth_prov;
import 'jobs_provider.dart';
import 'locals_provider.dart';

/// Orchestrating provider that composes domain-specific providers
/// 
/// This provider coordinates between AuthProvider, JobsProvider, and LocalsProvider
/// while maintaining backward compatibility with existing UI components.
/// 
/// Features:
/// - Domain-specific provider composition
/// - Centralized state management coordination
/// - Compressed state persistence
/// - Performance monitoring across providers
/// - Memory management coordination
class AppStateProvider extends ChangeNotifier {
  // Domain-specific providers
  late final AuthProvider _authProvider;
  late final JobsProvider _jobsProvider;
  late final LocalsProvider _localsProvider;

  // Services
  final AuthService _authService;
  final ResilientFirestoreService _firestoreService;
  late final CompressedStateManager _stateManager;

  // Provider subscriptions for coordination
  final Map<String, StreamSubscription> _providerSubscriptions = {};
  
  // Memory monitoring
  Timer? _memoryMonitorTimer;
  
  // Initialization state
  bool _isInitialized = false;
  String? _initializationError;

  // Getters for backward compatibility - delegate to domain providers
  
  // Auth state (delegated to AuthProvider)
  bool get isSignedIn => _authProvider.isAuthenticated;
  bool get isAuthenticated => _authProvider.isAuthenticated;
  bool get isLoading => _authProvider.isLoadingAuth || _jobsProvider.isLoadingJobs || _localsProvider.isLoadingLocals;
  bool get isLoadingAuth => _authProvider.isLoadingAuth;
  bool get isLoadingJobs => _jobsProvider.isLoadingJobs;
  bool get isLoadingLocals => _localsProvider.isLoadingLocals;
  bool get hasError => _authProvider.authError != null || _jobsProvider.jobsError != null || _localsProvider.localsError != null;
  String? get errorMessage => _authProvider.authError ?? _jobsProvider.jobsError ?? _localsProvider.localsError;
  String? get authError => _authProvider.authError;
  String? get jobsError => _jobsProvider.jobsError;
  String? get localsError => _localsProvider.localsError;

  // User access
  User? get user => _authProvider.user;

  // Jobs state (delegated to JobsProvider)
  List<Job> get jobs => _jobsProvider.jobs;
  List<Job> get filteredJobs => _jobsProvider.jobs; // JobsProvider manages filtering internally
  JobFilterCriteria? get activeJobFilter => _jobsProvider.activeFilter;
  JobFilterCriteria? get activeFilter => _jobsProvider.activeFilter;
  bool get hasMoreJobs => _jobsProvider.hasMoreJobs;

  // Locals state (delegated to LocalsProvider)
  List<LocalsRecord> get locals => _localsProvider.locals;
  bool get hasMoreLocals => _localsProvider.hasMoreLocals;

  // Provider access for advanced usage
  AuthProvider get authProvider => _authProvider;
  JobsProvider get jobsProvider => _jobsProvider;
  LocalsProvider get localsProvider => _localsProvider;

  // Initialization status
  bool get isInitialized => _isInitialized;
  String? get initializationError => _initializationError;

  AppStateProvider(this._authService, this._firestoreService) {
    _initializeProviders();
  }

  /// Initialize domain-specific providers and set up coordination
  Future<void> _initializeProviders() async {
    try {
      // Initialize state manager
      _stateManager = CompressedStateManager();
      
      // Initialize domain providers
      _authProvider = AuthProvider(_authService);
      _jobsProvider = JobsProvider(_firestoreService);
      _localsProvider = LocalsProvider(_firestoreService);

      // Load saved state
      await _loadSavedState();

      // Set up provider coordination
      _setupProviderCoordination();

      // Set up memory monitoring
      _setupMemoryMonitoring();

      _isInitialized = true;
      _initializationError = null;

      if (kDebugMode) {
        print('AppStateProvider: Initialized with domain providers');
      }

      notifyListeners();
    } catch (e) {
      _initializationError = e.toString();
      _isInitialized = false;

      if (kDebugMode) {
        print('AppStateProvider: Initialization error - $e');
      }

      notifyListeners();
    }
  }

  /// Load saved state from compressed storage
  Future<void> _loadSavedState() async {
    try {
      final savedState = await _stateManager.loadState();
      if (savedState != null && savedState is Map<String, dynamic>) {
        // Note: Individual providers handle their own state restoration
        // This is just for coordination-level state if needed
        
        if (kDebugMode) {
          print('AppStateProvider: Saved state loaded');
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error loading saved state - $e');
      }
      // Don't fail initialization due to state loading errors
    }
  }

  /// Set up coordination between domain providers
  void _setupProviderCoordination() {
    // Listen to auth state changes to trigger data reload
    _providerSubscriptions['auth'] = _authProvider.addListener(() {
      if (_authProvider.isSignedIn) {
        // User signed in - initialize data providers
        _jobsProvider.loadJobs(isRefresh: true);
        _localsProvider.loadLocals(isRefresh: true);
      } else {
        // User signed out - clear data
        _jobsProvider.clearJobs();
        _localsProvider.clearFilters();
      }
      
      // Propagate changes to listeners
      notifyListeners();
    }) as StreamSubscription;

    // Listen to jobs provider changes
    _providerSubscriptions['jobs'] = _jobsProvider.addListener(() {
      // Trigger memory cleanup if needed
      _jobsProvider.performMemoryCleanup();
      notifyListeners();
    }) as StreamSubscription;

    // Listen to locals provider changes  
    _providerSubscriptions['locals'] = _localsProvider.addListener(() {
      // Trigger memory cleanup if needed
      _localsProvider.performMemoryCleanup();
      notifyListeners();
    }) as StreamSubscription;
  }

  /// Set up periodic memory monitoring
  void _setupMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _performCoordinatedMemoryCleanup(),
    );
  }

  /// Perform coordinated memory cleanup across all providers
  void _performCoordinatedMemoryCleanup() {
    _jobsProvider.performMemoryCleanup();
    _localsProvider.performMemoryCleanup();
    
    if (kDebugMode) {
      print('AppStateProvider: Coordinated memory cleanup performed');
    }
  }

  // Delegated authentication methods

  /// Sign in with email and password (delegated to AuthProvider)
  Future<bool> signInWithEmailAndPassword(String email, String password) {
    return _authProvider.signInWithEmailAndPassword(email, password);
  }

  /// Sign out (delegated to AuthProvider)
  Future<void> signOut() {
    return _authProvider.signOut();
  }

  /// Clear auth error (delegated to AuthProvider)
  void clearAuthError() {
    _authProvider.clearError();
  }

  // Delegated jobs methods

  /// Load jobs (delegated to JobsProvider)
  Future<void> loadJobs({bool isRefresh = false}) {
    return _jobsProvider.loadJobs(isRefresh: isRefresh);
  }

  /// Load more jobs (delegated to JobsProvider)
  Future<void> loadMoreJobs() {
    return _jobsProvider.loadMoreJobs();
  }

  /// Update job filter (delegated to JobsProvider)
  Future<void> updateActiveFilter(JobFilter filter) {
    return _jobsProvider.updateJobFilter(filter);
  }

  /// Clear job filter (delegated to JobsProvider)
  void clearJobFilter() {
    _jobsProvider.clearFilter();
  }

  /// Clear jobs error (delegated to JobsProvider)
  void clearJobsError() {
    _jobsProvider.clearJobsError();
  }

  // Delegated locals methods

  /// Load locals (delegated to LocalsProvider)
  Future<void> loadLocals({bool isRefresh = false, String? state}) {
    return _localsProvider.loadLocals(isRefresh: isRefresh, state: state);
  }

  /// Load more locals (delegated to LocalsProvider)
  Future<void> loadMoreLocals() {
    return _localsProvider.loadMoreLocals();
  }

  /// Search locals (delegated to LocalsProvider)
  Future<void> searchLocals(String query) {
    return _localsProvider.searchLocals(query);
  }

  /// Filter locals by state (delegated to LocalsProvider)
  Future<void> filterLocalsByState(String? state) {
    return _localsProvider.filterByState(state);
  }

  /// Get locals by state (delegated to LocalsProvider)
  List<LocalsRecord> getLocalsByState(String state) {
    return _localsProvider.getLocalsByState(state);
  }

  /// Get local by number (delegated to LocalsProvider)
  LocalsRecord? getLocalByNumber(int localNumber) {
    return _localsProvider.getLocalByNumber(localNumber);
  }

  /// Clear locals error (delegated to LocalsProvider)
  void clearLocalsError() {
    _localsProvider.clearLocalsError();
  }

  // Utility methods

  /// Get visible jobs (delegated to JobsProvider)
  List<Job> getVisibleJobs() {
    return _jobsProvider.visibleJobs;
  }

  /// Update virtual job list (delegated to JobsProvider)
  void updateVirtualJobList(int startIndex) {
    _jobsProvider.updateVirtualList(startIndex);
  }

  /// Get operation stats from all providers
  Map<String, dynamic> getOperationStats() {
    return {
      'auth': _authProvider.getPerformanceMetrics(),
      'jobs': _jobsProvider.getPerformanceMetrics(),
      'locals': _localsProvider.getPerformanceMetrics(),
      'compressed_state': _stateManager.getPerformanceMetrics(),
      'coordination': {
        'initialized': _isInitialized,
        'providerSubscriptions': _providerSubscriptions.length,
        'memoryMonitoringActive': _memoryMonitorTimer?.isActive ?? false,
      },
    };
  }

  /// Get combined performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return {
      'providers': {
        'auth': _authProvider.getPerformanceMetrics(),
        'jobs': _jobsProvider.getPerformanceMetrics(),
        'locals': _localsProvider.getPerformanceMetrics(),
      },
      'stateManager': _stateManager.getPerformanceMetrics(),
      'coordination': {
        'initialized': _isInitialized,
        'activeSubscriptions': _providerSubscriptions.length,
        'memoryMonitoringActive': _memoryMonitorTimer?.isActive ?? false,
      },
    };
  }

  /// Save state before disposal
  Future<void> _saveStateOnDispose() async {
    try {
      final combinedState = {
        'auth': _authProvider.getStateSnapshot(),
        'jobs': _jobsProvider.getStateSnapshot(),
        'locals': _localsProvider.getStateSnapshot(),
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await _stateManager.saveState(combinedState);
      
      if (kDebugMode) {
        print('AppStateProvider: State saved on dispose');
      }
    } catch (e) {
      if (kDebugMode) {
        print('AppStateProvider: Error saving state on dispose - $e');
      }
    }
  }

  /// Cleanup subscriptions and resources
  @override
  void dispose() async {
    // Save state before disposing
    await _saveStateOnDispose();
    
    // Cancel memory monitoring timer
    _memoryMonitorTimer?.cancel();
    
    // Dispose domain providers
    _authProvider.dispose();
    _jobsProvider.dispose();
    _localsProvider.dispose();
    
    // Cancel all subscriptions
    for (final subscription in _providerSubscriptions.values) {
      subscription.cancel();
    }
    _providerSubscriptions.clear();
    
    if (kDebugMode) {
      print('AppStateProvider: Disposed with cleanup of ${_providerSubscriptions.length} provider subscriptions');
    }
    
    super.dispose();
  }
}