import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../design_system/app_theme.dart';

class MessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final int readCount;
  final bool isGroupChat;
  final int totalMembers;

  const MessageStatusIndicator({
    super.key,
    required this.status,
    this.readCount = 0,
    this.isGroupChat = false,
    this.totalMembers = 1,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStatusIcon(),
        if (isGroupChat && shouldShowReadCount()) ...[
          const SizedBox(width: AppTheme.spacingXs),
          _buildReadCount(),
        ],
      ],
    );
  }

  Widget _buildStatusIcon() {
    switch (status) {
      case MessageStatus.sending:
        return Icon(
          Icons.access_time,
          size: AppTheme.iconXs,
          color: AppTheme.textLight.withValues(alpha: 0.7),
        );
      case MessageStatus.sent:
        return Icon(
          Icons.done,
          size: AppTheme.iconXs,
          color: AppTheme.textLight,
        );
      case MessageStatus.delivered:
        return Icon(
          Icons.done_all,
          size: AppTheme.iconXs,
          color: AppTheme.textLight,
        );
      case MessageStatus.read:
        return Icon(
          Icons.done_all,
          size: AppTheme.iconXs,
          color: AppTheme.accentCopper, // Copper color for read status
        );
      case MessageStatus.failed:
        return Icon(
          Icons.error_outline,
          size: AppTheme.iconXs,
          color: AppTheme.errorRed,
        );
    }
  }

  Widget _buildReadCount() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingXs,
        vertical: 2.0, // Small vertical padding
      ),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Text(
        '${readCount + 1}/$totalMembers', // +1 to include the sender
        style: TextStyle(
          fontSize: 10,
          color: AppTheme.accentCopper,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }

  bool shouldShowReadCount() {
    return isGroupChat && 
           (status == MessageStatus.read || status == MessageStatus.delivered) &&
           readCount > 0;
  }

  String getStatusTooltip() {
    switch (status) {
      case MessageStatus.sending:
        return 'Sending...';
      case MessageStatus.sent:
        return 'Sent';
      case MessageStatus.delivered:
        return isGroupChat ? 'Delivered to group' : 'Delivered';
      case MessageStatus.read:
        return isGroupChat ? 'Read by ${readCount + 1} members' : 'Read';
      case MessageStatus.failed:
        return 'Failed to send';
    }
  }
}

// Enhanced status indicator with tooltip and advanced features
class EnhancedMessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final int readCount;
  final bool isGroupChat;
  final int totalMembers;
  final VoidCallback? onTap;

  const EnhancedMessageStatusIndicator({
    super.key,
    required this.status,
    this.readCount = 0,
    this.isGroupChat = false,
    this.totalMembers = 1,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final statusIndicator = MessageStatusIndicator(
      status: status,
      readCount: readCount,
      isGroupChat: isGroupChat,
      totalMembers: totalMembers,
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        child: Tooltip(
          message: statusIndicator.getStatusTooltip(),
          child: statusIndicator,
        ),
      );
    }

    return Tooltip(
      message: statusIndicator.getStatusTooltip(),
      child: statusIndicator,
    );
  }
}

// Status indicator for message lists (compact version)
class CompactMessageStatusIndicator extends StatelessWidget {
  final MessageStatus status;
  final bool isUnread;

  const CompactMessageStatusIndicator({
    super.key,
    required this.status,
    this.isUnread = false,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: AppTheme.spacingMd,
      height: AppTheme.spacingMd,
      decoration: BoxDecoration(
        color: _getIndicatorColor(),
        shape: BoxShape.circle,
      ),
      child: status == MessageStatus.sending
          ? const SizedBox(
              width: AppTheme.spacingSm,
              height: AppTheme.spacingSm,
              child: CircularProgressIndicator(
                strokeWidth: 2,
                color: Colors.white,
              ),
            )
          : null,
    );
  }

  Color _getIndicatorColor() {
    if (isUnread) return AppTheme.accentCopper;
    
    switch (status) {
      case MessageStatus.failed:
        return AppTheme.errorRed;
      case MessageStatus.sending:
        return AppTheme.infoBlue;
      default:
        return AppTheme.successGreen;
    }
  }
}