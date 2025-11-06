# Journeyman Jobs - Crew Chat Feature Knowledge Base

**Date:** 2025-01-18
**Purpose:** Comprehensive reference guide for implementing chat functionality in the crews feature
**Based on:** Analysis of Chatty (Clean Architecture) and Stream Chat V1 sample applications

---

## 📚 Table of Contents

1. [Executive Summary](#executive-summary)
2. [Architecture Comparison](#architecture-comparison)
3. [Key Features Analysis](#key-features-analysis)
4. [Implementation Patterns](#implementation-patterns)
5. [Firebase Integration Guide](#firebase-integration-guide)
6. [State Management Approaches](#state-management-approaches)
7. [Navigation Architecture](#navigation-architecture)
8. [Electrical Worker Specific Features](#electrical-worker-specific-features)
9. [Implementation Roadmap](#implementation-roadmap)
10. [Code Examples & Recipes](#code-examples--recipes)
11. [Best Practices](#best-practices)
12. [Common Pitfalls](#common-pitfalls)

---

## 🎯 Executive Summary

This knowledge base synthesizes the architectural patterns, features, and implementation approaches from two sample Flutter chat applications to guide the development of crew-based chat functionality for electrical workers in the Journeyman Jobs app.

### Key Takeaways

- **Stream Chat V1** provides the most comprehensive feature set and modern implementation patterns
- **Chatty App** demonstrates Clean Architecture principles that ensure maintainability and testability
- Both apps provide valuable patterns that can be combined for optimal results
- Electrical workers have specific communication needs that require specialized features

### Recommended Approach

1. **Adopt Clean Architecture** from Chatty App for maintainability
2. **Use Stream Chat V1** for core chat functionality and advanced features
3. **Implement go_router** for robust navigation
4. **Include Firebase Messaging** for push notifications
5. **Apply electrical-specific customizations** for worker needs

---

## 🏗️ Architecture Comparison

### Chatty App Architecture

```dart
Domain Layer (Business Logic)
├── Models (AuthUser, ChatUser)
├── Use Cases (LoginUseCase, CreateGroupUseCase)
└── Exceptions (AuthException)

Data Layer (Repositories)
├── Interfaces (AuthRepository, StreamApiRepository)
├── Local Implementations
└── Production Implementations

UI Layer (Presentation)
├── Cubits (State Management)
├── Screens
└── Reusable Components
```

### Stream Chat V1 Architecture

```dart
Feature-Based Structure
├── Pages (Screens)
├── Widgets (Reusable Components)
├── Routes (Navigation)
├── State (State Management)
└── Utils (Helper Functions)

External Services
├── Stream Chat SDK
├── Firebase Services
├── Local Notifications
└── Sentry (Error Tracking)
```

### Hybrid Recommended Architecture for Crews

```dart
lib/features/crews/
├── domain/           # Business logic (from Chatty)
│   ├── models/       # Crew, Message, User models
│   ├── usecases/     # Business operations
│   └── exceptions/   # Custom exceptions
├── data/            # Data sources (from Chatty)
│   ├── repositories/ # Repository interfaces
│   ├── services/     # Service implementations
│   └── dto/         # Data transfer objects
├── presentation/    # UI layer (hybrid)
│   ├── screens/     # Chat screens
│   ├── widgets/     # Reusable components
│   └── providers/   # State management
└── shared/          # Shared utilities
    ├── navigation/  # Routing (from Stream Chat V1)
    ├── theme/      # Theming
    └── utils/      # Helper functions
```

---

## ⭐ Key Features Analysis

### Essential Chat Features (Both Apps)

| Feature | Chatty App | Stream Chat V1 | Priority for Crews |
|---------|------------|----------------|-------------------|
| Real-time messaging | ✅ | ✅ | **Critical** |
| Group chats | ✅ | ✅ | **Critical** |
| File attachments | ✅ | ✅ | **Critical** |
| Authentication | ✅ | ✅ | **Critical** |
| Offline support | ❌ | ✅ | **High** |
| Push notifications | ❌ | ✅ | **High** |
| Message reactions | ❌ | ✅ | **Medium** |
| Threads | ❌ | ✅ | **Medium** |
| Message search | ❌ | ✅ | **Medium** |
| Typing indicators | ✅ | ✅ | **Low** |
| Read receipts | ✅ | ✅ | **Low |

### Advanced Features Worth Implementing

1. **Location Sharing** - Critical for job site coordination
2. **Voice Messages** - Useful for hands-free communication
3. **Job Status Updates** - Integration with job management

---

## 🔧 Implementation Patterns

### 1. Repository Pattern (from Chatty)

```dart
// Abstract repository interface
abstract class CrewChatRepository {
  Future<void> sendMessage(String crewId, String message);
  Future<List<CrewMessage>> getMessages(String crewId);
  Stream<List<CrewMessage>> messageStream(String crewId);
}

// Production implementation
class CrewChatRepositoryImpl implements CrewChatRepository {
  final StreamChatClient _client;

  CrewChatRepositoryImpl(this._client);

  @override
  Future<void> sendMessage(String crewId, String message) async {
    final channel = _client.channel('messaging', id: crewId);
    await channel.sendMessage(MessageRequest(text: message));
  }

  // ... other implementations
}
```

### 2. Use Case Pattern (from Chatty)

```dart
// Business logic encapsulation
class CreateCrewChannelUseCase {
  final CrewChatRepository _repository;
  final CrewRepository _crewRepo;

  CreateCrewChannelUseCase(this._repository, this._crewRepo);

  Future<String> execute(String crewName, List<String> memberIds) async {
    // Business rules validation
    if (memberIds.length < 2) {
      throw CrewException('Crew must have at least 2 members');
    }

    // Create channel
    final channelId = await _repository.createChannel(
      name: crewName,
      members: memberIds,
      extraData: {
        'type': 'crew',
        'created_at': DateTime.now().toIso8601String(),
      },
    );

    // Update crew record
    await _crewRepo.updateChatChannel(crewName, channelId);

    return channelId;
  }
}
```

### 3. State Management with Provider (from Stream Chat V1)

```dart
// Crew chat state notifier
class CrewChatNotifier extends ChangeNotifier {
  final CreateCrewChannelUseCase _createChannelUseCase;
  final JoinCrewUseCase _joinCrewUseCase;

  CrewChatState _state = CrewChatState.initial();
  CrewChatState get state => _state;

  CrewChatNotifier(this._createChannelUseCase, this._joinCrewUseCase);

  Future<void> createCrewChannel(String name, List<String> members) async {
    _state = _state.copyWith(isLoading: true);
    notifyListeners();

    try {
      final channelId = await _createChannelUseCase.execute(name, members);
      _state = _state.copyWith(
        isLoading: false,
        channelId: channelId,
        error: null,
      );
    } catch (e) {
      _state = _state.copyWith(
        isLoading: false,
        error: e.toString(),
      );
    }

    notifyListeners();
  }
}
```

### 4. Navigation with go_router (from Stream Chat V1)

```dart
// Route definitions for crew chat
final crewChatRoutes = [
  GoRoute(
    path: '/crews/:crewId/chat',
    builder: (context, state) => CrewChatScreen(
      crewId: state.pathParameters['crewId']!,
    ),
    routes: [
      GoRoute(
        path: '/info',
        builder: (context, state) => CrewChatInfoScreen(
          crewId: state.pathParameters['crewId']!,
        ),
      ),
      GoRoute(
        path: '/media',
        builder: (context, state) => CrewMediaScreen(
          crewId: state.pathParameters['crewId']!,
        ),
      ),
    ],
  ),
];
```

---

## 🔥 Firebase Integration Guide

### 1. Authentication Setup

```dart
// Firebase Auth service
class FirebaseAuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  Future<UserCredential> signInWithGoogle() async {
    final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
    final GoogleSignInAuthentication googleAuth =
        await googleUser!.authentication;

    final credential = GoogleAuthProvider.credential(
      accessToken: googleAuth.accessToken,
      idToken: googleAuth.idToken,
    );

    return await _auth.signInWithCredential(credential);
  }

  Future<void> signOut() async {
    await _auth.signOut();
    await _googleSignIn.signOut();
  }
}
```

### 2. Firebase Messaging for Push Notifications

```dart
// Notification service
class CrewNotificationService {
  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  Future<void> initialize() async {
    // Request permission
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    // Get token
    final token = await _messaging.getToken();

    // Subscribe to crew topics
    await subscribeToCrewTopics();

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage(_handleBackgroundMessage);

    // Handle foreground messages
    FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  Future<void> subscribeToCrewTopics() async {
    final userCrews = await getUserCrews();
    for (final crew in userCrews) {
      await _messaging.subscribeToTopic('crew_${crew.id}');
    }
  }
}
```

### 3. Secure Token Storage

```dart
// Secure storage for Stream Chat tokens
class TokenStorageService {
  final FlutterSecureStorage _storage = const FlutterSecureStorage();

  static const String _apiKeyKey = 'stream_api_key';
  static const String _userIdKey = 'stream_user_id';
  static const String _tokenKey = 'stream_token';

  Future<void> saveTokens({
    required String apiKey,
    required String userId,
    required String token,
  }) async {
    await _storage.write(key: _apiKeyKey, value: apiKey);
    await _storage.write(key: _userIdKey, value: userId);
    await _storage.write(key: _tokenKey, value: token);
  }

  Future<Map<String, String?>> getTokens() async {
    return {
      'apiKey': await _storage.read(key: _apiKeyKey),
      'userId': await _storage.read(key: _userIdKey),
      'token': await _storage.read(key: _tokenKey),
    };
  }
}
```

---

## 📱 State Management Approaches

### Option 1: Provider Pattern (Recommended)

- Used by Stream Chat V1
- Simpler to implement
- Good for medium-sized apps
- Easy to understand and debug

### Option 2: BLoC/Cubit Pattern

- Used by Chatty App
- More robust for complex state
- Better testability
- Steeper learning curve

### Recommended Hybrid Approach

```dart
// Use Provider for global state
final crewChatProvider = ChangeNotifierProvider((ref) => CrewChatNotifier());

// Use Cubit for local component state
class MessageInputCubit extends Cubit<MessageInputState> {
  MessageInputCubit() : super(MessageInputState.initial());

  void updateText(String text) {
    emit(state.copyWith(text: text));
  }

  void sendTypingEvent(bool isTyping) {
    // Handle typing indicators
  }
}
```

---

## 🧭 Navigation Architecture

### Type-Safe Routing with go_router

```dart
// Route configuration
final appRouter = GoRouter(
  routes: [
    // Crew chat routes
    GoRoute(
      path: '/crews',
      builder: (context, state) => const CrewsScreen(),
      routes: [
        GoRoute(
          path: '/:crewId/chat',
          builder: (context, state) => CrewChatScreen(
            crewId: state.pathParameters['crewId']!,
          ),
        ),
        GoRoute(
          path: '/create',
          builder: (context, state) => const CreateCrewScreen(),
        ),
      ],
    ),
  ],
  redirect: (context, state) {
    // Authentication guard
    final isAuthenticated = checkAuthStatus();
    if (!isAuthenticated && !state.location.startsWith('/login')) {
      return '/login';
    }
    return null;
  },
);
```

### Navigation Helper Utilities

```dart
// Navigation utilities (from Chatty)
class CrewNavigationHelper {
  static Future<void> navigateToChat(
    BuildContext context,
    String crewId, {
    String? messageId,
  }) async {
    final uri = Uri(
      path: '/crews/$crewId/chat',
      queryParameters: messageId != null ? {'message': messageId} : null,
    );

    context.go(uri.toString());
  }

  static Future<void> navigateToCrewInfo(
    BuildContext context,
    String crewId,
  ) async {
    context.go('/crews/$crewId/info');
  }
}
```

---

## 👷 Electrical Worker Specific Features

### 1. Crew Organization Patterns

```dart
// Crew-specific channel configuration
class CrewChannelConfig {
  static Channel createCrewChannel({
    required String crewId,
    required String localUnion,
    required String crewType,
  }) {
    return Channel(
      type: 'messaging',
      id: crewId,
      extraData: {
        'name': 'IBEW Local $localUnion - $crewType Crew',
        'crew_type': crewType, // lineman, wireman, operator, etc.
        'local_union': localUnion,
        'created_for': 'electrical_workers',
        'features': [
          'job_sharing',
          'location_sharing',
          'safety_alerts',
        ],
      },
    );
  }
}
```

### 2. Job-Specific Features

```dart
// Job sharing through chat
class JobSharingService {
  Future<void> shareJobInChat({
    required String crewId,
    required JobModel job,
    required String message,
  }) async {
    final attachment = Attachment(
      type: 'job_posting',
      extraData: {
        'job_id': job.id,
        'company': job.company,
        'location': job.location,
        'wage': job.wage,
        'classification': job.classification,
      },
    );

    await chatClient.sendMessage(
      channelId,
      MessageRequest(
        text: message,
        attachments: [attachment],
      ),
    );
  }
}
```

### 3. Safety Integration

```dart
// Safety check-in messages
class SafetyCheckInService {
  Future<void> sendSafetyAlert({
    required String crewId,
    required String alertType, // weather, injury, etc.
    required String location,
    String? details,
  }) async {
    final message = MessageRequest(
      text: '⚠️ SAFETY ALERT: ${alertType.toUpperCase()}',
      attachments: [
        Attachment(
          type: 'safety_alert',
          extraData: {
            'alert_type': alertType,
            'location': location,
            'details': details,
            'timestamp': DateTime.now().toIso8601String(),
            'requires_acknowledgment': true,
          },
        ),
      ],
    );

    await chatClient.sendMessage(crewId, message);
  }
}
```

### 4. Location Sharing

```dart
// Job site location sharing
class LocationSharingService {
  Future<void> shareJobLocation({
    required String crewId,
    required double latitude,
    required double longitude,
    required String address,
  }) async {
    final locationAttachment = Attachment(
      type: 'location',
      extraData: {
        'lat': latitude,
        'lng': longitude,
        'address': address,
        'type': 'job_site',
      },
    );

    await chatClient.sendMessage(
      crewId,
      MessageRequest(
        text: '📍 Job Site Location',
        attachments: [locationAttachment],
      ),
    );
  }
}
```

---

## 🛣️ Implementation Roadmap

### Phase 1: Foundation (Week 1-2)

1. **Set up Clean Architecture structure**
   - Create domain, data, and presentation layers
   - Define repository interfaces
   - Set up dependency injection

2. **Integrate Stream Chat SDK**
   - Add dependencies
   - Initialize client
   - Set up authentication

3. **Basic UI Implementation**
   - Channel list screen
   - Chat screen scaffolding
   - Message input component

### Phase 2: Core Features (Week 3-4)

1. **Messaging Implementation**
   - Send/receive messages
   - Real-time updates
   - Message history

2. **Crew Management**
   - Create crew channels
   - Add/remove members
   - Crew permissions

3. **File Sharing**
   - Image uploads
   - Document sharing
   - File preview

### Phase 3: Advanced Features (Week 5-6)

1. **Push Notifications**
   - Firebase integration
   - Local notifications
   - Background handling

2. **Offline Support**
   - Persistence client
   - Offline messaging
   - Sync on reconnect

3. **Electrical-Specific Features**
   - Job sharing integration
   - Safety alerts
   - Location sharing

### Phase 4: Polish & Optimization (Week 7-8)

1. **UI/UX Refinements**
   - Theming consistency
   - Responsive design
   - Accessibility

2. **Performance Optimization**
   - Lazy loading
   - Memory management
   - Battery optimization

3. **Testing & QA**
   - Unit tests
   - Integration tests
   - User acceptance testing

---

## 💻 Code Examples & Recipes

### 1. Custom Message Types

```dart
// Job posting message
class JobPostingMessage extends StatelessWidget {
  final Map<String, dynamic> jobData;

  const JobPostingMessage({Key? key, required this.jobData}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.work, color: Colors.blue),
                const SizedBox(width: 8),
                Text(
                  'Job Posting',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ],
            ),
            const SizedBox(height: 12),
            Text(jobData['company'] ?? 'Unknown Company'),
            Text(jobData['location'] ?? 'Unknown Location'),
            if (jobData['wage'] != null)
              Text('Wage: \$${jobData['wage']}/hr'),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => viewJobDetails(jobData['id']),
              child: const Text('View Details'),
            ),
          ],
        ),
      ),
    );
  }
}
```

### 2. Custom Message Input

```dart
// Crew-specific message input
class CrewMessageInput extends StatefulWidget {
  final String crewId;
  final void Function(String)? onSendMessage;

  const CrewMessageInput({
    Key? key,
    required this.crewId,
    this.onSendMessage,
  }) : super(key: key);

  @override
  State<CrewMessageInput> createState() => _CrewMessageInputState();
}

class _CrewMessageInputState extends State<CrewMessageInput> {
  final TextEditingController _controller = TextEditingController();
  bool _isTyping = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 4,
            offset: const Offset(0, -2),
          ),
        ],
      ),
      child: SafeArea(
        child: Row(
          children: [
            // Attachments button
            IconButton(
              icon: const Icon(Icons.attach_file),
              onPressed: _showAttachmentOptions,
            ),

            // Location button
            IconButton(
              icon: const Icon(Icons.location_on),
              onPressed: _shareLocation,
            ),

            // Job sharing button
            IconButton(
              icon: const Icon(Icons.work_outline),
              onPressed: _shareJob,
            ),

            // Text input
            Expanded(
              child: TextField(
                controller: _controller,
                decoration: InputDecoration(
                  hintText: 'Type a message...',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(24),
                  ),
                ),
                onChanged: _handleTyping,
              ),
            ),

            // Send button
            IconButton(
              icon: const Icon(Icons.send),
              onPressed: _sendMessage,
            ),
          ],
        ),
      ),
    );
  }

  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      widget.onSendMessage?.call(_controller.text);
      _controller.clear();
    }
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentOptionsSheet(
        onImageSelected: _sendImage,
        onDocumentSelected: _sendDocument,
      ),
    );
  }

  void _shareLocation() async {
    final position = await getCurrentLocation();
    // Implement location sharing
  }

  void _shareJob() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => JobSharingScreen(
          crewId: widget.crewId,
        ),
      ),
    );
  }
}
```

### 3. Custom Message Bubble

```dart
// Electrical-themed message bubble
class ElectricalMessageBubble extends StatelessWidget {
  final Message message;
  final bool isOwnMessage;

  const ElectricalMessageBubble({
    Key? key,
    required this.message,
    required this.isOwnMessage,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        mainAxisAlignment: isOwnMessage
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        children: [
          if (!isOwnMessage) ...[
            AvatarImage(
              imageUrl: message.user?.image,
              initials: message.user?.name?.substring(0, 1) ?? '?',
              size: 32,
            ),
            const SizedBox(width: 8),
          ],
          Flexible(
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                color: isOwnMessage
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.surface,
                borderRadius: BorderRadius.circular(20),
                border: isOwnMessage
                    ? null
                    : Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (!isOwnMessage)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        message.user?.name ?? 'Unknown',
                        style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),

                  // Message content
                  _buildMessageContent(),

                  // Timestamp
                  Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      formatTimestamp(message.createdAt),
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: isOwnMessage
                            ? Colors.white70
                            : Colors.grey[600],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    // Handle different message types
    if (message.attachments?.isNotEmpty == true) {
      final attachment = message.attachments!.first;
      switch (attachment.type) {
        case 'image':
          return Image.network(
            attachment.imageUrl!,
            height: 200,
            width: double.infinity,
            fit: BoxFit.cover,
          );
        case 'job_posting':
          return JobPostingMessage(
            jobData: attachment.extraData ?? {},
          );
        case 'location':
          return LocationMessage(
            locationData: attachment.extraData ?? {},
          );
        case 'safety_alert':
          return SafetyAlertMessage(
            alertData: attachment.extraData ?? {},
          );
        default:
          return Text(message.text ?? '');
      }
    }

    return Text(
      message.text ?? '',
      style: TextStyle(
        color: isOwnMessage
            ? Colors.white
            : Theme.of(context).colorScheme.onSurface,
      ),
    );
  }
}
```

---

## ✅ Best Practices

### 1. Architecture Best Practices

- **Separate concerns** with Clean Architecture
- **Dependency injection** for testability
- **Repository pattern** for data access
- **Use cases** for business logic

### 2. Performance Best Practices

- **Lazy loading** for message lists
- **Image caching** for attachments
- **Controller disposal** to prevent memory leaks
- **Pagination** for large chat histories

### 3. Security Best Practices

- **Secure token storage** with FlutterSecureStorage
- **Input validation** for all user inputs
- **Permission checks** before accessing features
- **HTTPS** for all API calls

### 4. UI/UX Best Practices

- **Consistent theming** with electrical branding
- **Offline indicators** for connection status
- **Loading states** for async operations
- **Error handling** with user-friendly messages

### 5. Testing Best Practices

- **Unit tests** for business logic
- **Widget tests** for UI components
- **Integration tests** for user flows
- **Mock implementations** for external dependencies

---

## ⚠️ Common Pitfalls

### 1. Architecture Pitfalls

- **Mixing business logic with UI** - Keep layers separate
- **Tight coupling** - Use interfaces and dependency injection
- **Global state abuse** - Keep state local when possible

### 2. Performance Pitfalls

- **Not disposing controllers** - Always dispose in dispose()
- **Loading too many messages** - Implement pagination
- **Blocking main thread** - Use isolates for heavy operations

### 3. Firebase Pitfalls

- **Not handling auth state changes** - Listen to auth stream
- **Ignoring notification permissions** - Request permissions early
- **Missing background configuration** - Configure background handlers

### 4. Stream Chat Pitfalls

- **Not handling connection state** - Show connection status
- **Ignoring rate limits** - Implement throttling
- **Missing offline setup** - Configure persistence client

---

## 📖 Reference Files

### Key Files from Chatty App

- `lib/dependencies.dart` - Dependency injection setup
- `lib/data/auth_repository.dart` - Repository pattern example
- `lib/domain/usecases/login_usecase.dart` - Use case pattern
- `lib/ui/app_theme_cubit.dart` - State management example

### Key Files from Stream Chat V1

- `lib/app.dart` - App configuration and setup
- `lib/routes/app_routes.dart` - Navigation structure
- `lib/utils/local_notification_observer.dart` - Notification handling
- `lib/pages/channel_page.dart` - Chat screen implementation

---

## 🚀 Next Steps

1. **Review this knowledge base** with your development team
2. **Set up the project structure** following the hybrid architecture
3. **Integrate dependencies** (Stream Chat, Firebase, go_router)
4. **Implement Phase 1** of the roadmap
5. **Schedule regular reviews** to ensure alignment with electrical worker needs

---

## 📞 Support & Resources

- **Stream Chat Documentation**: <https://getstream.io/chat/flutter/tutorial/>
- **Firebase Documentation**: <https://firebase.google.com/docs>
- **go_router Documentation**: <https://pub.dev/packages/go_router>
- **Clean Architecture**: <https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html>

---

**Last Updated:** 2025-01-18
**Version:** 1.0
**Next Review:** After Phase 1 completion
