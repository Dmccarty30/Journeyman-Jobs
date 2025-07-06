import 'package:flutter/material.dart';

class PowerLineLoader extends StatelessWidget {
  final double width;
  final double height;
  final Duration duration;
  final Color pulseColor;
  final Color lineColor;

  const PowerLineLoader({
    super.key,
    this.width = 300,
    this.height = 80,
    this.duration = const Duration(seconds: 3),
    this.pulseColor = Colors.red,
    this.lineColor = Colors.grey,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(pulseColor),
          strokeWidth: 4,
        ),
      ),
    );
  }
}