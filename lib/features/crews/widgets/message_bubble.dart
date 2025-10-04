import 'package:flutter/material.dart';
import 'package:intl/intl.dart'; // For date formatting
import '../models/message.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/circuit_pattern_painter.dart'; // For circuit background
import 'message_status_indicator.dart';

class MessageBubble extends StatelessWidget {
  final Message message;
  final bool isCurrentUser;
  final bool showAvatar;
  final String senderName;
  final int? totalMembers; // For group chat member count
  final VoidCallback? onStatusTap;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    required this.senderName,
    this.showAvatar = true,
    this.totalMembers,
    this.onStatusTap,
  });

  @override
  Widget build(BuildContext context) {
    final bool isSystemNotification = message.type == MessageType.systemNotification;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        mainAxisAlignment: isCurrentUser ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          if (!isCurrentUser && showAvatar && !isSystemNotification) ...[
            CircleAvatar(
              radius: AppTheme.radiusLg,
              backgroundColor: AppTheme.accentCopper.withOpacity(AppTheme.opacityElectricalCircuitTrace),
              child: Text(
                _getInitials(senderName),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
          ],
          ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: MediaQuery.of(context).size.width * 0.7,
            ),
            child: Column(
              crossAxisAlignment: isCurrentUser ? CrossAxisAlignment.end : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser && showAvatar && !isSystemNotification)
                  Padding(
                    padding: const EdgeInsets.only(left: AppTheme.spacingSm, bottom: AppTheme.spacingXs),
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
                          const SizedBox(width: AppTheme.spacingXs),
                          _buildMessageTypeIcon(context),
                        ],
                      ],
                    ),
                  ),
                Container(
                  padding: EdgeInsets.symmetric(
                    horizontal: isSystemNotification ? AppTheme.spacingMd : AppTheme.spacingLg,
                    vertical: isSystemNotification ? AppTheme.spacingSm : AppTheme.spacingMd,
                  ),
                  decoration: BoxDecoration(
                    color: _getBubbleColor(),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthCopperThin),
                    boxShadow: isCurrentUser
                        ? [
                            BoxShadow(
                              color: AppTheme.accentCopper.withOpacity(AppTheme.opacityElectricalGlow),
                              blurRadius: AppTheme.spacingMd,
                              offset: const Offset(0, AppTheme.spacingXs),
                            ),
                          ]
                        : null,
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: CustomPaint(
                          painter: CircuitPatternPainter(
                            primaryColor: AppTheme.electricalCircuitTrace.withOpacity(AppTheme.opacityElectricalCircuitTrace),
                            secondaryColor: AppTheme.electricalCircuitTraceLight.withOpacity(AppTheme.opacityElectricalCircuitTraceLight),
                            animate: false, // No animation for static background
                          ),
                        ),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isSystemNotification) ...[
                            Row(
                              children: [
                                Icon(
                                  Icons.notifications_active,
                                  size: AppTheme.iconSm,
                                  color: AppTheme.accentCopper,
                                ),
                                const SizedBox(width: AppTheme.spacingSm),
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
                              const SizedBox(height: AppTheme.spacingSm),
                              _buildAttachments(context),
                            ],
                          ],
                          const SizedBox(height: AppTheme.spacingXs),
                          _buildMessageMetadata(context),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          if (isCurrentUser && showAvatar && !isSystemNotification) ...[
            const SizedBox(width: AppTheme.spacingSm),
            CircleAvatar(
              radius: AppTheme.radiusLg,
              backgroundColor: AppTheme.accentCopper,
              child: Icon(
                Icons.person,
                size: AppTheme.iconSm,
                color: AppTheme.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageMetadata(BuildContext context) {
    final isGroupChat = message.isCrewMessage && (totalMembers != null && totalMembers! > 2);
    final readCount = message.readByList.length - (isCurrentUser ? 1 : 0); // Exclude self if current user
    
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          _formatTime(message.sentAt),
          style: Theme.of(context).textTheme.labelSmall?.copyWith(
            color: AppTheme.textLight,
          ),
        ),
        if (isCurrentUser) ...[
          const SizedBox(width: AppTheme.spacingXs),
          EnhancedMessageStatusIndicator(
            status: message.status,
            readCount: readCount,
            isGroupChat: isGroupChat,
            totalMembers: totalMembers ?? 1,
            onTap: onStatusTap,
          ),
        ],
      ],
    );
  }

  Widget _buildAttachments(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SizedBox(height: AppTheme.spacingSm),
        Container(
          height: AppTheme.borderWidthThin,
          color: _getTextColor().withOpacity(AppTheme.opacityElectricalCircuitTrace),
          margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
        ),
        Wrap(
          spacing: AppTheme.spacingSm,
          runSpacing: AppTheme.spacingXs,
          children: message.attachments!.map((attachment) {
            return Container(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: _getBubbleColor(),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: _getTextColor().withOpacity(AppTheme.opacityElectricalCircuitTraceLight),
                  width: AppTheme.borderWidthThin,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _getAttachmentIcon(attachment.type),
                    size: AppTheme.iconXs,
                    color: _getTextColor(),
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
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
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final messageDate = DateTime(timestamp.year, timestamp.month, timestamp.day);

    if (messageDate.isAtSameMomentAs(today)) {
      return DateFormat('h:mm a').format(timestamp);
    } else if (messageDate.isAtSameMomentAs(yesterday)) {
      return 'Yesterday, ${DateFormat('h:mm a').format(timestamp)}';
    } else {
      return DateFormat('MMM d, h:mm a').format(timestamp);
    }
  }

  Color _getBubbleColor() {
    switch (message.type) {
      case MessageType.systemNotification:
        return AppTheme.electricalSurface;
      case MessageType.jobShare:
        return AppTheme.accentCopper.withOpacity(AppTheme.opacityElectricalCircuitTrace);
      case MessageType.text:
      default:
        return isCurrentUser ? AppTheme.primaryNavy : AppTheme.electricalSurface;
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
        return isCurrentUser ? AppTheme.white : AppTheme.textOnDark;
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
      size: AppTheme.iconXs,
      color: iconColor,
    );
  }
}