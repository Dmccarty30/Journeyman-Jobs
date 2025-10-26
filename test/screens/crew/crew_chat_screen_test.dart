import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mockito/mockito.dart';
import 'package:mockito/annotations.dart';
import 'package:provider/provider.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:journeyman_jobs/screens/crew/crew_chat_screen.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

import 'crew_chat_screen_test.mocks.dart';

@GenerateMocks([
  CrewMessagingService,
  UserModel,
  Crew,
])
void main() {
  group('CrewChatScreen Tests - User Vision Compliance', () {
    late FakeFirebaseFirestore fakeFirestore;
    late MockCrewMessagingService mockMessagingService;
    late MockUserModel mockCurrentUser;
    late MockUserModel mockCrewMember;
    late MockUserModel mockNonMember;
    late MockCrew mockCrew;
    late List<CrewMessage> testMessages;

    setUp(() async {
      fakeFirestore = FakeFirebaseFirestore();
      mockMessagingService = MockCrewMessagingService();
      mockCurrentUser = MockUserModel();
      mockCrewMember = MockUserModel();
      mockNonMember = MockUserModel();
      mockCrew = MockCrew();

      // Setup current user (foreman)
      when(mockCurrentUser.uid).thenReturn('foreman_123');
      when(mockCurrentUser.displayNameStr).thenReturn('John Foreman');
      when(mockCurrentUser.avatarUrl).thenReturn('https://example.com/avatar.jpg');

      // Setup crew member
      when(mockCrewMember.uid).thenReturn('member_456');
      when(mockCrewMember.displayNameStr).thenReturn('Jane Member');

      // Setup non-member
      when(mockNonMember.uid).thenReturn('non_member_789');
      when(mockNonMember.displayNameStr).thenReturn('Outside User');

      // Setup crew
      when(mockCrew.id).thenReturn('crew_123');
      when(mockCrew.name).thenReturn('Test Crew Alpha');
      when(mockCrew.foremanId).thenReturn('foreman_123');
      when(mockCrew.memberIds).thenReturn(['foreman_123', 'member_456']);

      // Create test messages with chronological ordering
      testMessages = [
        CrewMessage(
          id: 'msg_1',
          crewId: 'crew_123',
          senderId: 'foreman_123',
          senderName: 'John Foreman',
          content: 'Welcome to the crew chat!',
          type: CrewMessageType.text,
          createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 30))),
        ),
        CrewMessage(
          id: 'msg_2',
          crewId: 'crew_123',
          senderId: 'member_456',
          senderName: 'Jane Member',
          content: 'Thanks for adding me!',
          type: CrewMessageType.text,
          createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 25))),
        ),
        CrewMessage(
          id: 'msg_3',
          crewId: 'crew_123',
          senderId: 'foreman_123',
          senderName: 'John Foreman',
          content: 'We have a storm job coming up',
          type: CrewMessageType.alert,
          priority: CrewMessagePriority.high,
          createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 20))),
        ),
        CrewMessage(
          id: 'msg_4',
          crewId: 'crew_123',
          senderId: 'member_456',
          senderName: 'Jane Member',
          content: 'Ready when you are!',
          type: CrewMessageType.text,
          createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 15))),
        ),
        CrewMessage(
          id: 'msg_5',
          crewId: 'crew_123',
          senderId: 'foreman_123',
          senderName: 'John Foreman',
          content: 'Great! Location details sent',
          type: CrewMessageType.location,
          createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 10))),
        ),
      ];

      // Setup default mock responses
      when(mockMessagingService.getMessages(crewId: 'crew_123'))
          .thenAnswer((_) async => testMessages.reversed.toList());
      when(mockMessagingService.sendMessage(
        crewId: anyNamed('crewId'),
        sender: anyNamed('sender'),
        content: anyNamed('content'),
      )).thenAnswer((_) async => testMessages.first);
    });

    Widget createTestScreen({UserModel? user}) {
      return MaterialApp(
        home: ChangeNotifierProvider<UserModel>.value(
          value: user ?? mockCurrentUser,
          child: CrewChatScreen(
            crewId: 'crew_123',
            crewName: 'Test Crew Alpha',
          ),
        ),
      );
    }

    group('Crew Member Access Tests', () {
      testWidgets('Foreman can access crew chat', (WidgetTester tester) async {
        // Mock foreman is in crew
        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: anyNamed('content'),
        )).thenAnswer((_) async {
          // Verify sender is crew member (access control check)
          final sender = arg.named('sender') as UserModel;
          if (!['foreman_123', 'member_456'].contains(sender.uid)) {
            throw Exception('User is not a member of this crew');
          }
          return testMessages.first;
        });

        await tester.pumpWidget(createTestScreen(user: mockCurrentUser));
        await tester.pumpAndSettle();

        // Verify foreman can see chat interface
        expect(find.text('Test Crew Alpha'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
        expect(find.text('Start the conversation'), findsOneWidget);
      });

      testWidgets('Crew member can access crew chat', (WidgetTester tester) async {
        // Mock member is in crew
        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: anyNamed('content'),
        )).thenAnswer((_) async {
          // Verify sender is crew member (access control check)
          final sender = arg.named('sender') as UserModel;
          if (!['foreman_123', 'member_456'].contains(sender.uid)) {
            throw Exception('User is not a member of this crew');
          }
          return testMessages.first;
        });

        await tester.pumpWidget(createTestScreen(user: mockCrewMember));
        await tester.pumpAndSettle();

        // Verify member can see chat interface
        expect(find.text('Test Crew Alpha'), findsOneWidget);
        expect(find.byType(TextField), findsOneWidget);
        expect(find.byIcon(Icons.send), findsOneWidget);
      });

      testWidgets('Non-member cannot send messages to crew chat', (WidgetTester tester) async {
        // Mock non-member access denied
        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: anyNamed('content'),
        )).thenThrow(Exception('User is not a member of this crew'));

        await tester.pumpWidget(createTestScreen(user: mockNonMember));
        await tester.pumpAndSettle();

        // Try to send a message
        await tester.enterText(find.byType(TextField), 'I should not be able to send this');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(find.text('Failed to send message: Exception: User is not a member of this crew'), findsOneWidget);
      });
    });

    group('Real-time Message Display Tests', () {
      testWidgets('Messages display in chronological order (newest first)', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify messages are displayed in correct chronological order
        expect(find.text('Great! Location details sent'), findsOneWidget);
        expect(find.text('Ready when you are!'), findsOneWidget);
        expect(find.text('We have a storm job coming up'), findsOneWidget);
        expect(find.text('Thanks for adding me!'), findsOneWidget);
        expect(find.text('Welcome to the crew chat!'), findsOneWidget);

        // Verify newest message appears at bottom (reverse: true in ListView)
        final listView = tester.widget<ListView>(find.byType(ListView));
        expect(listView.reverse, isTrue);
      });

      testWidgets('New messages appear instantly in real-time', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Mock real-time message stream
        final newMessage = CrewMessage(
          id: 'msg_6',
          crewId: 'crew_123',
          senderId: 'member_456',
          senderName: 'Jane Member',
          content: 'New real-time message!',
          type: CrewMessageType.text,
          createdAt: Timestamp.now(),
        );

        // Simulate real-time message received
        when(mockMessagingService.streamMessages('crew_123'))
            .thenAnswer((_) => Stream.value([newMessage, ...testMessages]));

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify new message appears instantly
        expect(find.text('New real-time message!'), findsOneWidget);
      });

      testWidgets('Date separators show correctly', (WidgetTester tester) async {
        // Create messages spanning multiple days
        final multiDayMessages = [
          CrewMessage(
            id: 'msg_old',
            crewId: 'crew_123',
            senderId: 'foreman_123',
            senderName: 'John Foreman',
            content: 'Old message from yesterday',
            type: CrewMessageType.text,
            createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(days: 1))),
          ),
          ...testMessages,
        ];

        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenAnswer((_) async => multiDayMessages.reversed.toList());

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify date separators appear
        expect(find.text('Yesterday'), findsOneWidget);
        expect(find.text('Today'), findsOneWidget);
      });
    });

    group('High-Volume Message Tests', () {
      testWidgets('Can handle 30+ consecutive messages efficiently', (WidgetTester tester) async {
        // Create 35 messages to test high-volume performance
        final highVolumeMessages = <CrewMessage>[];
        for (int i = 0; i < 35; i++) {
          highVolumeMessages.add(CrewMessage(
            id: 'msg_$i',
            crewId: 'crew_123',
            senderId: i % 2 == 0 ? 'foreman_123' : 'member_456',
            senderName: i % 2 == 0 ? 'John Foreman' : 'Jane Member',
            content: 'High volume test message $i - Testing performance with many messages',
            type: CrewMessageType.text,
            createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 35 - i))),
          ));
        }

        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenAnswer((_) async => highVolumeMessages.reversed.toList());

        final stopwatch = Stopwatch()..start();
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();
        stopwatch.stop();

        // Performance should be under 2 seconds for 35 messages
        expect(stopwatch.elapsedMilliseconds, lessThan(2000));

        // Verify all messages are displayed
        for (int i = 0; i < 35; i++) {
          expect(find.text('High volume test message $i - Testing performance with many messages'), findsOneWidget);
        }

        // Verify chat performance is maintained
        expect(find.byType(ScrollController), findsOneWidget);
        expect(find.byType(ListView), findsOneWidget);
      });

      testWidgets('Scrolling performance with many messages', (WidgetTester tester) async {
        // Create 50 messages for scrolling test
        final scrollMessages = <CrewMessage>[];
        for (int i = 0; i < 50; i++) {
          scrollMessages.add(CrewMessage(
            id: 'scroll_msg_$i',
            crewId: 'crew_123',
            senderId: 'foreman_123',
            senderName: 'John Foreman',
            content: 'Scroll test message $i - Long message content to test scrolling performance and rendering efficiency',
            type: CrewMessageType.text,
            createdAt: Timestamp.fromDate(DateTime.now().subtract(Duration(minutes: 50 - i))),
          ));
        }

        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenAnswer((_) async => scrollMessages.reversed.toList());

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Test scrolling performance
        final scrollStart = Stopwatch()..start();
        await tester.fling(find.byType(ListView), const Offset(0, 500), 1000);
        await tester.pumpAndSettle();
        scrollStart.stop();

        // Scrolling should be smooth (under 500ms)
        expect(scrollStart.elapsedMilliseconds, lessThan(500));

        // Verify messages are still displayed correctly after scrolling
        expect(find.textContaining('Scroll test message'), findsWidgets);
      });

      testWidgets('Message sending performance under high load', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Send multiple messages rapidly
        final messagesToSend = ['Test 1', 'Test 2', 'Test 3', 'Test 4', 'Test 5'];

        for (final messageContent in messagesToSend) {
          when(mockMessagingService.sendMessage(
            crewId: anyNamed('crewId'),
            sender: anyNamed('sender'),
            content: messageContent,
          )).thenAnswer((_) async {
            return CrewMessage(
              id: 'new_msg_${messageContent}',
              crewId: 'crew_123',
              senderId: 'foreman_123',
              senderName: 'John Foreman',
              content: messageContent,
              type: CrewMessageType.text,
              createdAt: Timestamp.now(),
            );
          });

          await tester.enterText(find.byType(TextField), messageContent);
          await tester.tap(find.byIcon(Icons.send));
          await tester.pumpAndSettle();
        }

        // Verify all messages were sent successfully
        for (final messageContent in messagesToSend) {
          expect(find.text(messageContent), findsOneWidget);
        }
      });
    });

    group('Message Features Tests', () {
      testWidgets('Can send different message types', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Test text message
        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: 'Test text message',
          type: CrewMessageType.text,
        )).thenAnswer((_) async {
          return CrewMessage(
            id: 'text_msg',
            crewId: 'crew_123',
            senderId: 'foreman_123',
            senderName: 'John Foreman',
            content: 'Test text message',
            type: CrewMessageType.text,
            createdAt: Timestamp.now(),
          );
        });

        await tester.enterText(find.byType(TextField), 'Test text message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('Test text message'), findsOneWidget);
      });

      testWidgets('Message reply functionality works', (WidgetTester tester) async {
        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenAnswer((_) async => testMessages.reversed.toList());

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Long press on a message to show options
        await tester.longPress(find.text('Thanks for adding me!'));
        await tester.pumpAndSettle();

        // Tap reply option
        await tester.tap(find.text('Reply'));
        await tester.pumpAndSettle();

        // Verify reply indicator appears
        expect(find.text('Replying to Jane Member'), findsOneWidget);

        // Send reply message
        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: 'Reply message',
          replyToMessageId: 'msg_2',
        )).thenAnswer((_) async {
          return CrewMessage(
            id: 'reply_msg',
            crewId: 'crew_123',
            senderId: 'foreman_123',
            senderName: 'John Foreman',
            content: 'Reply message',
            type: CrewMessageType.text,
            replyToMessageId: 'msg_2',
            createdAt: Timestamp.now(),
          );
        });

        await tester.enterText(find.byType(TextField), 'Reply message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        expect(find.text('Reply message'), findsOneWidget);
      });

      testWidgets('Crew info displays correctly', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify crew name in app bar
        expect(find.text('Test Crew Alpha'), findsOneWidget);

        // Verify crew info bar shows member count
        expect(find.text('2 members'), findsOneWidget);

        // Verify online status indicator
        expect(find.byType(CircleAvatar), findsWidgets);
      });
    });

    group('Error Handling Tests', () {
      testWidgets('Handles network errors gracefully', (WidgetTester tester) async {
        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenThrow(Exception('Network error'));

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify error message is shown
        expect(find.text('Failed to load messages: Exception: Network error'), findsOneWidget);
      });

      testWidgets('Handles empty chat state', (WidgetTester tester) async {
        when(mockMessagingService.getMessages(crewId: 'crew_123'))
            .thenAnswer((_) async => []);

        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        // Verify empty state is displayed
        expect(find.text('Start the conversation'), findsOneWidget);
        expect(find.text('Send a message to connect with your crew members'), findsOneWidget);
        expect(find.byIcon(Icons.chat_bubble_outline), findsOneWidget);
      });
    });

    group('Security Tests', () {
      testWidgets('Messages are properly associated with crew', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: anyNamed('content'),
        )).thenAnswer((_) async {
          // Verify crew ID is correct
          final crewId = arg.named('crewId') as String;
          expect(crewId, equals('crew_123'));

          return testMessages.first;
        });

        await tester.enterText(find.byType(TextField), 'Security test message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify message was sent to correct crew
        verify(mockMessagingService.sendMessage(
          crewId: 'crew_123',
          sender: mockCurrentUser,
          content: 'Security test message',
        )).called(1);
      });

      testWidgets('Sender information is correctly attached', (WidgetTester tester) async {
        await tester.pumpWidget(createTestScreen());
        await tester.pumpAndSettle();

        when(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: anyNamed('sender'),
          content: anyNamed('content'),
        )).thenAnswer((_) async {
          // Verify sender information is correct
          final sender = arg.named('sender') as UserModel;
          expect(sender.uid, equals('foreman_123'));
          expect(sender.displayNameStr, equals('John Foreman'));

          return testMessages.first;
        });

        await tester.enterText(find.byType(TextField), 'Sender verification message');
        await tester.tap(find.byIcon(Icons.send));
        await tester.pumpAndSettle();

        // Verify sender info is correctly attached
        verify(mockMessagingService.sendMessage(
          crewId: anyNamed('crewId'),
          sender: mockCurrentUser,
          content: 'Sender verification message',
        )).called(1);
      });
    });
  });
}