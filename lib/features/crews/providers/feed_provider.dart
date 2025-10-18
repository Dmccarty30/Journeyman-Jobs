// lib/features/crews/providers/feed_provider.dart
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:state_notifier/state_notifier.dart';

import '../../../providers/core_providers.dart' as core_providers;
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../services/feed_service.dart';
import '../../../models/post_model.dart';
import '../models/tailboard.dart';

part 'feed_provider.g.dart';

/// FeedService provider
@Riverpod(keepAlive: true)
FeedService feedService(Ref ref) => FeedService();

/// Stream of posts for a specific crew
@riverpod
Stream<List<PostModel>> crewPostsStream(Ref ref, String crewId) {
  final feedService = ref.watch(feedServiceProvider);
  return feedService.getCrewPosts(crewId: crewId).map((snapshot) {
    // Limit to 50 most recent posts
    final posts = snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
    posts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
    return posts.take(50).toList();
  });
}

/// Stream of global feed posts (all crews)
@riverpod
Stream<List<PostModel>> globalFeedStream(Ref ref) {
  return FirebaseFirestore.instance
      .collection('posts')
      .orderBy('timestamp', descending: true)
      .limit(50) // Limit to 50 most recent posts
      .snapshots()
      .map((snapshot) {
        return snapshot.docs.map((doc) => PostModel.fromFirestore(doc)).toList();
      });
}

/// Global feed posts provider
@riverpod
AsyncValue<List<PostModel>> globalFeed(Ref ref) {
  final postsAsync = ref.watch(globalFeedStreamProvider);
  
  return postsAsync.when(
    data: (posts) => AsyncValue.data(posts.where((post) => !post.deleted).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Posts for a specific crew
@riverpod
AsyncValue<List<PostModel>> crewPosts(Ref ref, String crewId) {
  final postsAsync = ref.watch(crewPostsStreamProvider(crewId));

  return postsAsync.when(
    data: (posts) {
      final filteredPosts = posts.where((post) => !post.deleted).toList();
      return AsyncValue.data(filteredPosts);
    },
    loading: () => const AsyncValue.loading(),
    error: (error, stack) {
  ref.read(core_providers.coreErrorReporterProvider).report('crewPosts', error, stack, 'crewId: $crewId');
      return AsyncValue.error(error, stack);
    },
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
AsyncValue<List<Comment>> postComments(Ref ref, String postId) {
  final commentsAsync = ref.watch(postCommentsStreamProvider(postId));

  return commentsAsync.when(
    data: (comments) => AsyncValue.data(comments),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) {
  ref.read(core_providers.coreErrorReporterProvider).report('postComments', error, stack, 'postId: $postId');
      return AsyncValue.error(error, stack);
    },
  );
}

/// Provider to get posts for selected crew
@riverpod
AsyncValue<List<PostModel>> selectedCrewPosts(Ref ref) {
  final selectedCrew = ref.watch(core_providers.selectedCrewProvider);
  if (selectedCrew == null) return const AsyncValue.data([]);

  return ref.watch(crewPostsProvider(selectedCrew.id));
}

/// Provider to get pinned posts for a crew
@riverpod
AsyncValue<List<PostModel>> pinnedPosts(Ref ref, String crewId) {
  final postsAsync = ref.watch(crewPostsProvider(crewId));
  // Note: PostModel doesn't have isPinned field, this would need to be added
  // For now, return empty list
  return postsAsync.when(
    data: (_) => const AsyncValue.data([]),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider to get recent posts (non-pinned) for a crew
@riverpod
AsyncValue<List<PostModel>> recentPosts(Ref ref, String crewId) {
  final postsAsync = ref.watch(crewPostsProvider(crewId));
  // Sort by timestamp descending and return all (since no pinned field)
  return postsAsync.when(
    data: (posts) => AsyncValue.data(posts..sort((a, b) => b.timestamp.compareTo(a.timestamp))),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
}

/// Provider to get posts by a specific author
@riverpod
AsyncValue<List<PostModel>> postsByAuthor(Ref ref, String crewId, String authorId) {
  final postsAsync = ref.watch(crewPostsProvider(crewId));
  return postsAsync.when(
    data: (posts) => AsyncValue.data(posts.where((post) => post.authorId == authorId).toList()),
    loading: () => const AsyncValue.loading(),
    error: (error, stack) => AsyncValue.error(error, stack),
  );
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
  // Read current user from auth provider alias
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
      state = AsyncValue.error(e, stack);
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
  return ref.watch(postCreationStateProvider);
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
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> deletePost(String postId) async {
    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.deletePost(postId);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> togglePinPost(String postId, bool isPinned) async {
    state = const AsyncValue.loading();
    try {
      final feedService = _ref.read(feedServiceProvider);
      await feedService.togglePinPost(postId, isPinned);
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
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
  return ref.watch(postUpdateStateProvider);
}

/// Notifier for reactions
class ReactionNotifier extends StateNotifier<AsyncValue<void>> {
  ReactionNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  String _reactionTypeToEmoji(ReactionType reactionType) {
    switch (reactionType) {
      case ReactionType.like:
        return '👍';
      case ReactionType.love:
        return '❤️';
      case ReactionType.celebrate:
        return '🎉';
      case ReactionType.thumbsUp:
        return '👍';
      case ReactionType.thumbsDown:
        return '👎';
    }
  }

  Future<void> addReaction({
    required String postId,
    required ReactionType reactionType,
  }) async {
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
        emoji: _reactionTypeToEmoji(reactionType),
      );
      state = const AsyncValue.data(null);
    } catch (e, stack) {
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> removeReaction(String postId) async {
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
      state = AsyncValue.error(e, stack);
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
  return ref.watch(reactionStateProvider);
}

/// Notifier for comments
class CommentNotifier extends StateNotifier<AsyncValue<String?>> {
  CommentNotifier(this._ref) : super(const AsyncValue.data(null));

  final Ref _ref;

  Future<void> addComment({
    required String postId,
    required String content,
  }) async {
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
      state = AsyncValue.error(e, stack);
    }
  }

  Future<void> updateComment({
    required String postId,
    required String commentId,
    required String content,
  }) async {
  final currentUser = _ref.read(auth_providers.currentUserProvider);
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
      state = AsyncValue.error(e, stack);
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
      state = AsyncValue.error(e, stack);
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
  return ref.watch(commentStateProvider);
}

/// Provider to get crew post statistics
@riverpod
Future<Map<String, dynamic>> crewPostStats(Ref ref, String crewId) async {
  final feedService = ref.watch(feedServiceProvider);
  return await feedService.getCrewPostStats(crewId);
}

// Helper function to convert ReactionType to emoji
String _reactionTypeToEmoji(ReactionType reactionType) {
  switch (reactionType) {
    case ReactionType.like:
      return '👍';
    case ReactionType.love:
      return '❤️';
    case ReactionType.celebrate:
      return '🎉';
    case ReactionType.thumbsUp:
      return '👍';
    case ReactionType.thumbsDown:
      return '👎';
  }
}

/// Provider to get reaction counts for a post
@riverpod
Future<Map<ReactionType, int>> postReactionCounts(Ref ref, String postId) async {
  try {
    final emojiCounts = await ref.watch(feedServiceProvider).getPostReactionCounts(postId);

    // Convert Firestore data to ReactionType map
    final reactionCounts = <ReactionType, int>{};
    final emojiMap = {
      '👍': ReactionType.like,
      '❤️': ReactionType.love,
      '🎉': ReactionType.celebrate,
      '👎': ReactionType.thumbsDown,
    };

    emojiCounts.forEach((emoji, count) {
      final reactionType = emojiMap[emoji];
      if (reactionType != null) {
        reactionCounts[reactionType] = count;
      }
    });

    return reactionCounts;
  } catch (e, stack) {
  ref.read(core_providers.coreErrorReporterProvider).report('postReactionCounts', e, stack, 'postId: $postId');
    rethrow;
  }
}

/// Provider to check if current user has reacted to a post
@riverpod
Future<bool> userReactionToPost(Ref ref, String postId, ReactionType reactionType) async {
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  if (currentUser == null) return false;

  try {
    return await ref.watch(feedServiceProvider).hasUserReacted(
      postId,
      currentUser.uid,
      _reactionTypeToEmoji(reactionType),
    );
  } catch (e, stack) {
  ref.read(core_providers.coreErrorReporterProvider).report('userReactionToPost', e, stack, 'postId: $postId, reactionType: $reactionType');
    rethrow;
  }
}
