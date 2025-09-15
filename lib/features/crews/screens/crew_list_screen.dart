import 'package:flutter/material.dart';

/// Placeholder screen for Crew List
/// TODO: Implement full crew list functionality in Phase 3.6
class CrewListScreen extends StatelessWidget {
  const CrewListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crews'),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.groups,
              size: 64,
              color: Color(0xFFB45309), // AppTheme.accentCopper
            ),
            SizedBox(height: 16),
            Text(
              'Crews Communication Hub',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            SizedBox(height: 8),
            Text(
              'Coming Soon - Phase 3',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          // TODO: Navigate to create crew screen
        },
        backgroundColor: const Color(0xFFB45309), // AppTheme.accentCopper
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
