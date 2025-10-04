// lib/features/crews/providers/feed_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../services/feed_service.dart';
import '../../../models/post_model.dart';
import '../models/tailboard.dart';
import 'crews_riverpod_provider.dart';

part 'feed_provider.g.dart';

/// FeedService provider
@Riverpod(keepAlive: true)
FeedService feedService(Ref ref) => FeedService();

/// Stream of posts for a specific crew
@riverpod
Stream<List<PostModel>> crewPostsStream(Ref ref, String crewId) {
  final feedService = ref.watch(feedServiceProvider);
  return feedService.getCrewPosts(crewId: crewId).map((snapshot) {
    return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
  });
}

/// Posts for a specific crew
@riverpod
List<PostModel> crewPosts(Ref ref, String crewId) {
  final postsAsync = ref.watch(crewPostsStreamProvider(crewId));

  return postsAsync.when(
    data: (posts) => posts.where((post) => !post.deleted).toList(),
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Stream of comments for a specific post
@riverpod
Stream<List<Comment>> postCommentsStream(Ref ref, String postId) {
  final feedService = ref.watch(feedServiceProvider);
  return feedService.getPostComments(postId: postId).map((snapshot) {
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return Comment(
        id: doc.id,
        authorId: data['authorId'] ?? '',
        content: data['content'] ?? '',
        postedAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
        editedAt: (data['updatedAt'] as Timestamp?)?.toDate(),
      );
    }).toList();
  });
}

/// Comments for a specific post
@riverpod
List<Comment> postComments(Ref ref, String postId) {
  final commentsAsync = ref.watch(postCommentsStreamProvider(postId));

  return commentsAsync.when(
    data: (comments) => comments,
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Provider to get posts for selected crew
@riverpod
List<PostModel> selectedCrewPosts(Ref ref) {
  final selectedCrew = ref.watch(selectedCrewProvider);
  if (selectedCrew == null) return [];

  return ref.watch(crewPostsProvider(selectedCrew.id));
}

/// Provider to get pinned posts for a crew
@riverpod
List<PostModel> pinnedPosts(Ref ref, String crewId) {
  final posts = ref.watch(crewPostsProvider(crewId));
  // Note: PostModel doesn't have isPinned field, this would need to be added
  // For now, return empty list
  return [];
}

/// Provider to get recent posts (non-pinned) for a crew
@riverpod
List<PostModel> recentPosts(Ref ref, String crewId) {
  final posts = ref.watch(crewPostsProvider(crewId));
  // Sort by timestamp descending and return all (since no pinned field)
  return posts..sort((a, b) => b.timestamp.compareTo(a.timestamp));
}

/// Provider to get posts by a specific author
@riverpod
List<PostModel> postsByAuthor(Ref ref, String crewId, String authorId) {
  final posts = ref.watch(crewPostsProvider(crewId));
  return posts.where((post) => post.authorId == authorId).toList();
}

/// Notifier for post creation
class PostCreationNotifier extends StateNotifier<AsyncValue<String?>> {
  PostCreationNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> createPost({
    required String crewId,
    required String content,
    List<String> mediaUrls = const [],
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      final postId = await feedService.createPost(
        crewId: crewId,
        authorId: currentUser.uid,
        content: content,
        mediaUrls: mediaUrls,
      );
      state = AsyncValue.data(postId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for post creation notifier
@riverpod
PostCreationNotifier postCreationNotifier(Ref ref) {
  return PostCreationNotifier(ref);
}

/// Stream of post creation state
@riverpod
AsyncValue<String?> postCreationState(Ref ref) {
  final notifier = ref.watch(postCreationNotifierProvider);
  return notifier.state;
}

/// Notifier for post updates
class PostUpdateNotifier extends StateNotifier<AsyncValue<void>> {
  PostUpdateNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> updatePost({
    required String postId,
    required String content,
    List<String>? mediaUrls,
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.updatePost(
        postId: postId,
        authorId: currentUser.uid,
        content: content,
        mediaUrls: mediaUrls,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.deletePost(postId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> togglePinPost(String postId, bool isPinned) async {
    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.togglePinPost(postId, isPinned);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for post update notifier
@riverpod
PostUpdateNotifier postUpdateNotifier(Ref ref) {
  return PostUpdateNotifier(ref);
}

/// Stream of post update state
@riverpod
AsyncValue<void> postUpdateState(Ref ref) {
  final notifier = ref.watch(postUpdateNotifierProvider);
  return notifier.state;
}

/// Notifier for reactions
class ReactionNotifier extends StateNotifier<AsyncValue<void>> {
  ReactionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> addReaction({
    required String postId,
    required ReactionType reactionType,
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.addReaction(
        postId: postId,
        memberId: currentUser.uid,
        reactionType: reactionType,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> removeReaction(String postId) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.removeReaction(
        postId: postId,
        memberId: currentUser.uid,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for reaction notifier
@riverpod
ReactionNotifier reactionNotifier(Ref ref) {
  return ReactionNotifier(ref);
}

/// Stream of reaction state
@riverpod
AsyncValue<void> reactionState(Ref ref) {
  final notifier = ref.watch(reactionNotifierProvider);
  return notifier.state;
}

/// Notifier for comments
class CommentNotifier extends StateNotifier<AsyncValue<String?>> {
  CommentNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      final commentId = await feedService.addComment(
        postId: postId,
        authorId: currentUser.uid,
        content: content,
      );
      state = AsyncValue.data(commentId);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
    final currentUser = _ref.read(currentUserProvider);
    if (currentUser == null) {
      state = const AsyncValue.error('User not authenticated', StackTrace.empty);
      return;
    }

    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.updateComment(
        postId: postId,
        commentId: commentId,
        authorId: currentUser.uid,
        content: content,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  Future<void> deleteComment({
    required String postId,
    required String commentId,
  }) async {
    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.deleteComment(
        postId: postId,
        commentId: commentId,
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stackTrace: stack);
    }
  }

  void reset() {
    state = const AsyncValue.data(null);
  }
}

/// Provider for comment notifier
@riverpod
CommentNotifier commentNotifier(Ref ref) {
  return CommentNotifier(ref);
}

/// Stream of comment state
@riverpod
AsyncValue<String?> commentState(Ref ref) {
  final notifier = ref.watch(commentNotifierProvider);
  return notifier.state;
}

/// Provider to get crew post statistics
@riverpod
Future<Map<String, dynamic>> crewPostStats(Ref ref, String crewId) async {
  final feedService = ref.watch(feedServiceProvider);
  return await feedService.getCrewPostStats(crewId);
}

/// Provider to get reaction counts for a post
@riverpod
Map<ReactionType, int> postReactionCounts(Ref ref, String postId) {
  // This would need to be implemented with a stream of the post
  // For now, return empty map
  return {};
}

/// Provider to check if current user has reacted to a post
@riverpod
bool userReactionToPost(Ref ref, String postId, ReactionType reactionType) {
  final currentUser = ref.watch(currentUserProvider);
  if (currentUser == null) return false;

  // This would need access to the post's reactions data
  // For now, return false
  return false;
}