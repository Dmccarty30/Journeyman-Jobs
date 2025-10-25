import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/message.dart';

/// Optimized Crew Message Service with Firestore real-time listeners
///
/// **Performance Optimizations:**
/// - Pagination with cursor-based queries (limit 50 messages per page)
/// - Composite indexes for efficient timestamp ordering
/// - Offline persistence enabled by default
/// - Batch writes for multiple operations
/// - Real-time listeners with proper cleanup
class CrewMessageService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Performance constants
  static const int defaultPageSize = 50;
  static const int maxPageSize = 100;

  // Collection references
  CollectionReference get crewsCollection => _firestore.collection('crews');

  /// Get crew messages subcollection reference
  CollectionReference _getCrewMessagesCollection(String crewId) {
    return crewsCollection.doc(crewId).collection('messages');
  }

  /// Send message to crew feed with optimistic UI support
  ///
  /// **Firestore Structure:**
  /// ```
  /// crews/{crewId}/messages/{messageId}
  ///   - senderId: string
  ///   - content: string
  ///   - type: string (text|image|voice|document|jobShare|systemNotification)
  ///   - sentAt: timestamp (indexed)
  ///   - status: string (sending|sent|delivered|read)
  ///   - attachments: array
  ///   - readBy: map<string, timestamp>
  ///   - isEdited: boolean
  /// ```
  Future<String> sendMessageToFeed({
    required String crewId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    try {
      final messagesRef = _getCrewMessagesCollection(crewId);
      final docRef = messagesRef.doc(); // Generate ID first for optimistic UI

      final message = Message(
        id: docRef.id,
        senderId: senderId,
        crewId: crewId,
        content: content,
        type: type,
        attachments: attachments,
        sentAt: DateTime.now(),
        readBy: {senderId: DateTime.now()}, // Sender has read
        status: MessageStatus.sending,
        isEdited: false,
      );

      await docRef.set(message.toFirestore());

      // Update last activity timestamp on crew
      await crewsCollection.doc(crewId).update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Message sent to crew feed: $crewId');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message to feed: $e');
      }
      rethrow;
    }
  }

  /// Get real-time stream of crew feed messages (paginated)
  ///
  /// **Composite Index Required:**
  /// ```
  /// Collection: crews/{crewId}/messages
  /// Fields: sentAt (descending), __name__ (descending)
  /// ```
  Stream<List<Message>> getCrewFeedMessages({
    required String crewId,
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
  }) {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    Query query = _getCrewMessagesCollection(crewId)
        .orderBy('sentAt', descending: true)
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Message.fromFirestore(doc);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing message ${doc.id}: $e');
          }
          rethrow;
        }
      }).toList();
    });
  }

  /// Send message to crew chat with optimistic UI support
  ///
  /// **Firestore Structure:**
  /// ```
  /// crews/{crewId}/chat/{messageId}
  ///   - Same structure as feed messages
  ///   - Optimized for real-time chat delivery
  /// ```
  Future<String> sendMessageToChat({
    required String crewId,
    required String senderId,
    required String content,
    MessageType type = MessageType.text,
    List<Attachment>? attachments,
  }) async {
    try {
      final chatRef = crewsCollection.doc(crewId).collection('chat');
      final docRef = chatRef.doc();

      final message = Message(
        id: docRef.id,
        senderId: senderId,
        crewId: crewId,
        content: content,
        type: type,
        attachments: attachments,
        sentAt: DateTime.now(),
        readBy: {senderId: DateTime.now()},
        status: MessageStatus.sending,
        isEdited: false,
      );

      await docRef.set(message.toFirestore());

      // Update last activity timestamp
      await crewsCollection.doc(crewId).update({
        'lastActivityAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Message sent to crew chat: $crewId');
      }

      return docRef.id;
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error sending message to chat: $e');
      }
      rethrow;
    }
  }

  /// Get real-time stream of crew chat messages (paginated)
  ///
  /// **Composite Index Required:**
  /// ```
  /// Collection: crews/{crewId}/chat
  /// Fields: sentAt (ascending), __name__ (ascending)
  /// ```
  Stream<List<Message>> getCrewChatMessages({
    required String crewId,
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
  }) {
    // Enforce pagination limits
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    Query query = crewsCollection
        .doc(crewId)
        .collection('chat')
        .orderBy('sentAt', descending: false) // Oldest first for chat
        .limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        try {
          return Message.fromFirestore(doc);
        } catch (e) {
          if (kDebugMode) {
            print('⚠️ Error parsing chat message ${doc.id}: $e');
          }
          rethrow;
        }
      }).toList();
    });
  }

  /// Mark message as read by user (optimized with field update)
  Future<void> markMessageAsRead({
    required String crewId,
    required String messageId,
    required String userId,
    bool isChatMessage = false,
  }) async {
    try {
      final collection = isChatMessage ? 'chat' : 'messages';
      final messageRef = crewsCollection
          .doc(crewId)
          .collection(collection)
          .doc(messageId);

      await messageRef.update({
        'readBy.$userId': FieldValue.serverTimestamp(),
        'readStatus.$userId': FieldValue.serverTimestamp(),
        'readByList': FieldValue.arrayUnion([userId]),
      });

      if (kDebugMode) {
        print('✅ Message marked as read: $messageId by $userId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error marking message as read: $e');
      }
      rethrow;
    }
  }

  /// Edit message content (with edited timestamp)
  Future<void> editMessage({
    required String crewId,
    required String messageId,
    required String newContent,
    required String userId,
    bool isChatMessage = false,
  }) async {
    try {
      final collection = isChatMessage ? 'chat' : 'messages';
      final messageRef = crewsCollection
          .doc(crewId)
          .collection(collection)
          .doc(messageId);

      // Verify user is the sender
      final doc = await messageRef.get();
      if (!doc.exists) {
        throw Exception('Message not found');
      }

      final message = Message.fromFirestore(doc);
      if (message.senderId != userId) {
        throw Exception('Only the sender can edit this message');
      }

      await messageRef.update({
        'content': newContent,
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('✅ Message edited: $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error editing message: $e');
      }
      rethrow;
    }
  }

  /// Delete message (soft delete by setting status)
  Future<void> deleteMessage({
    required String crewId,
    required String messageId,
    required String userId,
    bool isChatMessage = false,
  }) async {
    try {
      final collection = isChatMessage ? 'chat' : 'messages';
      final messageRef = crewsCollection
          .doc(crewId)
          .collection(collection)
          .doc(messageId);

      // Verify user is the sender or admin
      final doc = await messageRef.get();
      if (!doc.exists) {
        throw Exception('Message not found');
      }

      final message = Message.fromFirestore(doc);
      if (message.senderId != userId) {
        // TODO: Check if user is crew admin/foreman
        throw Exception('Only the sender can delete this message');
      }

      // Soft delete - update content and add deleted flag
      await messageRef.update({
        'content': '[Message deleted]',
        'status': 'deleted',
        'deletedAt': FieldValue.serverTimestamp(),
        'deletedBy': userId,
      });

      if (kDebugMode) {
        print('✅ Message deleted: $messageId');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error deleting message: $e');
      }
      rethrow;
    }
  }

  /// Batch mark multiple messages as read (performance optimization)
  Future<void> batchMarkMessagesAsRead({
    required String crewId,
    required List<String> messageIds,
    required String userId,
    bool isChatMessage = false,
  }) async {
    if (messageIds.isEmpty) return;

    try {
      final batch = _firestore.batch();
      final collection = isChatMessage ? 'chat' : 'messages';

      for (final messageId in messageIds) {
        final messageRef = crewsCollection
            .doc(crewId)
            .collection(collection)
            .doc(messageId);

        batch.update(messageRef, {
          'readBy.$userId': FieldValue.serverTimestamp(),
          'readStatus.$userId': FieldValue.serverTimestamp(),
          'readByList': FieldValue.arrayUnion([userId]),
        });
      }

      await batch.commit();

      if (kDebugMode) {
        print('✅ Batch marked ${messageIds.length} messages as read');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ Error batch marking messages as read: $e');
      }
      rethrow;
    }
  }

  /// Get unread message count for user in crew
  Future<int> getUnreadMessageCount({
    required String crewId,
    required String userId,
    bool isChatMessage = false,
  }) async {
    try {
      final collection = isChatMessage ? 'chat' : 'messages';
      final snapshot = await crewsCollection
          .doc(crewId)
          .collection(collection)
          .where('readByList', whereNotIn: [userId])
          .get();

      return snapshot.size;
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Error getting unread count: $e');
      }
      return 0;
    }
  }
}
