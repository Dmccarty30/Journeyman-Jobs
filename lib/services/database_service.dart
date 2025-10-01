import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter/services.dart';
import '../services/storage_service.dart';
import 'dart:io';
import 'cache_service.dart';
import '../models/user_model.dart';
import '../models/crew_model.dart';
import '../models/post_model.dart';
import '../models/job_model.dart';
import '../models/conversation_model.dart' as conv;
import '../models/contractor_model.dart';
import '../features/crews/models/message.dart';
import '../services/notification_service.dart';
import '../services/connectivity_service.dart';
import '../domain/exceptions/app_exception.dart';

class DatabaseService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final String? uid = FirebaseAuth.instance.currentUser?.uid;

  // User Operations
  Future<UserModel?> getUser(String userId) async {
    final cache = CacheService();
    final cachedUser = await cache.get<UserModel>('user_$userId');
    if (cachedUser != null) {
      return cachedUser;
    }

    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      throw OfflineError('No internet connection available');
    }
    try {
      final doc = await _db.collection('users').doc(userId).get();
      final user = doc.exists ? UserModel.fromFirestore(doc) : null;
      if (user != null) {
        await cache.set('user_$userId', user, ttl: CacheService.userDataTtl);
      }
      return user;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw PermissionError(e.message ?? 'Permission denied');
        case 'network-request-failed':
          throw NetworkError(e.message ?? 'Network error');
        default:
          throw AppException('Failed to get user: ${e.message}', code: e.code);
      }
    } on PlatformException catch (e) {
      throw NetworkError('Platform error: ${e.message}');
    } catch (e) {
      throw AppException('Failed to get user: ${e.toString()}');
    }
  }

  Future<void> updateUser(UserModel user) async {
    if (!user.isValid()) {
      throw ValidationError('Invalid user data');
    }
    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      throw OfflineError('No internet connection available');
    }
    try {
      await _db.collection('users').doc(user.uid).set(user.toFirestore(), SetOptions(merge: true));
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw PermissionError(e.message ?? 'Permission denied');
        case 'network-request-failed':
          throw NetworkError(e.message ?? 'Network error');
        default:
          throw AppException('Failed to update user: ${e.message}', code: e.code);
      }
    } on PlatformException catch (e) {
      throw NetworkError('Platform error: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  Future<void> setOnlineStatus(bool status) async {
    if (uid == null) return;
    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      throw OfflineError('No internet connection available');
    }
    try {
      await _db.collection('users').doc(uid!).update({
        'onlineStatus': status,
        'lastActive': FieldValue.serverTimestamp(),
      });
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw PermissionError(e.message ?? 'Permission denied');
        case 'network-request-failed':
          throw NetworkError(e.message ?? 'Network error');
        default:
          throw AppException('Failed to update online status: ${e.message}', code: e.code);
      }
    } on PlatformException catch (e) {
      throw NetworkError('Platform error: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  // Crew Operations
  Future<Crew?> getCrew(String crewId) async {
    final connectivity = ConnectivityService();
    if (!connectivity.isOnline) {
      throw OfflineError('No internet connection available');
    }
    try {
      final doc = await _db.collection('crews').doc(crewId).get();
      return doc.exists ? Crew.fromFirestore(doc) : null;
    } on FirebaseException catch (e) {
      switch (e.code) {
        case 'permission-denied':
          throw PermissionError(e.message ?? 'Permission denied');
        case 'network-request-failed':
          throw NetworkError(e.message ?? 'Network error');
        default:
          throw AppException('Failed to get crew: ${e.message}', code: e.code);
      }
    } on PlatformException catch (e) {
      throw NetworkError('Platform error: ${e.message}');
    } catch (e) {
      throw AppException('Failed to get crew: ${e.toString()}');
    }
  }

  Future<String> createCrew(Crew crew) async {
    try {
      final ref = await _db.collection('crews').add(crew.toFirestore());
      // Add to foreman's crewIds
      await _db.collection('users').doc(crew.foremanId).update({
        'crewIds': FieldValue.arrayUnion([ref.id]),
      });
      return ref.id;
    } on FirebaseException catch (e) {
      throw AppException('Failed to create crew: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  Future<void> joinCrew(String crewId) async {
    if (uid == null) return;
    try {
      await _db.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayUnion([uid]),
      });
      await _db.collection('users').doc(uid!).update({
        'crewIds': FieldValue.arrayUnion([crewId]),
      });
    } on FirebaseException catch (e) {
      throw AppException('Failed to join crew: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  Future<void> removeMember(String crewId, String memberId) async {
    final crew = await getCrew(crewId);
    if (crew?.foremanId != uid) throw AppException('Not authorized to remove member');
    try {
      await _db.collection('crews').doc(crewId).update({
        'memberIds': FieldValue.arrayRemove([memberId]),
      });
      await _db.collection('users').doc(memberId).update({
        'crewIds': FieldValue.arrayRemove([crewId]),
      });
    } on FirebaseException catch (e) {
      throw AppException('Failed to remove member: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  Future<void> updateJobPreferences(String crewId, Map<String, dynamic> prefs) async {
    final crew = await getCrew(crewId);
    if (crew?.foremanId != uid) throw Exception('Not foreman');
    await _db.collection('crews').doc(crewId).update({'jobPreferences': prefs});
  }

  // Feed Posts
  Stream<List<PostModel>> streamFeedPosts(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Query<Map<String, dynamic>> query = _db.collection('crews').doc(crewId).collection('feedPosts')
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.snapshots()
        .map((snap) => snap.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  Future<void> createPost(String crewId, PostModel post, {List<File>? mediaFiles}) async {
    List<String> mediaUrls = [];
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      final connectivity = ConnectivityService();
      try {
        for (var file in mediaFiles) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final path = 'crews/$crewId/posts/${post.id}/media/$timestamp';
          final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
          if (url != null) {
            mediaUrls.add(url);
          }
        }
        post = post.copyWith(mediaUrls: mediaUrls);
      } on AppException {
        // Log error, continue without media
      } catch (e) {
        throw AppException('Failed to upload media: $e');
      }
    }

    final postRef = await _db.collection('crews').doc(crewId).collection('feedPosts').add(post.toFirestore());
    final postId = postRef.id;

    // Send notifications to crew members except author
    final crew = await getCrew(crewId);
    if (crew != null && uid != null) {
      final members = await _db.collection('users').where('crewIds', arrayContains: crewId).get();
      for (var memberDoc in members.docs) {
        final memberId = memberDoc.id;
        if (memberId != uid) {
          final user = UserModel.fromFirestore(memberDoc);
          final token = user.fcmToken;
          if (token != null && token.isNotEmpty) {
            await NotificationService.sendNotification(
              token: token,
              title: 'New Post in Crew',
              body: post.content,
              data: {
                'type': 'post',
                'postId': postId,
                'crewId': crewId,
              },
            );
          }
        }
      }
    }
  }

  Future<void> likePost(String crewId, String postId) async {
    if (uid == null) return;
    await _db.collection('crews').doc(crewId).collection('feedPosts').doc(postId).update({
      'likes': FieldValue.arrayUnion([uid]),
    });
  }

  Future<void> deletePost(String crewId, String postId, String authorId) async {
    if (uid != authorId) throw Exception('Not author');
    await _db.collection('crews').doc(crewId).collection('feedPosts').doc(postId).update({'deleted': true});
  }

  // Jobs
  Stream<List<Job>> streamJobs(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Query<Map<String, dynamic>> query = _db.collection('crews').doc(crewId).collection('jobs')
        .where('deleted', isEqualTo: false)
        .where('matchesCriteria', isEqualTo: true)
        .orderBy('timestamp', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.snapshots()
        .map((snap) => snap.docs.map((doc) => Job.fromFirestore(doc)).toList());
  }

  Future<void> shareJob(String crewId, Job job) async {
    final crew = await getCrew(crewId);
    final jobToShare = job.copyWith(matchesCriteria: _computeJobMatch(job.jobDetails, crew?.jobPreferences ?? {}));

    // Calculate match score as weighted average of individual criteria
    double score = 0.0;

    // Hours match
    double jobHours = jobToShare.jobDetails['hours']?.toDouble() ?? 0.0;
    double prefHours = crew?.jobPreferences['hoursWorked']?.toDouble() ?? 0.0;
    bool hoursMatch = jobHours >= prefHours;
    score += hoursMatch ? 0.3 : 0.0;

    // Pay rate match
    double jobPay = jobToShare.jobDetails['payRate']?.toDouble() ?? 0.0;
    double prefPay = crew?.jobPreferences['payRate']?.toDouble() ?? 0.0;
    bool payMatch = jobPay >= prefPay;
    score += payMatch ? 0.3 : 0.0;

    // Per diem match
    double jobPerDiem = jobToShare.jobDetails['perDiem']?.toDouble() ?? 0.0;
    double prefPerDiem = crew?.jobPreferences['perDiem']?.toDouble() ?? 0.0;
    bool perDiemMatch = jobPerDiem >= prefPerDiem;
    score += perDiemMatch ? 0.2 : 0.0;

    // Contractor match
    bool jobContractor = jobToShare.jobDetails['contractor'] ?? false;
    bool prefContractor = crew?.jobPreferences['contractor'] ?? false;
    bool contractorMatch = jobContractor == prefContractor;
    score += contractorMatch ? 0.1 : 0.0;

    // Location match
    GeoPoint? jobLoc = jobToShare.jobDetails['location'];
    GeoPoint? prefLoc = crew?.jobPreferences['location'];
    bool locationMatch = true;
    if (jobLoc != null && prefLoc != null) {
      double distance = Geolocator.distanceBetween(
        jobLoc.latitude,
        jobLoc.longitude,
        prefLoc.latitude,
        prefLoc.longitude,
      ) / 1000.0; // Convert to km
      locationMatch = distance <= 100;
    }
    score += locationMatch ? 0.1 : 0.0;

    final batch = _db.batch();
    final jobRef = _db.collection('crews').doc(crewId).collection('jobs').doc();
    batch.set(jobRef, jobToShare.toFirestore());

    // Always increment total jobs shared
    Map<String, dynamic> crewUpdates = {
      'stats.totalJobsShared': FieldValue.increment(1),
    };

    // If matches criteria, update match stats
    if (jobToShare.matchesCriteria) {
      crewUpdates['stats.totalMatchScore'] = FieldValue.increment(score);
      crewUpdates['stats.matchCount'] = FieldValue.increment(1);
    }

    batch.update(_db.collection('crews').doc(crewId), crewUpdates);
    await batch.commit();

    final jobId = jobRef.id;

    // Send notifications to crew members
    if (crew != null && uid != null) {
      final members = await _db.collection('users').where('crewIds', arrayContains: crewId).get();
      for (var memberDoc in members.docs) {
        final memberId = memberDoc.id;
        if (memberId != uid) { // Exclude sharer
          final user = UserModel.fromFirestore(memberDoc);
          final token = user.fcmToken;
          if (token != null && token.isNotEmpty) {
            await NotificationService.sendNotification(
              token: token,
              title: 'New Job Shared in Crew',
              body: '${jobToShare.jobTitle} at ${jobToShare.company}',
              data: {
                'type': 'job',
                'jobId': jobId,
                'crewId': crewId,
              },
            );
          }
        }
      }
    }
  }

  // Chat/Conversations
  Future<String> getOrCreateConversation(String crewId, {bool isDirect = false, List<String>? participants}) async {
    // For crew-wide: use fixed ID like 'crew_chat'
    final convId = isDirect ? _generateDirectConvId(participants!) : 'crew_chat';
    final ref = _db.collection('crews').doc(crewId).collection('conversations').doc(convId);
    final doc = await ref.get();
    if (!doc.exists) {
      await ref.set({
        'type': isDirect ? 'direct' : 'crew',
        'participantIds': isDirect ? participants : [],
        'lastMessage': '',
        'lastMessageTime': FieldValue.serverTimestamp(),
      });
    }
    return convId;
  }

Stream<List<Message>> streamMessages(String crewId, String conversationId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Query<Map<String, dynamic>> query = _db.collection('crews').doc(crewId).collection('conversations').doc(conversationId)
        .collection('messages')
        .where('deleted', isEqualTo: false)
        .orderBy('timestamp', descending: false)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
return query.snapshots()
        .map((snap) => snap.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(String crewId, String conversationId, Message message, {List<File>? mediaFiles}) async {
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      final connectivity = ConnectivityService();
      try {
        List<Attachment> attachments = [];
        for (var file in mediaFiles) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final path = 'crews/$crewId/conversations/$conversationId/messages/${message.id}/media/$timestamp';
          final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
          if (url != null) {
            // Create an Attachment object instead of just storing the URL
            final attachment = Attachment(
              url: url,
              filename: file.path.split('/').last,
              type: _getAttachmentTypeFromFile(file),
              sizeBytes: await file.length(),
            );
            attachments.add(attachment);
          }
        }
        // Update message with attachments instead of mediaUrls
        message = message.copyWith(attachments: attachments);
      } on AppException {
        // Log error, continue without media
      } catch (e) {
        throw AppException('Failed to upload media: $e');
      }
    }
    final batch = _db.batch();
    final messageRef = _db.collection('crews').doc(crewId).collection('conversations').doc(conversationId)
        .collection('messages').doc();
    batch.set(messageRef, message.toFirestore());
    batch.update(_db.collection('crews').doc(crewId).collection('conversations').doc(conversationId), {
      'lastMessage': message.content,
      'lastMessageTime': FieldValue.serverTimestamp(),
    });
    await batch.commit();
  }

  Future<void> markAsRead(String crewId, String conversationId, String messageId) async {
    if (uid == null) return;
    await _db.collection('crews').doc(crewId).collection('conversations').doc(conversationId)
        .collection('messages').doc(messageId).update({
      'readBy': FieldValue.arrayUnion([uid]),
    });
  }

  // Members Stream
  Stream<List<UserModel>> streamMembers(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    Query<Map<String, dynamic>> query = _db.collection('users')
        .where('crewIds', arrayContains: crewId)
        .orderBy('lastActive', descending: true)
        .limit(limit);
    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }
    return query.snapshots()
        .map((snap) => snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  // Helper: Generate unique ID for direct conv (sort uids and join)
  String _generateDirectConvId(List<String> participants) {
    participants.sort();
    return participants.join('_');
  }

  bool _computeJobMatch(Map<String, dynamic> jobDetails, Map<String, dynamic> prefs) {
    // Hours check
    double jobHours = jobDetails['hours']?.toDouble() ?? 0.0;
    double prefHours = prefs['hoursWorked']?.toDouble() ?? 0.0;
    if (jobHours < prefHours) return false;

    // Pay rate check
    double jobPay = jobDetails['payRate']?.toDouble() ?? 0.0;
    double prefPay = prefs['payRate']?.toDouble() ?? 0.0;
    if (jobPay < prefPay) return false;

    // Per diem check
    double jobPerDiem = jobDetails['perDiem']?.toDouble() ?? 0.0;
    double prefPerDiem = prefs['perDiem']?.toDouble() ?? 0.0;
    if (jobPerDiem < prefPerDiem) return false;

    // Contractor check
    bool jobContractor = jobDetails['contractor'] ?? false;
    bool prefContractor = prefs['contractor'] ?? false;
    if (jobContractor != prefContractor) return false;

    // Location check
    GeoPoint? jobLoc = jobDetails['location'];
    GeoPoint? prefLoc = prefs['location'];
    if (jobLoc != null && prefLoc != null) {
      double distance = Geolocator.distanceBetween(
        jobLoc.latitude,
        jobLoc.longitude,
        prefLoc.latitude,
        prefLoc.longitude,
      ) / 1000.0; // Convert to km
      if (distance > 100) return false;
    }
    // If no locations, assume match

    return true;
  }

  Stream<DocumentSnapshot> streamConversation(String crewId, String convId) {
    return _db.collection('crews').doc(crewId).collection('conversations').doc(convId).snapshots();
  }

Stream<List<conv.Conversation>> streamConversations(String crewId) {
    return _db.collection('crews').doc(crewId).collection('conversations')
        .where('deleted', isEqualTo: false)
        .snapshots()
        .map((snap) => snap.docs.map((doc) => conv.Conversation.fromFirestore(doc)).toList());
  }

  Future<void> updateTyping(String crewId, String convId, String userId, bool typing) async {
    try {
      final updateData = typing
          ? {'typingUsers': FieldValue.arrayUnion([userId])}
          : {'typingUsers': FieldValue.arrayRemove([userId])};
      await _db.collection('crews').doc(crewId).collection('conversations').doc(convId).update(updateData);
    } on FirebaseException catch (e) {
      throw AppException('Failed to update typing: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  Future<void> batchCreatePostAndNotify(String crewId, PostModel post, {List<File>? mediaFiles}) async {
    List<String> mediaUrls = [];
    if (mediaFiles != null && mediaFiles.isNotEmpty) {
      final connectivity = ConnectivityService();
      try {
        for (var file in mediaFiles) {
          final timestamp = DateTime.now().millisecondsSinceEpoch;
          final path = 'crews/$crewId/posts/${post.id}/media/$timestamp';
          final url = await StorageService(connectivityService: connectivity).uploadMedia(file, path);
          if (url != null) {
            mediaUrls.add(url);
          }
        }
        post = post.copyWith(mediaUrls: mediaUrls);
      } on AppException {
        // Log error, continue without media
      } catch (e) {
        throw AppException('Failed to upload media: $e');
      }
    }
    final batch = _db.batch();
    final postRef = _db.collection('crews').doc(crewId).collection('feedPosts').doc();
    batch.set(postRef, post.toFirestore());
    batch.update(_db.collection('crews').doc(crewId), {
      'stats.totalPosts': FieldValue.increment(1),
    });
    await batch.commit();
  }

  // ==================== Contractor Methods ====================

  /// Streams a list of contractors for storm work
  Stream<List<Contractor>> streamContractors({
    int limit = 50,
    DocumentSnapshot? startAfter,
  }) {
    try {
      Query query = _db.collection('contractors')
          .orderBy('company')
          .limit(limit);

      if (startAfter != null) {
        query = query.startAfterDocument(startAfter);
      }

      return query.snapshots().map((snapshot) {
        return snapshot.docs.map((doc) {
          return Contractor.fromJson(doc.data() as Map<String, dynamic>);
        }).toList();
      });
    } catch (e) {
      throw AppException('Failed to stream contractors: ${e.toString()}');
    }
  }

  /// Gets a single contractor by ID
  Future<Contractor?> getContractor(String contractorId) async {
    try {
      final doc = await _db.collection('contractors').doc(contractorId).get();
      if (!doc.exists) return null;
      return Contractor.fromJson(doc.data() as Map<String, dynamic>);
    } on FirebaseException catch (e) {
      throw AppException('Failed to get contractor: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  /// Searches contractors by company name
  Stream<List<Contractor>> searchContractors(String searchQuery) {
    try {
      if (searchQuery.isEmpty) {
        return streamContractors();
      }

      // Firestore doesn't support full-text search, so we'll get all and filter
      return _db.collection('contractors')
          .orderBy('company')
          .snapshots()
          .map((snapshot) {
        return snapshot.docs
            .map((doc) => Contractor.fromJson(doc.data()))
            .where((contractor) =>
                contractor.company.toLowerCase().contains(searchQuery.toLowerCase()))
            .toList();
      });
    } catch (e) {
      throw AppException('Failed to search contractors: ${e.toString()}');
    }
  }

  /// Creates a new contractor (admin function)
  Future<String> createContractor(Contractor contractor) async {
    try {
      final docRef = _db.collection('contractors').doc();
      final newContractor = contractor.copyWith(id: docRef.id);
      await docRef.set(newContractor.toFirestore());
      return docRef.id;
    } on FirebaseException catch (e) {
      throw AppException('Failed to create contractor: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  /// Updates an existing contractor (admin function)
  Future<void> updateContractor(Contractor contractor) async {
    try {
      await _db.collection('contractors')
          .doc(contractor.id)
          .update(contractor.toFirestore());
    } on FirebaseException catch (e) {
      throw AppException('Failed to update contractor: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  /// Deletes a contractor (admin function)
  Future<void> deleteContractor(String contractorId) async {
    try {
      await _db.collection('contractors').doc(contractorId).delete();
    } on FirebaseException catch (e) {
      throw AppException('Failed to delete contractor: ${e.message}');
    } catch (e) {
      throw AppException('Database error: ${e.toString()}');
    }
  }

  /// Helper method to determine attachment type from file
  AttachmentType _getAttachmentTypeFromFile(File file) {
    final extension = file.path.split('.').last.toLowerCase();
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
      case 'mkv':
        return AttachmentType.video;
      case 'mp3':
      case 'wav':
      case 'aac':
      case 'm4a':
        return AttachmentType.audio;
      case 'pdf':
      case 'doc':
      case 'docx':
      case 'txt':
      case 'xls':
      case 'xlsx':
        return AttachmentType.document;
      default:
        return AttachmentType.file;
    }
  }
}
