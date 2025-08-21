import 'package:flutter/material.dart';
import '../app_theme.dart';
import '../../models/job_model.dart';
import '../../utils/job_formatting.dart';
import 'reusable_components.dart';

/// Optimized JobCard component with enhanced performance features
class OptimizedJobCard extends StatefulWidget {
  /// The job object containing all job data
  final Job job;
  
  /// Whether the job is currently favorited
  final bool isFavorited;
  
  /// Whether to show the swipe action overlay
  final bool showSwipeActions;
  
  /// Callback function for when the card is tapped
  final VoidCallback? onTap;
  
  /// Callback function for favoriting/bookmarking the job
  final VoidCallback? onFavorite;
  
  /// Callback function for bidding on the job
  final VoidCallback? onBid;
  
  /// Optional margin for the card
  final EdgeInsets? margin;
  
  /// Optional padding for the card content
  final EdgeInsets? padding;
  
  /// Whether to use high contrast mode for accessibility
  final bool highContrastMode;

  const OptimizedJobCard({
    super.key,
    required this.job,
    this.isFavorited = false,
    this.showSwipeActions = true,
    this.onTap,
    this.onFavorite,
    this.onBid,
    this.margin,
    this.padding,
    this.highContrastMode = false,
  });

  @override
  State<OptimizedJobCard> createState() => _OptimizedJobCardState();
}

class _OptimizedJobCardState extends State<OptimizedJobCard> 
    with SingleTickerProviderStateMixin {
  
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  
  bool _isSwipeVisible = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 200),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.95,
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

  EdgeInsets _getDefaultMargin() {
    return const EdgeInsets.symmetric(
      horizontal: AppTheme.spacingMd,
      vertical: AppTheme.spacingSm,
    );
  }

  Color get _highContrastBackground => 
      widget.highContrastMode ? AppTheme.surfaceElevated : AppTheme.surface;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => _animationController.forward(),
      onTapUp: (_) => _animationController.reverse(),
      onTapCancel: () => _animationController.reverse(),
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: _buildCard(),
          );
        },
      ),
    );
  }

  Widget _buildCard() {
    return JJCard(
      margin: widget.margin ?? _getDefaultMargin(),
      padding: widget.padding ?? const EdgeInsets.all(AppTheme.spacingMd),
      backgroundColor: widget.highContrastMode ? _highContrastBackground : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildHeader(),
          const SizedBox(height: AppTheme.spacingSm),
          _buildJobDetails(),
          const SizedBox(height: AppTheme.spacingSm),
          _buildLocationAndWage(),
          if (widget.showSwipeActions) ...[
            const SizedBox(height: AppTheme.spacingSm),
            _buildActionButtons(),
          ],
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Local number
        if (widget.job.local != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.primaryNavy,
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
            ),
            child: Text(
              'Local ${widget.job.local}',
              style: AppTheme.labelSmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        
        // Classification
        if (widget.job.classification != null)
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withOpacity(0.1),
              borderRadius: BorderRadius.circular(AppTheme.radiusSm),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: 1,
              ),
            ),
            child: Text(
              widget.job.classification!,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
      ],
    );
  }

  Widget _buildJobDetails() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Company name
        Text(
          widget.job.company,
          style: AppTheme.titleMedium.copyWith(
            fontWeight: FontWeight.bold,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        
        if (widget.job.jobTitle != null) ...[
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            widget.job.jobTitle!,
            style: AppTheme.bodyMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ],
    );
  }

  Widget _buildLocationAndWage() {
    return Row(
      children: [
        // Location
        Expanded(
          flex: 3,
          child: Row(
            children: [
              Icon(
                Icons.location_on_outlined,
                size: 16,
                color: AppTheme.textSecondary,
              ),
              const SizedBox(width: AppTheme.spacingXs),
              Flexible(
                child: Text(
                  widget.job.location,
                  style: AppTheme.bodySmall.copyWith(
                    color: AppTheme.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
        
        // Wage
        if (widget.job.wage != null)
          Expanded(
            flex: 2,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Icon(
                  Icons.attach_money,
                  size: 16,
                  color: AppTheme.successGreen,
                ),
                Text(
                  JobFormatting.formatWage(widget.job.wage!),
                  style: AppTheme.labelMedium.copyWith(
                    color: AppTheme.successGreen,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Favorite button
        Expanded(
          child: JJButton(
            text: widget.isFavorited ? 'Saved' : 'Save',
            icon: widget.isFavorited ? Icons.bookmark : Icons.bookmark_outline,
            variant: widget.isFavorited 
                ? JJButtonVariant.secondary 
                : JJButtonVariant.outline,
            size: JJButtonSize.small,
            onPressed: widget.onFavorite,
          ),
        ),
        
        const SizedBox(width: AppTheme.spacingSm),
        
        // Bid button
        Expanded(
          child: JJButton(
            text: 'Bid Now',
            icon: Icons.flash_on,
            variant: JJButtonVariant.primary,
            size: JJButtonSize.small,
            onPressed: widget.onBid,
          ),
        ),
      ],
    );
  }
}