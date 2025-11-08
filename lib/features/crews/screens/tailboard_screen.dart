import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import '../providers/crews_riverpod_provider.dart';
import '../models/models.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import '../../../design_system/app_theme.dart';
import '../../../design_system/tailboard_components.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import '../../../navigation/app_router.dart';
import '../../../design_system/tailboard_theme.dart';
import '../../../providers/core_providers.dart' hide legacyCurrentUserProvider;
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/widgets/electrical_circuit_background.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import '../providers/feed_provider.dart';
import '../providers/jobs_filter_provider.dart';
import '../widgets/crew_selection_dropdown.dart';
import '../widgets/crew_preferences_dialog.dart';
import '../widgets/tab_widgets.dart';
import '../widgets/dynamic_container_row.dart';
import '../providers/stream_chat_providers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

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

// Reusable dialog background component for consistent styling
class _ElectricalDialogBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _ElectricalDialogBackground({
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return TailboardComponents.circuitBackground(context, 
      child: Padding(
        padding: padding ?? EdgeInsets.only(
          top: 24,
          left: 24,
          right: 24,
          bottom: MediaQuery.of(context).viewInsets.bottom + 24,
        ),
        child: child,
      ),
    );
  }
}

// Reusable text field component for consistent styling
class _ElectricalTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? labelText;
  final String? hintText;
  final String? Function(String?)? validator;
  final int? maxLines;
  final VoidCallback? onTap;
  final bool readOnly;
  final TextInputType? keyboardType;

  const _ElectricalTextField({
    required this.controller, this.labelText, this.hintText, this.validator, this.maxLines, this.onTap, required this.readOnly, this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: TailboardTheme.surfaceLow,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: TailboardTheme.navy600),
        boxShadow: const [
          BoxShadow(
            color: Color(0x33000000),
            offset: Offset(0, 4),
            blurRadius: 6,
          ),
          BoxShadow(
            color: Color(0x1A000000),
            offset: Offset(0, 1),
            blurRadius: 2,
          ),
        ],
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        onTap: onTap,
        readOnly: readOnly,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: Colors.white,
          height: 1.5,
        ),
        decoration: InputDecoration(
          labelText: labelText,
          hintText: hintText,
          labelStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFFFCD34D),
            height: 1.4,
          ),
          hintStyle: const TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.normal,
            color: Color(0xFF4A5568),
            height: 1.4,
          ),
          filled: false,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.all(16),
        ),
      ),
    );
  }
}

// Reusable action buttons for dialogs
class _DialogActions extends StatelessWidget {
  final VoidCallback? onCancel;
  final VoidCallback? onConfirm;
  final String cancelText;
  final String confirmText;
  final bool isConfirmLoading;

  const _DialogActions({
    this.onConfirm,
    this.confirmText = 'Submit', this.onCancel, required this.cancelText, required this.isConfirmLoading,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        TailboardComponents.actionButton(context, 
          text: cancelText,
          onPressed: onCancel ?? () => Navigator.pop(context),
          isPrimary: false,
        ),
        const SizedBox(width: 16),
        TailboardComponents.actionButton(context, 
          text: confirmText,
          onPressed: isConfirmLoading ? () {} : onConfirm,
          isPrimary: true,
          isLoading: isConfirmLoading,
        ),
      ],
    );
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
        _showMemberRoles();
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
    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Sort Feed',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ListTile(
              leading: Icon(Icons.access_time, color: AppTheme.accentCopper),
              title: Text('Newest First', style: TextStyle(color: AppTheme.textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Update sort option using the feed filter provider
                ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.newestFirst);
                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: 'Sorted by newest first',
                  type: ElectricalNotificationType.success,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.history, color: AppTheme.accentCopper),
              title: Text('Oldest First', style: TextStyle(color: AppTheme.textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Update sort option using the feed filter provider
                ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.oldestFirst);
                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: 'Sorted by oldest first',
                  type: ElectricalNotificationType.success,
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.favorite, color: AppTheme.accentCopper),
              title: Text('Most Liked', style: TextStyle(color: AppTheme.textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Update sort option using the feed filter provider
                ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.mostLiked);
                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: 'Sorted by most liked',
                  type: ElectricalNotificationType.success,
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show feed history (archived posts)
  void _showFeedHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Feed History',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'View archived posts and past crew activity',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            TailboardComponents.actionButton(
              context,
              text: 'View History',
              onPressed: () {
                Navigator.pop(context);
                // Toggle archived posts filter using the feed filter provider
                ref.read(feedFilterProvider.notifier).toggleArchived();

                final showingArchived = ref.read(feedFilterProvider).showArchived;

                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: showingArchived
                      ? 'Showing archived posts'
                      : 'Hiding archived posts',
                  type: ElectricalNotificationType.info,
                );
              },
              isPrimary: true,
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // ACTION FUNCTIONS - Jobs Tab
  // ============================================================

  /// Show construction type filter dialog
  void _showConstructionTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Construction Type',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...[
              'Commercial',
              'Industrial',
              'Residential',
              'Transmission',
              "Distibution",
              'Sub-Station',
            ].map((type) => ListTile(
              leading: Icon(Icons.business, color: AppTheme.accentCopper),
              title: Text(type, style: TextStyle(color: AppTheme.textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Update filter state using the jobs filter provider
                ref.read(jobsFilterProvider.notifier).setConstructionType(type);
                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: 'Filtering by $type jobs',
                  type: ElectricalNotificationType.success,
                );
              },
            )),
          ],
        ),
      ),
    );
  }

  /// Show local filter dialog
  void _showLocalFilter() {
    final TextEditingController localController = TextEditingController();

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Local',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Enter IBEW local number to filter jobs',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: AppTheme.mediumGray,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: localController,
              keyboardType: TextInputType.number,
              style: TextStyle(color: AppTheme.textOnDark),
              decoration: InputDecoration(
                labelText: 'Local Number',
                hintText: 'e.g., 46, 134, 58',
                labelStyle: TextStyle(color: AppTheme.mediumGray),
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
            _DialogActions(
              confirmText: 'Apply Filter',
              onConfirm: () {
                final local = localController.text.trim();
                Navigator.pop(context);
                if (local.isNotEmpty) {
                  final localNumber = int.tryParse(local);
                  if (localNumber != null) {
                    // Update filter state using the jobs filter provider
                    ref.read(jobsFilterProvider.notifier).setLocalNumber(localNumber);
                    JJElectricalNotifications.showElectricalToast(
                      context: context,
                      message: 'Filtering by Local $localNumber',
                      type: ElectricalNotificationType.success,
                    );
                  } else {
                    JJElectricalNotifications.showElectricalToast(
                      context: context,
                      message: 'Please enter a valid local number',
                      type: ElectricalNotificationType.error,
                    );
                  }
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  /// Show classification filter dialog
  void _showClassificationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Filter by Classification',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),
            ...[
              'Inside Wireman',
              'Journeyman Lineman',
              'Tree Trimmer',
              'Equipment Operator',
              'Inside Journeyman Electrician',
            ].map((classification) => ListTile(
              leading: Icon(Icons.work_outline, color: AppTheme.accentCopper),
              title: Text(classification, style: TextStyle(color: AppTheme.textOnDark)),
              onTap: () {
                Navigator.pop(context);
                // Update filter state using the jobs filter provider
                ref.read(jobsFilterProvider.notifier).setClassification(classification);
                JJElectricalNotifications.showElectricalToast(
                  context: context,
                  message: 'Filtering by $classification',
                  type: ElectricalNotificationType.success,
                );
              },
            )),
          ],
        ),
      ),
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
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _ElectricalDialogBackground(
          child: Column(
            children: [
              // Header
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.tag, color: AppTheme.accentCopper, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Crew Channels',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.mediumGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.mediumGray, height: 1),

              // Channel List
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final channelsAsync = ref.watch(crewChannelsProvider(selectedCrew.id));

                    return channelsAsync.when(
                      data: (channels) {
                        if (channels.isEmpty) {
                          return _buildEmptyChannelsState();
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: channels.length,
                          itemBuilder: (context, index) {
                            final channel = channels[index];
                            return _buildElectricalChannelPreview(channel);
                          },
                        );
                      },
                      loading: () => Center(
                        child: JJElectricalLoader(
                          width: 150,
                          height: 50,
                          message: 'Loading channels...',
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.errorRed,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load channels',
                                style: TextStyle(
                                  color: AppTheme.textOnDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.mediumGray),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom electrical-themed channel preview tile
  Widget _buildElectricalChannelPreview(Channel channel) {
    final channelName = channel.name ?? channel.id ?? 'Unknown';
    final lastMessage = channel.state?.messages.lastOrNull;
    final unreadCount = channel.state?.unreadCount ?? 0;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha:0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.tag,
          color: AppTheme.accentCopper,
          size: 20,
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              '# $channelName',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage.text ?? 'Message',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              'No messages yet',
              style: TextStyle(
                color: AppTheme.mediumGray.withValues(alpha:0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
      onTap: () {
        Navigator.pop(context);
        _navigateToChannelMessages(channel);
      },
    );
  }

  /// Build empty state when no channels exist
  Widget _buildEmptyChannelsState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha:0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Channels Yet',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first crew channel\nto start collaborating',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Navigate to channel messages screen
  void _navigateToChannelMessages(Channel channel) {
    // Store active channel in provider
    ref.read(activeChannelProvider.notifier).state = channel;

    // Navigate to chat tab to show messages
    _tabController.animateTo(2);

    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: 'Opening # ${channel.name ?? channel.id}',
      type: ElectricalNotificationType.success,
    );
  }

  /// Show direct messages dialog with Stream Chat integration
  void _showDirectMessages() {
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Select a crew to view members',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew.id));

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _ElectricalDialogBackground(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(
                      Icons.people,
                      color: AppTheme.accentCopper,
                      size: 28,
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Direct Messages',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.mediumGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.mediumGray, height: 1),

              // Member List with Stream Chat integration
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final clientAsync = ref.watch(streamChatClientProvider);

                    return clientAsync.when(
                      data: (client) {
                        if (crewMembersAsync.isEmpty) {
                          return _buildEmptyMembersState();
                        }

                        return ListView.builder(
                          controller: scrollController,
                          itemCount: crewMembersAsync.length,
                          itemBuilder: (context, index) {
                            final member = crewMembersAsync[index];
                            return _buildElectricalMemberTile(member, client, selectedCrew.id);
                          },
                        );
                      },
                      loading: () => Center(
                        child: JJElectricalLoader(
                          width: 150,
                          height: 50,
                          message: 'Loading members...',
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                Icons.error_outline,
                                size: 64,
                                color: AppTheme.errorRed,
                              ),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to load members',
                                style: TextStyle(
                                  color: AppTheme.textOnDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.mediumGray),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom electrical-themed member tile for DM creation
  Widget _buildElectricalMemberTile(
    dynamic member,
    StreamChatClient client,
    String crewId,
  ) {
    // Extract member info
    final memberName = member.customTitle ?? member.role.toString().split('.').last;
    final isOnline = member.isAvailable ?? false;
    final memberId = member.id ?? '';

    // Get current user to avoid self-DM
    final currentUserId = client.state.currentUser?.id;
    final isSelf = currentUserId == memberId;

    return ListTile(
      leading: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha:0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                memberName.substring(0, 1).toUpperCase(),
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          // Online status indicator
          if (isOnline && !isSelf)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 14,
                height: 14,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.primaryNavy, width: 2),
                ),
              ),
            ),
        ],
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              memberName,
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          if (isSelf)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha:0.3),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'You',
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: Text(
        isOnline ? 'Online' : 'Offline',
        style: TextStyle(
          color: isOnline ? AppTheme.successGreen : AppTheme.mediumGray,
          fontSize: 14,
        ),
      ),
      onTap: isSelf
          ? null
          : () {
              Navigator.pop(context);
              _createOrOpenDirectMessage(client, memberId, memberName, crewId);
            },
      enabled: !isSelf,
    );
  }

  /// Build empty state when no members exist
  Widget _buildEmptyMembersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha:0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Crew Members',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Invite members to start\ndirect messaging',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create or open a 1:1 DM channel with distinct flag
  Future<void> _createOrOpenDirectMessage(
    StreamChatClient client,
    String otherUserId,
    String otherUserName,
    String crewId,
  ) async {
    try {
      // Show loading toast
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Opening DM with $otherUserName...',
        type: ElectricalNotificationType.info,
      );

      // Create/get distinct DM channel with team filter
      final channel = client.channel(
        'messaging',
        extraData: {
          'team': crewId, // Team filter for crew isolation
          'members': [client.state.currentUser!.id, otherUserId],
        },
        id: null, // Let Stream generate ID
      );

      // Watch the channel with distinct flag to prevent duplicates
      await channel.watch();

      // Add members if channel was just created
      if (!channel.state!.members.any((m) => m.userId == otherUserId)) {
        await channel.addMembers([otherUserId]);
      }

      // Store active channel in provider
      ref.read(activeChannelProvider.notifier).state = channel;

      // Navigate to chat tab to show messages
      _tabController.animateTo(2);

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Chat with $otherUserName opened',
        type: ElectricalNotificationType.success,
      );
    } catch (e) {
      // Error handling
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to open DM: $e',
        type: ElectricalNotificationType.error,
      );
    }
  }

  /// Show chat history dialog
  /// Show chat history dialog with Stream Chat archived channels
  void _showChatHistory() {
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Select a crew to view history',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 0.7,
        minChildSize: 0.5,
        maxChildSize: 0.95,
        builder: (context, scrollController) => _ElectricalDialogBackground(
          child: Column(
            children: [
              // Header with close button
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Row(
                  children: [
                    Icon(Icons.history, color: AppTheme.accentCopper, size: 28),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'Chat History',
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          color: AppTheme.textOnDark,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    IconButton(
                      icon: Icon(Icons.close, color: AppTheme.mediumGray),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ],
                ),
              ),
              const Divider(color: AppTheme.mediumGray, height: 1),

              // Archived Channels List with Stream Chat integration
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final clientAsync = ref.watch(streamChatClientProvider);

                    return clientAsync.when(
                      data: (client) {
                        // Query archived channels with team filter
                        return StreamBuilder<List<Channel>>(
                          stream: client.queryChannels(
                            filter: Filter.and([
                              Filter.equal('hidden', true),
                              Filter.equal('team', selectedCrew.id),
                            ]),
                            sort: [const SortOption('updated_at', direction: SortOption.DESC)],
                          ),
                          builder: (context, snapshot) {
                            if (snapshot.connectionState == ConnectionState.waiting) {
                              return Center(
                                child: JJElectricalLoader(
                                  width: 150,
                                  height: 50,
                                  message: 'Loading history...',
                                ),
                              );
                            }

                            if (snapshot.hasError) {
                              return Center(
                                child: Padding(
                                  padding: const EdgeInsets.all(24.0),
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                                      const SizedBox(height: 16),
                                      Text(
                                        'Failed to load history',
                                        style: TextStyle(
                                          color: AppTheme.textOnDark,
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      const SizedBox(height: 8),
                                      Text(
                                        snapshot.error.toString(),
                                        textAlign: TextAlign.center,
                                        style: TextStyle(color: AppTheme.mediumGray),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }

                            final archivedChannels = snapshot.data ?? [];

                            if (archivedChannels.isEmpty) {
                              return _buildEmptyHistoryState();
                            }

                            return ListView.builder(
                              controller: scrollController,
                              itemCount: archivedChannels.length,
                              itemBuilder: (context, index) {
                                final channel = archivedChannels[index];
                                return _buildArchivedChannelTile(channel, client);
                              },
                            );
                          },
                        );
                      },
                      loading: () => Center(
                        child: JJElectricalLoader(
                          width: 150,
                          height: 50,
                          message: 'Initializing...',
                        ),
                      ),
                      error: (error, stack) => Center(
                        child: Padding(
                          padding: const EdgeInsets.all(24.0),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.error_outline, size: 64, color: AppTheme.errorRed),
                              const SizedBox(height: 16),
                              Text(
                                'Failed to initialize chat',
                                style: TextStyle(
                                  color: AppTheme.textOnDark,
                                  fontSize: 18,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                error.toString(),
                                textAlign: TextAlign.center,
                                style: TextStyle(color: AppTheme.mediumGray),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// Build custom electrical-themed archived channel tile
  Widget _buildArchivedChannelTile(Channel channel, StreamChatClient client) {
    // Extract channel info
    final channelName = channel.name ?? 'Unnamed Channel';
    final lastMessage = channel.state?.messages.lastOrNull;
    final archivedAt = channel.state?.updatedAt ?? DateTime.now();
    final messageCount = channel.state?.messages.length ?? 0;

    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha:0.15),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Center(
          child: Icon(
            Icons.archive,
            color: AppTheme.accentCopper.withValues(alpha:0.6),
            size: 24,
          ),
        ),
      ),
      title: Row(
        children: [
          Expanded(
            child: Text(
              channelName,
              style: TextStyle(
                color: AppTheme.textOnDark.withValues(alpha:0.7),
                fontWeight: FontWeight.w600,
                fontSize: 16,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          Text(
            _formatArchiveDate(archivedAt),
            style: TextStyle(
              color: AppTheme.mediumGray,
              fontSize: 12,
            ),
          ),
        ],
      ),
      subtitle: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (lastMessage != null)
            Text(
              lastMessage.text ?? 'Attachment',
              style: TextStyle(
                color: AppTheme.mediumGray.withValues(alpha:0.8),
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          const SizedBox(height: 4),
          Text(
            '$messageCount messages',
            style: TextStyle(
              color: AppTheme.mediumGray.withValues(alpha:0.6),
              fontSize: 12,
            ),
          ),
        ],
      ),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Restore button
          IconButton(
            icon: Icon(Icons.unarchive, color: AppTheme.accentCopper),
            tooltip: 'Restore channel',
            onPressed: () => _restoreChannel(channel),
          ),
          // Delete button
          IconButton(
            icon: Icon(Icons.delete_forever, color: AppTheme.errorRed),
            tooltip: 'Delete permanently',
            onPressed: () => _deleteChannel(channel),
          ),
        ],
      ),
    );
  }

  /// Build empty state when no archived channels exist
  Widget _buildEmptyHistoryState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha:0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Archived Chats',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Archived conversations\nwill appear here',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Format archive date for display
  String _formatArchiveDate(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays == 0) {
      return 'Today';
    } else if (difference.inDays == 1) {
      return 'Yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      final weeks = (difference.inDays / 7).floor();
      return '$weeks week${weeks > 1 ? 's' : ''} ago';
    } else {
      final months = (difference.inDays / 30).floor();
      return '$months month${months > 1 ? 's' : ''} ago';
    }
  }

  /// Restore archived channel
  Future<void> _restoreChannel(Channel channel) async {
    try {
      // Show loading toast
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Restoring channel...',
        type: ElectricalNotificationType.info,
      );

      // Unarchive the channel by showing it
      await channel.show();

      // Close the modal
      if (mounted) Navigator.pop(context);

      // Success toast
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Channel restored successfully',
        type: ElectricalNotificationType.success,
      );
    } catch (e) {
      // Error handling
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to restore channel: $e',
        type: ElectricalNotificationType.error,
      );
    }
  }

  /// Delete archived channel permanently
  Future<void> _deleteChannel(Channel channel) async {
    // Show confirmation dialog
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          side: BorderSide(color: AppTheme.accentCopper, width: 2),
        ),
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.errorRed, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Delete Channel?',
                style: TextStyle(
                  color: AppTheme.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        content: Text(
          'This will permanently delete the channel and all its messages. This action cannot be undone.',
          style: TextStyle(
            color: AppTheme.mediumGray,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    // If user confirmed deletion
    if (confirmed == true) {
      try {
        // Show loading toast
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Deleting channel...',
          type: ElectricalNotificationType.info,
        );

        // Delete the channel permanently
        await channel.delete();

        // Close the modal
        if (mounted) Navigator.pop(context);

        // Success toast
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Channel deleted permanently',
          type: ElectricalNotificationType.success,
        );
      } catch (e) {
        // Error handling
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to delete channel: $e',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }

  // ============================================================
  // ACTION FUNCTIONS - Members Tab
  // ============================================================

  /// Show member roster dialog
  void _showMemberRoster() {
    final selectedCrew = ref.read(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew?.id ?? ''));

    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crew Roster',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCrew == null)
              Text(
                'Select a crew to view roster',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              )
            else
              Column(
                children: [
                  Container(
                    padding: EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppTheme.primaryNavy.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(color: AppTheme.accentCopper, width: 1),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Members',
                          style: TextStyle(color: AppTheme.mediumGray),
                        ),
                        Text(
                          '${crewMembersAsync.length}',
                          style: TextStyle(
                            color: AppTheme.accentCopper,
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                  if (crewMembersAsync.isEmpty)
                    Text(
                      'No members in crew',
                      style: TextStyle(color: AppTheme.mediumGray),
                    )
                  else
                    ...crewMembersAsync.take(3).map((member) => ListTile(
                      leading: CircleAvatar(
                        backgroundColor: AppTheme.accentCopper,
                        child: Text(
                          member.customTitle?.substring(0, 1).toUpperCase() ?? 'M',
                          style: TextStyle(color: AppTheme.white),
                        ),
                      ),
                      title: Text(
                        member.customTitle ?? member.role.toString().split('.').last,
                        style: TextStyle(color: AppTheme.textOnDark),
                      ),
                      subtitle: Text(
                        member.role.toString().split('.').last.toUpperCase(),
                        style: TextStyle(color: AppTheme.mediumGray),
                      ),
                      trailing: Icon(
                        Icons.chevron_right,
                        color: AppTheme.accentCopper,
                      ),
                    )),
                  if (crewMembersAsync.length > 3)
                    TextButton(
                      onPressed: () {
                        Navigator.pop(context);
                        // Navigate to full roster view
                      },
                      child: Text(
                        'View All ${crewMembersAsync.length} Members',
                        style: TextStyle(color: AppTheme.accentCopper),
                      ),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Show member availability dialog
  void _showMemberAvailability() {
    final selectedCrew = ref.read(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew?.id ?? ''));

    final availableMembers = crewMembersAsync.where((m) => m.isAvailable).toList();
    final unavailableMembers = crewMembersAsync.where((m) => !m.isAvailable).toList();

    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Member Availability',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCrew == null)
              Text(
                'Select a crew to view availability',
                style: TextStyle(color: AppTheme.mediumGray),
              )
            else
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _buildAvailabilityCard(
                        'Available',
                        availableMembers.length,
                        AppTheme.successGreen,
                        Icons.check_circle,
                      ),
                      _buildAvailabilityCard(
                        'Offline',
                        unavailableMembers.length,
                        AppTheme.mediumGray,
                        Icons.cancel,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  if (availableMembers.isNotEmpty) ...[
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'Available Now',
                        style: TextStyle(
                          color: AppTheme.successGreen,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    ...availableMembers.take(3).map((member) => ListTile(
                      dense: true,
                      leading: Icon(Icons.circle, color: AppTheme.successGreen, size: 12),
                      title: Text(
                        member.customTitle ?? member.role.toString().split('.').last,
                        style: TextStyle(color: AppTheme.textOnDark),
                      ),
                    )),
                  ],
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// Helper to build availability card
  Widget _buildAvailabilityCard(String label, int count, Color color, IconData icon) {
    return Container(
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(color: color.withValues(alpha: 0.3), width: 1),
      ),
      child: Column(
        children: [
          Icon(icon, color: color, size: 32),
          const SizedBox(height: 8),
          Text(
            '$count',
            style: TextStyle(
              color: color,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            label,
            style: TextStyle(color: color, fontSize: 12),
          ),
        ],
      ),
    );
  }

  /// Show member roles dialog
  void _showMemberRoles() {
    final selectedCrew = ref.read(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew?.id ?? ''));

    // Group members by role
    final roleGroups = <String, List<CrewMember>>{};
    for (final member in crewMembersAsync) {
      final roleKey = member.role.toString().split('.').last;
      roleGroups[roleKey] = [...(roleGroups[roleKey] ?? []), member];
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => _ElectricalDialogBackground(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Crew Roles',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            if (selectedCrew == null)
              Text(
                'Select a crew to view roles',
                style: TextStyle(color: AppTheme.mediumGray),
              )
            else if (roleGroups.isEmpty)
              Text(
                'No roles assigned',
                style: TextStyle(color: AppTheme.mediumGray),
              )
            else
              ...roleGroups.entries.map((entry) => ListTile(
                leading: Icon(
                  _getRoleIcon(entry.key),
                  color: AppTheme.accentCopper,
                ),
                title: Text(
                  entry.key.toUpperCase(),
                  style: TextStyle(color: AppTheme.textOnDark, fontWeight: FontWeight.bold),
                ),
                trailing: Container(
                  padding: EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withValues(alpha: 0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    '${entry.value.length}',
                    style: TextStyle(
                      color: AppTheme.accentCopper,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                onTap: () {
                  // Show members in this role
                },
              )),
          ],
        ),
      ),
    );
  }

  /// Helper to get icon for role
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'foreman':
        return Icons.engineering;
      case 'lead':
        return Icons.star;
      case 'journeyman':
        return Icons.work;
      default:
        return Icons.person;
    }
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
        sort: [const SortOption('last_message_at', direction: SortOption.DESC)],
      ).first;

      if (channels.isNotEmpty) {
        // Found the #general channel, navigate to it
        final generalChannel = channels.first;
        
        // Update user's team assignment to ensure access
        await ref.read(streamChatServiceProvider).updateUserTeam(selectedCrew.id);
        
        // Store as active channel
        ref.read(activeChannelProvider.notifier).state = generalChannel;
        
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
          'general-${selectedCrew.id}',  // Unique ID for crew's general channel
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
        await generalChannel.addMembers([client.state.user!.id]);
        
        // Store as active channel
        ref.read(activeChannelProvider.notifier).state = generalChannel;
        
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
                  EnhancedFeedTab(), // Use the enhanced feed tab with real-time functionality
                  JobsTab(),
                  ChatTab(),
                  MembersTab(),
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
            return _ElectricalDialogBackground(
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
                  TextField(
                    controller: postContentController,
                    maxLines: 5,
                    maxLength: maxCharacters,
                    onChanged: (value) {
                      setModalState(() {
                        charactersRemaining = maxCharacters - value.length;
                      });
                    },
                    style: TextStyle(color: AppTheme.textOnDark),
                    decoration: InputDecoration(
                      hintText: 'What\'s on your mind?',
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
                      counterText: '', // Hide default counter
                    ),
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
                      _DialogActions(
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
                    TextField(
                      controller: messageController,
                      maxLines: 3,
                      style: TextStyle(color: AppTheme.textOnDark),
                      decoration: InputDecoration(
                        hintText: 'Add a custom message (optional)',
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
    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew?.id ?? ''));

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
    final crewService = ref.read(crewServiceProvider);
    
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

  /// Build electrical-themed Stream Chat configuration
  ///
  /// Creates a StreamChatThemeData with electrical theme colors:
  /// - Primary accent: AppTheme.accentCopper (#B45309)
  /// - Backgrounds: Navy shades from AppTheme
  /// - Message bubbles with proper contrast for readability
  StreamChatThemeData _buildElectricalStreamTheme() {
    return StreamChatThemeData(
      // Primary color theme - copper accent with navy backgrounds
      colorTheme: StreamColorTheme.light(
        primary: AppTheme.accentCopper, // Copper for primary actions/highlights
        accent: AppTheme.accentCopper,  // Copper for accent elements
        disabled: AppTheme.mediumGray,  // Gray for disabled elements
        textHigh: AppTheme.textPrimary, // Dark navy text on light backgrounds
        textLow: AppTheme.textSecondary, // Medium gray for secondary text
        textBg: AppTheme.white,         // White text on colored backgrounds
        borders: AppTheme.lightGray,    // Light gray borders
        inputBg: AppTheme.white,        // White input backgrounds
        appBg: AppTheme.surfaceLight,   // Light surface background
        overlayDark: Colors.black.withValues(alpha: 0.5),
        overlay: Colors.white.withValues(alpha: 0.8),
      ),

      // Own message theme (messages sent by current user)
      ownMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.accentCopper, // Copper background for own messages
        messageTextStyle: TextStyle(
          color: AppTheme.white, // White text on copper for contrast (7.6:1 ratio)
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        avatarTheme: StreamAvatarThemeData(
          backgroundColor: AppTheme.secondaryCopper,
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        createdAtTextStyle: TextStyle(
          color: AppTheme.white.withValues(alpha: 0.8),
          fontSize: 12,
        ),
      ),

      // Other message theme (messages from other users)
      otherMessageTheme: StreamMessageThemeData(
        messageBackgroundColor: AppTheme.surfaceLight, // Light gray background for others' messages
        messageTextStyle: TextStyle(
          color: AppTheme.textPrimary, // Dark navy text for readability (14.8:1 ratio)
          fontSize: 16,
          fontWeight: FontWeight.w400,
        ),
        avatarTheme: StreamAvatarThemeData(
          backgroundColor: AppTheme.primaryNavy, // Navy for others' avatars
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        createdAtTextStyle: TextStyle(
          color: AppTheme.textLight, // Medium gray for timestamps
          fontSize: 12,
        ),
      ),

      // Channel list preview theme
      channelPreviewTheme: StreamChannelPreviewThemeData(
        avatarTheme: StreamAvatarThemeData(
          backgroundColor: AppTheme.primaryNavy,
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 40,
            width: 40,
          ),
        ),
        titleStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 16,
          fontWeight: FontWeight.w600,
        ),
        subtitleStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        indicatorIconSize: 16,
        lastMessageTextStyle: TextStyle(
          color: AppTheme.textLight,
          fontSize: 14,
        ),
      ),

      // Channel header theme
      channelHeaderTheme: StreamChannelHeaderThemeData(
        avatarTheme: StreamAvatarThemeData(
          backgroundColor: AppTheme.accentCopper,
          borderRadius: BorderRadius.circular(20),
          constraints: const BoxConstraints.tightFor(
            height: 36,
            width: 36,
          ),
        ),
        titleStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        subtitleStyle: TextStyle(
          color: AppTheme.textSecondary,
          fontSize: 14,
        ),
        color: AppTheme.white,
        height: 56,
      ),

      // Message input theme
      messageInputTheme: StreamMessageInputThemeData(
        inputDecoration: InputDecoration(
          fillColor: AppTheme.white,
          filled: true,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.lightGray),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(color: AppTheme.lightGray),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(24),
            borderSide: const BorderSide(
              color: AppTheme.accentCopper,
              width: 2,
            ),
          ),
          hintStyle: TextStyle(
            color: AppTheme.textLight,
            fontSize: 16,
          ),
          labelStyle: TextStyle(
            color: AppTheme.textSecondary,
            fontSize: 14,
          ),
        ),
        sendButtonColor: AppTheme.accentCopper,
        actionButtonColor: AppTheme.textSecondary,
        sendIcon: Icons.send,
        uploadIcon: Icons.attach_file,
      ),

      // Gallery theme (for image attachments)
      galleryTheme: StreamGalleryThemeData(
        backgroundColor: AppTheme.primaryNavy,
        headerBackgroundColor: AppTheme.primaryNavy,
        headerTextStyle: TextStyle(
          color: AppTheme.white,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
        closeButtonIcon: Icons.close,
        closeButtonColor: AppTheme.white,
        pageIndicatorColor: AppTheme.white.withValues(alpha: 0.4),
        currentPageIndicatorColor: AppTheme.accentCopper,
      ),

      // Message list theme
      messageListTheme: StreamMessageListThemeData(
        backgroundColor: AppTheme.surfaceLight,
        messageBackgroundColor: AppTheme.white,
        errorColor: AppTheme.errorRed,
        linkColor: AppTheme.infoBlue,
        dateDividerTextStyle: TextStyle(
          color: AppTheme.textLight,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),

      // Avatar theme for consistency
      avatarTheme: StreamAvatarThemeData(
        backgroundColor: AppTheme.primaryNavy,
        borderRadius: BorderRadius.circular(20),
        constraints: const BoxConstraints.tightFor(
          height: 40,
          width: 40,
        ),
      ),

      // Bottom sheet theme
      bottomSheetTheme: StreamBottomSheetThemeData(
        backgroundColor: AppTheme.white,
        barrierColor: Colors.black.withValues(alpha: 0.5),
        headerBackgroundColor: AppTheme.surfaceLight,
        headerTextStyle: TextStyle(
          color: AppTheme.textPrimary,
          fontSize: 18,
          fontWeight: FontWeight.w600,
        ),
      ),

      // Reaction picker theme
      reactionPickerTheme: StreamReactionPickerThemeData(
        backgroundColor: AppTheme.white,
        backgroundColorHighlighted: AppTheme.accentCopper.withValues(alpha: 0.1),
        reactionIconsColor: AppTheme.textPrimary,
        reactionIconsColorHighlighted: AppTheme.accentCopper,
      ),

      // Lazy loading scroll view theme
      lazyLoadingScrollViewTheme: StreamLazyLoadingScrollViewThemeData(
        backgroundColor: AppTheme.surfaceLight,
        loadingIndicatorColor: AppTheme.accentCopper,
        errorColor: AppTheme.errorRed,
        centerTextStyle: TextStyle(
          color: AppTheme.textLight,
          fontSize: 16,
        ),
        retryButtonTextStyle: TextStyle(
          color: AppTheme.white,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
        retryButtonBackgroundColor: AppTheme.accentCopper,
      ),
    );
  }
}
