import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../models/chat_message.dart';
import '../widgets/realtime_presence_indicators.dart';

/// Enhanced message bubble widget with read receipts, reactions,
/// and improved visual design for crew chat.
class EnhancedMessageBubble extends ConsumerStatefulWidget {
  final ChatMessage message;
  final bool isMe;
  final bool showAvatar;
  final bool showTimestamp;
  final VoidCallback? onReply;
  final VoidCallback? onReact;

  const EnhancedMessageBubble({
    Key? key,
    required this.message,
    required this.isMe,
    this.showAvatar = true,
    this.showTimestamp = true,
    this.onReply,
    this.onReact,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedMessageBubble> createState() => _EnhancedMessageBubbleState();
}

class _EnhancedMessageBubbleState extends ConsumerState<EnhancedMessageBubble>
    with TickerProviderStateMixin {
  bool _showActions = false;
  late AnimationController _bounceController;
  late AnimationController _slideController;
  late Animation<double> _bounceAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
  }

  void _setupAnimations() {
    _bounceController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );

    _bounceAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _bounceController,
      curve: Curves.elasticOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.2),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));

    // Trigger animations when widget is built
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _bounceController.forward();
    });
  }

  @override
  void dispose() {
    _bounceController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _toggleActions() {
    setState(() {
      _showActions = !_showActions;
    });

    if (_showActions) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      child: Column(
        crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              if (!widget.isMe && widget.showAvatar) ...[
                _buildSenderAvatar(),
                const SizedBox(width: 8),
              ],
              Expanded(
                child: Column(
                  crossAxisAlignment: widget.isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                  children: [
                    if (!widget.isMe && widget.showAvatar)
                      _buildSenderName(),
                    _buildMessageBubble(),
                    if (widget.showTimestamp)
                      _buildMessageInfo(),
                  ],
                ),
              ),
              if (widget.isMe && widget.showAvatar) ...[
                const SizedBox(width: 8),
                _buildReadReceipt(),
              ],
            ],
          ),
          if (_showActions)
            SlideTransition(
              position: _slideAnimation,
              child: _buildMessageActions(),
            ),
        ],
      ),
    );
  }

  Widget _buildSenderAvatar() {
    return Consumer(
      builder: (context, ref, child) {
        final userAsync = ref.watch(userStreamProvider(widget.message.senderId));
        
        return userAsync.when(
          data: (user) => CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
            backgroundImage: user.photoUrl != null 
                ? NetworkImage(user.photoUrl!)
                : null,
            child: user.photoUrl == null
                ? Text(
                    user.displayName.isNotEmpty
                        ? user.displayName[0].toUpperCase()
                        : 'U',
                    style: TextStyle(
                      color: AppTheme.accentCopper,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  )
                : null,
          ),
          loading: () => CircleAvatar(
            radius: 16,
            backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
            child: const CircularProgressIndicator(
              strokeWidth: 2,
              valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
            ),
          ),
          error: (error, stack) => CircleAvatar(
            radius: 16,
            backgroundColor: Colors.red.withOpacity(0.2),
            child: const Icon(
              Icons.error_outline,
              color: Colors.red,
              size: 16,
            ),
          ),
        );
      },
    );
  }

  Widget _buildSenderName() {
    return Consumer(
      builder: (context, ref, child) {
        final userAsync = ref.watch(userStreamProvider(widget.message.senderId));
        
        return userAsync.when(
          data: (user) => Padding(
            padding: const EdgeInsets.only(bottom: 4),
            child: Row(
              children: [
                Text(
                  user.displayName,
                  style: AppTheme.caption.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(width: 4),
                RealtimePresenceIndicators(
                  userId: widget.message.senderId,
                  size: 8,
                ),
              ],
            ),
          ),
          loading: () => const SizedBox.shrink(),
          error: (error, stack) => const SizedBox.shrink(),
        );
      },
    );
  }

  Widget _buildMessageBubble() {
    return GestureDetector(
      onLongPress: _toggleActions,
      child: AnimatedBuilder(
        animation: _bounceAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _bounceAnimation.value,
            child: Container(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.of(context).size.width * 0.75,
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                gradient: widget.isMe
                    ? LinearGradient(
                        colors: [
                          AppTheme.accentCopper,
                          AppTheme.accentCopper.withOpacity(0.8),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      )
                    : LinearGradient(
                        colors: [
                          Colors.white.withOpacity(0.1),
                          Colors.white.withOpacity(0.05),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                borderRadius: BorderRadius.only(
                  topLeft: const Radius.circular(20),
                  topRight: const Radius.circular(20),
                  bottomLeft: widget.isMe ? const Radius.circular(20) : const Radius.circular(4),
                  bottomRight: widget.isMe ? const Radius.circular(4) : const Radius.circular(20),
                ),
                border: Border.all(
                  color: widget.isMe
                      ? AppTheme.accentCopper.withOpacity(0.5)
                      : Colors.white.withOpacity(0.2),
                ),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Message text
                  Text(
                    widget.message.text,
                    style: AppTheme.bodyText.copyWith(
                      color: widget.isMe ? Colors.white : Colors.white,
                      fontSize: 16,
                    ),
                  ),
                  
                  // Message attachments (if any)
                  if (widget.message.attachments != null && 
                      widget.message.attachments!.isNotEmpty)
                    _buildMessageAttachments(),
                  
                  // Message reactions
                  if (widget.message.reactions != null && 
                      widget.message.reactions!.isNotEmpty)
                    _buildMessageReactions(),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildMessageAttachments() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 8,
        runSpacing: 8,
        children: widget.message.attachments!.map((attachment) {
          return _buildAttachmentItem(attachment);
        }).toList(),
      ),
    );
  }

  Widget _buildAttachmentItem(MessageAttachment attachment) {
    switch (attachment.type) {
      case AttachmentType.image:
        return _buildImageAttachment(attachment);
      case AttachmentType.document:
        return _buildDocumentAttachment(attachment);
      case AttachmentType.location:
        return _buildLocationAttachment(attachment);
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildImageAttachment(MessageAttachment attachment) {
    return Container(
      width: 100,
      height: 100,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: Colors.white.withOpacity(0.1),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(8),
        child: Image.network(
          attachment.url,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stack) {
            return Container(
              color: Colors.white.withOpacity(0.1),
              child: const Icon(
                Icons.broken_image,
                color: Colors.white,
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildDocumentAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.description,
            color: AppTheme.accentCopper,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            attachment.name ?? 'Document',
            style: AppTheme.caption.copyWith(
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildLocationAttachment(MessageAttachment attachment) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.location_on,
            color: AppTheme.accentCopper,
            size: 20,
          ),
          const SizedBox(width: 8),
          Text(
            attachment.name ?? 'Location',
            style: AppTheme.caption.copyWith(
              color: Colors.white,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildMessageReactions() {
    final reactions = widget.message.reactions!;
    
    return Container(
      margin: const EdgeInsets.only(top: 8),
      child: Wrap(
        spacing: 4,
        runSpacing: 4,
        children: reactions.entries.map((entry) {
          return _buildReactionItem(entry.key, entry.value);
        }).toList(),
      ),
    );
  }

  Widget _buildReactionItem(String emoji, List<String> userIds) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            emoji,
            style: const TextStyle(fontSize: 16),
          ),
          if (userIds.length > 1) ...[
            const SizedBox(width: 4),
            Text(
              '${userIds.length}',
              style: AppTheme.caption.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildMessageInfo() {
    return Padding(
      padding: const EdgeInsets.only(top: 4),
      child: Row(
        mainAxisAlignment: widget.isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Text(
            _formatTimestamp(widget.message.timestamp),
            style: AppTheme.caption.copyWith(
              color: Colors.white.withOpacity(0.5),
              fontSize: 10,
            ),
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 4),
            _buildReadStatusIcon(),
          ],
        ],
      ),
    );
  }

  Widget _buildReadReceipt() {
    return Consumer(
      builder: (context, ref, child) {
        return CircleAvatar(
          radius: 8,
          backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
          child: Icon(
            _getReadStatusIcon(),
            color: AppTheme.accentCopper,
            size: 12,
          ),
        );
      },
    );
  }

  Widget _buildReadStatusIcon() {
    if (widget.message.isRead) {
      return const Icon(
        Icons.done_all,
        size: 12,
        color: AppTheme.accentCopper,
      );
    } else {
      return const Icon(
        Icons.done,
        size: 12,
        color: Colors.white,
      );
    }
  }

  IconData _getReadStatusIcon() {
    if (widget.message.isRead) {
      return Icons.done_all;
    } else {
      return Icons.done;
    }
  }

  Widget _buildMessageActions() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.accentCopper.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildActionButton(
            icon: Icons.reply,
            label: 'Reply',
            onTap: widget.onReply,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.emoji_emotions_outlined,
            label: 'React',
            onTap: widget.onReact,
          ),
          const SizedBox(width: 16),
          _buildActionButton(
            icon: Icons.copy,
            label: 'Copy',
            onTap: _copyMessage,
          ),
          if (widget.isMe) ...[
            const SizedBox(width: 16),
            _buildActionButton(
              icon: Icons.delete,
              label: 'Delete',
              onTap: _deleteMessage,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildActionButton({
    required IconData icon,
    required String label,
    required VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(8),
      child: Padding(
        padding: const EdgeInsets.all(8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.accentCopper,
              size: 20,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: AppTheme.caption.copyWith(
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _copyMessage() {
    // Copy message text to clipboard
    // Clipboard.setData(ClipboardData(text: widget.message.text));
    
    // Show toast notification
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Message copied'),
        backgroundColor: AppTheme.accentCopper,
      ),
    );
  }

  void _deleteMessage() {
    // Show confirmation dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete Message'),
        content: const Text('Are you sure you want to delete this message?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Delete message logic here
            },
            child: const Text(
              'Delete',
              style: TextStyle(color: Colors.red),
            ),
          ),
        ],
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inMinutes < 1) {
      return 'just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}:${timestamp.minute.toString().padLeft(2, '0')}';
    } else {
      return '${timestamp.month}/${timestamp.day}';
    }
  }
}

// Models for message attachments and reactions
enum AttachmentType {
  image,
  document,
  location,
}

class MessageAttachment {
  final String url;
  final String? name;
  final AttachmentType type;
  final Map<String, dynamic>? metadata;

  MessageAttachment({
    required this.url,
    this.name,
    required this.type,
    this.metadata,
  });
}
