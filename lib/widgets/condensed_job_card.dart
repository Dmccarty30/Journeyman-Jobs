import 'package:flutter/material.dart';
import '../models/job_model.dart';
import '../design_system/app_theme.dart';
import '../utils/text_formatting_wrapper.dart';

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
    // Extract values with fallback to jobDetails map
    final wageValue = job.wage ?? (job.jobDetails['payRate'] as double?);
    final hoursValue = job.hours ?? (job.jobDetails['hours'] as int?);
    final perDiemValue = job.perDiem ?? (job.jobDetails['perDiem'] as String?);

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
                    JobDataFormatter.formatClassification(job.classification ?? job.jobClass),
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
              color: AppTheme.accentCopper,
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Contractor | Wages
            _buildTwoColumnRow(
              leftLabel: 'Contractor',
              leftValue: JobDataFormatter.formatCompany(job.company),
              rightLabel: 'Wages',
              rightValue: wageValue != null ? '\$${wageValue.toStringAsFixed(2)}/hr' : 'N/A',
              rightValueColor: wageValue != null && wageValue > 0 ? AppTheme.successGreen : null,
            ),
            const SizedBox(height: 8),

            // Location | Hours
            _buildTwoColumnRow(
              leftLabel: 'Location',
              leftValue: JobDataFormatter.formatLocation(job.location),
              rightLabel: 'Hours',
              rightValue: hoursValue != null ? '${hoursValue}/week' : 'N/A',
            ),
            const SizedBox(height: 8),

            // Start Date | Per Diem
            _buildTwoColumnRow(
              leftLabel: 'Start Date',
              leftValue: job.startDate ?? 'N/A',
              rightLabel: 'Per Diem',
              rightValue: perDiemValue ?? 'N/A',
            ),
            const SizedBox(height: AppTheme.spacingSm),

            // Arrow indicator row
            Row(
              children: [
                const Spacer(),
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

  /// Helper method to build two-column info rows
  Widget _buildTwoColumnRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    Color? leftValueColor,
    Color? rightValueColor,
  }) => Row(
        children: [
          // Left column
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  const TextSpan(
                    text: 'Contractor: ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: leftValue,
                    style: TextStyle(
                      color: leftValueColor ?? AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Right column
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: '$rightLabel: ',
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textDark,
                      fontSize: 12,
                    ),
                  ),
                  TextSpan(
                    text: rightValue,
                    style: TextStyle(
                      color: rightValueColor ?? AppTheme.textLight,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      );
}
