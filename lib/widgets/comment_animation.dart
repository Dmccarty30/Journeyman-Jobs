import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'social_animations.dart';
import '../design_system/app_theme.dart';

/// A widget that provides a slide, scale, and fade animation for its child.
///
/// This is typically used to animate comments appearing or disappearing in a list.
class CommentAnimation extends StatefulWidget {
  /// Controls whether the child is visible and the animation is running.
  final bool isVisible;
  /// The widget to be animated.
  final Widget child;
  /// The total duration of the animation.
  final Duration? animationDuration;
  /// The curve to apply to the slide animation.
  final Curve? curve;
  /// The starting offset for the slide animation. Defaults to `Offset(0, 0.5)`.
  final Offset? beginOffset;
  /// The starting scale factor for the scale animation. Defaults to `0.8`.
  final double? beginScale;
  /// An optional callback that fires when the animation completes.
  final VoidCallback? onAnimationComplete;
  
  /// Creates a [CommentAnimation] widget.
  const CommentAnimation({
    super.key,
    required this.isVisible,
    required this.child,
    this.animationDuration,
    this.curve,
    this.beginOffset,
    this.beginScale,
    this.onAnimationComplete,
  });
  
  @override
  State<CommentAnimation> createState() => _CommentAnimationState();
}

class _CommentAnimationState extends State<CommentAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.commentAnimationDuration,
      vsync: this,
    );
    
    _slideAnimation = Tween<Offset>(
      begin: widget.beginOffset ?? const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve ?? Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: widget.beginScale ?? 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Trigger animation when visible
    if (widget.isVisible) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(CommentAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isVisible != oldWidget.isVisible) {
      if (widget.isVisible) {
        _controller.forward().then((_) {
          widget.onAnimationComplete?.call();
        });
      } else {
        _controller.reverse();
      }
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return FadeTransition(
          opacity: _fadeAnimation,
          child: SlideTransition(
            position: _slideAnimation,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: widget.child,
            ),
          ),
        );
      },
    );
  }
}

/// A widget that displays an animated "is typing" indicator.
///
/// It shows a text label followed by three pulsing dots to signify activity.
class TypingIndicator extends StatefulWidget {
  /// The text to display next to the pulsing dots (e.g., "User is typing").
  final String text;
  /// The color of the text and dots.
  final Color? color;
  /// The font size of the text.
  final double? fontSize;
  /// The duration of one full pulse animation cycle.
  final Duration? pulseDuration;
  
  /// Creates a [TypingIndicator] widget.
  const TypingIndicator({
    super.key,
    required this.text,
    this.color,
    this.fontSize,
    this.pulseDuration,
  });
  
  @override
  State<TypingIndicator> createState() => _TypingIndicatorState();
}

class _TypingIndicatorState extends State<TypingIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.pulseDuration ?? SocialAnimations.typingAnimationDuration,
      vsync: this,
    );
    
    _pulseAnimation = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    _controller.repeat(reverse: true);
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              widget.text,
              style: TextStyle(
                color: widget.color ?? AppTheme.textSecondary,
                fontSize: widget.fontSize ?? AppTheme.bodySmall.fontSize,
              ),
            ),
            const SizedBox(width: 4),
            Row(
              mainAxisSize: MainAxisSize.min,
              children: List.generate(3, (index) {
                return AnimatedContainer(
                  duration: Duration(
                    milliseconds: (index * 200) + (_controller.value * 1000).toInt(),
                  ),
                  margin: const EdgeInsets.symmetric(horizontal: 1),
                  width: 4,
                  height: 4 * _pulseAnimation.value,
                  decoration: BoxDecoration(
                    color: widget.color ?? AppTheme.textSecondary,
                    shape: BoxShape.circle,
                  ),
                );
              }),
            ),
          ],
        );
      },
    );
  }
}

/// A widget that displays a list of comments with a staggered animation effect.
///
/// Each comment in the list animates in sequentially.
class AnimatedCommentList extends StatefulWidget {
  /// The list of comment widgets to display and animate.
  final List<Widget> comments;
  /// The delay between the start of each comment's animation.
  final Duration? staggerDuration;
  /// The duration of the animation for each individual comment.
  final Duration? animationDuration;
  /// The axis along which the comments should animate in.
  final Axis direction;
  
  /// Creates an [AnimatedCommentList] widget.
  const AnimatedCommentList({
    super.key,
    required this.comments,
    this.staggerDuration,
    this.animationDuration,
    this.direction = Axis.vertical,
  });
  
  @override
  State<AnimatedCommentList> createState() => _AnimatedCommentListState();
}

class _AnimatedCommentListState extends State<AnimatedCommentList> {
  @override
  Widget build(BuildContext context) {
    return Column(
      children: widget.comments.asMap().entries.map((entry) {
        final index = entry.key;
        final comment = entry.value;
        
        return CommentAnimation(
          isVisible: true,
          beginOffset: widget.direction == Axis.vertical 
              ? const Offset(0, 0.3) 
              : const Offset(0.3, 0),
          beginScale: 0.9,
          animationDuration: widget.animationDuration,
          onAnimationComplete: () {
            // Animation complete callback if needed
          },
          child: comment,
        );
      }).toList(),
    );
  }
}

/// An animated text input field designed for entering comments.
///
/// It features a border and scale animation that activates when the field gains focus.
class AnimatedCommentInput extends StatefulWidget {
  /// The controller for the text field.
  final TextEditingController? controller;
  /// The focus node to control the focus state of the text field.
  final FocusNode? focusNode;
  /// The hint text to display when the input field is empty.
  final String? hintText;
  /// A callback that fires when the send button is pressed.
  final VoidCallback? onSend;
  /// A callback that fires when the text in the input field changes.
  final ValueChanged<String>? onTextChanged;
  /// The duration of the focus animation.
  final Duration? animationDuration;
  
  /// Creates an [AnimatedCommentInput] widget.
  const AnimatedCommentInput({
    super.key,
    this.controller,
    this.focusNode,
    this.hintText,
    this.onSend,
    this.onTextChanged,
    this.animationDuration,
  });
  
  @override
  State<AnimatedCommentInput> createState() => _AnimatedCommentInputState();
}

class _AnimatedCommentInputState extends State<AnimatedCommentInput>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _borderAnimation;
  late Animation<double> _scaleAnimation;
  bool _isFocused = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.commentAnimationDuration,
      vsync: this,
    );
    
    _borderAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 1.05,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Listen to focus changes
    widget.focusNode?.addListener(_onFocusChange);
  }
  
  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    _controller.dispose();
    super.dispose();
  }
  
  void _onFocusChange() {
    final wasFocused = _isFocused;
    _isFocused = widget.focusNode?.hasFocus ?? false;
    
    if (wasFocused != _isFocused) {
      if (_isFocused) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
    }
  }
  
  void _handleSend() {
    if (widget.controller?.text.trim().isNotEmpty ?? false) {
      widget.onSend?.call();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            border: Border.all(
              color: _isFocused
                  ? SocialAnimations.commentBorderColor
                  : AppTheme.dividerColor,
              width: 1 * _borderAnimation.value,
            ),
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            color: AppTheme.surface,
          ),
          child: Row(
            children: [
              Expanded(
                child: TextField(
                  controller: widget.controller,
                  focusNode: widget.focusNode,
                  onChanged: widget.onTextChanged,
                  decoration: InputDecoration(
                    hintText: widget.hintText ?? 'Add a comment...',
                    hintStyle: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 12,
                    ),
                  ),
                  onSubmitted: (_) => _handleSend(),
                ),
              ),
              AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                margin: const EdgeInsets.only(right: 8),
                child: IconButton(
                  icon: Icon(
                    Icons.send,
                    color: _isFocused
                        ? SocialAnimations.commentBorderColor
                        : AppTheme.textSecondary,
                    size: 20,
                  ),
                  onPressed: _handleSend,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

/// A widget that displays a comment thread that can be expanded and collapsed
/// with a smooth animation.
class AnimatedCommentThread extends StatefulWidget {
  /// The list of comment widgets in the thread.
  final List<Widget> comments;
  /// The widget to display as the header, which also acts as the toggle button.
  final Widget header;
  /// The initial expanded state of the thread.
  final bool isExpanded;
  /// The duration of the expand/collapse animation.
  final Duration? animationDuration;
  /// An optional callback that fires when the thread is toggled.
  final VoidCallback? onToggle;
  
  /// Creates an [AnimatedCommentThread] widget.
  const AnimatedCommentThread({
    super.key,
    required this.comments,
    required this.header,
    this.isExpanded = false,
    this.animationDuration,
    this.onToggle,
  });
  
  @override
  State<AnimatedCommentThread> createState() => _AnimatedCommentThreadState();
}

class _AnimatedCommentThreadState extends State<AnimatedCommentThread>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _heightAnimation;
  late Animation<double> _opacityAnimation;
  bool _isExpanded = false;
  
  @override
  void initState() {
    super.initState();
    _isExpanded = widget.isExpanded;
    
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.commentAnimationDuration,
      vsync: this,
    );
    
    _heightAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _opacityAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    if (_isExpanded) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(AnimatedCommentThread oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isExpanded != oldWidget.isExpanded) {
      if (widget.isExpanded) {
        _controller.forward();
      } else {
        _controller.reverse();
      }
      _isExpanded = widget.isExpanded;
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        GestureDetector(
          onTap: () {
            widget.onToggle?.call();
            setState(() {
              _isExpanded = !_isExpanded;
              if (_isExpanded) {
                _controller.forward();
              } else {
                _controller.reverse();
              }
            });
          },
          child: widget.header,
        ),
        AnimatedBuilder(
          animation: _controller,
          builder: (context, child) {
            return ClipRect(
              child: Align(
                heightFactor: _heightAnimation.value,
                child: Opacity(
                  opacity: _opacityAnimation.value,
                  child: child,
                ),
              ),
            );
          },
          child: Column(
            children: widget.comments,
          ),
        ),
      ],
    );
  }
}

/// A widget that displays a numerical counter with an animation that "counts up"
/// from zero to the target [count].
///
/// This is typically used for displaying comment or like counts.
class AnimatedCommentCounter extends StatefulWidget {
  /// The target number to count up to.
  final int count;
  /// The label to display after the count (e.g., "comments"). Defaults to "comment" or "comments".
  final String? label;
  /// The color of the text.
  final Color? color;
  /// The duration of the counting animation.
  final Duration? animationDuration;
  
  /// Creates an [AnimatedCommentCounter] widget.
  const AnimatedCommentCounter({
    super.key,
    required this.count,
    this.label,
    this.color,
    this.animationDuration,
  });
  
  @override
  State<AnimatedCommentCounter> createState() => _AnimatedCommentCounterState();
}

class _AnimatedCommentCounterState extends State<AnimatedCommentCounter>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<int> _countAnimation;
  int _displayedCount = 0;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.commentAnimationDuration,
      vsync: this,
    );
    
    _countAnimation = IntTween(
      begin: 0,
      end: widget.count,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _controller.forward();
  }
  
  @override
  void didUpdateWidget(AnimatedCommentCounter oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.count != oldWidget.count) {
      _controller.forward(from: 0).then((_) {
        _controller.reset();
        _controller.forward();
      });
    }
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Text(
          '${_countAnimation.value} ${widget.label ?? (widget.count == 1 ? 'comment' : 'comments')}',
          style: AppTheme.bodySmall.copyWith(
            color: widget.color ?? AppTheme.textSecondary,
            fontWeight: FontWeight.w500,
          ),
        );
      },
    );
  }
}