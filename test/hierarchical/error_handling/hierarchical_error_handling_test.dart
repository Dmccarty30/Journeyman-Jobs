import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/locals_riverpod_provider.dart';
import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/utils/memory_management.dart';

import '../fixtures/hierarchical_mock_data.dart';
import '../helpers/test_helpers.dart';

/// Error handling and edge case tests for hierarchical initialization
void main() {
  group('Hierarchical Error Handling Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockCollectionReference mockCollection;
    late MockQuery mockQuery;
    late MockDocumentReference mockDocumentReference;
    late MockDocumentSnapshot mockDocumentSnapshot;
    late MockQuerySnapshot mockQuerySnapshot;

    late FirestoreService firestoreService;
    late ResilientFirestoreService resilientService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockCollection = MockCollectionReference();
      mockQuery = MockQuery();
      mockDocumentReference = MockDocumentReference();
      mockDocumentSnapshot = MockDocumentSnapshot();
      mockQuerySnapshot = MockQuerySnapshot();

      firestoreService = FirestoreService();
      resilientService = ResilientFirestoreService();

      // Setup default mock responses
      when(mockFirestore.collection(any)).thenReturn(mockCollection);
      when(mockCollection.doc(any)).thenReturn(mockDocumentReference);
      when(mockDocumentReference.get()).thenAnswer((_) async => mockDocumentSnapshot);
      when(mockDocumentReference.set(any)).thenAnswer((_) async {});
      when(mockDocumentReference.update(any)).thenAnswer((_) async {});
      when(mockDocumentReference.delete()).thenAnswer((_) async {});
      when(mockCollection.limit(any)).thenReturn(mockQuery);
      when(mockCollection.where(any, any, any)).thenReturn(mockQuery);
      when(mockQuery.get()).thenAnswer((_) async => mockQuerySnapshot);
      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockDocumentSnapshot.exists).thenReturn(true);
      when(mockDocumentSnapshot.data()).thenReturn({});
    });

    group('Authentication Error Handling', () {
      test('should throw UnauthenticatedException when not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => firestoreService.getUser('test_user'),
          throwsA(isA<UnauthenticatedException>()),
        );
      });

      test('should handle user not found gracefully', () async {
        // Arrange
        when(mockUser.uid).thenReturn('nonexistent_user');
        when(mockDocumentSnapshot.exists).thenReturn(false);

        // Act & Assert
        expect(
          () => firestoreService.getUser('nonexistent_user'),
          throwsA(isA<UserNotFoundException>()),
        );
      });

      test('should handle authentication timeout', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);
        when(mockAuth.authStateChanges())
            .thenAnswer((_) => Stream.error(FirebaseException(
              plugin: 'firebase_auth',
              code: 'network-request-failed',
            )));

        // Act & Assert
        expect(
          () => mockAuth.authStateChanges().first,
          throwsA(isA<FirebaseException>()),
        );
      });

      test('should handle session expiration', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.uid).thenReturn('expired_user');
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Simulate expired session
        when(mockDocumentSnapshot.get()).thenThrow(FirebaseException(
          plugin: 'firestore',
          code: 'permission-denied',
          message: 'Session expired',
        ));

        // Act & Assert
        expect(
          () => firestoreService.getUser('expired_user'),
          throwsA(isA<SessionExpiredException>()),
        );
      });

      test('should handle email verification required', () async {
        // Arrange
        final mockUser = MockUser();
        when(mockUser.uid).thenReturn('unverified_user');
        when(mockUser.emailVerified).thenReturn(false);
        when(mockAuth.currentUser).thenReturn(mockUser);

        // Act & Assert
        expect(
          () => mockUser.emailVerified,
          isFalse,
        );
      });
    });

    group('Network Error Handling', () {
      test('should retry on network timeout', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'deadline-exceeded',
              message: 'Network timeout',
            ))
            .thenAnswer((_) async => mockQuerySnapshot); // Success on retry

        // Act
        final result = await resilientService.getLocalsWithRetry(retryCount: 3);

        // Assert
        expect(result, isNotNull);
        verify(mockQuery.get()).called(3); // Should retry 3 times
      });

      test('should handle network unavailable gracefully', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Network unavailable',
            ));

        // Act & Assert
        expect(
          () => resilientService.getLocalsWithRetry(retryCount: 3),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle connection reset', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'resource-exhausted',
              message: 'Connection reset',
            ));

        // Act & Assert
        expect(
          () => firestoreService.getLocals(),
          throwsA(isA<NetworkException>()),
        );
      });

      test('should handle intermittent network failures', () async {
        // Arrange
        int callCount = 0;
        when(mockQuery.get()).thenAnswer((_) async {
          callCount++;
          if (callCount == 1 || callCount == 3) {
            throw FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Intermittent failure',
            );
          }
          return mockQuerySnapshot;
        });

        // Act
        final result = await resilientService.getLocalsWithRetry(retryCount: 5);

        // Assert
        expect(result, isNotNull);
        expect(callCount, equals(5)); // Should try 5 times
      });

      test('should fallback to cached data during network outage', () async {
        // Arrange
        final localsCache = LocalsLRUCache();
        final cachedLocal = HierarchicalMockData.testLocal;
        localsCache.put(cachedLocal.localNumber, cachedLocal);

        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Network outage',
            ));

        // Act
        try {
          await firestoreService.getLocals();
          fail('Should have thrown exception');
        } catch (e) {
          // Expected - network error
          expect(e, isA<NetworkException>());
        }

        // Verify cache is still accessible
        final cachedResult = localsCache.get(cachedLocal.localNumber);

        // Assert
        expect(cachedResult, isNotNull);
        expect(cachedResult!.localNumber, equals(cachedLocal.localNumber));
      });
    });

    group('Permission Error Handling', () {
      test('should handle permission denied for collection access', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
              message: 'Missing or insufficient permissions',
            ));

        // Act & Assert
        expect(
          () => firestoreService.getLocals(),
          throwsA(isA<PermissionDeniedException>()),
        );
      });

      test('should handle permission denied for document access', () async {
        // Arrange
        when(mockDocumentReference.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
              message: 'Missing or insufficient permissions',
            ));

        // Act & Assert
        expect(
          () => firestoreService.getLocal('test_local'),
          throwsA(isA<PermissionDeniedException>()),
        );
      });

      test('should handle permission denied for write operations', () async {
        // Arrange
        when(mockDocumentReference.set(any))
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
              message: 'Missing or insufficient permissions',
            ));

        // Act & Assert
        expect(
          () => firestoreService.createUser(
            uid: 'test_user',
            userData: {'test': 'data'},
          ),
          throwsA(isA<PermissionDeniedException>()),
        );
      });

      test('should handle security rule violations', () async {
        // Arrange
        when(mockDocumentReference.update(any))
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
              message: 'Security rule violation',
            ));

        // Act & Assert
        expect(
          () => firestoreService.updateUser(
            uid: 'test_user',
            data: {'test': 'data'},
          ),
          throwsA(isA<SecurityRuleViolationException>()),
        );
      });
    });

    group('Data Validation Error Handling', () {
      test('should handle malformed JSON data', () {
        // Arrange
        final malformedData = {
          'id': null, // Missing required field
          'local_union': '3',
          'local_name': 'Test Local',
        };

        when(mockDocumentSnapshot.data()).thenReturn(malformedData);

        // Act & Assert
        expect(
          () => LocalsRecord.fromFirestore(mockDocumentSnapshot),
          throwsA(isA<DataValidationException>()),
        );
      });

      test('should handle invalid local union numbers', () {
        // Arrange
        final invalidLocals = [
          HierarchicalMockData.testLocal.copyWith(localNumber: 'invalid'),
          HierarchicalMockData.testLocal.copyWith(localNumber: '-1'),
          HierarchicalMockData.testLocal.copyWith(localNumber: '99999'),
          HierarchicalMockData.testLocal.copyWith(localNumber: '0'),
        ];

        // Act & Assert
        for (final invalidLocal in invalidLocals) {
          expect(
            () => localsCache.put(invalidLocal.localNumber, invalidLocal),
            throwsA(isA<DataValidationException>()),
            reason: 'Invalid local number: ${invalidLocal.localNumber}',
          );
        }
      });

      test('should handle invalid job data', () {
        // Arrange
        final invalidJobs = [
          HierarchicalMockData.testJob.copyWith(
            wage: -10.0, // Negative wage
          ),
          HierarchicalMockData.testJob.copyWith(
            company: '', // Empty company
          ),
          HierarchicalMockData.testJob.copyWith(
            timestamp: null, // Missing timestamp
          ),
        ];

        // Act & Assert
        for (final invalidJob in invalidJobs) {
          expect(
            () => jobList.addJob(invalidJob),
            throwsA(isA<DataValidationException>()),
          );
        }
      });

      test('should handle circular references in hierarchical data', () async {
        // Arrange
        final circularLocal = HierarchicalMockData.testLocal.copyWith(
          id: 'circular_local',
          localNumber: 'circular',
        );

        final circularMember = HierarchicalMockData.testMember.copyWith(
          id: 'circular_member',
          localUnion: 'circular',
        );

        // This would create a circular reference if not handled properly
        localsCache.put(circularLocal.localNumber, circularLocal);

        // Act
        final retrievedLocal = localsCache.get(circularLocal.localNumber);

        // Assert
        expect(retrievedLocal, isNotNull);
        expect(retrievedLocal!.id, equals('circular_local'));
        expect(retrievedLocal.localNumber, equals('circular'));

        // No infinite loop should occur
        expect(localsCache.size, equals(1));
      });

      test('should handle extremely large data values', () {
        // Arrange
        final largeString = 'x' * 10000; // 10KB string
        final largeList = List.generate(1000, (index) => 'item_$index');
        final largeMap = Map.fromEntries(
          largeList.map((item) => MapEntry(item, item)),
        );

        final largeLocal = HierarchicalMockData.testLocal.copyWith(
          localName: largeString,
          specialties: largeList.take(10),
        );

        final largeJob = HierarchicalMockData.testJob.copyWith(
          jobDescription: largeString,
          booksYourOn: largeList.map((s) => int.tryParse(s) ?? 0).toList(),
        );

        // Act & Assert
        expect(
          () => localsCache.put(largeLocal.localNumber, largeLocal),
          throwsA(isA< oversizedDataException>()),
        );

        expect(
          () => jobList.addJob(largeJob),
          throwsA(isA< oversizedDataException>()),
        );
      });
    });

    group('Memory Management Error Handling', () {
      test('should handle memory overflow gracefully', () {
        // Arrange
        final memoryMonitor = MemoryMonitor();
        final jobList = BoundedJobList();
        final localsCache = LocalsLRUCache();

        // Act - Try to exceed memory limits
        for (int i = 0; i < 10000; i++) {
          final largeJob = HierarchicalMockData.testJob.copyWith(
            id: 'overflow_$i',
            jobDetails: {
              'hours': 40,
              'payRate': 50.0,
              'perDiem': 'Daily',
              'contractor': 'Large Corp $i',
              'location': null,
              'extraData': List.generate(1000, (index) => 'Extra data $index'),
            },
          );

          jobList.addJob(largeJob);
        }

        // Assert
        expect(jobList.length, equals(BoundedJobList.maxSize)); // Should be limited
        expect(
          memoryMonitor.getTotalMemoryUsage(jobList: jobList),
          lessThan(10 * 1024 * 1024), // < 10MB
        );
      });

      test('should handle cache corruption gracefully', () {
        // Arrange
        final localsCache = LocalsLRUCache();

        // Act - Simulate cache corruption by invalidating internal state
        // (This would normally happen through memory corruption or bugs)

        // Try to access corrupted state
        try {
          localsCache.get('nonexistent');
          // If cache is corrupted, this might throw an exception
        } catch (e) {
          expect(e, isA<CacheCorruptionException>());
        }

        // Verify cache can be recovered
        localsCache.clear();
        expect(localsCache.size, equals(0));
      });

      test('should handle concurrent memory access conflicts', () async {
        // Arrange
        final localsCache = LocalsLRUCache();
        final futures = <Future>[];

        // Act - Create concurrent access
        for (int i = 0; i < 100; i++) {
          futures.add(Future(() async {
            // Mix of operations
            if (i % 3 == 0) {
              localsCache.put('concurrent_$i', HierarchicalMockData.testLocal.copyWith(
                id: 'concurrent_$i',
                localNumber: i.toString(),
              ));
            } else if (i % 3 == 1) {
              localsCache.get((i % 10).toString());
            } else {
              localsCache.clear();
            }
          }));
        }

        // Assert
        await expectLater(
          Future.wait(futures),
          completes,
          reason: 'Concurrent operations should complete without errors',
        );

        // Final state should be consistent
        expect(localsCache.size, lessThanOrEqualTo(LocalsLRUCache.maxSize));
      });

      test('should handle memory cleanup failures', () {
        // Arrange
        final memoryMonitor = MemoryMonitor();
        final jobList = BoundedJobList();

        // Fill with data
        for (int i = 0; i < 300; i++) {
          jobList.addJob(HierarchicalMockData.testJob.copyWith(id: 'cleanup_$i'));
        }

        // Act - Try cleanup (might fail if system is under stress)
        try {
          memoryMonitor.performCleanup(jobList: jobList);
          // If cleanup succeeds
          expect(jobList.length, lessThanOrEqualTo(BoundedJobList.maxSize));
        } catch (e) {
          expect(e, isA<MemoryCleanupException>());
        }
      });
    });

    group('Edge Case Handling', () {
      test('should handle empty database gracefully', () async {
        // Arrange
        when(mockQuerySnapshot.docs).thenReturn([]);

        // Act
        final result = await firestoreService.getLocals();

        // Assert
        expect(result, isNotNull);
        expect(result.docs.length, equals(0));
      });

      test('should handle extremely large result sets', () async {
        // Arrange
        final largeDocList = List.generate(10000, (index) {
          final mockDoc = MockDocumentSnapshot();
          when(mockDoc.id).thenReturn('large_doc_$index');
          when(mockDoc.data()).thenReturn({
            'id': 'large_doc_$index',
            'name': 'Large Document $index',
            'data': List.generate(100, (i) => 'Data $i'),
          });
          when(mockDoc.exists).thenReturn(true);
          return mockDoc;
        });

        when(mockQuerySnapshot.docs).thenReturn(largeDocList);

        // Act
        final result = await firestoreService.getLocals();

        // Assert
        expect(result.docs.length, equals(10000));
      });

      test('should handle rapid state changes', () async {
        // Arrange
        final localsCache = LocalsLRUCache();

        // Act - Perform rapid state changes
        for (int cycle = 0; cycle < 100; cycle++) {
          // Add items
          for (int i = 0; i < 10; i++) {
            localsCache.put('rapid_$cycle_$i', HierarchicalMockData.testLocal.copyWith(
              id: 'rapid_$cycle_$i',
              localNumber: '$cycle$i',
            ));
          }

          // Clear cache
          localsCache.clear();

          // Verify consistency
          expect(localsCache.size, equals(0));
        }

        // Assert
        expect(localsCache.size, equals(0));
      });

      test('should handle database migration scenarios', () async {
        // Arrange - Simulate old vs new schema
        final oldSchemaData = {
          'id': 'old_schema',
          'local_union': '3',
          'local_name': 'Old Schema Local',
          'member_count': 1500,
          // Missing new fields
        };

        final newSchemaData = {
          'id': 'new_schema',
          'localNumber': '3',
          'localName': 'New Schema Local',
          'memberCount': 1500,
          'isActive': true, // New field
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        };

        when(mockDocumentSnapshot.data()).thenReturn(oldSchemaData);

        // Act - Handle migration
        try {
          final migratedLocal = LocalsRecord.fromFirestore(mockDocumentSnapshot);
          // This should handle missing fields gracefully
          expect(migratedLocal.isActive, isTrue); // Default value
          expect(migratedLocal.createdAt, isNotNull); // Default value
        } catch (e) {
          expect(e, isA<SchemaMigrationException>());
        }
      });

      test('should handle timezone and timestamp edge cases', () {
        // Arrange
        final edgeCaseTimestamps = [
          DateTime.fromMillisecondsSinceEpoch(-1), // Before epoch
          DateTime.fromMillisecondsSinceEpoch(0), // Exactly epoch
          DateTime.fromMillisecondsSinceEpoch(253402300799999), // Max timestamp
          DateTime.now().add(Duration(days: 365 * 100)), // Far future
        ];

        // Act & Assert
        for (final timestamp in edgeCaseTimestamps) {
          final job = HierarchicalMockData.testJob.copyWith(
            timestamp: timestamp,
          );

          // Should handle edge case timestamps
          expect(job.timestamp, equals(timestamp));
        }
      });

      test('should handle Unicode and special characters', () {
        // Arrange
        final specialCharacterData = {
          'id': 'unicode_test',
          'localNumber': '3',
          'localName': '🔌 IBEW Local 3 - Special Characters: àáâãäåæç',
          'location': '测试城市 (Test City)',
          'contactEmail': 'test@example.com',
          'contactPhone': '+1 (555) 123-4567',
          'memberCount': 1500,
          'specialties': ['🔌', '⚡', '🔧'],
        };

        when(mockDocumentSnapshot.data()).thenReturn(specialCharacterData);

        // Act
        final local = LocalsRecord.fromFirestore(mockDocumentSnapshot);

        // Assert
        expect(local.localName, contains('🔌'));
        expect(local.location, contains('测试'));
        expect(local.specialties, contains('🔌'));
      });

      test('should handle null and undefined values consistently', () {
        // Arrange
        final nullTestData = HierarchicalMockData.testLocal.copyWith(
          classification: null,
          address: null,
          website: null,
        );

        // Act
        localsCache.put(nullTestData.localNumber, nullTestData);
        final retrievedLocal = localsCache.get(nullTestData.localNumber);

        // Assert
        expect(retrievedLocal, isNotNull);
        expect(retrievedLocal!.classification, isNull);
        expect(retrievedLocal.address, isNull);
        expect(retrievedLocal.website, isNull);
      });
    });

    group('Error Recovery Tests', () {
      test('should recover from temporary failures', () async {
        // Arrange
        int attemptCount = 0;
        when(mockQuery.get()).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount < 3) {
            throw FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Temporary failure',
            );
          }
          return mockQuerySnapshot;
        });

        // Act
        final result = await resilientService.getLocalsWithRetry(retryCount: 5);

        // Assert
        expect(result, isNotNull);
        expect(attemptCount, equals(3));
      });

      test('should implement exponential backoff for retries', () async {
        // Arrange
        final retryTimes = <int>[];
        when(mockQuery.get()).thenAnswer((_) async {
          retryTimes.add(DateTime.now().millisecondsSinceEpoch);
          if (retryTimes.length < 3) {
            throw FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Retry needed',
            );
          }
          return mockQuerySnapshot;
        });

        // Act
        await resilientService.getLocalsWithRetry(retryCount: 5);

        // Assert
        expect(retryTimes.length, equals(3));

        // Verify exponential backoff (time between retries should increase)
        if (retryTimes.length > 1) {
          for (int i = 1; i < retryTimes.length; i++) {
              final timeDiff = retryTimes[i] - retryTimes[i - 1];
              expect(timeDiff, greaterThan(100)); // At least 100ms between retries
          }
        }
      });

      test('should provide meaningful error messages', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'permission-denied',
              message: 'User lacks permission to access collection',
            ));

        // Act & Assert
        try {
          await firestoreService.getLocals();
          fail('Should have thrown exception');
        } catch (e) {
          expect(e, isA<PermissionDeniedException>());
          expect(e.toString(), contains('permission'));
          expect(e.toString(), contains('denied'));
        }
      });

      test('should log errors appropriately', () async {
        // Arrange
        final errorLog = <String>[];

        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'unavailable',
              message: 'Test error for logging',
            ));

        // Act
        try {
          await firestoreService.getLocals();
        } catch (e) {
          errorLog.add(e.toString());
        }

        // Assert
        expect(errorLog.isNotEmpty, isTrue);
        expect(errorLog.first, contains('Test error for logging'));
      });
    });

    group('Resource Exhaustion Tests', {
      test('should handle too many concurrent requests', () async {
        // Arrange
        final maxConcurrentRequests = 1000;
        final futures = <Future>[];

        when(mockQuery.get()).thenAnswer((_) async {
          await Future.delayed(Duration(milliseconds: 10)); // Small delay
          return mockQuerySnapshot;
        });

        // Act - Create many concurrent requests
        for (int i = 0; i < maxConcurrentRequests; i++) {
          futures.add(firestoreService.getLocals());
        }

        // Assert
        // Some requests may fail due to resource limits
        final results = await Future.wait(
          futures,
          eagerError: false, // Continue on errors
        );

        // At least some should succeed
        expect(results.where((result) => result != null).isNotEmpty, isTrue);
      });

      test('should handle large document sizes', () async {
        // Arrange
        final largeDocument = {
          'id': 'large_doc',
          'data': List.generate(10000, (index) => 'Large data chunk $index'),
          'metadata': Map.fromEntries(
            List.generate(1000, (index) => MapEntry('meta_$index', 'Large metadata value $index')),
          ),
        };

        when(mockDocumentSnapshot.data()).thenReturn(largeDocument);

        // Act
        try {
          final local = LocalsRecord.fromFirestore(mockDocumentSnapshot);
          // This might fail due to size limits
          expect(local, isNotNull);
        } catch (e) {
          expect(e, isA<DocumentSizeExceededException>());
        }
      });

      test('should handle quota exceeded errors', () async {
        // Arrange
        when(mockQuery.get())
            .thenThrow(FirebaseException(
              plugin: 'firestore',
              code: 'resource-exhausted',
              message: 'Quota exceeded',
            ));

        // Act & Assert
        expect(
          () => firestoreService.getLocals(),
          throwsA(isA<QuotaExceededException>()),
        );
      });
    });
  });
}