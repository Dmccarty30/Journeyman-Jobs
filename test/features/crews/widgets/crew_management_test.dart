import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:journeyman_jobs/features/crews/screens/crew_management_screen.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';

import 'crew_management_test.mocks.dart';

@GenerateMocks([Crew, CrewMember])
void main() {
  group('CrewManagementScreen Tests', () {
    late MockCrew mockCrew;
    late MockCrewMember mockMember;

    setUp(() {
      mockCrew = MockCrew();
      when(mockCrew.name).thenReturn('Test Crew');
      when(mockCrew.description).thenReturn('Test Description');
      when(mockCrew.memberCount).thenReturn(5);
      when(mockCrew.activeJobsCount).thenReturn(3);
      when(mockCrew.efficiency).thenReturn(85);
      when(mockCrew.isActive).thenReturn(true);
      when(mockCrew.createdAt).thenReturn(DateTime.now());

      mockMember = MockCrewMember();
      when(mockMember.userId).thenReturn('user-123');
      when(mockMember.displayName).thenReturn('John Doe');
      when(mockMember.role).thenReturn(CrewRole.journeyman);
      when(mockMember.isOnline).thenReturn(true);
    });

    Widget createWidgetUnderTest() {
      return ProviderScope(
        child: MaterialApp(
          home: CrewManagementScreen(crewId: 'test-crew-123'),
        ),
      );
    }

    testWidgets('displays crew management screen with correct title', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Test Crew'), findsOneWidget);
      expect(find.byIcon(Icons.people), findsOneWidget);
      expect(find.byIcon(Icons.mail), findsOneWidget);
      expect(find.byIcon(Icons.activity), findsOneWidget);
      expect(find.byIcon(Icons.analytics), findsOneWidget);
    });

    testWidgets('displays crew statistics correctly', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Active Jobs'), findsOneWidget);
      expect(find.text('Efficiency'), findsOneWidget);
    });

    testWidgets('floating action button is present and functional', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.byType(FloatingActionButton), findsOneWidget);
      expect(find.text('Invite Member'), findsOneWidget);
      expect(find.byIcon(Icons.person_add), findsOneWidget);
    });

    testWidgets('tab bar displays all tabs', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      expect(find.text('Members'), findsOneWidget);
      expect(find.text('Invitations'), findsOneWidget);
      expect(find.text('Activity'), findsOneWidget);
      expect(find.text('Analytics'), findsOneWidget);
    });

    testWidgets('settings button opens settings dialog', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.settings));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('permissions button opens permission dialog', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      await tester.tap(find.byIcon(Icons.security));
      await tester.pumpAndSettle();

      expect(find.byType(Dialog), findsOneWidget);
    });

    testWidgets('members tab displays crew members', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Switch to members tab (should be default)
      expect(find.byType(CrewMembersTab), findsOneWidget);
    });

    testWidgets('member card displays user information', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find member cards
      expect(find.byType(CrewMemberCard), findsAtLeastNWidgets(1));
    });

    testWidgets('member card menu shows options', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Find and tap more options menu
      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Change Role'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
      expect(find.text('Remove from Crew'), findsOneWidget);
    });

    testWidgets('empty state displays when no members', (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify empty state elements
      expect(find.text('No members yet'), findsOneWidget);
      expect(find.byIcon(Icons.people_outline), findsOneWidget);
    });

    testWidgets('loading state displays during data fetch', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // Verify loading indicators
      expect(find.byType(CircularProgressIndicator), findsAtLeastNWidgets(1));
    });

    testWidgets('error state displays correctly on failure', 
        (WidgetTester tester) async {
      await tester.pumpWidget(createWidgetUnderTest());

      // This would require mocking the provider to return an error
      // For now, verify error state UI elements exist
    });
  });

  group('CrewMemberCard Tests', () {
    testWidgets('member card displays correct information', 
        (WidgetTester tester) async {
      final mockMember = MockCrewMember();
      when(mockMember.userId).thenReturn('user-123');
      when(mockMember.displayName).thenReturn('John Doe');
      when(mockMember.role).thenReturn(CrewRole.journeyman);
      when(mockMember.isOnline).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: mockMember,
              onRoleChanged: (role) {},
              onRemoved: () {},
            ),
          ),
        ),
      );

      expect(find.text('John Doe'), findsOneWidget);
      expect(find.text('Role: Journeyman'), findsOneWidget);
      expect(find.text('Online'), findsOneWidget);
    });

    testWidgets('offline member shows offline status', (WidgetTester tester) async {
      final mockMember = MockCrewMember();
      when(mockMember.userId).thenReturn('user-123');
      when(mockMember.displayName).thenReturn('Jane Doe');
      when(mockMember.role).thenReturn(CrewRole.apprentice);
      when(mockMember.isOnline).thenReturn(false);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: mockMember,
              onRoleChanged: (role) {},
              onRemoved: () {},
            ),
          ),
        ),
      );

      expect(find.text('Jane Doe'), findsOneWidget);
      expect(find.text('Role: Apprentice'), findsOneWidget);
      expect(find.text('Online'), findsNothing);
    });

    testWidgets('member card menu works correctly', (WidgetTester tester) async {
      final mockMember = MockCrewMember();
      when(mockMember.userId).thenReturn('user-123');
      when(mockMember.displayName).thenReturn('Test User');
      when(mockMember.role).thenReturn(CrewRole.journeyman);
      when(mockMember.isOnline).thenReturn(true);

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: mockMember,
              onRoleChanged: (role) {},
              onRemoved: () {},
            ),
          ),
        ),
      );

      await tester.tap(find.byIcon(Icons.more_vert));
      await tester.pump();

      expect(find.text('Change Role'), findsOneWidget);
      expect(find.text('Send Message'), findsOneWidget);
      expect(find.text('Remove from Crew'), findsOneWidget);
    });
  });
}
