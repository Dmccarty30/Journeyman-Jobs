import 'package:flutter_test/flutter_test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/services/crew_auth_service.dart';
import 'package:journeyman_jobs/services/crew_permission_service.dart';
import 'package:journeyman_jobs/services/crew_auth_monitoring_service.dart';
import 'package:journeyman_jobs/services/user_discovery_service.dart';
import 'package:journeyman_jobs/services/crew_auth_integration_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';

void main() {
  group('Crew Authentication Services Tests', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CrewAuthService crewAuthService;
    late CrewPermissionService permissionService;
    late CrewAuthMonitoringService monitoringService;
    late UserDiscoveryService discoveryService;
    late CrewAuthIntegrationService integrationService;

    setUp(() {
      fakeFirestore = FakeFirebaseFirestore();
      crewAuthService = CrewAuthService(
        auth: _MockFirebaseAuth(),
        firestore: fakeFirestore,
      );
      permissionService = CrewPermissionService(
        authService: crewAuthService,
        firestore: fakeFirestore,
      );
      monitoringService = CrewAuthMonitoringService(
        firestore: fakeFirestore,
      );
      discoveryService = UserDiscoveryService(
        firestore: fakeFirestore,
      );
      integrationService = CrewAuthIntegrationService(
        authService: crewAuthService,
        permissionService: permissionService,
        monitoringService: monitoringService,
        discoveryService: discoveryService,
        firestore: fakeFirestore,
      );
    });

    group('CrewAuthService Tests', () {
      test('should verify crew member permissions correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        // Create test crew member
        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canInviteMembers': true,
            'canRemoveMembers': true,
            'canShareJobs': true,
            'canPostAnnouncements': true,
            'canEditCrewInfo': true,
            'canViewAnalytics': true,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final hasPermission = await crewAuthService.verifyCrewPermission(
          userId: userId,
          crewId: crewId,
          permission: CrewPermission.inviteMembers,
        );

        // Assert
        expect(hasPermission, isTrue);
      });

      test('should reject permissions for non-members', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        // Act
        final hasPermission = await crewAuthService.verifyCrewPermission(
          userId: userId,
          crewId: crewId,
          permission: CrewPermission.inviteMembers,
        );

        // Assert
        expect(hasPermission, isFalse);
      });

      test('should generate crew session token successfully', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {},
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final sessionToken = await crewAuthService.generateCrewSessionToken(
          crewId: crewId,
          userId: userId,
        );

        // Assert
        expect(sessionToken, isNotNull);
        expect(sessionToken.userId, equals(userId));
        expect(sessionToken.crewId, equals(crewId));
        expect(sessionToken.role, equals(MemberRole.foreman));
        expect(sessionToken.isExpired, isFalse);
      });

      test('should validate crew session token correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {},
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        final sessionToken = await crewAuthService.generateCrewSessionToken(
          crewId: crewId,
          userId: userId,
        );

        // Act
        final validation = await crewAuthService.verifyCrewSessionToken(sessionToken);

        // Assert
        expect(validation.isValid, isTrue);
        expect(validation.crewMember, isNotNull);
      });

      test('should reject expired session tokens', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        final expiredToken = CrewSessionToken(
          userId: userId,
          crewId: crewId,
          role: MemberRole.member,
          permissions: MemberPermissions.fromRole(MemberRole.member),
          issuedAt: DateTime.now().subtract(const Duration(hours: 2)),
          expiresAt: DateTime.now().subtract(const Duration(hours: 1)),
          token: 'expired_token',
        );

        // Act
        final validation = await crewAuthService.verifyCrewSessionToken(expiredToken);

        // Assert
        expect(validation.isValid, isFalse);
        expect(validation.reason, equals('Token expired'));
      });
    });

    group('CrewPermissionService Tests', () {
      test('should check UI element visibility correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canInviteMembers': true,
            'canRemoveMembers': true,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final canSeeInviteButton = await permissionService.shouldShowUIElement(
          userId: userId,
          crewId: crewId,
          uiElement: UIElement.inviteButton,
        );

        final canSeeAnalytics = await permissionService.shouldShowUIElement(
          userId: userId,
          crewId: crewId,
          uiElement: UIElement.analyticsTab,
        );

        // Assert
        expect(canSeeInviteButton, isTrue);
        expect(canSeeAnalytics, isTrue);
      });

      test('should get available operations for user role', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'lead',
          'joinedAt': Timestamp.now(),
          'permissions': {},
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final operations = await permissionService.getAvailableOperations(
          userId: userId,
          crewId: crewId,
        );

        // Assert
        expect(operations, contains(CrewOperation.inviteMembers));
        expect(operations, contains(CrewOperation.shareJobs));
        expect(operations, contains(CrewOperation.postAnnouncements));
        expect(operations, isNot(contains(CrewOperation.deleteCrew)));
      });

      test('should validate feature access correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'member',
          'joinedAt': Timestamp.now(),
          'permissions': {},
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final analyticsAccess = await permissionService.canAccessFeature(
          userId: userId,
          crewId: crewId,
          feature: CrewFeature.analytics,
        );

        final announcementsAccess = await permissionService.canAccessFeature(
          userId: userId,
          crewId: crewId,
          feature: CrewFeature.announcements,
        );

        // Assert
        expect(analyticsAccess.canAccess, isFalse);
        expect(announcementsAccess.canAccess, isFalse);
      });
    });

    group('UserDiscoveryService Tests', () {
      test('should search users by display name', () async {
        // Arrange
        await fakeFirestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'displayName': 'John Smith',
          'email': 'john@example.com',
          'localNumber': '124',
          'isActive': true,
        });

        await fakeFirestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'displayName': 'Jane Doe',
          'email': 'jane@example.com',
          'localNumber': '124',
          'isActive': true,
        });

        // Act
        final result = await discoveryService.searchUsers(
          query: 'John',
          limit: 10,
        );

        // Assert
        expect(result.users, isNotEmpty);
        expect(result.users.first.displayName, equals('John Smith'));
      });

      test('should search users by IBEW local number', () async {
        // Arrange
        await fakeFirestore.collection('users').doc('user1').set({
          'uid': 'user1',
          'displayName': 'John Smith',
          'email': 'john@example.com',
          'localNumber': '124',
          'isActive': true,
        });

        // Act
        final result = await discoveryService.searchUsers(
          query: 'IBEW 124',
          limit: 10,
        );

        // Assert
        expect(result.users, isNotEmpty);
        expect(result.users.first.localNumber, equals('124'));
      });

      test('should provide suggested users based on characteristics', () async {
        // Arrange
        const currentUserId = 'user1';

        await fakeFirestore.collection('users').doc(currentUserId).set({
          'uid': currentUserId,
          'displayName': 'John Smith',
          'email': 'john@example.com',
          'localNumber': '124',
          'certifications': ['Journeyman Wireman', 'OSHA 10'],
          'isActive': true,
        });

        await fakeFirestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'displayName': 'Jane Doe',
          'email': 'jane@example.com',
          'localNumber': '124',
          'certifications': ['Journeyman Wireman'],
          'isActive': true,
        });

        // Act
        final suggestions = await discoveryService.getSuggestedUsers(
          userId: currentUserId,
          limit: 5,
        );

        // Assert
        expect(suggestions, isNotEmpty);
      });
    });

    group('CrewAuthIntegrationService Tests', () {
      test('should handle complete user invitation flow', () async {
        // Arrange
        const inviterId = 'user1';
        const inviteeId = 'user2';
        const crewId = 'crew1';

        // Setup inviter with permissions
        await fakeFirestore.collection('crew_members').doc(inviterId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canInviteMembers': true,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Setup invitee
        await fakeFirestore.collection('users').doc(inviteeId).set({
          'uid': inviteeId,
          'displayName': 'Jane Doe',
          'email': 'jane@example.com',
          'isActive': true,
        });

        // Act
        final result = await integrationService.inviteUserToCrew(
          inviterId: inviterId,
          inviteeId: inviteeId,
          crewId: crewId,
          message: 'Join our crew!',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.invitationId, isNotNull);

        // Verify invitation was created
        final invitations = await fakeFirestore.collection('crew_invitations').get();
        expect(invitations.docs, isNotEmpty);
        expect(invitations.docs.first.data()['inviteeId'], equals(inviteeId));
      });

      test('should reject invitation for users without permission', () async {
        // Arrange
        const inviterId = 'user1';
        const inviteeId = 'user2';
        const crewId = 'crew1';

        // Setup inviter without permissions
        await fakeFirestore.collection('crew_members').doc(inviterId).set({
          'crewId': crewId,
          'role': 'member',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canInviteMembers': false,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final result = await integrationService.inviteUserToCrew(
          inviterId: inviterId,
          inviteeId: inviteeId,
          crewId: crewId,
        );

        // Assert
        expect(result.success, isFalse);
        expect(result.reason, contains('permission'));
      });

      test('should perform secure user search', () async {
        // Arrange
        const searcherId = 'user1';
        const crewId = 'crew1';

        // Setup searcher as crew member
        await fakeFirestore.collection('crew_members').doc(searcherId).set({
          'crewId': crewId,
          'role': 'member',
          'joinedAt': Timestamp.now(),
          'permissions': {},
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Setup users to search for
        await fakeFirestore.collection('users').doc('user2').set({
          'uid': 'user2',
          'displayName': 'John Smith',
          'email': 'john@example.com',
          'localNumber': '124',
          'isActive': true,
        });

        // Act
        final result = await integrationService.searchUsersSecurely(
          searcherId: searcherId,
          crewId: crewId,
          query: 'John',
        );

        // Assert
        expect(result.success, isTrue);
        expect(result.users, isNotEmpty);
      });

      test('should validate crew access correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        await fakeFirestore.collection('crew_members').doc(userId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canInviteMembers': true,
            'canViewAnalytics': true,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Act
        final accessResult = await integrationService.validateCrewAccess(
          userId: userId,
          crewId: crewId,
        );

        // Assert
        expect(accessResult.hasAccess, isTrue);
        expect(accessResult.role, equals(MemberRole.foreman));
        expect(accessResult.availableOperations, isNotEmpty);
      });

      test('should generate crew security report', () async {
        // Arrange
        const requesterId = 'user1';
        const crewId = 'crew1';

        // Setup requester with analytics permission
        await fakeFirestore.collection('crew_members').doc(requesterId).set({
          'crewId': crewId,
          'role': 'foreman',
          'joinedAt': Timestamp.now(),
          'permissions': {
            'canViewAnalytics': true,
          },
          'isAvailable': true,
          'lastActive': Timestamp.now(),
          'isActive': true,
        });

        // Setup crew
        await fakeFirestore.collection('crews').doc(crewId).set({
          'name': 'Test Crew',
          'memberCount': 5,
        });

        // Act
        final report = await integrationService.generateCrewSecurityReport(
          crewId: crewId,
          requesterId: requesterId,
          period: 7,
        );

        // Assert
        expect(report.success, isTrue);
        expect(report.crewId, equals(crewId));
        expect(report.memberCount, equals(5));
      });
    });

    group('Performance and Error Handling Tests', () {
      test('should handle rate limiting correctly', () async {
        // Arrange
        const userId = 'user1';
        const crewId = 'crew1';

        // Act & Assert
        // Multiple rapid calls should trigger rate limiting
        for (int i = 0; i < 15; i++) {
          final hasPermission = await crewAuthService.verifyCrewPermission(
            userId: userId,
            crewId: crewId,
            permission: CrewPermission.inviteMembers,
          );

          if (i >= 10) {
            // After 10 attempts, should be rate limited
            expect(hasPermission, isFalse);
          }
        }
      });

      test('should handle network errors gracefully', () async {
        // Arrange - create service with invalid Firestore instance
        final invalidService = CrewAuthService(
          auth: _MockFirebaseAuth(),
          firestore: _MockInvalidFirestore(),
        );

        // Act & Assert
        expect(
          () => invalidService.verifyCrewPermission(
            userId: 'user1',
            crewId: 'crew1',
            permission: CrewPermission.inviteMembers,
          ),
          throwsA(isA<Exception>()),
        );
      });

      test('should clean up resources properly', () async {
        // Arrange
        final searchService = UserDiscoveryService(firestore: fakeFirestore);

        // Act
        searchService.dispose();
        crewAuthService.dispose();

        // Assert - No exceptions should be thrown
        expect(() => searchService.dispose(), returnsNormally);
      });
    });

    tearDown(() {
      crewAuthService.dispose();
      permissionService.clearAllPermissionCaches();
    });
  });
}

// Mock implementations for testing

class _MockFirebaseAuth {
  String? _currentUserUid;

  set currentUserUid(String? uid) {
    _currentUserUid = uid;
  }

  String? get currentUserUid => _currentUserUid;
}

class _MockInvalidFirestore implements FirebaseFirestore {
  @override
  noSuchMethod(Invocation invocation) {
    throw Exception('Mock Firestore error');
  }
}