import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../models/message.dart';
import '../services/message_service.dart';
import 'crews_riverpod_provider.dart';

part 'messaging_riverpod_provider.g.dart';

/// MessageService provider
@riverpod
MessageService messageService(Ref ref) => MessageService();

/// Stream of crew messages
@riverpod
Stream<List<Message>> crewMessagesStream(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }
  
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getCrewMessagesStream(crewId, currentUser.uid);
}

/// Crew messages
@riverpod
List<Message> crewMessages(Ref ref, String crewId) {
  final messagesAsync = ref.watch(crewMessagesStreamProvider(crewId));
  
  return messagesAsync.when(
    data: (messages) => messages,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Stream of direct messages between two users
@riverpod
Stream<List<Message>> directMessagesStream(
  Ref ref,
  String userId1,
  String userId2,
) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  
  if (currentUser == null) {
    return Stream.value([]);
  }
  
  final messageService = ref.watch(messageServiceProvider);
  return messageService.getDirectMessagesStream(userId1, userId2, currentUser.uid);
}

/// Direct messages between two users
@riverpod
List<Message> directMessages(
  Ref ref,
  String userId1,
  String userId2,
) {
  final messagesAsync = ref.watch(directMessagesStreamProvider(userId1, userId2));
  
  return messagesAsync.when(
    data: (messages) => messages,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider to get unread crew messages count for current user
@riverpod
int unreadCrewMessagesCount(Ref ref, String crewId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final messages = ref.watch(crewMessagesProvider(crewId));
  
  if (currentUser == null) return 0;
  
  return messages.where((message) {
    return message.isCrewMessage && !message.isReadBy(currentUser.uid);
  }).length;
}

/// Provider to get unread direct messages count for current user
@riverpod
int unreadDirectMessagesCount(Ref ref, String otherUserId) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final messages = ref.watch(directMessagesProvider(
    currentUser?.uid ?? '',
    otherUserId,
  ));
  
  if (currentUser == null) return 0;
  
  return messages.where((message) {
    return message.isDirectMessage && 
           message.senderId != currentUser.uid &&
           !message.isReadBy(currentUser.uid);
  }).length;
}

/// Provider to get total unread messages count for current user across all crews
@riverpod
int totalUnreadMessages(Ref ref) {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final crews = ref.watch(userCrewsProvider);
  
  if (currentUser == null) return 0;
  
  int totalUnread = 0;
  
  for (final crew in crews) {
    totalUnread += ref.watch(unreadCrewMessagesCountProvider(crew.id));
  }
  
  return totalUnread;
}

/// Provider to get recent messages (last 24 hours)
@riverpod
List<Message> recentMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  final twentyFourHoursAgo = DateTime.now().subtract(const Duration(hours: 24));
  
  return messages.where((message) {
    return message.sentAt.isAfter(twentyFourHoursAgo);
  }).toList();
}

/// Provider to get messages by sender
@riverpod
List<Message> messagesBySender(Ref ref, String crewId, String senderId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.where((message) => message.senderId == senderId).toList();
}

/// Provider to get messages with attachments
@riverpod
List<Message> messagesWithAttachments(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.where((message) => message.hasAttachments).toList();
}

/// Provider to get latest message in a crew
@riverpod
Message? latestMessage(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  if (messages.isEmpty) return null;
  
  return messages.reduce((a, b) => a.sentAt.isAfter(b.sentAt) ? a : b);
}

/// Provider to get last message timestamp
@riverpod
DateTime? lastMessageTimestamp(Ref ref, String crewId) {
  final latest = ref.watch(latestMessageProvider(crewId));
  return latest?.sentAt;
}

/// Provider to check if crew has unread messages
@riverpod
bool hasUnreadCrewMessages(Ref ref, String crewId) {
  final unreadCount = ref.watch(unreadCrewMessagesCountProvider(crewId));
  return unreadCount > 0;
}

/// Provider to get message by ID
@riverpod
Message? messageById(Ref ref, String crewId, String messageId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.firstWhere(
    (message) => message.id == messageId,
    orElse: () => null as dynamic,
  );
}

/// Provider to get read receipts for a message
@riverpod
Map<String, DateTime> messageReadReceipts(Ref ref, String crewId, String messageId) {
  final message = ref.watch(messageByIdProvider(crewId, messageId));
  return message?.readBy ?? {};
}

/// Provider to get read receipt count for a message
@riverpod
int messageReadReceiptCount(Ref ref, String crewId, String messageId) {
  final readBy = ref.watch(messageReadReceiptsProvider(crewId, messageId));
  return readBy.length;
}

/// Provider to check if message has been read by specific user
@riverpod
bool isMessageReadBy(Ref ref, String crewId, String messageId, String userId) {
  final message = ref.watch(messageByIdProvider(crewId, messageId));
  return message?.isReadBy(userId) ?? false;
}

/// Provider to get messages in chronological order
@riverpod
List<Message> chronologicalMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return List.from(messages)..sort((a, b) => a.sentAt.compareTo(b.sentAt));
}

/// Provider to get messages in reverse chronological order
@riverpod
List<Message> reverseChronologicalMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return List.from(messages)..sort((a, b) => b.sentAt.compareTo(a.sentAt));
}

/// Provider to get text messages only
@riverpod
List<Message> textMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.where((message) => message.type == MessageType.text).toList();
}

/// Provider to get messages with job shares
@riverpod
List<Message> jobShareMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.where((message) => message.type == MessageType.jobShare).toList();
}

/// Provider to get system notification messages
@riverpod
List<Message> systemNotificationMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.where((message) => message.type == MessageType.systemNotification).toList();
}

/// Provider to get message count for a crew
@riverpod
int messageCount(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  return messages.length;
}

/// Provider to get today's messages
@riverpod
List<Message> todaysMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  final today = DateTime.now();
  final startOfDay = DateTime(today.year, today.month, today.day);
  
  return messages.where((message) {
    return message.sentAt.isAfter(startOfDay);
  }).toList();
}

/// Provider to get messages from last week
@riverpod
List<Message> lastWeekMessages(Ref ref, String crewId) {
  final messages = ref.watch(crewMessagesProvider(crewId));
  final oneWeekAgo = DateTime.now().subtract(const Duration(days: 7));
  
  return messages.where((message) {
    return message.sentAt.isAfter(oneWeekAgo);
  }).toList();
}
