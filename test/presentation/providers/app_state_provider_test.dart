import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/providers/app_state_provider.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/locals_record.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/filter_criteria.dart';
import 'package:mockito/mockito.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';

import '../../helpers/test_helpers.dart';
import '../../fixtures/mock_data.dart';

void main() {
  late AppStateProvider appStateProvider;
  late MockAuthService mockAuthService;
  late MockResilientFirestoreService mockFirestoreService;
  late MockConnectivityService mockConnectivityService;
  late FakeFirebaseFirestore fakeFirestore;

  setUp(() {
    mockAuthService = MockAuthService();
    mockFirestoreService = MockResilientFirestoreService();
    mockConnectivityService = MockConnectivityService();
    fakeFirestore = FakeFirebaseFirestore();

    // Setup default mock behaviors
    when(mockAuthService.authStateChanges)
        .thenAnswer((_) => Stream.value(null));
    when(mockConnectivityService.isConnected).thenReturn(true);
    when(mockConnectivityService.hasListeners).thenReturn(false);

    appStateProvider = AppStateProvider(
      mockAuthService,
      mockFirestoreService,
      mockConnectivityService,
    );
  });

  tearDown(() {
    appStateProvider.dispose();
  });

  group('AppStateProvider - Initialization Tests', () {
    test('should initialize with default values', () {
      expect(appStateProvider.user, isNull);
      expect(appStateProvider.userProfile, isNull);
      expect(appStateProvider.jobs, isEmpty);
      expect(appStateProvider.locals, isEmpty);
      expect(appStateProvider.isLoadingAuth, isFalse);
      expect(appStateProvider.isLoadingJobs, isFalse);
      expect(appStateProvider.isLoadingLocals, isFalse);
      expect(appStateProvider.isLoadingUserProfile, isFalse);
    });

    test('should set up auth state listener on initialization', () {
      verify(mockAuthService.authStateChanges).called(1);
    });
  });

  group('AppStateProvider - Authentication Tests', () {
    test('should update user state when auth changes', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test-uid');
      when(mockUser.email).thenReturn('test@example.com');

      final authStream = Stream.value(mockUser);
      when(mockAuthService.authStateChanges).thenAnswer((_) => authStream);

      // Act
      appStateProvider = AppStateProvider(
        mockAuthService,
        mockFirestoreService,
        mockConnectivityService,
      );

      // Wait for stream to emit
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.user, equals(mockUser));
      expect(appStateProvider.isAuthenticated, isTrue);
    });

    test('should clear user data on sign out', () async {
      // Arrange
      final mockUser = MockUser();
      when(mockUser.uid).thenReturn('test-uid');
      
      // First sign in
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(mockUser));
      
      appStateProvider = AppStateProvider(
        mockAuthService,
        mockFirestoreService,
        mockConnectivityService,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appStateProvider.user, equals(mockUser));

      // Then sign out
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.value(null));
      
      // Simulate auth state change
      appStateProvider.dispose();
      appStateProvider = AppStateProvider(
        mockAuthService,
        mockFirestoreService,
        mockConnectivityService,
      );
      
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.user, isNull);
      expect(appStateProvider.isAuthenticated, isFalse);
      expect(appStateProvider.userProfile, isNull);
    });

    test('should handle auth errors gracefully', () async {
      // Arrange
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => Stream.error(Exception('Auth error')));

      // Act
      appStateProvider = AppStateProvider(
        mockAuthService,
        mockFirestoreService,
        mockConnectivityService,
      );

      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.authError, isNotNull);
      expect(appStateProvider.authError, contains('error'));
      expect(appStateProvider.isLoadingAuth, isFalse);
    });
  });

  group('AppStateProvider - Jobs Management Tests', () {
    test('should load jobs successfully', () async {
      // Arrange
      final jobsData = [
        MockData.createJob(id: 'job1').toJson(),
        MockData.createJob(id: 'job2').toJson(),
      ];

      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocs = jobsData.map((data) {
        final doc = MockQueryDocumentSnapshot();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn(data['id'] as String);
        return doc;
      }).toList();

      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot));

      // Act
      await appStateProvider.loadJobs();

      // Assert
      expect(appStateProvider.jobs.length, equals(2));
      expect(appStateProvider.isLoadingJobs, isFalse);
      expect(appStateProvider.jobsError, isNull);
    });

    test('should handle job loading errors', () async {
      // Arrange
      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.error(Exception('Firestore error')));

      // Act
      await appStateProvider.loadJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.jobs, isEmpty);
      expect(appStateProvider.jobsError, isNotNull);
      expect(appStateProvider.isLoadingJobs, isFalse);
    });

    test('should implement pagination for jobs', () async {
      // Arrange
      final firstBatch = [TestFixtures.createJobData(id: 'job1')];
      final secondBatch = [TestFixtures.createJobData(id: 'job2')];

      final mockQuerySnapshot1 = MockQuerySnapshot();
      final mockDocs1 = firstBatch.map((data) {
        final doc = MockQueryDocumentSnapshot();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn(data['id'] as String);
        return doc;
      }).toList();
      when(mockQuerySnapshot1.docs).thenReturn(mockDocs1);

      final mockQuerySnapshot2 = MockQuerySnapshot();
      final mockDocs2 = secondBatch.map((data) {
        final doc = MockQueryDocumentSnapshot();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn(data['id'] as String);
        return doc;
      }).toList();
      when(mockQuerySnapshot2.docs).thenReturn(mockDocs2);

      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: null,
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot1));

      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot2));

      // Act - Load first batch
      await appStateProvider.loadJobs();
      expect(appStateProvider.jobs.length, equals(1));

      // Load more
      await appStateProvider.loadMoreJobs();

      // Assert
      expect(appStateProvider.jobs.length, equals(2));
      expect(appStateProvider.hasMoreJobs, isTrue);
    });

    test('should refresh jobs and clear existing data', () async {
      // Arrange
      // Add initial jobs
      final initialJobs = [
        TestFixtures.createJobData(id: 'old-job'),
      ];
      
      final newJobs = [
        TestFixtures.createJobData(id: 'new-job'),
      ];

      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocs = newJobs.map((data) {
        final doc = MockQueryDocumentSnapshot();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn(data['id'] as String);
        return doc;
      }).toList();
      when(mockQuerySnapshot.docs).thenReturn(mockDocs);

      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot));

      // Act
      await appStateProvider.refreshJobs();

      // Assert
      expect(appStateProvider.jobs.length, equals(1));
      expect(appStateProvider.jobs.first.id, equals('new-job'));
    });
  });

  group('AppStateProvider - Locals Management Tests', () {
    test('should load locals successfully', () async {
      // Arrange
      final localsData = [
        TestFixtures.createLocalData(localNumber: 123),
        TestFixtures.createLocalData(localNumber: 456),
      ];

      final mockQuerySnapshot = MockQuerySnapshot();
      final mockDocs = localsData.map((data) {
        final doc = MockQueryDocumentSnapshot();
        when(doc.data()).thenReturn(data);
        when(doc.id).thenReturn('local-${data['localNumber']}');
        return doc;
      }).toList();

      when(mockQuerySnapshot.docs).thenReturn(mockDocs);
      when(mockFirestoreService.getLocals(
        limit: anyNamed('limit'),
        state: anyNamed('state'),
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot));

      // Act
      await appStateProvider.loadLocals();

      // Assert
      expect(appStateProvider.locals.length, equals(2));
      expect(appStateProvider.isLoadingLocals, isFalse);
      expect(appStateProvider.localsError, isNull);
    });

    test('should search locals by term', () async {
      // Arrange
      final searchResults = [
        TestFixtures.createLocalData(localNumber: 123, name: 'IBEW Local 123'),
      ];

      final mockQuerySnapshot = MockQuerySnapshot();
      when(mockQuerySnapshot.docs).thenReturn([]);
      
      when(mockFirestoreService.searchLocals(
        any,
        limit: anyNamed('limit'),
      )).thenAnswer((_) async => mockQuerySnapshot);

      // Act
      await appStateProvider.searchLocals('123');

      // Assert
      verify(mockFirestoreService.searchLocals(
        '123',
        limit: anyNamed('limit'),
      )).called(1);
    });
  });

  group('AppStateProvider - Filter Management Tests', () {
    test('should update active filter', () {
      // Arrange
      final filter = JobFilterCriteria(
        classifications: ['Inside Wireman'],
        maxDistance: 50,
      );

      // Act
      appStateProvider.updateActiveFilter(filter);

      // Assert
      expect(appStateProvider.activeFilter, equals(filter));
      expect(appStateProvider.activeFilter.classifications, contains('Inside Wireman'));
      expect(appStateProvider.activeFilter.maxDistance, equals(50));
    });

    test('should reload jobs when filter changes', () async {
      // Arrange
      final mockQuerySnapshot = MockQuerySnapshot();
      when(mockQuerySnapshot.docs).thenReturn([]);
      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.value(mockQuerySnapshot));

      final filter = JobFilterCriteria(
        classifications: ['Inside Wireman'],
      );

      // Act
      appStateProvider.updateActiveFilter(filter);
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      verify(mockFirestoreService.getJobs(
        classifications: ['Inside Wireman'],
        locals: any,
        limit: any,
        lastDocument: any,
      )).called(greaterThanOrEqualTo(1));
    });
  });

  group('AppStateProvider - Memory Management Tests', () {
    test('should properly dispose subscriptions', () {
      // Arrange
      final controller = StreamController<User?>();
      when(mockAuthService.authStateChanges)
          .thenAnswer((_) => controller.stream);

      appStateProvider = AppStateProvider(
        mockAuthService,
        mockFirestoreService,
        mockConnectivityService,
      );

      // Act
      appStateProvider.dispose();

      // Assert
      expect(appStateProvider.disposed, isTrue);
      controller.close();
    });

    test('should clear all data on dispose', () {
      // Arrange
      appStateProvider.updateActiveFilter(
        JobFilterCriteria(classifications: ['Test']),
      );

      // Act
      appStateProvider.dispose();

      // Assert
      expect(() => appStateProvider.jobs, throwsA(isA<Error>()));
    });
  });

  group('AppStateProvider - Error Handling Tests', () {
    test('should set appropriate error messages', () async {
      // Arrange
      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) => Stream.error(
            FirebaseException(
              plugin: 'cloud_firestore',
              message: 'Permission denied',
            ),
          ));

      // Act
      await appStateProvider.loadJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.jobsError, isNotNull);
      expect(appStateProvider.jobsError, contains('Permission'));
    });

    test('should recover from errors on retry', () async {
      // Arrange
      var callCount = 0;
      when(mockFirestoreService.getJobs(
        classifications: any,
        locals: any,
        limit: any,
        lastDocument: any,
      )).thenAnswer((_) {
        callCount++;
        if (callCount == 1) {
          return Stream.error(Exception('Network error'));
        }
        final mockSnapshot = MockQuerySnapshot();
        when(mockSnapshot.docs).thenReturn([]);
        return Stream.value(mockSnapshot);
      });

      // Act - First call fails
      await appStateProvider.loadJobs();
      await Future.delayed(const Duration(milliseconds: 100));
      expect(appStateProvider.jobsError, isNotNull);

      // Retry succeeds
      await appStateProvider.loadJobs();
      await Future.delayed(const Duration(milliseconds: 100));

      // Assert
      expect(appStateProvider.jobsError, isNull);
      expect(appStateProvider.isLoadingJobs, isFalse);
    });
  });
}

// Mock classes
class MockUser extends Mock implements User {
  @override
  String get uid => 'test-uid';
}

class MockQuerySnapshot extends Mock implements QuerySnapshot {}

class MockQueryDocumentSnapshot extends Mock implements QueryDocumentSnapshot {
  @override
  Map<String, dynamic> data() => {};
}