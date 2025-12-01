import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import '../models/job_model.dart';
import 'job_details_dialog.dart';
import '../utils/text_formatting_wrapper.dart';

/// A card widget displaying job details using RichText with icons
/// Shows job information in a two-span format: bold labels and bracketed values
class RichTextJobCard extends StatelessWidget {

  const RichTextJobCard({
    required this.job, super.key,
    this.onDetails,
    this.onBid,
  });
  final Job job;
  final VoidCallback? onDetails;
  final VoidCallback? onBid;

  @override
  Widget build(BuildContext context) => Container(
      width: double.infinity,
      margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: 8),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppTheme.accentCopper, width: AppTheme.borderWidthMedium),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Row 1: Local | Classification
            _buildTwoColumnRow(
              leftLabel: 'Local',
              leftValue: job.localNumber?.toString() ?? job.local?.toString() ?? 'N/A',
              leftIcon: Icons.vpn_key_outlined,
              rightLabel: 'Classification',
              rightValue: toTitleCase(job.classification ?? 'N/A'),
              rightIcon: Icons.badge_outlined,
            ),
            const SizedBox(height: 8),

            // Row 2: Contractor | Wages
            _buildTwoColumnRow(
              leftLabel: 'Contractor',
              leftValue: toTitleCase(job.company.isNotEmpty ? job.company : 'N/A'),
              leftIcon: Icons.business_center_outlined,
              rightLabel: 'Wages',
              rightValue: job.wage != null && job.wage! > 0 
                  ? '\$${job.wage!.toStringAsFixed(2)}/hr' 
                  : 'N/A',
              rightValueColor: job.wage != null && job.wage! > 0 ? AppTheme.successGreen : null,
              rightIcon: Icons.attach_money,
            ),
            const SizedBox(height: 8),

            // Row 3: Location | Hours
            _buildTwoColumnRow(
              leftLabel: 'Location',
              leftValue: toTitleCase(job.location.isNotEmpty ? job.location : 'N/A'),
              leftIcon: Icons.location_on_outlined,
              rightLabel: 'Hours',
              rightValue: job.hours != null ? '${job.hours}/week' : 'N/A',
              rightIcon: Icons.access_time,
            ),
            const SizedBox(height: 8),

            // Row 4: Start Date | Per Diem
            _buildTwoColumnRow(
              leftLabel: 'Start Date',
              leftValue: job.startDate ?? 'N/A',
              leftIcon: Icons.calendar_today_outlined,
              rightLabel: 'Per Diem',
              rightValue: job.perDiem ?? 'N/A',
              rightIcon: Icons.hotel_outlined,
            ),
            const SizedBox(height: 8),

            // Row 5: Type of Work (full width)
            _buildInfoRow(
              label: 'Type of Work',
              value: toTitleCase(job.typeOfWork ?? 'N/A'),
              icon: Icons.build_outlined,
            ),
            const SizedBox(height: 8),

            // Row 6: Notes/Requirements (full width)
            if (job.qualifications != null && job.qualifications!.isNotEmpty)
              _buildInfoRow(
                label: 'Notes/Requirements',
                value: job.qualifications!,
                icon: Icons.library_books_outlined,
              ),

            const SizedBox(height: 16),

            // Action buttons
            Row(
              children: [
                // Details button (outlined with AppTheme)
                Expanded(
                  child: OutlinedButton(
                    onPressed: () => _showJobDetailsDialog(context),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: AppTheme.primaryNavy,
                      side: const BorderSide(color: AppTheme.primaryNavy),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                    ),
                    child: const Text(
                      'Details',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                // Bid Now button (copper gradient with flash icon)
                Expanded(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppTheme.accentCopper,
                          AppTheme.accentCopper.withValues(alpha: 0.7),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: ElevatedButton(
                      onPressed: onBid,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        foregroundColor: AppTheme.white,
                        shadowColor: Colors.transparent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8),
                        ),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.flash_on,
                            size: 18,
                          ),
                          SizedBox(width: 4),
                          Text(
                            'Bid Now',
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );

  /// Helper method to build two-column info rows (Local | Classification)
  Widget _buildTwoColumnRow({
    required String leftLabel,
    required String leftValue,
    IconData? leftIcon,
    Color? leftValueColor,
    required String rightLabel,
    required String rightValue,
    IconData? rightIcon,
    Color? rightValueColor,
  }) => Row(
      children: [
        // Left column
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                if (leftIcon != null)
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(leftIcon, size: 16, color: AppTheme.textDark),
                    ),
                  ),
                TextSpan(
                  text: '$leftLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: leftValue,
                  style: TextStyle(
                    color: leftValueColor ?? AppTheme.textLight,
                    fontSize: 13,
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
                if (rightIcon != null)
                  WidgetSpan(
                    child: Padding(
                      padding: const EdgeInsets.only(right: 4.0),
                      child: Icon(rightIcon, size: 16, color: AppTheme.textDark),
                    ),
                  ),
                TextSpan(
                  text: '$rightLabel: ',
                  style: const TextStyle(
                    fontWeight: FontWeight.w600, // Adjusted to match bold
                    color: AppTheme.textDark,
                    fontSize: 13,
                  ),
                ),
                TextSpan(
                  text: rightValue,
                  style: TextStyle(
                    color: rightValueColor ?? AppTheme.textLight,
                    fontSize: 13,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );

  /// Helper method to build single info rows (full width)
  Widget _buildInfoRow({
    required String label,
    required String value,
    IconData? icon,
    Color? valueColor,
  }) => RichText(
      text: TextSpan(
        children: [
          if (icon != null)
            WidgetSpan(
              child: Padding(
                padding: const EdgeInsets.only(right: 4.0),
                child: Icon(icon, size: 16, color: AppTheme.textDark),
              ),
            ),
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: AppTheme.textDark,
              fontSize: 13,
            ),
          ),
          TextSpan(
            text: value,
            style: TextStyle(
              color: valueColor ?? AppTheme.textLight,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );

  /// Show the job details dialog
  void _showJobDetailsDialog(BuildContext context) {
    // Call the custom onDetails callback if provided, otherwise show dialog directly
    if (onDetails != null) {
      onDetails!();
    } else {
      // Fallback: show dialog directly if no callback provided
      showDialog(
        context: context,
        builder: (context) => JobDetailsDialog(job: job),
      );
    }
  }
}
