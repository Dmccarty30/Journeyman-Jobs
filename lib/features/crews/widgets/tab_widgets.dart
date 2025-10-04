import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../../../models/post_model.dart';
import '../models/tailboard.dart';
import '../widgets/post_card.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'Select a crew to view team updates and announcements',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Team updates and announcements for your crew will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Watch for real-time posts
    final posts = ref.watch(crewPostsProvider(selectedCrew.id));
    final currentUserName = currentUser.displayName ?? currentUser.email ?? 'Unknown User';

    if (posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'Feed for ${selectedCrew.name}',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Team updates and announcements for ${selectedCrew.name} will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        // Force refresh the posts provider
        ref.invalidate(crewPostsStreamProvider(selectedCrew.id));
      },
      color: AppTheme.accentCopper,
      backgroundColor: AppTheme.white,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(vertical: 16),
        itemCount: posts.length,
        itemBuilder: (context, index) {
          final post = posts[index];
          
          // Get real-time comments for this post
          final comments = ref.watch(postCommentsProvider(post.id));
          
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: PostCard(
              post: post,
              currentUserId: currentUser.uid,
              commentUserId: currentUser.uid,
              currentUserName: currentUserName,
              comments: comments,
              onLike: (userId, post) {
                // Use the reaction notifier for liking posts
                ref.read(reactionNotifierProvider.notifier).addReaction(
                  postId: post.id,
                  reactionType: ReactionType.like,
                );
              },
              onComment: (userId, post) {
                // Toggle comments visibility will be handled by PostCard
                // This is just a callback to track when comments are shown
              },
              onShare: (userId, post) {
                // Implement share functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Post shared!'),
                    backgroundColor: AppTheme.electricalSuccess.withOpacity(0.8),
                  ),
                );
              },
              onDelete: (userId, post) {
                if (post.authorId == userId) {
                  ref.read(postUpdateNotifierProvider.notifier).deletePost(post.id);
                }
              },
              onEdit: (userId, post) {
                if (post.authorId == userId) {
                  _showEditPostDialog(context, ref, post);
                }
              },
              onReaction: (userId, emoji, post) {
                // Add reaction functionality
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('Reaction added: $emoji'),
                    backgroundColor: AppTheme.accentCopper.withOpacity(0.8),
                  ),
                );
              },
              onAddComment: (postId, content) {
                ref.read(commentNotifierProvider.notifier).addComment(
                  postId: postId,
                  content: content,
                );
              },
              onLikeComment: (commentId, postId) {
                // Implement like comment functionality
              },
              onUnlikeComment: (commentId, postId) {
                // Implement unlike comment functionality
              },
              onEditComment: (commentId, postId) {
                // Implement edit comment functionality
              },
              onDeleteComment: (commentId, postId) {
                ref.read(commentNotifierProvider.notifier).deleteComment(
                  postId: postId,
                  commentId: commentId,
                );
              },
              onReplyToComment: (postId, commentId) {
                // Implement reply to comment functionality
              },
            ).animate().fadeIn(
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ).slideY(
              begin: 0.1,
              end: 0,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeInOut,
            ),
          );
        },
      ),
    );
  }

  void _showEditPostDialog(BuildContext context, WidgetRef ref, PostModel post) {
    final TextEditingController controller = TextEditingController(text: post.content);
    
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Post'),
        content: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            hintText: 'Edit your post...',
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.borderCopperLight),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              borderSide: BorderSide(color: AppTheme.accentCopper),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('Cancel', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(postUpdateNotifierProvider.notifier).updatePost(
                postId: post.id,
                content: controller.text,
              );
            },
            child: Text('Save', style: TextStyle(color: AppTheme.accentCopper)),
          ),
        ],
      ),
    );
  }
}

class JobsTab extends ConsumerWidget {
  const JobsTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.work_outline, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Jobs for ${selectedCrew.name}' : 'Jobs Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Shared job opportunities for ${selectedCrew.name} appear here'
                : 'Select a crew to view shared job opportunities',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Chat for ${selectedCrew.name}' : 'Chat Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Direct messaging and group chat for ${selectedCrew.name} appear here'
                : 'Select a crew to view direct messaging and group chat',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

class MembersTab extends ConsumerWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.people_alt_outlined, size: 48, color: AppTheme.mediumGray),
          const SizedBox(height: 16),
          Text(
            selectedCrew != null ? 'Members of ${selectedCrew.name}' : 'Members Tab Content',
            style: Theme.of(context).textTheme.titleLarge,
          ),
          const SizedBox(height: 8),
          Text(
            selectedCrew != null
                ? 'Crew member information for ${selectedCrew.name} appears here'
                : 'Select a crew to view crew member information',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}