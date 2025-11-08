import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/features/crews/providers/stream_chat_providers.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog showing a list of crew channels with Stream Chat integration
///
/// Shows a draggable scrollable sheet with:
/// - List of channels with unread count badges
/// - Last message preview for each channel
/// - Loading and error states
/// - Empty state when no channels exist
class ChannelListDialog extends ConsumerWidget {
  const ChannelListDialog({super.key, required this.onNavigateToChat});

  /// Callback to navigate to chat tab
  final VoidCallback onNavigateToChat;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedCrew = ref.watch(selectedCrewProvider);

    if (selectedCrew == null) {
      return ElectricalDialogBackground(
        child: Center(
          child: Text(
            'Select a crew to view channels',
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
            // Header
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: [
                  Icon(Icons.tag, color: AppTheme.accentCopper, size: 28),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'Crew Channels',
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

            // Channel List
            Expanded(
              child: ref.watch(crewChannelsProvider(selectedCrew.id)).when(
                data: (channels) {
                  if (channels.isEmpty) {
                    return _buildEmptyChannelsState(context);
                  }

                  return ListView.builder(
                    controller: scrollController,
                    itemCount: channels.length,
                    itemBuilder: (context, index) {
                      final channel = channels[index];
                      return _buildElectricalChannelPreview(context, ref, channel);
                    },
                  );
                },
                loading: () => Center(
                  child: JJElectricalLoader(
                    width: 150,
                    height: 50,
                    message: 'Loading channels...',
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
                          'Failed to load channels',
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

  /// Build custom electrical-themed channel preview tile
  Widget _buildElectricalChannelPreview(BuildContext context, WidgetRef ref, Channel channel) {
    final channelName = channel.name ?? channel.id ?? 'Unknown';
    final lastMessage = channel.state?.messages.lastOrNull;
    final unreadCount = channel.state?.unreadCount ?? 0;

    return ListTile(
      leading: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(
          Icons.tag,
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
          if (unreadCount > 0)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                unreadCount.toString(),
                style: TextStyle(
                  color: AppTheme.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
        ],
      ),
      subtitle: lastMessage != null
          ? Text(
              lastMessage.text ?? 'Message',
              style: TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 14,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            )
          : Text(
              'No messages yet',
              style: TextStyle(
                color: AppTheme.mediumGray.withValues(alpha: 0.7),
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),
      onTap: () {
        Navigator.pop(context);
        _navigateToChannelMessages(context, ref, channel);
        onNavigateToChat();
      },
    );
  }

  /// Build empty state when no channels exist
  Widget _buildEmptyChannelsState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.flash_on,
              size: 80,
              color: AppTheme.accentCopper.withValues(alpha: 0.3),
            ),
            const SizedBox(height: 24),
            Text(
              'No Channels Yet',
              style: TextStyle(
                color: AppTheme.textOnDark,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Create your first crew channel\nto start collaborating',
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

  /// Navigate to channel messages screen
  void _navigateToChannelMessages(BuildContext context, WidgetRef ref, Channel channel) {
    // Store active channel in provider
    ref.read(activeChannelProvider).set(channel);

    // Navigate to chat tab to show messages
    // Note: We need to access the parent's TabController
    // This will need to be handled by passing a callback
    JJElectricalNotifications.showElectricalToast(
      context: context,
      message: 'Opening # ${channel.name ?? channel.id}',
      type: ElectricalNotificationType.success,
    );
  }
}
