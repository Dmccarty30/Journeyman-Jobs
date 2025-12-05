import 'package:flutter/material.dart';
import '../electrical_components/electrical_circuit_background.dart';

class JJElectricalScaffold extends StatelessWidget {
  final PreferredSizeWidget? appBar;
  final Widget body;
  final Widget? floatingActionButton;
  final Widget? bottomNavigationBar;
  final Color? backgroundColor;
  final double backgroundOpacity;

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