import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../design_system/app_theme.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final String senderName;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.senderName,
    this.showAvatar = true,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser && showAvatar) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              child: Text(
                _getInitials(senderName),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: 8),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser && showAvatar)
                  Padding(
                    padding: const EdgeInsets.only(left: 8, bottom: 2),
                    child: Row(
                      children: [
                        Text(
                          senderName,
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.textLight,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        if (message.type != MessageType.text) ...[
                          const SizedBox(width: 4),
                          _buildMessageTypeIcon(context),
                        ],
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: message.type == MessageType.systemNotification ? 12 : 16,
                    vertical: message.type == MessageType.systemNotification ? 8 : 12
                  ),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(),
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(isCurrentUser ? 16 : message.type == MessageType.systemNotification ? 12 : 4),
                      topRight: Radius.circular(isCurrentUser ? message.type == MessageType.systemNotification ? 12 : 4 : 16),
                      bottomLeft: const Radius.circular(16),
                      bottomRight: const Radius.circular(16),
                    ),
                    border: message.type == MessageType.systemNotification
                        ? Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopperThin)
                        : null,
                    boxShadow: message.type == MessageType.systemNotification || isCurrentUser
                        ? [
                            BoxShadow(
                              color: _getBubbleColor().withValues(alpha: 0.2),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ]
                        : null,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.type == MessageType.systemNotification) ...[
                        Row(
                          children: [
                            Icon(
                              Icons.notifications_active,
                              size: 16,
                              color: AppTheme.accentCopper,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                message.content,
                                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                  color: AppTheme.textPrimary,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ] else ...[
                        Text(
                          message.content,
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: _getTextColor(),
                            fontWeight: message.type == MessageType.jobShare ? FontWeight.w600 : FontWeight.normal,
                          ),
                        ),
                        if (message.hasAttachments) ...[
                          const SizedBox(height: 8),
                          _buildAttachments(context),
                        ],
                      ],
                    ],
                  ),
                ),
                const SizedBox(height: 4),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      _formatTime(message.sentAt),
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: AppTheme.textLight,
                        fontSize: 10,
                      ),
                    ),
                    if (isCurrentUser) ...[
                      const SizedBox(width: 4),
                      Icon(
                        message.readBy.isNotEmpty ? Icons.done_all : Icons.done,
                        size: 12,
                        color: message.readBy.isNotEmpty ? AppTheme.infoBlue : AppTheme.textLight,
                      ),
                    ],
                  ],
                ),
              ],
            ),
          ),
          if (isCurrentUser && showAvatar) ...[
            const SizedBox(width: 8),
            CircleAvatar(
              radius: 16,
              backgroundColor: AppTheme.accentCopper,
              child: Icon(
                Icons.person,
                size: 16,
                color: AppTheme.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildAttachments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: 8),
        Container(
          height: 1,
          color: _getTextColor().withValues(alpha: 0.2),
          margin: const EdgeInsets.symmetric(vertical: 8),
        ),
        Wrap(
          spacing: 8,
          runSpacing: 4,
          children: message.attachments!.map((attachment) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
              decoration: BoxDecoration(
                color: _getBubbleColor(),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(
                  color: _getTextColor().withValues(alpha: 0.3),
                  width: AppTheme.borderWidthThin
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAttachmentIcon(attachment.type),
                    size: 14,
                    color: _getTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Flexible(
                    child: Text(
                      attachment.filename,
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: _getTextColor(),
                        fontSize: 10,
                      ),
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  IconData _getAttachmentIcon(AttachmentType type) {
    switch (type) {
      case AttachmentType.image:
        return Icons.image;
      case AttachmentType.document:
        return Icons.description;
      case AttachmentType.video:
        return Icons.videocam;
      case AttachmentType.voiceNote:
        return Icons.audiotrack;
      case AttachmentType.certification:
        return Icons.verified;
      case AttachmentType.file:
        return Icons.insert_drive_file;
      case AttachmentType.audio:
        return Icons.audiotrack;
    }
  }

  String _getInitials(String name) {
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.substring(0, 2).toUpperCase();
  }

  String _formatTime(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }

  Color _getBubbleColor() {
    switch (message.type) {
      case MessageType.systemNotification:
        return AppTheme.electricalSurface;
      case MessageType.jobShare:
        return AppTheme.accentCopper.withValues(alpha: 0.1);
      case MessageType.text:
      default:
        return isCurrentUser ? AppTheme.accentCopper : AppTheme.offWhite;
    }
  }

  Color _getTextColor() {
    switch (message.type) {
      case MessageType.systemNotification:
        return AppTheme.accentCopper;
      case MessageType.jobShare:
        return AppTheme.accentCopper;
      case MessageType.text:
      default:
        return isCurrentUser ? AppTheme.white : AppTheme.textPrimary;
    }
  }

  Widget _buildMessageTypeIcon(BuildContext context) {
    IconData iconData;
    Color iconColor;
    
    switch (message.type) {
      case MessageType.image:
        iconData = Icons.image;
        iconColor = AppTheme.infoBlue;
        break;
      case MessageType.voice:
        iconData = Icons.mic;
        iconColor = AppTheme.successGreen;
        break;
      case MessageType.document:
        iconData = Icons.description;
        iconColor = AppTheme.warningYellow;
        break;
      case MessageType.jobShare:
        iconData = Icons.work;
        iconColor = AppTheme.accentCopper;
        break;
      case MessageType.systemNotification:
        iconData = Icons.notifications_active;
        iconColor = AppTheme.accentCopper;
        break;
      case MessageType.text:
      default:
        return const SizedBox.shrink();
    }
    
    return Icon(
      iconData,
      size: 14,
      color: iconColor,
    );
  }
}