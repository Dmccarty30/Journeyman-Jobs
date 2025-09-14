import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../../models/job_model.dart';
import '../../utils/job_formatting.dart';
import 'reusable_components.dart';
import 'standardized_card.dart';

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
    final List<CardColumnData> columns = [
      CardColumnData(
        rows: [
          // Company info
          if (job.company.isNotEmpty)
            CardRowData(
              icon: Icons.business_outlined,
              label: 'Company',
              value: job.company,
            ),
          
          // Location
          CardRowData(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: JobFormatting.formatLocation(job.location),
          ),
          
          // Wage
          if (job.wage != null)
            CardRowData(
              icon: Icons.attach_money,
              label: 'Wage',
              value: '\$${job.wage!.toStringAsFixed(2)}/hr',
              iconColor: AppTheme.accentCopper,
              valueColor: AppTheme.accentCopper,
            ),
          
          // Hours
          if (job.hours != null)
            CardRowData(
              icon: Icons.schedule,
              label: 'Hours',
              value: '${job.hours!} hrs',
            ),
        ],
      ),
    ];

    return StandardizedCard(
      columns: columns,
      header: job.company,
      onTap: onTap,
      margin: margin,
      padding: padding,
      showCopperBorder: true,
      backgroundColor: AppTheme.white,
    );
  }

  /// Builds the full-size (detailed) variant of the job card
  Widget _buildFullCard() {
    final List<CardColumnData> columns = [
      // First column - Location and Local info
      CardColumnData(
        rows: [
          CardRowData(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: job.location,
          ),
          if (job.local != null)
            CardRowData(
              icon: Icons.group,
              label: 'Local',
              value: 'Local ${job.local}',
            ),
        ],
      ),
      
      // Second column - Wage and Hours
      CardColumnData(
        rows: [
          if (job.wage != null)
            CardRowData(
              icon: Icons.attach_money,
              label: 'Wage',
              value: '\$${job.wage!.toStringAsFixed(2)}/hr',
              iconColor: AppTheme.accentCopper,
              valueColor: AppTheme.accentCopper,
            ),
          if (job.hours != null)
            CardRowData(
              icon: Icons.schedule,
              label: 'Hours',
              value: '${job.hours!} hrs',
            ),
        ],
      ),
      
      // Third column - Positions and Posted date
      if (job.numberOfJobs != null || job.datePosted != null)
        CardColumnData(
          rows: [
            if (job.numberOfJobs != null)
              CardRowData(
                icon: Icons.people,
                label: 'Positions',
                value: job.numberOfJobs!,
              ),
            if (job.datePosted != null)
              CardRowData(
                icon: Icons.calendar_today,
                label: 'Posted',
                value: job.datePosted!,
              ),
          ],
        ),
      
      // Fourth column - Per Diem and Duration
      if (job.perDiem != null || job.duration != null)
        CardColumnData(
          rows: [
            if (job.perDiem != null)
              CardRowData(
                icon: Icons.hotel,
                label: 'Per Diem',
                value: job.perDiem!,
              ),
            if (job.duration != null)
              CardRowData(
                icon: Icons.timer,
                label: 'Duration',
                value: job.duration!,
              ),
          ],
        ),
    ];

        // Custom header section with company, job title, and favorite button
        Container(
          margin: margin ?? const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          padding: padding ?? const EdgeInsets.all(AppTheme.spacingLg),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
            border: Border.all(
              color: AppTheme.accentCopper.withOpacity(0.3),
              width: 1.5,
            ),
            boxShadow: [AppTheme.shadowSm],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header row with company and favorite button
              Row(
                children: [
                  Expanded(
                    child: Text(
                      job.company,
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
              
              // Job title/subtitle
              if (job.jobTitle != null || job.classification != null) ...[
                const SizedBox(height: AppTheme.spacingSm),
                Text(
                  JobFormatting.formatJobTitle(job.jobTitle ?? job.classification ?? ''),
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.textPrimary,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              
              const SizedBox(height: AppTheme.spacingMd),
              
              // Standardized card content
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: _buildStandardizedColumns(columns),
              ),
            ],
          ),
        ),
        
        // Action buttons
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingMd,
            vertical: AppTheme.spacingSm,
          ),
          child: Row(
            children: [
              Expanded(
                flex: 2,
                child: JJButton(
                  text: 'View Details',
                  onPressed: onViewDetails,
                  icon: Icons.info_outline,
                  variant: JJButtonVariant.secondary,
                  size: JJButtonSize.medium,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                flex: 3,
                child: JJButton(
                  text: 'Bid Now',
                  onPressed: onBidNow,
                  icon: Icons.flash_on,
                  variant: JJButtonVariant.primary,
                  size: JJButtonSize.medium,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Builds the standardized columns with vertical dividers
  List<Widget> _buildStandardizedColumns(List<CardColumnData> columns) {
    final List<Widget> columnWidgets = [];

    for (int i = 0; i < columns.length; i++) {
      // Add column
      columnWidgets.add(
        Expanded(
          flex: columns[i].flex ?? 1,
          child: _buildStandardizedColumn(columns[i]),
        ),
      );

      // Add vertical divider between columns (except after the last column)
      if (i < columns.length - 1) {
        columnWidgets.add(
          const SizedBox(width: AppTheme.spacingMd),
        );
        columnWidgets.add(
          _buildVerticalDivider(),
        );
        columnWidgets.add(
          const SizedBox(width: AppTheme.spacingMd),
        );
      }
    }

    return columnWidgets;
  }

  /// Builds a single standardized column with its rows
  Widget _buildStandardizedColumn(CardColumnData columnData) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: columnData.rows.map((row) => _buildStandardizedRow(row)).toList(),
    );
  }

  /// Builds a single standardized row with icon and rich text
  Widget _buildStandardizedRow(CardRowData rowData) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Icon
          Icon(
            rowData.icon,
            size: AppTheme.iconXs,
            color: rowData.iconColor ?? AppTheme.textSecondary,
          ),
          const SizedBox(width: AppTheme.spacingXs),

          // Rich text content
          Expanded(
            child: RichText(
              text: TextSpan(
                children: [
                  // Bold label ending with ": "
                  TextSpan(
                    text: '${rowData.label}: ',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.textSecondary,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  // Regular value text
                  TextSpan(
                    text: rowData.value,
                    style: AppTheme.bodySmall.copyWith(
                      color: rowData.valueColor ?? AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
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

  /// Builds the vertical divider between columns
  Widget _buildVerticalDivider() {
    return Container(
      width: 2,
      height: 60, // Fixed height for consistency
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            AppTheme.accentCopper.withOpacity(0.1),
            AppTheme.accentCopper.withOpacity(0.4),
            AppTheme.accentCopper.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(1),
        boxShadow: [
          BoxShadow(
            color: AppTheme.accentCopper.withOpacity(0.2),
            blurRadius: 2,
            offset: const Offset(0, 0),
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
