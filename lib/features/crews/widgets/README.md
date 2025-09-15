# MessageBubble Widget

Professional messaging widget designed specifically for IBEW electrical worker crew communications. Features safety-first design, emergency messaging, and electrical industry-specific functionality.

## Features

### Message Types Support
- **Text Messages**: Standard crew communication
- **Safety Alerts**: Warning styling with orange accent
- **Emergency Messages**: High-priority red styling with urgent indicators
- **System Messages**: Centered, gray styling for automated notifications
- **Job Updates**: Work progress and status updates
- **Weather Alerts**: Storm and weather-related safety information

### Electrical Worker Specific Features
- **Role Badges**: Visual indicators for crew roles (Foreman, Journeyman, Apprentice, etc.)
- **Safety Prioritization**: Emergency and safety messages have visual prominence
- **Attachment Support**: Electrical schematics, safety docs, work orders, inspection reports
- **Professional Styling**: IBEW-appropriate color scheme and typography

### Interactive Features
- **Swipe to Reply**: Left swipe on received messages to quickly reply
- **Long Press Actions**: Access message options (copy, reply, react, acknowledge)
- **Tap Attachments**: Preview images, download documents, open locations
- **Emergency Acknowledgment**: Special handling for emergency message responses

### Visual Design
- **Electrical Theme**: Navy and copper color scheme throughout
- **Bubble Styling**: 
  - Sent messages: Copper gradient, right-aligned
  - Received messages: White/gray gradient, left-aligned
  - Emergency: Red border and background tint
  - Safety: Orange border and warning icons
- **Animations**: Smooth bubble appearance, tap feedback, swipe gestures
- **Accessibility**: Screen reader support, high contrast, proper focus management

## Usage

### Basic Usage
```dart
MessageBubble(
  message: crewCommunication,
  isCurrentUser: false,
  showSenderName: true,
  showTimestamp: true,
)
```

### With Callbacks
```dart
MessageBubble(
  message: crewCommunication,
  isCurrentUser: false,
  onTap: () => print('Message tapped'),
  onLongPress: () => showMessageOptions(),
  onReply: () => setupReplyContext(),
  onReaction: (reaction) => addReactionToMessage(reaction),
)
```

### System Messages
```dart
MessageBubble(
  message: systemMessage,
  isCurrentUser: false,
  isSystemMessage: true,
)
```

## Message Properties

### Required
- `message`: CrewCommunication object containing message data
- `isCurrentUser`: Boolean indicating if message was sent by current user

### Optional
- `onTap`: Callback for message tap
- `onLongPress`: Callback for long press (shows action menu)
- `onReaction`: Callback for adding reactions
- `onReply`: Callback for reply action
- `showAvatar`: Show/hide user avatar (default: true)
- `showTimestamp`: Show/hide timestamp (default: true)
- `showSenderName`: Show/hide sender name (default: false)
- `currentUserId`: Current user ID for read receipt logic
- `isSystemMessage`: Override for system message styling
- `enableSwipeToReply`: Enable/disable swipe gesture (default: true)

## Attachment Types

The widget supports various attachment types relevant to electrical work:

### Documents
- **PDF Files**: Work orders, permits, manuals
- **Safety Documents**: Safety checklists, procedures
- **Job Specifications**: Project requirements, specifications

### Electrical Specific
- **Schematics**: Circuit diagrams, wiring plans
- **Code Documentation**: NEC references, local code requirements
- **Inspection Reports**: Quality control, safety inspections

### Media
- **Images**: Job site photos, equipment pictures
- **Location**: GPS coordinates, job site locations

## Styling

### Colors
- **Primary Navy**: `#1A202C` - Main brand color
- **Accent Copper**: `#B45309` - Electrical industry theme
- **Emergency Red**: `#E53E3E` - Emergency messages
- **Warning Orange**: `#ED8936` - Safety alerts
- **Success Green**: `#38A169` - Read receipts, confirmations

### Typography
- **Body Text**: Inter font family, readable sizes
- **Timestamps**: Small, secondary color
- **Role Badges**: Bold, uppercase, colored borders

### Animations
- **Scale Animation**: Tap feedback (0.95x scale)
- **Slide Animation**: Swipe-to-reply indicator
- **Entrance**: Smooth fade-in for new messages

## Accessibility

- **Screen Reader Support**: Proper semantic labels and hints
- **High Contrast**: Sufficient color contrast ratios
- **Touch Targets**: Minimum 44x44 point touch areas
- **Focus Management**: Proper focus order and indicators

## Emergency Features

### Emergency Messages
- Red border and background tint
- "EMERGENCY" header with warning icon
- Special acknowledgment action in long-press menu
- High visual priority and contrast

### Safety Alerts
- Orange border and accent colors
- "SAFETY ALERT" header with warning icon
- Can be pinned for visibility
- Warning symbol prominence

## Integration

### With Provider
```dart
Consumer<CrewCommunicationProvider>(
  builder: (context, provider, child) {
    return ListView.builder(
      itemCount: provider.messages.length,
      itemBuilder: (context, index) {
        final message = provider.messages[index];
        return MessageBubble(
          message: message,
          isCurrentUser: message.senderId == currentUserId,
          onReply: () => provider.replyToMessage(message),
        );
      },
    );
  },
)
```

### In Chat Screen
```dart
class CrewChatScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              itemBuilder: (context, index) => MessageBubble(
                message: messages[index],
                isCurrentUser: messages[index].senderId == currentUserId,
                showSenderName: true,
                onReply: () => _handleReply(messages[index]),
              ),
            ),
          ),
          MessageInputField(),
        ],
      ),
    );
  }
}
```

## Testing

Comprehensive test suite includes:
- Widget rendering tests
- Interaction tests (tap, long press, swipe)
- Message type styling tests
- Attachment display tests
- Accessibility tests

Run tests with:
```bash
flutter test test/features/crews/widgets/message_bubble_test.dart
```

## Performance

- **Efficient Rendering**: Optimized for large message lists
- **Image Caching**: Network images cached automatically
- **Gesture Optimization**: Minimal rebuild on interactions
- **Memory Management**: Proper disposal of animation controllers
