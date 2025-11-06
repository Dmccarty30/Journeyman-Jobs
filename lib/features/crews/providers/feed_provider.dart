// lib/features/crews/providers/feed_provider.dart
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/post_model.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;

part 'feed_provider.g.dart';

/// Enum for feed sort options
enum FeedSortOption {
  newestFirst,
  oldestFirst,
  mostLiked,
}

/// State class for feed filters and sort options
class FeedFilterState {
  /// Whether to show only the current user's posts
  final bool showMyPostsOnly;

  /// Current sort option for the feed
  final FeedSortOption sortOption;

  /// Whether to show archived posts
  final bool showArchived;

  const FeedFilterState({
    this.showMyPostsOnly = false,
    this.sortOption = FeedSortOption.newestFirst,
    this.showArchived = false,
  });

  FeedFilterState copyWith({
    bool? showMyPostsOnly,
    FeedSortOption? sortOption,
    bool? showArchived,
  }) {
    return FeedFilterState(
      showMyPostsOnly: showMyPostsOnly ?? this.showMyPostsOnly,
      sortOption: sortOption ?? this.sortOption,
      showArchived: showArchived ?? this.showArchived,
    );
  }

  /// Check if any filters are active
  bool get hasActiveFilters => showMyPostsOnly || showArchived;

  /// Get filter summary text for display
  String getFilterSummary() {
    final filters = <String>[];
    if (showMyPostsOnly) filters.add('My Posts');
    if (showArchived) filters.add('Archived');

    final sortText = switch (sortOption) {
      FeedSortOption.newestFirst => 'Newest First',
      FeedSortOption.oldestFirst => 'Oldest First',
      FeedSortOption.mostLiked => 'Most Liked',
    };

    filters.add('Sort: $sortText');

    return filters.join(' • ');
  }
}

/// Provider for feed filter state
@riverpod
class FeedFilter extends _$FeedFilter {
  @override
  FeedFilterState build() => const FeedFilterState();

  /// Toggle showing only current user's posts
  void toggleMyPostsOnly() {
    state = state.copyWith(showMyPostsOnly: !state.showMyPostsOnly);
  }

  /// Set the sort option
  void setSortOption(FeedSortOption option) {
    state = state.copyWith(sortOption: option);
  }

  /// Toggle showing archived posts
  void toggleArchived() {
    state = state.copyWith(showArchived: !state.showArchived);
  }

  /// Clear all filters (but keep sort option)
  void clearFilters() {
    state = FeedFilterState(sortOption: state.sortOption);
  }
}

/// Stream provider for crew posts with real-time updates
@riverpod
Stream<List<Post>> crewPostsStream(Ref ref, String crewId) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('posts')
      .where('crewId', isEqualTo: crewId)
      .orderBy('createdAt', descending: true)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList());
}

/// Provider for crew posts (converts stream to AsyncValue)
@riverpod
Future<List<Post>> crewPosts(Ref ref, String crewId) async {
  final stream = ref.watch(crewPostsStreamProvider(crewId));
  return await stream.first;
}

/// Stream provider for global feed with real-time updates
@riverpod
Stream<List<Post>> globalFeedStream(Ref ref) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('posts')
      .where('crewId', isNull: true)
      .orderBy('createdAt', descending: true)
      .limit(100) // Limit global feed to prevent overwhelming data
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => Post.fromFirestore(doc))
          .toList());
}

/// Provider for global feed (converts stream to AsyncValue)
@riverpod
Stream<List<Post>> globalFeed(Ref ref) {
  return ref.watch(globalFeedStreamProvider);
}

/// Provider for filtered and sorted posts based on crew or global context
@riverpod
List<Post> filteredPosts(Ref ref, String? crewId) {
  // Get posts from crew or global feed
  final postsAsync = crewId != null
      ? ref.watch(crewPostsStreamProvider(crewId))
      : ref.watch(globalFeedStreamProvider);

  // Get current user for filtering
  final currentUser = ref.watch(auth_providers.currentUserProvider);
  final currentUserId = currentUser?.uid;

  // Get filter state
  final filterState = ref.watch(feedFilterProvider);

  // Handle async state - return empty list if loading or error
  return postsAsync.when(
    data: (posts) {
      var filteredPosts = posts;

      // Apply "My Posts Only" filter
      if (filterState.showMyPostsOnly && currentUserId != null) {
        filteredPosts = filteredPosts
            .where((post) => post.userId == currentUserId)
            .toList();
      }

      // Apply archived filter
      if (!filterState.showArchived) {
        filteredPosts = filteredPosts
            .where((post) => !post.isArchived)
            .toList();
      }

      // Apply sort
      switch (filterState.sortOption) {
        case FeedSortOption.newestFirst:
          filteredPosts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
          break;
        case FeedSortOption.oldestFirst:
          filteredPosts.sort((a, b) => a.createdAt.compareTo(b.createdAt));
          break;
        case FeedSortOption.mostLiked:
          filteredPosts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
          break;
      }

      return filteredPosts;
    },
    loading: () => [],
    error: (_, __) => [],
  );
}

/// Stream provider for post comments with real-time updates
@riverpod
Stream<List<PostComment>> postCommentsStream(Ref ref, String postId) {
  final firestore = FirebaseFirestore.instance;

  return firestore
      .collection('posts')
      .doc(postId)
      .collection('comments')
      .orderBy('createdAt', descending: false)
      .snapshots()
      .map((snapshot) => snapshot.docs
          .map((doc) => PostComment.fromFirestore(doc))
          .toList());
}

/// Provider for post comments (converts stream to AsyncValue)
@riverpod
Stream<List<PostComment>> postComments(Ref ref, String postId) {
  return ref.watch(postCommentsStreamProvider(postId));
}

/// Provider to check if any filters are active
@riverpod
bool hasActiveFeedFilters(Ref ref) {
  final filterState = ref.watch(feedFilterProvider);
  return filterState.hasActiveFilters;
}

/// Provider to get filter summary text
@riverpod
String feedFilterSummary(Ref ref) {
  final filterState = ref.watch(feedFilterProvider);
  return filterState.getFilterSummary();
}

/// Provider for archived posts (history)
@riverpod
Future<List<Post>> archivedPosts(Ref ref, String? crewId) async {
  final firestore = FirebaseFirestore.instance;

  Query query = firestore
      .collection('posts')
      .where('isArchived', isEqualTo: true)
      .orderBy('updatedAt', descending: true)
      .limit(50);

  if (crewId != null) {
    query = query.where('crewId', isEqualTo: crewId);
  }

  final snapshot = await query.get();
  return snapshot.docs
      .map((doc) => Post.fromFirestore(doc))
      .toList();
}
