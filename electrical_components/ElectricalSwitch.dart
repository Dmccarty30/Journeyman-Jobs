import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// @deprecated Use JJCircuitBreakerSwitch instead for a more authentic electrical switch experience
/// This component is deprecated and will be removed in a future version.
/// Please use JJCircuitBreakerSwitch from jj_circuit_breaker_switch.dart instead.
@Deprecated('Use JJCircuitBreakerSwitch instead')
class LegacyElectricalSwitch extends StatefulWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final double width;
  final double height;

  const LegacyElectricalSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.width = 100.0,
    this.height = 40.0,
  });

  @override
  State<LegacyElectricalSwitch> createState() => _LegacyElectricalSwitchState();
}

class _LegacyElectricalSwitchState extends State<LegacyElectricalSwitch> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800), // Smooth flow speed for electricity animation
    );
    if (widget.value) {
      _animationController.repeat();
    }
  }

  @override
  void didUpdateWidget(covariant LegacyElectricalSwitch oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.value != oldWidget.value) {
      if (widget.value) {
        _animationController.repeat();
      } else {
        _animationController.stop();
        _animationController.reset();
      }
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.onChanged != null) {
          widget.onChanged!(!widget.value);
        }
      },
      child: CustomPaint(
        size: Size(widget.width, widget.height),
        painter: _LegacyElectricalSwitchPainter(
          isOn: widget.value,
          animation: _animationController,
        ),
      ),
    );
  }
}

class _LegacyElectricalSwitchPainter extends CustomPainter {
  final bool isOn;
  final Animation<double> animation;

  _LegacyElectricalSwitchPainter({
    required this.isOn,
    required this.animation,
  }) : super(repaint: animation);

  @override
  void paint(Canvas canvas, Size size) {
    // Define paints abiding by AppTheme
    final wirePaint = Paint()
      ..color = AppTheme.accentCopper // Copper wire color
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final pivotPaint = Paint()
      ..color = AppTheme.mediumGray
      ..style = PaintingStyle.fill;

    final leverPaint = Paint()
      ..color = isOn ? AppTheme.successGreen : AppTheme.mediumGray // Green when on, gray when off
      ..strokeWidth = 6.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final currentPaint = Paint()
      ..color = AppTheme.warningYellow // Yellow for electricity flow
      ..strokeWidth = 4.0
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 2.0); // Soft glow effect

    // Positions for simple circuit elements
    final double pivotY = size.height / 2;
    final double leftPivotX = size.width * 0.25;
    final double rightPivotX = size.width * 0.75;
    final double leverLength = rightPivotX - leftPivotX;

    // Draw left wire (from start to left pivot)
    canvas.drawLine(Offset(0, pivotY), Offset(leftPivotX, pivotY), wirePaint);

    // Draw right wire (from right pivot to end)
    canvas.drawLine(Offset(rightPivotX, pivotY), Offset(size.width, pivotY), wirePaint);

    // Draw pivots (small circles representing switch contacts)
    canvas.drawCircle(Offset(leftPivotX, pivotY), 4.0, pivotPaint);
    canvas.drawCircle(Offset(rightPivotX, pivotY), 4.0, pivotPaint);

    // Draw lever (switch handle)
    if (isOn) {
      // Horizontal position when on (circuit closed)
      canvas.drawLine(Offset(leftPivotX, pivotY), Offset(rightPivotX, pivotY), leverPaint);
    } else {
      // Angled down when off (circuit open)
      const double angle = math.pi / 4; // 45 degrees down
      final double endX = leftPivotX + leverLength * math.cos(angle);
      final double endY = pivotY + leverLength * math.sin(angle);
      canvas.drawLine(Offset(leftPivotX, pivotY), Offset(endX, endY), leverPaint);
    }

    // Electricity flow animation when on (moving dashes along the entire wire)
    if (isOn) {
      const double dashLength = 8.0;
      const double spaceLength = 6.0;
      final double totalLength = size.width;
      final double offset = animation.value * (dashLength + spaceLength) * 2; // Faster flow

      for (double i = -offset; i < totalLength; i += dashLength + spaceLength) {
        final double start = i.clamp(0, totalLength);
        final double end = (i + dashLength).clamp(0, totalLength);
        if (end > start) {
          canvas.drawLine(Offset(start, pivotY), Offset(end, pivotY), currentPaint);
        }
      }
    }
  }

  @override
  bool shouldRepaint(covariant _LegacyElectricalSwitchPainter oldDelegate) {
    return isOn != oldDelegate.isOn || animation.value != oldDelegate.animation.value;
  }
}