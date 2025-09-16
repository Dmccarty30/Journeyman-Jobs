import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../models/share_notification_model.dart';

/// Card for displaying job share notifications
/// 
/// Features:
/// - Electrical-themed design with lightning accents
/// - Different styles for sent/received notifications
/// - Interactive actions (view job, mark as read)
/// - Status indicators and timestamps
/// - Swipe-to-dismiss functionality
class JJNotificationCard extends StatefulWidget {
  /// The notification data to display
  final ShareNotificationModel notification;
  
  /// Callback when notification is tapped
  final VoidCallback? onTap;
  
  /// Callback when notification is dismissed
  final VoidCallback? onDismiss;
  
  /// Callback when job is viewed
  final VoidCallback? onViewJob;
  
  /// Callback when notification is marked as read
  final VoidCallback? onMarkAsRead;
  
  /// Whether to show avatar
  final bool showAvatar;

  const JJNotificationCard({
    Key? key,
    required this.notification,
    this.onTap,
    this.onDismiss,
    this.onViewJob,
    this.onMarkAsRead,
    this.showAvatar = true,
  }) : super(key: key);

  @override
  State<JJNotificationCard> createState() => _JJNotificationCardState();
}

class _JJNotificationCardState extends State<JJNotificationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnimation;
  bool _isDismissed = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));
    
    // Add subtle pulse for unread notifications
    if (!widget.notification.isRead) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _handleDismiss() {
    setState(() => _isDismissed = true);
    widget.onDismiss?.call();
  }

  void _handleMarkAsRead() {
    if (!widget.notification.isRead) {
      _pulseController.stop();
      widget.onMarkAsRead?.call();
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isDismissed) return const SizedBox.shrink();
    
    return AnimatedBuilder(
      animation: _pulseAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: _pulseAnimation.value,
          child: Container(
            margin: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            child: Dismissible(
              key: Key(widget.notification.id),
              direction: DismissDirection.endToStart,
              onDismissed: (_) => _handleDismiss(),
              background: _buildDismissBackground(),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  onTap: () {
                    _handleMarkAsRead();
                    widget.onTap?.call();
                  },
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: widget.notification.isRead
                          ? AppTheme.surface
                          : AppTheme.surfaceElevated,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      border: Border.all(
                        color: widget.notification.isRead
                            ? AppTheme.borderLight
                            : AppTheme.accentCopper.withValues(alpha: 0.3),
                        width: widget.notification.isRead
                            ? AppTheme.borderWidthThin
                            : AppTheme.borderWidthMedium,
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: AppTheme.shadowColor.withValues(alpha: 
                            widget.notification.isRead ? 0.05 : 0.1,
                          ),
                          blurRadius: widget.notification.isRead ? 4 : 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Header with avatar and type indicator
                        _buildHeader(),
                        
                        const SizedBox(height: AppTheme.spacingMd),
                        
                        // Main content
                        _buildContent(),
                        
                        const SizedBox(height: AppTheme.spacingMd),
                        
                        // Footer with actions and timestamp
                        _buildFooter(),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDismissBackground() {
    return Container(
      alignment: Alignment.centerRight,
      padding: const EdgeInsets.only(right: AppTheme.spacingLg),
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: const Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.delete_outline_rounded,
            color: Colors.white,
            size: 24,
          ),
          SizedBox(height: AppTheme.spacingXs),
          Text(
            'Dismiss',
            style: TextStyle(
              color: Colors.white,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Avatar (optional)
        if (widget.showAvatar) ...[
          CircleAvatar(
            radius: 16,
            backgroundColor: _getTypeColor().withValues(alpha: 0.1),
            backgroundImage: widget.notification.senderProfileImage != null
                ? NetworkImage(widget.notification.senderProfileImage!)
                : null,
            child: widget.notification.senderProfileImage == null
                ? Icon(
                    _getTypeIcon(),
                    size: 16,
                    color: _getTypeColor(),
                  )
                : null,
          ),
          
          const SizedBox(width: AppTheme.spacingMd),
        ],
        
        // Type and sender info
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  // Type indicator
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingSm,
                      vertical: AppTheme.spacingXxs,
                    ),
                    decoration: BoxDecoration(
                      color: _getTypeColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          _getTypeIcon(),
                          size: 12,
                          color: _getTypeColor(),
                        ),
                        const SizedBox(width: AppTheme.spacingXs),
                        Text(
                          _getTypeText(),
                          style: AppTheme.labelSmall.copyWith(
                            color: _getTypeColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  
                  const Spacer(),
                  
                  // Unread indicator
                  if (!widget.notification.isRead)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: const BoxDecoration(
                        color: AppTheme.accentCopper,
                        shape: BoxShape.circle,
                      ),
                    )
                      .animate()
                      .scale(
                        begin: const Offset(0.8, 0.8),
                        end: const Offset(1.2, 1.2),
                        duration: 1000.ms,
                      )
                      .then()
                      .scale(
                        begin: const Offset(1.2, 1.2),
                        end: const Offset(0.8, 0.8),
                        duration: 1000.ms,
                      ),
                ],
              ),
              
              // Sender name
              if (widget.notification.senderName != null) ...[
                const SizedBox(height: AppTheme.spacingXxs),
                Text(
                  widget.notification.senderName!,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Notification message
        Text(
          widget.notification.message,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textPrimary,
            fontWeight: widget.notification.isRead
                ? FontWeight.normal
                : FontWeight.w500,
          ),
          maxLines: 3,
          overflow: TextOverflow.ellipsis,
        ),
        
        // Job preview (if available)
        if (widget.notification.jobTitle != null) ...[
          const SizedBox(height: AppTheme.spacingMd),
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.accentCopper.withValues(alpha: 0.2),
                width: AppTheme.borderWidthThin,
              ),
            ),
            child: Row(
              children: [
                Icon(
                  Icons.work_outline_rounded,
                  size: 16,
                  color: AppTheme.accentCopper,
                ),
                
                const SizedBox(width: AppTheme.spacingSm),
                
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        widget.notification.jobTitle!,
                        style: AppTheme.bodySmall.copyWith(
                          color: AppTheme.textPrimary,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      if (widget.notification.jobCompany != null) ...[
                        const SizedBox(height: AppTheme.spacingXxs),
                        Text(
                          widget.notification.jobCompany!,
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Timestamp
        Text(
          _formatTimestamp(widget.notification.createdAt),
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        
        const Spacer(),
        
        // Action buttons
        if (widget.notification.jobId != null && widget.onViewJob != null)
          TextButton.icon(
            onPressed: widget.onViewJob,
            icon: const Icon(
              Icons.visibility_outlined,
              size: 16,
            ),
            label: const Text('View Job'),
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.accentCopper,
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              minimumSize: Size.zero,
              tapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          ),
      ],
    );
  }

  Color _getTypeColor() {
    switch (widget.notification.type) {
      case ShareNotificationType.jobShared:
        return AppTheme.accentCopper;
      case ShareNotificationType.shareReceived:
        return AppTheme.infoBlue;
      case ShareNotificationType.shareViewed:
        return AppTheme.successGreen;
      case ShareNotificationType.shareExpired:
        return AppTheme.warningOrange;
    }
  }

  IconData _getTypeIcon() {
    switch (widget.notification.type) {
      case ShareNotificationType.jobShared:
        return Icons.flash_on_rounded;
      case ShareNotificationType.shareReceived:
        return Icons.inbox_rounded;
      case ShareNotificationType.shareViewed:
        return Icons.visibility_rounded;
      case ShareNotificationType.shareExpired:
        return Icons.schedule_rounded;
    }
  }

  String _getTypeText() {
    switch (widget.notification.type) {
      case ShareNotificationType.jobShared:
        return 'Job Shared';
      case ShareNotificationType.shareReceived:
        return 'Job Received';
      case ShareNotificationType.shareViewed:
        return 'Job Viewed';
      case ShareNotificationType.shareExpired:
        return 'Share Expired';
    }
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);
    
    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${timestamp.month}/${timestamp.day}/${timestamp.year}';
    }
  }
}
