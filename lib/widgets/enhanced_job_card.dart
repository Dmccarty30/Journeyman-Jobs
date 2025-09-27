import 'package:flutter/material.dart';
import '../utils/string_formatter.dart';

import '../design_system/app_theme.dart';
import '../electrical_components/enhanced_backgrounds.dart' show VoltageLevel, EnhancedBackgrounds;
import '../models/job_model.dart';

/// Enhanced JobCard component with electrical theme
class EnhancedJobCard extends StatelessWidget {
  /// Creates an EnhancedJobCard.
  ///
  /// The [job] and [variant] parameters are required.
  const EnhancedJobCard({
    required this.job, required this.variant, super.key,
    this.onTap,
    this.onViewDetails,
    this.onBidNow,
    this.onFavorite,
    this.isFavorited = false,
    this.margin,
    this.padding,
  });

  /// The job data to display
  final Job job;
  
  /// The variant of the job card to display
  final JobCardVariant variant;
  
  /// Callback when the card is tapped
  final VoidCallback? onTap;
  
  /// Callback when the view details button is pressed
  final VoidCallback? onViewDetails;
  
  /// Callback when the bid now button is pressed
  final VoidCallback? onBidNow;
  
  /// Callback when the favorite button is pressed
  final VoidCallback? onFavorite;
  
  /// Whether the job is favorited
  final bool isFavorited;
  
  /// Margin around the card
  final EdgeInsets? margin;
  
  /// Padding inside the card
  final EdgeInsets? padding;

  @override
  Widget build(BuildContext context) => switch (variant) {
        JobCardVariant.half => _buildHalfCard(),
        JobCardVariant.full => _buildFullCard(),
      };

  Widget _buildHalfCard() => EnhancedBackgrounds.enhancedCardBackground(
        onTap: onTap,
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildHeader(),
            const SizedBox(height: AppTheme.spacingSm),
            _buildContent(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildActionButtons(),
          ],
        ),
      );

  Widget _buildFullCard() => EnhancedBackgrounds.enhancedCardBackground(
        onTap: onTap,
        margin: margin ?? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        ),
        padding: padding ?? const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            _buildEnhancedHeader(),
            const SizedBox(height: AppTheme.spacingSm),
            _buildStatusIndicator(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildEnhancedContent(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildElectricalDetails(),
            const SizedBox(height: AppTheme.spacingMd),
            _buildEnhancedActionButtons(),
          ],
        ),
      );

  Widget _buildHeader() => Row(
        children: <Widget>[
          // Local indicator with electrical theme
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusXs),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Icon(
                  Icons.electrical_services,
                  size: 12,
                  color: AppTheme.white,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Text(
                  'Local ${job.local ?? "N/A"}',
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const Spacer(),
          if (_isStormWork())
            Container(
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingSm,
                vertical: AppTheme.spacingXs,
              ),
              decoration: BoxDecoration(
                color: AppTheme.warningYellow.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                border: Border.all(
                  color: AppTheme.warningYellow,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  const Icon(
                    Icons.thunderstorm,
                    size: 12,
                    color: AppTheme.warningYellow,
                  ),
                  const SizedBox(width: AppTheme.spacingXs),
                  Text(
                    'STORM WORK',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.warningYellow,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
        ],
      );

  Widget _buildEnhancedHeader() => Row(
        children: <Widget>[
          // Enhanced local indicator
          Container(
            height: 50,
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingMd,
            ),
            decoration: BoxDecoration(
              gradient: AppTheme.buttonGradient,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              boxShadow: const <BoxShadow>[AppTheme.shadowSm],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: AppTheme.white.withValues(alpha: 0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.electrical_services,
                    size: 18,
                    color: AppTheme.white,
                  ),
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget>[
                    Text(
                      'IBEW Local',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.white.withValues(alpha: 0.8),
                        fontSize: 10,
                      ),
                    ),
                    Text(
                      '${job.local ?? "N/A"}',
                      style: AppTheme.bodyLarge.copyWith(
                        color: AppTheme.white,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const Spacer(),
          // Favorite button with electrical animation
          _buildFavoriteButton(),
        ],
      );

  Widget _buildStatusIndicator() {
    final bool isUrgent = _isStormWork();
    final bool isPriority = _isHighPriority();
    
    if (!isUrgent && !isPriority) {
      return const SizedBox.shrink();
    }
    
    return Container(
      decoration: EnhancedBackgrounds.voltageStatusGradient(
        isUrgent ? VoltageLevel.high : VoltageLevel.medium,
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      child: Row(
        children: <Widget>[
          Icon(
            isUrgent ? Icons.thunderstorm : Icons.priority_high,
            size: 16,
            color: AppTheme.white,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Text(
            isUrgent ? 'EMERGENCY STORM WORK' : 'HIGH PRIORITY',
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: AppTheme.white,
              shape: BoxShape.circle,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          if (job.classification != null)
            Text(
              toTitleCase(job.classification!),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.w600,
              ),
            ),
          if (_description != null) ...<Widget>[
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              _description!,
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.textSecondary,
              ),
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );

  Widget _buildEnhancedContent() => Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          // Classification with electrical icon
          if (job.classification != null)
            Row(
              children: <Widget>[
                Icon(
                  _getClassificationIcon(job.classification!),
                  size: 20,
                  color: AppTheme.accentCopper,
                ),
                const SizedBox(width: AppTheme.spacingSm),
                Expanded(
                  child: Text(
                    toTitleCase(job.classification!),
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          
          // Location with enhanced styling
          ...<Widget>[
            const SizedBox(height: AppTheme.spacingSm),
            Row(
              children: <Widget>[
                const Icon(
                  Icons.location_on,
                  size: 16,
                  color: AppTheme.textSecondary,
                ),
                const SizedBox(width: AppTheme.spacingXs),
                Expanded(
                  child: Text(
                    toTitleCase(job.location),
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
          
          // Description with better formatting
          if (_description != null) ...<Widget>[
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              _description!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                height: 1.4,
              ),
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ],
      );

  Widget _buildElectricalDetails() => Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.offWhite,
          borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          border: Border.all(
            color: AppTheme.accentCopper.withValues(alpha: 0.2),
          ),
        ),
        child: Row(
          children: <Widget>[
            _buildDetailItem(
              icon: Icons.schedule,
              label: 'Duration',
              value: job.duration ?? 'TBD',
            ),
            const SizedBox(width: AppTheme.spacingLg),
            _buildDetailItem(
              icon: Icons.attach_money,
              label: 'Rate',
              value: _rate,
            ),
            const Spacer(),
            // Voltage level indicator
            _buildVoltageIndicator(),
          ],
        ),
      );

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
  }) =>
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Icon(
                icon,
                size: 14,
                color: AppTheme.accentCopper,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Text(
                label,
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            value,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.primaryNavy,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      );

  Widget _buildVoltageIndicator() {
    final VoltageLevel voltage = _getVoltageLevel();
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: EnhancedBackgrounds.voltageStatusGradient(voltage),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(
            Icons.bolt,
            size: 14,
            color: AppTheme.white,
          ),
          const SizedBox(width: AppTheme.spacingXs),
          Text(
            _getVoltageText(voltage),
            style: AppTheme.bodySmall.copyWith(
              color: AppTheme.white,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() => Row(
        children: <Widget>[
          Expanded(
            child: ElevatedButton(
              onPressed: onViewDetails,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.lightGray,
                foregroundColor: AppTheme.primaryNavy,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Details'),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: ElevatedButton(
              onPressed: onBidNow,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                elevation: 0,
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingSm,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Bid Now'),
            ),
          ),
        ],
      );

  Widget _buildEnhancedActionButtons() => Row(
        children: <Widget>[
          Expanded(
            flex: 2,
            child: ElevatedButton.icon(
              onPressed: onBidNow,
              icon: const Icon(Icons.flash_on, size: 18),
              label: const Text('Quick Bid'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                elevation: 2,
                shadowColor: AppTheme.accentCopper.withValues(alpha: 0.3),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: OutlinedButton(
              onPressed: onViewDetails,
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.primaryNavy,
                side: const BorderSide(
                  color: AppTheme.primaryNavy,
                  width: 1.5,
                ),
                padding: const EdgeInsets.symmetric(
                  vertical: AppTheme.spacingMd,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
              child: const Text('Details'),
            ),
          ),
        ],
      );

  Widget _buildFavoriteButton() => DecoratedBox(
        decoration: BoxDecoration(
          color: isFavorited ? AppTheme.errorRed : AppTheme.lightGray,
          shape: BoxShape.circle,
          boxShadow: const <BoxShadow>[AppTheme.shadowSm],
        ),
        child: IconButton(
          onPressed: onFavorite,
          icon: Icon(
            isFavorited ? Icons.favorite : Icons.favorite_border,
            color: isFavorited ? AppTheme.white : AppTheme.textSecondary,
            size: 20,
          ),
        ),
      );

  IconData _getClassificationIcon(String classification) {
    final String lowerClassification = classification.toLowerCase();
    if (lowerClassification.contains('lineman')) {
      return Icons.power_outlined;
    } else if (lowerClassification.contains('electrician')) {
      return Icons.electrical_services;
    } else if (lowerClassification.contains('wireman')) {
      return Icons.cable;
    } else if (lowerClassification.contains('operator')) {
      return Icons.settings;
    }
    return Icons.construction;
  }

  VoltageLevel _getVoltageLevel() {
    final String classification = job.classification?.toLowerCase() ?? '';
    if (classification.contains('transmission') || 
        classification.contains('lineman')) {
      return VoltageLevel.high;
    } else if (classification.contains('distribution') || 
               classification.contains('substation')) {
      return VoltageLevel.medium;
    }
    return VoltageLevel.low;
  }

  String _getVoltageText(VoltageLevel level) {
    switch (level) {
      case VoltageLevel.high:
        return 'HIGH V';
      case VoltageLevel.medium:
        return 'MED V';
      case VoltageLevel.low:
        return 'LOW V';
    }
  }

  /// Check if job is storm work based on job fields
  bool _isStormWork() {
    // Check various fields for storm-related keywords
    final String title = job.jobTitle?.toLowerCase() ?? '';
    final String description = job.jobDescription?.toLowerCase() ?? '';
    final String typeOfWork = job.typeOfWork?.toLowerCase() ?? '';
    final String classification = job.classification?.toLowerCase() ?? '';
    
    return title.contains('storm') || 
           title.contains('emergency') ||
           description.contains('storm') ||
           description.contains('emergency') ||
           typeOfWork.contains('storm') ||
           typeOfWork.contains('emergency') ||
           classification.contains('storm') ||
           classification.contains('emergency');
  }

  /// Check if job is high priority based on job fields
  bool _isHighPriority() {
    // Check various fields for priority indicators
    final String title = job.jobTitle?.toLowerCase() ?? '';
    final String description = job.jobDescription?.toLowerCase() ?? '';
    final String typeOfWork = job.typeOfWork?.toLowerCase() ?? '';
    final String classification = job.classification?.toLowerCase() ?? '';
    final double? wage = job.wage;
    
    // High priority if it's storm work, high wage,
    // or contains priority keywords
    // High wage jobs
    return _isStormWork() ||
           (wage != null && wage > 50.0) ||
           title.contains('urgent') ||
           title.contains('immediate') ||
           title.contains('asap') ||
           description.contains('urgent') ||
           description.contains('immediate') ||
           description.contains('asap') ||
           typeOfWork.contains('urgent') ||
           typeOfWork.contains('immediate') ||
           classification.contains('urgent') ||
           classification.contains('immediate');
  }

  /// Get job description with fallback
  String? get _description => job.jobDescription;

  /// Get job rate with formatting
  String get _rate {
    if (job.wage != null) {
      return '\$${job.wage!.toStringAsFixed(2)}/hr';
    }
    return 'Contact Local';
  }
}

/// Job card variants for different use cases
enum JobCardVariant {
  /// Compact card for home screen and lists
  half,
  /// Full detailed card for job listings
  full,
}
