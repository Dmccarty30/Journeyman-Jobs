import 'package:flutter/material.dart';
import '../models/message.dart';
import '../../../design_system/app_theme.dart';

class DMPreviewCard extends StatelessWidget {
  final Message lastMessage;
  final String otherUserName;
  final String otherUserId;
  final int unreadCount;
  final VoidCallback onTap;
  final String? otherUserAvatarUrl;

  const DMPreviewCard({
    super.key,
    required this.lastMessage,
    required this.otherUserName,
    required this.otherUserId,
    required this.unreadCount,
    required this.onTap,
    this.otherUserAvatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: unreadCount > 0 ? AppTheme.accentCopper.withOpacity(0.05) : AppTheme.white,
          border: Border(
            bottom: BorderSide(
              color: AppTheme.borderLight.withOpacity(0.5),
              width: 1,
            ),
          ),
        ),
        child: Row(
          children: [
            // Avatar
            Stack(
              children: [
                CircleAvatar(
                  radius: 24,
                  backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
                  backgroundImage: otherUserAvatarUrl != null
                      ? NetworkImage(otherUserAvatarUrl!)
                      : null,
                  child: otherUserAvatarUrl == null
                      ? Text(
                          _getInitials(otherUserName),
                          style: Theme.of(context).textTheme.titleMedium?.copyWith(
                            color: AppTheme.accentCopper,
                            fontWeight: FontWeight.w600,
                          ),
                        )
                      : null,
                ),
                if (unreadCount > 0)
                  Positioned(
                    right: 0,
                    top: 0,
                    child: Container(
                      width: 16,
                      height: 16,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AppTheme.white,
                          width: 2,
                        ),
                      ),
                      child: Center(
                        child: Text(
                          unreadCount > 9 ? '9+' : unreadCount.toString(),
                          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                            color: AppTheme.white,
                            fontSize: 8,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ),
              ],
            ),
            const SizedBox(width: 12),
            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          otherUserName,
                          style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                            color: AppTheme.textPrimary,
                            fontWeight: unreadCount > 0 ? FontWeight.w600 : FontWeight.w500,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      Text(
                        _formatTime(lastMessage.sentAt),
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppTheme.textLight,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      if (lastMessage.senderId == otherUserId)
                        Icon(
                          Icons.reply,
                          size: 14,
                          color: AppTheme.textLight,
                        ),
                      Expanded(
                        child: Text(
                          _getMessagePreview(lastMessage),
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: unreadCount > 0 ? AppTheme.textPrimary : AppTheme.textSecondary,
                            fontWeight: unreadCount > 0 ? FontWeight.w500 : FontWeight.normal,
                          ),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _getMessagePreview(Message message) {
    if (message.type == MessageType.text) {
      return message.content;
    } else if (message.type == MessageType.image) {
      return '📷 Photo';
    } else if (message.type == MessageType.voice) {
      return '🎤 Voice message';
    } else if (message.type == MessageType.document) {
      return '📄 Document';
    } else if (message.type == MessageType.jobShare) {
      return '🔗 Shared a job';
    } else if (message.type == MessageType.systemNotification) {
      return '📢 ${message.content}';
    }
    return message.content;
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
      if (difference.inDays == 1) return 'Yesterday';
      return '${difference.inDays}d';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m';
    } else {
      return 'now';
    }
  }
}