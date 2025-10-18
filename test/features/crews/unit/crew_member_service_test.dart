import 'package:test/test.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';

void main() {
  group('CrewMember Management Tests', () {
    test('MemberPermissions fromRole should create correct permissions for foreman', () {
      // Arrange & Act
      final permissions = MemberPermissions.fromRole(MemberRole.foreman);

      // Assert
      expect(permissions.canInviteMembers, isTrue);
      expect(permissions.canRemoveMembers, isTrue);
      expect(permissions.canShareJobs, isTrue);
      expect(permissions.canPostAnnouncements, isTrue);
      expect(permissions.canEditCrewInfo, isTrue);
      expect(permissions.canViewAnalytics, isTrue);
    });

    test('MemberPermissions fromRole should create correct permissions for lead', () {
      // Arrange & Act
      final permissions = MemberPermissions.fromRole(MemberRole.lead);

      // Assert
      expect(permissions.canInviteMembers, isTrue);
      expect(permissions.canRemoveMembers, isFalse);
      expect(permissions.canShareJobs, isTrue);
      expect(permissions.canPostAnnouncements, isTrue);
      expect(permissions.canEditCrewInfo, isFalse);
      expect(permissions.canViewAnalytics, isFalse);
    });

    test('MemberPermissions fromRole should create correct permissions for member', () {
      // Arrange & Act
      final permissions = MemberPermissions.fromRole(MemberRole.member);

      // Assert
      expect(permissions.canInviteMembers, isFalse);
      expect(permissions.canRemoveMembers, isFalse);
      expect(permissions.canShareJobs, isFalse);
      expect(permissions.canPostAnnouncements, isFalse);
      expect(permissions.canEditCrewInfo, isFalse);
      expect(permissions.canViewAnalytics, isFalse);
    });

    test('MemberPermissions fromMap should create permissions from map data', () {
      // Arrange
      final map = {
        'canInviteMembers': true,
        'canRemoveMembers': false,
        'canShareJobs': true,
        'canPostAnnouncements': false,
        'canEditCrewInfo': true,
        'canViewAnalytics': false,
      };

      // Act
      final permissions = MemberPermissions.fromMap(map);

      // Assert
      expect(permissions.canInviteMembers, isTrue);
      expect(permissions.canRemoveMembers, isFalse);
      expect(permissions.canShareJobs, isTrue);
      expect(permissions.canPostAnnouncements, isFalse);
      expect(permissions.canEditCrewInfo, isTrue);
      expect(permissions.canViewAnalytics, isFalse);
    });

    test('MemberPermissions toMap should convert to map correctly', () {
      // Arrange
      final permissions = MemberPermissions(
        canInviteMembers: true,
        canRemoveMembers: false,
        canShareJobs: true,
        canPostAnnouncements: false,
        canEditCrewInfo: true,
        canViewAnalytics: false,
      );

      // Act
      final map = permissions.toMap();

      // Assert
      expect(map, isA<Map<String, dynamic>>());
      expect(map['canInviteMembers'], isTrue);
      expect(map['canRemoveMembers'], isFalse);
      expect(map['canShareJobs'], isTrue);
      expect(map['canPostAnnouncements'], isFalse);
      expect(map['canEditCrewInfo'], isTrue);
      expect(map['canViewAnalytics'], isFalse);
    });

    test('MemberPermissions copyWith should update permissions correctly', () {
      // Arrange
      final originalPermissions = MemberPermissions.fromRole(MemberRole.member);
      
      // Act
      final updatedPermissions = originalPermissions.copyWith(
        canInviteMembers: true,
        canShareJobs: true,
      );

      // Assert
      expect(updatedPermissions.canInviteMembers, isTrue);
      expect(updatedPermissions.canShareJobs, isTrue);
      // Other permissions should remain as member role defaults
      expect(updatedPermissions.canRemoveMembers, isFalse);
      expect(updatedPermissions.canPostAnnouncements, isFalse);
    });

    test('CrewMember should be created with correct properties', () {
      // Arrange & Act
      final member = _createTestCrewMember();

      // Assert
      expect(member.userId, equals('test-user-123'));
      expect(member.crewId, equals('test-crew-123'));
      expect(member.role, equals(MemberRole.member));
      expect(member.isAvailable, isTrue);
      expect(member.permissions, isA<MemberPermissions>());
      expect(member.lastActive, isA<DateTime>());
    });

    test('CrewMember hasPermission should check permissions correctly', () {
      // Arrange
      final foremanMember = CrewMember(
        userId: 'user-1',
        crewId: 'crew-1',
        role: MemberRole.foreman,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.foreman),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      final regularMember = CrewMember(
        userId: 'user-2',
        crewId: 'crew-1',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.member),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      // Act & Assert - Foreman permissions
      expect(foremanMember.hasPermission('canInviteMembers'), isTrue);
      expect(foremanMember.hasPermission('canRemoveMembers'), isTrue);
      expect(foremanMember.hasPermission('canShareJobs'), isTrue);
      expect(foremanMember.hasPermission('canPostAnnouncements'), isTrue);
      expect(foremanMember.hasPermission('canEditCrewInfo'), isTrue);
      expect(foremanMember.hasPermission('canViewAnalytics'), isTrue);

      // Act & Assert - Regular member permissions
      expect(regularMember.hasPermission('canInviteMembers'), isFalse);
      expect(regularMember.hasPermission('canRemoveMembers'), isFalse);
      expect(regularMember.hasPermission('canShareJobs'), isFalse);
      expect(regularMember.hasPermission('canPostAnnouncements'), isFalse);
      expect(regularMember.hasPermission('canEditCrewInfo'), isFalse);
      expect(regularMember.hasPermission('canViewAnalytics'), isFalse);

      // Act & Assert - Invalid permission
      expect(foremanMember.hasPermission('invalid_permission'), isFalse);
      expect(regularMember.hasPermission('invalid_permission'), isFalse);
    });

    test('CrewMember updateRole should update role and permissions', () {
      // Arrange
      final member = _createTestCrewMember();

      // Act
      final updatedMember = member.updateRole(MemberRole.lead);

      // Assert
      expect(updatedMember.role, equals(MemberRole.lead));
      expect(updatedMember.permissions.canInviteMembers, isTrue);
      expect(updatedMember.permissions.canShareJobs, isTrue);
      expect(updatedMember.permissions.canPostAnnouncements, isTrue);
      expect(updatedMember.permissions.canRemoveMembers, isFalse);
      expect(updatedMember.permissions.canEditCrewInfo, isFalse);
      expect(updatedMember.permissions.canViewAnalytics, isFalse);
    });

    test('CrewMember markActive should update availability and lastActive', () {
      // Arrange
      final member = _createTestCrewMember();
      final originalLastActive = member.lastActive;

      // Act
      final updatedMember = member.markActive();

      // Assert
      expect(updatedMember.isAvailable, isTrue);
      expect(updatedMember.lastActive.isAfter(originalLastActive), isTrue);
    });

    test('CrewMember markInactive should update availability', () {
      // Arrange
      final member = _createTestCrewMember();

      // Act
      final updatedMember = member.markInactive();

      // Assert
      expect(updatedMember.isAvailable, isFalse);
      // lastActive should remain the same
      expect(updatedMember.lastActive, equals(member.lastActive));
    });

    test('CrewMember copyWith should update properties correctly', () {
      // Arrange
      final originalMember = _createTestCrewMember();
      const newUserId = 'new-user-123';
      const newRole = MemberRole.lead;
      final newPermissions = MemberPermissions.fromRole(MemberRole.lead);

      // Act
      final updatedMember = originalMember.copyWith(
        userId: newUserId,
        role: newRole,
        permissions: newPermissions,
        isAvailable: false,
      );

      // Assert
      expect(updatedMember.userId, equals(newUserId));
      expect(updatedMember.role, equals(newRole));
      expect(updatedMember.permissions, equals(newPermissions));
      expect(updatedMember.isAvailable, isFalse);
      // Other properties should remain unchanged
      expect(updatedMember.crewId, equals(originalMember.crewId));
      expect(updatedMember.joinedAt, equals(originalMember.joinedAt));
    });

    test('CrewMember toFirestore should convert to map correctly', () {
      // Arrange
      final member = _createTestCrewMember();

      // Act
      final firestoreData = member.toFirestore();

      // Assert
      expect(firestoreData, isA<Map<String, dynamic>>());
      expect(firestoreData['crewId'], equals('test-crew-123'));
      expect(firestoreData['role'], equals('member'));
      expect(firestoreData['joinedAt'], isA<Timestamp>());
      expect(firestoreData['permissions'], isA<Map>());
      expect(firestoreData['isAvailable'], isTrue);
      expect(firestoreData['lastActive'], isA<Timestamp>());
    });
  });

  group('Member Role Management Tests', () {
    test('Should correctly identify member capabilities by role', () {
      // Arrange
      final foreman = CrewMember(
        userId: 'foreman-1',
        crewId: 'crew-1',
        role: MemberRole.foreman,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.foreman),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      final lead = CrewMember(
        userId: 'lead-1',
        crewId: 'crew-1',
        role: MemberRole.lead,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.lead),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      final member = CrewMember(
        userId: 'member-1',
        crewId: 'crew-1',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.member),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      // Act & Assert - Invitation capabilities
      expect(foreman.permissions.canInviteMembers, isTrue);
      expect(lead.permissions.canInviteMembers, isTrue);
      expect(member.permissions.canInviteMembers, isFalse);

      // Act & Assert - Job sharing capabilities
      expect(foreman.permissions.canShareJobs, isTrue);
      expect(lead.permissions.canShareJobs, isTrue);
      expect(member.permissions.canShareJobs, isFalse);

      // Act & Assert - Member removal capabilities
      expect(foreman.permissions.canRemoveMembers, isTrue);
      expect(lead.permissions.canRemoveMembers, isFalse);
      expect(member.permissions.canRemoveMembers, isFalse);

      // Act & Assert - Analytics capabilities
      expect(foreman.permissions.canViewAnalytics, isTrue);
      expect(lead.permissions.canViewAnalytics, isFalse);
      expect(member.permissions.canViewAnalytics, isFalse);
    });

    test('Should handle role transitions correctly', () {
      // Arrange
      var member = CrewMember(
        userId: 'user-1',
        crewId: 'crew-1',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.member),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      // Act - Promote to lead
      member = member.updateRole(MemberRole.lead);

      // Assert
      expect(member.role, equals(MemberRole.lead));
      expect(member.permissions.canInviteMembers, isTrue);
      expect(member.permissions.canShareJobs, isTrue);

      // Act - Promote to foreman
      member = member.updateRole(MemberRole.foreman);

      // Assert
      expect(member.role, equals(MemberRole.foreman));
      expect(member.permissions.canRemoveMembers, isTrue);
      expect(member.permissions.canViewAnalytics, isTrue);

      // Act - Demote to member
      member = member.updateRole(MemberRole.member);

      // Assert
      expect(member.role, equals(MemberRole.member));
      expect(member.permissions.canInviteMembers, isFalse);
      expect(member.permissions.canShareJobs, isFalse);
    });
  });
}

// Helper function to create test crew member
CrewMember _createTestCrewMember({String userId = 'test-user-123'}) {
  return CrewMember(
    userId: userId,
    crewId: 'test-crew-123',
    role: MemberRole.member,
    joinedAt: DateTime.now(),
    permissions: MemberPermissions.fromRole(MemberRole.member),
    isAvailable: true,
    lastActive: DateTime.now(),
  );
}