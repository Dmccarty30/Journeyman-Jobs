import 'package:flutter/material.dart';

/// Placeholder screen for Create Crew
/// TODO: Implement full crew creation functionality in Phase 3.6
class CreateCrewScreen extends StatelessWidget {
  const CreateCrewScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Crew'),
        backgroundColor: const Color(0xFF1A202C), // AppTheme.primaryNavy
      ),
      body: const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add,
              size: 64,
              color: Color(0xFFB45309), // AppTheme.accentCopper
            ),
            SizedBox(height: 16),
            Text(
              'Create New Crew',
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
    );
  }
}
