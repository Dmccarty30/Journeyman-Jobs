import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/jj_electrical_toast.dart';
import '../../../electrical_components/circuit_board_background.dart';
import '../../../models/users_record.dart';
import '../models/crew.dart';
import '../models/crew_member.dart';
import '../providers/crews_riverpod_provider.dart';
import '../widgets/crew_member_avatar.dart';
import '../widgets/user_search_dialog.dart';
import '../widgets/crew_settings_dialog.dart';
import '../widgets/permission_management_dialog.dart';
import 'crew_chat_screen.dart';

/// Screen for comprehensive crew management including members, permissions, and settings.
/// 
/// This screen provides crew foremen and administrators with tools to:
/// - View and manage crew members
/// - Invite new members
/// - Manage member roles and permissions
/// - Configure crew settings
/// - Monitor crew activity and statistics
class CrewManagementScreen extends ConsumerStatefulWidget {
  final String crewId;

  const CrewManagementScreen({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  @override
  ConsumerState<CrewManagementScreen> createState() => _CrewManagementScreenState();
}

class _CrewManagementScreenState extends ConsumerState<CrewManagementScreen>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _fabAnimationController;
  late Animation<double> _fabAnimation;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _setupFabAnimation();
  }

  void _setupFabAnimation() {
    _fabAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fabAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _fabAnimationController,
      curve: Curves.easeInOut,
    ));

    _fabAnimationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _fabAnimationController.dispose();
    super.dispose();
  }

  /// Opens user search dialog to invite new members.
  Future<void> _inviteMember() async {
    final crewService = ref.read(crewServiceProvider);
    
    showDialog(
      context: context,
      builder: (context) => UserSearchDialog(
        crewId: widget.crewId,
        title: 'Invite to Crew',
        onUserSelected: (user) async {
          try {
            await crewService.inviteUserToCrew(
              crewId: widget.crewId,
              userId: user.uid,
              invitedBy: ref.read(authRiverpodProvider)!.uid,
            );
            
            if (mounted) {
              JJElectricalToast.showSuccess(
                context: context,
                message: 'Invitation sent to ${user.displayName}',
              );
            }
          } catch (e) {
            if (mounted) {
              JJElectricalToast.showError(
                context: context,
                message: 'Failed to send invitation: $e',
              );
            }
          }
        },
      ),
    );
  }

  /// Opens crew settings dialog.
  Future<void> _openCrewSettings() async {
    showDialog(
      context: context,
      builder: (context) => CrewSettingsDialog(
        crewId: widget.crewId,
      ),
    );
  }

  /// Opens permission management dialog.
  Future<void> _openPermissionManagement() async {
    showDialog(
      context: context,
      builder: (context) => PermissionManagementDialog(
        crewId: widget.crewId,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crewAsync = ref.watch(crewStreamProvider(widget.crewId));
    
    return Scaffold(
      backgroundColor: AppTheme.primaryNavy,
      body: ElectricalCircuitBackground(
        child: crewAsync.when(
          data: (crew) => _buildContent(crew),
          loading: () => _buildLoadingState(),
          error: (error, stack) => _buildErrorState(error),
        ),
      ),
      floatingActionButton: AnimatedBuilder(
        animation: _fabAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _fabAnimation.value,
            child: FloatingActionButton.extended(
              onPressed: _inviteMember,
              backgroundColor: AppTheme.accentCopper,
              icon: const Icon(Icons.person_add, color: Colors.white),
              label: const Text(
                'Invite Member',
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildContent(Crew crew) {
    return NestedScrollView(
      headerSliverBuilder: (context, innerBoxIsScrolled) {
        return [
          SliverAppBar(
            expandedHeight: 200,
            floating: false,
            pinned: true,
            backgroundColor: AppTheme.primaryNavy,
            flexibleSpace: FlexibleSpaceBar(
              title: Text(
                crew.name,
                style: AppTheme.headingLarge.copyWith(
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 4,
                      color: Colors.black.withOpacity(0.3),
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
              ),
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: [
                      AppTheme.primaryNavy,
                      AppTheme.secondaryNavy,
                    ],
                  ),
                ),
                child: Stack(
                  children: [
                    // Circuit pattern overlay
                    Positioned.fill(
                      child: Opacity(
                        opacity: 0.1,
                        child: CustomPaint(
                          painter: CircuitPatternPainter(),
                        ),
                      ),
                    ),
                    // Crew stats
                    Positioned(
                      bottom: 20,
                      left: 20,
                      right: 20,
                      child: Row(
                        children: [
                          _buildStatItem(
                            icon: Icons.people,
                            label: 'Members',
                            value: '${crew.memberCount ?? 0}',
                          ),
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.work,
                            label: 'Active Jobs',
                            value: '${crew.activeJobsCount ?? 0}',
                          ),
                          const SizedBox(width: 20),
                          _buildStatItem(
                            icon: Icons.trending_up,
                            label: 'Efficiency',
                            value: '${crew.efficiency ?? 0}%',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
            actions: [
              IconButton(
                onPressed: _openCrewSettings,
                icon: const Icon(Icons.settings, color: AppTheme.accentCopper),
                tooltip: 'Crew Settings',
              ),
              IconButton(
                onPressed: _openPermissionManagement,
                icon: const Icon(Icons.security, color: AppTheme.accentCopper),
                tooltip: 'Permissions',
              ),
            ],
            bottom: TabBar(
              controller: _tabController,
              indicatorColor: AppTheme.accentCopper,
              labelColor: AppTheme.accentCopper,
              unselectedLabelColor: Colors.white.withOpacity(0.7),
              tabs: const [
                Tab(text: 'Members', icon: Icon(Icons.people)),
                Tab(text: 'Invitations', icon: Icon(Icons.mail)),
                Tab(text: 'Activity', icon: Icon(Icons.activity)),
                Tab(text: 'Analytics', icon: Icon(Icons.analytics)),
              ],
            ),
          ),
        ];
      },
      body: TabBarView(
        controller: _tabController,
        children: [
          CrewMembersTab(crewId: widget.crewId),
          CrewInvitationsTab(crewId: widget.crewId),
          CrewActivityTab(crewId: widget.crewId),
          CrewAnalyticsTab(crewId: widget.crewId),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: AppTheme.accentCopper,
            size: 16,
          ),
          const SizedBox(width: 6),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                value,
                style: AppTheme.bodyText.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                label,
                style: AppTheme.caption.copyWith(
                  color: Colors.white.withOpacity(0.7),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              color: Colors.red.withOpacity(0.7),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading crew',
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error.toString(),
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Tab widget for displaying crew members.
class CrewMembersTab extends ConsumerWidget {
  final String crewId;

  const CrewMembersTab({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final membersAsync = ref.watch(crewMembersStreamProvider(crewId));
    
    return membersAsync.when(
      data: (members) => _buildMembersList(members),
      loading: () => _buildLoadingState(),
      error: (error, stack) => _buildErrorState(error),
    );
  }

  Widget _buildMembersList(List<CrewMember> members) {
    if (members.isEmpty) {
      return _buildEmptyState(
        icon: Icons.people_outline,
        title: 'No members yet',
        message: 'Invite members to build your crew.',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: members.length,
      itemBuilder: (context, index) {
        final member = members[index];
        return CrewMemberCard(
          member: member,
          onRoleChanged: (newRole) {
            // Handle role change
            ref.read(crewServiceProvider).updateMemberRole(
              crewId: crewId,
              userId: member.userId,
              newRole: newRole,
            );
          },
          onRemoved: () {
            // Handle member removal
            _showRemoveMemberDialog(context, member);
          },
        );
      },
    );
  }

  void _showRemoveMemberDialog(BuildContext context, CrewMember member) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text('Are you sure you want to remove ${member.displayName} from the crew?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Remove member logic here
            },
            child: Text(
              'Remove',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingState() {
    return const Center(
      child: CircularProgressIndicator(
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
      ),
    );
  }

  Widget _buildErrorState(Object error) {
    return Center(
      child: Text(
        'Error: $error',
        style: AppTheme.bodyText.copyWith(color: Colors.white),
      ),
    );
  }

  Widget _buildEmptyState({
    required IconData icon,
    required String title,
    required String message,
  }) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white.withOpacity(0.5),
              size: 64,
            ),
            const SizedBox(height: 16),
            Text(
              title,
              style: AppTheme.headingMedium.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              message,
              style: AppTheme.bodyText.copyWith(
                color: Colors.white.withOpacity(0.5),
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

/// Card widget for displaying crew member information.
class CrewMemberCard extends ConsumerWidget {
  final CrewMember member;
  final Function(String) onRoleChanged;
  final VoidCallback onRemoved;

  const CrewMemberCard({
    Key? key,
    required this.member,
    required this.onRoleChanged,
    required this.onRemoved,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(member.userId));
    
    return userAsync.when(
      data: (user) => _buildMemberCard(user),
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(),
    );
  }

  Widget _buildMemberCard(UsersRecord user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.2),
        ),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        leading: CrewMemberAvatar(
          user: user,
          role: member.role,
          size: 48,
        ),
        title: Text(
          user.displayName,
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (user.localNumber != null)
              Text(
                'IBEW Local ${user.localNumber}',
                style: AppTheme.caption.copyWith(
                  color: AppTheme.accentCopper,
                ),
              ),
            Text(
              'Role: ${member.role.displayName}',
              style: AppTheme.caption.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
            if (member.isOnline)
              Row(
                children: [
                  Icon(
                    Icons.circle,
                    color: Colors.green,
                    size: 8,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Online',
                    style: AppTheme.caption.copyWith(
                      color: Colors.green,
                    ),
                  ),
                ],
              ),
          ],
        ),
        trailing: PopupMenuButton<String>(
          icon: Icon(
            Icons.more_vert,
            color: AppTheme.accentCopper,
          ),
          itemBuilder: (context) => [
            PopupMenuItem(
              value: 'change_role',
              child: Row(
                children: [
                  Icon(Icons.swap_horiz, color: AppTheme.accentCopper),
                  const SizedBox(width: 8),
                  Text('Change Role'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'send_message',
              child: Row(
                children: [
                  Icon(Icons.message, color: AppTheme.accentCopper),
                  const SizedBox(width: 8),
                  Text('Send Message'),
                ],
              ),
            ),
            PopupMenuItem(
              value: 'remove',
              child: Row(
                children: [
                  Icon(Icons.remove_circle, color: Colors.red),
                  const SizedBox(width: 8),
                  Text('Remove from Crew'),
                ],
              ),
            ),
          ],
          onSelected: (value) {
            switch (value) {
              case 'change_role':
                _showRoleSelectionDialog(context);
                break;
              case 'send_message':
                // Navigate to chat with this member
                break;
              case 'remove':
                onRemoved();
                break;
            }
          },
        ),
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      ),
    );
  }

  Widget _buildErrorCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 80,
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.red.withOpacity(0.3)),
      ),
      child: const Center(
        child: Icon(
          Icons.error_outline,
          color: Colors.red,
        ),
      ),
    );
  }

  void _showRoleSelectionDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CrewRole.values
              .where((role) => role != CrewRole.owner)
              .map((role) => RadioListTile<CrewRole>(
                    title: Text(role.displayName),
                    value: role,
                    groupValue: member.role,
                    onChanged: (value) {
                      if (value != null) {
                        Navigator.of(context).pop();
                        onRoleChanged(value.name);
                      }
                    },
                  ))
              .toList(),
        ),
      ),
    );
  }
}

/// Placeholder widgets for other tabs
class CrewInvitationsTab extends ConsumerWidget {
  final String crewId;

  const CrewInvitationsTab({Key? key, required this.crewId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text(
        'Invitations Tab - To be implemented',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class CrewActivityTab extends ConsumerWidget {
  final String crewId;

  const CrewActivityTab({Key? key, required this.crewId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text(
        'Activity Tab - To be implemented',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

class CrewAnalyticsTab extends ConsumerWidget {
  final String crewId;

  const CrewAnalyticsTab({Key? key, required this.crewId}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return const Center(
      child: Text(
        'Analytics Tab - To be implemented',
        style: TextStyle(color: Colors.white),
      ),
    );
  }
}

/// Custom painter for circuit pattern background
class CircuitPatternPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = AppTheme.accentCopper.withOpacity(0.1)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    // Draw circuit-like pattern
    final path = Path();
    const double spacing = 20.0;
    
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        // Draw horizontal lines
        if (x % (spacing * 2) == 0) {
          path.moveTo(x, y);
          path.lineTo(x + spacing, y);
        }
        // Draw vertical lines
        if (y % (spacing * 2) == 0) {
          path.moveTo(x, y);
          path.lineTo(x, y + spacing);
        }
        // Draw connection dots
        canvas.drawCircle(Offset(x, y), 2, paint);
      }
    }
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
