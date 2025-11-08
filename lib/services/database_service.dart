import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';
import '../models/crew_model.dart';
import '../features/crews/models/post_model.dart';
import '../models/job_model.dart';
import '../models/conversation_model.dart' as conv;
import '../models/contractor_model.dart';
import '../features/crews/models/message.dart';
import 'unified_firestore_service.dart';

class DatabaseService {
  final UnifiedFirestoreService _unifiedFirestoreService;

  DatabaseService(this._unifiedFirestoreService);

  Future<UserModel?> getUser(String userId) async {
    final doc = await _unifiedFirestoreService.getUser(userId);
    return doc.exists ? UserModel.fromFirestore(doc) : null;
  }

  Future<void> updateUser(UserModel user) async {
    await _unifiedFirestoreService.updateUser(uid: user.uid, data: user.toFirestore());
  }

  Future<void> setOnlineStatus(bool status) async {
    await _unifiedFirestoreService.setOnlineStatus(status);
  }

  Future<Crew?> getCrew(String crewId) async {
    final doc = await _unifiedFirestoreService.getCrew(crewId);
    return doc.exists ? Crew.fromFirestore(doc) : null;
  }

  Future<String> createCrew(Crew crew) async {
    return await _unifiedFirestoreService.createCrew(crew.toFirestore());
  }

  Future<void> joinCrew(String crewId) async {
    await _unifiedFirestoreService.joinCrew(crewId);
  }

  Future<void> removeMember(String crewId, String memberId) async {
    await _unifiedFirestoreService.removeMember(crewId, memberId);
  }

  Future<void> updateJobPreferences(String crewId, Map<String, dynamic> prefs) async {
    await _unifiedFirestoreService.updateJobPreferences(crewId, prefs);
  }

  Stream<List<PostModel>> streamFeedPosts(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    return _unifiedFirestoreService.streamFeedPosts(crewId, limit: limit, startAfter: startAfter)
        .map((snap) => snap.docs.map((doc) => PostModel.fromFirestore(doc)).toList());
  }

  Future<void> createPost(String crewId, PostModel post, {List<File>? mediaFiles}) async {
    await _unifiedFirestoreService.createPost(crewId, post.toFirestore(), mediaFiles: mediaFiles);
  }

  Future<void> likePost(String crewId, String postId) async {
    await _unifiedFirestoreService.likePost(crewId, postId);
  }

  Future<void> deletePost(String crewId, String postId, String authorId) async {
    await _unifiedFirestoreService.deletePost(crewId, postId, authorId);
  }

  Stream<List<Job>> streamJobs(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    return _unifiedFirestoreService.getJobs(filters: {'crewId': crewId}, limit: limit, startAfter: startAfter)
        .map((snap) => snap.docs.map((doc) => Job.fromFirestore(doc)).toList());
  }

  Future<void> shareJob(String crewId, Job job) async {
    await _unifiedFirestoreService.shareJob(crewId, job);
  }

  Future<String> getOrCreateConversation(String crewId, {bool isDirect = false, List<String>? participants}) async {
    return await _unifiedFirestoreService.getOrCreateConversation(crewId, isDirect: isDirect, participants: participants);
  }

  Stream<List<Message>> streamMessages(String crewId, String conversationId, {int limit = 20, DocumentSnapshot? startAfter}) {
    return _unifiedFirestoreService.streamMessages(crewId, conversationId, limit: limit, startAfter: startAfter)
        .map((snap) => snap.docs.map((doc) => Message.fromFirestore(doc)).toList());
  }

  Future<void> sendMessage(String crewId, String conversationId, Message message, {List<File>? mediaFiles}) async {
    await _unifiedFirestoreService.sendMessage(crewId, conversationId, message, mediaFiles: mediaFiles);
  }

  Future<void> markAsRead(String crewId, String conversationId, String messageId) async {
    await _unifiedFirestoreService.markAsRead(crewId, conversationId, messageId);
  }

  Stream<List<UserModel>> streamMembers(String crewId, {int limit = 20, DocumentSnapshot? startAfter}) {
    return _unifiedFirestoreService.streamMembers(crewId, limit: limit, startAfter: startAfter)
        .map((snap) => snap.docs.map((doc) => UserModel.fromFirestore(doc)).toList());
  }

  Stream<DocumentSnapshot> streamConversation(String crewId, String convId) {
    return _unifiedFirestoreService.streamConversation(crewId, convId);
  }

  Stream<List<conv.Conversation>> streamConversations(String crewId) {
    return _unifiedFirestoreService.streamConversations(crewId);
  }

  Future<void> updateTyping(String crewId, String convId, String userId, bool typing) async {
    await _unifiedFirestoreService.updateTyping(crewId, convId, userId, typing);
  }

  Future<void> batchCreatePostAndNotify(String crewId, PostModel post, {List<File>? mediaFiles}) async {
    await _unifiedFirestoreService.batchCreatePostAndNotify(crewId, post, mediaFiles: mediaFiles);
  }

  Stream<List<Contractor>> streamContractors({int limit = 50, DocumentSnapshot? startAfter}) {
    return _unifiedFirestoreService.streamContractors(limit: limit, startAfter: startAfter);
  }

  Future<Contractor?> getContractor(String contractorId) async {
    return await _unifiedFirestoreService.getContractor(contractorId);
  }

  Stream<List<Contractor>> searchContractors(String searchQuery) {
    return _unifiedFirestoreService.searchContractors(searchQuery);
  }

  Future<String> createContractor(Contractor contractor) async {
    return await _unifiedFirestoreService.createContractor(contractor);
  }

  Future<void> updateContractor(Contractor contractor) async {
    await _unifiedFirestoreService.updateContractor(contractor);
  }

  Future<void> deleteContractor(String contractorId) async {
    await _unifiedFirestoreService.deleteContractor(contractorId);
  }
}