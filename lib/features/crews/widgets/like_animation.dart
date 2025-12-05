import 'package:flutter/material.dart';
import 'dart:math' as math;
import 'social_animations.dart';
import '../../../design_system/app_theme.dart';

/// Like animation widget with heart pop, color transitions, and particle effects
class LikeAnimation extends StatefulWidget {
  final bool isLiked;
  final VoidCallback onLike;
  final double size;
  final Color? likedColor;
  final Color? unlikedColor;
  final Duration? animationDuration;
  
  const LikeAnimation({
    super.key,
    required this.isLiked,
    required this.onLike,
    this.size = 24.0,
    this.likedColor,
    this.unlikedColor,
    this.animationDuration,
  });
  
  @override
  State<LikeAnimation> createState() => _LikeAnimationState();
}

class _LikeAnimationState extends State<LikeAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _particleAnimation;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.likeAnimationDuration,
      vsync: this,
    );
    
    // Scale animation: 0.8 → 1.5 → 1.0
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 0.8, end: 1.5), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.5, end: 1.0), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: SocialAnimations.likeCurve,
    ));
    
    // Color animation: gray → copper → red
    _colorAnimation = TweenSequence([
      TweenSequenceItem(tween: ColorTween(begin: AppTheme.mediumGray, end: AppTheme.accentCopper), weight: 50),
      TweenSequenceItem(tween: ColorTween(begin: AppTheme.accentCopper, end: widget.likedColor ?? SocialAnimations.likeColor), weight: 50),
    ]).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Particle animation
    _particleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleLike() {
    if (!_isAnimating) {
      _isAnimating = true;
      _controller.forward().then((_) {
        _controller.reset();
        _isAnimating = false;
      });
      widget.onLike();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLike,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Stack(
            alignment: Alignment.center,
            children: [
              // Heart icon with scale and color animation
              AnimatedScale(
                scale: _scaleAnimation.value,
                duration: const Duration(milliseconds: 100),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 100),
                  child: Icon(
                    widget.isLiked ? Icons.favorite : Icons.favorite_border,
                    color: widget.isLiked
                        ? (_colorAnimation.value ?? AppTheme.mediumGray)
                        : (widget.unlikedColor ?? AppTheme.textSecondary),
                    size: widget.size,
                  ),
                ),
              ),
              
              // Particle effects when liked
              if (widget.isLiked && _particleAnimation.value > 0)
                _buildParticleEffects(),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildParticleEffects() {
    final particles = SocialAnimations.generateParticles(
      count: 8,
      area: Size(widget.size * 2, widget.size * 2),
      color: SocialAnimations.particleCopperColor,
      minSize: 2.0,
      maxSize: 4.0,
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

/// Like button widget with enhanced animation effects
class AnimatedLikeButton extends StatefulWidget {
  final bool isLiked;
  final int likeCount;
  final VoidCallback onLike;
  final double size;
  final Color? likedColor;
  final Color? unlikedColor;
  final Duration? animationDuration;
  final bool showCount;
  
  const AnimatedLikeButton({
    super.key,
    required this.isLiked,
    required this.likeCount,
    required this.onLike,
    this.size = 24.0,
    this.likedColor,
    this.unlikedColor,
    this.animationDuration,
    this.showCount = true,
  });
  
  @override
  State<AnimatedLikeButton> createState() => _AnimatedLikeButtonState();
}

class _AnimatedLikeButtonState extends State<AnimatedLikeButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _countAnimation;
  bool _isAnimating = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.animationDuration ?? SocialAnimations.likeAnimationDuration,
      vsync: this,
    );
    
    // Scale animation for button
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
    ));
    
    // Color animation
    _colorAnimation = ColorTween(
      begin: widget.unlikedColor ?? AppTheme.textSecondary,
      end: widget.likedColor ?? SocialAnimations.likeColor,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Count animation
    _countAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleLike() {
    if (!_isAnimating) {
      _isAnimating = true;
      _controller.forward().then((_) {
        _controller.reverse().then((_) {
          _isAnimating = false;
        });
      });
      widget.onLike();
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: _handleLike,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Animated heart icon
              AnimatedScale(
                scale: _scaleAnimation.value,
                duration: const Duration(milliseconds: 100),
                child: Icon(
                  widget.isLiked ? Icons.favorite : Icons.favorite_border,
                  color: widget.isLiked
                      ? (_colorAnimation.value ?? AppTheme.mediumGray)
                      : (widget.unlikedColor ?? AppTheme.textSecondary),
                  size: widget.size,
                ),
              ),
              
              // Like count with animation
              if (widget.showCount) ...[
                const SizedBox(width: 4),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  child: Text(
                    '${widget.likeCount}',
                    key: ValueKey(widget.likeCount),
                    style: AppTheme.bodySmall.copyWith(
                      color: widget.isLiked
                          ? (_colorAnimation.value ?? AppTheme.mediumGray)
                          : AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
              
              // Particle effects when liked
              if (widget.isLiked && _controller.status == AnimationStatus.forward)
                Positioned.fill(
                  child: _buildParticleEffects(),
                ),
            ],
          );
        },
      ),
    );
  }
  
  Widget _buildParticleEffects() {
    final particles = SocialAnimations.generateParticles(
      count: 6,
      area: Size(widget.size * 3, widget.size * 3),
      color: SocialAnimations.particleCopperColor,
      minSize: 1.5,
      maxSize: 3.0,
    );
    
    return Stack(
      children: particles.map((particle) {
        return AnimatedParticle(
          particle: particle,
          progress: _controller.value,
        );
      }).toList(),
    );
  }
}

/// Heart burst animation for when a post is liked
class HeartBurstAnimation extends StatefulWidget {
  final VoidCallback onComplete;
  final int heartCount;
  final double maxSize;
  final Duration? duration;
  
  const HeartBurstAnimation({
    super.key,
    required this.onComplete,
    this.heartCount = 8,
    this.maxSize = 30.0,
    this.duration,
  });
  
  @override
  State<HeartBurstAnimation> createState() => _HeartBurstAnimationState();
}

class _HeartBurstAnimationState extends State<HeartBurstAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;
  late Animation<double> _fadeAnimation;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration ?? SocialAnimations.likeAnimationDuration,
      vsync: this,
    );
    
    _scaleAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.elasticOut,
    ));
    
    _fadeAnimation = Tween<double>(begin: 1.0, end: 0.0).animate(CurvedAnimation(
      parent: _controller,
      curve: const Interval(0.5, 1.0, curve: Curves.easeOut),
    ));
    
    _controller.forward().whenComplete(() {
      widget.onComplete();
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
        return Stack(
          alignment: Alignment.center,
          children: List.generate(widget.heartCount, (index) {
            final angle = (index / widget.heartCount) * 2 * math.pi;
            final distance = _scaleAnimation.value * 50;
            final x = math.cos(angle) * distance;
            final y = math.sin(angle) * distance;
            
            return Positioned(
              left: x,
              top: y,
              child: Opacity(
                opacity: _fadeAnimation.value,
                child: Transform.scale(
                  scale: _scaleAnimation.value,
                  child: Icon(
                    Icons.favorite,
                    color: SocialAnimations.likeColor,
                    size: widget.maxSize * _scaleAnimation.value,
                  ),
                ),
              ),
            );
          }),
        );
      },
    );
  }
}