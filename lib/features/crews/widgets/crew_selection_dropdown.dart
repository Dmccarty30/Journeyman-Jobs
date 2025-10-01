import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';

class CrewSelectionDropdown extends ConsumerWidget {
  const CrewSelectionDropdown({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final crewsAsync = ref.watch(userCrewsStreamProvider);

    return crewsAsync.when(
      loading: () => const CircularProgressIndicator(),
      error: (error, stackTrace) {
        // Show error dialog with retry option
        WidgetsBinding.instance.addPostFrameCallback((_) {
          showDialog(
            context: context,
            builder: (context) => AlertDialog(
              title: const Text('Error Loading Crews'),
              content: Text('Failed to load crews: $error'),
              actions: [
                TextButton(
                  onPressed: () => Navigator.of(context).pop(),
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                    ref.invalidate(userCrewsStreamProvider);
                  },
                  child: const Text('Retry'),
                ),
              ],
            ),
          );
        });
        return const Text('Error loading crews');
      },
      data: (crews) {
        // Auto-select first crew if none selected and crews available
        if (crews.isNotEmpty && ref.watch(selectedCrewProvider) == null) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            final firstCrew = crews.first;
            ref.read(selectedCrewNotifierProviderProvider).setCrew(firstCrew);
          });
        }
        
        return DropdownButtonFormField<String>(
          decoration: InputDecoration(
            labelText: 'Select Crew',
            border: const OutlineInputBorder(),
            hintText: crews.isEmpty ? 'No crews available' : 'Select a crew',
          ),
          initialValue: ref.watch(selectedCrewProvider)?.id,
          items: crews.map((Crew crew) {
            return DropdownMenuItem<String>(
              value: crew.id,
              child: Text(crew.name),
            );
          }).toList(),
          onChanged: crews.isEmpty ? null : (String? value) {
            if (value != null) {
              final crew = crews.firstWhere((c) => c.id == value);
              ref.read(selectedCrewNotifierProviderProvider).setCrew(crew);
            }
          },
        );
      },
    );
  }
}