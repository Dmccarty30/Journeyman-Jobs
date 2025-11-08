import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/tailboard_components.dart';

class ElectricalDialogBackground extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;

  const ElectricalDialogBackground({
    super.key,
    required this.child,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    return TailboardComponents.circuitBackground(
      context,
      child: Padding(
        padding: padding ??
            EdgeInsets.only(
              top: 24,
              left: 24,
              right: 24,
              bottom: MediaQuery.of(context).viewInsets.bottom + 24,
            ),
        child: child,
      ),
    );
  }
}
