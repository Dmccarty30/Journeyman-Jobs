import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/electrical_components.dart';

/// Feature availability card showing ready vs loading features
///
/// This widget displays a collection of features with their current availability
/// status, providing users with clear information about what they can access
/// and what's still loading. Features include:
///
/// - Visual status indicators (available, loading, coming soon)
/// - Electrical-themed icons and animations
/// - Feature descriptions and access information
/// - Interactive cards with tap actions
/// - Accessibility support for screen readers
/// - Responsive grid layout
/// - Progress indicators for loading features
class FeatureAvailabilityCard extends StatefulWidget {
  /// List of features to display
  final List<String> features;

  /// Status of all features in this card
  final FeatureStatus status;

  /// Callback when a feature is tapped
  final Function(String)? onFeatureTap;

  /// Card title override
  final String? title;

  /// Card description
  final String? description;

  /// Whether to show feature descriptions
  final bool showDescriptions;

  /// Grid layout options
  final FeatureCardLayout layout;

  /// Custom styling
  final FeatureCardStyle? style;

  const FeatureAvailabilityCard({
    super.key,
    required this.features,
    required this.status,
    this.onFeatureTap,
    this.title,
    this.description,
    this.showDescriptions = true,
    this.layout = FeatureCardLayout.grid,
    this.style,
  });

  @override
  State<FeatureAvailabilityCard> createState() => _FeatureAvailabilityCardState();
}

class _FeatureAvailabilityCardState extends State<FeatureAvailabilityCard>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    _pulseController = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _slideController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    _pulseAnimation = Tween<double>(
      begin: 0.9,
      end: 1.1,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: Curves.easeInOut,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    if (widget.status == FeatureStatus.loading) {
      _pulseController.repeat(reverse: true);
    }

    _slideController.forward();
  }

  @override
  void didUpdateWidget(FeatureAvailabilityCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (oldWidget.status != widget.status) {
      if (widget.status == FeatureStatus.loading) {
        _pulseController.repeat(reverse: true);
      } else {
        _pulseController.stop();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = widget.style ?? FeatureCardStyle.defaultStyle;

    return Container(
      decoration: BoxDecoration(
        color: _getCardBackgroundColor(),
        borderRadius: BorderRadius.circular(style.borderRadius),
        border: Border.all(
          color: _getBorderColor(),
          width: style.borderWidth,
        ),
        boxShadow: _getBoxShadow(),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header section
          _buildHeader(style),

          // Features section
          _buildFeatures(style),
        ],
      ),
    ).animate(controller: _slideController).slideY().fadeIn();
  }

  Widget _buildHeader(FeatureCardStyle style) {
    return Container(
      padding: style.headerPadding,
      decoration: BoxDecoration(
        color: _getHeaderBackgroundColor(),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(style.borderRadius),
          topRight: Radius.circular(style.borderRadius),
        ),
        border: Border(
          bottom: BorderSide(
            color: _getBorderColor().withValues(alpha: 0.3),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // Status icon
          _buildStatusIcon(),

          const SizedBox(width: AppTheme.spacingMd),

          // Title and description
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.title ?? _getDefaultTitle(),
                  style: style.titleStyle.copyWith(
                    color: _getTextColor(),
                  ),
                ),
                if (widget.description != null) ...[
                  const SizedBox(height: AppTheme.spacingXs),
                  Text(
                    widget.description!,
                    style: style.descriptionStyle.copyWith(
                      color: _getTextColor().withValues(alpha: 0.8),
                    ),
                  ),
                ],
              ],
            ),
          ),

          // Feature count
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: AppTheme.spacingXs,
            ),
            decoration: BoxDecoration(
              color: _getStatusColor().withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Text(
              '${widget.features.length}',
              style: style.countStyle.copyWith(
                color: _getStatusColor(),
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusIcon() {
    final iconSize = 24.0;
    final iconColor = _getStatusColor();

    if (widget.status == FeatureStatus.loading) {
      return AnimatedBuilder(
        animation: _pulseAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _pulseAnimation.value,
            child: Container(
              width: iconSize + 8,
              height: iconSize + 8,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    iconColor,
                    iconColor.withValues(alpha: 0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(iconSize / 2),
              ),
              child: Icon(
                Icons.electrical_services,
                color: AppTheme.white,
                size: iconSize,
              ),
            ),
          );
        },
      );
    } else if (widget.status == FeatureStatus.available) {
      return Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: iconColor,
          borderRadius: BorderRadius.circular(iconSize / 2),
        ),
        child: Icon(
          Icons.check_circle,
          color: AppTheme.white,
          size: iconSize,
        ),
      );
    } else {
      return Container(
        width: iconSize + 8,
        height: iconSize + 8,
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.3),
          borderRadius: BorderRadius.circular(iconSize / 2),
          border: Border.all(
            color: iconColor,
            width: 2,
          ),
        ),
        child: Icon(
          Icons.schedule,
          color: iconColor,
          size: iconSize,
        ),
      );
    }
  }

  Widget _buildFeatures(FeatureCardStyle style) {
    if (widget.features.isEmpty) {
      return Padding(
        padding: style.contentPadding,
        child: Center(
          child: Text(
            'No features available',
            style: style.emptyTextStyle.copyWith(
              color: _getTextColor().withValues(alpha: 0.6),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: style.contentPadding,
      child: widget.layout == FeatureCardLayout.grid
          ? _buildGridFeatures(style)
          : _buildListFeatures(style),
    );
  }

  Widget _buildGridFeatures(FeatureCardStyle style) {
    final crossAxisCount = widget.features.length <= 2
        ? 1
        : widget.features.length <= 4
            ? 2
            : 3;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: crossAxisCount,
        crossAxisSpacing: AppTheme.spacingMd,
        mainAxisSpacing: AppTheme.spacingMd,
        childAspectRatio: 2.5,
      ),
      itemCount: widget.features.length,
      itemBuilder: (context, index) {
        final feature = widget.features[index];
        return _buildFeatureItem(feature, style, isGrid: true);
      },
    );
  }

  Widget _buildListFeatures(FeatureCardStyle style) {
    return Column(
      children: widget.features.map((feature) {
        return Padding(
          padding: EdgeInsets.only(bottom: AppTheme.spacingMd),
          child: _buildFeatureItem(feature, style, isGrid: false),
        );
      }).toList(),
    );
  }

  Widget _buildFeatureItem(String feature, FeatureCardStyle style, {required bool isGrid}) {
    final featureInfo = _getFeatureInfo(feature);
    final canTap = widget.onFeatureTap != null && widget.status == FeatureStatus.available;

    return Semantics(
      button: canTap,
      label: _getFeatureSemanticLabel(feature),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: canTap ? () => widget.onFeatureTap!(feature) : null,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          child: Container(
            padding: isGrid
                ? const EdgeInsets.all(AppTheme.spacingMd)
                : const EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: _getFeatureBackgroundColor(),
              borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              border: Border.all(
                color: _getFeatureBorderColor(),
                width: 1,
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Feature name with icon
                Row(
                  children: [
                    Icon(
                      featureInfo.icon,
                      size: isGrid ? AppTheme.iconSm : AppTheme.iconMd,
                      color: _getFeatureIconColor(),
                    ),
                    const SizedBox(width: AppTheme.spacingSm),
                    Expanded(
                      child: Text(
                        feature,
                        style: (isGrid ? style.gridFeatureStyle : style.listFeatureStyle)
                            .copyWith(color: _getTextColor()),
                      ),
                    ),
                    if (widget.status == FeatureStatus.loading) ...[
                      SizedBox(
                        width: isGrid ? 12 : 16,
                        height: isGrid ? 12 : 16,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          valueColor: AlwaysStoppedAnimation<Color>(_getStatusColor()),
                        ),
                      ),
                    ] else if (widget.status == FeatureStatus.available) ...[
                      Icon(
                        Icons.check_circle,
                        size: isGrid ? AppTheme.iconXs : AppTheme.iconSm,
                        color: AppTheme.successGreen,
                      ),
                    ],
                  ],
                ),

                // Feature description (if not grid and descriptions are enabled)
                if (!isGrid && widget.showDescriptions && featureInfo.description != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    featureInfo.description!,
                    style: style.featureDescriptionStyle.copyWith(
                      color: _getTextColor().withValues(alpha: 0.7),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    ).animate().fadeIn(delay: (widget.features.indexOf(feature) * 100).ms).slideX();
  }

  Color _getCardBackgroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen.withValues(alpha: 0.05);
    } else if (widget.status == FeatureStatus.loading) {
      return AppTheme.accentCopper.withValues(alpha: 0.05);
    } else {
      return isDark ? AppTheme.darkSurface : AppTheme.white;
    }
  }

  Color _getHeaderBackgroundColor() {
    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen.withValues(alpha: 0.1);
    } else if (widget.status == FeatureStatus.loading) {
      return AppTheme.accentCopper.withValues(alpha: 0.1);
    } else {
      return Colors.transparent;
    }
  }

  Color _getBorderColor() {
    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen;
    } else if (widget.status == FeatureStatus.loading) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.lightGray;
    }
  }

  Color _getStatusColor() {
    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen;
    } else if (widget.status == FeatureStatus.loading) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.textLight;
    }
  }

  Color _getTextColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return isDark ? AppTheme.white : AppTheme.textPrimary;
  }

  Color _getFeatureBackgroundColor() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen.withValues(alpha: 0.1);
    } else {
      return isDark
          ? AppTheme.white.withValues(alpha: 0.05)
          : AppTheme.white;
    }
  }

  Color _getFeatureBorderColor() {
    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen.withValues(alpha: 0.3);
    } else {
      return AppTheme.lightGray.withValues(alpha: 0.3);
    }
  }

  Color _getFeatureIconColor() {
    if (widget.status == FeatureStatus.available) {
      return AppTheme.successGreen;
    } else if (widget.status == FeatureStatus.loading) {
      return AppTheme.accentCopper;
    } else {
      return AppTheme.textLight;
    }
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.status == FeatureStatus.loading) {
      return [
        BoxShadow(
          color: AppTheme.accentCopper.withValues(alpha: 0.2),
          blurRadius: 12,
          spreadRadius: 2,
        ),
      ];
    } else if (widget.status == FeatureStatus.available) {
      return [
        BoxShadow(
          color: AppTheme.successGreen.withValues(alpha: 0.2),
          blurRadius: 8,
          spreadRadius: 1,
        ),
      ];
    } else {
      return [AppTheme.shadowSm];
    }
  }

  String _getDefaultTitle() {
    switch (widget.status) {
      case FeatureStatus.available:
        return 'Available Features';
      case FeatureStatus.loading:
        return 'Loading Features';
      case FeatureStatus.comingSoon:
        return 'Coming Soon';
    }
  }

  FeatureInfo _getFeatureInfo(String feature) {
    return predefinedFeatures[feature] ?? FeatureInfo(
      name: feature,
      icon: Icons.extension,
      description: 'Access this feature when initialization completes',
    );
  }

  String _getFeatureSemanticLabel(String feature) {
    final featureInfo = _getFeatureInfo(feature);
    final status = widget.status.name;
    return '$feature feature: $status. ${featureInfo.description ?? 'No description available'}';
  }
}

/// Feature status enumeration
enum FeatureStatus {
  /// Feature is ready to use
  available,

  /// Feature is currently loading
  loading,

  /// Feature will be available in the future
  comingSoon,
}

/// Layout options for feature cards
enum FeatureCardLayout {
  /// Grid layout for multiple features
  grid,

  /// List layout for detailed feature information
  list,
}

/// Feature information model
@immutable
class FeatureInfo {
  final String name;
  final IconData icon;
  final String? description;

  const FeatureInfo({
    required this.name,
    required this.icon,
    this.description,
  });
}

/// Predefined feature information
const Map<String, FeatureInfo> predefinedFeatures = {
  'Profile': FeatureInfo(
    name: 'Profile',
    icon: Icons.person,
    description: 'View and edit your professional profile and credentials',
  ),
  'Basic Jobs': FeatureInfo(
    name: 'Job Search',
    icon: Icons.work,
    description: 'Browse available job opportunities in your area',
  ),
  'Local Directory': FeatureInfo(
    name: 'Union Directory',
    icon: Icons.business,
    description: 'Access IBEW local union contact information',
  ),
  'Advanced Job Search': FeatureInfo(
    name: 'Advanced Search',
    icon: Icons.search,
    description: 'Search jobs with advanced filters and criteria',
  ),
  'Job Matching': FeatureInfo(
    name: 'Job Matching',
    icon: Icons.compare_arrows,
    description: 'Get personalized job recommendations based on your profile',
  ),
  'Crew Basic': FeatureInfo(
    name: 'Crew Features',
    icon: Icons.group,
    description: 'Connect with your crew and manage team activities',
  ),
  'Crew Management': FeatureInfo(
    name: 'Full Crew Management',
    icon: Icons.admin_panel_settings,
    description: 'Complete crew management tools and analytics',
  ),
  'Weather Services': FeatureInfo(
    name: 'Weather & Alerts',
    icon: Icons.cloud,
    description: 'Real-time weather updates and severe weather alerts',
  ),
  'Offline Sync': FeatureInfo(
    name: 'Offline Mode',
    icon: Icons.sync,
    description: 'Access your data offline with automatic synchronization',
  ),
  'Notifications': FeatureInfo(
    name: 'Push Notifications',
    icon: Icons.notifications,
    description: 'Stay updated with real-time job alerts and notifications',
  ),
};

/// Styling options for feature availability cards
@immutable
class FeatureCardStyle {
  final TextStyle titleStyle;
  final TextStyle descriptionStyle;
  final TextStyle countStyle;
  final TextStyle emptyTextStyle;
  final TextStyle listFeatureStyle;
  final TextStyle gridFeatureStyle;
  final TextStyle featureDescriptionStyle;
  final EdgeInsets headerPadding;
  final EdgeInsets contentPadding;
  final double borderRadius;
  final double borderWidth;

  const FeatureCardStyle({
    required this.titleStyle,
    required this.descriptionStyle,
    required this.countStyle,
    required this.emptyTextStyle,
    required this.listFeatureStyle,
    required this.gridFeatureStyle,
    required this.featureDescriptionStyle,
    required this.headerPadding,
    required this.contentPadding,
    required this.borderRadius,
    required this.borderWidth,
  });

  factory FeatureCardStyle.defaultStyle => const FeatureCardStyle(
    titleStyle: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),
    descriptionStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    countStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.bold,
    ),
    emptyTextStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w400,
    ),
    listFeatureStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    gridFeatureStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    featureDescriptionStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    headerPadding: EdgeInsets.all(16),
    contentPadding: EdgeInsets.all(16),
    borderRadius: 12.0,
    borderWidth: 1.5,
  );

  factory FeatureCardStyle.compact => const FeatureCardStyle(
    titleStyle: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      height: 1.2,
    ),
    descriptionStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
      height: 1.4,
    ),
    countStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.bold,
    ),
    emptyTextStyle: TextStyle(
      fontSize: 12,
      fontWeight: FontWeight.w400,
    ),
    listFeatureStyle: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    gridFeatureStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w600,
      height: 1.2,
    ),
    featureDescriptionStyle: TextStyle(
      fontSize: 11,
      fontWeight: FontWeight.w400,
      height: 1.3,
    ),
    headerPadding: EdgeInsets.all(12),
    contentPadding: EdgeInsets.all(12),
    borderRadius: 8.0,
    borderWidth: 1.0,
  );
}