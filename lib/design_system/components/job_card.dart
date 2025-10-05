import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../../models/job_model.dart';
import '../../utils/job_formatting.dart';
import 'reusable_components.dart';

/// Enum for JobCard variants
enum JobCardVariant {
  /// Half-size variant for home screen and compact displays
  half,
  /// Full-size variant for jobs screen with detailed information
  full,
}

/// Reusable JobCard component for displaying job information
/// Supports two variants: half (compact) and full (detailed)
class JobCard extends StatelessWidget {
  /// The job object containing all job data
  final Job job;
  
  /// The variant type determining the card size and information display
  final JobCardVariant variant;
  
  /// Callback function for when the card is tapped
  final VoidCallback? onTap;
  
  /// Callback function for the "View Details" button
  final VoidCallback? onViewDetails;
  
  /// Callback function for the "Bid Now" button
  final VoidCallback? onBidNow;
  
  /// Callback function for favoriting/bookmarking the job
  final VoidCallback? onFavorite;
  
  /// Whether the job is currently favorited
  final bool isFavorited;
  
  /// Optional margin for the card
  final EdgeInsets? margin;
  
  /// Optional padding for the card content
  final EdgeInsets? padding;

  const JobCard({
    super.key,
    required this.job,
    required this.variant,
    this.onTap,
    this.onViewDetails,
    this.onBidNow,
    this.onFavorite,
    this.isFavorited = false,
    this.margin,
    this.padding,
  });

  @override
  Widget build(BuildContext context) {
    switch (variant) {
      case JobCardVariant.half:
        return _buildHalfCard();
      case JobCardVariant.full:
        return _buildFullCard();
    }
  }

  /// Builds the half-size (compact) variant of the job card
  Widget _buildHalfCard() {
    return JJCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header with company and favorite button
          Row(
            children: [
              Expanded(
                child: Text(
                  JobFormatting.formatJobTitle(job.company),
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              if (onFavorite != null)
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    size: AppTheme.iconSm,
                    color: isFavorited ? AppTheme.accentCopper : AppTheme.textLight,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // Job title or classification
          if (job.jobTitle != null || job.classification != null)
            Text(
              JobFormatting.formatJobTitle(job.jobTitle ?? job.classification ?? ''),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          
          // Company info
          if (job.company.isNotEmpty) ...[            
            const SizedBox(height: AppTheme.spacingXs),
            Row(
              children: [
                Icon(
                  Icons.business_outlined,
                  size: AppTheme.iconXs,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    'Company: ${job.company}',
                    style: AppTheme.labelSmall.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingXs),
          
          // Location with icon
          Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: AppTheme.iconXs,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Expanded(
                child: Text(
                  'Location: ${JobFormatting.formatLocation(job.location)}',
                  style: AppTheme.labelSmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // Wage and hours
          Row(
            children: [
              if (job.wage != null) ...[
                Icon(
                  Icons.attach_money,
                  size: AppTheme.iconXs,
                  color: AppTheme.accentCopper,
                ),
                Text(
                  '\$${job.wage!.toStringAsFixed(2)}/hr',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.accentCopper,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              if (job.wage != null && job.hours != null)
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: AppTheme.spacingSm),
                  width: 1,
                  height: 12,
                  color: AppTheme.lightGray,
                ),
              if (job.hours != null) ...[
                Icon(
                  Icons.schedule,
                  size: AppTheme.iconXs,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  '${job.hours!} hrs',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                child: JJSecondaryButton(
                  text: 'Details',
                  onPressed: onViewDetails,
                  height: 36,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: JJPrimaryButton(
                  text: 'Bid Now',
                  onPressed: onBidNow,
                  height: 36,
                  variant: JJButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds the full-size (detailed) variant of the job card
  Widget _buildFullCard() {
    return JJCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header with company and favorite button
          Row(
            children: [
              Expanded(
                child: Text(
                  JobFormatting.formatJobTitle(job.company),
                  style: AppTheme.headlineSmall.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (onFavorite != null)
                GestureDetector(
                  onTap: onFavorite,
                  child: Icon(
                    isFavorited ? Icons.bookmark : Icons.bookmark_border,
                    size: AppTheme.iconMd,
                    color: isFavorited ? AppTheme.accentCopper : AppTheme.textLight,
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // Job title or classification
          if (job.jobTitle != null || job.classification != null)
            Text(
              JobFormatting.formatJobTitle(job.jobTitle ?? job.classification ?? ''),
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w600,
              ),
            ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Job details grid
          Row(
            children: [
              Expanded(
                child: _buildDetailItem(
                  icon: Icons.location_on_outlined,
                  label: 'Location',
                  value: JobFormatting.formatLocation(job.location),
                ),
              ),
              if (job.local != null)
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.group,
                    label: 'Local',
                    value: 'Local ${job.local}',
                  ),
                ),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          Row(
            children: [
              if (job.wage != null)
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.attach_money,
                    label: 'Wage',
                    value: '\$${job.wage!.toStringAsFixed(2)}/hr',
                    isHighlighted: true,
                  ),
                ),
              if (job.hours != null)
                Expanded(
                  child: _buildDetailItem(
                    icon: Icons.schedule,
                    label: 'Hours',
                    value: '${job.hours!} hrs',
                  ),
                ),
            ],
          ),
          
          if (job.numberOfJobs != null || job.datePosted != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                if (job.numberOfJobs != null)
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.people,
                      label: 'Positions',
                      value: job.numberOfJobs!,
                    ),
                  ),
                if (job.datePosted != null)
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.calendar_today,
                      label: 'Posted',
                      value: job.datePosted!,
                    ),
                  ),
              ],
            ),
          ],
          
          // Additional details
          if (job.perDiem != null || job.duration != null) ...[
            const SizedBox(height: AppTheme.spacingMd),
            Row(
              children: [
                if (job.perDiem != null)
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.hotel,
                      label: 'Per Diem',
                      value: job.perDiem!,
                    ),
                  ),
                if (job.duration != null)
                  Expanded(
                    child: _buildDetailItem(
                      icon: Icons.timer,
                      label: 'Duration',
                      value: job.duration!,
                    ),
                  ),
              ],
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingLg),
          
          // Action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: JJSecondaryButton(
                  text: 'View Details',
                  onPressed: onViewDetails,
                  icon: Icons.info_outline,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                flex: 3,
                child: JJPrimaryButton(
                  text: 'Bid Now',
                  onPressed: onBidNow,
                  icon: Icons.flash_on,
                  variant: JJButtonVariant.primary,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds a detail item with icon, label, and value
  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Icon(
              icon,
              size: AppTheme.iconXs,
              color: isHighlighted ? AppTheme.accentCopper : AppTheme.textSecondary,
            ),
            const SizedBox(width: AppTheme.spacingXs),
            Text(
              label,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
                fontSize: 11,
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          value,
          style: AppTheme.bodySmall.copyWith(
            color: isHighlighted ? AppTheme.accentCopper : AppTheme.textPrimary,
            fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
          ),
          overflow: TextOverflow.ellipsis,
        ),
      ],
    );
  }
}
