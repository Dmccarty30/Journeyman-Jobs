import 'package:flutter/material.dart';
import '../design_system/popup_theme.dart';
import '../design_system/app_theme.dart';
import '../models/job_model.dart';

/// A comprehensive dialog displaying detailed job information
/// Follows the PopupTheme guidelines for consistent styling
class JobDetailsDialog extends StatelessWidget {
  const JobDetailsDialog({
    required this.job,
    super.key,
  });

  final Job job;

  @override
  Widget build(BuildContext context) {
    final popupTheme = context.popupTheme;
    
    return Dialog(
      elevation: popupTheme.elevation,
      shape: RoundedRectangleBorder(
        borderRadius: popupTheme.borderRadius,
        side: BorderSide(
          color: popupTheme.borderColor,
          width: popupTheme.borderWidth,
        ),
      ),
      backgroundColor: popupTheme.backgroundColor,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: popupTheme.maxWidth ?? 500,
          maxHeight: popupTheme.maxHeight ?? 600,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with title and close button
            _buildHeader(context),
            // Scrollable content
            Flexible(
              child: SingleChildScrollView(
                padding: popupTheme.padding,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Job Title and Company
                    _buildJobTitleSection(),
                    const SizedBox(height: 16),
                    
                    // Main job details grid
                    _buildDetailsGrid(),
                    const SizedBox(height: 16),
                    
                    // Qualifications/Requirements
                    if (job.qualifications?.isNotEmpty == true)
                      _buildQualificationsSection(),
                    
                    // Job Description
                    if (job.jobDescription?.isNotEmpty == true)
                      _buildDescriptionSection(),
                    
                    // Additional Details
                    _buildAdditionalDetails(),
                  ],
                ),
              ),
            ),
            // Footer with action buttons
            _buildFooter(context),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          bottom: BorderSide(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: Text(
              'Job Details',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
          ),
          IconButton(
            icon: const Icon(Icons.close),
            onPressed: () => Navigator.of(context).pop(),
            color: AppTheme.textLight,
          ),
        ],
      ),
    );
  }

  Widget _buildJobTitleSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.jobTitle?.isNotEmpty == true)
          Text(
            job.jobTitle!,
            style: const TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
        const SizedBox(height: 4),
        Text(
          job.company,
          style: TextStyle(
            fontSize: 16,
            color: AppTheme.textDark,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  Widget _buildDetailsGrid() {
    return Column(
      children: [
        _buildDetailRow('Local', job.localNumber?.toString() ?? job.local?.toString() ?? 'N/A'),
        _buildDetailRow('Classification', job.classification ?? job.jobClass ?? 'N/A'),
        _buildDetailRow('Location', job.location),
        _buildDetailRow('Wage', job.wage != null && job.wage! > 0 
            ? '\$${job.wage!.toStringAsFixed(2)}/hr' 
            : 'N/A'),
        _buildDetailRow('Hours', job.hours != null ? '${job.hours}/week' : 'N/A'),
        _buildDetailRow('Start Date', job.startDate ?? 'N/A'),
        _buildDetailRow('Start Time', job.startTime ?? 'N/A'),
        _buildDetailRow('Per Diem', job.perDiem ?? 'N/A'),
        _buildDetailRow('Duration', job.duration ?? 'N/A'),
        _buildDetailRow('Type of Work', job.typeOfWork ?? 'N/A'),
        _buildDetailRow('Agreement', job.agreement ?? 'N/A'),
        _buildDetailRow('Positions Available', job.numberOfJobs ?? 'N/A'),
        if (job.voltageLevel?.isNotEmpty == true)
          _buildDetailRow('Voltage Level', job.voltageLevel!),
      ],
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 140,
            child: Text(
              '$label:',
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                color: AppTheme.textDark,
                fontSize: 14,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: TextStyle(
                color: AppTheme.textLight,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQualificationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1),
        const Text(
          'Qualifications & Requirements',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          job.qualifications!,
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildDescriptionSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 24, thickness: 1),
        const Text(
          'Job Description',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          job.jobDescription!,
          style: TextStyle(
            color: AppTheme.textLight,
            fontSize: 14,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 16),
      ],
    );
  }

  Widget _buildAdditionalDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (job.datePosted?.isNotEmpty == true)
          _buildDetailRow('Date Posted', job.datePosted!),
        if (job.sub?.isNotEmpty == true)
          _buildDetailRow('Sub', job.sub!),
        if (job.booksYourOn?.isNotEmpty == true)
          _buildDetailRow('Books You\'re On', job.booksYourOn!.join(', ')),
      ],
    );
  }

  Widget _buildFooter(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.offWhite,
        borderRadius: BorderRadius.only(
          bottomLeft: Radius.circular(AppTheme.radiusLg),
          bottomRight: Radius.circular(AppTheme.radiusLg),
        ),
        border: Border(
          top: BorderSide(
            color: AppTheme.accentCopper.withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          Expanded(
            child: OutlinedButton(
              onPressed: () => Navigator.of(context).pop(),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryNavy,
                side: const BorderSide(color: AppTheme.primaryNavy),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                padding: const EdgeInsets.symmetric(vertical: 12),
              ),
              child: const Text(
                'Close',
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: ElevatedButton(
              onPressed: () {
                // TODO: Implement bid functionality
                Navigator.of(context).pop();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Bid functionality coming soon!'),
                  ),
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
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
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}