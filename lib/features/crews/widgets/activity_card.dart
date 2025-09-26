import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tailboard.dart';
import '../../../design_system/app_theme.dart';

class ActivityCard extends ConsumerWidget {
  final ActivityItem activity;
  final String currentUserId;

  const ActivityCard({
    super.key,
    required this.activity,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isRead = activity.isReadBy(currentUserId);
    final timeAgo = _formatTimeAgo(activity.timestamp);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isRead ? AppTheme.borderLight : AppTheme.accentCopper.withValues(alpha: 0.3),
          width: isRead ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _handleActivityTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Activity Icon
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: _getActivityColor().withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  _getActivityIcon(),
                  color: _getActivityColor(),
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              // Activity Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _getActivityText(),
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontWeight: isRead ? FontWeight.normal : FontWeight.w600,
                        color: isRead ? AppTheme.textSecondary : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      timeAgo,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                      ),
                    ),
                  ],
                ),
              ),
              // Unread indicator
              if (!isRead)
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    borderRadius: BorderRadius.circular(4),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getActivityColor() {
    switch (activity.type) {
      case ActivityType.memberJoined:
        return AppTheme.successGreen;
      case ActivityType.memberLeft:
        return AppTheme.errorRed;
      case ActivityType.jobShared:
        return AppTheme.accentCopper;
      case ActivityType.jobApplied:
        return AppTheme.infoBlue;
      case ActivityType.announcementPosted:
        return AppTheme.warningYellow;
      case ActivityType.milestoneReached:
        return AppTheme.secondaryCopper;
    }
    return AppTheme.mediumGray; // Default fallback
  }

  IconData _getActivityIcon() {
    switch (activity.type) {
      case ActivityType.memberJoined:
        return Icons.person_add;
      case ActivityType.memberLeft:
        return Icons.person_remove;
      case ActivityType.jobShared:
        return Icons.share;
      case ActivityType.jobApplied:
        return Icons.assignment_turned_in;
      case ActivityType.announcementPosted:
        return Icons.announcement;
      case ActivityType.milestoneReached:
        return Icons.celebration;
    }
    return Icons.info_outline; // Default fallback
  }

  String _getActivityText() {
    final actorName = activity.data['actorName'] ?? 'Someone';
    final jobTitle = activity.data['jobTitle'] ?? 'a job';
    final milestone = activity.data['milestone'] ?? 'milestone';

    switch (activity.type) {
      case ActivityType.memberJoined:
        return '$actorName joined the crew';
      case ActivityType.memberLeft:
        return '$actorName left the crew';
      case ActivityType.jobShared:
        return '$actorName shared $jobTitle';
      case ActivityType.jobApplied:
        return '$actorName applied to $jobTitle';
      case ActivityType.announcementPosted:
        return '$actorName posted an announcement';
      case ActivityType.milestoneReached:
        return 'Crew reached $milestone milestone';
    }
    return 'Unknown activity';
  }

  String _formatTimeAgo(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  void _handleActivityTap(BuildContext context) {
    // Mark as read and handle navigation if needed
    // This would typically call a provider method to mark the activity as read
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Activity: ${_getActivityText()}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}