import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:state_notifier/state_notifier.dart';
import '../services/crew_message_service.dart';
import '../models/message.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;

/// Crew Message Service Provider
final crewMessageServiceProvider = Provider<CrewMessageService>((ref) {
  return CrewMessageService();
});

/// Stream of crew feed messages with pagination support
///
/// **Performance Features:**
/// - Real-time Firestore listener
/// - Automatic pagination (50 messages)
/// - Offline caching enabled
/// - Optimistic UI updates
final crewFeedMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, crewId) {
  final messageService = ref.watch(crewMessageServiceProvider);
  return messageService.getCrewFeedMessages(crewId: crewId);
});

/// Stream of crew chat messages with pagination support
///
/// **Performance Features:**
/// - Real-time Firestore listener
/// - Automatic pagination (50 messages)
/// - Auto-scroll to latest message
/// - Read receipt tracking
final crewChatMessagesStreamProvider = StreamProvider.autoDispose
    .family<List<Message>, String>((ref, crewId) {
  final messageService = ref.watch(crewMessageServiceProvider);
  return messageService.getCrewChatMessages(crewId: crewId);
});

/// Notifier for sending feed messages with optimistic UI
class FeedMessageNotifier extends StateNotifier<AsyncValue<String?>> {
  FeedMessageNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Send message to crew feed with optimistic UI
  Future<void> sendMessage({
    required String crewId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final messageService = _ref.read(crewMessageServiceProvider);
      final messageId = await messageService.sendMessageToFeed(
        crewId: crewId,
        senderId: currentUser.uid,
        content: content,
        type: type,
        attachments: attachments,
      );
      state = AsyncValue.data(messageId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for feed message notifier
final feedMessageNotifierProvider =
    StateNotifierProvider.autoDispose<FeedMessageNotifier, AsyncValue<String?>>(
  (ref) => FeedMessageNotifier(ref),
);

/// Notifier for sending chat messages with optimistic UI
class ChatMessageNotifier extends StateNotifier<AsyncValue<String?>> {
  ChatMessageNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Send message to crew chat with optimistic UI
  Future<void> sendMessage({
    required String crewId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error(
        'User not authenticated',
        StackTrace.empty,
      );
      return;
    }

    state = const AsyncValue.loading();
    try {
      final messageService = _ref.read(crewMessageServiceProvider);
      final messageId = await messageService.sendMessageToChat(
        crewId: crewId,
        senderId: currentUser.uid,
        content: content,
        type: type,
        attachments: attachments,
      );
      state = AsyncValue.data(messageId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for chat message notifier
final chatMessageNotifierProvider =
    StateNotifierProvider.autoDispose<ChatMessageNotifier, AsyncValue<String?>>(
  (ref) => ChatMessageNotifier(ref),
);

/// Notifier for marking messages as read
class MessageReadNotifier extends StateNotifier<AsyncValue<void>> {
  MessageReadNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  /// Mark single message as read
  Future<void> markAsRead({
    required String crewId,
    required String messageId,
    bool isChatMessage = false,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final messageService = _ref.read(crewMessageServiceProvider);
      await messageService.markMessageAsRead(
        crewId: crewId,
        messageId: messageId,
        userId: currentUser.uid,
        isChatMessage: isChatMessage,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  /// Batch mark multiple messages as read (performance optimization)
  Future<void> batchMarkAsRead({
    required String crewId,
    required List<String> messageIds,
    bool isChatMessage = false,
  }) async {
    final currentUser = _ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) return;

    state = const AsyncValue.loading();
    try {
      final messageService = _ref.read(crewMessageServiceProvider);
      await messageService.batchMarkMessagesAsRead(
        crewId: crewId,
        messageIds: messageIds,
        userId: currentUser.uid,
        isChatMessage: isChatMessage,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }
}

/// Provider for message read notifier
final messageReadNotifierProvider =
    StateNotifierProvider.autoDispose<MessageReadNotifier, AsyncValue<void>>(
  (ref) => MessageReadNotifier(ref),
);

/// Get unread message count for crew feed
final crewFeedUnreadCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, crewId) async {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return 0;

  final messageService = ref.watch(crewMessageServiceProvider);
  return await messageService.getUnreadMessageCount(
    crewId: crewId,
    userId: currentUser.uid,
    isChatMessage: false,
  );
});

/// Get unread message count for crew chat
final crewChatUnreadCountProvider =
    FutureProvider.autoDispose.family<int, String>((ref, crewId) async {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return 0;

  final messageService = ref.watch(crewMessageServiceProvider);
  return await messageService.getUnreadMessageCount(
    crewId: crewId,
    userId: currentUser.uid,
    isChatMessage: true,
  );
});
