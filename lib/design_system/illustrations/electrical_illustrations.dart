import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'dart:math' as math;
import '../app_theme.dart';

/// Enum defining all available electrical-themed illustrations
enum ElectricalIllustration {
  // Worker illustrations
  electricianAtWork,
  linemanClimbing,
  teamMeeting,
  safetyGear,
  
  // Tool illustrations
  multimeter,
  wireStrippers,
  voltMeter,
  toolBelt,
  
  // Concept illustrations
  circuitBoard,
  powerGrid,
  lightBulb,
  electricalPanel,
  
  // Status illustrations
  jobSearch,
  success,
  noResults,
  maintenance,
  
  // Union/Badge illustrations
  ibewLogo,
  unionBadge,
  certification,
}

/// Widget that displays electrical-themed illustrations with animations
class ElectricalIllustrationWidget extends StatelessWidget {
  final ElectricalIllustration illustration;
  final double? width;
  final double? height;
  final Color? color;
  final bool animate;
  final Duration animationDuration;
  final Curve animationCurve;

  const ElectricalIllustrationWidget({
    super.key,
    required this.illustration,
    this.width,
    this.height,
    this.color,
    this.animate = true,
    this.animationDuration = const Duration(milliseconds: 800),
    this.animationCurve = Curves.easeOutBack,
  });

  @override
  Widget build(BuildContext context) {
    Widget illustrationWidget = _buildIllustration();
    
    if (animate) {
      illustrationWidget = illustrationWidget
          .animate()
          .scale(
            duration: animationDuration,
            curve: animationCurve,
            begin: const Offset(0.8, 0.8),
            end: const Offset(1.0, 1.0),
          )
          .fadeIn(
            duration: animationDuration * 0.8,
          );
    }
    
    return illustrationWidget;
  }

  Widget _buildIllustration() {
    // For now, we'll use custom painted illustrations
    // In a production app, you would load actual SVG files
    return CustomPaint(
      size: Size(width ?? 200, height ?? 200),
      painter: _getIllustrationPainter(),
    );
  }

  CustomPainter _getIllustrationPainter() {
    switch (illustration) {
      case ElectricalIllustration.circuitBoard:
        return CircuitBoardPainter(color: color ?? AppTheme.accentCopper);
      case ElectricalIllustration.lightBulb:
        return LightBulbPainter(color: color ?? AppTheme.accentCopper);
      case ElectricalIllustration.noResults:
        return NoResultsPainter(color: color ?? AppTheme.textLight);
      case ElectricalIllustration.jobSearch:
        return JobSearchPainter(color: color ?? AppTheme.primaryNavy);
      default:
        return PlaceholderPainter(color: color ?? AppTheme.textLight);
    }
  }
}

/// Circuit board pattern painter
class CircuitBoardPainter extends CustomPainter {
  final Color color;

  CircuitBoardPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final nodePaint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    // Draw circuit lines
    final path = Path();
    
    // Horizontal lines
    for (int i = 1; i < 5; i++) {
      final y = size.height * (i / 5);
      path.moveTo(0, y);
      path.lineTo(size.width * 0.3, y);
      path.moveTo(size.width * 0.7, y);
      path.lineTo(size.width, y);
    }
    
    // Vertical lines
    for (int i = 1; i < 5; i++) {
      final x = size.width * (i / 5);
      path.moveTo(x, 0);
      path.lineTo(x, size.height * 0.3);
      path.moveTo(x, size.height * 0.7);
      path.lineTo(x, size.height);
    }
    
    canvas.drawPath(path, paint);
    
    // Draw nodes
    for (int i = 1; i < 5; i++) {
      for (int j = 1; j < 5; j++) {
        final x = size.width * (i / 5);
        final y = size.height * (j / 5);
        canvas.drawCircle(Offset(x, y), 4, nodePaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Light bulb illustration painter
class LightBulbPainter extends CustomPainter {
  final Color color;

  LightBulbPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw bulb shape
    final bulbPath = Path();
    final centerX = size.width / 2;
    final centerY = size.height * 0.35;
    final radius = size.width * 0.3;
    
    // Bulb top
    bulbPath.addOval(Rect.fromCircle(
      center: Offset(centerX, centerY),
      radius: radius,
    ));
    
    // Bulb base
    final baseTop = centerY + radius * 0.8;
    final baseBottom = size.height * 0.7;
    final baseWidth = radius * 0.6;
    
    bulbPath.moveTo(centerX - baseWidth, baseTop);
    bulbPath.lineTo(centerX - baseWidth * 0.8, baseBottom);
    bulbPath.lineTo(centerX + baseWidth * 0.8, baseBottom);
    bulbPath.lineTo(centerX + baseWidth, baseTop);
    
    canvas.drawPath(bulbPath, fillPaint);
    canvas.drawPath(bulbPath, paint);
    
    // Draw filament
    final filamentPaint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    final filamentPath = Path();
    filamentPath.moveTo(centerX - radius * 0.3, centerY);
    for (int i = 0; i < 5; i++) {
      final x = centerX - radius * 0.3 + (radius * 0.6 * i / 4);
      final y = centerY + (i % 2 == 0 ? -10 : 10);
      filamentPath.lineTo(x, y);
    }
    
    canvas.drawPath(filamentPath, filamentPaint);
    
    // Draw light rays
    final rayPaint = Paint()
      ..color = color.withValues(alpha: 0.5)
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;
    
    for (int i = 0; i < 8; i++) {
      final angle = (i * 45) * 3.14159 / 180;
      final startRadius = radius + 10;
      final endRadius = radius + 25;
      
      final startX = centerX + startRadius * math.cos(angle);
      final startY = centerY + startRadius * math.sin(angle);
      final endX = centerX + endRadius * math.cos(angle);
      final endY = centerY + endRadius * math.sin(angle);
      
      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        rayPaint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// No results illustration painter
class NoResultsPainter extends CustomPainter {
  final Color color;

  NoResultsPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    // Draw empty toolbox
    final boxRect = Rect.fromLTWH(
      size.width * 0.2,
      size.height * 0.3,
      size.width * 0.6,
      size.height * 0.4,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(boxRect, const Radius.circular(8)),
      paint,
    );
    
    // Draw handle
    final handlePath = Path();
    handlePath.moveTo(size.width * 0.35, size.height * 0.3);
    handlePath.quadraticBezierTo(
      size.width * 0.5, size.height * 0.2,
      size.width * 0.65, size.height * 0.3,
    );
    
    canvas.drawPath(handlePath, paint);
    
    // Draw search icon
    final searchCenter = Offset(size.width * 0.5, size.height * 0.5);
    final searchRadius = size.width * 0.1;
    
    canvas.drawCircle(searchCenter, searchRadius, paint);
    
    // Search handle
    final handleStart = Offset(
      searchCenter.dx + searchRadius * 0.7,
      searchCenter.dy + searchRadius * 0.7,
    );
    final handleEnd = Offset(
      searchCenter.dx + searchRadius * 1.3,
      searchCenter.dy + searchRadius * 1.3,
    );
    
    canvas.drawLine(handleStart, handleEnd, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Job search illustration painter
class JobSearchPainter extends CustomPainter {
  final Color color;

  JobSearchPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke;

    final fillPaint = Paint()
      ..color = color.withValues(alpha: 0.1)
      ..style = PaintingStyle.fill;

    // Draw clipboard
    final clipboardRect = Rect.fromLTWH(
      size.width * 0.25,
      size.height * 0.2,
      size.width * 0.5,
      size.height * 0.6,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(clipboardRect, const Radius.circular(8)),
      fillPaint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(clipboardRect, const Radius.circular(8)),
      paint,
    );
    
    // Draw clip
    final clipRect = Rect.fromLTWH(
      size.width * 0.4,
      size.height * 0.15,
      size.width * 0.2,
      size.height * 0.1,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(clipRect, const Radius.circular(4)),
      paint,
    );
    
    // Draw checklist lines
    final lineStartX = size.width * 0.35;
    final lineEndX = size.width * 0.65;
    
    for (int i = 0; i < 3; i++) {
      final y = size.height * (0.35 + i * 0.1);
      
      // Draw checkbox
      final checkboxRect = Rect.fromLTWH(
        lineStartX - 15,
        y - 8,
        16,
        16,
      );
      canvas.drawRect(checkboxRect, paint);
      
      // Draw checkmark for first item
      if (i == 0) {
        final checkPath = Path();
        checkPath.moveTo(lineStartX - 12, y);
        checkPath.lineTo(lineStartX - 8, y + 4);
        checkPath.lineTo(lineStartX - 2, y - 6);
        canvas.drawPath(checkPath, paint);
      }
      
      // Draw line
      canvas.drawLine(
        Offset(lineStartX + 10, y),
        Offset(lineEndX, y),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Placeholder illustration painter
class PlaceholderPainter extends CustomPainter {
  final Color color;

  PlaceholderPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    // Draw electrical plug icon as placeholder
    final centerX = size.width / 2;
    final centerY = size.height / 2;
    
    // Draw plug body
    final plugRect = Rect.fromCenter(
      center: Offset(centerX, centerY),
      width: size.width * 0.4,
      height: size.height * 0.3,
    );
    
    canvas.drawRRect(
      RRect.fromRectAndRadius(plugRect, const Radius.circular(8)),
      paint,
    );
    
    // Draw prongs
    final prongWidth = size.width * 0.05;
    final prongHeight = size.height * 0.15;
    final prongSpacing = size.width * 0.15;
    
    canvas.drawRect(
      Rect.fromLTWH(
        centerX - prongSpacing / 2 - prongWidth / 2,
        centerY - plugRect.height / 2 - prongHeight,
        prongWidth,
        prongHeight,
      ),
      paint,
    );
    
    canvas.drawRect(
      Rect.fromLTWH(
        centerX + prongSpacing / 2 - prongWidth / 2,
        centerY - plugRect.height / 2 - prongHeight,
        prongWidth,
        prongHeight,
      ),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

/// Helper class to get illustrations by context
class IllustrationHelper {
  static ElectricalIllustration getEmptyStateIllustration(String context) {
    switch (context.toLowerCase()) {
      case 'jobs':
      case 'search':
        return ElectricalIllustration.noResults;
      case 'saved':
      case 'bookmarks':
        return ElectricalIllustration.jobSearch;
      case 'profile':
      case 'settings':
        return ElectricalIllustration.electricianAtWork;
      default:
        return ElectricalIllustration.lightBulb;
    }
  }
  
  static ElectricalIllustration getSuccessIllustration() {
    return ElectricalIllustration.success;
  }
  
  static ElectricalIllustration getLoadingIllustration() {
    return ElectricalIllustration.circuitBoard;
  }
}