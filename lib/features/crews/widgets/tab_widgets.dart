import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../providers/core_providers.dart' hide legacyCurrentUserProvider;
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../widgets/post_card.dart';
import '../../../models/job_model.dart';
import '../../../widgets/rich_text_job_card.dart';
import '../../../widgets/dialogs/job_details_dialog.dart';
import '../../../electrical_components/jj_electrical_toast.dart';
import '../providers/crew_jobs_riverpod_provider.dart';
import '../../../screens/crew/crew_chat_screen.dart';

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

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  final ScrollController _scrollController = ScrollController();
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Handle infinite scrolling if needed in the future
  }

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(job: job),
    );
  }

  void _handleBidAction(Job job) {
    // TODO: Handle bid action for crew jobs
    JJElectricalToast.showInfo(context: context, message: 'Bidding on job at ${job.company}');
  }

  List<Job> _getFilteredJobs(List<Job> jobs) {
    if (_searchQuery.isEmpty) return jobs;

    final query = _searchQuery.trim().toLowerCase();
    return jobs.where((job) {
      final company = job.company.toLowerCase();
      final location = job.location.toLowerCase();
      final jobTitle = job.jobTitle?.toLowerCase() ?? '';
      final typeOfWork = job.typeOfWork?.toLowerCase() ?? '';

      return company.contains(query) ||
             location.contains(query) ||
             jobTitle.contains(query) ||
             typeOfWork.contains(query);
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    // If no crew is selected, show a prompt to select a crew
    if (selectedCrew == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.work_outline, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'No crew selected',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a crew to view job opportunities matching your crew preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Watch crew data and crew filtered jobs using the real-time job matching service
    final crewAsync = ref.watch(crewByIdProvider(selectedCrew.id));
    final crewJobsAsync = ref.watch(crewFilteredJobsStreamProvider(selectedCrew.id));
    final isLoading = ref.watch(isCrewJobsLoadingProvider(selectedCrew.id));
    final error = ref.watch(crewJobsErrorProvider(selectedCrew.id));

    final crew = crewAsync;
    if (crew == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error_outline, size: 48, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Crew not found',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Unable to load crew data',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return Column(
          children: [
            // Crew info header
            Container(
              padding: const EdgeInsets.all(16),
              margin: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.08),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.work, color: AppTheme.accentCopper, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Jobs for ${crew.name}',
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Spacer(),
                      if (crew.preferences.jobTypes.isNotEmpty)
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppTheme.accentCopper.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${crew.preferences.jobTypes.length} preferences',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  if (crew.preferences.jobTypes.isNotEmpty) ...[
                    Text(
                      'Job Types: ${crew.preferences.jobTypes.join(', ')}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (crew.preferences.constructionTypes.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Construction Types: ${crew.preferences.constructionTypes.join(', ')}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (crew.preferences.minHourlyRate != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Min Rate: \$${crew.preferences.minHourlyRate!.toStringAsFixed(2)}/hr',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                  if (crew.preferences.maxDistanceMiles != null) ...[
                    const SizedBox(height: 4),
                    Text(
                      'Max Distance: ${crew.preferences.maxDistanceMiles} miles',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ],
              ),
            ),

        // Search bar
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: TextField(
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
            decoration: InputDecoration(
              hintText: 'Search jobs...',
              prefixIcon: Icon(Icons.search, color: AppTheme.accentCopper),
              filled: true,
              fillColor: AppTheme.white,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
              ),
              enabledBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(
                  color: AppTheme.accentCopper.withValues(alpha: 0.5),
                  width: AppTheme.borderWidthCopperThin,
                ),
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
              ),
              contentPadding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingMd,
              ),
            ),
          ),
        ),

        const SizedBox(height: 8),

        // Jobs list
        Expanded(
          child: crewJobsAsync.when(
            loading: () => isLoading && _searchQuery.isEmpty
                ? const Center(child: CircularProgressIndicator())
                : const SizedBox.shrink(),
            error: (error, stack) => Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.error_outline, size: 48, color: Colors.red),
                  const SizedBox(height: 16),
                  Text(
                    'Error loading crew jobs',
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    error.toString(),
                    style: Theme.of(context).textTheme.bodyMedium,
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  ElevatedButton(
                    onPressed: () => ref.invalidate(crewFilteredJobsStreamProvider(selectedCrew.id)),
                    child: const Text('Retry'),
                  ),
                ],
              ),
            ),
            data: (jobs) {
              final filteredJobs = _getFilteredJobs(jobs);

              if (filteredJobs.isEmpty) {
                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.work_outline, size: 48, color: AppTheme.mediumGray),
                      const SizedBox(height: 16),
                      Text(
                        _searchQuery.isNotEmpty ? 'No matching jobs found' : 'No jobs available',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        _searchQuery.isNotEmpty
                            ? 'Try adjusting your search terms'
                            : 'Jobs matching your crew preferences will appear here',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                        textAlign: TextAlign.center,
                      ),
                      if (_searchQuery.isNotEmpty) ...[
                        const SizedBox(height: 16),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              _searchQuery = '';
                            });
                          },
                          child: const Text('Clear Search'),
                        ),
                      ],
                    ],
                  ),
                );
              }

              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(crewFilteredJobsStreamProvider(selectedCrew.id));
                },
                color: AppTheme.accentCopper,
                backgroundColor: AppTheme.white,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return RichTextJobCard(
                      job: job,
                      onDetails: () => _showJobDetails(job),
                      onBid: () => _handleBidAction(job),
                    ).animate().fadeIn(
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    ).slideY(
                      begin: 0.1,
                      end: 0,
                      duration: const Duration(milliseconds: 300),
                      curve: Curves.easeInOut,
                    );
                  },
                ),
              );
            },
          ),
        ),
        ],
      );
  }
}

class ChatTab extends ConsumerWidget {
  const ChatTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    // If no crew is selected, show a prompt to select a crew
    if (selectedCrew == null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.chat_bubble_outline, size: 48, color: AppTheme.mediumGray),
            const SizedBox(height: 16),
            Text(
              'Select a Crew',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 8),
            Text(
              'Select a crew to view direct messaging and group chat',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    // Navigate to the actual CrewChatScreen
    return CrewChatScreen(
      crewId: selectedCrew.id,
      crewName: selectedCrew.name,
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
                              // Navigate to crew chat with member context
                              Navigator.pushNamed(
                                context,
                                '/crews/chat/${selectedCrew.id}',
                                arguments: {
                                  'crewId': selectedCrew.id,
                                  'crewName': selectedCrew.name,
                                  'directMessageTo': member.userId,
                                  'memberName': (member.customTitle ?? member.role.toString().split('.').last),
                                },
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
