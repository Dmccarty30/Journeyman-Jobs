# Journeyman Jobs Messaging System Implementation Plan

## 📋 Executive Summary

This document provides a comprehensive, step-by-step implementation plan for building a robust messaging system for Journeyman Jobs using Stream Chat SDK, Clean Architecture, and Firebase integration. The system will support 1-on-1 chatting, crew communications, feed broadcasting, and electrical worker-specific features.

## 🏗️ Architecture Overview

### Core Technologies

- **Chat Engine**: Stream Chat Flutter SDK v6.0.0+
- **State Management**: Provider + Cubit hybrid
- **Navigation**: go_router for type-safe routing
- **Backend**: Firebase (Auth, Firestore, Storage, Messaging)
- **Architecture**: Clean Architecture (Domain/Data/Presentation layers)
- **Offline Support**: Stream Chat Persistence Client

### Design Principles

- **Mobile-first**: Optimized for field workers on budget Android devices
- **Electrical-themed**: IBEW branding and electrical worker UX
- **Offline-first**: Critical for storm work and remote job sites
- **Performance**: 60fps scrolling, <15% battery/hr active usage
- **Security**: End-to-end encryption, secure token storage

## 📦 Dependencies Installation

### Add to pubspec.yaml

```yaml
dependencies:
  # Core Chat
  stream_chat_flutter: ^6.0.0
  stream_chat_persistence: ^5.0.0
  stream_chat_localizations: ^6.0.0

  # State Management & Navigation
  provider: ^6.0.0
  flutter_bloc: ^8.1.0
  go_router: ^12.0.0

  # Firebase Integration
  firebase_core: ^2.24.0
  firebase_auth: ^4.16.0
  firebase_messaging: ^14.7.0
  cloud_firestore: ^4.14.0
  firebase_storage: ^11.6.0

  # Security & Storage
  flutter_secure_storage: ^8.0.0
  crypto: ^3.0.3

  # UI & Media
  image_picker: ^1.0.0
  file_picker: ^6.0.0
  flutter_svg: ^2.0.0
  cached_network_image: ^3.3.0

  # Permissions
  permission_handler: ^11.0.0

  # Location & Weather
  geolocator: ^10.1.0
  geocoding: ^2.1.0

  # Utilities
  uuid: ^4.0.0
  intl: ^0.19.0
  dio: ^5.3.0
  path_provider: ^2.1.0

dev_dependencies:
  flutter_test:
    sdk: flutter
  mockito: ^5.4.0
  build_runner: ^2.4.0
  flutter_lints: ^3.0.0
```

## 🗂️ Complete Folder Structure

```bash
lib/features/crews/
├── domain/                    # Business Logic Layer
│   ├── models/               # Core entities
│   │   ├── crew_channel.dart
│   │   ├── crew_message.dart
│   │   ├── crew_user.dart
│   │   ├── enums.dart
│   │   ├── job_attachment.dart
│   │   ├── safety_alert.dart
│   │   └── location_share.dart
│   ├── usecases/             # Business operations
│   │   ├── messaging/
│   │   │   ├── send_message_usecase.dart
│   │   │   ├── create_channel_usecase.dart
│   │   │   ├── manage_members_usecase.dart
│   │   │   └── mark_messages_read_usecase.dart
│   │   ├── feed/
│   │   │   ├── publish_to_feed_usecase.dart
│   │   │   ├── moderate_feed_usecase.dart
│   │   │   └── get_feed_posts_usecase.dart
│   │   ├── notifications/
│   │   │   ├── send_notification_usecase.dart
│   │   │   ├── device_token_usecase.dart
│   │   │   └── handle_safety_alert_usecase.dart
│   │   └── jobs/
│   │       ├── share_job_usecase.dart
│   │       ├── create_job_attachment_usecase.dart
│   │       └── apply_for_job_usecase.dart
│   ├── repositories/         # Abstract interfaces
│   │   ├── chat_repository.dart
│   │   ├── feed_repository.dart
│   │   ├── notification_repository.dart
│   │   ├── crew_repository.dart
│   │   └── job_repository.dart
│   └── exceptions/           # Custom exceptions
│       ├── crew_exceptions.dart
│       ├── chat_exceptions.dart
│       ├── feed_exceptions.dart
│       └── notification_exceptions.dart
├── data/                     # Data Layer
│   ├── repositories/         # Repository implementations
│   │   ├── chat_repository_impl.dart
│   │   ├── feed_repository_impl.dart
│   │   ├── notification_repository_impl.dart
│   │   ├── crew_repository_impl.dart
│   │   └── job_repository_impl.dart
│   ├── services/             # External service integrations
│   │   ├── stream_chat_service.dart
│   │   ├── firebase_messaging_service.dart
│   │   ├── storage_service.dart
│   │   ├── location_service.dart
│   │   └── notification_service.dart
│   ├── datasources/          # Data sources
│   │   ├── local/
│   │   │   ├── secure_storage_datasource.dart
│   │   │   └── local_cache_datasource.dart
│   │   └── remote/
│   │       ├── stream_chat_datasource.dart
│   │       ├── firebase_datasource.dart
│   │       └── crew_api_datasource.dart
│   └── dto/                  # Data transfer objects
│       ├── message_dto.dart
│       ├── channel_dto.dart
│       ├── user_dto.dart
│       ├── job_attachment_dto.dart
│       └── safety_alert_dto.dart
├── presentation/             # UI Layer
│   ├── screens/              # Main screens
│   │   ├── messaging/
│   │   │   ├── chat_list_screen.dart
│   │   │   ├── chat_screen.dart
│   │   │   ├── direct_message_screen.dart
│   │   │   └── new_chat_screen.dart
│   │   ├── crew/
│   │   │   ├── crew_chat_screen.dart
│   │   │   ├── crew_management_screen.dart
│   │   │   ├── create_crew_screen.dart
│   │   │   ├── crew_directory_screen.dart
│   │   │   └── crew_settings_screen.dart
│   │   ├── feed/
│   │   │   ├── feed_screen.dart
│   │   │   ├── feed_post_screen.dart
│   │   │   ├── feed_mod_screen.dart
│   │   │   └── create_feed_post_screen.dart
│   │   └── notifications/
│   │       ├── notifications_screen.dart
│   │       └── notification_settings_screen.dart
│   ├── widgets/              # Reusable components
│   │   ├── message/
│   │   │   ├── message_bubble.dart
│   │   │   ├── message_input.dart
│   │   │   ├── attachment_preview.dart
│   │   │   ├── reaction_bar.dart
│   │   │   ├── message_status_indicator.dart
│   │   │   └── typing_indicator.dart
│   │   ├── channel/
│   │   │   ├── channel_tile.dart
│   │   │   ├── channel_header.dart
│   │   │   ├── channel_list_view.dart
│   │   │   ├── channel_settings.dart
│   │   │   └── create_channel_dialog.dart
│   │   ├── crew/
│   │   │   ├── crew_card.dart
│   │   │   ├── crew_member_tile.dart
│   │   │   ├── crew_avatar.dart
│   │   │   └── crew_status_indicator.dart
│   │   ├── feed/
│   │   │   ├── feed_post_card.dart
│   │   │   ├── feed_filter_chips.dart
│   │   │   └── feed_moderation_tools.dart
│   │   ├── attachments/
│   │   │   ├── image_attachment.dart
│   │   │   ├── document_attachment.dart
│   │   │   ├── job_attachment.dart
│   │   │   └── safety_alert_attachment.dart
│   │   ├── common/
│   │   │   ├── online_indicator.dart
│   │   │   ├── loading_indicator.dart
│   │   │   ├── error_widget.dart
│   │   │   ├── empty_state_widget.dart
│   │   │   └── search_bar.dart
│   │   └── electrical/
│   │       ├── electrical_reactions.dart
│   │       ├── safety_alert_banner.dart
│   │       ├── job_sharing_card.dart
│   │       └── location_share_widget.dart
│   ├── providers/            # State management
│   │   ├── chat_provider.dart
│   │   ├── crew_provider.dart
│   │   ├── feed_provider.dart
│   │   ├── notification_provider.dart
│   │   ├── auth_provider.dart
│   │   └── settings_provider.dart
│   ├── cubits/               # Cubit state management
│   │   ├── chat_cubit.dart
│   │   ├── message_input_cubit.dart
│   │   ├── channel_list_cubit.dart
│   │   ├── crew_cubit.dart
│   │   ├── feed_cubit.dart
│   │   └── notification_cubit.dart
│   └── shared/               # Shared UI utilities
│       ├── navigation/
│       │   ├── chat_routes.dart
│       │   └── navigation_service.dart
│       ├── theme/
│       │   ├── chat_theme.dart
│       │   └── electrical_colors.dart
│       └── utils/
│           ├── date_formatter.dart
│           ├── message_helper.dart
│           └── permission_handler.dart
└── _external/               # External integrations
    ├── stream_chat/
    │   ├── stream_chat_client.dart
    │   ├── stream_chat_config.dart
    │   └── stream_chat_theme.dart
    ├── firebase/
    │   ├── firebase_config.dart
    │   ├── firebase_messaging_handler.dart
    │   └── firebase_security_rules.txt
    └── constants/
        ├── chat_constants.dart
        ├── notification_constants.dart
        └── api_endpoints.dart
```

## 📋 Phase 1: Foundation Implementation (Week 1-2)

### 1.1 Setup Infrastructure (2 days)

#### Task 1.1.1: Initialize Stream Chat Configuration

**File**: `lib/features/crews/_external/stream_chat/stream_chat_config.dart`

```dart
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class StreamChatConfig {
  static const String _apiKeyEnv = String.fromEnvironment('STREAM_CHAT_API_KEY');
  static const String _appIdEnv = String.fromEnvironment('STREAM_CHAT_APP_ID');

  static String get apiKey => _apiKeyEnv.isNotEmpty ? _apiKeyEnv : 'your_dev_api_key';
  static String get appId => _appIdEnv.isNotEmpty ? _appIdEnv : 'your_dev_app_id';

  static const logLevel = Level.INFO;
  static const _storage = FlutterSecureStorage();

  static ChatPersistenceClient createPersistenceClient() {
    return ChatPersistenceClient(
      connectionMode: ConnectionMode.background,
      logLevel: logLevel,
      sizeLimit: 100 * 1024 * 1024, // 100MB
    );
  }

  static StreamChatClient createClient({
    required String userId,
    required String token,
  }) {
    return StreamChatClient(
      apiKey,
      logLevel: logLevel,
      persistentConnection: true,
    );
  }

  static Future<void> storeCredentials({
    required String userId,
    required String token,
  }) async {
    await _storage.write(key: 'stream_chat_user_id', value: userId);
    await _storage.write(key: 'stream_chat_token', value: token);
  }

  static Future<Map<String, String?>> getCredentials() async {
    final userId = await _storage.read(key: 'stream_chat_user_id');
    final token = await _storage.read(key: 'stream_chat_token');
    return {'userId': userId, 'token': token};
  }

  static Future<void> clearCredentials() async {
    await _storage.delete(key: 'stream_chat_user_id');
    await _storage.delete(key: 'stream_chat_token');
  }
}
```

**Implementation Steps**:

- [ ] Create Stream Chat configuration class
- [ ] Set up environment variables for API keys
- [ ] Configure persistence client
- [ ] Implement secure credential storage
- [ ] Add error handling for missing configuration

#### Task 1.1.2: Initialize Firebase Configuration

**File**: `lib/features/crews/_external/firebase/firebase_config.dart`

```dart
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

class FirebaseConfig {
  static Future<void> initialize() async {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    if (!kIsWeb) {
      await FirebaseMessaging.instance.setAutoInitEnabled(true);
    }
  }

  static Future<String> getFCMToken() async {
    final messaging = FirebaseMessaging.instance;

    // Request permission
    final settings = await messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      provisional: false,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      return await messaging.getToken() ?? '';
    }

    throw Exception('FCM permission denied');
  }

  static Future<void> initializeForegroundMessages() {
    return FirebaseMessaging.onMessage.listen(_handleForegroundMessage);
  }

  static void _handleForegroundMessage(RemoteMessage message) {
    // Handle foreground messages
    if (message.notification != null) {
      // Show in-app notification
    }
  }
}
```

**Implementation Steps**:

- [ ] Create Firebase configuration class
- [ ] Set up Firebase options for different environments
- [ ] Initialize Firebase Messaging
- [ ] Configure notification channels
- [ ] Add permission handling

### 1.2 Domain Layer Implementation (3 days)

#### Task 1.2.1: Create Core Models

**File**: `lib/features/crews/domain/models/crew_channel.dart`

```dart
import 'package:equatable/equatable.dart';

enum ChannelType {
  direct('direct'),
  crew('crew'),
  feed('feed'),
  announcement('announcement');

  const ChannelType(this.value);
  final String value;
}

enum CrewType {
  lineman('lineman'),
  wireman('wireman'),
  operator('operator'),
  treeTrimmer('tree_trimmer'),
  mixed('mixed');

  const CrewType(this.value);
  final String value;
}

enum ChannelPermission {
  read('read'),
  write('write'),
  admin('admin'),
  owner('owner');

  const ChannelPermission(this.value);
  final String value;
}

class CrewChannel extends Equatable {
  final String id;
  final String name;
  final String? description;
  final ChannelType type;
  final List<String> memberIds;
  final Map<String, ChannelPermission> permissions;
  final String? createdBy;
  final DateTime createdAt;
  final DateTime? lastMessageAt;
  final Map<String, dynamic>? extraData;
  final bool isArchived;
  final bool isMuted;

  const CrewChannel({
    required this.id,
    required this.name,
    this.description,
    required this.type,
    required this.memberIds,
    required this.permissions,
    this.createdBy,
    required this.createdAt,
    this.lastMessageAt,
    this.extraData,
    this.isArchived = false,
    this.isMuted = false,
  });

  CrewChannel copyWith({
    String? id,
    String? name,
    String? description,
    ChannelType? type,
    List<String>? memberIds,
    Map<String, ChannelPermission>? permissions,
    String? createdBy,
    DateTime? createdAt,
    DateTime? lastMessageAt,
    Map<String, dynamic>? extraData,
    bool? isArchived,
    bool? isMuted,
  }) {
    return CrewChannel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      type: type ?? this.type,
      memberIds: memberIds ?? this.memberIds,
      permissions: permissions ?? this.permissions,
      createdBy: createdBy ?? this.createdBy,
      createdAt: createdAt ?? this.createdAt,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      extraData: extraData ?? this.extraData,
      isArchived: isArchived ?? this.isArchived,
      isMuted: isMuted ?? this.isMuted,
    );
  }

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        type,
        memberIds,
        permissions,
        createdBy,
        createdAt,
        lastMessageAt,
        extraData,
        isArchived,
        isMuted,
      ];
}
```

**File**: `lib/features/crews/domain/models/crew_message.dart`

```dart
import 'package:equatable/equatable.dart';

enum MessageType {
  text('text'),
  image('image'),
  file('file'),
  jobPosting('job_posting'),
  safetyAlert('safety_alert'),
  locationShare('location_share'),
  system('system');

  const MessageType(this.value);
  final String value;
}

enum MessageStatus {
  sending('sending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed');

  const MessageStatus(this.value);
  final String value;
}

class CrewMessage extends Equatable {
  final String id;
  final String channelId;
  final String senderId;
  final String? senderName;
  final String? senderAvatar;
  final MessageType type;
  final String? text;
  final Map<String, dynamic>? attachments;
  final MessageStatus status;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final DateTime? deletedAt;
  final List<String> readBy;
  final Map<String, dynamic>? reactions;
  final String? replyToId;
  final String? threadId;
  final bool isEdited;

  const CrewMessage({
    required this.id,
    required this.channelId,
    required this.senderId,
    this.senderName,
    this.senderAvatar,
    required this.type,
    this.text,
    this.attachments,
    required this.status,
    required this.createdAt,
    this.updatedAt,
    this.deletedAt,
    this.readBy = const [],
    this.reactions,
    this.replyToId,
    this.threadId,
    this.isEdited = false,
  });

  CrewMessage copyWith({
    String? id,
    String? channelId,
    String? senderId,
    String? senderName,
    String? senderAvatar,
    MessageType? type,
    String? text,
    Map<String, dynamic>? attachments,
    MessageStatus? status,
    DateTime? createdAt,
    DateTime? updatedAt,
    DateTime? deletedAt,
    List<String>? readBy,
    Map<String, dynamic>? reactions,
    String? replyToId,
    String? threadId,
    bool? isEdited,
  }) {
    return CrewMessage(
      id: id ?? this.id,
      channelId: channelId ?? this.channelId,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      senderAvatar: senderAvatar ?? this.senderAvatar,
      type: type ?? this.type,
      text: text ?? this.text,
      attachments: attachments ?? this.attachments,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      readBy: readBy ?? this.readBy,
      reactions: reactions ?? this.reactions,
      replyToId: replyToId ?? this.replyToId,
      threadId: threadId ?? this.threadId,
      isEdited: isEdited ?? this.isEdited,
    );
  }

  @override
  List<Object?> get props => [
        id,
        channelId,
        senderId,
        senderName,
        senderAvatar,
        type,
        text,
        attachments,
        status,
        createdAt,
        updatedAt,
        deletedAt,
        readBy,
        reactions,
        replyToId,
        threadId,
        isEdited,
      ];
}
```

**Implementation Steps**:

- [ ] Create CrewChannel model with all properties
- [ ] Create CrewMessage model with status tracking
- [ ] Create CrewUser model with electrical worker fields
- [ ] Create enums for types and permissions
- [ ] Add Equatable for value equality
- [ ] Add copyWith methods for immutability

#### Task 1.2.2: Create Repository Interfaces

**File**: `lib/features/crews/domain/repositories/chat_repository.dart`

```dart
import 'package:dartz/dartz.dart';
import 'package:journeyman_jobs/features/crews/domain/models/crew_channel.dart';
import 'package:journeyman_jobs/features/crews/domain/models/crew_message.dart';
import 'package:journeyman_jobs/features/crews/domain/exceptions/chat_exceptions.dart';

abstract class ChatRepository {
  // Channel operations
  Future<Either<ChatException, List<CrewChannel>>> getUserChannels(String userId);
  Future<Either<ChatException, CrewChannel>> createChannel(CrewChannel channel);
  Future<Either<ChatException, void>> updateChannel(String channelId, Map<String, dynamic> updates);
  Future<Either<ChatException, void>> deleteChannel(String channelId);
  Future<Either<ChatException, void>> joinChannel(String channelId, String userId);
  Future<Either<ChatException, void>> leaveChannel(String channelId, String userId);
  Future<Either<ChatException, void>> addMember(String channelId, String userId);
  Future<Either<ChatException, void>> removeMember(String channelId, String userId);

  // Message operations
  Future<Either<ChatException, List<CrewMessage>>> getMessages(
    String channelId, {
    int limit = 20,
    String? beforeMessageId,
  });
  Future<Either<ChatException, CrewMessage>> sendMessage(
    String channelId,
    Map<String, dynamic> messageData,
  );
  Future<Either<ChatException, void>> updateMessage(
    String messageId,
    Map<String, dynamic> updates,
  );
  Future<Either<ChatException, void>> deleteMessage(String messageId);
  Future<Either<ChatException, void>> markAsRead(String channelId, List<String> messageIds);

  // Real-time operations
  Stream<List<CrewChannel>> watchChannels(String userId);
  Stream<List<CrewMessage>> watchMessages(String channelId);
  Stream<CrewChannel> watchChannel(String channelId);

  // Search operations
  Future<Either<ChatException, List<CrewChannel>>> searchChannels(String query);
  Future<Either<ChatException, List<CrewMessage>>> searchMessages(
    String channelId,
    String query,
  );
}
```

**Implementation Steps**:

- [ ] Create ChatRepository interface
- [ ] Create FeedRepository interface
- [ ] Create NotificationRepository interface
- [ ] Define all methods with Either return type
- [ ] Document all methods with DartDoc

### 1.3 Data Layer Implementation (3 days)

#### Task 1.3.1: Implement Stream Chat Service

**File**: `lib/features/crews/data/services/stream_chat_service.dart`

```dart
import 'dart:async';
import 'package:dartz/dartz.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/domain/exceptions/chat_exceptions.dart';
import 'package:journeyman_jobs/features/crews/domain/models/crew_channel.dart';
import 'package:journeyman_jobs/features/crews/domain/models/crew_message.dart';
import 'package:journeyman_jobs/features/crews/_external/stream_chat/stream_chat_config.dart';

class StreamChatService {
  late StreamChatClient _client;
  late ChatPersistenceClient _persistenceClient;
  String? _currentUserId;

  // Singleton pattern
  static final StreamChatService _instance = StreamChatService._internal();
  factory StreamChatService() => _instance;
  StreamChatService._internal();

  Future<void> initialize({
    required String userId,
    required String token,
  }) async {
    try {
      _client = StreamChatConfig.createClient(
        userId: userId,
        token: token,
      );

      _persistenceClient = StreamChatConfig.createPersistenceClient();

      await _client.connectUser(
        User(
          id: userId,
          extraData: {
            'ibew_member': true,
            'created_at': DateTime.now().toIso8601String(),
          },
        ),
        token,
      );

      _currentUserId = userId;
    } catch (e) {
      throw ChatInitializationException(e.toString());
    }
  }

  Future<void> disconnect() async {
    await _client.disconnect();
    _currentUserId = null;
  }

  // Channel operations
  Future<Either<ChatException, Channel>> createDirectMessage(String otherUserId) async {
    try {
      final channel = await _client.channel(
        'messaging',
        extraData: {
          'members': [_currentUserId, otherUserId],
          'type': 'direct',
          'ibew_verified': true,
          'created_by': _currentUserId,
        },
      );

      return Right(channel);
    } catch (e) {
      return Left(ChannelCreationException(e.toString()));
    }
  }

  Future<Either<ChatException, Channel>> createCrewChannel({
    required String crewName,
    required List<String> memberIds,
    required String crewType,
    String? description,
  }) async {
    try {
      final allMembers = {...memberIds, _currentUserId!}.toList();

      final channel = await _client.channel(
        'messaging',
        extraData: {
          'name': 'IBEW $crewName',
          'description': description,
          'crew_type': crewType,
          'type': 'crew',
          'members': allMembers,
          'created_by': _currentUserId,
          'electrical_features': [
            'job_sharing',
            'safety_alerts',
            'location_sharing',
          ],
          'ibew_verified': true,
        },
      );

      return Right(channel);
    } catch (e) {
      return Left(ChannelCreationException(e.toString()));
    }
  }

  Future<Either<ChatException, Channel>> createFeedChannel({
    required String feedName,
    required String feedType,
    bool isPublic = true,
  }) async {
    try {
      final channel = await _client.channel(
        'livestream',
        extraData: {
          'name': feedName,
          'type': 'feed',
          'feed_type': feedType,
          'is_public': isPublic,
          'moderators': [_currentUserId],
          'created_by': _currentUserId,
        },
      );

      return Right(channel);
    } catch (e) {
      return Left(ChannelCreationException(e.toString()));
    }
  }

  // Message operations
  Future<Either<ChatException, Message>> sendMessage({
    required String channelId,
    required String text,
    List<Attachment>? attachments,
    String? replyToId,
  }) async {
    try {
      final channel = _client.channel(channelType: 'messaging', id: channelId);

      final messageRequest = MessageRequest(
        text: text,
        attachments: attachments ?? [],
        replyMessageId: replyToId,
      );

      final response = await channel.sendMessage(messageRequest);

      if (response.message != null) {
        return Right(response.message!);
      } else {
        return Left(MessageSendingException('Failed to send message'));
      }
    } catch (e) {
      return Left(MessageSendingException(e.toString()));
    }
  }

  // Query operations
  Future<List<Channel>> queryChannels({
    Filter? filter,
    List<SortOption>? sort,
    int limit = 20,
    String? next,
  }) async {
    try {
      final response = await _client.queryChannels(
        filter: filter ?? Filter.and_([
          Filter.in_('members', [_currentUserId!]),
        ]),
        sort: sort ?? [FieldSort('last_message_at', direction: -1)],
        pagination: PaginationParams(limit: limit, next: next),
      );

      return response.channels;
    } catch (e) {
      throw ChatException('Failed to query channels: $e');
    }
  }

  Stream<List<Channel>> watchChannels({
    Filter? filter,
    List<SortOption>? sort,
  }) {
    return _client.queryChannels(
      filter: filter ?? Filter.and_([
        Filter.in_('members', [_currentUserId!]),
      ]),
      sort: sort ?? [FieldSort('last_message_at', direction: -1)],
    ).map((response) => response.channels);
  }

  Stream<List<Message>> watchMessages(String channelId) {
    final channel = _client.channel(channelType: 'messaging', id: channelId);
    return channel.state!.messagesStream;
  }

  // Getters
  StreamChatClient get client => _client;
  String? get currentUserId => _currentUserId;
  bool get isConnected => _client.wsConnectionStatus.value == ConnectionStatus.connected;
}
```

**Implementation Steps**:

- [ ] Create StreamChatService with singleton pattern
- [ ] Implement initialization and disconnection
- [ ] Create methods for all channel types
- [ ] Implement message sending with attachments
- [ ] Add query and watch methods
- [ ] Handle all error cases with Either pattern

### 1.4 Presentation Layer Implementation (4 days)

#### Task 1.4.1: Create Chat List Screen

**File**: `lib/features/crews/presentation/screens/messaging/chat_list_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:journeyman_jobs/features/crews/presentation/providers/chat_provider.dart';
import 'package:journeyman_jobs/features/crews/presentation/widgets/channel/channel_list_view.dart';
import 'package:journeyman_jobs/features/crews/presentation/widgets/common/search_bar.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({Key? key}) : super(key: key);

  @override
  State<ChatListScreen> createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen>
    with AutomaticKeepAliveClientMixin {
  final TextEditingController _searchController = TextEditingController();
  bool _isSearching = false;

  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().loadChannels();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: Text(
          'IBEW Connect',
          style: AppTheme.headingLarge.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: Icon(
              _isSearching ? Icons.close : Icons.search,
              color: AppTheme.accentCopper,
            ),
            onPressed: _toggleSearch,
          ),
          PopupMenuButton<String>(
            icon: Icon(
              Icons.more_vert,
              color: AppTheme.accentCopper,
            ),
            onSelected: _handleMenuAction,
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'new_chat',
                child: Row(
                  children: [
                    Icon(Icons.add, color: AppTheme.primaryNavy),
                    SizedBox(width: 8),
                    Text('New Chat'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'create_crew',
                child: Row(
                  children: [
                    Icon(Icons.group_add, color: AppTheme.primaryNavy),
                    SizedBox(width: 8),
                    Text('Create Crew'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'feed',
                child: Row(
                  children: [
                    Icon(Icons.rss_feed, color: AppTheme.primaryNavy),
                    SizedBox(width: 8),
                    Text('View Feed'),
                  ],
                ),
              ),
            ],
          ),
        ],
        bottom: _isSearching
            ? PreferredSize(
                preferredSize: const Size.fromHeight(60),
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: JJSearchBar(
                    controller: _searchController,
                    hintText: 'Search chats...',
                    onChanged: _onSearchChanged,
                  ),
                ),
              )
            : null,
      ),
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.accentCopper,
        child: Consumer<ChatProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading && provider.channels.isEmpty) {
              return const Center(
                child: JJElectricalLoader(
                  width: 200,
                  height: 60,
                  message: 'Loading chats...',
                ),
              );
            }

            if (provider.error != null) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.error_outline,
                      size: 64,
                      color: AppTheme.errorRed,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Error loading chats',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      provider.error!,
                      style: AppTheme.bodySmall,
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: _retry,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCopper,
                      ),
                      child: const Text('Retry'),
                    ),
                  ],
                ),
              );
            }

            if (provider.channels.isEmpty) {
              return Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.chat_bubble_outline,
                      size: 64,
                      color: AppTheme.textGrey,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'No chats yet',
                      style: AppTheme.headingMedium,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Start a new conversation or join a crew',
                      style: AppTheme.bodySmall,
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton.icon(
                      onPressed: _createNewChat,
                      icon: const Icon(Icons.add),
                      label: const Text('New Chat'),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.accentCopper,
                      ),
                    ),
                  ],
                ),
              );
            }

            return ChannelListView(
              channels: provider.filteredChannels,
              onTap: _navigateToChat,
              onLongPress: _showChannelOptions,
            );
          },
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: _createNewChat,
        backgroundColor: AppTheme.accentCopper,
        child: const Icon(
          Icons.add,
          color: Colors.white,
        ),
      ),
    );
  }

  void _toggleSearch() {
    setState(() {
      _isSearching = !_isSearching;
      if (!_isSearching) {
        _searchController.clear();
        context.read<ChatProvider>().clearSearch();
      }
    });
  }

  void _onSearchChanged(String query) {
    context.read<ChatProvider>().searchChannels(query);
  }

  Future<void> _onRefresh() async {
    await context.read<ChatProvider>().refreshChannels();
  }

  void _retry() {
    context.read<ChatProvider>().loadChannels();
  }

  void _createNewChat() {
    // Navigate to new chat screen
    context.go('/chat/new');
  }

  void _navigateToChat(String channelId) {
    context.go('/chat/$channelId');
  }

  void _showChannelOptions(String channelId) {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChannelOptionsSheet(channelId: channelId),
    );
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'new_chat':
        _createNewChat();
        break;
      case 'create_crew':
        context.go('/crew/create');
        break;
      case 'feed':
        context.go('/feed');
        break;
    }
  }
}
```

**Implementation Steps**:

- [ ] Create ChatListScreen with proper theming
- [ ] Implement search functionality
- [ ] Add pull-to-refresh
- [ ] Create loading and error states
- [ ] Add menu actions
- [ ] Implement navigation

#### Task 1.4.2: Create Chat Screen

**File**: `lib/features/crews/presentation/screens/messaging/chat_screen.dart`

```dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/presentation/providers/chat_provider.dart';
import 'package:journeyman_jobs/features/crews/presentation/widgets/message/message_bubble.dart';
import 'package:journeyman_jobs/features/crews/presentation/widgets/message/message_input.dart';
import 'package:journeyman_jobs/features/crews/presentation/widgets/channel/channel_header.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

class ChatScreen extends StatefulWidget {
  final String channelId;

  const ChatScreen({
    Key? key,
    required this.channelId,
  }) : super(key: key);

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ScrollController _scrollController = ScrollController();
  final FocusNode _focusNode = FocusNode();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<ChatProvider>().markChannelAsRead(widget.channelId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundGrey,
      appBar: AppBar(
        title: ChannelHeader(channelId: widget.channelId),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(
              Icons.info_outline,
              color: AppTheme.accentCopper,
            ),
            onPressed: _showChannelInfo,
          ),
        ],
      ),
      body: Consumer<ChatProvider>(
        builder: (context, provider, child) {
          final messages = provider.messages[widget.channelId] ?? [];

          return Column(
            children: [
              Expanded(
                child: messages.isEmpty
                    ? _buildEmptyState()
                    : _buildMessageList(messages),
              ),
              MessageInput(
                channelId: widget.channelId,
                onSend: _sendMessage,
                onAttachmentTap: _showAttachmentOptions,
              ),
            ],
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppTheme.textGrey,
          ),
          const SizedBox(height: 16),
          Text(
            'Start the conversation',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.textGrey,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Send a message to begin chatting',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textGrey,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageList(List<Message> messages) {
    return ListView.builder(
      controller: _scrollController,
      reverse: true,
      padding: const EdgeInsets.symmetric(vertical: 8),
      itemCount: messages.length,
      itemBuilder: (context, index) {
        final message = messages[index];
        final isOwnMessage = message.user?.id == provider.currentUserId;

        return MessageBubble(
          message: message,
          isOwnMessage: isOwnMessage,
          onTap: _onMessageTap,
          onLongPress: _showMessageOptions,
        );
      },
    );
  }

  void _sendMessage(String text, {List<Attachment>? attachments}) {
    context.read<ChatProvider>().sendMessage(
      widget.channelId,
      text: text,
      attachments: attachments,
    );

    _scrollController.animateTo(
      0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _onMessageTap(Message message) {
    // Handle message tap (e.g., expand image)
  }

  void _showMessageOptions(Message message) {
    showModalBottomSheet(
      context: context,
      builder: (context) => MessageOptionsSheet(
        message: message,
        onReply: () => _replyToMessage(message),
        onDelete: () => _deleteMessage(message),
      ),
    );
  }

  void _replyToMessage(Message message) {
    // Focus input and set reply context
    _focusNode.requestFocus();
  }

  void _deleteMessage(Message message) {
    context.read<ChatProvider>().deleteMessage(message.id);
  }

  void _showAttachmentOptions() {
    showModalBottomSheet(
      context: context,
      builder: (context) => AttachmentOptionsSheet(
        onImageSelected: _sendImage,
        onFileSelected: _sendFile,
        onJobSelected: _shareJob,
      ),
    );
  }

  void _sendImage() async {
    // Pick and send image
  }

  void _sendFile() async {
    // Pick and send file
  }

  void _shareJob() async {
    // Navigate to job selection
  }

  void _showChannelInfo() {
    showModalBottomSheet(
      context: context,
      builder: (context) => ChannelInfoSheet(channelId: widget.channelId),
    );
  }
}
```

**Implementation Steps**:

- [ ] Create ChatScreen with message list
- [ ] Implement message input with attachment support
- [ ] Add empty state handling
- [ ] Create message options menu
- [ ] Implement reply and delete actions
- [ ] Add smooth scrolling animations

### 1.5 State Management Setup (2 days)

#### Task 1.5.1: Create Chat Provider

**File**: `lib/features/crews/presentation/providers/chat_provider.dart`

```dart
import 'package:flutter/foundation.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/features/crews/data/services/stream_chat_service.dart';
import 'package:journeyman_jobs/features/crews/domain/models/crew_channel.dart';
import 'package:journeyman_jobs/features/crews/domain/exceptions/chat_exceptions.dart';

class ChatProvider extends ChangeNotifier {
  final StreamChatService _chatService;

  List<Channel> _channels = [];
  List<Channel> get channels => _channels;

  List<Channel> _filteredChannels = [];
  List<Channel> get filteredChannels => _filteredChannels;

  Map<String, List<Message>> _messages = {};
  Map<String, List<Message>> get messages => _messages;

  Set<String> _unreadChannelIds = {};
  Set<String> get unreadChannelIds => _unreadChannelIds;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _error;
  String? get error => _error;

  String _searchQuery = '';
  String get searchQuery => _searchQuery;

  ChatProvider(this._chatService) {
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    // Initialize chat with stored credentials if available
    final credentials = await StreamChatService.getCredentials();
    if (credentials['userId'] != null && credentials['token'] != null) {
      await _chatService.initialize(
        userId: credentials['userId']!,
        token: credentials['token']!,
      );
      await loadChannels();
    }
  }

  Future<void> loadChannels() async {
    _setLoading(true);
    _clearError();

    try {
      final channels = await _chatService.queryChannels(
        sort: [FieldSort('last_message_at', direction: -1)],
      );

      _channels = channels;
      _filteredChannels = channels;

      // Update unread channels
      _updateUnreadChannels();

      notifyListeners();
    } catch (e) {
      _setError(e.toString());
    } finally {
      _setLoading(false);
    }
  }

  Future<void> refreshChannels() async {
    await loadChannels();
  }

  void searchChannels(String query) {
    _searchQuery = query;

    if (query.isEmpty) {
      _filteredChannels = _channels;
    } else {
      _filteredChannels = _channels.where((channel) {
        final name = channel.name?.toLowerCase() ?? '';
        final memberNames = channel.state?.members
            ?.map((m) => m.user?.name?.toLowerCase() ?? '')
            .join(' ') ?? '';
        return name.contains(query.toLowerCase()) ||
               memberNames.contains(query.toLowerCase());
      }).toList();
    }

    notifyListeners();
  }

  void clearSearch() {
    _searchQuery = '';
    _filteredChannels = _channels;
    notifyListeners();
  }

  Future<void> loadMessages(String channelId) async {
    if (_messages.containsKey(channelId)) return;

    try {
      final channel = _chatService.client.channel(
        channelType: 'messaging',
        id: channelId,
      );

      final response = await channel.query(
        messagesPagination: PaginationParams(limit: 50),
      );

      _messages[channelId] = response.messages ?? [];

      // Start watching for new messages
      _chatService.watchMessages(channelId).listen((newMessages) {
        _messages[channelId] = newMessages;
        notifyListeners();
      });

      notifyListeners();
    } catch (e) {
      debugPrint('Error loading messages: $e');
    }
  }

  Future<void> sendMessage(
    String channelId, {
    required String text,
    List<Attachment>? attachments,
    String? replyToId,
  }) async {
    try {
      final result = await _chatService.sendMessage(
        channelId: channelId,
        text: text,
        attachments: attachments,
        replyToId: replyToId,
      );

      result.fold(
        (error) => _setError(error.toString()),
        (message) {
          // Message sent successfully
          _clearError();
        },
      );
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<void> markChannelAsRead(String channelId) async {
    try {
      final channel = _chatService.client.channel(
        channelType: 'messaging',
        id: channelId,
      );

      await channel.markRead();
      _unreadChannelIds.remove(channelId);
      notifyListeners();
    } catch (e) {
      debugPrint('Error marking channel as read: $e');
    }
  }

  Future<void> deleteMessage(String messageId) async {
    try {
      await _chatService.client.deleteMessage(messageId);
      _clearError();
    } catch (e) {
      _setError(e.toString());
    }
  }

  Future<Channel?> createDirectMessage(String otherUserId) async {
    try {
      final result = await _chatService.createDirectMessage(otherUserId);

      Channel? newChannel;
      result.fold(
        (error) {
          _setError(error.toString());
        },
        (channel) {
          newChannel = channel;
          _channels.insert(0, channel);
          _filteredChannels.insert(0, channel);
          notifyListeners();
        },
      );

      return newChannel;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  Future<Channel?> createCrewChannel({
    required String crewName,
    required List<String> memberIds,
    required String crewType,
    String? description,
  }) async {
    try {
      final result = await _chatService.createCrewChannel(
        crewName: crewName,
        memberIds: memberIds,
        crewType: crewType,
        description: description,
      );

      Channel? newChannel;
      result.fold(
        (error) {
          _setError(error.toString());
        },
        (channel) {
          newChannel = channel;
          _channels.insert(0, channel);
          _filteredChannels.insert(0, channel);
          notifyListeners();
        },
      );

      return newChannel;
    } catch (e) {
      _setError(e.toString());
      return null;
    }
  }

  void _updateUnreadChannels() {
    _unreadChannelIds.clear();

    for (final channel in _channels) {
      final unreadCount = channel.state?.unreadCount ?? 0;
      if (unreadCount > 0) {
        _unreadChannelIds.add(channel.cid!);
      }
    }
  }

  void _setLoading(bool loading) {
    _isLoading = loading;
    notifyListeners();
  }

  void _setError(String error) {
    _error = error;
    notifyListeners();
  }

  void _clearError() {
    _error = null;
    notifyListeners();
  }

  String? get currentUserId => _chatService.currentUserId;
}
```

**Implementation Steps**:

- [ ] Create ChatProvider with all channel operations
- [ ] Implement message management
- [ ] Add search functionality
- [ ] Implement error handling
- [ ] Add loading states
- [ ] Set up real-time updates

### 1.6 Navigation Integration (1 day)

#### Task 1.6.1: Create Chat Routes

**File**: `lib/features/crews/presentation/shared/navigation/chat_routes.dart`

```dart
import 'package:go_router/go_router.dart';
import 'package:flutter/material.dart';
import 'package:journeyman_jobs/features/crews/presentation/screens/messaging/chat_list_screen.dart';
import 'package:journeyman_jobs/features/crews/presentation/screens/messaging/chat_screen.dart';
import 'package:journeyman_jobs/features/crews/presentation/screens/messaging/new_chat_screen.dart';
import 'package:journeyman_jobs/features/crews/presentation/screens/crew/crew_chat_screen.dart';
import 'package:journeyman_jobs/features/crews/presentation/screens/feed/feed_screen.dart';

final chatRoutes = [
  GoRoute(
    path: '/chat',
    builder: (context, state) => const ChatListScreen(),
    routes: [
      GoRoute(
        path: '/:channelId',
        builder: (context, state) => ChatScreen(
          channelId: state.pathParameters['channelId']!,
        ),
      ),
      GoRoute(
        path: '/new',
        builder: (context, state) => const NewChatScreen(),
      ),
      GoRoute(
        path: '/direct/:userId',
        builder: (context, state) {
          final userId = state.pathParameters['userId']!;
          // Create or get direct message channel
          return ChatScreen(channelId: userId);
        },
      ),
      GoRoute(
        path: '/crew/:crewId',
        builder: (context, state) => CrewChatScreen(
          crewId: state.pathParameters['crewId']!,
        ),
      ),
    ],
  ),
  GoRoute(
    path: '/feed',
    builder: (context, state) => const FeedScreen(),
  ),
];
```

**Implementation Steps**:

- [ ] Create all chat routes
- [ ] Add parameter handling
- [ ] Integrate with main router
- [ ] Add route guards if needed

## 📋 Phase 2: Crew Features Implementation (Week 3-4)

### 2.1 Crew Channel Management (4 days)

#### Task 2.1.1: Create Crew Channel Service

- [ ] Extend StreamChatService for crew-specific channels
- [ ] Implement crew type classifications
- [ ] Add crew permission system
- [ ] Create crew discovery features

#### Task 2.1.2: Implement Member Management

- [ ] Create invite/remove member logic
- [ ] Implement role hierarchy (Admin, Member, Observer)
- [ ] Add crew search and discovery
- [ ] Create crew invitation system

#### Task 2.1.3: Build Crew UI Components

- [ ] Design crew profile widget
- [ ] Create crew member list view
- [ ] Add crew status indicators
- [ ] Implement crew settings panel

### 2.2 Crew Chat Features (3 days)

#### Task 2.2.1: Crew-Specific Features

- [ ] Add crew location sharing
- [ ] Implement crew check-in/out system
- [ ] Create crew-specific reactions (electrical emojis)
- [ ] Add crew status updates

#### Task 2.2.2: Crew Management Screens

- [ ] Create crew creation flow
- [ ] Build crew directory
- [ ] Implement crew search
- [ ] Add crew settings and configuration

### 2.3 Integration with Existing System (3 days)

#### Task 2.3.1: Integrate Crew Data

- [ ] Connect to existing crew database
- [ ] Sync crew memberships
- [ ] Update crew chat channels automatically
- [ ] Handle crew data conflicts

## 📋 Phase 3: Advanced Features Implementation (Week 5-6)

### 3.1 File Attachments (4 days)

#### Task 3.1.1: Media Handling

- [ ] Implement image picker with camera support
- [ ] Add image compression and optimization
- [ ] Create image gallery viewer
- [ ] Implement video recording and playback

#### Task 3.1.2: Document Handling

- [ ] Add PDF/document picker
- [ ] Create document preview functionality
- [ ] Implement download manager
- [ ] Add document viewer integration

#### Task 3.1.3: Attachment UI

- [ ] Design attachment preview cards
- [ ] Create upload progress indicators
- [ ] Implement drag-and-drop for file uploads
- [ ] Add attachment management (delete, save, share)

### 3.2 Message Reactions & Threading (3 days)

#### Task 3.2.1: Reaction System

- [ ] Implement electrical-themed reactions (⚡, 🔧, ⚠️, etc.)
- [ ] Create reaction picker UI
- [ ] Add reaction animations
- [ ] Implement reaction summary view

#### Task 3.2.2: Message Threading

- [ ] Add reply functionality
- [ ] Create threaded message view
- [ ] Implement thread navigation
- [ ] Add thread indicators

### 3.3 Feed System (3 days)

#### Task 3.3.1: Feed Implementation

- [ ] Create broadcast channel system
- [ ] Implement feed moderation tools
- [ ] Add feed filtering and search
- [ ] Create feed analytics

#### Task 3.3.2: Feed UI Components

- [ ] Design feed card layout
- [ ] Create feed post creator
- [ ] Implement feed interaction buttons
- [ ] Add feed share functionality

### 3.4 Push Notifications (3 days)

#### Task 3.4.1: Firebase Messaging Setup

- [ ] Initialize Firebase Cloud Messaging
- [ ] Configure notification channels
- [ ] Implement permission handling
- [ ] Create notification service

#### Task 3.4.2: Notification Types

- [ ] Crew message notifications
- [ ] Safety alert notifications
- [ ] Job posting notifications
- [ ] System update notifications

### 3.5 Offline Support (1 day)

#### Task 3.5.1: Persistence Configuration

- [ ] Enable Stream Chat persistence
- [ ] Implement offline message queue
- [ ] Add sync status indicators
- [ ] Create offline mode UI

## 📋 Phase 4: Electrical-Specific Features (Week 7-8)

### 4.1 Job Sharing Integration (3 days)

#### Task 4.1.1: Job Model Integration

- [ ] Connect to existing Job model
- [ ] Create job attachment widgets
- [ ] Implement job sharing from chat
- [ ] Add job application tracking

#### Task 4.1.2: Job Sharing Features

- [ ] "Share to Crew" functionality
- [ ] Job preview cards in chat
- [ ] Quick apply from shared jobs
- [ ] Job sharing analytics

### 4.2 Safety Alert System (3 days)

#### Task 4.2.1: Safety Alert Implementation

- [ ] Create safety alert message type
- [ ] Implement alert severity levels
- [ ] Add alert acknowledgment system
- [ ] Create alert escalation rules

#### Task 4.2.2: Safety Alert UI

- [ ] Design alert card widgets
- [ ] Add alert animations
- [ ] Create alert history view
- [ ] Implement alert reporting

### 4.3 Location Features (2 days)

#### Task 4.3.1: Location Sharing

- [ ] Implement location picker
- [ ] Add location sharing permissions
- [ ] Create map preview in chat
- [ ] Implement location-based alerts

#### Task 4.3.2: Job Site Features

- [ ] Job site check-in system
- [ ] Crew location map
- [ ] Proximity alerts
- [ ] Location history

### 4.4 Electrical-Themed Customization (2 days)

#### Task 4.4.1: Electrical UI Elements

- [ ] Circuit pattern backgrounds
- [ ] Lightning bolt animations
- [ ] Electrical color schemes
- [ ] Custom electrical icons

#### Task 4.4.2: Specialized Features

- [ ] Electrical status indicators
- [ ] Safety protocol messages
- [ ] Weather alert integration
- [ ] Storm work coordination

## 🧪 Testing Strategy

### Unit Tests (Throughout implementation)

- [ ] Repository implementations
- [ ] Use cases
- [ ] Provider logic
- [ ] Service integrations

### Widget Tests (After each screen)

- [ ] Screen rendering
- [ ] User interactions
- [ ] Navigation flows
- [ ] Error states

### Integration Tests (End of each phase)

- [ ] End-to-end messaging flow
- [ ] Offline synchronization
- [ ] Push notification delivery
- [ ] File upload/download

### Performance Tests

- [ ] Message loading performance
- [ ] Memory usage monitoring
- [ ] Battery consumption testing
- [ ] Network optimization

## 🔧 Configuration Checklist

### Environment Setup

- [ ] Add Stream Chat API keys to environment
- [ ] Configure Firebase project
- [ ] Set up development database
- [ ] Configure CI/CD pipeline

### Security Configuration

- [ ] Enable authentication providers
- [ ] Configure Firestore security rules
- [ ] Set up Storage security rules
- [ ] Configure API key restrictions

### Production Setup

- [ ] Configure production database
- [ ] Set up monitoring and analytics
- [ ] Configure error reporting
- [ ] Set up backup procedures

## 📊 Success Metrics

### Technical KPIs

- Message delivery success rate: >99.9%
- App startup time: <2 seconds
- Message load time: <500ms
- Battery usage: <15%/hour active
- Memory usage: <150MB average

### User Engagement

- Daily Active Users (DAU)
- Messages sent per user per day
- Average session duration
- Feature adoption rates
- User satisfaction score

## 🔄 Maintenance Plan

### Daily

- Monitor error rates
- Check system performance
- Review user feedback

### Weekly

- Update dependencies
- Review analytics
- Optimize queries

### Monthly

- Security audits
- Performance reviews
- Feature usage analysis
- User survey review

### Quarterly

- Architecture review
- Scalability assessment
- Technology updates
- Roadmap planning

This comprehensive implementation plan provides a detailed roadmap for building a robust, feature-rich messaging system tailored specifically for IBEW electrical workers while maintaining clean architecture principles and best practices.
