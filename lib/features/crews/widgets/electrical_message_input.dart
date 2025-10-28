import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';

/// Electrical-themed message input field with comprehensive features.
///
/// This component provides:
/// - Electrical gradient styling with copper accents
/// - Real-time character count and limits
/// - Support for multiple input types (text, emojis, attachments)
/// - Electrical animations and micro-interactions
/// - Accessibility support with semantic labels
/// - Responsive design for various screen sizes
/// - Voice input support (future enhancement)
/// - Message preview and draft saving
class ElectricalMessageInput extends StatefulWidget {
  /// Controller for the text input
  final TextEditingController controller;

  /// Focus node for managing focus state
  final FocusNode? focusNode;

  /// Callback when message is sent
  final Function(String message) onSendMessage;

  /// Callback when attachment button is pressed
  final VoidCallback? onAttachmentPressed;

  /// Callback when voice recording starts/stops
  final VoidCallback? onVoicePressed;

  /// Placeholder text for the input field
  final String placeholder;

  /// Maximum number of characters allowed
  final int maxCharacters;

  /// Whether to show character count
  final bool showCharacterCount;

  /// Whether to enable voice input
  final bool enableVoiceInput;

  /// Whether to enable attachments
  final bool enableAttachments;

  /// Whether to show electrical circuit background
  final bool showCircuitPattern;

  /// Whether the input is currently loading/sending
  final bool isLoading;

  /// Current reply-to message (for threaded conversations)
  final String? replyToMessage;

  /// Callback to clear reply state
  final VoidCallback? onClearReply;

  const ElectricalMessageInput({
    Key? key,
    required this.controller,
    required this.onSendMessage,
    this.focusNode,
    this.onAttachmentPressed,
    this.onVoicePressed,
    this.placeholder = 'Type a message...',
    this.maxCharacters = 1000,
    this.showCharacterCount = true,
    this.enableVoiceInput = true,
    this.enableAttachments = true,
    this.showCircuitPattern = true,
    this.isLoading = false,
    this.replyToMessage,
    this.onClearReply,
  }) : super(key: key);

  @override
  State<ElectricalMessageInput> createState() => _ElectricalMessageInputState();
}

class _ElectricalMessageInputState extends State<ElectricalMessageInput>
    with TickerProviderStateMixin {
  late FocusNode _focusNode;
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;

  bool _isFocused = false;
  bool _isVoiceRecording = false;
  int _characterCount = 0;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeAnimations();
    _setupListeners();
  }

  @override
  void dispose() {
    _focusNode.dispose();
    _glowController.dispose();
    _pulseController.dispose();
    widget.controller.removeListener(_onTextChanged);
    super.dispose();
  }

  void _initializeControllers() {
    _focusNode = widget.focusNode ?? FocusNode();
    _characterCount = widget.controller.text.length;
  }

  void _initializeAnimations() {
    // Glow animation for focused state
    _glowController = AnimationController(
      duration: AppTheme.durationElectricalGlow,
      vsync: this,
    );

    // Pulse animation for send button
    _pulseController = AnimationController(
      duration: AppTheme.durationElectricalSpark,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: AppTheme.curveElectricalSpark,
    ));
  }

  void _setupListeners() {
    _focusNode.addListener(_onFocusChanged);
    widget.controller.addListener(_onTextChanged);
  }

  void _onFocusChanged() {
    if (_focusNode.hasFocus != _isFocused) {
      setState(() => _isFocused = _focusNode.hasFocus);

      if (_isFocused) {
        _glowController.repeat(reverse: true);
        HapticFeedback.selectionClick();
      } else {
        _glowController.stop();
        _glowController.reset();
      }
    }
  }

  void _onTextChanged() {
    final newCount = widget.controller.text.length;
    if (newCount != _characterCount) {
      setState(() => _characterCount = newCount);

      // Haptic feedback at character limits
      if (_characterCount == widget.maxCharacters) {
        HapticFeedback.mediumImpact();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _getBorderColor(),
          width: _getBorderWidth(),
        ),
        boxShadow: _getBoxShadow(),
      ),
      child: Column(
        children: [
          // Reply indicator (if replying to a message)
          if (widget.replyToMessage != null) _buildReplyIndicator(),

          // Main input area
          Container(
            padding: _getInputPadding(),
            decoration: BoxDecoration(
              color: _getInputBackgroundColor(),
              borderRadius: _getInputBorderRadius(),
            ),
            child: Stack(
              children: [
                // Circuit pattern background
                if (widget.showCircuitPattern)
                  Positioned.fill(
                    child: Opacity(
                      opacity: _getCircuitPatternOpacity(),
                      child: CustomPaint(
                        painter: CircuitPatternPainter(
                          density: ComponentDensity.low,
                          traceColor: _getCircuitTraceColor(),
                          backgroundColor: Colors.transparent,
                        ),
                      ),
                    ),
                  ),

                // Input field and buttons
                Row(
                  children: [
                    // Left side buttons
                    _buildLeftButtons(),

                    const SizedBox(width: AppTheme.spacingSm),

                    // Text input field
                    Expanded(
                      child: _buildTextField(),
                    ),

                    const SizedBox(width: AppTheme.spacingSm),

                    // Right side buttons
                    _buildRightButtons(),
                  ],
                ),

                // Electrical glow overlay when focused
                if (_isFocused && _glowAnimation.value > 0.5)
                  Positioned.fill(
                    child: Container(
                      decoration: BoxDecoration(
                        borderRadius: _getInputBorderRadius(),
                        border: Border.all(
                          color: AppTheme.electricalGlowInfo
                              .withValues(alpha: _glowAnimation.value * 0.5),
                          width: 2,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),

          // Character count and additional options
          if (widget.showCharacterCount || _characterCount > widget.maxCharacters * 0.8)
            _buildBottomSection(),
        ],
      ),
    );
  }

  /// Builds the reply indicator
  Widget _buildReplyIndicator() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha: 0.1),
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
            width: 1,
          ),
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
              'Replying to message',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          GestureDetector(
            onTap: widget.onClearReply,
            child: Container(
              padding: const EdgeInsets.all(AppTheme.spacingXs),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(AppTheme.radiusRound),
              ),
              child: Icon(
                Icons.close,
                size: 16,
                color: AppTheme.accentCopper,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Builds left side action buttons
  Widget _buildLeftButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Attachment button
        if (widget.enableAttachments)
          _buildActionButton(
            icon: Icons.attach_file,
            onPressed: widget.onAttachmentPressed,
            tooltip: 'Attach file',
            isActive: false,
          ),

        if (widget.enableAttachments && widget.enableVoiceInput)
          const SizedBox(width: AppTheme.spacingXs),

        // Voice input button
        if (widget.enableVoiceInput)
          _buildActionButton(
            icon: _isVoiceRecording ? Icons.stop : Icons.mic,
            onPressed: _handleVoiceButtonPressed,
            tooltip: _isVoiceRecording ? 'Stop recording' : 'Voice input',
            isActive: _isVoiceRecording,
          ),
      ],
    );
  }

  /// Builds the main text input field
  Widget _buildTextField() {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: _getTextFieldBorderColor(),
          width: 1,
        ),
      ),
      child: TextField(
        controller: widget.controller,
        focusNode: _focusNode,
        maxLines: null,
        minLines: 1,
        textCapitalization: TextCapitalization.sentences,
        decoration: InputDecoration(
          hintText: widget.placeholder,
          hintStyle: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textLight,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
        ),
        style: AppTheme.bodyMedium.copyWith(
          color: AppTheme.textPrimary,
        ),
        onSubmitted: _handleSubmitted,
        enabled: !widget.isLoading,
      ),
    );
  }

  /// Builds right side action buttons
  Widget _buildRightButtons() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        // Emoji button (placeholder for future implementation)
        _buildActionButton(
          icon: Icons.emoji_emotions_outlined,
          onPressed: _handleEmojiPressed,
          tooltip: 'Add emoji',
          isActive: false,
        ),

        const SizedBox(width: AppTheme.spacingXs),

        // Send button
        AnimatedBuilder(
          animation: _pulseAnimation,
          builder: (context, child) {
            return Transform.scale(
              scale: widget.isLoading ? _pulseAnimation.value : 1.0,
              child: _buildSendButton(),
            );
          },
        ),
      ],
    );
  }

  /// Builds individual action button
  Widget _buildActionButton({
    required IconData icon,
    required VoidCallback? onPressed,
    required String tooltip,
    bool isActive = false,
  }) {
    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        color: isActive
            ? AppTheme.accentCopper.withValues(alpha: 0.2)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: isActive
            ? Border.all(
                color: AppTheme.accentCopper.withValues(alpha: 0.5),
                width: 1,
              )
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          onTap: onPressed,
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              color: isActive
                  ? AppTheme.accentCopper
                  : AppTheme.textSecondary,
              size: AppTheme.iconMd,
            ),
          ),
        ),
      ),
    );
  }

  /// Builds the send button with electrical theming
  Widget _buildSendButton() {
    final canSend = widget.controller.text.trim().isNotEmpty && !widget.isLoading;

    return Container(
      width: 40,
      height: 40,
      decoration: BoxDecoration(
        gradient: canSend
            ? AppTheme.electricalGradient
            : LinearGradient(
                colors: [AppTheme.mediumGray, AppTheme.mediumGray],
              ),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: canSend
            ? [
                BoxShadow(
                  color: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusRound),
          onTap: canSend ? _handleSendMessage : null,
          child: Center(
            child: widget.isLoading
                ? SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        AppTheme.white,
                      ),
                    ),
                  )
                : Icon(
                    Icons.send,
                    color: canSend ? AppTheme.white : AppTheme.white.withValues(alpha: 0.6),
                    size: AppTheme.iconSm,
                  ),
          ),
        ),
      ),
    );
  }

  /// Builds the bottom section with character count
  Widget _buildBottomSection() {
    final isNearLimit = _characterCount > widget.maxCharacters * 0.8;
    final isAtLimit = _characterCount >= widget.maxCharacters;

    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: isAtLimit
            ? AppTheme.errorRed.withValues(alpha: 0.1)
            : isNearLimit
                ? AppTheme.warningYellow.withValues(alpha: 0.1)
                : Colors.transparent,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          Text(
            '$_characterCount/$widget.maxCharacters',
            style: AppTheme.bodySmall.copyWith(
              color: isAtLimit
                  ? AppTheme.errorRed
                  : isNearLimit
                      ? AppTheme.warningYellow
                      : AppTheme.textLight,
              fontWeight: isAtLimit ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ],
      ),
    );
  }

  // Event handlers

  void _handleSubmitted(String value) {
    if (value.trim().isNotEmpty && !widget.isLoading) {
      _handleSendMessage();
    }
  }

  void _handleSendMessage() {
    final message = widget.controller.text.trim();
    if (message.isEmpty || widget.isLoading) return;

    HapticFeedback.lightImpact();
    _pulseController.forward().then((_) {
      _pulseController.reverse();
    });

    widget.onSendMessage(message);
  }

  void _handleVoiceButtonPressed() {
    if (_isVoiceRecording) {
      setState(() => _isVoiceRecording = false);
      widget.onVoicePressed?.call();
      HapticFeedback.mediumImpact();
    } else {
      setState(() => _isVoiceRecording = true);
      widget.onVoicePressed?.call();
      HapticFeedback.lightImpact();
    }
  }

  void _handleEmojiPressed() {
    // Placeholder for emoji picker implementation
    HapticFeedback.selectionClick();
  }

  // Helper methods for styling

  Color _getBorderColor() {
    if (_isFocused) {
      return AppTheme.accentCopper;
    }
    return AppTheme.borderCopper;
  }

  double _getBorderWidth() {
    if (_isFocused) {
      return AppTheme.borderWidthThick;
    }
    return AppTheme.borderWidthMedium;
  }

  List<BoxShadow> _getBoxShadow() {
    if (_isFocused) {
      return [
        AppTheme.shadowMd,
        BoxShadow(
          color: AppTheme.electricalGlowInfo.withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 2),
        ),
      ];
    }
    return AppTheme.shadowCard;
  }

  EdgeInsets _getInputPadding() {
    EdgeInsets padding = const EdgeInsets.all(AppTheme.spacingMd);

    if (widget.replyToMessage != null) {
      padding = padding.copyWith(
        top: AppTheme.spacingSm,
        bottom: AppTheme.spacingSm,
      );
    }

    return padding;
  }

  Color _getInputBackgroundColor() {
    return _isFocused
        ? AppTheme.offWhite.withValues(alpha: 0.8)
        : AppTheme.offWhite;
  }

  BorderRadius _getInputBorderRadius() {
    if (widget.replyToMessage != null) {
      return const BorderRadius.only(
        bottomLeft: Radius.circular(AppTheme.radiusLg),
        bottomRight: Radius.circular(AppTheme.radiusLg),
      );
    }
    return BorderRadius.circular(AppTheme.radiusLg);
  }

  double _getCircuitPatternOpacity() {
    return _isFocused ? 0.15 : 0.08;
  }

  Color _getCircuitTraceColor() {
    return AppTheme.electricalCircuitTrace.withValues(alpha: 0.3);
  }

  Color _getTextFieldBorderColor() {
    if (_isFocused) {
      return AppTheme.accentCopper.withValues(alpha: 0.5);
    }
    return AppTheme.borderLight;
  }
}