import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/user_model.dart';
import '../models/filter_criteria.dart';
import '../models/locals_record.dart';
import '../services/auth_service.dart';
import '../services/resilient_firestore_service.dart';
import '../services/connectivity_service.dart';

/// Consolidated app state provider that manages all core application state
/// 
/// This provider serves as a single source of truth for:
/// - Authentication state
/// - User data and preferences  
/// - Jobs data with filtering
/// - Locals data
/// - Loading and error states
/// - Subscription management
class AppStateProvider extends ChangeNotifier {
  final AuthService _authService;
  final ResilientFirestoreService _firestoreService;
  final ConnectivityService _connectivityService;

  // Core state
  User? _user;
  UserModel? _userProfile;
  List<Job> _jobs = [];
  List<LocalsRecord> _locals = [];
  JobFilterCriteria _activeFilter = JobFilterCriteria.empty();
  
  // UI state
  bool _isLoadingAuth = false;
  bool _isLoadingJobs = false;
  bool _isLoadingLocals = false;
  bool _isLoadingUserProfile = false;
  
  // Error state
  String? _authError;
  String? _jobsError;
  String? _localsError;
  String? _userProfileError;
  
  // Pagination state
  DocumentSnapshot? _lastJobDocument;
  DocumentSnapshot? _lastLocalDocument;
  bool _hasMoreJobs = true;
  bool _hasMoreLocals = true;
  
  // Subscription management
  final Map<String, StreamSubscription> _subscriptions = {};
  
  // Getters for state
  User? get user => _user;
  UserModel? get userProfile => _userProfile;
  List<Job> get jobs => _jobs;
  List<LocalsRecord> get locals => _locals;
  JobFilterCriteria get activeFilter => _activeFilter;
  
  // Loading state getters
  bool get isLoadingAuth => _isLoadingAuth;
  bool get isLoadingJobs => _isLoadingJobs;
  bool get isLoadingLocals => _isLoadingLocals;
  bool get isLoadingUserProfile => _isLoadingUserProfile;
  bool get isLoading => _isLoadingAuth || _isLoadingJobs || _isLoadingLocals || _isLoadingUserProfile;
  
  // Error state getters
  String? get authError => _authError;
  String? get jobsError => _jobsError;
  String? get localsError => _localsError;
  String? get userProfileError => _userProfileError;
  bool get hasError => _authError != null || _jobsError != null || _localsError != null || _userProfileError != null;
  
  // Pagination getters
  bool get hasMoreJobs => _hasMoreJobs;
  bool get hasMoreLocals => _hasMoreLocals;
  
  // Computed state
  bool get isAuthenticated => _user != null;
  bool get hasProfile => _userProfile != null;
  bool get isOnline => _connectivityService.isOnline;
  
  AppStateProvider(this._authService, this._firestoreService, this._connectivityService) {
    _initializeListeners();
  }

  /// Initialize all data listeners and subscriptions
  void _initializeListeners() {
    // Listen to authentication state changes
    _subscriptions['auth'] = _authService.authStateChanges.listen(
      _handleAuthStateChange,
      onError: _handleAuthError,
    );
    
    // Listen to connectivity changes for offline/online sync
    _subscriptions['connectivity'] = Stream.periodic(
      const Duration(seconds: 30),
      (_) => _connectivityService.isOnline,
    ).listen(_handleConnectivityChange);
    
    if (kDebugMode) {
      print('AppStateProvider: Initialized with ${_subscriptions.length} listeners');
    }
  }

  /// Handle authentication state changes
  void _handleAuthStateChange(User? user) {
    final wasAuthenticated = _user != null;
    _user = user;
    _authError = null;
    
    if (kDebugMode) {
      print('AppStateProvider: Auth state changed - ${user != null ? 'logged in' : 'logged out'}');
    }
    
    if (user != null) {
      // User logged in - load their data
      if (!wasAuthenticated) {
        _loadUserData();
      }
    } else {
      // User logged out - clear all data
      _clearUserData();
    }
    
    notifyListeners();
  }

  /// Handle authentication errors
  void _handleAuthError(dynamic error) {
    _authError = error.toString();
    _isLoadingAuth = false;
    
    if (kDebugMode) {
      print('AppStateProvider: Auth error - $error');
    }
    
    notifyListeners();
  }

  /// Handle connectivity state changes
  void _handleConnectivityChange(bool isOnline) {
    if (isOnline && _user != null) {
      // Back online - refresh data if stale
      _refreshStaleData();
    }
  }

  /// Load user-specific data after authentication
  Future<void> _loadUserData() async {
    if (_user == null) return;
    
    await Future.wait([
      _loadUserProfile(),
      _loadUserJobs(),
      _loadUserLocals(),
    ]);
  }

  /// Load user profile data
  Future<void> _loadUserProfile() async {
    if (_user == null) return;
    
    _isLoadingUserProfile = true;
    _userProfileError = null;
    notifyListeners();
    
    try {
      final userDoc = await _firestoreService.getUserProfile(_user!.uid);
      _userProfile = userDoc != null ? UserModel.fromFirestore(userDoc) : null;
      
      if (kDebugMode) {
        print('AppStateProvider: User profile loaded');
      }
    } catch (e) {
      _userProfileError = e.toString();
      
      if (kDebugMode) {
        print('AppStateProvider: Error loading user profile - $e');
      }
    } finally {
      _isLoadingUserProfile = false;
      notifyListeners();
    }
  }

  /// Load user's relevant jobs with current filter
  Future<void> _loadUserJobs({bool isRefresh = false}) async {
    if (_user == null) return;
    
    if (isRefresh) {
      _lastJobDocument = null;
      _hasMoreJobs = true;
      _jobs.clear();
    }
    
    _isLoadingJobs = true;
    _jobsError = null;
    notifyListeners();
    
    try {
      final snapshot = await _firestoreService.getJobsWithFilter(
        filter: _activeFilter,
        startAfter: _lastJobDocument,
        limit: 20,
      );
      
      final newJobs = snapshot.docs
          .map((doc) => Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>))
          .toList();
      
      if (isRefresh) {
        _jobs = newJobs;
      } else {
        _jobs.addAll(newJobs);
      }
      
      _lastJobDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreJobs = snapshot.docs.length == 20; // Has more if we got a full page
      
      if (kDebugMode) {
        print('AppStateProvider: Loaded ${newJobs.length} jobs (total: ${_jobs.length})');
      }
    } catch (e) {
      _jobsError = e.toString();
      
      if (kDebugMode) {
        print('AppStateProvider: Error loading jobs - $e');
      }
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Load more jobs (pagination)
  Future<void> loadMoreJobs() async {
    if (!_hasMoreJobs || _isLoadingJobs) return;
    await _loadUserJobs(isRefresh: false);
  }

  /// Load user's relevant locals
  Future<void> _loadUserLocals({bool isRefresh = false}) async {
    if (isRefresh) {
      _lastLocalDocument = null;
      _hasMoreLocals = true;
      _locals.clear();
    }
    
    _isLoadingLocals = true;
    _localsError = null;
    notifyListeners();
    
    try {
      // Get user's state preference for geographic filtering
      final userState = _userProfile?.state;
      
      final snapshot = await _firestoreService.getLocals(
        state: userState,
        startAfter: _lastLocalDocument,
        limit: 50,
      ).first;
      
      final newLocals = snapshot.docs
          .map((doc) => LocalsRecord.fromFirestore(doc))
          .toList();
      
      if (isRefresh) {
        _locals = newLocals;
      } else {
        _locals.addAll(newLocals);
      }
      
      _lastLocalDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMoreLocals = snapshot.docs.length == 50; // Has more if we got a full page
      
      if (kDebugMode) {
        print('AppStateProvider: Loaded ${newLocals.length} locals (total: ${_locals.length})');
      }
    } catch (e) {
      _localsError = e.toString();
      
      if (kDebugMode) {
        print('AppStateProvider: Error loading locals - $e');
      }
    } finally {
      _isLoadingLocals = false;
      notifyListeners();
    }
  }

  /// Load more locals (pagination)
  Future<void> loadMoreLocals() async {
    if (!_hasMoreLocals || _isLoadingLocals) return;
    await _loadUserLocals(isRefresh: false);
  }

  /// Update job filter and refresh jobs
  Future<void> updateJobFilter(JobFilterCriteria newFilter) async {
    _activeFilter = newFilter;
    
    if (kDebugMode) {
      print('AppStateProvider: Filter updated - refreshing jobs');
    }
    
    // Refresh jobs with new filter
    await _loadUserJobs(isRefresh: true);
  }

  /// Refresh all data
  Future<void> refreshAll() async {
    if (_user == null) return;
    
    if (kDebugMode) {
      print('AppStateProvider: Refreshing all data');
    }
    
    await Future.wait([
      _loadUserProfile(),
      _loadUserJobs(isRefresh: true),
      _loadUserLocals(isRefresh: true),
    ]);
  }

  /// Refresh jobs only
  Future<void> refreshJobs() async {
    await _loadUserJobs(isRefresh: true);
  }

  /// Refresh locals only
  Future<void> refreshLocals() async {
    await _loadUserLocals(isRefresh: true);
  }

  /// Refresh stale data when connectivity is restored
  Future<void> _refreshStaleData() async {
    // Check if data is stale and refresh if needed
    bool needsRefresh = false;
    
    // For now, always refresh when coming back online
    // In a production app, you'd track last update timestamps
    if (_user != null) {
      needsRefresh = true;
    }
    
    if (needsRefresh) {
      if (kDebugMode) {
        print('AppStateProvider: Refreshing stale data after coming online');
      }
      
      await refreshAll();
    }
  }

  /// Clear all user data (on logout)
  void _clearUserData() {
    _userProfile = null;
    _jobs.clear();
    _locals.clear();
    _activeFilter = JobFilterCriteria.empty();
    
    // Clear pagination state
    _lastJobDocument = null;
    _lastLocalDocument = null;
    _hasMoreJobs = true;
    _hasMoreLocals = true;
    
    // Clear loading states
    _isLoadingUserProfile = false;
    _isLoadingJobs = false;
    _isLoadingLocals = false;
    
    // Clear errors
    _userProfileError = null;
    _jobsError = null;
    _localsError = null;
    
    if (kDebugMode) {
      print('AppStateProvider: User data cleared');
    }
  }

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoadingAuth = true;
    _authError = null;
    notifyListeners();
    
    try {
      await _authService.signInWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  /// Sign up with email and password
  Future<bool> signUpWithEmailAndPassword(String email, String password) async {
    _isLoadingAuth = true;
    _authError = null;
    notifyListeners();
    
    try {
      await _authService.signUpWithEmailAndPassword(email: email, password: password);
      return true;
    } catch (e) {
      _authError = e.toString();
      return false;
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  /// Sign out
  Future<void> signOut() async {
    _isLoadingAuth = true;
    notifyListeners();
    
    try {
      await _authService.signOut();
    } catch (e) {
      _authError = e.toString();
    } finally {
      _isLoadingAuth = false;
      notifyListeners();
    }
  }

  /// Update user profile
  Future<bool> updateUserProfile(UserModel updatedProfile) async {
    if (_user == null) return false;
    
    _isLoadingUserProfile = true;
    _userProfileError = null;
    notifyListeners();
    
    try {
      await _firestoreService.updateUserProfile(_user!.uid, updatedProfile);
      _userProfile = updatedProfile;
      
      // Refresh jobs and locals as preferences may have changed
      await Future.wait([
        _loadUserJobs(isRefresh: true),
        _loadUserLocals(isRefresh: true),
      ]);
      
      return true;
    } catch (e) {
      _userProfileError = e.toString();
      return false;
    } finally {
      _isLoadingUserProfile = false;
      notifyListeners();
    }
  }

  /// Get app state summary for debugging
  Map<String, dynamic> getStateSummary() {
    return {
      'isAuthenticated': isAuthenticated,
      'hasProfile': hasProfile,
      'jobsCount': _jobs.length,
      'localsCount': _locals.length,
      'isLoading': isLoading,
      'hasError': hasError,
      'isOnline': isOnline,
      'subscriptionsCount': _subscriptions.length,
      'activeFilter': _activeFilter.toJson(),
    };
  }

  /// Cleanup subscriptions and resources
  @override
  void dispose() {
    // Cancel all subscriptions
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    _subscriptions.clear();
    
    if (kDebugMode) {
      print('AppStateProvider: Disposed with cleanup of ${_subscriptions.length} subscriptions');
    }
    
    super.dispose();
  }
}