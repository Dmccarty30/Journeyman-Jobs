import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import '../../../../design_system/tailboard_theme.dart';
import '../../../../design_system/tailboard_components.dart';
import '../../providers/crews_riverpod_provider.dart';
import '../../models/crew_member.dart';

class MemberRosterDialog extends ConsumerWidget {
  const MemberRosterDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return const SizedBox.shrink();
    }

    final membersAsync = ref.watch(crewMembersProvider(selectedCrew.id));

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
                  'Member Roster',
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
            child: membersAsync.isEmpty
                ? const EmptyStateWidget(
                    icon: Icons.people_outline,
                    title: 'No Members Yet',
                    message: 'Invite members to join your crew',
                  )
                : ListView.builder(
                    padding: const EdgeInsets.all(TailboardTheme.spacingM),
                    itemCount: membersAsync.length,
                    itemBuilder: (context, index) {
                      final member = membersAsync[index];
                      return _MemberRosterItem(member: member);
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _MemberRosterItem extends StatelessWidget {
  final CrewMember member;

  const _MemberRosterItem({required this.member});

  @override
  Widget build(BuildContext context) {
    final joinedDate = DateFormat.yMMMd().format(member.joinedAt);

    return Padding(
      padding: const EdgeInsets.only(bottom: TailboardTheme.spacingS),
      child: Container(
        padding: const EdgeInsets.all(TailboardTheme.spacingM),
        decoration: TailboardTheme.cardDecoration(),
        child: Row(
          children: [
            CircleAvatar(
              radius: 24,
              backgroundColor: TailboardTheme.copper.withValues(alpha: 0.2),
              child: Text(
                      (member.displayName ?? 'U')[0].toUpperCase(),
                      style: TailboardTheme.headingSmall.copyWith(
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
                  const SizedBox(height: 2),
                  Text(
                    'Joined $joinedDate',
                    style: TailboardTheme.bodySmall,
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
            Column(
              children: [
                Container(
                  width: 10,
                  height: 10,
                  decoration: BoxDecoration(
                    color: member.isActive
                        ? TailboardTheme.success
                        : TailboardTheme.textTertiary,
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  member.isActive ? 'Active' : 'Inactive',
                  style: TailboardTheme.labelSmall,
                ),
              ],
            ),
            const SizedBox(width: TailboardTheme.spacingS),
            IconButton(
              icon: const Icon(Icons.message, color: TailboardTheme.copper),
              onPressed: () {
                // TODO: Navigate to DM with this member
              },
            ),
          ],
        ),
      ),
    );
  }
}
