// MEMORY LEAK FIX - CrewCommunicationScreen
// CRITICAL: PageController and TextEditingController memory leak fix

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:async';
import '../models/crew_communication.dart';
import '../models/crew_member.dart';
import '../providers/crew_communication_provider.dart';
import '../services/crew_communication_service.dart';
import '../widgets/crew_member_card.dart';

/// FIXED: Added proper dispose() method to prevent battery drain
/// during electrical work shifts
class CrewCommunicationScreen extends StatefulWidget {
  final String crewId;
  final String currentUserId;

  const CrewCommunicationScreen({
    Key? key,
    required this.crewId,
    required this.currentUserId,
  }) : super(key: key);

  @override
  State<CrewCommunicationScreen> createState() => _CrewCommunicationScreenState();
}

class _CrewCommunicationScreenState extends State<CrewCommunicationScreen> {
  // Controllers that need disposal
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  late CrewCommunicationService _communicationService;

  // Stream subscriptions that need cancellation
  StreamSubscription<List<CrewCommunication>>? _messagesSubscription;
  StreamSubscription<List<CrewMember>>? _membersSubscription;

  @override
  void initState() {
    super.initState();
    _communicationService = CrewCommunicationService();
    _initializeStreams();
  }

  void _initializeStreams() {
    // Initialize stream subscriptions
    _messagesSubscription = _communicationService
        .getMessagesStream(widget.crewId)
        .listen((messages) {
      if (mounted) {
        // Handle messages
      }
    });

    _membersSubscription = _communicationService
        .getMembersStream(widget.crewId)
        .listen((members) {
      if (mounted) {
        // Handle members
      }
    });
  }

  // CRITICAL MEMORY LEAK FIX: Proper disposal of all resources
  @override
  void dispose() {
    // Dispose controllers
    _messageController.dispose();
    _scrollController.dispose();

    // Cancel stream subscriptions
    _messagesSubscription?.cancel();
    _membersSubscription?.cancel();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Crew Communication'),
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Consumer<CrewCommunicationProvider>(
              builder: (context, provider, child) {
                return ListView.builder(
                  controller: _scrollController,
                  itemCount: provider.messages.length,
                  itemBuilder: (context, index) {
                    final message = provider.messages[index];
                    return ListTile(
                      title: Text(message.content),
                      subtitle: Text(message.senderName),
                    );
                  },
                );
              },
            ),
          ),
          // Message input
          Padding(
            padding: EdgeInsets.all(16),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                SizedBox(width: 8),
                IconButton(
                  onPressed: _sendMessage,
                  icon: Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _sendMessage() {
    final text = _messageController.text.trim();
    if (text.isNotEmpty) {
      _communicationService.sendMessage(
        crewId: widget.crewId,
        senderId: widget.currentUserId,
        content: text,
      );
      _messageController.clear();
    }
  }
}