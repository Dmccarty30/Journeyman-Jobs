// lib/providers/riverpod/global_feed_riverpod_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../models/message.dart';
import '../models/message_type.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';

part 'global_feed_riverpod_provider.g.dart';

/// Stream of global messages
@riverpod
Stream<List<Message>> globalMessagesStream(Ref ref) {
  return FirebaseFirestore.instance
      .collection('global_messages')
      .orderBy('sentAt', descending: true)
      .limit(50)
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => Message.fromMap(doc.data())).toList();
      });
}

/// Global messages
@riverpod
List<Message> globalMessages(Ref ref) {
  final messagesAsync = ref.watch(globalMessagesStreamProvider);
  
  return messagesAsync.when(
    data: (messages) => messages,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider to send a global message
@riverpod
class SendGlobalMessageNotifier extends _$SendGlobalMessageNotifier {
  @override
  void build() {} // No initial state needed for a method provider

  Future<void> sendGlobalMessage(String text, {required String senderId, required String content}) async {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      throw Exception('User not authenticated to send global message.');
    }

    try {
      await FirebaseFirestore.instance.collection('global_messages').add({
        'text': text,
        'senderId': currentUser.uid,
        'sentAt': FieldValue.serverTimestamp(),
        'type': MessageType.text.value,
        'readBy': {}, // Initialize with empty readBy map
      });
    } catch (e) {
      rethrow;
    }
  }
}

/// Provider to get unread global messages count
@riverpod
int unreadGlobalCount(Ref ref) {
  final currentUser = ref.watch(currentUserProvider);
  final messages = ref.watch(globalMessagesProvider);
  
  if (currentUser == null) return 0;
  
  return messages.where((message) {
    return message.senderId != currentUser.uid && !message.isReadBy(currentUser.uid);
  }).length;
}
