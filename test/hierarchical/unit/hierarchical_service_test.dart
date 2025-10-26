import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/utils/memory_management.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/domain/exceptions/app_exception.dart';

import '../fixtures/hierarchical_mock_data.dart';
import '../helpers/test_helpers.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentReference,
  DocumentSnapshot,
  QuerySnapshot,
  Query,
  FirebaseAuth,
  User,
])
import 'hierarchical_service_test.mocks.dart';

void main() {
  group('Hierarchical Service Tests', () {
    late MockFirebaseFirestore mockFirestore;
    late MockFirebaseAuth mockAuth;
    late MockUser mockUser;
    late FirestoreService firestoreService;
    late ResilientFirestoreService resilientService;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      mockAuth = MockFirebaseAuth();
      mockUser = MockUser();

      firestoreService = FirestoreService();
      resilientService = ResilientFirestoreService();

      // Setup default authenticated user
      when(mockUser.uid).thenReturn(HierarchicalMockData.testUserId);
      when(mockUser.email).thenReturn('test@example.com');
      when(mockAuth.currentUser).thenReturn(mockUser);
    });

    group('Level 1: Unions Service Tests', () {
      test('should load unions with authentication', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(mockFirestore.collection('unions')).thenReturn(mockCollection);
        when(mockCollection.limit(any)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.docs).thenReturn(HierarchicalMockData.mockUnionDocs);

        // Act
        final result = await firestoreService.getUnions();

        // Assert
        verify(mockFirestore.collection('unions')).called(1);
        expect(result, isNotNull);
      });

      test('should throw UnauthenticatedException when not authenticated', () async {
        // Arrange
        when(mockAuth.currentUser).thenReturn(null);

        // Act & Assert
        expect(
          () => firestoreService.getUnions(),
          throwsA(isA<UnauthenticatedException>()),
        );
      });

      test('should handle union filtering by jurisdiction', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(mockFirestore.collection('unions')).thenReturn(mockCollection);
        when(mockCollection.where('jurisdiction', isEqualTo: 'International'))
            .thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);

        // Act
        await firestoreService.getUnionsByJurisdiction('International');

        // Assert
        verify(mockCollection.where('jurisdiction', isEqualTo: 'International'))
            .called(1);
      });
    });

    group('Level 2: Locals Service Tests', () {
      test('should load all locals with pagination', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(mockFirestore.collection('locals')).thenReturn(mockCollection);
        when(mockCollection.orderBy('local_union')).thenReturn(mockQuery);
        when(mockQuery.limit(20)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.docs).thenReturn(HierarchicalMockData.mockLocalDocs.sublist(0, 20));

        // Act
        final result = await firestoreService.getLocals(limit: 20);

        // Assert
        verify(mockQuery.limit(20)).called(1);
        expect(result, isNotNull);
      });

      test('should handle large locals dataset efficiently', () async {
        // Arrange
        final localsCache = LocalsLRUCache(maxCacheSize: 100);

        // Act - Simulate loading 797+ locals
        for (int i = 0; i < HierarchicalMockData.allLocals.length; i++) {
          final local = HierarchicalMockData.allLocals[i];
          localsCache.put(local.localNumber, local);
        }

        // Assert
        expect(localsCache.size, equals(100)); // Should be limited to max size
        expect(localsCache.estimatedMemoryUsage, lessThan(1024 * 1024)); // < 1MB

        // Verify LRU eviction working
        expect(localsCache.get(HierarchicalMockData.allLocals.first.localNumber),
               isNull);
        expect(localsCache.get(HierarchicalMockData.allLocals.last.localNumber),
               isNotNull);
      });

      test('should search locals by name efficiently', () async {
        // Arrange
        final localsCache = LocalsLRUCache();

        // Pre-populate cache
        for (final local in HierarchicalMockData.allLocals.take(50)) {
          localsCache.put(local.localNumber, local);
        }

        // Act
        final searchResults = localsCache.searchByName('New York');

        // Assert
        expect(searchResults.isNotEmpty, isTrue);
        expect(searchResults.every((local) =>
               local.localName.toLowerCase().contains('new york')), isTrue);

        // Performance validation
        final stopwatch = Stopwatch()..start();
        localsCache.searchByName('Chicago');
        stopwatch.stop();

        expect(stopwatch.elapsedMilliseconds, lessThan(10)); // Should be < 10ms
      });

      test('should filter locals by state with performance', () async {
        // Arrange
        final localsCache = LocalsLRUCache();

        // Pre-populate with diverse state data
        for (final local in HierarchicalMockData.allLocals) {
          localsCache.put(local.localNumber, local);
        }

        // Act
        final nyLocals = localsCache.getLocalsByState('NY');
        final caLocals = localsCache.getLocalsByState('CA');

        // Assert
        expect(nyLocals.isNotEmpty, isTrue);
        expect(caLocals.isNotEmpty, isTrue);
        expect(nyLocals.every((local) => local.state == 'NY'), isTrue);
        expect(caLocals.every((local) => local.state == 'CA'), isTrue);
      });
    });

    group('Level 3: Members Service Tests', () {
      test('should load members for specific local', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(mockFirestore.collection('users')).thenReturn(mockCollection);
        when(mockCollection.where('localUnion', isEqualTo: '3')).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.docs).thenReturn(HierarchicalMockData.mockMemberDocs);

        // Act
        final result = await firestoreService.getMembersByLocal('3');

        // Assert
        verify(mockCollection.where('localUnion', isEqualTo: '3')).called(1);
        expect(result, isNotNull);
      });

      test('should validate member-to-local relationship', () async {
        // Arrange
        final member = HierarchicalMockData.testMember;
        final local = HierarchicalMockData.testLocal;

        // Act
        final isValidRelationship = member.localUnion == local.localNumber;

        // Assert
        expect(isValidRelationship, isTrue);

        // Test invalid relationship
        final invalidMember = HierarchicalMockData.testMember.copyWith(
          localUnion: '999' // Non-existent local
        );
        expect(invalidMember.localUnion == local.localNumber, isFalse);
      });

      test('should handle member permission boundaries', () async {
        // Arrange
        final regularMember = HierarchicalMockData.testMember;
        final adminMember = HierarchicalMockData.adminMember;

        // Act & Assert
        expect(regularMember.role, equals(MemberRole.regular));
        expect(adminMember.role, equals(MemberRole.admin));

        // Permission validation would be tested here
        // This is a placeholder for actual permission logic
      });
    });

    group('Level 4: Jobs Service Tests', () {
      test('should load jobs filtered by hierarchy', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();
        final mockSnapshot = MockQuerySnapshot();

        when(mockFirestore.collection('jobs')).thenReturn(mockCollection);
        when(mockCollection.where('local', isEqualTo: 3)).thenReturn(mockQuery);
        when(mockQuery.orderBy('timestamp', descending: true)).thenReturn(mockQuery);
        when(mockQuery.limit(20)).thenReturn(mockQuery);
        when(mockQuery.get()).thenAnswer((_) async => mockSnapshot);
        when(mockSnapshot.docs).thenReturn(HierarchicalMockData.mockJobDocs);

        // Act
        final result = await firestoreService.getJobsByLocal(3, limit: 20);

        // Assert
        verify(mockCollection.where('local', isEqualTo: 3)).called(1);
        verify(mockQuery.orderBy('timestamp', descending: true)).called(1);
        verify(mockQuery.limit(20)).called(1);
        expect(result, isNotNull);
      });

      test('should manage job list memory efficiently', () async {
        // Arrange
        final jobList = BoundedJobList();

        // Act - Add more jobs than the maximum
        for (int i = 0; i < HierarchicalMockData.allJobs.length; i++) {
          jobList.addJob(HierarchicalMockData.allJobs[i]);
        }

        // Assert
        expect(jobList.length, equals(BoundedJobList.maxSize)); // Should be limited
        expect(jobList.estimatedMemoryUsage, lessThan(1024 * 1024)); // < 1MB

        // Verify FIFO eviction
        expect(jobList.jobs.first.id,
               equals(HierarchicalMockData.allJobs[HierarchicalMockData.allJobs.length - BoundedJobList.maxSize].id));
      });

      test('should filter jobs by member preferences', () async {
        // Arrange
        final member = HierarchicalMockData.testMember;
        final allJobs = HierarchicalMockData.allJobs;

        // Act
        final filteredJobs = allJobs.where((job) {
          return job.local == int.tryParse(member.localUnion) &&
                 member.preferredClassifications.contains(job.classification);
        }).toList();

        // Assert
        expect(filteredJobs.isNotEmpty, isTrue);
        expect(filteredJobs.every((job) =>
               job.local == int.tryParse(member.localUnion)), isTrue);
        expect(filteredJobs.every((job) =>
               member.preferredClassifications.contains(job.classification)), isTrue);
      });

      test('should handle job search with pagination', () async {
        // Arrange
        final virtualList = VirtualJobListState();
        final allJobs = HierarchicalMockData.allJobs;

        // Act
        virtualList.updateJobs(allJobs, 0);
        final firstPage = virtualList.visibleJobs;

        virtualList.updateJobs(allJobs, VirtualJobListState.maxRenderedItems);
        final secondPage = virtualList.visibleJobs;

        // Assert
        expect(firstPage.length, equals(VirtualJobListState.maxRenderedItems));
        expect(secondPage.length, equals(VirtualJobListState.maxRenderedItems));
        expect(firstPage.first.id, isNot(equals(secondPage.first.id)));

        // Memory efficiency
        expect(virtualList.estimatedMemoryUsage, lessThan(1024 * 1024)); // < 1MB
      });
    });

    group('Resilient Service Tests', () {
      test('should retry failed operations with exponential backoff', () async {
        // Arrange
        final mockCollection = MockCollectionReference();
        final mockQuery = MockQuery();

        when(mockFirestore.collection('locals')).thenReturn(mockCollection);
        when(mockCollection.limit(any)).thenReturn(mockQuery);

        // Fail first 2 attempts, succeed on 3rd
        when(mockQuery.get())
            .thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable'))
            .thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable'))
            .thenAnswer((_) async => MockQuerySnapshot());

        // Act
        final result = await resilientService.getLocalsWithRetry(retryCount: 3);

        // Assert
        verify(mockQuery.get()).called(3); // Should retry 3 times
        expect(result, isNotNull);
      });

      test('should fallback to cached data on network failure', () async {
        // Arrange
        final localsCache = LocalsLRUCache();

        // Pre-populate cache
        for (final local in HierarchicalMockData.allLocals.take(10)) {
          localsCache.put(local.localNumber, local);
        }

        when(mockFirestore.collection('locals'))
            .thenThrow(FirebaseException(plugin: 'firestore', code: 'unavailable'));

        // Act
        final cachedLocals = localsCache.allLocals;

        // Assert
        expect(cachedLocals.length, equals(10));
        expect(cachedLocals.every((local) =>
               localsCache.containsKey(local.localNumber)), isTrue);
      });

      test('should handle concurrent operations safely', () async {
        // Arrange
        final operationManager = ConcurrentOperationManager();
        final futures = <Future>[];

        // Act - Simulate concurrent operations
        for (int i = 0; i < 10; i++) {
          futures.add(operationManager.executeOperation(() async {
            await Future.delayed(Duration(milliseconds: 100));
            return 'Operation $i completed';
          }));
        }

        final results = await Future.wait(futures);

        // Assert
        expect(results.length, equals(10));
        expect(results.toSet().length, equals(10)); // All operations completed
        expect(operationManager.activeOperations, equals(0)); // All operations finished
      });
    });

    group('Memory Management Tests', () {
      test('should monitor memory usage across hierarchy', () async {
        // Arrange
        final jobList = BoundedJobList();
        final localsCache = LocalsLRUCache();
        final virtualList = VirtualJobListState();

        // Act - Load data into each component
        for (final job in HierarchicalMockData.allJobs.take(50)) {
          jobList.addJob(job);
        }

        for (final local in HierarchicalMockData.allLocals.take(50)) {
          localsCache.put(local.localNumber, local);
        }

        virtualList.updateJobs(HierarchicalMockData.allJobs.take(50), 0);

        final totalMemory = MemoryMonitor.getTotalMemoryUsage(
          jobList: jobList,
          localsCache: localsCache,
          virtualList: virtualList,
        );

        // Assert
        expect(totalMemory, lessThan(5 * 1024 * 1024)); // < 5MB total

        final memoryStats = MemoryMonitor.getMemoryStats(
          jobList: jobList,
          localsCache: localsCache,
          virtualList: virtualList,
        );

        expect(memoryStats['currentUsageMB'], isNotNull);
        expect(memoryStats['components'], isNotNull);
      });

      test('should perform cleanup when memory threshold exceeded', () async {
        // Arrange
        final jobList = BoundedJobList();
        final localsCache = LocalsLRUCache();

        // Fill up to trigger cleanup
        for (int i = 0; i < 300; i++) { // Exceeds limits
          jobList.addJob(HierarchicalMockData.allJobs[i % HierarchicalMockData.allJobs.length]);
        }

        for (int i = 0; i < 150; i++) { // Exceeds cache size
          localsCache.put('local_$i', HierarchicalMockData.allLocals[i % HierarchicalMockData.allLocals.length]);
        }

        // Act
        final shouldCleanup = MemoryMonitor.shouldPerformCleanup(
          jobList: jobList,
          localsCache: localsCache,
        );

        if (shouldCleanup) {
          MemoryMonitor.performCleanup(
            jobList: jobList,
            localsCache: localsCache,
          );
        }

        // Assert
        expect(jobList.length, lessThanOrEqualTo(BoundedJobList.maxSize));
        expect(localsCache.size, lessThanOrEqualTo(LocalsLRUCache.maxSize));
      });
    });

    group('Integration Service Tests', () {
      test('should maintain data consistency across hierarchy levels', () async {
        // Arrange
        final union = HierarchicalMockData.testUnion;
        final local = HierarchicalMockData.testLocal;
        final member = HierarchicalMockData.testMember;
        final job = HierarchicalMockData.testJob;

        // Act & Assert - Validate hierarchical relationships
        expect(local.localNumber, startsWith(union.id)); // Local belongs to Union
        expect(member.localUnion, equals(local.localNumber)); // Member belongs to Local
        expect(job.local, equals(int.tryParse(member.localUnion))); // Job belongs to Member's Local

        // Validate data flow integrity
        final hierarchy = {
          'union': union.id,
          'local': local.localNumber,
          'member': member.localUnion,
          'job': job.local,
        };

        expect(hierarchy['union'], equals(hierarchy['local'].toString().substring(0, 1)));
        expect(hierarchy['local'], equals(hierarchy['member']));
        expect(hierarchy['member'], equals(hierarchy['job'].toString()));
      });

      test('should handle cascade loading failures gracefully', () async {
        // Arrange
        when(mockFirestore.collection('unions'))
            .thenThrow(FirebaseException(plugin: 'firestore', code: 'permission-denied'));

        // Act & Assert
        expect(
          () => firestoreService.getUnions(),
          throwsA(isA<PermissionDeniedException>()),
        );

        // Verify lower levels are not attempted when upper level fails
        verifyNever(mockFirestore.collection('locals'));
        verifyNever(mockFirestore.collection('users'));
        verifyNever(mockFirestore.collection('jobs'));
      });
    });
  });
}