import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';

/// Dialog showing member availability status
///
/// Shows a bottom sheet with:
/// - Available vs offline member counts
/// - List of available members
/// - Color-coded status indicators
/// - Empty state when no crew selected
class MemberAvailabilityDialog extends ConsumerWidget {
  const MemberAvailabilityDialog({super.key});

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
                'Member Availability',
                style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  color: AppTheme.textOnDark,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'Select a crew to view availability',
                style: TextStyle(color: AppTheme.mediumGray),
              ),
            ],
          ),
        ),
      );
    }

    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew.id));

    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Text(
            'Member Availability',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),

          // Availability cards
          Builder(
            builder: (context) {
              final availableMembers = crewMembersAsync.where((m) => m.isAvailable).toList();
              final unavailableMembers = crewMembersAsync.where((m) => !m.isAvailable).toList();

              return Column(
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

                  // Available members list
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
                    ...availableMembers.take(5).map((member) => ListTile(
                      dense: true,
                      leading: Icon(
                        Icons.circle,
                        color: AppTheme.successGreen,
                        size: 12,
                      ),
                      title: Text(
                        member.customTitle ?? member.role.toString().split('.').last,
                        style: TextStyle(color: AppTheme.textOnDark),
                      ),
                      subtitle: Text(
                        member.role.toString().split('.').last.toUpperCase(),
                        style: TextStyle(
                          color: AppTheme.mediumGray,
                          fontSize: 12,
                        ),
                      ),
                    )),
                    if (availableMembers.length > 5)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          '+${availableMembers.length - 5} more available',
                          style: TextStyle(
                            color: AppTheme.mediumGray,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                  ] else
                    Text(
                      'No members available',
                      style: TextStyle(
                        color: AppTheme.mediumGray,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }

  /// Build availability card with count and icon
  Widget _buildAvailabilityCard(
    String label,
    int count,
    Color color,
    IconData icon,
  ) {
    return Container(
      padding: const EdgeInsets.all(16),
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
}