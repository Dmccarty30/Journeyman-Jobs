import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/screens/crew_detail_screen.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew_enums.dart';
import 'package:journeyman_jobs/features/crews/providers/crew_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/crew_member_provider.dart';

import '../../../mocks/firebase_mocks.dart';

void main() {
  group('CrewDetailScreen', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          // Override providers with mocks for testing
          crewProvider.overrideWith((ref) => MockCrewNotifier()),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()),
        ],
      );
    });

    tearDown(() {
      container.dispose();
    });

    testWidgets('displays loading state when crew is null', (tester) async {
      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      // Should show loading screen
      expect(find.text('Loading crew details...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('displays crew information when loaded', (tester) async {
      // Set up mock crew data
      final mockCrew = Crew(
        id: 'test-crew-id',
        name: 'Test Storm Crew',
        description: 'Emergency restoration crew for IBEW Local 123',
        createdBy: 'creator-id',
        memberIds: ['member1', 'member2'],
        maxMembers: 10,
        classifications: ['Journeyman Lineman', 'Tree Trimmer'],
        jobTypes: [JobType.stormWork, JobType.maintenance],
        travelRadius: 100,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        homeLocal: '123',
        location: 'Austin, TX',
        availableForStormWork: true,
      );

      final mockMembers = [
        CrewMember(
          userId: 'member1',
          crewId: 'test-crew-id',
          displayName: 'John Smith',
          role: CrewRole.foreman,
          joinedAt: DateTime.now(),
          isActive: true,
          workPreferences: const CrewMemberPreferences(),
          notifications: const NotificationSettings(),
          classifications: ['Journeyman Lineman'],
          localNumber: '123',
          yearsExperience: 15,
        ),
        CrewMember(
          userId: 'member2',
          crewId: 'test-crew-id',
          displayName: 'Jane Doe',
          role: CrewRole.crewMember,
          joinedAt: DateTime.now(),
          isActive: true,
          workPreferences: const CrewMemberPreferences(),
          notifications: const NotificationSettings(),
          classifications: ['Tree Trimmer'],
          localNumber: '123',
          yearsExperience: 8,
        ),
      ];

      // Override providers with mock data
      container = ProviderContainer(
        overrides: [
          crewProvider.overrideWith((ref) => MockCrewNotifier()..mockCrew = mockCrew),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()..mockMembers = mockMembers),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      // Wait for widget to rebuild with mock data
      await tester.pump();

      // Verify crew name appears in app bar
      expect(find.text('Test Storm Crew'), findsOneWidget);

      // Verify crew stats in header
      expect(find.text('2/10'), findsOneWidget); // Members count
      expect(find.text('IBEW Local 123'), findsOneWidget);
      expect(find.text('Austin, TX'), findsOneWidget);

      // Verify storm work indicator
      expect(find.text('Storm'), findsOneWidget);
      expect(find.byIcon(Icons.flash_on), findsWidgets);

      // Verify tab bar
      expect(find.text('Overview'), findsOneWidget);
      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Jobs'), findsOneWidget);
      expect(find.text('Messages'), findsOneWidget);
      expect(find.text('Settings'), findsOneWidget);
    });

    testWidgets('navigates between tabs correctly', (tester) async {
      final mockCrew = Crew(
        id: 'test-crew-id',
        name: 'Test Crew',
        createdBy: 'creator-id',
        memberIds: ['member1'],
        maxMembers: 10,
        classifications: ['Inside Wireman'],
        jobTypes: [JobType.commercial],
        travelRadius: 50,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          crewProvider.overrideWith((ref) => MockCrewNotifier()..mockCrew = mockCrew),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      await tester.pump();

      // Initially on Overview tab
      expect(find.text('Recent Activity'), findsOneWidget);

      // Tap Members tab
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Should show members content
      expect(find.text('Members (0/10)'), findsOneWidget);

      // Tap Jobs tab
      await tester.tap(find.text('Jobs'));
      await tester.pumpAndSettle();

      // Should show jobs content
      expect(find.text('Active Jobs'), findsOneWidget);

      // Tap Settings tab
      await tester.tap(find.text('Settings'));
      await tester.pumpAndSettle();

      // Should show settings content
      expect(find.text('General Settings'), findsOneWidget);
    });

    testWidgets('shows admin options for crew admin', (tester) async {
      final mockCrew = Crew(
        id: 'test-crew-id',
        name: 'Test Crew',
        createdBy: 'current-user-id', // Current user is creator/admin
        memberIds: ['current-user-id'],
        maxMembers: 10,
        classifications: ['Inside Wireman'],
        jobTypes: [JobType.commercial],
        travelRadius: 50,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          crewProvider.overrideWith((ref) => MockCrewNotifier()..mockCrew = mockCrew),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      await tester.pump();

      // Should show admin menu button
      expect(find.byIcon(Icons.more_vert), findsOneWidget);

      // Tap admin menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pumpAndSettle();

      // Should show admin options
      expect(find.text('Crew Options'), findsOneWidget);
      expect(find.text('Edit Crew Details'), findsOneWidget);
      expect(find.text('Invite Members'), findsOneWidget);
      expect(find.text('Delete Crew'), findsOneWidget);
    });

    testWidgets('shows empty state for no members', (tester) async {
      final mockCrew = Crew(
        id: 'test-crew-id',
        name: 'Test Crew',
        createdBy: 'creator-id',
        memberIds: [], // No members
        maxMembers: 10,
        classifications: ['Inside Wireman'],
        jobTypes: [JobType.commercial],
        travelRadius: 50,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      container = ProviderContainer(
        overrides: [
          crewProvider.overrideWith((ref) => MockCrewNotifier()..mockCrew = mockCrew),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()..mockMembers = []),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      await tester.pump();

      // Navigate to Members tab
      await tester.tap(find.text('Members'));
      await tester.pumpAndSettle();

      // Should show empty state
      expect(find.text('No members yet'), findsOneWidget);
      expect(find.text('Invite electrical workers to join your crew'), findsOneWidget);
      expect(find.text('Invite Members'), findsWidgets);
    });

    testWidgets('displays IBEW classifications correctly', (tester) async {
      final mockCrew = Crew(
        id: 'test-crew-id',
        name: 'Multi-Craft Crew',
        createdBy: 'creator-id',
        memberIds: ['member1'],
        maxMembers: 10,
        classifications: [
          'Journeyman Lineman',
          'Inside Wireman',
          'Tree Trimmer',
          'Equipment Operator'
        ],
        jobTypes: [JobType.commercial, JobType.utility],
        travelRadius: 75,
        isActive: true,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        homeLocal: '456',
        availableForStormWork: true,
        availableForEmergencyWork: true,
      );

      container = ProviderContainer(
        overrides: [
          crewProvider.overrideWith((ref) => MockCrewNotifier()..mockCrew = mockCrew),
          crewMemberProvider.overrideWith((ref) => MockCrewMemberNotifier()),
        ],
      );

      await tester.pumpWidget(
        UncontrolledProviderScope(
          container: container,
          child: MaterialApp(
            home: CrewDetailScreen(crewId: 'test-crew-id'),
          ),
        ),
      );

      await tester.pump();

      // Should show first two classifications in header
      expect(find.text('Journeyman Lineman'), findsOneWidget);
      expect(find.text('Inside Wireman'), findsOneWidget);

      // Should show work availability indicators
      expect(find.text('Storm Work'), findsOneWidget);
      expect(find.text('Emergency Work'), findsOneWidget);
      expect(find.text('75 mile radius'), findsOneWidget);

      // Navigate to overview to see all classifications
      // (should already be on Overview tab)
      expect(find.text('IBEW Classifications'), findsOneWidget);
    });
  });
}

/// Mock crew notifier for testing
class MockCrewNotifier extends StateNotifier<CrewState> {
  MockCrewNotifier() : super(const CrewState());

  Crew? mockCrew;

  @override
  CrewState get state => CrewState(
    selectedCrew: mockCrew,
    userCrews: mockCrew != null ? [mockCrew!] : [],
    isLoading: false,
  );

  void selectCrew(String crewId) {
    // Mock implementation - crew is already set
  }

  void clearSelectedCrew() {
    mockCrew = null;
  }

  Future<bool> deleteCrew(String crewId, String userId) async {
    return true;
  }
}

/// Mock crew member notifier for testing
class MockCrewMemberNotifier extends StateNotifier<CrewMemberState> {
  MockCrewMemberNotifier() : super(const CrewMemberState());

  List<CrewMember> mockMembers = [];

  @override
  CrewMemberState get state => CrewMemberState(
    membersByCrewId: {
      'test-crew-id': mockMembers,
    },
    isLoading: false,
  );

  void subscribeToCrewMembers(String crewId) {
    // Mock implementation - members are already set
  }

  Future<String> inviteMember({
    required String crewId,
    required Map<String, dynamic> invitationData,
  }) async {
    return 'mock-invitation-id';
  }

  Future<void> updateMemberRole({
    required String crewId,
    required String memberId,
    required CrewRole newRole,
  }) async {
    // Mock implementation
  }

  Future<void> removeMember({
    required String crewId,
    required String memberId,
  }) async {
    // Mock implementation
  }
}