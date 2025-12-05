import 'package:flutter/material.dart';
import 'social_animations.dart';
import '../../../design_system/app_theme.dart';

/// Comment animation with slide-in effects and transitions
class CommentAnimation extends StatefulWidget {
  final bool isVisible;
  final Widget child;
  final Duration? animationDuration;
  final Curve? curve;
  final Offset? beginOffset;
  final double? beginScale;
  final VoidCallback? onAnimationComplete;
  
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

/// Typing indicator with pulse animation
class TypingIndicator extends StatefulWidget {
  final String text;
  final Color? color;
  final double? fontSize;
  final Duration? pulseDuration;
  
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

/// Staggered comment list with animation
class AnimatedCommentList extends StatefulWidget {
  final List<Widget> comments;
  final Duration? staggerDuration;
  final Duration? animationDuration;
  final Axis direction;
  
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

/// Comment input with focus animation
class AnimatedCommentInput extends StatefulWidget {
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final String? hintText;
  final VoidCallback? onSend;
  final ValueChanged<String>? onTextChanged;
  final Duration? animationDuration;
  
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

/// Comment thread with expand/collapse animation
class AnimatedCommentThread extends StatefulWidget {
  final List<Widget> comments;
  final Widget header;
  final bool isExpanded;
  final Duration? animationDuration;
  final VoidCallback? onToggle;
  
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

/// Comment counter with animation
class AnimatedCommentCounter extends StatefulWidget {
  final int count;
  final String? label;
  final Color? color;
  final Duration? animationDuration;
  
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