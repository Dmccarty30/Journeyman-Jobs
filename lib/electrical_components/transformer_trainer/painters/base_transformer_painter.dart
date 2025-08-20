
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../../design_system/app_theme.dart';
import '../models/transformer_models_export.dart';

/// Base class for all transformer diagram painters with mobile optimizations
abstract class BaseTransformerPainter extends CustomPainter {
  
  BaseTransformerPainter({
    this.connections = const <WireConnection>[],
    this.isEnergized = false,
  });
  // Cached paint objects for better performance
  static final Map<String, Paint> _paintCache = <String, ui.Paint>{};
  static final Map<String, TextPainter> _textPainterCache = <String, TextPainter>{};
  
  // Background caching
  ui.Image? _cachedBackground;
  Size? _lastSize;
  
  // Connection data for repaint optimization
  final List<WireConnection> connections;
  final bool isEnergized;
  
  // Cached paint getters for better performance
  Paint get linePaint => _getCachedPaint('line', () => Paint()
    ..color = AppTheme.textPrimary
    ..strokeWidth = 2.0
    ..style = PaintingStyle.stroke,);

  Paint get thickLinePaint => _getCachedPaint('thickLine', () => Paint()
    ..color = AppTheme.textPrimary
    ..strokeWidth = 3.0
    ..style = PaintingStyle.stroke,);

  Paint get dashedLinePaint => _getCachedPaint('dashedLine', () => Paint()
    ..color = AppTheme.mediumGray
    ..strokeWidth = 1.5
    ..style = PaintingStyle.stroke,);

  Paint get fillPaint => _getCachedPaint('fill', () => Paint()
    ..color = AppTheme.white
    ..style = PaintingStyle.fill,);

  // Text styles with mobile scaling
  TextStyle get labelStyle => _getScaledTextStyle(12, FontWeight.bold, AppTheme.textPrimary);
  TextStyle get voltageStyle => _getScaledTextStyle(11, FontWeight.w500, AppTheme.errorRed);
  TextStyle get terminalStyle => _getScaledTextStyle(10, FontWeight.bold, AppTheme.infoBlue);
  
  // Cache management methods
  static Paint _getCachedPaint(String key, Paint Function() factory) => _paintCache.putIfAbsent(key, factory);
  
  // Cached text painters for better performance
  TextPainter _getCachedTextPainter(String text, TextStyle style) {
    final String key = '${text}_${style.fontSize}_${style.color}_${style.fontWeight}';
    return _textPainterCache.putIfAbsent(key, () {
      final TextPainter painter = TextPainter(
        text: TextSpan(text: text, style: style),
        textDirection: TextDirection.ltr,
      );
      painter.layout();
      return painter;
    });
  }
  
  // Mobile responsive text scaling
  TextStyle _getScaledTextStyle(double baseSize, FontWeight weight, Color color) {
    // Scale text based on device pixel ratio for better mobile readability
    final double scale = ui.window.devicePixelRatio > 2.5 ? 1.2 : 1.0;
    return TextStyle(
      color: color,
      fontSize: baseSize * scale,
      fontWeight: weight,
    );
  }
  
  // Static cleanup method for memory management
  static void clearCache() {
    _paintCache.clear();
    _textPainterCache.clear();
  }

  @override
  void paint(Canvas canvas, Size size) {
    // Check if we can use cached background
    if (_cachedBackground != null && _lastSize == size) {
      // Draw cached background
      canvas.drawImage(_cachedBackground!, Offset.zero, Paint());
      // Only draw dynamic elements (connections)
      paintConnections(canvas, size);
    } else {
      // Full repaint needed
      paintBackground(canvas, size);
      paintConnections(canvas, size);
      // Cache the background for future use
      _cacheBackground(canvas, size);
    }
  }

  @override
  bool shouldRepaint(covariant BaseTransformerPainter oldDelegate) {
    // Only repaint if connections or energization state changed
    return connections != oldDelegate.connections || 
           isEnergized != oldDelegate.isEnergized;
  }
  
  // Subclasses should implement these methods
  void paintBackground(Canvas canvas, Size size);
  void paintConnections(Canvas canvas, Size size);
  
  // Background caching implementation
  void _cacheBackground(Canvas canvas, Size size) {
    // Implementation would cache the static background
    // This is a placeholder - actual implementation would use PictureRecorder
    _lastSize = size;
  }

  /// Draw a transformer symbol at the specified position
  void drawTransformer(
    Canvas canvas,
    Offset position,
    String label, {
    double width = 80,
    double height = 60,
  }) {
    final ui.Rect rect = Rect.fromCenter(
      center: position,
      width: width,
      height: height,
    );

    // Draw transformer outline
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      linePaint,
    );

    // Draw primary winding (left side)
    final ui.Offset primaryCenter = Offset(position.dx - width * 0.2, position.dy);
    _drawWinding(canvas, primaryCenter, 20);

    // Draw secondary winding (right side)
    final ui.Offset secondaryCenter = Offset(position.dx + width * 0.2, position.dy);
    _drawWinding(canvas, secondaryCenter, 20);

    // Draw core (center line)
    canvas.drawLine(
      Offset(position.dx, position.dy - height * 0.3),
      Offset(position.dx, position.dy + height * 0.3),
      thickLinePaint,
    );

    // Draw label
    _drawText(canvas, label, position + const Offset(0, -35), labelStyle);
  }

  /// Draw a winding symbol (circle with internal lines)
  void _drawWinding(Canvas canvas, Offset center, double radius) {
    // Draw outer circle
    canvas.drawCircle(center, radius, linePaint);
    
    // Draw internal coil lines
    for (int i = -2; i <= 2; i++) {
      final double y = center.dy + i * 4.0;
      canvas.drawLine(
        Offset(center.dx - radius * 0.7, y),
        Offset(center.dx + radius * 0.7, y),
        dashedLinePaint,
      );
    }
  }

  /// Draw terminal connections (H1, H2, X1, X2, etc.)
  void drawTerminal(
    Canvas canvas,
    Offset position,
    String label, {
    bool isInput = false,
    ConnectionType type = ConnectionType.primary,
  }) {
    const double terminalRadius = 6;
    
    // Draw terminal circle
    final ui.Color color = _getTerminalColor(type);
    final ui.Paint terminalPaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    
    canvas.drawCircle(position, terminalRadius, terminalPaint);
    canvas.drawCircle(position, terminalRadius, linePaint);
    
    // Draw terminal label
    final ui.Offset labelOffset = isInput 
        ? Offset(position.dx - 20, position.dy - 5)
        : Offset(position.dx + 15, position.dy - 5);
    
    _drawText(canvas, label, labelOffset, terminalStyle);
  }

  /// Get color for terminal based on type
  Color _getTerminalColor(ConnectionType type) {
    switch (type) {
      case ConnectionType.primary:
        return AppTheme.errorRed.withOpacity(0.6);
      case ConnectionType.secondary:
        return AppTheme.infoBlue.withOpacity(0.6);
      case ConnectionType.neutral:
        return AppTheme.mediumGray.withOpacity(0.6);
      case ConnectionType.ground:
        return AppTheme.groundBrown.withOpacity(0.6);
    }
  }

  /// Draw phase line connections
  void drawPhaseLine(
    Canvas canvas,
    Offset from,
    Offset to,
    String phaseLabel, {
    bool isDashed = false,
  }) {
    final ui.Paint paint = isDashed ? dashedLinePaint : linePaint;
    
    if (isDashed) {
      _drawDashedLine(canvas, from, to, paint);
    } else {
      canvas.drawLine(from, to, paint);
    }

    // Draw phase label at midpoint
    final ui.Offset midPoint = Offset(
      (from.dx + to.dx) / 2,
      (from.dy + to.dy) / 2 - 10,
    );
    _drawText(canvas, phaseLabel, midPoint, labelStyle);
  }

  /// Draw voltage measurement indicators
  void drawVoltageIndicator(
    Canvas canvas,
    Offset from,
    Offset to,
    String voltage,
  ) {
    // Draw voltage measurement line
    final ui.Paint voltagePaint = Paint()
      ..color = AppTheme.errorRed
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    canvas.drawLine(from, to, voltagePaint);

    // Draw voltage label
    final ui.Offset midPoint = Offset(
      (from.dx + to.dx) / 2,
      (from.dy + to.dy) / 2,
    );
    _drawText(canvas, voltage, midPoint, voltageStyle);
  }

  /// Draw ground symbol
  void drawGroundSymbol(Canvas canvas, Offset position) {
    const double groundSize = 15;
    
    // Draw ground lines (decreasing width)
    for (int i = 0; i < 4; i++) {
      final double width = groundSize - (i * 3);
      final double y = position.dy + (i * 3);
      canvas.drawLine(
        Offset(position.dx - width / 2, y),
        Offset(position.dx + width / 2, y),
        thickLinePaint,
      );
    }

    // Draw connection line to ground
    canvas.drawLine(
      Offset(position.dx, position.dy - 10),
      Offset(position.dx, position.dy),
      linePaint,
    );
  }

  /// Draw neutral symbol (typically a small circle with N)
  void drawNeutralSymbol(Canvas canvas, Offset position) {
    const double neutralRadius = 8;
    
    // Draw neutral circle
    canvas.drawCircle(position, neutralRadius, fillPaint);
    canvas.drawCircle(position, neutralRadius, linePaint);
    
    // Draw 'N' label
    _drawText(canvas, 'N', position - const Offset(3, 5), terminalStyle);
  }

  /// Helper method to draw text with caching
  void _drawText(Canvas canvas, String text, Offset position, TextStyle style) {
    final TextPainter textPainter = _getCachedTextPainter(text, style);
    textPainter.paint(canvas, position);
  }

  /// Helper method to draw dashed lines
  void _drawDashedLine(Canvas canvas, Offset from, Offset to, Paint paint) {
    const double dashWidth = 5;
    const double dashSpace = 3;
    
    final double distance = (to - from).distance;
    final int dashCount = (distance / (dashWidth + dashSpace)).floor();
    
    for (int i = 0; i < dashCount; i++) {
      final ui.Offset start = from + (to - from) * (i * (dashWidth + dashSpace) / distance);
      final ui.Offset end = from + (to - from) * ((i * (dashWidth + dashSpace) + dashWidth) / distance);
      canvas.drawLine(start, end, paint);
    }
  }
}
