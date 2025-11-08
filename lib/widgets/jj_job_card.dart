import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';
import 'package:cached_network_image/cached_network_image.dart';

import '../models/job_model.dart';
import '../design_system/app_theme.dart';

/// Job card variants for different display contexts
enum JJJobCardVariant {
  /// Compact card for home screen and lists (height: 120)
  compact,
  
  /// Standard card with moderate detail (height: 160)
  standard,
  
  /// Detailed card with full job information (height: 200+)
  detailed,
}

/// Configuration options for JJJobCard display
class JJJobCardConfig {
  /// Whether to show the bookmark button
  final bool showBookmark;
  
  /// Whether to show storm badge
  final bool showStormBadge;
  
  /// Whether to show wage information
  final bool showWage;
  
  /// Whether to show union local information
  final bool showUnionLocal;
  
  /// Whether to show job status indicator
  final bool showStatus;
  
  /// Whether to animate card appearance
  final bool animate;
  
  /// Custom elevation override
  final double? elevation;
  
  /// Custom border radius override
  final BorderRadius? borderRadius;
  
  /// Whether to show electrical circuit background
  final bool showCircuitPattern;

  const JJJobCardConfig({
    this.showBookmark = true,
    this.showStormBadge = true,
    this.showWage = true,
    this.showUnionLocal = true,
    this.showStatus = true,
    this.animate = true,
    this.elevation,
    this.borderRadius,
    this.showCircuitPattern = true,
  });
}
/// A unified job card component with electrical theming
/// 
/// This component consolidates all job card implementations into a single,
/// configurable widget that supports multiple display variants and features.
/// 
/// Example usage:
/// ```dart
/// JJJobCard(
///   job: job,
///   variant: JJJobCardVariant.standard,
///   onTap: () => navigateToJobDetail(job),
///   onBookmark: (isBookmarked) => toggleBookmark(job),
/// )
/// ```
class JJJobCard extends StatefulWidget {
  /// The job data to display
  final Job job;
  
  /// Display variant for the card
  final JJJobCardVariant variant;
  
  /// Configuration options
  final JJJobCardConfig config;
  
  /// Callback when card is tapped
  final VoidCallback? onTap;
  
  /// Callback when bookmark is toggled
  final ValueChanged<bool>? onBookmark;
  
  /// Whether this job is bookmarked
  final bool isBookmarked;
  
  /// Whether to show a selection indicator
  final bool isSelected;
  
  /// Additional content to display below the job info
  final Widget? footer;
  
  /// Custom margin around the card
  final EdgeInsets? margin;

  const JJJobCard({
    super.key,
    required this.job,
    this.variant = JJJobCardVariant.standard,
    this.config = const JJJobCardConfig(),
    this.onTap,
    this.onBookmark,
    this.isBookmarked = false,
    this.isSelected = false,
    this.footer,
    this.margin,
  });

  @override
  State<JJJobCard> createState() => _JJJobCardState();
}

/// State class for JJJobCard
class _JJJobCardState extends State<JJJobCard> {
  @override
  Widget build(BuildContext context) {
    // TODO: Implement the actual card UI based on the variant and configuration
    // This is a minimal implementation that returns a basic card
    return Card(
      margin: widget.margin ?? const EdgeInsets.all(8.0),
      elevation: widget.config.elevation ?? 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: widget.config.borderRadius ?? BorderRadius.circular(12.0),
      ),
      child: InkWell(
        onTap: widget.onTap,
        borderRadius: widget.config.borderRadius ?? BorderRadius.circular(12.0),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Job title
              Text(
                widget.job.jobTitle ?? widget.job.company,
                style: const TextStyle(
                  fontSize: 16.0,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8.0),
              // Job location
              Text(widget.job.location),
              if (widget.footer != null) ...[
                const SizedBox(height: 12.0),
                widget.footer!,
              ],
            ],
          ),
        ),
      ),
    );
  }
}
