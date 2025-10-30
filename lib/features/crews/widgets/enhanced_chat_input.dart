import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/jj_electrical_toast.dart';
import 'realtime_presence_indicators.dart';

/// Enhanced chat input widget with real-time typing indicators,
/// attachment support, and electrical theme integration.
class EnhancedChatInput extends ConsumerStatefulWidget {
  final String crewId;
  final Function(String) onMessageSent;
  final bool enabled;

  const EnhancedChatInput({
    Key? key,
    required this.crewId,
    required this.onMessageSent,
    this.enabled = true,
  }) : super(key: key);

  @override
  ConsumerState<EnhancedChatInput> createState() => _EnhancedChatInputState();
}

class _EnhancedChatInputState extends ConsumerState<EnhancedChatInput>
    with TickerProviderStateMixin {
  final TextEditingController _textController = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  
  bool _isTyping = false;
  bool _isRecording = false;
  bool _showAttachments = false;
  String _typingText = '';
  
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _setupAnimations();
    _setupTypingListener();
  }

  void _setupAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(
      begin: 0.8,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutBack,
    ));
  }

  void _setupTypingListener() {
    _textController.addListener(_onTextChanged);
    _focusNode.addListener(_onFocusChanged);
  }

  void _onTextChanged() {
    final text = _textController.text;
    
    if (text != _typingText) {
      setState(() {
        _typingText = text;
        _isTyping = text.isNotEmpty;
      });

      // Notify typing status to other users
      if (_isTyping) {
        _notifyTypingStarted();
      } else {
        _notifyTypingStopped();
      }
    }
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus) {
      // Handle focus gained
    } else {
      // Handle focus lost
      _notifyTypingStopped();
    }
  }

  void _notifyTypingStarted() {
    // This would send typing notification to Firebase
    // ref.read(typingNotifierProvider.notifier).startTyping(widget.crewId);
  }

  void _notifyTypingStopped() {
    // This would stop typing notification to Firebase
    // ref.read(typingNotifierProvider.notifier).stopTyping(widget.crewId);
  }

  @override
  void dispose() {
    _textController.removeListener(_onTextChanged);
    _focusNode.removeListener(_onFocusChanged);
    _textController.dispose();
    _focusNode.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    _notifyTypingStopped();
    super.dispose();
  }

  Future<void> _sendMessage() async {
    final text = _textController.text.trim();
    if (text.isEmpty) return;

    try {
      await widget.onMessageSent(text);
      _textController.clear();
      setState(() {
        _isTyping = false;
        _typingText = '';
      });
      _notifyTypingStopped();
    } catch (e) {
      if (mounted) {
        JJElectricalToast.showError(
          context: context,
          message: 'Failed to send message: $e',
        );
      }
    }
  }

  void _toggleAttachments() {
    setState(() {
      _showAttachments = !_showAttachments;
    });

    if (_showAttachments) {
      _slideController.forward();
    } else {
      _slideController.reverse();
    }
  }

  void _toggleVoiceRecording() {
    setState(() {
      _isRecording = !_isRecording;
    });

    if (_isRecording) {
      _startVoiceRecording();
    } else {
      _stopVoiceRecording();
    }
  }

  void _startVoiceRecording() {
    // Implement voice recording functionality
    JJElectricalToast.showInfo(
      context: context,
      message: 'Voice recording started',
    );
  }

  void _stopVoiceRecording() {
    // Implement voice recording stop functionality
    JJElectricalToast.showInfo(
      context: context,
      message: 'Voice recording stopped',
    );
  }

  void _sendLocation() {
    // Implement location sharing functionality
    JJElectricalToast.showInfo(
      context: context,
      message: 'Location sharing feature coming soon',
    );
  }

  void _sendPhoto() {
    // Implement photo sharing functionality
    JJElectricalToast.showInfo(
      context: context,
      message: 'Photo sharing feature coming soon',
    );
  }

  void _sendDocument() {
    // Implement document sharing functionality
    JJElectricalToast.showInfo(
      context: context,
      message: 'Document sharing feature coming soon',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // Typing indicator from other users
        Consumer(
          builder: (context, ref, child) {
            // final typingUsers = ref.watch(typingUsersProvider(widget.crewId));
            // For now, show empty typing indicator
            return const SizedBox.shrink(); // TypingIndicator(typingUserIds: [], userNames: {});
          },
        ),
        
        // Attachments panel
        if (_showAttachments)
          SlideTransition(
            position: _slideAnimation,
            child: _buildAttachmentsPanel(),
          ),
        
        // Main input area
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.primaryNavy,
            border: Border(
              top: BorderSide(
                color: AppTheme.accentCopper.withOpacity(0.2),
              ),
            ),
          ),
          child: Column(
            children: [
              _buildMainInputRow(),
              if (_isRecording) _buildRecordingIndicator(),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMainInputRow() {
    return Row(
      children: [
        // Attachment button
        IconButton(
          onPressed: widget.enabled ? _toggleAttachments : null,
          icon: Icon(
            _showAttachments ? Icons.close : Icons.attach_file,
            color: widget.enabled 
                ? AppTheme.accentCopper 
                : AppTheme.accentCopper.withOpacity(0.5),
          ),
        ),
        
        // Message input field
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.1),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: AppTheme.accentCopper.withOpacity(0.3),
              ),
            ),
            child: TextField(
              controller: _textController,
              focusNode: _focusNode,
              enabled: widget.enabled,
              style: AppTheme.bodyText.copyWith(
                color: Colors.white,
              ),
              decoration: InputDecoration(
                hintText: 'Type a message...',
                hintStyle: AppTheme.bodyText.copyWith(
                  color: Colors.white.withOpacity(0.5),
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
              ),
              maxLines: null,
              textCapitalization: TextCapitalization.sentences,
            ),
          ),
        ),
        
        const SizedBox(width: 8),
        
        // Voice recording button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: _isRecording ? _pulseAnimation.value : 1.0,
              child: IconButton(
                onPressed: widget.enabled ? _toggleVoiceRecording : null,
                icon: Icon(
                  _isRecording ? Icons.stop : Icons.mic,
                  color: _isRecording 
                      ? Colors.red 
                      : (widget.enabled 
                          ? AppTheme.accentCopper 
                          : AppTheme.accentCopper.withOpacity(0.5)),
                ),
              ),
            );
          },
        ),
        
        // Send button
        IconButton(
          onPressed: (widget.enabled && _textController.text.trim().isNotEmpty) 
              ? _sendMessage 
              : null,
          icon: Icon(
            Icons.send,
            color: (widget.enabled && _textController.text.trim().isNotEmpty)
                ? AppTheme.accentCopper 
                : AppTheme.accentCopper.withOpacity(0.5),
          ),
        ),
      ],
    );
  }

  Widget _buildAttachmentsPanel() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy,
        border: Border(
          top: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.2),
          ),
        ),
      ),
      child: Column(
        children: [
          Row(
            children: [
              Text(
                'Share',
                style: AppTheme.bodyText.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              IconButton(
                onPressed: _toggleAttachments,
                icon: Icon(
                  Icons.close,
                  color: AppTheme.accentCopper,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildAttachmentButton(
                icon: Icons.camera_alt,
                label: 'Photo',
                onTap: _sendPhoto,
              ),
              _buildAttachmentButton(
                icon: Icons.location_on,
                label: 'Location',
                onTap: _sendLocation,
              ),
              _buildAttachmentButton(
                icon: Icons.description,
                label: 'Document',
                onTap: _sendDocument,
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildAttachmentButton({
    required IconData icon,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppTheme.accentCopper.withOpacity(0.3),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              icon,
              color: AppTheme.accentCopper,
              size: 24,
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

  Widget _buildRecordingIndicator() {
    return Container(
      margin: const EdgeInsets.only(top: 8),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.red.withOpacity(0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Colors.red.withOpacity(0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius: BorderRadius.circular(6),
                ),
              );
            },
          ),
          const SizedBox(width: 8),
          Text(
            'Recording... Tap to stop',
            style: AppTheme.caption.copyWith(
              color: Colors.red,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }
}
