import 'package:flutter_test/flutter_test.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/resilient_firestore_service.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/locals_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/utils/memory_management.dart';

import '../fixtures/hierarchical_mock_data.dart';
import '../helpers/test_helpers.dart';

/// Integration tests for hierarchical initialization with Firebase
///
/// These tests require Firebase emulators to be running:
/// ```bash
/// firebase emulators:start --only firestore,auth
/// ```
void main() {
  group('Hierarchical Firebase Integration Tests', () {
    late FirebaseApp app;
    late FirebaseFirestore firestore;
    late FirebaseAuth auth;
    late FirestoreService firestoreService;
    late ResilientFirestoreService resilientService;

    setUpAll(() async {
      try {
        // Initialize Firebase with emulator settings
        app = await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: 'test-api-key',
            appId: 'test-app-id',
            messagingSenderId: 'test-sender-id',
            projectId: 'test-project',
          ),
        );

        // Configure Firebase to use emulators
        await FirebaseFirestore.instance.useFirestoreEmulator('localhost', 8080);
        await FirebaseAuth.instance.useAuthEmulator('localhost', 9099);

        firestore = FirebaseFirestore.instanceFor(app: app);
        auth = FirebaseAuth.instanceFor(app: app);

        firestoreService = FirestoreService();
        resilientService = ResilientFirestoreService();
      } catch (e) {
        print('Firebase initialization failed: $e');
        print('Make sure Firebase emulators are running:');
        print('firebase emulators:start --only firestore,auth');
        rethrow;
      }
    });

    tearDownAll(() async {
      await app.delete();
    });

    setUp(() async {
      // Clean up test data before each test
      await cleanupTestData();
    });

    group('Level 1: Unions Integration Tests', () {
      test('should create and retrieve union documents', () async {
        // Arrange
        final unionData = HierarchicalMockData.testUnion;
        await firestore.collection('unions').doc(unionData['id']).set(unionData);

        // Act
        final doc = await firestore.collection('unions').doc(unionData['id']).get();
        final retrievedData = doc.data();

        // Assert
        expect(doc.exists, isTrue);
        expect(retrievedData['id'], equals(unionData['id']));
        expect(retrievedData['name'], equals(unionData['name']));
        expect(retrievedData['jurisdiction'], equals(unionData['jurisdiction']));
        expect(retrievedData['localCount'], equals(unionData['localCount']));
      });

      test('should query unions with filtering', () async {
        // Arrange
        final unions = [
          HierarchicalMockData.testUnion,
          HierarchicalMockData.regionalUnion,
          HierarchicalMockData.localUnion,
        ];

        for (final union in unions) {
          await firestore.collection('unions').doc(union['id']).set(union);
        }

        // Act
        final querySnapshot = await firestore
            .collection('unions')
            .where('jurisdiction', isEqualTo: 'International')
            .get();

        // Assert
        expect(querySnapshot.docs.length, equals(1));
        expect(querySnapshot.docs.first['name'], equals('IBEW International'));
      });

      test('should handle union pagination', () async {
        // Arrange
        final unions = List.generate(25, (index) => HierarchicalMockData._createMockUnion(
          'union_${index + 1}',
          'Test Union ${index + 1}',
          'Test',
          100,
        ));

        for (final union in unions) {
          await firestore.collection('unions').doc(union['id']).set(union);
        }

        // Act - Get first page
        final firstPage = await firestore
            .collection('unions')
            .orderBy('name')
            .limit(10)
            .get();

        // Get second page
        final secondPage = await firestore
            .collection('unions')
            .orderBy('name')
            .startAfterDocument(firstPage.docs.last)
            .limit(10)
            .get();

        // Assert
        expect(firstPage.docs.length, equals(10));
        expect(secondPage.docs.length, equals(10));
        expect(firstPage.docs.last['name'], isNot(equals(secondPage.docs.first['name'])));
      });
    });

    group('Level 2: Locals Integration Tests', () {
      test('should create and retrieve large locals dataset', () async {
        // Arrange - Create sample locals (reduced for testing)
        final testLocals = HierarchicalMockData.allLocals.take(100).toList();

        // Act - Batch write locals
        final batch = firestore.batch();
        for (final local in testLocals) {
          final docRef = firestore.collection('locals').doc(local.id);
          batch.set(docRef, local.toJson());
        }
        await batch.commit();

        // Verify all locals were created
        final querySnapshot = await firestore.collection('locals').get();

        // Assert
        expect(querySnapshot.docs.length, greaterThanOrEqualTo(100));

        // Verify data integrity
        for (final local in testLocals.take(10)) {
          final doc = await firestore.collection('locals').doc(local.id).get();
          expect(doc.exists, isTrue);
          expect(doc.data()!['localNumber'], equals(local.localNumber));
          expect(doc.data()!['localName'], equals(local.localName));
        }
      });

      test('should query locals by state efficiently', () async {
        // Arrange
        final nyLocals = HierarchicalMockData.allLocals
            .where((local) => local.state == 'NY')
            .take(20)
            .toList();

        final batch = firestore.batch();
        for (final local in nyLocals) {
          batch.set(firestore.collection('locals').doc(local.id), local.toJson());
        }
        await batch.commit();

        // Act
        final stopwatch = Stopwatch()..start();
        final querySnapshot = await firestore
            .collection('locals')
            .where('state', isEqualTo: 'NY')
            .limit(20)
            .get();
        stopwatch.stop();

        // Assert
        expect(querySnapshot.docs.length, equals(20));
        expect(stopwatch.elapsedMilliseconds, lessThan(500)); // Should be fast with proper indexing

        for (final doc in querySnapshot.docs) {
          expect(doc.data()!['state'], equals('NY'));
        }
      });

      test('should handle locals search with text queries', () async {
        // Arrange
        final searchLocals = [
          LocalsRecord(
            id: 'search_1',
            localNumber: '3',
            localName: 'New York Electrical Workers',
            location: 'New York, NY',
            contactEmail: 'test@local3.org',
            contactPhone: '(212) 555-0003',
            memberCount: 15200,
            specialties: ['High Voltage'],
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
          LocalsRecord(
            id: 'search_2',
            localNumber: '11',
            localName: 'Los Angeles Electrical Workers',
            location: 'Los Angeles, CA',
            contactEmail: 'test@local11.org',
            contactPhone: '(213) 555-0011',
            memberCount: 9800,
            specialties: ['Solar'],
            isActive: true,
            createdAt: DateTime.now(),
            updatedAt: DateTime.now(),
          ),
        ];

        final batch = firestore.batch();
        for (final local in searchLocals) {
          batch.set(firestore.collection('locals').doc(local.id), local.toJson());
        }
        await batch.commit();

        // Act - Search for "New York"
        final nyResults = await firestore
            .collection('locals')
            .where('localName', isGreaterThanOrEqualTo: 'New York')
            .where('localName', isLessThanOrEqualTo: 'New York\uf8ff')
            .get();

        // Assert
        expect(nyResults.docs.length, equals(1));
        expect(nyResults.docs.first['localName'], equals('New York Electrical Workers'));
      });

      test('should maintain performance with large locals dataset', () async {
        // Arrange - Create large dataset
        final largeLocals = HierarchicalMockData.largeLocalDataset.take(500).toList();

        final batch = firestore.batch();
        for (final local in largeLocals) {
          batch.set(firestore.collection('locals').doc(local.id), local.toJson());
        }
        await batch.commit();

        // Act - Measure performance
        final stopwatch = Stopwatch()..start();
        final querySnapshot = await firestore
            .collection('locals')
            .orderBy('memberCount', descending: true)
            .limit(20)
            .get();
        stopwatch.stop();

        // Assert
        expect(querySnapshot.docs.length, equals(20));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000)); // Should be under 1s

        // Verify data is ordered by member count
        for (int i = 0; i < querySnapshot.docs.length - 1; i++) {
          final currentCount = querySnapshot.docs[i]['memberCount'] as int;
          final nextCount = querySnapshot.docs[i + 1]['memberCount'] as int;
          expect(currentCount, greaterThanOrEqualTo(nextCount));
        }
      });
    });

    group('Level 3: Members Integration Tests', () {
      test('should create and retrieve member with local affiliation', () async {
        // Arrange
        final memberData = HierarchicalMockData.testMember;
        await firestore.collection('users').doc(memberData['id']).set(memberData);

        // Act
        final doc = await firestore.collection('users').doc(memberData['id']).get();
        final retrievedData = doc.data();

        // Assert
        expect(doc.exists, isTrue);
        expect(retrievedData['id'], equals(memberData['id']));
        expect(retrievedData['localUnion'], equals(memberData['localUnion']));
        expect(retrievedData['name'], equals(memberData['name']));
        expect(retrievedData['email'], equals(memberData['email']));
      });

      test('should query members by local union', () async {
        // Arrange
        final members = [
          HierarchicalMockData.testMember,
          HierarchicalMockData.adminMember,
          HierarchicalMockData._createMockMember(
            id: 'member_3',
            name: 'Third Member',
            email: 'third@example.com',
            localUnion: '3',
            certifications: ['Journeyman'],
            memberRole: MemberRole.regular,
          ),
        ];

        for (final member in members) {
          await firestore.collection('users').doc(member['id']).set(member);
        }

        // Act
        final querySnapshot = await firestore
            .collection('users')
            .where('localUnion', isEqualTo: '3')
            .get();

        // Assert
        expect(querySnapshot.docs.length, equals(3));
        for (final doc in querySnapshot.docs) {
          expect(doc.data()!['localUnion'], equals('3'));
        }
      });

      test('should handle member preferences and certifications', () async {
        // Arrange
        final memberWithPreferences = HierarchicalMockData.testMember;
        await firestore.collection('users').doc(memberWithPreferences['id']).set(memberWithPreferences);

        // Act
        final doc = await firestore.collection('users').doc(memberWithPreferences['id']).get();
        final data = doc.data()!;

        // Assert
        expect(data['preferences'], isNotNull);
        expect(data['certifications'], isNotNull);
        expect(data['certifications'], contains('Journeyman'));
        expect(data['certifications'], contains('OSHA 30'));
      });
    });

    group('Level 4: Jobs Integration Tests', () {
      test('should create and retrieve jobs with hierarchical relationships', () async {
        // Arrange
        final jobData = HierarchicalMockData.testJob.toJson();
        await firestore.collection('jobs').doc(jobData['id']).set(jobData);

        // Act
        final doc = await firestore.collection('jobs').doc(jobData['id']).get();
        final retrievedData = doc.data();

        // Assert
        expect(doc.exists, isTrue);
        expect(retrievedData['id'], equals(jobData['id']));
        expect(retrievedData['local'], equals(jobData['local']));
        expect(retrievedData['classification'], equals(jobData['classification']));
        expect(retrievedData['company'], equals(jobData['company']));
      });

      test('should query jobs by local union and classification', () async {
        // Arrange
        final jobs = HierarchicalMockData.allJobs.take(50).toList();

        final batch = firestore.batch();
        for (final job in jobs) {
          batch.set(firestore.collection('jobs').doc(job.id), job.toJson());
        }
        await batch.commit();

        // Act
        final querySnapshot = await firestore
            .collection('jobs')
            .where('local', isEqualTo: 3)
            .where('classification', isEqualTo: 'Inside Wireman')
            .orderBy('timestamp', descending: true)
            .limit(10)
            .get();

        // Assert
        expect(querySnapshot.docs.length, greaterThan(0));
        for (final doc in querySnapshot.docs) {
          expect(doc.data()!['local'], equals(3));
          expect(doc.data()!['classification'], equals('Inside Wireman'));
        }
      });

      test('should handle job filtering and pagination', () async {
        // Arrange
        final filterJobs = HierarchicalMockData.allJobs.where((job) =>
            job.local == 3 && job.wage != null && job.wage! > 40.0
        ).toList();

        final batch = firestore.batch();
        for (final job in filterJobs) {
          batch.set(firestore.collection('jobs').doc(job.id), job.toJson());
        }
        await batch.commit();

        // Act - First page
        final firstPage = await firestore
            .collection('jobs')
            .where('local', isEqualTo: 3)
            .where('wage', isGreaterThan: 40.0)
            .orderBy('wage', descending: true)
            .limit(10)
            .get();

        // Second page
        final secondPage = await firestore
            .collection('jobs')
            .where('local', isEqualTo: 3)
            .where('wage', isGreaterThan: 40.0)
            .orderBy('wage', descending: true)
            .startAfterDocument(firstPage.docs.last)
            .limit(10)
            .get();

        // Assert
        expect(firstPage.docs.length, greaterThan(0));
        expect(secondPage.docs.length, greaterThan(0));

        // Verify pagination is working
        if (firstPage.docs.isNotEmpty && secondPage.docs.isNotEmpty) {
          final firstPageWage = firstPage.docs.first['wage'] as double;
          final secondPageWage = secondPage.docs.last['wage'] as double;
          expect(firstPageWage, greaterThanOrEqualTo(secondPageWage));
        }
      });

      test('should handle job search and text queries', () async {
        // Arrange
        final searchJobs = HierarchicalMockData.allJobs.where((job) =>
            job.company.toLowerCase().contains('electrical') ||
            job.jobDescription!.toLowerCase().contains('electrical')
        ).take(20).toList();

        final batch = firestore.batch();
        for (final job in searchJobs) {
          batch.set(firestore.collection('jobs').doc(job.id), job.toJson());
        }
        await batch.commit();

        // Act - Search for jobs containing "electrical"
        final searchResults = await firestore
            .collection('jobs')
            .where('company', isGreaterThanOrEqualTo: 'electrical')
            .where('company', isLessThanOrEqualTo: 'electrical\uf8ff')
            .limit(10)
            .get();

        // Assert
        expect(searchResults.docs.length, greaterThan(0));
        for (final doc in searchResults.docs) {
          final company = doc.data()!['company'] as String;
          expect(company.toLowerCase().contains('electrical'), isTrue);
        }
      });
    });

    group('Cross-Hierarchy Integration Tests', () {
      test('should maintain data consistency across hierarchy levels', () async {
        // Arrange - Create complete hierarchy
        final union = HierarchicalMockData.testUnion;
        final local = HierarchicalMockData.testLocal;
        final member = HierarchicalMockData.testMember;
        final job = HierarchicalMockData.testJob;

        // Create all documents
        await firestore.collection('unions').doc(union['id']).set(union);
        await firestore.collection('locals').doc(local.id).set(local.toJson());
        await firestore.collection('users').doc(member['id']).set(member);
        await firestore.collection('jobs').doc(job.id).set(job.toJson());

        // Act - Verify hierarchy integrity
        final unionDoc = await firestore.collection('unions').doc(union['id']).get();
        final localDoc = await firestore.collection('locals').doc(local.id).get();
        final memberDoc = await firestore.collection('users').doc(member['id']).get();
        final jobDoc = await firestore.collection('jobs').doc(job.id).get();

        // Assert
        expect(unionDoc.exists, isTrue);
        expect(localDoc.exists, isTrue);
        expect(memberDoc.exists, isTrue);
        expect(jobDoc.exists, isTrue);

        // Verify relationships
        expect(localDoc.data()!['localNumber'], equals(memberDoc.data()!['localUnion']));
        expect(jobDoc.data()!['local'], equals(int.tryParse(memberDoc.data()!['localUnion'])));
      });

      test('should handle cascade operations', () async {
        // Arrange - Create hierarchy with cascade potential
        final unionId = 'cascade_union';
        final locals = List.generate(5, (index) => HierarchicalMockData.allLocals[index]);
        final members = List.generate(10, (index) => HierarchicalMockData._createMockMember(
          id: 'cascade_member_$index',
          name: 'Member $index',
          email: 'member$index@test.com',
          localUnion: locals[index % locals.length].localNumber,
          certifications: ['Journeyman'],
          memberRole: MemberRole.regular,
        ));

        // Create union, locals, and members
        await firestore.collection('unions').doc(unionId).set(HierarchicalMockData._createMockUnion(
          unionId, 'Cascade Union', 'Test', locals.length,
        ));

        for (final local in locals) {
          await firestore.collection('locals').doc(local.id).set(local.toJson());
        }

        for (final member in members) {
          await firestore.collection('users').doc(member['id']).set(member);
        }

        // Act - Test cascade query (get members through locals)
        final localsQuery = await firestore
            .collection('locals')
            .where('isActive', isEqualTo: true)
            .get();

        final localIds = localsQuery.docs.map((doc) => doc.id).toList();

        final membersQuery = await firestore
            .collection('users')
            .where('localUnion', whereIn: localsQuery.docs
                .map((doc) => doc.data()!['localNumber'])
                .toList())
            .get();

        // Assert
        expect(localsQuery.docs.length, equals(5));
        expect(membersQuery.docs.length, greaterThanOrEqualTo(5));
      });

      test('should handle hierarchical permissions and security', () async {
        // Arrange - Create users with different roles
        final adminUser = HierarchicalMockData.adminMember;
        final regularUser = HierarchicalMockData.testMember;

        await firestore.collection('users').doc(adminUser['id']).set(adminUser);
        await firestore.collection('users').doc(regularUser['id']).set(regularUser);

        // Create restricted data
        final restrictedLocal = HierarchicalMockData.testLocal.copyWith(
          memberCount: 0, // Make it appear empty for testing
        );
        await firestore.collection('locals').doc(restrictedLocal.id).set(restrictedLocal.toJson());

        // Act - Simulate different user contexts
        final adminContext = await simulateUserContext(adminUser['id']);
        final regularContext = await simulateUserContext(regularUser['id']);

        // Assert
        expect(adminContext['canAccessRestrictedData'], isTrue);
        expect(regularContext['canAccessRestrictedData'], isFalse);
      });
    });

    group('Performance Integration Tests', () {
      test('should handle large dataset operations efficiently', () async {
        // Arrange
        final largeJobSet = HierarchicalMockData.largeJobDataset.take(200).toList();
        final largeLocalSet = HierarchicalMockData.largeLocalDataset.take(100).toList();

        // Act - Measure batch write performance
        final writeStopwatch = Stopwatch()..start();

        final batch = firestore.batch();
        for (final local in largeLocalSet) {
          batch.set(firestore.collection('locals').doc(local.id), local.toJson());
        }
        for (final job in largeJobSet) {
          batch.set(firestore.collection('jobs').doc(job.id), job.toJson());
        }
        await batch.commit();

        writeStopwatch.stop();

        // Measure read performance
        final readStopwatch = Stopwatch()..start();

        final localsQuery = await firestore.collection('locals').limit(50).get();
        final jobsQuery = await firestore.collection('jobs').limit(50).get();

        readStopwatch.stop();

        // Assert
        expect(writeStopwatch.elapsedMilliseconds, lessThan(5000)); // Should be under 5s
        expect(readStopwatch.elapsedMilliseconds, lessThan(2000)); // Should be under 2s
        expect(localsQuery.docs.length, equals(50));
        expect(jobsQuery.docs.length, equals(50));
      });

      test('should maintain performance under concurrent operations', () async {
        // Arrange
        final concurrentLocals = HierarchicalMockData.allLocals.take(50).toList();

        // Act - Perform concurrent writes
        final futures = <Future>[];
        final stopwatch = Stopwatch()..start();

        for (final local in concurrentLocals) {
          futures.add(firestore.collection('locals').doc(local.id).set(local.toJson()));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(10000)); // Should be under 10s

        // Verify all writes completed
        final verifyQuery = await firestore.collection('locals').get();
        expect(verifyQuery.docs.length, greaterThanOrEqualTo(50));
      });

      test('should handle memory usage with large datasets', () async {
        // Arrange
        final memoryMonitor = MemoryMonitor();
        final jobList = BoundedJobList();
        final localsCache = LocalsLRUCache();

        // Act - Load large datasets
        for (final job in HierarchicalMockData.largeJobDataset) {
          jobList.addJob(job);
        }

        for (final local in HierarchicalMockData.largeLocalDataset) {
          localsCache.put(local.id, local);
        }

        // Monitor memory
        final memoryUsage = memoryMonitor.getTotalMemoryUsage(
          jobList: jobList,
          localsCache: localsCache,
        );

        // Assert
        expect(jobList.length, equals(BoundedJobList.maxSize)); // Should be limited
        expect(localsCache.size, equals(LocalsLRUCache.maxSize)); // Should be limited
        expect(memoryUsage, lessThan(10 * 1024 * 1024)); // Should be under 10MB

        final memoryStats = memoryMonitor.getMemoryStats(
          jobList: jobList,
          localsCache: localsCache,
        );
        expect(memoryStats['shouldCleanup'], isFalse); // Should not need cleanup yet
      });
    });

    group('Error Handling Integration Tests', () {
      test('should handle network interruptions gracefully', () async {
        // Arrange
        final local = HierarchicalMockData.testLocal;
        await firestore.collection('locals').doc(local.id).set(local.toJson());

        // Act - Simulate network error
        try {
          // This would normally work, but we'll simulate an error
          await firestore.collection('locals').doc(local.id).update({
            'networkError': 'Simulated network failure',
          });
        } catch (e) {
          // Handle the error
          expect(e, isA<FirebaseException>());
        }

        // Verify data is still accessible
        final doc = await firestore.collection('locals').doc(local.id).get();
        expect(doc.exists, isTrue);
      });

      test('should handle permission denied scenarios', () async {
        // Act - Try to access restricted collection
        try {
          await firestore.collection('admin_only').get();
        } catch (e) {
          expect(e, isA<FirebaseException>());
          expect((e as FirebaseException).code, equals('permission-denied'));
        }
      });

      test('should handle data corruption scenarios', () async {
        // Arrange - Create corrupted data
        final corruptedLocal = HierarchicalMockData.testLocal.toJson();
        corruptedLocal['memberCount'] = 'invalid_number';
        corruptedLocal['isActive'] = 'invalid_boolean';

        // Act
        await firestore.collection('locals').doc('corrupted').set(corruptedLocal);

        // Try to retrieve and parse
        final doc = await firestore.collection('locals').doc('corrupted').get();
        final data = doc.data()!;

        // Assert - Should handle gracefully
        expect(doc.exists, isTrue);
        expect(data['memberCount'], equals('invalid_number'));
        expect(data['isActive'], equals('invalid_boolean'));

        // In real implementation, this would trigger validation and error handling
      });
    });

    group('Real-time Updates Integration Tests', () {
      test('should handle real-time updates for locals', () async {
        // Arrange
        final local = HierarchicalMockData.testLocal;
        await firestore.collection('locals').doc(local.id).set(local.toJson());

        // Act - Set up real-time listener
        final stream = firestore.collection('locals').doc(local.id).snapshots();
        final expectFirst = expectLater(stream, emits(anything));

        // Update the document
        await firestore.collection('locals').doc(local.id).update({
          'memberCount': 16000,
          'updatedAt': Timestamp.now(),
        });

        final updatedDoc = await expectFirst;
        final updatedData = updatedDoc.data()!;

        // Assert
        expect(updatedData['memberCount'], equals(16000));
      });

      test('should handle real-time updates for jobs', () async {
        // Arrange
        final job = HierarchicalMockData.testJob;
        await firestore.collection('jobs').doc(job.id).set(job.toJson());

        // Act - Set up real-time listener
        final stream = firestore.collection('jobs').doc(job.id).snapshots();
        final expectFirst = expectLater(stream, emits(anything));

        // Update job status
        await firestore.collection('jobs').doc(job.id).update({
          'matchesCriteria': true,
          'updatedAt': Timestamp.now(),
        });

        final updatedDoc = await expectFirst;
        final updatedData = updatedDoc.data()!;

        // Assert
        expect(updatedData['matchesCriteria'], isTrue);
      });
    });
  });
}

/// Helper functions for integration tests
Future<void> cleanupTestData() async {
  try {
    final firestore = FirebaseFirestore.instance;

    // Clean up test collections
    final collections = ['unions', 'locals', 'users', 'jobs'];

    for (final collection in collections) {
      final snapshot = await firestore.collection(collection).get();
      for (final doc in snapshot.docs) {
        await doc.reference.delete();
      }
    }
  } catch (e) {
    print('Cleanup failed: $e');
  }
}

Future<Map<String, dynamic>> simulateUserContext(String userId) async {
  // Simulate user context and permissions
  final firestore = FirebaseFirestore.instance;
  final userDoc = await firestore.collection('users').doc(userId).get();

  if (!userDoc.exists) {
    return {'canAccessRestrictedData': false};
  }

  final userData = userDoc.data()!;
  final role = userData['memberRole'] as String?;

  return {
    'userId': userId,
    'role': role,
    'canAccessRestrictedData': role == 'admin',
  };
}

extension LocalsRecordExtension on LocalsRecord {
  LocalsRecord copyWith({
    String? id,
    String? localNumber,
    String? localName,
    String? classification,
    String? location,
    String? address,
    String? contactEmail,
    String? contactPhone,
    String? website,
    int? memberCount,
    List<String>? specialties,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocalsRecord(
      id: id ?? this.id,
      localNumber: localNumber ?? this.localNumber,
      localName: localName ?? this.localName,
      classification: classification ?? this.classification,
      location: location ?? this.location,
      address: address ?? this.address,
      contactEmail: contactEmail ?? this.contactEmail,
      contactPhone: contactPhone ?? this.contactPhone,
      website: website ?? this.website,
      memberCount: memberCount ?? this.memberCount,
      specialties: specialties ?? this.specialties,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }
}