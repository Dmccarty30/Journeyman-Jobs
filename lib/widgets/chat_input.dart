import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'dart:async';

/// A widget for composing and sending messages in a chat conversation.
///
/// This stateful widget provides a text input field and a send button. It also
/// handles "is typing" indicators by communicating with the database service
/// when the user starts or stops typing.
class ChatInput extends ConsumerStatefulWidget {
  /// The ID of the crew the conversation belongs to.
  final String crewId;
  /// The ID of the specific conversation.
  final String convId;
  /// A callback function that is invoked when the user sends a message.
  final Function(String) onSendMessage;

  /// Creates a [ChatInput] widget.
  const ChatInput({
    super.key,
    required this.crewId,
    required this.convId,
    required this.onSendMessage,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

/// The state for the [ChatInput] widget.
class _ChatInputState extends ConsumerState<ChatInput> {
  /// The controller for the text input field.
  final TextEditingController _controller = TextEditingController();
  /// A timer to debounce "is typing" notifications.
  Timer? _typingTimer;
  /// A flag to track the user's current typing status.
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

  /// Listens for changes in the text field to manage the typing indicator.
  void _handleTextChange() {
    final text = _controller.text.trim();
    final typing = text.isNotEmpty;
    if (typing != _isTyping) {
      _isTyping = typing;
      if (typing) {
        _startTypingTimer();
      } else {
        _stopTyping();
      }
    }
  }

  /// Starts a timer to send a "user is typing" notification to the database.
  ///
  /// This is debounced to avoid sending too many updates.
  void _startTypingTimer() {
    _typingTimer?.cancel();
    _typingTimer = Timer(const Duration(milliseconds: 400), () {
      final dbService = ref.read(databaseServiceProvider);
      final currentUserAsync = ref.read(currentUserProvider);
      final userId = currentUserAsync?.uid ?? '';
      if (userId.isNotEmpty) {
        dbService.updateTyping(widget.crewId, widget.convId, userId, true);
      }
    });
  }

  /// Immediately sends a "user stopped typing" notification to the database.
  void _stopTyping() {
    _typingTimer?.cancel();
    final dbService = ref.read(databaseServiceProvider);
    final currentUserAsync = ref.read(currentUserProvider);
    final userId = currentUserAsync?.uid ?? '';
    if (userId.isNotEmpty) {
      dbService.updateTyping(widget.crewId, widget.convId, userId, false);
    }
  }

  /// Sends the message if the input field is not empty.
  ///
  /// It calls the [onSendMessage] callback, clears the text field,
  /// and sends a "stopped typing" notification.
  void _sendMessage() {
    if (_controller.text.trim().isNotEmpty) {
      final msg = _controller.text.trim();
      widget.onSendMessage(msg);
      _controller.clear();
      _stopTyping();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _controller,
              decoration: InputDecoration(
                hintText: 'Send a message...',
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(20.0),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              onSubmitted: (_) => _sendMessage(),
            ),
          ),
          const SizedBox(width: 8.0),
          FloatingActionButton(
            onPressed: _sendMessage,
            mini: true,
            child: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _controller.removeListener(_handleTextChange);
    _typingTimer?.cancel();
    _controller.dispose();
    super.dispose();
  }
}
