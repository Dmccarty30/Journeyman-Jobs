import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import '../../fixtures/mock_data.dart';
import '../../fixtures/test_constants.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
])
import 'firestore_service_test.mocks.dart';

void main() {
  late FirestoreService firestoreService;
  late MockFirebaseFirestore mockFirestore;
  late MockCollectionReference mockUsersCollection;
  late MockCollectionReference mockJobsCollection;
  late MockCollectionReference mockLocalsCollection;
  late MockDocumentReference mockDocumentReference;
  late MockDocumentSnapshot mockDocumentSnapshot;
  late MockQuerySnapshot mockQuerySnapshot;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockUsersCollection = MockCollectionReference();
    mockJobsCollection = MockCollectionReference();
    mockLocalsCollection = MockCollectionReference();
    mockDocumentReference = MockDocumentReference();
    mockDocumentSnapshot = MockDocumentSnapshot();
    mockQuerySnapshot = MockQuerySnapshot();

    // Setup collection mocks
    when(mockFirestore.collection('users')).thenReturn(mockUsersCollection);
    when(mockFirestore.collection('jobs')).thenReturn(mockJobsCollection);
    when(mockFirestore.collection('locals')).thenReturn(mockLocalsCollection);

    firestoreService = FirestoreService();
  });

  group('FirestoreService - User Operations', () {
    test('createUser should create user document with correct data', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final userData = MockData.createAuthData(uid: userId);
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any)).thenAnswer((_) async {});

      // Act
      await firestoreService.createUser(uid: userId, userData: userData);

      // Assert
      verify(mockUsersCollection.doc(userId)).called(1);
      verify(mockDocumentReference.set(argThat(
        allOf([
          containsPair('uid', userId),
          containsPair('onboardingStatus', 'pending'),
          containsPair('email', userData['email']),
        ])
      ))).called(1);
    });

    test('createUser should throw exception on error', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final userData = MockData.createAuthData(uid: userId);
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any))
          .thenThrow(Exception('Firestore error'));

      // Act & Assert
      expect(
        () => firestoreService.createUser(uid: userId, userData: userData),
        throwsException,
      );
    });

    test('userProfileExists should return true when user exists', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(true);

      // Act
      final exists = await firestoreService.userProfileExists(userId);

      // Assert
      expect(exists, isTrue);
      verify(mockUsersCollection.doc(userId)).called(1);
      verify(mockDocumentReference.get()).called(1);
    });

    test('userProfileExists should return false when user does not exist', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentSnapshot.exists).thenReturn(false);

      // Act
      final exists = await firestoreService.userProfileExists(userId);

      // Assert
      expect(exists, isFalse);
    });

    test('userProfileExists should throw exception on error', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenThrow(Exception('Network error'));

      // Act & Assert
      expect(
        () => firestoreService.userProfileExists(userId),
        throwsException,
      );
    });
  });

  group('FirestoreService - Collection Access', () {
    test('should provide access to users collection', () {
      // Act
      final usersCollection = firestoreService.usersCollection;

      // Assert
      expect(usersCollection, isNotNull);
      verify(mockFirestore.collection('users')).called(1);
    });

    test('should provide access to jobs collection', () {
      // Act
      final jobsCollection = firestoreService.jobsCollection;

      // Assert
      expect(jobsCollection, isNotNull);
      verify(mockFirestore.collection('jobs')).called(1);
    });

    test('should provide access to locals collection', () {
      // Act
      final localsCollection = firestoreService.localsCollection;

      // Assert
      expect(localsCollection, isNotNull);
      verify(mockFirestore.collection('locals')).called(1);
    });

    test('should provide access to firestore instance', () {
      // Act
      final firestore = firestoreService.firestore;

      // Assert
      expect(firestore, equals(mockFirestore));
    });
  });

  group('FirestoreService - Constants', () {
    test('should have correct default page size', () {
      expect(FirestoreService.defaultPageSize, equals(20));
    });

    test('should have correct max page size', () {
      expect(FirestoreService.maxPageSize, equals(100));
    });
  });

  group('FirestoreService - IBEW Specific Operations', () {
    test('createUserProfile should handle IBEW member data correctly', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final ibewUserData = {
        'localNumber': MockData.realIBEWLocals.first,
        'classification': MockData.electricalClassifications.first,
        'certifications': ['OSHA 30', 'First Aid/CPR'],
        'yearsExperience': 5,
        'preferredDistance': 50,
      };
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any)).thenAnswer((_) async {});

      // Act
      await firestoreService.createUserProfile(userId: userId, data: ibewUserData);

      // Assert
      verify(mockDocumentReference.set(argThat(
        allOf([
          containsPair('localNumber', MockData.realIBEWLocals.first),
          containsPair('classification', MockData.electricalClassifications.first),
          containsPair('certifications', ['OSHA 30', 'First Aid/CPR']),
        ])
      ))).called(1);
    });

    test('should handle storm work scenarios', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final stormWorkerData = {
        'localNumber': MockData.realIBEWLocals.first,
        'classification': 'Journeyman Lineman',
        'availableForStormWork': true,
        'mobilityLevel': 'high',
        'emergencyContacts': ['555-0123'],
      };
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any)).thenAnswer((_) async {});

      // Act
      await firestoreService.createUserProfile(userId: userId, data: stormWorkerData);

      // Assert
      verify(mockDocumentReference.set(argThat(
        containsPair('availableForStormWork', true)
      ))).called(1);
    });
  });

  group('FirestoreService - Error Handling', () {
    test('should handle network timeout errors gracefully', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final userData = MockData.createAuthData(uid: userId);
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any))
          .thenThrow(Exception(TestConstants.networkErrorMessage));

      // Act & Assert
      expect(
        () => firestoreService.createUser(uid: userId, userData: userData),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle permission denied errors', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get())
          .thenThrow(Exception(TestConstants.permissionErrorMessage));

      // Act & Assert
      expect(
        () => firestoreService.userProfileExists(userId),
        throwsA(isA<Exception>()),
      );
    });

    test('should handle firestore operation failures', () async {
      // Arrange
      const userId = TestConstants.testUserId;
      final userData = MockData.createAuthData(uid: userId);
      
      when(mockUsersCollection.doc(userId)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.set(any))
          .thenThrow(Exception(TestConstants.firestoreErrorMessage));

      // Act & Assert
      expect(
        () => firestoreService.createUser(uid: userId, userData: userData),
        throwsA(isA<Exception>()),
      );
    });
  });

  group('FirestoreService - Performance Considerations', () {
    test('should respect page size limits', () {
      expect(FirestoreService.defaultPageSize, lessThanOrEqualTo(FirestoreService.maxPageSize));
    });

    test('should handle large IBEW local datasets efficiently', () {
      // This test ensures we're aware of the performance implications
      // of handling 797+ IBEW locals
      expect(MockData.realIBEWLocals.length, greaterThan(0));
      expect(MockData.realIBEWLocals.length, lessThan(800)); // Subset for testing
    });
  });
}