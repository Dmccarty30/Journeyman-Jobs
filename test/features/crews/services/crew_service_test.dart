import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/lib/domain/exceptions/app_exception.dart';
import 'package:journeyman_jobs/lib/domain/exceptions/crew_exception.dart';
import 'package:journeyman_jobs/lib/domain/exceptions/member_exception.dart';
import 'package:journeyman_jobs/lib/services/connectivity_service.dart';
import 'package:journeyman_jobs/lib/services/offline_data_service.dart';
import 'package:journeyman_jobs/features/crews/services/job_sharing_service.dart';
import 'package:journeyman_jobs/features/crews/services/job_matching_service.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/permission.dart';
import 'package:journeyman_jobs/domain/enums/invitation_status.dart';

// Mocks
class MockFirebaseFirestore extends Mock implements FirebaseFirestore {}
class MockCollectionReference extends Mock implements CollectionReference {}
class MockDocumentReference extends Mock implements DocumentReference {}
class MockDocumentSnapshot extends Mock implements DocumentSnapshot {}
class MockQuerySnapshot extends Mock implements QuerySnapshot {}
class MockQuery extends Mock implements Query {}
class MockJobSharingService extends Mock implements JobSharingService {}
class MockJobMatchingService extends Mock implements JobMatchingService {}
class MockOfflineDataService extends Mock implements OfflineDataService {}
class MockConnectivityService extends Mock implements ConnectivityService {}

void main() {
  late CrewService crewService;
  late MockFirebaseFirestore mockFirestore;
  late MockJobSharingService mockJobSharingService;
  late MockJobMatchingService mockJobMatchingService;
  late MockOfflineDataService mockOfflineDataService;
  late MockConnectivityService mockConnectivityService;
  late MockCollectionReference mockCrewsCollection;
  late MockDocumentReference mockCrewDoc;
  late MockCollectionReference mockMembersCollection;
  late MockDocumentReference mockMemberDoc;
  late MockCollectionReference mockInvitationsCollection;
  late MockDocumentReference mockInvitationDoc;
  late MockCollectionReference mockCountersCollection;
  late MockDocumentReference mockCountersDoc;
  late MockCollectionReference mockUserCrewsCollection;
  late MockDocumentReference mockUserCrewsDoc;

  setUp(() {
    mockFirestore = MockFirebaseFirestore();
    mockJobSharingService = MockJobSharingService();
    mockJobMatchingService = MockJobMatchingService();
    mockOfflineDataService = MockOfflineDataService();
    mockConnectivityService = MockConnectivityService();
    mockCrewsCollection = MockCollectionReference();
    mockCrewDoc = MockDocumentReference();
    mockMembersCollection = MockCollectionReference();
    mockMemberDoc = MockDocumentReference();
    mockInvitationsCollection = MockCollectionReference();
    mockInvitationDoc = MockDocumentReference();
    mockCountersCollection = MockCollectionReference();
    mockCountersDoc = MockDocumentReference();
    mockUserCrewsCollection = MockCollectionReference();
    mockUserCrewsDoc = MockDocumentReference();

    // Common mock setups
    when(mockFirestore.collection('crews')).thenReturn(mockCrewsCollection);
    when(mockCrewsCollection.doc(any)).thenReturn(mockCrewDoc);
    when(mockCrewDoc.collection('members')).thenReturn(mockMembersCollection);
    when(mockMembersCollection.doc(any)).thenReturn(mockMemberDoc);
    when(mockCrewDoc.collection('invitations')).thenReturn(mockInvitationsCollection);
    when(mockInvitationsCollection.doc(any)).thenReturn(mockInvitationDoc);
    when(mockFirestore.collection('counters')).thenReturn(mockCountersCollection);
    when(mockCountersCollection.doc('crews')).thenReturn(mockCountersDoc);
    when(mockCountersDoc.collection('user_crews')).thenReturn(mockUserCrewsCollection);
    when(mockUserCrewsCollection.doc(any)).thenReturn(mockUserCrewsDoc);

    // Default connectivity to online
    when(mockConnectivityService.isOnline).thenReturn(true);

    crewService = CrewService(
      jobSharingService: mockJobSharingService,
      jobMatchingService: mockJobMatchingService,
      offlineDataService: mockOfflineDataService,
      connectivityService: mockConnectivityService,
    );
  });

  group('CrewService', () {
    // Test cases for createCrew
    group('createCrew', () {
      final crewName = 'Test Crew';
      final foremanId = 'foreman123';
      final preferences = CrewPreferences(
        jobTypes: ['Electrical'],
        minHourlyRate: 25.0,
        autoShareEnabled: true,
      );

      test('should create a crew successfully when online', () async {
        // Mock _getNextCrewId
        when(mockCountersDoc.get()).thenAnswer((_) async => MockDocumentSnapshot()); // No existing counter
        when(mockFirestore.runTransaction<int>(any)).thenAnswer((invocation) async {
          final Function transactionCallback = invocation.positionalArguments[0];
          final mockTransaction = MockTransaction();
          when(mockTransaction.get(any)).thenAnswer((_) async => MockDocumentSnapshot());
          return await transactionCallback(mockTransaction);
        });

        // Mock CrewValidation.isCrewNameUnique
        when(CrewValidation.isCrewNameUnique(any, any)).thenAnswer((_) async => true);
        // Mock _checkCrewCreationLimit
        when(mockUserCrewsDoc.get()).thenAnswer((_) async => MockDocumentSnapshot()); // No existing count
        // Mock Firestore set operation
        when(mockCrewDoc.set(any)).thenAnswer((_) async => Future.value());
        when(mockUserCrewsDoc.set(any, any)).thenAnswer((_) async => Future.value());

        await crewService.createCrew(
          name: crewName,
          foremanId: foremanId,
          preferences: preferences,
        );

        verify(mockCrewDoc.set(any)).called(1);
        verify(mockUserCrewsDoc.set(any, any)).called(1);
      });

      test('should throw CrewException if crew name is not unique when online', () async {
        when(CrewValidation.isCrewNameUnique(any, any)).thenAnswer((_) async => false);

        expect(
          () => crewService.createCrew(
            name: crewName,
            foremanId: foremanId,
            preferences: preferences,
          ),
          throwsA(isA<CrewException>().having(
            (e) => e.code,
            'code',
            'crew-name-exists',
          )),
        );
      });

      test('should handle offline crew creation by storing locally', () async {
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockOfflineDataService.storeCrewsOffline(any)).thenAnswer((_) async => Future.value());
        when(mockOfflineDataService.markDataDirty(any, any)).thenAnswer((_) async => Future.value());
        when(mockUserCrewsDoc.get()).thenAnswer((_) async => MockDocumentSnapshot()); // No existing count

        await crewService.createCrew(
          name: crewName,
          foremanId: foremanId,
          preferences: preferences,
        );

        verify(mockOfflineDataService.storeCrewsOffline(any)).called(1);
        verify(mockOfflineDataService.markDataDirty(any, any)).called(1);
        verifyNever(mockCrewDoc.set(any)); // Should not interact with Firestore
      });

      // Add more test cases for validation, limits, FirebaseException, etc.
    });

    // Test cases for getCrew
    group('getCrew', () {
      final crewId = 'crew123';
      final mockCrew = Crew(
        id: crewId,
        name: 'Test Crew',
        foremanId: 'foreman123',
        memberIds: ['foreman123'],
        preferences: CrewPreferences(jobTypes: [], minHourlyRate: 0, autoShareEnabled: false),
        createdAt: DateTime.now(),
        roles: {'foreman123': MemberRole.foreman},
        stats: CrewStats(
          totalJobsShared: 0,
          totalApplications: 0,
          applicationRate: 0,
          averageMatchScore: 0,
          successfulPlacements: 0,
          responseTime: 0,
          jobTypeBreakdown: {},
          lastActivityAt: DateTime.now(),
          matchScores: [],
          successRate: 0,
        ),
        isActive: true,
      );

      test('should get crew from Firestore when online', () async {
        final mockDocSnapshot = MockDocumentSnapshot();
        when(mockDocSnapshot.exists).thenReturn(true);
        when(mockDocSnapshot.data()).thenReturn(mockCrew.toFirestore());
        when(mockCrewDoc.get()).thenAnswer((_) async => mockDocSnapshot);
        when(mockOfflineDataService.storeCrewsOffline(any)).thenAnswer((_) async => Future.value());

        final result = await crewService.getCrew(crewId);

        expect(result?.id, crewId);
        verify(mockCrewDoc.get()).called(1);
        verify(mockOfflineDataService.storeCrewsOffline([mockCrew])).called(1);
        verifyNever(mockOfflineDataService.getOfflineCrews());
      });

      test('should get crew from offline cache when offline', () async {
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockOfflineDataService.getOfflineCrews()).thenAnswer((_) async => [mockCrew]);

        final result = await crewService.getCrew(crewId);

        expect(result?.id, crewId);
        verify(mockOfflineDataService.getOfflineCrews()).called(1);
        verifyNever(mockCrewDoc.get());
      });

      test('should return null if crew not found online or offline', () async {
        when(mockCrewDoc.get()).thenAnswer((_) async => MockDocumentSnapshot()); // Not exists
        when(mockOfflineDataService.getOfflineCrews()).thenAnswer((_) async => []);

        final resultOnline = await crewService.getCrew(crewId);
        expect(resultOnline, isNull);

        when(mockConnectivityService.isOnline).thenReturn(false);
        final resultOffline = await crewService.getCrew(crewId);
        expect(resultOffline, isNull);
      });

      // Add more test cases for FirebaseException, etc.
    });

    // Test cases for updateCrew
    group('updateCrew', () {
      final crewId = 'crew123';
      final updatedName = 'Updated Crew Name';
      final mockCrew = Crew(
        id: crewId,
        name: 'Original Crew Name',
        foremanId: 'foreman123',
        memberIds: ['foreman123'],
        preferences: CrewPreferences(jobTypes: [], minHourlyRate: 0, autoShareEnabled: false),
        createdAt: DateTime.now(),
        roles: {},
        stats: CrewStats(
          totalJobsShared: 0,
          totalApplications: 0,
          applicationRate: 0,
          averageMatchScore: 0,
          successfulPlacements: 0,
          responseTime: 0,
          jobTypeBreakdown: {},
          lastActivityAt: DateTime.now(),
          matchScores: [],
          successRate: 0,
        ),
        isActive: true,
      );

      test('should update crew name successfully when online', () async {
        when(CrewValidation.isCrewNameUnique(any, any)).thenAnswer((_) async => true);
        when(mockCrewDoc.update(any)).thenAnswer((_) async => Future.value());

        await crewService.updateCrew(crewId: crewId, name: updatedName);

        verify(mockCrewDoc.update({'name': updatedName})).called(1);
      });

      test('should throw CrewException if updated name is not unique when online', () async {
        when(CrewValidation.isCrewNameUnique(any, any)).thenAnswer((_) async => false);

        expect(
          () => crewService.updateCrew(crewId: crewId, name: updatedName),
          throwsA(isA<CrewException>().having(
            (e) => e.code,
            'code',
            'crew-name-exists',
          )),
        );
      });

      test('should update crew locally when offline', () async {
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockOfflineDataService.getOfflineCrews()).thenAnswer((_) async => [mockCrew]);
        when(mockOfflineDataService.storeCrewsOffline(any)).thenAnswer((_) async => Future.value());
        when(mockOfflineDataService.markDataDirty(any, any)).thenAnswer((_) async => Future.value());

        await crewService.updateCrew(crewId: crewId, name: updatedName);

        verify(mockOfflineDataService.storeCrewsOffline(argThat(contains(mockCrew.copyWith(name: updatedName))))).called(1);
        verify(mockOfflineDataService.markDataDirty('crew_$crewId', {'name': updatedName})).called(1);
        verifyNever(mockCrewDoc.update(any));
      });
    });

    // Test cases for deleteCrew
    group('deleteCrew', () {
      final crewId = 'crew123';
      final mockCrew = Crew(
        id: crewId,
        name: 'Test Crew',
        foremanId: 'foreman123',
        memberIds: ['foreman123'],
        preferences: CrewPreferences(jobTypes: [], minHourlyRate: 0, autoShareEnabled: false),
        createdAt: DateTime.now(),
        roles: {'foreman123': MemberRole.foreman},
        stats: CrewStats(
          totalJobsShared: 0,
          totalApplications: 0,
          applicationRate: 0,
          averageMatchScore: 0,
          successfulPlacements: 0,
          responseTime: 0,
          jobTypeBreakdown: {},
          lastActivityAt: DateTime.now(),
          matchScores: [],
          successRate: 0,
        ),
        isActive: true,
      );

      test('should soft delete crew successfully when online', () async {
        when(mockCrewDoc.update(any)).thenAnswer((_) async => Future.value());

        await crewService.deleteCrew(crewId);

        verify(mockCrewDoc.update({'isActive': false})).called(1);
      });

      test('should soft delete crew locally when offline', () async {
        when(mockConnectivityService.isOnline).thenReturn(false);
        when(mockOfflineDataService.getOfflineCrews()).thenAnswer((_) async => [mockCrew]);
        when(mockOfflineDataService.storeCrewsOffline(any)).thenAnswer((_) async => Future.value());
        when(mockOfflineDataService.markDataDirty(any, any)).thenAnswer((_) async => Future.value());

        await crewService.deleteCrew(crewId);

        verify(mockOfflineDataService.storeCrewsOffline(argThat(contains(mockCrew.copyWith(isActive: false))))).called(1);
        verify(mockOfflineDataService.markDataDirty('crew_$crewId', {'isActive': false})).called(1);
        verifyNever(mockCrewDoc.update(any));
      });
    });

    // Add more test groups for other methods (inviteMember, removeMember, etc.)
  });
}

// Mock for Firestore Transaction
class MockTransaction extends Mock implements Transaction {}

// Mock for CrewValidation (assuming it's a static class or has static methods)
class CrewValidation {
  static String? validateCrewName(String name) => null;
  static Future<bool> isCrewNameUnique(String name, FirebaseFirestore firestore) async => true;
  static bool isUnderMemberLimit(int currentMembers) => true;
}

// Mock for MessageValidation
class MessageValidation {
  static String? validateMessageContent(String content) => null;
}

// Mock for GeneralValidation
class GeneralValidation {
  static bool isValidEmail(String email) => true;
  static Future<void> exponentialBackoff({
    required int attempt,
    required Duration baseDelay,
    required int maxAttempts,
  }) async => Future.value();
}

// Mock for MemberPermissions (assuming it's a static class or has static methods)
class MemberPermissions {
  static MemberPermissions fromRole(MemberRole role) => MemberPermissions();
  Map<String, dynamic> toMap() => {};
}
