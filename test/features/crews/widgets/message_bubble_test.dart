import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/features/crews/models/crew_communication.dart';
import 'package:journeyman_jobs/features/crews/models/crew_enums.dart';
import 'package:journeyman_jobs/features/crews/widgets/message_bubble.dart';

void main() {
  group('MessageBubble Widget Tests', () {
    late CrewCommunication testMessage;

    setUp(() {
      testMessage = CrewCommunication(
        id: 'test-message-1',
        crewId: 'test-crew-1',
        senderId: 'test-user-1',
        content: 'Test message content for IBEW electrical crew',
        type: MessageType.text,
        timestamp: DateTime.now(),
        attachments: [],
        readBy: {},
        isPinned: false,
        isEdited: false,
        senderName: 'John Doe',
        senderRole: 'Journeyman',
      );
    });

    testWidgets('renders text message correctly', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isCurrentUser: false,
            ),
          ),
        ),
      );

      expect(find.text('Test message content for IBEW electrical crew'), findsOneWidget);
      expect(find.text('John Doe'), findsOneWidget);
    });

    testWidgets('displays emergency message with alert styling', (WidgetTester tester) async {
      final emergencyMessage = testMessage.copyWith(
        type: MessageType.emergency,
        content: 'EMERGENCY: Worker injury on site, need immediate assistance',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: emergencyMessage,
              isCurrentUser: false,
            ),
          ),
        ),
      );

      expect(find.text('EMERGENCY'), findsOneWidget);
      expect(find.byIcon(Icons.emergency), findsOneWidget);
      expect(find.text('EMERGENCY: Worker injury on site, need immediate assistance'), findsOneWidget);
    });

    testWidgets('displays safety alert with warning styling', (WidgetTester tester) async {
      final safetyMessage = testMessage.copyWith(
        type: MessageType.safetyAlert,
        content: 'Safety reminder: Hard hats required in this area',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: safetyMessage,
              isCurrentUser: false,
            ),
          ),
        ),
      );

      expect(find.text('SAFETY ALERT'), findsOneWidget);
      expect(find.byIcon(Icons.warning), findsOneWidget);
    });

    testWidgets('shows role badge for crew members', (WidgetTester tester) async {
      final messageWithRole = testMessage.copyWith(
        senderRole: 'Foreman',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: messageWithRole,
              isCurrentUser: false,
              showSenderName: true,
            ),
          ),
        ),
      );

      expect(find.text('FOREMAN'), findsOneWidget);
    });

    testWidgets('displays system message with proper styling', (WidgetTester tester) async {
      final systemMessage = testMessage.copyWith(
        type: MessageType.system,
        content: 'John Doe joined the crew',
      );

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: systemMessage,
              isCurrentUser: false,
              isSystemMessage: true,
            ),
          ),
        ),
      );

      expect(find.text('John Doe joined the crew'), findsOneWidget);
      expect(find.byIcon(Icons.info), findsOneWidget);
    });

    testWidgets('handles message with attachments', (WidgetTester tester) async {
      // This test would require creating MessageAttachment objects
      // Skipped for now as it requires more complex setup
    });

    testWidgets('responds to tap gestures', (WidgetTester tester) async {
      bool tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isCurrentUser: false,
              onTap: () => tapped = true,
            ),
          ),
        ),
      );

      await tester.tap(find.byType(MessageBubble));
      expect(tapped, isTrue);
    });

    testWidgets('displays timestamp when enabled', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isCurrentUser: false,
              showTimestamp: true,
            ),
          ),
        ),
      );

      // Should find timestamp text (exact format depends on implementation)
      expect(find.textContaining('ago'), findsOneWidget);
    });

    testWidgets('shows different styling for current user messages', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: MessageBubble(
              message: testMessage,
              isCurrentUser: true,
            ),
          ),
        ),
      );

      // Current user messages should be aligned differently and have different colors
      // This would require more detailed widget tree inspection
      expect(find.byType(MessageBubble), findsOneWidget);
    });
  });
}
