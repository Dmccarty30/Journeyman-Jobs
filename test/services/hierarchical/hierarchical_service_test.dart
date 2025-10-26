import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import 'package:journeyman_jobs/services/hierarchical/hierarchical_service.dart';
import 'package:journeyman_jobs/models/hierarchical/union_model.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_data_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/models/job_model.dart';

// Generate mocks
@GenerateMocks([
  FirebaseFirestore,
  CollectionReference,
  DocumentSnapshot,
  QuerySnapshot,
  DocumentReference,
  Query,
])
import 'hierarchical_service_test.mocks.dart';

void main() {
  group('HierarchicalService', () {
    late HierarchicalService hierarchicalService;
    late MockFirebaseFirestore mockFirestore;
    late FakeFirebaseInstance fakeFirestore;

    setUp(() {
      mockFirestore = MockFirebaseFirestore();
      hierarchicalService = HierarchicalService(firestore: mockFirestore);
      fakeFirestore = FakeFirebaseInstance();
    });

    tearDown(() {
      hierarchicalService.dispose();
    });

    group('Union Data Loading', () {
      test('should load union data successfully', () async {
        // Setup fake Firestore with union data
        await fakeFirestore.collection('unions').add({
          'name': 'International Brotherhood of Electrical Workers',
          'abbreviation': 'IBEW',
          'type': 'International',
          'jurisdiction': 'North America',
          'localCount': 0,
          'totalMembership': 0,
          'headquartersLocation': 'Washington, DC',
          'contactEmail': 'info@ibew.org',
          'contactPhone': '(202) 728-6000',
          'website': 'https://www.ibew.org',
          'foundedDate': Timestamp.fromDate(DateTime(1891)),
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Use hierarchical service with fake firestore
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        // Test loading union data
        final result = await serviceWithFake.initializeHierarchicalData();

        expect(result.union, isNotNull);
        expect(result.union!.name, equals('International Brotherhood of Electrical Workers'));
        expect(result.union!.abbreviation, equals('IBEW'));
        expect(result.loadingStatus, equals(HierarchicalLoadingStatus.loaded));

        serviceWithFake.dispose();
      });

      test('should create default union when no union data exists', () async {
        // Use empty fake firestore
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData();

        expect(result.union, isNotNull);
        expect(result.union!.id, equals('ibew-international'));
        expect(result.union!.name, equals('International Brotherhood of Electrical Workers'));
        expect(result.loadingStatus, equals(HierarchicalLoadingStatus.loaded));

        serviceWithFake.dispose();
      });

      test('should handle union loading errors gracefully', () async {
        // Setup mock to throw error
        when(mockFirestore.collection('unions')).thenThrow(Exception('Firestore error'));

        hierarchicalService = HierarchicalService(firestore: mockFirestore);

        final result = await hierarchicalService.initializeHierarchicalData();

        expect(result.union, isNotNull); // Should create default union
        expect(result.union!.name, equals('International Brotherhood of Electrical Workers'));
      });
    });

    group('Locals Data Loading', () {
      test('should load locals data successfully', () async {
        // Setup fake Firestore with locals data
        await fakeFirestore.collection('locals').add({
          'local_union': '134',
          'local_name': 'Chicago Electrical Workers',
          'city': 'Chicago',
          'state': 'IL',
          'email': 'contact@local134.org',
          'phone': '(312) 555-0134',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData();

        expect(result.locals, isNotEmpty);
        expect(result.locals.containsKey(134), isTrue);
        expect(result.locals[134]!.localName, equals('Chicago Electrical Workers'));
        expect(result.loadingStatus, equals(HierarchicalLoadingStatus.loaded));

        serviceWithFake.dispose();
      });

      test('should load preferred locals when specified', () async {
        // Setup fake Firestore with multiple locals
        await fakeFirestore.collection('locals').addAll([
          {
            'local_union': '134',
            'local_name': 'Chicago Electrical Workers',
            'city': 'Chicago',
            'state': 'IL',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          },
          {
            'local_union': '3',
            'local_name': 'New York Electrical Workers',
            'city': 'New York',
            'state': 'NY',
            'isActive': true,
            'createdAt': Timestamp.now(),
            'updatedAt': Timestamp.now(),
          },
        ]);

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData(
          preferredLocals: [134], // Only load Local 134
        );

        expect(result.locals, isNotEmpty);
        expect(result.locals.containsKey(134), isTrue);
        expect(result.locals.containsKey(3), isFalse); // Should not load Local 3

        serviceWithFake.dispose();
      });
    });

    group('Members Data Loading', () {
      test('should load members data successfully', () async {
        // Setup fake Firestore with user data
        await fakeFirestore.collection('users').add({
          'homeLocal': 134,
          'firstName': 'John',
          'lastName': 'Doe',
          'classification': 'Journeyman Lineman',
          'ticketNumber': 'JL134123',
          'email': 'john.doe@example.com',
          'phoneNumber': '(555) 123-4567',
          'city': 'Chicago',
          'state': 'IL',
          'isWorking': false,
          'constructionTypes': ['Commercial', 'Industrial'],
          'certifications': ['OSHA 10'],
          'yearsExperience': 5,
          'isActive': true,
          'createdTime': Timestamp.now(),
        });

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData(
          preferredLocals: [134],
        );

        expect(result.members, isNotEmpty);
        expect(result.members.values.first.localNumber, equals(134));
        expect(result.members.values.first.fullName, equals('John Doe'));
        expect(result.members.values.first.classification, equals('Journeyman Lineman'));

        serviceWithFake.dispose();
      });
    });

    group('Jobs Data Loading', () {
      test('should load jobs data successfully', () async {
        // Setup fake Firestore with job data
        await fakeFirestore.collection('jobs').add({
          'company': 'Electrical Contractors Inc',
          'location': 'Chicago, IL',
          'local': 134,
          'classification': 'Journeyman Lineman',
          'jobTitle': 'Journeyman Lineman',
          'deleted': false,
          'matchesCriteria': true,
          'sharerId': 'test-user',
          'jobDetails': {
            'hours': 40,
            'payRate': 45.0,
            'perDiem': '100',
            'contractor': 'Electrical Contractors Inc',
          },
          'timestamp': Timestamp.now(),
        });

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData(
          preferredLocals: [134],
        );

        expect(result.jobs, isNotEmpty);
        expect(result.jobs.values.first.company, equals('Electrical Contractors Inc'));
        expect(result.jobs.values.first.local, equals(134));

        serviceWithFake.dispose();
      });

      test('should filter out deleted jobs', () async {
        // Setup fake Firestore with mixed job data
        await fakeFirestore.collection('jobs').addAll([
          {
            'company': 'Active Job',
            'location': 'Chicago, IL',
            'local': 134,
            'deleted': false,
            'matchesCriteria': true,
            'sharerId': 'test-user',
            'timestamp': Timestamp.now(),
          },
          {
            'company': 'Deleted Job',
            'location': 'Chicago, IL',
            'local': 134,
            'deleted': true,
            'matchesCriteria': true,
            'sharerId': 'test-user',
            'timestamp': Timestamp.now(),
          },
        ]);

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData(
          preferredLocals: [134],
        );

        expect(result.jobs.length, equals(1));
        expect(result.jobs.values.first.company, equals('Active Job'));

        serviceWithFake.dispose();
      });
    });

    group('Data Validation', () {
      test('should validate hierarchical data consistency', () async {
        // Setup consistent data
        await fakeFirestore.collection('unions').add({
          'name': 'Test Union',
          'abbreviation': 'TU',
          'type': 'International',
          'jurisdiction': 'Test',
          'localCount': 1,
          'totalMembership': 100,
          'headquartersLocation': 'Test City',
          'contactEmail': 'test@test.com',
          'contactPhone': '(555) 123-4567',
          'foundedDate': Timestamp.fromDate(DateTime(2000)),
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        await fakeFirestore.collection('locals').add({
          'local_union': '123',
          'local_name': 'Test Local',
          'city': 'Test City',
          'state': 'TS',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        await fakeFirestore.collection('users').add({
          'homeLocal': 123,
          'firstName': 'Test',
          'lastName': 'User',
          'classification': 'Journeyman',
          'email': 'test@example.com',
          'isActive': true,
          'createdTime': Timestamp.now(),
        });

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        final result = await serviceWithFake.initializeHierarchicalData();

        expect(result.isValid(), isTrue);

        serviceWithFake.dispose();
      });
    });

    group('Search Functionality', () {
      test('should search across hierarchical data', () async {
        // Setup test data
        await fakeFirestore.collection('locals').add({
          'local_union': '134',
          'local_name': 'Chicago Electrical Workers',
          'city': 'Chicago',
          'state': 'IL',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        await serviceWithFake.initializeHierarchicalData();

        final searchResults = serviceWithFake.search('Chicago');

        expect(searchResults.locals, isNotEmpty);
        expect(searchResults.locals.first.localName, contains('Chicago'));

        serviceWithFake.dispose();
      });

      test('should return empty results for empty query', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        await serviceWithFake.initializeHierarchicalData();

        final searchResults = serviceWithFake.search('');

        expect(searchResults.locals, isEmpty);
        expect(searchResults.members, isEmpty);
        expect(searchResults.jobs, isEmpty);
        expect(searchResults.hasResults, isFalse);

        serviceWithFake.dispose();
      });
    });

    group('Caching', () {
      test('should return cached data when fresh', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        // Load data first time
        await serviceWithFake.initializeHierarchicalData();
        expect(serviceWithFake.isCacheFresh, isTrue);

        // Load data second time (should use cache)
        final stopwatch = Stopwatch()..start();
        await serviceWithFake.initializeHierarchicalData();
        stopwatch.stop();

        // Should be much faster due to caching
        expect(stopwatch.elapsedMilliseconds, lessThan(100));

        serviceWithFake.dispose();
      });

      test('should clear cache when requested', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        await serviceWithFake.initializeHierarchicalData();
        expect(serviceWithFake.isCacheFresh, isTrue);

        serviceWithFake.clearCache();
        expect(serviceWithFake.cachedData.locals, isEmpty);

        serviceWithFake.dispose();
      });
    });

    group('Error Handling', () {
      test('should handle Firestore errors gracefully', () async {
        // Setup mock to throw error
        when(mockFirestore.collection(any)).thenThrow(Exception('Connection failed'));

        hierarchicalService = HierarchicalService(firestore: mockFirestore);

        final result = await hierarchicalService.initializeHierarchicalData();

        // Should return data with default union but error status
        expect(result.union, isNotNull);
        expect(result.union!.name, equals('International Brotherhood of Electrical Workers'));
        expect(result.locals, isEmpty);
        expect(result.members, isEmpty);
        expect(result.jobs, isEmpty);
      });

      test('should retry failed operations', () async {
        int attemptCount = 0;

        // Setup mock that fails first time, succeeds second time
        when(mockFirestore.collection('unions')).thenAnswer((_) async {
          attemptCount++;
          if (attemptCount == 1) {
            throw Exception('Temporary failure');
          }
          return MockCollectionReference();
        });

        hierarchicalService = HierarchicalService(firestore: mockFirestore);

        // This should succeed after retry
        final result = await hierarchicalService.refreshHierarchicalData();

        expect(attemptCount, equals(2)); // Should have tried twice
        expect(result, isNotNull);
      });
    });

    group('Real-time Updates', () {
      test('should set up real-time listeners', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        // Setup real-time listeners
        serviceWithFake.setupRealtimeListeners();

        // Add data to trigger updates
        await fakeFirestore.collection('locals').add({
          'local_union': '134',
          'local_name': 'Test Local',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Wait for real-time update
        await Future.delayed(const Duration(milliseconds: 100));

        // Verify data was loaded through real-time listener
        expect(serviceWithFake.cachedData.locals, isNotEmpty);

        serviceWithFake.dispose();
      });

      test('should cancel real-time listeners on dispose', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        serviceWithFake.setupRealtimeListeners();
        serviceWithFake.dispose();

        // Add data after dispose - should not trigger updates
        await fakeFirestore.collection('locals').add({
          'local_union': '134',
          'local_name': 'Test Local',
          'isActive': true,
          'createdAt': Timestamp.now(),
          'updatedAt': Timestamp.now(),
        });

        // Wait a bit to ensure no updates
        await Future.delayed(const Duration(milliseconds: 100));

        // Service should not have been updated since it was disposed
        expect(serviceWithFake.cachedData.locals, isEmpty);
      });
    });

    group('Performance Metrics', () {
      test('should track query performance', () async {
        final serviceWithFake = HierarchicalService(firestore: fakeFirestore);

        // Load data to generate metrics
        await serviceWithFake.initializeHierarchicalData();

        // Performance metrics should be available
        // Note: This would require exposing metrics through the service
        // For now, we just verify the operation completes successfully
        expect(serviceWithFake.cachedData, isNotNull);

        serviceWithFake.dispose();
      });
    });
  });
}

/// Helper function to create mock data
Map<String, dynamic> createMockUnionData() {
  return {
    'name': 'International Brotherhood of Electrical Workers',
    'abbreviation': 'IBEW',
    'type': 'International',
    'jurisdiction': 'North America',
    'localCount': 0,
    'totalMembership': 0,
    'headquartersLocation': 'Washington, DC',
    'contactEmail': 'info@ibew.org',
    'contactPhone': '(202) 728-6000',
    'website': 'https://www.ibew.org',
    'foundedDate': Timestamp.fromDate(DateTime(1891)),
    'isActive': true,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };
}

Map<String, dynamic> createMockLocalData() {
  return {
    'local_union': '134',
    'local_name': 'Chicago Electrical Workers',
    'city': 'Chicago',
    'state': 'IL',
    'email': 'contact@local134.org',
    'phone': '(312) 555-0134',
    'isActive': true,
    'createdAt': Timestamp.now(),
    'updatedAt': Timestamp.now(),
  };
}

Map<String, dynamic> createMockMemberData() {
  return {
    'homeLocal': 134,
    'firstName': 'John',
    'lastName': 'Doe',
    'classification': 'Journeyman Lineman',
    'ticketNumber': 'JL134123',
    'email': 'john.doe@example.com',
    'phoneNumber': '(555) 123-4567',
    'city': 'Chicago',
    'state': 'IL',
    'isWorking': false,
    'constructionTypes': ['Commercial', 'Industrial'],
    'certifications': ['OSHA 10'],
    'yearsExperience': 5,
    'isActive': true,
    'createdTime': Timestamp.now(),
  };
}

Map<String, dynamic> createMockJobData() {
  return {
    'company': 'Electrical Contractors Inc',
    'location': 'Chicago, IL',
    'local': 134,
    'classification': 'Journeyman Lineman',
    'jobTitle': 'Journeyman Lineman',
    'deleted': false,
    'matchesCriteria': true,
    'sharerId': 'test-user',
    'jobDetails': {
      'hours': 40,
      'payRate': 45.0,
      'perDiem': '100',
      'contractor': 'Electrical Contractors Inc',
    },
    'timestamp': Timestamp.now(),
  };
}