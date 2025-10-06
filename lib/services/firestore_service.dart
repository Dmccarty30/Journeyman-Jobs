import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

/// A generic service providing fundamental Firestore operations.
///
/// This class offers a reusable interface for common Firestore tasks such as
/// CRUD operations, batch writes, and transactions, with built-in performance
/// optimizations like pagination limits.
class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Performance optimization constants
  /// The default number of documents to fetch in a paginated query.
  static const int defaultPageSize = 20;
  /// The maximum number of documents that can be fetched in a single query.
  static const int maxPageSize = 100;

  // Get Firestore instance
  /// Provides direct access to the underlying [FirebaseFirestore] instance.
  FirebaseFirestore get firestore => _firestore;

  // Collections
  /// A reference to the 'users' collection in Firestore.
  CollectionReference get usersCollection => _firestore.collection('users');
  /// A reference to the 'jobs' collection in Firestore.
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  /// A reference to the 'locals' collection in Firestore.
  CollectionReference get localsCollection => _firestore.collection('locals');

  // User Operations
  /// Creates a new user document in the 'users' collection.
  ///
  /// - [uid]: The unique ID of the user.
  /// - [userData]: A map of data to be stored for the user.
  Future<void> createUser({
    required String uid,
    required Map<String, dynamic> userData,
  }) async {
    try {
      await usersCollection.doc(uid).set({
        ...userData,
        'createdTime': FieldValue.serverTimestamp(),
        'onboardingStatus': 'pending',
      });
    } catch (e) {
      throw Exception('Error creating user: $e');
    }
  }

  /// Creates or overwrites a user profile document.
  ///
  /// - [userId]: The ID of the user whose profile is being created.
  /// - [data]: The profile data.
  Future<void> createUserProfile({
    required String userId,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(userId).set(data);
    } catch (e) {
      throw Exception('Error creating user profile: $e');
    }
  }

  /// Checks if a user profile document exists.
  ///
  /// - [userId]: The ID of the user to check.
  ///
  /// Returns `true` if the document exists, `false` otherwise.
  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error checking user profile: $e');
    }
  }

  /// Deletes a user's data from Firestore.
  ///
  /// - [userId]: The ID of the user to delete.
  Future<void> deleteUserData(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user data: $e');
    }
  }

  /// Updates the email field for a specific user.
  ///
  /// - [userId]: The ID of the user to update.
  /// - [newEmail]: The new email address.
  Future<void> updateUserEmail(String userId, String newEmail) async {
    try {
      await usersCollection.doc(userId).update({'email': newEmail});
    } catch (e) {
      throw Exception('Error updating user email: $e');
    }
  }

  /// Fetches a single user document snapshot.
  ///
  /// - [uid]: The unique ID of the user to fetch.
  ///
  /// Returns a `Future<DocumentSnapshot>`.
  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

  /// Updates a user document with the provided data.
  ///
  /// - [uid]: The ID of the user to update.
  /// - [data]: A map of fields to update.
  Future<void> updateUser({
    required String uid,
    required Map<String, dynamic> data,
  }) async {
    try {
      await usersCollection.doc(uid).update(data);
    } catch (e) {
      throw Exception('Error updating user: $e');
    }
  }

  /// Provides a real-time stream of a user's document.
  ///
  /// - [uid]: The ID of the user to stream.
  ///
  /// Returns a `Stream<DocumentSnapshot>`.
  Stream<DocumentSnapshot> getUserStream(String uid) {
    return usersCollection.doc(uid).snapshots();
  }

  // Job Operations
  /// Retrieves a paginated and filtered stream of jobs.
  ///
  /// - [limit]: The maximum number of jobs to fetch.
  /// - [startAfter]: The `DocumentSnapshot` to start after for pagination.
  /// - [filters]: A map of key-value pairs to filter the jobs query.
  ///
  /// Returns a `Stream<QuerySnapshot>`.
  Stream<QuerySnapshot> getJobs({
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
    // Enforce pagination limits for performance
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }
    
    Query query = jobsCollection.orderBy('timestamp', descending: true);

    // Apply filters
    if (filters != null) {
      if (filters['local'] != null) {
        query = query.where('local', isEqualTo: filters['local']);
      }
      if (filters['classification'] != null) {
        query = query.where('classification', isEqualTo: filters['classification']);
      }
      if (filters['location'] != null) {
        query = query.where('location', isEqualTo: filters['location']);
      }
      if (filters['typeOfWork'] != null) {
        query = query.where('typeOfWork', isEqualTo: filters['typeOfWork']);
      }
    }

    // Always enforce pagination
    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Fetches a single job document by its ID.
  ///
  /// - [jobId]: The unique ID of the job.
  ///
  /// Returns a `Future<DocumentSnapshot>`.
  Future<DocumentSnapshot> getJob(String jobId) async {
    try {
      return await jobsCollection.doc(jobId).get();
    } catch (e) {
      throw Exception('Error getting job: $e');
    }
  }

  // Local Union Operations
  /// Retrieves a paginated and optionally filtered stream of IBEW locals.
  ///
  /// - [limit]: The maximum number of locals to fetch.
  /// - [startAfter]: The `DocumentSnapshot` for pagination.
  /// - [state]: An optional state to filter the locals by.
  ///
  /// Returns a `Stream<QuerySnapshot>`.
  Stream<QuerySnapshot> getLocals({
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    String? state,
  }) {
    // Enforce pagination limits for performance
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }
    
    if (kDebugMode) {
      print('🔍 FirestoreService.getLocals called:');
      print('  - Collection: locals');
      print('  - Limit: $limit');
      print('  - State filter: ${state ?? "none"}');
      print('  - Start after: ${startAfter != null ? "yes" : "no"}');
    }
    
    // Temporarily remove orderBy to test if documents load
    // Query query = localsCollection.orderBy('local_union');
    Query query = localsCollection;
    
    // Apply geographic filtering if provided
    if (state != null && state.isNotEmpty) {
      query = query.where('state', isEqualTo: state);
    }
    
    // Always enforce pagination
    query = query.limit(limit);
    
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    
    if (kDebugMode) {
      print('📡 Executing query on locals collection...');
    }
    
    return query.snapshots();
  }

  /// Searches for IBEW locals by name, with optional state filtering.
  ///
  /// Uses a prefix-style query on the `local_union` field.
  ///
  /// - [searchTerm]: The term to search for.
  /// - [limit]: The maximum number of results to return.
  /// - [state]: An optional state to scope the search.
  ///
  /// Returns a `Future<QuerySnapshot>` containing the search results.
  Future<QuerySnapshot> searchLocals(
    String searchTerm, {
    int limit = defaultPageSize,
    String? state,
  }) async {
    try {
      // Enforce pagination limits for performance
      if (limit > maxPageSize) {
        limit = maxPageSize;
      }
      
      Query query = localsCollection;
      
      // Apply geographic filtering first (most selective)
      if (state != null && state.isNotEmpty) {
        query = query.where('state', isEqualTo: state);
      }
      
      // Apply search filter
      query = query
          .where('local_union', isGreaterThanOrEqualTo: searchTerm.toLowerCase())
          .where('local_union', isLessThanOrEqualTo: '${searchTerm.toLowerCase()}\uf8ff')
          .limit(limit);
      
      return await query.get();
    } catch (e) {
      throw Exception('Error searching locals: $e');
    }
  }

  /// Fetches a single IBEW local document by its ID.
  ///
  /// - [localId]: The unique ID of the local.
  ///
  /// Returns a `Future<DocumentSnapshot>`.
  Future<DocumentSnapshot> getLocal(String localId) async {
    try {
      return await localsCollection.doc(localId).get();
    } catch (e) {
      throw Exception('Error getting local: $e');
    }
  }

  // Batch Operations
  /// Executes a series of write operations as a single atomic batch.
  ///
  /// - [operations]: A list of [BatchOperation] objects to be executed.
  Future<void> batchWrite(List<BatchOperation> operations) async {
    final batch = _firestore.batch();

    for (final operation in operations) {
      switch (operation.type) {
        case OperationType.create:
          batch.set(operation.reference, operation.data!);
          break;
        case OperationType.update:
          batch.update(operation.reference, operation.data!);
          break;
        case OperationType.delete:
          batch.delete(operation.reference);
          break;
      }
    }

    try {
      await batch.commit();
    } catch (e) {
      throw Exception('Error in batch operation: $e');
    }
  }

  // Transaction Operations
  /// Runs a set of read and write operations as a single atomic transaction.
  ///
  /// The [handler] function receives a [Transaction] object and must complete
  /// all its operations within the transaction.
  ///
  /// Returns a `Future<T>` with the result of the transaction handler.
  Future<T> runTransaction<T>(
    Future<T> Function(Transaction transaction) handler,
  ) async {
    try {
      return await _firestore.runTransaction(handler);
    } catch (e) {
      throw Exception('Error in transaction: $e');
    }
  }
}

// Helper classes
/// Defines the type of operation to be performed in a batch write.
enum OperationType {
  /// Creates a new document.
  create,
  /// Updates an existing document.
  update,
  /// Deletes a document.
  delete
}

/// Represents a single operation within a Firestore batch write.
class BatchOperation {
  /// The reference to the document to be modified.
  final DocumentReference reference;
  /// The type of operation to perform.
  final OperationType type;
  /// The data to be used for a create or update operation.
  final Map<String, dynamic>? data;

  /// Creates a batch operation.
  BatchOperation({
    required this.reference,
    required this.type,
    this.data,
  });
}
