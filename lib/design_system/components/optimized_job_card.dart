import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../app_theme.dart';
import '../../models/job_model.dart';
import 'reusable_components.dart';

/// Mobile-optimized JobCard with 44dp minimum touch targets and glove-friendly interactions
/// 
/// Features:
/// - 44dp minimum touch targets for accessibility and glove usage
/// - Haptic feedback for better user experience
/// - Swipe gesture support for quick actions
/// - High-contrast mode for outdoor visibility
/// - Battery-efficient rendering optimizations
class OptimizedJobCard extends StatefulWidget {
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
  
  /// Whether to enable high-contrast mode for outdoor use
  final bool highContrastMode;
  
  /// Whether to enable swipe gestures
  final bool enableSwipeGestures;
  
  /// Callback for bookmark swipe action
  final VoidCallback? onSwipeBookmark;
  
  /// Callback for apply swipe action
  final VoidCallback? onSwipeApply;

  const OptimizedJobCard({
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
    this.highContrastMode = false,
    this.enableSwipeGestures = true,
    this.onSwipeBookmark,
    this.onSwipeApply,
  });

  @override
  State<OptimizedJobCard> createState() => _OptimizedJobCardState();
}

class _OptimizedJobCardState extends State<OptimizedJobCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  bool _isSwipeVisible = false;

  // Mobile-optimized minimum touch target size (44dp)
  static const double kMinTouchTarget = 44.0;
  
  // High-contrast colors for outdoor use
  static const Color _highContrastText = Color(0xFF000000);
  static const Color _highContrastBackground = Color(0xFFFFFFFF);
  static const Color _highContrastAccent = Color(0xFF0066CC);

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _slideAnimation = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(0.3, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onHorizontalDragUpdate: widget.enableSwipeGestures ? _handleSwipe : null,
      onHorizontalDragEnd: widget.enableSwipeGestures ? _handleSwipeEnd : null,
      onTap: () {
        _provideTactileFeedback();
        widget.onTap?.call();
      },
      child: Stack(
        children: [
          // Swipe action background
          if (widget.enableSwipeGestures) _buildSwipeBackground(),
          
          // Main card content
          SlideTransition(
            position: _slideAnimation,
            child: _buildCardContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildSwipeBackground() {
    return Container(
      margin: widget.margin ?? _getDefaultMargin(),
      decoration: BoxDecoration(
        color: widget.isFavorited ? AppTheme.successGreen : AppTheme.accentCopper,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Row(
        children: [
          const SizedBox(width: AppTheme.spacingLg),
          Icon(
            widget.isFavorited ? Icons.bookmark_remove : Icons.bookmark_add,
            color: Colors.white,
            size: 24,
          ),
          const Spacer(),
          Icon(
            Icons.flash_on,
            color: Colors.white,
            size: 24,
          ),
          const SizedBox(width: AppTheme.spacingLg),
        ],
      ),
    );
  }
      Widget _buildCardContent() => JJCard(
          margin: widget.margin ?? _getDefaultMargin(),
          padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMd),
          backgroundColor: widget.highContrastMode ? _highContrastBackground : null,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header row - Local and Classification
              Row(
                children: [
                  // Local
                  if (widget.job.local != null)
                    Expanded(
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      Widget _buildCardContent() {          ),
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {          const Spacer(),
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {          Icon(
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {            Icons.flash_on,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {            color: Colors.white,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {            size: 24,
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {          ),
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {          const SizedBox(width: AppTheme.spacingLg),
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {        ],
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {      ),
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {    );
                size: 24,
              ),
              const Spacer(),
              Icon(
                Icons.flash_on,
                color: Colors.white,
                size: 24,
              ),
              const SizedBox(width: AppTheme.spacingLg),
            ],
          ),
        );
      }
      Widget _buildCardContent() {
        switch (widget.variant) {
          case JobCardVariant.half:
            return _buildHalfCard();
          case JobCardVariant.full:
            return _buildFullCard();
        }
      }
  Widget _buildHalfCard() {
    return JJCard(
      margin: widget.margin ?? _getDefaultMargin(),
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      backgroundColor: widget.highContrastMode ? _highContrastBackground : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header row - Local and Classification
          Row(
            children: [
              // Local
              if (widget.job.local != null)
                Expanded(
                  child: RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(
                          text: 'Local: ',
                          style: _getTextStyle(AppTheme.bodySmall).copyWith(
                            color: _getSecondaryTextColor(),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        TextSpan(
                          text: '${widget.job.local}',
                          style: _getTextStyle(AppTheme.bodySmall).copyWith(
                            color: _getPrimaryTextColor(),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              
              // Classification
              if (widget.job.classification != null)
                Expanded(
                  child: Text(
                    widget.job.classification!,
                    style: _getTextStyle(AppTheme.bodySmall).copyWith(
                      color: _getPrimaryTextColor(),
                      fontWeight: FontWeight.w600,
                    ),
                    overflow: TextOverflow.ellipsis,
                    textAlign: TextAlign.center,
                  ),
                ),
              
              // Optimized favorite button with 44dp touch target
              _buildOptimizedFavoriteButton(),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingSm),
          
          // Posted time row
          if (widget.job.datePosted != null) _buildInfoRow(
            icon: Icons.access_time,
            text: 'Posted ${widget.job.datePosted}',
          ),
          
          const SizedBox(height: AppTheme.spacingXs),
          
          // Location row
          _buildInfoRow(
            icon: Icons.location_on_outlined,
            label: 'Location: ',
            text: widget.job.location,
          ),
          
          const SizedBox(height: AppTheme.spacingXs),
          
          // Hours and Per Diem row
          Row(
            children: [
              if (widget.job.hours != null) ...[
                Icon(
                  Icons.schedule,
                  size: AppTheme.iconXs,
                  color: _getSecondaryTextColor(),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Hours: ',
                        style: _getTextStyle(AppTheme.bodySmall).copyWith(
                          color: _getSecondaryTextColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: '${widget.job.hours}',
                        style: _getTextStyle(AppTheme.bodySmall).copyWith(
                          color: _getPrimaryTextColor(),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              
              // Spacer
              if (widget.job.hours != null && widget.job.perDiem != null)
                const SizedBox(width: AppTheme.spacingMd),
              
              // Per Diem
              if (widget.job.perDiem != null && widget.job.perDiem!.isNotEmpty) ...[
                Icon(
                  Icons.attach_money,
                  size: AppTheme.iconXs,
                  color: _getAccentColor(),
                ),
                const SizedBox(width: AppTheme.spacingXs),
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: 'Per Diem: ',
                        style: _getTextStyle(AppTheme.bodySmall).copyWith(
                          color: _getSecondaryTextColor(),
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      TextSpan(
                        text: widget.job.perDiem!,
                        style: _getTextStyle(AppTheme.bodySmall).copyWith(
                          color: _getAccentColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Optimized action buttons with 44dp minimum height
          Row(
            children: [
              Expanded(
                child: _buildOptimizedButton(
                  text: 'Details',
                  onPressed: () {
                    _provideTactileFeedback();
                    widget.onViewDetails?.call();
                  },
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Expanded(
                child: _buildOptimizedButton(
                  text: 'Apply',
                  onPressed: () {
                    _provideTactileFeedback();
                    widget.onBidNow?.call();
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFullCard() {
    return JJCard(
      margin: widget.margin ?? _getDefaultMargin(),
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingLg),
      backgroundColor: widget.highContrastMode ? _highContrastBackground : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header row
          Row(
            children: [
              // Local and Classification
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (widget.job.local != null)
                      RichText(
                        text: TextSpan(
                          children: [
                            TextSpan(
                              text: 'Local: ',
                              style: _getTextStyle(AppTheme.bodyMedium).copyWith(
                                color: _getSecondaryTextColor(),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            TextSpan(
                              text: '${widget.job.local}',
                              style: _getTextStyle(AppTheme.bodyMedium).copyWith(
                                color: _getPrimaryTextColor(),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    if (widget.job.classification != null)
                      Text(
                        widget.job.classification!,
                        style: _getTextStyle(AppTheme.titleMedium).copyWith(
                          color: _getPrimaryTextColor(),
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                  ],
                ),
              ),
              
              // Optimized favorite button
              _buildOptimizedFavoriteButton(),
            ],
          ),
          
          const SizedBox(height: AppTheme.spacingMd),
          
          // Posted time
          if (widget.job.datePosted != null) ...[
            _buildInfoRow(
              icon: Icons.access_time,
              text: 'Posted ${widget.job.datePosted}',
              isLarge: true,
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],
          
          // Job details
          _buildDetailItem(
            icon: Icons.location_on_outlined,
            label: 'Location',
            value: widget.job.location,
          ),
          
          if (widget.job.hours != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailItem(
              icon: Icons.schedule,
              label: 'Hours',
              value: '${widget.job.hours}',
            ),
          ],
          
          if (widget.job.wage != null) ...[
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailItem(
              icon: Icons.attach_money,
              label: 'Wages',
              value: '\$${widget.job.wage!.toStringAsFixed(2)}/hr',
              isHighlighted: true,
            ),
          ],
          
          if (widget.job.perDiem != null && widget.job.perDiem!.isNotEmpty) ...[
            const SizedBox(height: AppTheme.spacingSm),
            _buildDetailItem(
              icon: Icons.hotel,
              label: 'Per Diem',
              value: widget.job.perDiem!,
              isHighlighted: true,
            ),
          ],
          
          const SizedBox(height: AppTheme.spacingLg),
          
          // Optimized action buttons
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildOptimizedButton(
                  text: 'Details',
                  icon: Icons.info_outline,
                  onPressed: () {
                    _provideTactileFeedback();
                    widget.onViewDetails?.call();
                  },
                  isPrimary: false,
                ),
              ),
              const SizedBox(width: AppTheme.spacingMd),
              Expanded(
                flex: 3,
                child: _buildOptimizedButton(
                  text: 'Apply',
                  icon: Icons.flash_on,
                  onPressed: () {
                    _provideTactileFeedback();
                    widget.onBidNow?.call();
                  },
                  isPrimary: true,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildOptimizedFavoriteButton() {
    return Container(
      constraints: const BoxConstraints(
        minWidth: kMinTouchTarget,
        minHeight: kMinTouchTarget,
      ),
      child: IconButton(
        onPressed: widget.onFavorite != null ? () {
          _provideTactileFeedback();
          widget.onFavorite!();
        } : null,
        icon: Icon(
          widget.isFavorited ? Icons.bookmark : Icons.bookmark_border,
          size: widget.variant == JobCardVariant.half ? AppTheme.iconSm : AppTheme.iconMd,
          color: widget.isFavorited ? _getAccentColor() : _getSecondaryTextColor(),
        ),
        visualDensity: VisualDensity.compact,
        padding: const EdgeInsets.all(4),
      ),
    );
  }

  Widget _buildOptimizedButton({
    required String text,
    required VoidCallback? onPressed,
    required bool isPrimary,
    IconData? icon,
  }) {
    return SizedBox(
      height: kMinTouchTarget,
      child: isPrimary 
        ? JJPrimaryButton(
            text: text,
            icon: icon,
            onPressed: onPressed,
            height: kMinTouchTarget,
            textStyle: _getTextStyle(AppTheme.bodyMedium),
          )
        : JJSecondaryButton(
            text: text,
            icon: icon,
            onPressed: onPressed,
            height: kMinTouchTarget,
            textStyle: _getTextStyle(AppTheme.bodyMedium),
          ),
    );
  }

  Widget _buildInfoRow({
    required IconData icon,
    required String text,
    String? label,
    bool isLarge = false,
  }) {
    return Row(
      children: [
        Icon(
          icon,
          size: isLarge ? AppTheme.iconSm : AppTheme.iconXs,
          color: _getSecondaryTextColor(),
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: label != null
            ? RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: label,
                      style: _getTextStyle(isLarge ? AppTheme.bodyMedium : AppTheme.labelSmall).copyWith(
                        color: _getSecondaryTextColor(),
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    TextSpan(
                      text: text,
                      style: _getTextStyle(isLarge ? AppTheme.bodyMedium : AppTheme.labelSmall).copyWith(
                        color: _getPrimaryTextColor(),
                      ),
                    ),
                  ],
                ),
                overflow: TextOverflow.ellipsis,
              )
            : Text(
                text,
                style: _getTextStyle(isLarge ? AppTheme.bodyMedium : AppTheme.labelSmall).copyWith(
                  color: _getSecondaryTextColor(),
                ),
                overflow: TextOverflow.ellipsis,
              ),
        ),
      ],
    );
  }

  Widget _buildDetailItem({
    required IconData icon,
    required String label,
    required String value,
    bool isHighlighted = false,
  }) {
    if (value.isEmpty || value.toLowerCase().contains('competitive')) {
      return const SizedBox.shrink();
    }
    
    return Row(
      children: [
        Icon(
          icon,
          size: AppTheme.iconSm,
          color: isHighlighted ? _getAccentColor() : _getSecondaryTextColor(),
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$label: ',
                  style: _getTextStyle(AppTheme.bodyMedium).copyWith(
                    color: _getSecondaryTextColor(),
                    fontWeight: FontWeight.w500,
                  ),
                ),
                TextSpan(
                  text: value,
                  style: _getTextStyle(AppTheme.bodyMedium).copyWith(
                    color: isHighlighted ? _getAccentColor() : _getPrimaryTextColor(),
                    fontWeight: isHighlighted ? FontWeight.w600 : FontWeight.w500,
                  ),
                ),
              ],
            ),
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // Color helper methods for high-contrast mode
  Color _getPrimaryTextColor() {
    return widget.highContrastMode ? _highContrastText : AppTheme.textPrimary;
  }

  Color _getSecondaryTextColor() {
    return widget.highContrastMode ? _highContrastText : AppTheme.textSecondary;
  }

  Color _getAccentColor() {
    return widget.highContrastMode ? _highContrastAccent : AppTheme.accentCopper;
  }

  TextStyle _getTextStyle(TextStyle baseStyle) {
    if (!widget.highContrastMode) return baseStyle;
    
    return baseStyle.copyWith(
      color: _highContrastText,
      fontWeight: FontWeight.w600, // Bolder text for better outdoor visibility
    );
  }

  EdgeInsets _getDefaultMargin() {
    return widget.variant == JobCardVariant.half
      ? const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingSm,
          vertical: AppTheme.spacingXs,
        )
      : const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        );
  }

  void _provideTactileFeedback() {
    HapticFeedback.lightImpact();
  }

  void _handleSwipe(DragUpdateDetails details) {
    if (!widget.enableSwipeGestures) return;
    
    final delta = details.primaryDelta ?? 0;
    if (delta.abs() > 10) {
      if (!_isSwipeVisible) {
        setState(() {
          _isSwipeVisible = true;
        });
        _animationController.forward();
      }
    }
  }

  void _handleSwipeEnd(DragEndDetails details) {
    if (!widget.enableSwipeGestures || !_isSwipeVisible) return;
    
    final velocity = details.primaryVelocity ?? 0;
    
    if (velocity > 300) {
      // Right swipe - bookmark action
      _provideTactileFeedback();
      widget.onSwipeBookmark?.call();
    } else if (velocity < -300) {
      // Left swipe - apply action
      _provideTactileFeedback();
      widget.onSwipeApply?.call();
    }
    
    // Reset animation
    _animationController.reverse().then((_) {
      setState(() {
        _isSwipeVisible = false;
      });
    });
  }
}

/// Enum for JobCard variants
enum JobCardVariant {
  /// Half-size variant for home screen and compact displays
  half,
  /// Full-size variant for jobs screen with detailed information
  full,
}
