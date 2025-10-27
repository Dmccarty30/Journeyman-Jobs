import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';

/// Message bubble component for crew chat interface
///
/// This widget displays individual messages with:
/// - Different styles for sent/received messages
/// - Support for various message types (text, image, location, etc.)
/// - Reaction display and interaction
/// - Read status indicators
/// - Electrical themed styling
class CrewMessageBubble extends StatefulWidget {
  final CrewMessage message;
  final bool isFromCurrentUser;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final Function(String)? onReactionTap;
  final bool showTimestamp;
  final bool showReadStatus;

  const CrewMessageBubble({
    super.key,
    required this.message,
    required this.isFromCurrentUser,
    this.onTap,
    this.onLongPress,
    this.onReactionTap,
    this.showTimestamp = true,
    this.showReadStatus = true,
  });

  @override
  State<CrewMessageBubble> createState() => _CrewMessageBubbleState();
}

class _CrewMessageBubbleState extends State<CrewMessageBubble>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingXs,
        ),
        child: Column(
          crossAxisAlignment: widget.isFromCurrentUser
              ? CrossAxisAlignment.end
              : CrossAxisAlignment.start,
          children: [
            // Message bubble
            Row(
              mainAxisAlignment: widget.isFromCurrentUser
                  ? MainAxisAlignment.end
                  : MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                if (!widget.isFromCurrentUser) ...[
                  // Sender avatar
                  CircleAvatar(
                    radius: 16,
                    backgroundColor: AppTheme.primaryNavy,
                    backgroundImage: widget.message.senderAvatarUrl != null
                        ? NetworkImage(widget.message.senderAvatarUrl!)
                        : null,
                    child: widget.message.senderAvatarUrl == null
                        ? Text(
                            widget.message.senderName.isNotEmpty
                                ? widget.message.senderName[0].toUpperCase()
                                : 'U',
                            style: AppTheme.bodySmall.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.w600,
                            ),
                          )
                        : null,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                ],

                // Message content
                Flexible(
                  child: Column(
                    crossAxisAlignment: widget.isFromCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      if (!widget.isFromCurrentUser && widget.message.type != CrewMessageType.system)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                          child: Text(
                            widget.message.senderName,
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.textSecondary,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),

                      GestureDetector(
                        onTap: widget.onTap,
                        onLongPress: widget.onLongPress,
                        child: _buildMessageBubble(),
                      ),
                    ],
                  ),
                ),

                if (widget.isFromCurrentUser) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  // Read status indicator
                  if (widget.showReadStatus)
                    _buildReadStatus(),
                ],
              ],
            ),

            // Timestamp
            if (widget.showTimestamp)
              Padding(
                padding: EdgeInsets.only(
                  top: AppTheme.spacingXs,
                  left: widget.isFromCurrentUser ? 0 : 40,
                  right: widget.isFromCurrentUser ? 40 : 0,
                ),
                child: Text(
                  _formatTimestamp(widget.message.createdAt),
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textLight,
                    fontSize: 10,
                  ),
                ),
              ),

            // Reactions
            if (widget.message.hasReactions)
              Padding(
                padding: EdgeInsets.only(
                  top: AppTheme.spacingXs,
                  left: widget.isFromCurrentUser ? 0 : 40,
                  right: widget.isFromCurrentUser ? 40 : 0,
                ),
                child: _buildReactions(),
              ),

            // Edited indicator
            if (widget.message.isEdited)
              Padding(
                padding: EdgeInsets.only(
                  top: AppTheme.spacingXs,
                  left: widget.isFromCurrentUser ? 0 : 40,
                  right: widget.isFromCurrentUser ? 40 : 0,
                ),
                child: Text(
                  'edited',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textLight,
                    fontSize: 10,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    // System messages have special styling
    if (widget.message.isSystemMessage) {
      return _buildSystemMessage();
    }

    Container bubble = Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      padding: _getBubblePadding(),
      decoration: BoxDecoration(
        color: _getBubbleColor(),
        borderRadius: _getBubbleBorderRadius(),
        border: _getBubbleBorder(),
        boxShadow: _getBubbleShadow(),
      ),
      child: _buildMessageContent(),
    );

    // Add priority indicator for high/urgent messages
    if (widget.message.isHighPriority || widget.message.isUrgent) {
      return Stack(
        children: [
          bubble,
          Positioned(
            top: -4,
            right: widget.isFromCurrentUser ? -4 : null,
            left: !widget.isFromCurrentUser ? -4 : null,
            child: Container(
              width: 12,
              height: 12,
              decoration: BoxDecoration(
                color: widget.message.isUrgent
                    ? AppTheme.errorRed
                    : AppTheme.warningYellow,
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: widget.message.isUrgent
                        ? AppTheme.errorRed
                        : AppTheme.warningYellow,
                    blurRadius: 4,
                  ),
                ],
              ),
              child: Icon(
                widget.message.isUrgent ? Icons.priority_high : Icons.warning,
                size: 8,
                color: AppTheme.white,
              ),
            ),
          ),
        ],
      );
    }

    return bubble;
  }

  Widget _buildSystemMessage() {
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.8,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: AppTheme.primaryNavy.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Center(
        child: Text(
          widget.message.content,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.primaryNavy,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case CrewMessageType.text:
        return _buildTextMessage();
      case CrewMessageType.image:
        return _buildImageMessage();
      case CrewMessageType.voiceNote:
        return _buildVoiceNoteMessage();
      case CrewMessageType.location:
        return _buildLocationMessage();
      case CrewMessageType.jobShare:
        return _buildJobShareMessage();
      case CrewMessageType.alert:
        return _buildAlertMessage();
      case CrewMessageType.system:
        return _buildSystemMessage();
      }
  }

  Widget _buildTextMessage() {
    return Text(
      widget.message.content,
      style: AppTheme.bodyMedium.copyWith(
        color: _getTextColor(),
        height: 1.4,
      ),
    );
  }

  Widget _buildImageMessage() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (widget.message.content.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
            child: Text(
              widget.message.content,
              style: AppTheme.bodyMedium.copyWith(
                color: _getTextColor(),
              ),
            ),
          ),
        // Image placeholder
        Container(
          width: 200,
          height: 150,
          decoration: BoxDecoration(
            color: AppTheme.neutralGray300,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          ),
          child: widget.message.hasMedia
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  child: Image.network(
                    widget.message.mediaUrls.first,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) {
                      return _buildImageErrorWidget();
                    },
                    loadingBuilder: (context, child, loadingProgress) {
                      if (loadingProgress == null) return child;
                      return _buildImageLoadingWidget();
                    },
                  ),
                )
              : _buildImagePlaceholder(),
        ),
      ],
    );
  }

  Widget _buildVoiceNoteMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.mic,
          color: _getTextColor(),
          size: AppTheme.iconLg,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Text(
          'Voice note',
          style: AppTheme.bodyMedium.copyWith(
            color: _getTextColor(),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Icon(
          Icons.play_arrow,
          color: _getTextColor(),
          size: AppTheme.iconLg,
        ),
      ],
    );
  }

  Widget _buildLocationMessage() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.location_on,
          color: _getTextColor(),
          size: AppTheme.iconLg,
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Flexible(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Location shared',
                style: AppTheme.bodyMedium.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w600,
                ),
              ),
              if (widget.message.content.isNotEmpty)
                Text(
                  widget.message.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: _getTextColor().withValues(alpha: 0.7),
                  ),
                ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildJobShareMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: _getTextColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.work,
            color: _getTextColor(),
            size: AppTheme.iconLg,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Flexible(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Opportunity',
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                if (widget.message.content.isNotEmpty)
                  Text(
                    widget.message.content,
                    style: AppTheme.bodySmall.copyWith(
                      color: _getTextColor().withValues(alpha: 0.7),
                    ),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAlertMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.message.isUrgent
            ? AppTheme.errorRed.withValues(alpha: 0.1)
            : AppTheme.warningYellow.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: widget.message.isUrgent
              ? AppTheme.errorRed.withValues(alpha: 0.3)
              : AppTheme.warningYellow.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            widget.message.isUrgent ? Icons.warning : Icons.info,
            color: widget.message.isUrgent
                ? AppTheme.errorRed
                : AppTheme.warningYellow,
            size: AppTheme.iconLg,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Flexible(
            child: Text(
              widget.message.content,
              style: AppTheme.bodyMedium.copyWith(
                color: widget.message.isUrgent
                    ? AppTheme.errorRed
                    : AppTheme.warningYellow,
                ),
              ),
          ),
        ],
      ),
    );
  }

  Widget _buildImageErrorWidget() {
    return Container(
      color: AppTheme.neutralGray300,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.broken_image,
              color: AppTheme.textLight,
              size: AppTheme.iconXl,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              'Failed to load',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textLight,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageLoadingWidget() {
    return Center(
      child: CircularProgressIndicator(
        strokeWidth: 2,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.textLight),
      ),
    );
  }

  Widget _buildImagePlaceholder() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.image,
            color: AppTheme.textLight,
            size: AppTheme.iconXl,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            'Image',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReadStatus() {
    if (widget.message.readStatus.length <= 1) {
      return const SizedBox.shrink();
    }

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          Icons.done_all,
          size: 16,
          color: AppTheme.successGreen,
        ),
        const SizedBox(width: 2),
        Text(
          '${widget.message.readStatus.length}',
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textLight,
            fontSize: 10,
          ),
        ),
      ],
    );
  }

  Widget _buildReactions() {
    final reactions = widget.message.reactions.entries.toList();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color: AppTheme.borderLight,
          width: 1,
        ),
      ),
      child: Wrap(
        spacing: AppTheme.spacingXs,
        children: reactions.map((entry) {
          return GestureDetector(
            onTap: () => widget.onReactionTap?.call(entry.key),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingXs,
                vertical: 2,
              ),
              decoration: BoxDecoration(
                color: AppTheme.white,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.borderLight,
                  width: 1,
                ),
              ),
              child: Text(
                entry.value,
                style: const TextStyle(fontSize: 12),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  EdgeInsets _getBubblePadding() {
    switch (widget.message.type) {
      case CrewMessageType.image:
      case CrewMessageType.jobShare:
      case CrewMessageType.alert:
        return const EdgeInsets.all(AppTheme.spacingSm);
      default:
        return const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        );
    }
  }

  Color _getBubbleColor() {
    if (widget.message.isSystemMessage) {
      return AppTheme.primaryNavy.withValues(alpha: 0.1);
    }

    if (widget.isFromCurrentUser) {
      return AppTheme.primaryNavy;
    }

    return AppTheme.white;
  }

  Color _getTextColor() {
    if (widget.message.isSystemMessage) {
      return AppTheme.primaryNavy;
    }

    if (widget.isFromCurrentUser) {
      return AppTheme.white;
    }

    return AppTheme.textPrimary;
  }

  BorderRadius _getBubbleBorderRadius() {
    if (widget.message.isSystemMessage) {
      return BorderRadius.circular(AppTheme.radiusLg);
    }

    if (widget.isFromCurrentUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(AppTheme.radiusLg),
        topRight: Radius.circular(AppTheme.radiusLg),
        bottomLeft: Radius.circular(AppTheme.radiusLg),
        bottomRight: Radius.circular(AppTheme.radiusSm),
      );
    }

    return const BorderRadius.only(
      topLeft: Radius.circular(AppTheme.radiusSm),
      topRight: Radius.circular(AppTheme.radiusLg),
      bottomLeft: Radius.circular(AppTheme.radiusLg),
      bottomRight: Radius.circular(AppTheme.radiusLg),
    );
  }

  Border? _getBubbleBorder() {
    if (widget.message.isSystemMessage) {
      return Border.all(
        color: AppTheme.primaryNavy.withValues(alpha: 0.2),
        width: 1,
      );
    }

    if (!widget.isFromCurrentUser) {
      return Border.all(
        color: AppTheme.borderLight,
        width: 1,
      );
    }

    return null;
  }

  List<BoxShadow> _getBubbleShadow() {
    if (widget.message.isSystemMessage) {
      return [];
    }

    if (widget.isFromCurrentUser) {
      return [
        BoxShadow(
          color: AppTheme.primaryNavy.withValues(alpha: 0.2),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];
    }

    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.1),
        blurRadius: 4,
        offset: const Offset(0, 2),
      ),
    ];
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return DateFormat('h:mm a').format(date);
    } else if (difference.inDays < 7) {
      return DateFormat('EEEE').format(date);
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }
}