import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/tailboard_components.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog for viewing feed history and archived posts
///
/// Shows a bottom sheet with option to toggle archived posts visibility.
/// Updates the FeedFilterProvider to show/hide archived content.
class FeedHistoryDialog extends ConsumerWidget {
  const FeedHistoryDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Feed History',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'View archived posts and past crew activity',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          TailboardComponents.actionButton(
            context,
            text: 'View History',
            onPressed: () {
              Navigator.pop(context);
              // Toggle archived posts filter using the feed filter provider
              ref.read(feedFilterProvider.notifier).toggleArchived();

              final showingArchived = ref.read(feedFilterProvider).showArchived;

              JJElectricalNotifications.showElectricalToast(
                context: context,
                message: showingArchived
                    ? 'Showing archived posts'
                    : 'Hiding archived posts',
                type: ElectricalNotificationType.info,
              );
            },
            isPrimary: true,
          ),
        ],
      ),
    );
  }
}