import 'package:flutter/material.dart';

/// Placeholder screen for Crew Communication
/// TODO: Implement full crew messaging functionality in Phase 3.6
class CrewCommunicationScreen extends StatelessWidget {
  final String crewId;
  
  const CrewCommunicationScreen({
    super.key,
    required this.crewId,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Crew Chat'),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(
              Icons.chat,
              size: 64,
              color: Color(0xFFB45309), // AppTheme.accentCopper
            ),
            const SizedBox(height: 16),
            Text(
              'Crew Chat: $crewId',
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF1A202C),
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Coming Soon - Phase 3',
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
