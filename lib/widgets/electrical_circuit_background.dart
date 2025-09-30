import 'package:flutter/material.dart';

/// A reusable background widget that displays an electrical circuit pattern
/// with configurable density for consistent app-wide styling.
class ElectricalCircuitBackground extends StatelessWidget {
  final Widget child;
  final String density; // 'low', 'medium', 'high'
  final double opacity;

  const ElectricalCircuitBackground({
    required this.child,
    this.density = 'high',
    this.opacity = 0.05,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).scaffoldBackgroundColor,
        image: DecorationImage(
          image: AssetImage('assets/images/circuit_bg_$density.png'),
          fit: BoxFit.cover,
          opacity: opacity,
        ),
      ),
      child: child,
    );
  }
}