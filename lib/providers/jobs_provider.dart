import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../services/resilient_firestore_service.dart';
import '../backend/schema/jobs_record.dart';

/// Provider for managing jobs list and pagination
/// 
/// This provider handles job data fetching, filtering, and pagination
/// efficiently using Provider pattern to avoid StreamBuilder anti-patterns.
class JobsProvider extends ChangeNotifier {
  final ResilientFirestoreService _firestoreService = ResilientFirestoreService();
  
  // State variables
  List<JobsRecord> _jobs = [];
  bool _isLoading = true;
  String? _error;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  Map<String, dynamic>? _filters;
  
  // Subscription management
  StreamSubscription<QuerySnapshot>? _jobsSubscription;
  
  // Getters
  List<JobsRecord> get jobs => _jobs;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get hasMore => _hasMore;
  Map<String, dynamic>? get filters => _filters;
  
  JobsProvider() {
    _loadInitialJobs();
  }
  
  /// Load initial batch of jobs
  void _loadInitialJobs() {
    _isLoading = true;
    _error = null;
    notifyListeners();
    
    _jobsSubscription?.cancel();
    _jobsSubscription = _firestoreService.getJobs(
      limit: 20,
      filters: _filters,
    ).listen(
      _handleJobsUpdate,
      onError: _handleError,
    );
  }
  
  /// Handle job listings updates
  void _handleJobsUpdate(QuerySnapshot snapshot) {
    _jobs = snapshot.docs.map((doc) => JobsRecord.fromSnapshot(doc)).toList();
    _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
    _hasMore = snapshot.docs.length >= 20;
    _isLoading = false;
    _error = null;
    
    notifyListeners();
  }
  
  /// Handle errors
  void _handleError(dynamic error) {
    _error = error.toString();
    _isLoading = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('JobsProvider Error: $error');
    }
  }
  
  /// Load more jobs for pagination
  Future<void> loadMoreJobs() async {
    if (_isLoading || !_hasMore) return;
    
    _isLoading = true;
    notifyListeners();
    
    try {
      final snapshot = await _firestoreService.getJobs(
        limit: 20,
        startAfter: _lastDocument,
        filters: _filters,
      ).first;
      
      final newJobs = snapshot.docs.map((doc) => JobsRecord.fromSnapshot(doc)).toList();
      
      _jobs.addAll(newJobs);
      _lastDocument = snapshot.docs.isNotEmpty ? snapshot.docs.last : null;
      _hasMore = snapshot.docs.length >= 20;
      _isLoading = false;
      _error = null;
      
      notifyListeners();
    } catch (error) {
      _handleError(error);
    }
  }
  
  /// Refresh job listings
  Future<void> refreshJobs() async {
    _jobs.clear();
    _lastDocument = null;
    _hasMore = true;
    _loadInitialJobs();
  }
  
  /// Apply filters to job search
  void applyFilters(Map<String, dynamic>? filters) {
    _filters = filters;
    _jobs.clear();
    _lastDocument = null;
    _hasMore = true;
    _loadInitialJobs();
  }
  
  /// Clear all filters
  void clearFilters() {
    _filters = null;
    _jobs.clear();
    _lastDocument = null;
    _hasMore = true;
    _loadInitialJobs();
  }
  
  /// Search jobs by query
  void searchJobs(String query) {
    if (query.isEmpty) {
      clearFilters();
      return;
    }
    
    // Apply search filter
    final searchFilters = <String, dynamic>{
      'searchQuery': query,
    };
    
    applyFilters(searchFilters);
  }
  
  /// Filter jobs by classification
  void filterByClassification(String classification) {
    if (classification == 'All Jobs') {
      clearFilters();
      return;
    }
    
    final classificationFilters = <String, dynamic>{
      'classification': classification,
    };
    
    applyFilters(classificationFilters);
  }
  
  @override
  void dispose() {
    _jobsSubscription?.cancel();
    super.dispose();
  }
}