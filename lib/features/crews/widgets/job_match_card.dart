import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/tailboard.dart';
import '../../../design_system/app_theme.dart';

class JobMatchCard extends ConsumerWidget {
  final SuggestedJob job;
  final String currentUserId;

  const JobMatchCard({
    super.key,
    required this.job,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isViewed = job.viewedByMemberIds.contains(currentUserId);
    final isApplied = job.appliedMemberIds.contains(currentUserId);
    final matchScore = job.matchScore;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      elevation: isViewed ? 0 : 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: BorderSide(
          color: isViewed ? AppTheme.borderLight : AppTheme.accentCopper.withValues(alpha: 0.3),
          width: isViewed ? 1 : 2,
        ),
      ),
      child: InkWell(
        onTap: () => _handleJobTap(context),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header with match score and status
              Row(
                children: [
                  // Match Score Badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      color: _getMatchScoreColor(matchScore),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Text(
                      '${matchScore}% Match',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const Spacer(),
                  // Status indicators
                  if (isApplied)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppTheme.successGreen.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(
                            Icons.check_circle,
                            size: 14,
                            color: AppTheme.successGreen,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Applied',
                            style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: AppTheme.successGreen,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  if (!isViewed && !isApplied)
                    Container(
                      width: 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color: AppTheme.accentCopper,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 12),
              // Job Title (placeholder - would fetch from job service)
              Text(
                'Electrical Foreman Position', // Would be actual job title
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppTheme.textPrimary,
                ),
              ),
              const SizedBox(height: 4),
              // Company and Location (placeholder)
              Text(
                'ABC Electrical Contractors • New York, NY',
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
              const SizedBox(height: 8),
              // Match Reasons
              if (job.matchReasons.isNotEmpty)
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Why this matches:',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(
                        fontWeight: FontWeight.w600,
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    ...job.matchReasons.take(3).map((reason) {
                      return Padding(
                        padding: const EdgeInsets.only(left: 8, bottom: 2),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.check_circle,
                              size: 14,
                              color: AppTheme.successGreen,
                            ),
                            const SizedBox(width: 6),
                            Expanded(
                              child: Text(
                                reason,
                                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                                  color: AppTheme.textSecondary,
                                ),
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ],
                ),
              const SizedBox(height: 12),
              // Job Details Row
              Row(
                children: [
                  _buildDetailChip(
                    context,
                    Icons.attach_money,
                    '\$35-45/hr',
                    AppTheme.accentCopper,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    Icons.schedule,
                    'Full-time',
                    AppTheme.infoBlue,
                  ),
                  const SizedBox(width: 8),
                  _buildDetailChip(
                    context,
                    Icons.calendar_today,
                    'Start ASAP',
                    AppTheme.warningYellow,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Action Buttons
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton(
                      onPressed: isApplied ? null : () => _handleApply(context),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isApplied ? AppTheme.mediumGray : AppTheme.accentCopper,
                        foregroundColor: AppTheme.white,
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                      ),
                      child: Text(
                        isApplied ? 'Already Applied' : 'Apply Now',
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _handleShare(context),
                    icon: Icon(
                      Icons.share,
                      color: AppTheme.accentCopper,
                    ),
                    style: IconButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.accentCopper,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  IconButton(
                    onPressed: () => _handleSave(context),
                    icon: Icon(
                      Icons.bookmark_border,
                      color: AppTheme.accentCopper,
                    ),
                    style: IconButton.styleFrom(
                      side: BorderSide(
                        color: AppTheme.accentCopper,
                        width: 1,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailChip(BuildContext context, IconData icon, String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            size: 14,
            color: color,
          ),
          const SizedBox(width: 4),
          Text(
            text,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: color,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Color _getMatchScoreColor(int score) {
    if (score >= 80) return AppTheme.successGreen;
    if (score >= 60) return AppTheme.warningYellow;
    return AppTheme.errorRed;
  }

  void _handleJobTap(BuildContext context) {
    // Mark as viewed and show job details
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Job details: ${job.jobId}'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleApply(BuildContext context) {
    if (job.appliedMemberIds.contains(currentUserId)) return;
    
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Application submitted!'),
        backgroundColor: AppTheme.successGreen,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  void _handleShare(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Job shared with crew'),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _handleSave(BuildContext context) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: const Text('Job saved for later'),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}