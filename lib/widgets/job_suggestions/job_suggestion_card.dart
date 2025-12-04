import 'package:flutter/material.dart';
import '../../models/job_suggestion_model.dart';

class JobSuggestionCard extends StatelessWidget {
  final JobSuggestion suggestion;
  final VoidCallback? onDetailsPressed;
  final VoidCallback? onAcceptPressed;

  const JobSuggestionCard({
    super.key,
    required this.suggestion,
    this.onDetailsPressed,
    this.onAcceptPressed,
  });

  @override
  Widget build(BuildContext context) {
    // Placeholder UI for a job suggestion card.
    // In a real implementation, this would display key information
    // from the `suggestion` model, such as the reason for suggestion,
    // relevance score, and details of the suggested job.
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Suggested Job: ${suggestion.suggestedJobId}', // Using ID for placeholder
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Reason: ${suggestion.reason}',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            Text(
              'Relevance Score: ${suggestion.relevanceScore.toStringAsFixed(2)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
            const SizedBox(height: 16.0),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                if (onDetailsPressed != null)
                  TextButton(
                    onPressed: onDetailsPressed,
                    child: const Text('Details'),
                  ),
                if (onAcceptPressed != null)
                  ElevatedButton(
                    onPressed: onAcceptPressed,
                    child: const Text('Accept'),
                  ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
