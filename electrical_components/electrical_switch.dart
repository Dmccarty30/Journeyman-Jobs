import 'package:flutter/material.dart';

/// A custom painter for the electrical switch component
class _ElectricalSwitchPainter extends CustomPainter {
  final bool isOn;
  final Color onColor;
  final Color offColor;

  _ElectricalSwitchPainter({
    required this.isOn,
    required this.onColor,
    required this.offColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isOn ? onColor : offColor
      ..style = PaintingStyle.fill;

    // Draw switch background
    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, 0, size.width, size.height),
      Radius.circular(size.height / 2),
    );
    canvas.drawRRect(backgroundRect, paint);

    // Draw switch handle
    final handlePaint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final handleRadius = size.height * 0.4;
    final handleX = isOn ? size.width - handleRadius - 4 : handleRadius + 4;
    final handleY = size.height / 2;

    canvas.drawCircle(
      Offset(handleX, handleY),
      handleRadius,
      handlePaint,
    );
  }

  @override
  bool shouldRepaint(_ElectricalSwitchPainter oldDelegate) {
    return oldDelegate.isOn != isOn ||
        oldDelegate.onColor != onColor ||
        oldDelegate.offColor != offColor;
  }
}

/// A custom electrical switch widget
class ElectricalSwitch extends StatelessWidget {
  final bool value;
  final ValueChanged<bool>? onChanged;
  final Color? activeColor;
  final Color? inactiveColor;

  const ElectricalSwitch({
    super.key,
    required this.value,
    this.onChanged,
    this.activeColor,
    this.inactiveColor,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final effectiveActiveColor = activeColor ?? theme.colorScheme.primary;
    final effectiveInactiveColor = inactiveColor ?? Colors.grey;

    return GestureDetector(
      onTap: onChanged != null ? () => onChanged!(!value) : null,
      child: SizedBox(
        width: 60,
        height: 30,
        child: CustomPaint(
          painter: _ElectricalSwitchPainter(
            isOn: value,
            onColor: effectiveActiveColor,
            offColor: effectiveInactiveColor,
          ),
        ),
      ),
    );
  }
}