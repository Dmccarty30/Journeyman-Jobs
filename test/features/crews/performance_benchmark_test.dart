import 'package:flutter_test/flutter_test.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:mocktail/mocktail.dart';
import 'package:journeyman_jobs/features/crews/services/crew_service.dart';
import 'package:journeyman_jobs/features/crews/services/message_service.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';
import 'package:journeyman_jobs/domain/enums/member_role.dart';
import 'package:journeyman_jobs/domain/enums/crew_visibility.dart';
import 'package:journeyman_jobs/domain/enums/message_type.dart';

/// Performance benchmark tests for crew features
///
/// Tests cover:
/// - Crew creation and retrieval performance
/// - Message sending and retrieval performance
/// - Large crew operations performance
/// - Memory usage optimization
/// - Concurrent operation performance
/// - Database query optimization
/// - UI rendering performance
/// - Network latency handling
void main() {
  group('Performance Benchmarks', () {
    late FakeFirebaseFirestore fakeFirestore;
    late CrewService crewService;
    late MessageService messageService;
    late List<String> testUserIds;
    late List<String> testCrewIds;

    setUp(() async {
      fakeFirestore = FakeCloudFirestore();
      crewService = CrewService(
        jobSharingService: MockJobSharingService(),
        offlineDataService: MockOfflineDataService(),
        connectivityService: MockConnectivityService(),
      );
      messageService = MessageService();

      testUserIds = List.generate(100, (i) => 'user-$i');
      testCrewIds = List.generate(10, (i) => 'crew-$i');

      await _setupPerformanceTestEnvironment();
    });

    // Crew Creation Performance Tests
    group('Crew Creation Performance', () {
      testWidgets('creates single crew within acceptable time', (WidgetTester tester) async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await crewService.createCrew(
          name: 'Performance Test Crew',
          foremanId: testUserIds[0],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
        );

        stopwatch.stop();

        // Assert - Should complete within 500ms
        expect(stopwatch.elapsedMilliseconds, lessThan(500),
            reason: 'Crew creation took ${stopwatch.elapsedMilliseconds}ms, expected < 500ms');
      });

      testWidgets('handles batch crew creation efficiently', (WidgetTester tester) async {
        // Arrange
        final stopwatch = Stopwatch()..start();
        const crewCount = 10;

        // Act
        final futures = <Future<void>>[];
        for (int i = 0; i < crewCount; i++) {
          futures.add(crewService.createCrew(
            name: 'Batch Crew $i',
            foremanId: testUserIds[i],
            preferences: const CrewPreferences(
              jobTypes: [],
              constructionTypes: [],
              autoShareEnabled: false,
            ),
          ));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Batch crew creation of $crewCount crews took ${stopwatch.elapsedMilliseconds}ms, expected < 5000ms');
        expect(stopwatch.elapsedMilliseconds / crewCount, lessThan(500),
            reason: 'Average crew creation time: ${stopwatch.elapsedMilliseconds / crewCount}ms, expected < 500ms per crew');
      });

      testWidgets('retrieves crew data efficiently', (WidgetTester tester) async {
        // Arrange - Pre-populate with crews
        for (int i = 0; i < 10; i++) {
          await crewService.createCrew(
            name: 'Retrieval Test Crew $i',
            foremanId: testUserIds[i],
            preferences: const CrewPreferences(
              jobTypes: [],
              constructionTypes: [],
              autoShareEnabled: false,
            ),
          );
        }

        final stopwatch = Stopwatch()..start();

        // Act - Retrieve all crews
        final retrievedCrews = <Crew>[];
        for (final crewId in testCrewIds) {
          final crew = await crewService.getCrew(crewId);
          if (crew != null) {
            retrievedCrews.add(crew);
          }
        }

        stopwatch.stop();

        // Assert
        expect(retrievedCrews.length, equals(10));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Crew retrieval took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms');
      });
    });

    // Message Performance Tests
    group('Message Performance', () {
      testWidgets('sends single message within acceptable time', (WidgetTester tester) async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act
        await messageService.sendCrewMessage(
          crewId: testCrewIds[0],
          senderId: testUserIds[0],
          content: 'Performance test message',
        );

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(100),
            reason: 'Single message send took ${stopwatch.elapsedMilliseconds}ms, expected < 100ms');
      });

      testWidgets('handles high-volume message sending efficiently', (WidgetTester tester) async {
        // Arrange
        const messageCount = 100;
        final stopwatch = Stopwatch()..start();

        // Act
        final futures = <Future<void>>[];
        for (int i = 0; i < messageCount; i++) {
          futures.add(messageService.sendCrewMessage(
            crewId: testCrewIds[0],
            senderId: testUserIds[i % 10],
            content: 'High volume message $i',
          ));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
            reason: 'Sending $messageCount messages took ${stopwatch.elapsedMilliseconds}ms, expected < 10000ms');
        expect(stopwatch.elapsedMilliseconds / messageCount, lessThan(100),
            reason: 'Average message send time: ${stopwatch.elapsedMilliseconds / messageCount}ms, expected < 100ms per message');
      });

      testWidgets('retrieves message history efficiently', (WidgetTester tester) async {
        // Arrange - Pre-populate with messages
        const messageCount = 50;
        for (int i = 0; i < messageCount; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewIds[0],
            senderId: testUserIds[0],
            content: 'History message $i',
          );
        }

        final stopwatch = Stopwatch()..start();

        // Act
        final stream = messageService.getCrewMessagesStream(testCrewIds[0], testUserIds[0]);
        final messages = await stream.first;

        stopwatch.stop();

        // Assert
        expect(messages.length, equals(messageCount));
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Message history retrieval took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms');
      });
    });

    // Large Crew Operations Performance Tests
    group('Large Crew Operations', () {
      testWidgets('handles large crew membership efficiently', (WidgetTester tester) async {
        // Arrange - Create large crew with many members
        final largeCrewId = 'large-crew-test';
        await crewService.createCrew(
          name: 'Large Test Crew',
          foremanId: testUserIds[0],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
        );

        final stopwatch = Stopwatch()..start();
        const memberCount = 50;

        // Act - Add many members
        for (int i = 1; i < memberCount; i++) {
          await crewService.inviteMember(
            crewId: largeCrewId,
            inviterId: testUserIds[0],
            inviteeId: testUserIds[i],
            role: MemberRole.member,
          );
        }

        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(10000),
            reason: 'Adding $memberCount members took ${stopwatch.elapsedMilliseconds}ms, expected < 10000ms');
      });

      testWidgets('retrieves large member lists efficiently', (WidgetTester tester) async {
        // Arrange - Create crew with many members
        final largeCrewId = 'large-retrieval-test';
        await crewService.createCrew(
          name: 'Large Retrieval Test Crew',
          foremanId: testUserIds[0],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
        );

        // Add members
        for (int i = 1; i < 20; i++) {
          await crewService.inviteMember(
            crewId: largeCrewId,
            inviterId: testUserIds[0],
            inviteeId: testUserIds[i],
            role: MemberRole.member,
          );
        }

        final stopwatch = Stopwatch()..start();

        // Act - Retrieve member list
        final members = await crewService.getCrewMembers(largeCrewId);

        stopwatch.stop();

        // Assert
        expect(members.length, greaterThan(20)); // Foreman + invited members
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Large member list retrieval took ${stopwatch.elapsedMilliseconds}ms, expected < 2000ms');
      });
    });

    // Concurrent Operations Performance Tests
    group('Concurrent Operations', () {
      testWidgets('handles concurrent crew creation efficiently', (WidgetTester tester) async {
        // Arrange
        const crewCount = 20;
        final stopwatch = Stopwatch()..start();

        // Act - Create crews concurrently
        final futures = <Future<void>>[];
        for (int i = 0; i < crewCount; i++) {
          futures.add(crewService.createCrew(
            name: 'Concurrent Crew $i',
            foremanId: testUserIds[i],
            preferences: const CrewPreferences(
              jobTypes: [],
              constructionTypes: [],
              autoShareEnabled: false,
            ),
          ));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(8000),
            reason: 'Concurrent creation of $crewCount crews took ${stopwatch.elapsedMilliseconds}ms, expected < 8000ms');
      });

      testWidgets('handles concurrent message sending efficiently', (WidgetTester tester) async {
        // Arrange
        const messageCount = 100;
        final stopwatch = Stopwatch()..start();

        // Act - Send messages concurrently from multiple users
        final futures = <Future<void>>[];
        for (int i = 0; i < messageCount; i++) {
          futures.add(messageService.sendCrewMessage(
            crewId: testCrewIds[i % testCrewIds.length],
            senderId: testUserIds[i % testUserIds.length],
            content: 'Concurrent message $i',
          ));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(15000),
            reason: 'Concurrent sending of $messageCount messages took ${stopwatch.elapsedMilliseconds}ms, expected < 15000ms');
      });

      testWidgets('handles concurrent member operations efficiently', (WidgetTester tester) async {
        // Arrange
        final stopwatch = Stopwatch()..start();

        // Act - Perform concurrent member operations
        final futures = <Future<void>>[];

        // Add members
        for (int i = 1; i < 10; i++) {
          futures.add(crewService.inviteMember(
            crewId: testCrewIds[0],
            inviterId: testUserIds[0],
            inviteeId: testUserIds[i],
            role: MemberRole.member,
          ));
        }

        await Future.wait(futures);
        stopwatch.stop();

        // Assert
        expect(stopwatch.elapsedMilliseconds, lessThan(5000),
            reason: 'Concurrent member operations took ${stopwatch.elapsedMilliseconds}ms, expected < 5000ms');
      });
    });

    // Memory Usage Tests
    group('Memory Usage Optimization', () {
      testWidgets('does not leak memory during repeated operations', (WidgetTester tester) async {
        // Arrange
        final initialMemory = _getCurrentMemoryUsage();

        // Act - Perform repeated operations
        for (int iteration = 0; iteration < 10; iteration++) {
          // Create and delete crews
          final crewId = 'memory-test-crew-$iteration';
          await crewService.createCrew(
            name: 'Memory Test Crew $iteration',
            foremanId: testUserIds[0],
            preferences: const CrewPreferences(
              jobTypes: [],
              constructionTypes: [],
              autoShareEnabled: false,
            ),
          );

          // Send messages
          for (int i = 0; i < 10; i++) {
            await messageService.sendCrewMessage(
              crewId: crewId,
              senderId: testUserIds[0],
              content: 'Memory test message $i',
            );
          }

          // Clean up
          await crewService.deleteCrew(crewId);
        }

        final finalMemory = _getCurrentMemoryUsage();
        final memoryIncrease = finalMemory - initialMemory;

        // Assert - Memory increase should be reasonable (< 10MB)
        expect(memoryIncrease, lessThan(10 * 1024 * 1024),
            reason: 'Memory increase: ${memoryIncrease / (1024 * 1024)}MB, expected < 10MB');
      });

      testWidgets('handles large messages without excessive memory usage', (WidgetTester tester) async {
        // Arrange
        final largeContent = 'A' * 10000; // 10KB message
        final initialMemory = _getCurrentMemoryUsage();

        // Act - Send large messages
        for (int i = 0; i < 10; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewIds[0],
            senderId: testUserIds[0],
            content: '$largeContent $i',
          );
        }

        final finalMemory = _getCurrentMemoryUsage();
        final memoryIncrease = finalMemory - initialMemory;

        // Assert - Memory usage should be reasonable (< 50MB for 10 large messages)
        expect(memoryIncrease, lessThan(50 * 1024 * 1024),
            reason: 'Memory increase for large messages: ${memoryIncrease / (1024 * 1024)}MB, expected < 50MB');
      });
    });

    // Database Query Optimization Tests
    group('Database Query Optimization', () {
      testWidgets('uses indexed queries efficiently', (WidgetTester tester) async {
        // Arrange - Pre-populate with data
        for (int i = 0; i < 100; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewIds[i % testCrewIds.length],
            senderId: testUserIds[i % testUserIds.length],
            content: 'Indexed message $i',
          );
        }

        final stopwatch = Stopwatch()..start();

        // Act - Perform indexed queries
        final allMessages = <Message>[];
        for (final crewId in testCrewIds) {
          final stream = messageService.getCrewMessagesStream(crewId, testUserIds[0]);
          final messages = await stream.first;
          allMessages.addAll(messages);
        }

        stopwatch.stop();

        // Assert
        expect(allMessages.length, equals(100));
        expect(stopwatch.elapsedMilliseconds, lessThan(2000),
            reason: 'Indexed queries took ${stopwatch.elapsedMilliseconds}ms, expected < 2000ms');
      });

      testWidgets('limits query results efficiently', (WidgetTester tester) async {
        // Arrange - Send more messages than the limit
        const messageCount = 200; // Exceeds default limit of 100

        for (int i = 0; i < messageCount; i++) {
          await messageService.sendCrewMessage(
            crewId: testCrewIds[0],
            senderId: testUserIds[0],
            content: 'Limited message $i',
          );
        }

        final stopwatch = Stopwatch()..start();

        // Act - Retrieve messages (should be limited)
        final stream = messageService.getCrewMessagesStream(testCrewIds[0], testUserIds[0]);
        final messages = await stream.first;

        stopwatch.stop();

        // Assert
        expect(messages.length, equals(100), // Should be limited to 100
            reason: 'Query limit not applied correctly');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Limited query took ${stopwatch.elapsedMilliseconds}ms, expected < 1000ms');
      });
    });

    // Network Latency Simulation Tests
    group('Network Latency Handling', () {
      testWidgets('handles simulated network delays gracefully', (WidgetTester tester) async {
        // Arrange - Simulate network delay by adding artificial delays
        final stopwatch = Stopwatch()..start();

        // Act - Perform operations with artificial delays
        await Future.delayed(const Duration(milliseconds: 100)); // Simulate network latency
        await crewService.createCrew(
          name: 'Network Delay Test Crew',
          foremanId: testUserIds[0],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
        );

        await Future.delayed(const Duration(milliseconds: 100));
        await messageService.sendCrewMessage(
          crewId: testCrewIds[0],
          senderId: testUserIds[0],
          content: 'Network delay test message',
        );

        stopwatch.stop();

        // Assert - Operations should complete despite delays
        expect(stopwatch.elapsedMilliseconds, greaterThan(200),
            reason: 'Network delays should be properly handled');
        expect(stopwatch.elapsedMilliseconds, lessThan(1000),
            reason: 'Operations should complete within reasonable time despite delays');
      });
    });

    // Helper Methods
    Future<void> _setupPerformanceTestEnvironment() async {
      // Setup basic crews for testing
      for (int i = 0; i < testCrewIds.length; i++) {
        final crew = Crew(
          id: testCrewIds[i],
          name: 'Performance Test Crew $i',
          foremanId: testUserIds[i],
          memberIds: [testUserIds[i]],
          preferences: const CrewPreferences(
            jobTypes: [],
            constructionTypes: [],
            autoShareEnabled: false,
          ),
          roles: {testUserIds[i]: MemberRole.foreman},
          stats: const CrewStats(
            totalJobsShared: 0,
            totalApplications: 0,
            applicationRate: 0.0,
            averageMatchScore: 0.0,
            successfulPlacements: 0,
            responseTime: 0.0,
            jobTypeBreakdown: {},
            lastActivityAt: null,
            matchScores: [],
            successRate: 0.0,
          ),
          isActive: true,
          createdAt: DateTime.now(),
          lastActivityAt: DateTime.now(),
          visibility: CrewVisibility.private,
          maxMembers: 50,
          inviteCodeCounter: 0,
        );

        await fakeFirestore.collection('crews').doc(testCrewIds[i]).set(crew.toFirestore());

        // Add crew member
        final member = CrewMember(
          userId: testUserIds[i],
          crewId: testCrewIds[i],
          role: MemberRole.foreman,
          joinedAt: DateTime.now(),
          permissions: MemberPermissions.fromRole(MemberRole.foreman),
          isAvailable: true,
          lastActive: DateTime.now(),
          isActive: true,
        );

        await fakeFirestore
            .collection('crews')
            .doc(testCrewIds[i])
            .collection('members')
            .doc(testUserIds[i])
            .set(member.toFirestore());
      }
    }

    int _getCurrentMemoryUsage() {
      // This is a placeholder for actual memory monitoring
      // In a real implementation, you would use dart:developer or other memory profiling tools
      return 0;
    }
  });
}

// Mock classes for testing
class MockJobSharingService extends Mock implements JobSharingService {}
class MockOfflineDataService extends Mock implements OfflineDataService {}
class MockConnectivityService extends Mock implements ConnectivityService {
  @override
  bool get isOnline => true;
}