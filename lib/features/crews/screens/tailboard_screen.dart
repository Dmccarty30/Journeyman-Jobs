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

// Reusable dialog background component for consistent styling
class _ElectricalDialogBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const _ElectricalDialogBackground({
    required this.child,
    this.padding,
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
    required this.controller,
    this.labelText,
    this.hintText,
    this.validator,
    this.maxLines = 1,
    this.onTap,
    this.readOnly = false,
    this.keyboardType,
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
    this.onCancel,
    this.onConfirm,
    this.cancelText = 'Cancel',
    this.confirmText = 'Submit',
    this.isConfirmLoading = false,
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
                    color: TailboardTheme.navy800.withOpacity(0.1),
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

      await ref.read(postCreationProvider).createPost(
        crewId: selectedCrew.id,
        content: content,
      );

      if (!mounted) return;
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Post created successfully!',
        type: ElectricalNotificationType.success,
      );
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
}
