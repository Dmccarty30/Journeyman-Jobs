import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/models.dart';
import '../../providers/providers.dart';

/// Screen for crew chat functionality
/// 
/// This screen displays real-time messaging between crew members
/// with support for text, images, and file attachments.
class CrewChatScreen extends ConsumerStatefulWidget {
  final String crewId;
  final String crewName;

  const CrewChatScreen({
    Key? key,
    required this.crewId,
    required this.crewName,
  }) : super(key: key);

  @override
  ConsumerState<CrewChatScreen> createState() => _CrewChatScreenState();
}

class _CrewChatScreenState extends ConsumerState<CrewChatScreen> {
  final TextEditingController _messageController = TextEditingController();
  
  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.crewName),
        backgroundColor: const Color(0xFF1A202C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Container(
              color: Colors.grey[100],
              child: const Center(
                child: Text(
                  'Chat functionality coming soon',
                  style: TextStyle(fontSize: 16, color: Colors.grey),
                ),
              ),
            ),
          ),
          _buildMessageInput(),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: Colors.grey[300]!)),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: const InputDecoration(
                hintText: 'Type a message...',
                border: OutlineInputBorder(),
              ),
            ),
          ),
          const SizedBox(width: 8),
          IconButton(
            onPressed: () {
              // TODO: Implement message sending
              _messageController.clear();
            },
            icon: const Icon(Icons.send),
          ),
        ],
      ),
    );
  }
}
