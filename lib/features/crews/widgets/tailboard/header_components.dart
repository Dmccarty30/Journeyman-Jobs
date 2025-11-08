// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

// Journeyman Jobs - Absolute imports
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/tailboard_components.dart';
import 'package:journeyman_jobs/design_system/tailboard_theme.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/crew_selection_dropdown.dart';
import 'package:journeyman_jobs/navigation/app_router.dart';

/// Header widget for when a crew is selected
class TailboardHeader extends ConsumerWidget {
  final Crew crew;
  final VoidCallback? onCrewTap;
  final VoidCallback? onSettingsTap;

  const TailboardHeader({
    super.key,
    required this.crew,
    this.onCrewTap,
    this.onSettingsTap,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
          child: Column(
            children: [
              // Main header content
              _buildCrewInfoSection(context, ref),
              const SizedBox(height: 16),
              // Header actions
              _buildHeaderActions(context),
            ],
          ),
        ),
      ),
    );
  }

  /// Build crew information section
  Widget _buildCrewInfoSection(BuildContext context, WidgetRef ref) {
    return Row(
      children: [
        // Crew avatar/icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppTheme.accentCopper,
                AppTheme.secondaryCopper,
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.accentCopper.withValues(alpha: 0.3),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: const Icon(
            Icons.electrical_services,
            color: AppTheme.white,
            size: 24,
          ),
        ),
        const SizedBox(width: 16),

        // Crew details
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                crew.name,
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.darkGray,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Row(
                children: [
                  Icon(
                    Icons.group_outlined,
                    size: 16,
                    color: AppTheme.mediumGray,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${crew.memberIds.length} members',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: AppTheme.accentCopper.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      'Active',
                      style: TextStyle(
                        color: AppTheme.accentCopper,
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Build header action buttons
  Widget _buildHeaderActions(BuildContext context) {
    return Row(
      children: [
        // Quick actions button
        Expanded(
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: AppTheme.primaryNavy.withValues(alpha: 0.2),
                width: 1,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(20),
                onTap: onCrewTap,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.dashboard_outlined,
                      size: 18,
                      color: AppTheme.primaryNavy,
                    ),
                    const SizedBox(width: 8),
                    Text(
                      'Quick Actions',
                      style: TextStyle(
                        color: AppTheme.primaryNavy,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),

        // Settings button
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.white,
            shape: BoxShape.circle,
            border: Border.all(
              color: AppTheme.borderCopper.withValues(alpha: 0.3),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              borderRadius: BorderRadius.circular(20),
              onTap: onSettingsTap,
              child: Icon(
                Icons.settings_outlined,
                size: 20,
                color: AppTheme.mediumGray,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

/// Header widget for when no crew is selected
class TailboardNoCrewHeader extends ConsumerWidget {
  const TailboardNoCrewHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
          // Welcome icon
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

          // Welcome text
          Text(
            'Welcome to the Tailboard',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 8),

          // Description
          Text(
            'This is your crew hub for messaging, job sharing, and team coordination. You can access direct messaging even without a crew.',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
              height: 1.4,
            ),
          ),
          const SizedBox(height: 24),

          // Create/join crew button
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(12),
              gradient: LinearGradient(
                colors: [
                  AppTheme.primaryNavy,
                  AppTheme.primaryNavy.withValues(alpha: 0.8),
                ],
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
              label: const Text(
                'Create or Join a Crew',
                style: TextStyle(color: AppTheme.white),
              ),
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

          // Crew selection dropdown
          Padding(
            padding: const EdgeInsetsDirectional.fromSTEB(30, 0, 30, 0),
            child: const CrewSelectionDropdown(isExpanded: true),
          ),
        ],
      ),
    );
  }
}

/// Custom tab bar with electrical theme
class TailboardTabBar extends StatelessWidget {
  final TabController controller;
  final List<String> tabs;
  final List<IconData> icons;
  final Function(int)? onTabTap;

  const TailboardTabBar({
    super.key,
    required this.controller,
    required this.tabs,
    required this.icons,
    this.onTabTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        child: TabBar(
          controller: controller,
          onTap: onTabTap,
          labelColor: AppTheme.accentCopper,
          unselectedLabelColor: AppTheme.mediumGray,
          indicatorColor: AppTheme.accentCopper,
          indicatorWeight: 3,
          indicatorSize: TabBarIndicatorSize.tab,
          labelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
          unselectedLabelStyle: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.normal,
          ),
          tabs: List.generate(tabs.length, (index) {
            return Tab(
              icon: Icon(icons[index], size: 20),
              text: tabs[index],
              iconMargin: const EdgeInsets.only(bottom: 4),
            );
          }),
        ),
      ),
    );
  }
}

/// Floating action button with electrical theme
class TailboardFloatingActionButton extends ConsumerWidget {
  final int selectedTab;
  final Map<int, IconData> tabIcons;
  final Map<int, VoidCallback> tabActions;

  const TailboardFloatingActionButton({
    super.key,
    required this.selectedTab,
    required this.tabIcons,
    required this.tabActions,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final icon = tabIcons[selectedTab];
    final onPressed = tabActions[selectedTab];

    if (icon == null || onPressed == null) {
      return const SizedBox.shrink();
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
    );
  }
}

/// Quick actions bottom sheet
class QuickActionsBottomSheet extends StatelessWidget {
  const QuickActionsBottomSheet({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AppTheme.mediumGray.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // Title
          Text(
            'Quick Actions',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.darkGray,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),

          // Action items
          _buildActionItem(
            context,
            icon: Icons.settings,
            title: 'Crew Settings',
            subtitle: 'Manage crew preferences and settings',
            onTap: () {
              Navigator.pop(context);
              // Handle crew settings
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.person_add,
            title: 'Invite Members',
            subtitle: 'Add new members to your crew',
            onTap: () {
              Navigator.pop(context);
              // Handle invite members
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.analytics,
            title: 'View Analytics',
            subtitle: 'See crew activity and statistics',
            onTap: () {
              Navigator.pop(context);
              // Handle analytics
            },
          ),
          _buildActionItem(
            context,
            icon: Icons.notifications_outlined,
            title: 'Notifications',
            subtitle: 'Manage notification preferences',
            onTap: () {
              Navigator.pop(context);
              // Handle notifications
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  /// Build individual action item
  Widget _buildActionItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return ListTile(
      leading: Container(
        width: 48,
        height: 48,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Icon(
          icon,
          color: AppTheme.accentCopper,
          size: 24,
        ),
      ),
      title: Text(
        title,
        style: TextStyle(
          color: AppTheme.darkGray,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        subtitle,
        style: TextStyle(
          color: AppTheme.mediumGray,
          fontSize: 14,
        ),
      ),
      trailing: Icon(
        Icons.chevron_right,
        color: AppTheme.mediumGray,
      ),
      onTap: onTap,
    );
  }
}