import 'package:flutter/material.dart';
import 'social_animations.dart';
import '../design_system/app_theme.dart';

/// A custom pull-to-refresh widget featuring an "electrical arc" animation.
///
/// This widget wraps a scrollable child and provides a custom visual indicator
/// that animates as the user pulls down to refresh the content.
class ElectricalPullToRefresh extends StatefulWidget {
  /// A callback function that is triggered when a refresh is initiated.
  /// It should return a `Future` that completes when the refresh is done.
  final Future<void> Function() onRefresh;
  /// The scrollable widget that this pull-to-refresh indicator is associated with.
  final Widget child;
  /// The distance in logical pixels the user must pull down to trigger the refresh.
  final double triggerDistance;
  
  /// Creates an [ElectricalPullToRefresh] widget.
  const ElectricalPullToRefresh({
    super.key,
    required this.onRefresh,
    required this.child,
    this.triggerDistance = 80.0,
  });

  @override
  State<ElectricalPullToRefresh> createState() => _ElectricalPullToRefreshState();
}

/// The state for the [ElectricalPullToRefresh] widget.
///
/// Manages the animations and the state transitions from pulling, to ready,
/// to refreshing, and back to idle.
class _ElectricalPullToRefreshState extends State<ElectricalPullToRefresh>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pullAnimation;
  late Animation<double> _arcAnimation;
  late Animation<double> _progressAnimation;
  
  bool _isRefreshing = false;
  bool _canRefresh = false;
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: SocialAnimations.pullToRefreshDuration,
      vsync: this,
    );
    
    // Pull animation
    _pullAnimation = Tween<double>(
      begin: 0.0,
      end: widget.triggerDistance,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    ));
    
    // Arc animation for electrical effect
    _arcAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    ));
    
    // Progress animation
    _progressAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.linear,
    ));
  }
  
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  
  void _handleDragStart(DragStartDetails details) {
    if (!_isRefreshing) {
      _controller.reset();
    }
  }
  
  void _handleDragUpdate(DragUpdateDetails details) {
    if (!_isRefreshing) {
      final double pullDistance = details.primaryDelta ?? 0;
      final double clampedPull = pullDistance.clamp(0.0, widget.triggerDistance);
      final double progress = clampedPull / widget.triggerDistance;
      
      _controller.value = progress;
      _canRefresh = progress >= 1.0;
    }
  }
  
  void _handleDragEnd(DragEndDetails details) {
    if (_canRefresh && !_isRefreshing) {
      _isRefreshing = true;
      _controller.forward().then((_) {
        _performRefresh();
      });
    } else {
      _controller.reverse().then((_) {
        _canRefresh = false;
      });
    }
  }
  
  Future<void> _performRefresh() async {
    try {
      await widget.onRefresh();
    } finally {
      if (mounted) {
        _controller.reverse().then((_) {
          _isRefreshing = false;
          _canRefresh = false;
        });
      }
    }
  }
  
  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        if (notification is ScrollStartNotification) {
          _handleDragStart(DragStartDetails(
            globalPosition: Offset(0, notification.metrics.pixels),
          ));
        } else if (notification is ScrollUpdateNotification) {
          _handleDragUpdate(DragUpdateDetails(
            primaryDelta: notification.metrics.pixels,
            globalPosition: Offset.zero,
          ));
        } else if (notification is ScrollEndNotification) {
          _handleDragEnd(DragEndDetails(
            velocity: const Velocity(pixelsPerSecond: Offset.zero),
          ));
        }
        return false;
      },
      child: Stack(
        children: [
          widget.child,
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: _buildRefreshIndicator(),
          ),
        ],
      ),
    );
  }
  
  /// Builds the refresh indicator widget based on the current animation state.
  Widget _buildRefreshIndicator() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final double indicatorHeight = _pullAnimation.value;
        
        if (indicatorHeight <= 0) return const SizedBox.shrink();
        
        return Container(
          height: indicatorHeight + 60,
          alignment: Alignment.topCenter,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              // Electrical arc animation
              if (_isRefreshing)
                _buildElectricalArc()
              else if (_canRefresh)
                _buildReadyToRefreshIndicator()
              else
                _buildPullingIndicator(),
              
              const SizedBox(height: 8),
              
              // Progress indicator
              if (_isRefreshing)
                _buildCircularProgress(),
            ],
          ),
        );
      },
    );
  }
  
  /// Builds the indicator shown when the user is pulling down but has not yet
  /// reached the trigger distance.
  Widget _buildPullingIndicator() {
    return Opacity(
      opacity: _controller.value,
      child: Transform.scale(
        scale: 0.8 + _controller.value * 0.2,
        child: Icon(
          Icons.bolt,
          color: AppTheme.accentCopper,
          size: 24,
        ),
      ),
    );
  }
  
  /// Builds the indicator shown when the user has pulled far enough to trigger a refresh.
  Widget _buildReadyToRefreshIndicator() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      child: Icon(
        Icons.bolt,
        color: AppTheme.errorRed,
        size: 32,
      ),
    );
  }
  
  /// Builds the custom electrical arc animation displayed during the refresh.
  Widget _buildElectricalArc() {
    return CustomPaint(
      painter: ElectricalArcPainter(
        progress: _arcAnimation.value,
        color: AppTheme.accentCopper,
      ),
      size: const Size(60, 40),
    );
  }
  
  /// Builds the circular progress indicator shown during the refresh.
  Widget _buildCircularProgress() {
    return SizedBox(
      width: 32,
      height: 32,
      child: CircularProgressIndicator(
        strokeWidth: 2.5,
        value: _progressAnimation.value,
        valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        backgroundColor: AppTheme.mediumGray,
      ),
    );
  }
}

/// A [CustomPainter] that draws an animated electrical arc effect.
class ElectricalArcPainter extends CustomPainter {
  /// The current progress of the animation, from 0.0 to 1.0.
  final double progress;
  /// The color of the arc and sparks.
  final Color color;
  
  /// Creates an instance of [ElectricalArcPainter].
  ElectricalArcPainter({
    required this.progress,
    required this.color,
  });
  
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0);
    
    final Path path = Path();
    final double width = size.width;
    final double height = size.height;
    
    // Create electrical arc effect
    for (double i = 0; i <= progress; i += 0.1) {
      final double x = width * i;
      final double y = height * (0.5 + 0.3 * (i - 0.5).abs());
      
      if (i == 0) {
        path.moveTo(x, y);
      } else {
        path.lineTo(x, y);
      }
    }
    
    // Add electrical sparks
    if (progress > 0.5) {
      for (int i = 0; i < 3; i++) {
        final double sparkX = width * (0.3 + i * 0.2);
        final double sparkY = height * (0.3 + (i % 2) * 0.4);
        final double sparkSize = 2 + progress * 3;
        
        canvas.drawCircle(Offset(sparkX, sparkY), sparkSize, paint);
      }
    }
    
    canvas.drawPath(path, paint);
  }
  
  @override
  bool shouldRepaint(ElectricalArcPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}
