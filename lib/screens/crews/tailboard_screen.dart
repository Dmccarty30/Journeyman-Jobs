import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/features/crews/widgets/job_match_card.dart';
import 'package:riverpod/src/framework.dart';
import '../../features/crews/providers/crews_riverpod_provider.dart';
import '../../features/crews/providers/tailboard_riverpod_provider.dart';
import '../../features/crews/models/models.dart';
import '../../features/crews/widgets/activity_card.dart';
import '../../features/crews/widgets/announcement_card.dart';
import '../../features/crews/widgets/message_bubble.dart';
import '../../features/crews/widgets/chat_input.dart';
import '../../features/crews/widgets/crew_member_avatar.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../design_system/app_theme.dart';
import '../../navigation/app_router.dart';

class TailboardScreen extends ConsumerStatefulWidget {
  const TailboardScreen({super.key});

  @override
  ConsumerState<TailboardScreen> createState() => _TailboardScreenState();
}

class _TailboardScreenState extends ConsumerState<TailboardScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    super.dispose();
  }

  void _handleTabSelection() {
    if (_tabController.index != _selectedTab) {
      setState(() {
        _selectedTab = _tabController.index;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: Column(
        children: [
          // Header - conditional based on crew
          selectedCrew != null 
            ? _buildHeader(context, selectedCrew)
            : _buildNoCrewHeader(context),
          _buildTabBar(),
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: const [
                FeedTab(),
                JobsTab(),
                ChatTab(),
                MembersTab(),
              ],
            ),
          ),
        ],
      ),
      floatingActionButton: selectedCrew != null ? _buildFloatingActionButton() : null,
    );
  }

  Widget _buildNoCrewHeader(BuildContext context) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          Icon(
            Icons.group_outlined,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Welcome to the Tailboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),
          Text(
            'This is your crew hub for messaging, job sharing, and team coordination. You can access direct messaging even without a crew.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 24),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouter.crewOnboarding);
              },
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text('Create or Join a Crew', style: TextStyle(color: AppTheme.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Crew crew) {
    return Container(
      color: AppTheme.white,
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          Row(
            children: [
              // Crew Avatar/Logo
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Icon(
                  Icons.group,
                  color: AppTheme.accentCopper,
                  size: 28,
                ),
              ),
              const SizedBox(width: 12),
              // Crew Info
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      crew.name,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                        fontWeight: FontWeight.bold,
                        color: AppTheme.textPrimary,
                      ),
                    ),
                    Text(
                      '${crew.memberIds.length} members',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              // Quick Actions
              Row(
                children: [
                  IconButton(
                    onPressed: () => _showQuickActions(context),
                    icon: Icon(
                      Icons.more_vert,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Quick Stats Row
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Jobs',
                crew.stats.totalJobsShared.toString(),
                Icons.work_outline,
              ),
              _buildStatItem(
                context,
                'Applications',
                crew.stats.totalApplications.toString(),
                Icons.assignment_turned_in_outlined,
              ),
              _buildStatItem(
                context,
                'Score',
                '${crew.stats.averageMatchScore.toStringAsFixed(0)}%',
                Icons.analytics_outlined,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: AppTheme.mediumGray,
        indicatorColor: AppTheme.accentCopper,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.feed_outlined),
            text: 'Feed',
          ),
          Tab(
            icon: Icon(Icons.work_outline),
            text: 'Jobs',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble_outline),
            text: 'Chat',
          ),
          Tab(
            icon: Icon(Icons.people_outline),
            text: 'Members',
          ),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    switch (_selectedTab) {
      case 0: // Feed
        return FloatingActionButton(
          onPressed: () => _showCreatePostDialog(),
          backgroundColor: AppTheme.accentCopper,
          child: const Icon(Icons.add, color: AppTheme.white),
        );
      case 1: // Jobs
        return FloatingActionButton(
          onPressed: () => _showShareJobDialog(),
          backgroundColor: AppTheme.accentCopper,
          child: const Icon(Icons.share, color: AppTheme.white),
        );
      case 2: // Chat
        return FloatingActionButton(
          onPressed: () => _showNewMessageDialog(),
          backgroundColor: AppTheme.accentCopper,
          child: const Icon(Icons.message, color: AppTheme.white),
        );
      default:
        return null;
    }
  }

  void _showQuickActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.settings),
              title: const Text('Crew Settings'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to crew settings
              },
            ),
            ListTile(
              leading: const Icon(Icons.person_add),
              title: const Text('Invite Members'),
              onTap: () {
                Navigator.pop(context);
                // Show invite members dialog
              },
            ),
            ListTile(
              leading: const Icon(Icons.analytics),
              title: const Text('View Analytics'),
              onTap: () {
                Navigator.pop(context);
                // Navigate to analytics
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showCreatePostDialog() {
    // Implement create post dialog
  }

  void _showShareJobDialog() {
    // Implement share job dialog
  }

  void _showNewMessageDialog() {
    // Implement new message dialog
  }
}

// Placeholder widgets for tabs - these will be implemented in subsequent tasks
class FeedTab extends ConsumerWidget {
  const FeedTab({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return const Center(
        child: Text('No crew selected'),
      );
    }

    final activities = ref.watch(activityItemsProvider(selectedCrew.id));
    final posts = ref.watch(tailboardPostsProvider(selectedCrew.id));
    final pinnedPosts = posts.where((post) => post.isPinned).toList();
    final recentPosts = posts.where((post) => !post.isPinned).toList();

    if (activities.isEmpty && posts.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.feed_outlined,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No activity yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Activity and announcements will appear here',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Pinned announcements
          if (pinnedPosts.isNotEmpty)
            Column(
              children: pinnedPosts.map((post) {
                return AnnouncementCard(
                  post: post,
                  currentUserId: currentUser.uid,
                );
              }).toList(),
            ),
          // Recent activities
          if (activities.isNotEmpty)
            Column(
              children: activities.map((activity) {
                return ActivityCard(
                  activity: activity,
                  currentUserId: currentUser.uid,
                );
              }).toList(),
            ),
          // Recent announcements
          if (recentPosts.isNotEmpty)
            Column(
              children: recentPosts.map((post) {
                return AnnouncementCard(
                  post: post,
                  currentUserId: currentUser.uid,
                );
              }).toList(),
            ),
        ],
      ),
    );
  }
}

class JobsTab extends ConsumerStatefulWidget {
  const JobsTab({super.key});

  @override
  ConsumerState<JobsTab> createState() => _JobsTabState();
}

class _JobsTabState extends ConsumerState<JobsTab> {
  String _selectedFilter = 'all';
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return const Center(
        child: Text('No crew selected'),
      );
    }

    final suggestedJobs = ref.watch(suggestedJobsProvider(selectedCrew.id));
    final filteredJobs = _filterJobs(suggestedJobs);

    if (suggestedJobs.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 16),
            Text(
              'No job matches yet',
              style: Theme.of(context).textTheme.titleLarge?.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'AI will suggest jobs based on crew preferences',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ],
        ),
      );
    }

    return Column(
      children: [
        // Search and Filter Bar
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.white,
          child: Column(
            children: [
              // Search Bar
              TextField(
                decoration: InputDecoration(
                  hintText: 'Search jobs...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: AppTheme.borderLight),
                  ),
                  filled: true,
                  fillColor: AppTheme.offWhite,
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value.toLowerCase();
                  });
                },
              ),
              const SizedBox(height: 12),
              // Filter Chips
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _buildFilterChip('all', 'All Jobs'),
                    const SizedBox(width: 8),
                    _buildFilterChip('high', 'High Match'),
                    const SizedBox(width: 8),
                    _buildFilterChip('unviewed', 'New'),
                    const SizedBox(width: 8),
                    _buildFilterChip('applied', 'Applied'),
                    const SizedBox(width: 8),
                    _buildFilterChip('saved', 'Saved'),
                  ],
                ),
              ),
            ],
          ),
        ),
        // Job List
        Expanded(
          child: filteredJobs.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.filter_list_off,
                        size: 48,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No jobs match your filters',
                        style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Try adjusting your search or filter criteria',
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return JobMatchCard(
                      job: job,
                      currentUserId: currentUser.uid,
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildFilterChip(String value, String label) {
    final isSelected = _selectedFilter == value;
    return ChoiceChip(
      label: Text(label),
      selected: isSelected,
      onSelected: (selected) {
        setState(() {
          _selectedFilter = value;
        });
      },
      selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
      backgroundColor: AppTheme.offWhite,
      labelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
        color: isSelected ? AppTheme.accentCopper : AppTheme.textSecondary,
        fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
      ),
      side: BorderSide(
        color: isSelected ? AppTheme.accentCopper : AppTheme.borderLight,
        width: 1,
      ),
    );
  }

  List<SuggestedJob> _filterJobs(List<SuggestedJob> jobs) {
    return jobs.where((job) {
      // Search filter
      if (_searchQuery.isNotEmpty) {
        // Would search job title, company, etc. (placeholder logic)
        final jobTitle = 'Electrical Foreman Position'.toLowerCase();
        if (!jobTitle.contains(_searchQuery)) {
          return false;
        }
      }

      // Category filters
      switch (_selectedFilter) {
        case 'high':
          return job.matchScore >= 80;
        case 'unviewed':
          return !job.viewedByMemberIds.contains(ref.read(currentUserProvider)!.uid);
        case 'applied':
          return job.appliedMemberIds.contains(ref.read(currentUserProvider)!.uid);
        case 'saved':
          // Would check saved jobs (placeholder)
          return false;
        case 'all':
        default:
          return true;
      }
    }).toList();
  }
}

class ChatTab extends ConsumerStatefulWidget {
  const ChatTab({super.key});

  @override
  ConsumerState<ChatTab> createState() => _ChatTabState();
}

class _ChatTabState extends ConsumerState<ChatTab> {
  bool _showCrewChat = true; // Toggle between crew chat and DMs/Global

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (currentUser == null) {
      return const Center(
        child: Text('User not authenticated'),
      );
    }

    // Adjust toggle labels based on crew
    final isCrewSelected = selectedCrew != null;
    final leftToggleLabel = isCrewSelected ? 'Crew Chat' : 'Direct Messages';
    final rightToggleLabel = isCrewSelected ? 'Direct Messages' : 'Global Chat';

    return Column(
      children: [
        // Chat Type Toggle
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.white,
          child: Row(
            children: [
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showCrewChat = true),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: _showCrewChat ? AppTheme.accentCopper : AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      leftToggleLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: _showCrewChat ? AppTheme.white : AppTheme.textSecondary,
                        fontWeight: _showCrewChat ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: InkWell(
                  onTap: () => setState(() => _showCrewChat = false),
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    decoration: BoxDecoration(
                      color: !_showCrewChat ? AppTheme.accentCopper : AppTheme.offWhite,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Text(
                      rightToggleLabel,
                      textAlign: TextAlign.center,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: !_showCrewChat ? AppTheme.white : AppTheme.textSecondary,
                        fontWeight: !_showCrewChat ? FontWeight.w600 : FontWeight.normal,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        // Chat Content
        Expanded(
          child: isCrewSelected 
            ? (_showCrewChat 
                ? _buildCrewChat(selectedCrew!.id, currentUser.uid)
                : _buildDirectMessages(selectedCrew.id, currentUser.uid))
            : (_showCrewChat 
                ? _buildDirectMessages(null, currentUser.uid)  // Direct messages when no crew
                : _buildGlobalChat(currentUser.uid)),  // Global chat placeholder
        ),
      ],
    );
  }

  Widget _buildCrewChat(String crewId, String currentUserId) {
    // For now, return empty state since we need to implement the crew messages provider
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No messages yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start the conversation in your crew chat',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDirectMessages(String? crewId, String currentUserId) {
    // For now, return empty state since we don't have DM providers set up yet
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.message_outlined,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'No direct messages yet',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Start a conversation with another user',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildGlobalChat(String currentUserId) {
    // Placeholder for global chat
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.chat_outlined,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          Text(
            'Global Chat',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
              color: AppTheme.textPrimary,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Global announcements and discussions coming soon',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.textSecondary,
            ),
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
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return const Center(
        child: Text('No crew selected'),
      );
    }

    // Get crew members (in a real app, this would come from a provider)
    final members = selectedCrew.memberIds.map((memberId) {
      // Mock member data - in a real app, this would come from user profiles
      return {
        'id': memberId,
        'name': memberId == currentUser.uid ? 'You' : 'Crew Member ${memberId.substring(0, 6)}',
        'role': memberId == selectedCrew.foremanId ? 'Foreman' : 'Lineman',
        'isOnline': memberId.hashCode % 2 == 0, // Mock online status
        'lastActive': memberId.hashCode % 3 == 0 ? '2h ago' : null,
        'avatarUrl': null, // Would come from user profile
      };
    }).toList();

    // Sort: online members first, then by name
    members.sort((a, b) {
      if (a['isOnline'] == true && b['isOnline'] != true) return -1;
      if (a['isOnline'] != true && b['isOnline'] == true) return 1;
      return (a['name'] as String).compareTo(b['name'] as String);
    });

    return Column(
      children: [
        // Crew Stats Header
        Container(
          padding: const EdgeInsets.all(16),
          color: AppTheme.white,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem(
                context,
                'Total',
                members.length.toString(),
                Icons.people_outline,
              ),
              _buildStatItem(
                context,
                'Online',
                members.where((m) => m['isOnline'] as bool).length.toString(),
                Icons.circle,
              ),
              _buildStatItem(
                context,
                'Active',
                members.where((m) => m['lastActive'] != null).length.toString(),
                Icons.access_time,
              ),
            ],
          ),
        ),
        // Members List
        Expanded(
          child: members.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.people_outline,
                        size: 64,
                        color: AppTheme.mediumGray,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No members yet',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Invite members to join your crew',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: AppTheme.textSecondary,
                        ),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return CrewMemberListItem(
                      memberName: member['name'] as String,
                      avatarUrl: member['avatarUrl'] as String?,
                      isOnline: member['isOnline'] as bool,
                      role: member['role'] as String,
                      lastActive: member['lastActive'] as String?,
                      onTap: () {
                        // Would navigate to member profile or show member details
                        debugPrint('Tapped on member: ${member['name']}');
                      },
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildStatItem(BuildContext context, String label, String value, IconData icon) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 16,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(width: 4),
          Text(
            '$label: ',
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          Text(
            value,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontWeight: FontWeight.bold,
              color: AppTheme.darkGray,
            ),
          ),
        ],
      ),
    );
  }
}
