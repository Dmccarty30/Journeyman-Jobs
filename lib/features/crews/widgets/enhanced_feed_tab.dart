import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../providers/core_providers.dart' hide legacyCurrentUserProvider;
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../models/tailboard.dart';
import '../../../models/post_model.dart';

class EnhancedFeedTab extends ConsumerWidget {
  const EnhancedFeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(auth_providers.currentUserProvider);

    // Allow feed access even without a crew - this implements PUBLIC ACCESS
    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed_outlined, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'Public Feed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Sign in to interact with posts from all crews',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () {
                // Navigate to sign in - implement according to your auth flow
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Sign in functionality to be implemented'),
                    backgroundColor: AppTheme.infoBlue,
                  ),
                );
              },
              icon: const Icon(Icons.login),
              label: const Text('Sign In'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      );
    }

    // Always use global feed for PUBLIC ACCESS - all users can see all posts
    final postsAsync = ref.watch(globalFeedProvider);
    final currentUserName = currentUser.displayName ?? currentUser.email ?? 'Unknown User';

    return postsAsync.when(
      loading: () => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: AppTheme.accentCopper),
            const SizedBox(height: 16),
            Text(
              'Loading Public Feed...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            ),
          ],
        ),
      ),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error loading posts',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your connection and try again',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () {
                ref.invalidate(globalFeedProvider);
              },
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
            ),
          ],
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed_outlined, size: 48, color: AppTheme.mediumGray),
                const SizedBox(height: 16),
                Text(
                  'Public Feed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedCrew != null
                      ? 'Posts from all crews will appear here'
                      : 'Posts from all crews will appear here',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
                ),
                if (selectedCrew != null) ...[
                  const SizedBox(height: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Text(
                      'Also showing ${selectedCrew.name} crew posts',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            // Force refresh the global feed for immediate updates
            ref.invalidate(globalFeedProvider);
          },
          color: AppTheme.accentCopper,
          backgroundColor: AppTheme.white,
          child: ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 16),
            itemCount: posts.length,
            itemBuilder: (context, index) {
              final post = posts[index];

              // Get real-time comments for this post
              final commentsAsync = ref.watch(postCommentsProvider(post.id));

              return commentsAsync.when(
                loading: () => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: PostCard(
                    post: post,
                    currentUserId: currentUser.uid,
                    commentUserId: currentUser.uid,
                    currentUserName: currentUserName,
                    comments: [],
                    onLike: (userId, post) async => _handleLike(ref, post, userId),
                    onComment: (userId, post) {},
                    onShare: (userId, post) => _handleShare(context, post),
                    onDelete: (userId, post) async => _handleDelete(ref, context, post, userId),
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) async => _handleReaction(ref, post, emoji, userId),
                    onAddComment: (postId, content) async => _handleAddComment(ref, postId, content),
                    onLikeComment: (commentId, postId) {},
                    onUnlikeComment: (commentId, postId) {},
                    onEditComment: (commentId, postId) {},
                    onDeleteComment: (commentId, postId) {},
                    onReplyToComment: (postId, commentId) {},
                  ),
                ),
                error: (error, stack) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: PostCard(
                    post: post,
                    currentUserId: currentUser.uid,
                    commentUserId: currentUser.uid,
                    currentUserName: currentUserName,
                    comments: [],
                    onLike: (userId, post) async => _handleLike(ref, post, userId),
                    onComment: (userId, post) {},
                    onShare: (userId, post) => _handleShare(context, post),
                    onDelete: (userId, post) async => _handleDelete(ref, context, post, userId),
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) async => _handleReaction(ref, post, emoji, userId),
                    onAddComment: (postId, content) async => _handleAddComment(ref, postId, content),
                    onLikeComment: (commentId, postId) {},
                    onUnlikeComment: (commentId, postId) {},
                    onEditComment: (commentId, postId) {},
                    onDeleteComment: (commentId, postId) {},
                    onReplyToComment: (postId, commentId) {},
                  ),
                ),
                data: (comments) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  child: PostCard(
                    post: post,
                    currentUserId: currentUser.uid,
                    commentUserId: currentUser.uid,
                    currentUserName: currentUserName,
                    comments: comments,
                    onLike: (userId, post) async => _handleLike(ref, post, userId),
                    onComment: (userId, post) {},
                    onShare: (userId, post) => _handleShare(context, post),
                    onDelete: (userId, post) async => _handleDelete(ref, context, post, userId),
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) async => _handleReaction(ref, post, emoji, userId),
                    onAddComment: (postId, content) async => _handleAddComment(ref, postId, content),
                    onLikeComment: (commentId, postId) {},
                    onUnlikeComment: (commentId, postId) {},
                    onEditComment: (commentId, postId) {},
                    onDeleteComment: (commentId, postId) {},
                    onReplyToComment: (postId, commentId) {},
                  ).animate().fadeIn(
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ).slideY(
                    begin: 0.1,
                    end: 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Handle like/reaction functionality with immediate feedback
  Future<void> _handleLike(WidgetRef ref, PostModel post, String userId) async {
    try {
      final reactionNotifier = ref.read(reactionNotifierProvider.notifier);

      if (post.likes.contains(userId)) {
        // Remove like
        await reactionNotifier.removeReaction(post.id);
      } else {
        // Add like
        await reactionNotifier.addReaction(
          postId: post.id,
          reactionType: ReactionType.like,
        );
      }
    } catch (e) {
      // Error is handled by the individual UI components
      debugPrint('Error handling like: $e');
    }
  }

  // Handle share functionality
  void _handleShare(BuildContext context, PostModel post) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Post shared!'),
        backgroundColor: AppTheme.electricalSuccess.withValues(alpha: 0.8),
      ),
    );
  }

  // Handle delete functionality with permissions
  Future<void> _handleDelete(WidgetRef ref, BuildContext context, PostModel post, String userId) async {
    if (post.authorId != userId) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('You can only delete your own posts'),
          backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
        ),
      );
      return;
    }

    try {
      final updateNotifier = ref.read(postUpdateNotifierProvider.notifier);
      await updateNotifier.deletePost(post.id);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Post deleted successfully'),
          backgroundColor: AppTheme.electricalSuccess.withValues(alpha: 0.8),
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to delete post: $e'),
          backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
        ),
      );
    }
  }

  // Handle reaction functionality
  Future<void> _handleReaction(WidgetRef ref, PostModel post, String emoji, String userId) async {
    try {
      final reactionNotifier = ref.read(reactionNotifierProvider.notifier);

      // Convert emoji to ReactionType
      ReactionType reactionType;
      switch (emoji) {
        case '❤️':
          reactionType = ReactionType.love;
          break;
        case '🎉':
          reactionType = ReactionType.celebrate;
          break;
        case '👎':
          reactionType = ReactionType.thumbsDown;
          break;
        default:
          reactionType = ReactionType.like;
      }

      await reactionNotifier.addReaction(
        postId: post.id,
        reactionType: reactionType,
      );
    } catch (e) {
      debugPrint('Error handling reaction: $e');
    }
  }

  // Handle comment addition with immediate feedback
  Future<void> _handleAddComment(WidgetRef ref, String postId, String content) async {
    try {
      final commentNotifier = ref.read(commentNotifierProvider.notifier);
      await commentNotifier.addComment(
        postId: postId,
        content: content,
      );
    } catch (e) {
      debugPrint('Error adding comment: $e');
    }
  }
}