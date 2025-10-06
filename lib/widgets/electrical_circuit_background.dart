import 'package:flutter/material.dart';

/// A reusable background widget that displays an electrical circuit pattern.
///
/// This widget provides a consistent, themed background across the application,
/// with options to configure the density and opacity of the circuit pattern image.
class ElectricalCircuitBackground extends StatelessWidget {
  /// The widget to display on top of the background.
  final Widget child;
  /// The density of the circuit pattern.
  ///
  /// This corresponds to the image asset used (e.g., 'circuit_bg_high.png').
  /// Valid values are typically 'low', 'medium', or 'high'.
  final String density;
  /// The opacity of the background image, allowing content underneath to be
  /// partially visible if desired.
  final double opacity;

  /// Creates an [ElectricalCircuitBackground] widget.
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