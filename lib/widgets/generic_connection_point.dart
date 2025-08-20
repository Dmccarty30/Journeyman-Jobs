import 'package:flutter/material.dart';
import '../models/transformer_models.dart';

/// Generic interactive connection point widget
class GenericConnectionPointWidget extends StatefulWidget {

  const GenericConnectionPointWidget({
    required this.connectionPoint, required this.isSelected, required this.isConnected, required this.showGuidance, required this.onTap, super.key,
    this.isCompatible = true,
    this.isDragSource = false,
    this.connectionMode = ConnectionMode.stickyKeys,
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
  final VoidCallback? onDragStart;
  final VoidCallback? onDragEnd;
  final Function(DragTargetDetails<String>)? onAcceptDrop;

  @override
  State<GenericConnectionPointWidget> createState() => _GenericConnectionPointWidgetState();
}

class _GenericConnectionPointWidgetState extends State<GenericConnectionPointWidget>
    with SingleTickerProviderStateMixin {
  AnimationController? _pulseController;
  Animation<double>? _pulseAnimation;

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
  }

  @override
  void dispose() {
    _pulseController?.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(GenericConnectionPointWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Start pulse animation if selected
    if (widget.isSelected && !oldWidget.isSelected) {
      _pulseController?.repeat(reverse: true);
    } else if (!widget.isSelected && oldWidget.isSelected) {
      _pulseController?.stop();
      _pulseController?.reset();
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget connectionPoint = GestureDetector(
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _pulseAnimation ?? const AlwaysStoppedAnimation(1),
        builder: (BuildContext context, Widget? child) => Transform.scale(
            scale: widget.isSelected ? _pulseAnimation!.value : 1.0,
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: _getConnectionPointColor(),
                border: Border.all(
                  color: _getConnectionPointBorderColor(),
                  width: 2,
                ),
                shape: BoxShape.circle,
                boxShadow: <BoxShadow>[
                  if (widget.isSelected)
                    BoxShadow(
                      color: _getConnectionPointColor().withOpacity(0.5),
                      spreadRadius: 2,
                      blurRadius: 8,
                    ),
                ],
              ),
              child: Center(
                child: Icon(
                  _getConnectionPointIcon(),
                  size: 16,
                  color: Colors.white,
                ),
              ),
            ),
          ),
      ),
    );

    // Wrap with drag and drop functionality if in drag mode
    if (widget.connectionMode == ConnectionMode.dragAndDrop) {
      if (widget.isDragSource && widget.onDragStart != null) {
        connectionPoint = Draggable<String>(
          data: widget.connectionPoint.id,
          onDragStarted: widget.onDragStart,
          onDragEnd: (_) => widget.onDragEnd?.call(),
          feedback: Material(
            color: Colors.transparent,
            child: Container(
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                color: _getConnectionPointColor().withOpacity(0.7),
                shape: BoxShape.circle,
              ),
            ),
          ),
          childWhenDragging: Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: _getConnectionPointColor().withOpacity(0.3),
              border: Border.all(
                color: _getConnectionPointBorderColor().withOpacity(0.3),
                width: 2,
              ),
              shape: BoxShape.circle,
            ),
          ),
          child: connectionPoint,
        );
      } else if (widget.onAcceptDrop != null) {
        connectionPoint = DragTarget<String>(
          onAcceptWithDetails: widget.onAcceptDrop,
          onWillAcceptWithDetails: (DragTargetDetails<String> details) => widget.isCompatible,
          builder: (BuildContext context, List<String?> candidateData, List rejectedData) {
            final bool isHovering = candidateData.isNotEmpty;
            return AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              transform: Matrix4.identity()..scale(isHovering ? 1.2 : 1.0),
              child: connectionPoint,
            );
          },
        );
      }
    }

    return connectionPoint;
  }

  /// Get connection point color based on type and state
  Color _getConnectionPointColor() {
    if (widget.isConnected) {
      return Colors.green;
    }
    
    if (widget.isSelected) {
      return Colors.blue;
    }

    if (!widget.isCompatible) {
      return Colors.grey[400]!;
    }
    
    switch (widget.connectionPoint.type) {
      case ConnectionType.primary:
        return Colors.red[700]!;
      case ConnectionType.secondary:
        return Colors.blue[700]!;
      case ConnectionType.neutral:
        return Colors.grey[600]!;
      case ConnectionType.ground:
        return Colors.brown[700]!;
    }
  }

  /// Get connection point border color
  Color _getConnectionPointBorderColor() {
    if (widget.isSelected) {
      return Colors.blue[800]!;
    }
    
    if (widget.isConnected) {
      return Colors.green[800]!;
    }

    if (!widget.isCompatible) {
      return Colors.grey[600]!;
    }
    
    return Colors.grey[800]!;
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
        return Icons.landscape;
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
        color: Colors.grey[800],
        borderRadius: BorderRadius.circular(8),
      ),
      textStyle: const TextStyle(
        color: Colors.white,
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

/// Custom painter for drawing wire connections
class WireConnectionPainter extends CustomPainter {

  WireConnectionPainter({
    required this.connections,
    required this.connectionPoints,
    required this.wireColors,
    this.showConnections = true,
  });
  final List<WireConnection> connections;
  final List<ConnectionPoint> connectionPoints;
  final Map<String, Color> wireColors;
  final bool showConnections;

  @override
  void paint(Canvas canvas, Size size) {
    if (!showConnections || connections.isEmpty) return;

    for (final WireConnection connection in connections) {
      // Find the connection points
      final ConnectionPoint fromPoint = connectionPoints.firstWhere(
        (ConnectionPoint p) => p.id == connection.fromPointId,
        orElse: () => connectionPoints.first,
      );
      final ConnectionPoint toPoint = connectionPoints.firstWhere(
        (ConnectionPoint p) => p.id == connection.toPointId,
        orElse: () => connectionPoints.first,
      );

      // Create the paint
      final Paint paint = Paint()
        ..color = connection.color
        ..strokeWidth = connection.isCorrect ? 3.0 : 2.0
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round;

      // Add dashed line for incorrect connections
      if (!connection.isCorrect) {
        paint.color = paint.color.withOpacity(0.5);
        _drawDashedLine(
          canvas,
          fromPoint.position,
          toPoint.position,
          paint,
        );
      } else {
        // Draw solid line for correct connections
        canvas.drawLine(
          fromPoint.position,
          toPoint.position,
          paint,
        );
      }

      // Draw arrow at the end
      _drawArrow(
        canvas,
        fromPoint.position,
        toPoint.position,
        paint,
      );
    }
  }

  void _drawDashedLine(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    const double dashWidth = 5;
    const double dashSpace = 3;
    final double distance = (end - start).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    final double dx = (end.dx - start.dx) / distance;
    final double dy = (end.dy - start.dy) / distance;
    
    for (int i = 0; i < dashCount; i++) {
      final Offset dashStart = Offset(
        start.dx + (dashWidth + dashSpace) * i * dx,
        start.dy + (dashWidth + dashSpace) * i * dy,
      );
      final Offset dashEnd = Offset(
        start.dx + ((dashWidth + dashSpace) * i + dashWidth) * dx,
        start.dy + ((dashWidth + dashSpace) * i + dashWidth) * dy,
      );
      canvas.drawLine(dashStart, dashEnd, paint);
    }
  }

  void _drawArrow(
    Canvas canvas,
    Offset start,
    Offset end,
    Paint paint,
  ) {
    final double angle = (end - start).direction;
    const double arrowLength = 10;
    const double arrowAngle = 0.5;
    
    final Offset arrowPoint1 = Offset(
      end.dx - arrowLength * (angle - arrowAngle).clamp(-1, 1),
      end.dy - arrowLength * (angle - arrowAngle).clamp(-1, 1),
    );
    
    final Offset arrowPoint2 = Offset(
      end.dx - arrowLength * (angle + arrowAngle).clamp(-1, 1),
      end.dy - arrowLength * (angle + arrowAngle).clamp(-1, 1),
    );
    
    final Path path = Path()
      ..moveTo(arrowPoint1.dx, arrowPoint1.dy)
      ..lineTo(end.dx, end.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);
    
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(WireConnectionPainter oldDelegate) => connections != oldDelegate.connections ||
        connectionPoints != oldDelegate.connectionPoints ||
        showConnections != oldDelegate.showConnections;
}