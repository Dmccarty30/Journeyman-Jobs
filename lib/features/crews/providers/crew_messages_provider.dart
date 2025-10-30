import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chat_message.dart';

/// Provider for managing crew chat messages.
final crewMessagesProvider = StreamProvider.family<List<ChatMessage>, String>((ref, crewId) {
  return FirebaseFirestore.instance
      .collection('crews')
      .doc(crewId)
      .collection('messages')
      .orderBy('timestamp', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList());
});

/// Notifier for crew messages operations.
class CrewMessagesNotifier extends AsyncNotifier<List<ChatMessage>> {
  String _crewId = '';

  @override
  Future<List<ChatMessage>> build() async {
    return [];
  }

  void setCrewId(String crewId) {
    _crewId = crewId;
    _loadMessages();
  }

  Future<void> _loadMessages() async {
    state = const AsyncValue.loading();
    
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('crews')
          .doc(_crewId)
          .collection('messages')
          .orderBy('timestamp', descending: true)
          .get();
      
      final messages = snapshot.docs
          .map((doc) => ChatMessage.fromFirestore(doc))
          .toList();
      
      state = AsyncValue.data(messages);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> sendMessage(String text) async {
    if (_crewId.isEmpty) return;
    
    try {
      final user = ref.read(authRiverpodProvider);
      if (user == null) return;
      
      final message = ChatMessage(
        id: '', // Will be set by Firestore
        crewId: _crewId,
        senderId: user.uid,
        senderName: user.displayName ?? 'Unknown',
        text: text,
        timestamp: DateTime.now(),
        isRead: false,
      );
      
      await FirebaseFirestore.instance
          .collection('crews')
          .doc(_crewId)
          .collection('messages')
          .add(message.toFirestore());
      
      // Refresh messages
      _loadMessages();
    } catch (e) {
      // Handle error
    }
  }

  Future<void> markMessagesAsRead() async {
    if (_crewId.isEmpty) return;
    
    try {
      final user = ref.read(authRiverpodProvider);
      if (user == null) return;
      
      final unreadMessages = await FirebaseFirestore.instance
          .collection('crews')
          .doc(_crewId)
          .collection('messages')
          .where('senderId', isNotEqualTo: user.uid)
          .where('isRead', isEqualTo: false)
          .get();
      
      for (final doc in unreadMessages.docs) {
        await doc.reference.update({'isRead': true});
      }
    } catch (e) {
      // Handle error
    }
  }
}

/// Provider for crew messages notifier.
final crewMessagesNotifierProvider = AsyncNotifierProvider<CrewMessagesNotifier, List<ChatMessage>>(
  CrewMessagesNotifier.new,
);
