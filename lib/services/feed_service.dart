import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../domain/exceptions/app_exception.dart';
import '../models/post_model.dart';

class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Performance optimization constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Collections
  CollectionReference get _postsCollection => _firestore.collection('posts');

  // Get Firestore instance
  FirebaseFirestore get firestore => _firestore;

  // Post CRUD Operations

  /// Create a new post in a crew's feed
  Future<String> createPost({
    required String crewId,
    required String authorId,
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    try {
      // Validate input
      if (crewId.isEmpty) throw AppException('Crew ID cannot be empty');
      if (authorId.isEmpty) throw AppException('Author ID cannot be empty');
      if (content.trim().isEmpty) throw AppException('Post content cannot be empty');

      final postData = {
        'crewId': crewId,
        'authorId': authorId,
        'content': content.trim(),
        'mediaUrls': mediaUrls,
        'likes': <String>[],
        'reactions': <String, String>{}, // memberId -> reactionType
        'commentCount': 0,
        'isPinned': false,
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final docRef = await _postsCollection.add(postData);

      if (kDebugMode) {
        print('📝 Created post ${docRef.id} for crew $crewId');
      }

      return docRef.id;
    } catch (e) {
      throw AppException('Failed to create post: $e');
    }
  }

  /// Get posts for a specific crew with pagination
  Stream<QuerySnapshot> getCrewPosts({
    required String crewId,
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
    bool includeDeleted = false,
  }) {
    // Enforce pagination limits for performance
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    Query query = _postsCollection
        .where('crewId', isEqualTo: crewId)
        .where('isDeleted', isEqualTo: includeDeleted)
        .orderBy('createdAt', descending: true);

    // Always enforce pagination
    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    if (kDebugMode) {
      print('📡 Getting posts for crew $crewId (limit: $limit)');
    }

    return query.snapshots();
  }

  /// Get a single post by ID
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;

      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw AppException('Failed to get post: $e');
    }
  }

  /// Update a post's content
  Future<void> updatePost({
    required String postId,
    required String authorId,
    required String content,
    List<String>? mediaUrls,
  }) async {
    try {
      // Validate input
      if (content.trim().isEmpty) throw AppException('Post content cannot be empty');

      final updateData = {
        'content': content.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      if (mediaUrls != null) {
        updateData['mediaUrls'] = mediaUrls;
      }

      await _postsCollection.doc(postId).update(updateData);

      if (kDebugMode) {
        print('✏️ Updated post $postId');
      }
    } catch (e) {
      throw AppException('Failed to update post: $e');
    }
  }

  /// Soft delete a post
  Future<void> deletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).update({
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('🗑️ Soft deleted post $postId');
      }
    } catch (e) {
      throw AppException('Failed to delete post: $e');
    }
  }

  /// Hard delete a post (permanent deletion)
  Future<void> hardDeletePost(String postId) async {
    try {
      await _postsCollection.doc(postId).delete();

      if (kDebugMode) {
        print('💥 Hard deleted post $postId');
      }
    } catch (e) {
      throw AppException('Failed to hard delete post: $e');
    }
  }

  /// Pin/unpin a post
  Future<void> togglePinPost(String postId, bool isPinned) async {
    try {
      await _postsCollection.doc(postId).update({
        'isPinned': isPinned,
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('📌 ${isPinned ? 'Pinned' : 'Unpinned'} post $postId');
      }
    } catch (e) {
      throw AppException('Failed to toggle pin status: $e');
    }
  }

  // Likes and Reactions

  /// Add or update a reaction to a post
  Future<void> addReaction({
    required String postId,
    required String memberId,
    required String emoji,
  }) async {
    try {
      final postRef = _postsCollection.doc(postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw AppException('Post not found');

        final data = postDoc.data() as Map<String, dynamic>;
        final reactions = Map<String, int>.from(data['reactions'] ?? {});
        final userReactions = Map<String, String>.from(data['userReactions'] ?? {});
        final likes = List<String>.from(data['likes'] ?? []);

        // Update user reactions map
        userReactions[memberId] = emoji;

        // Update reactions count
        reactions[emoji] = (reactions[emoji] ?? 0) + 1;

        // Update likes list based on emoji
        if (emoji == '👍') {
          if (!likes.contains(memberId)) {
            likes.add(memberId);
          }
        } else {
          // For other emojis, remove from likes if present
          likes.remove(memberId);
        }

        transaction.update(postRef, {
          'reactions': reactions,
          'userReactions': userReactions,
          'likes': likes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) {
        print('👍 Added $emoji reaction to post $postId by $memberId');
      }
    } catch (e) {
      throw AppException('Failed to add reaction: $e');
    }
  }

  /// Remove a reaction from a post
  Future<void> removeReaction({
    required String postId,
    required String memberId,
  }) async {
    try {
      final postRef = _postsCollection.doc(postId);

      await _firestore.runTransaction((transaction) async {
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) throw AppException('Post not found');

        final data = postDoc.data() as Map<String, dynamic>;
        final reactions = Map<String, int>.from(data['reactions'] ?? {});
        final userReactions = Map<String, String>.from(data['userReactions'] ?? {});
        final likes = List<String>.from(data['likes'] ?? []);

        // Get the emoji that was removed
        final removedEmoji = userReactions[memberId];

        // Remove user reaction
        userReactions.remove(memberId);

        // Decrement reaction count if exists
        if (removedEmoji != null) {
          reactions[removedEmoji] = (reactions[removedEmoji] ?? 1) - 1;
          if (reactions[removedEmoji]! <= 0) {
            reactions.remove(removedEmoji);
          }
        }

        // Remove from likes if present
        likes.remove(memberId);

        transaction.update(postRef, {
          'reactions': reactions,
          'userReactions': userReactions,
          'likes': likes,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      });

      if (kDebugMode) {
        print('👎 Removed reaction from post $postId by $memberId');
      }
    } catch (e) {
      throw AppException('Failed to remove reaction: $e');
    }
  }

  /// Get reaction counts for a post from Firestore
  Future<Map<String, int>> getPostReactionCounts(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return {};

      final data = doc.data() as Map<String, dynamic>;
      return Map<String, int>.from(data['reactions'] ?? {});
    } catch (e) {
      throw AppException('Failed to get reaction counts: $e');
    }
  }

  /// Check if a user has reacted to a post with a specific emoji
  Future<bool> hasUserReacted(String postId, String userId, String emoji) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return false;

      final data = doc.data() as Map<String, dynamic>;
      final userReactions = Map<String, String>.from(data['userReactions'] ?? {});
      return userReactions[userId] == emoji;
    } catch (e) {
      throw AppException('Failed to check user reaction: $e');
    }
  }

  // Comments

  /// Add a comment to a post
  Future<String> addComment({
    required String postId,
    required String authorId,
    required String content,
  }) async {
    try {
      // Validate input
      if (content.trim().isEmpty) throw AppException('Comment content cannot be empty');

      final commentData = {
        'postId': postId,
        'authorId': authorId,
        'content': content.trim(),
        'isDeleted': false,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      final commentRef = await _postsCollection
          .doc(postId)
          .collection('comments')
          .add(commentData);

      // Update comment count on post
      await _postsCollection.doc(postId).update({
        'commentCount': FieldValue.increment(1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('💬 Added comment ${commentRef.id} to post $postId');
      }

      return commentRef.id;
    } catch (e) {
      throw AppException('Failed to add comment: $e');
    }
  }

  /// Get comments for a post
  Stream<QuerySnapshot> getPostComments({
    required String postId,
    int limit = defaultPageSize,
    DocumentSnapshot? startAfter,
  }) {
    // Enforce pagination limits for performance
    if (limit > maxPageSize) {
      limit = maxPageSize;
    }

    Query query = _postsCollection
        .doc(postId)
        .collection('comments')
        .where('isDeleted', isEqualTo: false)
        .orderBy('createdAt', descending: false); // Oldest first for threads

    query = query.limit(limit);

    if (startAfter != null) {
      query = query.startAfterDocument(startAfter);
    }

    return query.snapshots();
  }

  /// Update a comment
  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String authorId,
    required String content,
  }) async {
    try {
      // Validate input
      if (content.trim().isEmpty) throw AppException('Comment content cannot be empty');

      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'content': content.trim(),
            'updatedAt': FieldValue.serverTimestamp(),
          });

      if (kDebugMode) {
        print('✏️ Updated comment $commentId on post $postId');
      }
    } catch (e) {
      throw AppException('Failed to update comment: $e');
    }
  }

  /// Delete a comment
  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    try {
      await _postsCollection
          .doc(postId)
          .collection('comments')
          .doc(commentId)
          .update({
            'isDeleted': true,
            'updatedAt': FieldValue.serverTimestamp(),
          });

      // Update comment count on post
      await _postsCollection.doc(postId).update({
        'commentCount': FieldValue.increment(-1),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      if (kDebugMode) {
        print('🗑️ Soft deleted comment $commentId from post $postId');
      }
    } catch (e) {
      throw AppException('Failed to delete comment: $e');
    }
  }

  // Real-time Updates

  /// Get real-time stream of posts for a crew
  Stream<QuerySnapshot> getCrewPostsStream({
    required String crewId,
    int limit = defaultPageSize,
  }) {
    return getCrewPosts(crewId: crewId, limit: limit);
  }

  /// Get real-time stream of comments for a post
  Stream<QuerySnapshot> getPostCommentsStream({
    required String postId,
    int limit = defaultPageSize,
  }) {
    return getPostComments(postId: postId, limit: limit);
  }

  /// Get real-time stream of a single post
  Stream<DocumentSnapshot> getPostStream(String postId) {
    return _postsCollection.doc(postId).snapshots();
  }

  // Analytics and Statistics

  /// Get post statistics for a crew
  Future<Map<String, dynamic>> getCrewPostStats(String crewId) async {
    try {
      final querySnapshot = await _postsCollection
          .where('crewId', isEqualTo: crewId)
          .where('isDeleted', isEqualTo: false)
          .get();

      int totalPosts = 0;
      int totalLikes = 0;
      int totalComments = 0;
      int totalReactions = 0;

      for (final doc in querySnapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        totalPosts++;
        totalLikes += (data['likes'] as List<dynamic>?)?.length ?? 0;
        totalComments += (data['commentCount'] as int?) ?? 0;
        totalReactions += (data['reactions'] as Map<String, dynamic>?)?.length ?? 0;
      }

      return {
        'totalPosts': totalPosts,
        'totalLikes': totalLikes,
        'totalComments': totalComments,
        'totalReactions': totalReactions,
        'averageLikesPerPost': totalPosts > 0 ? totalLikes / totalPosts : 0.0,
        'averageCommentsPerPost': totalPosts > 0 ? totalComments / totalPosts : 0.0,
      };
    } catch (e) {
      throw AppException('Failed to get crew post stats: $e');
    }
  }

  // Batch Operations

  /// Batch delete multiple posts
  Future<void> batchDeletePosts(List<String> postIds) async {
    final batch = _firestore.batch();

    for (final postId in postIds) {
      batch.update(_postsCollection.doc(postId), {
        'isDeleted': true,
        'updatedAt': FieldValue.serverTimestamp(),
      });
    }

    try {
      await batch.commit();

      if (kDebugMode) {
        print('🗑️ Batch deleted ${postIds.length} posts');
      }
    } catch (e) {
      throw AppException('Failed to batch delete posts: $e');
    }
  }

  // Validation Helpers


}
