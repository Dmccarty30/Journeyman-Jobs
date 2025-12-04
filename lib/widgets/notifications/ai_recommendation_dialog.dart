import 'package:flutter/material.dart';
import '../../models/job_suggestion_model.dart'; // Assuming JobSuggestion is used

class AiRecommendationDialog extends StatelessWidget {
  final JobSuggestion recommendation;
  final VoidCallback? onAccept;
  final VoidCallback? onReject;

  const AiRecommendationDialog({
    super.key,
    required this.recommendation,
    this.onAccept,
    this.onReject,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('New AI Job Recommendation!'),
      content: SingleChildScrollView(
        child: ListBody(
          children: <Widget>[
            Text('We found a new job for you: ${recommendation.suggestedJobId}'),
            const SizedBox(height: 8),
            Text('Reason: ${recommendation.reason}'),
            const SizedBox(height: 8),
            Text('Relevance Score: ${recommendation.relevanceScore.toStringAsFixed(2)}'),
            // TODO: Add more detailed job information from the Job model if available
          ],
        ),
      ),
      actions: <Widget>[
        TextButton(
          child: const Text('Reject'),
          onPressed: () {
            onReject?.call();
            Navigator.of(context).pop();
          },
        ),
        ElevatedButton(
          child: const Text('View & Accept'),
          onPressed: () {
            onAccept?.call();
            Navigator.of(context).pop();
          },
        ),
      ],
    );
  }
}
