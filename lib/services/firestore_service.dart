import 'package:cloud_firestore/cloud_firestore.dart';

class FirestoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Collections
  CollectionReference get usersCollection => _firestore.collection('users');
  CollectionReference get jobsCollection => _firestore.collection('jobs');
  CollectionReference get localsCollection => _firestore.collection('locals');

  // User Operations
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

  Future<bool> userProfileExists(String userId) async {
    try {
      final doc = await usersCollection.doc(userId).get();
      return doc.exists;
    } catch (e) {
      throw Exception('Error checking user profile: $e');
    }
  }

  Future<void> deleteUserData(String userId) async {
    try {
      await usersCollection.doc(userId).delete();
    } catch (e) {
      throw Exception('Error deleting user data: $e');
    }
  }

  Future<void> updateUserEmail(String userId, String newEmail) async {
    try {
      await usersCollection.doc(userId).update({'email': newEmail});
    } catch (e) {
      throw Exception('Error updating user email: $e');
    }
  }

  Future<DocumentSnapshot> getUser(String uid) async {
    try {
      return await usersCollection.doc(uid).get();
    } catch (e) {
      throw Exception('Error getting user: $e');
    }
  }

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

  Stream<DocumentSnapshot> getUserStream(String uid) {
    return usersCollection.doc(uid).snapshots();
  }

  // Job Operations
  Stream<QuerySnapshot> getJobs({
    int? limit,
    DocumentSnapshot? startAfter,
    Map<String, dynamic>? filters,
  }) {
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

    if (limit != null) {
      query = query.limit(limit);
    }

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  Future<DocumentSnapshot> getJob(String jobId) async {
    try {
      return await jobsCollection.doc(jobId).get();
    } catch (e) {
      throw Exception('Error getting job: $e');
    }
  }

  // Local Union Operations
  Stream<QuerySnapshot> getLocals() {
    return localsCollection.orderBy('localUnion').snapshots();
  }

  Future<QuerySnapshot> searchLocals(String searchTerm) async {
    try {
      // Note: This is a basic search. For more advanced search,
      // consider using a search service like Algolia
      final results = await localsCollection
          .where('localUnion', isGreaterThanOrEqualTo: searchTerm)
          .where('localUnion', isLessThanOrEqualTo: '$searchTerm\uf8ff')
          .get();
      
      return results;
    } catch (e) {
      throw Exception('Error searching locals: $e');
    }
  }

  Future<DocumentSnapshot> getLocal(String localId) async {
    try {
      return await localsCollection.doc(localId).get();
    } catch (e) {
      throw Exception('Error getting local: $e');
    }
  }

  // Batch Operations
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
enum OperationType { create, update, delete }

class BatchOperation {
  final DocumentReference reference;
  final OperationType type;
  final Map<String, dynamic>? data;

  BatchOperation({
    required this.reference,
    required this.type,
    this.data,
  });
}
