import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';

/// Enhanced message bubble widget with electrical theme and comprehensive interactions.
///
/// This component provides:
/// - Electrical gradient styling for sent/received messages
/// - Message status indicators with electrical icons
/// - Reply threading with visual hierarchy
/// - Reaction system with electrical animations
/// - Support for multiple message types (text, image, file, location)
/// - Accessibility support with semantic labels
/// - Touch interactions with haptic feedback
class ElectricalMessageBubble extends StatefulWidget {
  /// Message data to display
  final CrewMessage message;

  /// Whether the message is from the current user
  final bool isFromCurrentUser;

  /// Callback when message is tapped
  final VoidCallback? onTap;

  /// Callback when message is long-pressed
  final VoidCallback? onLongPress;

  /// Callback when a reaction is tapped
  final Function(String emoji)? onReactionTap;

  /// Message display variant
  final MessageBubbleVariant variant;

  /// Whether to show the timestamp
  final bool showTimestamp;

  /// Whether to show message status indicators
  final bool showMessageStatus;

  /// Maximum width of the message bubble
  final double? maxWidth;

  const ElectricalMessageBubble({
    Key? key,
    required this.message,
    required this.isFromCurrentUser,
    this.onTap,
    this.onLongPress,
    this.onReactionTap,
    this.variant = MessageBubbleVariant.standard,
    this.showTimestamp = true,
    this.showMessageStatus = true,
    this.maxWidth,
  }) : super(key: key);

  @override
  State<ElectricalMessageBubble> createState() => _ElectricalMessageBubbleState();
}

class _ElectricalMessageBubbleState extends State<ElectricalMessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _reactionController;
  late Animation<double> _glowAnimation;
  late Animation<double> _reactionAnimation;

  bool _isPressed = false;
  Set<String> _selectedReactions = {};

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
    _initializeReactions();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _reactionController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _glowController = AnimationController(
      duration: AppTheme.durationElectricalGlow,
      vsync: this,
    );

    _reactionController = AnimationController(
      duration: AppTheme.durationElectricalSpark,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _reactionAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _reactionController,
      curve: AppTheme.curveElectricalSpark,
    ));

    // Start subtle glow animation for new messages
    if (widget.isFromCurrentUser) {
      _glowController.repeat(reverse: true);
    }
  }

  void _initializeReactions() {
    if (widget.message.reactions != null) {
      _selectedReactions = Set.from(widget.message.reactions!.keys);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: _getMargin(),
      child: Column(
        crossAxisAlignment: _getCrossAxisAlignment(),
        children: [
          // Reply indicator (if replying to another message)
          if (widget.message.replyToMessageId != null) _buildReplyIndicator(),

          // Main message bubble
          _buildMessageBubble(),

          // Message footer (timestamp and status)
          if (widget.showTimestamp || widget.showMessageStatus) ...[
            const SizedBox(height: AppTheme.spacingXs),
            _buildMessageFooter(),
          ],

          // Reaction bar
          if (_selectedReactions.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingXs),
            _buildReactionBar(),
          ],
        ],
      ),
    );
  }

  /// Builds the main message bubble with electrical theming
  Widget _buildMessageBubble() {
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        widget.onTap?.call();
      },
      onLongPress: () {
        HapticFeedback.mediumImpact();
        widget.onLongPress?.call();
      },
      onTapDown: (_) => setState(() => _isPressed = true),
      onTapUp: (_) => setState(() => _isPressed = false),
      onTapCancel: () => setState(() => _isPressed = false),
      child: AnimatedBuilder(
        animation: _glowAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _isPressed ? 0.98 : 1.0,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: widget.maxWidth ??
                    MediaQuery.of(context).size.width * 0.75,
              ),
              decoration: BoxDecoration(
                gradient: _getMessageGradient(),
                borderRadius: _getBorderRadius(),
                border: Border.all(
                  color: _getBorderColor(),
                  width: _getBorderWidth(),
                ),
                boxShadow: _getBoxShadow(),
              ),
              child: ClipRRect(
                borderRadius: _getBorderRadius(),
                child: Stack(
                  children: [
                    // Circuit pattern background
                    Positioned.fill(
                      child: Opacity(
                        opacity: _getCircuitPatternOpacity(),
                        child: CustomPaint(
                          painter: CircuitPatternPainter(
                            density: ComponentDensity.low,
                            traceColor: _getCircuitTraceColor(),
                            backgroundColor: Colors.transparent,
                          ),
                        ),
                      ),
                    ),

                    // Message content
                    Padding(
                      padding: _getContentPadding(),
                      child: _buildMessageContent(),
                    ),

                    // Electrical glow overlay for new messages
                    if (widget.isFromCurrentUser && _glowAnimation.value > 0.5)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: _getBorderRadius(),
                            border: Border.all(
                              color: AppTheme.electricalGlowInfo
                                  .withValues(alpha: _glowAnimation.value * 0.3),
                              width: 1,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the message content based on type
  Widget _buildMessageContent() {
    switch (widget.message.type) {
      case CrewMessageType.text:
        return _buildTextContent();
      case CrewMessageType.image:
        return _buildImageContent();
      case CrewMessageType.file:
        return _buildFileContent();
      case CrewMessageType.location:
        return _buildLocationContent();
      case CrewMessageType.system:
        return _buildSystemContent();
      default:
        return _buildTextContent();
    }
  }

  /// Builds text message content with proper styling
  Widget _buildTextContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Sender name (for group chats)
        if (!widget.isFromCurrentUser && widget.message.senderName != null) ...[
          Text(
            widget.message.senderName!,
            style: AppTheme.bodySmall.copyWith(
              color: _getSenderNameColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 2),
        ],

        // Message text
        Text(
          widget.message.content,
          style: AppTheme.bodyMedium.copyWith(
            color: _getTextColor(),
            height: 1.4,
          ),
        ),
      ],
    );
  }

  /// Builds image message content
  Widget _buildImageContent() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Image container
        Container(
          width: double.infinity,
          height: 200,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            color: Colors.black.withValues(alpha: 0.1),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            child: widget.message.imageUrl != null
                ? Image.network(
                    widget.message.imageUrl!,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        _buildImagePlaceholder(),
                  )
                : _buildImagePlaceholder(),
          ),
        ),

        // Image caption (if any)
        if (widget.message.content.isNotEmpty) ...[
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            widget.message.content,
            style: AppTheme.bodySmall.copyWith(
              color: _getTextColor(),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds file message content
  Widget _buildFileContent() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: _getFileBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          // File icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: _getFileIconColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Icon(
              _getFileIcon(),
              color: _getFileIconColor(),
              size: AppTheme.iconLg,
            ),
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // File info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.message.fileName ?? 'Unknown File',
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _formatFileSize(),
                  style: AppTheme.bodySmall.copyWith(
                    color: _getSecondaryTextColor(),
                  ),
                ),
              ],
            ),
          ),

          // Download button
          Icon(
            Icons.download,
            color: _getSecondaryTextColor(),
            size: AppTheme.iconSm,
          ),
        ],
      ),
    );
  }

  /// Builds location message content
  Widget _buildLocationContent() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: _getLocationBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
      ),
      child: Row(
        children: [
          // Location icon
          Container(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            decoration: BoxDecoration(
              color: AppTheme.infoBlue.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: const Icon(
              Icons.location_on,
              color: AppTheme.infoBlue,
              size: AppTheme.iconLg,
            ),
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Location info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Location Shared',
                  style: AppTheme.bodyMedium.copyWith(
                    color: _getTextColor(),
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  widget.message.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: _getSecondaryTextColor(),
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Builds system message content
  Widget _buildSystemContent() {
    return Center(
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        decoration: BoxDecoration(
          color: AppTheme.mediumGray.withValues(alpha: 0.2),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        ),
        child: Text(
          widget.message.content,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  /// Builds reply indicator for threaded messages
  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingXs),
      padding: const EdgeInsets.only(left: AppTheme.spacingMd),
      child: Row(
        children: [
          // Reply line
          Container(
            width: 2,
            height: 20,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(1),
            ),
          ),

          const SizedBox(width: AppTheme.spacingSm),

          // Reply text
          Expanded(
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingSm),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                border: Border.all(
                  color: AppTheme.accentCopper.withValues(alpha: 0.3),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.reply,
                    size: 14,
                    color: AppTheme.accentCopper,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Expanded(
                    child: Text(
                      'Replying to message',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.w500,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds message footer with timestamp and status
  Widget _buildMessageFooter() {
    return Row(
      mainAxisAlignment: widget.isFromCurrentUser
          ? MainAxisAlignment.end
          : MainAxisAlignment.start,
      children: [
        // Timestamp
        Text(
          _formatTimestamp(),
          style: AppTheme.bodySmall.copyWith(
            color: _getSecondaryTextColor(),
            fontSize: 10,
          ),
        ),

        // Message status (only for sent messages)
        if (widget.isFromCurrentUser && widget.showMessageStatus) ...[
          const SizedBox(width: AppTheme.spacingXs),
          _buildMessageStatusIndicator(),
        ],
      ],
    );
  }

  /// Builds message status indicator with electrical icons
  Widget _buildMessageStatusIndicator() {
    IconData statusIcon;
    Color statusColor;

    switch (widget.message.status) {
      case MessageStatus.sending:
        statusIcon = Icons.schedule;
        statusColor = AppTheme.textMuted;
        break;
      case MessageStatus.sent:
        statusIcon = Icons.check;
        statusColor = AppTheme.textMuted;
        break;
      case MessageStatus.delivered:
        statusIcon = Icons.done_all;
        statusColor = AppTheme.textMuted;
        break;
      case MessageStatus.read:
        statusIcon = Icons.done_all;
        statusColor = AppTheme.infoBlue;
        break;
      case MessageStatus.failed:
        statusIcon = Icons.error;
        statusColor = AppTheme.errorRed;
        break;
      default:
        statusIcon = Icons.check;
        statusColor = AppTheme.textMuted;
    }

    return Icon(
      statusIcon,
      size: 14,
      color: statusColor,
    );
  }

  /// Builds reaction bar with electrical animations
  Widget _buildReactionBar() {
    return AnimatedBuilder(
      animation: _reactionAnimation,
      builder: (context, child) {
        return Transform.scale(
          scale: 1.0 + (_reactionAnimation.value * 0.1),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _getReactionBackgroundColor(),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              border: Border.all(
                color: _getReactionBorderColor(),
                width: 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: _selectedReactions.map((emoji) {
                final count = widget.message.reactions?[emoji] ?? 0;
                return _buildReactionChip(emoji, count);
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  /// Builds individual reaction chip
  Widget _buildReactionChip(String emoji, int count) {
    return GestureDetector(
      onTap: () {
        _reactionController.forward().then((_) {
          _reactionController.reverse();
        });
        widget.onReactionTap?.call(emoji);
      },
      child: Container(
        margin: const EdgeInsets.only(right: AppTheme.spacingXs),
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingXs,
          vertical: 2,
        ),
        decoration: BoxDecoration(
          color: _getReactionChipColor(emoji),
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              emoji,
              style: const TextStyle(fontSize: 12),
            ),
            if (count > 1) ...[
              const SizedBox(width: 2),
              Text(
                count.toString(),
                style: AppTheme.bodySmall.copyWith(
                  color: _getReactionTextColor(),
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }

  // Helper methods for styling and data

  EdgeInsets _getMargin() {
    switch (widget.variant) {
      case MessageBubbleVariant.compact:
        return const EdgeInsets.symmetric(vertical: 1, horizontal: AppTheme.spacingSm);
      default:
        return const EdgeInsets.symmetric(vertical: 4, horizontal: AppTheme.spacingSm);
    }
  }

  CrossAxisAlignment _getCrossAxisAlignment() {
    return widget.isFromCurrentUser
        ? CrossAxisAlignment.end
        : CrossAxisAlignment.start;
  }

  LinearGradient _getMessageGradient() {
    if (widget.isFromCurrentUser) {
      return AppTheme.electricalGradient;
    } else {
      return LinearGradient(
        colors: [
          AppTheme.secondaryNavy,
          AppTheme.darkSurface,
        ],
      );
    }
  }

  BorderRadius _getBorderRadius() {
    final isCurrentUser = widget.isFromCurrentUser;
    return BorderRadius.only(
      topLeft: const Radius.circular(AppTheme.radiusLg),
      topRight: const Radius.circular(AppTheme.radiusLg),
      bottomLeft: Radius.circular(isCurrentUser ? AppTheme.radiusLg : AppTheme.radiusSm),
      bottomRight: Radius.circular(isCurrentUser ? AppTheme.radiusSm : AppTheme.radiusLg),
    );
  }

  Color _getBorderColor() {
    if (widget.isFromCurrentUser) {
      return AppTheme.accentCopper.withValues(alpha: 0.3);
    } else {
      return AppTheme.borderLight;
    }
  }

  double _getBorderWidth() {
    return widget.variant == MessageBubbleVariant.featured ? 1.5 : 1.0;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.variant == MessageBubbleVariant.featured) {
      return [
        BoxShadow(
          color: widget.isFromCurrentUser
              ? AppTheme.electricalGlowInfo.withValues(alpha: 0.2)
              : Colors.black.withValues(alpha: 0.1),
          blurRadius: 8,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return [
      BoxShadow(
        color: Colors.black.withValues(alpha: 0.05),
        blurRadius: 4,
        offset: const Offset(0, 1),
      ),
    ];
  }

  double _getCircuitPatternOpacity() {
    return widget.isFromCurrentUser ? 0.15 : 0.08;
  }

  Color _getCircuitTraceColor() {
    return widget.isFromCurrentUser
        ? AppTheme.electricalCircuitTrace
        : AppTheme.electricalCircuitTraceLight;
  }

  EdgeInsets _getContentPadding() {
    switch (widget.variant) {
      case MessageBubbleVariant.compact:
        return const EdgeInsets.all(AppTheme.spacingSm);
      default:
        return const EdgeInsets.all(AppTheme.spacingMd);
    }
  }

  Color _getTextColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white
        : AppTheme.white;
  }

  Color _getSecondaryTextColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white.withValues(alpha: 0.7)
        : AppTheme.white.withValues(alpha: 0.6);
  }

  Color _getSenderNameColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white.withValues(alpha: 0.8)
        : AppTheme.accentCopper;
  }

  Color _getFileBackgroundColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white.withValues(alpha: 0.1)
        : AppTheme.black.withValues(alpha: 0.1);
  }

  Color _getFileIconColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white
        : AppTheme.accentCopper;
  }

  IconData _getFileIcon() {
    final fileName = widget.message.fileName?.toLowerCase() ?? '';
    if (fileName.endsWith('.pdf')) return Icons.picture_as_pdf;
    if (fileName.endsWith('.doc') || fileName.endsWith('.docx')) return Icons.description;
    if (fileName.endsWith('.xls') || fileName.endsWith('.xlsx')) return Icons.table_chart;
    if (fileName.endsWith('.jpg') || fileName.endsWith('.png')) return Icons.image;
    if (fileName.endsWith('.zip') || fileName.endsWith('.rar')) return Icons.archive;
    return Icons.insert_drive_file;
  }

  String _formatFileSize() {
    final size = widget.message.fileSize ?? 0;
    if (size < 1024) return '$size B';
    if (size < 1024 * 1024) return '${(size / 1024).toStringAsFixed(1)} KB';
    return '${(size / (1024 * 1024)).toStringAsFixed(1)} MB';
  }

  Color _getLocationBackgroundColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white.withValues(alpha: 0.1)
        : AppTheme.infoBlue.withValues(alpha: 0.1);
  }

  Color _getReactionBackgroundColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white.withValues(alpha: 0.1)
        : AppTheme.black.withValues(alpha: 0.1);
  }

  Color _getReactionBorderColor() {
    return AppTheme.accentCopper.withValues(alpha: 0.3);
  }

  Color _getReactionChipColor(String emoji) {
    final hasReacted = widget.message.userReactions?.contains(emoji) ?? false;
    return hasReacted
        ? AppTheme.accentCopper.withValues(alpha: 0.3)
        : Colors.transparent;
  }

  Color _getReactionTextColor() {
    return widget.isFromCurrentUser
        ? AppTheme.white
        : AppTheme.accentCopper;
  }

  Widget _buildImagePlaceholder() {
    return Container(
      color: AppTheme.mediumGray.withValues(alpha: 0.3),
      child: const Center(
        child: Icon(
          Icons.broken_image,
          color: AppTheme.textMuted,
          size: AppTheme.iconXl,
        ),
      ),
    );
  }

  String _formatTimestamp() {
    final now = DateTime.now();
    final messageTime = widget.message.createdAt.toDate();
    final difference = now.difference(messageTime);

    if (difference.inMinutes < 1) return 'now';
    if (difference.inHours < 1) return '${difference.inMinutes}m';
    if (difference.inDays < 1) return '${difference.inHours}h';
    if (difference.inDays < 7) return '${difference.inDays}d';

    return '${messageTime.hour.toString().padLeft(2, '0')}:${messageTime.minute.toString().padLeft(2, '0')}';
  }
}

/// Enum defining message bubble display variants
enum MessageBubbleVariant {
  /// Standard message bubble with full features
  standard,

  /// Compact version for tight spaces
  compact,

  /// Featured version with enhanced styling
  featured,
}