import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../../design_system/app_theme.dart';
import '../../../electrical_components/enhanced_backgrounds.dart';
import '../../../models/job_model.dart';
import '../../../widgets/enhanced_job_card.dart';
import '../models/job_notification.dart';
import '../models/crew_enums.dart';

/// A notification card for job opportunities shared within crews.
///
/// Displays job details with crew-specific context including who shared,
/// member responses, and action buttons for electrical trade coordination.
class JobNotificationCard extends ConsumerStatefulWidget {
  /// Creates a job notification card.
  const JobNotificationCard({
    super.key,
    required this.notification,
    required this.job,
    required this.isRead,
    this.onTap,
    this.onApply,
    this.onShare,
    this.onDiscuss,
    this.onSave,
    this.onViewDetails,
    this.showActions = true,
    this.margin,
  });

  /// The job notification data
  final JobNotification notification;

  /// The job details
  final Job job;

  /// Whether the notification has been read
  final bool isRead;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when apply button is pressed
  final VoidCallback? onApply;

  /// Callback when share button is pressed
  final VoidCallback? onShare;

  /// Callback when discuss button is pressed
  final VoidCallback? onDiscuss;

  /// Callback when save button is pressed
  final VoidCallback? onSave;

  /// Callback when view details is pressed
  final VoidCallback? onViewDetails;

  /// Whether to show action buttons
  final bool showActions;

  /// Card margin
  final EdgeInsets? margin;

  @override
  ConsumerState<JobNotificationCard> createState() => _JobNotificationCardState();
}

class _JobNotificationCardState extends ConsumerState<JobNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 0.95,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    // Start pulse animation for unread notifications
    if (!widget.isRead) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(JobNotificationCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.isRead != widget.isRead) {
      if (!widget.isRead) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: widget.isRead ? 1.0 : _pulseAnimation.value,
          child: Container(
            margin: widget.margin ?? const EdgeInsets.all(AppTheme.spacingSm),
            child: Card(
              elevation: widget.isRead ? 2 : 4,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                side: _getCardBorder(),
              ),
              child: InkWell(
                onTap: widget.onTap,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                child: Container(
                  decoration: _getCardDecoration(),
                  child: Column(
                    children: [
                      _buildNotificationHeader(),
                      _buildJobContent(),
                      if (widget.showActions) _buildActionButtons(),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  /// Get card border based on notification state
  BorderSide _getCardBorder() {
    if (widget.notification.isPriority) {
      return const BorderSide(
        color: AppTheme.errorRed,
        width: AppTheme.borderWidthThick,
      );
    } else if (!widget.isRead) {
      return const BorderSide(
        color: AppTheme.accentCopper,
        width: AppTheme.borderWidthMedium,
      );
    }
    return const BorderSide(
      color: AppTheme.borderLight,
      width: AppTheme.borderWidthThin,
    );
  }

  /// Get card decoration based on notification state
  BoxDecoration _getCardDecoration() {
    if (widget.notification.isExpired) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        color: AppTheme.lightGray.withOpacity(0.5),
      );
    } else if (widget.notification.isPriority) {
      return BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        gradient: LinearGradient(
          colors: [
            AppTheme.errorRed.withOpacity(0.1),
            AppTheme.white,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      );
    }
    return BoxDecoration(
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      color: AppTheme.white,
    );
  }

  /// Build notification header with metadata
  Widget _buildNotificationHeader() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.notification.isPriority
            ? AppTheme.errorRed.withOpacity(0.1)
            : AppTheme.offWhite,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusMd),
          topRight: Radius.circular(AppTheme.radiusMd),
        ),
      ),
      child: Row(
        children: [
          // Notification indicator
          Container(
            width: 8,
            height: 8,
            decoration: BoxDecoration(
              color: _getStatusColor(),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: AppTheme.spacingXs),

          // Shared by indicator
          Icon(
            Icons.share,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          
          Expanded(
            child: Text(
              'Shared by crew member',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
          ),

          // Timestamp
          Text(
            timeago.format(widget.notification.timestamp),
            style: AppTheme.captionText.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),

          // Priority indicator
          if (widget.notification.isPriority) ...[
            const SizedBox(width: AppTheme.spacingXs),
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.errorRed,
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    Icons.flash_on,
                    size: 12,
                    color: AppTheme.white,
                  ),
                  const SizedBox(width: 2),
                  Text(
                    'URGENT',
                    style: AppTheme.captionText.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }

  /// Build job content section
  Widget _buildJobContent() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and classification
          Row(
            children: [
              Expanded(
                child: Text(
                  widget.job.jobTitle ?? widget.job.company,
                  style: AppTheme.headingSmall.copyWith(
                    color: widget.notification.isExpired
                        ? AppTheme.textSecondary
                        : AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (widget.job.classification != null) ...[
                const SizedBox(width: AppTheme.spacingXs),
                _buildClassificationBadge(widget.job.classification!),
              ],
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingXs),

          // Location and local
          Row(
            children: [
              Icon(
                Icons.location_on,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: Text(
                  widget.job.location,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ),
              if (widget.job.local != null) ...[
                const SizedBox(width: AppTheme.spacingXs),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingXs,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy,
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Text(
                    'Local ${widget.job.local}',
                    style: AppTheme.captionText.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ],
          ),

          const SizedBox(height: AppTheme.spacingXs),

          // Pay and hours
          Row(
            children: [
              if (widget.job.wage != null) ...[
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: AppTheme.successGreen,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  '\$${widget.job.wage!.toStringAsFixed(2)}/hr',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
              if (widget.job.hours != null) ...[
                const SizedBox(width: AppTheme.spacingSm),
                Icon(
                  Icons.schedule,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  '${widget.job.hours}h/week',
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),

          // Message from sharer
          if (widget.notification.message != null) ...[
            const SizedBox(height: AppTheme.spacingXs),
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: AppTheme.offWhite,
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: AppTheme.borderWidthThin,
                ),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(
                    Icons.message,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      widget.notification.message!,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.textSecondary,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ],

          // Response summary
          if (widget.notification.memberResponses.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXs),
            _buildResponseSummary(),
          ],

          // Expiration warning
          if (widget.notification.expiresAt != null) ...[
            const SizedBox(height: AppTheme.spacingXs),
            _buildExpirationWarning(),
          ],
        ],
      ),
    );
  }

  /// Build classification badge
  Widget _buildClassificationBadge(String classification) {
    Color badgeColor;
    switch (classification.toLowerCase()) {
      case 'inside':
      case 'inside wireman':
        badgeColor = AppTheme.infoBlue;
        break;
      case 'outside':
      case 'journeyman lineman':
        badgeColor = AppTheme.warningOrange;
        break;
      case 'tree trimmer':
        badgeColor = AppTheme.successGreen;
        break;
      case 'operator':
        badgeColor = AppTheme.secondaryCopper;
        break;
      default:
        badgeColor = AppTheme.primaryNavy;
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: badgeColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
      ),
      child: Text(
        classification.toUpperCase(),
        style: AppTheme.captionText.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  /// Build response summary
  Widget _buildResponseSummary() {
    final responses = widget.notification.memberResponses.values;
    final acceptedCount = responses.where((r) => r.type == ResponseType.accepted).length;
    final pendingCount = responses.where((r) => r.type == ResponseType.pending).length;
    final totalCount = responses.length;

    return Row(
      children: [
        Icon(
          Icons.people,
          size: 16,
          color: AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          '$acceptedCount/$totalCount interested',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
        if (pendingCount > 0) ...[
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            '($pendingCount pending)',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.warningOrange,
            ),
          ),
        ],
      ],
    );
  }

  /// Build expiration warning
  Widget _buildExpirationWarning() {
    final expiresAt = widget.notification.expiresAt!;
    final timeUntilExpiration = expiresAt.difference(DateTime.now());
    final isExpiringSoon = timeUntilExpiration.inHours < 24;

    return Row(
      children: [
        Icon(
          Icons.schedule,
          size: 16,
          color: isExpiringSoon ? AppTheme.errorRed : AppTheme.textSecondary,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          widget.notification.isExpired
              ? 'Expired'
              : 'Expires ${timeago.format(expiresAt)}',
          style: AppTheme.bodySmall.copyWith(
            color: widget.notification.isExpired
                ? AppTheme.errorRed
                : isExpiringSoon
                    ? AppTheme.warningOrange
                    : AppTheme.textSecondary,
            fontWeight: isExpiringSoon ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  /// Build action buttons
  Widget _buildActionButtons() {
    if (widget.notification.isExpired) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingSm),
        child: Text(
          'This job opportunity has expired',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontStyle: FontStyle.italic,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: const BoxDecoration(
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: Row(
        children: [
          // Apply button
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: widget.onApply,
              icon: const Icon(Icons.work, size: 16),
              label: const Text('Apply'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingXs),

          // Secondary actions
          Expanded(
            child: OutlinedButton.icon(
              onPressed: widget.onShare,
              icon: const Icon(Icons.share, size: 16),
              label: const Text('Share'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentCopper,
                side: const BorderSide(color: AppTheme.accentCopper),
                padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                ),
              ),
            ),
          ),

          const SizedBox(width: AppTheme.spacingXs),

          // More options
          PopupMenuButton<String>(
            onSelected: (value) {
              switch (value) {
                case 'details':
                  widget.onViewDetails?.call();
                  break;
                case 'discuss':
                  widget.onDiscuss?.call();
                  break;
                case 'save':
                  widget.onSave?.call();
                  break;
              }
            },
            itemBuilder: (context) => [
              const PopupMenuItem(
                value: 'details',
                child: Row(
                  children: [
                    Icon(Icons.info_outline, size: 16),
                    SizedBox(width: 8),
                    Text('View Details'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'discuss',
                child: Row(
                  children: [
                    Icon(Icons.chat_bubble_outline, size: 16),
                    SizedBox(width: 8),
                    Text('Discuss'),
                  ],
                ),
              ),
              const PopupMenuItem(
                value: 'save',
                child: Row(
                  children: [
                    Icon(Icons.bookmark_border, size: 16),
                    SizedBox(width: 8),
                    Text('Save'),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingXs),
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderLight),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
              ),
              child: const Icon(
                Icons.more_vert,
                size: 16,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Get status color based on notification state
  Color _getStatusColor() {
    if (widget.notification.isExpired) {
      return AppTheme.textSecondary;
    } else if (widget.notification.isPriority) {
      return AppTheme.errorRed;
    } else if (!widget.isRead) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.successGreen;
    }
  }
}
