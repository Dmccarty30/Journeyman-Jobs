import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/job_card.dart';
import '../models/job_model.dart';
import '../features/job_sharing/widgets/share_button.dart';

/// Enhanced job card that includes sharing functionality
/// Extends the basic JobCard with additional features for the crew system
class EnhancedJobCard extends StatelessWidget {
  /// The job model to display
  final JobModel job;
  
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

  const EnhancedJobCard({
    super.key,
    required this.job,
    this.variant = JobCardVariant.full,
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
    return Stack(
      children: [
        // Base job card
        JobCard(
          job: job,
          variant: variant,
          onTap: onTap,
          onViewDetails: onViewDetails,
          onBidNow: onBidNow,
          onFavorite: onFavorite,
          isFavorited: isFavorited,
          margin: margin,
          padding: padding,
        ),
        
        // Share button positioned at top right
        if (variant == JobCardVariant.full)
          Positioned(
            top: (margin?.top ?? AppTheme.spacingSm) + AppTheme.spacingMd,
            right: (margin?.right ?? AppTheme.spacingMd) + AppTheme.spacingMd + AppTheme.iconMd + AppTheme.spacingSm,
            child: JJShareButton(
              onPressed: () {},
              size: JJShareButtonSize.small,
              tooltip: 'Share job with colleagues',
            ),
          ),
      ],
    );
  }
}