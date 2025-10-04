import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/features/crews/models/message.dart';

class ChatService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  
  // Get Firestore collections
  CollectionReference get crewsCollection => _firestore.collection('crews');
  CollectionReference get messagesCollection => _firestore.collection('messages');

  // Update message status when sent (delivered to server)
  Future<void> markAsSent(String messageId, {bool isCrewMessage = false, String? crewId, String? conversationId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'status': 'sent',
        'deliveredAt': Timestamp.fromDate(currentTime),
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
      throw Exception('Error marking message as sent: $e');
    }
  }

  // Update when delivered to recipients
  Future<void> markAsDelivered(String messageId, String userId, {bool isCrewMessage = false, String? crewId, String? conversationId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'status': 'delivered',
        'deliveredAt': Timestamp.fromDate(currentTime),
        'deliveredTo.$userId': Timestamp.fromDate(currentTime),
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
      throw Exception('Error marking message as delivered: $e');
    }
  }

  // Update when read by recipients
  Future<void> markAsRead(String messageId, String userId, {bool isCrewMessage = false, String? crewId, String? conversationId}) async {
    try {
      final currentTime = DateTime.now();
      final updateData = {
        'readBy.$userId': Timestamp.fromDate(currentTime),
        'readStatus.$userId': Timestamp.fromDate(currentTime),
        'readByList': FieldValue.arrayUnion([userId]),
      };

      // If everyone has read the message, mark as read
      if (isCrewMessage && crewId != null) {
        final crewDoc = await crewsCollection.doc(crewId).get();
        final crewData = crewDoc.data() as Map<String, dynamic>?;
        final memberIds = List<String>.from(crewData?['memberIds'] ?? []);

        final messageDoc = await crewsCollection
            .doc(crewId)
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
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      } else if (conversationId != null) {
        // For direct messages, mark as read when the recipient reads it
        updateData['status'] = 'read';
        updateData['readAt'] = Timestamp.fromDate(currentTime);

        await messagesCollection
            .doc(conversationId)
            .collection('messages')
            .doc(messageId)
            .update(updateData);
      }
    } catch (e) {
      throw Exception('Error marking message as read: $e');
    }
  }

  // Stream message status updates
  Stream<MessageStatus> getMessageStatus(String messageId, {bool isCrewMessage = false, String? crewId, String? conversationId}) {
    Stream<DocumentSnapshot> snapshotStream;
    
    if (isCrewMessage && crewId != null) {
      snapshotStream = crewsCollection
          .doc(crewId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else if (conversationId != null) {
      snapshotStream = messagesCollection
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else {
      return Stream.error('Invalid message location parameters');
    }

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
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
  Stream<Map<String, DateTime>> getMessageDeliveryStatus(String messageId, {bool isCrewMessage = false, String? crewId, String? conversationId}) {
    Stream<DocumentSnapshot> snapshotStream;
    
    if (isCrewMessage && crewId != null) {
      snapshotStream = crewsCollection
          .doc(crewId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else if (conversationId != null) {
      snapshotStream = messagesCollection
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else {
      return Stream.error('Invalid message location parameters');
    }

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
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
  Stream<Map<String, DateTime>> getReadReceipts(String messageId, {bool isCrewMessage = false, String? crewId, String? conversationId}) {
    Stream<DocumentSnapshot> snapshotStream;
    
    if (isCrewMessage && crewId != null) {
      snapshotStream = crewsCollection
          .doc(crewId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else if (conversationId != null) {
      snapshotStream = messagesCollection
          .doc(conversationId)
          .collection('messages')
          .doc(messageId)
          .snapshots();
    } else {
      return Stream.error('Invalid message location parameters');
    }

    return snapshotStream.map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>?;
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
  Future<void> batchDeliverMessages(List<String> messageIds, String userId, {bool isCrewMessage = false, String? crewId, String? conversationId}) async {
    try {
      final currentTime = DateTime.now();
      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final updateData = {
          'status': 'delivered',
          'deliveredAt': Timestamp.fromDate(currentTime),
          'deliveredTo.$userId': Timestamp.fromDate(currentTime),
        };

        if (isCrewMessage && crewId != null) {
          final ref = crewsCollection
              .doc(crewId)
              .collection('messages')
              .doc(messageId);
          batch.update(ref, updateData);
        } else if (conversationId != null) {
          final ref = messagesCollection
              .doc(conversationId)
              .collection('messages')
              .doc(messageId);
          batch.update(ref, updateData);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error batch updating message delivery: $e');
    }
  }

  // Batch update multiple messages as read (for performance)
  Future<void> batchReadMessages(List<String> messageIds, String userId, {bool isCrewMessage = false, String? crewId, String? conversationId}) async {
    try {
      final currentTime = DateTime.now();
      final batch = _firestore.batch();

      for (final messageId in messageIds) {
        final updateData = {
          'readBy.$userId': Timestamp.fromDate(currentTime),
          'readStatus.$userId': Timestamp.fromDate(currentTime),
          'readByList': FieldValue.arrayUnion([userId]),
        };

        if (isCrewMessage && crewId != null) {
          final ref = crewsCollection
              .doc(crewId)
              .collection('messages')
              .doc(messageId);
          batch.update(ref, updateData);
        } else if (conversationId != null) {
          final ref = messagesCollection
              .doc(conversationId)
              .collection('messages')
              .doc(messageId);
          
          // For direct messages, mark as read immediately
          updateData['status'] = 'read';
          updateData['readAt'] = Timestamp.fromDate(currentTime);
          
          batch.update(ref, updateData);
        }
      }

      await batch.commit();
    } catch (e) {
      throw Exception('Error batch updating message read status: $e');
    }
  }

  // Get pending message delivery statuses
  Stream<List<Message>> getPendingDeliveries(String userId, {bool isCrewMessage = false, String? crewId, String? conversationId}) {
    Query query;
    
    if (isCrewMessage && crewId != null) {
      query = crewsCollection
          .doc(crewId)
          .collection('messages')
          .where('deliveredTo.$userId', isNull: true)
          .where('senderId', isNotEqualTo: userId) // Don't mark own messages as delivered
          .orderBy('sentAt', descending: true)
          .limit(50);
    } else if (conversationId != null) {
      query = messagesCollection
          .doc(conversationId)
          .collection('messages')
          .where('deliveredTo.$userId', isNull: true)
          .where('senderId', isNotEqualTo: userId) // Don't mark own messages as delivered
          .orderBy('sentAt', descending: true)
          .limit(50);
    } else {
      return Stream.error('Invalid message location parameters');
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => Message.fromFirestore(doc)).toList();
    });
  }
}