import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Mock classes for Firebase services used in testing
///
/// Provides comprehensive mocking for Firebase services to enable
/// unit testing of crew job sharing functionality.

class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}

class MockFirebaseAuth extends Mock implements FirebaseAuth {}

class MockUser extends Mock implements User {}

class MockDocumentReference extends Mock implements DocumentReference {}

class MockCollectionReference extends Mock implements CollectionReference {}

class MockCollectionGroup extends Mock implements CollectionReference {}

class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQuery extends Mock implements Query {}

class MockBatch extends Mock implements WriteBatch {}

class MockTransaction extends Mock implements Transaction {}

class MockTimestamp extends Mock implements Timestamp {
  @override
  DateTime toDate() => DateTime.now();

  @override
  int get seconds => DateTime.now().millisecondsSinceEpoch ~/ 1000;

  @override
  int get nanoseconds => 0;
}

class MockFieldValue extends Mock implements FieldValue {}

/// Helper class to create mock Firestore collections and documents
class FirebaseMockHelper {
  static MockDocumentReference createMockDocumentReference(String id) {
    final mockDoc = MockDocumentReference();
    when(mockDoc.id).thenReturn(id);
    return mockDoc;
  }

  static MockDocumentSnapshot createMockDocumentSnapshot(
    String id,
    Map<String, dynamic>? data, {
    bool exists = true,
  }) {
    final mockSnapshot = MockDocumentSnapshot();
    when(mockSnapshot.id).thenReturn(id);
    when(mockSnapshot.exists).thenReturn(exists);
    when(mockSnapshot.data()).thenReturn(data);
    return mockSnapshot;
  }

  static MockQueryDocumentSnapshot createMockQueryDocumentSnapshot(
    String id,
    Map<String, dynamic> data,
  ) {
    final mockSnapshot = MockQueryDocumentSnapshot();
    when(mockSnapshot.id).thenReturn(id);
    when(mockSnapshot.data()).thenReturn(data);
    when(mockSnapshot.exists).thenReturn(true);
    return mockSnapshot;
  }

  static MockQuerySnapshot createMockQuerySnapshot(
    List<QueryDocumentSnapshot> docs,
  ) {
    final mockSnapshot = MockQuerySnapshot();
    when(mockSnapshot.docs).thenReturn(docs);
    when(mockSnapshot.size).thenReturn(docs.length);
    return mockSnapshot;
  }

  static MockUser createMockUser({
    String uid = 'test_user_id',
    String? email = 'test@example.com',
    String? displayName = 'Test User',
    bool emailVerified = true,
  }) {
    final mockUser = MockUser();
    when(mockUser.uid).thenReturn(uid);
    when(mockUser.email).thenReturn(email);
    when(mockUser.displayName).thenReturn(displayName);
    when(mockUser.emailVerified).thenReturn(emailVerified);
    return mockUser;
  }

  static Timestamp createMockTimestamp([DateTime? dateTime]) {
    final targetDateTime = dateTime ?? DateTime.now();
    final mockTimestamp = MockTimestamp();
    when(mockTimestamp.toDate()).thenReturn(targetDateTime);
    when(mockTimestamp.seconds)
        .thenReturn(targetDateTime.millisecondsSinceEpoch ~/ 1000);
    when(mockTimestamp.nanoseconds).thenReturn(0);
    return mockTimestamp;
  }
}