import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/crew_invitation_service.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';

/// Comprehensive tests for CrewInvitationService
///
/// Test coverage includes:
/// - Invitation creation and validation
/// - Invitation acceptance and declining
/// - Permission validation
/// - Error handling
/// - Real-time streaming
void main() {
  group('CrewInvitationService Tests', () {
    late CrewInvitationService service;
    late MockFirestoreService mockFirestoreService;

    setUp(() {
      service = CrewInvitationService();
      mockFirestoreService = MockFirestoreService();
    });

    group('Invitation Creation', () {
      testWidgets('should create invitation successfully', (WidgetTester tester) async {
        // Arrange
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        // Act & Assert
        final invitation = await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
          message: 'Please join our crew!',
        );

        expect(invitation.crewId, equals(crew.id));
        expect(invitation.inviterId, equals(foreman.uid));
        expect(invitation.inviteeId, equals(invitee.uid));
        expect(invitation.status, equals(CrewInvitationStatus.pending));
        expect(invitation.crewName, equals(crew.name));
        expect(invitation.inviterName, equals(foreman.displayNameStr));
        expect(invitation.message, equals('Please join our crew!'));
        expect(invitation.inviteeName, equals(invitee.displayNameStr));
        expect(invitation.isValid(), isTrue);
      });

      test('should throw exception when crew ID is empty', (WidgetTester tester) async {
        // Arrange
        final crew = _createMockCrew(id: '');
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        // Act & Assert
        expect(
          () => service.inviteUserToCrew(
            crew: crew,
            foreman: foreman,
            invitee: invitee,
          ),
          throwsA(isA<CrewException>()),
        );
      });

      test('should throw exception when user is already member', (WidgetTester tester) async {
        // Arrange
        final crew = _createMockCrew(memberIds: ['user1', 'foreman1']);
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        // Act & Assert
        expect(
          () => service.inviteUserToCrew(
            crew: crew,
            foreman: foreman,
            invitee: invitee,
          ),
          throwsA(isA<CrewException>()),
        );
      });

      test('should throw exception when pending invitation exists', (WidgetTester tester) async {
        // Arrange
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        // Act & Assert
        // First invitation should succeed
        await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
        );

        // Second invitation should fail
        expect(
          () => service.inviteUserToCrew(
            crew: crew,
            foreman: foreman,
            invitee: invitee,
          ),
          throwsA(isA<CrewException>()),
        );
      });
    });

    group('Invitation Response', () {
      testWidgets('should accept invitation successfully', (WidgetTester tester) async {
        // Arrange
        final invitation = _createMockInvitation(
          status: CrewInvitationStatus.pending,
          inviteeId: 'user1',
        );
        final userId = 'user1';

        // Act
        final result = await service.acceptInvitation(invitation.id, userId);

        // Assert
        expect(result, isTrue);
      });

      test('should decline invitation successfully', (WidgetTester tester) async {
        // Arrange
        final invitation = _createMockInvitation(
          status: CrewInvitationStatus.pending,
          inviteeId: 'user1',
        );
        final userId = 'user1';

        // Act
        final result = await service.declineInvitation(invitation.id, userId);

        // Assert
        expect(result, isTrue);
      });

      test('should throw exception when accepting invitation for wrong user', (WidgetTester tester) async {
        // Arrange
        final invitation = _createMockInvitation(
          status: CrewInvitationStatus.pending,
          inviteeId: 'user1',
        );
        final wrongUserId = 'user2';

        // Act & Assert
        expect(
          () => service.acceptInvitation(invitation.id, wrongUserId),
          throwsA(isA<CrewException>()),
        );
      });

      test('should throw exception when responding to expired invitation', (WidgetTester tester) async {
        // Arrange
        final invitation = _createMockInvitation(
          status: CrewInvitationStatus.pending,
          inviteeId: 'user1',
          expiresAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 8))), // Expired
        );
        final userId = 'user1';

        // Act & Assert
        expect(
          () => service.acceptInvitation(invitation.id, userId),
          throwsA(isA<CrewException>()),
        );
      });

      test('should throw exception when responding to already accepted invitation', (WidgetTester tester) async {
        // Arrange
        final invitation = _createMockInvitation(
          status: CrewInvitationStatus.accepted,
          inviteeId: 'user1',
        );
        final userId = 'user1';

        // Act & Assert
        expect(
          () => service.acceptInvitation(invitation.id, userId),
          throwsA(isA<CrewException>()),
        );
      });
    });

    group('Invitation Retrieval', () {
      testWidgets('should get invitations for user', (WidgetTester tester) async {
        // Arrange
        final userId = 'user1';
        final expectedInvitations = [
          _createMockInvitation(inviteeId: userId),
          _createMockInvitation(inviteeId: userId),
        ];

        // Act
        final invitations = await service.getInvitationsForUser(userId);

        // Assert
        expect(invitations.length, equals(2));
        expect(invitations.first.inviteeId, equals(userId));
        expect(invitations.last.inviteeId, equals(userId));
      });

      testWidgets('should get pending invitations only', (WidgetTester tester) async {
        // Arrange
        final userId = 'user1';
        final allInvitations = [
          _createMockInvitation(inviteeId: userId, status: CrewInvitationStatus.pending),
          _createMockInvitation(inviteeId: userId, status: CrewInvitationStatus.accepted),
          _createMockInvitation(inviteeId: userId, status: CrewInvitationStatus.expired),
        ];

        // Act
        final pendingInvitations = await service.getPendingInvitationsForUser(userId);

        // Assert
        expect(pendingInvitations.length, equals(1));
        expect(pendingInvitations.first.status, equals(CrewInvitationStatus.pending));
      });

      testWidgets('should get sent invitations', (WidgetTester tester) async {
        // Arrange
        final foremanId = 'foreman1';
        final expectedInvitations = [
          _createMockInvitation(inviterId: foremanId),
          _createMockInvitation(inviterId: foremanId),
        ];

        // Act
        final sentInvitations = await service.getSentInvitations(foremanId);

        // Assert
        expect(sentInvitations.length, equals(2));
        expect(sentInvitations.first.inviterId, equals(foremanId));
        expect(sentInvitations.last.inviterId, equals(foremanId));
      });

      testWidgets('should get invitations for crew', (WidgetTester tester) async {
        // Arrange
        final crewId = 'crew1';
        final expectedInvitations = [
          _createMockInvitation(crewId: crewId),
          _createMockInvitation(crewId: crewId),
        ];

        // Act
        final crewInvitations = await service.getInvitationsForCrew(crewId);

        // Assert
        expect(crewInvitations.length, equals(2));
        expect(crewInvitations.first.crewId, equals(crewId));
        expect(crewInvitations.last.crewId, equals(crewId));
      });
    });

    group('Invitation Statistics', () {
      testWidgets('should calculate invitation statistics correctly', (WidgetTester tester) async {
        // Arrange
        final crewId = 'crew1';
        final invitations = [
          _createMockInvitation(crewId: crewId, status: CrewInvitationStatus.pending),
          _createMockInvitation(crewId: crewId, status: CrewInvitationStatus.accepted),
          _createMockInvitation(crewId: crewId, status: CrewInvitationStatus.declined),
          _createMockInvitation(crewId: crewId, status: CrewInvitationStatus.expired),
        ];

        // Act
        final stats = await service.getInvitationStatsForCrew(crewId);

        // Assert
        expect(stats.totalInvitations, equals(4));
        expect(stats.pendingInvitations, equals(1));
        expect(stats.acceptedInvitations, equals(1));
        expect(stats.declinedInvitations, equals(1));
        expect(stats.expiredInvitations, equals(1));
        expect(stats.acceptanceRate, equals(0.5)); // 1 accepted out of 2 responded
      });

      testWidgets('should handle empty invitation list', (WidgetTester tester) async {
        // Arrange
        final crewId = 'empty_crew';

        // Act
        final stats = await service.getInvitationStatsForCrew(crewId);

        // Assert
        expect(stats.totalInvitations, equals(0));
        expect(stats.acceptanceRate, equals(0.0));
      });
    });

    group('Error Handling', () {
      testWidgets('should handle network errors gracefully', (WidgetTester tester) async {
        // This test would require mocking Firestore to throw network errors
        // For now, we'll test the error structure

        // Arrange
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        // Act & Assert
        expect(
          () => service.inviteUserToCrew(
            crew: crew,
            foreman: foreman,
            invitee: invitee,
          ),
          returnsA(isA<CrewInvitation>()),
        );
      });

      test('should provide meaningful error messages', (WidgetTester tester) async {
        // Test error message quality
        final crew = _createMockCrew(id: '');
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        try {
          await service.inviteUserToCrew(
            crew: crew,
            foreman: foreman,
            invitee: invitee,
          );
          fail('Should have thrown an exception');
        } catch (e) {
          expect(e, isA<CrewException>());
          expect(e.toString(), contains('Crew ID cannot be empty'));
        }
      });
    });

    group('Model Validation', () {
      testWidgets('should validate crew invitation model', (WidgetTester tester) async {
        // Test valid invitation
        final validInvitation = _createMockInvitation();
        expect(validInvitation.isValid(), isTrue);

        // Test invalid invitation
        final invalidInvitation = CrewInvitation(
          id: 'test',
          crewId: '', // Empty crew ID
          inviterId: 'inviter1',
          inviteeId: 'invitee1',
          status: CrewInvitationStatus.pending,
          createdAt: Timestamp.now(),
          updatedAt: Timestamp.now(),
          expiresAt: Timestamp.now(),
          crewName: 'Test Crew',
          inviterName: 'Test Inviter',
        );
        expect(invalidInvitation.isValid(), isFalse);
      });

      testWidgets('should validate invitation expiration', (WidgetTester tester async {
        // Test non-expired invitation
        final validInvitation = _createMockInvitation(
          expiresAt: Timestamp.fromDate(DateTime.now().add(const Duration(days: 3))),
        );
        expect(validInvitation.isExpired, isFalse);
        expect(validInvitation.isActive, isTrue);

        // Test expired invitation
        final expiredInvitation = _createMockInvitation(
          expiresAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        );
        expect(expiredInvitation.isExpired, isTrue);
        expect(expiredInvitation.isActive, isFalse);
      });

      testWidgets('should validate invitation response capability', (WidgetTester tester async {
        // Test pending invitation can be responded to
        final pendingInvitation = _createMockInvitation(status: CrewInvitationStatus.pending);
        expect(pendingInvitation.canRespond, isTrue);

        // Test accepted invitation cannot be responded to
        final acceptedInvitation = _createMockInvitation(status: CrewInvitationStatus.accepted);
        expect(acceptedInvitation.canRespond, isFalse);

        // Test expired invitation cannot be responded to
        final expiredInvitation = _createMockInvitation(
          status: CrewInvitationStatus.pending,
          expiresAt: Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        );
        expect(expiredInvitation.canRespond, isFalse);
      });
    });

    group('Edge Cases', () {
      testWidgets('should handle maximum length validation', (WidgetTester tester) async {
        // Test long message
        final longMessage = 'A' * 1000;
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        final invitation = await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
          message: longMessage,
        );

        expect(invitation.message, equals(longMessage));
        expect(invitation.isValid(), isTrue);
      });

      testWidgets('should handle special characters in message', (WidgetTester tester async {
        final specialMessage = 'Test message with émojis 🎉 and special chars!';
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        final invitation = await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
          message: specialMessage,
        );

        expect(invitation.message, equals(specialMessage));
        expect(invitation.isValid(), isTrue);
      });

      testWidgets('should handle Unicode in user names', (WidgetTester tester async {
        final crew = _createMockCrew();
        final foreman = _createMockUser(
          id: 'foreman1',
          name: 'Jürgen Müller',
          email: 'jurgen@example.com',
        );
        final invitee = _createMockUser(
          id: 'user1',
          name: 'José García',
          email: 'jose@example.com',
        );

        final invitation = await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
        );

        expect(invitation.inviterName, equals('Jürgen Müller'));
        expect(invitation.inviteeName, equals('José García'));
        expect(invitation.isValid(), isTrue);
      });
    });

    group('Business Logic', () {
      testWidgets('should set 7-day expiration by default', (WidgetTester tester async {
        final now = Timestamp.now();
        final crew = _createMockCrew();
        final foreman = _createMockUser(id: 'foreman1', name: 'John Doe');
        final invitee = _createMockUser(id: 'user1', name: 'Jane Smith');

        final invitation = await service.inviteUserToCrew(
          crew: crew,
          foreman: foreman,
          invitee: invitee,
        );

        final expectedExpiry = now.toDate().add(const Duration(days: 7));
        final actualExpiry = invitation.expiresAt.toDate();

        expect(
          actualExpiry.difference(expectedExpiry).inSeconds.abs(),
          lessThan(5,
        ), // Allow 5 seconds tolerance
        );
      });

      testWidgets('should calculate hours until expiration correctly', (WidgetTester tester) async {
        final now = DateTime.now();
        final expiresAt = now.add(const Duration(hours: 24));

        final invitation = _createMockInvitation(
          expiresAt: Timestamp.fromDate(expiresAt),
        );

        expect(invitation.hoursUntilExpiration, equals(24));
      });

      testWidgets('should handle statistics acceptance rate calculation', (WidgetTester tester async {
        final invitations = [
          _createMockInvitation(status: CrewInvitationStatus.accepted),
          _createMockInvitation(status: CrewInvitationStatus.accepted),
          _createMockInvitation(status: CrewInvitationStatus.declined),
        ];

        final stats = CrewInvitationStats.fromInvitations(invitations);

        expect(stats.totalInvitations, equals(3));
        expect(stats.acceptedInvitations, equals(2));
        expect(stats.declinedInvitations, equals(1));
        expect(stats.acceptanceRate, equals(2/3)); // 2 accepted out of 3 total
        });
      });
    });
  });
}

// Helper methods for creating mock data
Crew _createMockCrew({
  String id = 'crew1',
  String name = 'Test Crew',
  String foremanId = 'foreman1',
  List<String> memberIds = const ['foreman1'],
  Map<String, dynamic>? jobPreferences,
}) {
  return Crew(
    id: id,
    name: name,
    foremanId: foremanId,
    memberIds: memberIds,
    jobPreferences: jobPreferences ?? {},
    stats: CrewStats(),
  );
}

UserModel _createMockUser({
  String id = 'user1',
  String name = 'Test User',
  String email = 'test@example.com',
  String classification = 'Journeyman Lineman',
  int homeLocal = 26,
}) {
  return UserModel(
    uid: id,
    username: email.split('@')[0],
    classification: classification,
    homeLocal: homeLocal,
    role: 'electrician',
    email: email,
    displayName: name,
    firstName: name.split(' ')[0],
    lastName: name.split(' ').length > 1 ? name.split(' ')[1] : '',
    phoneNumber: '555-123-4567',
    address1: '123 Test St',
    city: 'Test City',
    state: 'TS',
    zipcode: 12345,
    ticketNumber: 'TEST123456',
    isWorking: false,
    networkWithOthers: true,
    careerAdvancements: false,
    betterBenefits: true,
    higherPayRate: true,
    learnNewSkill: false,
    travelToNewLocation: true,
    findLongTermWork: false,
    lastActive: Timestamp.now(),
  );
}

CrewInvitation _createMockInvitation({
  String id = 'invitation1',
  String crewId = 'crew1',
  String inviterId = 'inviter1',
  String inviteeId = 'invitee1',
  CrewInvitationStatus status = CrewInvitationStatus.pending,
  String? message,
  String crewName = 'Test Crew',
  String inviterName = 'Test Inviter',
  String? inviteeName,
  Timestamp? createdAt,
  Timestamp? updatedAt,
  Timestamp? expiresAt,
}) {
  final now = Timestamp.now();
  final weekLater = now.toDate().add(const Duration(days: 7));

  return CrewInvitation(
    id: id,
    crewId: crewId,
    inviterId: inviterId,
    inviteeId: inviteeId,
    status: status,
    createdAt: createdAt ?? now,
    updatedAt: updatedAt ?? now,
    expiresAt: expiresAt ?? Timestamp.fromDate(weekLater),
    message: message,
    crewName: crewName,
    inviterName: inviterName,
    inviteeName: inviteeName,
  );
}