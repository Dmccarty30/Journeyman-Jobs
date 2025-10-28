import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/widgets/crew_card.dart';
import 'package:journeyman_jobs/features/crews/widgets/electrical_crew_invitation_card.dart';
import 'package:journeyman_jobs/features/crews/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/features/crews/models/invite_code.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import 'package:journeyman_jobs/widgets/jj_skeleton_loader.dart';

/// Electrical-themed crew list screen with comprehensive features.
///
/// This screen provides:
/// - Electrical gradient header with circuit patterns
/// - Crew list with multiple view modes (grid, list)
/// - Search and filtering capabilities
/// - Invitation management section
/// - Create/join crew actions
/// - Responsive design for mobile and tablet
/// - Accessibility support with semantic navigation
/// - Pull-to-refresh and infinite scrolling
/// - Empty states with contextual guidance
class ElectricalCrewListScreen extends ConsumerStatefulWidget {
  /// Callback when a crew is selected
  final Function(Crew crew)? onCrewSelected;

  /// Callback when create crew is pressed
  final VoidCallback? onCreateCrew;

  /// Callback when join crew is pressed
  final VoidCallback? onJoinCrew;

  /// Initial view mode for the crew list
  final CrewListViewMode initialViewMode;

  const ElectricalCrewListScreen({
    Key? key,
    this.onCrewSelected,
    this.onCreateCrew,
    this.onJoinCrew,
    this.initialViewMode = CrewListViewMode.list,
  }) : super(key: key);

  @override
  ConsumerState<ElectricalCrewListScreen> createState() =>
      _ElectricalCrewListScreenState();
}

class _ElectricalCrewListScreenState extends ConsumerState<ElectricalCrewListScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TabController _tabController;
  late AnimationController _headerAnimationController;
  late AnimationController _fabAnimationController;
  late Animation<double> _headerAnimation;
  late Animation<double> _fabAnimation;

  CrewListViewMode _viewMode = CrewListViewMode.list;
  bool _isSearching = false;
  String _searchQuery = '';
  List<Crew> _filteredCrews = [];
  List<CrewInvitation> _pendingInvitations = [];
  bool _isLoading = true;
  bool _isRefreshing = false;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _loadData();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _tabController.dispose();
    _headerAnimationController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  void _initializeControllers() {
    _scrollController = ScrollController();
    _tabController = TabController(length: 3, vsync: this);
    _viewMode = widget.initialViewMode;
  }

  void _initializeAnimations() {
    _headerAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _headerAnimation = Tween<double>(
      begin: 1.0,
      end: 0.8,
    ).animate(CurvedAnimation(
      parent: _headerAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.elasticOut,
    ));

    // Start FAB animation after a short delay
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        _fabAnimationController.forward();
      }
    });

    // Listen to scroll events for header animation
    _scrollController.addListener(_onScrollChanged);
  }

  void _onScrollChanged() {
    final offset = _scrollController.offset;
    final shouldShrink = offset > 100;

    if (shouldShrink && _headerAnimationController.status == AnimationStatus.dismissed) {
      _headerAnimationController.forward();
    } else if (!shouldShrink && _headerAnimationController.status == AnimationStatus.completed) {
      _headerAnimationController.reverse();
    }
  }

  Future<void> _loadData() async {
    // Simulate data loading
    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      setState(() {
        _isLoading = false;
        _filteredCrews = _getMockCrews();
        _pendingInvitations = _getMockInvitations();
      });
    }
  }

  Future<void> _refreshData() async {
    setState(() => _isRefreshing = true);
    await _loadData();
    setState(() => _isRefreshing = false);
  }

  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
      _filterCrews();
    });
  }

  void _filterCrews() {
    if (_searchQuery.isEmpty) {
      _filteredCrews = _getMockCrews();
    } else {
      _filteredCrews = _getMockCrews().where((crew) {
        return crew.name.toLowerCase().contains(_searchQuery) ||
            (crew.location?.city?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      body: CustomScrollView(
        controller: _scrollController,
        slivers: [
          // Electrical header with circuit patterns
          _buildSliverAppBar(),

          // Search bar and filters
          SliverToBoxAdapter(
            child: _buildSearchAndFilters(),
          ),

          // Tab bar for different sections
          SliverToBoxAdapter(
            child: _buildTabBar(),
          ),

          // Content based on selected tab
          SliverFillRemaining(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildMyCrewsTab(),
                _buildInvitationsTab(),
                _buildDiscoverTab(),
              ],
            ),
          ),
        ],
      ),

      // Floating action buttons
      floatingActionButton: _buildFloatingActionButtons(),
    );
  }

  /// Builds the electrical-themed app bar
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 200,
      floating: false,
      pinned: true,
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Stack(
          children: [
            // Circuit pattern background
            Positioned.fill(
              child: CustomPaint(
                painter: CircuitPatternPainter(
                  density: ComponentDensity.high,
                  traceColor: AppTheme.electricalCircuitTrace.withValues(alpha: 0.1),
                  backgroundColor: Colors.transparent,
                ),
              ),
            ),

            // Gradient overlay
            Positioned.fill(
              child: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.primaryNavy.withValues(alpha: 0.9),
                      AppTheme.secondaryNavy,
                    ],
                  ),
                ),
              ),
            ),

            // Header content
            Positioned.fill(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(AppTheme.spacingLg),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      // Title
                      AnimatedBuilder(
                        animation: _headerAnimation,
                        builder: (context, child) {
                          return Transform.scale(
                            scale: _headerAnimation.value,
                            child: Text(
                              'My Crews',
                              style: AppTheme.displayLarge.copyWith(
                                color: AppTheme.white,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(height: AppTheme.spacingSm),

                      // Subtitle
                      Text(
                        'Connect and collaborate with your electrical team',
                        style: AppTheme.bodyLarge.copyWith(
                          color: AppTheme.white.withValues(alpha: 0.8),
                        ),
                      ),

                      const SizedBox(height: AppTheme.spacingMd),

                      // Quick stats
                      Row(
                        children: [
                          _buildQuickStat(
                            icon: Icons.group,
                            label: 'Active Crews',
                            value: _filteredCrews.length.toString(),
                          ),
                          const SizedBox(width: AppTheme.spacingLg),
                          _buildQuickStat(
                            icon: Icons.mail,
                            label: 'Pending',
                            value: _pendingInvitations.length.toString(),
                          ),
                          const SizedBox(width: AppTheme.spacingLg),
                          _buildQuickStat(
                            icon: Icons.bolt,
                            label: 'Active Now',
                            value: '12',
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds individual quick stat item
  Widget _buildQuickStat({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper,
          size: AppTheme.iconSm,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.white.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds search bar and filter options
  Widget _buildSearchAndFilters() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      child: Row(
        children: [
          // Search bar
          Expanded(
            child: Container(
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: AppTheme.borderWidthMedium,
                ),
                boxShadow: AppTheme.shadowSm,
              ),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: 'Search crews...',
                  hintStyle: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textLight,
                  ),
                  prefixIcon: const Icon(
                    Icons.search,
                    color: AppTheme.textSecondary,
                  ),
                  suffixIcon: _searchQuery.isNotEmpty
                      ? IconButton(
                          onPressed: () => _onSearchChanged(''),
                          icon: const Icon(
                            Icons.clear,
                            color: AppTheme.textSecondary,
                          ),
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.all(AppTheme.spacingMd),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // View mode toggle
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: AppTheme.borderLight,
                width: AppTheme.borderWidthMedium,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildViewModeButton(
                  icon: Icons.view_list,
                  isActive: _viewMode == CrewListViewMode.list,
                  onPressed: () => setState(() => _viewMode = CrewListViewMode.list),
                ),
                Container(
                  width: 1,
                  height: 24,
                  color: AppTheme.borderLight,
                ),
                _buildViewModeButton(
                  icon: Icons.grid_view,
                  isActive: _viewMode == CrewListViewMode.grid,
                  onPressed: () => setState(() => _viewMode = CrewListViewMode.grid),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds individual view mode button
  Widget _buildViewModeButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback onPressed,
  }) {
    return IconButton(
      onPressed: onPressed,
      icon: Icon(
        icon,
        color: isActive ? AppTheme.accentCopper : AppTheme.textSecondary,
      ),
      style: IconButton.styleFrom(
        backgroundColor: isActive ? AppTheme.accentCopper.withValues(alpha: 0.1) : Colors.transparent,
      ),
    );
  }

  /// Builds the tab bar for different sections
  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        boxShadow: AppTheme.shadowSm,
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.accentCopper,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: AppTheme.textSecondary,
        indicatorWeight: 3,
        indicatorSize: TabBarIndicatorSize.tab,
        tabs: const [
          Tab(
            icon: Icon(Icons.group),
            text: 'My Crews',
          ),
          Tab(
            icon: Icon(Icons.mail),
            text: 'Invitations',
          ),
          Tab(
            icon: Icon(Icons.explore),
            text: 'Discover',
          ),
        ],
      ),
    );
  }

  /// Builds the "My Crews" tab content
  Widget _buildMyCrewsTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_filteredCrews.isEmpty) {
      return _buildEmptyState(
        icon: Icons.group_outlined,
        title: 'No crews found',
        message: _searchQuery.isNotEmpty
            ? 'Try searching with different keywords'
            : 'Create your first crew or join an existing one',
        actionLabel: 'Create Crew',
        onAction: widget.onCreateCrew,
      );
    }

    return RefreshIndicator(
      onRefresh: _refreshData,
      color: AppTheme.accentCopper,
      child: _buildCrewsList(),
    );
  }

  /// Builds the "Invitations" tab content
  Widget _buildInvitationsTab() {
    if (_isLoading) {
      return _buildLoadingState();
    }

    if (_pendingInvitations.isEmpty) {
      return _buildEmptyState(
        icon: Icons.mail_outline,
        title: 'No invitations',
        message: 'You don\'t have any pending crew invitations',
        actionLabel: 'Join Crew',
        onAction: widget.onJoinCrew,
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _pendingInvitations.length,
      itemBuilder: (context, index) {
        final invitation = _pendingInvitations[index];
        return ElectricalCrewInvitationCard(
          invitation: invitation,
          crew: _getMockCrew(), // Mock crew data
          inviter: _getMockUser(), // Mock user data
          variant: index == 0 ? InvitationCardVariant.featured : InvitationCardVariant.standard,
          onAccept: () => _handleAcceptInvitation(invitation),
          onDecline: () => _handleDeclineInvitation(invitation),
        );
      },
    );
  }

  /// Builds the "Discover" tab content
  Widget _buildDiscoverTab() {
    return _buildEmptyState(
      icon: Icons.explore_outlined,
      title: 'Discover Crews',
      message: 'Find and join crews based on your location and interests',
      actionLabel: 'Explore',
      onAction: () {
        // Navigate to crew discovery screen
      },
    );
  }

  /// Builds the crews list based on view mode
  Widget _buildCrewsList() {
    switch (_viewMode) {
      case CrewListViewMode.grid:
        return _buildCrewsGrid();
      case CrewListViewMode.list:
      default:
        return _buildCrewsListView();
    }
  }

  /// Builds list view for crews
  Widget _buildCrewsListView() {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: _filteredCrews.length,
      itemBuilder: (context, index) {
        final crew = _filteredCrews[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: CrewCard(
            crew: crew,
            onTap: () => widget.onCrewSelected?.call(crew),
            variant: index == 0 ? CrewCardVariant.featured : CrewCardVariant.standard,
          ),
        );
      },
    );
  }

  /// Builds grid view for crews
  Widget _buildCrewsGrid() {
    return GridView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 1.2,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
      ),
      itemCount: _filteredCrews.length,
      itemBuilder: (context, index) {
        final crew = _filteredCrews[index];
        return CrewCard(
          crew: crew,
          onTap: () => widget.onCrewSelected?.call(crew),
          variant: CrewCardVariant.compact,
        );
      },
    );
  }

  /// Builds loading state with electrical skeleton loaders
  Widget _buildLoadingState() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        children: [
          JJSkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: AppTheme.radiusLg,
            showCircuitPattern: true,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJSkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: AppTheme.radiusLg,
            showCircuitPattern: true,
          ),
          const SizedBox(height: AppTheme.spacingMd),
          JJSkeletonLoader(
            width: double.infinity,
            height: 120,
            borderRadius: AppTheme.radiusLg,
            showCircuitPattern: true,
          ),
        ],
      ),
    );
  }

  /// Builds empty state with contextual messaging
  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical background circle
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentCopper.withValues(alpha: 0.1),
                    AppTheme.primaryNavy.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                icon,
                size: 48,
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              title,
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              message,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),

            if (actionLabel != null && onAction != null) ...[
              const SizedBox(height: AppTheme.spacingLg),
              ElevatedButton.icon(
                onPressed: onAction,
                icon: const Icon(Icons.add),
                label: Text(actionLabel),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingLg,
                    vertical: AppTheme.spacingMd,
                  ),
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Builds floating action buttons
  Widget _buildFloatingActionButtons() {
    return AnimatedBuilder(
      animation: _fabAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _fabAnimation.value,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Join crew button
              FloatingActionButton(
                onPressed: widget.onJoinCrew,
                backgroundColor: AppTheme.secondaryNavy,
                heroTag: 'join_crew',
                child: const Icon(
                  Icons.group_add,
                  color: AppTheme.white,
                ),
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Create crew button
              FloatingActionButton(
                onPressed: widget.onCreateCrew,
                backgroundColor: AppTheme.accentCopper,
                heroTag: 'create_crew',
                child: const Icon(
                  Icons.add,
                  color: AppTheme.white,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Event handlers

  void _handleAcceptInvitation(CrewInvitation invitation) {
    // Handle invitation acceptance
    setState(() {
      _pendingInvitations.remove(invitation);
    });
  }

  void _handleDeclineInvitation(CrewInvitation invitation) {
    // Handle invitation decline
    setState(() {
      _pendingInvitations.remove(invitation);
    });
  }

  // Mock data methods (replace with actual data fetching)

  List<Crew> _getMockCrews() {
    return [
      Crew(
        id: '1',
        name: 'IBEW Local 124 Storm Team',
        foremanId: 'foreman1',
        memberIds: ['user1', 'user2', 'user3'],
        preferences: CrewPreferences.empty(),
        stats: CrewStats.empty(),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 30)),
        roles: {},
        lastActivityAt: DateTime.now().subtract(const Duration(minutes: 15)),
        visibility: CrewVisibility.private,
        maxMembers: 50,
        inviteCodeCounter: 0,
      ),
      Crew(
        id: '2',
        name: 'Pacific Northwest Linemen',
        foremanId: 'foreman2',
        memberIds: ['user4', 'user5'],
        preferences: CrewPreferences.empty(),
        stats: CrewStats.empty(),
        isActive: true,
        createdAt: DateTime.now().subtract(const Duration(days: 15)),
        roles: {},
        lastActivityAt: DateTime.now().subtract(const Duration(hours: 2)),
        visibility: CrewVisibility.public,
        maxMembers: 30,
        inviteCodeCounter: 0,
      ),
    ];
  }

  List<CrewInvitation> _getMockInvitations() {
    return [
      CrewInvitation(
        id: 'inv1',
        crewId: 'crew1',
        inviterId: 'inviter1',
        inviteeId: 'current_user',
        status: InvitationStatus.pending,
        createdAt: DateTime.now().subtract(const Duration(hours: 3)),
        message: 'Join our storm response team for the upcoming season!',
      ),
    ];
  }

  Crew _getMockCrew() {
    return _getMockCrews().first;
  }

  UserModel _getMockUser() {
    // Return mock user data
    return UserModel(
      uid: 'user1',
      email: 'user@example.com',
      displayName: 'John Doe',
      localNumber: '124',
    );
  }
}

/// Enum defining crew list view modes
enum CrewListViewMode {
  /// Standard list view
  list,

  /// Grid view for compact display
  grid,
}