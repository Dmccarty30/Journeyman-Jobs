import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get Firestore collections
  CollectionReference get crewsCollection => _firestore.collection('crews');
  CollectionReference get messagesCollection => _firestore.collection('messages');

  // Get or create channels for a crew
  Future<List<Map<String, dynamic>>> getChannels(String crewId) async {
    try {
      final channelsSnapshot = await crewsCollection
          .doc(crewId)
          .collection('channels')
          .orderBy('createdAt', descending: true)
          .get();

      final channels = channelsSnapshot.docs.map((doc) => {
        'id': doc.id,
        ...doc.data(),
      }).toList();

      // If no channels exist, create a default 'general' channel
      if (channels.isEmpty) {
        final generalChannel = {
          'name': 'General',
          'description': 'General crew discussions',
          'isDefault': true,
          'createdAt': FieldValue.serverTimestamp(),
          'memberCount': 0,
        };

        final channelRef = crewsCollection.doc(crewId).collection('channels').doc('general');
        await channelRef.set(generalChannel);

        channels.add({
          'id': 'general',
          ...generalChannel,
        });
      }

      return channels;
    } catch (e) {
      throw Exception('Error getting channels: $e');
    }
  }

  // Create a new channel
  Future<String> createChannel({
    required String crewId,
    required String name,
    String? description,
  }) async {
    try {
      final channelId = name.toLowerCase().replaceAll(' ', '_');
      final channelData = {
        'name': name,
        'description': description ?? '',
        'createdAt': FieldValue.serverTimestamp(),
        'memberCount': 0,
        'isDefault': false,
      };

      await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .set(channelData);

      return channelId;
    } catch (e) {
      throw Exception('Error creating channel: $e');
    }
  }

  // Update message status when sent (delivered to server)
  Future<void> markAsSent(String messageId, {required String crewId, required String channelId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'status': 'sent',
        'deliveredAt': Timestamp.fromDate(currentTime),
      };

      await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error marking message as sent: $e');
    }
  }

  // Update when delivered to recipients
  Future<void> markAsDelivered(String messageId, String userId, {required String crewId, required String channelId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'status': 'delivered',
        'deliveredAt': Timestamp.fromDate(currentTime),
        'deliveredTo.$userId': Timestamp.fromDate(currentTime),
      };

      await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error marking message as delivered: $e');
    }
  }

  // Update when read by recipients
  Future<void> markAsRead(String messageId, String userId, {required String crewId, required String channelId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'readBy.$userId': Timestamp.fromDate(currentTime),
        'readStatus.$userId': Timestamp.fromDate(currentTime),
        'readByList': FieldValue.arrayUnion([userId]),
      };

      // If everyone has read the message, mark as read
      final crewDoc = await crewsCollection.doc(crewId).get();
      final crewData = crewDoc.data() as Map<String, dynamic>?;
      final memberIds = List<String>.from(crewData?['memberIds'] ?? []);

      final messageDoc = await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (messageDoc.exists) {
        final message = Message.fromFirestore(messageDoc);
        if (message.readByList.length >= memberIds.length - 1) { // -1 for sender
          updateData['status'] = 'read';
          updateData['readAt'] = Timestamp.fromDate(currentTime);
        }
      }

      await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .update(updateData);
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  // Stream message status updates
  Stream<MessageStatus> getMessageStatus(String messageId, {required String crewId, required String channelId}) {
    final snapshotStream = crewsCollection
        .doc(crewId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .doc(messageId)
        .snapshots();

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final statusString = data?['status'] as String? ?? 'sent';
        return MessageStatus.values.firstWhere(
          (s) => s.toString().split('.').last == statusString,
          orElse: () => MessageStatus.sent,
        );
      }
      return MessageStatus.sent;
    });
  }

  // Get real-time message delivery status
  Stream<Map<String, DateTime>> getMessageDeliveryStatus(String messageId, {required String crewId, required String channelId}) {
    final snapshotStream = crewsCollection
        .doc(crewId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .doc(messageId)
        .snapshots();

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final deliveredTo = <String, DateTime>{};
        
        if (data?['deliveredTo'] != null) {
          (data!['deliveredTo'] as Map<String, dynamic>).forEach((key, value) {
            if (value is Timestamp) {
              deliveredTo[key] = value.toDate();
            }
          });
        }
        
        return deliveredTo;
      }
      return <String, DateTime>{};
    });
  }

  // Get read receipts for a message
  Stream<Map<String, DateTime>> getReadReceipts(String messageId, {required String crewId, required String channelId}) {
    final snapshotStream = crewsCollection
        .doc(crewId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .doc(messageId)
        .snapshots();

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data();
        final readBy = <String, DateTime>{};
        
        if (data?['readBy'] != null) {
          (data!['readBy'] as Map<String, dynamic>).forEach((key, value) {
            if (value is Timestamp) {
              readBy[key] = value.toDate();
            }
          });
        }
        
        return readBy;
      }
      return <String, DateTime>{};
    });
  }

  // Batch update multiple messages as delivered (for performance)
  Future<void> batchDeliverMessages(List<String> messageIds, String userId, {required String crewId, required String channelId}) async {
    try {
      final currentTime = DateTime.now();
      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final updateData = {
          'status': 'delivered',
          'deliveredAt': Timestamp.fromDate(currentTime),
          'deliveredTo.$userId': Timestamp.fromDate(currentTime),
        };

        final ref = crewsCollection
            .doc(crewId)
            .collection('channels')
            .doc(channelId)
            .collection('messages')
            .doc(messageId);
        batch.update(ref, updateData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error batch updating message delivery: $e');
    }
  }

  // Batch update multiple messages as read (for performance)
  Future<void> batchReadMessages(List<String> messageIds, String userId, {required String crewId, required String channelId}) async {
    try {
      final currentTime = DateTime.now();
      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final updateData = {
          'readBy.$userId': Timestamp.fromDate(currentTime),
          'readStatus.$userId': Timestamp.fromDate(currentTime),
          'readByList': FieldValue.arrayUnion([userId]),
        };

        final ref = crewsCollection
            .doc(crewId)
            .collection('channels')
            .doc(channelId)
            .collection('messages')
            .doc(messageId);
        
        batch.update(ref, updateData);
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error batch updating message read status: $e');
    }
  }

  // Get pending message delivery statuses for a channel
  Stream<List<Message>> getPendingDeliveries(String userId, {required String crewId, required String channelId}) {
    final query = crewsCollection
        .doc(crewId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .where('deliveredTo.$userId', isNull: true)
        .where('senderId', isNotEqualTo: userId) // Don't mark own messages as delivered
        .orderBy('sentAt', descending: true)
        .limit(50);

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }

  // Get messages stream for a specific channel
  Stream<List<Message>> getChannelMessagesStream(String crewId, String channelId, {int limit = 50}) {
    return crewsCollection
        .doc(crewId)
        .collection('channels')
        .doc(channelId)
        .collection('messages')
        .orderBy('sentAt', descending: true)
        .limit(limit)
        .snapshots()
        .map((snapshot) => snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  // Send a message to a channel
  Future<String> sendMessageToChannel({
    required String crewId,
    required String channelId,
    required String senderId,
    required String content,
    List<Attachment> attachments = const [],
    MessageType type = MessageType.text,
  }) async {
    try {
      final messageId = _firestore.collection('temp_ids').doc().id; // Generate unique ID
      final message = Message(
        id: messageId,
        senderId: senderId,
        content: content,
        attachments: attachments.isEmpty ? null : attachments,
        type: type,
        isEdited: false,
        sentAt: DateTime.now(),
        status: MessageStatus.sending,
        deliveredTo: {},
        readBy: {},
        readByList: [],
      );

      await crewsCollection
          .doc(crewId)
          .collection('channels')
          .doc(channelId)
          .collection('messages')
          .doc(messageId)
          .set(message.toFirestore());

      // Mark as sent immediately
      await markAsSent(messageId, crewId: crewId, channelId: channelId);

      return messageId;
    } catch (e) {
      throw Exception('Error sending message: $e');
    }
  }
}
