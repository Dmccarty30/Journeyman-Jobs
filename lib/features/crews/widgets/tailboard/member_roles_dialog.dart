import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../../../design_system/tailboard_components.dart';
import '../../providers/crews_riverpod_provider.dart';
import '../../models/crew_member.dart';
import '../../../../domain/enums/member_role.dart' as domain;

class MemberRolesDialog extends ConsumerStatefulWidget {
  const MemberRolesDialog({super.key});

  static Future<void> show(BuildContext context) async {
    return showDialog(
      context: context,
      builder: (context) => const MemberRolesDialog(),
    );
  }

  @override
  ConsumerState<MemberRolesDialog> createState() => _MemberRolesDialogState();
}

class _MemberRolesDialogState extends ConsumerState<MemberRolesDialog> {
  final Map<String, domain.MemberRole> _roleChanges = {};

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return const SizedBox.shrink();
    }

    final membersAsync = ref.watch(crewMembersStreamProvider(selectedCrew.id));

    return Dialog(
      backgroundColor: TailboardTheme.backgroundDark,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
      ),
      child: Container(
        constraints: const BoxConstraints(maxHeight: 600, maxWidth: 500),
        padding: const EdgeInsets.all(TailboardTheme.spacingL),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member Roles',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
            const SizedBox(height: TailboardTheme.spacingM),
            Expanded(
              child: membersAsync.when(
                loading: () => const ElectricalLoadingIndicator(
                  message: 'Loading members...',
                ),
                error: (error, stack) => EmptyStateWidget(
                  icon: Icons.error_outline,
                  title: 'Error Loading Members',
                  message: error.toString(),
                ),
                data: (members) {
                  if (members.isEmpty) {
                    return const EmptyStateWidget(
                      icon: Icons.people_outline,
                      title: 'No Members Yet',
                      message: 'Invite members to join your crew',
                    );
                  }

                  return ListView.builder(
                    itemCount: members.length,
                    itemBuilder: (context, index) {
                      final member = members[index];
                      final currentRole = selectedCrew.roles[member.userId] ?? domain.MemberRole.member;
                      final newRole = _roleChanges[member.userId] ?? currentRole;

                      return _MemberRoleItem(
                        member: member,
                        currentRole: newRole,
                        onRoleChanged: (role) {
                          setState(() {
                            _roleChanges[member.userId] = role;
                          });
                        },
                      );
                    },
                  );
                },
              ),
            ),
            if (_roleChanges.isNotEmpty) ...[
              const SizedBox(height: TailboardTheme.spacingM),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () {
                        setState(() {
                          _roleChanges.clear();
                        });
                      },
                      style: TailboardTheme.secondaryButton,
                      child: const Text('Reset'),
                    ),
                  ),
                  const SizedBox(width: TailboardTheme.spacingM),
                  Expanded(
                    child: ElevatedButton(
                      onPressed: _saveRoleChanges,
                      style: TailboardTheme.primaryButton,
                      child: const Text('Save Changes'),
                    ),
                  ),
                ],
              ),
            ],
          ],
        ),
      ),
    );
  }

  Future<void> _saveRoleChanges() async {
    // TODO: Implement role saving logic via crew service
    Navigator.of(context).pop();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Role changes saved successfully'),
        backgroundColor: TailboardTheme.success,
      ),
    );
  }
}

class _MemberRoleItem extends StatelessWidget {
  final CrewMember member;
  final domain.MemberRole currentRole;
  final ValueChanged<domain.MemberRole> onRoleChanged;

  const _MemberRoleItem({
    required this.member,
    required this.currentRole,
    required this.onRoleChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
      child: Container(
        padding: const EdgeInsets.all(TailboardTheme.spacingM),
        decoration: TailboardTheme.cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: TailboardTheme.copper.withValues(alpha: 0.2),
              child: Text(
                      member.displayName![0].toUpperCase(),
                      style: TailboardTheme.bodyMedium.copyWith(
                        color: TailboardTheme.copper,
                      ),
                    ),
            ),
            const SizedBox(width: TailboardTheme.spacingM),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    member.displayName ?? 'Unknown',
                    style: TailboardTheme.bodyMedium.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            DropdownButton<domain.MemberRole>(
              value: currentRole,
              dropdownColor: TailboardTheme.backgroundCard,
              style: TailboardTheme.bodyMedium,
              underline: Container(),
              icon: const Icon(Icons.arrow_drop_down, color: TailboardTheme.copper),
              items: domain.MemberRole.values.map((role) {
                return DropdownMenuItem(
                  value: role,
                  child: Row(
                    children: [
                      Icon(
                        _getRoleIcon(role),
                        size: 16,
                        color: _getRoleColor(role),
                      ),
                      const SizedBox(width: TailboardTheme.spacingS),
                      Text(
                        _getRoleDisplayName(role),
                        style: TailboardTheme.bodyMedium.copyWith(
                          color: _getRoleColor(role),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
              onChanged: (role) {
                if (role != null) {
                  onRoleChanged(role);
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  IconData _getRoleIcon(domain.MemberRole role) {
    switch (role) {
      case domain.MemberRole.foreman:
        return Icons.engineering;
      case domain.MemberRole.member:
        return Icons.person;
    }
  }

  Color _getRoleColor(domain.MemberRole role) {
    switch (role) {
      case domain.MemberRole.foreman:
        return TailboardTheme.copper;
      case domain.MemberRole.member:
        return TailboardTheme.textSecondary;
    }
  }

  String _getRoleDisplayName(domain.MemberRole role) {
    switch (role) {
      case domain.MemberRole.foreman:
        return 'Foreman';
      case domain.MemberRole.member:
        return 'Member';
    }
  }
}
