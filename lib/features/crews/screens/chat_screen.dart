import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../widgets/chat_input.dart';
import '../models/chat_message.dart';
import 'package:intl/intl.dart';

class ChatScreen extends ConsumerStatefulWidget {
  final String crewId;
  final String crewName;
  
  const ChatScreen({
    super.key,
    required this.crewId,
    required this.crewName,
  });

  @override
  ConsumerState<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends ConsumerState<ChatScreen>
    with TickerProviderStateMixin {
  final ScrollController _scrollController = ScrollController();
  final List<ChatMessage> _messages = []; // TODO: Replace with actual data
  late AnimationController _fadeAnimationController;

  @override
  void initState() {
    super.initState();
    _fadeAnimationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _loadMockMessages();
    _fadeAnimationController.forward();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _fadeAnimationController.dispose();
    super.dispose();
  }

  void _loadMockMessages() {
    // Mock messages for demonstration
    final now = DateTime.now();
    _messages.addAll([
      ChatMessage(
        id: '1',
        senderId: 'user1',
        senderName: 'Mike Rodriguez',
        senderInitials: 'MR',
        content: 'Morning crew! Weather looks good for the transmission work today.',
        timestamp: now.subtract(const Duration(hours: 2)),
        isCurrentUser: false,
      ),
      ChatMessage(
        id: '2',
        senderId: 'current_user',
        senderName: 'You',
        senderInitials: 'YO',
        content: 'Copy that. I\'ll bring the extra safety gear we discussed.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 45)),
        isCurrentUser: true,
      ),
      ChatMessage(
        id: '3',
        senderId: 'user2',
        senderName: 'Sarah Chen',
        senderInitials: 'SC',
        content: 'Perfect! The utility confirmed access to the right-of-way. Meet at the staging area at 7 AM.',
        timestamp: now.subtract(const Duration(hours: 1, minutes: 30)),
        isCurrentUser: false,
      ),
      ChatMessage(
        id: '4',
        senderId: 'current_user',
        senderName: 'You',
        senderInitials: 'YO',
        content: '👍 See you there. Storm work pays well but safety first.',
        timestamp: now.subtract(const Duration(minutes: 30)),
        isCurrentUser: true,
      ),
    ]);
  }

  void _sendMessage(String content) {
    if (content.trim().isEmpty) return;

    final newMessage = ChatMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      senderId: 'current_user',
      senderName: 'You',
      senderInitials: 'YO',
      content: content.trim(),
      timestamp: DateTime.now(),
      isCurrentUser: true,
    );

    setState(() {
      _messages.add(newMessage);
    });

    // Scroll to bottom with animation
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });

    // TODO: Send message to backend/Firebase
  }

  Widget _buildMessageBubble(ChatMessage message, int index) {
    final isCurrentUser = message.isCurrentUser;
    final showAvatar = index == 0 || 
        _messages[index - 1].senderId != message.senderId ||
        message.timestamp.difference(_messages[index - 1].timestamp).inMinutes > 5;
    
    final showTimestamp = showAvatar ||
        (index < _messages.length - 1 && 
         message.timestamp.difference(_messages[index + 1].timestamp).inMinutes > 15);

    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      child: Column(
        crossAxisAlignment: isCurrentUser 
            ? CrossAxisAlignment.end 
            : CrossAxisAlignment.start,
        children: [
          if (showTimestamp && index > 0)
            Container(
              margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.lightGray.withValues(alpha: 0.7),
                    borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                  ),
                  child: Text(
                    _formatTimestamp(message.timestamp),
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ),
            ),
          
          Row(
            mainAxisAlignment: isCurrentUser 
                ? MainAxisAlignment.end 
                : MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Avatar for other users (left side)
              if (!isCurrentUser) ...[
                if (showAvatar)
                  _buildAvatar(message)
                else
                  const SizedBox(width: 32),
                const SizedBox(width: AppTheme.spacingSm),
              ],
              
              // Message bubble
              Flexible(
                child: Container(
                  constraints: BoxConstraints(
                    maxWidth: MediaQuery.of(context).size.width * 0.75,
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm + 2,
                  ),
                  decoration: BoxDecoration(
                    gradient: isCurrentUser
                        ? LinearGradient(
                            colors: [
                              AppTheme.accentCopper,
                              AppTheme.secondaryCopper,
                            ],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : null,
                    color: isCurrentUser ? null : AppTheme.white,
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg).copyWith(
                      bottomLeft: isCurrentUser || !showAvatar
                          ? const Radius.circular(AppTheme.radiusLg)
                          : const Radius.circular(AppTheme.radiusXs),
                      bottomRight: !isCurrentUser || !showAvatar
                          ? const Radius.circular(AppTheme.radiusLg)
                          : const Radius.circular(AppTheme.radiusXs),
                    ),
                    border: isCurrentUser 
                        ? null 
                        : Border.all(
                            color: AppTheme.borderLight,
                            width: 1,
                          ),
                    boxShadow: [
                      BoxShadow(
                        color: isCurrentUser 
                            ? AppTheme.accentCopper.withValues(alpha: 0.2)
                            : Colors.black.withValues(alpha: 0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (showAvatar && !isCurrentUser)
                        Padding(
                          padding: const EdgeInsets.only(bottom: AppTheme.spacingXs),
                          child: Text(
                            message.senderName,
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      Text(
                        message.content,
                        style: AppTheme.bodyMedium.copyWith(
                          color: isCurrentUser 
                              ? AppTheme.white 
                              : AppTheme.textPrimary,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              
              // Avatar for current user (right side) - typically not shown
              if (isCurrentUser) ...[
                const SizedBox(width: AppTheme.spacingSm),
                if (showAvatar)
                  _buildAvatar(message)
                else
                  const SizedBox(width: 32),
              ],
            ],
          ),
          
          // Message time
          if (showAvatar || index == _messages.length - 1)
            Padding(
              padding: EdgeInsets.only(
                top: AppTheme.spacingXs,
                left: isCurrentUser ? 0 : 44, // Align with message bubble
                right: isCurrentUser ? 44 : 0,
              ),
              child: Text(
                DateFormat.Hm().format(message.timestamp),
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.textLight,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatar(ChatMessage message) {
    return Container(
      width: 32,
      height: 32,
      decoration: BoxDecoration(
        gradient: message.isCurrentUser
            ? AppTheme.buttonGradient
            : LinearGradient(
                colors: [
                  AppTheme.primaryNavy,
                  AppTheme.secondaryNavy,
                ],
              ),
        shape: BoxShape.circle,
        border: Border.all(
          color: AppTheme.white,
          width: 2,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Center(
        child: Text(
          message.senderInitials,
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
        ),
      ),
    );
  }

  String _formatTimestamp(DateTime timestamp) {
    final now = DateTime.now();
    final difference = now.difference(timestamp);

    if (difference.inDays > 0) {
      return DateFormat.MMMMd().format(timestamp);
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else if (difference.inMinutes > 0) {
      return '${difference.inMinutes}m ago';
    } else {
      return 'Just now';
    }
  }

  Widget _buildTypingIndicator() {
    // TODO: Implement actual typing indicator logic
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      child: Row(
        children: [
          _buildAvatar(ChatMessage(
            id: 'typing',
            senderId: 'other_user',
            senderName: 'Someone',
            senderInitials: 'SU',
            content: '',
            timestamp: DateTime.now(),
            isCurrentUser: false,
          )),
          const SizedBox(width: AppTheme.spacingSm),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
              vertical: AppTheme.spacingSm,
            ),
            decoration: BoxDecoration(
              color: AppTheme.lightGray.withValues(alpha: 0.5),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildTypingDot(0),
                const SizedBox(width: 4),
                _buildTypingDot(1),
                const SizedBox(width: 4),
                _buildTypingDot(2),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingDot(int index) {
    return TweenAnimationBuilder<double>(
      duration: const Duration(milliseconds: 600),
      tween: Tween(begin: 0.4, end: 1.0),
      builder: (context, value, child) {
        return Transform.scale(
          scale: value,
          child: Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: AppTheme.textSecondary,
              shape: BoxShape.circle,
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              widget.crewName,
              style: AppTheme.titleLarge.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
            ),
            Text(
              '${_messages.where((m) => !m.isCurrentUser).map((m) => m.senderId).toSet().length + 1} members', // +1 for current user
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.info_outline),
            onPressed: () {
              // TODO: Show crew info
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    AppTheme.offWhite,
                    Color(0xFFF0F4F8),
                  ],
                ),
              ),
              child: FadeTransition(
                opacity: _fadeAnimationController,
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingMd),
                  itemCount: _messages.length + 1, // +1 for potential typing indicator
                  itemBuilder: (context, index) {
                    if (index == _messages.length) {
                      // Show typing indicator if someone is typing
                      // TODO: Replace with actual typing state check
                      return const SizedBox.shrink();
                      // return _buildTypingIndicator();
                    }
                    
                    return AnimatedContainer(
                      duration: Duration(milliseconds: 300 + (index * 50)),
                      curve: Curves.easeOutBack,
                      child: _buildMessageBubble(_messages[index], index),
                    );
                  },
                ),
              ),
            ),
          ),
          
          // Chat input
          Container(
            decoration: BoxDecoration(
              color: AppTheme.white,
              border: Border(
                top: BorderSide(
                  color: AppTheme.borderLight.withValues(alpha: 0.5),
                  width: 1,
                ),
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, -2),
                ),
              ],
            ),
            child: SafeArea(
              top: false,
              child: ChatInput(
                onSendMessage: _sendMessage,
                hintText: 'Message ${widget.crewName}...',
                onAttachmentPressed: () {
                  // TODO: Implement attachment functionality
                },
                onVoicePressed: () {
                  // TODO: Implement voice message functionality
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}