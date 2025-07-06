import 'package:flutter/material.dart';
import 'locals_widget.dart';

/// LocalsScreen that displays the LocalsWidget
/// 
/// This screen serves as a wrapper for the LocalsWidget and provides
/// a clean interface for displaying local union information.
class LocalsScreen extends StatelessWidget {
  const LocalsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const LocalsWidget();
  }
}
