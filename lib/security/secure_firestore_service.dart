/// Secure Firestore service wrapper with input validation and rate limiting.
///
/// This service wraps Firestore operations with security enhancements:
/// - Query parameter sanitization (prevent injection)
/// - Field name validation
/// - Document ID validation
/// - Rate limiting for write operations
/// - Input validation for IBEW-specific fields
///
/// Usage:
/// ```dart
/// final secureFirestore = SecureFirestoreService();
///
/// // Safe document read
/// final doc = await secureFirestore.getDocument(
///   collection: 'users',
///   documentId: userId,
/// );
///
/// // Safe query with validated field
/// final jobs = await secureFirestore.query(
///   collection: 'jobs',
///   field: 'local',
///   value: 123,
/// );
/// ```
library;

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:journeyman_jobs/security/input_validator.dart';
import 'package:journeyman_jobs/security/rate_limiter.dart';

/// Secure wrapper for Firestore operations with input validation.
///
/// All public methods validate inputs before executing Firestore operations.
/// Provides protection against:
/// - Firestore injection attacks
/// - Invalid field names
/// - Invalid document IDs
/// - Excessive write operations (rate limiting)
class SecureFirestoreService {
  final FirebaseFirestore _firestore;
  final RateLimiter _rateLimiter;

  /// Creates a secure Firestore service.
  ///
  /// Parameters:
  /// - firestore: FirebaseFirestore instance (defaults to FirebaseFirestore.instance)
  /// - rateLimiter: RateLimiter instance (defaults to new instance with standard config)
  SecureFirestoreService({
    FirebaseFirestore? firestore,
    RateLimiter? rateLimiter,
  })  : _firestore = firestore ?? FirebaseFirestore.instance,
        _rateLimiter = rateLimiter ?? RateLimiter();

  // ============================================================================
  // DOCUMENT OPERATIONS
  // ============================================================================

  /// Safely gets a document from Firestore with validated parameters.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - documentId: Document ID (validated for injection)
  ///
  /// Returns the DocumentSnapshot or throws ValidationException.
  ///
  /// Example:
  /// ```dart
  /// final userDoc = await secureFirestore.getDocument(
  ///   collection: 'users',
  ///   documentId: 'user123',
  /// );
  /// ```
  Future<DocumentSnapshot> getDocument({
    required String collection,
    required String documentId,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate document ID
    final sanitizedDocId = InputValidator.sanitizeDocumentId(documentId);

    debugPrint('[SecureFirestore] Getting document: $sanitizedCollection/$sanitizedDocId');

    return await _firestore
        .collection(sanitizedCollection)
        .doc(sanitizedDocId)
        .get();
  }

  /// Safely creates or updates a document with validated parameters.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - documentId: Document ID (validated for injection)
  /// - data: Document data (field names validated)
  /// - userId: User ID for rate limiting
  /// - merge: Whether to merge with existing data (default: false)
  ///
  /// Throws:
  /// - [ValidationException] if validation fails
  /// - [RateLimitException] if rate limit exceeded
  ///
  /// Example:
  /// ```dart
  /// await secureFirestore.setDocument(
  ///   collection: 'users',
  ///   documentId: 'user123',
  ///   data: {'name': 'John Doe', 'email': 'john@example.com'},
  ///   userId: 'user123',
  /// );
  /// ```
  Future<void> setDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required String userId,
    bool merge = false,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate document ID
    final sanitizedDocId = InputValidator.sanitizeDocumentId(documentId);

    // Security: Validate field names in data
    final sanitizedData = _validateDataFields(data);

    // Security: Check rate limit for write operations
    if (!await _rateLimiter.isAllowed(userId, operation: 'firestore_write')) {
      final retryAfter = _rateLimiter.getRetryAfter(
        userId,
        operation: 'firestore_write',
      );
      throw RateLimitException(
        'Too many write operations. Please try again later.',
        retryAfter: retryAfter,
        operation: 'firestore_write',
      );
    }

    debugPrint('[SecureFirestore] Setting document: $sanitizedCollection/$sanitizedDocId');

    await _firestore
        .collection(sanitizedCollection)
        .doc(sanitizedDocId)
        .set(sanitizedData, SetOptions(merge: merge));
  }

  /// Safely updates a document with validated parameters.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - documentId: Document ID (validated for injection)
  /// - data: Update data (field names validated)
  /// - userId: User ID for rate limiting
  ///
  /// Throws:
  /// - [ValidationException] if validation fails
  /// - [RateLimitException] if rate limit exceeded
  Future<void> updateDocument({
    required String collection,
    required String documentId,
    required Map<String, dynamic> data,
    required String userId,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate document ID
    final sanitizedDocId = InputValidator.sanitizeDocumentId(documentId);

    // Security: Validate field names in data
    final sanitizedData = _validateDataFields(data);

    // Security: Check rate limit for write operations
    if (!await _rateLimiter.isAllowed(userId, operation: 'firestore_write')) {
      final retryAfter = _rateLimiter.getRetryAfter(
        userId,
        operation: 'firestore_write',
      );
      throw RateLimitException(
        'Too many write operations. Please try again later.',
        retryAfter: retryAfter,
        operation: 'firestore_write',
      );
    }

    debugPrint('[SecureFirestore] Updating document: $sanitizedCollection/$sanitizedDocId');

    await _firestore
        .collection(sanitizedCollection)
        .doc(sanitizedDocId)
        .update(sanitizedData);
  }

  /// Safely deletes a document with validated parameters.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - documentId: Document ID (validated for injection)
  /// - userId: User ID for rate limiting
  ///
  /// Throws:
  /// - [ValidationException] if validation fails
  /// - [RateLimitException] if rate limit exceeded
  Future<void> deleteDocument({
    required String collection,
    required String documentId,
    required String userId,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate document ID
    final sanitizedDocId = InputValidator.sanitizeDocumentId(documentId);

    // Security: Check rate limit for write operations
    if (!await _rateLimiter.isAllowed(userId, operation: 'firestore_write')) {
      final retryAfter = _rateLimiter.getRetryAfter(
        userId,
        operation: 'firestore_write',
      );
      throw RateLimitException(
        'Too many write operations. Please try again later.',
        retryAfter: retryAfter,
        operation: 'firestore_write',
      );
    }

    debugPrint('[SecureFirestore] Deleting document: $sanitizedCollection/$sanitizedDocId');

    await _firestore
        .collection(sanitizedCollection)
        .doc(sanitizedDocId)
        .delete();
  }

  // ============================================================================
  // QUERY OPERATIONS
  // ============================================================================

  /// Safely queries a collection with validated field names.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - field: Field name to query (validated for injection)
  /// - value: Value to match
  /// - limit: Maximum number of results (default: 20, max: 100)
  ///
  /// Returns QuerySnapshot with matching documents.
  ///
  /// Throws [ValidationException] if validation fails.
  ///
  /// Example:
  /// ```dart
  /// final jobs = await secureFirestore.query(
  ///   collection: 'jobs',
  ///   field: 'local',
  ///   value: 123,
  ///   limit: 50,
  /// );
  /// ```
  Future<QuerySnapshot> query({
    required String collection,
    required String field,
    required dynamic value,
    int limit = 20,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate field name
    final sanitizedField = InputValidator.sanitizeFirestoreField(field);

    // Security: Validate limit (prevent excessive queries)
    InputValidator.validateIntRange(limit, min: 1, max: 100, fieldName: 'limit');

    debugPrint(
      '[SecureFirestore] Querying: $sanitizedCollection where $sanitizedField == $value (limit: $limit)',
    );

    return await _firestore
        .collection(sanitizedCollection)
        .where(sanitizedField, isEqualTo: value)
        .limit(limit)
        .get();
  }

  /// Safely queries with multiple conditions.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - conditions: Map of field -> value conditions (all fields validated)
  /// - limit: Maximum number of results (default: 20, max: 100)
  ///
  /// Returns QuerySnapshot with matching documents.
  ///
  /// Example:
  /// ```dart
  /// final jobs = await secureFirestore.queryMultiple(
  ///   collection: 'jobs',
  ///   conditions: {
  ///     'local': 123,
  ///     'classification': 'Inside Wireman',
  ///   },
  /// );
  /// ```
  Future<QuerySnapshot> queryMultiple({
    required String collection,
    required Map<String, dynamic> conditions,
    int limit = 20,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate limit
    InputValidator.validateIntRange(limit, min: 1, max: 100, fieldName: 'limit');

    // Build query with validated field names
    Query query = _firestore.collection(sanitizedCollection);

    for (final entry in conditions.entries) {
      // Security: Validate each field name
      final sanitizedField = InputValidator.sanitizeFirestoreField(entry.key);
      query = query.where(sanitizedField, isEqualTo: entry.value);
    }

    debugPrint('[SecureFirestore] Querying with multiple conditions: $sanitizedCollection');

    return await query.limit(limit).get();
  }

  /// Safely gets all documents in a collection with pagination.
  ///
  /// Parameters:
  /// - collection: Collection path (validated for injection)
  /// - limit: Maximum number of results (default: 20, max: 100)
  /// - startAfter: Document to start after (for pagination)
  ///
  /// Returns QuerySnapshot with documents.
  Future<QuerySnapshot> getCollection({
    required String collection,
    int limit = 20,
    DocumentSnapshot? startAfter,
  }) async {
    // Security: Validate collection path
    final sanitizedCollection = InputValidator.sanitizeCollectionPath(collection);

    // Security: Validate limit
    InputValidator.validateIntRange(limit, min: 1, max: 100, fieldName: 'limit');

    debugPrint('[SecureFirestore] Getting collection: $sanitizedCollection (limit: $limit)');

    Query query = _firestore.collection(sanitizedCollection).limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return await query.get();
  }

  // ============================================================================
  // IBEW-SPECIFIC VALIDATIONS
  // ============================================================================

  /// Validates and creates a job document with IBEW-specific field validation.
  ///
  /// Validates:
  /// - local number (1-9999)
  /// - classification (valid IBEW classifications)
  /// - wage ($1-$999.99)
  ///
  /// Throws [ValidationException] if IBEW field validation fails.
  Future<void> createJobDocument({
    required String documentId,
    required Map<String, dynamic> jobData,
    required String userId,
  }) async {
    // Security: Validate IBEW-specific fields
    if (jobData.containsKey('local')) {
      final local = jobData['local'];
      if (local is int) {
        InputValidator.validateLocalNumber(local);
      }
    }

    if (jobData.containsKey('classification')) {
      final classification = jobData['classification'];
      if (classification is String) {
        jobData['classification'] = InputValidator.validateClassification(classification);
      }
    }

    if (jobData.containsKey('wage')) {
      final wage = jobData['wage'];
      if (wage is num) {
        InputValidator.validateWage(wage.toDouble());
      }
    }

    // Use standard set operation with validated data
    await setDocument(
      collection: 'jobs',
      documentId: documentId,
      data: jobData,
      userId: userId,
    );
  }

  // ============================================================================
  // PRIVATE HELPERS
  // ============================================================================

  /// Validates all field names in a data map.
  ///
  /// Recursively validates nested maps.
  /// Throws [ValidationException] if any field name is invalid.
  Map<String, dynamic> _validateDataFields(Map<String, dynamic> data) {
    final validated = <String, dynamic>{};

    for (final entry in data.entries) {
      // Security: Validate field name
      final sanitizedKey = InputValidator.sanitizeFirestoreField(entry.key);

      // Recursively validate nested maps
      if (entry.value is Map<String, dynamic>) {
        validated[sanitizedKey] = _validateDataFields(
          entry.value as Map<String, dynamic>,
        );
      } else {
        validated[sanitizedKey] = entry.value;
      }
    }

    return validated;
  }

  /// Disposes of the service and cleans up resources.
  void dispose() {
    _rateLimiter.dispose();
  }
}
