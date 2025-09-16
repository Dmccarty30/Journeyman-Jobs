import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:image_picker/image_picker.dart';
import 'package:geolocator/geolocator.dart';
import 'package:intl/intl.dart';

import '../../../design_system/app_theme.dart';
import '../models/crew_communication.dart';
import '../models/crew_enums.dart';
import '../models/message_attachment.dart';
import '../providers/crew_communication_provider.dart';
import '../widgets/message_bubble.dart';

/// CrewCommunicationScreen - Real-time crew messaging for IBEW electrical workers
///
/// Features professional electrical worker communication including safety alerts,
/// emergency coordination, work status updates, and file sharing capabilities.
/// Designed specifically for IBEW union electrical workers with safety-first protocols.
class CrewCommunicationScreen extends ConsumerStatefulWidget {
  /// The ID of the crew for this communication channel
  final String crewId;

  /// Optional crew name for display in app bar
  final String? crewName;

  /// Current user ID for message attribution
  final String? currentUserId;

  const CrewCommunicationScreen({
    super.key,
    required this.crewId,
    this.crewName,
    this.currentUserId,
  });

  @override
  ConsumerState<CrewCommunicationScreen> createState() => _CrewCommunicationScreenState();
}

class _CrewCommunicationScreenState extends ConsumerState<CrewCommunicationScreen>
    with TickerProviderStateMixin {

  // Controllers and Animation
  final ScrollController _scrollController = ScrollController();
  final TextEditingController _messageController = TextEditingController();
  final FocusNode _messageFocusNode = FocusNode();
  late AnimationController _typingAnimationController;
  late Animation<double> _typingAnimation;

  // State variables
  bool _isTyping = false;
  bool _showScrollToBottom = false;
  List<File> _selectedAttachments = [];
  MessageType _selectedMessageType = MessageType.text;
  String? _replyToMessageId;
  CrewCommunication? _replyToMessage;

  // Image picker for attachments
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void initState() {
    super.initState();

    // Initialize animations
    _typingAnimationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _typingAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _typingAnimationController,
      curve: Curves.easeInOut,
    ));

    // Set up scroll listener
    _scrollController.addListener(_onScroll);

    // Focus node listener for typing indicators
    _messageFocusNode.addListener(_onFocusChange);

    // Message controller listener for typing indicators
    _messageController.addListener(_onTextChange);

    // Start listening to messages when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(crewCommunicationNotifierProvider.notifier)
          .startListeningToMessages(widget.crewId);
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    _messageController.dispose();
    _messageFocusNode.dispose();
    _typingAnimationController.dispose();

    // Stop listening to messages when screen is disposed
    ref.read(crewCommunicationNotifierProvider.notifier)
        .stopListeningToMessages(widget.crewId);

    super.dispose();
  }

  void _onScroll() {
    final showButton = _scrollController.offset > 100;
    if (showButton != _showScrollToBottom) {
      setState(() => _showScrollToBottom = showButton);
    }
  }

  void _onFocusChange() {
    _updateTypingStatus();
  }

  void _onTextChange() {
    final hasText = _messageController.text.trim().isNotEmpty;
    if (hasText != _isTyping) {
      setState(() => _isTyping = hasText);
      _updateTypingStatus();
    }
  }

  void _updateTypingStatus() {
    if (widget.currentUserId != null) {
      final isTyping = _messageFocusNode.hasFocus &&
                      _messageController.text.trim().isNotEmpty;

      ref.read(crewCommunicationNotifierProvider.notifier)
          .setTypingIndicator(widget.crewId, widget.currentUserId!, isTyping);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(),
      body: Column(
        children: [
          // Messages list
          Expanded(
            child: _buildMessagesList(),
          ),

          // Reply indicator
          if (_replyToMessage != null) _buildReplyIndicator(),

          // Typing indicators
          _buildTypingIndicators(),

          // Message input
          _buildMessageInput(),
        ],
      ),
      floatingActionButton: _showScrollToBottom ? _buildScrollToBottomFab() : null,
    );
  }

  PreferredSizeWidget _buildAppBar() {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final isLoading = state.isLoadingForCrew(widget.crewId);
    final isOnline = state.isOnline;

    return AppBar(
      backgroundColor: AppTheme.primaryNavy,
      foregroundColor: AppTheme.white,
      elevation: 2,
      title: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            widget.crewName ?? 'Crew Chat',
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          Row(
            children: [
              Icon(
                isOnline ? Icons.wifi : Icons.wifi_off,
                size: 12,
                color: isOnline ? AppTheme.successGreen : AppTheme.errorRed,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                isOnline ? 'Online' : 'Offline',
                style: AppTheme.labelSmall.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.8),
                ),
              ),
              if (isLoading) ...[
                const SizedBox(width: AppTheme.spacingSm),
                SizedBox(
                  width: 12,
                  height: 12,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppTheme.accentCopper,
                    ),
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
      actions: [
        // Safety quick actions
        PopupMenuButton<String>(
          icon: const Icon(Icons.more_vert, color: AppTheme.white),
          color: AppTheme.white,
          onSelected: _handleAppBarAction,
          itemBuilder: (context) => [
            const PopupMenuItem(
              value: 'safety_alert',
              child: Row(
                children: [
                  Icon(Icons.warning, color: AppTheme.warningOrange),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Send Safety Alert'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'emergency',
              child: Row(
                children: [
                  Icon(Icons.emergency, color: AppTheme.errorRed),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Emergency Alert'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'check_in',
              child: Row(
                children: [
                  Icon(Icons.check_circle, color: AppTheme.successGreen),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Safety Check-in'),
                ],
              ),
            ),
            const PopupMenuItem(
              value: 'crew_info',
              child: Row(
                children: [
                  Icon(Icons.info, color: AppTheme.infoBlue),
                  SizedBox(width: AppTheme.spacingSm),
                  Text('Crew Details'),
                ],
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildMessagesList() {
    return StreamBuilder<List<CrewCommunication>>(
      stream: ref.watch(crewMessagesProvider(widget.crewId)),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _buildLoadingIndicator();
        }

        if (snapshot.hasError) {
          return _buildErrorState(snapshot.error.toString());
        }

        final messages = snapshot.data ?? [];

        if (messages.isEmpty) {
          return _buildEmptyState();
        }

        return ListView.builder(
          controller: _scrollController,
          reverse: true, // Show newest messages at bottom
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
          itemCount: messages.length,
          itemBuilder: (context, index) {
            final message = messages[index];
            final isCurrentUser = message.senderId == widget.currentUserId;
            final showTimestamp = _shouldShowTimestamp(messages, index);
            final showAvatar = _shouldShowAvatar(messages, index);

            return MessageBubble(
              message: message,
              isCurrentUser: isCurrentUser,
              showTimestamp: showTimestamp,
              showAvatar: showAvatar,
              currentUserId: widget.currentUserId,
              onReply: () => _setReplyMessage(message),
              onLongPress: () => _showMessageActions(message),
              enableSwipeToReply: !isCurrentUser,
            ).animate().slideY(
              begin: 0.2,
              duration: const Duration(milliseconds: 300),
              curve: Curves.easeOut,
            ).fadeIn();
          },
        );
      },
    );
  }

  Widget _buildLoadingIndicator() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Loading messages...',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.errorRed.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Failed to load messages',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingLg),
            ElevatedButton(
              onPressed: () {
                ref.read(crewCommunicationNotifierProvider.notifier)
                    .startListeningToMessages(widget.crewId);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.chat_bubble_outline,
              size: 64,
              color: AppTheme.accentCopper.withValues(alpha: 0.5),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Start the conversation',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              'Be the first to share updates, coordinate work, or check in with your crew.',
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

  Widget _buildReplyIndicator() {
    if (_replyToMessage == null) return const SizedBox.shrink();

    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingSm),
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
        border: Border(
          left: BorderSide(
            color: AppTheme.accentCopper,
            width: 3,
          ),
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.reply,
            size: 16,
            color: AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Replying to ${_replyToMessage!.senderName ?? 'Unknown'}',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Text(
                  _replyToMessage!.content,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          IconButton(
            onPressed: _clearReply,
            icon: const Icon(Icons.close),
            iconSize: 18,
            color: AppTheme.textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildTypingIndicators() {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final typingUsers = state.getTypingUsersForCrew(widget.crewId)
        .where((userId) => userId != widget.currentUserId)
        .toList();

    if (typingUsers.isEmpty) return const SizedBox.shrink();

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: [
          AnimatedBuilder(
            animation: _typingAnimation,
            builder: (context, child) {
              _typingAnimationController.repeat();
              return Row(
                children: List.generate(3, (index) {
                  return AnimatedContainer(
                    duration: Duration(milliseconds: 300 + (index * 100)),
                    margin: const EdgeInsets.only(right: 2),
                    width: 6,
                    height: 6,
                    decoration: BoxDecoration(
                      color: AppTheme.accentCopper.withValues(alpha: 
                        0.5 + (0.5 * _typingAnimation.value),
                      ),
                      shape: BoxShape.circle,
                    ),
                  );
                }),
              );
            },
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            _getTypingText(typingUsers),
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.textSecondary,
              fontStyle: FontStyle.italic,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMessageInput() {
    final state = ref.watch(crewCommunicationNotifierProvider);
    final isOnline = state.isOnline;

    return Container(
      decoration: BoxDecoration(
        color: AppTheme.white,
        border: Border(
          top: BorderSide(
            color: AppTheme.lightGray,
            width: AppTheme.borderWidthThin,
          ),
        ),
      ),
      child: Column(
        children: [
          // Message type selector
          if (_selectedMessageType != MessageType.text) _buildMessageTypeIndicator(),

          // Attachment preview
          if (_selectedAttachments.isNotEmpty) _buildAttachmentPreview(),

          // Input row
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingSm),
            child: Row(
              children: [
                // Attachment button
                _buildAttachmentButton(),

                const SizedBox(width: AppTheme.spacingSm),

                // Message input field
                Expanded(
                  child: _buildMessageField(),
                ),

                const SizedBox(width: AppTheme.spacingSm),

                // Send button
                _buildSendButton(isOnline),
              ],
            ),
          ),

          // Safety quick actions
          _buildSafetyQuickActions(),
        ],
      ),
    );
  }

  Widget _buildMessageTypeIndicator() {
    IconData icon;
    Color color;
    String label;

    switch (_selectedMessageType) {
      case MessageType.safetyAlert:
        icon = Icons.warning;
        color = AppTheme.warningOrange;
        label = 'Safety Alert';
        break;
      case MessageType.emergency:
        icon = Icons.emergency;
        color = AppTheme.errorRed;
        label = 'Emergency';
        break;
      case MessageType.jobUpdate:
        icon = Icons.work;
        color = AppTheme.infoBlue;
        label = 'Job Update';
        break;
      default:
        return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      color: color.withValues(alpha: 0.1),
      child: Row(
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            label,
            style: AppTheme.labelSmall.copyWith(
              color: color,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Spacer(),
          IconButton(
            onPressed: () => setState(() => _selectedMessageType = MessageType.text),
            icon: const Icon(Icons.close),
            iconSize: 16,
            color: color,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(minWidth: 24, minHeight: 24),
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentPreview() {
    return Container(
      height: 80,
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: _selectedAttachments.length,
        itemBuilder: (context, index) {
          final file = _selectedAttachments[index];
          return Container(
            width: 60,
            margin: const EdgeInsets.only(right: AppTheme.spacingSm),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppTheme.lightGray),
            ),
            child: Stack(
              children: [
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: Image.file(
                    file,
                    width: 60,
                    height: 60,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 2,
                  right: 2,
                  child: GestureDetector(
                    onTap: () => _removeAttachment(index),
                    child: Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        color: AppTheme.errorRed,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppTheme.white,
                        size: 12,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildAttachmentButton() {
    return PopupMenuButton<String>(
      icon: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: AppTheme.accentCopper.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: const Icon(
          Icons.add,
          color: AppTheme.accentCopper,
        ),
      ),
      onSelected: _handleAttachmentAction,
      itemBuilder: (context) => [
        const PopupMenuItem(
          value: 'camera',
          child: Row(
            children: [
              Icon(Icons.camera_alt, color: AppTheme.primaryNavy),
              SizedBox(width: AppTheme.spacingSm),
              Text('Camera'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'gallery',
          child: Row(
            children: [
              Icon(Icons.photo_library, color: AppTheme.primaryNavy),
              SizedBox(width: AppTheme.spacingSm),
              Text('Gallery'),
            ],
          ),
        ),
        const PopupMenuItem(
          value: 'location',
          child: Row(
            children: [
              Icon(Icons.location_on, color: AppTheme.errorRed),
              SizedBox(width: AppTheme.spacingSm),
              Text('Location'),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessageField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AppTheme.lightGray,
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: TextField(
        controller: _messageController,
        focusNode: _messageFocusNode,
        textCapitalization: TextCapitalization.sentences,
        maxLines: null,
        keyboardType: TextInputType.multiline,
        textInputAction: TextInputAction.newline,
        decoration: InputDecoration(
          hintText: 'Type a message...',
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          border: InputBorder.none,
          enabledBorder: InputBorder.none,
          focusedBorder: InputBorder.none,
        ),
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
        ),
      ),
    );
  }

  Widget _buildSendButton(bool isOnline) {
    final hasContent = _messageController.text.trim().isNotEmpty ||
                      _selectedAttachments.isNotEmpty;

    return GestureDetector(
      onTap: hasContent && isOnline ? _sendMessage : null,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          gradient: hasContent && isOnline
              ? AppTheme.buttonGradient
              : null,
          color: hasContent && isOnline
              ? null
              : AppTheme.lightGray,
          shape: BoxShape.circle,
        ),
        child: Icon(
          Icons.send,
          color: hasContent && isOnline
              ? AppTheme.white
              : AppTheme.textSecondary,
          size: 20,
        ),
      ),
    );
  }

  Widget _buildSafetyQuickActions() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      child: Row(
        children: [
          _buildQuickActionButton(
            icon: Icons.warning,
            label: 'Safety',
            color: AppTheme.warningOrange,
            onTap: () => _showSafetyAlertDialog(),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildQuickActionButton(
            icon: Icons.check_circle,
            label: 'Check-in',
            color: AppTheme.successGreen,
            onTap: () => _showCheckInDialog(),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          _buildQuickActionButton(
            icon: Icons.emergency,
            label: 'Emergency',
            color: AppTheme.errorRed,
            onTap: () => _showEmergencyDialog(),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickActionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
          decoration: BoxDecoration(
            color: color.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(6),
            border: Border.all(
              color: color.withValues(alpha: 0.3),
              width: AppTheme.borderWidthThin,
            ),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, size: 16, color: color),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                label,
                style: AppTheme.labelSmall.copyWith(
                  color: color,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildScrollToBottomFab() {
    return FloatingActionButton.small(
      onPressed: _scrollToBottom,
      backgroundColor: AppTheme.accentCopper,
      foregroundColor: AppTheme.white,
      child: const Icon(Icons.keyboard_arrow_down),
    );
  }

  // Helper Methods

  bool _shouldShowTimestamp(List<CrewCommunication> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index];
    final next = messages[index + 1];

    return current.timestamp.difference(next.timestamp).inMinutes > 5;
  }

  bool _shouldShowAvatar(List<CrewCommunication> messages, int index) {
    if (index == messages.length - 1) return true;

    final current = messages[index];
    final next = messages[index + 1];

    return current.senderId != next.senderId;
  }

  String _getTypingText(List<String> typingUsers) {
    if (typingUsers.isEmpty) return '';
    if (typingUsers.length == 1) return '${typingUsers.first} is typing...';
    if (typingUsers.length == 2) return '${typingUsers.join(' and ')} are typing...';
    return 'Several people are typing...';
  }

  void _scrollToBottom() {
    _scrollController.animateTo(
      0.0,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOut,
    );
  }

  void _setReplyMessage(CrewCommunication message) {
    setState(() {
      _replyToMessage = message;
      _replyToMessageId = message.id;
    });
    _messageFocusNode.requestFocus();
  }

  void _clearReply() {
    setState(() {
      _replyToMessage = null;
      _replyToMessageId = null;
    });
  }

  void _removeAttachment(int index) {
    setState(() {
      _selectedAttachments.removeAt(index);
    });
  }

  // Action Handlers

  void _handleAppBarAction(String action) {
    switch (action) {
      case 'safety_alert':
        _showSafetyAlertDialog();
        break;
      case 'emergency':
        _showEmergencyDialog();
        break;
      case 'check_in':
        _showCheckInDialog();
        break;
      case 'crew_info':
        // Navigate to crew details
        break;
    }
  }

  void _handleAttachmentAction(String action) async {
    switch (action) {
      case 'camera':
        await _pickImageFromCamera();
        break;
      case 'gallery':
        await _pickImageFromGallery();
        break;
      case 'location':
        await _shareLocation();
        break;
    }
  }

  Future<void> _pickImageFromCamera() async {
    try {
      final XFile? image = await _imagePicker.pickImage(
        source: ImageSource.camera,
        imageQuality: 70,
      );
      if (image != null) {
        setState(() {
          _selectedAttachments.add(File(image.path));
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to capture image: $e');
    }
  }

  Future<void> _pickImageFromGallery() async {
    try {
      final List<XFile> images = await _imagePicker.pickMultiImage(
        imageQuality: 70,
        limit: 5,
      );
      if (images.isNotEmpty) {
        setState(() {
          _selectedAttachments.addAll(
            images.map((xfile) => File(xfile.path)),
          );
        });
      }
    } catch (e) {
      _showErrorSnackBar('Failed to pick images: $e');
    }
  }

  Future<void> _shareLocation() async {
    try {
      // Check location permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showErrorSnackBar('Location permission denied');
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        _showErrorSnackBar('Location permission permanently denied');
        return;
      }

      // Get current position
      final Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      // Send location message
      await ref.read(crewCommunicationNotifierProvider.notifier).sendMessage(
        crewId: widget.crewId,
        content: 'Shared current location',
        messageType: MessageType.locationShare,
        attachments: [
          MessageAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            messageId: '',
            fileName: 'location_${DateTime.now().millisecondsSinceEpoch}',
            url: 'geo:${position.latitude},${position.longitude}',
            type: AttachmentType.location,
            sizeBytes: 0,
            uploadedAt: DateTime.now(),
            description: 'Current job site location',
          ),
        ],
      );

      _showSuccessSnackBar('Location shared successfully');
    } catch (e) {
      _showErrorSnackBar('Failed to share location: $e');
    }
  }

  void _sendMessage() async {
    final content = _messageController.text.trim();
    if (content.isEmpty && _selectedAttachments.isEmpty) return;

    try {
      // Prepare attachments
      final List<MessageAttachment> attachments = [];
      for (final file in _selectedAttachments) {
        // Create attachment (URL would be set after upload)
        attachments.add(
          MessageAttachment(
            id: DateTime.now().millisecondsSinceEpoch.toString(),
            messageId: '',
            fileName: file.path.split('/').last,
            url: file.path, // Temporary local path
            type: AttachmentType.image,
            sizeBytes: await file.length(),
            uploadedAt: DateTime.now(),
          ),
        );
      }

      // Send message
      await ref.read(crewCommunicationNotifierProvider.notifier).sendMessage(
        crewId: widget.crewId,
        content: content,
        messageType: _selectedMessageType,
        attachments: attachments.isNotEmpty ? attachments : null,
      );

      // Clear input
      _messageController.clear();
      setState(() {
        _selectedAttachments.clear();
        _selectedMessageType = MessageType.text;
      });
      _clearReply();

      // Scroll to bottom
      _scrollToBottom();

      // Trigger haptic feedback
      HapticFeedback.lightImpact();

    } catch (e) {
      _showErrorSnackBar('Failed to send message: $e');
    }
  }

  void _showMessageActions(CrewCommunication message) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ListTile(
              leading: const Icon(Icons.reply, color: AppTheme.primaryNavy),
              title: const Text('Reply'),
              onTap: () {
                Navigator.pop(context);
                _setReplyMessage(message);
              },
            ),
            ListTile(
              leading: const Icon(Icons.copy, color: AppTheme.primaryNavy),
              title: const Text('Copy'),
              onTap: () {
                Navigator.pop(context);
                Clipboard.setData(ClipboardData(text: message.content));
                _showSuccessSnackBar('Message copied');
              },
            ),
            if (message.type == MessageType.emergency)
              ListTile(
                leading: const Icon(Icons.check_circle, color: AppTheme.successGreen),
                title: const Text('Acknowledge Emergency'),
                onTap: () {
                  Navigator.pop(context);
                  // Handle emergency acknowledgment
                },
              ),
          ],
        ),
      ),
    );
  }

  void _showSafetyAlertDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: Row(
          children: [
            Icon(Icons.warning, color: AppTheme.warningOrange),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Safety Alert'),
          ],
        ),
        content: const Text('Send a safety alert to all crew members?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(crewCommunicationNotifierProvider.notifier)
                  .sendSafetyAnnouncement(
                crewId: widget.crewId,
                content: 'Safety reminder: Stay alert and follow all protocols',
                safetyLevel: SafetyLevel.general,
                urgency: MessageUrgency.normal,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.warningOrange,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Send Alert'),
          ),
        ],
      ),
    );
  }

  void _showEmergencyDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: Row(
          children: [
            Icon(Icons.emergency, color: AppTheme.errorRed),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Emergency Alert'),
          ],
        ),
        content: const Text('Send an emergency alert to all crew members?\n\nThis will notify supervisors and safety coordinators.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              try {
                final position = await Geolocator.getCurrentPosition();
                await ref.read(crewCommunicationNotifierProvider.notifier)
                    .sendEmergencyAlert(
                  crewId: widget.crewId,
                  content: 'EMERGENCY: Immediate assistance required',
                  location: {
                    'latitude': position.latitude,
                    'longitude': position.longitude,
                    'timestamp': DateTime.now().toIso8601String(),
                  },
                );
              } catch (e) {
                await ref.read(crewCommunicationNotifierProvider.notifier)
                    .sendEmergencyAlert(
                  crewId: widget.crewId,
                  content: 'EMERGENCY: Immediate assistance required',
                  location: {},
                );
              }
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Send Emergency'),
          ),
        ],
      ),
    );
  }

  void _showCheckInDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.white,
        title: Row(
          children: [
            Icon(Icons.check_circle, color: AppTheme.successGreen),
            const SizedBox(width: AppTheme.spacingSm),
            const Text('Safety Check-in'),
          ],
        ),
        content: const Text('Report your current safety status to the crew.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(context);
              await ref.read(crewCommunicationNotifierProvider.notifier)
                  .sendSafetyCheckin(
                crewId: widget.crewId,
                content: 'All clear - crew safe and on schedule',
                safetyStatus: SafetyStatus.allClear,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.successGreen,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('All Clear'),
          ),
        ],
      ),
    );
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.errorRed,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _showSuccessSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppTheme.successGreen,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }
}