
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../../design_system/app_theme.dart';
import '../../../models/transformer_models.dart';

/// Interactive connection point widget optimized for mobile devices
class ConnectionPointWidget extends StatefulWidget {

  const ConnectionPointWidget({
    required this.connectionPoint, required this.isSelected, required this.isConnected, required this.showGuidance, required this.isCompatible, required this.isDragSource, required this.connectionMode, required this.onTap, super.key,
    this.onDragUpdate,
    this.onDragStart,
    this.onDragEnd,
    this.onAcceptDrop,
  });
  final ConnectionPoint connectionPoint;
  final bool isSelected;
  final bool isConnected;
  final bool showGuidance;
  final bool isCompatible;
  final bool isDragSource;
  final ConnectionMode connectionMode;
  final VoidCallback onTap;
  final Function(DragUpdateDetails)? onDragUpdate;
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Function(String)? onAcceptDrop;

  @override
  State<ConnectionPointWidget> createState() => _ConnectionPointWidgetState();
}

class _ConnectionPointWidgetState extends State<ConnectionPointWidget>
    with TickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;
  AnimationController? _glowController;
  Animation<double>? _glowAnimation;
  AnimationController? _scaleController;
  Animation<double>? _scaleAnimation;
  bool _isHovering = false;
  bool _isPressed = false;
  
  // Mobile touch constants
  static const double _minTouchTarget = 44; // iOS/Android accessibility guidelines
  static const double _visualSize = 28;
  static const double _mobileVisualSize = 32; // Larger on mobile

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      duration: const Duration(seconds: 1),
      vsync: this,
    );
    _pulseAnimation = Tween<double>(
      begin: 1,
      end: 1.3,
    ).animate(CurvedAnimation(
      parent: _pulseController!,
      curve: Curves.easeInOut,
    ),);

    _glowController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _glowAnimation = Tween<double>(
      begin: 0,
      end: 1,
    ).animate(CurvedAnimation(
      parent: _glowController!,
      curve: Curves.easeInOut,
    ),);
    
    // Scale animation for press feedback
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 100),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1,
      end: 0.95,
    ).animate(CurvedAnimation(
      parent: _scaleController!,
      curve: Curves.easeInOut,
    ),);
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    _glowController?.dispose();
    _scaleController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(ConnectionPointWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulse animation if selected
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController?.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController?.stop();
      _pulseController?.reset();
    }

    // Start glow animation if compatible
    if (widget.isCompatible && !oldWidget.isCompatible) {
      _glowController?.repeat(reverse: true);
    } else if (!widget.isCompatible && oldWidget.isCompatible) {
      _glowController?.stop();
      _glowController?.reset();
    }
  }

  void _handleTap() {
    // Enhanced haptic feedback for mobile
    if (widget.isCompatible || widget.isSelected) {
      HapticFeedback.mediumImpact();
    } else {
      HapticFeedback.lightImpact();
    }
    widget.onTap();
  }
  
  void _handleTapDown() {
    setState(() => _isPressed = true);
    _scaleController?.forward();
    // Immediate haptic feedback for press
    HapticFeedback.selectionClick();
  }
  
  void _handleTapUp() {
    setState(() => _isPressed = false);
    _scaleController?.reverse();
  }
  
  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _scaleController?.reverse();
  }
  
  // Check if current device is mobile
  bool get _isMobile {
    final MediaQueryData mediaQuery = MediaQuery.of(context);
    return mediaQuery.size.width < 768; // Tablet breakpoint
  }
  
  // Get appropriate sizes for current device
  double get _touchTargetSize => _minTouchTarget;
  double get _connectionVisualSize => _isMobile ? _mobileVisualSize : _visualSize;

  @override
  Widget build(BuildContext context) {
    // Main touch target with proper sizing
    final Container touchTarget = SizedBox(
      width: _touchTargetSize,
      height: _touchTargetSize,
      child: Center(
        child: AnimatedBuilder(
          animation: Listenable.merge(<Listenable?>[_pulseAnimation, _glowAnimation, _scaleAnimation]),
          builder: (BuildContext context, Widget? child) {
            final double baseScale = widget.isSelected
                ? _pulseAnimation!.value
                : (_isHovering ? 1.1 : 1.0);
            final double pressScale = _isPressed ? _scaleAnimation!.value : 1.0;
            
            return Transform.scale(
              scale: baseScale * pressScale,
              child: Container(
                width: _connectionVisualSize,
                height: _connectionVisualSize,
                decoration: BoxDecoration(
                  color: _getConnectionPointColor(),
                  border: Border.all(
                    color: _getConnectionPointBorderColor(),
                    width: widget.isCompatible ? 3.0 : 2.0,
                  ),
                  shape: BoxShape.circle,
                  boxShadow: <BoxShadow>[
                    if (widget.isSelected || widget.isCompatible || _isPressed)
                      BoxShadow(
                        color: _getGlowColor().withOpacity(
                          widget.isCompatible
                            ? 0.3 + (_glowAnimation?.value ?? 0) * 0.4
                            : _isPressed ? 0.7 : 0.5,
                        ),
                        spreadRadius: widget.isCompatible ? 6 : (_isPressed ? 3 : 2),
                        blurRadius: widget.isCompatible ? 14 : (_isPressed ? 10 : 8),
                      ),
                  ],
                ),
                child: Center(
                  child: Icon(
                    _getConnectionPointIcon(),
                    size: _isMobile ? 16 : 14,
                    color: AppTheme.white,
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );

    // For drag-drop mode, wrap with draggable/drag target
    if (widget.connectionMode == ConnectionMode.dragAndDrop) {
      return MouseRegion(
        onEnter: (_) => setState(() => _isHovering = true),
        onExit: (_) => setState(() => _isHovering = false),
        cursor: SystemMouseCursors.grab,
        child: LongPressDraggable<String>(
          data: widget.connectionPoint.id,
          feedback: _buildDragFeedback(),
          childWhenDragging: Opacity(
            opacity: 0.5,
            child: touchTarget,
          ),
          onDragStarted: () {
            HapticFeedback.mediumImpact();
            widget.onDragStart?.call();
          },
          onDragUpdate: widget.onDragUpdate,
          onDragEnd: (_) => widget.onDragEnd?.call(),
          child: DragTarget<String>(
            builder: (BuildContext context, List<String?> candidateData, List rejectedData) {
              final bool isAcceptingDrag = candidateData.isNotEmpty;
              return GestureDetector(
                onTap: _handleTap,
                onTapDown: (_) => _handleTapDown(),
                onTapUp: (_) => _handleTapUp(),
                onTapCancel: _handleTapCancel,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: isAcceptingDrag ? Border.all(
                      color: AppTheme.successGreen,
                      width: 3,
                    ) : null,
                  ),
                  child: touchTarget,
                ),
              );
            },
            onWillAcceptWithDetails: (String? data) {
              if (data == null) return false;
              final bool canAccept = data != widget.connectionPoint.id;
              if (canAccept) {
                HapticFeedback.selectionClick(); // Preview feedback
              }
              return canAccept;
            },
            onAcceptWithDetails: (String data) {
              HapticFeedback.heavyImpact();
              widget.onAcceptDrop?.call(data);
            },
          ),
        ),
      );
    }

    // For sticky keys mode, use simple gesture detector with enhanced touch
    return MouseRegion(
      onEnter: (_) => setState(() => _isHovering = true),
      onExit: (_) => setState(() => _isHovering = false),
      cursor: widget.isCompatible
          ? SystemMouseCursors.click
          : SystemMouseCursors.basic,
      child: GestureDetector(
        onTap: _handleTap,
        onTapDown: (_) => _handleTapDown(),
        onTapUp: (_) => _handleTapUp(),
        onTapCancel: _handleTapCancel,
        // Enhanced touch behavior for mobile
        behavior: HitTestBehavior.opaque,
        child: touchTarget,
      ),
    );
  }

  Widget _buildDragFeedback() => Material(
      color: Colors.transparent,
      child: Container(
        width: _connectionVisualSize + 8, // Slightly larger for drag feedback
        height: _connectionVisualSize + 8,
        decoration: BoxDecoration(
          color: _getConnectionPointColor().withOpacity(0.9),
          shape: BoxShape.circle,
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: _getConnectionPointColor().withOpacity(0.6),
              spreadRadius: 6,
              blurRadius: 16,
            ),
          ],
          border: Border.all(
            color: AppTheme.white,
            width: 2,
          ),
        ),
        child: Center(
          child: Icon(
            _getConnectionPointIcon(),
            size: _isMobile ? 18 : 16,
            color: AppTheme.white,
          ),
        ),
      ),
    );

  /// Get connection point color based on type and state
  Color _getConnectionPointColor() {
    if (widget.isConnected) {
      return AppTheme.successGreen;
    }
    
    if (widget.isSelected || widget.isDragSource) {
      return AppTheme.infoBlue;
    }

    if (widget.isCompatible) {
      return AppTheme.warningYellow;
    }
    
    switch (widget.connectionPoint.type) {
      case ConnectionType.primary:
        return AppTheme.errorRed;
      case ConnectionType.secondary:
        return AppTheme.infoBlue;
      case ConnectionType.neutral:
        return AppTheme.mediumGray;
      case ConnectionType.ground:
        return AppTheme.groundBrown;
    }
  }

  /// Get connection point border color
  Color _getConnectionPointBorderColor() {
    if (widget.isCompatible) {
      return AppTheme.warningYellow.withOpacity(0.8);
    }

    if (widget.isSelected || widget.isDragSource) {
      return AppTheme.infoBlue.withOpacity(0.8);
    }
    
    if (widget.isConnected) {
      return AppTheme.successGreen.withOpacity(0.8);
    }
    
    return AppTheme.darkGray;
  }

  /// Get glow color for animations
  Color _getGlowColor() {
    if (widget.isCompatible) {
      return AppTheme.warningYellow;
    }
    if (widget.isSelected || widget.isDragSource) {
      return AppTheme.infoBlue;
    }
    if (widget.isConnected) {
      return AppTheme.successGreen;
    }
    return _getConnectionPointColor();
  }

  /// Get appropriate icon for connection point
  IconData _getConnectionPointIcon() {
    if (widget.isConnected) {
      return Icons.link;
    }
    
    switch (widget.connectionPoint.type) {
      case ConnectionType.primary:
        return Icons.bolt;
      case ConnectionType.secondary:
        return Icons.power;
      case ConnectionType.neutral:
        return Icons.horizontal_rule;
      case ConnectionType.ground:
        return Icons.electrical_services;
    }
  }
}

/// Tooltip widget for connection points
class ConnectionPointTooltip extends StatelessWidget {

  const ConnectionPointTooltip({
    required this.connectionPoint, required this.child, super.key,
  });
  final ConnectionPoint connectionPoint;
  final Widget child;

  @override
  Widget build(BuildContext context) => Tooltip(
      message: _getTooltipMessage(),
      decoration: BoxDecoration(
        color: AppTheme.darkGray,
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: AppTheme.white,
        fontSize: 12,
      ),
      child: child,
    );

  String _getTooltipMessage() {
    final String typeDescription = _getTypeDescription();
    final String inputOutput = connectionPoint.isInput ? 'Input' : 'Output';
    
    return '${connectionPoint.label}\n$typeDescription $inputOutput';
  }

  String _getTypeDescription() {
    switch (connectionPoint.type) {
      case ConnectionType.primary:
        return 'Primary Side';
      case ConnectionType.secondary:
        return 'Secondary Side';
      case ConnectionType.neutral:
        return 'Neutral Point';
      case ConnectionType.ground:
        return 'Ground Connection';
    }
  }
}
