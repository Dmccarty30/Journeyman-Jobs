import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';

class MessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get Firestore collections
  CollectionReference get crewsCollection => _firestore.collection('crews');
  CollectionReference get messagesCollection => _firestore.collection('messages');

  // Send a crew message
  Future<void> sendCrewMessage({
    required String crewId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    try {
      final message = Message(
        id: '', // Will be set by Firestore
        senderId: senderId,
        crewId: crewId,
        content: content,
        type: type,
        attachments: attachments,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      await crewsCollection
          .doc(crewId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      throw Exception('Error sending crew message: $e');
    }
  }

  // Send a direct message
  Future<void> sendDirectMessage({
    required String senderId,
    required String recipientId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    try {
      final message = Message(
        id: '', // Will be set by Firestore
        senderId: senderId,
        recipientId: recipientId,
        content: content,
        type: type,
        attachments: attachments,
        sentAt: DateTime.now(),
        readBy: {},
        isEdited: false,
      );

      // Create a conversation ID that is consistent regardless of who sends first
      final conversationId = _getConversationId(senderId, recipientId);
      
      await messagesCollection
          .doc(conversationId)
          .collection('messages')
          .add(message.toFirestore());
    } catch (e) {
      throw Exception('Error sending direct message: $e');
    }
  }

  // Get crew messages stream
  Stream<List<Message>> getCrewMessagesStream(String crewId, String uid) {
    return crewsCollection
        .doc(crewId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100) // Limit to recent messages
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Get direct messages stream for a conversation
  Stream<List<Message>> getDirectMessagesStream(String userId1, String userId2, String uid) {
    final conversationId = _getConversationId(userId1, userId2);
    
    return messagesCollection
        .doc(conversationId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(100) // Limit to recent messages
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Get all conversations for a user
  Stream<List<Map<String, dynamic>>> getUserConversationsStream(String userId) {
    return messagesCollection
        .where('participants', arrayContains: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return {
          'conversationId': doc.id,
          'participants': data['participants'] ?? [],
          'lastMessage': data['lastMessage'] ?? {},
          'updatedAt': data['updatedAt'],
        };
      }).toList();
    });
  }

  // Mark message as read
  Future<void> markAsRead({
    required String messageId,
    required String userId,
    bool isCrewMessage = false,
    String? crewId,
    String? conversationId,
  }) async {
    try {
      if (isCrewMessage && crewId != null) {
        // Mark crew message as read
        final messageDoc = await crewsCollection
            .doc(crewId)
            .collection('messages')
            .doc(messageId)
            .get();

        if (messageDoc.exists) {
          final message = Message.fromFirestore(messageDoc);
          final updatedMessage = message.markAsRead(userId);
          
          await messageDoc.reference.update({
            'readBy': updatedMessage.readBy.map((key, value) => 
                MapEntry(key, Timestamp.fromDate(value))),
          });
        }
      } else if (conversationId != null) {
        // Mark direct message as read
        final messageDoc = await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .doc(messageId)
            .get();

        if (messageDoc.exists) {
          final message = Message.fromFirestore(messageDoc);
          final updatedMessage = message.markAsRead(userId);
          
          await messageDoc.reference.update({
            'readBy': updatedMessage.readBy.map((key, value) => 
                MapEntry(key, Timestamp.fromDate(value))),
          });
        }
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  // Edit a message
  Future<void> editMessage({
    required String messageId,
    required String newContent,
    bool isCrewMessage = false,
    String? crewId,
    String? conversationId,
  }) async {
    try {
      final updateData = {
        'content': newContent,
        'isEdited': true,
        'editedAt': Timestamp.fromDate(DateTime.now()),
      };

      if (isCrewMessage && crewId != null) {
        await crewsCollection
            .doc(crewId)
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      } else if (conversationId != null) {
        await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Error editing message: $e');
    }
  }

  // Delete a message (soft delete)
  Future<void> deleteMessage({
    required String messageId,
    bool isCrewMessage = false,
    String? crewId,
    String? conversationId,
  }) async {
    try {
      final updateData = {
        'content': '[Message deleted]',
        'type': 'systemNotification',
        'attachments': null,
        'isEdited': false,
        'editedAt': null,
      };

      if (isCrewMessage && crewId != null) {
        await crewsCollection
            .doc(crewId)
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      } else if (conversationId != null) {
        await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Error deleting message: $e');
    }
  }

  // Get unread message count for a user
  Future<int> getUnreadMessageCount({
    required String userId,
    bool isCrewMessage = false,
    String? crewId,
    String? conversationId,
  }) async {
    try {
      if (isCrewMessage && crewId != null) {
        final snapshot = await crewsCollection
            .doc(crewId)
            .collection('messages')
            .get();

        int unreadCount = 0;
        for (final doc in snapshot.docs) {
          final message = Message.fromFirestore(doc);
          if (!message.isReadBy(userId)) {
            unreadCount++;
          }
        }
        return unreadCount;
      } else if (conversationId != null) {
        final snapshot = await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .get();

        int unreadCount = 0;
        for (final doc in snapshot.docs) {
          final message = Message.fromFirestore(doc);
          if (!message.isReadBy(userId)) {
            unreadCount++;
          }
        }
        return unreadCount;
      }
      return 0;
    } catch (e) {
      return 0;
    }
  }

  // Get recent messages for a user
  Future<List<Message>> getRecentMessages({
    required String userId,
    int limit = 20,
  }) async {
    try {
      final List<Message> recentMessages = [];

      // Get recent crew messages
      final crewSnapshot = await crewsCollection
          .where('memberIds', arrayContains: userId)
          .get();

      for (final crewDoc in crewSnapshot.docs) {
        final messagesSnapshot = await crewsCollection
            .doc(crewDoc.id)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .limit(5) // Get few messages from each crew
            .get();

        for (final messageDoc in messagesSnapshot.docs) {
          final message = Message.fromFirestore(messageDoc);
          recentMessages.add(message);
        }
      }

      // Get recent direct messages
      final conversationsSnapshot = await messagesCollection
          .where('participants', arrayContains: userId)
          .get();

      for (final conversationDoc in conversationsSnapshot.docs) {
        final messagesSnapshot = await messagesCollection
            .doc(conversationDoc.id)
            .collection('messages')
            .orderBy('sentAt', descending: true)
            .limit(5) // Get few messages from each conversation
            .get();

        for (final messageDoc in messagesSnapshot.docs) {
          final message = Message.fromFirestore(messageDoc);
          recentMessages.add(message);
        }
      }

      // Sort by sent time and limit
      recentMessages.sort((a, b) => b.sentAt.compareTo(a.sentAt));
      return recentMessages.take(limit).toList();
    } catch (e) {
      return [];
    }
  }

  // Search messages
  Future<List<Message>> searchMessages({
    required String query,
    String? userId,
    String? crewId,
    String? conversationId,
    int limit = 50,
  }) async {
    try {
      final List<Message> results = [];

      // Search in crew messages
      if (crewId != null) {
        final snapshot = await crewsCollection
            .doc(crewId)
            .collection('messages')
            .where('content', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('content', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .limit(limit)
            .get();

        for (final doc in snapshot.docs) {
          results.add(Message.fromFirestore(doc));
        }
      }

      // Search in direct messages
      if (conversationId != null) {
        final snapshot = await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .where('content', isGreaterThanOrEqualTo: query.toLowerCase())
            .where('content', isLessThanOrEqualTo: '${query.toLowerCase()}\uf8ff')
            .limit(limit)
            .get();

        for (final doc in snapshot.docs) {
          results.add(Message.fromFirestore(doc));
        }
      }

      return results;
    } catch (e) {
      return [];
    }
  }

  // Helper method to get conversation ID
  String _getConversationId(String userId1, String userId2) {
    // Sort user IDs to ensure consistent conversation ID regardless of who sends first
    final sortedIds = [userId1, userId2]..sort();
    return '${sortedIds[0]}_${sortedIds[1]}';
  }

  // Create or update conversation metadata
  Future<void> _updateConversationMetadata({
    required String conversationId,
    required String senderId,
    required String recipientId,
    required Message message,
  }) async {
    try {
      final conversationData = {
        'participants': [senderId, recipientId],
        'lastMessage': {
          'senderId': senderId,
          'content': message.content,
          'sentAt': Timestamp.fromDate(message.sentAt),
          'type': message.type.toString().split('.').last,
        },
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      await messagesCollection.doc(conversationId).set(conversationData);
    } catch (e) {
      print('Error updating conversation metadata: $e');
    }
  }
}