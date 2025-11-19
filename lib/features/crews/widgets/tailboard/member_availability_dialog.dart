import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../../../design_system/tailboard_components.dart';
import '../../providers/crews_riverpod_provider.dart';
import '../../models/crew_member.dart';

class MemberAvailabilityDialog extends ConsumerWidget {
  const MemberAvailabilityDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return const SizedBox.shrink();
    }

    final membersAsync = ref.watch(crewMembersStreamProvider(selectedCrew.id));

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      decoration: BoxDecoration(
        color: TailboardTheme.backgroundCard,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(TailboardTheme.radiusXL),
        ),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(TailboardTheme.spacingL),
            decoration: BoxDecoration(
              border: Border(
                bottom: BorderSide(
                  color: TailboardTheme.divider,
                  width: 1,
                ),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'Member Availability',
                  style: TailboardTheme.headingMedium,
                ),
                IconButton(
                  icon: const Icon(Icons.close, color: TailboardTheme.textSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                ),
              ],
            ),
          ),
          Expanded(
            child: membersAsync.when(
              loading: () => const ElectricalLoadingIndicator(
                message: 'Loading availability...',
              ),
              error: (error, stack) => EmptyStateWidget(
                icon: Icons.error_outline,
                title: 'Error Loading Availability',
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

                final availableMembers = members.where((m) => m.isActive).toList();
                final unavailableMembers = members.where((m) => !m.isActive).toList();

                return ListView(
                  padding: const EdgeInsets.all(TailboardTheme.spacingM),
                  children: [
                    if (availableMembers.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Available (${availableMembers.length})',
                        color: TailboardTheme.success,
                      ),
                      ...availableMembers.map((member) => _AvailabilityItem(
                        member: member,
                        isAvailable: true,
                      )),
                      const SizedBox(height: TailboardTheme.spacingL),
                    ],
                    if (unavailableMembers.isNotEmpty) ...[
                      _SectionHeader(
                        title: 'Unavailable (${unavailableMembers.length})',
                        color: TailboardTheme.textTertiary,
                      ),
                      ...unavailableMembers.map((member) => _AvailabilityItem(
                        member: member,
                        isAvailable: false,
                      )),
                    ],
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final Color color;

  const _SectionHeader({
    required this.title,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TailboardTheme.spacingM),
      child: Row(
        children: [
          Container(
            width: 4,
            height: 20,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: TailboardTheme.spacingS),
          Text(
            title,
            style: TailboardTheme.headingSmall.copyWith(
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _AvailabilityItem extends StatelessWidget {
  final CrewMember member;
  final bool isAvailable;

  const _AvailabilityItem({
    required this.member,
    required this.isAvailable,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
      child: Container(
        padding: const EdgeInsets.all(TailboardTheme.spacingM),
        decoration: TailboardTheme.cardDecoration(
          color: isAvailable
              ? TailboardTheme.success.withValues(alpha: 0.05)
              : TailboardTheme.backgroundDark,
        ),
        child: Row(
          children: [
            Stack(
              children: [
                CircleAvatar(
                  radius: 20,
                  backgroundColor: TailboardTheme.copper.withValues(alpha: 0.2),
                  child: Text(
                          (member.displayName ?? 'U')[0].toUpperCase(),
                          style: TailboardTheme.bodyMedium.copyWith(
                            color: TailboardTheme.copper,
                          ),
                        ),
                ),
                Positioned(
                  right: 0,
                  bottom: 0,
                  child: Container(
                    width: 12,
                    height: 12,
                    decoration: BoxDecoration(
                      color: isAvailable
                          ? TailboardTheme.success
                          : TailboardTheme.textTertiary,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: TailboardTheme.backgroundCard,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
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
                  if (member.classification != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      member.classification!,
                      style: TailboardTheme.bodySmall,
                    ),
                  ],
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TailboardTheme.spacingM,
                vertical: TailboardTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: isAvailable
                    ? TailboardTheme.success.withValues(alpha: 0.1)
                    : TailboardTheme.backgroundLight,
                borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
                border: Border.all(
                  color: isAvailable
                      ? TailboardTheme.success
                      : TailboardTheme.border,
                ),
              ),
              child: Text(
                isAvailable ? 'Available' : 'Working',
                style: TailboardTheme.labelMedium.copyWith(
                  color: isAvailable
                      ? TailboardTheme.success
                      : TailboardTheme.textTertiary,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
