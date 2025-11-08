import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog showing a list of crew members for direct messaging
///
/// Shows a draggable scrollable sheet with:
/// - List of crew members with online status
/// - Ability to create/open 1:1 DM channels
/// - Stream Chat integration with distinct channels
/// - Loading and error states
/// - Empty state when no members exist
class DirectMessagesDialog extends ConsumerWidget {
  const DirectMessagesDialog({super.key, required this.onNavigateToChat});

  /// Callback to navigate to chat tab
  final VoidCallback onNavigateToChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return ElectricalDialogBackground(
        child: Center(
          child: Text(
            'Select a crew to view members',
            style: TextStyle(color: AppTheme.textOnDark),
          ),
        ),
      );
    }

    final crewMembersAsync = ref.watch(crewMembersProvider(selectedCrew.id));

    return DraggableScrollableSheet(
      initialChildSize: 0.7,
      minChildSize: 0.5,
      maxChildSize: 0.95,
      builder: (context, scrollController) => ElectricalDialogBackground(
        child: Column(
          children: [
            // Header with close button
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(
                    Icons.people,
                    color: AppTheme.accentCopper,
                    size: 28,
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Direct Messages',
                      style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        color: AppTheme.textOnDark,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: Icon(Icons.close, color: AppTheme.mediumGray),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
            ),
            const Divider(color: AppTheme.mediumGray, height: 1),

            // Member List with Stream Chat integration
            Expanded(
              child: ref.watch(streamChatClientProvider).when(
                data: (client) {
                  if (crewMembersAsync.isEmpty) {
                    return _buildEmptyMembersState(context);
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: crewMembersAsync.length,
                    itemBuilder: (context, index) {
                      final member = crewMembersAsync[index];
                      return _buildElectricalMemberTile(
                        context,
                        ref,
                        member,
                        client,
                        selectedCrew.id,
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: JJElectricalLoader(
                    width: 150,
                    height: 50,
                    message: 'Loading members...',
                  ),
                ),
                error: (error, stack) => Center(
                  child: Padding(
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.error_outline,
                          size: 64,
                          color: AppTheme.errorRed,
                        ),
                        const SizedBox(height: 16),
                        Text(
                          'Failed to load members',
                          style: TextStyle(
                            color: AppTheme.textOnDark,
                            fontSize: 18,
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
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Build custom electrical-themed member tile for DM creation
  Widget _buildElectricalMemberTile(
    BuildContext context,
    WidgetRef ref,
    dynamic member,
    StreamChatClient client,
    String crewId,
  ) {
    // Extract member info
    final memberName = member.customTitle ?? member.role.toString().split('.').last;
    final isOnline = member.isAvailable ?? false;
    final memberId = member.id ?? '';

    // Get current user to avoid self-DM
    final currentUserId = client.state.currentUser?.id;
    final isSelf = currentUserId == memberId;

    return ListTile(
      leading: Stack(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Center(
              child: Text(
                memberName.isNotEmpty ? memberName[0].toUpperCase() : '?',
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          if (isOnline)
            Positioned(
              right: 0,
              bottom: 0,
              child: Container(
                width: 16,
                height: 16,
                decoration: BoxDecoration(
                  color: AppTheme.successGreen,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(
                    color: AppTheme.white,
                    width: 2,
                  ),
                ),
              ),
            ),
        ],
      ),
      title: Text(
        memberName,
        style: TextStyle(
          color: isSelf ? AppTheme.mediumGray : AppTheme.textOnDark,
          fontWeight: FontWeight.w600,
          fontSize: 16,
        ),
      ),
      subtitle: Text(
        isSelf ? 'You cannot DM yourself' : (isOnline ? 'Online' : 'Offline'),
        style: TextStyle(
          color: isOnline ? AppTheme.successGreen : AppTheme.mediumGray,
          fontSize: 14,
        ),
      ),
      trailing: isSelf
          ? Icon(Icons.block, color: AppTheme.mediumGray)
          : Icon(Icons.message, color: AppTheme.accentCopper),
      onTap: isSelf
          ? null
          : () {
              Navigator.pop(context);
              _createOrOpenDirectMessage(
                context,
                ref,
                client,
                memberId,
                memberName,
                crewId,
              ).then((_) => onNavigateToChat());
            },
      enabled: !isSelf,
    );
  }

  /// Build empty state when no members exist
  Widget _buildEmptyMembersState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.people_outline,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Crew Members',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Invite members to start\ndirect messaging',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Create or open a direct message channel with distinct flag
  Future<void> _createOrOpenDirectMessage(
    BuildContext context,
    WidgetRef ref,
    StreamChatClient client,
    String otherUserId,
    String otherUserName,
    String crewId,
  ) async {
    try {
      // Show loading toast
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Opening DM with $otherUserName...',
        type: ElectricalNotificationType.info,
      );

      // Create/get distinct DM channel with team filter
      final channel = client.channel(
        'messaging',
        extraData: {
          'team': crewId, // Team filter for crew isolation
          'members': [client.state.currentUser!.id, otherUserId],
        },
        id: null, // Let Stream generate ID
      );

      // Watch the channel with distinct flag to prevent duplicates
      await channel.watch();

      // Add members if channel was just created
      if (!channel.state!.members.any((m) => m.userId == otherUserId)) {
        await channel.addMembers([otherUserId]);
      }

      // Store active channel in provider
      ref.read(activeChannelProvider).set(channel);

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Chat with $otherUserName opened',
        type: ElectricalNotificationType.success,
      );
    } catch (e) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to open chat',
        type: ElectricalNotificationType.error,
      );
    }
  }
}