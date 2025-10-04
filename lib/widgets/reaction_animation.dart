import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'social_animations.dart';
import '../design_system/app_theme.dart';

/// Enhanced reaction animation with bounce, particle effects, and electrical theme
class EnhancedReactionAnimation extends StatefulWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final Duration? animationDuration;
  final Color? glowColor;
  
  const EnhancedReactionAnimation({
    super.key,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.size = 32.0,
    this.animationDuration,
    this.glowColor,
  });
  
  @override
  State<EnhancedReactionAnimation> createState() => _EnhancedReactionAnimationState();
}

class _EnhancedReactionAnimationState extends State<EnhancedReactionAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _bounceAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _rotationAnimation;
  late Animation<double> _glowAnimation;
  late Animation<double> _particleAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.reactionAnimationDuration,
      vsync: this,
    );
    
    // Bounce animation on selection
    _bounceAnimation = Tween<double>(
      begin: 1.0,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: SocialAnimations.reactionCurve,
    ));
    
    // Scale animation
    _scaleAnimation = Tween<double>(
      begin: 0.8,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    // Rotation animation
    _rotationAnimation = Tween<double>(
      begin: 0.0,
      end: math.pi / 12, // 15 degrees
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Glow animation
    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Particle animation
    _particleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: SocialAnimations.particleCurve,
    ));
    
    // Trigger animation when selected
    if (widget.isSelected) {
      _controller.forward();
    }
  }
  
  @override
  void didUpdateWidget(EnhancedReactionAnimation oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    if (widget.isSelected != oldWidget.isSelected) {
      if (widget.isSelected) {
        _controller.forward();
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
    return GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Glow effect
              if (widget.isSelected && _glowAnimation.value > 0)
                Container(
                  width: widget.size * 2 * _glowAnimation.value,
                  height: widget.size * 2 * _glowAnimation.value,
                  decoration: BoxDecoration(
                    color: (widget.glowColor ?? SocialAnimations.reactionGlowColor)
                        .withOpacity(0.3 * _glowAnimation.value),
                    shape: BoxShape.circle,
                  ),
                ),
              
              // Animated emoji
              Transform.scale(
                scale: _scaleAnimation.value,
                child: Transform.rotate(
                  angle: _rotationAnimation.value,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    padding: EdgeInsets.all(widget.isSelected ? 4.0 : 0.0),
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: widget.isSelected
                          ? Border.all(
                              color: (widget.glowColor ?? SocialAnimations.reactionGlowColor)
                                  .withOpacity(0.8 * _glowAnimation.value),
                              width: 2.0,
                            )
                          : null,
                    ),
                    child: Text(
                      widget.emoji,
                      style: TextStyle(
                        fontSize: widget.size,
                        height: 1.0,
                      ),
                    ),
                  ),
                ),
              ),
              
              // Particle effects
              if (widget.isSelected && _particleAnimation.value > 0)
                _buildParticleEffects(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildParticleEffects() {
    final particles = SocialAnimations.generateParticles(
      count: 6,
      area: Size(widget.size * 2, widget.size * 2),
      color: widget.glowColor ?? SocialAnimations.particleCopperColor,
      minSize: 1.5,
      maxSize: 3.0,
    );
    
    return Stack(
      children: particles.map((particle) {
        return AnimatedParticle(
          particle: particle,
          progress: _particleAnimation.value,
        );
      }).toList(),
    );
  }
}

/// Reaction picker with staggered animation
class AnimatedReactionPicker extends StatefulWidget {
  final List<String> emojis;
  final String? selectedEmoji;
  final ValueChanged<String> onReactionSelected;
  final double size;
  final Duration? animationDuration;
  final Color? glowColor;
  
  const AnimatedReactionPicker({
    super.key,
    required this.emojis,
    this.selectedEmoji,
    required this.onReactionSelected,
    this.size = 32.0,
    this.animationDuration,
    this.glowColor,
  });
  
  @override
  State<AnimatedReactionPicker> createState() => _AnimatedReactionPickerState();
}

class _AnimatedReactionPickerState extends State<AnimatedReactionPicker> {
  late List<AnimationController> _controllers;
  late List<Animation<double>> _animations;
  
  @override
  void initState() {
    super.initState();
    
    _controllers = List.generate(
      widget.emojis.length,
      (index) => AnimationController(
        duration: widget.animationDuration ?? SocialAnimations.reactionAnimationDuration,
        vsync: this,
      ),
    );
    
    _animations = _controllers.map((controller) {
      return Tween<double>(
        begin: 0.0,
        end: 1.0,
      ).animate(CurvedAnimation(
        parent: controller,
        curve: Curves.elasticOut,
      ));
    }).toList();
    
    // Animate reactions with stagger
    for (int i = 0; i < _controllers.length; i++) {
      Future.delayed(Duration(milliseconds: i * 100), () {
        if (mounted) {
          _controllers[i].forward();
        }
      });
    }
  }
  
  @override
  void dispose() {
    for (var controller in _controllers) {
      controller.dispose();
    }
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: widget.emojis.asMap().entries.map((entry) {
        final index = entry.key;
        final emoji = entry.value;
        final isSelected = widget.selectedEmoji == emoji;
        
        return AnimatedReactionButton(
          emoji: emoji,
          isSelected: isSelected,
          onTap: () {
            widget.onReactionSelected(emoji);
            // Trigger animation
            _controllers[index].forward().then((_) {
              _controllers[index].reverse();
            });
          },
          size: widget.size,
          animationDuration: widget.animationDuration,
          glowColor: widget.glowColor,
          animation: _animations[index],
        );
      }).toList(),
    );
  }
}

/// Individual reaction button with animation
class AnimatedReactionButton extends StatelessWidget {
  final String emoji;
  final bool isSelected;
  final VoidCallback onTap;
  final double size;
  final Duration? animationDuration;
  final Color? glowColor;
  final Animation<double>? animation;
  
  const AnimatedReactionButton({
    super.key,
    required this.emoji,
    required this.isSelected,
    required this.onTap,
    this.size = 32.0,
    this.animationDuration,
    this.glowColor,
    this.animation,
  });
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedBuilder(
        animation: animation ?? const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: animation?.value ?? 1.0,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 4.0),
              padding: EdgeInsets.all(isSelected ? 4.0 : 0.0),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: isSelected
                    ? Border.all(
                        color: (glowColor ?? SocialAnimations.reactionGlowColor)
                            .withOpacity(0.8 * (animation?.value ?? 1.0)),
                        width: 2.0,
                      )
                    : null,
              ),
              child: Text(
                emoji,
                style: TextStyle(
                  fontSize: size,
                  height: 1.0,
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}

/// Reaction popup with electrical effects
class ReactionPopup extends StatefulWidget {
  final Offset position;
  final List<String> emojis;
  final ValueChanged<String> onReactionSelected;
  final Duration? animationDuration;
  final Color? glowColor;
  
  const ReactionPopup({
    super.key,
    required this.position,
    required this.emojis,
    required this.onReactionSelected,
    this.animationDuration,
    this.glowColor,
  });
  
  @override
  State<ReactionPopup> createState() => _ReactionPopupState();
}

class _ReactionPopupState extends State<ReactionPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.reactionAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _controller.forward();
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: widget.position.dx,
      top: widget.position.dy,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: Material(
            color: Colors.transparent,
            child: Container(
              padding: const EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                color: AppTheme.surfaceElevated,
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                border: Border.all(
                  color: widget.glowColor ?? SocialAnimations.reactionGlowColor,
                  width: 1.0,
                ),
                boxShadow: [
                  BoxShadow(
                    color: (widget.glowColor ?? SocialAnimations.reactionGlowColor)
                        .withOpacity(0.3),
                    blurRadius: 10,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: AnimatedReactionPicker(
                emojis: widget.emojis,
                onReactionSelected: widget.onReactionSelected,
                size: 32.0,
                glowColor: widget.glowColor,
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// Floating reaction with electrical trail
class FloatingReaction extends StatefulWidget {
  final String emoji;
  final Offset startPosition;
  final Offset endPosition;
  final Duration duration;
  final VoidCallback? onComplete;
  final double size;
  
  const FloatingReaction({
    super.key,
    required this.emoji,
    required this.startPosition,
    required this.endPosition,
    this.duration = const Duration(milliseconds: 1000),
    this.onComplete,
    this.size = 24.0,
  });
  
  @override
  State<FloatingReaction> createState() => _FloatingReactionState();
}

class _FloatingReactionState extends State<FloatingReaction>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _positionAnimation;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    );
    
    _positionAnimation = Tween<Offset>(
      begin: widget.startPosition,
      end: widget.endPosition,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));
    
    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(
      begin: 1.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _controller.forward().whenComplete(() {
      widget.onComplete?.call();
    });
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
        return Positioned(
          left: _positionAnimation.value.dx,
          top: _positionAnimation.value.dy,
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: Transform.scale(
              scale: _scaleAnimation.value,
              child: Text(
                widget.emoji,
                style: TextStyle(
                  fontSize: widget.size,
                  height: 1.0,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}