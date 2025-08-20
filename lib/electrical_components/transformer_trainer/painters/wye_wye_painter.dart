
import 'package:flutter/material.dart';

import '../models/transformer_models_export.dart';
import 'base_transformer_painter.dart';

/// Custom painter for Wye-Wye transformer bank configuration with mobile optimizations
class WyeWyePainter extends BaseTransformerPainter {
  WyeWyePainter({
    super.connections,
    super.isEnergized,
  });

  @override
  void paintBackground(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Define transformer positions (forming a vertical arrangement)
    final Offset t1Position = Offset(centerX, centerY - 80);
    final Offset t2Position = Offset(centerX, centerY);
    final Offset t3Position = Offset(centerX, centerY + 80);
    
    // Draw the three transformers
    drawTransformer(canvas, t1Position, 'T1');
    drawTransformer(canvas, t2Position, 'T2');
    drawTransformer(canvas, t3Position, 'T3');
    
    // Draw primary side (left side - Wye configuration)
    _drawPrimaryWye(canvas, centerX, centerY);
    
    // Draw secondary side (right side - Wye configuration)
    _drawSecondaryWye(canvas, centerX, centerY);
    
    // Draw voltage labels
    _drawVoltageLabels(canvas, centerX, centerY);
    
    // Draw connection terminals
    _drawConnectionTerminals(canvas, centerX, centerY);
  }
  
  @override
  void paintConnections(Canvas canvas, Size size) {
    // Draw active wire connections with visual feedback
    for (final WireConnection connection in connections) {
      _drawWireConnection(canvas, connection);
    }
    
    // Add energization effects if enabled
    if (isEnergized) {
      _drawEnergizationEffects(canvas, size);
    }
  }
  
  /// Draw a wire connection between points
  void _drawWireConnection(Canvas canvas, WireConnection connection) {
    // This would get the actual positions of connection points
    // For now, using placeholder positions
    final Offset? fromPosition = _getConnectionPointPosition(connection.fromPointId);
    final Offset? toPosition = _getConnectionPointPosition(connection.toPointId);
    
    if (fromPosition != null && toPosition != null) {
      final Paint paint = Paint()
        ..color = connection.isCorrect ? Colors.green : Colors.red
        ..strokeWidth = 3.0
        ..style = PaintingStyle.stroke;
      
      canvas.drawLine(fromPosition, toPosition, paint);
      
      // Add arrow to indicate direction
      _drawConnectionArrow(canvas, fromPosition, toPosition, paint);
    }
  }
  
  /// Get connection point position by ID
  Offset? _getConnectionPointPosition(String pointId) {
    // This would map connection point IDs to actual positions
    // Implementation would depend on the connection point layout
    return null; // Placeholder
  }
  
  /// Draw energization effects
  void _drawEnergizationEffects(Canvas canvas, Size size) {
    // Add visual effects for energized state
    final Paint glowPaint = Paint()
      ..color = Colors.yellow.withOpacity(0.3)
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 3);
    
    // Apply glow effect to energized connections
    for (final WireConnection connection in connections) {
      if (connection.isCorrect) {
        final Offset? fromPosition = _getConnectionPointPosition(connection.fromPointId);
        final Offset? toPosition = _getConnectionPointPosition(connection.toPointId);
        
        if (fromPosition != null && toPosition != null) {
          canvas.drawLine(fromPosition, toPosition, glowPaint);
        }
      }
    }
  }
  
  /// Draw connection arrow
  void _drawConnectionArrow(Canvas canvas, Offset from, Offset to, Paint paint) {
    const double arrowSize = 8;
    final Offset direction = to - from;
    final double distance = direction.distance;
    
    if (distance > 0) {
      final Offset normalizedDirection = direction / distance;
      final Offset arrowStart = to - normalizedDirection * arrowSize;
      
      final Offset perpendicular = Offset(-normalizedDirection.dy, normalizedDirection.dx) * (arrowSize * 0.5);
      
      final Path arrowPath = Path()
        ..moveTo(to.dx, to.dy)
        ..lineTo(arrowStart.dx + perpendicular.dx, arrowStart.dy + perpendicular.dy)
        ..lineTo(arrowStart.dx - perpendicular.dx, arrowStart.dy - perpendicular.dy)
        ..close();
      
      canvas.drawPath(arrowPath, paint);
    }
  }

  /// Draw primary Wye configuration
  void _drawPrimaryWye(Canvas canvas, double centerX, double centerY) {
    // Primary input lines (left side)
    final Offset phaseAStart = Offset(centerX - 150, centerY - 80);
    final Offset phaseBStart = Offset(centerX - 150, centerY);
    final Offset phaseCStart = Offset(centerX - 150, centerY + 80);
    
    // Primary terminals on transformers
    final Offset t1H1 = Offset(centerX - 40, centerY - 80);
    final Offset t2H1 = Offset(centerX - 40, centerY);
    final Offset t3H1 = Offset(centerX - 40, centerY + 80);
    
    // Draw phase input lines
    drawPhaseLine(canvas, phaseAStart, t1H1, 'A');
    drawPhaseLine(canvas, phaseBStart, t2H1, 'B');
    drawPhaseLine(canvas, phaseCStart, t3H1, 'C');
    
    // Draw primary neutral point (Wye center)
    final Offset primaryNeutral = Offset(centerX - 60, centerY + 40);
    
    // H2 terminals on transformers
    final Offset t1H2 = Offset(centerX - 40, centerY - 60);
    final Offset t2H2 = Offset(centerX - 40, centerY + 20);
    final Offset t3H2 = Offset(centerX - 40, centerY + 100);
    
    // Draw connections from H2 terminals to neutral point
    canvas.drawLine(t1H2, primaryNeutral, linePaint);
    canvas.drawLine(t2H2, primaryNeutral, linePaint);
    canvas.drawLine(t3H2, primaryNeutral, linePaint);
    
    // Draw neutral symbol
    drawNeutralSymbol(canvas, primaryNeutral);
    
    // Draw ground connection for primary neutral
    drawGroundSymbol(canvas, Offset(primaryNeutral.dx, primaryNeutral.dy + 30));
  }

  /// Draw secondary Wye configuration
  void _drawSecondaryWye(Canvas canvas, double centerX, double centerY) {
    // Secondary output lines (right side)
    final Offset phaseAEnd = Offset(centerX + 150, centerY - 80);
    final Offset phaseBEnd = Offset(centerX + 150, centerY);
    final Offset phaseCEnd = Offset(centerX + 150, centerY + 80);
    final Offset neutralEnd = Offset(centerX + 150, centerY + 120);
    
    // Secondary terminals on transformers
    final Offset t1X1 = Offset(centerX + 40, centerY - 80);
    final Offset t2X1 = Offset(centerX + 40, centerY);
    final Offset t3X1 = Offset(centerX + 40, centerY + 80);
    
    // Draw phase output lines
    drawPhaseLine(canvas, t1X1, phaseAEnd, 'a');
    drawPhaseLine(canvas, t2X1, phaseBEnd, 'b');
    drawPhaseLine(canvas, t3X1, phaseCEnd, 'c');
    
    // Draw secondary neutral point (Wye center)
    final Offset secondaryNeutral = Offset(centerX + 60, centerY + 40);
    
    // X2 terminals on transformers
    final Offset t1X2 = Offset(centerX + 40, centerY - 60);
    final Offset t2X2 = Offset(centerX + 40, centerY + 20);
    final Offset t3X2 = Offset(centerX + 40, centerY + 100);
    
    // Draw connections from X2 terminals to neutral point
    canvas.drawLine(t1X2, secondaryNeutral, linePaint);
    canvas.drawLine(t2X2, secondaryNeutral, linePaint);
    canvas.drawLine(t3X2, secondaryNeutral, linePaint);
    
    // Draw neutral output line
    canvas.drawLine(secondaryNeutral, neutralEnd, linePaint);
    
    // Draw neutral symbols
    drawNeutralSymbol(canvas, secondaryNeutral);
    drawNeutralSymbol(canvas, neutralEnd);
    
    // Draw ground connection for secondary neutral
    drawGroundSymbol(canvas, Offset(neutralEnd.dx, neutralEnd.dy + 30));
  }

  /// Draw voltage measurement labels
  void _drawVoltageLabels(Canvas canvas, double centerX, double centerY) {
    // Primary voltage labels
    _drawText(canvas, '7200V', Offset(centerX - 100, centerY - 100), voltageStyle);
    
    // Secondary voltage labels
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 150, centerY - 80),
      Offset(centerX + 150, centerY + 120),
      '120V',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 150, centerY - 80),
      Offset(centerX + 150, centerY),
      '240V',
    );
  }

  /// Draw connection terminals for interactive use
  void _drawConnectionTerminals(Canvas canvas, double centerX, double centerY) {
    // Primary input terminals
    drawTerminal(canvas, Offset(centerX - 150, centerY - 80), 'A', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 150, centerY), 'B', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 150, centerY + 80), 'C', 
                 isInput: true,);
    
    // Transformer primary terminals
    drawTerminal(canvas, Offset(centerX - 40, centerY - 80), 'H1');
    drawTerminal(canvas, Offset(centerX - 40, centerY - 60), 'H2');
    drawTerminal(canvas, Offset(centerX - 40, centerY), 'H1');
    drawTerminal(canvas, Offset(centerX - 40, centerY + 20), 'H2');
    drawTerminal(canvas, Offset(centerX - 40, centerY + 80), 'H1');
    drawTerminal(canvas, Offset(centerX - 40, centerY + 100), 'H2');
    
    // Transformer secondary terminals
    drawTerminal(canvas, Offset(centerX + 40, centerY - 80), 'X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY - 60), 'X2', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY), 'X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY + 20), 'X2', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY + 80), 'X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY + 100), 'X2', 
                 type: ConnectionType.secondary,);
    
    // Output terminals
    drawTerminal(canvas, Offset(centerX + 150, centerY - 80), 'a', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 150, centerY), 'b', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 150, centerY + 80), 'c', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 150, centerY + 120), 'N', 
                 type: ConnectionType.neutral,);
  }

  /// Helper method to draw text
  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}
