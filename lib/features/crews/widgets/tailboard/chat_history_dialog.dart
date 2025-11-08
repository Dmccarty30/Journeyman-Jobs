import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog showing chat history with archived channels
///
/// Shows a draggable scrollable sheet with:
/// - List of archived channels with restore/delete options
/// - Date formatting for archived timestamps
/// - Confirmation dialogs for destructive actions
/// - Empty state when no archived channels exist
/// - Complex Stream Chat operations for archive management
class ChatHistoryDialog extends ConsumerWidget {
  const ChatHistoryDialog({super.key, required this.onNavigateToChat});

  /// Callback to navigate to chat tab
  final VoidCallback onNavigateToChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return ElectricalDialogBackground(
        child: Center(
          child: Text(
            'Select a crew to view history',
            style: TextStyle(color: AppTheme.textOnDark),
          ),
        ),
      );
    }

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
                  Icon(Icons.history, color: AppTheme.accentCopper, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Chat History',
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

            // Archived Channels List with Stream Chat integration
            Expanded(
              child: ref.watch(streamChatClientProvider).when(
                data: (client) {
                  // Query archived channels for this crew
                  final archivedChannelsQuery = client.queryChannels(
                    filter: Filter.and([
                      Filter.equal('type', 'messaging'),
                      Filter.equal('team', selectedCrew.id),
                      Filter.equal('hidden', true), // Stream uses 'hidden' for archived channels
                    ]),
                    presence: true,
                  );

                  return StreamBuilder<List<Channel>>(
                    stream: archivedChannelsQuery,
                    builder: (context, snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return Center(
                          child: JJElectricalLoader(
                            width: 150,
                            height: 50,
                            message: 'Loading history...',
                          ),
                        );
                      }

                      if (snapshot.hasError) {
                        return Center(
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
                                  'Failed to load history',
                                  style: TextStyle(
                                    color: AppTheme.textOnDark,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  snapshot.error.toString(),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(color: AppTheme.mediumGray),
                                ),
                              ],
                            ),
                          ),
                        );
                      }

                      final archivedChannels = snapshot.data ?? [];

                      if (archivedChannels.isEmpty) {
                        return _buildEmptyHistoryState(context);
                      }

                      return ListView.builder(
                        controller: scrollController,
                        itemCount: archivedChannels.length,
                        itemBuilder: (context, index) {
                          final channel = archivedChannels[index];
                          return _buildArchivedChannelTile(
                            context,
                            ref,
                            channel,
                            client,
                            selectedCrew.id,
                          );
                        },
                      );
                    },
                  );
                },
                loading: () => Center(
                  child: JJElectricalLoader(
                    width: 150,
                    height: 50,
                    message: 'Loading history...',
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
                          'Failed to load history',
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

  /// Build custom electrical-themed archived channel tile
  Widget _buildArchivedChannelTile(
    BuildContext context,
    WidgetRef ref,
    Channel channel,
    StreamChatClient client,
    String crewId,
  ) {
    final channelName = channel.name ?? channel.id ?? 'Unknown';
    final lastMessage = channel.state?.messages.lastOrNull;
    final archivedDate = channel.createdAt ?? DateTime.now();
    final memberCount = channel.memberCount ?? 0;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ListTile(
        leading: Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            Icons.archive,
            color: AppTheme.accentCopper,
            size: 20,
          ),
        ),
        title: Row(
          children: [
            Expanded(
              child: Text(
                '# $channelName',
                style: TextStyle(
                  color: AppTheme.textOnDark,
                  fontWeight: FontWeight.w600,
                  fontSize: 16,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                'Archived',
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (lastMessage != null)
              Text(
                lastMessage.text ?? 'Message',
                style: TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 14,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            const SizedBox(height: 4),
            Row(
              children: [
                Icon(
                  Icons.access_time,
                  size: 12,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(width: 4),
                Text(
                  'Archived ${_formatArchiveDate(archivedDate)}',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 12,
                  ),
                ),
                const SizedBox(width: 12),
                Icon(
                  Icons.group,
                  size: 12,
                  color: AppTheme.mediumGray,
                ),
                const SizedBox(width: 4),
                Text(
                  '$memberCount members',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ],
        ),
        trailing: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            IconButton(
              icon: Icon(Icons.restore, color: AppTheme.successGreen),
              onPressed: () {
                Navigator.pop(context);
                _restoreChannel(context, ref, client, channel, crewId)
                    .then((_) => onNavigateToChat());
              },
              tooltip: 'Restore Channel',
            ),
            IconButton(
              icon: Icon(Icons.delete, color: AppTheme.errorRed),
              onPressed: () => _deleteChannel(context, client, channel),
              tooltip: 'Delete Channel',
            ),
          ],
        ),
      ),
    );
  }

  /// Build empty state when no archived channels exist
  Widget _buildEmptyHistoryState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Archived Chats',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Archived channels will appear here\nwhen you hide them from the main list',
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

  /// Format archive date in a user-friendly way
  String _formatArchiveDate(DateTime archivedDate) {
    final now = DateTime.now();
    final difference = now.difference(archivedDate);

    if (difference.inDays == 0) {
      return 'today';
    } else if (difference.inDays == 1) {
      return 'yesterday';
    } else if (difference.inDays < 7) {
      return '${difference.inDays} days ago';
    } else if (difference.inDays < 30) {
      return '${(difference.inDays / 7).floor()} weeks ago';
    } else {
      return '${(difference.inDays / 30).floor()} months ago';
    }
  }

  /// Restore an archived channel
  Future<void> _restoreChannel(
    BuildContext context,
    WidgetRef ref,
    StreamChatClient client,
    Channel channel,
    String crewId,
  ) async {
    try {
      // Show loading toast
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Restoring # ${channel.name ?? channel.id}...',
        type: ElectricalNotificationType.info,
      );

      // Unhide the channel (Stream Chat uses 'hidden' field for archiving)
      await channel.hide(clearHistory: false);

      // Optionally add it back to the team filter
      await channel.updatePartial(set: {
        'set': {
          'team': crewId,
        },
      });

      // Store active channel in provider
      ref.read(activeChannelProvider).set(channel);

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: '# ${channel.name ?? channel.id} restored',
        type: ElectricalNotificationType.success,
      );
    } catch (e) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Failed to restore channel',
        type: ElectricalNotificationType.error,
      );
    }
  }

  /// Delete a channel with confirmation
  Future<void> _deleteChannel(
    BuildContext context,
    StreamChatClient client,
    Channel channel,
  ) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.primaryNavy,
        title: Text(
          'Delete Channel?',
          style: TextStyle(color: AppTheme.textOnDark),
        ),
        content: Text(
          'Are you sure you want to permanently delete # ${channel.name ?? channel.id}? This action cannot be undone.',
          style: TextStyle(color: AppTheme.textOnDark),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: Text(
              'Cancel',
              style: TextStyle(color: AppTheme.mediumGray),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
            ),
            child: Text(
              'Delete',
              style: TextStyle(color: AppTheme.white),
            ),
          ),
        ],
      ),
    );

    if (confirmed == true) {
      try {
        // Show loading toast
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Deleting # ${channel.name ?? channel.id}...',
          type: ElectricalNotificationType.info,
        );

        // Delete the channel permanently
        await client.deleteChannel(channel.id!, {
          'hard_delete': true,
        } as String);

        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: '# ${channel.name ?? channel.id} deleted',
          type: ElectricalNotificationType.success,
        );
      } catch (e) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to delete channel',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }
}