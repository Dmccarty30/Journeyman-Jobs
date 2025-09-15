import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/app_theme.dart';
import '../../../electrical_components/electrical_loader.dart';
import '../../../electrical_components/circuit_pattern_painter.dart';
import '../../../electrical_components/electrical_icons.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';
import '../providers/crew_provider.dart';
import '../providers/crew_member_provider.dart';
import '../widgets/crew_member_card.dart';

/// Comprehensive crew detail screen serving as the operational hub
/// for IBEW electrical worker crews.
///
/// Features real-time updates, role-based permissions, professional
/// IBEW protocol integration, and mobile-optimized interface for
/// field workers. Supports crew management, job coordination,
/// communication access, and emergency protocols.
class CrewDetailScreen extends ConsumerStatefulWidget {
  final String crewId;

  const CrewDetailScreen({
    super.key,
    required this.crewId,
  });

  @override
  ConsumerState<CrewDetailScreen> createState() => _CrewDetailScreenState();
}

class _CrewDetailScreenState extends ConsumerState<CrewDetailScreen>
    with TickerProviderStateMixin {
  late final TabController _tabController;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;

  // Current user - TODO: Get from auth provider
  static const String _currentUserId = 'current-user-id';

  // Tab indices
  static const int _overviewTabIndex = 0;
  static const int _membersTabIndex = 1;
  static const int _jobsTabIndex = 2;
  static const int _messagesTabIndex = 3;
  static const int _settingsTabIndex = 4;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    // Initialize crew data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCrewData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize crew data and set up real-time listeners
  void _initializeCrewData() {
    ref.read(crewProvider.notifier).selectCrew(widget.crewId);
    ref.read(crewMemberProvider.notifier).subscribeToCrewMembers(widget.crewId);
  }

  /// Handle back navigation and cleanup
  void _onBackPressed() {
    ref.read(crewProvider.notifier).clearSelectedCrew();
    context.pop();
  }

  /// Show crew options menu for admins
  void _showCrewOptionsMenu(Crew crew) {
    if (!crew.isAdmin(_currentUserId)) return;

    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCrewOptionsSheet(crew),
    );
  }

  /// Build crew options bottom sheet
  Widget _buildCrewOptionsSheet(Crew crew) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Title
          Text(
            'Crew Options',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),

          const SizedBox(height: 16),

          // Options
          _buildOptionTile(
            icon: Icons.edit,
            title: 'Edit Crew Details',
            onTap: () {
              Navigator.pop(context);
              context.push('/crews/${crew.id}/edit');
            },
          ),

          _buildOptionTile(
            icon: Icons.person_add,
            title: 'Invite Members',
            onTap: () {
              Navigator.pop(context);
              _showInviteMemberDialog();
            },
          ),

          _buildOptionTile(
            icon: Icons.share,
            title: 'Share Crew',
            onTap: () {
              Navigator.pop(context);
              _shareCrewDetails(crew);
            },
          ),

          if (crew.createdBy == _currentUserId)
            _buildOptionTile(
              icon: Icons.delete,
              title: 'Delete Crew',
              color: AppTheme.errorRed,
              onTap: () {
                Navigator.pop(context);
                _showDeleteCrewDialog(crew);
              },
            ),

          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build option tile for bottom sheet
  Widget _buildOptionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    final iconColor = color ?? AppTheme.accentCopper;

    return ListTile(
      leading: Icon(icon, color: iconColor),
      title: Text(
        title,
        style: TextStyle(color: color),
      ),
      onTap: onTap,
    );
  }

  /// Show invite member dialog
  void _showInviteMemberDialog() {
    final emailController = TextEditingController();
    final messageController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Invite Member'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: emailController,
              decoration: const InputDecoration(
                labelText: 'Email Address',
                hintText: 'Enter member email',
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextField(
              controller: messageController,
              decoration: const InputDecoration(
                labelText: 'Message (Optional)',
                hintText: 'Add a personal message',
              ),
              maxLines: 3,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              if (emailController.text.isNotEmpty) {
                _inviteMember(
                  emailController.text,
                  messageController.text.isEmpty ? null : messageController.text,
                );
                Navigator.pop(context);
              }
            },
            child: const Text('Send Invite'),
          ),
        ],
      ),
    );
  }

  /// Invite member to crew
  Future<void> _inviteMember(String email, String? message) async {
    try {
      await ref.read(crewMemberProvider.notifier).inviteMember(
        crewId: widget.crewId,
        invitationData: {
          'inviteMethod': 'email',
          'inviteValue': email,
          'message': message ?? '',
          'role': CrewRole.crewMember,
        },
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Invitation sent successfully'),
            backgroundColor: AppTheme.successGreen,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to send invitation: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  /// Share crew details
  void _shareCrewDetails(Crew crew) {
    // TODO: Implement crew sharing functionality
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Share functionality coming soon'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  /// Show delete crew confirmation dialog
  void _showDeleteCrewDialog(Crew crew) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Crew'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning,
              color: AppTheme.errorRed,
              size: 48,
            ),
            const SizedBox(height: 16),
            Text(
              'Are you sure you want to delete "${crew.name}"?',
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            const Text(
              'This action cannot be undone. All members will be removed.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 14,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              _deleteCrew(crew);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  /// Delete crew
  Future<void> _deleteCrew(Crew crew) async {
    final success = await ref.read(crewProvider.notifier).deleteCrew(
      crew.id,
      _currentUserId,
    );

    if (success && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Crew deleted successfully'),
          backgroundColor: AppTheme.successGreen,
        ),
      );
      _onBackPressed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final crewState = ref.watch(crewProvider);
    final memberState = ref.watch(crewMemberProvider);
    final crew = crewState.selectedCrew;
    final members = memberState.getCrewMembers(widget.crewId);

    if (crew == null) {
      return _buildLoadingScreen();
    }

    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: _buildAppBar(crew),
      body: Column(
        children: [
          // Crew info header
          _buildCrewInfoHeader(crew, members),

          // Tab bar
          _buildTabBar(),

          // Tab content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                _buildOverviewTab(crew, members),
                _buildMembersTab(crew, members),
                _buildJobsTab(crew),
                _buildMessagesTab(crew),
                _buildSettingsTab(crew),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build loading screen for crew data
  Widget _buildLoadingScreen() {
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        title: const Text('Loading...'),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: _onBackPressed,
        ),
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            JJElectricalLoader(
              size: 60,
              color: AppTheme.accentCopper,
            ),
            SizedBox(height: 16),
            Text(
              'Loading crew details...',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.mediumGray,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build app bar with crew actions
  PreferredSizeWidget _buildAppBar(Crew crew) {
    final isAdmin = crew.isAdmin(_currentUserId);

    return AppBar(
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: AppTheme.white,
      centerTitle: true,
      title: Text(
        crew.name,
        style: const TextStyle(
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
        overflow: TextOverflow.ellipsis,
      ),
      leading: IconButton(
        icon: const Icon(Icons.arrow_back),
        onPressed: _onBackPressed,
        tooltip: 'Back to crews',
      ),
      actions: [
        if (isAdmin)
          IconButton(
            icon: const Icon(Icons.more_vert),
            onPressed: () => _showCrewOptionsMenu(crew),
            tooltip: 'Crew options',
          ),
      ],
      elevation: 0,
    );
  }

  /// Build crew information header
  Widget _buildCrewInfoHeader(Crew crew, List<CrewMember> members) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(24),
          bottomRight: Radius.circular(24),
        ),
        boxShadow: [AppTheme.shadowMd],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Basic info row
          Row(
            children: [
              // Crew avatar/icon
              Container(
                width: 60,
                height: 60,
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: crew.imageUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(16),
                        child: Image.network(
                          crew.imageUrl!,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) {
                            return const Icon(
                              Icons.groups,
                              color: AppTheme.white,
                              size: 32,
                            );
                          },
                        ),
                      )
                    : const Icon(
                        Icons.groups,
                        color: AppTheme.white,
                        size: 32,
                      ),
              ),

              const SizedBox(width: 16),

              // Crew details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Classifications
                    if (crew.classifications.isNotEmpty) ...[
                      Wrap(
                        spacing: 6,
                        children: crew.classifications.take(2).map((classification) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 4,
                            ),
                            decoration: BoxDecoration(
                              color: AppTheme.accentCopper.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                color: AppTheme.accentCopper.withOpacity(0.3),
                              ),
                            ),
                            child: Text(
                              classification,
                              style: const TextStyle(
                                fontSize: 12,
                                fontWeight: FontWeight.w500,
                                color: AppTheme.white,
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),
                    ],

                    // Home local
                    if (crew.homeLocal != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.location_on,
                            color: AppTheme.accentCopper,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'IBEW Local ${crew.homeLocal}',
                            style: const TextStyle(
                              color: AppTheme.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 4),
                    ],

                    // Location
                    if (crew.location != null) ...[
                      Row(
                        children: [
                          const Icon(
                            Icons.place,
                            color: AppTheme.white,
                            size: 16,
                          ),
                          const SizedBox(width: 4),
                          Expanded(
                            child: Text(
                              crew.location!,
                              style: const TextStyle(
                                color: AppTheme.white,
                                fontSize: 13,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ],
                ),
              ),

              // Storm work indicator
              if (crew.availableForStormWork)
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppTheme.warningOrange.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: AppTheme.warningOrange.withOpacity(0.3),
                    ),
                  ),
                  child: const Column(
                    children: [
                      Icon(
                        Icons.flash_on,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                      Text(
                        'Storm',
                        style: TextStyle(
                          color: AppTheme.warningOrange,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),

          const SizedBox(height: 16),

          // Stats row
          Row(
            children: [
              _buildStatItem(
                'Members',
                '${members.length}/${crew.maxMembers}',
                Icons.people,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                'Jobs',
                crew.currentJobIds.length.toString(),
                Icons.work,
              ),
              const SizedBox(width: 20),
              _buildStatItem(
                'Rating',
                crew.averageRating > 0
                    ? crew.averageRating.toStringAsFixed(1)
                    : 'N/A',
                Icons.star,
              ),
            ],
          ),

          // Description
          if (crew.description?.isNotEmpty == true) ...[
            const SizedBox(height: 12),
            Text(
              crew.description!,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 14,
                height: 1.4,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      ),
    );
  }

  /// Build stat item for crew header
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Row(
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper,
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              label,
              style: const TextStyle(
                color: AppTheme.white,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Build tab bar
  Widget _buildTabBar() {
    return Container(
      color: AppTheme.white,
      child: TabBar(
        controller: _tabController,
        isScrollable: true,
        indicatorColor: AppTheme.accentCopper,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: AppTheme.mediumGray,
        labelStyle: const TextStyle(
          fontWeight: FontWeight.w600,
          fontSize: 14,
        ),
        unselectedLabelStyle: const TextStyle(
          fontWeight: FontWeight.w500,
          fontSize: 14,
        ),
        tabs: const [
          Tab(text: 'Overview'),
          Tab(text: 'Members'),
          Tab(text: 'Jobs'),
          Tab(text: 'Messages'),
          Tab(text: 'Settings'),
        ],
      ),
    );
  }

  /// Build overview tab content
  Widget _buildOverviewTab(Crew crew, List<CrewMember> members) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Recent activity section
          _buildSectionCard(
            title: 'Recent Activity',
            icon: Icons.timeline,
            child: Column(
              children: [
                _buildActivityItem(
                  'Crew created',
                  _formatDateTime(crew.createdAt),
                  Icons.group_add,
                ),
                if (crew.lastActivityAt != null)
                  _buildActivityItem(
                    'Last activity',
                    _formatDateTime(crew.lastActivityAt!),
                    Icons.access_time,
                  ),
                if (members.isNotEmpty)
                  _buildActivityItem(
                    'Latest member joined',
                    _formatDateTime(members
                        .map((m) => m.joinedAt)
                        .reduce((a, b) => a.isAfter(b) ? a : b)),
                    Icons.person_add,
                  ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Crew capabilities
          _buildSectionCard(
            title: 'Crew Capabilities',
            icon: Icons.engineering,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Classifications
                if (crew.classifications.isNotEmpty) ...[
                  const Text(
                    'IBEW Classifications',
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: crew.classifications.map((classification) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCopper.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AppTheme.accentCopper.withOpacity(0.3),
                          ),
                        ),
                        child: Text(
                          classification,
                          style: const TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: AppTheme.accentCopper,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 16),
                ],

                // Work preferences
                Row(
                  children: [
                    if (crew.availableForStormWork) ...[
                      const Icon(
                        Icons.flash_on,
                        color: AppTheme.warningOrange,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text('Storm Work'),
                      const SizedBox(width: 16),
                    ],
                    if (crew.availableForEmergencyWork) ...[
                      const Icon(
                        Icons.emergency,
                        color: AppTheme.errorRed,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      const Text('Emergency Work'),
                    ],
                  ],
                ),

                if (crew.travelRadius > 0) ...[
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      const Icon(
                        Icons.near_me,
                        color: AppTheme.infoBlue,
                        size: 20,
                      ),
                      const SizedBox(width: 4),
                      Text('${crew.travelRadius} mile radius'),
                    ],
                  ),
                ],
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Quick actions
          _buildSectionCard(
            title: 'Quick Actions',
            icon: Icons.bolt,
            child: Column(
              children: [
                _buildQuickActionTile(
                  icon: Icons.message,
                  title: 'Send Message',
                  subtitle: 'Communicate with crew',
                  onTap: () => _tabController.animateTo(_messagesTabIndex),
                ),
                _buildQuickActionTile(
                  icon: Icons.work,
                  title: 'Share Job',
                  subtitle: 'Share job opportunity',
                  onTap: () => _tabController.animateTo(_jobsTabIndex),
                ),
                if (crew.isAdmin(_currentUserId))
                  _buildQuickActionTile(
                    icon: Icons.person_add,
                    title: 'Invite Member',
                    subtitle: 'Add new crew member',
                    onTap: _showInviteMemberDialog,
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build members tab content
  Widget _buildMembersTab(Crew crew, List<CrewMember> members) {
    final isAdmin = crew.isAdmin(_currentUserId);

    return Column(
      children: [
        // Member list header
        Container(
          padding: const EdgeInsets.all(16),
          child: Row(
            children: [
              Text(
                'Members (${members.length}/${crew.maxMembers})',
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const Spacer(),
              if (isAdmin && members.length < crew.maxMembers)
                ElevatedButton.icon(
                  onPressed: _showInviteMemberDialog,
                  icon: const Icon(Icons.person_add, size: 18),
                  label: const Text('Invite'),
                  style: ElevatedButton.styleFrom(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    textStyle: const TextStyle(fontSize: 14),
                  ),
                ),
            ],
          ),
        ),

        // Member list
        Expanded(
          child: members.isEmpty
              ? _buildEmptyMembersState()
              : ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: members.length,
                  itemBuilder: (context, index) {
                    final member = members[index];
                    final isCurrentUser = member.userId == _currentUserId;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: CrewMemberCard(
                        member: member,
                        currentUserRole: crew.isAdmin(_currentUserId)
                            ? CrewRole.foreman
                            : CrewRole.crewMember,
                        showActions: isAdmin && !isCurrentUser,
                        onTap: () => _showMemberDetails(member),
                        onRoleChange: isAdmin ? (role) => _editMemberRole(member, role) : null,
                        onRemove: isAdmin ? () => _removeMember(member) : null,
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  /// Build jobs tab content
  Widget _buildJobsTab(Crew crew) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Active jobs section
          _buildSectionCard(
            title: 'Active Jobs',
            icon: Icons.work,
            child: crew.currentJobIds.isEmpty
                ? const Center(
                    child: Column(
                      children: [
                        Icon(
                          Icons.work_off,
                          size: 48,
                          color: AppTheme.mediumGray,
                        ),
                        SizedBox(height: 8),
                        Text(
                          'No active jobs',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 16,
                          ),
                        ),
                      ],
                    ),
                  )
                : Column(
                    children: crew.currentJobIds.map((jobId) {
                      // TODO: Create a simplified job display for now
                      // since JobNotificationCard requires more complex data
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: ListTile(
                          leading: const Icon(
                            Icons.work,
                            color: AppTheme.accentCopper,
                          ),
                          title: Text('Job: $jobId'),
                          subtitle: const Text('Active job'),
                          trailing: const Icon(Icons.chevron_right),
                          onTap: () {
                            // TODO: Navigate to job details
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text('Navigate to job: $jobId'),
                                backgroundColor: AppTheme.infoBlue,
                              ),
                            );
                          },
                        ),
                      );
                    }).toList(),
                  ),
          ),

          const SizedBox(height: 16),

          // Job sharing section
          _buildSectionCard(
            title: 'Job Sharing',
            icon: Icons.share,
            child: Column(
              children: [
                _buildQuickActionTile(
                  icon: Icons.add_circle_outline,
                  title: 'Share New Job',
                  subtitle: 'Share job opportunity with crew',
                  onTap: () {
                    // TODO: Navigate to job sharing screen
                  },
                ),
                _buildQuickActionTile(
                  icon: Icons.history,
                  title: 'Job History',
                  subtitle: 'View completed jobs',
                  onTap: () {
                    // TODO: Navigate to job history
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build messages tab content
  Widget _buildMessagesTab(Crew crew) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            Icons.chat_bubble_outline,
            size: 64,
            color: AppTheme.mediumGray,
          ),
          const SizedBox(height: 16),
          const Text(
            'Crew Communication',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Communication features coming soon',
            textAlign: TextAlign.center,
            style: TextStyle(
              color: AppTheme.mediumGray,
              fontSize: 16,
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () {
              // TODO: Navigate to communication screen
            },
            icon: const Icon(Icons.chat),
            label: const Text('Start Conversation'),
          ),
        ],
      ),
    );
  }

  /// Build settings tab content
  Widget _buildSettingsTab(Crew crew) {
    final isAdmin = crew.isAdmin(_currentUserId);

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // General settings
          _buildSectionCard(
            title: 'General Settings',
            icon: Icons.settings,
            child: Column(
              children: [
                if (isAdmin) ...[
                  _buildSettingsTile(
                    icon: Icons.edit,
                    title: 'Edit Crew Details',
                    subtitle: 'Name, description, classifications',
                    onTap: () => context.push('/crews/${crew.id}/edit'),
                  ),
                  _buildSettingsTile(
                    icon: Icons.public,
                    title: 'Privacy Settings',
                    subtitle: crew.isPublic ? 'Public crew' : 'Private crew',
                    onTap: () {
                      // TODO: Toggle crew privacy
                    },
                    trailing: Switch(
                      value: crew.isPublic,
                      onChanged: (value) {
                        // TODO: Update crew privacy
                      },
                      activeColor: AppTheme.accentCopper,
                    ),
                  ),
                ],
                _buildSettingsTile(
                  icon: Icons.notifications,
                  title: 'Notifications',
                  subtitle: 'Manage crew notifications',
                  onTap: () {
                    // TODO: Navigate to notification settings
                  },
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Member management
          if (isAdmin) ...[
            _buildSectionCard(
              title: 'Member Management',
              icon: Icons.group,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.person_add,
                    title: 'Invite Members',
                    subtitle: 'Send invitations to new members',
                    onTap: _showInviteMemberDialog,
                  ),
                  _buildSettingsTile(
                    icon: Icons.group_remove,
                    title: 'Manage Members',
                    subtitle: 'Edit roles and remove members',
                    onTap: () => _tabController.animateTo(_membersTabIndex),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 16),
          ],

          // Danger zone
          if (crew.createdBy == _currentUserId) ...[
            _buildSectionCard(
              title: 'Danger Zone',
              icon: Icons.warning,
              color: AppTheme.errorRed,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.delete_forever,
                    title: 'Delete Crew',
                    subtitle: 'Permanently delete this crew',
                    onTap: () => _showDeleteCrewDialog(crew),
                    textColor: AppTheme.errorRed,
                  ),
                ],
              ),
            ),
          ] else ...[
            _buildSectionCard(
              title: 'Membership',
              icon: Icons.exit_to_app,
              color: AppTheme.warningOrange,
              child: Column(
                children: [
                  _buildSettingsTile(
                    icon: Icons.exit_to_app,
                    title: 'Leave Crew',
                    subtitle: 'Remove yourself from this crew',
                    onTap: () => _showLeaveCrewDialog(crew),
                    textColor: AppTheme.warningOrange,
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build section card wrapper
  Widget _buildSectionCard({
    required String title,
    required IconData icon,
    required Widget child,
    Color? color,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  icon,
                  color: color ?? AppTheme.accentCopper,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  title,
                  style: AppTheme.titleLarge.copyWith(
                    color: color ?? AppTheme.primaryNavy,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }

  /// Build activity item for overview
  Widget _buildActivityItem(String title, String time, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          Icon(
            icon,
            color: AppTheme.accentCopper,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  time,
                  style: const TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build quick action tile
  Widget _buildQuickActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentCopper,
          size: 20,
        ),
      ),
      title: Text(title),
      subtitle: Text(subtitle),
      trailing: const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Build settings tile
  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    Widget? trailing,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(
        icon,
        color: textColor ?? AppTheme.accentCopper,
        size: 20,
      ),
      title: Text(
        title,
        style: TextStyle(color: textColor),
      ),
      subtitle: Text(subtitle),
      trailing: trailing ?? const Icon(Icons.chevron_right),
      onTap: onTap,
      contentPadding: EdgeInsets.zero,
    );
  }

  /// Build empty members state
  Widget _buildEmptyMembersState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.group_add,
                size: 48,
                color: AppTheme.accentCopper,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'No members yet',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Invite electrical workers to join your crew',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 14,
              ),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: _showInviteMemberDialog,
              icon: const Icon(Icons.person_add),
              label: const Text('Invite Members'),
            ),
          ],
        ),
      ),
    );
  }

  /// Show member details
  void _showMemberDetails(CrewMember member) {
    // TODO: Navigate to member detail screen or show modal
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Member details for ${member.displayName ?? 'Unknown'}'),
        backgroundColor: AppTheme.infoBlue,
      ),
    );
  }

  /// Edit member role
  void _editMemberRole(CrewMember member, [CrewRole? newRole]) {
    if (newRole != null) {
      // Update the role directly
      ref.read(crewMemberProvider.notifier).updateMemberRole(
        crewId: widget.crewId,
        memberId: member.userId,
        newRole: newRole,
      );
    } else {
      // Show role selection dialog
      _showRoleSelectionDialog(member);
    }
  }

  /// Show role selection dialog
  void _showRoleSelectionDialog(CrewMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Edit Role for ${member.displayName ?? 'Member'}'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CrewRole.values.map((role) {
            return RadioListTile<CrewRole>(
              title: Text(role.displayName),
              value: role,
              groupValue: member.role,
              onChanged: (value) {
                Navigator.pop(context);
                if (value != null && value != member.role) {
                  _editMemberRole(member, value);
                }
              },
              activeColor: AppTheme.accentCopper,
            );
          }).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Remove member from crew
  void _removeMember(CrewMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.displayName ?? 'this member'} from the crew?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(crewMemberProvider.notifier).removeMember(
                crewId: widget.crewId,
                memberId: member.userId,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Show leave crew dialog
  void _showLeaveCrewDialog(Crew crew) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Crew'),
        content: Text(
          'Are you sure you want to leave "${crew.name}"?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              ref.read(crewMemberProvider.notifier).removeMember(
                crewId: crew.id,
                memberId: _currentUserId,
              );
              _onBackPressed();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
            ),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }

  /// Format DateTime for display
  String _formatDateTime(DateTime dateTime) {
    final now = DateTime.now();
    final difference = now.difference(dateTime);

    if (difference.inDays > 7) {
      return '${dateTime.month}/${dateTime.day}/${dateTime.year}';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays == 1 ? '' : 's'} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours == 1 ? '' : 's'} ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes} minute${difference.inMinutes == 1 ? '' : 's'} ago';
    } else {
      return 'Just now';
    }
  }
}
