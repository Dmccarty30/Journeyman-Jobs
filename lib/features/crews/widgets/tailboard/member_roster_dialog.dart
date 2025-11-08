import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';

/// Dialog showing crew member roster
///
/// Shows a bottom sheet with:
/// - Total member count
/// - First 3 crew members with preview
/// - Button to view all members
/// - Empty state when no crew selected or no members
class MemberRosterDialog extends ConsumerWidget {
  const MemberRosterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return ElectricalDialogBackground(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
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
              const SizedBox(height: 24),
              Text(
                'Select a crew to view roster',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.mediumGray,
                ),
              ),
            ],
          ),
        ),
      );
    }

    final crewMembersAsync = ref.watch(crewMembersStreamProvider(selectedCrew.id));

    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Crew Roster',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Member count card
          Container(
            padding: const EdgeInsets.all(16),
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
                crewMembersAsync.when(
                  data: (members) => Text(
                    '${members.length}',
                    style: TextStyle(
                      color: AppTheme.accentCopper,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  loading: () => CircularProgressIndicator(
                    color: AppTheme.accentCopper,
                    strokeWidth: 2,
                  ),
                  error: (_, _) => Text(
                    '0',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // Member list or empty state
          crewMembersAsync.when(
            data: (members) {
              if (members.isEmpty) {
                return Padding(
                  padding: const EdgeInsets.all(24.0),
                  child: Text(
                    'No members in crew',
                    style: TextStyle(color: AppTheme.mediumGray),
                  ),
                );
              }

              return Column(
                children: [
                  // First 3 members
                  ...members.take(3).map((member) => ListTile(
                    leading: CircleAvatar(
                      backgroundColor: AppTheme.accentCopper,
                      child: Text(
                        member.customTitle?.isNotEmpty == true
                            ? member.customTitle!.substring(0, 1).toUpperCase()
                            : 'M',
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

                  // View all button
                  if (members.length > 3)
                    Padding(
                      padding: const EdgeInsets.only(top: 8.0),
                      child: TextButton(
                        onPressed: () {
                          Navigator.pop(context);
                          // TODO: Navigate to full roster view
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Full roster view coming soon!'),
                              backgroundColor: AppTheme.accentCopper,
                            ),
                          );
                        },
                        child: Text(
                          'View All ${members.length} Members',
                          style: TextStyle(color: AppTheme.accentCopper),
                        ),
                      ),
                    ),
                ],
              );
            },
            loading: () => Center(
              child: Padding(
                padding: const EdgeInsets.all(32.0),
                child: Column(
                  children: [
                    CircularProgressIndicator(
                      color: AppTheme.accentCopper,
                      strokeWidth: 3,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      'Loading roster...',
                      style: TextStyle(color: AppTheme.mediumGray),
                    ),
                  ],
                ),
              ),
            ),
            error: (error, stack) => Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                children: [
                  Icon(
                    Icons.error_outline,
                    size: 48,
                    color: AppTheme.errorRed,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Failed to load roster',
                    style: TextStyle(
                      color: AppTheme.errorRed,
                      fontSize: 16,
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
        ],
      ),
    );
  }
}