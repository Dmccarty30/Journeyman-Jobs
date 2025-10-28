import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_toast.dart';
import '../../models/crew_member.dart';
import '../../providers/crews_riverpod_provider.dart';
import '../../domain/enums/permission.dart';

/// Dialog for managing crew member permissions and roles.
/// 
/// Provides granular control over what crew members can do within the crew,
/// including role-based permissions and individual permission overrides.
class PermissionManagementDialog extends ConsumerStatefulWidget {
  final String crewId;

  const PermissionManagementDialog({
    Key? key,
    required this.crewId,
  }) : super(key: key);

  @override
  ConsumerState<PermissionManagementDialog> createState() => _PermissionManagementDialogState();
}

class _PermissionManagementDialogState extends ConsumerState<PermissionManagementDialog>
    with TickerProviderStateMixin {
  late TabController _tabController;
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  List<CrewMember> _members = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _setupAnimations();
    _loadMembers();
  }

  void _setupAnimations() {
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _tabController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  Future<void> _loadMembers() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final crewService = ref.read(crewServiceProvider);
      final members = await crewService.getCrewMembers(widget.crewId);

      if (mounted) {
        setState(() {
          _members = members;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
        JJElectricalToast.showError(
          context: context,
          message: 'Failed to load members: $e',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _fadeAnimation,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: Dialog(
            backgroundColor: Colors.transparent,
            child: Container(
              width: MediaQuery.of(context).size.width * 0.9,
              height: MediaQuery.of(context).size.height * 0.8,
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: AppTheme.accentCopper.withOpacity(0.3),
                ),
              ),
              child: Column(
                children: [
                  _buildHeader(),
                  _buildTabBar(),
                  Expanded(
                    child: _buildTabContent(),
                  ),
                  _buildActions(),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppTheme.primaryNavy,
            AppTheme.secondaryNavy,
          ],
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
        ),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.security,
            color: AppTheme.accentCopper,
            size: 24,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'Permission Management',
              style: AppTheme.headingLarge.copyWith(
                color: Colors.white,
                fontSize: 20,
              ),
            ),
          ),
          IconButton(
            onPressed: () => Navigator.of(context).pop(),
            icon: Icon(
              Icons.close,
              color: AppTheme.accentCopper,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTabBar() {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: TabBar(
        controller: _tabController,
        indicatorColor: AppTheme.accentCopper,
        labelColor: AppTheme.accentCopper,
        unselectedLabelColor: Colors.white.withOpacity(0.7),
        tabs: const [
          Tab(text: 'Roles', icon: Icon(Icons.people)),
          Tab(text: 'Permissions', icon: Icon(Icons.lock)),
        ],
      ),
    );
  }

  Widget _buildTabContent() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    return TabBarView(
      controller: _tabController,
      children: [
        _buildRolesTab(),
        _buildPermissionsTab(),
      ],
    );
  }

  Widget _buildRolesTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Crew Roles & Permissions',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.accentCopper,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Manage roles and their associated permissions for crew members.',
            style: AppTheme.bodyText.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.builder(
              itemCount: _members.length,
              itemBuilder: (context, index) {
                final member = _members[index];
                return RoleManagementCard(
                  member: member,
                  onRoleChanged: (newRole) {
                    _updateMemberRole(member.userId, newRole);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionsTab() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permission Overview',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.accentCopper,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Review and understand what each role can do within the crew.',
            style: AppTheme.bodyText.copyWith(
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: CrewRole.values.map((role) {
                  return PermissionOverviewCard(role: role);
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: Text(
              'Close',
              style: TextStyle(color: AppTheme.accentCopper),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _updateMemberRole(String userId, CrewRole newRole) async {
    try {
      final crewService = ref.read(crewServiceProvider);
      await crewService.updateMemberRole(
        crewId: widget.crewId,
        userId: userId,
        newRole: newRole,
      );

      // Refresh members list
      await _loadMembers();

      if (mounted) {
        JJElectricalToast.showSuccess(
          context: context,
          message: 'Role updated successfully!',
        );
      }
    } catch (e) {
      if (mounted) {
        JJElectricalToast.showError(
          context: context,
          message: 'Failed to update role: $e',
        );
      }
    }
  }
}

/// Card for managing individual member roles.
class RoleManagementCard extends ConsumerWidget {
  final CrewMember member;
  final Function(CrewRole) onRoleChanged;

  const RoleManagementCard({
    Key? key,
    required this.member,
    required this.onRoleChanged,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userAsync = ref.watch(userStreamProvider(member.userId));
    
    return userAsync.when(
      data: (user) => _buildContent(user),
      loading: () => _buildLoadingCard(),
      error: (error, stack) => _buildErrorCard(),
    );
  }

  Widget _buildContent(user) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.2),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: AppTheme.accentCopper,
                  child: Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.displayName,
                        style: AppTheme.bodyText.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (user.email != null)
                        Text(
                          user.email!,
                          style: AppTheme.caption.copyWith(
                            color: Colors.white.withOpacity(0.7),
                          ),
                        ),
                    ],
                  ),
                ),
                _buildRoleDropdown(),
              ],
            ),
            const SizedBox(height: 12),
            _buildPermissionSummary(),
          ],
        ),
      ),
    );
  }

  Widget _buildRoleDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withOpacity(0.2),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.5),
        ),
      ),
      child: DropdownButton<CrewRole>(
        value: member.role,
        onChanged: (CrewRole? newRole) {
          if (newRole != null) {
            onRoleChanged(newRole);
          }
        },
        items: CrewRole.values.map((role) {
          return DropdownMenuItem<CrewRole>(
            value: role,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  _getRoleIcon(role),
                  color: AppTheme.accentCopper,
                  size: 16,
                ),
                const SizedBox(width: 8),
                Text(
                  role.displayName,
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          );
        }).toList(),
        dropdownColor: AppTheme.primaryNavy,
        icon: Icon(
          Icons.arrow_drop_down,
          color: AppTheme.accentCopper,
        ),
        underline: const SizedBox(),
      ),
    );
  }

  Widget _buildPermissionSummary() {
    final permissions = member.role.permissions;
    
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Permissions',
            style: AppTheme.caption.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 6,
            runSpacing: 6,
            children: permissions.map((permission) {
              return Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 8,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  permission.displayName,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentCopper,
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingCard() {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      height: 120,
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
      height: 120,
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

  IconData _getRoleIcon(CrewRole role) {
    switch (role) {
      case CrewRole.owner:
        return Icons.admin_panel_settings;
      case CrewRole.foreman:
        return Icons.engineering;
      case CrewRole.journeyman:
        return Icons.build;
      case CrewRole.apprentice:
        return Icons.school;
      case CrewRole.operator:
        return Icons.construction;
      default:
        return Icons.person;
    }
  }
}

/// Card showing permission overview for each role.
class PermissionOverviewCard extends StatelessWidget {
  final CrewRole role;

  const PermissionOverviewCard({
    Key? key,
    required this.role,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.05),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.2),
        ),
      ),
      child: ExpansionTile(
        tilePadding: const EdgeInsets.all(16),
        leading: CircleAvatar(
          backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
          child: Icon(
            _getRoleIcon(role),
            color: AppTheme.accentCopper,
          ),
        ),
        title: Text(
          role.displayName,
          style: AppTheme.bodyText.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        subtitle: Text(
          _getRoleDescription(role),
          style: AppTheme.caption.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Permissions',
                  style: AppTheme.bodyText.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: role.permissions.map((permission) {
                    return Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(16),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            _getPermissionIcon(permission),
                            color: AppTheme.accentCopper,
                            size: 14,
                          ),
                          const SizedBox(width: 6),
                          Text(
                            permission.displayName,
                            style: AppTheme.caption.copyWith(
                              color: AppTheme.accentCopper,
                            ),
                          ),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String _getRoleDescription(CrewRole role) {
    switch (role) {
      case CrewRole.owner:
        return 'Full control over all crew aspects and settings';
      case CrewRole.foreman:
        return 'Can manage members, jobs, and daily operations';
      case CrewRole.journeyman:
        return 'Can view jobs and participate in crew activities';
      case CrewRole.apprentice:
        return 'Learning role with limited permissions';
      case CrewRole.operator:
        return 'Specialized role for equipment operations';
      default:
        return 'Standard crew member permissions';
    }
  }

  IconData _getRoleIcon(CrewRole role) {
    switch (role) {
      case CrewRole.owner:
        return Icons.admin_panel_settings;
      case CrewRole.foreman:
        return Icons.engineering;
      case CrewRole.journeyman:
        return Icons.build;
      case CrewRole.apprentice:
        return Icons.school;
      case CrewRole.operator:
        return Icons.construction;
      default:
        return Icons.person;
    }
  }

  IconData _getPermissionIcon(Permission permission) {
    switch (permission) {
      case Permission.manageMembers:
        return Icons.people;
      case Permission.manageJobs:
        return Icons.work;
      case Permission.manageSettings:
        return Icons.settings;
      case Permission.inviteMembers:
        return Icons.person_add;
      case Permission.shareJobs:
        return Icons.share;
      case Permission.viewAnalytics:
        return Icons.analytics;
      case Permission.sendMessages:
        return Icons.message;
      case Permission.removeMembers:
        return Icons.person_remove;
      default:
        return Icons.check_circle;
    }
  }
}
