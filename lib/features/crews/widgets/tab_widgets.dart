import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';

// Design system
import '../../../design_system/tailboard_theme.dart';
import '../../../design_system/tailboard_components.dart';

// Providers
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../providers/riverpod/jobs_riverpod_provider.dart';
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/feed_filter_provider.dart';

// Models
import '../../../models/job_model.dart';
import '../models/crew_member.dart';
import '../models/message.dart';
import '../models/tailboard.dart';

// Widgets
import '../widgets/post_card.dart';
import '../widgets/chat_components.dart';
import '../widgets/tailboard/job_preferences_dialog.dart';
import '../widgets/tailboard/apply_job_dialog.dart';
import '../../../widgets/dialogs/job_details_dialog.dart';

// Services
import '../services/message_service.dart';

// ============================================================
// FILTER PROVIDERS
// ============================================================

// ============================================================
// FEED TAB - Universal Public Feed
// ============================================================

class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentUser = ref.watch(currentUserProvider);
    final feedFilter = ref.watch(feedFilterProvider);

    if (currentUser == null) {
      return const SingleChildScrollView(
        child: EmptyStateWidget(
          icon: Icons.login,
          title: 'Sign In Required',
          message: 'Please sign in to view and post to the public feed',
        ),
      );
    }

    // Watch the public/global feed (available to all users)
    final postsAsync = ref.watch(crewPostsStreamProvider('global'));

    return postsAsync.when(
      loading: () => const ElectricalLoadingIndicator(
        message: 'Loading Public Feed...',
      ),
      error: (error, stack) => SingleChildScrollView(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error Loading Feed',
          message: error.toString(),
        ),
      ),
      data: (posts) {
        // Apply filters
        var filteredPosts = posts;

        if (feedFilter.showMyPostsOnly) {
          filteredPosts =
              posts.where((p) => p.authorId == currentUser.uid).toList();
        }

        // Apply sorting
        switch (feedFilter.sortOption) {
          case FeedSortOption.recent:
            filteredPosts.sort((a, b) => b.timestamp.compareTo(a.timestamp));
            break;
          case FeedSortOption.oldest:
            filteredPosts.sort((a, b) => a.timestamp.compareTo(b.timestamp));
            break;
          case FeedSortOption.popular:
            filteredPosts.sort(
                (a, b) => (b.reactions.length).compareTo(a.reactions.length));
            break;
        }

        if (filteredPosts.isEmpty) {
          return const SingleChildScrollView(
            child: EmptyStateWidget(
              icon: Icons.feed,
              title: 'Feed is Empty',
              message: 'Be the first to post something!',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(crewPostsStreamProvider('global'));
          },
          color: TailboardTheme.copper,
          backgroundColor: TailboardTheme.backgroundCard,
          child: ListView.builder(
            padding: const EdgeInsets.all(TailboardTheme.spacingM),
            itemCount: filteredPosts.length,
            itemBuilder: (context, index) {
              final post = filteredPosts[index];
              final commentsAsync = ref.watch(postCommentsProvider(post.id));

              return commentsAsync.when(
                loading: () => _buildPostCard(
                    context, ref, post, <Comment>[], currentUser.uid),
                error: (_, __) => _buildPostCard(
                    context, ref, post, <Comment>[], currentUser.uid),
                data: (comments) => _buildPostCard(
                    context, ref, post, comments, currentUser.uid),
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildPostCard(
    BuildContext context,
    WidgetRef ref,
    post,
    List<Comment>? comments,
    String currentUserId,
  ) {
    final currentUserName =
        ref.read(currentUserProvider)?.displayName ?? 'User';

    return Padding(
      padding: const EdgeInsets.only(bottom: TailboardTheme.spacingM),
      child: PostCard(
        post: post,
        currentUserId: currentUserId,
        commentUserId: currentUserId,
        currentUserName: currentUserName,
        comments: comments,
        onLike: (userId, post) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Liked post!'),
              backgroundColor: TailboardTheme.copper,
              duration: const Duration(seconds: 1),
            ),
          );
        },
        onComment: (userId, post) {
          // Placeholder for comment interaction
        },
        onShare: (userId, post) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: const Text('Post shared!'),
              backgroundColor: TailboardTheme.success,
            ),
          );
        },
        onDelete: (userId, post) {},
        onEdit: (userId, post) {},
        onReaction: (userId, emoji, post) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Reaction added: $emoji'),
              backgroundColor: TailboardTheme.copper,
            ),
          );
        },
        onAddComment: (postId, content) {},
        onLikeComment: (commentId, postId) {},
        onUnlikeComment: (commentId, postId) {},
        onEditComment: (commentId, postId) {},
        onDeleteComment: (commentId, postId) {},
        onReplyToComment: (postId, commentId) {},
      ),
    ).animate().fadeIn(duration: 300.ms).slideY(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
        );
  }
}

// ============================================================
// JOBS TAB - Filtered Job Listings
// ============================================================

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showJobDetails(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(
        job: job,
        isDarkTheme: true,
      ),
    );
  }

  void _applyToJob(BuildContext context, Job job) {
    showDialog(
      context: context,
      builder: (context) => ApplyJobDialog(job: job),
    );
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final jobsState = ref.watch(jobsProvider);

    return Column(
      children: [
        // Preferences banner (if crew selected)
        if (selectedCrew != null) _buildPreferencesBanner(selectedCrew),

        // Search bar
        _buildSearchBar(),

        const SizedBox(height: TailboardTheme.spacingS),

        // Job list
        Expanded(
          child: jobsState.isLoading
              ? const ElectricalLoadingIndicator(
                  message: 'Loading jobs...',
                )
              : jobsState.error != null
                  ? SingleChildScrollView(
                      child: EmptyStateWidget(
                        icon: Icons.error_outline,
                        title: 'Error Loading Jobs',
                        message: jobsState.error!,
                      ),
                    )
                  : jobsState.jobs.isEmpty
                      ? const SingleChildScrollView(
                          child: EmptyStateWidget(
                            icon: Icons.work_outline,
                            title: 'No Jobs Found',
                            message:
                                'Try adjusting your filters or search criteria',
                          ),
                        )
                      : RefreshIndicator(
                          onRefresh: () async {
                            ref.invalidate(jobsProvider);
                          },
                          color: TailboardTheme.copper,
                          child: ListView.builder(
                            padding:
                                const EdgeInsets.all(TailboardTheme.spacingM),
                            itemCount: jobsState.jobs.length,
                            itemBuilder: (context, index) {
                              return _buildJobCard(jobsState.jobs[index]);
                            },
                          ),
                        ),
        ),
      ],
    );
  }

  Widget _buildPreferencesBanner(dynamic selectedCrew) {
    final preferencesCount = selectedCrew.preferences.jobTypes.length;

    return Container(
      margin: const EdgeInsets.all(TailboardTheme.spacingM),
      padding: const EdgeInsets.all(TailboardTheme.spacingM),
      decoration: TailboardTheme.cardDecoration(
        color: TailboardTheme.copper.withValues(alpha: 0.1),
      ),
      child: Row(
        children: [
          const Icon(Icons.work_outline, color: TailboardTheme.copper),
          const SizedBox(width: TailboardTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Jobs for ${selectedCrew.name}',
                  style: TailboardTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (selectedCrew.preferences.jobTypes.isNotEmpty)
                  Text(
                    'Job Types: ${selectedCrew.preferences.jobTypes.join(", ")}',
                    style: TailboardTheme.bodySmall,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
              ],
            ),
          ),
          TextButton(
            onPressed: () {
              showDialog(
                context: context,
                builder: (context) => JobPreferencesDialog(
                  crewId: selectedCrew.id,
                  initialPreferences: selectedCrew.preferences,
                ),
              );
            },
            child: Text(
              '$preferencesCount preferences',
              style: TailboardTheme.bodySmall.copyWith(
                color: TailboardTheme.copper,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingM,
      ),
      child: TextField(
        controller: _searchController,
        decoration: TailboardTheme.inputDecoration(
          hintText: 'Search jobs...',
          prefixIcon: const Icon(Icons.search, color: TailboardTheme.copper),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear,
                      color: TailboardTheme.textSecondary),
                  onPressed: () {
                    _searchController.clear();
                    setState(() {
                      _searchQuery = '';
                    });
                  },
                )
              : null,
        ),
        style: TailboardTheme.bodyMedium,
        onChanged: (value) {
          setState(() {
            _searchQuery = value;
          });
        },
      ),
    );
  }

  Widget _buildJobCard(Job job) {
    return Container(
      margin: const EdgeInsets.only(bottom: TailboardTheme.spacingM),
      padding: const EdgeInsets.all(TailboardTheme.spacingM),
      decoration: TailboardTheme.cardDecoration(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  job.jobTitle ?? job.company,
                  style: TailboardTheme.headingSmall,
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: TailboardTheme.spacingS,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: TailboardTheme.copper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(TailboardTheme.radiusS),
                ),
                child: Text(
                  job.classification ?? 'General',
                  style: TailboardTheme.labelSmall.copyWith(
                    color: TailboardTheme.copper,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: TailboardTheme.spacingS),
          _buildJobDetail(Icons.business, job.company),
          _buildJobDetail(Icons.location_on, job.location),
          if (job.local != null)
            _buildJobDetail(Icons.groups, 'Local ${job.local}'),
          if (job.wage != null)
            _buildJobDetail(
                Icons.attach_money, '\$${job.wage!.toStringAsFixed(2)}/hr'),
          if (job.hours != null)
            _buildJobDetail(Icons.access_time, '${job.hours} hrs/week'),
          const SizedBox(height: TailboardTheme.spacingM),
          Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: () => _showJobDetails(context, job),
                  style: TailboardTheme.secondaryButton,
                  child: const Text('Details'),
                ),
              ),
              const SizedBox(width: TailboardTheme.spacingS),
              Expanded(
                child: ElevatedButton(
                  onPressed: () => _applyToJob(context, job),
                  style: TailboardTheme.primaryButton,
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildJobDetail(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        children: [
          Icon(icon, size: 16, color: TailboardTheme.textSecondary),
          const SizedBox(width: TailboardTheme.spacingS),
          Expanded(
            child: Text(
              text,
              style: TailboardTheme.bodySmall,
            ),
          ),
        ],
      ),
    );
  }
}

// ============================================================
// CHAT TAB - Group Chat
// ============================================================

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  final ScrollController _scrollController = ScrollController();
  final MessageService _messageService = MessageService();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollToBottom() {
    if (_scrollController.hasClients) {
      Future.delayed(const Duration(milliseconds: 100), () {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return const SingleChildScrollView(
        child: EmptyStateWidget(
          icon: Icons.chat_bubble_outline,
          title: 'No Crew Selected',
          message: 'Select a crew to start chatting with your team',
        ),
      );
    }

    // Get messages stream
    return StreamBuilder<List<Message>>(
      stream: _messageService.getCrewMessagesStream(
          selectedCrew.id, currentUser.uid),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const ElectricalLoadingIndicator(
            message: 'Loading messages...',
          );
        }

        if (snapshot.hasError) {
          return SingleChildScrollView(
            child: EmptyStateWidget(
              icon: Icons.error_outline,
              title: 'Error Loading Messages',
              message: snapshot.error.toString(),
            ),
          );
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return Column(
            children: [
              const Expanded(
                child: EmptyStateWidget(
                  icon: Icons.forum,
                  title: 'No Messages Yet',
                  message: 'Send a message to connect with your crew',
                ),
              ),
              ChatInput(
                onSendMessage: (message) => _sendMessage(
                  selectedCrew.id,
                  currentUser.uid,
                  currentUser.displayName ?? 'User',
                  message,
                ),
              ),
            ],
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());

        return Column(
          children: [
            Expanded(
              child: ListView.builder(
                controller: _scrollController,
                padding: const EdgeInsets.all(TailboardTheme.spacingM),
                reverse: true, // Messages from bottom
                itemCount: messages.length,
                itemBuilder: (context, index) {
                  final message = messages[messages.length - 1 - index];
                  final isCurrentUser = message.senderId == currentUser.uid;

                  return MessageBubble(
                    message: message.content,
                    senderId: message.senderId,
                    senderName: _getSenderName(message),
                    timestamp: message.sentAt,
                    isCurrentUser: isCurrentUser,
                  );
                },
              ),
            ),
            ChatInput(
              onSendMessage: (message) => _sendMessage(
                selectedCrew.id,
                currentUser.uid,
                currentUser.displayName ?? 'User',
                message,
              ),
            ),
          ],
        );
      },
    );
  }

  String _getSenderName(Message message) {
    // Try to get name from message metadata
    if (message.senderId.isNotEmpty) {
      // In a real app, fetch from user profile
      return message.senderId; // Placeholder
    }
    return 'Unknown User';
  }

  Future<void> _sendMessage(
    String crewId,
    String senderId,
    String senderName,
    String content,
  ) async {
    try {
      await _messageService.sendCrewMessage(
        crewId: crewId,
        senderId: senderId,
        content: content,
      );
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: TailboardTheme.error,
          ),
        );
      }
    }
  }
}

// ============================================================
// MEMBERS TAB - Crew Member List
// ============================================================

class MembersTab extends ConsumerWidget {
  const MembersTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return const SingleChildScrollView(
        child: EmptyStateWidget(
          icon: Icons.people_outline,
          title: 'No Crew Selected',
          message: 'Select a crew to view members',
        ),
      );
    }

    final membersAsync = ref.watch(crewMembersStreamProvider(selectedCrew.id));

    return membersAsync.when(
      loading: () => const ElectricalLoadingIndicator(
        message: 'Loading members...',
      ),
      error: (error, stack) => SingleChildScrollView(
        child: EmptyStateWidget(
          icon: Icons.error_outline,
          title: 'Error Loading Members',
          message: error.toString(),
        ),
      ),
      data: (members) {
        if (members.isEmpty) {
          return const SingleChildScrollView(
            child: EmptyStateWidget(
              icon: Icons.person_add,
              title: 'No Members Yet',
              message: 'Invite people to join your crew',
            ),
          );
        }

        return RefreshIndicator(
          onRefresh: () async {
            ref.invalidate(crewMembersProvider(selectedCrew.id));
          },
          color: TailboardTheme.copper,
          child: ListView.builder(
            padding: const EdgeInsets.all(TailboardTheme.spacingM),
            itemCount: members.length,
            itemBuilder: (context, index) {
              return _buildMemberCard(context, members[index]);
            },
          ),
        );
      },
    );
  }

  Widget _buildMemberCard(BuildContext context, CrewMember member) {
    final joinedDate = DateFormat.yMMMd().format(member.joinedAt);

    return Container(
      margin: const EdgeInsets.only(bottom: TailboardTheme.spacingM),
      padding: const EdgeInsets.all(TailboardTheme.spacingM),
      decoration: TailboardTheme.cardDecoration(),
      child: Row(
        children: [
          Stack(
            children: [
              CircleAvatar(
                radius: 28,
                backgroundColor: TailboardTheme.copper.withValues(alpha: 0.2),
                child: Text(
                  member.userId[0].toUpperCase(),
                  style: TailboardTheme.headingMedium.copyWith(
                    color: TailboardTheme.copper,
                  ),
                ),
              ),
              Positioned(
                right: 0,
                bottom: 0,
                child: Container(
                  width: 14,
                  height: 14,
                  decoration: BoxDecoration(
                    color: member.isActive
                        ? TailboardTheme.success
                        : TailboardTheme.textTertiary,
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: TailboardTheme.backgroundCard,
                      width: 2,
                    ),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(width: TailboardTheme.spacingM),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'User ${member.userId.substring(0, 8)}',
                  style: TailboardTheme.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Joined $joinedDate',
                  style: TailboardTheme.bodySmall,
                ),
                if (member.role.toString() != 'MemberRole.member')
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: TailboardTheme.spacingS,
                      vertical: 2,
                    ),
                    decoration: BoxDecoration(
                      color: TailboardTheme.success.withValues(alpha: 0.1),
                      borderRadius:
                          BorderRadius.circular(TailboardTheme.radiusS),
                    ),
                    child: Text(
                      member.role.toString().split('.').last.toUpperCase(),
                      style: TailboardTheme.labelSmall.copyWith(
                        color: TailboardTheme.success,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TailboardTheme.spacingM,
              vertical: TailboardTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: member.isAvailable
                  ? TailboardTheme.success.withValues(alpha: 0.1)
                  : TailboardTheme.backgroundDark,
              borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
              border: Border.all(
                color: member.isAvailable
                    ? TailboardTheme.success
                    : TailboardTheme.border,
              ),
            ),
            child: Text(
              member.isAvailable ? 'Available' : 'Away',
              style: TailboardTheme.labelSmall.copyWith(
                color: member.isAvailable
                    ? TailboardTheme.success
                    : TailboardTheme.textTertiary,
              ),
            ),
          ),
          const SizedBox(width: TailboardTheme.spacingS),
          IconButton(
            icon: const Icon(Icons.message, color: TailboardTheme.copper),
            onPressed: () {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                      'Start chat with User ${member.userId.substring(0, 8)} (Coming Soon)'),
                  backgroundColor: TailboardTheme.info,
                ),
              );
            },
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms).slideX(
          begin: 0.1,
          end: 0,
          duration: 300.ms,
        );
  }
}
