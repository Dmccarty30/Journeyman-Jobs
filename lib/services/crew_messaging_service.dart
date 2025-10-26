import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/firestore_service.dart';
import 'package:journeyman_jobs/services/fcm_service.dart';
import 'package:journeyman_jobs/services/notification_service.dart';

/// Service for real-time crew messaging
///
/// This service handles all crew messaging operations including:
/// - Sending and receiving messages
/// - Real-time message streaming
/// - Message reactions and read status
/// - Push notifications
/// - Media handling
/// - Message history and search
class CrewMessagingService {
  static final CrewMessagingService _instance = CrewMessagingService._internal();
  factory CrewMessagingService() => _instance;
  CrewMessagingService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirestoreService _firestoreService = FirestoreService();
  final CollectionReference _messagesCollection =
      FirebaseFirestore.instance.collection('crewMessages');
  final CollectionReference _conversationsCollection =
      FirebaseFirestore.instance.collection('crewConversations');

  /// Send a message to a crew
  ///
  /// [crewId] - ID of the crew
  /// [sender] - User sending the message
  /// [content] - Message content
  /// [type] - Message type (default: text)
  /// [priority] - Message priority (default: normal)
  /// [mediaUrls] - Optional media URLs
  /// [metadata] - Optional metadata for different message types
  /// [replyToMessageId] - Optional reply-to message ID
  ///
  /// Returns the sent message
  Future<CrewMessage> sendMessage({
    required String crewId,
    required UserModel sender,
    required String content,
    CrewMessageType type = CrewMessageType.text,
    CrewMessagePriority priority = CrewMessagePriority.normal,
    List<String> mediaUrls = const [],
    Map<String, dynamic>? metadata,
    String? replyToMessageId,
  }) async {
    try {
      // Validate inputs
      if (crewId.isEmpty) {
        throw ArgumentError('Crew ID cannot be empty');
      }
      if (sender.uid.isEmpty) {
        throw ArgumentError('Sender ID cannot be empty');
      }
      if (content.trim().isEmpty && type != CrewMessageType.system) {
        throw ArgumentError('Message content cannot be empty');
      }

      // Get crew to verify sender is a member
      final crew = await _firestore.collection('crews').doc(crewId).get();
      if (!crew.exists) {
        throw Exception('Crew not found');
      }

      final crewData = crew.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(crewData['memberIds'] ?? []);
      if (!memberIds.contains(sender.uid)) {
        throw Exception('User is not a member of this crew');
      }

      // Create the message
      final now = Timestamp.now();
      final message = CrewMessage(
        id: '', // Will be set by Firestore
        crewId: crewId,
        senderId: sender.uid,
        senderName: sender.displayNameStr,
        senderAvatarUrl: sender.avatarUrl,
        content: content.trim(),
        type: type,
        priority: priority,
        createdAt: now,
        mediaUrls: mediaUrls,
        metadata: metadata,
        readStatus: [
          MessageReadStatus(userId: sender.uid, readAt: now.toDate(), isRead: true)
        ],
        replyToMessageId: replyToMessageId,
      );

      // Save to Firestore
      final docRef = await _messagesCollection.add(message.toFirestore());
      final savedMessage = message.copyWith(id: docRef.id);

      // Update conversation
      await _updateConversation(crewId, savedMessage);

      // Send push notifications to other members
      await _sendPushNotification(savedMessage, sender, memberIds);

      return savedMessage;
    } catch (e) {
      throw Exception('Failed to send message: $e');
    }
  }

  /// Send a system message (join/leave/invite notifications)
  Future<CrewMessage> sendSystemMessage({
    required String crewId,
    required String content,
    Map<String, dynamic>? metadata,
  }) async {
    try {
      final now = Timestamp.now();
      final message = CrewMessage(
        id: '', // Will be set by Firestore
        crewId: crewId,
        senderId: 'system',
        senderName: 'System',
        content: content,
        type: CrewMessageType.system,
        priority: CrewMessagePriority.normal,
        createdAt: now,
        readStatus: [], // System messages don't need read status
      );

      // Save to Firestore
      final docRef = await _messagesCollection.add(message.toFirestore());
      final savedMessage = message.copyWith(id: docRef.id);

      // Update conversation
      await _updateConversation(crewId, savedMessage);

      return savedMessage;
    } catch (e) {
      throw Exception('Failed to send system message: $e');
    }
  }

  /// Get messages for a crew (paginated)
  Future<List<CrewMessage>> getMessages({
    required String crewId,
    int limit = 50,
    CrewMessage? lastMessage,
  }) async {
    try {
      Query query = _messagesCollection
          .where('crewId', isEqualTo: crewId)
          .where('isDeleted', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(limit);

      if (lastMessage != null) {
        query = query.startAfterDocument(
            await _messagesCollection.doc(lastMessage.id).get());
      }

      final QuerySnapshot snapshot = await query.get();
      return snapshot.docs
          .map((doc) => CrewMessage.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to get messages: $e');
    }
  }

  /// Search messages in a crew
  Future<List<CrewMessage>> searchMessages({
    required String crewId,
    required String query,
    int limit = 20,
  }) async {
    try {
      if (query.trim().isEmpty) {
        return [];
      }

      // Note: This is a basic implementation. For production, consider using
      // Algolia or another search service for better performance
      final QuerySnapshot snapshot = await _messagesCollection
          .where('crewId', isEqualTo: crewId)
          .where('isDeleted', isEqualTo: false)
          .where('content', isGreaterThanOrEqualTo: query.trim())
          .where('content', isLessThanOrEqualTo: query.trim() + '\uf8ff')
          .orderBy('content')
          .orderBy('createdAt', descending: true)
          .limit(limit)
          .get();

      return snapshot.docs
          .map((doc) => CrewMessage.fromFirestore(doc))
          .toList();
    } catch (e) {
      throw Exception('Failed to search messages: $e');
    }
  }

  /// Mark message as read by user
  Future<bool> markMessageAsRead(String messageId, String userId) async {
    try {
      final messageRef = _messagesCollection.doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = CrewMessage.fromFirestore(messageDoc);
      if (message.isReadByUser(userId)) {
        return true; // Already marked as read
      }

      // Add read status
      await messageRef.update({
        'readStatus': FieldValue.arrayUnion([
          {
            'userId': userId,
            'readAt': Timestamp.now(),
            'isRead': true,
          }
        ])
      });

      // Update conversation unread count
      await _updateConversationUnreadCount(message.crewId, userId);

      return true;
    } catch (e) {
      throw Exception('Failed to mark message as read: $e');
    }
  }

  /// Mark all messages in crew as read by user
  Future<bool> markAllMessagesAsRead(String crewId, String userId) async {
    try {
      final QuerySnapshot snapshot = await _messagesCollection
          .where('crewId', isEqualTo: crewId)
          .where('isDeleted', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        final message = CrewMessage.fromFirestore(doc);
        if (!message.isReadByUser(userId)) {
          batch.update(doc.reference, {
            'readStatus': FieldValue.arrayUnion([
              {
                'userId': userId,
                'readAt': Timestamp.now(),
                'isRead': true,
              }
            ])
          });
        }
      }

      if (snapshot.docs.isNotEmpty) {
        await batch.commit();
      }

      // Reset conversation unread count
      await _updateConversationUnreadCount(crewId, userId, reset: true);

      return true;
    } catch (e) {
      throw Exception('Failed to mark all messages as read: $e');
    }
  }

  /// Add reaction to message
  Future<bool> addReaction(String messageId, String userId, String emoji) async {
    try {
      final messageRef = _messagesCollection.doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = CrewMessage.fromFirestore(messageDoc);
      final newReactions = Map<String, String>.from(message.reactions);
      newReactions[userId] = emoji;

      await messageRef.update({'reactions': newReactions});

      return true;
    } catch (e) {
      throw Exception('Failed to add reaction: $e');
    }
  }

  /// Remove reaction from message
  Future<bool> removeReaction(String messageId, String userId) async {
    try {
      final messageRef = _messagesCollection.doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = CrewMessage.fromFirestore(messageDoc);
      final newReactions = Map<String, String>.from(message.reactions);
      newReactions.remove(userId);

      await messageRef.update({'reactions': newReactions});

      return true;
    } catch (e) {
      throw Exception('Failed to remove reaction: $e');
    }
  }

  /// Edit a message (text only)
  Future<bool> editMessage(String messageId, String userId, String newContent) async {
    try {
      final messageRef = _messagesCollection.doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = CrewMessage.fromFirestore(messageDoc);

      // Validate ownership and type
      if (message.senderId != userId) {
        throw Exception('Only sender can edit message');
      }

      if (message.type != CrewMessageType.text) {
        throw Exception('Only text messages can be edited');
      }

      if (message.isDeleted) {
        throw Exception('Cannot edit deleted message');
      }

      // Update message
      await messageRef.update({
        'content': newContent.trim(),
        'editedAt': Timestamp.now(),
      });

      return true;
    } catch (e) {
      throw Exception('Failed to edit message: $e');
    }
  }

  /// Delete a message (soft delete)
  Future<bool> deleteMessage(String messageId, String userId) async {
    try {
      final messageRef = _messagesCollection.doc(messageId);
      final messageDoc = await messageRef.get();

      if (!messageDoc.exists) {
        throw Exception('Message not found');
      }

      final message = CrewMessage.fromFirestore(messageDoc);

      // Validate ownership
      if (message.senderId != userId) {
        throw Exception('Only sender can delete message');
      }

      if (message.isDeleted) {
        return true; // Already deleted
      }

      // Soft delete
      await messageRef.update({
        'isDeleted': true,
        'content': '[Message deleted]',
        'mediaUrls': [],
      });

      return true;
    } catch (e) {
      throw Exception('Failed to delete message: $e');
    }
  }

  /// Get conversations for a user
  Future<List<CrewConversation>> getConversationsForUser(String userId) async {
    try {
      // Get crews user is a member of
      final crewsSnapshot = await _firestore
          .collection('crews')
          .where('memberIds', arrayContains: userId)
          .get();

      final conversations = <CrewConversation>[];
      for (final crewDoc in crewsSnapshot.docs) {
        final crewData = crewDoc.data() as Map<String, dynamic>;
        final crewId = crewDoc.id;
        final crewName = crewData['name'] ?? 'Unknown Crew';

        // Get conversation data
        final conversationDoc = await _conversationsCollection.doc(crewId).get();
        CrewConversation conversation;

        if (conversationDoc.exists) {
          conversation = CrewConversation.fromFirestore(conversationDoc);
        } else {
          // Create conversation if it doesn't exist
          conversation = CrewConversation(
            crewId: crewId,
            crewName: crewName,
            lastActivity: Timestamp.now(),
            memberIds: List<String>.from(crewData['memberIds'] ?? []),
          );
          await _conversationsCollection.doc(crewId).set(conversation.toFirestore());
        }

        // Calculate unread count for this user
        conversation = await _calculateUnreadCount(conversation, userId);
        conversations.add(conversation);
      }

      // Sort by last activity
      conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      return conversations;
    } catch (e) {
      throw Exception('Failed to get conversations: $e');
    }
  }

  /// Stream of messages for a crew (real-time)
  Stream<List<CrewMessage>> streamMessages(String crewId) {
    return _messagesCollection
        .where('crewId', isEqualTo: crewId)
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => CrewMessage.fromFirestore(doc))
            .toList());
  }

  /// Stream of conversations for a user (real-time)
  Stream<List<CrewConversation>> streamConversationsForUser(String userId) {
    return _firestore
        .collection('crews')
        .where('memberIds', arrayContains: userId)
        .snapshots()
        .asyncMap((crewsSnapshot) async {
      final conversations = <CrewConversation>[];

      for (final crewDoc in crewsSnapshot.docs) {
        final crewData = crewDoc.data() as Map<String, dynamic>;
        final crewId = crewDoc.id;
        final crewName = crewData['name'] ?? 'Unknown Crew';

        // Get conversation data
        final conversationDoc = await _conversationsCollection.doc(crewId).get();
        CrewConversation conversation;

        if (conversationDoc.exists) {
          conversation = CrewConversation.fromFirestore(conversationDoc);
        } else {
          conversation = CrewConversation(
            crewId: crewId,
            crewName: crewName,
            lastActivity: Timestamp.now(),
            memberIds: List<String>.from(crewData['memberIds'] ?? []),
          );
        }

        // Calculate unread count
        conversation = await _calculateUnreadCount(conversation, userId);
        conversations.add(conversation);
      }

      // Sort by last activity
      conversations.sort((a, b) => b.lastActivity.compareTo(a.lastActivity));
      return conversations;
    });
  }

  /// Stream of unread count for a crew
  Stream<int> streamUnreadCount(String crewId, String userId) {
    return _messagesCollection
        .where('crewId', isEqualTo: crewId)
        .where('isDeleted', isEqualTo: false)
        .where('senderId', isNotEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      int count = 0;
      for (final doc in snapshot.docs) {
        final message = CrewMessage.fromFirestore(doc);
        if (!message.isReadByUser(userId)) {
          count++;
        }
      }
      return count;
    });
  }

  /// Private method to update conversation
  Future<void> _updateConversation(String crewId, CrewMessage message) async {
    try {
      final conversationRef = _conversationsCollection.doc(crewId);
      final conversationDoc = await conversationRef.get();

      if (conversationDoc.exists) {
        await conversationRef.update({
          'lastMessage': message.toFirestore(),
          'lastActivity': message.createdAt,
        });
      } else {
        // Get crew name for new conversation
        final crewDoc = await _firestore.collection('crews').doc(crewId).get();
        final crewName = crewDoc.exists
            ? (crewDoc.data() as Map<String, dynamic>)['name'] ?? 'Unknown Crew'
            : 'Unknown Crew';

        final conversation = CrewConversation(
          crewId: crewId,
          crewName: crewName,
          lastMessage: message,
          lastActivity: message.createdAt,
          memberIds: [], // Will be populated when fetching conversations
        );

        await conversationRef.set(conversation.toFirestore());
      }
    } catch (e) {
      // Log error but don't fail the message send
      print('Failed to update conversation: $e');
    }
  }

  /// Private method to send push notification
  Future<void> _sendPushNotification(
    CrewMessage message,
    UserModel sender,
    List<String> memberIds,
  ) async {
    try {
      // Don't send notifications for system messages or self messages
      if (message.type == CrewMessageType.system) return;

      for (final memberId in memberIds) {
        if (memberId == sender.uid) continue; // Don't notify sender

        // Get member's FCM token
        final userDoc = await _firestore.collection('users').doc(memberId).get();
        if (!userDoc.exists) continue;

        final userData = userDoc.data() as Map<String, dynamic>;
        final fcmToken = userData['fcmToken'] as String?;

        if (fcmToken == null || fcmToken.isEmpty) continue;

        // Prepare notification
        String title = 'New message from ${sender.displayNameStr}';
        String body = message.content;

        // Customize for different message types
        switch (message.type) {
          case CrewMessageType.image:
            body = '📷 Photo';
            break;
          case CrewMessageType.voiceNote:
            body = '🎤 Voice message';
            break;
          case CrewMessageType.location:
            body = '📍 Location shared';
            break;
          case CrewMessageType.jobShare:
            body = '💼 Job shared';
            break;
          case CrewMessageType.alert:
            title = '⚠️ Crew Alert';
            if (message.isUrgent) {
              title = '🚨 URGENT: Crew Alert';
            }
            break;
          default:
            // Truncate long messages
            if (body.length > 100) {
              body = '${body.substring(0, 97)}...';
            }
        }

        await NotificationService.sendPushNotification(
          recipientId: memberId,
          title: title,
          body: body,
          data: {
            'type': 'crew_message',
            'crewId': message.crewId,
            'messageId': message.id,
            'senderId': message.senderId,
            'messageType': message.type.toString().split('.').last,
          },
        );
      }
    } catch (e) {
      // Log error but don't fail the message send
      print('Failed to send push notifications: $e');
    }
  }

  /// Private method to calculate unread count for a conversation
  Future<CrewConversation> _calculateUnreadCount(
    CrewConversation conversation,
    String userId,
  ) async {
    try {
      final QuerySnapshot snapshot = await _messagesCollection
          .where('crewId', isEqualTo: conversation.crewId)
          .where('isDeleted', isEqualTo: false)
          .where('senderId', isNotEqualTo: userId)
          .get();

      int unreadCount = 0;
      for (final doc in snapshot.docs) {
        final message = CrewMessage.fromFirestore(doc);
        if (!message.isReadByUser(userId)) {
          unreadCount++;
        }
      }

      return conversation.copyWith(unreadCount: unreadCount);
    } catch (e) {
      // Return original conversation if calculation fails
      return conversation;
    }
  }

  /// Private method to update conversation unread count
  Future<void> _updateConversationUnreadCount(
    String crewId,
    String userId, {
    bool reset = false,
  }) async {
    try {
      final conversationRef = _conversationsCollection.doc(crewId);
      final conversationDoc = await conversationRef.get();

      if (!conversationDoc.exists) return;

      int newUnreadCount = 0;
      if (!reset) {
        final snapshot = await _messagesCollection
            .where('crewId', isEqualTo: crewId)
            .where('isDeleted', isEqualTo: false)
            .where('senderId', isNotEqualTo: userId)
            .get();

        for (final doc in snapshot.docs) {
          final message = CrewMessage.fromFirestore(doc);
          if (!message.isReadByUser(userId)) {
            newUnreadCount++;
          }
        }
      }

      await conversationRef.update({'unreadCount': newUnreadCount});
    } catch (e) {
      // Log error but don't fail the operation
      print('Failed to update conversation unread count: $e');
    }
  }
}