import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/hierarchical/union_model.dart';
import '../../models/hierarchical/hierarchical_data_model.dart';
import '../../models/locals_record.dart';
import '../../models/job_model.dart';
import '../firestore_service.dart';

/// Service for managing hierarchical IBEW data loading and initialization
///
/// This service handles the complete hierarchy:
/// Union → Local → Members → Jobs
///
/// Features:
/// - Efficient batch loading of hierarchical data
/// - Real-time updates through Firestore listeners
/// - Caching and offline support
/// - Error handling and retry logic
/// - Performance monitoring
class HierarchicalService {
  final FirestoreService _firestoreService;
  final FirebaseFirestore _firestore;
  final FirebaseAuth _auth;

  // Cache for hierarchical data
  HierarchicalData _cachedData = HierarchicalData.empty();

  // Stream controllers for real-time updates
  final StreamController<HierarchicalData> _dataController =
      StreamController<HierarchicalData>.broadcast();

  // Stream subscriptions
  StreamSubscription<DocumentSnapshot>? _unionSubscription;
  StreamSubscription<QuerySnapshot>? _localsSubscription;
  StreamSubscription<QuerySnapshot>? _membersSubscription;
  StreamSubscription<QuerySnapshot>? _jobsSubscription;

  // Configuration
  final Duration _cacheTimeout = const Duration(minutes: 5);
  final int _maxRetries = 3;
  final Duration _retryDelay = const Duration(seconds: 2);

  HierarchicalService({
    FirestoreService? firestoreService,
    FirebaseFirestore? firestore,
    FirebaseAuth? auth,
  }) : _firestoreService = firestoreService ?? FirestoreService(),
       _firestore = firestore ?? FirebaseFirestore.instance,
       _auth = auth ?? FirebaseAuth.instance;

  /// Stream of hierarchical data updates
  Stream<HierarchicalData> get hierarchicalDataStream => _dataController.stream;

  /// Gets cached hierarchical data
  HierarchicalData get cachedData => _cachedData;

  /// Checks if cached data is fresh
  bool get isCacheFresh {
    return DateTime.now().difference(_cachedData.lastUpdated) < _cacheTimeout;
  }

  /// Initializes the complete hierarchical data structure
  ///
  /// This method loads data in the optimal order:
  /// 1. Union information
  /// 2. Local unions for the user's area/union
  /// 3. Members for those locals
  /// 4. Jobs for those locals
  Future<HierarchicalData> initializeHierarchicalData({
    String? unionId,
    List<int>? preferredLocals,
    bool forceRefresh = false,
  }) async {
    debugPrint('[HierarchicalService] Initializing hierarchical data...');

    // Return cached data if fresh and not forcing refresh
    if (!forceRefresh && isCacheFresh && _cachedData.loadingStatus == HierarchicalLoadingStatus.loaded) {
      debugPrint('[HierarchicalService] Returning fresh cached data');
      return _cachedData;
    }

    try {
      // Start with loading status
      _updateData(_cachedData.withLoadingStatus(HierarchicalLoadingStatus.loadingUnion));

      // Step 1: Load Union data
      final union = await _loadUnionData(unionId: unionId);
      _updateData(_cachedData.withUnion(union).withLoadingStatus(HierarchicalLoadingStatus.loadingLocals));

      // Step 2: Load Local unions
      final locals = await _loadLocalsData(unionId: unionId, preferredLocals: preferredLocals);
      _updateData(_cachedData.withLoadingStatus(HierarchicalLoadingStatus.loadingMembers));

      // Step 3: Load Members
      final members = await _loadMembersData(locals.keys.toList());
      _updateData(_cachedData.withLoadingStatus(HierarchicalLoadingStatus.loadingJobs));

      // Step 4: Load Jobs
      final jobs = await _loadJobsData(locals.keys.toList());

      // Build complete hierarchical data
      final hierarchicalData = HierarchicalData(
        union: union,
        locals: locals,
        members: members,
        jobs: jobs,
        loadingStatus: HierarchicalLoadingStatus.loaded,
        lastUpdated: DateTime.now(),
      );

      // Update cache and notify listeners
      _updateData(hierarchicalData);

      debugPrint('[HierarchicalService] Hierarchical data initialized successfully');
      debugPrint('[HierarchicalService] Stats: ${hierarchicalData.stats}');

      return hierarchicalData;
    } catch (e, stackTrace) {
      debugPrint('[HierarchicalService] Error initializing hierarchical data: $e');
      debugPrint('[HierarchicalService] Stack trace: $stackTrace');

      final errorData = _cachedData.withError(
        'Failed to initialize hierarchical data: $e',
        status: HierarchicalLoadingStatus.error,
      );
      _updateData(errorData);

      rethrow;
    }
  }

  /// Loads union data from Firestore
  Future<Union?> _loadUnionData({String? unionId}) async {
    debugPrint('[HierarchicalService] Loading union data...');

    try {
      DocumentSnapshot unionDoc;

      if (unionId != null) {
        // Load specific union
        unionDoc = await _firestore.collection('unions').doc(unionId).get();
      } else {
        // Load primary IBEW union (assume there's one main union)
        final query = await _firestore
            .collection('unions')
            .where('type', isEqualTo: 'International')
            .where('isActive', isEqualTo: true)
            .limit(1)
            .get();

        if (query.docs.isEmpty) {
          debugPrint('[HierarchicalService] No union found, creating default IBEW union');
          return _createDefaultUnion();
        }

        unionDoc = query.docs.first;
      }

      if (!unionDoc.exists) {
        debugPrint('[HierarchicalService] Union document not found, creating default');
        return _createDefaultUnion();
      }

      final union = Union.fromFirestore(unionDoc);
      debugPrint('[HierarchicalService] Loaded union: ${union.name}');
      return union;

    } catch (e) {
      debugPrint('[HierarchicalService] Error loading union data: $e');
      // Return default union on error
      return _createDefaultUnion();
    }
  }

  /// Loads local unions data from Firestore
  Future<Map<int, LocalsRecord>> _loadLocalsData({
    String? unionId,
    List<int>? preferredLocals,
  }) async {
    debugPrint('[HierarchicalService] Loading locals data...');

    try {
      QuerySnapshot localsQuery;

      if (preferredLocals != null && preferredLocals.isNotEmpty) {
        // Load specific preferred locals
        localsQuery = await _firestore
            .collection('locals')
            .where('local_union', whereIn: preferredLocals.map((l) => l.toString()).toList())
            .where('isActive', isEqualTo: true)
            .get();
      } else {
        // Load all active locals with reasonable limit
        localsQuery = await _firestore
            .collection('locals')
            .where('isActive', isEqualTo: true)
            .orderBy('local_union')
            .limit(100) // Limit for performance
            .get();
      }

      final Map<int, LocalsRecord> locals = {};

      for (final doc in localsQuery.docs) {
        try {
          final local = LocalsRecord.fromFirestore(doc);
          final localNumber = int.tryParse(local.localNumber);
          if (localNumber != null) {
            locals[localNumber] = local;
          }
        } catch (e) {
          debugPrint('[HierarchicalService] Error parsing local document ${doc.id}: $e');
          // Continue with other locals
        }
      }

      debugPrint('[HierarchicalService] Loaded ${locals.length} locals');
      return locals;

    } catch (e) {
      debugPrint('[HierarchicalService] Error loading locals data: $e');
      rethrow;
    }
  }

  /// Loads members data for specified locals
  Future<Map<String, UnionMember>> _loadMembersData(List<int> localNumbers) async {
    debugPrint('[HierarchicalService] Loading members data for ${localNumbers.length} locals...');

    if (localNumbers.isEmpty) {
      return {};
    }

    try {
      final Map<String, UnionMember> members = {};

      // Load members in batches to avoid Firestore limits
      const batchSize = 10;
      for (int i = 0; i < localNumbers.length; i += batchSize) {
        final batch = localNumbers.skip(i).take(batchSize).toList();

        final query = await _firestore
            .collection('users')
            .where('homeLocal', whereIn: batch)
            .where('isActive', isEqualTo: true)
            .get();

        for (final doc in query.docs) {
          try {
            // Create UnionMember from UserModel data
            final userData = doc.data() as Map<String, dynamic>;
            userData['id'] = doc.id; // Ensure document ID is included

            // This would need to be adapted based on actual user model structure
            // For now, we'll create a basic UnionMember
            final member = UnionMember(
              userId: doc.id,
              localNumber: userData['homeLocal'] ?? 0,
              fullName: '${userData['firstName'] ?? ''} ${userData['lastName'] ?? ''}'.trim(),
              classification: userData['classification'] ?? '',
              ticketNumber: userData['ticketNumber'] ?? '',
              joinDate: (userData['createdTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
              isWorking: userData['isWorking'] ?? false,
              email: userData['email'] ?? '',
              phoneNumber: userData['phoneNumber'] ?? '',
              location: '${userData['city'] ?? ''}, ${userData['state'] ?? ''}',
              skills: List<String>.from(userData['constructionTypes'] ?? []),
              certifications: List<String>.from(userData['certifications'] ?? []),
              yearsExperience: userData['yearsExperience'] ?? 0,
              isAvailable: !(userData['isWorking'] ?? false),
              createdAt: (userData['createdTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
              updatedAt: DateTime.now(),
              reference: doc.reference,
              rawData: userData,
            );

            members[member.userId] = member;
          } catch (e) {
            debugPrint('[HierarchicalService] Error parsing member document ${doc.id}: $e');
            // Continue with other members
          }
        }
      }

      debugPrint('[HierarchicalService] Loaded ${members.length} members');
      return members;

    } catch (e) {
      debugPrint('[HierarchicalService] Error loading members data: $e');
      rethrow;
    }
  }

  /// Loads jobs data for specified locals
  Future<Map<String, Job>> _loadJobsData(List<int> localNumbers) async {
    debugPrint('[HierarchicalService] Loading jobs data for ${localNumbers.length} locals...');

    if (localNumbers.isEmpty) {
      return {};
    }

    try {
      final Map<String, Job> jobs = {};

      // Load recent jobs for the specified locals
      final query = await _firestore
          .collection('jobs')
          .where('local', whereIn: localNumbers)
          .where('deleted', isEqualTo: false)
          .orderBy('timestamp', descending: true)
          .limit(200) // Limit for performance
          .get();

      for (final doc in query.docs) {
        try {
          final job = Job.fromFirestore(doc);
          jobs[job.id] = job;
        } catch (e) {
          debugPrint('[HierarchicalService] Error parsing job document ${doc.id}: $e');
          // Continue with other jobs
        }
      }

      debugPrint('[HierarchicalService] Loaded ${jobs.length} jobs');
      return jobs;

    } catch (e) {
      debugPrint('[HierarchicalService] Error loading jobs data: $e');
      rethrow;
    }
  }

  /// Creates a default IBEW union when no union data is found
  Union _createDefaultUnion() {
    debugPrint('[HierarchicalService] Creating default IBEW union');

    final now = DateTime.now();
    return Union(
      id: 'ibew-international',
      name: 'International Brotherhood of Electrical Workers',
      abbreviation: 'IBEW',
      type: 'International',
      jurisdiction: 'North America',
      localCount: 0, // Will be updated when locals are loaded
      totalMembership: 0, // Will be updated when members are loaded
      headquartersLocation: 'Washington, DC',
      contactEmail: 'info@ibew.org',
      contactPhone: '(202) 728-6000',
      website: 'https://www.ibew.org',
      foundedDate: DateTime(1891),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    );
  }

  /// Sets up real-time listeners for hierarchical data updates
  void setupRealtimeListeners({
    String? unionId,
    List<int>? preferredLocals,
  }) {
    debugPrint('[HierarchicalService] Setting up real-time listeners...');

    // Cancel existing subscriptions
    cancelRealtimeListeners();

    try {
      // Listen for union updates
      if (unionId != null) {
        _unionSubscription = _firestore
            .collection('unions')
            .doc(unionId)
            .snapshots()
            .listen((snapshot) {
              if (snapshot.exists) {
                final union = Union.fromFirestore(snapshot);
                _updateData(_cachedData.withUnion(union));
              }
            }, onError: (error) {
              debugPrint('[HierarchicalService] Union listener error: $error');
            });
      }

      // Listen for locals updates
      Query localsQuery = _firestore.collection('locals').where('isActive', isEqualTo: true);
      if (preferredLocals != null && preferredLocals.isNotEmpty) {
        localsQuery = localsQuery.where('local_union', whereIn: preferredLocals.map((l) => l.toString()).toList());
      }

      _localsSubscription = localsQuery.snapshots().listen((snapshot) {
        final Map<int, LocalsRecord> locals = {};
        for (final doc in snapshot.docs) {
          try {
            final local = LocalsRecord.fromFirestore(doc);
            final localNumber = int.tryParse(local.localNumber);
            if (localNumber != null) {
              locals[localNumber] = local;
            }
          } catch (e) {
            debugPrint('[HierarchicalService] Error parsing local update ${doc.id}: $e');
          }
        }
        _updateData(_cachedData.copyWith(locals: locals));
      }, onError: (error) {
        debugPrint('[HierarchicalService] Locals listener error: $error');
      });

      debugPrint('[HierarchicalService] Real-time listeners set up successfully');

    } catch (e) {
      debugPrint('[HierarchicalService] Error setting up real-time listeners: $e');
    }
  }

  /// Cancels all real-time listeners
  void cancelRealtimeListeners() {
    debugPrint('[HierarchicalService] Canceling real-time listeners...');

    _unionSubscription?.cancel();
    _localsSubscription?.cancel();
    _membersSubscription?.cancel();
    _jobsSubscription?.cancel();

    _unionSubscription = null;
    _localsSubscription = null;
    _membersSubscription = null;
    _jobsSubscription = null;
  }

  /// Refreshes hierarchical data with retry logic
  Future<HierarchicalData> refreshHierarchicalData({
    String? unionId,
    List<int>? preferredLocals,
  }) async {
    debugPrint('[HierarchicalService] Refreshing hierarchical data...');

    for (int attempt = 1; attempt <= _maxRetries; attempt++) {
      try {
        return await initializeHierarchicalData(
          unionId: unionId,
          preferredLocals: preferredLocals,
          forceRefresh: true,
        );
      } catch (e) {
        debugPrint('[HierarchicalService] Refresh attempt $attempt failed: $e');

        if (attempt == _maxRetries) {
          rethrow;
        }

        // Wait before retrying with exponential backoff
        await Future.delayed(_retryDelay * attempt);
      }
    }

    throw Exception('Failed to refresh hierarchical data after $_maxRetries attempts');
  }

  /// Updates cached data and notifies listeners
  void _updateData(HierarchicalData newData) {
    _cachedData = newData;
    _dataController.add(newData);
  }

  /// Searches hierarchical data for matching items
  HierarchicalSearchResult search(String query) {
    if (query.trim().isEmpty) {
      return HierarchicalSearchResult(
        locals: _cachedData.locals.values.toList(),
        members: _cachedData.members.values.toList(),
        jobs: _cachedData.jobs.values.toList(),
      );
    }

    final lowerQuery = query.toLowerCase();

    final matchingLocals = _cachedData.locals.values
        .where((local) =>
            local.localName.toLowerCase().contains(lowerQuery) ||
            local.location.toLowerCase().contains(lowerQuery) ||
            local.localNumber.toLowerCase().contains(lowerQuery))
        .toList();

    final matchingMembers = _cachedData.members.values
        .where((member) =>
            member.fullName.toLowerCase().contains(lowerQuery) ||
            member.classification.toLowerCase().contains(lowerQuery) ||
            member.location.toLowerCase().contains(lowerQuery))
        .toList();

    final matchingJobs = _cachedData.jobs.values
        .where((job) =>
            job.company.toLowerCase().contains(lowerQuery) ||
            job.location.toLowerCase().contains(lowerQuery) ||
            job.jobTitle?.toLowerCase().contains(lowerQuery) == true ||
            job.classification?.toLowerCase().contains(lowerQuery) == true)
        .toList();

    return HierarchicalSearchResult(
      locals: matchingLocals,
      members: matchingMembers,
      jobs: matchingJobs,
    );
  }

  /// Clears all cached data
  void clearCache() {
    debugPrint('[HierarchicalService] Clearing cache...');
    _updateData(HierarchicalData.empty());
  }

  /// Disposes the service and cleans up resources
  void dispose() {
    debugPrint('[HierarchicalService] Disposing service...');

    cancelRealtimeListeners();
    _dataController.close();
  }
}

/// Result of a hierarchical search operation
@immutable
class HierarchicalSearchResult {
  final List<LocalsRecord> locals;
  final List<UnionMember> members;
  final List<Job> jobs;

  const HierarchicalSearchResult({
    required this.locals,
    required this.members,
    required this.jobs,
  });

  bool get hasResults => locals.isNotEmpty || members.isNotEmpty || jobs.isNotEmpty;

  int get totalResults => locals.length + members.length + jobs.length;

  @override
  String toString() {
    return 'HierarchicalSearchResult(locals: ${locals.length}, members: ${members.length}, jobs: ${jobs.length})';
  }
}