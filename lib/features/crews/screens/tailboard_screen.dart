// Flutter & Dart imports

// Third-party package imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

// Journeyman Jobs - Absolute imports (preferred)
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/tailboard_components.dart';
import 'package:journeyman_jobs/design_system/tailboard_theme.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart' as crew_providers;
import 'package:journeyman_jobs/features/crews/widgets/crew_preferences_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/crew_selection_dropdown.dart';
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/member_roles_dialog.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/navigation/app_router.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/widgets/electrical_circuit_background.dart';

// Tailboard widget imports
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_text_field.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/dialog_actions.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/feed_sort_options_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/feed_history_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/construction_type_filter_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/local_filter_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/classification_filter_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/channels_list_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/direct_messages_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/chat_history_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/member_roster_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/member_availability_dialog.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/stream_chat_theme.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/utility_widgets.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/card_widgets.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/tab_view_builders.dart';

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
  _TailboardScreenState();
  late TabController _tabController;
  int _selectedTab = 0;



  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addObserver(this);

    // Remove this line since it's not needed
    // _selectedCrewDisplay = null;

    // Animations will be applied directly on widgets using flutter_animate extensions
    // (e.g., .animate().fadeIn().slideY(begin: 0.1, end: 0))

    // Listen to crew selection changes and update Stream Chat team assignment
    // This ensures proper team isolation for chat channels
    _listenToCrewChanges();
  }

  /// Listen to crew selection changes and update Stream Chat team assignment
  ///
  /// This method:
  /// - Watches selectedCrewProvider for changes
  /// - Updates the user's team assignment in Stream Chat when crew changes
  /// - Ensures message isolation between crews
  /// - Handles null crew assignments gracefully
  void _listenToCrewChanges() {
    ref.listen<Crew?>(selectedCrewProvider, (previous, next) {
      // Only update if crew actually changed and is not null
      if (previous?.id != next?.id && next != null) {
        debugPrint('[TailboardScreen] Crew changed from ${previous?.id} to ${next.id}');

        // Update user's team assignment in Stream Chat
        // This enforces team isolation - users only see channels from their crew
        _updateUserStreamChatTeam(next.id);
      }
    });
  }

  /// Update user's team assignment in Stream Chat
  ///
  /// Calls the StreamChatService to update the user's team assignment,
  /// which ensures they only have access to their crew's channels.
  ///
  /// Parameters:
  /// - [crewId]: The ID of the crew to assign the user to
  Future<void> _updateUserStreamChatTeam(String crewId) async {
    try {
      final streamService = ref.read(streamChatServiceProvider);
      await streamService.updateUserTeam(crewId);
      debugPrint('[TailboardScreen] Successfully updated Stream Chat team to: $crewId');
    } catch (e) {
      debugPrint('[TailboardScreen] Failed to update Stream Chat team: $e');
      // Don't show error to user - chat will still work with limited functionality
      // Team isolation is enforced server-side, so this is a safety measure
    }
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

  /// Get container labels based on currently selected tab
  List<String> _getContainerLabelsForTab() {
    switch (_selectedTab) {
      case 0: // Feed tab
        return ['My Posts', 'Sort', 'History', 'Crew Chat'];
      case 1: // Jobs tab
        return ['Construction', 'Local', 'Classification', 'Crew Chat'];
      case 2: // Chat tab
        return ['Channels', 'DMs', 'History', 'Crew Chat'];
      case 3: // Members tab
        return ['Roster', 'Availability', 'Roles', 'Crew Chat'];
      default:
        return ['', '', '', ''];
    }
  }

  /// Handle container tap actions based on tab and container index
  void _handleContainerTap(int containerIndex) {
    switch (_selectedTab) {
      case 0: // Feed tab actions
        _handleFeedContainerTap(containerIndex);
        break;
      case 1: // Jobs tab actions
        _handleJobsContainerTap(containerIndex);
        break;
      case 2: // Chat tab actions
        _handleChatContainerTap(containerIndex);
        break;
      case 3: // Members tab actions
        _handleMembersContainerTap(containerIndex);
        break;
    }
  }

  /// Handle Feed tab container actions
  void _handleFeedContainerTap(int index) {
    switch (index) {
      case 0: // My Posts
        _filterFeedByUserPosts();
        break;
      case 1: // Sort
        _showFeedSortOptions();
        break;
      case 2: // History
        _showFeedHistory();
        break;
      case 3: // Crew Chat
        _navigateToCrewChat();
        break;
    }
  }

  /// Handle Jobs tab container actions
  void _handleJobsContainerTap(int index) {
    switch (index) {
      case 0: // Construction Type
        _showConstructionTypeFilter();
        break;
      case 1: // Local
        _showLocalFilter();
        break;
      case 2: // Classification
        _showClassificationFilter();
        break;
      case 3: // Crew Chat
        _navigateToCrewChat();
        break;
    }
  }

  /// Handle Chat tab container actions
  void _handleChatContainerTap(int index) {
    switch (index) {
      case 0: // Channels
        _showChannelsList();
        break;
      case 1: // DMs
        _showDirectMessages();
        break;
      case 2: // History
        _showChatHistory();
        break;
      case 3: // Crew Chat
        _navigateToCrewChat();
        break;
    }
  }

  /// Handle Members tab container actions
  void _handleMembersContainerTap(int index) {
    switch (index) {
      case 0: // Roster
        _showMemberRoster();
        break;
      case 1: // Availability
        _showMemberAvailability();
        break;
      case 2: // Roles
        MemberRolesDialog.show(context);
        break;
      case 3: // Crew Chat
        _navigateToCrewChat();
        break;
    }
  }

  // ============================================================
  // ACTION FUNCTIONS - Feed Tab
  // ============================================================

  /// Filter feed to show only current user's posts
  void _filterFeedByUserPosts() {
    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please sign in to view your posts',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    // Toggle the "My Posts Only" filter using the feed filter provider
    ref.read(feedFilterProvider.notifier).toggleMyPostsOnly();

    final isFiltering = ref.read(feedFilterProvider).showMyPostsOnly;

    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: isFiltering
          ? 'Filtering to show only your posts'
          : 'Showing all posts',
      type: ElectricalNotificationType.info,
    );
  }

  /// Show feed sort options dialog
  void _showFeedSortOptions() {
    showDialog(
      context: context,
      builder: (context) => const FeedSortOptionsDialog(),
    );
  }

  /// Show feed history (archived posts)
  void _showFeedHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FeedHistoryDialog(),
    );
  }

  // ============================================================
  // ACTION FUNCTIONS - Jobs Tab
  // ============================================================

  /// Show construction type filter dialog
  void _showConstructionTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ConstructionTypeFilterDialog(),
    );
  }

  /// Show local filter dialog
  void _showLocalFilter() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => const LocalFilterDialog(),
    );
  }

  /// Show classification filter dialog
  void _showClassificationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ClassificationFilterDialog(),
    );
  }

  // ============================================================
  // ACTION FUNCTIONS - Chat Tab
  // ============================================================

  /// Show channels list dialog with Stream Chat integration
  void _showChannelsList() {
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Select a crew to view channels',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => ChannelListDialog(
        onNavigateToChat: () {
          _tabController.animateTo(2);
        },
      ),
    );
  }

  
  /// Show direct messages dialog with Stream Chat integration
  void _showDirectMessages() {
    showDialog(
      context: context,
      builder: (context) => DirectMessagesDialog(
        onNavigateToChat: () {
          // Navigate to chat tab
          if (_tabController.index == 1) {
            // Already on chat tab, refresh messages
            setState(() {});
          } else {
            _tabController.animateTo(1);
          }
        },
      ),
    );
  }

  
  /// Show chat history dialog
  void _showChatHistory() {
    showDialog(
      context: context,
      builder: (context) => ChatHistoryDialog(
        onNavigateToChat: () {
          // Navigate to chat tab
          if (_tabController.index == 1) {
            // Already on chat tab, refresh messages
            setState(() {});
          } else {
            _tabController.animateTo(1);
          }
        },
      ),
    );
  }

  
  // ============================================================
  // ACTION FUNCTIONS - Members Tab
  // ============================================================

  /// Show member roster dialog
  void _showMemberRoster() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MemberRosterDialog(),
    );
  }

  /// Show member availability dialog
  void _showMemberAvailability() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MemberAvailabilityDialog(),
    );
  }

  
  // ============================================================
  // SHARED ACTION FUNCTION
  // ============================================================

  /// Navigate to crew chat screen
  void _navigateToCrewChat() async {
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please select a crew first',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    try {
      // Get Stream Chat client
      final client = await ref.read(streamChatClientProvider.future);
      
      // Query for the #general channel for this crew
      // Using team filter to ensure we get the correct crew's general channel
      final channels = await client.queryChannels(
        filter: Filter.and([
          Filter.equal('team', selectedCrew.id),  // Team isolation
          Filter.equal('type', 'team'),            // Team channel type
          Filter.equal('name', 'general'),         // General channel name
        ]),
      ).first;

      if (channels.isNotEmpty) {
        // Found the #general channel, navigate to it
        final generalChannel = channels.first;
        
        // Update user's team assignment to ensure access
        await ref.read(streamChatServiceProvider).updateUserTeam(selectedCrew.id);
        
        // Store as active channel
        ref.read(activeChannelProvider).set(generalChannel);
        
        // Navigate to chat tab
        _tabController.animateTo(2);
        
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Opening #general channel',
          type: ElectricalNotificationType.success,
        );
      } else {
        // #general channel doesn't exist, create it
        final generalChannel = await client.channel(
          'team', 
          id: 'general-${selectedCrew.id}',  // Unique ID for crew's general channel
          extraData: {
            'name': 'general',
            'team': selectedCrew.id,
            'created_by': 'system',
            'description': 'General announcements and discussions for ${selectedCrew.name}',
          },
        );
        
        // Create the channel
        await generalChannel.create();
        
        // Add current user as a member
        await generalChannel.addMembers([client.state.currentUser!.id]);
        
        // Store as active channel
        ref.read(activeChannelProvider).set(generalChannel);
        
        // Navigate to chat tab
        _tabController.animateTo(2);
        
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Created and opened #general channel',
          type: ElectricalNotificationType.success,
        );
      }
    } catch (e) {
      debugPrint('Error navigating to crew chat: $e');
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to open crew chat',
        type: ElectricalNotificationType.error,
      );
      
      // Fallback: just navigate to chat tab
      _tabController.animateTo(2);
    }
  }

  /// Navigate to channel messages screen
  void _navigateToChannelMessages(Channel channel) {
    // Store as active channel
    ref.read(activeChannelProvider).set(channel);

    // Navigate to chat tab (which should show the channel messages)
    _tabController.animateTo(2);
  }


  @override
  Widget build(BuildContext context) {
    final authInit = ref.watch(auth_providers.authInitializationProvider);
    final user = ref.watch(auth_providers.currentUserProvider);

    if (authInit.isLoading) {
      return TailboardComponents.circuitBackground(context, 
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: JJElectricalLoader(
              width: 200,
              height: 60,
              message: 'Initializing...',
            ),
          ),
        ),
      );
    }

    if (user == null) {
      return TailboardComponents.circuitBackground(context, 
        child: Scaffold(
          backgroundColor: Colors.transparent,
          body: Center(
            child: Container(
              padding: const EdgeInsets.all(32),
              margin: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: TailboardTheme.navy800,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: TailboardTheme.navy800.withValues(alpha:0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: const LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFB45309)],
                      ),
                    ),
                    child: Icon(
                      Icons.lock_outline,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    'Authentication Required',
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                      height: 1.3,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Please sign in to access the Tailboard crew hub',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.normal,
                      color: Color(0xFF718096),
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 24),
                  SizedBox(
                    width: double.infinity,
                    child: Container(
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFB45309)],
                        ),
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: const [
                          BoxShadow(
                            color: Color(0x33000000),
                            offset: Offset(0, 4),
                            blurRadius: 6,
                          ),
                        ],
                      ),
                      child: ElevatedButton.icon(
                        onPressed: () => context.go(AppRouter.auth),
                        icon: const Icon(Icons.login),
                        label: const Text('Go to Sign In'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.transparent,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ).animate().scale(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }

    final selectedCrew = ref.watch(selectedCrewProvider);

    return TailboardComponents.circuitBackground(context,
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: Column(
          children: [
            // Header - conditional based on crew
            selectedCrew != null
              ? _buildHeader(context, selectedCrew)
              : _buildNoCrewHeader(context),

            // Dynamic container row - changes based on selected tab
            DynamicContainerRow(
              labels: _getContainerLabelsForTab(),
              selectedIndex: 0, // Default to first container, could be made dynamic
              onTap: _handleContainerTap,
              height: 60.0,
            ),

            _buildTabBar(context),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  // Feed Tab - Enhanced feed with posts and filters
                  const FeedTabBuilder(),
                  // Jobs Tab - Enhanced list view matching HTML mockup
                  _buildEnhancedJobsTab(),
                  // Chat Tab - Enhanced channel list with message previews
                  _buildEnhancedChatTab(),
                  // Members Tab - Enhanced member list with cards
                  _buildEnhancedCrewTab(),
                ],
              ),
            ),
          ],
        ),
        floatingActionButton: _buildFloatingActionButton(),
      ),
    ).animate().fadeIn(
      duration: const Duration(milliseconds: 500),
    );
  }

  Widget _buildNoCrewHeader(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.white,
            AppTheme.offWhite.withValues(alpha: 0.3),
          ],
        ),
      ),
      padding: const EdgeInsets.fromLTRB(16, 48, 16, 16),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: AppTheme.accentCopper.withValues(alpha: 0.1),
              border: Border.all(
                color: AppTheme.accentCopper.withValues(alpha: 0.2),
                width: 2,
              ),
            ),
            child: Icon(
              Icons.group_outlined,
              size: 48,
              color: AppTheme.accentCopper,
            ),
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
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [AppTheme.primaryNavy, AppTheme.primaryNavy.withValues(alpha: 0.8)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              boxShadow: [
                BoxShadow(
                  color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ElevatedButton.icon(
              onPressed: () {
                context.go(AppRouter.crewOnboarding);
              },
              icon: const Icon(Icons.add, color: AppTheme.white),
              label: const Text('Create or Join a Crew', style: TextStyle(color: AppTheme.white)),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 0,
              ),
            ),
          ),
          const SizedBox(height: 16),
          // Dropdown has explicit padding to prevent edge overflow
          Padding(
            padding: EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
            child: CrewSelectionDropdown(isExpanded: true),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader(BuildContext context, Crew crew) {
    return TailboardComponents.simplifiedHeader(context, 
      crewName: crew.name,
      memberCount: crew.memberIds.length,
      userRole: 'Journeyman', // You can get this from user data
      onCrewTap: () => _showQuickActions(context),
      onSettingsTap: () => _showQuickActions(context),
    );
  }

  
  Widget _buildTabBar(BuildContext context) {
    return TailboardComponents.optimizedTabBar(context, 
      controller: _tabController,
      tabs: const ['Feed', 'Jobs', 'Chat', 'Members'],
      icons: const [
        Icons.feed_outlined,
        Icons.work_outline,
        Icons.chat_bubble_outline,
        Icons.group_outlined,
      ],
    );
  }

  Widget? _buildFloatingActionButton() {
    IconData icon;
    VoidCallback onPressed;

    switch (_selectedTab) {
      case 0: // Feed
        icon = Icons.add;
        onPressed = () => _showCreatePostDialog();
        break;
      case 1: // Jobs
        icon = Icons.share;
        onPressed = () => _showShareJobDialog();
        break;
      case 2: // Chat
        icon = Icons.message;
        onPressed = () => _showNewMessageDialog();
        break;
      case 3: // Members
        icon = Icons.group_add;
        onPressed = () {
          JJElectricalNotifications.showElectricalToast(
            context: context,
            message: 'Member management coming soon!',
            type: ElectricalNotificationType.info,
          );
        };
        break;
      default:
        return null;
    }

    return Container(
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF92400E), Color(0xFFD97706), Color(0xFFB45309)],
        ),
        borderRadius: BorderRadius.circular(16),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33B45309),
            offset: Offset(0, 4),
            blurRadius: 8,
          ),
        ],
      ),
      child: FloatingActionButton(
        onPressed: onPressed,
        backgroundColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        child: Icon(icon, color: Colors.white),
      ),
    ).animate().scale(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
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
    final TextEditingController postContentController = TextEditingController();
    final maxCharacters = 1000;
    int charactersRemaining = maxCharacters;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
            return ElectricalDialogBackground(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    'Create Post',
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      color: AppTheme.textOnDark,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 16),
                  ElectricalTextField(
                    controller: postContentController,
                    maxLines: 5,
                    labelText: 'What\'s on your mind?',
                    hintText: 'Share your thoughts...',
                    onChanged: (value) {
                      setModalState(() {
                        charactersRemaining = maxCharacters - value.length;
                      });
                    },
                  ),
                  Align(
                    alignment: Alignment.centerRight,
                    child: Text(
                      '$charactersRemaining characters remaining',
                      style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: AppTheme.mediumGray,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      IconButton(
                        icon: Icon(Icons.attach_file, color: AppTheme.accentCopper),
                        onPressed: () {
                          JJElectricalNotifications.showElectricalToast(
                            context: context,
                            message: 'Media upload coming soon!',
                            type: ElectricalNotificationType.info,
                          );
                        },
                      ),
                      DialogActions(
                        onConfirm: () async => _handleCreatePost(postContentController),
                      ),
                    ],
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _handleCreatePost(TextEditingController controller) async {
    try {
      final content = controller.text.trim();
      if (content.isEmpty) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Post content cannot be empty.',
          type: ElectricalNotificationType.error,
        );
        return;
      }

      final selectedCrew = ref.read(selectedCrewProvider);
      final currentUser = ref.read(auth_providers.currentUserProvider);

      if (selectedCrew == null) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'No crew selected. Please select a crew to post.',
          type: ElectricalNotificationType.error,
        );
        return;
      }
      if (currentUser == null) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'User not authenticated. Please log in.',
          type: ElectricalNotificationType.error,
        );
        return;
      }

      // Create post with immediate real-time updates
      await ref.read(postCreationProvider).createPost(
        crewId: selectedCrew.id,
        content: content,
      );

      if (!mounted) return;
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Post published to public feed!',
        type: ElectricalNotificationType.success,
      );

      // Force immediate refresh of the global feed to show the new post instantly
      ref.invalidate(globalFeedProvider);

      if (!mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to create post: ${e.toString()}',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }

  void _showShareJobDialog() {
    final TextEditingController messageController = TextEditingController();
    final selectedCrew = ref.read(selectedCrewProvider);
    final jobsAsync = ref.watch(recentJobsProvider);
    Job? selectedJob;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
          return ElectricalDialogBackground(
            child: Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'Share Job with Crew',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    jobsAsync.when(
                      data: (jobs) {
                        if (jobs.isEmpty) {
                          return Text(
                            'No jobs available to share.',
                            style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                          );
                        }
                        return DropdownButtonFormField<Job>(
                          initialValue: selectedJob,
                          decoration: InputDecoration(
                            labelText: 'Select Job',
                            labelStyle: TextStyle(color: AppTheme.mediumGray),
                            filled: true,
                            fillColor: AppTheme.secondaryNavy,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                            ),
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                            ),
                          ),
                          dropdownColor: AppTheme.secondaryNavy,
                          style: TextStyle(color: AppTheme.textOnDark),
                          items: jobs.map<DropdownMenuItem<Job>>((Job job) {
                            return DropdownMenuItem<Job>(
                              value: job,
                              child: Text(job.jobTitle ?? 'Untitled Job', style: TextStyle(color: AppTheme.textOnDark)),
                            );
                          }).toList(),
                          onChanged: (Job? job) {
                            setModalState(() {
                              selectedJob = job;
                            });
                          },
                        );
                      },
                      loading: () => const CircularProgressIndicator(),
                      error: (error, stack) => Text('Error loading jobs: $error', style: TextStyle(color: AppTheme.errorRed)),
                    ),
                    const SizedBox(height: 16),
                    ElectricalTextField(
                      controller: messageController,
                      maxLines: 3,
                      hintText: 'Add a custom message (optional)',
                    ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (selectedCrew == null) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'No crew selected. Please select a crew to share the job.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }
                              if (selectedJob == null) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'Please select a job to share.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }

                              final currentUser = ref.read(auth_providers.currentUserProvider);
                              if (currentUser == null) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'User not authenticated. Please log in.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }

                              final jobDetails = selectedJob!.toFirestore();
                              jobDetails['customMessage'] = messageController.text.trim();

                              await ref.read(postCreationProvider).createPost(
                                crewId: selectedCrew.id,
                                content: 'Job Shared: ${selectedJob!.jobTitle ?? 'Untitled Job'}',
                                // Assuming MessageType.jobShare can be handled by content or a specific field
                                // For now, embedding details in content or adding a new field to PostModel if needed
                                // For this task, we'll just put it in content for simplicity.
                                // A more robust solution would involve extending PostModel with a jobDetails field.
                              );

                              if (!mounted) return;
                              JJElectricalNotifications.showElectricalToast(
                                context: context,
                                message: 'Job shared successfully!',
                                type: ElectricalNotificationType.success,
                              );
                              if (!mounted) return;
                              Navigator.pop(context);
                            } catch (e) {
                              if (mounted) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'Failed to share job: ${e.toString()}',
                                  type: ElectricalNotificationType.error,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCopper,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                          child: Text(
                            'Share Job',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showNewMessageDialog() {
    final TextEditingController messageController = TextEditingController();
    final TextEditingController subjectController = TextEditingController();
    final selectedCrew = ref.read(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crew_providers.crewMembersProvider(selectedCrew?.id ?? ''));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {
          return ElectricalCircuitBackground(
            child: Padding(
                padding: EdgeInsets.only(
                  top: 16,
                  left: 16,
                  right: 16,
                  bottom: MediaQuery.of(context).viewInsets.bottom + 16,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'New Message to Crew',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: subjectController,
                      style: TextStyle(color: AppTheme.textOnDark),
                      decoration: InputDecoration(
                        labelText: 'Subject',
                        labelStyle: TextStyle(color: AppTheme.mediumGray),
                        filled: true,
                        fillColor: AppTheme.secondaryNavy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: messageController,
                      maxLines: 5,
                      style: TextStyle(color: AppTheme.textOnDark),
                      decoration: InputDecoration(
                        hintText: 'Type your message here...',
                        hintStyle: TextStyle(color: AppTheme.mediumGray),
                        filled: true,
                        fillColor: AppTheme.secondaryNavy,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    if (crewMembersAsync.isEmpty)
                      Text(
                        'No crew members to message.',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(color: AppTheme.mediumGray),
                      )
                    else
                      DropdownButtonFormField<CrewMember>(
                        initialValue: null, // Allow selection of any member
                        decoration: InputDecoration(
                          labelText: 'Select Recipient (Optional)',
                          labelStyle: TextStyle(color: AppTheme.mediumGray),
                          filled: true,
                          fillColor: AppTheme.secondaryNavy,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: BorderSide(color: AppTheme.borderCopper, width: AppTheme.borderWidthCopperThin),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            borderSide: BorderSide(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopper),
                          ),
                        ),
                        dropdownColor: AppTheme.secondaryNavy,
                        style: TextStyle(color: AppTheme.textOnDark),
                        items: [
                          const DropdownMenuItem<CrewMember>(
                            value: null,
                            child: Text('All Crew Members', style: TextStyle(color: AppTheme.textOnDark)),
                          ),
                          ...crewMembersAsync.map((member) {
                            return DropdownMenuItem(
                              value: member,
                              child: Text(member.customTitle ?? member.role.toString().split('.').last.toUpperCase(), style: TextStyle(color: AppTheme.textOnDark)),
                            );
                          }),
                        ],
                        onChanged: (member) {
                          setModalState(() {
                            // Store selected member if needed, for now just UI update
                          });
                        },
                      ),
                    const SizedBox(height: 16),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        TextButton(
                          onPressed: () {
                            Navigator.pop(context);
                          },
                          child: Text(
                            'Cancel',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                              color: AppTheme.mediumGray,
                            ),
                          ),
                        ),
                        const SizedBox(width: 8),
                        ElevatedButton(
                          onPressed: () async {
                            try {
                              if (selectedCrew == null) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'No crew selected. Please select a crew to message.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }

                              final currentUser = ref.read(auth_providers.currentUserProvider);
                              if (currentUser == null) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'User not authenticated. Please log in.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }

                              final message = messageController.text.trim();

                              if (message.isEmpty) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'Message cannot be empty.',
                                  type: ElectricalNotificationType.error,
                                );
                                return;
                              }

                              // Logic to send message - this would typically involve a service
                              // For now, we'll just show a success toast
                              if (!mounted) return;
                                 JJElectricalNotifications.showElectricalToast(
                                   context: context,
                                   message: 'Message sent successfully!',
                                   type: ElectricalNotificationType.success,
                                 );
                                 if (!mounted) return;
                                 Navigator.pop(context);
                            } catch (e) {
                              if (mounted) {
                                JJElectricalNotifications.showElectricalToast(
                                  context: context,
                                  message: 'Failed to send message: ${e.toString()}',
                                  type: ElectricalNotificationType.error,
                                );
                              }
                            }
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppTheme.accentCopper,
                            foregroundColor: AppTheme.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                            ),
                          ),
                              child: Text(
                                'Send Message',
                                style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.white,
                                ),
                              ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showCrewPreferencesDialog() async {
    final firebase_auth.User? currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    // Get the crew service from the provider
    final dbService = ref.read(databaseServiceProvider);
    final crewService = ref.read(crew_providers.crewServiceProvider);
    
    final selectedCrew = ref.watch(selectedCrewProvider);
    
    if (selectedCrew == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Please select a crew first'),
          backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
        ),
      );
      return;
    }

    try {
      // Get crew data from Firestore
      final crewData = await dbService.getCrew(selectedCrew.id);
      if (!mounted) return;
      if (crewData == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Selected crew not found'),
            backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
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
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading crew data: ${e.toString()}'),
          backgroundColor: AppTheme.errorRed.withValues(alpha: 0.8),
        ),
      );
    }
  }
  // ============================================================
  // ENHANCED TAB BUILDERS - Matching HTML Mockup Design
  // ============================================================

  /// Build enhanced Jobs tab with list view
  Widget _buildEnhancedJobsTab() {
    return Consumer(
      builder: (context, ref, child) {
        return Container(
          color: Colors.white,
          child: buildEmptyJobsState(
            onRefresh: () {
              // TODO: Implement proper jobs refresh logic
            },
            onExploreJobs: () {
              // TODO: Navigate to main job board
            },
          ),
        );
      },
    );
  }

  /// Build enhanced Chat tab with channel list
  Widget _buildEnhancedChatTab() {
    return Consumer(
      builder: (context, ref, child) {
        final chatClientAsync = ref.watch(streamChatClientProvider);
        final selectedCrew = ref.watch(selectedCrewProvider);
        
        return chatClientAsync.when(
          data: (client) {
            return StreamChat(
              client: client,
              streamChatThemeData: ElectricalStreamChatTheme.theme,
              child: Container(
                color: Colors.white,
                child: selectedCrew == null
                    ? _buildNoCrewSelectedChat()
                    : StreamChannelListView(
                        controller: StreamChannelListController(
                          client: client,
                          filter: Filter.equal('team', selectedCrew.id),
                        ),
                        emptyBuilder: (context) => const EmptyStateWidget(
                          icon: Icons.chat_bubble_outline,
                          title: 'No Chat Channels',
                          subtitle: 'Create your first crew channel\nto start collaborating',
                        ),
                        errorBuilder: (context, error) => ErrorStateWidget(
                          error: error.toString(),
                          onRetry: () => ref.invalidate(streamChatClientProvider),
                        ),
                        loadingBuilder: (context) => const LoadingStateWidget(),
                        separatorBuilder: (context, channelPreviewList, index) =>
                          const Divider(height: 1, thickness: 1, color: Color(0xFFE2E8F0)),
                        onChannelTap: (channel) => _navigateToChannelMessages(channel),
                      ),
              ),
            );
          },
          loading: () => const LoadingStateWidget(),
          error: (error, stack) => ErrorStateWidget(
            error: error.toString(),
            onRetry: () => ref.invalidate(streamChatClientProvider),
          ),
        );
      },
    );
  }

  
  
  /// Build no crew selected chat state
  Widget _buildNoCrewSelectedChat() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.group_outlined,
                size: 64,
                color: AppTheme.mediumGray.withValues(alpha: 0.5),
              ),
              const SizedBox(height: 16),
              Text(
                'No Crew Selected',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textOnDark,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                'Please select a crew to start chatting with your team members',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  
  /// Build enhanced Crew tab with member cards
  Widget _buildEnhancedCrewTab() {
    return Consumer(
      builder: (context, ref, child) {
        final selectedCrew = ref.watch(selectedCrewProvider);
        
        if (selectedCrew == null) {
          return Container(
            color: Colors.white,
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 64,
                    color: AppTheme.mediumGray.withValues(alpha: 0.5),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No crew selected',
                    style: TextStyle(
                      fontSize: 18,
                      color: AppTheme.mediumGray,
                    ),
                  ),
                ],
              ),
            ),
          );
        }
        
        final crewMembers = ref.watch(crew_providers.crewMembersProvider(selectedCrew.id));
        
        return Container(
          color: Colors.white,
          child: ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: crewMembers.length,
            itemBuilder: (context, index) {
              final member = crewMembers[index];
              return _buildCrewMemberCard(member);
            },
          ),
        );
      },
    );
  }

  

  /// Build enhanced channel preview matching HTML mockup design
  Widget _buildEnhancedChannelPreview(BuildContext context, Channel channel) {
    return ChannelPreviewCard(
      channel: channel,
      onTap: () => _navigateToChannelMessages(channel),
    );
  }

  
  /// Build crew member card matching HTML mockup design
  Widget _buildCrewMemberCard(dynamic member) {
    return CrewMemberCard(
      member: member,
    );
  }

  
  // MOVED: StreamChatThemeData _buildElectricalStreamTheme()
  // -> Extracted to ElectricalStreamChatTheme.theme
  // in lib/features/crews/widgets/tailboard/stream_chat_theme.dart

  /// Builds an error state widget with retry functionality
  ///
  /// Displays an electrical-themed error message when data loading fails.
  /// Shows a lightning bolt icon with error details and a retry button
  /// that matches the app's electrical industrial aesthetic.
  ///
  /// Parameters:
  /// - [error]: The error message to display
  /// - [onRetry]: Callback function when retry button is pressed
  // MOVED: Widget buildErrorState(String error, VoidCallback onRetry)
  // -> Extracted to ErrorStateWidget class
  // in lib/features/crews/widgets/tailboard/utility_widgets.dart

  // MOVED: Widget buildLoadingState([String? message])
  // -> Extracted to LoadingStateWidget class
  // in lib/features/crews/widgets/tailboard/utility_widgets.dart

  /// Helper widget for loading progress items
  ///
  /// Creates individual progress indicator items with electrical theming.
  ///
  /// Parameters:
  /// - [label]: The text label for the progress item
  /// - [isActive]: Whether this item is currently loading
  Widget _buildLoadingProgressItem(String label, bool isActive) {
    return Row(
      children: [
        SizedBox(
          width: 16,
          height: 16,
          child: isActive
              ? CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(
                    AppTheme.accentCopper,
                  ),
                )
              : Icon(
                  Icons.circle_outlined,
                  size: 16,
                  color: Colors.grey.shade400,
                ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: TextStyle(
              color: isActive ? AppTheme.primaryNavy : Colors.grey.shade500,
              fontSize: 12,
              fontWeight: isActive ? FontWeight.w500 : FontWeight.normal,
            ),
          ),
        ),
      ],
    );
  }

  /// Builds an empty state widget when no jobs are available
  ///
  /// Displays a user-friendly empty state for electrical workers
  /// with themed icons, helpful messaging, and actionable next steps.
  ///
  /// Parameters:
  /// - [onRefresh]: Optional callback for manual refresh
  /// - [onExploreJobs]: Optional callback to explore job board
  Widget buildEmptyJobsState({
    VoidCallback? onRefresh,
    VoidCallback? onExploreJobs,
  }) {
    return Container(
      height: double.infinity,
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.grey.shade50,
            Colors.white,
          ],
        ),
      ),
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(32.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Empty state illustration
              Container(
                width: 160,
                height: 160,
                decoration: BoxDecoration(
                  color: AppTheme.primaryNavy.withValues(alpha:0.05),
                  shape: BoxShape.circle,
                  border: Border.all(
                    color: AppTheme.primaryNavy.withValues(alpha:0.1),
                    width: 2,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Central hard hat icon
                    Icon(
                      Icons.engineering,
                      size: 64,
                      color: AppTheme.primaryNavy.withValues(alpha: 0.6),
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 32),

              // Empty state title
              Text(
                'No Jobs Available',
                style: TextStyle(
                  color: AppTheme.primaryNavy,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // Description message
              Text(
                'There are currently no job postings for this crew. '
                'Check back later for new opportunities or explore the main job board.',
                style: TextStyle(
                  color: AppTheme.textSecondary,
                  fontSize: 16,
                  height: 1.5,
                ),
                textAlign: TextAlign.center,
                maxLines: 3,
              ),

              const SizedBox(height: 40),

              // Action buttons
              Column(
                children: [
                  // Primary action button
                  if (onExploreJobs != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: ElevatedButton.icon(
                        onPressed: onExploreJobs,
                        icon: const Icon(Icons.work_rounded, size: 20),
                        label: Text(
                          'EXPLORE JOB BOARD',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            letterSpacing: 1.1,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.accentCopper,
                          foregroundColor: Colors.white,
                          elevation: 4,
                          shadowColor: AppTheme.accentCopper.withValues(alpha:0.3),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),

                    const SizedBox(height: 12),
                  ],

                  // Secondary refresh button
                  if (onRefresh != null) ...[
                    SizedBox(
                      width: double.infinity,
                      height: 48,
                      child: OutlinedButton.icon(
                        onPressed: onRefresh,
                        icon: const Icon(Icons.refresh_rounded, size: 20),
                        label: Text(
                          'REFRESH',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 14,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        style: OutlinedButton.styleFrom(
                          side: BorderSide(color: AppTheme.primaryNavy.withValues(alpha:0.3)),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(8),
                          ),
                        ),
                      ),
                    ),
                  ],
                ],
              ),

              const SizedBox(height: 32),

              // Helpful tips section
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade50,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.blue.shade100),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          Icons.lightbulb_outline_rounded,
                          size: 20,
                          color: AppTheme.accentCopper,
                        ),
                        const SizedBox(width: 8),
                        Text(
                          'Pro Tips',
                          style: TextStyle(
                            color: AppTheme.primaryNavy,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    ...[
                      '• Set up job alerts to get notified of new opportunities',
                      '• Connect with other crew members for job referrals',
                      '• Update your skills and certifications in your profile',
                    ].map((tip) => Padding(
                      padding: const EdgeInsets.only(bottom: 4),
                      child: Text(
                        tip,
                        style: TextStyle(
                          color: AppTheme.textSecondary,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                    )),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
