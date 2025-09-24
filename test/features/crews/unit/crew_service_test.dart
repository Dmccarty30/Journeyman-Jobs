import 'package:test/test.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew_preferences.dart';
import 'package:journeyman_jobs/features/crews/models/crew_stats.dart';

void main() {
  group('Crew Model Tests', () {
    test('Crew should be created with correct properties', () {
      // Arrange
      final crew = _createTestCrew();

      // Act & Assert
      expect(crew.id, equals('test-crew-123'));
      expect(crew.name, equals('Test Crew'));
      expect(crew.foremanId, equals('test-user-123'));
      expect(crew.memberIds, contains('test-user-123'));
      expect(crew.memberCount, equals(1));
      expect(crew.canOperate, isFalse); // Only 1 member
      expect(crew.isActive, isTrue);
    });

    test('Crew copyWith should update properties correctly', () {
      // Arrange
      final originalCrew = _createTestCrew();
      const newName = 'Updated Crew Name';
      const newLogoUrl = 'https://example.com/logo.png';

      // Act
      final updatedCrew = originalCrew.copyWith(
        name: newName,
        logoUrl: newLogoUrl,
        isActive: false,
      );

      // Assert
      expect(updatedCrew.name, equals(newName));
      expect(updatedCrew.logoUrl, equals(newLogoUrl));
      expect(updatedCrew.isActive, isFalse);
      // Other properties should remain unchanged
      expect(updatedCrew.id, equals(originalCrew.id));
      expect(updatedCrew.foremanId, equals(originalCrew.foremanId));
    });

    test('Crew toFirestore should return correct map structure', () {
      // Arrange
      final crew = _createTestCrew();

      // Act
      final firestoreData = crew.toFirestore();

      // Assert
      expect(firestoreData, isA<Map<String, dynamic>>());
      expect(firestoreData['name'], equals('Test Crew'));
      expect(firestoreData['foremanId'], equals('test-user-123'));
      expect(firestoreData['memberIds'], isA<List>());
      expect(firestoreData['preferences'], isA<Map>());
      expect(firestoreData['roles'], isA<Map>());
      expect(firestoreData['stats'], isA<Map>());
      expect(firestoreData['isActive'], isTrue);
    });
  });

  group('CrewMember Model Tests', () {
    test('CrewMember should be created with correct properties', () {
      // Arrange
      final member = _createTestCrewMember();

      // Act & Assert
      expect(member.userId, equals('test-user-123'));
      expect(member.crewId, equals('test-crew-123'));
      expect(member.role, equals(MemberRole.member));
      expect(member.isAvailable, isTrue);
      expect(member.permissions.canInviteMembers, isFalse);
      expect(member.permissions.canShareJobs, isFalse);
    });

    test('CrewMember permissions should vary by role', () {
      // Arrange & Act
      final foremanMember = CrewMember(
        userId: 'user-1',
        crewId: 'crew-1',
        role: MemberRole.foreman,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.foreman),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      final leadMember = CrewMember(
        userId: 'user-2',
        crewId: 'crew-1',
        role: MemberRole.lead,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.lead),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      final regularMember = CrewMember(
        userId: 'user-3',
        crewId: 'crew-1',
        role: MemberRole.member,
        joinedAt: DateTime.now(),
        permissions: MemberPermissions.fromRole(MemberRole.member),
        isAvailable: true,
        lastActive: DateTime.now(),
      );

      // Assert - Foreman permissions
      expect(foremanMember.permissions.canInviteMembers, isTrue);
      expect(foremanMember.permissions.canRemoveMembers, isTrue);
      expect(foremanMember.permissions.canShareJobs, isTrue);
      expect(foremanMember.permissions.canPostAnnouncements, isTrue);
      expect(foremanMember.permissions.canEditCrewInfo, isTrue);
      expect(foremanMember.permissions.canViewAnalytics, isTrue);

      // Assert - Lead permissions
      expect(leadMember.permissions.canInviteMembers, isTrue);
      expect(leadMember.permissions.canRemoveMembers, isFalse);
      expect(leadMember.permissions.canShareJobs, isTrue);
      expect(leadMember.permissions.canPostAnnouncements, isTrue);
      expect(leadMember.permissions.canEditCrewInfo, isFalse);
      expect(leadMember.permissions.canViewAnalytics, isFalse);

      // Assert - Regular member permissions
      expect(regularMember.permissions.canInviteMembers, isFalse);
      expect(regularMember.permissions.canRemoveMembers, isFalse);
      expect(regularMember.permissions.canShareJobs, isFalse);
      expect(regularMember.permissions.canPostAnnouncements, isFalse);
      expect(regularMember.permissions.canEditCrewInfo, isFalse);
      expect(regularMember.permissions.canViewAnalytics, isFalse);
    });

    test('CrewMember hasPermission should work correctly', () {
      // Arrange
      final member = _createTestCrewMember();

      // Act & Assert
      expect(member.hasPermission('canInviteMembers'), isFalse);
      expect(member.hasPermission('canShareJobs'), isFalse);
      expect(member.hasPermission('canPostAnnouncements'), isFalse);
      expect(member.hasPermission('invalid_permission'), isFalse);
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
    });

    test('CrewMember markActive should update availability', () {
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
    });
  });

  group('CrewPreferences Model Tests', () {
    test('CrewPreferences should be created with correct properties', () {
      // Arrange
      final preferences = _createTestPreferences();

      // Act & Assert
      expect(preferences.jobTypes, contains('Inside Wireman'));
      expect(preferences.minHourlyRate, equals(35.0));
      expect(preferences.maxDistanceMiles, equals(50));
      expect(preferences.preferredCompanies, contains('Test Electric Co'));
      expect(preferences.requiredSkills, contains('OSHA 30'));
      expect(preferences.autoShareEnabled, isTrue);
      expect(preferences.matchThreshold, equals(75));
    });

    test('CrewPreferences copyWith should update properties correctly', () {
      // Arrange
      final originalPreferences = _createTestPreferences();
      const newMinRate = 45.0;
      const newMaxDistance = 75;

      // Act
      final updatedPreferences = originalPreferences.copyWith(
        minHourlyRate: newMinRate,
        maxDistanceMiles: newMaxDistance,
        autoShareEnabled: false,
      );

      // Assert
      expect(updatedPreferences.minHourlyRate, equals(newMinRate));
      expect(updatedPreferences.maxDistanceMiles, equals(newMaxDistance));
      expect(updatedPreferences.autoShareEnabled, isFalse);
      // Other properties should remain unchanged
      expect(updatedPreferences.jobTypes, equals(originalPreferences.jobTypes));
    });

    test('CrewPreferences toMap should return correct structure', () {
      // Arrange
      final preferences = _createTestPreferences();

      // Act
      final map = preferences.toMap();

      // Assert
      expect(map, isA<Map<String, dynamic>>());
      expect(map['jobTypes'], isA<List>());
      expect(map['minHourlyRate'], equals(35.0));
      expect(map['maxDistanceMiles'], equals(50));
      expect(map['preferredCompanies'], isA<List>());
      expect(map['requiredSkills'], isA<List>());
      expect(map['availability'], isA<Map>());
      expect(map['autoShareEnabled'], isTrue);
      expect(map['matchThreshold'], equals(75));
    });
  });

  group('CrewStats Model Tests', () {
    test('CrewStats should be created with correct properties', () {
      // Arrange
      final stats = _createTestStats();

      // Act & Assert
      expect(stats.totalJobsShared, equals(10));
      expect(stats.totalApplications, equals(25));
      expect(stats.applicationRate, equals(2.5));
      expect(stats.averageMatchScore, equals(85.0));
      expect(stats.successfulPlacements, equals(3));
      expect(stats.responseTime, equals(24.0));
      expect(stats.jobTypeBreakdown, isA<Map>());
      expect(stats.lastActivityAt, isA<DateTime>());
    });

    test('CrewStats calculateApplicationRate should work correctly', () {
      // Arrange
      final statsWithJobs = CrewStats(
        totalJobsShared: 10,
        totalApplications: 25,
        applicationRate: 0.0, // Will be calculated
        averageMatchScore: 85.0,
        successfulPlacements: 3,
        responseTime: 24.0,
        jobTypeBreakdown: {'Inside Wireman': 15, 'Journeyman Lineman': 10},
        lastActivityAt: DateTime.now(),
      );

      final statsWithoutJobs = CrewStats(
        totalJobsShared: 0,
        totalApplications: 25,
        applicationRate: 0.0,
        averageMatchScore: 85.0,
        successfulPlacements: 3,
        responseTime: 24.0,
        jobTypeBreakdown: {},
        lastActivityAt: DateTime.now(),
      );

      // Act
      final rateWithJobs = statsWithJobs.calculateApplicationRate();
      final rateWithoutJobs = statsWithoutJobs.calculateApplicationRate();

      // Assert
      expect(rateWithJobs, equals(2.5));
      expect(rateWithoutJobs, equals(0.0));
    });

    test('CrewStats increment helpers should work correctly', () {
      // Arrange
      final originalStats = _createTestStats();
      final originalLastActivity = originalStats.lastActivityAt;

      // Act
      final incrementedJobShared = originalStats.incrementJobShared();
      final incrementedApplication = originalStats.incrementApplication();
      final incrementedPlacement = originalStats.incrementSuccessfulPlacement();

      // Assert
      expect(incrementedJobShared.totalJobsShared, equals(11));
      expect(incrementedJobShared.lastActivityAt.isAfter(originalLastActivity), isTrue);

      expect(incrementedApplication.totalApplications, equals(26));
      expect(incrementedApplication.lastActivityAt.isAfter(originalLastActivity), isTrue);

      expect(incrementedPlacement.successfulPlacements, equals(4));
      expect(incrementedPlacement.lastActivityAt.isAfter(originalLastActivity), isTrue);
    });

    test('CrewStats updateAverageMatchScore should work correctly', () {
      // Arrange
      final stats = _createTestStats();
      const newScore = 90.0;

      // Act
      final updatedStats = stats.updateAverageMatchScore(newScore);

      // Assert
      expect(updatedStats.averageMatchScore, isNot(equals(stats.averageMatchScore)));
    });

    test('CrewStats updateJobTypeBreakdown should work correctly', () {
      // Arrange
      final stats = _createTestStats();
      const jobType = 'Inside Wireman';

      // Act
      final updatedStats = stats.updateJobTypeBreakdown(jobType);

      // Assert
      expect(updatedStats.jobTypeBreakdown[jobType], equals(16)); // 15 + 1
    });
  });
}

// Helper functions for creating test data
Crew _createTestCrew({String id = 'test-crew-123'}) {
  return Crew(
    id: id,
    name: 'Test Crew',
    foremanId: 'test-user-123',
    memberIds: ['test-user-123'],
    preferences: _createTestPreferences(),
    createdAt: DateTime.now(),
    roles: {'test-user-123': MemberRole.foreman},
    stats: _createTestStats(),
    isActive: true,
  );
}

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

CrewPreferences _createTestPreferences() {
  return CrewPreferences(
    jobTypes: ['Inside Wireman', 'Journeyman Lineman'],
    minHourlyRate: 35.0,
    maxDistanceMiles: 50,
    preferredCompanies: ['Test Electric Co'],
    requiredSkills: ['OSHA 30', 'First Aid/CPR'],
    autoShareEnabled: true,
    matchThreshold: 75,
  );
}

CrewStats _createTestStats() {
  return CrewStats(
    totalJobsShared: 10,
    totalApplications: 25,
    applicationRate: 2.5,
    averageMatchScore: 85.0,
    successfulPlacements: 3,
    responseTime: 24.0,
    jobTypeBreakdown: {'Inside Wireman': 15, 'Journeyman Lineman': 10},
    lastActivityAt: DateTime.now(),
  );
}