import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../design_system/app_theme.dart';
import '../utils/string_formatter.dart';

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
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          boxShadow: const [
            AppTheme.shadowSm,
          ],
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopperThin,
          ),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Header row with local and classification
            Row(
              children: [
                // Local badge
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingSm,
                    vertical: AppTheme.spacingXs,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withValues(alpha: 26/255),
                    borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                  ),
                  child: Text(
                    'Local ${job.localNumber ?? job.local ?? 'N/A'}',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                // Classification
                Expanded(
                  child: Text(
                    toTitleCase(job.classification ?? job.jobClass ?? 'General Electrical'),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w600,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),
            // Horizontal divider
            Divider(
              height: 1,
              color: AppTheme.textLight,
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Location row
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    toTitleCase(job.location),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Hours, Per Diem, and Wage row
            Row(
              children: [
                // Hours
                if (job.hours != null) ...[
                  Icon(
                    Icons.access_time,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    '${job.hours} hrs/week',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                ],

                // Per Diem
                if (job.perDiem != null && job.perDiem!.isNotEmpty) ...[
                  Icon(
                    Icons.hotel,
                    size: 16,
                    color: AppTheme.textSecondary,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'Per Diem: ${job.perDiem}',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                ],

                // Wage
                if (job.wage != null) ...[
                  Text(
                    '\$${job.wage!.toStringAsFixed(2)}/hr',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],

                const Spacer(),

                // Arrow indicator
                Icon(
                  Icons.arrow_forward_ios,
                  size: 16,
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
