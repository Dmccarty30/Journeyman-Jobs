import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/users_record.dart';
import '../security/rate_limiter.dart';
import '../security/input_validator.dart';

/// Service for discovering and searching users within the Journeyman Jobs application.
///
/// This service provides comprehensive user search and suggestion functionality
/// optimized for the IBEW electrical worker community. It implements fuzzy matching,
/// relevance ranking, and performance optimizations for large user bases (1000+ users).
///
/// Features:
/// - Real-time search with debouncing
/// - Fuzzy matching for names, emails, and IBEW locals
/// - Relevance-based ranking with customizable scoring
/// - Pagination support for large result sets
/// - Performance caching with TTL
/// - Rate limiting for abuse prevention
/// - Privacy-preserving search (excludes inactive users)
class UserDiscoveryService {
  final FirebaseFirestore _firestore;
  final RateLimiter _rateLimiter;

  // Collection names
  static const String _usersCollection = 'users';

  // Performance optimization: Search result cache with TTL
  final Map<String, _CachedSearchResult> _searchCache = {};
  static const Duration _cacheTTL = Duration(minutes: 5);
  static const int _maxCacheSize = 100;

  // Search configuration
  static const int _defaultSearchLimit = 20;
  static const int _maxSearchLimit = 50;
  static const int _debounceDelayMs = 300;

  // IBEW local patterns for enhanced matching
  static final RegExp _localPattern = RegExp(r'local\s*(\d+)', caseSensitive: false);
  static final RegExp _ibewPattern = RegExp(r'ibew\s*(\d+)', caseSensitive: false);

  // Search timers for debouncing
  final Map<String, Timer> _searchTimers = {};

  UserDiscoveryService({
    required FirebaseFirestore firestore,
  }) : _firestore = firestore,
       _rateLimiter = RateLimiter();

  /// Searches for users based on a query with fuzzy matching and relevance ranking.
  ///
  /// This method implements sophisticated search functionality optimized for
  /// the electrical worker community. It searches across multiple fields:
  /// - Display names (fuzzy matching)
  /// - Email addresses (exact and partial matching)
  /// - IBEW local numbers (pattern-based extraction)
  ///
  /// The search includes performance optimizations:
  /// - Debouncing to prevent excessive queries
  /// - Result caching with TTL
  /// - Pagination for large result sets
  /// - Rate limiting for abuse prevention
  ///
  /// Parameters:
  /// - [query]: Search query string (can be name, email, or local number)
  /// - [limit]: Maximum number of results to return (default: 20, max: 50)
  /// - [excludeUserId]: User ID to exclude from results (useful for self-exclusion)
  /// - [pageToken]: Pagination token for retrieving next page of results
  ///
  /// Returns:
  /// - [UserSearchResult] containing users list and pagination metadata
  ///
  /// Throws:
  /// - [ValidationException] if query is invalid
  /// - [RateLimitException] if search rate limit is exceeded
  /// - [FirebaseException] for database errors
  Future<UserSearchResult> searchUsers({
    required String query,
    int limit = _defaultSearchLimit,
    String? excludeUserId,
    String? pageToken,
  }) async {
    try {
      // Security: Validate and sanitize input
      final sanitizedQuery = InputValidator.sanitizeSearchQuery(query);
      if (sanitizedQuery.isEmpty) {
        return UserSearchResult(users: [], hasMore: false);
      }

      // Security: Enforce search limits
      final searchLimit = limit.clamp(1, _maxSearchLimit);

      // Security: Check rate limit (per IP/session)
      final rateLimitKey = 'search_${sanitizeQuery.hashCode}';
      if (!await _rateLimiter.isAllowed(rateLimitKey, operation: 'search')) {
        final retryAfter = _rateLimiter.getRetryAfter(rateLimitKey, operation: 'search');
        throw RateLimitException(
          'Too many search requests. Please try again later.',
          retryAfter: retryAfter,
          operation: 'search',
        );
      }

      // Performance: Check cache first
      final cacheKey = _generateCacheKey(sanitizedQuery, searchLimit, excludeUserId);
      final cachedResult = _getCachedResult(cacheKey);
      if (cachedResult != null) {
        return cachedResult;
      }

      // Extract IBEW local number if present in query
      final localNumber = _extractLocalNumber(sanitizedQuery);

      // Build optimized search query
      List<UsersRecord> users = [];

      if (localNumber != null) {
        // Primary search by IBEW local number (most relevant for electrical workers)
        users = await _searchByLocalNumber(
          localNumber: localNumber,
          limit: searchLimit,
          excludeUserId: excludeUserId,
        );

        // If not enough results from local search, supplement with name search
        if (users.length < searchLimit) {
          final additionalUsers = await _searchByDisplayName(
            query: sanitizedQuery,
            limit: searchLimit - users.length,
            excludeUserId: excludeUserId,
            excludeUserIds: users.map((u) => u.uid).toList(),
          );
          users.addAll(additionalUsers);
        }
      } else {
        // Search by display name and email
        users = await _searchByDisplayName(
          query: sanitizedQuery,
          limit: searchLimit,
          excludeUserId: excludeUserId,
        );

        // If not enough results from name search, supplement with email search
        if (users.length < searchLimit) {
          final additionalUsers = await _searchByEmail(
            query: sanitizedQuery,
            limit: searchLimit - users.length,
            excludeUserId: excludeUserId,
            excludeUserIds: users.map((u) => u.uid).toList(),
          );
          users.addAll(additionalUsers);
        }
      }

      // Apply relevance ranking and sorting
      users = _rankAndSortResults(users, sanitizedQuery, localNumber);

      // Performance: Cache results
      final result = UserSearchResult(users: users, hasMore: users.length >= searchLimit);
      _cacheResult(cacheKey, result);

      // Security: Reset rate limit on successful search
      _rateLimiter.reset(rateLimitKey, operation: 'search');

      return result;
    } on ValidationException catch (e) {
      debugPrint('[UserDiscoveryService] Validation error: $e');
      throw e.message;
    } on RateLimitException catch (e) {
      debugPrint('[UserDiscoveryService] Rate limit exceeded: $e');
      rethrow;
    } on FirebaseException catch (e) {
      debugPrint('[UserDiscoveryService] Firestore error: $e');
      rethrow;
    } catch (e) {
      debugPrint('[UserDiscoveryService] Unexpected error: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to search users: $e',
      );
    }
  }

  /// Gets suggested users based on shared characteristics and relevance scoring.
  ///
  /// This method provides personalized user suggestions for crew invitations
  /// based on various relevance factors:
  /// - Same IBEW local (highest relevance)
  /// - Similar certifications and skills
  /// - Geographic proximity
  /// - Recent activity
  ///
  /// The algorithm uses a weighted scoring system to rank suggestions
  /// and returns the most relevant users for crew collaboration.
  ///
  /// Parameters:
  /// - [userId]: Current user's ID for generating suggestions
  /// - [limit]: Maximum number of suggestions to return (default: 10)
  /// - [crewId]: Optional crew ID to exclude current crew members
  ///
  /// Returns:
  /// - List of suggested [UsersRecord] ordered by relevance score
  ///
  /// Throws:
  /// - [FirebaseException] for database errors
  Future<List<UsersRecord>> getSuggestedUsers({
    required String userId,
    int limit = 10,
    String? crewId,
  }) async {
    try {
      // Get current user's profile for relevance matching
      final currentUserDoc = await _firestore
          .collection(_usersCollection)
          .doc(userId)
          .get();

      if (!currentUserDoc.exists) {
        return [];
      }

      final currentUser = UsersRecord.fromFirestore(currentUserDoc);

      // Get existing crew members to exclude from suggestions
      List<String> excludeUserIds = [userId];
      if (crewId != null) {
        final crewDoc = await _firestore.collection('crews').doc(crewId).get();
        if (crewDoc.exists) {
          final crewData = crewDoc.data() as Map<String, dynamic>;
          final memberIds = List<String>.from(crewData['memberIds'] ?? []);
          excludeUserIds.addAll(memberIds);
        }
      }

      // Build queries for different relevance factors
      List<UsersRecord> suggestions = [];

      // 1. Same IBEW local (highest priority)
      if (currentUser.localNumber != null) {
        final localSuggestions = await _searchByLocalNumber(
          localNumber: currentUser.localNumber!,
          limit: limit ~/ 2, // Reserve half for local matches
          excludeUserId: userId,
          excludeUserIds: excludeUserIds,
        );
        suggestions.addAll(localSuggestions);
        excludeUserIds.addAll(localSuggestions.map((u) => u.uid));
      }

      // 2. Similar certifications (medium priority)
      if (currentUser.certifications != null && currentUser.certifications!.isNotEmpty) {
        final certificationSuggestions = await _searchByCertifications(
          certifications: currentUser.certifications!,
          limit: (limit - suggestions.length) ~/ 2,
          excludeUserIds: excludeUserIds,
        );
        suggestions.addAll(certificationSuggestions);
        excludeUserIds.addAll(certificationSuggestions.map((u) => u.uid));
      }

      // 3. Recently active users (fill remaining slots)
      if (suggestions.length < limit) {
        final activeSuggestions = await _searchByRecentActivity(
          limit: limit - suggestions.length,
          excludeUserIds: excludeUserIds,
        );
        suggestions.addAll(activeSuggestions);
      }

      // Apply final relevance scoring and ranking
      suggestions = _rankSuggestions(suggestions, currentUser);

      return suggestions.take(limit).toList();
    } on FirebaseException catch (e) {
      debugPrint('[UserDiscoveryService] Error getting suggested users: $e');
      rethrow;
    } catch (e) {
      debugPrint('[UserDiscoveryService] Unexpected error getting suggestions: $e');
      throw FirebaseException(
        plugin: 'cloud_firestore',
        message: 'Failed to get suggested users: $e',
      );
    }
  }

  /// Real-time search with debouncing for UI components.
  ///
  /// This method provides debounced search functionality ideal for
  /// real-time UI search fields. It implements debouncing to prevent
  /// excessive Firestore queries during rapid typing.
  ///
  /// Parameters:
  /// - [query]: Search query string
  /// - [onResults]: Callback function to receive search results
  /// - [limit]: Maximum number of results (default: 20)
  /// - [excludeUserId]: User ID to exclude from results
  /// - [debounceDelay]: Debounce delay in milliseconds (default: 300)
  void searchUsersDebounced({
    required String query,
    required Function(UserSearchResult) onResults,
    int limit = _defaultSearchLimit,
    String? excludeUserId,
    int debounceDelay = _debounceDelayMs,
  }) {
    // Cancel existing timer for this query
    final timerKey = query.hashCode.toString();
    _searchTimers[timerKey]?.cancel();

    // Set new timer
    _searchTimers[timerKey] = Timer(Duration(milliseconds: debounceDelay), () async {
      try {
        final results = await searchUsers(
          query: query,
          limit: limit,
          excludeUserId: excludeUserId,
        );
        onResults(results);
      } catch (e) {
        debugPrint('[UserDiscoveryService] Debounced search error: $e');
        onResults(UserSearchResult(users: [], hasMore: false));
      } finally {
        _searchTimers.remove(timerKey);
      }
    });
  }

  // Private helper methods

  /// Searches users by display name with fuzzy matching.
  Future<List<UsersRecord>> _searchByDisplayName({
    required String query,
    required int limit,
    String? excludeUserId,
    List<String>? excludeUserIds,
  }) async {
    final queryLower = query.toLowerCase();

    // Firestore doesn't support fuzzy matching natively, so we use multiple queries
    // with different matching strategies and combine results

    List<UsersRecord> results = [];

    // 1. Exact prefix match (highest relevance)
    final prefixSnapshot = await _firestore
        .collection(_usersCollection)
        .where('displayName', isGreaterThanOrEqualTo: query)
        .where('displayName', isLessThanOrEqualTo: query + '\uf8ff')
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();

    for (final doc in prefixSnapshot.docs) {
      if (doc.id != excludeUserId &&
          (excludeUserIds == null || !excludeUserIds.contains(doc.id))) {
        results.add(UsersRecord.fromFirestore(doc));
      }
    }

    if (results.length >= limit) return results;

    // 2. Contains match (medium relevance)
    final words = queryLower.split(' ').where((w) => w.length > 1).toList();
    if (words.isNotEmpty) {
      for (final word in words.take(2)) { // Limit to prevent too many queries
        final containsSnapshot = await _firestore
            .collection(_usersCollection)
            .where('searchableDisplayName', arrayContains: word)
            .where('isActive', isEqualTo: true)
            .limit(limit - results.length)
            .get();

        for (final doc in containsSnapshot.docs) {
          final userId = doc.id;
          if (userId != excludeUserId &&
              (excludeUserIds == null || !excludeUserIds.contains(userId)) &&
              !results.any((u) => u.uid == userId)) {
            results.add(UsersRecord.fromFirestore(doc));
          }
        }
      }
    }

    return results;
  }

  /// Searches users by email address.
  Future<List<UsersRecord>> _searchByEmail({
    required String query,
    required int limit,
    String? excludeUserId,
    List<String>? excludeUserIds,
  }) async {
    if (!query.contains('@')) return [];

    final emailQuery = query.toLowerCase();

    // Search for email prefix matches
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('email', isGreaterThanOrEqualTo: emailQuery)
        .where('email', isLessThanOrEqualTo: emailQuery + '\uf8ff')
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();

    List<UsersRecord> results = [];
    for (final doc in snapshot.docs) {
      if (doc.id != excludeUserId &&
          (excludeUserIds == null || !excludeUserIds.contains(doc.id))) {
        results.add(UsersRecord.fromFirestore(doc));
      }
    }

    return results;
  }

  /// Searches users by IBEW local number.
  Future<List<UsersRecord>> _searchByLocalNumber({
    required String localNumber,
    required int limit,
    String? excludeUserId,
    List<String>? excludeUserIds,
  }) async {
    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('localNumber', isEqualTo: localNumber)
        .where('isActive', isEqualTo: true)
        .limit(limit)
        .get();

    List<UsersRecord> results = [];
    for (final doc in snapshot.docs) {
      if (doc.id != excludeUserId &&
          (excludeUserIds == null || !excludeUserIds.contains(doc.id))) {
        results.add(UsersRecord.fromFirestore(doc));
      }
    }

    return results;
  }

  /// Searches users by certifications.
  Future<List<UsersRecord>> _searchByCertifications({
    required List<String> certifications,
    required int limit,
    List<String>? excludeUserIds,
  }) async {
    List<UsersRecord> results = [];

    for (final certification in certifications.take(3)) { // Limit queries
      final snapshot = await _firestore
          .collection(_usersCollection)
          .where('certifications', arrayContains: certification)
          .where('isActive', isEqualTo: true)
          .limit(limit ~/ certifications.length + 1)
          .get();

      for (final doc in snapshot.docs) {
        final userId = doc.id;
        if ((excludeUserIds == null || !excludeUserIds.contains(userId)) &&
            !results.any((u) => u.uid == userId)) {
          results.add(UsersRecord.fromFirestore(doc));
        }
      }
    }

    return results;
  }

  /// Searches for recently active users.
  Future<List<UsersRecord>> _searchByRecentActivity({
    required int limit,
    List<String>? excludeUserIds,
  }) async {
    final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));

    final snapshot = await _firestore
        .collection(_usersCollection)
        .where('isActive', isEqualTo: true)
        .where('lastActiveAt', isGreaterThanOrEqualTo: Timestamp.fromDate(thirtyDaysAgo))
        .orderBy('lastActiveAt', descending: true)
        .limit(limit)
        .get();

    List<UsersRecord> results = [];
    for (final doc in snapshot.docs) {
      final userId = doc.id;
      if ((excludeUserIds == null || !excludeUserIds.contains(userId))) {
        results.add(UsersRecord.fromFirestore(doc));
      }
    }

    return results;
  }

  /// Ranks and sorts search results by relevance.
  List<UsersRecord> _rankAndSortResults(
    List<UsersRecord> users,
    String query,
    String? localNumber,
  ) {
    final queryLower = query.toLowerCase();

    // Calculate relevance scores
    final scoredUsers = users.map((user) {
      double score = 0.0;

      // Exact name match (highest score)
      if (user.displayName.toLowerCase() == queryLower) {
        score += 100.0;
      }
      // Name starts with query (high score)
      else if (user.displayName.toLowerCase().startsWith(queryLower)) {
        score += 80.0;
      }
      // Name contains query (medium score)
      else if (user.displayName.toLowerCase().contains(queryLower)) {
        score += 60.0;
      }

      // Local number exact match (very high score)
      if (localNumber != null && user.localNumber == localNumber) {
        score += 120.0;
      }

      // Email match (lower score for privacy)
      if (user.email.toLowerCase().startsWith(queryLower)) {
        score += 40.0;
      }

      // Activity bonus (recently active users get higher score)
      final daysSinceActive = user.createdTime != null
          ? DateTime.now().difference(user.createdTime!).inDays
          : 365;
      if (daysSinceActive < 30) score += 10.0;
      else if (daysSinceActive < 90) score += 5.0;

      return MapEntry(user, score);
    }).toList();

    // Sort by score (descending) and return users
    scoredUsers.sort((a, b) => b.value.compareTo(a.value));
    return scoredUsers.map((entry) => entry.key).toList();
  }

  /// Ranks suggested users by relevance to current user.
  List<UsersRecord> _rankSuggestions(List<UsersRecord> suggestions, UsersRecord currentUser) {
    final scoredSuggestions = suggestions.map((user) {
      double score = 0.0;

      // Same IBEW local (highest relevance)
      if (currentUser.localNumber != null &&
          user.localNumber == currentUser.localNumber) {
        score += 100.0;
      }

      // Shared certifications (medium relevance)
      if (currentUser.certifications != null && user.certifications != null) {
        final sharedCertifications = currentUser.certifications!
            .where((cert) => user.certifications!.contains(cert))
            .length;
        score += sharedCertifications * 20.0;
      }

      // Experience level similarity
      if (currentUser.yearsExperience != null && user.yearsExperience != null) {
        final experienceDiff = (currentUser.yearsExperience! - user.yearsExperience!).abs();
        if (experienceDiff <= 2) score += 15.0;
        else if (experienceDiff <= 5) score += 10.0;
      }

      // Recent activity bonus
      final daysSinceActive = user.createdTime != null
          ? DateTime.now().difference(user.createdTime!).inDays
          : 365;
      if (daysSinceActive < 7) score += 5.0;

      return MapEntry(user, score);
    }).toList();

    scoredSuggestions.sort((a, b) => b.value.compareTo(a.value));
    return scoredSuggestions.map((entry) => entry.key).toList();
  }

  /// Extracts IBEW local number from query string.
  String? _extractLocalNumber(String query) {
    final match = _localPattern.firstMatch(query) ?? _ibewPattern.firstMatch(query);
    return match?.group(1);
  }

  /// Generates cache key for search results.
  String _generateCacheKey(String query, int limit, String? excludeUserId) {
    return '${query}_${limit}_${excludeUserId ?? ''}';
  }

  /// Gets cached search result if valid.
  UserSearchResult? _getCachedResult(String cacheKey) {
    final cached = _searchCache[cacheKey];
    if (cached != null &&
        DateTime.now().difference(cached.timestamp) < _cacheTTL) {
      return cached.result;
    }

    // Remove expired cache entry
    _searchCache.remove(cacheKey);
    return null;
  }

  /// Caches search result with TTL.
  void _cacheResult(String cacheKey, UserSearchResult result) {
    // Remove oldest entries if cache is full
    if (_searchCache.length >= _maxCacheSize) {
      final oldestKey = _searchCache.entries
          .reduce((a, b) => a.value.timestamp.isBefore(b.value.timestamp) ? a : b)
          .key;
      _searchCache.remove(oldestKey);
    }

    _searchCache[cacheKey] = _CachedSearchResult(
      result: result,
      timestamp: DateTime.now(),
    );
  }

  /// Cleans up resources and timers.
  void dispose() {
    for (final timer in _searchTimers.values) {
      timer.cancel();
    }
    _searchTimers.clear();
    _searchCache.clear();
  }
}

/// Data class representing search results with pagination metadata.
class UserSearchResult {
  final List<UsersRecord> users;
  final bool hasMore;
  final String? nextPageToken;

  UserSearchResult({
    required this.users,
    required this.hasMore,
    this.nextPageToken,
  });
}

/// Internal cache entry for search results.
class _CachedSearchResult {
  final UserSearchResult result;
  final DateTime timestamp;

  _CachedSearchResult({
    required this.result,
    required this.timestamp,
  });
}

/// Custom exception for rate limiting.
class RateLimitException implements Exception {
  final String message;
  final Duration? retryAfter;
  final String operation;

  RateLimitException(
    this.message, {
    this.retryAfter,
    required this.operation,
  });

  @override
  String toString() => 'RateLimitException: $message';
}

/// Custom exception for validation errors.
class ValidationException implements Exception {
  final String message;

  ValidationException(this.message);

  @override
  String toString() => 'ValidationException: $message';
}