import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../models/job_suggestion_model.dart';
import 'job_suggestion_card.dart';

// Placeholder provider for job suggestions
final jobSuggestionsProvider = FutureProvider<List<JobSuggestion>>((ref) async {
  // In a real app, this would fetch suggestions from a service
  // For now, return a dummy list
  await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
  return [
    JobSuggestion(
      id: 'sug1',
      originalJobId: 'job1',
      suggestedJobId: 'job_A',
      reason: 'Similar skills, higher pay',
      relevanceScore: 0.95,
      createdAt: Timestamp.now(),
    ),
    JobSuggestion(
      id: 'sug2',
      originalJobId: 'job2',
      suggestedJobId: 'job_B',
      reason: 'Closer to home, better benefits',
      relevanceScore: 0.88,
      createdAt: Timestamp.now(),
    ),
  ];
});

class JobSuggestionsList extends ConsumerWidget {
  const JobSuggestionsList({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final AsyncValue<List<JobSuggestion>> suggestions = ref.watch(jobSuggestionsProvider);

    return suggestions.when(
      data: (sugs) {
        if (sugs.isEmpty) {
          return const Center(child: Text('No job suggestions yet.'));
        }
        return ListView.builder(
          itemCount: sugs.length,
          itemBuilder: (context, index) {
            final suggestion = sugs[index];
            return JobSuggestionCard(
              suggestion: suggestion,
              onDetailsPressed: () {
                // TODO: Implement navigation to detailed job view
                print('View details for suggested job: ${suggestion.suggestedJobId}');
              },
              onAcceptPressed: () {
                // TODO: Implement logic to accept suggestion
                print('Accepted suggestion for job: ${suggestion.suggestedJobId}');
              },
            );
          },
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => Center(child: Text('Error loading suggestions: $err')),
    );
  }
}
