import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/design_system/components/reusable_components.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/utils/job_formatting.dart';

/// Card display variants covering all use cases
enum JobCardVariant {
  /// Compact card for home screen (replaces CondensedJobCard)
  /// - Two-column layout
  /// - Essential fields only
  /// - Arrow indicator
  /// - No action buttons
  compact,

  /// Half-size card for lists (from JobCard)
  /// - Vertical layout
  /// - Core fields
  /// - Inline action buttons
  /// - Minimal spacing
  half,

  /// Full-size card for detailed views (from JobCard)
  /// - Vertical layout
  /// - All available fields
  /// - Prominent action buttons
  /// - Generous spacing
  full,

  /// Detailed card with RichText formatting (from RichTextJobCard)
  /// - Two-column field layout
  /// - Comprehensive field display
  /// - Type of work and qualifications
  /// - Copper gradient buttons
  detailed,

  /// Standard single-column card
  /// - Default balanced layout
  /// - Moderate spacing
  /// - Standard button styling
  standard,
}

/// Visual style presets for different contexts
enum JobCardStyle {
  /// Standard electrical theme
  /// - Copper accents
  /// - Basic borders
  /// - Standard shadows
  standard,

  /// Enhanced electrical theme
  /// - Storm work badges
  /// - Enhanced backgrounds
  /// - Classification icons
  /// - Priority detection
  enhanced,

  /// Minimal theme
  /// - Reduced decoration
  /// - Flat design
  /// - Text-focused
  minimal,

  /// High contrast theme
  /// - Accessibility-focused
  /// - Strong color contrast
  /// - Clear visual hierarchy
  highContrast,
}

/// Configurable feature flags for optional capabilities
class JobCardFeatures {
  /// Show favorite/bookmark button
  final bool showFavorite;

  /// Show storm work badge
  final bool showStormBadge;

  /// Show priority indicators
  final bool showPriorityIndicator;

  /// Enable tap animation feedback
  final bool enableAnimation;

  /// Show swipe action overlay
  final bool showSwipeActions;

  /// Show classification icon (vs text only)
  final bool showClassificationIcon;

  /// Show copper divider lines
  final bool showDividers;

  /// Show navigation arrow (compact variant)
  final bool showNavigationArrow;

  /// Show action buttons
  final bool showActionButtons;

  const JobCardFeatures({
    this.showFavorite = true,
    this.showStormBadge = true,
    this.showPriorityIndicator = true,
    this.enableAnimation = false,
    this.showSwipeActions = false,
    this.showClassificationIcon = false,
    this.showDividers = true,
    this.showNavigationArrow = true,
    this.showActionButtons = true,
  });
}

/// UnifiedJobCard - Consolidated job card component
///
/// Replaces 6 duplicate job card implementations with a single
/// configurable component supporting all use cases.
///
/// ## Variants
///
/// - **compact**: Two-column layout for HomeScreen (6-10 jobs)
/// - **half**: Vertical compact layout for lists
/// - **full**: Detailed vertical layout for lists
/// - **detailed**: Comprehensive two-column with RichText
/// - **standard**: Default balanced layout
///
/// ## Styles
///
/// - **standard**: Basic electrical theme (copper accents, borders)
/// - **enhanced**: Advanced theme (storm badges, classification icons)
/// - **minimal**: Flat design, text-focused
/// - **highContrast**: Accessibility-optimized
///
/// ## Examples
///
/// ### HomeScreen Compact View
/// ```dart
/// UnifiedJobCard(
///   job: job,
///   variant: JobCardVariant.compact,
///   features: const JobCardFeatures(showActionButtons: false),
///   onTap: () => navigateToDetails(job),
/// )
/// ```
///
/// ### JobsScreen Detailed View
/// ```dart
/// UnifiedJobCard(
///   job: job,
///   variant: JobCardVariant.detailed,
///   style: JobCardStyle.enhanced,
///   features: const JobCardFeatures(),
///   onViewDetails: () => showDialog(...),
///   onBidNow: () => handleBid(job),
/// )
/// ```
///
/// ### VirtualJobList High-Performance View
/// ```dart
/// UnifiedJobCard(
///   job: job,
///   variant: JobCardVariant.half,
///   features: const JobCardFeatures(enableAnimation: false),
///   isFavorited: favorites.contains(job.id),
///   onFavorite: () => toggleFavorite(job),
/// )
/// ```
class UnifiedJobCard extends StatelessWidget {
  /// The canonical job model
  final Job job;

  /// Card display variant
  final JobCardVariant variant;

  /// Visual style preset
  final JobCardStyle style;

  /// Feature flags for optional capabilities
  final JobCardFeatures features;

  /// Interaction callbacks
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBidNow;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  /// Layout configuration
  final EdgeInsets? margin;
  final EdgeInsets? padding;

  /// Accessibility
  final bool highContrastMode;

  const UnifiedJobCard({
    super.key,
    required this.job,
    this.variant = JobCardVariant.standard,
    this.style = JobCardStyle.standard,
    this.features = const JobCardFeatures(),
    this.onTap,
    this.onViewDetails,
    this.onBidNow,
    this.onFavorite,
    this.isFavorited = false,
    this.margin,
    this.padding,
    this.highContrastMode = false,
  });

  @override
  Widget build(BuildContext context) {
    return JJCard(
      onTap: onTap,
      margin: margin ?? const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      padding: padding ?? _getVariantPadding(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildCardContent(context),
        ],
      ),
    );
  }

  /// Get padding based on variant
  EdgeInsets _getVariantPadding() {
    switch (variant) {
      case JobCardVariant.compact:
        return const EdgeInsets.all(12);
      case JobCardVariant.half:
        return const EdgeInsets.all(12);
      case JobCardVariant.full:
        return const EdgeInsets.all(16);
      case JobCardVariant.detailed:
        return const EdgeInsets.all(16);
      case JobCardVariant.standard:
        return const EdgeInsets.all(14);
    }
  }

  /// Build card content based on variant
  Widget _buildCardContent(BuildContext context) {
    switch (variant) {
      case JobCardVariant.compact:
        return _buildCompactVariant(context);
      case JobCardVariant.half:
        return _buildHalfVariant(context);
      case JobCardVariant.full:
        return _buildFullVariant(context);
      case JobCardVariant.detailed:
        return _buildDetailedVariant(context);
      case JobCardVariant.standard:
        return _buildStandardVariant(context);
    }
  }

  /// Build compact variant (HomeScreen - replaces CondensedJobCard)
  /// Two-column layout with essential fields only
  Widget _buildCompactVariant(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header row with local badge
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            if (job.local != null)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                decoration: BoxDecoration(
                  color: AppTheme.accentCopper,
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'Local ${job.local}',
                  style: AppTheme.bodySmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            if (features.showNavigationArrow)
              Icon(
                Icons.arrow_forward_ios,
                size: 16,
                color: AppTheme.accentCopper,
              ),
          ],
        ),
        const SizedBox(height: 12),

        // Two-column field layout
        _buildCompactField('Classification', job.classification ?? 'Not specified'),
        _buildCompactField('Contractor', job.company),
        _buildCompactField('Wages', JobFormatting.formatWage(job.wage)),
        _buildCompactField('Location', job.location),
        if (job.hours != null)
          _buildCompactField('Hours', job.hours.toString()),
        if (job.startDate != null)
          _buildCompactField('Start Date', job.startDate!),
        if (job.perDiem != null && job.perDiem!.isNotEmpty)
          _buildCompactField('Per Diem', job.perDiem!),
      ],
    );
  }

  /// Build compact field (label: value)
  Widget _buildCompactField(String label, String value) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppTheme.textSecondary,
              ),
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build half variant (VirtualJobList compact mode)
  Widget _buildHalfVariant(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with company and favorite
        Row(
          children: [
            Icon(Icons.business, size: 16, color: AppTheme.accentCopper),
            const SizedBox(width: 4),
            Expanded(
              child: Text(
                job.company,
                style: AppTheme.bodyMedium.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (features.showFavorite && onFavorite != null)
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : AppTheme.textSecondary,
                  size: 20,
                ),
                onPressed: onFavorite,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
              ),
          ],
        ),
        const SizedBox(height: 8),

        // Core fields
        _buildDetailRow(
          Icons.engineering,
          job.classification ?? 'Not specified',
        ),
        _buildDetailRow(
          Icons.location_on,
          job.location,
        ),
        if (job.local != null)
          _buildDetailRow(
            Icons.groups,
            'Local ${job.local}',
          ),
        _buildDetailRow(
          Icons.attach_money,
          JobFormatting.formatWage(job.wage),
          color: AppTheme.accentCopper,
        ),

        // Action buttons
        if (features.showActionButtons) ...[
          const SizedBox(height: 12),
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: JJButton(
                    text: 'Details',
                    onPressed: onViewDetails!,
                    variant: JJButtonVariant.secondary,
                    size: JJButtonSize.small,
                  ),
                ),
              if (onViewDetails != null && onBidNow != null)
                const SizedBox(width: 8),
              if (onBidNow != null)
                Expanded(
                  child: JJButton(
                    text: 'Bid',
                    onPressed: onBidNow!,
                    variant: JJButtonVariant.primary,
                    size: JJButtonSize.small,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build full variant (VirtualJobList full mode)
  Widget _buildFullVariant(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header with company and favorite
        Row(
          children: [
            Icon(Icons.business, size: 20, color: AppTheme.accentCopper),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                job.company,
                style: AppTheme.headlineMedium,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (features.showFavorite && onFavorite != null)
              IconButton(
                icon: Icon(
                  isFavorited ? Icons.favorite : Icons.favorite_border,
                  color: isFavorited ? Colors.red : AppTheme.textSecondary,
                ),
                onPressed: onFavorite,
              ),
          ],
        ),
        const SizedBox(height: 16),

        // Job title if available
        if (job.jobTitle != null && job.jobTitle!.isNotEmpty) ...[
          Text(
            job.jobTitle!,
            style: AppTheme.bodyLarge.copyWith(fontWeight: FontWeight.w600),
          ),
          const SizedBox(height: 12),
        ],

        // Detail grid
        Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.engineering,
                    job.classification ?? 'Not specified',
                  ),
                  _buildDetailRow(
                    Icons.location_on,
                    job.location,
                  ),
                  if (job.local != null)
                    _buildDetailRow(
                      Icons.groups,
                      'Local ${job.local}',
                    ),
                ],
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDetailRow(
                    Icons.attach_money,
                    JobFormatting.formatWage(job.wage),
                    color: AppTheme.accentCopper,
                  ),
                  if (job.hours != null)
                    _buildDetailRow(
                      Icons.schedule,
                      '${job.hours} hours',
                    ),
                  if (job.perDiem != null && job.perDiem!.isNotEmpty)
                    _buildDetailRow(
                      Icons.hotel,
                      '\$${job.perDiem}/day',
                    ),
                ],
              ),
            ),
          ],
        ),

        // Optional fields
        if (job.duration != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.calendar_today, 'Duration: ${job.duration}'),
        ],
        if (job.datePosted != null) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.update, 'Posted: ${job.datePosted}'),
        ],
        if (job.numberOfJobs != null && job.numberOfJobs!.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildDetailRow(Icons.people, '${job.numberOfJobs} positions'),
        ],

        // Action buttons
        if (features.showActionButtons) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: JJButton(
                    text: 'View Details',
                    onPressed: onViewDetails!,
                    variant: JJButtonVariant.secondary,
                  ),
                ),
              if (onViewDetails != null && onBidNow != null)
                const SizedBox(width: 12),
              if (onBidNow != null)
                Expanded(
                  child: JJButton(
                    text: 'Bid Now',
                    onPressed: onBidNow!,
                    variant: JJButtonVariant.primary,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build detailed variant (JobsScreen - replaces RichTextJobCard)
  /// Comprehensive two-column layout with RichText formatting
  Widget _buildDetailedVariant(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        if (job.local != null) ...[
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text(
              'Local ${job.local}',
              style: AppTheme.bodyMedium.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 12),
        ],

        // Two-column RichText layout
        _buildRichTextField('Classification', job.classification ?? 'Not specified'),
        if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),

        _buildRichTextField('Contractor', job.company),
        if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),

        _buildRichTextField('Wages', JobFormatting.formatWage(job.wage)),
        if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),

        _buildRichTextField('Location', job.location),
        if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),

        // Additional fields
        if (job.hours != null) ...[
          _buildRichTextField('Hours', job.hours.toString()),
          if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),
        ],
        if (job.startDate != null) ...[
          _buildRichTextField('Start Date', job.startDate!),
          if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),
        ],
        if (job.perDiem != null && job.perDiem!.isNotEmpty) ...[
          _buildRichTextField('Per Diem', '\$${job.perDiem}'),
          if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),
        ],
        if (job.typeOfWork != null && job.typeOfWork!.isNotEmpty) ...[
          _buildRichTextField('Type of Work', job.typeOfWork!),
          if (features.showDividers) const Divider(color: AppTheme.accentCopper, height: 20),
        ],
        if (job.qualifications != null && job.qualifications!.isNotEmpty) ...[
          _buildRichTextField('Qualifications', job.qualifications!),
        ],

        // Action button with copper gradient
        if (features.showActionButtons && onBidNow != null) ...[
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppTheme.accentCopper, Color(0xFFD97706)],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: onBidNow,
                borderRadius: BorderRadius.circular(8),
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.flash_on, color: Colors.white, size: 20),
                      const SizedBox(width: 8),
                      Text(
                        'Bid Now',
                        style: AppTheme.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build standard variant (balanced default)
  Widget _buildStandardVariant(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company name
        Text(
          job.company,
          style: AppTheme.headlineMedium,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 12),

        // Core fields
        _buildDetailRow(
          Icons.engineering,
          job.classification ?? 'Not specified',
        ),
        _buildDetailRow(
          Icons.location_on,
          job.location,
        ),
        if (job.local != null)
          _buildDetailRow(
            Icons.groups,
            'Local ${job.local}',
          ),
        _buildDetailRow(
          Icons.attach_money,
          JobFormatting.formatWage(job.wage),
          color: AppTheme.accentCopper,
        ),
        if (job.jobTitle != null && job.jobTitle!.isNotEmpty)
          _buildDetailRow(
            Icons.work,
            job.jobTitle!,
          ),
        if (job.perDiem != null && job.perDiem!.isNotEmpty)
          _buildDetailRow(
            Icons.hotel,
            'Per Diem: \$${job.perDiem}',
          ),
        if (job.duration != null)
          _buildDetailRow(
            Icons.calendar_today,
            'Duration: ${job.duration}',
          ),

        // Action buttons
        if (features.showActionButtons && (onViewDetails != null || onBidNow != null)) ...[
          const SizedBox(height: 16),
          Row(
            children: [
              if (onViewDetails != null)
                Expanded(
                  child: JJButton(
                    text: 'Details',
                    onPressed: onViewDetails!,
                    variant: JJButtonVariant.secondary,
                  ),
                ),
              if (onViewDetails != null && onBidNow != null)
                const SizedBox(width: 12),
              if (onBidNow != null)
                Expanded(
                  child: JJButton(
                    text: 'Bid Now',
                    onPressed: onBidNow!,
                    variant: JJButtonVariant.primary,
                  ),
                ),
            ],
          ),
        ],
      ],
    );
  }

  /// Build detail row with icon
  Widget _buildDetailRow(IconData icon, String text, {Color? color}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        children: [
          Icon(
            icon,
            size: 16,
            color: color ?? AppTheme.textSecondary,
          ),
          const SizedBox(width: 6),
          Expanded(
            child: Text(
              text,
              style: AppTheme.bodyMedium.copyWith(
                color: color ?? AppTheme.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Build RichText field (label: value in bold)
  Widget _buildRichTextField(String label, String value) {
    return RichText(
      text: TextSpan(
        style: AppTheme.bodyMedium.copyWith(color: AppTheme.textPrimary),
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          TextSpan(text: value),
        ],
      ),
    );
  }
}
