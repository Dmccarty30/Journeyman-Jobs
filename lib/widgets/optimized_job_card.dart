import 'package:flutter/material.dart';
import '../models/job_model.dart';

class OptimizedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;
  final bool showStormBadge;

  const OptimizedJobCard({
    super.key,
    required this.job,
    this.onTap,
    this.showStormBadge = true,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.all(8.0),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              job.jobTitle ?? 'Job Position',
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Row(
              children: [
                const Icon(Icons.location_on, size: 16),
                const SizedBox(width: 4),
                Text(job.location),
              ],
            ),
            if ((job.typeOfWork?.toLowerCase().contains('storm') ?? false) && showStormBadge)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Row(
                  children: [
                    const Icon(Icons.flash_on, color: Colors.red, size: 16),
                    const SizedBox(width: 4),
                    const Text('Storm Work', style: TextStyle(color: Colors.red)),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}

// Placeholder for JobCardSkeleton and _DetailChip to avoid immediate errors
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({super.key});
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}

class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  const _DetailChip({required this.icon, required this.label});
  @override
  Widget build(BuildContext context) {
    return const SizedBox.shrink();
  }
}
