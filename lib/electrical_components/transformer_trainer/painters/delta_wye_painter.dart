
import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../models/transformer_models_export.dart';
import 'base_transformer_painter.dart';


/// Custom painter for Delta-Wye transformer bank configuration
/// Primary side in Delta, Secondary side in Wye
class DeltaWyePainter extends BaseTransformerPainter {
  DeltaWyePainter({
    super.connections,
    super.isEnergized,
  });
  
  @override
  void paintBackground(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Define transformer positions
    final Offset t1Position = Offset(centerX, centerY - 60);
    final Offset t2Position = Offset(centerX - 50, centerY + 40);
    final Offset t3Position = Offset(centerX + 50, centerY + 40);
    
    // Draw the three transformers
    drawTransformer(canvas, t1Position, 'T1');
    drawTransformer(canvas, t2Position, 'T2');
    drawTransformer(canvas, t3Position, 'T3');
    
    // Draw primary side (Delta configuration)
    _drawPrimaryDelta(canvas, centerX, centerY);
    
    // Draw secondary side (Wye configuration)
    _drawSecondaryWye(canvas, centerX, centerY);
    
    // Draw voltage labels
    _drawVoltageLabels(canvas, centerX, centerY);
    
    // Draw connection terminals
    _drawConnectionTerminals(canvas, centerX, centerY);
    
    // Draw phase shift indicator
    _drawPhaseShiftIndicator(canvas, centerX, centerY);
  }
  
  @override
  void paintConnections(Canvas canvas, Size size) {
    // Draw dynamic connection lines based on the current connections
    // This would show energized lines or specific connection states
    // For now, just a placeholder implementation
    if (isEnergized) {
      // Could draw energized indicators here
    }
    
    // ignore: unused_local_variable
    for (final WireConnection connection in connections) {
      // Draw each wire connection dynamically
      // This would be implemented based on your specific connection model
    }
  }

  /// Draw primary Delta configuration
  void _drawPrimaryDelta(Canvas canvas, double centerX, double centerY) {
    // Primary input lines
    final Offset phaseAStart = Offset(centerX - 140, centerY - 60);
    final Offset phaseBStart = Offset(centerX - 140, centerY);
    final Offset phaseCStart = Offset(centerX - 140, centerY + 60);
    
    // Primary delta connection points
    final Offset deltaPoint1 = Offset(centerX - 70, centerY - 30);  // Top
    final Offset deltaPoint2 = Offset(centerX - 90, centerY + 30);  // Bottom left
    final Offset deltaPoint3 = Offset(centerX - 50, centerY + 30);  // Bottom right
    
    // Draw input phase lines to delta points
    drawPhaseLine(canvas, phaseAStart, deltaPoint1, 'A');
    drawPhaseLine(canvas, phaseBStart, deltaPoint2, 'B');
    drawPhaseLine(canvas, phaseCStart, deltaPoint3, 'C');
    
    // Draw primary delta triangle
    canvas.drawLine(deltaPoint1, deltaPoint2, thickLinePaint);
    canvas.drawLine(deltaPoint2, deltaPoint3, thickLinePaint);
    canvas.drawLine(deltaPoint3, deltaPoint1, thickLinePaint);
    
    // Connect transformer H1 and H2 terminals to delta
    final Offset t1H1 = Offset(centerX - 40, centerY - 60);
    final Offset t1H2 = Offset(centerX - 25, centerY - 45);
    final Offset t2H1 = Offset(centerX - 90, centerY + 40);
    final Offset t2H2 = Offset(centerX - 75, centerY + 55);
    final Offset t3H1 = Offset(centerX + 10, centerY + 40);
    final Offset t3H2 = Offset(centerX + 25, centerY + 55);
    
    // Connect H1 terminals to delta points
    canvas.drawLine(t1H1, deltaPoint1, linePaint);
    canvas.drawLine(t2H1, deltaPoint2, linePaint);
    canvas.drawLine(t3H1, deltaPoint3, linePaint);
    
    // Delta closure connections (H2 terminals)
    canvas.drawLine(t1H2, deltaPoint2, linePaint);
    canvas.drawLine(t2H2, deltaPoint3, linePaint);
    canvas.drawLine(t3H2, deltaPoint1, linePaint);
  }

  /// Draw secondary Wye configuration
  void _drawSecondaryWye(Canvas canvas, double centerX, double centerY) {
    // Secondary output lines
    final Offset phaseAEnd = Offset(centerX + 140, centerY - 60);
    final Offset phaseBEnd = Offset(centerX + 140, centerY);
    final Offset phaseCEnd = Offset(centerX + 140, centerY + 60);
    final Offset neutralEnd = Offset(centerX + 140, centerY + 100);
    
    // Secondary terminals on transformers
    final Offset t1X1 = Offset(centerX + 40, centerY - 60);
    final Offset t2X1 = Offset(centerX - 10, centerY + 40);
    final Offset t3X1 = Offset(centerX + 90, centerY + 40);
    
    // Draw phase output lines
    drawPhaseLine(canvas, t1X1, phaseAEnd, 'a');
    drawPhaseLine(canvas, t2X1, phaseBEnd, 'b');
    drawPhaseLine(canvas, t3X1, phaseCEnd, 'c');
    
    // Draw secondary neutral point (Wye center)
    final Offset secondaryNeutral = Offset(centerX + 70, centerY + 20);
    
    // X2 terminals on transformers
    final Offset t1X2 = Offset(centerX + 25, centerY - 45);
    final Offset t2X2 = Offset(centerX + 5, centerY + 55);
    final Offset t3X2 = Offset(centerX + 75, centerY + 55);
    
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
    drawGroundSymbol(canvas, Offset(neutralEnd.dx, neutralEnd.dy + 25));
  }

  /// Draw voltage measurement labels
  void _drawVoltageLabels(Canvas canvas, double centerX, double centerY) {
    // Primary voltage (line-to-line for Delta)
    _drawText(canvas, '12.47kV', Offset(centerX - 120, centerY - 90), voltageStyle);
    
    // Secondary voltage (line-to-neutral and line-to-line for Wye)
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 140, centerY - 60),
      Offset(centerX + 140, centerY + 100),
      '277V L-N',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 140, centerY - 60),
      Offset(centerX + 140, centerY),
      '480V L-L',
    );
    
    // Note about phase shift
    _drawText(canvas, '30° Phase Shift', 
              Offset(centerX - 30, centerY + 120), 
              TextStyle(color: Colors.orange[700], fontSize: 12, fontWeight: FontWeight.bold),);
  }

  /// Draw phase shift indicator
  void _drawPhaseShiftIndicator(Canvas canvas, double centerX, double centerY) {
    // Draw a small diagram showing 30-degree phase shift
    final Offset indicatorCenter = Offset(centerX, centerY + 90);
    const double radius = 15;
    
    // Draw circle
    canvas.drawCircle(indicatorCenter, radius, linePaint);
    
    // Draw primary phasor (reference)
    canvas.drawLine(
      indicatorCenter,
      Offset(indicatorCenter.dx, indicatorCenter.dy - radius * 0.8),
      Paint()..color = Colors.red..strokeWidth = 2,
    );
    
    // Draw secondary phasor (30 degrees behind for Delta-Wye)
    const double angle = 30 * 3.14159 / 180; // +30 degrees in radians
    final double endX = indicatorCenter.dx + radius * 0.8 * math.sin(angle);
    final double endY = indicatorCenter.dy - radius * 0.8 * math.cos(angle);
    
    canvas.drawLine(
      indicatorCenter,
      Offset(endX, endY),
      Paint()..color = Colors.blue..strokeWidth = 2,
    );
    
    // Draw angle arc
    final Rect rect = Rect.fromCircle(center: indicatorCenter, radius: radius * 0.5);
    canvas.drawArc(
      rect,
      -3.14159 / 2, // Start at top
      angle, // Sweep 30 degrees
      false,
      Paint()..color = Colors.orange..strokeWidth = 1.5..style = PaintingStyle.stroke,
    );
    
    // Label
    _drawText(canvas, '30°', Offset(centerX + 5, centerY + 75), 
              const TextStyle(fontSize: 10, color: Colors.orange),);
  }

  /// Draw connection terminals
  void _drawConnectionTerminals(Canvas canvas, double centerX, double centerY) {
    // Primary input terminals
    drawTerminal(canvas, Offset(centerX - 140, centerY - 60), 'A', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 140, centerY), 'B', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 140, centerY + 60), 'C', 
                 isInput: true,);
    
    // Transformer terminals (showing key ones for T1)
    drawTerminal(canvas, Offset(centerX - 40, centerY - 60), 'T1-H1');
    drawTerminal(canvas, Offset(centerX - 25, centerY - 45), 'T1-H2');
    drawTerminal(canvas, Offset(centerX + 40, centerY - 60), 'T1-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 25, centerY - 45), 'T1-X2', 
                 type: ConnectionType.secondary,);
    
    // Output terminals
    drawTerminal(canvas, Offset(centerX + 140, centerY - 60), 'a', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 140, centerY), 'b', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 140, centerY + 60), 'c', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 140, centerY + 100), 'N', 
                 type: ConnectionType.neutral,);
    
    // Secondary neutral terminal
    drawTerminal(canvas, Offset(centerX + 70, centerY + 20), 'N', 
                 type: ConnectionType.neutral,);
  }

  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: text, style: style),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(canvas, position);
  }
}
