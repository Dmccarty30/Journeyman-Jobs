import 'dart:io' show Platform;

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../design_system/app_theme.dart';
import '../../design_system/tailboard_theme.dart';
import '../../models/job_model.dart';
import '../../models/locals_record.dart';
import '../../providers/riverpod/locals_riverpod_provider.dart';
import '../../screens/locals/locals_screen.dart';

/// A dialog widget displaying detailed job information
/// Matches the exact styling of the locals screen popup
/// Supports both Legacy (AppTheme) and Modern (TailboardTheme) styles
class JobDetailsDialog extends ConsumerWidget {
  const JobDetailsDialog({
    required this.job,
    this.isDarkTheme = false,
    super.key,
  });

  final Job job;
  final bool isDarkTheme;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    // Theme colors based on mode
    final backgroundColor = isDarkTheme ? TailboardTheme.backgroundCard : AppTheme.white;
    final borderColor = isDarkTheme ? TailboardTheme.copper : AppTheme.accentCopper;
    final headerColor = isDarkTheme ? TailboardTheme.backgroundDark : AppTheme.primaryNavy;
    final textColor = isDarkTheme ? TailboardTheme.textPrimary : AppTheme.primaryNavy;

    return Dialog(
      backgroundColor: backgroundColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(
          color: borderColor,
        ),
      ),
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.85,
          maxWidth: MediaQuery.of(context).size.width * 0.95,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with Navy/Dark background
            Container(
              padding: const EdgeInsets.all(AppTheme.spacingLg),
              decoration: BoxDecoration(
                color: headerColor,
                borderRadius: const BorderRadius.only(
                  topLeft: Radius.circular(AppTheme.radiusLg),
                  topRight: Radius.circular(AppTheme.radiusLg),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          job.jobTitle?.isNotEmpty ?? false
                              ? job.jobTitle!
                              : job.classification?.isNotEmpty ?? false
                                  ? job.classification!
                                  : 'Job Opportunity',
                          style: isDarkTheme
                              ? TailboardTheme.headingSmall.copyWith(fontSize: 16)
                              : AppTheme.headlineSmall.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                        ),
                        const SizedBox(height: AppTheme.spacingXs),
                        if (job.company.isNotEmpty)
                          Text(
                            job.company,
                            style: isDarkTheme
                                ? TailboardTheme.bodyMedium.copyWith(
                                    color: TailboardTheme.textSecondary,
                                    fontSize: 13,
                                  )
                                : AppTheme.bodyMedium.copyWith(
                                    color: AppTheme.white.withAlpha(204),
                                    fontSize: 13,
                                  ),
                          ),
                        if (job.local != null || job.localNumber != null) ...[
                          const SizedBox(height: AppTheme.spacingXs),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: AppTheme.spacingSm,
                              vertical: AppTheme.spacingXs,
                            ),
                            decoration: BoxDecoration(
                              color: isDarkTheme
                                  ? TailboardTheme.copper.withValues(alpha: 0.2)
                                  : AppTheme.accentCopper.withAlpha(51),
                              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                            ),
                            child: Text(
                              'IBEW Local ${job.localNumber ?? job.local ?? 'N/A'}',
                              style: isDarkTheme
                                  ? TailboardTheme.labelSmall.copyWith(
                                      color: TailboardTheme.copperLight,
                                      fontSize: 10,
                                    )
                                  : AppTheme.labelSmall.copyWith(
                                      color: AppTheme.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 10,
                                    ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                  IconButton(
                    onPressed: () => Navigator.of(context).pop(),
                    icon: const Icon(Icons.close),
                    color: isDarkTheme ? TailboardTheme.textSecondary : AppTheme.white,
                    style: IconButton.styleFrom(
                      backgroundColor: isDarkTheme
                          ? Colors.white.withValues(alpha: 0.05)
                          : AppTheme.white.withAlpha(26),
                    ),
                  ),
                ],
              ),
            ),
            // Content
            Flexible(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppTheme.spacingLg),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildSectionHeader('Job Information', textColor),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildJobInfoCard(context, ref),
                    const SizedBox(height: AppTheme.spacingLg),
                    _buildSectionHeader('Additional Details', textColor),
                    const SizedBox(height: AppTheme.spacingMd),
                    _buildAdditionalDetailsCard(),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, Color textColor) => Row(
        children: [
          Container(
            width: 3,
            height: 20,
            decoration: BoxDecoration(
              color: isDarkTheme ? TailboardTheme.copper : AppTheme.accentCopper,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            title,
            style: isDarkTheme
                ? TailboardTheme.headingSmall.copyWith(
                    fontSize: 14,
                    color: TailboardTheme.textPrimary,
                  )
                : AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                  ),
          ),
        ],
      );

  Widget _buildJobInfoCard(BuildContext context, WidgetRef ref) => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: isDarkTheme ? TailboardTheme.backgroundDark : AppTheme.offWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: isDarkTheme ? TailboardTheme.border : AppTheme.lightGray,
          ),
        ),
        child: Column(
          children: [
            if (job.location.isNotEmpty)
              _buildClickableRow(
                context,
                icon: Icons.location_on_outlined,
                label: 'Location',
                value: job.location,
                iconColor: isDarkTheme ? TailboardTheme.copper : AppTheme.accentCopper,
                onTap: () => _launchMaps(job.location),
              ),
            if (job.local != null || job.localNumber != null)
              _buildClickableRow(
                context,
                icon: Icons.business_outlined,
                label: 'Local Union',
                value: 'IBEW Local ${job.localNumber ?? job.local}',
                iconColor: isDarkTheme ? TailboardTheme.copper : AppTheme.accentCopper,
                onTap: () => _navigateToLocal(context, ref),
              ),
            if (job.classification?.isNotEmpty ?? false)
              _buildClickableRow(
                context,
                icon: Icons.work_outline,
                label: 'Classification',
                value: job.classification!,
                iconColor: isDarkTheme ? TailboardTheme.textSecondary : AppTheme.textLight,
              ),
            if (job.wage != null && job.wage! > 0)
              _buildClickableRow(
                context,
                icon: Icons.attach_money_outlined,
                label: 'Wage',
                value: '\$${job.wage!.toStringAsFixed(2)}/hour',
                iconColor: isDarkTheme ? TailboardTheme.success : AppTheme.successGreen,
              ),
            if (job.hours != null && job.hours! > 0)
              _buildClickableRow(
                context,
                icon: Icons.schedule_outlined,
                label: 'Hours',
                value: '${job.hours} hours/week',
                iconColor: isDarkTheme ? TailboardTheme.textSecondary : AppTheme.textLight,
              ),
            if (job.startDate?.isNotEmpty ?? false)
              _buildClickableRow(
                context,
                icon: Icons.calendar_today_outlined,
                label: 'Start Date',
                value: job.startDate!,
                iconColor: isDarkTheme ? TailboardTheme.textSecondary : AppTheme.textLight,
              ),
            if (job.numberOfJobs?.isNotEmpty ?? false)
              _buildClickableRow(
                context,
                icon: Icons.people_outline,
                label: 'Positions Available',
                value: job.numberOfJobs!,
                iconColor: isDarkTheme ? TailboardTheme.textSecondary : AppTheme.textLight,
              ),
          ],
        ),
      );

  Widget _buildAdditionalDetailsCard() {
    // Check if we have any additional details to show
    final hasAdditionalDetails = [
      job.jobDescription,
      job.qualifications,
      job.perDiem,
      job.sub,
      job.jobClass,
      job.agreement,
      job.typeOfWork,
      job.duration,
      job.datePosted,
    ].any((field) => field?.isNotEmpty ?? false);

    final cardColor = isDarkTheme ? TailboardTheme.backgroundDark : AppTheme.lightGray.withAlpha(102);
    final borderColor = isDarkTheme ? TailboardTheme.border : AppTheme.mediumGray.withAlpha(51);

    if (!hasAdditionalDetails) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: borderColor,
          ),
        ),
        child: Text(
          'No additional details available.',
          style: isDarkTheme
              ? TailboardTheme.bodyMedium.copyWith(
                  color: TailboardTheme.textSecondary,
                  fontStyle: FontStyle.italic,
                )
              : AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textLight,
                  fontStyle: FontStyle.italic,
                ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: borderColor,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          if (job.jobDescription?.isNotEmpty ?? false)
            _buildDetailRow('Job Description', job.jobDescription!),
          if (job.qualifications?.isNotEmpty ?? false)
            _buildDetailRow('Qualifications', job.qualifications!),
          if (job.perDiem?.isNotEmpty ?? false)
            _buildDetailRow('Per Diem/Benefits', job.perDiem!),
          if (job.sub?.isNotEmpty ?? false)
            _buildDetailRow('Subcontractor', job.sub!),
          if (job.jobClass?.isNotEmpty ?? false)
            _buildDetailRow('Job Class', job.jobClass!),
          if (job.agreement?.isNotEmpty ?? false)
            _buildDetailRow('Agreement', job.agreement!),
          if (job.typeOfWork?.isNotEmpty ?? false)
            _buildDetailRow('Type of Work', job.typeOfWork!),
          if (job.duration?.isNotEmpty ?? false)
            _buildDetailRow('Duration', job.duration!),
          if (job.datePosted?.isNotEmpty ?? false)
            _buildDetailRow('Date Posted', job.datePosted!),
        ],
      ),
    );
  }

  Widget _buildClickableRow(
    BuildContext context, {
    required IconData icon,
    required String label,
    required String value,
    required Color iconColor,
    VoidCallback? onTap,
  }) {
    final isClickable = onTap != null;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            vertical: AppTheme.spacingSm,
            horizontal: AppTheme.spacingXs,
          ),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Icon(
                icon,
                size: AppTheme.iconMd,
                color: iconColor,
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      label,
                      style: isDarkTheme
                          ? TailboardTheme.labelSmall.copyWith(
                              color: TailboardTheme.textSecondary,
                            )
                          : AppTheme.labelSmall.copyWith(
                              color: AppTheme.textLight,
                              fontSize: 9,
                            ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      value,
                      style: isDarkTheme
                          ? TailboardTheme.bodyMedium.copyWith(
                              color: isClickable ? TailboardTheme.copper : TailboardTheme.textPrimary,
                              decoration: isClickable ? TextDecoration.underline : null,
                              decorationColor: TailboardTheme.copper,
                              fontWeight: isClickable ? FontWeight.w600 : FontWeight.normal,
                              fontSize: 12,
                            )
                          : AppTheme.bodyMedium.copyWith(
                              color: isClickable ? AppTheme.accentCopper : AppTheme.textDark,
                              decoration: isClickable ? TextDecoration.underline : null,
                              decorationColor: AppTheme.accentCopper,
                              fontWeight: isClickable ? FontWeight.w500 : FontWeight.normal,
                              fontSize: 12,
                            ),
                    ),
                  ],
                ),
              ),
              if (isClickable)
                Icon(
                  Icons.open_in_new,
                  size: AppTheme.iconSm,
                  color: isDarkTheme
                      ? TailboardTheme.copper.withValues(alpha: 0.6)
                      : AppTheme.accentCopper.withAlpha(153),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) => Padding(
        padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              width: 120,
              child: Text(
                label,
                style: isDarkTheme
                    ? TailboardTheme.labelSmall.copyWith(fontSize: 10)
                    : AppTheme.labelSmall.copyWith(
                        color: AppTheme.textLight,
                        fontWeight: FontWeight.w600,
                        fontSize: 10,
                      ),
              ),
            ),
            Expanded(
              child: Text(
                value,
                style: isDarkTheme
                    ? TailboardTheme.bodyMedium.copyWith(fontSize: 11)
                    : AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textDark,
                        fontSize: 11,
                      ),
              ),
            ),
          ],
        ),
      );

  Future<void> _launchMaps(String location) async {
    final encodedLocation = Uri.encodeComponent(location);
    Uri uri;

    if (Platform.isIOS) {
      uri = Uri.parse('maps://maps.apple.com/?q=$encodedLocation');
    } else {
      uri = Uri.parse('geo:0,0?q=$encodedLocation');
    }

    try {
      await launchUrl(uri);
    } catch (e) {
      // Fallback to Google Maps web
      final webUri = Uri.parse('https://maps.google.com/maps?q=$encodedLocation');
      await launchUrl(webUri, mode: LaunchMode.externalApplication);
    }
  }

  void _navigateToLocal(BuildContext context, WidgetRef ref) {
    Navigator.of(context).pop(); // Close the current job dialog first

    // Get the local number from the job
    final localNumber = (job.localNumber ?? job.local)?.toString();
    if (localNumber == null) return;

    // Find the local record by number
    final localsState = ref.read(localsProvider);

    // Try to find the matching local
    LocalsRecord? matchingLocal;
    try {
      matchingLocal = localsState.locals.firstWhere(
        (local) => local.localNumber == localNumber,
      );
    } catch (e) {
      matchingLocal = null;
    }

    if (matchingLocal != null) {
      // Show the local details dialog
      showDialog(
        context: context,
        builder: (context) => LocalDetailsDialog(local: matchingLocal!),
      );
    } else {
      // If local not found, show error message
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Local $localNumber not found or details unavailable.'),
          backgroundColor: AppTheme.errorRed,
        ),
      );
    }
  }
}
