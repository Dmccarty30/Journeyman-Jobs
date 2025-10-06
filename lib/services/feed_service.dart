import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart' show kDebugMode;

import '../domain/exceptions/app_exception.dart';
import '../features/crews/models/tailboard.dart';
import '../models/post_model.dart';

/// A service dedicated to managing feed-related operations in Firestore.
///
/// This includes creating, reading, updating, and deleting posts, comments,
/// and reactions within a crew's feed. It also provides methods for
/// real-time data streaming and statistical analysis.
class FeedService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Performance optimization constants
  static const int defaultPageSize = 20;
  static const int maxPageSize = 100;

  // Collections
  CollectionReference get _postsCollection => _firestore.collection('posts');
  CollectionReference get _crewsCollection => _firestore.collection('crews');

  // Get Firestore instance
  /// Returns the underlying [FirebaseFirestore] instance for direct access if needed.
  FirebaseFirestore get firestore => _firestore;

  // Post CRUD Operations

  /// Creates a new post in a crew's feed.
  ///
  /// - [crewId]: The ID of the crew where the post will be created.
  /// - [authorId]: The ID of the user creating the post.
  /// - [content]: The text content of the post.
  /// - [mediaUrls]: An optional list of URLs for attached media.
  ///
  /// Returns the ID of the newly created post as a `Future<String>`.
  /// Throws an [AppException] if validation fails or on Firestore errors.
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

  /// Retrieves a paginated stream of posts for a specific crew.
  ///
  /// - [crewId]: The ID of the crew whose posts are to be fetched.
  /// - [limit]: The maximum number of posts to return per page.
  /// - [startAfter]: The `DocumentSnapshot` to start fetching after for pagination.
  /// - [includeDeleted]: Whether to include posts that have been soft-deleted.
  ///
  /// Returns a `Stream<QuerySnapshot>` that emits updates in real-time.
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

  /// Fetches a single post by its ID.
  ///
  /// - [postId]: The unique ID of the post.
  ///
  /// Returns a `Future<PostModel?>`, which is the post object if found, otherwise `null`.
  Future<PostModel?> getPost(String postId) async {
    try {
      final doc = await _postsCollection.doc(postId).get();
      if (!doc.exists) return null;

      return PostModel.fromFirestore(doc);
    } catch (e) {
      throw AppException('Failed to get post: $e');
    }
  }

  /// Updates the content and/or media of an existing post.
  ///
  /// - [postId]: The ID of the post to update.
  /// - [authorId]: The ID of the author (for validation, though not used in current implementation).
  /// - [content]: The new text content for the post.
  /// - [mediaUrls]: An optional new list of media URLs.
  ///
  /// Throws an [AppException] on validation or Firestore errors.
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

  /// Soft-deletes a post by setting its `isDeleted` flag to `true`.
  ///
  /// The post remains in the database but will be hidden from default queries.
  ///
  /// - [postId]: The ID of the post to soft-delete.
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

  /// Permanently deletes a post from Firestore.
  ///
  /// This action is irreversible. Use with caution.
  ///
  /// - [postId]: The ID of the post to permanently delete.
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

  /// Pins or unpins a post in a crew's feed.
  ///
  /// Pinned posts can be displayed prominently in the UI.
  ///
  /// - [postId]: The ID of the post to pin or unpin.
  /// - [isPinned]: `true` to pin the post, `false` to unpin it.
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

  /// Adds or updates a user's reaction to a post.
  ///
  /// This method uses a Firestore transaction to ensure atomic updates to
  /// reaction counts and user reaction maps.
  ///
  /// - [postId]: The ID of the post to react to.
  /// - [memberId]: The ID of the user adding the reaction.
  /// - [emoji]: The emoji string representing the reaction.
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

  /// Removes a user's reaction from a post.
  ///
  /// This method uses a Firestore transaction to ensure atomic updates.
  ///
  /// - [postId]: The ID of the post.
  /// - [memberId]: The ID of the user whose reaction is to be removed.
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

  /// Retrieves the reaction counts for a specific post.
  ///
  /// - [postId]: The ID of the post.
  ///
  /// Returns a `Future<Map<String, int>>` where keys are emoji strings and
  /// values are their respective counts.
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

  /// Checks if a specific user has already reacted to a post with a given emoji.
  ///
  /// - [postId]: The ID of the post.
  /// - [userId]: The ID of the user.
  /// - [emoji]: The emoji to check for.
  ///
  /// Returns `true` if the user has reacted with the specified emoji, `false` otherwise.
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

  /// Adds a comment to a post.
  ///
  /// Atomically increments the `commentCount` on the parent post.
  ///
  /// - [postId]: The ID of the post to comment on.
  /// - [authorId]: The ID of the comment's author.
  /// - [content]: The text content of the comment.
  ///
  /// Returns the ID of the newly created comment as a `Future<String>`.
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

  /// Retrieves a paginated stream of comments for a specific post.
  ///
  /// - [postId]: The ID of the post whose comments are to be fetched.
  /// - [limit]: The maximum number of comments to return per page.
  /// - [startAfter]: The `DocumentSnapshot` for pagination.
  ///
  /// Returns a `Stream<QuerySnapshot>` of comments, ordered oldest to newest.
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

  /// Updates the content of an existing comment.
  ///
  /// - [postId]: The ID of the parent post.
  /// - [commentId]: The ID of the comment to update.
  /// - [authorId]: The ID of the author (for validation).
  /// - [content]: The new text content for the comment.
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

  /// Soft-deletes a comment and atomically decrements the post's `commentCount`.
  ///
  /// - [postId]: The ID of the parent post.
  /// - [commentId]: The ID of the comment to delete.
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

  /// A convenience method to get a real-time stream of posts for a crew.
  ///
  /// See [getCrewPosts] for parameter details.
  Stream<QuerySnapshot> getCrewPostsStream({
    required String crewId,
    int limit = defaultPageSize,
  }) {
    return getCrewPosts(crewId: crewId, limit: limit);
  }

  /// A convenience method to get a real-time stream of comments for a post.
  ///
  /// See [getPostComments] for parameter details.
  Stream<QuerySnapshot> getPostCommentsStream({
    required String postId,
    int limit = defaultPageSize,
  }) {
    return getPostComments(postId: postId, limit: limit);
  }

  /// Provides a real-time stream for a single post document.
  ///
  /// This is useful for listening to changes in likes, comments, and reactions.
  ///
  /// - [postId]: The ID of the post to stream.
  Stream<DocumentSnapshot> getPostStream(String postId) {
    return _postsCollection.doc(postId).snapshots();
  }

  // Analytics and Statistics

  /// Calculates and returns engagement statistics for all posts in a crew.
  ///
  /// - [crewId]: The ID of the crew.
  ///
  /// Returns a `Future<Map<String, dynamic>>` containing stats like total posts,
  /// likes, comments, and averages.
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

  /// Soft-deletes multiple posts in a single atomic batch operation.
  ///
  /// - [postIds]: A list of post IDs to be deleted.
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

  /// Validates post data before creation or update.
  bool _isValidPostData({
    required String content,
    List<String>? mediaUrls,
  }) {
    if (content.trim().isEmpty) return false;
    if (content.length > 10000) return false; // Reasonable content limit
    if (mediaUrls != null && mediaUrls.length > 10) return false; // Media limit
    return true;
  }

  /// Validates comment data before creation or update.
  bool _isValidCommentData(String content) {
    if (content.trim().isEmpty) return false;
    if (content.length > 2000) return false; // Reasonable comment limit
    return true;
  }
}
