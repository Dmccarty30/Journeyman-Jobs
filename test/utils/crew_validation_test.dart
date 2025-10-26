import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/utils/crew_validation.dart';

void main() {
  group('CrewValidation', () {
    group('validateCrewCreation', () {
      test('should pass validation for valid crew creation data', () {
        // Arrange
        final name = 'Test Crew';
        final foremanId = 'test-foreman-id';
        final jobPreferences = {'type': 'commercial', 'location': 'NYC'};

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
          jobPreferences: jobPreferences,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should fail validation for empty crew name', () {
        // Arrange
        final name = '';
        final foremanId = 'test-foreman-id';

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Crew name is required'));
      });

      test('should fail validation for crew name that is too long', () {
        // Arrange
        final name = 'a' * 51; // Exceeds max length of 50
        final foremanId = 'test-foreman-id';

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Crew name is too long'));
      });

      test('should fail validation for empty foreman ID', () {
        // Arrange
        final name = 'Test Crew';
        final foremanId = '';

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Foreman ID is required'));
      });

      test('should fail validation for invalid characters in crew name', () {
        // Arrange
        final name = 'Test<Crew>'; // Contains invalid characters
        final foremanId = 'test-foreman-id';

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Crew name contains invalid characters'));
      });

      test('should handle null job preferences gracefully', () {
        // Arrange
        final name = 'Test Crew';
        final foremanId = 'test-foreman-id';

        // Act
        final result = CrewValidation.validateCrewCreation(
          name: name,
          foremanId: foremanId,
          jobPreferences: null,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
      });
    });

    group('validateCrewUpdate', () {
      test('should pass validation for valid crew update data', () {
        // Arrange
        final name = 'Updated Crew Name';
        final jobPreferences = {'type': 'residential', 'location': 'LA'};

        // Act
        final result = CrewValidation.validateCrewUpdate(
          name: name,
          jobPreferences: jobPreferences,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should pass validation when all parameters are null', () {
        // Act
        final result = CrewValidation.validateCrewUpdate();

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should validate only provided fields', () {
        // Arrange
        final invalidName = ''; // Invalid name
        final validJobPreferences = {'type': 'commercial'};

        // Act
        final result = CrewValidation.validateCrewUpdate(
          name: invalidName,
          jobPreferences: validJobPreferences,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Crew name is required'));
      });
    });

    group('validateCrewMemberOperation', () {
      test('should allow foreman to add members', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final memberId = 'test-member-id';
        final currentMemberIds = [foremanId];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: memberId,
          currentMemberIds: currentMemberIds,
          operation: 'add',
        );

        // Assert
        expect(result, isNull);
      });

      test('should prevent non-foreman from adding members', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final memberId = 'test-member-id';
        final currentMemberIds = [foremanId];
        final actingUserId = 'unauthorized-user';

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: memberId,
          currentMemberIds: currentMemberIds,
          operation: 'add',
          actingUserId: actingUserId,
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Only the crew foreman can perform this operation'));
      });

      test('should prevent adding members who are already in the crew', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final memberId = 'existing-member-id';
        final currentMemberIds = [foremanId, memberId];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: memberId,
          currentMemberIds: currentMemberIds,
          operation: 'add',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('User is already a member of this crew'));
      });

      test('should prevent removing foreman from crew', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final currentMemberIds = [foremanId, 'member1', 'member2'];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: foremanId, // Trying to remove foreman
          currentMemberIds: currentMemberIds,
          operation: 'remove',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Cannot remove the crew foreman'));
      });

      test('should prevent removing non-members from crew', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final memberId = 'non-member-id';
        final currentMemberIds = [foremanId];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: memberId,
          currentMemberIds: currentMemberIds,
          operation: 'remove',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('User is not a member of this crew'));
      });

      test('should allow members to leave crew voluntarily', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final memberId = 'test-member-id';
        final currentMemberIds = [foremanId, memberId];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: memberId,
          currentMemberIds: currentMemberIds,
          operation: 'leave',
        );

        // Assert
        expect(result, isNull);
      });

      test('should prevent foreman from leaving crew with other members', () {
        // Arrange
        final crewId = 'test-crew-id';
        final foremanId = 'test-foreman-id';
        final currentMemberIds = [foremanId, 'member1'];

        // Act
        final result = CrewValidation.validateCrewMemberOperation(
          crewId: crewId,
          foremanId: foremanId,
          memberId: foremanId,
          currentMemberIds: currentMemberIds,
          operation: 'leave',
        );

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Foreman cannot leave crew with other members'));
      });
    });

    group('validateInvitationCreation', () {
      test('should pass validation for valid invitation', () {
        // Arrange
        final crew = createMockCrew(id: 'test-crew-id', foremanId: 'foreman-id');
        final invitee = createMockUser(id: 'invitee-id');
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitations = <CrewInvitation>[];

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should prevent inviting users already in crew', () {
        // Arrange
        final crew = createMockCrew(
          id: 'test-crew-id',
          foremanId: 'foreman-id',
          memberIds: ['foreman-id', 'existing-member-id'],
        );
        final invitee = createMockUser(id: 'existing-member-id');
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitations = <CrewInvitation>[];

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('User is already a member of this crew'));
      });

      test('should prevent inviting oneself', () {
        // Arrange
        final crew = createMockCrew(id: 'test-crew-id', foremanId: 'foreman-id');
        final invitee = createMockUser(id: 'foreman-id'); // Same as inviter
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitations = <CrewInvitation>[];

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Cannot invite yourself to a crew'));
      });

      test('should prevent duplicate pending invitations', () {
        // Arrange
        final crew = createMockCrew(id: 'test-crew-id', foremanId: 'foreman-id');
        final invitee = createMockUser(id: 'invitee-id');
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitation = createMockInvitation(
          crewId: 'test-crew-id',
          inviteeId: 'invitee-id',
          status: CrewInvitationStatus.pending,
        );
        final existingInvitations = [existingInvitation];

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Invitation already exists'));
      });

      test('should allow re-inviting after declined invitation', () {
        // Arrange
        final crew = createMockCrew(id: 'test-crew-id', foremanId: 'foreman-id');
        final invitee = createMockUser(id: 'invitee-id');
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitation = createMockInvitation(
          crewId: 'test-crew-id',
          inviteeId: 'invitee-id',
          status: CrewInvitationStatus.declined,
        );
        final existingInvitations = [existingInvitation];

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should validate invitation message length', () {
        // Arrange
        final crew = createMockCrew(id: 'test-crew-id', foremanId: 'foreman-id');
        final invitee = createMockUser(id: 'invitee-id');
        final inviter = createMockUser(id: 'foreman-id');
        final existingInvitations = <CrewInvitation>[];
        final longMessage = 'a' * 501; // Exceeds max length

        // Act
        final result = CrewValidation.validateInvitationCreation(
          crew: crew,
          invitee: invitee,
          inviter: inviter,
          existingInvitations: existingInvitations,
          message: longMessage,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Invitation message is too long'));
      });
    });

    group('validateUser', () {
      test('should pass validation for valid user', () {
        // Arrange
        final user = createMockUser(
          id: 'test-user-id',
          email: 'test@example.com',
          displayName: 'Test User',
        );

        // Act
        final result = CrewValidation.validateUser(user: user);

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should fail validation for user without ID', () {
        // Arrange
        final user = createMockUser(id: '');

        // Act
        final result = CrewValidation.validateUser(user: user);

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('User ID is required'));
      });

      test('should fail validation for user without email', () {
        // Arrange
        final user = createMockUser(
          id: 'test-user-id',
          email: '',
        );

        // Act
        final result = CrewValidation.validateUser(user: user);

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('User email is required'));
      });

      test('should fail validation for invalid email format', () {
        // Arrange
        final user = createMockUser(
          id: 'test-user-id',
          email: 'invalid-email',
        );

        // Act
        final result = CrewValidation.validateUser(user: user);

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Invalid email format'));
      });
    });

    group('validateCrewId', () {
      test('should pass validation for valid crew ID', () {
        // Arrange
        final crewId = 'valid-crew-id-12345';

        // Act
        final result = CrewValidation.validateCrewId(crewId);

        // Assert
        expect(result, isNull);
      });

      test('should fail validation for empty crew ID', () {
        // Arrange
        final crewId = '';

        // Act
        final result = CrewValidation.validateCrewId(crewId);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Crew ID is required'));
      });

      test('should fail validation for null crew ID', () {
        // Act
        final result = CrewValidation.validateCrewId(null);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Crew ID is required'));
      });

      test('should fail validation for too short crew ID', () {
        // Arrange
        final crewId = 'short';

        // Act
        final result = CrewValidation.validateCrewId(crewId);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Invalid crew ID format'));
      });
    });

    group('validateUserId', () {
      test('should pass validation for valid user ID', () {
        // Arrange
        final userId = 'valid-user-id-12345';

        // Act
        final result = CrewValidation.validateUserId(userId);

        // Assert
        expect(result, isNull);
      });

      test('should fail validation for empty user ID', () {
        // Arrange
        final userId = '';

        // Act
        final result = CrewValidation.validateUserId(userId);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('User ID is required'));
      });

      test('should fail validation for null user ID', () {
        // Act
        final result = CrewValidation.validateUserId(null);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('User ID is required'));
      });
    });

    group('validateMessage', () {
      test('should pass validation for valid text message', () {
        // Arrange
        final content = 'Valid message content';

        // Act
        final result = CrewValidation.validateMessage(
          content: content,
          type: CrewMessageType.text,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should fail validation for empty text message', () {
        // Arrange
        final content = '';

        // Act
        final result = CrewValidation.validateMessage(
          content: content,
          type: CrewMessageType.text,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Message content is required'));
      });

      test('should fail validation for message that is too long', () {
        // Arrange
        final content = 'a' * 1001; // Exceeds max length

        // Act
        final result = CrewValidation.validateMessage(
          content: content,
          type: CrewMessageType.text,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Message content is too long'));
      });

      test('should pass validation for image message without content', () {
        // Arrange
        final mediaUrl = 'https://example.com/image.jpg';

        // Act
        final result = CrewValidation.validateMessage(
          content: '', // Content optional for media messages
          type: CrewMessageType.image,
          mediaUrl: mediaUrl,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should fail validation for image message without media URL', () {
        // Act
        final result = CrewValidation.validateMessage(
          content: 'Check out this image',
          type: CrewMessageType.image,
          mediaUrl: '', // Required for image messages
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Media URL is required for media messages'));
      });

      test('should fail validation for location message without coordinates', () {
        // Act
        final result = CrewValidation.validateMessage(
          content: 'My location',
          type: CrewMessageType.location,
          metadata: {}, // Missing coordinates
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Location coordinates are required'));
      });

      test('should pass validation for location message with valid coordinates', () {
        // Arrange
        final metadata = {
          'latitude': 40.7128,
          'longitude': -74.0060,
        };

        // Act
        final result = CrewValidation.validateMessage(
          content: 'My location',
          type: CrewMessageType.location,
          metadata: metadata,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });
    });

    group('validateMessageReaction', () {
      test('should pass validation for valid emoji reaction', () {
        // Arrange
        final emoji = '👍';

        // Act
        final result = CrewValidation.validateMessageReaction(emoji);

        // Assert
        expect(result, isNull);
      });

      test('should fail validation for empty reaction', () {
        // Arrange
        final emoji = '';

        // Act
        final result = CrewValidation.validateMessageReaction(emoji);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Reaction emoji is required'));
      });

      test('should fail validation for invalid emoji format', () {
        // Arrange
        final emoji = 'invalid-emoji';

        // Act
        final result = CrewValidation.validateMessageReaction(emoji);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Invalid reaction emoji format'));
      });

      test('should fail validation for reaction that is too long', () {
        // Arrange
        final emoji = '👍' * 10; // Too many characters

        // Act
        final result = CrewValidation.validateMessageReaction(emoji);

        // Assert
        expect(result, isNotNull);
        expect(result, contains('Reaction emoji is too long'));
      });
    });

    group('validateMessageEdit', () {
      test('should allow editing text messages', () {
        // Arrange
        final message = createMockCrewMessage(type: CrewMessageType.text);

        // Act
        final result = CrewValidation.validateMessageEdit(
          message: message,
          newContent: 'Updated content',
          editorId: message.senderId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isTrue);
        expect(CrewValidation.getErrorMessages(result), isEmpty);
      });

      test('should prevent editing non-text messages', () {
        // Arrange
        final message = createMockCrewMessage(type: CrewMessageType.image);

        // Act
        final result = CrewValidation.validateMessageEdit(
          message: message,
          newContent: 'Updated caption',
          editorId: message.senderId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Only text messages can be edited'));
      });

      test('should prevent editing other users messages', () {
        // Arrange
        final message = createMockCrewMessage(type: CrewMessageType.text);

        // Act
        final result = CrewValidation.validateMessageEdit(
          message: message,
          newContent: 'Updated content',
          editorId: 'different-user-id',
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Can only edit your own messages'));
      });

      test('should prevent editing deleted messages', () {
        // Arrange
        final message = createMockCrewMessage(
          type: CrewMessageType.text,
          deletedAt: DateTime.now(),
        );

        // Act
        final result = CrewValidation.validateMessageEdit(
          message: message,
          newContent: 'Updated content',
          editorId: message.senderId,
        );

        // Assert
        expect(CrewValidation.isValid(result), isFalse);
        expect(CrewValidation.getErrorMessages(result), contains('Cannot edit deleted messages'));
      });
    });
  });
}

// Helper methods for creating mock data

Crew createMockCrew({
  String? id,
  String? foremanId,
  String name = 'Test Crew',
  List<String>? memberIds,
}) {
  return Crew(
    id: id ?? 'test-crew-id',
    name: name,
    foremanId: foremanId ?? 'test-foreman-id',
    memberIds: memberIds ?? ['test-foreman-id'],
    jobPreferences: const {},
    stats: CrewStats(),
    createdAt: DateTime.now(),
    updatedAt: DateTime.now(),
  );
}

UserModel createMockUser({
  String? id,
  String? email,
  String? displayName,
}) {
  return UserModel(
    uid: id ?? 'test-user-id',
    email: email ?? 'test@example.com',
    displayName: displayName ?? 'Test User',
    unionLocal: 'Local 123',
    classification: 'Journeyman',
    isProfileComplete: true,
    createdAt: DateTime.now(),
    lastLoginAt: DateTime.now(),
    isActive: true,
    settings: const {},
    preferences: const {},
    roles: const [],
  );
}

CrewInvitation createMockInvitation({
  String? id,
  String? crewId,
  String? inviteeId,
  CrewInvitationStatus status = CrewInvitationStatus.pending,
}) {
  return CrewInvitation(
    id: id ?? 'test-invitation-id',
    crewId: crewId ?? 'test-crew-id',
    crewName: 'Test Crew',
    inviterId: 'test-inviter-id',
    inviterName: 'Test Inviter',
    inviteeId: inviteeId ?? 'test-invitee-id',
    inviteeEmail: 'invitee@example.com',
    status: status,
    message: 'Please join our crew',
    createdAt: DateTime.now(),
    expiresAt: DateTime.now().add(const Duration(days: 7)),
    respondedAt: null,
  );
}

CrewMessage createMockCrewMessage({
  String? id,
  String? crewId,
  String? senderId,
  CrewMessageType type = CrewMessageType.text,
  String content = 'Test message',
  DateTime? deletedAt,
}) {
  return CrewMessage(
    id: id ?? 'test-message-id',
    crewId: crewId ?? 'test-crew-id',
    senderId: senderId ?? 'test-sender-id',
    content: content,
    type: type,
    createdAt: DateTime.now(),
    editedAt: null,
    isEdited: false,
    mediaUrl: null,
    metadata: const {},
    readStatus: [],
    reactions: {},
    replyToId: null,
    deletedAt: deletedAt,
  );
}