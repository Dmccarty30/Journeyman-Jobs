import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../providers/core_providers.dart' hide legacyCurrentUserProvider;
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(auth_providers.currentUserProvider);

    // Allow feed access even without a crew
    if (currentUser == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.feed, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'Please sign in to view the feed',
              style: Theme.of(context).textTheme.titleLarge,
            ),
          ],
        ),
      );
    }

    // Watch for real-time posts - use global feed if no crew selected
    final postsAsync = selectedCrew != null
        ? ref.watch(crewPostsProvider(selectedCrew.id))
        : ref.watch(globalFeedProvider);
    final currentUserName = currentUser.displayName ?? currentUser.email ?? 'Unknown User';

    return postsAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading posts: $error'),
          ],
        ),
      ),
      data: (posts) {
        if (posts.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.feed, size: 48, color: AppTheme.mediumGray),
                const SizedBox(height: 16),
                Text(
                  selectedCrew != null ? 'Feed for ${selectedCrew.name}' : 'Global Feed',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  selectedCrew != null
                      ? 'Team updates and announcements for ${selectedCrew.name} will appear here'
                      : 'Posts from all crews will appear here',
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
            if (selectedCrew != null) {
              ref.invalidate(crewPostsStreamProvider(selectedCrew.id));
            } else {
              ref.invalidate(globalFeedProvider);
            }
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
                    onLike: (userId, post) {},
                    onComment: (userId, post) {},
                    onShare: (userId, post) {},
                    onDelete: (userId, post) {},
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) {},
                    onAddComment: (postId, content) {},
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
                    onLike: (userId, post) {},
                    onComment: (userId, post) {},
                    onShare: (userId, post) {},
                    onDelete: (userId, post) {},
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) {},
                    onAddComment: (postId, content) {},
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
                    onLike: (userId, post) {},
                    onComment: (userId, post) {},
                    onShare: (userId, post) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Post shared!'),
                          backgroundColor: AppTheme.electricalSuccess.withValues(alpha: 0.8),
                        ),
                      );
                    },
                    onDelete: (userId, post) {},
                    onEdit: (userId, post) {},
                    onReaction: (userId, emoji, post) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Reaction added: $emoji'),
                          backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.8),
                        ),
                      );
                    },
                    onAddComment: (postId, content) {},
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

    if (selectedCrew == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.people_alt_outlined, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'No crew selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a crew to view crew member information',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Get crew members stream
    final membersAsync = ref.watch(crewMembersStreamProvider(selectedCrew.id));

    return membersAsync.when(
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text('Error loading members: $error'),
          ],
        ),
      ),
      data: (members) {
        if (members.isEmpty) {
          return Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.group_outlined, size: 48, color: AppTheme.mediumGray),
                const SizedBox(height: 16),
                Text(
                  'No members yet',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                Text(
                  'Invite members to join ${selectedCrew.name}',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: members.length,
          itemBuilder: (context, index) {
            final member = members[index];
            return ListTile(
              leading: CircleAvatar(
                backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                child: Text(
                  (member.customTitle ?? member.role.toString().split('.').last).substring(0, 1).toUpperCase(),
                  style: TextStyle(color: AppTheme.accentCopper),
                ),
              ),
              title: Text(
                member.customTitle ?? member.role.toString().split('.').last.toUpperCase(),
                style: Theme.of(context).textTheme.titleMedium,
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Joined: ${member.joinedAt.toString().split(' ')[0]}'),
                  Text(member.isAvailable ? 'Available' : 'Unavailable'),
                ],
              ),
              trailing: IconButton(
                icon: Icon(Icons.message, color: AppTheme.accentCopper),
                onPressed: () {
                  // Show direct message option
                  showModalBottomSheet(
                    context: context,
                    builder: (context) => Container(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          ListTile(
                            leading: Icon(Icons.message, color: AppTheme.accentCopper),
                            title: Text('Direct Message'),
                            subtitle: Text('Send a private message to ${member.customTitle ?? member.role.toString().split('.').last}'),
                            onTap: () {
                              Navigator.pop(context);
                              // TODO: Navigate to direct message screen
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Direct messaging coming soon!'),
                                  backgroundColor: AppTheme.infoBlue,
                                ),
                              );
                            },
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            );
          },
        );
      },
    );
  }
}
