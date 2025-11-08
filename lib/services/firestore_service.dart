import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';

/// Basic Firestore service for common database operations
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Get a reference to a collection
  CollectionReference<Map<String, dynamic>> collection(String path) {
    return _firestore.collection(path);
  }

  /// Get a reference to a document
  DocumentReference<Map<String, dynamic>> document(String path) {
    return _firestore.doc(path);
  }

  /// Add a document to a collection
  Future<DocumentReference<Map<String, dynamic>>> addDocument(
    String collectionPath,
    Map<String, dynamic> data,
  ) async {
    try {
      return await _firestore.collection(collectionPath).add(data);
    } catch (e) {
      debugPrint('Error adding document to $collectionPath: $e');
      rethrow;
    }
  }

  /// Set a document (create or update)
  Future<void> setDocument(
    String documentPath,
    Map<String, dynamic> data, {
    bool merge = false,
  }) async {
    try {
      await _firestore.doc(documentPath).set(data, SetOptions(merge: merge));
    } catch (e) {
      debugPrint('Error setting document $documentPath: $e');
      rethrow;
    }
  }

  /// Get a document
  Future<DocumentSnapshot<Map<String, dynamic>>> getDocument(
    String documentPath,
  ) async {
    try {
      return await _firestore.doc(documentPath).get();
    } catch (e) {
      debugPrint('Error getting document $documentPath: $e');
      rethrow;
    }
  }

  /// Update a document
  Future<void> updateDocument(
    String documentPath,
    Map<String, dynamic> data,
  ) async {
    try {
      await _firestore.doc(documentPath).update(data);
    } catch (e) {
      debugPrint('Error updating document $documentPath: $e');
      rethrow;
    }
  }

  /// Delete a document
  Future<void> deleteDocument(String documentPath) async {
    try {
      await _firestore.doc(documentPath).delete();
    } catch (e) {
      debugPrint('Error deleting document $documentPath: $e');
      rethrow;
    }
  }

  /// Query a collection with options
  Query<Map<String, dynamic>> queryCollection(
    String collectionPath, {
    String? orderBy,
    bool descending = false,
    int? limit,
    Query? whereQuery,
  }) {
    Query<Map<String, dynamic>> query = _firestore.collection(collectionPath);

    if (whereQuery != null) {
      // Apply where conditions from the existing query
      query = whereQuery;
    }

    if (orderBy != null) {
      query = query.orderBy(orderBy, descending: descending);
    }

    if (limit != null) {
      query = query.limit(limit);
    }

    return query;
  }

  /// Run a transaction
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) transactionHandler,
  ) async {
    try {
      return await _firestore.runTransaction(transactionHandler);
    } catch (e) {
      debugPrint('Error running transaction: $e');
      rethrow;
    }
  }

  /// Batch write operations
  WriteBatch createBatch() {
    return _firestore.batch();
  }

  /// Check if a document exists
  Future<bool> documentExists(String documentPath) async {
    try {
      final doc = await _firestore.doc(documentPath).get();
      return doc.exists;
    } catch (e) {
      debugPrint('Error checking document existence $documentPath: $e');
      return false;
    }
  }

  /// Get server timestamp
  Timestamp get serverTimestamp => Timestamp.now();

  /// Convert a timestamp to DateTime
  DateTime? timestampToDateTime(Timestamp? timestamp) {
    return timestamp?.toDate();
  }

  /// Convert DateTime to Timestamp
  Timestamp dateTimeToTimestamp(DateTime? dateTime) {
    return Timestamp.fromDate(dateTime ?? DateTime.now());
  }
}

/// Custom exception for Firestore operations
class FirestoreException implements Exception {
  final String message;
  final String? code;
  final dynamic originalError;

  FirestoreException(
    this.message, {
    this.code,
    this.originalError,
  });

  @override
  String toString() {
    return 'FirestoreException: $message${code != null ? ' (code: $code)' : ''}';
  }
}