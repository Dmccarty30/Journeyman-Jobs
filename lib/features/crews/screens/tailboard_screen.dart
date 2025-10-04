import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:go_router/go_router.dart';
import '../providers/crews_riverpod_provider.dart';
import '../providers/tailboard_riverpod_provider.dart';
import '../models/models.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../design_system/app_theme.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../navigation/app_router.dart';
import '../../../providers/core_providers.dart' hide selectedCrewProvider, currentUserProvider;
import '../services/crew_service.dart';
import '../widgets/crew_selection_dropdown.dart';
import '../widgets/crew_preferences_dialog.dart';
import '../widgets/tab_widgets.dart';

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
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
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
            context.go(AppRouter.auth);
          });
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        final selectedCrew = ref.watch(selectedCrewProvider);

        return Scaffold(
          backgroundColor: AppTheme.offWhite,
          body: Column(
            children: [
              // Header - conditional based on crew
              selectedCrew != null
                ? _buildHeader(context, selectedCrew)
                : _buildNoCrewHeader(context),
              _buildTabBar(context),
              Expanded(
                child: TabBarView(
                  controller: _tabController,
                  children: [
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
            child: CrewSelectionDropdown(),
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
                decoration: BoxDecoration(
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
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            crew.name,
                            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: AppTheme.textPrimary,
                            ),
                          ),
                        ),
                        SizedBox(width: 10),
                        Flexible(
                          child: CrewSelectionDropdown(),
                        ),
                      ],
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
          SizedBox(height: 16),
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
          SizedBox(width: 4),
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

  Widget _buildTabBar(BuildContext context) {
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
                _showCrewPreferencesDialog();
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

  void _showCrewPreferencesDialog() async {
    final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the crew service from the provider
    final dbService = ref.read(databaseServiceProvider);
    final crewService = ref.read(crewServiceProvider);
    
    final selectedCrew = ref.watch(selectedCrewProvider);
    
    if (selectedCrew == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a crew first'),
          backgroundColor: AppTheme.errorRed.withOpacity(0.8),
        ),
      );
      return;
    }

    try {
      // Get crew data from Firestore
      final crewData = await dbService.getCrew(selectedCrew.id);
      if (crewData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected crew not found'),
            backgroundColor: AppTheme.errorRed.withOpacity(0.8),
          ),
        );
        return;
      }

      // Show preferences dialog
      if (mounted) {
        showDialog(
          context: context,
          builder: (context) => CrewPreferencesDialog(
            crewService: crewService,
            crewId: selectedCrew.id,
            initialPreferences: selectedCrew.preferences,
          ),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading crew data: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed.withOpacity(0.8),
        ),
      );
    }
  }
}