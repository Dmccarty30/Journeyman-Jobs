import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/crews/widgets/crew_member_card.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/models/crew_enums.dart';

void main() {
  group('CrewMemberCard', () {
    // Test data
    late CrewMember testMember;
    late CrewMember testForeman;

    setUp(() {
      testMember = CrewMember(
        id: 'member1',
        userId: 'user1',
        crewId: 'crew1',
        displayName: 'John Smith',
        email: 'john.smith@ibew.org',
        phone: '+1234567890',
        profileImageUrl: 'https://example.com/profile.jpg',
        role: CrewRole.journeyman,
        joinedAt: DateTime.now().subtract(const Duration(days: 30)),
        lastActiveAt: DateTime.now().subtract(const Duration(hours: 2)),
        isActive: true,
        workPreferences: const CrewMemberPreferences(),
        notifications: const NotificationSettings(),
        classifications: ['Inside Wireman', 'Commercial Electrician'],
        localNumber: '123',
        yearsExperience: 8,
        certifications: ['OSHA 30', 'Arc Flash'],
        skills: ['Motor Control', 'PLC Programming'],
        availability: MemberAvailability.available,
        rating: 4.5,
        jobsCompleted: 25,
        emergencyContact: const EmergencyContact(
          name: 'Jane Smith',
          relationship: 'Spouse',
          phone: '+1987654321',
        ),
      );

      testForeman = testMember.copyWith(
        role: CrewRole.foreman,
        availability: MemberAvailability.onJob,
      );
    });

    testWidgets('displays member information correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify basic member information
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Journeyman'), findsOneWidget);
      expect(find.text('IBEW 123'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('shows role-appropriate colors and indicators', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testForeman,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify foreman role display
      expect(find.text('Foreman'), findsOneWidget);
      expect(find.text('On Job'), findsOneWidget);
    });

    testWidgets('displays member details in full layout', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              compact: false,
            ),
          ),
        ),
      );

      // Verify detailed information is shown
      expect(find.text('Classification:'), findsOneWidget);
      expect(find.text('Inside Wireman'), findsOneWidget);
      expect(find.text('Experience:'), findsOneWidget);
      expect(find.text('8 years'), findsOneWidget);
      expect(find.text('Rating:'), findsOneWidget);
      expect(find.text('4.5/5.0'), findsOneWidget);
      expect(find.text('Jobs Completed:'), findsOneWidget);
      expect(find.text('25'), findsOneWidget);
    });

    testWidgets('shows certifications and skills tags', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify certifications and skills
      expect(find.text('Certifications & Skills'), findsOneWidget);
      expect(find.text('OSHA 30'), findsOneWidget);
      expect(find.text('Arc Flash'), findsOneWidget);
      expect(find.text('Motor Control'), findsOneWidget);
      expect(find.text('PLC Programming'), findsOneWidget);
    });

    testWidgets('displays compact layout correctly', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              compact: true,
            ),
          ),
        ),
      );

      // Verify compact layout shows essential info only
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Journeyman'), findsOneWidget);
      expect(find.text('IBEW 123'), findsOneWidget);

      // Verify detailed info is not shown in compact mode
      expect(find.text('Classification:'), findsNothing);
      expect(find.text('Experience:'), findsNothing);
    });

    testWidgets('shows action buttons for authorized users', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman, // Authorized role
              showActions: true,
            ),
          ),
        ),
      );

      // Verify action buttons are shown
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Role'), findsOneWidget);
      expect(find.text('Remove'), findsOneWidget);
    });

    testWidgets('hides management actions for non-authorized users', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.journeyman, // Not authorized
              showActions: true,
            ),
          ),
        ),
      );

      // Verify only contact button is shown
      expect(find.text('Contact'), findsOneWidget);
      expect(find.text('Role'), findsNothing);
      expect(find.text('Remove'), findsNothing);
    });

    testWidgets('handles tap gesture', (tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      // Tap the card
      await tester.tap(find.byType(CrewMemberCard));
      expect(tapped, isTrue);
    });

    testWidgets('shows contact options bottom sheet', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Tap contact button
      await tester.tap(find.text('Contact'));
      await tester.pumpAndSettle();

      // Verify contact options are shown
      expect(find.text('Contact John Smith'), findsOneWidget);
      expect(find.text('Call'), findsOneWidget);
      expect(find.text('Text Message'), findsOneWidget);
      expect(find.text('Email'), findsOneWidget);
      expect(find.text('+1234567890'), findsNWidgets(2)); // Phone shown twice
      expect(find.text('john.smith@ibew.org'), findsOneWidget);
    });

    testWidgets('shows role change dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              onRoleChange: (role) {},
            ),
          ),
        ),
      );

      // Tap role button
      await tester.tap(find.text('Role'));
      await tester.pumpAndSettle();

      // Verify role change dialog is shown
      expect(find.text('Change Member Role'), findsOneWidget);
      expect(find.text('Foreman'), findsOneWidget);
      expect(find.text('Lead Journeyman'), findsOneWidget);
      expect(find.text('Journeyman'), findsNWidgets(2)); // Current role + option
      expect(find.text('Apprentice'), findsOneWidget);
    });

    testWidgets('shows remove confirmation dialog', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              onRemove: () {},
            ),
          ),
        ),
      );

      // Tap remove button
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      // Verify confirmation dialog is shown
      expect(find.text('Remove Member'), findsOneWidget);
      expect(find.text('Are you sure you want to remove John Smith from the crew?'),
             findsOneWidget);
      expect(find.text('Cancel'), findsOneWidget);
      expect(find.text('Remove'), findsNWidgets(2)); // Button + dialog action
    });

    testWidgets('calls role change callback', (tester) async {
      CrewRole? changedRole;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              onRoleChange: (role) => changedRole = role,
            ),
          ),
        ),
      );

      // Open role change dialog and select new role
      await tester.tap(find.text('Role'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Lead Journeyman'));
      await tester.pumpAndSettle();

      expect(changedRole, equals(CrewRole.leadJourneyman));
    });

    testWidgets('calls remove callback', (tester) async {
      bool removed = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
              onRemove: () => removed = true,
            ),
          ),
        ),
      );

      // Open remove dialog and confirm
      await tester.tap(find.text('Remove'));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Remove').last); // Tap confirmation button
      await tester.pumpAndSettle();

      expect(removed, isTrue);
    });

    testWidgets('shows appropriate classification icons', (tester) async {
      final linemanMember = testMember.copyWith(
        classifications: ['Journeyman Lineman'],
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: linemanMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify classification is displayed
      expect(find.text('Journeyman Lineman'), findsOneWidget);

      // Verify trade badge is shown (icon in CircleAvatar)
      expect(find.byIcon(Icons.power_outlined), findsOneWidget);
    });

    testWidgets('handles member with no contact information', (tester) async {
      final memberNoContact = testMember.copyWith(
        phone: null,
        email: null,
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: memberNoContact,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify no contact info is handled
      expect(find.text('No contact info'), findsOneWidget);

      // Tap contact button should still work
      await tester.tap(find.text('Contact'));
      await tester.pumpAndSettle();

      // Should show contact sheet but with limited options
      expect(find.text('Contact John Smith'), findsOneWidget);
    });

    testWidgets('shows emergency contact status', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: testMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify emergency contact status
      expect(find.text('Emergency Contact:'), findsOneWidget);
      expect(find.text('Available'), findsOneWidget);
    });

    testWidgets('formats last active time correctly', (tester) async {
      final recentMember = testMember.copyWith(
        lastActiveAt: DateTime.now().subtract(const Duration(minutes: 30)),
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: CrewMemberCard(
              member: recentMember,
              currentUserRole: CrewRole.foreman,
            ),
          ),
        ),
      );

      // Verify time formatting
      expect(find.text('Last Active:'), findsOneWidget);
      expect(find.textContaining('30m ago'), findsOneWidget);
    });
  });
}