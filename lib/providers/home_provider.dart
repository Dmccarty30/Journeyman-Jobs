import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/resilient_firestore_service.dart';
import '../backend/schema/jobs_record.dart';

/// Consolidated state management for the home screen
/// 
/// This provider manages authentication state, user data, and job listings
/// efficiently using a single state management pattern to avoid the 
/// triple-nested StreamBuilder anti-pattern.
class HomeProvider extends ChangeNotifier {
  final ResilientFirestoreService _firestoreService = ResilientFirestoreService();
  
  // State variables
  User? _user;
  Map<String, dynamic>? _userData;
  List<JobsRecord> _jobs = [];
  bool _isLoading = true;
  String? _error;
  
  // Subscription management
  StreamSubscription<User?>? _authSubscription;
  StreamSubscription<DocumentSnapshot>? _userSubscription;
  StreamSubscription<QuerySnapshot>? _jobsSubscription;
  
  // Getters
  User? get user => _user;
  Map<String, dynamic>? get userData => _userData;
  List<JobsRecord> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isAuthenticated => _user != null;
  
  HomeProvider() {
    _initializeProviders();
  }
  
  /// Initialize all stream subscriptions
  void _initializeProviders() {
    _authSubscription = FirebaseAuth.instance.authStateChanges().listen(
      _handleAuthStateChange,
      onError: _handleError,
    );
  }
  
  /// Handle authentication state changes
  void _handleAuthStateChange(User? user) {
    _user = user;
    
    if (user != null) {
      _loadUserData();
      _loadJobs();
    } else {
      _clearUserData();
    }
    
    notifyListeners();
  }
  
  /// Load user profile data
  void _loadUserData() {
    if (_user == null) return;
    
    _userSubscription?.cancel();
    _userSubscription = _firestoreService.getUserStream(_user!.uid).listen(
      _handleUserDataUpdate,
      onError: _handleError,
    );
  }
  
  /// Handle user data updates
  void _handleUserDataUpdate(DocumentSnapshot snapshot) {
    if (snapshot.exists) {
      _userData = snapshot.data() as Map<String, dynamic>?;
    } else {
      _userData = null;
    }
    
    notifyListeners();
  }
  
  /// Load job listings with pagination
  void _loadJobs() {
    _jobsSubscription?.cancel();
    _jobsSubscription = _firestoreService.getJobs(limit: 10).listen(
      _handleJobsUpdate,
      onError: _handleError,
    );
  }
  
  /// Handle job listings updates
  void _handleJobsUpdate(QuerySnapshot snapshot) {
    _jobs = snapshot.docs.map((doc) => JobsRecord.fromSnapshot(doc)).toList();
    _isLoading = false;
    _error = null;
    
    // Sort jobs based on user preferences if user data is available
    if (_userData != null) {
      _sortJobsByUserPreferences();
    }
    
    notifyListeners();
  }
  
  /// Sort jobs based on user preferences
  void _sortJobsByUserPreferences() {
    if (_userData == null) return;
    
    final userClassification = _userData!['classification'] as String?;
    final preferredConstructionTypes = List<String>.from(_userData!['preferredConstructionTypes'] ?? []);
    final preferredHours = _parseHours(_userData!['preferredHours']);
    final perDiemRequired = _parseBool(_userData!['perDiemRequired']);
    
    // Create scored jobs list
    List<MapEntry<JobsRecord, int>> scoredJobs = _jobs.map((job) {
      int score = 0;
      
      // Priority 1: Classification match (highest weight)
      if (job.classification == userClassification) {
        score += 1000;
      }
      
      // Priority 2: Construction type match
      if (job.typeOfWork.isNotEmpty && preferredConstructionTypes.contains(job.typeOfWork)) {
        score += 100;
      }
      
      // Priority 3: Hours match
      final jobHours = job.hours;
      final hoursDifference = (jobHours - preferredHours).abs();
      score += (50 - hoursDifference).clamp(0, 50);
      
      // Priority 4: Per diem match
      final jobHasPerDiem = _parseBool(job.perDiem);
      if (perDiemRequired && jobHasPerDiem) {
        score += 25;
      } else if (!perDiemRequired && !jobHasPerDiem) {
        score += 10;
      }
      
      return MapEntry(job, score);
    }).toList();
    
    // Sort by score (descending)
    scoredJobs.sort((a, b) => b.value.compareTo(a.value));
    
    _jobs = scoredJobs.map((e) => e.key).toList();
  }
  
  /// Handle errors
  void _handleError(dynamic error) {
    _error = error.toString();
    _isLoading = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('HomeProvider Error: $error');
    }
  }
  
  /// Clear user data on logout
  void _clearUserData() {
    _userData = null;
    _jobs = [];
    _isLoading = false;
    _error = null;
    
    _userSubscription?.cancel();
    _jobsSubscription?.cancel();
  }
  
  /// Refresh job listings
  Future<void> refreshJobs() async {
    _isLoading = true;
    notifyListeners();
    
    _loadJobs();
  }
  
  /// Get user display name
  String getUserDisplayName() {
    if (_userData != null) {
      final firstName = _userData!['firstName'] ?? _userData!['first_name'] ?? '';
      final lastName = _userData!['lastName'] ?? _userData!['last_name'] ?? '';
      return '$firstName $lastName'.trim();
    }
    return _user?.displayName ?? 'User';
  }
  
  /// Get user avatar initial
  String getUserInitial() {
    final displayName = getUserDisplayName();
    return displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
  }
  
  /// Get user photo URL
  String? getUserPhotoUrl() {
    return _userData?['photoUrl'] ?? _userData?['photo_url'] ?? _user?.photoURL;
  }
  
  /// Parse hours from dynamic data
  int _parseHours(dynamic hoursData) {
    if (hoursData is int) {
      return hoursData;
    } else if (hoursData is String) {
      return int.tryParse(hoursData) ?? 40;
    }
    return 40; // Default to 40 hours
  }
  
  /// Parse boolean from dynamic data
  bool _parseBool(dynamic boolData) {
    if (boolData is bool) {
      return boolData;
    } else if (boolData is String) {
      return boolData.toLowerCase() == 'true' || boolData == '1';
    } else if (boolData is int) {
      return boolData == 1;
    }
    return false; // Default to false
  }
  
  @override
  void dispose() {
    _authSubscription?.cancel();
    _userSubscription?.cancel();
    _jobsSubscription?.cancel();
    super.dispose();
  }
}