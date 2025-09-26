
import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../animations/electrical_fire_animation.dart';
import '../animations/flash_animation.dart';
import '../animations/power_up_animation.dart';
import '../models/transformer_models_export.dart';
import '../painters/base_transformer_painter.dart';
import '../painters/delta_delta_painter.dart';
import '../painters/delta_wye_painter.dart';
import '../painters/open_delta_painter.dart';
import '../painters/wye_delta_painter.dart';
import '../painters/wye_wye_painter.dart';
import '../state/transformer_state.dart';
import 'connection_point.dart';

/// Interactive transformer diagram widget
class TransformerDiagram extends StatefulWidget {

  const TransformerDiagram({
    required this.onConnectionMade, required this.onConnectionError, super.key,
    this.showGuidance = true,
    this.connectionMode = ConnectionMode.stickyKeys,
  });
  final Function(String fromId, String toId) onConnectionMade;
  final Function(String error) onConnectionError;
  final bool showGuidance;
  final ConnectionMode connectionMode;

  @override
  State<TransformerDiagram> createState() => _TransformerDiagramState();
}

class _TransformerDiagramState extends State<TransformerDiagram>
    with TickerProviderStateMixin {
  AnimationController? flashAnimationController;
  AnimationController? successAnimationController;
  bool _isEnergized = false;
  bool _showFireAnimation = false;
  bool _showPowerUpAnimation = false;
  
  @override
  void initState() {
    super.initState();
    flashAnimationController = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    successAnimationController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
  }

  @override
  void dispose() {
    flashAnimationController?.dispose();
    successAnimationController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Consumer<TransformerTrainerState>(
      builder: (BuildContext context, TransformerTrainerState state, Widget? child) => Column(
          children: <Widget>[
            // Connection mode toggle and Energize button
            _buildControlPanel(state),
            
            // Main diagram
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(16),
                child: Stack(
                  children: <Widget>[
                    // Background transformer diagram
                    Positioned.fill(
                      child: CustomPaint(
                        painter: _getPainter(state.currentState.bankType),
                      ),
                    ),
                    
                    // Interactive connection points
                    ..._buildConnectionPoints(state),
                    
                    // Existing wire connections
                    ..._buildExistingConnections(state),
                    
                    // Drag preview line
                    if (state.dragSourceId != null && state.dragPreviewPosition != null)
                      _buildDragPreviewLine(state),
                    
                    // Selected wire highlight (sticky keys mode)
                    if (state.selectedWireId != null && widget.connectionMode == ConnectionMode.stickyKeys)
                      _buildSelectedWireHighlight(state),
                    
                    // Flash animation overlay (for errors)
                    if (flashAnimationController?.isAnimating == true)
                      FlashAnimationWidget(
                        controller: flashAnimationController!,
                      ),
                    
                    // Instruction overlay
                    if (widget.showGuidance)
                      _buildInstructionOverlay(state),
                    
                    // Electrical Fire Animation overlay
                    if (_showFireAnimation)
                      Positioned.fill(
                        child: ElectricalFireAnimation(
                          onAnimationComplete: () {
                            setState(() {
                              _showFireAnimation = false;
                              _isEnergized = false;
                            });
                            // Reset connections after fire animation
                            state.clearConnections();
                          },
                        ),
                      ),
                    
                    // Power Up Animation overlay
                    if (_showPowerUpAnimation)
                      Positioned.fill(
                        child: PowerUpAnimation(
                          connectionPoints: state.connectionPoints
                              .map((ConnectionPoint p) => p.position)
                              .toList(),
                          onAnimationComplete: () {
                            setState(() {
                              _showPowerUpAnimation = false;
                            });
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ],
        ),
    );

  /// Build control panel with connection mode toggle and energize button
  Widget _buildControlPanel(TransformerTrainerState state) => Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Column(
        children: <Widget>[
          // Connection mode toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Icon(Icons.touch_app, size: 20),
              const SizedBox(width: 8),
              const Text('Tap Mode'),
              const SizedBox(width: 16),
              Switch(
                value: state.connectionMode == ConnectionMode.dragAndDrop,
                onChanged: !_isEnergized ? (bool value) {
                  state.setConnectionMode(
                    value ? ConnectionMode.dragAndDrop : ConnectionMode.stickyKeys,
                  );
                } : null,
                activeThumbColor: Colors.blue,
              ),
              const SizedBox(width: 16),
              const Icon(Icons.pan_tool, size: 20),
              const SizedBox(width: 8),
              const Text('Drag Mode'),
            ],
          ),
          const SizedBox(height: 8),
          // Energize button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              ElevatedButton.icon(
                onPressed: !_isEnergized && state.currentState.connections.isNotEmpty
                    ? () => _onEnergizePressed(state)
                    : null,
                icon: const Icon(Icons.power_settings_new),
                label: Text(_isEnergized ? 'Energized' : 'Energize Transformer'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: _isEnergized ? Colors.green : Colors.orange,
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                ),
              ),
              if (_isEnergized) ...<Widget>[
                const SizedBox(width: 16),
                TextButton.icon(
                  onPressed: () => _onResetPressed(state),
                  icon: const Icon(Icons.refresh),
                  label: const Text('Reset'),
                  style: TextButton.styleFrom(
                    foregroundColor: Colors.red,
                  ),
                ),
              ],
            ],
          ),
        ],
      ),
    );

  /// Get appropriate painter for the current bank type
  BaseTransformerPainter _getPainter(TransformerBankType bankType) {
    switch (bankType) {
      case TransformerBankType.wyeToWye:
        return WyeWyePainter();
      case TransformerBankType.deltaToDelta:
        return DeltaDeltaPainter();
      case TransformerBankType.wyeToDelta:
        return WyeDeltaPainter();
      case TransformerBankType.deltaToWye:
        return DeltaWyePainter();
      case TransformerBankType.openDelta:
        return OpenDeltaPainter();
    }
  }

  /// Build interactive connection points
  List<Widget> _buildConnectionPoints(TransformerTrainerState state) => state.connectionPoints.map((ConnectionPoint point) {
      final bool isSelected = state.selectedWireId == point.id;
      final bool isDragSource = state.dragSourceId == point.id;
      final bool isConnected = state.currentState.connections
          .any((WireConnection conn) => conn.fromPointId == point.id || conn.toPointId == point.id);
      final bool isCompatible = state.isCompatibleConnection(point.id);
      
      return Positioned(
        left: point.position.dx - 14,
        top: point.position.dy - 14,
        child: ConnectionPointWidget(
          connectionPoint: point,
          isSelected: isSelected,
          isConnected: isConnected,
          isCompatible: isCompatible,
          isDragSource: isDragSource,
          showGuidance: widget.showGuidance,
          connectionMode: state.connectionMode,
          onTap: () => _onConnectionPointTapped(point.id, state),
          onDragStart: () => _onDragStart(point.id, state),
          onDragEnd: () => _onDragEnd(state),
          onAcceptDrop: (String fromId) {
            _onDropAccepted(fromId, point.id, state);
          },
        ),
      );
    }).toList();

  /// Build visual representation of existing connections
  List<Widget> _buildExistingConnections(TransformerTrainerState state) => state.currentState.connections.map((WireConnection connection) {
      final ConnectionPoint fromPoint = state.connectionPoints
          .firstWhere((ConnectionPoint p) => p.id == connection.fromPointId);
      final ConnectionPoint toPoint = state.connectionPoints
          .firstWhere((ConnectionPoint p) => p.id == connection.toPointId);
      
      return Positioned.fill(
        child: CustomPaint(
          painter: ConnectionWirePainter(
            from: fromPoint.position,
            to: toPoint.position,
            isCorrect: connection.isCorrect,
          ),
        ),
      );
    }).toList();

  /// Handle connection point tap (sticky keys mode)
  void _onConnectionPointTapped(String pointId, TransformerTrainerState state) {
    if (state.connectionMode == ConnectionMode.dragAndDrop) {
      // In drag mode, tapping just provides feedback
      HapticFeedback.lightImpact();
      return;
    }
    
    // Sticky keys mode
    if (state.selectedWireId == null) {
      // First point selected
      state.selectWire(pointId);
      HapticFeedback.lightImpact();
    } else if (state.selectedWireId == pointId) {
      // Same point tapped - deselect
      state.clearWireSelection();
      HapticFeedback.lightImpact();
    } else {
      // Second point selected - attempt connection
      final String fromId = state.selectedWireId!;
      final String toId = pointId;
      
      if (state.isCompatibleConnection(toId)) {
        _makeConnection(fromId, toId, state);
        state.clearWireSelection();
      } else {
        // Invalid connection
        widget.onConnectionError('Invalid connection: Cannot connect these points');
        flashAnimationController?.forward().then((_) {
          flashAnimationController?.reset();
        });
        HapticFeedback.heavyImpact();
      }
    }
  }

  /// Handle drag start
  void _onDragStart(String pointId, TransformerTrainerState state) {
    state.startDrag(pointId);
  }


  /// Handle drag end
  void _onDragEnd(TransformerTrainerState state) {
    state.endDrag();
  }

  /// Handle drop accepted
  void _onDropAccepted(String fromId, String toId, TransformerTrainerState state) {
    if (state.isCompatibleConnection(toId)) {
      _makeConnection(fromId, toId, state);
    } else {
      widget.onConnectionError('Invalid connection: Cannot connect these points');
      flashAnimationController?.forward().then((_) {
        flashAnimationController?.reset();
      });
    }
    state.endDrag();
  }

  /// Make a connection between two points
  void _makeConnection(String fromId, String toId, TransformerTrainerState state) {
    // Check if connection is valid
    if (_isValidConnection(fromId, toId, state)) {
      widget.onConnectionMade(fromId, toId);
      successAnimationController?.forward().then((_) {
        successAnimationController?.reset();
      });
      HapticFeedback.mediumImpact();
    } else {
      widget.onConnectionError('Invalid connection: $fromId to $toId');
      flashAnimationController?.forward().then((_) {
        flashAnimationController?.reset();
      });
      HapticFeedback.heavyImpact();
    }
  }

  /// Check if a connection between two points is valid
  bool _isValidConnection(String fromId, String toId, TransformerTrainerState state) {
    // Check if connection already exists
    final bool existingConnection = state.currentState.connections
        .any((WireConnection conn) =>
            (conn.fromPointId == fromId && conn.toPointId == toId) ||
            (conn.fromPointId == toId && conn.toPointId == fromId),);
    
    if (existingConnection) return false;
    
    // Check against required connections
    return state.requiredConnections.any((WireConnection req) =>
        (req.fromPointId == fromId && req.toPointId == toId) ||
        (req.fromPointId == toId && req.toPointId == fromId),);
  }

  /// Build drag preview line
  Widget _buildDragPreviewLine(TransformerTrainerState state) {
    final ConnectionPoint sourcePoint = state.connectionPoints.firstWhere(
      (ConnectionPoint p) => p.id == state.dragSourceId,
    );
    
    return Positioned.fill(
      child: CustomPaint(
        painter: DragPreviewPainter(
          from: sourcePoint.position,
          to: state.dragPreviewPosition!,
        ),
      ),
    );
  }

  /// Build selected wire highlight
  Widget _buildSelectedWireHighlight(TransformerTrainerState state) {
    final ConnectionPoint selectedPoint = state.connectionPoints.firstWhere(
      (ConnectionPoint p) => p.id == state.selectedWireId,
    );
    
    return Positioned(
      left: selectedPoint.position.dx - 20,
      top: selectedPoint.position.dy - 20,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: Colors.blue.withValues(alpha: 0.6),
            width: 3,
          ),
        ),
      ),
    );
  }

  /// Build instruction overlay
  Widget _buildInstructionOverlay(TransformerTrainerState state) {
    String instruction = '';
    
    if (_isEnergized) {
      instruction = _showFireAnimation
          ? 'Incorrect connections caused electrical fire!'
          : _showPowerUpAnimation
              ? 'Transformer successfully energized!'
              : 'Transformer is energized';
    } else if (state.currentState.connections.isEmpty) {
      instruction = 'Make connections, then energize the transformer';
    } else if (state.connectionMode == ConnectionMode.dragAndDrop) {
      instruction = state.dragSourceId != null
        ? 'Drag to a compatible connection point'
        : 'Long press and drag from a connection point';
    } else {
      instruction = state.selectedWireId != null
        ? 'Tap on a compatible point to connect'
        : 'Tap on a connection point to select it';
    }
    
    return Positioned(
      top: 8,
      left: 0,
      right: 0,
      child: Center(
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: _showFireAnimation
                ? Colors.red.shade900
                : _showPowerUpAnimation
                    ? Colors.green.shade900
                    : Colors.black87,
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            instruction,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ),
    );
  }
  
  /// Handle energize button press
  void _onEnergizePressed(TransformerTrainerState state) {
    setState(() {
      _isEnergized = true;
    });
    
    // Validate connections
    final EnergizationResult result = state.energizeTransformer();
    
    if (result.isCorrect) {
      // Show power-up animation for correct connections
      setState(() {
        _showPowerUpAnimation = true;
      });
      HapticFeedback.lightImpact();
    } else {
      // Show electrical fire animation for incorrect connections
      setState(() {
        _showFireAnimation = true;
      });
      HapticFeedback.heavyImpact();
      widget.onConnectionError(result.errorMessage ?? 'Incorrect connections detected!');
    }
  }
  
  /// Handle reset button press
  void _onResetPressed(TransformerTrainerState state) {
    setState(() {
      _isEnergized = false;
      _showFireAnimation = false;
      _showPowerUpAnimation = false;
    });
    state.clearConnections();
    HapticFeedback.lightImpact();
  }
}

/// Custom painter for drag preview line
class DragPreviewPainter extends CustomPainter {

  DragPreviewPainter({
    required this.from,
    required this.to,
  });
  final Offset from;
  final Offset to;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = Colors.blue.withValues(alpha: 0.6)
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw dashed line
    _drawDashedLine(canvas, from, to, paint);
  }

  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const double dashWidth = 10;
    const double dashSpace = 5;
    final double distance = (to - from).distance;
    final Offset direction = (to - from) / distance;
    
    double currentDistance = 0;
    while (currentDistance < distance) {
      final Offset dashStart = from + direction * currentDistance;
      final Offset dashEnd = from + direction * math.min(currentDistance + dashWidth, distance);
      canvas.drawLine(dashStart, dashEnd, paint);
      currentDistance += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(DragPreviewPainter oldDelegate) => from != oldDelegate.from || to != oldDelegate.to;
}

/// Custom painter for drawing wire connections
class ConnectionWirePainter extends CustomPainter {

  ConnectionWirePainter({
    required this.from,
    required this.to,
    required this.isCorrect,
  });
  final Offset from;
  final Offset to;
  final bool isCorrect;

  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..strokeWidth = 3.0
      ..style = PaintingStyle.stroke;

    if (isCorrect) {
      paint.color = Colors.green;
    } else {
      paint.color = Colors.red;
      paint.strokeWidth = 4.0;
    }

    // Draw the wire connection
    canvas.drawLine(from, to, paint);

    // Add arrowhead to indicate direction
    _drawArrowHead(canvas, from, to, paint);
  }

  void _drawArrowHead(Canvas canvas, Offset from, Offset to, Paint paint) {
    const double arrowSize = 8;
    final double direction = (to - from).direction;
    
    final Offset arrowPoint1 = Offset(
      to.dx - arrowSize * 0.866 * math.cos(direction - 0.5),
      to.dy - arrowSize * 0.866 * math.sin(direction - 0.5),
    );
    
    final Offset arrowPoint2 = Offset(
      to.dx - arrowSize * 0.866 * math.cos(direction + 0.5),
      to.dy - arrowSize * 0.866 * math.sin(direction + 0.5),
    );

    final Path path = Path()
      ..moveTo(to.dx, to.dy)
      ..lineTo(arrowPoint1.dx, arrowPoint1.dy)
      ..moveTo(to.dx, to.dy)
      ..lineTo(arrowPoint2.dx, arrowPoint2.dy);

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(ConnectionWirePainter oldDelegate) => from != oldDelegate.from ||
           to != oldDelegate.to ||
           isCorrect != oldDelegate.isCorrect;
}

extension on Offset {
}
