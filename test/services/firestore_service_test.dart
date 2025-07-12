/// Tests for FirestoreService
/// 
/// Comprehensive tests for Firestore database operations including
/// user management, job queries, local union data, and batch operations.

import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import '../test_helpers/test_helpers.dart';
import '../test_helpers/mock_services.dart';

void main() {
  group('FirestoreService Tests', () {
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
      mockDocumentSnapshot = MockFactory.createMockDocumentSnapshot();
      mockQuerySnapshot = MockFactory.createMockQuerySnapshot();

      // Setup collection references
      when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
      when(() => mockFirestore.collection('jobs')).thenReturn(mockJobsCollection);
      when(() => mockFirestore.collection('locals')).thenReturn(mockLocalsCollection);

      // Create service with mocked Firestore
      firestoreService = FirestoreService();

      // Register fallback values
      registerFallbackValue(<String, dynamic>{});
      registerFallbackValue(FieldValue.serverTimestamp());
    });

    group('Collection Access', () {
      test('provides access to users collection', () {
        when(() => mockFirestore.collection('users')).thenReturn(mockUsersCollection);
        
        // This would require dependency injection in the actual implementation
        expect(firestoreService.usersCollection, isA<CollectionReference>());
      });

      test('provides access to jobs collection', () {
        when(() => mockFirestore.collection('jobs')).thenReturn(mockJobsCollection);
        
        expect(firestoreService.jobsCollection, isA<CollectionReference>());
      });

      test('provides access to locals collection', () {
        when(() => mockFirestore.collection('locals')).thenReturn(mockLocalsCollection);
        
        expect(firestoreService.localsCollection, isA<CollectionReference>());
      });
    });

    group('User Operations', () {
      group('Create User', () {
        test('creates user successfully with valid data', () async {
          final userData = TestDataGenerators.mockUserData();
          
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.set(any())).thenAnswer((_) async => {});

          await firestoreService.createUser(
            uid: 'test_uid',
            userData: userData,
          );

          verify(() => mockUsersCollection.doc('test_uid')).called(1);
          verify(() => mockDocumentReference.set(any())).called(1);
        });

        test('adds server timestamp and onboarding status on create', () async {
          final userData = TestDataGenerators.mockUserData();
          Map<String, dynamic>? capturedData;
          
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.set(any())).thenAnswer((invocation) async {
            capturedData = invocation.positionalArguments[0] as Map<String, dynamic>;
          });

          await firestoreService.createUser(
            uid: 'test_uid',
            userData: userData,
          );

          expect(capturedData!['createdTime'], isA<FieldValue>());
          expect(capturedData!['onboardingStatus'], equals('pending'));
        });

        test('handles Firestore errors during user creation', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.set(any()))
              .thenThrow(FirebaseException(plugin: 'firestore', code: 'permission-denied'));

          expect(
            () => firestoreService.createUser(
              uid: 'test_uid',
              userData: TestDataGenerators.mockUserData(),
            ),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error creating user'),
            )),
          );
        });
      });

      group('Create User Profile', () {
        test('creates user profile successfully', () async {
          final userData = TestDataGenerators.mockUserData();
          
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.set(any())).thenAnswer((_) async => {});

          await firestoreService.createUserProfile(
            userId: 'test_uid',
            data: userData,
          );

          verify(() => mockUsersCollection.doc('test_uid')).called(1);
          verify(() => mockDocumentReference.set(userData)).called(1);
        });

        test('handles profile creation errors', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.set(any()))
              .thenThrow(Exception('Network error'));

          expect(
            () => firestoreService.createUserProfile(
              userId: 'test_uid',
              data: TestDataGenerators.mockUserData(),
            ),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error creating user profile'),
            )),
          );
        });
      });

      group('User Profile Exists', () {
        test('returns true when user profile exists', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenAnswer((_) async => 
            MockFactory.createMockDocumentSnapshot(exists: true)
          );

          final exists = await firestoreService.userProfileExists('test_uid');

          expect(exists, isTrue);
          verify(() => mockUsersCollection.doc('test_uid')).called(1);
        });

        test('returns false when user profile does not exist', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenAnswer((_) async => 
            MockFactory.createMockDocumentSnapshot(exists: false)
          );

          final exists = await firestoreService.userProfileExists('test_uid');

          expect(exists, isFalse);
        });

        test('handles errors when checking user existence', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenThrow(Exception('Network error'));

          expect(
            () => firestoreService.userProfileExists('test_uid'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error checking user profile'),
            )),
          );
        });
      });

      group('Get User', () {
        test('retrieves user successfully', () async {
          final mockDoc = MockFactory.createMockDocumentSnapshot(
            data: TestDataGenerators.mockUserData(),
          );
          
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenAnswer((_) async => mockDoc);

          final result = await firestoreService.getUser('test_uid');

          expect(result, equals(mockDoc));
          verify(() => mockUsersCollection.doc('test_uid')).called(1);
        });

        test('handles errors when getting user', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenThrow(Exception('User not found'));

          expect(
            () => firestoreService.getUser('test_uid'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error getting user'),
            )),
          );
        });
      });

      group('Update User', () {
        test('updates user successfully', () async {
          final updateData = {'firstName': 'Updated', 'lastName': 'User'};
          
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.update(any())).thenAnswer((_) async => {});

          await firestoreService.updateUser(
            uid: 'test_uid',
            data: updateData,
          );

          verify(() => mockUsersCollection.doc('test_uid')).called(1);
          verify(() => mockDocumentReference.update(updateData)).called(1);
        });

        test('handles update errors', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.update(any()))
              .thenThrow(Exception('Update failed'));

          expect(
            () => firestoreService.updateUser(
              uid: 'test_uid',
              data: {'firstName': 'Updated'},
            ),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error updating user'),
            )),
          );
        });
      });

      group('Delete User Data', () {
        test('deletes user data successfully', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.delete()).thenAnswer((_) async => {});

          await firestoreService.deleteUserData('test_uid');

          verify(() => mockUsersCollection.doc('test_uid')).called(1);
          verify(() => mockDocumentReference.delete()).called(1);
        });

        test('handles deletion errors', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.delete()).thenThrow(Exception('Delete failed'));

          expect(
            () => firestoreService.deleteUserData('test_uid'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error deleting user data'),
            )),
          );
        });
      });

      group('Update User Email', () {
        test('updates user email successfully', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.update(any())).thenAnswer((_) async => {});

          await firestoreService.updateUserEmail('test_uid', 'newemail@example.com');

          verify(() => mockDocumentReference.update({'email': 'newemail@example.com'})).called(1);
        });

        test('handles email update errors', () async {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.update(any()))
              .thenThrow(Exception('Email update failed'));

          expect(
            () => firestoreService.updateUserEmail('test_uid', 'newemail@example.com'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error updating user email'),
            )),
          );
        });
      });

      group('Get User Stream', () {
        test('provides user document stream', () {
          when(() => mockUsersCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.snapshots())
              .thenAnswer((_) => Stream.value(mockDocumentSnapshot));

          final stream = firestoreService.getUserStream('test_uid');

          expect(stream, isA<Stream<DocumentSnapshot>>());
        });
      });
    });

    group('Job Operations', () {
      group('Get Jobs', () {
        test('returns jobs stream with default ordering', () {
          final mockQuery = MockQuery();
          
          when(() => mockJobsCollection.orderBy(any(), descending: any(named: 'descending')))
              .thenReturn(mockQuery);
          when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));

          final stream = firestoreService.getJobs();

          expect(stream, isA<Stream<QuerySnapshot>>());
          verify(() => mockJobsCollection.orderBy('timestamp', descending: true)).called(1);
        });

        test('applies filters correctly', () {
          final mockQuery = MockQuery();
          final mockFilteredQuery = MockQuery();
          
          when(() => mockJobsCollection.orderBy(any(), descending: any(named: 'descending')))
              .thenReturn(mockQuery);
          when(() => mockQuery.where(any(), isEqualTo: any(named: 'isEqualTo')))
              .thenReturn(mockFilteredQuery);
          when(() => mockFilteredQuery.snapshots())
              .thenAnswer((_) => Stream.value(mockQuerySnapshot));

          final filters = {
            'local': '456',
            'classification': 'Journeyman Lineman',
            'location': 'Houston, TX',
            'typeOfWork': 'Distribution',
          };

          final stream = firestoreService.getJobs(filters: filters);

          expect(stream, isA<Stream<QuerySnapshot>>());
          verify(() => mockQuery.where('local', isEqualTo: '456')).called(1);
          verify(() => mockQuery.where('classification', isEqualTo: 'Journeyman Lineman')).called(1);
        });

        test('applies limit correctly', () {
          final mockQuery = MockQuery();
          final mockLimitedQuery = MockQuery();
          
          when(() => mockJobsCollection.orderBy(any(), descending: any(named: 'descending')))
              .thenReturn(mockQuery);
          when(() => mockQuery.limit(any())).thenReturn(mockLimitedQuery);
          when(() => mockLimitedQuery.snapshots())
              .thenAnswer((_) => Stream.value(mockQuerySnapshot));

          final stream = firestoreService.getJobs(limit: 10);

          expect(stream, isA<Stream<QuerySnapshot>>());
          verify(() => mockQuery.limit(10)).called(1);
        });

        test('applies pagination correctly', () {
          final mockQuery = MockQuery();
          final mockPaginatedQuery = MockQuery();
          final startAfterDoc = MockFactory.createMockDocumentSnapshot();
          
          when(() => mockJobsCollection.orderBy(any(), descending: any(named: 'descending')))
              .thenReturn(mockQuery);
          when(() => mockQuery.startAfterDocument(any())).thenReturn(mockPaginatedQuery);
          when(() => mockPaginatedQuery.snapshots())
              .thenAnswer((_) => Stream.value(mockQuerySnapshot));

          final stream = firestoreService.getJobs(startAfter: startAfterDoc);

          expect(stream, isA<Stream<QuerySnapshot>>());
          verify(() => mockQuery.startAfterDocument(startAfterDoc)).called(1);
        });
      });

      group('Get Job', () {
        test('retrieves specific job successfully', () async {
          when(() => mockJobsCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

          final result = await firestoreService.getJob('job_123');

          expect(result, equals(mockDocumentSnapshot));
          verify(() => mockJobsCollection.doc('job_123')).called(1);
        });

        test('handles job retrieval errors', () async {
          when(() => mockJobsCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenThrow(Exception('Job not found'));

          expect(
            () => firestoreService.getJob('job_123'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error getting job'),
            )),
          );
        });
      });
    });

    group('Local Union Operations', () {
      group('Get Locals', () {
        test('returns locals stream with correct ordering', () {
          final mockQuery = MockQuery();
          
          when(() => mockLocalsCollection.orderBy(any())).thenReturn(mockQuery);
          when(() => mockQuery.snapshots()).thenAnswer((_) => Stream.value(mockQuerySnapshot));

          final stream = firestoreService.getLocals();

          expect(stream, isA<Stream<QuerySnapshot>>());
          verify(() => mockLocalsCollection.orderBy('localUnion')).called(1);
        });
      });

      group('Search Locals', () {
        test('searches locals successfully', () async {
          final mockQuery = MockQuery();
          final mockSearchQuery = MockQuery();
          
          when(() => mockLocalsCollection.where(any(), 
              isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo')))
              .thenReturn(mockQuery);
          when(() => mockQuery.where(any(), 
              isLessThanOrEqualTo: any(named: 'isLessThanOrEqualTo')))
              .thenReturn(mockSearchQuery);
          when(() => mockSearchQuery.get()).thenAnswer((_) async => mockQuerySnapshot);

          final result = await firestoreService.searchLocals('Local 123');

          expect(result, equals(mockQuerySnapshot));
          verify(() => mockLocalsCollection.where('localUnion', 
              isGreaterThanOrEqualTo: 'Local 123')).called(1);
          verify(() => mockQuery.where('localUnion', 
              isLessThanOrEqualTo: 'Local 123\uf8ff')).called(1);
        });

        test('handles search errors', () async {
          when(() => mockLocalsCollection.where(any(), 
              isGreaterThanOrEqualTo: any(named: 'isGreaterThanOrEqualTo')))
              .thenThrow(Exception('Search failed'));

          expect(
            () => firestoreService.searchLocals('Local 123'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error searching locals'),
            )),
          );
        });
      });

      group('Get Local', () {
        test('retrieves specific local successfully', () async {
          when(() => mockLocalsCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);

          final result = await firestoreService.getLocal('local_123');

          expect(result, equals(mockDocumentSnapshot));
          verify(() => mockLocalsCollection.doc('local_123')).called(1);
        });

        test('handles local retrieval errors', () async {
          when(() => mockLocalsCollection.doc(any())).thenReturn(mockDocumentReference);
          when(() => mockDocumentReference.get()).thenThrow(Exception('Local not found'));

          expect(
            () => firestoreService.getLocal('local_123'),
            throwsA(isA<Exception>().having(
              (e) => e.toString(),
              'message',
              contains('Error getting local'),
            )),
          );
        });
      });
    });

    group('Batch Operations', () {
      test('executes batch write successfully', () async {
        final mockBatch = MockWriteBatch();
        
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.set(any(), any())).thenReturn(mockBatch);
        when(() => mockBatch.update(any(), any())).thenReturn(mockBatch);
        when(() => mockBatch.delete(any())).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenAnswer((_) async => []);

        final operations = [
          BatchOperation(
            reference: mockDocumentReference,
            type: OperationType.create,
            data: {'test': 'data'},
          ),
          BatchOperation(
            reference: mockDocumentReference,
            type: OperationType.update,
            data: {'update': 'data'},
          ),
          BatchOperation(
            reference: mockDocumentReference,
            type: OperationType.delete,
          ),
        ];

        await firestoreService.batchWrite(operations);

        verify(() => mockBatch.set(mockDocumentReference, {'test': 'data'})).called(1);
        verify(() => mockBatch.update(mockDocumentReference, {'update': 'data'})).called(1);
        verify(() => mockBatch.delete(mockDocumentReference)).called(1);
        verify(() => mockBatch.commit()).called(1);
      });

      test('handles batch operation errors', () async {
        final mockBatch = MockWriteBatch();
        
        when(() => mockFirestore.batch()).thenReturn(mockBatch);
        when(() => mockBatch.commit()).thenThrow(Exception('Batch failed'));

        expect(
          () => firestoreService.batchWrite([]),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error in batch operation'),
          )),
        );
      });
    });

    group('Transaction Operations', () {
      test('executes transaction successfully', () async {
        final mockTransaction = MockTransaction();
        
        when(() => mockFirestore.runTransaction<String>(any()))
            .thenAnswer((invocation) async {
          final handler = invocation.positionalArguments[0] as Future<String> Function(Transaction);
          return await handler(mockTransaction);
        });

        final result = await firestoreService.runTransaction<String>((transaction) async {
          return 'success';
        });

        expect(result, equals('success'));
      });

      test('handles transaction errors', () async {
        when(() => mockFirestore.runTransaction<String>(any()))
            .thenThrow(Exception('Transaction failed'));

        expect(
          () => firestoreService.runTransaction<String>((transaction) async {
            return 'success';
          }),
          throwsA(isA<Exception>().having(
            (e) => e.toString(),
            'message',
            contains('Error in transaction'),
          )),
        );
      });
    });
  });
}

// Helper mock classes
class MockQuery extends Mock implements Query {}
class MockWriteBatch extends Mock implements WriteBatch {}
class MockTransaction extends Mock implements Transaction {}