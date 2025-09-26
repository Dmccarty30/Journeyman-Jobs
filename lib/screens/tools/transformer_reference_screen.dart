import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../design_system/app_theme.dart';
import '../../models/transformer_models.dart';
import 'transformer_workbench_screen.dart';

class TransformerReferenceScreen extends StatefulWidget {
  const TransformerReferenceScreen({super.key});

  @override
  State<TransformerReferenceScreen> createState() =>
      _TransformerReferenceScreenState();
}

class _TransformerReferenceScreenState
    extends State<TransformerReferenceScreen> {
  @override
  Widget build(BuildContext context) => Scaffold(
        backgroundColor: AppTheme.offWhite,
        appBar: AppBar(
          backgroundColor: AppTheme.primaryNavy,
          foregroundColor: AppTheme.white,
          title: const Text(
            'Reference Mode',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          actions: <Widget>[
            IconButton(
              icon: const Icon(Icons.search),
              onPressed: () {
                // TODO: Implement search functionality
              },
            ),
            IconButton(
              icon: const Icon(Icons.settings),
              onPressed: () {
                // TODO: Implement settings
              },
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              _buildInfoBanner(),
              const SizedBox(height: AppTheme.spacingLg),
              _buildSinglePotSection(),
              const SizedBox(height: AppTheme.spacingLg),
              _buildTwoPotSection(),
              const SizedBox(height: AppTheme.spacingLg),
              _buildThreePotSection(),
              const SizedBox(height: AppTheme.spacingXl),
            ],
          ),
        ),
      );

  Widget _buildInfoBanner() => Container(
        width: double.infinity,
        margin: const EdgeInsets.all(AppTheme.spacingMd),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.infoBlue.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.infoBlue.withValues(alpha: 0.3),
          ),
        ),
        child: const Row(
          children: <Widget>[
            Icon(
              Icons.info_outline,
              color: AppTheme.infoBlue,
              size: AppTheme.iconMd,
            ),
            SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'SELECT A CONFIGURATION TO EXPLORE',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    'Tap any transformer bank to view detailed diagrams and learn about each component.',
                    style: TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                      height: 1.4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildSinglePotSection() => _buildSection(
        title: 'SINGLE POT TRANSFORMERS',
        child: _buildSinglePotCard(),
      );

  Widget _buildTwoPotSection() => _buildSection(
        title: 'TWO POT BANKS',
        child: _buildTwoPotCard(),
      );

  Widget _buildThreePotSection() => _buildSection(
        title: 'THREE POT BANKS',
        child: Column(
          children: <Widget>[
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildThreePotCard(
                    'WYE-WYE',
                    _buildWyeWyeDiagram(),
                    TransformerBankType.wyeToWye,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildThreePotCard(
                    'DELTA-DELTA',
                    _buildDeltaDeltaDiagram(),
                    TransformerBankType.deltaToDelta,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: <Widget>[
                Expanded(
                  child: _buildThreePotCard(
                    'WYE-DELTA',
                    _buildWyeDeltaDiagram(),
                    TransformerBankType.wyeToDelta,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: _buildThreePotCard(
                    'DELTA-WYE',
                    _buildDeltaWyeDiagram(),
                    TransformerBankType.deltaToWye,
                  ),
                ),
              ],
            ),
          ],
        ),
      );

  Widget _buildSection({required String title, required Widget child}) =>
      Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.textSecondary,
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            child,
          ],
        ),
      );

  Widget _buildSinglePotCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: <Widget>[
            // Transformer diagram
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: CustomPaint(
                painter: SinglePotDiagramPainter(),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Information
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  const Text(
                    'SINGLE POT',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingXs),
                  const Text(
                    '120V/240V Residential',
                    style: TextStyle(
                      color: AppTheme.accentCopper,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  const Text(
                    '• Common household setup\n• Split-phase secondary\n• Center-tapped transformer',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingMd),
                  Align(
                    alignment: Alignment.centerRight,
                    child: _buildViewDetailsButton(
                      () => _openWorkbench(TransformerBankType.openDelta),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildTwoPotCard() => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Row(
          children: <Widget>[
            // Transformer diagram
            Container(
              width: 120,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: CustomPaint(
                painter: OpenDeltaDiagramPainter(),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            // Information
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    'OPEN DELTA',
                    style: TextStyle(
                      color: AppTheme.primaryNavy,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingXs),
                  Text(
                    '240V Three-Phase (2 Pots)',
                    style: TextStyle(
                      color: AppTheme.accentCopper,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingSm),
                  Text(
                    '• V-V Connection\n• 86.6% of full capacity\n• Emergency configuration',
                    style: TextStyle(
                      color: AppTheme.textLight,
                      fontSize: 12,
                      height: 1.4,
                    ),
                  ),
                  SizedBox(height: AppTheme.spacingMd),
                  Align(
                    alignment: Alignment.centerRight,
                  ),
                ],
              ),
            ),
          ],
        ),
      );

  Widget _buildThreePotCard(
    String title,
    Widget diagram,
    TransformerBankType bankType,
  ) =>
      Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
          border: Border.all(color: AppTheme.borderLight),
        ),
        child: Column(
          children: <Widget>[
            Text(
              title,
              style: const TextStyle(
                color: AppTheme.primaryNavy,
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Container(
              width: double.infinity,
              height: 80,
              decoration: BoxDecoration(
                color: AppTheme.lightGray,
                borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              ),
              child: diagram,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Align(
              alignment: Alignment.centerRight,
              child: _buildViewDetailsButton(() => _openWorkbench(bankType)),
            ),
          ],
        ),
      );

  void _openWorkbench(TransformerBankType bankType) {
    Navigator.push(
      context,
      MaterialPageRoute<Widget>(
        builder: (BuildContext context) => TransformerWorkbenchScreen(
          bankType: bankType,
          mode: TrainingMode.guided,
          difficulty: DifficultyLevel.beginner,
          isReferenceMode: true,
        ),
      ),
    );
  }

  Widget _buildViewDetailsButton(VoidCallback onPressed) => TextButton(
        onPressed: onPressed,
        style: TextButton.styleFrom(
          foregroundColor: AppTheme.accentCopper,
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
        ),
        child: const Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              'VIEW',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: 13,
              ),
            ),
            SizedBox(width: AppTheme.spacingXs),
            Icon(
              Icons.arrow_forward,
              size: AppTheme.iconSm,
            ),
          ],
        ),
      );

  // Diagram widgets
  Widget _buildWyeWyeDiagram() => CustomPaint(painter: WyeWyeDiagramPainter());

  Widget _buildDeltaDeltaDiagram() =>
      CustomPaint(painter: DeltaDeltaDiagramPainter());

  Widget _buildWyeDeltaDiagram() =>
      CustomPaint(painter: WyeDeltaDiagramPainter());

  Widget _buildDeltaWyeDiagram() =>
      CustomPaint(painter: DeltaWyeDiagramPainter());

}

// Custom painters for transformer diagrams
class SinglePotDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw transformer symbol (rectangle)
    final Rect rect = Rect.fromCenter(
      center: center,
      width: size.width * 0.4,
      height: size.height * 0.6,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, const Radius.circular(4)),
      paint,
    );

    // Draw T1 label
    final TextPainter textPainter = TextPainter(
      text: const TextSpan(
        text: 'T1',
        style: TextStyle(
          color: AppTheme.primaryNavy,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    textPainter.paint(
      canvas,
      Offset(
        center.dx - textPainter.width / 2,
        center.dy - textPainter.height / 2,
      ),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class OpenDeltaDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw two transformer rectangles
    final Rect t1Rect = Rect.fromCenter(
      center: Offset(center.dx - 25, center.dy),
      width: 20,
      height: 40,
    );
    final Rect t2Rect = Rect.fromCenter(
      center: Offset(center.dx + 25, center.dy),
      width: 20,
      height: 40,
    );

    canvas.drawRRect(
      RRect.fromRectAndRadius(t1Rect, const Radius.circular(2)),
      paint,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(t2Rect, const Radius.circular(2)),
      paint,
    );

    // Draw connection lines (V-V)
    canvas.drawLine(
      Offset(t1Rect.right, t1Rect.top),
      Offset(t2Rect.left, t2Rect.top),
      paint,
    );
    canvas.drawLine(
      Offset(t1Rect.right, t1Rect.bottom),
      Offset(t2Rect.left, t2Rect.bottom),
      paint,
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WyeWyeDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw Y-shaped connection (3 lines from center)
    const List<num> angles = <num>[0, 2.09, 4.19]; // 120 degrees apart
    for (final num angle in angles) {
      final Offset start = center;
      final Offset end = Offset(
        center.dx + 25 * math.cos(angle),
        center.dy + 25 * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DeltaDeltaDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 2
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw triangle (delta)
    final Path path = Path();
    const int radius = 20;
    const List<double> angles = <double>[1.57, 3.67, 5.76]; // Triangle points

    path.moveTo(
      center.dx + radius * math.cos(angles[0]),
      center.dy + radius * math.sin(angles[0]),
    );

    for (int i = 1; i < angles.length; i++) {
      path.lineTo(
        center.dx + radius * math.cos(angles[i]),
        center.dy + radius * math.sin(angles[i]),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class WyeDeltaDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw Y on left side
    final Offset leftCenter = Offset(center.dx - 15, center.dy);
    const List<num> angles = <num>[0, 2.09, 4.19];
    for (final num angle in angles) {
      final Offset start = leftCenter;
      final Offset end = Offset(
        leftCenter.dx + 12 * math.cos(angle),
        leftCenter.dy + 12 * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }

    // Draw triangle on right side
    final Offset rightCenter = Offset(center.dx + 15, center.dy);
    final Path path = Path();
    const int radius = 12;
    const List<double> triangleAngles = <double>[1.57, 3.67, 5.76];

    path.moveTo(
      rightCenter.dx + radius * math.cos(triangleAngles[0]),
      rightCenter.dy + radius * math.sin(triangleAngles[0]),
    );

    for (int i = 1; i < triangleAngles.length; i++) {
      path.lineTo(
        rightCenter.dx + radius * math.cos(triangleAngles[i]),
        rightCenter.dy + radius * math.sin(triangleAngles[i]),
      );
    }
    path.close();
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

class DeltaWyeDiagramPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint paint = Paint()
      ..color = AppTheme.primaryNavy
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final Offset center = Offset(size.width / 2, size.height / 2);

    // Draw triangle on left side
    final Offset leftCenter = Offset(center.dx - 15, center.dy);
    final Path path = Path();
    const int radius = 12;
    const List<double> triangleAngles = <double>[1.57, 3.67, 5.76];

    path.moveTo(
      leftCenter.dx + radius * math.cos(triangleAngles[0]),
      leftCenter.dy + radius * math.sin(triangleAngles[0]),
    );

    for (int i = 1; i < triangleAngles.length; i++) {
      path.lineTo(
        leftCenter.dx + radius * math.cos(triangleAngles[i]),
        leftCenter.dy + radius * math.sin(triangleAngles[i]),
      );
    }
    path.close();
    canvas.drawPath(path, paint);

    // Draw Y on right side
    final Offset rightCenter = Offset(center.dx + 15, center.dy);
    const List<num> angles = <num>[0, 2.09, 4.19];
    for (final num angle in angles) {
      final Offset start = rightCenter;
      final Offset end = Offset(
        rightCenter.dx + 12 * math.cos(angle),
        rightCenter.dy + 12 * math.sin(angle),
      );
      canvas.drawLine(start, end, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
