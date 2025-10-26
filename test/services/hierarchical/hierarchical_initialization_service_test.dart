import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';

import 'package:journeyman_jobs/services/hierarchical/hierarchical_initialization_service.dart';
import 'package:journeyman_jobs/services/hierarchical/hierarchical_service.dart';
import 'package:journeyman_jobs/services/auth_service.dart';
import 'package:journeyman_jobs/models/hierarchical/hierarchical_data_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:firebase_auth/firebase_auth.dart';

// Generate mocks
@GenerateMocks([
  HierarchicalService,
  AuthService,
  User,
])
import 'hierarchical_initialization_service_test.mocks.dart';

void main() {
  group('HierarchicalInitializationService', () {
    late HierarchicalInitializationService initializationService;
    late MockHierarchicalService mockHierarchicalService;
    late MockAuthService mockAuthService;
    late MockFirebaseAuth mockAuth;

    setUp(() {
      mockHierarchicalService = MockHierarchicalService();
      mockAuthService = MockAuthService();
      mockAuth = MockFirebaseAuth();

      initializationService = HierarchicalInitializationService(
        hierarchicalService: mockHierarchicalService,
        authService: mockAuthService,
        auth: mockAuth,
      );
    });

    tearDown(() {
      initializationService.dispose();
    });

    group('User Authentication States', () {
      test('should initialize for guest user when no authenticated user', () async {
        // Setup mock auth to return null user
        when(mockAuth.currentUser).thenReturn(null);

        // Setup mock hierarchical service
        final guestData = HierarchicalData.empty();
        when(mockHierarchicalService.initializeHierarchicalData())
            .thenAnswer((_) async => guestData);

        final result = await initializationService.initializeForCurrentUser();

        expect(result, equals(guestData));
        expect(initializationService.currentState.isCompleted, isTrue);
      });

      test('should initialize for authenticated user', () async {
        // Setup mock user
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Setup mock auth service to return user profile
        final mockUserDoc = createMockUserDocumentSnapshot();
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        // Setup mock hierarchical service
        final userData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [26], // User's home local
        )).thenAnswer((_) async => userData);

        final result = await initializationService.initializeForCurrentUser();

        expect(result, equals(userData));
        expect(initializationService.currentState.isCompleted, isTrue);
        verify(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [26],
        )).called(1);
      });

      test('should handle missing user profile gracefully', () async {
        // Setup mock user
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Setup mock auth service to return non-existent user profile
        final mockUserDoc = createMockUserDocumentSnapshot(exists: false);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        // Setup mock hierarchical service for guest initialization
        final guestData = HierarchicalData.empty();
        when(mockHierarchicalService.initializeHierarchicalData())
            .thenAnswer((_) async => guestData);

        final result = await initializationService.initializeForCurrentUser();

        expect(result, equals(guestData));
      });
    });

    group('Initialization Strategies', () {
      test('should use minimal strategy for new users', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Create new user (created 1 day ago)
        final newUser = createMockUserModel(
          createdTime: DateTime.now().subtract(const Duration(days: 1)),
        );

        final mockUserDoc = createMockUserDocumentSnapshot(userData: newUser);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        final minimalData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          forceRefresh: false,
        )).thenAnswer((_) async => minimalData);

        await initializationService.initializeForCurrentUser(
          strategy: HierarchicalInitializationStrategy.adaptive,
        );

        // Should use minimal strategy for new users
        verify(mockHierarchicalService.initializeHierarchicalData(
          forceRefresh: false,
        )).called(1);
      });

      test('should use preferred locals strategy when user has preferences', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Create user with preferred locals
        final userWithPreferences = createMockUserModel(
          preferredLocals: '134, 3, 11',
          homeLocal: 26,
        );

        final mockUserDoc = createMockUserDocumentSnapshot(userData: userWithPreferences);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        final preferredData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [134, 3, 11, 26], // Should include home local
        )).thenAnswer((_) async => preferredData);

        await initializationService.initializeForCurrentUser(
          strategy: HierarchicalInitializationStrategy.adaptive,
        );

        verify(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [134, 3, 11, 26],
        )).called(1);
      });

      test('should use home local first strategy for working users', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Create working user
        final workingUser = createMockUserModel(
          homeLocal: 26,
          isWorking: true,
        );

        final mockUserDoc = createMockUserDocumentSnapshot(userData: workingUser);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        final homeLocalData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [26],
        )).thenAnswer((_) async => homeLocalData);

        await initializationService.initializeForCurrentUser(
          strategy: HierarchicalInitializationStrategy.adaptive,
        );

        verify(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [26],
        )).called(1);
      });

      test('should use comprehensive strategy for users seeking travel work', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        // Create user seeking travel work
        final travelUser = createMockUserModel(
          homeLocal: 26,
          travelToNewLocation: true,
        );

        final mockUserDoc = createMockUserDocumentSnapshot(userData: travelUser);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        final comprehensiveData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          forceRefresh: false,
        )).thenAnswer((_) async => comprehensiveData);

        await initializationService.initializeForCurrentUser(
          strategy: HierarchicalInitializationStrategy.adaptive,
        );

        verify(mockHierarchicalService.initializeHierarchicalData(
          forceRefresh: false,
        )).called(1);
      });
    });

    group('Error Handling', () {
      test('should handle initialization errors gracefully', () async {
        when(mockAuth.currentUser).thenReturn(null);

        // Setup mock to throw error
        when(mockHierarchicalService.initializeHierarchicalData())
            .thenThrow(Exception('Network error'));

        expect(
          () => initializationService.initializeForCurrentUser(),
          throwsException,
        );

        expect(initializationService.currentState.hasError, isTrue);
        expect(initializationService.currentState.error, contains('Network error'));
      });

      test('should return last known good data on error', () async {
        // Set up last known good data
        final goodData = createMockHierarchicalData();
        await initializationService.initializeForCurrentUser(); // Initial success

        // Clear state and setup error
        initializationService.reset();
        when(mockHierarchicalService.initializeHierarchicalData())
            .thenThrow(Exception('Network error'));

        when(mockAuth.currentUser).thenReturn(null);

        final result = await initializationService.initializeForCurrentUser();

        expect(result, equals(goodData)); // Should return last known good data
      });

      test('should retry failed operations', () async {
        when(mockAuth.currentUser).thenReturn(null);

        int attemptCount = 0;
        when(mockHierarchicalService.initializeHierarchicalData())
            .thenAnswer((_) async {
          attemptCount++;
          if (attemptCount <= 2) {
            throw Exception('Temporary failure');
          }
          return createMockHierarchicalData();
        });

        final result = await initializationService.initializeForCurrentUser();

        expect(attemptCount, equals(3)); // Should have tried 3 times (max retries)
        expect(result, isNotNull);
        expect(initializationService.currentState.isCompleted, isTrue);
      });
    });

    group('User Preferences Updates', () {
      test('should reinitialize when user preferences change', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        final originalUser = createMockUserModel(preferredLocals: '134, 3');
        final mockUserDoc = createMockUserDocumentSnapshot(userData: originalUser);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        final originalData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [134, 3],
        )).thenAnswer((_) async => originalData);

        // Initial initialization
        await initializationService.initializeForCurrentUser();

        // Update user preferences
        final updatedUser = createMockUserModel(preferredLocals: '11, 26, 124');
        final updatedData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [11, 26, 124],
          forceRefresh: true,
        )).thenAnswer((_) async => updatedData);

        final result = await initializationService.reinitializeForUserPreferences(updatedUser);

        expect(result, equals(updatedData));
        verify(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [11, 26, 124],
          forceRefresh: true,
        )).called(1);
      });
    });

    group('Health Check', () {
      test('should perform health check successfully', () async {
        // Setup healthy data
        final healthyData = createMockHierarchicalData();
        when(mockHierarchicalService.cachedData).thenReturn(healthyData);
        when(mockHierarchicalService.isCacheFresh).thenReturn(true);

        final result = await initializationService.performHealthCheck();

        expect(result.isHealthy, isTrue);
        expect(result.isFresh, isTrue);
        expect(result.issues, isEmpty);
      });

      test('should identify health issues', () async {
        // Setup unhealthy data (missing union)
        final unhealthyData = HierarchicalData(
          union: null, // Missing union
          locals: {},
          members: {},
          jobs: {},
          loadingStatus: HierarchicalLoadingStatus.loaded,
          lastUpdated: DateTime.now().subtract(const Duration(hours: 2)), // Stale data
        );

        when(mockHierarchicalService.cachedData).thenReturn(unhealthyData);
        when(mockHierarchicalService.isCacheFresh).thenReturn(false);

        final result = await initializationService.performHealthCheck();

        expect(result.isHealthy, isFalse);
        expect(result.isFresh, isFalse);
        expect(result.issues, contains('No union data loaded'));
        expect(result.issues, contains('No local data loaded'));
        expect(result.issues, contains('Data is stale'));
      });
    });

    group('State Management', () {
      test('should update initialization state correctly', () async {
        when(mockAuth.currentUser).thenReturn(null);

        final dataStream = initializationService.initializationStateStream;
        final states = <HierarchicalInitializationState>[];

        final subscription = dataStream.listen(states.add);

        // Initialize
        await initializationService.initializeForCurrentUser();

        // Check state transitions
        expect(states.any((s) => s.isInitializing), isTrue);
        expect(states.last.isCompleted, isTrue);

        await subscription.cancel();
      });

      test('should reset state correctly', () async {
        // Initialize first
        await initializationService.initializeForCurrentUser();
        expect(initializationService.currentState.isCompleted, isTrue);

        // Reset
        initializationService.reset();
        expect(initializationService.currentState.isIdle, isTrue);
        expect(initializationService.lastKnownGoodData, isNull);
      });
    });

    group('Background Loading', () {
      test('should load additional data in background', () async {
        final mockUser = MockUser();
        when(mockAuth.currentUser).thenReturn(mockUser);
        when(mockUser.uid).thenReturn('test-user-123');

        final user = createMockUserModel(homeLocal: 26);
        final mockUserDoc = createMockUserDocumentSnapshot(userData: user);
        when(mockAuthService.getUserProfile('test-user-123'))
            .thenAnswer((_) async => mockUserDoc);

        // Setup initial data (minimal)
        final initialData = createMockHierarchicalData();
        when(mockHierarchicalService.initializeHierarchicalData(
          preferredLocals: [26],
        )).thenAnswer((_) async => initialData);

        // Setup comprehensive data for background loading
        final comprehensiveData = createMockHierarchicalData();
        when(mockHierarchicalService.refreshHierarchicalData())
            .thenAnswer((_) async => comprehensiveData);

        await initializationService.initializeForCurrentUser(
          strategy: HierarchicalInitializationStrategy.homeLocalFirst,
        );

        // Should complete initial loading quickly
        expect(initializationService.currentState.isCompleted, isTrue);

        // Background refresh should be triggered
        await Future.delayed(const Duration(milliseconds: 200));
        verify(mockHierarchicalService.refreshHierarchicalData()).called(1);
      });
    });
  });
}

// Helper functions to create mock data

MockDocumentSnapshot createMockUserDocumentSnapshot({
  UserModel? userData,
  bool exists = true,
}) {
  final mockDoc = MockDocumentSnapshot();
  when(mockDoc.exists).thenReturn(exists);

  if (userData != null) {
    when(mockDoc.data()).thenReturn(userData.toFirestore());
  }

  return mockDoc;
}

UserModel createMockUserModel({
  String? uid = 'test-user-123',
  int homeLocal = 26,
  String? preferredLocals,
  bool isWorking = false,
  bool travelToNewLocation = false,
  DateTime? createdTime,
}) {
  return UserModel(
    uid: uid ?? 'test-user-123',
    username: 'testuser',
    classification: 'Journeyman Lineman',
    homeLocal: homeLocal,
    role: 'electrician',
    crewIds: [],
    email: 'test@example.com',
    onlineStatus: true,
    lastActive: Timestamp.now(),
    firstName: 'Test',
    lastName: 'User',
    phoneNumber: '(555) 123-4567',
    address1: '123 Test St',
    city: 'Test City',
    state: 'TS',
    zipcode: 12345,
    ticketNumber: 'JL123456',
    isWorking: isWorking,
    booksOn: null,
    constructionTypes: ['Commercial'],
    hoursPerWeek: '40-50',
    perDiemRequirement: null,
    preferredLocals: preferredLocals,
    fcmToken: null,
    displayName: 'Test User',
    isActive: true,
    createdTime: createdTime ?? DateTime.now().subtract(const Duration(days: 30)),
    certifications: ['OSHA 10'],
    yearsExperience: 5,
    preferredDistance: 50,
    localNumber: homeLocal.toString(),
    networkWithOthers: true,
    careerAdvancements: false,
    betterBenefits: true,
    higherPayRate: true,
    learnNewSkill: false,
    travelToNewLocation: travelToNewLocation,
    findLongTermWork: true,
    careerGoals: 'Career advancement',
    howHeardAboutUs: 'Friend',
    lookingToAccomplish: 'Find better opportunities',
    onboardingStatus: null,
    hasSetJobPreferences: true,
  );
}

HierarchicalData createMockHierarchicalData() {
  final now = DateTime.now();
  return HierarchicalData(
    union: Union(
      id: 'ibew-international',
      name: 'International Brotherhood of Electrical Workers',
      abbreviation: 'IBEW',
      type: 'International',
      jurisdiction: 'North America',
      localCount: 100,
      totalMembership: 50000,
      headquartersLocation: 'Washington, DC',
      contactEmail: 'info@ibew.org',
      contactPhone: '(202) 728-6000',
      website: 'https://www.ibew.org',
      foundedDate: DateTime(1891),
      isActive: true,
      createdAt: now,
      updatedAt: now,
    ),
    locals: {},
    members: {},
    jobs: {},
    loadingStatus: HierarchicalLoadingStatus.loaded,
    lastUpdated: now,
  );
}