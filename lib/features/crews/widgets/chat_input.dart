import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'dart:async';


class ChatInput extends ConsumerStatefulWidget {
  final String crewId;
  final String convId;
  final Function(String) onSendMessage;

  const ChatInput({
    super.key,
    required this.crewId,
    required this.convId,
    required this.onSendMessage,
  });

  @override
  ConsumerState<ChatInput> createState() => _ChatInputState();
}

class _ChatInputState extends ConsumerState<ChatInput> {
  final TextEditingController _controller = TextEditingController();
  Timer? _typingTimer;
  bool _isTyping = false;

  @override
  void initState() {
    super.initState();
    _controller.addListener(_handleTextChange);
  }

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

  void _stopTyping() {
    _typingTimer?.cancel();
    final dbService = ref.read(databaseServiceProvider);
    final currentUserAsync = ref.read(currentUserProvider);
    final userId = currentUserAsync?.uid ?? '';
    if (userId.isNotEmpty) {
      dbService.updateTyping(widget.crewId, widget.convId, userId, false);
    }
  }

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
