
import 'package:flutter/material.dart';

import '../models/transformer_models_export.dart';
import 'base_transformer_painter.dart';

/// Custom painter for Delta-Delta transformer bank configuration
class DeltaDeltaPainter extends BaseTransformerPainter {
  DeltaDeltaPainter({
    super.connections,
    super.isEnergized,
  });
  
  @override
  void paintBackground(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Define transformer positions (forming a triangular arrangement)
    final Offset t1Position = Offset(centerX, centerY - 60);      // Top transformer
    final Offset t2Position = Offset(centerX - 60, centerY + 30); // Bottom left
    final Offset t3Position = Offset(centerX + 60, centerY + 30); // Bottom right
    
    // Draw the three transformers
    drawTransformer(canvas, t1Position, 'T1', width: 60, height: 40);
    drawTransformer(canvas, t2Position, 'T2', width: 60, height: 40);
    drawTransformer(canvas, t3Position, 'T3', width: 60, height: 40);
    
    // Draw primary side (left side - Delta configuration)
    _drawPrimaryDelta(canvas, centerX, centerY);
    
    // Draw secondary side (right side - Delta configuration)
    _drawSecondaryDelta(canvas, centerX, centerY);
    
    // Draw voltage labels
    _drawVoltageLabels(canvas, centerX, centerY);
    
    // Draw connection terminals
    _drawConnectionTerminals(canvas, centerX, centerY);
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
    // Primary input lines (left side)
    final Offset phaseAStart = Offset(centerX - 120, centerY - 60);
    final Offset phaseBStart = Offset(centerX - 120, centerY);
    final Offset phaseCStart = Offset(centerX - 120, centerY + 60);
    
    // Primary connection points for delta formation
    final Offset deltaPoint1 = Offset(centerX - 80, centerY - 40);  // Top
    final Offset deltaPoint2 = Offset(centerX - 80, centerY + 20);  // Bottom left
    final Offset deltaPoint3 = Offset(centerX - 60, centerY - 10);  // Bottom right
    
    // Draw input phase lines to delta points
    drawPhaseLine(canvas, phaseAStart, deltaPoint1, 'A');
    drawPhaseLine(canvas, phaseBStart, deltaPoint2, 'B');
    drawPhaseLine(canvas, phaseCStart, deltaPoint3, 'C');
    
    // Draw primary delta connections
    // Form the delta triangle
    canvas.drawLine(deltaPoint1, deltaPoint2, thickLinePaint);
    canvas.drawLine(deltaPoint2, deltaPoint3, thickLinePaint);
    canvas.drawLine(deltaPoint3, deltaPoint1, thickLinePaint);
    
    // Connect transformers to delta points
    final Offset t1H1 = Offset(centerX - 30, centerY - 60);
    final Offset t1H2 = Offset(centerX - 15, centerY - 50);
    final Offset t2H1 = Offset(centerX - 90, centerY + 30);
    final Offset t2H2 = Offset(centerX - 45, centerY + 40);
    final Offset t3H1 = Offset(centerX + 30, centerY + 30);
    final Offset t3H2 = Offset(centerX + 45, centerY + 20);
    
    // Connect H1 terminals to appropriate delta points
    canvas.drawLine(t1H1, deltaPoint1, linePaint);
    canvas.drawLine(t2H1, deltaPoint2, linePaint);
    canvas.drawLine(t3H1, deltaPoint3, linePaint);
    
    // Connect H2 terminals to form delta closure
    canvas.drawLine(t1H2, deltaPoint3, linePaint);
    canvas.drawLine(t2H2, deltaPoint1, linePaint);
    canvas.drawLine(t3H2, deltaPoint2, linePaint);
  }

  /// Draw secondary Delta configuration
  void _drawSecondaryDelta(Canvas canvas, double centerX, double centerY) {
    // Secondary output lines (right side)
    final Offset phaseAEnd = Offset(centerX + 120, centerY - 60);
    final Offset phaseBEnd = Offset(centerX + 120, centerY);
    final Offset phaseCEnd = Offset(centerX + 120, centerY + 60);
    
    // Secondary connection points for delta formation
    final Offset deltaPoint1 = Offset(centerX + 80, centerY - 40);  // Top
    final Offset deltaPoint2 = Offset(centerX + 80, centerY + 20);  // Bottom left
    final Offset deltaPoint3 = Offset(centerX + 60, centerY - 10);  // Bottom right
    
    // Draw output phase lines from delta points
    drawPhaseLine(canvas, deltaPoint1, phaseAEnd, 'a');
    drawPhaseLine(canvas, deltaPoint2, phaseBEnd, 'b');
    drawPhaseLine(canvas, deltaPoint3, phaseCEnd, 'c');
    
    // Draw secondary delta connections
    // Form the delta triangle
    canvas.drawLine(deltaPoint1, deltaPoint2, thickLinePaint);
    canvas.drawLine(deltaPoint2, deltaPoint3, thickLinePaint);
    canvas.drawLine(deltaPoint3, deltaPoint1, thickLinePaint);
    
    // Connect transformers to delta points
    final Offset t1X1 = Offset(centerX + 30, centerY - 60);
    final Offset t1X2 = Offset(centerX + 15, centerY - 50);
    final Offset t2X1 = Offset(centerX - 30, centerY + 30);
    final Offset t2X2 = Offset(centerX - 15, centerY + 40);
    final Offset t3X1 = Offset(centerX + 90, centerY + 30);
    final Offset t3X2 = Offset(centerX + 75, centerY + 20);
    
    // Connect X1 terminals to appropriate delta points
    canvas.drawLine(t1X1, deltaPoint1, linePaint);
    canvas.drawLine(t2X1, deltaPoint2, linePaint);
    canvas.drawLine(t3X1, deltaPoint3, linePaint);
    
    // Connect X2 terminals to form delta closure
    canvas.drawLine(t1X2, deltaPoint3, linePaint);
    canvas.drawLine(t2X2, deltaPoint1, linePaint);
    canvas.drawLine(t3X2, deltaPoint2, linePaint);
  }

  /// Draw voltage measurement labels
  void _drawVoltageLabels(Canvas canvas, double centerX, double centerY) {
    // Primary voltage labels (typically higher voltage)
    _drawText(canvas, '12.47kV', Offset(centerX - 100, centerY - 80), voltageStyle);
    
    // Secondary voltage labels (line-to-line voltages for delta)
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 120, centerY - 60),
      Offset(centerX + 120, centerY),
      '480V',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 120, centerY),
      Offset(centerX + 120, centerY + 60),
      '480V',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 120, centerY + 60),
      Offset(centerX + 120, centerY - 60),
      '480V',
    );
  }

  /// Draw connection terminals for interactive use
  void _drawConnectionTerminals(Canvas canvas, double centerX, double centerY) {
    // Primary input terminals
    drawTerminal(canvas, Offset(centerX - 120, centerY - 60), 'A', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 120, centerY), 'B', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 120, centerY + 60), 'C', 
                 isInput: true,);
    
    // Transformer 1 terminals
    drawTerminal(canvas, Offset(centerX - 30, centerY - 60), 'T1-H1');
    drawTerminal(canvas, Offset(centerX - 15, centerY - 50), 'T1-H2');
    drawTerminal(canvas, Offset(centerX + 30, centerY - 60), 'T1-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 15, centerY - 50), 'T1-X2', 
                 type: ConnectionType.secondary,);
    
    // Transformer 2 terminals
    drawTerminal(canvas, Offset(centerX - 90, centerY + 30), 'T2-H1');
    drawTerminal(canvas, Offset(centerX - 45, centerY + 40), 'T2-H2');
    drawTerminal(canvas, Offset(centerX - 30, centerY + 30), 'T2-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX - 15, centerY + 40), 'T2-X2', 
                 type: ConnectionType.secondary,);
    
    // Transformer 3 terminals
    drawTerminal(canvas, Offset(centerX + 30, centerY + 30), 'T3-H1');
    drawTerminal(canvas, Offset(centerX + 45, centerY + 20), 'T3-H2');
    drawTerminal(canvas, Offset(centerX + 90, centerY + 30), 'T3-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 75, centerY + 20), 'T3-X2', 
                 type: ConnectionType.secondary,);
    
    // Output terminals
    drawTerminal(canvas, Offset(centerX + 120, centerY - 60), 'a', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 120, centerY), 'b', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 120, centerY + 60), 'c', 
                 type: ConnectionType.secondary,);
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
