import 'package:flutter/material.dart';

class TransmissionTowerIcon extends StatelessWidget {
  final double size;
  final Color color;

  const TransmissionTowerIcon({
    super.key,
    this.size = 24,
    this.color = Colors.black,
  });

  @override
  Widget build(BuildContext context) {
    return Icon(
      Icons.bolt,  // Placeholder icon; replace with custom path if available
      size: size,
      color: color,
    );
  }
}