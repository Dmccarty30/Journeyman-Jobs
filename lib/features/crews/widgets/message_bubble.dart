import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../models/crew_communication.dart';
import '../models/crew_enums.dart';
import '../models/message_attachment.dart';
import '../../../design_system/app_theme.dart';

/// Message bubble widget for IBEW electrical worker crew communications
///
/// Features electrical worker-specific functionality including safety alerts,
/// job site communication, emergency messaging, and professional UI styling
/// for union electrical workers.
class MessageBubble extends StatefulWidget {
  /// The message data to display
  final CrewCommunication message;

  /// Whether this message was sent by the current user
  final bool isCurrentUser;

  /// Callback when the bubble is tapped
  final VoidCallback? onTap;

  /// Callback when the bubble is long pressed
  final VoidCallback? onLongPress;

  /// Callback when a reaction is added to the message
  final Function(String reaction)? onReaction;

  /// Callback when replying to this message
  final VoidCallback? onReply;

  /// Whether to show the user avatar
  final bool showAvatar;

  /// Whether to show the timestamp
  final bool showTimestamp;

  /// Whether to show sender name (for group chats)
  final bool showSenderName;

  /// Current user ID for read receipt logic
  final String? currentUserId;

  /// Whether this is a system message
  final bool isSystemMessage;

  /// Whether to enable swipe-to-reply gesture
  final bool enableSwipeToReply;

  const MessageBubble({
    super.key,
    required this.message,
    required this.isCurrentUser,
    this.onTap,
    this.onLongPress,
    this.onReaction,
    this.onReply,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.showSenderName = false,
    this.currentUserId,
    this.isSystemMessage = false,
    this.enableSwipeToReply = true,
  });

  @override
  State<MessageBubble> createState() => _MessageBubbleState();
}

class _MessageBubbleState extends State<MessageBubble>
    with TickerProviderStateMixin {
  late AnimationController _slideController;
  late AnimationController _scaleController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  bool _isPressed = false;
  bool _isSwipeActive = false;

  @override
  void initState() {
    super.initState();
    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-0.2, 0.0),
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOut,
    ));
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _slideController.dispose();
    _scaleController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        widget.onTap?.call();
        _triggerHapticFeedback();
      },
      onLongPress: () {
        widget.onLongPress?.call();
        _triggerHapticFeedback(HapticFeedback.mediumImpact);
        _showMessageActions(context);
      },
      onTapDown: (_) => _handleTapDown(),
      onTapUp: (_) => _handleTapUp(),
      onTapCancel: _handleTapUp,
      onPanStart: widget.enableSwipeToReply ? _handlePanStart : null,
      onPanUpdate: widget.enableSwipeToReply ? _handlePanUpdate : null,
      onPanEnd: widget.enableSwipeToReply ? _handlePanEnd : null,
      child: AnimatedBuilder(
        animation: Listenable.merge([_slideAnimation, _scaleAnimation]),
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Transform.translate(
              offset: _slideAnimation.value * 
                     MediaQuery.of(context).size.width,
              child: _buildMessageContent(),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageContent() {
    if (widget.isSystemMessage || widget.message.type == MessageType.system) {
      return _buildSystemMessage();
    }

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      child: Row(
        mainAxisAlignment: widget.isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!widget.isCurrentUser && widget.showAvatar) ...[
            _buildAvatar(),
            const SizedBox(width: AppTheme.spacingSm),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: widget.isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (widget.showSenderName && !widget.isCurrentUser)
                  _buildSenderInfo(),
                _buildMessageBubble(),
                if (widget.showTimestamp) _buildTimestamp(),
              ],
            ),
          ),
          if (widget.isCurrentUser && widget.showAvatar) ...[
            const SizedBox(width: AppTheme.spacingSm),
            _buildAvatar(),
          ],
        ],
      ),
    );
  }

  Widget _buildSystemMessage() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          decoration: BoxDecoration(
            color: AppTheme.lightGray.withValues(alpha: 0.3),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(
              color: AppTheme.primaryNavy.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getSystemMessageIcon(),
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Flexible(
                child: Text(
                  widget.message.content,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAvatar() {
    return CircleAvatar(
      radius: 16,
      backgroundColor: widget.isCurrentUser
          ? AppTheme.accentCopper
          : AppTheme.primaryNavy,
      child: Text(
        _getInitials(),
        style: AppTheme.labelMedium.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildSenderInfo() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingSm,
        bottom: AppTheme.spacingXs,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            widget.message.senderName ?? 'Unknown',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w600,
            ),
          ),
          if (widget.message.senderRole != null) ...[
            const SizedBox(width: AppTheme.spacingXs),
            _buildRoleBadge(widget.message.senderRole!),
          ],
        ],
      ),
    );
  }

  Widget _buildRoleBadge(String role) {
    final roleColor = _getRoleColor(role);
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: 6,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: roleColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: roleColor.withValues(alpha: 0.3),
          width: 0.5,
        ),
      ),
      child: Text(
        role.toUpperCase(),
        style: AppTheme.labelSmall.copyWith(
          color: roleColor,
          fontSize: 9,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _buildMessageBubble() {
    final isEmergency = _isEmergencyMessage();
    final isSafety = _isSafetyMessage();
    
    return Container(
      constraints: BoxConstraints(
        maxWidth: MediaQuery.of(context).size.width * 0.75,
      ),
      decoration: BoxDecoration(
        gradient: _getMessageGradient(),
        borderRadius: _getBubbleRadius(),
        border: (isEmergency || isSafety) ? Border.all(
          color: isEmergency ? AppTheme.errorRed : AppTheme.warningOrange,
          width: 2,
        ) : null,
        boxShadow: [
          BoxShadow(
            color: AppTheme.shadowColor.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (isEmergency || isSafety) _buildAlertHeader(),
          _buildMessageContent(),
          if (widget.message.attachments.isNotEmpty) _buildAttachments(),
          if (widget.message.replyToMessageId != null) _buildReplyIndicator(),
          _buildMessageFooter(),
        ],
      ),
    );
  }

  Widget _buildAlertHeader() {
    final isEmergency = _isEmergencyMessage();
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isEmergency 
            ? AppTheme.errorRed.withValues(alpha: 0.1)
            : AppTheme.warningOrange.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(18),
          topRight: Radius.circular(18),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isEmergency ? Icons.emergency : Icons.warning,
            size: 16,
            color: isEmergency ? AppTheme.errorRed : AppTheme.warningOrange,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            isEmergency ? 'EMERGENCY' : 'SAFETY ALERT',
            style: AppTheme.labelSmall.copyWith(
              color: isEmergency ? AppTheme.errorRed : AppTheme.warningOrange,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageContent() {
    return Padding(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildMessageText(),
          if (widget.message.isEdited) _buildEditedIndicator(),
        ],
      ),
    );
  }

  Widget _buildMessageText() {
    return SelectableText(
      widget.message.content,
      style: AppTheme.bodyMedium.copyWith(
        color: widget.isCurrentUser ? AppTheme.white : AppTheme.textPrimary,
        height: 1.4,
      ),
    );
  }

  Widget _buildEditedIndicator() {
    return Padding(
      padding: const EdgeInsets.only(top: AppTheme.spacingXs),
      child: Text(
        'edited',
        style: AppTheme.labelSmall.copyWith(
          color: widget.isCurrentUser 
              ? AppTheme.white.withValues(alpha: 0.7)
              : AppTheme.textSecondary,
          fontStyle: FontStyle.italic,
        ),
      ),
    );
  }

  Widget _buildAttachments() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        bottom: AppTheme.spacingSm,
      ),
      child: Column(
        children: widget.message.attachments.map((attachment) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
            child: _buildAttachment(attachment),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildAttachment(MessageAttachment attachment) {
    // Handle location sharing through message type or filename
    if (attachment.fileName.toLowerCase().contains('location') || 
        attachment.description?.toLowerCase().contains('location') == true) {
      return _buildLocationAttachment(attachment);
    }

    switch (attachment.type) {
      case AttachmentType.image:
        return _buildImageAttachment(attachment);
      case AttachmentType.document:
      case AttachmentType.workOrder:
      case AttachmentType.safetyDoc:
      case AttachmentType.jobSpec:
      case AttachmentType.manual:
      case AttachmentType.codeDoc:
      case AttachmentType.inspectionReport:
      case AttachmentType.timeSheet:
        return _buildDocumentAttachment(attachment);
      case AttachmentType.schematic:
        return _buildSchematicAttachment(attachment);
      default:
        return _buildGenericAttachment(attachment);
    }
  }

  Widget _buildImageAttachment(MessageAttachment attachment) {
    return Container(
      constraints: const BoxConstraints(
        maxHeight: 200,
        maxWidth: double.infinity,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          attachment.thumbnailUrl ?? attachment.url,
          fit: BoxFit.cover,
          loadingBuilder: (context, child, loadingProgress) {
            if (loadingProgress == null) return child;
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(
                  widget.isCurrentUser ? AppTheme.white : AppTheme.primaryNavy,
                ),
              ),
            );
          },
          errorBuilder: (context, error, stackTrace) {
            return Container(
              height: 100,
              alignment: Alignment.center,
              child: Icon(
                Icons.image_not_supported,
                color: widget.isCurrentUser 
                    ? AppTheme.white.withValues(alpha: 0.7)
                    : AppTheme.textSecondary,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isCurrentUser 
            ? AppTheme.white.withValues(alpha: 0.1)
            : AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            _getFileIcon(attachment.fileName),
            color: widget.isCurrentUser ? AppTheme.white : AppTheme.primaryNavy,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: AppTheme.bodySmall.copyWith(
                    color: widget.isCurrentUser 
                        ? AppTheme.white 
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  _formatFileSize(attachment.sizeBytes),
                  style: AppTheme.labelSmall.copyWith(
                    color: widget.isCurrentUser 
                        ? AppTheme.white.withValues(alpha: 0.7)
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.download,
            color: widget.isCurrentUser 
                ? AppTheme.white.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isCurrentUser 
            ? AppTheme.white.withValues(alpha: 0.1)
            : AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.location_on,
            color: AppTheme.errorRed,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Job Site Location',
                  style: AppTheme.bodySmall.copyWith(
                    color: widget.isCurrentUser 
                        ? AppTheme.white 
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                if (attachment.description != null)
                  Text(
                    attachment.description!,
                    style: AppTheme.labelSmall.copyWith(
                      color: widget.isCurrentUser 
                          ? AppTheme.white.withValues(alpha: 0.7)
                          : AppTheme.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: widget.isCurrentUser 
                ? AppTheme.white.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildSchematicAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isCurrentUser 
            ? AppTheme.white.withValues(alpha: 0.1)
            : AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.electrical_services,
            color: AppTheme.accentCopper,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  attachment.fileName,
                  style: AppTheme.bodySmall.copyWith(
                    color: widget.isCurrentUser 
                        ? AppTheme.white 
                        : AppTheme.textPrimary,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  'Electrical Schematic - ${_formatFileSize(attachment.sizeBytes)}',
                  style: AppTheme.labelSmall.copyWith(
                    color: widget.isCurrentUser 
                        ? AppTheme.white.withValues(alpha: 0.7)
                        : AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.open_in_new,
            color: widget.isCurrentUser 
                ? AppTheme.white.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
            size: 20,
          ),
        ],
      ),
    );
  }

  Widget _buildGenericAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isCurrentUser 
            ? AppTheme.white.withValues(alpha: 0.1)
            : AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppTheme.lightGray.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.attach_file,
            color: widget.isCurrentUser ? AppTheme.white : AppTheme.primaryNavy,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              attachment.fileName,
              style: AppTheme.bodySmall.copyWith(
                color: widget.isCurrentUser 
                    ? AppTheme.white 
                    : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        bottom: AppTheme.spacingSm,
      ),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: widget.isCurrentUser 
            ? AppTheme.white.withValues(alpha: 0.1)
            : AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(6),
        border: Border(
          left: BorderSide(
            color: widget.isCurrentUser ? AppTheme.white : AppTheme.primaryNavy,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: widget.isCurrentUser 
                ? AppTheme.white.withValues(alpha: 0.7)
                : AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            'Replying to message',
            style: AppTheme.labelSmall.copyWith(
              color: widget.isCurrentUser 
                  ? AppTheme.white.withValues(alpha: 0.7)
                  : AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageFooter() {
    return Padding(
      padding: const EdgeInsets.only(
        left: AppTheme.spacingMd,
        right: AppTheme.spacingMd,
        bottom: AppTheme.spacingSm,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.message.isPinned) ...[
            Icon(
              Icons.push_pin,
              size: 12,
              color: widget.isCurrentUser 
                  ? AppTheme.white.withValues(alpha: 0.7)
                  : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingXs),
          ],
          if (widget.isCurrentUser) _buildMessageStatus(),
        ],
      ),
    );
  }

  Widget _buildMessageStatus() {
    final readCount = widget.message.readBy.length;
    final hasBeenRead = readCount > 1; // More than just the sender

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          hasBeenRead ? Icons.done_all : Icons.done,
          size: 14,
          color: hasBeenRead 
              ? AppTheme.successGreen 
              : AppTheme.white.withValues(alpha: 0.7),
        ),
        if (readCount > 2) ...[
          const SizedBox(width: AppTheme.spacingXxs),
          Text(
            '$readCount',
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.white.withValues(alpha: 0.7),
              fontSize: 10,
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildTimestamp() {
    return Padding(
      padding: EdgeInsets.only(
        top: AppTheme.spacingXs,
        left: widget.isCurrentUser ? 0 : AppTheme.spacingSm,
        right: widget.isCurrentUser ? AppTheme.spacingSm : 0,
      ),
      child: Text(
        _formatTimestamp(widget.message.timestamp),
        style: AppTheme.labelSmall.copyWith(
          color: AppTheme.textSecondary,
          fontSize: 11,
        ),
      ),
    );
  }

  // Helper Methods

  void _handleTapDown() {
    setState(() => _isPressed = true);
    _scaleController.forward();
  }

  void _handleTapUp() {
    setState(() => _isPressed = false);
    _scaleController.reverse();
  }

  void _handlePanStart(DragStartDetails details) {
    if (!widget.isCurrentUser) {
      setState(() => _isSwipeActive = true);
    }
  }

  void _handlePanUpdate(DragUpdateDetails details) {
    if (_isSwipeActive && details.delta.dx < 0) {
      final progress = (-details.delta.dx / 100).clamp(0.0, 1.0);
      _slideController.value = progress;
    }
  }

  void _handlePanEnd(DragEndDetails details) {
    if (_isSwipeActive) {
      if (_slideController.value > 0.3) {
        widget.onReply?.call();
        _triggerHapticFeedback();
      }
      _slideController.reverse();
      setState(() => _isSwipeActive = false);
    }
  }

  void _triggerHapticFeedback([Function? customFeedback]) {
    if (customFeedback != null) {
      customFeedback();
    } else {
      HapticFeedback.lightImpact();
    }
  }

  void _showMessageActions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => _buildMessageActionsSheet(),
    );
  }

  Widget _buildMessageActionsSheet() {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionTile(
            icon: Icons.reply,
            title: 'Reply',
            onTap: () {
              Navigator.pop(context);
              widget.onReply?.call();
            },
          ),
          _buildActionTile(
            icon: Icons.copy,
            title: 'Copy',
            onTap: () {
              Navigator.pop(context);
              Clipboard.setData(ClipboardData(text: widget.message.content));
            },
          ),
          if (widget.message.attachments.isNotEmpty)
            _buildActionTile(
              icon: Icons.download,
              title: 'Save Attachments',
              onTap: () {
                Navigator.pop(context);
                // Handle attachment save
              },
            ),
          _buildActionTile(
            icon: Icons.add_reaction_outlined,
            title: 'Add Reaction',
            onTap: () {
              Navigator.pop(context);
              _showReactionPicker();
            },
          ),
          if (_isEmergencyMessage())
            _buildActionTile(
              icon: Icons.check_circle,
              title: 'Acknowledge Emergency',
              onTap: () {
                Navigator.pop(context);
                // Handle emergency acknowledgment
              },
              textColor: AppTheme.successGreen,
            ),
        ],
      ),
    );
  }

  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? textColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: textColor ?? AppTheme.primaryNavy),
      title: Text(
        title,
        style: AppTheme.bodyMedium.copyWith(
          color: textColor ?? AppTheme.textPrimary,
        ),
      ),
      onTap: onTap,
    );
  }

  void _showReactionPicker() {
    // Implement reaction picker logic
    final reactions = ['👍', '❤️', '😂', '😮', '😢', '⚡', '🔧', '⚠️'];
    // Show reaction picker dialog
  }

  // Utility Methods

  bool _isEmergencyMessage() {
    return widget.message.type == MessageType.emergency;
  }

  bool _isSafetyMessage() {
    return widget.message.type == MessageType.safetyAlert ||
           widget.message.type == MessageType.weatherAlert;
  }

  String _getInitials() {
    final name = widget.message.senderName ?? 'U';
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Color _getRoleColor(String role) {
    switch (role.toLowerCase()) {
      case 'foreman':
        return AppTheme.accentCopper;
      case 'safety coordinator':
        return AppTheme.warningOrange;
      case 'lead journeyman':
        return AppTheme.primaryNavy;
      default:
        return AppTheme.mediumGray;
    }
  }

  LinearGradient _getMessageGradient() {
    if (_isEmergencyMessage()) {
      return LinearGradient(
        colors: [
          AppTheme.errorRed,
          AppTheme.errorRed.withValues(alpha: 0.8),
        ],
      );
    }

    if (widget.isCurrentUser) {
      return const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          AppTheme.accentCopper,
          AppTheme.secondaryCopper,
        ],
      );
    }

    return const LinearGradient(
      colors: [
        AppTheme.white,
        AppTheme.offWhite,
      ],
    );
  }

  BorderRadius _getBubbleRadius() {
    const radius = 18.0;
    final isEmergency = _isEmergencyMessage();
    final isSafety = _isSafetyMessage();

    if (isEmergency || isSafety) {
      return BorderRadius.circular(radius);
    }

    if (widget.isCurrentUser) {
      return const BorderRadius.only(
        topLeft: Radius.circular(radius),
        topRight: Radius.circular(4),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    } else {
      return const BorderRadius.only(
        topLeft: Radius.circular(4),
        topRight: Radius.circular(radius),
        bottomLeft: Radius.circular(radius),
        bottomRight: Radius.circular(radius),
      );
    }
  }

  IconData _getSystemMessageIcon() {
    switch (widget.message.type) {
      case MessageType.jobUpdate:
        return Icons.work;
      case MessageType.scheduleChange:
        return Icons.schedule;
      case MessageType.safetyAlert:
        return Icons.warning;
      case MessageType.emergency:
        return Icons.emergency;
      case MessageType.weatherAlert:
        return Icons.cloud;
      default:
        return Icons.info;
    }
  }

  IconData _getFileIcon(String fileName) {
    final extension = fileName.split('.').last.toLowerCase();
    switch (extension) {
      case 'pdf':
        return Icons.picture_as_pdf;
      case 'doc':
      case 'docx':
        return Icons.description;
      case 'xls':
      case 'xlsx':
        return Icons.table_chart;
      case 'jpg':
      case 'jpeg':
      case 'png':
      case 'gif':
        return Icons.image;
      default:
        return Icons.insert_drive_file;
    }
  }

  String _formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
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
    } else if (difference.inDays == 1) {
      return 'Yesterday ${DateFormat('HH:mm').format(timestamp)}';
    } else {
      return DateFormat('MMM d, HH:mm').format(timestamp);
    }
  }
}
