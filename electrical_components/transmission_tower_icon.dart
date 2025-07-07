import 'package:flutter/material.dart';

/// Transmission Tower Icon
/// 
/// A static icon representing electrical transmission infrastructure.
/// Features a detailed tower structure with cross beams and power lines,
/// designed in a clean line art style.
/// 
/// Example usage:
/// ```dart
/// TransmissionTowerIcon(
///   size: 48,
///   color: Colors.navy,
/// )
/// ```
class TransmissionTowerIcon extends StatelessWidget {
  /// Size of the icon (width and height)
  final double size;
  
  /// Color of the transmission tower
  final Color? color;

  const TransmissionTowerIcon({
    Key? key,
    this.size = 48,
    this.color,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: TransmissionTowerPainter(
          color: color ?? const Color(0xFF1A202C), // Navy
        ),
      ),
    );
  }
}

class TransmissionTowerPainter extends CustomPainter {
  final Color color;

  TransmissionTowerPainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final thickPaint = Paint()
      ..color = color
      ..strokeWidth = 3
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final centerX = size.width / 2;
    final bottom = size.height * 0.9;
    final top = size.height * 0.1;

    // Draw main tower structure (vertical pole)
    canvas.drawLine(
      Offset(centerX, bottom),
      Offset(centerX, top),
      thickPaint,
    );

    // Draw cross beams at different heights
    final beamPositions = [0.25, 0.45, 0.65, 0.8];
    
    for (int i = 0; i < beamPositions.length; i++) {
      final y = bottom - (beamPositions[i] * (bottom - top));
      final beamWidth = size.width * (0.4 - i * 0.05); // Narrower as we go up
      
      // Horizontal beam
      canvas.drawLine(
        Offset(centerX - beamWidth, y),
        Offset(centerX + beamWidth, y),
        paint,
      );
      
      // Diagonal support beams
      if (i < beamPositions.length - 1) {
        final nextY = bottom - (beamPositions[i + 1] * (bottom - top));
        final nextBeamWidth = size.width * (0.4 - (i + 1) * 0.05);
        
        // Left diagonal
        canvas.drawLine(
          Offset(centerX - beamWidth, y),
          Offset(centerX - nextBeamWidth, nextY),
          paint,
        );
        
        // Right diagonal
        canvas.drawLine(
          Offset(centerX + beamWidth, y),
          Offset(centerX + nextBeamWidth, nextY),
          paint,
        );
      }
    }

    // Draw power line insulators
    final insulatorPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;
      
    final insulatorY = bottom - (0.3 * (bottom - top));
    
    for (int i = -1; i <= 1; i++) {
      if (i != 0) {
        final x = centerX + i * size.width * 0.25;
        // Draw insulator string
        canvas.drawLine(
          Offset(x, insulatorY),
          Offset(x, insulatorY + 8),
          insulatorPaint,
        );
        
        // Draw insulator disc
        canvas.drawCircle(
          Offset(x, insulatorY + 10),
          3,
          insulatorPaint,
        );
      }
    }

    // Draw power lines extending beyond the tower
    final lineY = insulatorY + 12;
    final linePaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    // Draw curved power lines (catenary curves)
    for (int i = 0; i < 3; i++) {
      final yOffset = i * 2;
      final path = Path();
      
      // Left side curve
      path.moveTo(0, lineY + yOffset + 5);
      path.quadraticBezierTo(
        centerX - size.width * 0.25, lineY + yOffset,
        centerX - size.width * 0.25, lineY + yOffset + 2,
      );
      
      // Right side curve
      path.moveTo(centerX + size.width * 0.25, lineY + yOffset + 2);
      path.quadraticBezierTo(
        centerX + size.width * 0.25, lineY + yOffset,
        size.width, lineY + yOffset + 5,
      );
      
      canvas.drawPath(path, linePaint);
    }
    
    // Draw ground line
    final groundPaint = Paint()
      ..color = color.withValues(alpha: 0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;
      
    canvas.drawLine(
      Offset(0, bottom + 2),
      Offset(size.width, bottom + 2),
      groundPaint,
    );
    
    // Draw warning sign on tower
    final signPaint = Paint()
      ..color = color
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;
      
    final signSize = size.width * 0.08;
    final signX = centerX + size.width * 0.15;
    final signY = bottom - (0.5 * (bottom - top));
    
    // Triangle warning sign
    final trianglePath = Path();
    trianglePath.moveTo(signX, signY - signSize);
    trianglePath.lineTo(signX - signSize, signY + signSize);
    trianglePath.lineTo(signX + signSize, signY + signSize);
    trianglePath.close();
    
    canvas.drawPath(trianglePath, signPaint);
    
    // Warning symbol (exclamation mark)
    canvas.drawLine(
      Offset(signX, signY - signSize * 0.3),
      Offset(signX, signY + signSize * 0.2),
      Paint()
        ..color = color
        ..strokeWidth = 1
        ..style = PaintingStyle.stroke
        ..strokeCap = StrokeCap.round,
    );
    
    canvas.drawCircle(
      Offset(signX, signY + signSize * 0.5),
      1,
      Paint()
        ..color = color
        ..style = PaintingStyle.fill,
    );
  }

  @override
  bool shouldRepaint(covariant TransmissionTowerPainter oldDelegate) {
    return oldDelegate.color != color;
  }
}