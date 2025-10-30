import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../models/user_model.dart';
import '../../models/hierarchical/hierarchical_types.dart';
import '../auth_service.dart';

/// Service for loading and processing data with real Firebase operations
///
/// This service handles the actual data loading, processing, and caching
/// operations needed by the hierarchical initialization system.
class DataLoadingService {
  static final Map<String, dynamic> _cache = {};
  static final Map<String, DateTime> _cacheTimestamps = {};
  static const Duration _cacheExpiry = Duration(minutes: 5);

  /// Loads user profile with caching and error handling
  static Future<UserModel?> loadUserProfile(String userId, {bool forceRefresh = false}) async {
    final cacheKey = 'user_profile_$userId';

    // Check cache first
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('[DataLoadingService] Loading user profile from cache');
      return _cache[cacheKey] as UserModel?;
    }

    try {
      debugPrint('[DataLoadingService] Loading user profile from Firestore');

      final userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(userId)
          .get(const GetOptions(source: Source.server));

      if (!userDoc.exists) {
        debugPrint('[DataLoadingService] User profile not found, creating default');

        // Create default user profile
        final defaultProfile = UserModel(
          uid: userId,
          username: userId,
          classification: 'Journeyman',
          homeLocal: 0,
          role: 'member',
          email: '',
          lastActive: DateTime.now(),
          firstName: 'User',
          lastName: 'Name',
          createdTime: DateTime.now(),
          networkWithOthers: false,
          careerAdvancements: false,
          betterBenefits: false,
          higherPayRate: false,
          learnNewSkill: false,
          travelToNewLocation: false,
          findLongTermWork: false,
        );
        await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .set(defaultProfile.toFirestore());

        _cache[cacheKey] = defaultProfile;
        _cacheTimestamps[cacheKey] = DateTime.now();

        return defaultProfile;
      }

      final userModel = UserModel.fromFirestore(userDoc);

      // Cache the result
      _cache[cacheKey] = userModel;
      _cacheTimestamps[cacheKey] = DateTime.now();

      debugPrint('[DataLoadingService] User profile loaded: ${userModel.email}');
      return userModel;
    } catch (e) {
      debugPrint('[DataLoadingService] Error loading user profile: $e');

      // Try to return cached version if available
      if (_cache.containsKey(cacheKey)) {
        debugPrint('[DataLoadingService] Returning cached user profile as fallback');
        return _cache[cacheKey] as UserModel?;
      }

      rethrow;
    }
  }

  /// Loads IBEW locals directory with caching
  static Future<Map<int, LocalsRecord>> loadLocalsDirectory({bool forceRefresh = false}) async {
    const cacheKey = 'locals_directory';

    // Check cache first
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('[DataLoadingService] Loading locals from cache');
      return _cache[cacheKey] as Map<int, LocalsRecord>;
    }

    try {
      debugPrint('[DataLoadingService] Loading locals from Firestore');

      final snapshot = await FirebaseFirestore.instance
          .collection('locals')
          .orderBy('localNumber')
          .limit(1000) // Limit to prevent excessive memory usage
          .get(const GetOptions(source: Source.server));

      final locals = <int, LocalsRecord>{};

      for (final doc in snapshot.docs) {
        try {
          final local = LocalsRecord.fromFirestore(doc);
          final localNumberInt = int.tryParse(local.localNumber) ?? 0;
          locals[localNumberInt] = local;
        } catch (e) {
          debugPrint('[DataLoadingService] Error parsing local ${doc.id}: $e');
          // Continue with other locals
        }
      }

      debugPrint('[DataLoadingService] Loaded ${locals.length} IBEW locals');

      // Cache the result
      _cache[cacheKey] = locals;
      _cacheTimestamps[cacheKey] = DateTime.now();

      // Ensure we have some locals loaded
      if (locals.isEmpty) {
        throw StateError('No IBEW locals could be loaded from database');
      }

      return locals;
    } catch (e) {
      debugPrint('[DataLoadingService] Error loading locals: $e');

      // Try to return cached version if available
      if (_cache.containsKey(cacheKey)) {
        debugPrint('[DataLoadingService] Returning cached locals as fallback');
        return _cache[cacheKey] as Map<int, LocalsRecord>;
      }

      rethrow;
    }
  }

  /// Loads jobs data with filtering based on user preferences
  static Future<Map<String, Job>> loadJobsData({
    int? homeLocal,
    List<String>? preferredLocals,
    int limit = 50,
    bool forceRefresh = false,
  }) async {
    // Create cache key based on preferences
    final cacheKey = 'jobs_data_${homeLocal ?? 'all'}_${preferredLocals?.join(',') ?? 'none'}_$limit';

    // Check cache first
    if (!forceRefresh && _isCacheValid(cacheKey)) {
      debugPrint('[DataLoadingService] Loading jobs from cache');
      return _cache[cacheKey] as Map<String, Job>;
    }

    try {
      debugPrint('[DataLoadingService] Loading jobs from Firestore');

      Query jobsQuery = FirebaseFirestore.instance
          .collection('jobs')
          .where('isActive', isEqualTo: true)
          .orderBy('postedDate', descending: true);

      // Apply user preferences filtering
      if (homeLocal != null) {
        jobsQuery = jobsQuery.where('localUnion', isEqualTo: homeLocal);
      } else if (preferredLocals != null && preferredLocals.isNotEmpty) {
        // Convert string local numbers to integers
        final preferredIntLocals = preferredLocals
            .where((local) => local.trim().isNotEmpty)
            .map((local) => int.tryParse(local.trim()))
            .where((local) => local != null)
            .cast<int>()
            .toList();

        if (preferredIntLocals.isNotEmpty) {
          jobsQuery = jobsQuery.where('localUnion', whereIn: preferredIntLocals);
        }
      }

      final snapshot = await jobsQuery.limit(limit).get(const GetOptions(source: Source.server));

      final jobs = <String, Job>{};

      for (final doc in snapshot.docs) {
        try {
          final job = Job.fromFirestore(doc as DocumentSnapshot<Map<String, dynamic>>);
          jobs[doc.id] = job;
        } catch (e) {
          debugPrint('[DataLoadingService] Error parsing job ${doc.id}: $e');
          // Continue with other jobs
        }
      }

      debugPrint('[DataLoadingService] Loaded ${jobs.length} active jobs');

      // Cache the result
      _cache[cacheKey] = jobs;
      _cacheTimestamps[cacheKey] = DateTime.now();

      return jobs;
    } catch (e) {
      debugPrint('[DataLoadingService] Error loading jobs: $e');

      // Try to return cached version if available
      if (_cache.containsKey(cacheKey)) {
        debugPrint('[DataLoadingService] Returning cached jobs as fallback');
        return _cache[cacheKey] as Map<String, Job>;
      }

      rethrow;
    }
  }

  /// Loads crew data for the current user
  static Future<Map<String, dynamic>> loadCrewData({String? userId}) async {
    final currentUser = userId ?? FirebaseAuth.instance.currentUser?.uid;

    if (currentUser == null) {
      debugPrint('[DataLoadingService] No user for crew data loading');
      return {};
    }

    final cacheKey = 'crew_data_$currentUser';

    // Check cache first (crew data changes frequently, so shorter cache time)
    if (_isCacheValid(cacheKey, Duration(minutes: 1))) {
      debugPrint('[DataLoadingService] Loading crew data from cache');
      return _cache[cacheKey] as Map<String, dynamic>;
    }

    try {
      debugPrint('[DataLoadingService] Loading crew data');

      // Load user's crews
      final crewsSnapshot = await FirebaseFirestore.instance
          .collection('crew_members')
          .where('userId', isEqualTo: currentUser)
          .get(const GetOptions(source: Source.server));

      final crewIds = crewsSnapshot.docs.map((doc) => doc['crewId'] as String).toList();

      // Load crew details
      final crewsData = <String, dynamic>{};
      if (crewIds.isNotEmpty) {
        final crewsDetailsSnapshot = await FirebaseFirestore.instance
            .collection('crews')
            .where(FieldPath.documentId, whereIn: crewIds.take(10)) // Limit to 10 crews
            .get(const GetOptions(source: Source.server));

        for (final doc in crewsDetailsSnapshot.docs) {
          crewsData[doc.id] = doc.data();
        }
      }

      final result = {
        'crewIds': crewIds,
        'crews': crewsData,
        'memberCount': crewsSnapshot.docs.length,
      };

      // Cache the result
      _cache[cacheKey] = result;
      _cacheTimestamps[cacheKey] = DateTime.now();

      debugPrint('[DataLoadingService] Loaded crew data for ${crewIds.length} crews');
      return result;
    } catch (e) {
      debugPrint('[DataLoadingService] Error loading crew data: $e');
      return {};
    }
  }

  /// Validates that Firebase services are accessible
  static Future<bool> validateFirebaseServices() async {
    try {
      // Test Firebase app
      final app = Firebase.app();
      debugPrint('[DataLoadingService] Firebase app validated: ${app.name}');

      // Test Firestore connectivity
      final testDoc = await FirebaseFirestore.instance
          .collection('system_health')
          .add({
            'timestamp': FieldValue.serverTimestamp(),
            'test': 'firebase_connectivity',
          });

      // Clean up test document
      await testDoc.delete();

      debugPrint('[DataLoadingService] Firestore connectivity validated');
      return true;
    } catch (e) {
      debugPrint('[DataLoadingService] Firebase validation failed: $e');
      return false;
    }
  }

  /// Validates user authentication state
  static Future<bool> validateAuthentication() async {
    try {
      final currentUser = FirebaseAuth.instance.currentUser;

      if (currentUser == null) {
        debugPrint('[DataLoadingService] No authenticated user');
        return false;
      }

      // Validate token is still valid
      final idToken = await currentUser.getIdToken();
      debugPrint('[DataLoadingService] Authentication validated for user: ${currentUser.uid}');
      return true;
    } catch (e) {
      debugPrint('[DataLoadingService] Authentication validation failed: $e');
      return false;
    }
  }

  /// Checks if cache entry is still valid
  static bool _isCacheValid(String key, [Duration? customExpiry]) {
    if (!_cache.containsKey(key) || !_cacheTimestamps.containsKey(key)) {
      return false;
    }

    final expiry = customExpiry ?? _cacheExpiry;
    final age = DateTime.now().difference(_cacheTimestamps[key]!);
    return age < expiry;
  }

  /// Clears all cached data
  static void clearCache() {
    _cache.clear();
    _cacheTimestamps.clear();
    debugPrint('[DataLoadingService] Cache cleared');
  }

  /// Clears specific cache entry
  static void clearCacheEntry(String key) {
    _cache.remove(key);
    _cacheTimestamps.remove(key);
    debugPrint('[DataLoadingService] Cache entry cleared: $key');
  }

  /// Gets cache statistics
  static Map<String, dynamic> getCacheStats() {
    return {
      'cacheSize': _cache.length,
      'validEntries': _cache.keys.where((key) => _isCacheValid(key)).length,
      'expiredEntries': _cache.keys.where((key) => !_isCacheValid(key)).length,
      'entries': _cache.keys.toList(),
    };
  }

  /// Performs health check on all data services
  static Future<Map<String, bool>> performHealthCheck() async {
    final results = <String, bool>{};

    try {
      results['firebase'] = await validateFirebaseServices();
      results['authentication'] = await validateAuthentication();

      // Test locals loading
      try {
        await loadLocalsDirectory(forceRefresh: false);
        results['locals'] = true;
      } catch (e) {
        debugPrint('[DataLoadingService] Locals health check failed: $e');
        results['locals'] = false;
      }

      // Test jobs loading
      try {
        await loadJobsData(limit: 1, forceRefresh: false);
        results['jobs'] = true;
      } catch (e) {
        debugPrint('[DataLoadingService] Jobs health check failed: $e');
        results['jobs'] = false;
      }

    } catch (e) {
      debugPrint('[DataLoadingService] Health check failed: $e');
    }

    return results;
  }
}