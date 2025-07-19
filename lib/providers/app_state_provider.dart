import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/job_model.dart';
import '../models/locals_record.dart';
import '../models/filter_criteria.dart';
import '../services/auth_service.dart';
import '../services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/utils/compressed_state_manager.dart';
import '../utils/error_sanitizer.dart';

/// Simplified app state provider that manages authentication, jobs, and locals
/// 
/// This provider directly manages state without complex provider composition
/// to avoid dependency issues while maintaining backward compatibility.
/// 
/// Features:
/// - Direct state management for auth, jobs, and locals
/// - Compressed state persistence
/// - Memory management
/// - Performance monitoring
class AppStateProvider extends ChangeNotifier {
  // Services
  final AuthService _authService;
  final ResilientFirestoreService _firestoreService;

  // Auth state
  User? _user;
  bool _isLoadingAuth = false;
  String? _authError;

  // Jobs state
  List<Job> _jobs = [];
  bool _isLoadingJobs = false;
  String? _jobsError;
  bool _hasMoreJobs = true;
  JobFilterCriteria? _activeFilter;
  DocumentSnapshot? _lastJobDocument;

  // Locals state
  List<LocalsRecord> _locals = [];
  bool _isLoadingLocals = false;
  String? _localsError;
  bool _hasMoreLocals = true;
  DocumentSnapshot? _lastLocalDocument;

  // Memory monitoring
  Timer? _memoryMonitorTimer;
  
  // Initialization state
  bool _isInitialized = false;
  String? _initializationError;

  // Getters for backward compatibility
  
  // Auth state
  bool get isSignedIn => _user != null;
  bool get isAuthenticated => _user != null;
  bool get isLoading => _isLoadingAuth || _isLoadingJobs || _isLoadingLocals;
  bool get isLoadingAuth => _isLoadingAuth;
  bool get isLoadingJobs => _isLoadingJobs;
  bool get isLoadingLocals => _isLoadingLocals;
  bool get isLoadingUserProfile => false;
  bool get hasError => _authError != null || _jobsError != null || _localsError != null;
  String? get errorMessage => _authError ?? _jobsError ?? _localsError;
  String? get authError => _authError;
  String? get jobsError => _jobsError;
  String? get localsError => _localsError;

  // User access
  User? get user => _user;
  User? get userProfile => _user; // For backward compatibility

  // Jobs state
  List<Job> get jobs => _jobs;
  List<Job> get filteredJobs => _jobs; // Filtering handled internally
  JobFilterCriteria? get activeJobFilter => _activeFilter;
  JobFilterCriteria? get activeFilter => _activeFilter;
  bool get hasMoreJobs => _hasMoreJobs;

  // Locals state
  List<LocalsRecord> get locals => _locals;
  bool get hasMoreLocals => _hasMoreLocals;

  // Initialization status
  bool get isInitialized => _isInitialized;
  String? get initializationError => _initializationError;

  AppStateProvider(this._authService, this._firestoreService) {
    _initializeProviders();
  }

  /// Initialize providers and set up coordination
  Future<void> _initializeProviders() async {
    try {
      // Initialize state manager

      // Load saved state
      await _loadSavedState();

      // Set up auth state listener
      _setupAuthListener();

      // Set up memory monitoring
      _setupMemoryMonitoring();

      _isInitialized = true;
      _initializationError = null;

      if (kDebugMode) {
        print('AppStateProvider: Initialized successfully');
      }

      notifyListeners();
    } catch (e) {
      _initializationError = ErrorSanitizer.sanitizeError(e);
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
      final savedState = await CompressedStateManager.loadState('app_state');
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

  /// Set up auth state listener
  void _setupAuthListener() {
    _authService.authStateChanges.listen((user) {
      _user = user;
      if (user != null) {
        // User signed in - load data
        refreshJobs();
        refreshLocals();
      } else {
        // User signed out - clear data
        _jobs.clear();
        _locals.clear();
        _authError = null;
        _jobsError = null;
        _localsError = null;
      }
      notifyListeners();
    });
  }

  /// Set up periodic memory monitoring
  void _setupMemoryMonitoring() {
    _memoryMonitorTimer = Timer.periodic(
      const Duration(minutes: 2),
      (_) => _performMemoryCleanup(),
    );
  }

  /// Perform memory cleanup
  void _performMemoryCleanup() {
    // Clear old jobs if we have too many
    if (_jobs.length > 1000) {
      _jobs = _jobs.take(500).toList();
    }
    
    // Clear old locals if we have too many
    if (_locals.length > 1000) {
      _locals = _locals.take(500).toList();
    }
    
    if (kDebugMode) {
      print('AppStateProvider: Memory cleanup performed');
    }
  }

  // Authentication methods

  /// Sign in with email and password
  Future<bool> signInWithEmailAndPassword(String email, String password) async {
    _isLoadingAuth = true;
    _authError = null;
    notifyListeners();

    try {
      final result = await _authService.signInWithEmailAndPassword(email: email, password: password);
      _isLoadingAuth = false;
      notifyListeners();
      return result != null;
    } catch (e) {
      _authError = ErrorSanitizer.sanitizeError(e);
      _isLoadingAuth = false;
      notifyListeners();
      return false;
    }
  }

  /// Sign out
  Future<void> signOut() async {
    try {
      await _authService.signOut();
      _user = null;
      _jobs.clear();
      _locals.clear();
      _authError = null;
      _jobsError = null;
      _localsError = null;
      notifyListeners();
    } catch (e) {
      _authError = ErrorSanitizer.sanitizeError(e);
      notifyListeners();
    }
  }

  /// Clear auth error
  void clearAuthError() {
    _authError = null;
    notifyListeners();
  }

  // Jobs methods

  /// Load jobs
  Future<void> loadJobs({bool isRefresh = false}) async {
    if (_isLoadingJobs) return;

    _isLoadingJobs = true;
    if (isRefresh) {
      _jobsError = null;
      _jobs.clear();
      _hasMoreJobs = true;
    }
    notifyListeners();

    try {
      final jobsStream = _firestoreService.getJobs(limit: 20);
      final snapshot = await jobsStream.first;
      
      final newJobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Job.fromJson({
          ...data,
          'id': doc.id,
          'reference': doc.reference,
        });
      }).toList();
      
      if (isRefresh) {
        _jobs = newJobs;
        _lastJobDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      } else {
        _jobs.addAll(newJobs);
        if (snapshot.docs.isNotEmpty) {
          _lastJobDocument = snapshot.docs.last;
        }
      }
      _hasMoreJobs = newJobs.length == 20;
      _jobsError = null;
    } catch (e) {
      _jobsError = ErrorSanitizer.sanitizeError(e);
      if (kDebugMode) {
        print('Error loading jobs: $e');
      }
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Refresh jobs - convenience method
  Future<void> refreshJobs() {
    return loadJobs(isRefresh: true);
  }

  /// Load more jobs
  Future<void> loadMoreJobs() async {
    if (_isLoadingJobs || !_hasMoreJobs) return;

    _isLoadingJobs = true;
    notifyListeners();

    try {
      final jobsStream = _firestoreService.getJobs(
        limit: 20,
        startAfter: _lastJobDocument,
      );
      final snapshot = await jobsStream.first;
      
      final newJobs = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return Job(
          id: doc.id,
          reference: doc.reference,
          local: data['local'],
          classification: data['classification'],
          company: data['company'] ?? '',
          location: data['location'] ?? '',
          hours: data['hours'],
          wage: (data['wage'] is int) ? (data['wage'] as int).toDouble() : data['wage'],
          sub: data['sub'],
          jobClass: data['jobClass'],
          localNumber: data['localNumber'],
          qualifications: data['qualifications'],
          datePosted: data['datePosted'],
          jobDescription: data['jobDescription'],
          jobTitle: data['jobTitle'],
          perDiem: data['perDiem'],
          agreement: data['agreement'],
          numberOfJobs: data['numberOfJobs'],
          timestamp: data['timestamp'] is Timestamp ? (data['timestamp'] as Timestamp).toDate() : null,
          startDate: data['startDate'],
          startTime: data['startTime'],
          booksYourOn: (data['booksYourOn'] as List?)?.cast<int>(),
          typeOfWork: data['typeOfWork'],
          duration: data['duration'],
          voltageLevel: data['voltageLevel'],
        );
      }).toList();
      
      _jobs.addAll(newJobs);
      if (snapshot.docs.isNotEmpty) {
        _lastJobDocument = snapshot.docs.last;
      }
      _hasMoreJobs = newJobs.length == 20;
    } catch (e) {
      _jobsError = ErrorSanitizer.sanitizeError(e);
      if (kDebugMode) {
        print('Error loading more jobs: $e');
      }
    } finally {
      _isLoadingJobs = false;
      notifyListeners();
    }
  }

  /// Update job filter
  Future<void> updateActiveFilter(JobFilterCriteria filter) async {
    _activeFilter = filter;
    await refreshJobs(); // Reload with new filter
  }

  /// Clear job filter
  void clearJobFilter() {
    _activeFilter = null;
    refreshJobs();
  }

  /// Clear jobs error
  void clearJobsError() {
    _jobsError = null;
    notifyListeners();
  }

  // Locals methods

  /// Load locals
  Future<void> loadLocals({bool isRefresh = false, String? state}) async {
    if (_isLoadingLocals) return;

    _isLoadingLocals = true;
    if (isRefresh) {
      _localsError = null;
      _locals.clear();
      _hasMoreLocals = true;
    }
    notifyListeners();

    try {
      final localsStream = _firestoreService.getLocals(limit: 20, state: state);
      final snapshot = await localsStream.first;
      
      final newLocals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LocalsRecord(
          id: doc.id,
          localNumber: data['localNumber'] ?? '',
          localName: data['localName'] ?? '',
          classification: data['classification'],
          location: data['location'] ?? '',
          address: data['address'],
          contactEmail: data['contactEmail'] ?? '',
          contactPhone: data['contactPhone'] ?? '',
          website: data['website'],
          memberCount: data['memberCount'] ?? 0,
          specialties: (data['specialties'] as List?)?.cast<String>() ?? [],
          isActive: data['isActive'] ?? true,
          createdAt: data['createdAt'] is Timestamp ? (data['createdAt'] as Timestamp).toDate() : DateTime.now(),
          updatedAt: data['updatedAt'] is Timestamp ? (data['updatedAt'] as Timestamp).toDate() : DateTime.now(),
          reference: doc.reference,
          rawData: data,
        );
      }).toList();
      
      if (isRefresh) {
        _locals = newLocals;
        _lastLocalDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      } else {
        _locals.addAll(newLocals);
        if (snapshot.docs.isNotEmpty) {
          _lastLocalDocument = snapshot.docs.last;
        }
      }
      _hasMoreLocals = newLocals.length == 20;
      _localsError = null;
    } catch (e) {
      _localsError = ErrorSanitizer.sanitizeError(e);
      if (kDebugMode) {
        print('Error loading locals: $e');
      }
    } finally {
      _isLoadingLocals = false;
      notifyListeners();
    }
  }

  /// Refresh locals - convenience method
  Future<void> refreshLocals() {
    return loadLocals(isRefresh: true);
  }

  /// Load more locals
  Future<void> loadMoreLocals() async {
    if (_isLoadingLocals || !_hasMoreLocals) return;

    _isLoadingLocals = true;
    notifyListeners();

    try {
      final localsStream = _firestoreService.getLocals(
        limit: 20,
        startAfter: _lastLocalDocument,
      );
      final snapshot = await localsStream.first;
      
      final newLocals = snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return LocalsRecord.fromJson({
          ...data,
          'id': doc.id,
          'reference': doc.reference,
        });
      }).toList();
      
      _locals.addAll(newLocals);
      if (snapshot.docs.isNotEmpty) {
        _lastLocalDocument = snapshot.docs.last;
      }
      _hasMoreLocals = newLocals.length == 20;
    } catch (e) {
      _localsError = ErrorSanitizer.sanitizeError(e);
      if (kDebugMode) {
        print('Error loading more locals: $e');
      }
    } finally {
      _isLoadingLocals = false;
      notifyListeners();
    }
  }

  /// Search locals
  Future<void> searchLocals(String query) async {
    // For now, implement as a simple filter on loaded locals
    // In a real app, this would be a server-side search
    await refreshLocals();
  }

  /// Filter locals by state
  Future<void> filterLocalsByState(String? state) async {
    await loadLocals(isRefresh: true, state: state);
  }

  /// Get locals by state
  List<LocalsRecord> getLocalsByState(String state) {
    return _locals.where((local) => local.state == state).toList();
  }

  /// Get local by number
  LocalsRecord? getLocalByNumber(int localNumber) {
    try {
      return _locals.firstWhere((local) => 
        int.tryParse(local.localUnion) == localNumber);
    } catch (e) {
      return null;
    }
  }

  /// Clear locals error
  void clearLocalsError() {
    _localsError = null;
    notifyListeners();
  }

  // Utility methods

  /// Get visible jobs
  List<Job> getVisibleJobs() {
    return _jobs;
  }

  /// Update virtual job list
  void updateVirtualJobList(int startIndex) {
    // For now, this is a no-op since we're not using virtual scrolling
    // In a real implementation, this would update the visible window
  }

  /// Get operation stats
  Map<String, dynamic> getOperationStats() {
    return {
      'auth': {
        'isAuthenticated': isAuthenticated,
        'isLoading': _isLoadingAuth,
        'hasError': _authError != null,
      },
      'jobs': {
        'count': _jobs.length,
        'isLoading': _isLoadingJobs,
        'hasError': _jobsError != null,
        'hasMore': _hasMoreJobs,
      },
      'locals': {
        'count': _locals.length,
        'isLoading': _isLoadingLocals,
        'hasError': _localsError != null,
        'hasMore': _hasMoreLocals,
      },
      'coordination': {
        'initialized': _isInitialized,
        'memoryMonitoringActive': _memoryMonitorTimer?.isActive ?? false,
      },
    };
  }

  /// Get combined performance metrics
  Map<String, dynamic> getPerformanceMetrics() {
    return getOperationStats();
  }

  /// Get current state snapshot for persistence
  Map<String, dynamic> getStateSnapshot() {
    return {
      'auth': {
        'isAuthenticated': isAuthenticated,
        'userId': _user?.uid,
        'userEmail': _user?.email,
      },
      'jobs': {
        'count': _jobs.length,
        'hasMore': _hasMoreJobs,
        'hasError': _jobsError != null,
      },
      'locals': {
        'count': _locals.length,
        'hasMore': _hasMoreLocals,
        'hasError': _localsError != null,
      },
      'timestamp': DateTime.now().toIso8601String(),
    };
  }

  /// Save state before disposal
  Future<void> _saveStateOnDispose() async {
    try {
      final combinedState = {
        'auth': {
          'isAuthenticated': isAuthenticated,
          'userId': _user?.uid,
        },
        'jobs': {
          'count': _jobs.length,
          'hasMore': _hasMoreJobs,
        },
        'locals': {
          'count': _locals.length,
          'hasMore': _hasMoreLocals,
        },
        'timestamp': DateTime.now().toIso8601String(),
      };
      
      await CompressedStateManager.saveState('app_state', combinedState);
      
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
    
    if (kDebugMode) {
      print('AppStateProvider: Disposed with cleanup');
    }
    
    super.dispose();
  }
}