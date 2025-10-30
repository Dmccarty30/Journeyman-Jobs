import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import 'package:journeyman_jobs/widgets/crew_member_avatar.dart';

/// Card widget displaying crew information with electrical theme integration.
///
/// This component provides:
/// - Consistent electrical visual theming with circuit patterns
/// - Interactive states with electrical glow effects
/// - Accessibility support with semantic labels
/// - Multiple display variants for different contexts
/// - Member preview and activity indicators
class CrewCard extends ConsumerWidget {
  /// Crew data to display
  final Crew crew;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long-pressed
  final VoidCallback? onLongPress;

  /// Whether to display member avatars
  final bool showMemberAvatars;

  /// Whether to show online status indicator
  final bool showOnlineStatus;

  /// Selection state for multi-select operations
  final bool isSelected;

  /// Visual variant of the card
  final CrewCardVariant variant;

  /// Maximum number of member avatars to display
  final int maxMemberAvatars;

  const CrewCard({
    Key? key,
    required this.crew,
    this.onTap,
    this.onLongPress,
    this.showMemberAvatars = true,
    this.showOnlineStatus = true,
    this.isSelected = false,
    this.variant = CrewCardVariant.standard,
    this.maxMemberAvatars = 3,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      margin: _getMargin(),
      decoration: BoxDecoration(
        color: _getBackgroundColor(),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _getBorderColor(),
          width: _getBorderWidth(),
        ),
        boxShadow: _getBoxShadow(),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusLg),
          onTap: onTap,
          onLongPress: onLongPress,
          child: Stack(
            children: [
              // Circuit pattern background
              Positioned.fill(
                child: Opacity(
                  opacity: _getCircuitPatternOpacity(),
                  child: CustomPaint(
                    painter: CircuitPatternPainter(
                      density: ComponentDensity.medium,
                      traceColor: AppTheme.electricalCircuitTrace,
                      backgroundColor: Colors.transparent,
                    ),
                  ),
                ),
              ),

              // Main content
              Padding(
                padding: _getContentPadding(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildHeader(),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildMainContent(),
                    if (showMemberAvatars) ...[
                      const SizedBox(height: AppTheme.spacingSm),
                      _buildMemberAvatars(),
                    ],
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildFooter(),
                  ],
                ),
              ),

              // Selection indicator
              if (isSelected) _buildSelectionIndicator(),

              // Variant-specific overlays
              if (variant == CrewCardVariant.featured) _buildFeaturedOverlay(),
            ],
          ),
        ),
      ),
    );
  }

  /// Builds the crew header with avatar and basic info
  Widget _buildHeader() {
    return Row(
      children: [
        // Crew avatar
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            gradient: AppTheme.electricalGradient,
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.white.withValues(alpha: 0.2),
              width: 2,
            ),
            boxShadow: [
              BoxShadow(
                color: AppTheme.electricalGlowInfo.withValues(alpha: 0.2),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Stack(
            children: [
              Center(
                child: crew.logoUrl != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                        child: Image.network(
                          crew.logoUrl!,
                          width: 40,
                          height: 40,
                          fit: BoxFit.cover,
                          errorBuilder: (context, error, stackTrace) =>
                              _buildDefaultAvatar(),
                        ),
                      )
                    : _buildDefaultAvatar(),
              ),

              // Featured badge
              if (variant == CrewCardVariant.featured)
                Positioned(
                  top: -6,
                  right: -6,
                  child: Container(
                    width: 20,
                    height: 20,
                    decoration: BoxDecoration(
                      color: AppTheme.warningYellow,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryNavy,
                        width: 2,
                      ),
                    ),
                    child: const Icon(
                      Icons.star,
                      color: AppTheme.primaryNavy,
                      size: 12,
                    ),
                  ),
                ),
            ],
          ),
        ),

        const SizedBox(width: AppTheme.spacingMd),

        // Crew name and status
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                crew.name,
                style: AppTheme.titleLarge.copyWith(
                  color: _getTextColor(),
                  fontWeight: FontWeight.w700,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: _getSecondaryTextColor(),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${crew.memberCount} members',
                    style: AppTheme.bodySmall.copyWith(
                      color: _getSecondaryTextColor(),
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Online status indicator
        if (showOnlineStatus)
          Container(
            width: 12,
            height: 12,
            decoration: BoxDecoration(
              color: _getActivityStatusColor(),
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: _getActivityStatusColor().withValues(alpha: 0.3),
                  blurRadius: 4,
                ),
              ],
            ),
          ),
      ],
    );
  }

  /// Builds the default avatar with crew initials
  Widget _buildDefaultAvatar() {
    return Text(
      crew.name.isNotEmpty
          ? crew.name[0].toUpperCase()
          : 'C',
      style: AppTheme.titleLarge.copyWith(
        color: AppTheme.white,
        fontWeight: FontWeight.bold,
        fontSize: 20,
      ),
    );
  }

  /// Builds the main content area
  Widget _buildMainContent() {
    return Row(
      children: [
        // Location indicator
        if (crew.location != null) ...[
          Icon(
            Icons.location_on,
            size: 16,
            color: _getSecondaryTextColor(),
          ),
          const SizedBox(width: 4),
          Expanded(
            child: Text(
              crew.location!.city ?? 'Unknown Location',
              style: AppTheme.bodySmall.copyWith(
                color: _getSecondaryTextColor(),
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],

        // Spacer
        if (crew.location != null) const SizedBox(width: AppTheme.spacingMd),

        // Activity indicator
        Icon(
          Icons.bolt,
          size: 16,
          color: AppTheme.accentCopper.withValues(alpha: 0.7),
        ),
        const SizedBox(width: 4),
        Text(
          _formatLastActivity(),
          style: AppTheme.bodySmall.copyWith(
            color: _getSecondaryTextColor(),
          ),
        ),
      ],
    );
  }

  /// Builds member avatars preview
  Widget _buildMemberAvatars() {
    return Row(
      children: [
        // Avatar stack
        Expanded(
          child: SizedBox(
            height: 32,
            child: Stack(
              children: List.generate(
                _getAvatarCount(),
                (index) => Positioned(
                  left: index * 20.0,
                  child: CrewMemberAvatar(
                    userId: crew.memberIds[index],
                    size: 32,
                    borderSize: 2,
                    borderColor: _getBackgroundColor(),
                  ),
                ),
              ),
            ),
          ),
        ),

        // Member count indicator
        if (crew.memberCount > maxMemberAvatars) ...[
          const SizedBox(width: 8),
          Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppTheme.spacingSm,
              vertical: 2,
            ),
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(AppTheme.radiusRound),
            ),
            child: Text(
              '+${crew.memberCount - maxMemberAvatars}',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w600,
                fontSize: 10,
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Builds the footer with additional information
  Widget _buildFooter() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        // Crew visibility indicator
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppTheme.spacingSm,
            vertical: 2,
          ),
          decoration: BoxDecoration(
            color: _getVisibilityColor().withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                _getVisibilityIcon(),
                size: 12,
                color: _getVisibilityColor(),
              ),
              const SizedBox(width: 4),
              Text(
                crew.visibility.name.capitalize(),
                style: AppTheme.bodySmall.copyWith(
                  color: _getVisibilityColor(),
                  fontWeight: FontWeight.w500,
                  fontSize: 10,
                ),
              ),
            ],
          ),
        ),

        // Electrical circuit indicator
        Row(
          children: [
            Icon(
              Icons.electric_bolt,
              size: 12,
              color: AppTheme.electricalCircuitTrace.withValues(alpha: 0.6),
            ),
            const SizedBox(width: 4),
            Text(
              'Active',
              style: AppTheme.bodySmall.copyWith(
                color: _getSecondaryTextColor(),
                fontSize: 10,
              ),
            ),
          ],
        ),
      ],
    );
  }

  /// Builds the selection indicator
  Widget _buildSelectionIndicator() {
    return Positioned(
      top: 8,
      right: 8,
      child: Container(
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          color: AppTheme.accentCopper,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: AppTheme.electricalGlowSuccess.withValues(alpha: 0.4),
              blurRadius: 8,
              spreadRadius: 1,
            ),
          ],
        ),
        child: const Icon(
          Icons.check,
          color: AppTheme.white,
          size: 16,
        ),
      ),
    );
  }

  /// Builds the featured overlay for highlighted cards
  Widget _buildFeaturedOverlay() {
    return Positioned(
      top: 0,
      left: 0,
      right: 0,
      height: 3,
      decoration: BoxDecoration(
        gradient: AppTheme.electricalGradient,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(AppTheme.radiusLg),
          topRight: Radius.circular(AppTheme.radiusLg),
        ),
      ),
    );
  }

  // Helper methods for styling and data

  EdgeInsets _getMargin() {
    switch (variant) {
      case CrewCardVariant.compact:
        return const EdgeInsets.symmetric(vertical: 2, horizontal: AppTheme.spacingSm);
      case CrewCardVariant.featured:
        return const EdgeInsets.all(AppTheme.spacingMd);
      default:
        return const EdgeInsets.symmetric(vertical: 4, horizontal: AppTheme.spacingSm);
    }
  }

  Color _getBackgroundColor() {
    switch (variant) {
      case CrewCardVariant.featured:
        return AppTheme.primaryNavy.withValues(alpha: 0.95);
      default:
        return AppTheme.primaryNavy;
    }
  }

  Color _getBorderColor() {
    if (isSelected) return AppTheme.accentCopper;
    if (variant == CrewCardVariant.featured) return AppTheme.accentCopper;
    return AppTheme.borderCopper;
  }

  double _getBorderWidth() {
    if (isSelected) return AppTheme.borderWidthThick;
    if (variant == CrewCardVariant.featured) return AppTheme.borderWidthMedium;
    return AppTheme.borderWidthMedium;
  }

  List<BoxShadow> _getBoxShadow() {
    if (isSelected) return [AppTheme.shadowElectricalSuccess];
    if (variant == CrewCardVariant.featured) {
      return [
        AppTheme.shadowLg,
        BoxShadow(
          color: AppTheme.electricalGlowInfo.withValues(alpha: 0.2),
          blurRadius: 20,
          spreadRadius: 1,
        ),
      ];
    }
    return AppTheme.shadowCard;
  }

  double _getCircuitPatternOpacity() {
    switch (variant) {
      case CrewCardVariant.featured:
        return 0.15;
      default:
        return 0.08;
    }
  }

  EdgeInsets _getContentPadding() {
    switch (variant) {
      case CrewCardVariant.compact:
        return const EdgeInsets.all(AppTheme.spacingSm);
      default:
        return const EdgeInsets.all(AppTheme.spacingMd);
    }
  }

  Color _getTextColor() {
    return variant == CrewCardVariant.featured
        ? AppTheme.white
        : AppTheme.white;
  }

  Color _getSecondaryTextColor() {
    return variant == CrewCardVariant.featured
        ? AppTheme.white.withValues(alpha: 0.8)
        : AppTheme.textLight;
  }

  Color _getActivityStatusColor() {
    final now = DateTime.now();
    final hoursSinceActivity = now.difference(crew.lastActivityAt).inHours;

    if (hoursSinceActivity < 1) return AppTheme.successGreen;
    if (hoursSinceActivity < 24) return AppTheme.warningYellow;
    return AppTheme.textMuted;
  }

  String _formatLastActivity() {
    final now = DateTime.now();
    final difference = now.difference(crew.lastActivityAt);

    if (difference.inMinutes < 1) return 'Active now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';
    return '${crew.lastActivityAt.day}/${crew.lastActivityAt.month}';
  }

  int _getAvatarCount() {
    return crew.memberIds.length.clamp(0, maxMemberAvatars);
  }

  Color _getVisibilityColor() {
    switch (crew.visibility) {
      case CrewVisibility.public:
        return AppTheme.successGreen;
      case CrewVisibility.private:
        return AppTheme.warningYellow;
      case CrewVisibility.inviteOnly:
        return AppTheme.infoBlue;
    }
  }

  IconData _getVisibilityIcon() {
    switch (crew.visibility) {
      case CrewVisibility.public:
        return Icons.public;
      case CrewVisibility.private:
        return Icons.lock;
      case CrewVisibility.inviteOnly:
        return Icons.mail;
    }
  }
}

/// Enum defining visual variants for crew cards
enum CrewCardVariant {
  /// Standard crew card with full information
  standard,

  /// Compact version for tight spaces
  compact,

  /// Featured/Highlighted version with enhanced styling
  featured,
}

/// Extension for capitalizing enum values
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}