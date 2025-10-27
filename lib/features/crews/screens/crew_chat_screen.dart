import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/crew_message_model.dart';
import 'package:journeyman_jobs/models/crew_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/services/crew_messaging_service.dart';
import 'package:journeyman_jobs/widgets/crew_message_bubble.dart';
import 'package:journeyman_jobs/widgets/electrical_components.dart';

/// Crew chat screen for real-time messaging
///
/// This screen provides:
/// - Real-time message streaming
/// - Message composition and sending
/// - Media sharing capabilities
/// - Electrical themed UI with circuit patterns
/// - Read status and reactions
class CrewChatScreen extends ConsumerStatefulWidget {
  final String crewId;
  final String crewName;
  final String? crewAvatar;
  final String? directMessageTo;
  final String? memberName;

  const CrewChatScreen({
    super.key,
    required this.crewId,
    required this.crewName,
    this.crewAvatar,
    this.directMessageTo,
    this.memberName,
  });

  @override
  ConsumerState<CrewChatScreen> createState() => _CrewChatScreenState();
}

class _CrewChatScreenState extends ConsumerState<CrewChatScreen>
    with TickerProviderStateMixin {
  late ScrollController _scrollController;
  late TextEditingController _messageController;
  late FocusNode _messageFocusNode;

  final CrewMessagingService _messagingService = CrewMessagingService();

  List<CrewMessage> _messages = [];
  List<UserModel> _crewMembers = [];
  bool _isLoading = true;
  bool _isSending = false;
  String? _replyingToMessageId;
  CrewMessage? _replyingToMessage;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _messageController = TextEditingController();
    _messageFocusNode = FocusNode();

    _loadMessages();
    _loadCrewMembers();
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Crew info bar
          _buildCrewInfoBar(),

          // Messages list
          Expanded(
            child: _buildMessagesList(),
          ),

          // Message input
          _buildMessageInput(),
        ],
      ),
    );
  }

  PreferredSizeWidget _buildAppBar() {
    String displayTitle = widget.crewName;

    // Show direct message title if messaging a specific member
    if (widget.directMessageTo != null && widget.memberName != null) {
      displayTitle = 'DM: ${widget.memberName}';
    }

    return AppBar(
      title: Text(
        displayTitle,
        style: const TextStyle(
          fontWeight: FontWeight.w700,
          color: AppTheme.white,
        ),
      ),
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      centerTitle: true,
      iconTheme: const IconThemeData(color: AppTheme.white),
      actions: [
        // Crew members button
        IconButton(
          onPressed: _showCrewMembers,
          icon: const Icon(Icons.group),
          color: AppTheme.white,
        ),

        // More options
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.white),
          onSelected: _handleMenuAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'info',
              child: Row(
                children: [
                  Icon(Icons.info_outline),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Crew Info'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'mute',
              child: Row(
                children: [
                  Icon(Icons.notifications_off_outlined),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Mute Notifications'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'leave',
              child: Row(
                children: [
                  Icon(Icons.exit_to_app, color: AppTheme.errorRed),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Leave Crew', style: TextStyle(color: AppTheme.errorRed)),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildCrewInfoBar() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          bottom: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Crew avatar
          CircleAvatar(
            radius: 20,
            backgroundColor: AppTheme.accentCopper,
            backgroundImage: widget.crewAvatar != null
                ? NetworkImage(widget.crewAvatar!)
                : null,
            child: widget.crewAvatar == null
                ? Text(
                    widget.crewName.isNotEmpty
                        ? widget.crewName[0].toUpperCase()
                        : 'C',
                    style: AppTheme.titleMedium.copyWith(
                      color: AppTheme.white,
                      fontWeight: FontWeight.w700,
                    ),
                  )
                : null,
          ),

          const SizedBox(width: AppTheme.spacingMd),

          // Crew info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.crewName,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  '${_crewMembers.length} members',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ),
          ),

          // Online status indicator
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: AppTheme.successGreen,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppTheme.successGreen.withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessagesList() {
    if (_isLoading) {
      return Center(
        child: JJElectricalLoader(
          width: 200,
          height: 40,
          message: 'Loading messages...',
        ),
      );
    }

    if (_messages.isEmpty) {
      return _buildEmptyState();
    }

    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.offWhite,
            AppTheme.offWhite.withValues(alpha: 0.95),
          ],
        ),
      ),
      child: ListView.builder(
        controller: _scrollController,
        padding: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingMd,
        ),
        reverse: true, // Show messages from bottom to top
        itemCount: _messages.length,
        itemBuilder: (context, index) {
          final message = _messages[index];
          final currentUser = ref.read(auth_providers.currentUserProvider);
          final isFromCurrentUser = message.senderId == currentUser?.uid;

          // Date separator
          if (_shouldShowDateSeparator(index)) {
            return Column(
              children: [
                _buildDateSeparator(message.createdAt),
                CrewMessageBubble(
                  message: message,
                  isFromCurrentUser: isFromCurrentUser,
                  onTap: () => _handleMessageTap(message),
                  onLongPress: () => _handleMessageLongPress(message),
                  onReactionTap: (userId) => _handleReactionTap(message, userId),
                ),
              ],
            );
          }

          return CrewMessageBubble(
            message: message,
            isFromCurrentUser: isFromCurrentUser,
            onTap: () => _handleMessageTap(message),
            onLongPress: () => _handleMessageLongPress(message),
            onReactionTap: (userId) => _handleReactionTap(message, userId),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingXl),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical background
            Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppTheme.accentCopper.withValues(alpha: 0.1),
                    AppTheme.primaryNavy.withValues(alpha: 0.05),
                  ],
                ),
              ),
              child: Icon(
                Icons.chat_bubble_outline,
                size: 48,
                color: AppTheme.textLight,
              ),
            ),

            const SizedBox(height: AppTheme.spacingLg),

            Text(
              'Start conversation',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),

            const SizedBox(height: AppTheme.spacingSm),

            Text(
              'Send a message to connect with your crew members',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMessageInput() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.borderLight,
            width: 1,
          ),
        ),
      ),
      child: Column(
        children: [
          // Reply indicator
          if (_replyingToMessage != null) _buildReplyIndicator(),

          // Input row
          Row(
            children: [
              // Attach button
              IconButton(
                onPressed: _showAttachmentOptions,
                icon: const Icon(Icons.attach_file),
                color: AppTheme.textSecondary,
                style: IconButton.styleFrom(
                  backgroundColor: AppTheme.offWhite,
                ),
              ),

              // Message input
              Expanded(
                child: TextField(
                  controller: _messageController,
                  focusNode: _messageFocusNode,
                  maxLines: null,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: 'Type a message...',
                    filled: true,
                    fillColor: AppTheme.offWhite,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide.none,
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      borderSide: BorderSide(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthThick,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                  ),
                ),
              ),

              const SizedBox(width: AppTheme.spacingSm),

              // Send button
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: AppTheme.electricalGradient,
                  boxShadow: [
                    BoxShadow(
                      color: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
                      blurRadius: 8,
                    ),
                  ],
                ),
                child: IconButton(
                  onPressed: _isSending || _messageController.text.trim().isEmpty
                      ? null
                      : _sendMessage,
                  icon: _isSending
                      ? SizedBox(
                          width: 20,
                          height: 20,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.white),
                          ),
                        )
                      : const Icon(
                          Icons.send,
                          color: AppTheme.white,
                        ),
                  style: IconButton.styleFrom(
                    backgroundColor: Colors.transparent,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildReplyIndicator() {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: AppTheme.iconSm,
            color: AppTheme.accentCopper,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              'Replying to ${_replyingToMessage!.senderName}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          IconButton(
            onPressed: () {
              setState(() {
                _replyingToMessage = null;
                _replyingToMessageId = null;
              });
            },
            icon: const Icon(Icons.close, size: 16),
            color: AppTheme.accentCopper,
          ),
        ],
      ),
    );
  }

  Widget _buildDateSeparator(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final messageDate = DateTime(date.year, date.month, date.day);

    String formattedDate;
    if (messageDate == today) {
      formattedDate = 'Today';
    } else {
      formattedDate = '${date.day}/${date.month}/${date.year}';
    }

    return Container(
      margin: const EdgeInsets.symmetric(vertical: 16),
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: AppTheme.mediumGray.withValues(alpha: 0.2),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Text(
            formattedDate,
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.textSecondary,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowDateSeparator(int index) {
    if (index == _messages.length - 1) return true;

    final currentMessage = _messages[index];
    final nextMessage = _messages[index + 1];

    final currentDate = currentMessage.createdAt.toDate();
    final nextDate = nextMessage.createdAt.toDate();

    return !currentDate.isSameDay(nextDate);
  }

  void _loadMessages() async {
    try {
      print("Loading messages for crew ID: ${widget.crewId}");
      final messages = await _messagingService.getCrewMessages(widget.crewId);
      setState(() {
        _messages = messages;
        _isLoading = false;
      });
      _scrollToBottom();
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading messages: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _loadCrewMembers() async {
    try {
      print("Loading crew members for crew ID: ${widget.crewId}");
      final members = await _messagingService.getCrewMembers(widget.crewId);
      setState(() {
        _crewMembers = members;
      });
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error loading crew members: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    }
  }

  void _sendMessage() async {
    if (_messageController.text.trim().isEmpty) return;

    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) return;

    setState(() {
      _isSending = true;
    });

    try {
      // Convert User to UserModel for service call
      final userDoc = await FirebaseFirestore.instance.collection('users').doc(currentUser.uid).get();
      if (!userDoc.exists) {
        throw Exception('User not found');
      }
      final userModel = UserModel.fromFirestore(userDoc);

      // Send message using the service method
      await _messagingService.sendMessage(
        crewId: widget.crewId,
        sender: userModel,
        content: _messageController.text.trim(),
        type: CrewMessageType.text,
        replyToMessageId: _replyingToMessageId,
      );

      _messageController.clear();
      setState(() {
        _replyingToMessage = null;
        _replyingToMessageId = null;
      });
      _scrollToBottom();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Error sending message: $e'),
            backgroundColor: AppTheme.errorRed,
          ),
        );
      }
    } finally {
      setState(() {
        _isSending = false;
      });
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOut,
        );
      }
    });
  }

  void _handleMessageTap(CrewMessage message) {
    // Handle message tap (e.g., show reactions, reply, etc.)
  }

  void _handleMessageLongPress(CrewMessage message) {
    // Handle long press (e.g., show context menu with delete, copy, etc.)
  }

  void _handleReactionTap(CrewMessage message, String userId) {
    // Handle reaction tap
  }

  void _showCrewMembers() {
    // Show crew members dialog/bottom sheet
  }

  void _showAttachmentOptions() {
    // Show attachment options (image, file, location, etc.)
  }

  void _handleMenuAction(String action) {
    switch (action) {
      case 'info':
        // Show crew info
        break;
      case 'mute':
        // Mute notifications
        break;
      case 'leave':
        _showLeaveCrewDialog();
        break;
    }
  }

  void _showLeaveCrewDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Leave Crew'),
        content: Text('Are you sure you want to leave ${widget.crewName}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              // Implement leave crew logic
            },
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

extension on DateTime {
  bool isSameDay(DateTime other) {
    return year == other.year && month == other.month && day == other.day;
  }
}