import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart' as crew_providers;
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'electrical_dialog_background.dart';

/// A bottom sheet dialog showing crew members grouped by their roles
///
/// This dialog displays all members of the selected crew organized by their
/// assigned roles. Each role shows an icon, role name, and member count.
/// Tapping on a role can show detailed member information.
class MemberRolesDialog extends ConsumerWidget {
  /// Creates a member roles dialog
  const MemberRolesDialog({super.key});

  /// Shows the member roles dialog as a modal bottom sheet
  static void show(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => const MemberRolesDialog(),
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

  /// Build the role groups list from crew members
  Widget _buildRoleGroupsList(List<CrewMember> crewMembers) {
    // Group members by role
    final roleGroups = <String, List<CrewMember>>{};
    for (final member in crewMembers) {
      final roleKey = member.role.toString().split('.').last;
      roleGroups[roleKey] = [...(roleGroups[roleKey] ?? []), member];
    }

    if (roleGroups.isEmpty) {
      return Text(
        'No roles assigned',
        style: TextStyle(color: AppTheme.mediumGray),
      );
    }

    return Column(
      children: roleGroups.entries.map((entry) => ListTile(
        leading: Icon(
          _getRoleIcon(entry.key),
          color: AppTheme.accentCopper,
        ),
        title: Text(
          entry.key.toUpperCase(),
          style: TextStyle(
            color: AppTheme.textOnDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        trailing: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
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
          // TODO: Show members in this role
          // This could navigate to a detailed view of members in this role
        },
      )).toList(),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.read(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crew_providers.crewMembersProvider(selectedCrew?.id ?? ''));

    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Crew Roles',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Content based on crew selection state
          if (selectedCrew == null)
            Text(
              'Select a crew to view roles',
              style: TextStyle(color: AppTheme.mediumGray),
            )
          else
            _buildRoleGroupsList(crewMembersAsync),

          const SizedBox(height: 16),
        ],
      ),
    );
  }
}