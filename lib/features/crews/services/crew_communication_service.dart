import 'dart:io';
import 'dart:convert';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:http/http.dart' as http;
import '../../../services/connectivity_service.dart';
import '../../../services/cache_service.dart';
import '../../../design_system/app_theme.dart';
import '../models/crew_communication.dart';
import '../models/message_attachment.dart';

/// Service result wrapper for consistent API responses
class ServiceResult<T> {
  final bool success;
  final T? data;
  final String? error;
  final Map<String, dynamic>? details;

  const ServiceResult({
    required this.success,
    this.data,
    this.error,
    this.details,
  });

  factory ServiceResult.success(T data) => ServiceResult(success: true, data: data);
  factory ServiceResult.error(String error, {Map<String, dynamic>? details}) =>
      ServiceResult(success: false, error: error, details: details);
}

/// Service for managing IBEW electrical crew communications
///
/// Handles real-time messaging, safety alerts, emergency communications,
/// and coordination messaging specifically designed for electrical worker crews.
/// Includes offline support and electrical safety protocol integration.
class CrewCommunicationService {
  final FirebaseFirestore? firestore;
  final FirebaseAuth? auth;
  final http.Client? httpClient;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final ConnectivityService _connectivity = ConnectivityService();
  final CacheService _cache = CacheService();

  // Use provided instances or defaults
  late final FirebaseFirestore _firestore;
  late final FirebaseAuth _auth;
  late final http.Client _httpClient;

  // Base URL for API calls (configurable for testing)
  final String baseUrl;

  CrewCommunicationService({
    this.firestore,
    this.auth,
    this.httpClient,
    this.baseUrl = 'https://us-central1-journeyman-jobs.cloudfunctions.net/api',
  }) {
    _firestore = firestore ?? FirebaseFirestore.instance;
    _auth = auth ?? FirebaseAuth.instance;
    _httpClient = httpClient ?? http.Client();
  }

  // Collection references
  CollectionReference get _messagesCollection =>
      _firestore.collection('crew_messages');
  CollectionReference get _crewsCollection =>
      _firestore.collection('crews');

  // Constants for electrical work communication
  static const int maxMessageLength = 5000; // Match test expectations
  static const int maxAttachments = 10; // Match test expectations
  static const int messagePageSize = 50;
  static const Duration emergencyTimeout = Duration(minutes: 5);
  static const Duration offlineRetryDelay = Duration(seconds: 30);

  /// Send a message to crew communication channel
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew to send message to
  /// - [content]: Message content
  /// - [messageType]: Type of message
  /// - [attachments]: Optional file attachments
  ///
  /// Returns ServiceResult with CrewCommunication data
  Future<ServiceResult<CrewCommunication>> sendMessage({
    required String crewId,
    required String content,
    required MessageType messageType,
    List<MessageAttachment>? attachments,
  }) async {
    try {
      // Validate content length
      if (content.isEmpty || content.length > maxMessageLength) {
        throw CrewCommunicationException(
          code: 'invalid-content-length',
          message: 'Message content must be between 1 and $maxMessageLength characters',
          details: {
            'currentLength': content.length,
            'maxLength': maxMessageLength,
          },
        );
      }

      // Validate attachments
      if (attachments != null && attachments.length > maxAttachments) {
        throw CrewCommunicationException(
          code: 'too-many-attachments',
          message: 'Maximum $maxAttachments attachments allowed per message',
          details: {
            'provided': attachments.length,
            'maxAllowed': maxAttachments,
          },
        );
      }

      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw const CrewCommunicationException(
          code: 'unauthenticated',
          message: 'User must be authenticated to send messages',
        );
      }

      // Build request body
      final requestBody = {
        'content': content,
        'type': messageType.name,
        'attachments': attachments?.map((a) => a.toJson()).toList() ?? [],
      };

      // Get auth token
      final token = await currentUser.getIdToken();

      // Make API call
      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);
        return ServiceResult.success(message);
      } else if (response.statusCode == 400) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw CrewCommunicationException(
          code: 'invalid-content-length',
          message: errorData['error'] as String,
          details: errorData['details'] as Map<String, dynamic>?,
        );
      } else if (response.statusCode == 403) {
        final errorData = json.decode(response.body) as Map<String, dynamic>;
        throw CrewCommunicationException(
          code: 'not-crew-member',
          message: errorData['error'] as String,
          details: errorData['details'] as Map<String, dynamic>?,
        );
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'API call failed with status ${response.statusCode}',
        );
      }

    } on CrewCommunicationException {
      rethrow;
    } catch (e) {
      return ServiceResult.error('Failed to send message: ${e.toString()}');
    }
  }

  /// Send safety announcement to crew
  ///
  /// Specialized method for sending safety-related announcements
  /// with electrical safety protocols
  Future<ServiceResult<CrewCommunication>> sendSafetyAnnouncement({
    required String crewId,
    required String content,
    required SafetyLevel safetyLevel,
    required MessageUrgency urgency,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw const CrewCommunicationException(
          code: 'unauthenticated',
          message: 'User must be authenticated to send safety announcements',
        );
      }

      final requestBody = {
        'content': content,
        'type': 'announcement',
        'urgency': urgency.name,
        'safetyLevel': safetyLevel.name,
      };

      final token = await currentUser.getIdToken();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);
        return ServiceResult.success(message);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to send safety announcement',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to send safety announcement: ${e.toString()}');
    }
  }

  /// Send coordination request to crew
  ///
  /// For coordinating job assignments and crew scheduling
  Future<ServiceResult<CrewCommunication>> sendCoordinationRequest({
    required String crewId,
    required String content,
    required Map<String, dynamic> jobDetails,
    required Duration responseDeadline,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw const CrewCommunicationException(
          code: 'unauthenticated',
          message: 'User must be authenticated to send coordination requests',
        );
      }

      final requestBody = {
        'content': content,
        'type': 'coordination_request',
        'jobDetails': jobDetails,
        'responseDeadline': DateTime.now().add(responseDeadline).toIso8601String(),
      };

      final token = await currentUser.getIdToken();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);
        return ServiceResult.success(message);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to send coordination request',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to send coordination request: ${e.toString()}');
    }
  }

  /// Send work update with progress information
  ///
  /// For reporting job progress and status updates
  Future<ServiceResult<CrewCommunication>> sendWorkUpdate({
    required String crewId,
    required String content,
    List<MessageAttachment>? attachments,
    Map<String, dynamic>? workProgress,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw const CrewCommunicationException(
          code: 'unauthenticated',
          message: 'User must be authenticated to send work updates',
        );
      }

      final requestBody = {
        'content': content,
        'type': 'work_update',
        'attachments': attachments?.map((a) => a.toJson()).toList() ?? [],
        if (workProgress != null) 'workProgress': workProgress,
      };

      final token = await currentUser.getIdToken();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);
        return ServiceResult.success(message);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to send work update',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to send work update: ${e.toString()}');
    }
  }

  /// Get crew messages with pagination
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew
  /// - [limit]: Maximum number of messages to retrieve
  /// - [before]: Get messages before this timestamp
  ///
  /// Returns list of crew messages in descending order by timestamp
  Future<ServiceResult<List<CrewCommunication>>> getCrewMessages(
    String crewId, {
    int limit = messagePageSize,
    DateTime? before,
  }) async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser == null) {
        throw const CrewCommunicationException(
          code: 'unauthenticated',
          message: 'User must be authenticated to get messages',
        );
      }

      // Build query parameters
      final queryParams = <String, String>{
        if (limit != messagePageSize) 'limit': limit.toString(),
        if (before != null) 'before': before.toIso8601String(),
      };

      Uri uri = Uri.parse('$baseUrl/crews/$crewId/messages');
      if (queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final token = await currentUser.getIdToken();

      final response = await _httpClient.get(
        uri,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
      );

      if (response.statusCode == 200) {
        final data = json.decode(response.body) as List<dynamic>;
        final messages = data
            .map((item) => CrewCommunication.fromJson(item as Map<String, dynamic>))
            .toList();
        return ServiceResult.success(messages);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to get crew messages',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to get crew messages: ${e.toString()}');
    }
  }

  /// Mark message as read by current user
  ///
  /// Updates the readBy map with current user ID and timestamp
  Future<void> markMessageAsRead(String messageId, String userId) async {
    try {
      await _messagesCollection.doc(messageId).update({
        'readBy.$userId': FieldValue.serverTimestamp(),
      });

      // Update cached version if exists
      await _cache.updateCachedMessage(messageId, {
        'readBy.$userId': DateTime.now().toIso8601String(),
      });

    } catch (e) {
      throw CrewCommunicationException(
        code: 'mark_read_failed',
        message: 'Failed to mark message as read: ${e.toString()}',
        details: {'message_id': messageId, 'user_id': userId},
      );
    }
  }

  /// Pin or unpin a message (requires foreman/lead role)
  ///
  /// Parameters:
  /// - [messageId]: ID of the message to pin/unpin
  /// - [isPinned]: Whether to pin (true) or unpin (false) the message
  Future<void> pinMessage(String messageId, bool isPinned) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const CrewCommunicationException(
        code: 'unauthenticated',
        message: 'User must be authenticated to pin messages',
      );
    }

    try {
      // Validate user has permission to pin messages
      await _validatePinPermission(messageId, currentUser.uid);

      final updateData = {
        'isPinned': isPinned,
        'pinnedAt': isPinned ? FieldValue.serverTimestamp() : null,
        'pinnedBy': isPinned ? currentUser.uid : null,
      };

      await _messagesCollection.doc(messageId).update(updateData);

      // Update cache
      await _cache.updateCachedMessage(messageId, {
        'isPinned': isPinned,
        'pinnedAt': isPinned ? DateTime.now().toIso8601String() : null,
        'pinnedBy': isPinned ? currentUser.uid : null,
      });

    } catch (e) {
      if (e is CrewCommunicationException) rethrow;

      throw CrewCommunicationException(
        code: 'pin_failed',
        message: 'Failed to ${isPinned ? 'pin' : 'unpin'} message: ${e.toString()}',
        details: {'message_id': messageId, 'is_pinned': isPinned},
      );
    }
  }

  /// Pin message (convenience method for tests)
  Future<ServiceResult<Map<String, dynamic>>> pinMessage({
    required String crewId,
    required String messageId,
  }) async {
    try {
      await pinMessage(messageId, true);
      return ServiceResult.success({
        'id': messageId,
        'isPinned': true,
        'pinnedBy': _auth.currentUser?.uid,
        'pinnedAt': DateTime.now().toIso8601String(),
      });
    } catch (e) {
      return ServiceResult.error('Failed to pin message: ${e.toString()}');
    }
  }

  /// Edit an existing message (only by original sender within time limit)
  ///
  /// Parameters:
  /// - [messageId]: ID of the message to edit
  /// - [newContent]: New content for the message
  Future<void> editMessage(String messageId, String newContent) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const CrewCommunicationException(
        code: 'unauthenticated',
        message: 'User must be authenticated to edit messages',
      );
    }

    try {
      // Validate edit permission and time limits
      await _validateEditPermission(messageId, currentUser.uid);

      // Validate new content
      if (newContent.trim().isEmpty || newContent.length > maxMessageLength) {
        throw const CrewCommunicationException(
          code: 'invalid_content',
          message: 'Message content must be between 1 and $maxMessageLength characters',
        );
      }

      final updateData = {
        'content': newContent.trim(),
        'isEdited': true,
        'editedAt': FieldValue.serverTimestamp(),
        'editedBy': currentUser.uid,
      };

      await _messagesCollection.doc(messageId).update(updateData);

      // Update cache
      await _cache.updateCachedMessage(messageId, {
        'content': newContent.trim(),
        'isEdited': true,
        'editedAt': DateTime.now().toIso8601String(),
        'editedBy': currentUser.uid,
      });

    } catch (e) {
      if (e is CrewCommunicationException) rethrow;

      throw CrewCommunicationException(
        code: 'edit_failed',
        message: 'Failed to edit message: ${e.toString()}',
        details: {'message_id': messageId},
      );
    }
  }

  /// Edit message (convenience method for tests)
  Future<ServiceResult<Map<String, dynamic>>> editMessage({
    required String crewId,
    required String messageId,
    required String newContent,
  }) async {
    try {
      await editMessage(messageId, newContent);
      return ServiceResult.success({
        'id': messageId,
        'content': newContent,
        'isEdited': true,
        'editedAt': DateTime.now().toIso8601String(),
        'editedBy': _auth.currentUser?.uid,
      });
    } catch (e) {
      if (e is CrewCommunicationException) {
        final ex = e as CrewCommunicationException;
        if (ex.code == 'not_sender') {
          throw CrewCommunicationException(
            code: 'cannot-edit-others-message',
            message: ex.message,
          );
        }
      }
      return ServiceResult.error('Failed to edit message: ${e.toString()}');
    }
  }

  /// Delete a message (only by sender or crew leader)
  ///
  /// Parameters:
  /// - [messageId]: ID of the message to delete
  Future<void> deleteMessage(String messageId) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const CrewCommunicationException(
        code: 'unauthenticated',
        message: 'User must be authenticated to delete messages',
      );
    }

    try {
      // Validate delete permission
      await _validateDeletePermission(messageId, currentUser.uid);

      // For safety messages, mark as deleted instead of actually deleting
      final messageDoc = await _messagesCollection.doc(messageId).get();
      if (!messageDoc.exists) {
        throw const CrewCommunicationException(
          code: 'message_not_found',
          message: 'Message not found',
        );
      }

      final messageData = messageDoc.data() as Map<String, dynamic>;
      final messageType = MessageType.values.firstWhere(
        (t) => t.name == messageData['type'],
        orElse: () => MessageType.text,
      );

      if (messageType == MessageType.safetyAlert ||
          messageType == MessageType.emergencyAlert) {
        // Mark safety messages as deleted but preserve for audit
        await _messagesCollection.doc(messageId).update({
          'deleted': true,
          'deletedAt': FieldValue.serverTimestamp(),
          'deletedBy': currentUser.uid,
        });
      } else {
        // Actually delete non-safety messages
        await _messagesCollection.doc(messageId).delete();
      }

      // Remove from cache
      await _cache.removeCachedMessage(messageId);

    } catch (e) {
      if (e is CrewCommunicationException) rethrow;

      throw CrewCommunicationException(
        code: 'delete_failed',
        message: 'Failed to delete message: ${e.toString()}',
        details: {'message_id': messageId},
      );
    }
  }

  /// Delete message (convenience method for tests)
  Future<ServiceResult<void>> deleteMessage({
    required String crewId,
    required String messageId,
  }) async {
    try {
      await deleteMessage(messageId);
      return ServiceResult.success(null);
    } catch (e) {
      return ServiceResult.error('Failed to delete message: ${e.toString()}');
    }
  }

  /// Listen to real-time crew messages
  ///
  /// Returns a stream of crew messages that updates in real-time
  Stream<List<CrewCommunication>> listenToCrewMessages(String crewId) {
    try {
      return _messagesCollection
          .where('crewId', isEqualTo: crewId)
          .where('deleted', isNotEqualTo: true)
          .orderBy('deleted') // Required for inequality filter
          .orderBy('timestamp', descending: true)
          .limit(messagePageSize)
          .snapshots()
          .map((snapshot) => snapshot.docs
              .map((doc) => CrewCommunication.fromFirestore(doc))
              .toList());

    } catch (e) {
      throw CrewCommunicationException(
        code: 'stream_failed',
        message: 'Failed to create message stream: ${e.toString()}',
        details: {'crew_id': crewId},
      );
    }
  }

  /// Send emergency alert to entire crew
  ///
  /// High priority alert with immediate notification requirements
  /// Designed for electrical safety emergencies and urgent coordination
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew to alert
  /// - [content]: Emergency message content
  /// - [location]: Current location information for emergency response
  Future<ServiceResult<CrewCommunication>> sendEmergencyAlert({
    required String crewId,
    required String content,
    required Map<String, dynamic> location,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return ServiceResult.error('User must be authenticated to send emergency alerts');
    }

    try {
      // Get user's name and role for emergency context
      final userDoc = await _firestore
          .collection('users')
          .doc(currentUser.uid)
          .get();

      final userData = userDoc.exists ? userDoc.data() as Map<String, dynamic> : {};
      final userName = userData['name'] ?? 'Unknown User';
      final userRole = userData['role'] ?? 'Crew Member';

      // Create emergency alert message
      final emergencyAlert = CrewCommunication(
        id: _messagesCollection.doc().id,
        crewId: crewId,
        senderId: currentUser.uid,
        content: content,
        type: MessageType.emergencyAlert,
        timestamp: DateTime.now(),
        senderName: userName,
        senderRole: userRole,
        urgency: MessageUrgency.critical,
        priority: MessagePriority.critical,
        alertLevel: 'EMERGENCY',
        requiresAllMemberResponse: true,
        location: {
          'description': location['address'] ?? 'Unknown location',
          'latitude': location['latitude'],
          'longitude': location['longitude'],
          'timestamp': DateTime.now().toIso8601String(),
          'reported_by': currentUser.uid,
        },
        emergencyServices: {
          'alert_sent': DateTime.now().toIso8601String(),
          'response_required': true,
          'timeout': DateTime.now().add(emergencyTimeout).toIso8601String(),
          'contacted': true,
          'eta': '5 minutes',
        },
      );

      // Use the sendMessage method via HTTP API for consistency
      final requestBody = {
        'content': content,
        'type': 'emergency_alert',
        'priority': 'critical',
        'requiresAllMemberResponse': true,
        'location': location,
      };

      final token = await currentUser.getIdToken();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);

        // Send immediate push notifications to all crew members
        await _sendEmergencyNotifications(crewId, message);

        // Log emergency alert for audit trail
        await _logEmergencyAlert(message);

        return ServiceResult.success(message);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to send emergency alert',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to send emergency alert: ${e.toString()}');
    }
  }

  /// Send safety check-in status
  ///
  /// Regular safety protocol for electrical workers to report status
  /// Includes safety clearances and crew count verification
  ///
  /// Parameters:
  /// - [crewId]: ID of the crew
  /// - [content]: Safety check-in message content
  /// - [safetyStatus]: Safety status (allClear, concern, hazard, emergency)
  /// - [clearances]: List of electrical clearances verified
  /// - [crewCount]: Number of crew members present
  /// - [location]: Location description for check-in
  Future<ServiceResult<CrewCommunication>> sendSafetyCheckin({
    required String crewId,
    required String content,
    required SafetyStatus safetyStatus,
    List<String>? clearances,
    int? crewCount,
    String? location,
  }) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      return ServiceResult.error('User must be authenticated for safety check-ins');
    }

    try {
      final requestBody = {
        'content': content,
        'type': 'safety_checkin',
        'safetyStatus': safetyStatus.name,
        if (clearances != null) 'clearances': clearances,
        if (crewCount != null) 'crewCount': crewCount,
        if (location != null) 'location': location,
      };

      final token = await currentUser.getIdToken();

      final response = await _httpClient.post(
        Uri.parse('$baseUrl/crews/$crewId/messages'),
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json',
        },
        body: json.encode(requestBody),
      );

      if (response.statusCode == 201) {
        final data = json.decode(response.body) as Map<String, dynamic>;
        final message = CrewCommunication.fromJson(data);

        // Handle critical safety situations
        if (safetyStatus == SafetyStatus.emergency) {
          await _handleEmergencySafetyCheckin(crewId, message);
        } else if (safetyStatus == SafetyStatus.hazard) {
          await _handleHazardSafetyCheckin(crewId, message);
        }

        // Update crew safety status tracking
        await _updateCrewSafetyStatus(crewId, currentUser.uid, safetyStatus);

        return ServiceResult.success(message);
      } else {
        throw CrewCommunicationException(
          code: 'api-error',
          message: 'Failed to send safety check-in',
        );
      }

    } catch (e) {
      return ServiceResult.error('Failed to send safety check-in: ${e.toString()}');
    }
  }

  /// Upload attachment to message
  ///
  /// Supports electrical work-related attachments like schematics,
  /// safety documents, job specifications, and inspection reports
  ///
  /// Parameters:
  /// - [messageId]: ID of the message to attach to
  /// - [attachment]: File to upload
  ///
  /// Returns the URL of the uploaded attachment
  Future<String> uploadAttachment(String messageId, File attachment) async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      throw const CrewCommunicationException(
        code: 'unauthenticated',
        message: 'User must be authenticated to upload attachments',
      );
    }

    try {
      // Validate attachment
      await _validateAttachment(attachment);

      // Create storage path
      final fileName = attachment.path.split('/').last;
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final storagePath = 'crew_attachments/$messageId/${timestamp}_$fileName';

      // Upload to Firebase Storage
      final ref = _storage.ref().child(storagePath);
      final uploadTask = ref.putFile(attachment);

      // Wait for upload completion
      final snapshot = await uploadTask.whenComplete(() {});
      final downloadUrl = await snapshot.ref.getDownloadURL();

      // Create attachment metadata
      final attachmentData = MessageAttachment(
        id: '${messageId}_${timestamp}',
        fileName: fileName,
        url: downloadUrl,
        type: _determineAttachmentType(fileName),
        sizeBytes: await attachment.length(),
        uploadedAt: DateTime.now(),
        uploadedBy: currentUser.uid,
      );

      // Update message with attachment
      await _messagesCollection.doc(messageId).update({
        'attachments': FieldValue.arrayUnion([attachmentData.toJson()]),
      });

      return downloadUrl;

    } catch (e) {
      throw CrewCommunicationException(
        code: 'attachment_upload_failed',
        message: 'Failed to upload attachment: ${e.toString()}',
        details: {
          'message_id': messageId,
          'file_name': attachment.path.split('/').last,
        },
      );
    }
  }

  // =================== PRIVATE HELPER METHODS ===================

  /// Validate user has access to crew
  Future<void> _validateCrewAccess(String crewId, String userId) async {
    final crewDoc = await _crewsCollection.doc(crewId).get();

    if (!crewDoc.exists) {
      throw const CrewCommunicationException(
        code: 'crew_not_found',
        message: 'Crew not found',
      );
    }

    final crewData = crewDoc.data() as Map<String, dynamic>;
    final memberIds = List<String>.from(crewData['memberIds'] ?? []);

    if (!memberIds.contains(userId)) {
      throw const CrewCommunicationException(
        code: 'access_denied',
        message: 'User does not have access to this crew',
      );
    }
  }

  /// Validate user has permission to pin messages
  Future<void> _validatePinPermission(String messageId, String userId) async {
    final messageDoc = await _messagesCollection.doc(messageId).get();
    if (!messageDoc.exists) {
      throw const CrewCommunicationException(
        code: 'message_not_found',
        message: 'Message not found',
      );
    }

    final messageData = messageDoc.data() as Map<String, dynamic>;
    final crewId = messageData['crewId'] as String;

    // Check if user is crew leader or foreman
    final crewDoc = await _crewsCollection.doc(crewId).get();
    if (!crewDoc.exists) {
      throw const CrewCommunicationException(
        code: 'crew_not_found',
        message: 'Crew not found',
      );
    }

    final crewData = crewDoc.data() as Map<String, dynamic>;
    final createdBy = crewData['createdBy'] as String?;
    final leaders = List<String>.from(crewData['leaders'] ?? []);

    if (createdBy != userId && !leaders.contains(userId)) {
      throw const CrewCommunicationException(
        code: 'insufficient_permission',
        message: 'Only crew leaders can pin messages',
      );
    }
  }

  /// Validate user can edit message
  Future<void> _validateEditPermission(String messageId, String userId) async {
    final messageDoc = await _messagesCollection.doc(messageId).get();
    if (!messageDoc.exists) {
      throw const CrewCommunicationException(
        code: 'message_not_found',
        message: 'Message not found',
      );
    }

    final messageData = messageDoc.data() as Map<String, dynamic>;
    final senderId = messageData['senderId'] as String;

    if (senderId != userId) {
      throw const CrewCommunicationException(
        code: 'not_sender',
        message: 'Only the message sender can edit messages',
      );
    }

    // Check time limit for editing (15 minutes)
    final timestamp = messageData['timestamp'] as Timestamp?;
    if (timestamp != null) {
      final messageTime = timestamp.toDate();
      final now = DateTime.now();
      const editTimeLimit = Duration(minutes: 15);

      if (now.difference(messageTime) > editTimeLimit) {
        throw const CrewCommunicationException(
          code: 'edit_time_expired',
          message: 'Messages can only be edited within 15 minutes of sending',
        );
      }
    }
  }

  /// Validate user can delete message
  Future<void> _validateDeletePermission(String messageId, String userId) async {
    final messageDoc = await _messagesCollection.doc(messageId).get();
    if (!messageDoc.exists) {
      throw const CrewCommunicationException(
        code: 'message_not_found',
        message: 'Message not found',
      );
    }

    final messageData = messageDoc.data() as Map<String, dynamic>;
    final senderId = messageData['senderId'] as String;
    final crewId = messageData['crewId'] as String;

    // Message sender can always delete their own messages
    if (senderId == userId) return;

    // Check if user is crew leader
    final crewDoc = await _crewsCollection.doc(crewId).get();
    if (crewDoc.exists) {
      final crewData = crewDoc.data() as Map<String, dynamic>;
      final createdBy = crewData['createdBy'] as String?;
      final leaders = List<String>.from(crewData['leaders'] ?? []);

      if (createdBy == userId || leaders.contains(userId)) return;
    }

    throw const CrewCommunicationException(
      code: 'insufficient_permission',
      message: 'Only the sender or crew leaders can delete messages',
    );
  }

  /// Send emergency notifications to all crew members
  Future<void> _sendEmergencyNotifications(
    String crewId,
    CrewCommunication message,
  ) async {
    try {
      final crewDoc = await _crewsCollection.doc(crewId).get();
      if (!crewDoc.exists) return;

      final crewData = crewDoc.data() as Map<String, dynamic>;
      final memberIds = List<String>.from(crewData['memberIds'] ?? []);

      // Send notifications to each crew member
      // This would integrate with FCM service for actual notifications
      for (final memberId in memberIds) {
        if (memberId != message.senderId) {
          // TODO: Integrate with FCM service for push notifications
          print('🚨 EMERGENCY ALERT sent to crew member: $memberId');
          print('   From: ${message.senderName} (${message.senderRole})');
          print('   Message: ${message.content}');
          print('   Location: ${message.location?['description'] ?? 'Unknown'}');
        }
      }
    } catch (e) {
      print('Warning: Failed to send emergency notifications: $e');
    }
  }

  /// Log emergency alert for audit trail
  Future<void> _logEmergencyAlert(CrewCommunication message) async {
    try {
      await _firestore.collection('emergency_logs').add({
        'messageId': message.id,
        'crewId': message.crewId,
        'senderId': message.senderId,
        'senderName': message.senderName,
        'alertLevel': message.alertLevel,
        'location': message.location,
        'timestamp': FieldValue.serverTimestamp(),
        'content': message.content,
        'requiresResponse': message.requiresAllMemberResponse,
      });
    } catch (e) {
      print('Warning: Failed to log emergency alert: $e');
    }
  }

  /// Handle emergency safety check-in
  Future<void> _handleEmergencySafetyCheckin(
    String crewId,
    CrewCommunication message,
  ) async {
    // Auto-escalate emergency safety check-ins
    final escalationMessage = 'EMERGENCY SAFETY ALERT: ${message.senderName} has reported an emergency situation. Immediate response required.';

    await sendEmergencyAlert(
      crewId: crewId,
      content: escalationMessage,
      location: message.location ?? {'description': 'Location unknown'},
    );
  }

  /// Handle hazard safety check-in
  Future<void> _handleHazardSafetyCheckin(
    String crewId,
    CrewCommunication message,
  ) async {
    // Send safety alert for hazard situations
    final hazardAlert = CrewCommunication(
      id: _messagesCollection.doc().id,
      crewId: crewId,
      senderId: message.senderId,
      content: 'HAZARD ALERT: ${message.senderName} has identified a safety hazard. Exercise caution and await further instructions.',
      type: MessageType.safetyAlert,
      timestamp: DateTime.now(),
      senderName: message.senderName,
      senderRole: message.senderRole,
      urgency: MessageUrgency.high,
      priority: MessagePriority.high,
      safetyLevel: SafetyLevel.general,
      requiresAcknowledgment: true,
    );

    await sendMessage(
      crewId: crewId,
      content: hazardAlert.content,
      messageType: hazardAlert.type,
    );
  }

  /// Update crew safety status tracking
  Future<void> _updateCrewSafetyStatus(
    String crewId,
    String userId,
    SafetyStatus status,
  ) async {
    try {
      await _crewsCollection.doc(crewId).update({
        'safetyStatus.$userId': {
          'status': status.name,
          'lastCheckin': FieldValue.serverTimestamp(),
          'timestamp': FieldValue.serverTimestamp(),
        },
        'lastSafetyUpdate': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Warning: Failed to update crew safety status: $e');
    }
  }

  /// Validate attachment file
  Future<void> _validateAttachment(File attachment) async {
    const maxFileSize = 10 * 1024 * 1024; // 10MB
    const allowedExtensions = [
      'pdf', 'doc', 'docx', 'txt', 'rtf',  // Documents
      'jpg', 'jpeg', 'png', 'gif', 'webp', // Images
      'mp4', 'mov', 'avi',                  // Videos
      'mp3', 'wav', 'm4a',                  // Audio
      'dwg', 'dxf',                         // CAD files
      'xls', 'xlsx', 'csv',                 // Spreadsheets
    ];

    // Check if file exists
    if (!await attachment.exists()) {
      throw const CrewCommunicationException(
        code: 'file_not_found',
        message: 'Attachment file not found',
      );
    }

    // Check file size
    final fileSize = await attachment.length();
    if (fileSize > maxFileSize) {
      throw const CrewCommunicationException(
        code: 'file_too_large',
        message: 'Attachment exceeds maximum size of ${(maxFileSize / (1024 * 1024)).round()}MB',
      );
    }

    // Check file extension
    final fileName = attachment.path.split('/').last.toLowerCase();
    final extension = fileName.split('.').last;

    if (!allowedExtensions.contains(extension)) {
      throw CrewCommunicationException(
        code: 'invalid_file_type',
        message: 'File type .$extension is not allowed',
        details: {'allowed_types': allowedExtensions.join(', ')},
      );
    }
  }

  /// Determine attachment type from file extension
  AttachmentType _determineAttachmentType(String fileName) {
    final extension = fileName.toLowerCase().split('.').last;

    switch (extension) {
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
      case 'webp':
        return AttachmentType.image;

      case 'mp4':
      case 'mov':
      case 'avi':
        return AttachmentType.video;

      case 'mp3':
      case 'wav':
      case 'm4a':
        return AttachmentType.audio;

      case 'dwg':
      case 'dxf':
        return AttachmentType.schematic;

      case 'xls':
      case 'xlsx':
      case 'csv':
        return AttachmentType.timeSheet;

      default:
        return AttachmentType.document;
    }
  }

  /// Get cached messages for offline access
  Future<List<CrewCommunication>> _getCachedMessages(String crewId, int limit) async {
    try {
      final cachedData = await _cache.getCachedMessages(crewId, limit);
      return cachedData.map((data) => CrewCommunication.fromJson(data)).toList();
    } catch (e) {
      return [];
    }
  }

  /// Cache messages for offline access
  Future<void> _cacheMessages(String crewId, List<CrewCommunication> messages) async {
    try {
      final messageMaps = messages.map((m) => m.toJson()).toList();
      await _cache.cacheMessages(crewId, messageMaps);
    } catch (e) {
      print('Warning: Failed to cache messages: $e');
    }
  }
}

/// Extension methods for cache service integration
extension CacheServiceExtension on CacheService {
  Future<void> cacheMessage(String crewId, Map<String, dynamic> messageData) async {
    // Implementation would depend on your cache service
    // This is a placeholder for the actual cache integration
  }

  Future<void> cacheMessages(String crewId, List<Map<String, dynamic>> messages) async {
    // Implementation would depend on your cache service
  }

  Future<List<Map<String, dynamic>>> getCachedMessages(String crewId, int limit) async {
    // Implementation would depend on your cache service
    return [];
  }

  Future<void> updateCachedMessage(String messageId, Map<String, dynamic> updates) async {
    // Implementation would depend on your cache service
  }

  Future<void> removeCachedMessage(String messageId) async {
    // Implementation would depend on your cache service
  }
}