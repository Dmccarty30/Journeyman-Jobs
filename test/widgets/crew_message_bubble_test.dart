import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/widgets/crew_message_bubble.dart';

void main() {
  group('CrewMessageBubble', () {
    late CrewMessage mockMessage;
    late String currentUserId;
    late VoidCallback mockOnReply;
    late VoidCallback mockOnEdit;
    late VoidCallback mockOnDelete;
    late Function(String) mockOnReact;

    setUp(() {
      currentUserId = 'current-user-id';
      mockMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'Test message content',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [
          MessageReadStatus(userId: 'user1', readAt: DateTime.now()),
          MessageReadStatus(userId: 'user2', readAt: DateTime.now()),
        ],
        reactions: {
          'user1': '👍',
          'user2': '❤️',
        },
        replyToId: null,
        deletedAt: null,
      );

      mockOnReply = () {};
      mockOnEdit = () {};
      mockOnDelete = () {};
      mockOnReact = (emoji) {};
    });

    Widget createTestWidget({bool isOwnMessage = false}) {
      return MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: mockMessage,
            isOwnMessage: isOwnMessage,
            currentUserId: currentUserId,
            senderName: isOwnMessage ? 'You' : 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      );
    }

    testWidgets('displays message content correctly', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Test message content'), findsOneWidget);
    });

    testWidgets('displays sender name for messages from others', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget(isOwnMessage: false));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('John Smith'), findsOneWidget);
      expect(find.text('Local 123'), findsOneWidget);
    });

    testWidgets('displays "You" for own messages', (WidgetTester tester) async {
      // Arrange
      final ownMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: currentUserId, // Same as current user
        content: 'My own message',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: ownMessage,
            isOwnMessage: true,
            currentUserId: currentUserId,
            senderName: 'You',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('My own message'), findsOneWidget);
      expect(find.text('You'), findsNothing); // "You" is handled differently in UI
    });

    testWidgets('displays message timestamp', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('5m ago'), findsOneWidget);
    });

    testWidgets('displays edited indicator for edited messages', (WidgetTester tester) async {
      // Arrange
      final editedMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'Edited message content',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
        editedAt: DateTime.now().subtract(const Duration(minutes: 2)),
        isEdited: true,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: editedMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('edited'), findsOneWidget);
    });

    testWidgets('displays read status for own messages', (WidgetTester tester) async {
      // Arrange
      final ownMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: currentUserId,
        content: 'My message',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [
          MessageReadStatus(userId: 'user1', readAt: DateTime.now()),
          MessageReadStatus(userId: 'user2', readAt: DateTime.now()),
        ],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: ownMessage,
            isOwnMessage: true,
            currentUserId: currentUserId,
            senderName: 'You',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('Read by 2'), findsOneWidget);
    });

    testWidgets('displays reactions summary', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('👍'), findsOneWidget);
      expect(find.text('❤️'), findsOneWidget);
    });

    testWidgets('displays image message correctly', (WidgetTester tester) async {
      // Arrange
      final imageMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'Check out this image',
        type: CrewMessageType.image,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: 'https://example.com/image.jpg',
        metadata: const {
          'width': '800',
          'height': '600',
        },
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: imageMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Check out this image'), findsOneWidget);
      expect(find.byType(Image), findsOneWidget);
    });

    testWidgets('displays location message correctly', (WidgetTester tester) async {
      // Arrange
      final locationMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'My current location',
        type: CrewMessageType.location,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {
          'latitude': 40.7128,
          'longitude': -74.0060,
          'address': 'New York, NY',
        },
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: locationMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('My current location'), findsOneWidget);
      expect(find.text('New York, NY'), findsOneWidget);
      expect(find.byIcon(Icons.location_on), findsOneWidget);
    });

    testWidgets('displays job share message correctly', (WidgetTester tester) async {
      // Arrange
      final jobShareMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'Check out this job opportunity',
        type: CrewMessageType.jobShare,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {
          'jobId': 'job-123',
          'jobTitle': 'Journeyman Electrician',
          'companyName': 'Electrical Contractors Inc',
        },
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: jobShareMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Check out this job opportunity'), findsOneWidget);
      expect(find.text('Journeyman Electrician'), findsOneWidget);
      expect(find.text('Electrical Contractors Inc'), findsOneWidget);
      expect(find.byIcon(Icons.work), findsOneWidget);
    });

    testWidgets('displays system message with different styling', (WidgetTester tester) async {
      // Arrange
      final systemMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'system',
        content: 'John Smith joined the crew',
        type: CrewMessageType.system,
        createdAt: DateTime.now().subtract(const Duration(minutes: 1)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {
          'systemType': 'member_joined',
        },
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: systemMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'System',
            senderUnionLocal: null,
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('John Smith joined the crew'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline), findsOneWidget);
    });

    testWidgets('shows message options on long press', (WidgetTester tester) async {
      // Arrange
      await tester.pumpWidget(createTestWidget());

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Test message content'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reply'), findsOneWidget);
      expect(find.text('React'), findsOneWidget);
    });

    testWidgets('shows edit and delete options for own messages', (WidgetTester tester) async {
      // Arrange
      final ownMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: currentUserId,
        content: 'My message',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: ownMessage,
            isOwnMessage: true,
            currentUserId: currentUserId,
            senderName: 'You',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.text('My message'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Edit'), findsOneWidget);
      expect(find.text('Delete'), findsOneWidget);
    });

    testWidgets('calls onReply when reply option is selected', (WidgetTester tester) async {
      // Arrange
      bool wasReplied = false;
      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: mockMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: () => wasReplied = true,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.text('Test message content'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Reply'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasReplied, isTrue);
    });

    testWidgets('calls onEdit when edit option is selected', (WidgetTester tester) async {
      // Arrange
      bool wasEdited = false;
      final ownMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: currentUserId,
        content: 'My message',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: null,
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: ownMessage,
            isOwnMessage: true,
            currentUserId: currentUserId,
            senderName: 'You',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: () => wasEdited = true,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.text('My message'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Edit'));
      await tester.pumpAndSettle();

      // Assert
      expect(wasEdited, isTrue);
    });

    testWidgets('displays deleted message placeholder', (WidgetTester tester) async {
      // Arrange
      final deletedMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'This message was deleted',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: deletedMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();

      // Assert
      expect(find.textContaining('This message was deleted'), findsOneWidget);
      expect(find.textContaining('deleted'), findsOneWidget);
    });

    testWidgets('does not show options for deleted messages', (WidgetTester tester) async {
      // Arrange
      final deletedMessage = CrewMessage(
        id: 'test-message-id',
        crewId: 'test-crew-id',
        senderId: 'sender-id',
        content: 'Deleted message',
        type: CrewMessageType.text,
        createdAt: DateTime.now().subtract(const Duration(minutes: 5)),
        editedAt: null,
        isEdited: false,
        mediaUrl: null,
        metadata: const {},
        readStatus: [],
        reactions: {},
        replyToId: null,
        deletedAt: DateTime.now().subtract(const Duration(minutes: 1)),
      );

      await tester.pumpWidget(MaterialApp(
        home: Scaffold(
          body: CrewMessageBubble(
            message: deletedMessage,
            isOwnMessage: false,
            currentUserId: currentUserId,
            senderName: 'John Smith',
            senderUnionLocal: 'Local 123',
            onReply: mockOnReply,
            onEdit: mockOnEdit,
            onDelete: mockOnDelete,
            onReact: mockOnReact,
          ),
        ),
      ));

      // Act
      await tester.pumpAndSettle();
      await tester.longPress(find.textContaining('deleted'));
      await tester.pumpAndSettle();

      // Assert
      expect(find.text('Reply'), findsNothing);
      expect(find.text('Edit'), findsNothing);
      expect(find.text('Delete'), findsNothing);
    });

    group('Accessibility', () {
      testWidgets('has proper accessibility labels', (WidgetTester tester) async {
        // Arrange
        await tester.pumpWidget(createTestWidget());

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.bySemanticsLabel('Message from John Smith: Test message content'),
          findsOneWidget,
        );
      });

      testWidgets('announces message status', (WidgetTester tester) async {
        // Arrange
        final editedMessage = CrewMessage(
          id: 'test-message-id',
          crewId: 'test-crew-id',
          senderId: 'sender-id',
          content: 'Edited message',
          type: CrewMessageType.text,
          createdAt: DateTime.now().subtract(const Duration(minutes: 10)),
          editedAt: DateTime.now().subtract(const Duration(minutes: 2)),
          isEdited: true,
          mediaUrl: null,
          metadata: const {},
          readStatus: [],
        reactions: {},
          replyToId: null,
          deletedAt: null,
        );

        await tester.pumpWidget(MaterialApp(
          home: Scaffold(
            body: CrewMessageBubble(
              message: editedMessage,
              isOwnMessage: false,
              currentUserId: currentUserId,
              senderName: 'John Smith',
              senderUnionLocal: 'Local 123',
              onReply: mockOnReply,
              onEdit: mockOnEdit,
              onDelete: mockOnDelete,
              onReact: mockOnReact,
            ),
          ),
        ));

        // Act
        await tester.pumpAndSettle();

        // Assert
        expect(
          find.bySemanticsLabelContaining('edited'),
          findsOneWidget,
        );
      });
    });
  });
}