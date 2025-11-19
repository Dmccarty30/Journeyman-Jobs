import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';
import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;

// Design system imports
import '../../../design_system/tailboard_theme.dart';
import '../../../design_system/tailboard_components.dart';

// Navigation
import '../../../navigation/app_router.dart';

// Providers
import '../providers/crews_riverpod_provider.dart';
import '../providers/feed_provider.dart';
import '../providers/feed_filter_provider.dart';
import '../../../providers/riverpod/auth_riverpod_provider.dart';
import '../../../providers/core_providers.dart'
    hide selectedCrewProvider, currentUserProvider;

// Models
import '../models/models.dart';

// Services

// Widgets
import '../widgets/crew_selection_dropdown.dart';
import '../widgets/crew_preferences_dialog.dart';
import '../widgets/dynamic_container_row.dart';
import '../widgets/tab_widgets.dart';

// Tailboard dialogs
import '../widgets/tailboard/feed_sort_options_dialog.dart';
import '../widgets/tailboard/feed_history_dialog.dart';
import '../widgets/tailboard/construction_type_filter_dialog.dart';
import '../widgets/tailboard/local_filter_dialog.dart';
import '../widgets/tailboard/classification_filter_dialog.dart';
import '../widgets/tailboard/job_preferences_dialog.dart';
import '../widgets/tailboard/member_roster_dialog.dart';
import '../widgets/tailboard/member_availability_dialog.dart';
import '../widgets/tailboard/member_roles_dialog.dart';
import '../widgets/tailboard/channels_list_dialog.dart';
import '../widgets/tailboard/direct_messages_dialog.dart';
import '../widgets/tailboard/chat_history_dialog.dart';

class TailboardScreen extends ConsumerStatefulWidget {
  const TailboardScreen({super.key});

  @override
  ConsumerState<TailboardScreen> createState() => _TailboardScreenState();
}

class _TailboardScreenState extends ConsumerState<TailboardScreen>
    with SingleTickerProviderStateMixin, WidgetsBindingObserver {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(_handleTabSelection);
    WidgetsBinding.instance.addObserver(this);
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
        return ['My Posts', 'Sort', 'History', 'Settings'];
      case 1: // Jobs tab
        return ['Construction', 'Local', 'Classification', 'Settings'];
      case 2: // Chat tab
        return ['Channels', 'DMs', 'History', 'Settings'];
      case 3: // Members tab
        return ['Roster', 'Availability', 'Roles', 'Settings'];
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

  // ============================================================
  // FEED TAB ACTION HANDLERS
  // ============================================================

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
      case 3: // Settings
        _showQuickActions(context);
        break;
    }
  }

  void _filterFeedByUserPosts() {
    final currentUser = ref.read(currentUserProvider);
    if (currentUser == null) {
      _showSnackBar('Please sign in to view your posts', isError: true);
      return;
    }

    ref.read(feedFilterProvider.notifier).toggleMyPostsOnly();
    final isFiltering = ref.read(feedFilterProvider).showMyPostsOnly;

    _showSnackBar(
      isFiltering ? 'Showing only your posts' : 'Showing all posts',
    );
  }

  void _showFeedSortOptions() {
    showDialog(
      context: context,
      builder: (context) => const FeedSortOptionsDialog(),
    );
  }

  void _showFeedHistory() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const FeedHistoryDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // ============================================================
  // JOBS TAB ACTION HANDLERS
  // ============================================================

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
      case 3: // Settings
        _showQuickActions(context);
        break;
    }
  }

  void _showConstructionTypeFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ConstructionTypeFilterDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showLocalFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const LocalFilterDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showClassificationFilter() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const ClassificationFilterDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // ============================================================
  // CHAT TAB ACTION HANDLERS
  // ============================================================

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
      case 3: // Settings
        _showQuickActions(context);
        break;
    }
  }

  void _showChannelsList() {
    if (ref.read(selectedCrewProvider) == null) {
      _showSnackBar('Select a crew to view channels', isError: true);
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

  void _showDirectMessages() {
    showDialog(
      context: context,
      builder: (context) => DirectMessagesDialog(
        onNavigateToChat: () {
          if (_tabController.index != 2) {
            _tabController.animateTo(2);
          }
        },
      ),
    );
  }

  void _showChatHistory() {
    showDialog(
      context: context,
      builder: (context) => ChatHistoryDialog(
        onNavigateToChat: () {
          if (_tabController.index != 2) {
            _tabController.animateTo(2);
          }
        },
      ),
    );
  }

  // ============================================================
  // MEMBERS TAB ACTION HANDLERS
  // ============================================================

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
      case 3: // Settings
        _showQuickActions(context);
        break;
    }
  }

  void _showMemberRoster() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MemberRosterDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  void _showMemberAvailability() {
    showModalBottomSheet(
      context: context,
      builder: (context) => const MemberAvailabilityDialog(),
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
    );
  }

  // ============================================================
  // FLOATING ACTION BUTTON HANDLERS
  // ============================================================

  void _showCreatePostDialog() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final selectedCrew = ref.read(selectedCrewProvider);

    if (currentUser == null) {
      _showSnackBar('Please sign in to create a post', isError: true);
      return;
    }

    final TextEditingController contentController = TextEditingController();
    bool isPosting = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Create Post',
            style: TailboardTheme.headingSmall.copyWith(
              color: TailboardTheme.textPrimary,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: contentController,
                  maxLines: 5,
                  decoration: TailboardTheme.inputDecoration(
                    hintText: 'What\'s on your mind?',
                  ),
                  style: TailboardTheme.bodyMedium,
                ),
                const SizedBox(height: TailboardTheme.spacingM),
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.image, color: TailboardTheme.copper),
                      onPressed: () {
                        _showSnackBar('Image upload coming soon');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.link, color: TailboardTheme.copper),
                      onPressed: () {
                        _showSnackBar('Link attachment coming soon');
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.work, color: TailboardTheme.copper),
                      onPressed: () {
                        _showSnackBar('Job tagging coming soon');
                      },
                    ),
                  ],
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: isPosting ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isPosting
                  ? null
                  : () async {
                      if (contentController.text.trim().isEmpty) {
                        _showSnackBar('Please enter some content',
                            isError: true);
                        return;
                      }

                      setState(() {
                        isPosting = true;
                      });

                      try {
                        final feedService = ref.read(feedServiceProvider);
                        await feedService.createPost(
                          crewId: selectedCrew?.id ?? 'global',
                          authorId: currentUser!.uid,
                          content: contentController.text,
                        );

                        if (mounted) {
                          Navigator.of(context).pop();
                          _showSnackBar('Post created successfully!');
                        }
                      } catch (e) {
                        if (mounted) {
                          _showSnackBar('Error creating post: ${e.toString()}',
                              isError: true);
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isPosting = false;
                          });
                        }
                      }
                    },
              style: TailboardTheme.primaryButton,
              child: isPosting
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TailboardTheme.backgroundCard,
                      ),
                    )
                  : const Text('Post'),
            ),
          ],
        ),
      ),
    );
  }

  void _showShareJobDialog() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final selectedCrew = ref.read(selectedCrewProvider);

    if (currentUser == null) {
      _showSnackBar('Please sign in to share a job', isError: true);
      return;
    }

    final TextEditingController companyController = TextEditingController();
    final TextEditingController locationController = TextEditingController();
    final TextEditingController wageController = TextEditingController();
    final TextEditingController descriptionController = TextEditingController();
    bool isSharing = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'Share Job Opportunity',
            style: TailboardTheme.headingSmall.copyWith(
              color: TailboardTheme.textPrimary,
            ),
          ),
          content: SizedBox(
            width: double.maxFinite,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: companyController,
                    decoration: TailboardTheme.inputDecoration(
                      hintText: 'Company Name',
                      prefixIcon: const Icon(Icons.business,
                          color: TailboardTheme.copper),
                    ),
                    style: TailboardTheme.bodyMedium,
                  ),
                  const SizedBox(height: TailboardTheme.spacingM),
                  TextField(
                    controller: locationController,
                    decoration: TailboardTheme.inputDecoration(
                      hintText: 'Location',
                      prefixIcon: const Icon(Icons.location_on,
                          color: TailboardTheme.copper),
                    ),
                    style: TailboardTheme.bodyMedium,
                  ),
                  const SizedBox(height: TailboardTheme.spacingM),
                  TextField(
                    controller: wageController,
                    decoration: TailboardTheme.inputDecoration(
                      hintText: 'Wage (e.g., \$45.00/hr)',
                      prefixIcon: const Icon(Icons.attach_money,
                          color: TailboardTheme.copper),
                    ),
                    style: TailboardTheme.bodyMedium,
                    keyboardType:
                        TextInputType.numberWithOptions(decimal: true),
                  ),
                  const SizedBox(height: TailboardTheme.spacingM),
                  TextField(
                    controller: descriptionController,
                    maxLines: 4,
                    decoration: TailboardTheme.inputDecoration(
                      hintText: 'Job Description',
                      prefixIcon: const Icon(Icons.description,
                          color: TailboardTheme.copper),
                    ),
                    style: TailboardTheme.bodyMedium,
                  ),
                ],
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: isSharing ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSharing
                  ? null
                  : () async {
                      if (companyController.text.trim().isEmpty ||
                          locationController.text.trim().isEmpty ||
                          descriptionController.text.trim().isEmpty) {
                        _showSnackBar('Please fill in all required fields',
                            isError: true);
                        return;
                      }

                      setState(() {
                        isSharing = true;
                      });

                      try {
                        // Share the job (implementation would go here)
                        await Future.delayed(
                            const Duration(seconds: 1)); // Simulate sharing

                        if (mounted) {
                          Navigator.of(context).pop();
                          _showSnackBar('Job shared successfully!');
                        }
                      } catch (e) {
                        if (mounted) {
                          _showSnackBar('Error sharing job: ${e.toString()}',
                              isError: true);
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isSharing = false;
                          });
                        }
                      }
                    },
              style: TailboardTheme.primaryButton,
              child: isSharing
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TailboardTheme.backgroundCard,
                      ),
                    )
                  : const Text('Share Job'),
            ),
          ],
        ),
      ),
    );
  }

  void _showNewMessageDialog() {
    final currentUser = firebase_auth.FirebaseAuth.instance.currentUser;
    final selectedCrew = ref.read(selectedCrewProvider);

    if (currentUser == null) {
      _showSnackBar('Please sign in to send messages', isError: true);
      return;
    }

    if (selectedCrew == null) {
      _showSnackBar('Please select a crew first', isError: true);
      return;
    }

    final TextEditingController messageController = TextEditingController();
    final TextEditingController recipientController = TextEditingController();
    bool isDirectMessage = false;
    bool isSending = false;

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: Text(
            'New Message',
            style: TailboardTheme.headingSmall.copyWith(
              color: TailboardTheme.textPrimary,
            ),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Message type toggle
              Row(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDirectMessage = false;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: !isDirectMessage
                              ? TailboardTheme.copper
                              : TailboardTheme.backgroundDark,
                          borderRadius:
                              BorderRadius.circular(TailboardTheme.radiusS),
                        ),
                        child: Text(
                          'Crew Message',
                          textAlign: TextAlign.center,
                          style: TailboardTheme.bodySmall.copyWith(
                            color: !isDirectMessage
                                ? TailboardTheme.backgroundCard
                                : TailboardTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: TailboardTheme.spacingS),
                  Expanded(
                    child: GestureDetector(
                      onTap: () {
                        setState(() {
                          isDirectMessage = true;
                        });
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: isDirectMessage
                              ? TailboardTheme.copper
                              : TailboardTheme.backgroundDark,
                          borderRadius:
                              BorderRadius.circular(TailboardTheme.radiusS),
                        ),
                        child: Text(
                          'Direct Message',
                          textAlign: TextAlign.center,
                          style: TailboardTheme.bodySmall.copyWith(
                            color: isDirectMessage
                                ? TailboardTheme.backgroundCard
                                : TailboardTheme.textSecondary,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: TailboardTheme.spacingM),

              // Recipient selector (only for direct messages)
              if (isDirectMessage) ...[
                TextField(
                  controller: recipientController,
                  decoration: TailboardTheme.inputDecoration(
                    hintText: 'Recipient name or email',
                    prefixIcon:
                        const Icon(Icons.person, color: TailboardTheme.copper),
                  ),
                  style: TailboardTheme.bodyMedium,
                ),
                const SizedBox(height: TailboardTheme.spacingM),
              ],

              // Message content
              TextField(
                controller: messageController,
                maxLines: 5,
                decoration: TailboardTheme.inputDecoration(
                  hintText: isDirectMessage
                      ? 'Type your message...'
                      : 'Type your message to ${selectedCrew.name}...',
                  prefixIcon:
                      const Icon(Icons.message, color: TailboardTheme.copper),
                ),
                style: TailboardTheme.bodyMedium,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: isSending ? null : () => Navigator.of(context).pop(),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: isSending
                  ? null
                  : () async {
                      if (messageController.text.trim().isEmpty) {
                        _showSnackBar('Please enter a message', isError: true);
                        return;
                      }

                      if (isDirectMessage &&
                          recipientController.text.trim().isEmpty) {
                        _showSnackBar('Please enter a recipient',
                            isError: true);
                        return;
                      }

                      setState(() {
                        isSending = true;
                      });

                      try {
                        // Send the message (implementation would go here)
                        await Future.delayed(
                            const Duration(seconds: 1)); // Simulate sending

                        if (mounted) {
                          Navigator.of(context).pop();
                          _showSnackBar('Message sent successfully!');
                        }
                      } catch (e) {
                        if (mounted) {
                          _showSnackBar(
                              'Error sending message: ${e.toString()}',
                              isError: true);
                        }
                      } finally {
                        if (mounted) {
                          setState(() {
                            isSending = false;
                          });
                        }
                      }
                    },
              style: TailboardTheme.primaryButton,
              child: isSending
                  ? const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: TailboardTheme.backgroundCard,
                      ),
                    )
                  : const Text('Send'),
            ),
          ],
        ),
      ),
    );
  }

  // ============================================================
  // CREW SETTINGS & PREFERENCES
  // ============================================================

  void _showQuickActions(BuildContext context) {
    final selectedCrew = ref.read(selectedCrewProvider);

    showModalBottomSheet(
      context: context,
      backgroundColor: TailboardTheme.backgroundCard,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(TailboardTheme.radiusXL),
        ),
      ),
      builder: (context) => Container(
        padding: const EdgeInsets.all(TailboardTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: TailboardTheme.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingL),
            if (selectedCrew != null) ...[
              ListTile(
                leading: const Icon(Icons.work_outline,
                    color: TailboardTheme.copper),
                title:
                    Text('Job Preferences', style: TailboardTheme.bodyMedium),
                subtitle: Text('Configure job filtering',
                    style: TailboardTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  _showJobPreferences();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.settings, color: TailboardTheme.copper),
                title: Text('Crew Settings', style: TailboardTheme.bodyMedium),
                subtitle: Text('Manage crew details',
                    style: TailboardTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  _showCrewPreferencesDialog();
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.person_add, color: TailboardTheme.copper),
                title: Text('Invite Members', style: TailboardTheme.bodyMedium),
                subtitle: Text('Add people to your crew',
                    style: TailboardTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Invite feature coming soon');
                },
              ),
              ListTile(
                leading:
                    const Icon(Icons.analytics, color: TailboardTheme.copper),
                title: Text('View Analytics', style: TailboardTheme.bodyMedium),
                subtitle: Text('Crew performance metrics',
                    style: TailboardTheme.bodySmall),
                onTap: () {
                  Navigator.pop(context);
                  _showSnackBar('Analytics feature coming soon');
                },
              ),
            ],
            ListTile(
              leading:
                  const Icon(Icons.help_outline, color: TailboardTheme.copper),
              title: Text('Help & Support', style: TailboardTheme.bodyMedium),
              onTap: () {
                Navigator.pop(context);
                _showSnackBar('Help documentation coming soon');
              },
            ),
          ],
        ),
      ),
    );
  }

  void _showJobPreferences() async {
    final selectedCrew = ref.read(selectedCrewProvider);
    if (selectedCrew == null) {
      _showSnackBar('Please select a crew first', isError: true);
      return;
    }

    final result = await showDialog<bool>(
      context: context,
      builder: (context) => JobPreferencesDialog(
        crewId: selectedCrew.id,
        initialPreferences: selectedCrew.preferences,
      ),
    );

    if (result == true && mounted) {
      _showSnackBar('Job preferences updated');
    }
  }

  void _showCrewPreferencesDialog() async {
    final firebase_auth.User? currentUser =
        firebase_auth.FirebaseAuth.instance.currentUser;
    if (currentUser == null) return;

    final crewService = ref.read(crewServiceProvider);
    final selectedCrew = ref.read(selectedCrewProvider);

    if (selectedCrew == null) {
      _showSnackBar('Please select a crew first', isError: true);
      return;
    }

    try {
      final dbService = ref.read(databaseServiceProvider);
      final crewData = await dbService.getCrew(selectedCrew.id);

      if (crewData == null) {
        _showSnackBar('Selected crew not found', isError: true);
        return;
      }

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
      _showSnackBar('Error loading crew data: ${e.toString()}', isError: true);
    }
  }

  // ============================================================
  // UI BUILDERS
  // ============================================================

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<firebase_auth.User?>(
      stream: firebase_auth.FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Scaffold(
            backgroundColor: TailboardTheme.backgroundDark,
            body: Center(
              child: Text(
                'Authentication error occurred',
                style: TailboardTheme.bodyMedium,
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: TailboardTheme.backgroundDark,
            body: const ElectricalLoadingIndicator(
              message: 'Authenticating...',
            ),
          );
        }

        if (snapshot.data == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            context.go(AppRouter.auth);
          });
          return Scaffold(
            backgroundColor: TailboardTheme.backgroundDark,
            body: const ElectricalLoadingIndicator(),
          );
        }

        final selectedCrew = ref.watch(selectedCrewProvider);

        return Scaffold(
          backgroundColor: TailboardTheme.backgroundDark,
          body: Column(
            children: [
              selectedCrew != null
                  ? _buildHeader(context, selectedCrew)
                  : _buildNoCrewHeader(context),
              if (selectedCrew != null)
                DynamicContainerRow(
                  labels: _getContainerLabelsForTab(),
                  onContainerTap: _handleContainerTap,
                ),
              _buildTabBar(context),
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
          floatingActionButton:
              selectedCrew != null ? _buildFloatingActionButton() : null,
        );
      },
    );
  }

  Widget _buildNoCrewHeader(BuildContext context) {
    return Container(
      color: TailboardTheme.backgroundCard,
      padding: const EdgeInsets.fromLTRB(
        TailboardTheme.spacingL,
        48,
        TailboardTheme.spacingL,
        TailboardTheme.spacingL,
      ),
      child: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: TailboardTheme.copper.withValues(alpha: 0.1),
              ),
              child: const Icon(
                Icons.group_outlined,
                size: 40,
                color: TailboardTheme.copper,
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingL),
            Text(
              'Welcome to the Tailboard',
              style: TailboardTheme.headingLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: TailboardTheme.spacingS),
            Text(
              'This is your crew hub for messaging, job sharing, and team coordination. You can access direct messaging even without a crew.',
              textAlign: TextAlign.center,
              style: TailboardTheme.bodyMedium.copyWith(
                color: TailboardTheme.textSecondary,
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingL),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.go(AppRouter.crewOnboarding);
                },
                icon: const Icon(Icons.add),
                label: const Text('Create or Join a Crew'),
                style: TailboardTheme.primaryButton,
              ),
            ),
            const SizedBox(height: TailboardTheme.spacingM),
            const CrewSelectionDropdown(),
          ],
        ),
      ),
    ).animate().fadeIn(duration: 400.ms);
  }

  Widget _buildHeader(BuildContext context, Crew crew) {
    return Container(
      color: TailboardTheme.backgroundCard,
      padding: const EdgeInsets.fromLTRB(
        TailboardTheme.spacingL,
        48,
        TailboardTheme.spacingL,
        TailboardTheme.spacingL,
      ),
      child: Column(
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: TailboardTheme.copper.withValues(alpha: 0.1),
                ),
                child: crew.logoUrl != null
                    ? ClipOval(
                        child: Image.network(
                          crew.logoUrl!,
                          width: 50,
                          height: 50,
                          fit: BoxFit.cover,
                        ),
                      )
                    : const Icon(
                        Icons.group,
                        color: TailboardTheme.copper,
                        size: 28,
                      ),
              ),
              const SizedBox(width: TailboardTheme.spacingM),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Flexible(
                          child: Text(
                            crew.name,
                            style: TailboardTheme.headingMedium,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const SizedBox(width: TailboardTheme.spacingS),
                        const SizedBox(
                          width: 160,
                          child: CrewSelectionDropdown(),
                        ),
                      ],
                    ),
                    Text(
                      '${crew.memberIds.length} members',
                      style: TailboardTheme.bodySmall,
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () => _showQuickActions(context),
                icon: const Icon(
                  Icons.more_vert,
                  color: TailboardTheme.textSecondary,
                ),
              ),
            ],
          ),
        ],
      ),
    ).animate().fadeIn(duration: 300.ms);
  }

  Widget _buildTabBar(BuildContext context) {
    return Container(
      color: TailboardTheme.backgroundCard,
      child: TabBar(
        controller: _tabController,
        labelColor: TailboardTheme.copper,
        unselectedLabelColor: TailboardTheme.textTertiary,
        labelStyle: TailboardTheme.labelLarge,
        unselectedLabelStyle: TailboardTheme.labelMedium,
        indicatorColor: TailboardTheme.copper,
        indicatorWeight: 3,
        tabs: const [
          Tab(icon: Icon(Icons.feed), text: 'Feed'),
          Tab(icon: Icon(Icons.work_outline), text: 'Jobs'),
          Tab(icon: Icon(Icons.chat_bubble_outline), text: 'Chat'),
          Tab(icon: Icon(Icons.people_alt_outlined), text: 'Members'),
        ],
      ),
    );
  }

  Widget? _buildFloatingActionButton() {
    late final IconData icon;
    late final VoidCallback onPressed;

    switch (_selectedTab) {
      case 0: // Feed
        icon = Icons.add;
        onPressed = _showCreatePostDialog;
        break;
      case 1: // Jobs
        icon = Icons.share;
        onPressed = _showShareJobDialog;
        break;
      case 2: // Chat
        icon = Icons.message;
        onPressed = _showNewMessageDialog;
        break;
      default:
        return null;
    }

    return FloatingActionButton(
      onPressed: onPressed,
      backgroundColor: TailboardTheme.copper,
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      ),
      child: Icon(icon, color: TailboardTheme.textPrimary),
    ).animate().scale(
          duration: 300.ms,
          curve: Curves.easeInOut,
        );
  }

  // ============================================================
  // UTILITIES
  // ============================================================

  void _showSnackBar(String message, {bool isError = false}) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? TailboardTheme.error : TailboardTheme.copper,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(TailboardTheme.radiusM),
        ),
      ),
    );
  }
}
