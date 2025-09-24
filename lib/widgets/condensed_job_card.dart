import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../design_system/app_theme.dart';

/// Condensed job card for home screen display
/// Shows only essential information: local, classification, location, hours, and per diem
class CondensedJobCard extends StatelessWidget {
  final Job job;
  final VoidCallback? onTap;

  const CondensedJobCard({
    super.key,
    required this.job,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(8),
          boxShadow: const [
            AppTheme.shadowSm,
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with local and classification
            Row(
              children: [
                // Local badge
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 26/255),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Local ${job.localNumber ?? job.local ?? 'N/A'}',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                // Classification
                Expanded(
                  child: Text(
                    job.classification ?? job.jobClass ?? 'General Electrical',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                // Wage if available
                if (job.wage != null) ...[
                  Text(
                    '\$${job.wage!.toStringAsFixed(2)}/hr',
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentCopper,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ],
            ),
            const SizedBox(height: 8),
            
            // Location row
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 14,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: 4),
                Expanded(
                  child: Text(
                    job.location,
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 6),
            
            // Hours and Per Diem row
            Row(
              children: [
                // Hours
                if (job.hours != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${job.hours} hrs/week',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: 12),
                ],
                
                // Per Diem
                if (job.perDiem != null && job.perDiem!.isNotEmpty) ...[
                  Icon(
                    Icons.hotel,
                    size: 14,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    'Per Diem: ${job.perDiem}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.successGreen,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
                
                const Spacer(),
                
                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 12,
                  color: AppTheme.textLight,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
