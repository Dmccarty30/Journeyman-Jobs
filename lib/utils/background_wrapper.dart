import 'package:flutter/material.dart';
import '../widgets/electrical_circuit_background.dart';

/// A custom scaffold widget that wraps its body with an [ElectricalCircuitBackground].
///
/// This widget simplifies the creation of screens that require the app's standard
/// electrical-themed background, providing a consistent look and feel.
class JJElectricalScaffold extends StatelessWidget {
  /// The app bar to display at the top of the scaffold.
  final PreferredSizeWidget? appBar;
  /// The primary content of the scaffold. This widget will be placed inside the
  /// [ElectricalCircuitBackground].
  final Widget body;
  /// A floating action button to display.
  final Widget? floatingActionButton;
  /// A bottom navigation bar to display at the bottom of the scaffold.
  final Widget? bottomNavigationBar;
  /// The background color of the scaffold. Defaults to `Colors.transparent` to allow
  /// the parent route's background to show through if needed.
  final Color? backgroundColor;
  /// The opacity of the electrical circuit background animation.
  final double backgroundOpacity;

  /// Creates an instance of [JJElectricalScaffold].
  const JJElectricalScaffold({
    super.key,
    this.appBar,
    required this.body,
    this.floatingActionButton,
    this.bottomNavigationBar,
    this.backgroundColor,
    this.backgroundOpacity = 0.35,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor ?? Colors.transparent,
      appBar: appBar,
      body: ElectricalCircuitBackground(
        density: 'high',
        opacity: backgroundOpacity,
        child: body,
      ),
      floatingActionButton: floatingActionButton,
      bottomNavigationBar: bottomNavigationBar,
    );
  }
}