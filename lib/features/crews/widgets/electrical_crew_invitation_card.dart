import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/features/crews/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/features/crews/models/crew.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import 'package:journeyman_jobs/widgets/crew_member_avatar.dart';

/// Electrical-themed crew invitation card with comprehensive interaction support.
///
/// This component provides:
/// - Electrical gradient styling with copper accents
/// - Animated invitation status indicators
/// - Interactive action buttons with haptic feedback
/// - Crew information display with member previews
/// - Invitation message with character limits
/// - Timestamp and expiration indicators
/// - Accessibility support with semantic labels
/// - Multiple visual variants for different contexts
class ElectricalCrewInvitationCard extends ConsumerStatefulWidget {
  /// Invitation data to display
  final CrewInvitation invitation;

  /// Crew data for the invitation
  final Crew crew;

  /// Inviter user data
  final UserModel inviter;

  /// Callback when invitation is accepted
  final VoidCallback? onAccept;

  /// Callback when invitation is declined
  final VoidCallback? onDecline;

  /// Callback when inviter profile is viewed
  final VoidCallback? onViewInviterProfile;

  /// Callback when crew details are viewed
  final VoidCallback? onViewCrewDetails;

  /// Visual variant of the card
  final InvitationCardVariant variant;

  /// Whether to show action buttons
  final bool showActions;

  /// Whether to show crew member preview
  final bool showMemberPreview;

  /// Whether the card is expanded to show more details
  final bool isExpanded;

  const ElectricalCrewInvitationCard({
    Key? key,
    required this.invitation,
    required this.crew,
    required this.inviter,
    this.onAccept,
    this.onDecline,
    this.onViewInviterProfile,
    this.onViewCrewDetails,
    this.variant = InvitationCardVariant.standard,
    this.showActions = true,
    this.showMemberPreview = true,
    this.isExpanded = false,
  }) : super(key: key);

  @override
  ConsumerState<ElectricalCrewInvitationCard> createState() =>
      _ElectricalCrewInvitationCardState();
}

class _ElectricalCrewInvitationCardState
    extends ConsumerState<ElectricalCrewInvitationCard>
    with TickerProviderStateMixin {
  late AnimationController _glowController;
  late AnimationController _pulseController;
  late AnimationController _slideController;
  late Animation<double> _glowAnimation;
  late Animation<double> _pulseAnimation;
  late Animation<Offset> _slideAnimation;

  bool _isAccepting = false;
  bool _isDeclining = false;

  @override
  void initState() {
    super.initState();
    _initializeAnimations();
  }

  @override
  void dispose() {
    _glowController.dispose();
    _pulseController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  void _initializeAnimations() {
    // Glow animation for new invitations
    _glowController = AnimationController(
      duration: AppTheme.durationElectricalGlow,
      vsync: this,
    );

    // Pulse animation for action buttons
    _pulseController = AnimationController(
      duration: AppTheme.durationElectricalSpark,
      vsync: this,
    );

    // Slide animation for card entrance
    _slideController = AnimationController(
      duration: AppTheme.durationElectricalSlide,
      vsync: this,
    );

    _glowAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _glowController,
      curve: Curves.easeInOut,
    ));

    _pulseAnimation = Tween<double>(
      begin: 1.0,
      end: 1.2,
    ).animate(CurvedAnimation(
      parent: _pulseController,
      curve: AppTheme.curveElectricalSpark,
    ));

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: AppTheme.curveElectricalSlide,
    ));

    // Start animations for pending invitations
    if (widget.invitation.status == InvitationStatus.pending) {
      _glowController.repeat(reverse: true);
      _slideController.forward();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: AnimatedBuilder(
        animation: Listenable.merge([_glowAnimation, _pulseAnimation]),
        builder: (context, child) {
          return Container(
            margin: _getMargin(),
            decoration: BoxDecoration(
              gradient: _getCardGradient(),
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
                onTap: () => widget.onViewCrewDetails?.call(),
                child: Stack(
                  children: [
                    // Circuit pattern background
                    Positioned.fill(
                      child: Opacity(
                        opacity: _getCircuitPatternOpacity(),
                        child: CustomPaint(
                          painter: CircuitPatternPainter(
                            density: ComponentDensity.medium,
                            traceColor: _getCircuitTraceColor(),
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
                          const SizedBox(height: AppTheme.spacingMd),
                          _buildInvitationMessage(),
                          if (widget.isExpanded) ...[
                            const SizedBox(height: AppTheme.spacingMd),
                            _buildDetailedInfo(),
                          ],
                          if (widget.showMemberPreview && !widget.isExpanded) ...[
                            const SizedBox(height: AppTheme.spacingMd),
                            _buildMemberPreview(),
                          ],
                          if (widget.showActions) ...[
                            const SizedBox(height: AppTheme.spacingLg),
                            _buildActionButtons(),
                          ],
                        ],
                      ),
                    ),

                    // Status overlay
                    Positioned.fill(
                      child: _buildStatusOverlay(),
                    ),

                    // Electrical glow effect for new invitations
                    if (_glowAnimation.value > 0.5)
                      Positioned.fill(
                        child: Container(
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                            border: Border.all(
                              color: _getGlowColor().withValues(
                                alpha: _glowAnimation.value * 0.4,
                              ),
                              width: 2,
                            ),
                          ),
                        ),
                      ),

                    // Priority indicator for urgent invitations
                    if (widget.invitation.priority == InvitationPriority.high)
                      Positioned(
                        top: 8,
                        left: 8,
                        child: _buildPriorityIndicator(),
                      ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  /// Builds the card header with crew and inviter info
  Widget _buildHeader() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Crew avatar
        GestureDetector(
          onTap: () => widget.onViewCrewDetails?.call(),
          child: Container(
            width: 56,
            height: 56,
            decoration: BoxDecoration(
              gradient: _getAvatarGradient(),
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.white.withValues(alpha: 0.3),
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: _getAvatarGlowColor().withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: Stack(
              children: [
                Center(
                  child: widget.crew.logoUrl != null
                      ? ClipRRect(
                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                          child: Image.network(
                            widget.crew.logoUrl!,
                            width: 48,
                            height: 48,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                _buildDefaultCrewAvatar(),
                          ),
                        )
                      : _buildDefaultCrewAvatar(),
                ),

                // Online/active indicator
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 16,
                    height: 16,
                    decoration: BoxDecoration(
                      color: _getActivityStatusColor(),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AppTheme.primaryNavy,
                        width: 2,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),

        const SizedBox(width: AppTheme.spacingMd),

        // Crew and inviter information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Crew name
              GestureDetector(
                onTap: () => widget.onViewCrewDetails?.call(),
                child: Text(
                  widget.crew.name,
                  style: AppTheme.titleLarge.copyWith(
                    color: AppTheme.white,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),

              const SizedBox(height: 4),

              // Inviter information
              Row(
                children: [
                  Text(
                    'Invited by ',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.7),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => widget.onViewInviterProfile?.call(),
                    child: Text(
                      widget.inviter.displayName,
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 4),

              // Invitation metadata
              Row(
                children: [
                  Icon(
                    Icons.people,
                    size: 14,
                    color: AppTheme.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '${widget.crew.memberCount} members',
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.6),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Icon(
                    Icons.schedule,
                    size: 14,
                    color: AppTheme.white.withValues(alpha: 0.6),
                  ),
                  const SizedBox(width: 4),
                  Text(
                    _formatInvitationTime(),
                    style: AppTheme.bodySmall.copyWith(
                      color: AppTheme.white.withValues(alpha: 0.6),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),

        // Invitation status indicator
        _buildStatusIndicator(),
      ],
    );
  }

  /// Builds the default crew avatar
  Widget _buildDefaultCrewAvatar() {
    return Text(
      widget.crew.name.isNotEmpty
          ? widget.crew.name[0].toUpperCase()
          : 'C',
      style: AppTheme.headlineMedium.copyWith(
        color: AppTheme.white,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  /// Builds the invitation message section
  Widget _buildInvitationMessage() {
    if (widget.invitation.message == null || widget.invitation.message!.isEmpty) {
      return Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          border: Border.all(
            color: AppTheme.white.withValues(alpha: 0.2),
            width: 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              Icons.mail_outline,
              color: AppTheme.accentCopper.withValues(alpha: 0.7),
              size: AppTheme.iconSm,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Expanded(
              child: Text(
                'No personal message included',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white.withValues(alpha: 0.6),
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.2),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.message,
                color: AppTheme.accentCopper,
                size: AppTheme.iconSm,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Personal Message',
                style: AppTheme.bodySmall.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            widget.invitation.message!,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.white,
              height: 1.4,
            ),
            maxLines: widget.isExpanded ? null : 3,
            overflow: widget.isExpanded ? null : TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  /// Builds detailed information section for expanded view
  Widget _buildDetailedInfo() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Crew description
          if (widget.crew.preferences.description?.isNotEmpty == true) ...[
            Text(
              'About this Crew',
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.accentCopper,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              widget.crew.preferences.description!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.white.withValues(alpha: 0.8),
                height: 1.4,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
          ],

          // Crew statistics
          Row(
            children: [
              Expanded(
                child: _buildStatItem(
                  'Members',
                  '${widget.crew.memberCount}',
                  Icons.people,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Activity',
                  'High',
                  Icons.bolt,
                ),
              ),
              Expanded(
                child: _buildStatItem(
                  'Privacy',
                  widget.crew.visibility.name.capitalize(),
                  _getPrivacyIcon(),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  /// Builds individual stat item for detailed view
  Widget _buildStatItem(String label, String value, IconData icon) {
    return Column(
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper.withValues(alpha: 0.7),
          size: AppTheme.iconMd,
        ),
        const SizedBox(height: AppTheme.spacingXs),
        Text(
          value,
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        Text(
          label,
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.white.withValues(alpha: 0.6),
          ),
        ),
      ],
    );
  }

  /// Builds member preview section
  Widget _buildMemberPreview() {
    return Row(
      children: [
        Text(
          'Crew Members',
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.white.withValues(alpha: 0.7),
            fontWeight: FontWeight.w500,
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        Expanded(
          child: SizedBox(
            height: 32,
            child: Stack(
              children: List.generate(
                widget.crew.memberIds.length.clamp(0, 4),
                (index) => Positioned(
                  left: index * 20.0,
                  child: CrewMemberAvatar(
                    userId: widget.crew.memberIds[index],
                    size: 32,
                    borderSize: 2,
                    borderColor: AppTheme.primaryNavy,
                  ),
                ),
              ),
            ),
          ),
        ),
        if (widget.crew.memberCount > 4) ...[
          const SizedBox(width: AppTheme.spacingSm),
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
              '+${widget.crew.memberCount - 4}',
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

  /// Builds action buttons for accepting/declining invitation
  Widget _buildActionButtons() {
    if (widget.invitation.status != InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return Row(
      children: [
        // Decline button
        Expanded(
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isDeclining ? _pulseAnimation.value : 1.0,
                child: _buildActionButton(
                  label: 'Decline',
                  icon: Icons.close,
                  onPressed: _isDeclining ? null : _handleDecline,
                  backgroundColor: AppTheme.errorRed,
                  isSecondary: true,
                ),
              );
            },
          ),
        ),

        const SizedBox(width: AppTheme.spacingMd),

        // Accept button
        Expanded(
          flex: 2,
          child: AnimatedBuilder(
            animation: _pulseAnimation,
            builder: (context, child) {
              return Transform.scale(
                scale: _isAccepting ? _pulseAnimation.value : 1.0,
                child: _buildActionButton(
                  label: 'Accept Invitation',
                  icon: Icons.check_circle,
                  onPressed: _isAccepting ? null : _handleAccept,
                  backgroundColor: AppTheme.successGreen,
                  isPrimary: true,
                ),
              );
            },
          ),
        ),
      ],
    );
  }

  /// Builds individual action button
  Widget _buildActionButton({
    required String label,
    required IconData icon,
    required VoidCallback? onPressed,
    required Color backgroundColor,
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: isPrimary
            ? LinearGradient(
                colors: [backgroundColor, backgroundColor.withValues(alpha: 0.8)],
              )
            : null,
        color: isSecondary ? Colors.transparent : backgroundColor,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isSecondary
            ? Border.all(
                color: backgroundColor.withValues(alpha: 0.5),
                width: AppTheme.borderWidthMedium,
              )
            : null,
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: backgroundColor.withValues(alpha: 0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ]
            : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: onPressed,
          child: Center(
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isAccepting || _isDeclining) ...[
                  SizedBox(
                    width: 16,
                    height: 16,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      valueColor: AlwaysStoppedAnimation<Color>(
                        isPrimary ? AppTheme.white : backgroundColor,
                      ),
                    ),
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                ] else ...[
                  Icon(
                    icon,
                    color: isPrimary ? AppTheme.white : backgroundColor,
                    size: AppTheme.iconSm,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                ],
                Text(
                  label,
                  style: AppTheme.buttonMedium.copyWith(
                    color: isPrimary ? AppTheme.white : backgroundColor,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  /// Builds status overlay for non-pending invitations
  Widget _buildStatusOverlay() {
    if (widget.invitation.status == InvitationStatus.pending) {
      return const SizedBox.shrink();
    }

    return Container(
      decoration: BoxDecoration(
        color: _getStatusOverlayColor().withValues(alpha: 0.9),
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              _getStatusIcon(),
              color: AppTheme.white,
              size: AppTheme.iconXxl,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              _getStatusText(),
              style: AppTheme.titleMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingXs),
            Text(
              _formatStatusTimestamp(),
              style: AppTheme.bodySmall.copyWith(
                color: AppTheme.white.withValues(alpha: 0.8),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// Builds status indicator in the header
  Widget _buildStatusIndicator() {
    Color statusColor;
    IconData statusIcon;

    switch (widget.invitation.status) {
      case InvitationStatus.pending:
        statusColor = AppTheme.warningYellow;
        statusIcon = Icons.pending;
        break;
      case InvitationStatus.accepted:
        statusColor = AppTheme.successGreen;
        statusIcon = Icons.check_circle;
        break;
      case InvitationStatus.declined:
        statusColor = AppTheme.errorRed;
        statusIcon = Icons.cancel;
        break;
      case InvitationStatus.expired:
        statusColor = AppTheme.textMuted;
        statusIcon = Icons.schedule;
        break;
    }

    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingXs),
      decoration: BoxDecoration(
        color: statusColor.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.5),
          width: 1,
        ),
      ),
      child: Icon(
        statusIcon,
        color: statusColor,
        size: AppTheme.iconSm,
      ),
    );
  }

  /// Builds priority indicator for high-priority invitations
  Widget _buildPriorityIndicator() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: 2,
      ),
      decoration: BoxDecoration(
        color: AppTheme.errorRed,
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        boxShadow: [
          BoxShadow(
            color: AppTheme.errorRed.withValues(alpha: 0.4),
            blurRadius: 6,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        'URGENT',
        style: AppTheme.bodySmall.copyWith(
          color: AppTheme.white,
          fontWeight: FontWeight.w700,
          fontSize: 10,
        ),
      ),
    );
  }

  // Action handlers

  Future<void> _handleAccept() async {
    HapticFeedback.mediumImpact();
    setState(() => _isAccepting = true);

    try {
      await widget.onAccept?.call();
      _pulseController.forward().then((_) {
        _pulseController.reverse();
      });
    } catch (e) {
      setState(() => _isAccepting = false);
    }
  }

  Future<void> _handleDecline() async {
    HapticFeedback.mediumImpact();
    setState(() => _isDeclining = true);

    try {
      await widget.onDecline?.call();
    } catch (e) {
      setState(() => _isDeclining = false);
    }
  }

  // Helper methods for styling and data

  EdgeInsets _getMargin() {
    switch (widget.variant) {
      case InvitationCardVariant.compact:
        return const EdgeInsets.symmetric(
          vertical: AppTheme.spacingXs,
          horizontal: AppTheme.spacingSm,
        );
      case InvitationCardVariant.featured:
        return const EdgeInsets.all(AppTheme.spacingMd);
      default:
        return const EdgeInsets.symmetric(
          vertical: AppTheme.spacingSm,
          horizontal: AppTheme.spacingSm,
        );
    }
  }

  LinearGradient _getCardGradient() {
    switch (widget.variant) {
      case InvitationCardVariant.featured:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy.withValues(alpha: 0.98),
            AppTheme.secondaryNavy,
          ],
        );
      default:
        return LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppTheme.primaryNavy,
            AppTheme.secondaryNavy,
          ],
        );
    }
  }

  Color _getBorderColor() {
    if (widget.invitation.status == InvitationStatus.pending) {
      return AppTheme.accentCopper.withValues(alpha: 0.5);
    }
    return AppTheme.borderCopper.withValues(alpha: 0.3);
  }

  double _getBorderWidth() {
    if (widget.invitation.status == InvitationStatus.pending) {
      return AppTheme.borderWidthMedium;
    }
    return AppTheme.borderWidthThin;
  }

  List<BoxShadow> _getBoxShadow() {
    if (widget.variant == InvitationCardVariant.featured) {
      return [
        AppTheme.shadowLg,
        BoxShadow(
          color: _getGlowColor().withValues(alpha: 0.2),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ];
    }
    return AppTheme.shadowCard;
  }

  double _getCircuitPatternOpacity() {
    return widget.variant == InvitationCardVariant.featured ? 0.12 : 0.08;
  }

  Color _getCircuitTraceColor() {
    return AppTheme.electricalCircuitTrace.withValues(alpha: 0.3);
  }

  EdgeInsets _getContentPadding() {
    switch (widget.variant) {
      case InvitationCardVariant.compact:
        return const EdgeInsets.all(AppTheme.spacingMd);
      default:
        return const EdgeInsets.all(AppTheme.spacingLg);
    }
  }

  LinearGradient _getAvatarGradient() {
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        AppTheme.accentCopper,
        AppTheme.secondaryCopper,
      ],
    );
  }

  Color _getAvatarGlowColor() {
    return AppTheme.electricalGlowSuccess;
  }

  Color _getActivityStatusColor() {
    final hoursSinceActivity = DateTime.now()
        .difference(widget.crew.lastActivityAt)
        .inHours;

    if (hoursSinceActivity < 1) return AppTheme.successGreen;
    if (hoursSinceActivity < 24) return AppTheme.warningYellow;
    return AppTheme.textMuted;
  }

  Color _getGlowColor() {
    if (widget.invitation.priority == InvitationPriority.high) {
      return AppTheme.errorRed;
    }
    return AppTheme.electricalGlowInfo;
  }

  Color _getStatusOverlayColor() {
    switch (widget.invitation.status) {
      case InvitationStatus.accepted:
        return AppTheme.successGreen;
      case InvitationStatus.declined:
        return AppTheme.errorRed;
      case InvitationStatus.expired:
        return AppTheme.textMuted;
      default:
        return AppTheme.primaryNavy;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.invitation.status) {
      case InvitationStatus.accepted:
        return Icons.check_circle;
      case InvitationStatus.declined:
        return Icons.cancel;
      case InvitationStatus.expired:
        return Icons.schedule;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText() {
    switch (widget.invitation.status) {
      case InvitationStatus.accepted:
        return 'Invitation Accepted';
      case InvitationStatus.declined:
        return 'Invitation Declined';
      case InvitationStatus.expired:
        return 'Invitation Expired';
      default:
        return 'Pending';
    }
  }

  IconData _getPrivacyIcon() {
    switch (widget.crew.visibility) {
      case CrewVisibility.public:
        return Icons.public;
      case CrewVisibility.private:
        return Icons.lock;
      case CrewVisibility.inviteOnly:
        return Icons.mail;
    }
  }

  String _formatInvitationTime() {
    final now = DateTime.now();
    final difference = now.difference(widget.invitation.createdAt);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';
    if (difference.inDays < 7) return '${difference.inDays}d ago';

    return '${widget.invitation.createdAt.day}/${widget.invitation.createdAt.month}';
  }

  String _formatStatusTimestamp() {
    if (widget.invitation.respondedAt == null) return '';

    final responseTime = widget.invitation.respondedAt!.toDate();
    final now = DateTime.now();
    final difference = now.difference(responseTime);

    if (difference.inMinutes < 1) return 'Just now';
    if (difference.inHours < 1) return '${difference.inMinutes}m ago';
    if (difference.inDays < 1) return '${difference.inHours}h ago';

    return 'on ${responseTime.day}/${responseTime.month}/${responseTime.year}';
  }
}

/// Enum defining invitation card display variants
enum InvitationCardVariant {
  /// Standard invitation card with full features
  standard,

  /// Compact version for tight spaces
  compact,

  /// Featured version with enhanced styling and animations
  featured,
}

/// Extension for capitalizing enum values
extension StringExtension on String {
  String capitalize() {
    if (isEmpty) return this;
    return '${this[0].toUpperCase()}${substring(1).toLowerCase()}';
  }
}