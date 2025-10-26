import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/widgets/crew_invitation_card.dart';

void main() {
  group('CrewInvitationCard', () {
    late CrewInvitation mockInvitation;
    late VoidCallback mockOnAccept;
    late VoidCallback mockOnDecline;
    late VoidCallback mockOnCancel;

    setUp(() {
      mockInvitation = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviterUnionLocal: 'Local 123',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.pending,
        message: 'Please join our electrical crew for upcoming projects.',
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 6, hours: 23)),
      );

      mockOnAccept = () {};
      mockOnDecline = () {};
      mockOnCancel = () {};
    });

    Widget createTestWidget({bool isIncoming = true}) {
      return MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: mockInvitation,
            isIncoming: isIncoming,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      );
    }

    testWidgets('displays crew name correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('IBEW Local 123 Crew'), findsOneWidget);
    });

    testWidgets('displays inviter information for incoming invitation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isIncoming: true));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('From: John Smith'), findsOneWidget);
      expect(find.text('Local 123'), findsOneWidget);
    });

    testWidgets('displays invitee information for outgoing invitation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isIncoming: false));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('To: test@example.com'), findsOneWidget);
    });

    testWidgets('displays invitation message', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Please join our electrical crew for upcoming projects.'), findsOneWidget);
    });

    testWidgets('displays accept and decline buttons for incoming pending invitation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isIncoming: true));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Accept'), findsOneWidget);
      expect(find.text('Decline'), findsOneWidget);
    });

    testWidgets('displays cancel button for outgoing pending invitation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isIncoming: false));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Cancel Invitation'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('displays status badge for accepted invitation', (WidgetTester tester) async {
      // Arrange
      final acceptedInvitation = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.accepted,
        message: 'Please join our crew.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 6)),
        respondedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: acceptedInvitation,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Accepted'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('displays status badge for declined invitation', (WidgetTester tester) async {
      // Arrange
      final declinedInvitation = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.declined,
        message: 'Please join our crew.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 6)),
        respondedAt: DateTime.now().subtract(const Duration(hours: 2)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: declinedInvitation,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Declined'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('displays expired badge for expired invitation', (WidgetTester tester) async {
      // Arrange
      final expiredInvitation = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.expired,
        message: 'Please join our crew.',
        createdAt: DateTime.now().subtract(const Duration(days: 8)),
        expiresAt: DateTime.now().subtract(const Duration(days: 1)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: expiredInvitation,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Expired'), findsOneWidget);
      expect(find.text('Accept'), findsNothing);
      expect(find.text('Decline'), findsNothing);
    });

    testWidgets('calls onAccept when accept button is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasAccepted = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: mockInvitation,
            isIncoming: true,
            onAccept: () => wasAccepted = true,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.tap(find.text('Accept'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasAccepted, isTrue);
    });

    testWidgets('calls onDecline when decline button is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasDeclined = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: mockInvitation,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: () => wasDeclined = true,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.tap(find.text('Decline'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasDeclined, isTrue);
    });

    testWidgets('calls onCancel when cancel button is tapped', (WidgetTester tester) async {
      // Arrange
      bool wasCancelled = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: mockInvitation,
            isIncoming: false,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: () => wasCancelled = true,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.tap(find.text('Cancel Invitation'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasCancelled, isTrue);
    });

    testWidgets('displays created time in readable format', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Sent 2 hours ago'), findsOneWidget);
    });

    testWidgets('displays expiration time for pending invitation', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Expires in 6 days'), findsOneWidget);
    });

    testWidgets('displays electrical theme elements', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert - Check for theme-appropriate colors and styling
      final cardFinder = find.byType(Card);
      expect(cardFinder, findsOneWidget);

      final card = tester.widget<Card>(cardFinder);
      expect(card.color, isNotNull); // Should have themed color
    });

    testWidgets('handles null invitation message gracefully', (WidgetTester tester) async {
      // Arrange
      final invitationWithoutMessage = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.pending,
        message: null, // Null message
        createdAt: DateTime.now().subtract(const Duration(hours: 2)),
        expiresAt: DateTime.now().add(const Duration(days: 7)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: invitationWithoutMessage,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert - Should not crash and should show default message
      expect(find.text('You\'re invited to join this crew!'), findsOneWidget);
    });

    testWidgets('displays responder information for responded invitations', (WidgetTester tester) async {
      // Arrange
      final respondedInvitation = CrewInvitation(
        id: 'test-invitation-id',
        crewId: 'test-crew-id',
        crewName: 'IBEW Local 123 Crew',
        inviterId: 'inviter-id',
        inviterName: 'John Smith',
        inviteeId: 'invitee-id',
        inviteeEmail: 'test@example.com',
        status: CrewInvitationStatus.accepted,
        message: 'Please join our crew.',
        createdAt: DateTime.now().subtract(const Duration(days: 1)),
        expiresAt: DateTime.now().add(const Duration(days: 6)),
        respondedAt: DateTime.now().subtract(const Duration(hours: 1)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewInvitationCard(
            invitation: respondedInvitation,
            isIncoming: true,
            onAccept: mockOnAccept,
            onDecline: mockOnDecline,
            onCancel: mockOnCancel,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Responded 1 hour ago'), findsOneWidget);
    });

    group('Accessibility', () {
      testWidgets('has proper accessibility labels', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.bySemanticsLabel('Accept invitation to IBEW Local 123 Crew'),
          findsOneWidget,
        );
        expect(
          find.bySemanticsLabel('Decline invitation to IBEW Local 123 Crew'),
          findsOneWidget,
        );
      });

      testWidgets('accept button has correct accessibility hints', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.bySemanticsLabel('Accept invitation'),
          findsOneWidget,
        );
      });

      testWidgets('status badges are properly announced', (WidgetTester tester) async {
        // Arrange
        final acceptedInvitation = CrewInvitation(
          id: 'test-invitation-id',
          crewId: 'test-crew-id',
          crewName: 'IBEW Local 123 Crew',
          inviterId: 'inviter-id',
          inviterName: 'John Smith',
          inviteeId: 'invitee-id',
          inviteeEmail: 'test@example.com',
          status: CrewInvitationStatus.accepted,
          message: 'Please join our crew.',
          createdAt: DateTime.now().subtract(const Duration(days: 1)),
          expiresAt: DateTime.now().add(const Duration(days: 6)),
          respondedAt: DateTime.now().subtract(const Duration(hours: 1)),
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: CrewInvitationCard(
              invitation: acceptedInvitation,
              isIncoming: true,
              onAccept: mockOnAccept,
              onDecline: mockOnDecline,
              onCancel: mockOnCancel,
            ),
          ),
        ));

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(find.bySemanticsLabel('Status: Accepted'), findsOneWidget);
      });
    });
  });
}