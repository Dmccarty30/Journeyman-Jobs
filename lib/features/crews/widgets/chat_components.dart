import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:intl/intl.dart';
import '../../../design_system/tailboard_theme.dart';

/// Message bubble widget for chat
class MessageBubble extends StatelessWidget {
  final String message;
  final String senderId;
  final String senderName;
  final DateTime timestamp;
  final bool isCurrentUser;
  final String? avatarUrl;

  const MessageBubble({
    super.key,
    required this.message,
    required this.senderId,
    required this.senderName,
    required this.timestamp,
    required this.isCurrentUser,
    this.avatarUrl,
  });

  @override
  Widget build(BuildContext context) {
    final timeStr = DateFormat('h:mm a').format(timestamp);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingM,
        vertical: TailboardTheme.spacingXS,
      ),
      child: Row(
        mainAxisAlignment: isCurrentUser
            ? MainAxisAlignment.end
            : MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          if (!isCurrentUser) ...[
            CircleAvatar(
              radius: 16,
              backgroundColor: TailboardTheme.copper.withValues(alpha: 0.2),
              child: avatarUrl != null
                  ? ClipOval(
                      child: Image.network(
                        avatarUrl!,
                        width: 32,
                        height: 32,
                        fit: BoxFit.cover,
                      ),
                    )
                  : Text(
                      senderName[0].toUpperCase(),
                      style: TailboardTheme.labelSmall.copyWith(
                        color: TailboardTheme.copper,
                      ),
                    ),
            ),
            const SizedBox(width: TailboardTheme.spacingS),
          ],
          Flexible(
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                if (!isCurrentUser)
                  Padding(
                    padding: const EdgeInsets.only(
                      left: TailboardTheme.spacingS,
                      bottom: 2,
                    ),
                    child: Text(
                      senderName,
                      style: TailboardTheme.labelSmall.copyWith(
                        color: TailboardTheme.copper,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: TailboardTheme.spacingM,
                    vertical: TailboardTheme.spacingS,
                  ),
                  decoration: BoxDecoration(
                    color: isCurrentUser
                        ? TailboardTheme.copper
                        : TailboardTheme.backgroundCard,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(
                        isCurrentUser ? TailboardTheme.radiusL : TailboardTheme.radiusS,
                      ),
                      topRight: Radius.circular(
                        isCurrentUser ? TailboardTheme.radiusS : TailboardTheme.radiusL,
                      ),
                      bottomLeft: const Radius.circular(TailboardTheme.radiusL),
                      bottomRight: const Radius.circular(TailboardTheme.radiusL),
                    ),
                    boxShadow: TailboardTheme.shadowSmall,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        message,
                        style: TailboardTheme.bodyMedium.copyWith(
                          color: isCurrentUser
                              ? TailboardTheme.textPrimary
                              : TailboardTheme.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeStr,
                        style: TailboardTheme.labelSmall.copyWith(
                          color: isCurrentUser
                              ? TailboardTheme.textPrimary.withValues(alpha: 0.7)
                              : TailboardTheme.textTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(duration: 200.ms).slideX(
      begin: isCurrentUser ? 0.1 : -0.1,
      end: 0,
      duration: 200.ms,
    );
  }
}

/// Chat input widget with send button
class ChatInput extends StatefulWidget {
  final ValueChanged<String> onSendMessage;
  final bool enabled;
  final String? placeholder;

  const ChatInput({
    super.key,
    required this.onSendMessage,
    this.enabled = true,
    this.placeholder,
  });

  @override
  State<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends State<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  bool _hasText = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _sendMessage() {
    final text = _controller.text.trim();
    if (text.isNotEmpty) {
      widget.onSendMessage(text);
      _controller.clear();
      setState(() {
        _hasText = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(TailboardTheme.spacingM),
      decoration: BoxDecoration(
        color: TailboardTheme.backgroundCard,
        border: Border(
          top: BorderSide(
            color: TailboardTheme.divider,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: Container(
                constraints: const BoxConstraints(maxHeight: 120),
                child: TextField(
                  controller: _controller,
                  enabled: widget.enabled,
                  maxLines: null,
                  textInputAction: TextInputAction.newline,
                  decoration: TailboardTheme.inputDecoration(
                    hintText: widget.placeholder ?? 'Type a message...',
                    prefixIcon: const Icon(Icons.message, color: TailboardTheme.copper),
                  ),
                  style: TailboardTheme.bodyMedium,
                  onChanged: (text) {
                    setState(() {
                      _hasText = text.trim().isNotEmpty;
                    });
                  },
                  onSubmitted: (_) {
                    if (_hasText) _sendMessage();
                  },
                ),
              ),
            ),
            const SizedBox(width: TailboardTheme.spacingS),
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              child: IconButton(
                onPressed: _hasText && widget.enabled ? _sendMessage : null,
                icon: Icon(
                  Icons.send,
                  color: _hasText && widget.enabled
                      ? TailboardTheme.copper
                      : TailboardTheme.textTertiary,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: _hasText && widget.enabled
                      ? TailboardTheme.copper.withValues(alpha: 0.1)
                      : TailboardTheme.backgroundDark,
                  padding: const EdgeInsets.all(TailboardTheme.spacingM),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Typing indicator widget
class TypingIndicator extends StatelessWidget {
  final String userName;

  const TypingIndicator({
    super.key,
    required this.userName,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: TailboardTheme.spacingM,
        vertical: TailboardTheme.spacingS,
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: TailboardTheme.spacingM,
              vertical: TailboardTheme.spacingS,
            ),
            decoration: BoxDecoration(
              color: TailboardTheme.backgroundCard,
              borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  '$userName is typing',
                  style: TailboardTheme.bodySmall.copyWith(
                    color: TailboardTheme.textSecondary,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(width: TailboardTheme.spacingS),
                SizedBox(
                  width: 24,
                  height: 12,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: List.generate(3, (index) {
                      return Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: TailboardTheme.copper,
                          shape: BoxShape.circle,
                        ),
                      ).animate(
                        onPlay: (controller) => controller.repeat(),
                      ).fadeIn(
                        delay: Duration(milliseconds: index * 200),
                        duration: 600.ms,
                      ).then().fadeOut(
                        duration: 600.ms,
                      );
                    }),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

/// Date divider for chat messages
class DateDivider extends StatelessWidget {
  final DateTime date;

  const DateDivider({
    super.key,
    required this.date,
  });

  @override
  Widget build(BuildContext context) {
    final dateStr = DateFormat.yMMMd().format(date);
    final isToday = DateTime.now().difference(date).inDays == 0;
    final isYesterday = DateTime.now().difference(date).inDays == 1;

    String displayText;
    if (isToday) {
      displayText = 'Today';
    } else if (isYesterday) {
      displayText = 'Yesterday';
    } else {
      displayText = dateStr;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: TailboardTheme.spacingM),
      child: Row(
        children: [
          Expanded(
            child: Container(
              height: 1,
              color: TailboardTheme.divider,
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: TailboardTheme.spacingM),
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: TailboardTheme.spacingM,
                vertical: TailboardTheme.spacingS,
              ),
              decoration: BoxDecoration(
                color: TailboardTheme.backgroundCard,
                borderRadius: BorderRadius.circular(TailboardTheme.radiusL),
                border: Border.all(
                  color: TailboardTheme.border,
                ),
              ),
              child: Text(
                displayText,
                style: TailboardTheme.labelSmall,
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 1,
              color: TailboardTheme.divider,
            ),
          ),
        ],
      ),
    );
  }
}
