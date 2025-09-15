import 'package:flutter/material.dart';
import '../models/crew_communication.dart';
import '../models/crew_enums.dart';
import '../models/message_attachment.dart';
import 'message_bubble.dart';

/// Example usage of MessageBubble widget for IBEW electrical crew communications
///
/// Demonstrates various message types, attachment handling, and electrical worker
/// specific features like safety alerts and emergency messages.
class MessageBubbleExample extends StatelessWidget {
  const MessageBubbleExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Message Bubble Examples'),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Regular text message from another user
          MessageBubble(
            message: _createTextMessage(
              'Hey crew, job site is ready for today. Meet at the main panel.',
              'Mike Johnson',
              'Foreman',
              false,
            ),
            isCurrentUser: false,
            showSenderName: true,
            showTimestamp: true,
          ),
          
          const SizedBox(height: 16),
          
          // Current user message
          MessageBubble(
            message: _createTextMessage(
              'Copy that, Mike. I\'ll be there in 15 minutes.',
              'Current User',
              'Journeyman',
              true,
            ),
            isCurrentUser: true,
            showTimestamp: true,
          ),
          
          const SizedBox(height: 16),
          
          // Safety alert message
          MessageBubble(
            message: _createSafetyMessage(
              'SAFETY ALERT: High voltage work starting in Panel Room B. All non-essential personnel must clear the area.',
              'Safety Coordinator',
              'Safety Coordinator',
            ),
            isCurrentUser: false,
            showSenderName: true,
            showTimestamp: true,
          ),
          
          const SizedBox(height: 16),
          
          // Emergency message
          MessageBubble(
            message: _createEmergencyMessage(
              'EMERGENCY: Worker down in Section 3. Medical assistance requested immediately.',
              'Site Supervisor',
              'Foreman',
            ),
            isCurrentUser: false,
            showSenderName: true,
            showTimestamp: true,
          ),
          
          const SizedBox(height: 16),
          
          // System message
          MessageBubble(
            message: _createSystemMessage(
              'Dave Miller has joined the crew',
            ),
            isCurrentUser: false,
            isSystemMessage: true,
          ),
          
          const SizedBox(height: 16),
          
          // Message with attachments
          MessageBubble(
            message: _createMessageWithAttachments(
              'Here\'s the wiring diagram for today\'s panel upgrade',
              'Lead Electrician',
              'Lead Journeyman',
            ),
            isCurrentUser: false,
            showSenderName: true,
            showTimestamp: true,
            onTap: () => _showAttachmentDialog(context),
          ),
          
          const SizedBox(height: 16),
          
          // Job update message
          MessageBubble(
            message: _createJobUpdateMessage(
              'Panel 4A installation completed. Moving to Panel 4B.',
              'Field Worker',
              'Journeyman',
            ),
            isCurrentUser: true,
            showTimestamp: true,
          ),
        ],
      ),
    );
  }

  CrewCommunication _createTextMessage(
    String content,
    String senderName,
    String senderRole,
    bool isCurrentUser,
  ) {
    return CrewCommunication(
      id: 'msg-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: isCurrentUser ? 'current-user' : 'other-user',
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 5)),
      attachments: [],
      readBy: {'current-user': DateTime.now()},
      isPinned: false,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  CrewCommunication _createSafetyMessage(
    String content,
    String senderName,
    String senderRole,
  ) {
    return CrewCommunication(
      id: 'safety-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: 'safety-coordinator',
      content: content,
      type: MessageType.safetyAlert,
      timestamp: DateTime.now().subtract(const Duration(minutes: 2)),
      attachments: [],
      readBy: {'current-user': DateTime.now()},
      isPinned: true,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  CrewCommunication _createEmergencyMessage(
    String content,
    String senderName,
    String senderRole,
  ) {
    return CrewCommunication(
      id: 'emergency-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: 'supervisor',
      content: content,
      type: MessageType.emergency,
      timestamp: DateTime.now().subtract(const Duration(minutes: 1)),
      attachments: [],
      readBy: {},
      isPinned: true,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  CrewCommunication _createSystemMessage(String content) {
    return CrewCommunication(
      id: 'system-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: 'system',
      content: content,
      type: MessageType.system,
      timestamp: DateTime.now().subtract(const Duration(minutes: 10)),
      attachments: [],
      readBy: {},
      isPinned: false,
      isEdited: false,
      senderName: 'System',
      senderRole: null,
    );
  }

  CrewCommunication _createMessageWithAttachments(
    String content,
    String senderName,
    String senderRole,
  ) {
    return CrewCommunication(
      id: 'attach-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: 'lead-electrician',
      content: content,
      type: MessageType.text,
      timestamp: DateTime.now().subtract(const Duration(minutes: 15)),
      attachments: [
        MessageAttachment(
          id: 'attach-1',
          fileName: 'panel_4a_wiring_diagram.pdf',
          url: 'https://example.com/files/panel_4a_wiring_diagram.pdf',
          type: AttachmentType.schematic,
          sizeBytes: 2048576, // 2MB
          description: 'Electrical wiring diagram for Panel 4A upgrade',
          uploadedAt: DateTime.now().subtract(const Duration(minutes: 16)),
          uploadedBy: 'lead-electrician',
        ),
        MessageAttachment(
          id: 'attach-2',
          fileName: 'safety_checklist.pdf',
          url: 'https://example.com/files/safety_checklist.pdf',
          type: AttachmentType.safetyDoc,
          sizeBytes: 512000, // 512KB
          description: 'Safety checklist for high voltage work',
          uploadedAt: DateTime.now().subtract(const Duration(minutes: 16)),
          uploadedBy: 'lead-electrician',
        ),
      ],
      readBy: {'current-user': DateTime.now()},
      isPinned: false,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  CrewCommunication _createJobUpdateMessage(
    String content,
    String senderName,
    String senderRole,
  ) {
    return CrewCommunication(
      id: 'job-${DateTime.now().millisecondsSinceEpoch}',
      crewId: 'crew-123',
      senderId: 'current-user',
      content: content,
      type: MessageType.jobUpdate,
      timestamp: DateTime.now().subtract(const Duration(minutes: 3)),
      attachments: [],
      readBy: {'current-user': DateTime.now(), 'foreman': DateTime.now()},
      isPinned: false,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  void _showAttachmentDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Attachment Tapped'),
        content: const Text('In a real app, this would open the attachment or show a preview.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

/// Demonstration screen showing different MessageBubble configurations
class MessageBubbleDemo extends StatefulWidget {
  const MessageBubbleDemo({super.key});

  @override
  State<MessageBubbleDemo> createState() => _MessageBubbleDemoState();
}

class _MessageBubbleDemoState extends State<MessageBubbleDemo> {
  final List<CrewCommunication> _messages = [];
  final TextEditingController _textController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSampleMessages();
  }

  void _loadSampleMessages() {
    // Add some sample messages to demonstrate the chat interface
    setState(() {
      _messages.addAll([
        _createMessage(
          'Good morning crew! Today we\'re working on the main distribution panel.',
          'Mike Johnson',
          'Foreman',
          'foreman-1',
          MessageType.jobUpdate,
          DateTime.now().subtract(const Duration(hours: 2)),
        ),
        _createMessage(
          'Roger that. I\'ve reviewed the safety protocols.',
          'Current User',
          'Journeyman',
          'current-user',
          MessageType.text,
          DateTime.now().subtract(const Duration(hours: 1, minutes: 45)),
        ),
        _createMessage(
          'SAFETY REMINDER: Lockout/Tagout procedures must be followed for all panel work.',
          'Safety Coordinator',
          'Safety Coordinator',
          'safety-1',
          MessageType.safetyAlert,
          DateTime.now().subtract(const Duration(hours: 1, minutes: 30)),
        ),
      ]);
    });
  }

  CrewCommunication _createMessage(
    String content,
    String senderName,
    String senderRole,
    String senderId,
    MessageType type,
    DateTime timestamp,
  ) {
    return CrewCommunication(
      id: 'msg-${timestamp.millisecondsSinceEpoch}',
      crewId: 'demo-crew',
      senderId: senderId,
      content: content,
      type: type,
      timestamp: timestamp,
      attachments: [],
      readBy: {'current-user': DateTime.now()},
      isPinned: type == MessageType.safetyAlert || type == MessageType.emergency,
      isEdited: false,
      senderName: senderName,
      senderRole: senderRole,
    );
  }

  void _sendMessage() {
    if (_textController.text.trim().isNotEmpty) {
      setState(() {
        _messages.add(_createMessage(
          _textController.text.trim(),
          'Current User',
          'Journeyman',
          'current-user',
          MessageType.text,
          DateTime.now(),
        ));
      });
      _textController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('IBEW Crew Chat Demo'),
        backgroundColor: const Color(0xFF1A202C),
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: _messages.length,
              itemBuilder: (context, index) {
                final message = _messages[index];
                final isCurrentUser = message.senderId == 'current-user';
                
                return MessageBubble(
                  message: message,
                  isCurrentUser: isCurrentUser,
                  showSenderName: !isCurrentUser,
                  showTimestamp: true,
                  onReply: () => _replyToMessage(message),
                  onReaction: (reaction) => _addReaction(message, reaction),
                );
              },
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            color: Colors.grey[100],
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _textController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 8),
                FloatingActionButton.small(
                  onPressed: _sendMessage,
                  backgroundColor: const Color(0xFFB45309), // AppTheme.accentCopper
                  child: const Icon(Icons.send, color: Colors.white),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _replyToMessage(CrewCommunication message) {
    // In a real app, this would set up reply context
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Replying to: ${message.senderName}')),
    );
  }

  void _addReaction(CrewCommunication message, String reaction) {
    // In a real app, this would add the reaction to the message
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Added reaction: $reaction')),
    );
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}
