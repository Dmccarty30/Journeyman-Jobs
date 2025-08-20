
import 'package:flutter/material.dart';

import '../models/transformer_models_export.dart';
import 'base_transformer_painter.dart';

/// Custom painter for Open Delta (V-V) transformer bank configuration
/// Uses only two transformers to provide three-phase service
class OpenDeltaPainter extends BaseTransformerPainter {
  OpenDeltaPainter({
    super.connections,
    super.isEnergized,
  });
  
  @override
  void paintBackground(Canvas canvas, Size size) {
    final double centerX = size.width / 2;
    final double centerY = size.height / 2;
    
    // Define transformer positions (only two transformers)
    final Offset t1Position = Offset(centerX, centerY - 40);      // Top transformer
    final Offset t2Position = Offset(centerX, centerY + 40);      // Bottom transformer
    
    // Draw the two transformers
    drawTransformer(canvas, t1Position, 'T1');
    drawTransformer(canvas, t2Position, 'T2');
    
    // Draw missing transformer location (dashed outline)
    _drawMissingTransformer(canvas, Offset(centerX - 80, centerY), 'T3 (Out)');
    
    // Draw primary side (Open Delta configuration)
    _drawPrimaryOpenDelta(canvas, centerX, centerY);
    
    // Draw secondary side (Open Delta configuration)
    _drawSecondaryOpenDelta(canvas, centerX, centerY);
    
    // Draw voltage labels
    _drawVoltageLabels(canvas, centerX, centerY);
    
    // Draw connection terminals
    _drawConnectionTerminals(canvas, centerX, centerY);
    
    // Draw capacity indicator
    _drawCapacityIndicator(canvas, centerX, centerY);
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

  /// Draw missing transformer with dashed outline
  void _drawMissingTransformer(Canvas canvas, Offset position, String label) {
    const double width = 80;
    const double height = 60;
    
    final Rect rect = Rect.fromCenter(
      center: position,
      width: width,
      height: height,
    );

    // Draw dashed outline
    final Paint dashedPaint = Paint()
      ..color = Colors.red[300]!
      ..strokeWidth = 2.0
      ..style = PaintingStyle.stroke;

    _drawDashedRect(canvas, rect, dashedPaint);

    // Draw X mark to indicate failure/removal
    canvas.drawLine(
      Offset(position.dx - width * 0.3, position.dy - height * 0.3),
      Offset(position.dx + width * 0.3, position.dy + height * 0.3),
      Paint()..color = Colors.red..strokeWidth = 3.0,
    );
    canvas.drawLine(
      Offset(position.dx + width * 0.3, position.dy - height * 0.3),
      Offset(position.dx - width * 0.3, position.dy + height * 0.3),
      Paint()..color = Colors.red..strokeWidth = 3.0,
    );

    // Draw label
    _drawText(canvas, label, position + const Offset(0, -45), 
              TextStyle(color: Colors.red[600], fontSize: 12, fontWeight: FontWeight.bold),);
  }

  /// Draw primary Open Delta configuration
  void _drawPrimaryOpenDelta(Canvas canvas, double centerX, double centerY) {
    // Primary input lines
    final Offset phaseAStart = Offset(centerX - 140, centerY - 80);
    final Offset phaseBStart = Offset(centerX - 140, centerY);
    final Offset phaseCStart = Offset(centerX - 140, centerY + 80);
    
    // Primary connection points for open delta (V-V)
    final Offset connectionPoint1 = Offset(centerX - 60, centerY - 40);
    final Offset connectionPoint2 = Offset(centerX - 60, centerY + 40);
    
    // Draw input phase lines
    drawPhaseLine(canvas, phaseAStart, connectionPoint1, 'A');
    drawPhaseLine(canvas, phaseCStart, connectionPoint2, 'C');
    
    // Draw phase B connection to center tap
    final Offset centerTap = Offset(centerX - 60, centerY);
    drawPhaseLine(canvas, phaseBStart, centerTap, 'B');
    
    // Connect transformers to primary points
    final Offset t1H1 = Offset(centerX - 40, centerY - 40);
    final Offset t1H2 = Offset(centerX - 40, centerY - 20);
    final Offset t2H1 = Offset(centerX - 40, centerY + 20);
    final Offset t2H2 = Offset(centerX - 40, centerY + 40);
    
    // Draw V-V primary connections
    canvas.drawLine(connectionPoint1, t1H1, linePaint);
    canvas.drawLine(centerTap, t1H2, linePaint);
    canvas.drawLine(centerTap, t2H1, linePaint);
    canvas.drawLine(connectionPoint2, t2H2, linePaint);
    
    // Draw the "V" shape of the open delta
    canvas.drawLine(connectionPoint1, centerTap, thickLinePaint);
    canvas.drawLine(centerTap, connectionPoint2, thickLinePaint);
  }

  /// Draw secondary Open Delta configuration
  void _drawSecondaryOpenDelta(Canvas canvas, double centerX, double centerY) {
    // Secondary output lines
    final Offset phaseAEnd = Offset(centerX + 140, centerY - 80);
    final Offset phaseBEnd = Offset(centerX + 140, centerY);
    final Offset phaseCEnd = Offset(centerX + 140, centerY + 80);
    
    // Secondary connection points for open delta (V-V)
    final Offset connectionPoint1 = Offset(centerX + 60, centerY - 40);
    final Offset connectionPoint2 = Offset(centerX + 60, centerY + 40);
    final Offset centerTap = Offset(centerX + 60, centerY);
    
    // Draw output phase lines
    drawPhaseLine(canvas, connectionPoint1, phaseAEnd, 'a');
    drawPhaseLine(canvas, centerTap, phaseBEnd, 'b');
    drawPhaseLine(canvas, connectionPoint2, phaseCEnd, 'c');
    
    // Connect transformers to secondary points
    final Offset t1X1 = Offset(centerX + 40, centerY - 40);
    final Offset t1X2 = Offset(centerX + 40, centerY - 20);
    final Offset t2X1 = Offset(centerX + 40, centerY + 20);
    final Offset t2X2 = Offset(centerX + 40, centerY + 40);
    
    // Draw V-V secondary connections
    canvas.drawLine(t1X1, connectionPoint1, linePaint);
    canvas.drawLine(t1X2, centerTap, linePaint);
    canvas.drawLine(t2X1, centerTap, linePaint);
    canvas.drawLine(t2X2, connectionPoint2, linePaint);
    
    // Draw the "V" shape of the open delta
    canvas.drawLine(connectionPoint1, centerTap, thickLinePaint);
    canvas.drawLine(centerTap, connectionPoint2, thickLinePaint);
  }

  /// Draw voltage measurement labels
  void _drawVoltageLabels(Canvas canvas, double centerX, double centerY) {
    // Primary voltage
    _drawText(canvas, '12.47kV', Offset(centerX - 120, centerY - 100), voltageStyle);
    
    // Secondary voltages (note: can be unbalanced under load)
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 140, centerY - 80),
      Offset(centerX + 140, centerY),
      '240V',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 140, centerY),
      Offset(centerX + 140, centerY + 80),
      '240V',
    );
    
    drawVoltageIndicator(
      canvas,
      Offset(centerX + 140, centerY - 80),
      Offset(centerX + 140, centerY + 80),
      '240V*',
    );
    
    // Warning about voltage unbalance
    _drawText(canvas, '*May be unbalanced', 
              Offset(centerX + 50, centerY + 120), 
              TextStyle(color: Colors.orange[600], fontSize: 10, fontStyle: FontStyle.italic),);
  }

  /// Draw capacity indicator
  void _drawCapacityIndicator(Canvas canvas, double centerX, double centerY) {
    // Draw capacity warning box
    final Rect warningRect = Rect.fromLTWH(centerX - 100, centerY - 120, 200, 40);
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(warningRect, const Radius.circular(6)),
      Paint()..color = Colors.orange[50]!,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(warningRect, const Radius.circular(6)),
      Paint()
        ..color = Colors.orange[300]!
        ..strokeWidth = 2
        ..style = PaintingStyle.stroke,
    );
    
    // Draw warning icon
    final Offset iconCenter = Offset(centerX - 80, centerY - 100);
    canvas.drawCircle(
      iconCenter,
      8,
      Paint()..color = Colors.orange,
    );
    
    _drawText(canvas, '!', iconCenter - const Offset(2, 5), 
              const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.bold),);
    
    // Draw capacity text
    _drawText(canvas, 'OPEN DELTA OPERATION', 
              Offset(centerX - 50, centerY - 115), 
              const TextStyle(color: Colors.orange, fontSize: 12, fontWeight: FontWeight.bold),);
    
    _drawText(canvas, '86.6% of Normal Capacity', 
              Offset(centerX - 50, centerY - 100), 
              const TextStyle(color: Colors.orange, fontSize: 11),);
  }

  /// Draw connection terminals
  void _drawConnectionTerminals(Canvas canvas, double centerX, double centerY) {
    // Primary input terminals
    drawTerminal(canvas, Offset(centerX - 140, centerY - 80), 'A', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 140, centerY), 'B', 
                 isInput: true,);
    drawTerminal(canvas, Offset(centerX - 140, centerY + 80), 'C', 
                 isInput: true,);
    
    // Transformer 1 terminals
    drawTerminal(canvas, Offset(centerX - 40, centerY - 40), 'T1-H1');
    drawTerminal(canvas, Offset(centerX - 40, centerY - 20), 'T1-H2');
    drawTerminal(canvas, Offset(centerX + 40, centerY - 40), 'T1-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY - 20), 'T1-X2', 
                 type: ConnectionType.secondary,);
    
    // Transformer 2 terminals
    drawTerminal(canvas, Offset(centerX - 40, centerY + 20), 'T2-H1');
    drawTerminal(canvas, Offset(centerX - 40, centerY + 40), 'T2-H2');
    drawTerminal(canvas, Offset(centerX + 40, centerY + 20), 'T2-X1', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 40, centerY + 40), 'T2-X2', 
                 type: ConnectionType.secondary,);
    
    // Output terminals
    drawTerminal(canvas, Offset(centerX + 140, centerY - 80), 'a', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 140, centerY), 'b', 
                 type: ConnectionType.secondary,);
    drawTerminal(canvas, Offset(centerX + 140, centerY + 80), 'c', 
                 type: ConnectionType.secondary,);
  }

  /// Helper method to draw dashed rectangle
  void _drawDashedRect(Canvas canvas, Rect rect, Paint paint) {
    const double dashWidth = 8;
    const double dashSpace = 4;
    
    // Top edge
    _drawDashedLine(canvas, rect.topLeft, rect.topRight, paint, dashWidth, dashSpace);
    // Right edge
    _drawDashedLine(canvas, rect.topRight, rect.bottomRight, paint, dashWidth, dashSpace);
    // Bottom edge
    _drawDashedLine(canvas, rect.bottomRight, rect.bottomLeft, paint, dashWidth, dashSpace);
    // Left edge
    _drawDashedLine(canvas, rect.bottomLeft, rect.topLeft, paint, dashWidth, dashSpace);
  }

  /// Helper method to draw dashed line with custom dash pattern
  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint, 
                      double dashWidth, double dashSpace,) {
    final double distance = (to - from).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final Offset start = from + (to - from) * (i * (dashWidth + dashSpace) / distance);
      final Offset end = from + (to - from) * ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(start, end, paint);
    }
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
