import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/features/crews/providers/tailboard_providers.dart';
import 'package:journeyman_jobs/features/crews/widgets/job_match_card.dart';
import 'package:journeyman_jobs/models/crew_model.dart'; // Assuming Crew model is here
import 'package:journeyman_jobs/models/user_model.dart'; // Assuming UserModel is here
import 'package:journeyman_jobs/models/jobs_record.dart'; // Assuming JobsRecord is here
import 'package:journeyman_jobs/models/users_record.dart'; // Assuming UsersRecord is here
import 'package:journeyman_jobs/providers/riverpod/selected_crew_provider.dart'; // Assuming selectedCrewProvider is here
import 'package:journeyman_jobs/providers/riverpod/current_user_provider.dart'; // Assuming currentUserProvider is here
import '../providers/crews_riverpod_provider.dart';
import '../providers/tailboard_riverpod_provider.dart';
import '../models/models.dart'; // This might be a barrel file, but specific imports are better
import 'package:flutter/foundation.dart';
import '../widgets/activity_card.dart';
import '../widgets/announcement_card.dart';
import '../widgets/crew_member_avatar.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../design_system/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../../navigation/app_router.dart';
import '../providers/tailboard_providers.dart';

// Extension method to add divide functionality to List
extension ListExtensions<T> on List<T> {
  List<T> divide(T separator) {
    if (isEmpty) return [];
    final result = <T>[];
    for (var i = 0; i < length; i++) {
      result.add(this[i]);
      if (i < length - 1) {
        result.add(separator);
      }
    }
    return result;
  }
}

class TailboardScreen extends ConsumerStatefulWidget {
  const TailboardScreen({super.key});

  @override
  ConsumerState<TailboardScreen> createState() => _TailboardScreenState();
}

class _TailboardScreenState extends ConsumerState<TailboardScreen> with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _selectedTab = 0;
  String? _selectedCrewDisplay;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addObserver(this);

    _selectedCrewDisplay = null;

    // Animations will be applied directly on widgets using flutter_animate extensions
    // (e.g., .animate().fadeIn().slideY(begin: 0.1, end: 0))
  }

  @override
  void dispose() {
    _tabController.removeListener(_handleTabSelection);
    _tabController.dispose();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    final dbService = ref.read(databaseServiceProvider);
    switch (state) {
      case AppLifecycleState.resumed:
        dbService.setOnlineStatus(true);
        break;
      case AppLifecycleState.paused:
        dbService.setOnlineStatus(false);
        break;
      default:
        break;
    }
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
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Scaffold(
            body: Center(child: Text('Authentication error occurred')),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        if (snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.login);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final selectedCrew = ref.watch(selectedCrewProvider);
        
        return Scaffold(
          backgroundColor: AppTheme.offWhite,
          body: Consumer(
            builder: (context, ref, child) {
              final connectivityAsync = ref.watch(connectivityServiceProvider);
              return connectivityAsync.when(
                data: (connectivity) {
                  return Column(
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
                  );
                },
                loading: () => const Center(child: CircularProgressIndicator()),
                error: (error, stack) {
                  return OfflineIndicator(
                    isOffline: true,
                    child: Center(
                      child: ErrorCard(
                        message: error.toString(),
                        onRetry: () => ref.refresh(connectivityServiceProvider),
                      ),
                    ),
                  );
                },
              );
            },
          ),
          floatingActionButton: selectedCrew != null ? _buildFloatingActionButton() : null,
        );
      },
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
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
            child: DropdownButtonFormField<String>(
              value: _selectedCrewDisplay,
              hint: const Text('Select your Crew...'),
              items: const [
                DropdownMenuItem<String>(
                  value: 'Crew 1',
                  child: Text('Crew 1'),
                ),
                DropdownMenuItem<String>(
                  value: 'Crew 2',
                  child: Text('Crew 2'),
                ),
              ],
              onChanged: (String? newValue) {
                setState(() {
                  _selectedCrewDisplay = newValue;
                });
              },
              decoration: InputDecoration(
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                suffixIcon: const Icon(Icons.arrow_drop_down),
                filled: true,
                fillColor: AppTheme.offWhite,
                hintStyle: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
            ),
          ),
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
            mainAxisSize: MainAxisSize.max,
            children: [
              Container(
                width: 40,
                height: 40,
                clipBehavior: Clip.antiAlias,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                ),
                child: CircleAvatar(
                  backgroundColor: AppTheme.accentCopper.withOpacity(0.1),
                  child: Icon(
                    Icons.group,
                    color: AppTheme.accentCopper,
                    size: 28,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(12, 0, 0, 0),
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
              Padding(
                padding: EdgeInsetsDirectional.fromSTEB(4, 0, 0, 0),
                child: Text(
                  '2h',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
              IconButton(
                onPressed: () => _showQuickActions(context),
                icon: Icon(
                  Icons.more_vert,
                  color: AppTheme.mediumGray,
                ),
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
        labelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w500,
        ),
        unselectedLabelStyle: Theme.of(context).textTheme.titleMedium?.copyWith(
          fontFamily: 'Plus Jakarta Sans',
          fontWeight: FontWeight.w400,
          color: AppTheme.mediumGray,
        ),
        indicatorColor: AppTheme.primaryNavy,
        indicatorWeight: 3,
        tabs: const [
          Tab(
            icon: Icon(Icons.feed),
            text: 'Feed',
          ),
          Tab(
            icon: Icon(Icons.forest),
            text: 'Jobs',
          ),
          Tab(
            icon: Icon(Icons.chat_bubble_outline_outlined),
            text: 'Chat',
          ),
          Tab(
            icon: Icon(Icons.people_alt_outlined),
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
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.add, color: AppTheme.white),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeInOut,
        );
      case 1: // Jobs
        return FloatingActionButton(
          onPressed: () => _showShareJobDialog(),
          backgroundColor: AppTheme.accentCopper,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.share, color: AppTheme.white),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeInOut,
        );
      case 2: // Chat
        return FloatingActionButton(
          onPressed: () => _showNewMessageDialog(),
          backgroundColor: AppTheme.accentCopper,
          elevation: 4,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          child: const Icon(Icons.message, color: AppTheme.white),
        ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeInOut,
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
class FeedTab extends ConsumerStatefulWidget {
  const FeedTab({super.key});

  @override
  ConsumerState<FeedTab> createState() => _FeedTabState();
}

class _FeedTabState extends ConsumerState<FeedTab> {
  final ScrollController _scrollController = ScrollController();

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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(feedPostsNotifierProvider(ref.watch(selectedCrewProvider)?.id ?? ''));
      notifier.loadMore();
    }
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null || currentUser == null) {
      return const Center(
        child: Text('No crew selected'),
      );
    }

    final postsAsync = ref.watch(feedPostsNotifierProvider(selectedCrew.id));

    return postsAsync.when(
      data: (posts) => posts.isEmpty
          ? const Center(child: Text('No posts yet'))
          : ListView.builder(
              controller: _scrollController,
              itemCount: posts.length + (ref.read(feedPostsNotifierProvider(selectedCrew.id).notifier).isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == posts.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final post = posts[index];
                return Card(
                  child: ListTile(
                    leading: const CircleAvatar(child: Icon(Icons.person)),
                    title: Text(post.authorName),
                    subtitle: Text(post.content),
                    trailing: Text(post.timestamp.toString()),
                  ),
                );
              },
            ),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (error, stack) => Center(child: Text('Error loading posts: $error')),
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
  String _selectedFilter = 'all';
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
    if (_scrollController.position.pixels >= _scrollController.position.maxScrollExtent - 200) {
      final notifier = ref.read(jobsNotifierProvider(ref.watch(selectedCrewProvider)?.id ?? ''));
      notifier.loadMore();
    }
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
      selectedColor: AppTheme.accentCopper.withOpacity(0.2),
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

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final currentUser = ref.watch(currentUserProvider);

    if (selectedCrew == null) {
      return const Center(
        child: Text('No crew selected'),
      );
    }

    final jobsAsync = ref.watch(jobsNotifierProvider(selectedCrew.id));

    List<Job> filteredJobs = [];
    if (jobsAsync.value != null) {
      filteredJobs = jobsAsync.value!.where((job) {
        // Search filter - assuming job has title or company field
        if (_searchQuery.isNotEmpty) {
          final searchLower = _searchQuery.toLowerCase();
          if (!(job.jobTitle.toLowerCase().contains(searchLower) || job.company.toLowerCase().contains(searchLower))) {
            return false;
          }
        }

        // Category filters
        switch (_selectedFilter) {
          case 'high':
            return job.matchScore >= 80;
          case 'unviewed':
            return !job.viewedByMemberIds.contains(currentUser.uid);
          case 'applied':
            return job.appliedMemberIds.contains(currentUser.uid);
          case 'saved':
            return job.isSavedByMemberIds.contains(currentUser.uid); // Assuming this field
          case 'all':
          default:
            return true;
        }
      }).toList();
    }

    if (filteredJobs.isEmpty && !jobsAsync.isLoading) {
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
          child: jobsAsync.when(
            data: (jobs) => ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.zero,
              itemCount: filteredJobs.length + (ref.read(jobsNotifierProvider(selectedCrew.id).notifier).isLoadingMore ? 1 : 0),
              itemBuilder: (context, index) {
                if (index == filteredJobs.length) {
                  return const Center(child: Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(),
                  ));
                }
                final job = filteredJobs[index];
                return Padding(
                  padding: EdgeInsets.all(10),
                  child: Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                      color: Color(0x19666666),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.mediumGray,
                        width: 1.5,
                      ),
                    ),
                    child: Padding(
                      padding: EdgeInsets.all(15),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: 'Local:',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textPrimary,
                                        fontSize: 14,
                                      ),
                                    ),
                                    TextSpan(
                                      text: job.local ?? 'N/A',
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                      ),
                                    )
                                  ],
                                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                    color: AppTheme.textSecondary,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 20,
                                child: VerticalDivider(
                                  thickness: 2,
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                              Text(
                                job.classification ?? 'N/A',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                      child: Icon(
                                        Icons.access_time,
                                        color: AppTheme.textPrimary,
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  Text(
                                    'Posted 2h ago',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                      child: Icon(
                                        Icons.location_on,
                                        color: Colors.black.withValues(alpha: 0.85),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Location:',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textPrimary,
                                          ),
                                        ),
                                        TextSpan(
                                          text: job.location ?? 'N/A',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            fontWeight: FontWeight.w600,
                                          ),
                                        )
                                      ],
                                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 10),
                          Row(
                            mainAxisSize: MainAxisSize.max,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                      child: FaIcon(
                                        FontAwesomeIcons.clock,
                                        color: Colors.black.withValues(alpha: 0.85),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Hours: ',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                                        ),
                                        TextSpan(
                                          text: job.hours.toString(),
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                                    ),
                                  ),
                                ],
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.max,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Container(
                                    width: 20,
                                    decoration: BoxDecoration(),
                                    child: Padding(
                                      padding: EdgeInsetsDirectional.fromSTEB(5, 0, 0, 0),
                                      child: FaIcon(
                                        FontAwesomeIcons.dollarSign,
                                        color: Colors.black.withValues(alpha: 0.85),
                                        size: 18,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 10),
                                  RichText(
                                    text: TextSpan(
                                      children: [
                                        TextSpan(
                                          text: 'Per Diem: ',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                                        ),
                                        TextSpan(
                                          text: '\$${job.perDiem}',
                                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            fontWeight: FontWeight.bold,
                                          ),
                                        )
                                      ],
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          Row(
                            children: [
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: ElevatedButton.icon(
                                    onPressed: () {
                                      // View details logic (UI-only placeholder)
                                    },
                                    icon: const Icon(Icons.visibility, color: AppTheme.white),
                                    label: const Text('View Details'),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppTheme.primaryNavy,
                                      foregroundColor: AppTheme.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 19),
                              Expanded(
                                child: SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () {
                                      // Bid now logic (UI-only placeholder)
                                    },
                                    icon: const Icon(Icons.gavel, color: Colors.white),
                                    label: const Text('Bid now'),
                                    style: OutlinedButton.styleFrom(
                                      foregroundColor: Colors.white,
                                      side: BorderSide(
                                        width: 1.5,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10),
                                      ),
                                      backgroundColor: AppTheme.mediumGray,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ).animate().fadeIn(
                    duration: 400.ms,
                    curve: Curves.easeInOut,
                  ).slideY(
                    begin: 100.0,
                    end: 0.0,
                    curve: Curves.easeInOut,
                  ),
                );
              },
            ),
            loading: () => const Center(child: CircularProgressIndicator()),
            error: (error, stack) => Center(child: Text('Error loading jobs: $error')),
          ),
        ),
      ],
    );
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
                ? _buildCrewChat(selectedCrew.id, currentUser.uid)
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
        'avatarUrl': 'https://images.unsplash.com/photo-1580489944761-15a19d654956?ixlib=rb-1.2.1&ixid=MnwxMjA3fDB8MHxzZWFyY2h8MzR8fHByb2ZpbGV8ZW58MHx8MHx8&auto=format&fit=crop&w=800&q=60', // Would come from user profile
        'classification': 'Journeyman',
        'local': 'Local 123',
        'yearsExperience': (memberId.hashCode % 10) + 1,
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
                  padding: const EdgeInsets.all(16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    return Container(
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            blurRadius: 5,
                            color: const Color(0x3416202A),
                            offset: const Offset(0, 3),
                          )
                        ],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(
                          color: AppTheme.mediumGray,
                          width: 1.5,
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(12),
                        child: Row(
                          children: [
                            // Avatar
                            Container(
                              width: 56,
                              height: 56,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: member['isOnline'] as bool ? Colors.green : Colors.transparent,
                                  width: 2,
                                ),
                              ),
                              child: CircleAvatar(
                                backgroundImage: NetworkImage(member['avatarUrl'] as String),
                                backgroundColor: AppTheme.offWhite,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Member info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Text(
                                        member['name'] as String,
                                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                      if (member['id'] == selectedCrew.foremanId)
                                        Container(
                                          margin: const EdgeInsets.only(left: 6),
                                          padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: AppTheme.accentCopper.withValues(alpha: 0.2),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            'Foreman',
                                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                              color: AppTheme.accentCopper,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${member['classification']} • ${member['local']}',
                                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.work,
                                        size: 14,
                                        color: AppTheme.textSecondary,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        '${member['yearsExperience']} years experience',
                                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                          color: AppTheme.textSecondary,
                                        ),
                                      ),
                                      if (member['isOnline'] as bool) ...[
                                        const SizedBox(width: 8),
                                        Container(
                                          width: 8,
                                          height: 8,
                                          decoration: const BoxDecoration(
                                            color: Colors.green,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                        const SizedBox(width: 4),
                                        Text(
                                          'Online',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: Colors.green,
                                          ),
                                        ),
                                      ],
                                      if (member['lastActive'] != null) ...[
                                        const SizedBox(width: 8),
                                        Text(
                                          '• ${member['lastActive']}',
                                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                            color: AppTheme.textSecondary,
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Action button
                            IconButton(
                              icon: const Icon(
                                Icons.more_vert,
                                color: AppTheme.textSecondary,
                              ),
                              onPressed: () {
                                // Show member actions
                              },
                            ),
                          ],
                        ),
                      ),
                    ).animate().fadeIn(
                      duration: 400.ms,
                      curve: Curves.easeInOut,
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
