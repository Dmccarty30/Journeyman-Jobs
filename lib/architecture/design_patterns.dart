/// @nodoc
library;

/// 🏗️ Journeyman Jobs - Architectural Design Patterns
///
/// This file contains standardized architectural patterns for phases 3-13
/// implementation. All new features should follow these patterns for consistency,
/// maintainability, and scalability.

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/utils/structured_logging.dart';

// =================== BASE SERVICE PATTERN ===================

/// Base service class that all feature services should extend.
/// Provides consistent error handling, logging, and offline support.
abstract class BaseService {
  final FirebaseFirestore _firestore;
  final String _serviceName;

  BaseService({
    required FirebaseFirestore firestore,
    required String serviceName,
  }) : _firestore = firestore,
       _serviceName = serviceName;

  /// Execute an operation with consistent error handling and logging
  Future<T> executeWithErrorHandling<T>(
    Future<T> Function() operation,
    String operationName, {
    Map<String, dynamic>? context,
  }) async {
    final stopwatch = Stopwatch()..start();

    try {
      StructuredLogger.info(
        'Starting operation',
        context: {
          'service': _serviceName,
          'operation': operationName,
          ...?context,
        },
      );

      final result = await operation();

      stopwatch.stop();
      StructuredLogger.info(
        'Operation completed successfully',
        context: {
          'service': _serviceName,
          'operation': operationName,
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...?context,
        },
      );

      return result;
    } catch (error, stackTrace) {
      stopwatch.stop();
      StructuredLogger.error(
        'Operation failed',
        error: error,
        stackTrace: stackTrace,
        context: {
          'service': _serviceName,
          'operation': operationName,
          'duration_ms': stopwatch.elapsedMilliseconds,
          ...?context,
        },
      );
      rethrow;
    }
  }

  /// Get a Firestore collection reference with optional converter
  CollectionReference<T> getCollection<T extends Object?>(
    String path, {
    FirestoreDataConverter<T>? converter,
  }) {
    final collection = _firestore.collection(path);
    if (converter != null) {
      return collection.withConverter<T>(
        fromFirestore: converter.fromFirestore,
        toFirestore: converter.toFirestore,
      );
    }
    return collection as CollectionReference<T>;
  }

  /// Execute a batch operation with automatic error handling
  Future<void> executeBatch(
    Future<void> Function(WriteBatch batch) operation,
    String operationName,
  ) async {
    return executeWithErrorHandling(() async {
      final batch = _firestore.batch();
      await operation(batch);
      await batch.commit();
    }, operationName);
  }

  /// Access to Firestore instance for direct queries when needed
  FirebaseFirestore get firestore => _firestore;
}

// =================== FIRESTORE DATA CONVERTER ===================

/// Generic Firestore data converter interface
///
/// This interface provides type-safe conversion between Firestore documents
/// and Dart model objects. Implementing this pattern ensures consistent
/// data transformation across the application.
///
/// Example usage:
/// ```dart
/// class JobConverter implements FirestoreDataConverter<Job> {
///   @override
///   Job fromFirestore(DocumentSnapshot<Map<String, dynamic>> snapshot, SnapshotOptions? options) {
///     final data = snapshot.data()!;
///     return Job.fromJson({...data, 'id': snapshot.id});
///   }
///
///   @override
///   Map<String, Object?> toFirestore(Job model, SetOptions? options) {
///     return model.toFirestore();
///   }
/// }
/// ```
abstract class FirestoreDataConverter<T> {
  /// Convert Firestore document to model object
  T fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> snapshot,
    SnapshotOptions? options,
  );

  /// Convert model object to Firestore document data
  Map<String, Object?> toFirestore(T model, SetOptions? options);
}

// =================== DATA MODEL PATTERN ===================

/// Base interface for all data models
abstract class BaseModel {
  /// Unique identifier for the model
  String get id;

  /// Convert model to Firestore document data
  Map<String, dynamic> toFirestore();

  /// Create model from Firestore document
  static BaseModel fromFirestore(DocumentSnapshot doc) {
    throw UnimplementedError('fromFirestore must be implemented');
  }

  /// Validate model data
  bool isValid() => true;

  /// Get validation errors
  List<String> getValidationErrors() => [];
}

/// Mixin for models that support timestamps
mixin TimestampedModel on BaseModel {
  DateTime? get createdAt;
  DateTime? get updatedAt;

  Map<String, dynamic> addTimestamps(Map<String, dynamic> data) {
    final now = FieldValue.serverTimestamp();
    return {
      ...data,
      if (createdAt == null) 'createdAt': now,
      'updatedAt': now,
    };
  }
}

/// Mixin for models that support soft deletion
mixin SoftDeletableModel on BaseModel {
  bool get isDeleted;
  DateTime? get deletedAt;

  Map<String, dynamic> addDeletionFields(Map<String, dynamic> data) {
    return {
      ...data,
      'isDeleted': isDeleted,
      if (deletedAt != null) 'deletedAt': Timestamp.fromDate(deletedAt!),
    };
  }
}

// =================== REPOSITORY PATTERN ===================

/// Generic repository interface for data access
abstract class Repository<T extends BaseModel> {
  /// Get a single item by ID
  Future<T?> getById(String id);

  /// Get multiple items with optional filtering
  Future<List<T>> getAll({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  /// Create a new item
  Future<String> create(T item);

  /// Update an existing item
  Future<void> update(String id, T item);

  /// Delete an item (hard delete)
  Future<void> delete(String id);

  /// Soft delete an item (if supported)
  Future<void> softDelete(String id) {
    throw UnimplementedError('Soft delete not supported');
  }

  /// Get a stream of items for real-time updates
  Stream<List<T>> watchAll({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  });

  /// Get a stream of a single item
  Stream<T?> watchById(String id);
}

/// Base implementation of repository pattern
abstract class FirestoreRepository<T extends BaseModel>
    extends BaseService implements Repository<T> {

  final String collectionPath;
  final T Function(DocumentSnapshot) fromFirestore;

  FirestoreRepository({
    required super.firestore,
    required this.collectionPath,
    required this.fromFirestore,
    required super.serviceName,
  });

  CollectionReference<Map<String, dynamic>> get _collection =>
      firestore.collection(collectionPath);

  @override
  Future<T?> getById(String id) async {
    return executeWithErrorHandling(() async {
      final doc = await _collection.doc(id).get();
      if (!doc.exists) return null;
      return fromFirestore(doc);
    }, 'getById', context: {'id': id});
  }

  @override
  Future<List<T>> getAll({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) async {
    return executeWithErrorHandling(() async {
      Query query = _collection;

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }

      // Apply ordering
      if (orderBy != null) {
        query = query.orderBy(orderBy, descending: descending);
      }

      // Apply limit
      if (limit != null) {
        query = query.limit(limit);
      }

      final snapshot = await query.get();
      return snapshot.docs.map(fromFirestore).toList();
    }, 'getAll', context: {
      'filters': filters,
      'orderBy': orderBy,
      'descending': descending,
      'limit': limit,
    });
  }

  @override
  Future<String> create(T item) async {
    return executeWithErrorHandling(() async {
      if (!item.isValid()) {
        throw ArgumentError('Invalid model: ${item.getValidationErrors()}');
      }

      final docRef = _collection.doc();
      await docRef.set(item.toFirestore());
      return docRef.id;
    }, 'create');
  }

  @override
  Future<void> update(String id, T item) async {
    return executeWithErrorHandling(() async {
      if (!item.isValid()) {
        throw ArgumentError('Invalid model: ${item.getValidationErrors()}');
      }

      await _collection.doc(id).update(item.toFirestore());
    }, 'update', context: {'id': id});
  }

  @override
  Future<void> delete(String id) async {
    return executeWithErrorHandling(() async {
      await _collection.doc(id).delete();
    }, 'delete', context: {'id': id});
  }

  @override
  Stream<List<T>> watchAll({
    Map<String, dynamic>? filters,
    String? orderBy,
    bool descending = false,
    int? limit,
  }) {
    Query query = _collection;

    // Apply filters
    if (filters != null) {
      for (final entry in filters.entries) {
        query = query.where(entry.key, isEqualTo: entry.value);
      }
    }

    // Apply ordering
    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    // Apply limit
    if (limit != null) {
      query = query.limit(limit);
    }

    return query.snapshots().map(
      (snapshot) => snapshot.docs.map(fromFirestore).toList(),
    );
  }

  @override
  Stream<T?> watchById(String id) {
    return _collection.doc(id).snapshots().map(
      (doc) => doc.exists ? fromFirestore(doc) : null,
    );
  }
}

// =================== PAGINATION PATTERN ===================

/// Pagination configuration for large datasets
class PaginationConfig {
  final int pageSize;
  final String orderByField;
  final bool descending;

  const PaginationConfig({
    this.pageSize = 20,
    this.orderByField = 'createdAt',
    this.descending = true,
  });
}

/// Pagination state for providers
class PaginatedData<T> {
  final List<T> items;
  final bool hasMore;
  final bool isLoading;
  final String? error;
  final DocumentSnapshot? lastDocument;

  const PaginatedData({
    required this.items,
    required this.hasMore,
    this.isLoading = false,
    this.error,
    this.lastDocument,
  });

  PaginatedData<T> copyWith({
    List<T>? items,
    bool? hasMore,
    bool? isLoading,
    String? error,
    DocumentSnapshot? lastDocument,
  }) {
    return PaginatedData<T>(
      items: items ?? this.items,
      hasMore: hasMore ?? this.hasMore,
      isLoading: isLoading ?? this.isLoading,
      error: error ?? this.error,
      lastDocument: lastDocument ?? this.lastDocument,
    );
  }
}

/// Mixin for repositories that support pagination
mixin PaginatedRepository<T extends BaseModel> on FirestoreRepository<T> {
  Future<PaginatedData<T>> getPaginated({
    PaginationConfig config = const PaginationConfig(),
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) async {
    return executeWithErrorHandling(() async {
      Query query = _collection;

      // Apply filters
      if (filters != null) {
        for (final entry in filters.entries) {
          query = query.where(entry.key, isEqualTo: entry.value);
        }
      }

      // Apply ordering
      query = query.orderBy(config.orderByField, descending: config.descending);

      // Apply pagination
      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      // Request one more item to check if there are more pages
      query = query.limit(config.pageSize + 1);

      final snapshot = await query.get();
      final docs = snapshot.docs;

      final hasMore = docs.length > config.pageSize;
      final items = docs
          .take(config.pageSize)
          .map(fromFirestore)
          .toList();

      final lastDocument = items.isNotEmpty ? docs[items.length - 1] : null;

      return PaginatedData<T>(
        items: items,
        hasMore: hasMore,
        lastDocument: lastDocument,
      );
    }, 'getPaginated');
  }
}

// =================== VALIDATION PATTERN ===================

/// Base validation interface
abstract class Validator<T> {
  bool isValid(T value);
  List<String> getErrors(T value);
}

/// Common validators
class CommonValidators {
  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static bool isNotEmpty(String? value) {
    return value != null && value.isNotEmpty;
  }

  static bool isValidPhoneNumber(String phone) {
    return RegExp(r'^\+?1?[2-9]\d{2}[2-9]\d{2}\d{4}$').hasMatch(phone);
  }

  static bool isValidUrl(String url) {
    try {
      final uri = Uri.parse(url);
      return uri.hasScheme && (uri.isScheme('http') || uri.isScheme('https'));
    } catch (e) {
      return false;
    }
  }
}

// =================== ERROR HANDLING PATTERN ===================

/// Base exception for app-specific errors
abstract class AppException implements Exception {
  final String message;
  final String? code;
  final Map<String, dynamic>? context;

  const AppException(this.message, {this.code, this.context});

  @override
  String toString() => 'AppException: $message';
}

/// Validation exception
class ValidationException extends AppException {
  final List<String> errors;

  const ValidationException(this.errors, {super.code, super.context})
      : super('Validation failed');

  @override
  String toString() => 'ValidationException: ${errors.join(', ')}';
}

/// Network exception
class NetworkException extends AppException {
  const NetworkException(super.message, {super.code, super.context});
}

/// Firestore exception wrapper
class FirestoreException extends AppException {
  const FirestoreException(super.message, {super.code, super.context});
}
