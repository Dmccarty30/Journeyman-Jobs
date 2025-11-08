import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/providers/feed_provider.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';

/// Dialog for selecting feed sort options
///
/// Shows a bottom sheet with three sort options:
/// - Newest First
/// - Oldest First
/// - Most Liked
/// Updates the FeedFilterProvider with the selected option.
class FeedSortOptionsDialog extends ConsumerWidget {
  const FeedSortOptionsDialog({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Align(
        alignment: Alignment.bottomCenter,
        child: Container(
          margin: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: Text(
                  'Sort Feed',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const Divider(height: 1),
              ListTile(
                leading: Icon(Icons.access_time, color: AppTheme.accentCopper),
                title: Text('Newest First'),
                onTap: () {
                  Navigator.pop(context);
                  // Update sort option using the feed filter provider
                  ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.newestFirst);
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Sorted by newest first',
                    type: ElectricalNotificationType.success,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.history, color: AppTheme.accentCopper),
                title: Text('Oldest First'),
                onTap: () {
                  Navigator.pop(context);
                  // Update sort option using the feed filter provider
                  ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.oldestFirst);
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Sorted by oldest first',
                    type: ElectricalNotificationType.success,
                  );
                },
              ),
              ListTile(
                leading: Icon(Icons.favorite, color: AppTheme.accentCopper),
                title: Text('Most Liked'),
                onTap: () {
                  Navigator.pop(context);
                  // Update sort option using the feed filter provider
                  ref.read(feedFilterProvider.notifier).setSortOption(FeedSortOption.mostLiked);
                  JJElectricalNotifications.showElectricalToast(
                    context: context,
                    message: 'Sorted by most liked',
                    type: ElectricalNotificationType.success,
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}