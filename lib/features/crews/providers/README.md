# CrewCommunicationProvider Documentation

## Overview

The `CrewCommunicationProvider` is a comprehensive state management solution for real-time crew communication in the Journeyman Jobs app. Built specifically for IBEW electrical workers, it handles messaging, safety alerts, emergency communications, and coordination messaging with offline support and electrical safety protocol integration.

## Key Features

- **Real-time messaging** with Firestore streams
- **Typing indicators** for enhanced UX
- **Attachment upload** with progress tracking
- **Offline message queue** with automatic sync
- **Unread count tracking** by crew
- **Safety protocols** for electrical workers
- **Emergency alert system** with location sharing
- **Message read receipts** and delivery status

## Architecture

### State Structure

```dart
class CrewCommunicationState {
  final Map<String, List<CrewCommunication>> messagesByCrewId;
  final Map<String, bool> loadingStates;
  final Map<String, String?> errors;
  final Map<String, int> unreadCounts;
  final Map<String, Set<String>> typingIndicators;
  final Map<String, double> uploadProgress;
  final List<Map<String, dynamic>> offlineMessageQueue;
  final bool isOnline;
}
```

### Provider Hierarchy

- `CrewCommunicationNotifier` - Main state manager
- `crewCommunicationServiceProvider` - Service layer
- `communicationConnectivityServiceProvider` - Connectivity monitoring
- Multiple specialized providers for specific data access

## Usage Examples

### 1. Basic Message Sending

```dart
// In your widget
class CrewChatScreen extends ConsumerWidget {
  final String crewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final communicationNotifier = ref.read(crewCommunicationNotifierProvider.notifier);

    // Send a basic text message
    void sendMessage(String content) {
      communicationNotifier.sendMessage(
        crewId: crewId,
        content: content,
        messageType: MessageType.text,
      );
    }

    return Scaffold(
      // Your chat UI here
    );
  }
}
```

### 2. Real-time Message Listening

```dart
// Start listening to messages for a crew
class CrewChatWidget extends ConsumerStatefulWidget {
  final String crewId;

  @override
  ConsumerState<CrewChatWidget> createState() => _CrewChatWidgetState();
}

class _CrewChatWidgetState extends ConsumerState<CrewChatWidget> {
  @override
  void initState() {
    super.initState();
    // Start listening when widget initializes
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crewCommunicationNotifierProvider.notifier)
          .startListeningToMessages(widget.crewId);
    });
  }

  @override
  void dispose() {
    // Stop listening when widget disposes
    ref.read(crewCommunicationNotifierProvider.notifier)
        .stopListeningToMessages(widget.crewId);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Watch messages stream
    final messagesAsync = ref.watch(crewMessagesProvider(widget.crewId));

    return messagesAsync.when(
      data: (messages) => ListView.builder(
        itemCount: messages.length,
        itemBuilder: (context, index) => MessageTile(message: messages[index]),
      ),
      loading: () => CircularProgressIndicator(),
      error: (error, stack) => Text('Error: $error'),
    );
  }
}
```

### 3. Safety Alert System

```dart
// Send safety announcement
void sendSafetyAlert() async {
  final notifier = ref.read(crewCommunicationNotifierProvider.notifier);

  try {
    await notifier.sendSafetyAnnouncement(
      crewId: 'crew_123',
      content: 'High voltage hazard identified at transformer bank. All crews exercise extreme caution.',
      safetyLevel: SafetyLevel.highVoltageHazard,
      urgency: MessageUrgency.critical,
    );
  } catch (e) {
    // Handle error
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Failed to send safety alert: $e')),
    );
  }
}

// Send emergency alert with location
void sendEmergencyAlert(Map<String, dynamic> location) async {
  final notifier = ref.read(crewCommunicationNotifierProvider.notifier);

  try {
    await notifier.sendEmergencyAlert(
      crewId: 'crew_123',
      content: 'EMERGENCY: Worker injured at job site. Immediate medical assistance required.',
      location: location,
    );
  } catch (e) {
    // Handle error
  }
}
```

### 4. Safety Check-in Protocol

```dart
// Regular safety check-in for electrical workers
void performSafetyCheckin() async {
  final notifier = ref.read(crewCommunicationNotifierProvider.notifier);

  try {
    await notifier.sendSafetyCheckin(
      crewId: 'crew_123',
      content: 'Crew safety check-in: All clear at substation Alpha',
      safetyStatus: SafetyStatus.allClear,
      clearances: ['Line 1 cleared', 'Transformer isolated'],
      crewCount: 4,
      location: 'Substation Alpha - Bay 2',
    );
  } catch (e) {
    // Handle error
  }
}
```

### 5. Attachment Upload with Progress

```dart
// Upload attachment with progress tracking
class AttachmentUploadWidget extends ConsumerWidget {
  final File file;
  final String messageId;
  final String attachmentId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final progress = state.getUploadProgressForAttachment(attachmentId);

    // Show upload progress
    if (progress > 0 && progress < 1) {
      return Column(
        children: [
          LinearProgressIndicator(value: progress),
          Text('Uploading... ${(progress * 100).toInt()}%'),
        ],
      );
    }

    return ElevatedButton(
      onPressed: () => _uploadFile(ref),
      child: Text('Upload Attachment'),
    );
  }

  Future<void> _uploadFile(WidgetRef ref) async {
    final notifier = ref.read(crewCommunicationNotifierProvider.notifier);

    try {
      final url = await notifier.uploadAttachment(
        messageId: messageId,
        attachment: file,
        attachmentId: attachmentId,
      );

      // Handle successful upload
      print('File uploaded: $url');
    } catch (e) {
      // Handle error
      print('Upload failed: $e');
    }
  }
}
```

### 6. Typing Indicators

```dart
// Show typing indicators
class TypingIndicatorWidget extends ConsumerWidget {
  final String crewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final typingUsers = state.getTypingUsersForCrew(crewId);

    if (typingUsers.isEmpty) return SizedBox.shrink();

    return Container(
      padding: EdgeInsets.all(8),
      child: Text(
        '${typingUsers.join(', ')} ${typingUsers.length == 1 ? 'is' : 'are'} typing...',
        style: TextStyle(
          fontStyle: FontStyle.italic,
          color: Colors.grey[600],
        ),
      ),
    );
  }
}

// Set typing indicator
class MessageInputWidget extends ConsumerStatefulWidget {
  final String crewId;
  final String currentUserId;

  @override
  ConsumerState<MessageInputWidget> createState() => _MessageInputWidgetState();
}

class _MessageInputWidgetState extends ConsumerState<MessageInputWidget> {
  final TextEditingController _controller = TextEditingController();
  Timer? _typingTimer;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_onTextChanged);
  }

  void _onTextChanged() {
    final notifier = ref.read(crewCommunicationNotifierProvider.notifier);

    // Set typing indicator
    notifier.setTypingIndicator(widget.crewId, widget.currentUserId, true);

    // Reset typing indicator after delay
    _typingTimer?.cancel();
    _typingTimer = Timer(Duration(milliseconds: 1000), () {
      notifier.setTypingIndicator(widget.crewId, widget.currentUserId, false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: _controller,
      decoration: InputDecoration(
        hintText: 'Type a message...',
      ),
    );
  }

  @override
  void dispose() {
    _typingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
```

### 7. Unread Message Tracking

```dart
// Show unread count badge
class UnreadBadgeWidget extends ConsumerWidget {
  final String crewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final unreadCount = ref.watch(crewUnreadCountProvider(crewId));

    return unreadCount.when(
      data: (count) => count > 0
        ? Badge(
            label: Text('$count'),
            child: Icon(Icons.message),
          )
        : Icon(Icons.message),
      loading: () => Icon(Icons.message),
      error: (_, __) => Icon(Icons.message_outlined),
    );
  }
}

// Check for any unread messages
class GlobalUnreadIndicator extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hasUnread = ref.watch(hasUnreadMessagesProvider);
    final totalCount = ref.watch(totalUnreadCountProvider);

    return hasUnread
      ? Badge(
          label: Text('$totalCount'),
          child: Icon(Icons.chat_bubble),
        )
      : Icon(Icons.chat_bubble_outline);
  }
}
```

### 8. Error Handling

```dart
// Handle communication errors
class ErrorHandlingWidget extends ConsumerWidget {
  final String crewId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final error = state.getErrorForCrew(crewId);

    if (error != null) {
      return Container(
        padding: EdgeInsets.all(16),
        margin: EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.red.shade100,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.red.shade300),
        ),
        child: Row(
          children: [
            Icon(Icons.error, color: Colors.red),
            SizedBox(width: 8),
            Expanded(child: Text(error)),
            IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                ref.read(crewCommunicationNotifierProvider.notifier)
                    .clearErrorForCrew(crewId);
              },
            ),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
```

### 9. Offline Support

```dart
// Monitor offline status and pending messages
class OfflineStatusWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final pendingCount = ref.watch(offlineMessageCountProvider);

    if (!state.isOnline && pendingCount > 0) {
      return Container(
        padding: EdgeInsets.all(8),
        color: Colors.orange.shade100,
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.orange),
            SizedBox(width: 8),
            Text('Offline - $pendingCount messages queued'),
          ],
        ),
      );
    } else if (!state.isOnline) {
      return Container(
        padding: EdgeInsets.all(8),
        color: Colors.grey.shade200,
        child: Row(
          children: [
            Icon(Icons.cloud_off, color: Colors.grey),
            SizedBox(width: 8),
            Text('Offline mode'),
          ],
        ),
      );
    }

    return SizedBox.shrink();
  }
}
```

### 10. Message Actions

```dart
// Message action buttons (edit, delete, pin)
class MessageActionsWidget extends ConsumerWidget {
  final CrewCommunication message;
  final String currentUserId;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final notifier = ref.read(crewCommunicationNotifierProvider.notifier);
    final canEdit = message.senderId == currentUserId;

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (canEdit)
          IconButton(
            icon: Icon(Icons.edit),
            onPressed: () => _editMessage(context, notifier),
          ),
        if (canEdit)
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: () => _deleteMessage(notifier),
          ),
        IconButton(
          icon: Icon(message.isPinned ? Icons.push_pin : Icons.push_pin_outlined),
          onPressed: () => _pinMessage(notifier),
        ),
        IconButton(
          icon: Icon(Icons.reply),
          onPressed: () => _replyToMessage(),
        ),
      ],
    );
  }

  void _editMessage(BuildContext context, CrewCommunicationNotifier notifier) {
    showDialog(
      context: context,
      builder: (context) => EditMessageDialog(
        message: message,
        onSave: (newContent) async {
          await notifier.editMessage(
            crewId: message.crewId,
            messageId: message.id,
            newContent: newContent,
          );
        },
      ),
    );
  }

  void _deleteMessage(CrewCommunicationNotifier notifier) async {
    await notifier.deleteMessage(
      crewId: message.crewId,
      messageId: message.id,
    );
  }

  void _pinMessage(CrewCommunicationNotifier notifier) async {
    await notifier.pinMessage(
      crewId: message.crewId,
      messageId: message.id,
    );
  }

  void _replyToMessage() {
    // Implement reply functionality
  }
}
```

## Integration Guidelines

### 1. Provider Setup

Add the provider to your app's provider scope:

```dart
// In your main app widget
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ProviderScope(
      child: MaterialApp(
        // Your app configuration
      ),
    );
  }
}
```

### 2. Initialization

Initialize communication for specific crews when entering crew screens:

```dart
class CrewDetailScreen extends ConsumerStatefulWidget {
  final String crewId;

  @override
  ConsumerState<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

class _CrewDetailScreenState extends ConsumerState<CrewDetailScreen> {
  @override
  void initState() {
    super.initState();
    // Start listening to messages
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crewCommunicationNotifierProvider.notifier)
          .startListeningToMessages(widget.crewId);
    });
  }

  @override
  void dispose() {
    // Clean up listeners
    ref.read(crewCommunicationNotifierProvider.notifier)
        .stopListeningToMessages(widget.crewId);
    super.dispose();
  }
}
```

### 3. Performance Considerations

- **Memory Management**: Always stop listening when leaving crew screens
- **Batch Operations**: Use batch reads when possible
- **Smart Caching**: The provider handles caching automatically
- **Background Sync**: Offline messages sync automatically when online

### 4. Testing

```dart
// Example test setup
void main() {
  late ProviderContainer container;
  late MockCrewCommunicationService mockService;

  setUp(() {
    mockService = MockCrewCommunicationService();
    container = ProviderContainer(
      overrides: [
        crewCommunicationServiceProvider.overrideWithValue(mockService),
      ],
    );
  });

  tearDown(() {
    container.dispose();
  });

  testWidgets('should send message successfully', (tester) async {
    // Mock successful message sending
    when(mockService.sendMessage(any)).thenAnswer(
      (_) async => ServiceResult.success(mockMessage),
    );

    final notifier = container.read(crewCommunicationNotifierProvider.notifier);

    await notifier.sendMessage(
      crewId: 'test_crew',
      content: 'Test message',
      messageType: MessageType.text,
    );

    verify(mockService.sendMessage(any)).called(1);
  });
}
```

## Electrical Worker Specific Features

### Safety Protocols

The provider includes specialized methods for electrical safety:

- **Safety Check-ins**: Regular crew status reporting
- **Emergency Alerts**: Immediate notification system with location
- **Hazard Reporting**: Specific safety level classifications
- **Clearance Tracking**: Electrical clearance status management

### Storm Work Support

- **Priority Messaging**: Emergency messages get queue priority
- **Location Sharing**: GPS coordinates for emergency response
- **Crew Coordination**: Multi-crew coordination for large outages
- **Resource Tracking**: Equipment and personnel status

### Compliance Features

- **Audit Trail**: All safety messages are logged
- **Read Receipts**: Confirmation of message delivery
- **Retention Policy**: Messages retained per IBEW requirements
- **Privacy Protection**: PII handling per electrical worker guidelines

## Best Practices

1. **Always handle errors** - Communication can fail in field conditions
2. **Implement offline support** - Electrical workers often work in remote areas
3. **Use appropriate message types** - Leverage safety-specific message types
4. **Monitor connectivity** - Show offline status to users
5. **Batch operations** - Minimize battery drain and data usage
6. **Clean up resources** - Always dispose of listeners and timers
7. **Test thoroughly** - Use real-world scenarios including poor connectivity

## Troubleshooting

### Common Issues

1. **Messages not updating**: Ensure `startListeningToMessages()` is called
2. **Memory leaks**: Always call `stopListeningToMessages()` in dispose
3. **Offline queue not syncing**: Check connectivity service integration
4. **Upload progress not showing**: Verify attachment ID is unique
5. **Typing indicators stuck**: Check timer cleanup in dispose methods

### Debug Tips

- Use `ref.read(allCommunicationErrorsProvider)` to see all errors
- Monitor `isAnyCrewLoadingProvider` for loading states
- Check `offlineMessageCountProvider` for queued messages
- Verify connectivity with `communicationConnectivityServiceProvider`