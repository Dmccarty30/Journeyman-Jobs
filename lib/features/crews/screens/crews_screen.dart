import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';

import '../../../design_system/app_theme.dart';
import '../../../navigation/app_router.dart';
import 'tailboard_screen.dart';

class CrewsScreen extends ConsumerWidget {
  const CrewsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final userCrews = ref.watch(userCrewsProvider);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Crews'),
        backgroundColor: AppTheme.white,
        elevation: 0,
      ),
      body: userCrews.isEmpty
          ? _buildEmptyState(context)
          : _buildCrewsList(context), // Placeholder for when crews exist
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.group_add,
              size: 80,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: 24),
            Text(
              'No Crews Yet!',
              style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    color: AppTheme.darkGray,
                    fontWeight: FontWeight.bold,
                  ),
            ),
            const SizedBox(height: 16),
            Text(
              'Become part of a team. Create your own crew or join an existing one to collaborate on jobs.',
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: AppTheme.mediumGray,
                  ),
            ),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: () {
                  context.push(AppRouter.createCrew);
                },
                icon: const Icon(Icons.add_circle_outline),
                label: const Text('Create a Crew'),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton.icon(
                onPressed: () {
                  context.push(AppRouter.joinCrew);
                },
                icon: const Icon(Icons.person_add_alt_1_outlined),
                label: const Text('Browse Public Crews / Enter Invite Code'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AppTheme.accentCopper,
                  side: BorderSide(color: AppTheme.accentCopper, width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  textStyle: AppTheme.titleMedium.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCrewsList(BuildContext context) {
    return const TailboardScreen();
  }
}