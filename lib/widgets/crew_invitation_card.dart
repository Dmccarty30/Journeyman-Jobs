import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/models/crew_invitation_model.dart';
import 'package:journeyman_jobs/widgets/electrical_components.dart';

/// Card component for displaying crew invitations with electrical theme
///
/// This widget shows crew invitation details including:
/// - Crew name and inviter information
/// - Invitation status and timestamp
/// - Accept/Decline buttons for pending invitations
/// - Electrical themed styling with circuit patterns
class CrewInvitationCard extends StatefulWidget {
  final CrewInvitation invitation;
  final VoidCallback? onAccept;
  final VoidCallback? onDecline;
  final VoidCallback? onCancel;
  final bool showActions;
  final bool isLoading;

  const CrewInvitationCard({
    super.key,
    required this.invitation,
    this.onAccept,
    this.onDecline,
    this.onCancel,
    this.showActions = true,
    this.isLoading = false,
  });

  @override
  State<CrewInvitationCard> createState() => _CrewInvitationCardState();
}

class _CrewInvitationCardState extends State<CrewInvitationCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: AppTheme.durationElectricalSlide,
      vsync: this,
    );

    _slideAnimation = Tween<double>(
      begin: 50.0,
      end: 0.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: AppTheme.curveElectricalSlide,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
    ));

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return Transform.translate(
          offset: Offset(0, _slideAnimation.value),
          child: Opacity(
            opacity: _fadeAnimation.value,
            child: child,
          ),
        );
      },
      child: _buildCard(),
    );
  }

  Widget _buildCard() {
    return Container(
      margin: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingMd,
        vertical: AppTheme.spacingSm,
      ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        border: Border.all(
          color: _getBorderColor(),
          width: AppTheme.borderWidthCopper,
        ),
        boxShadow: [
          BoxShadow(
            color: _getShadowColor().withValues(alpha: 0.2),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
        gradient: _getCardGradient(),
      ),
      child: Stack(
        children: [
          // Circuit pattern background
          Positioned.fill(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              child: CircuitPatternBackground(
                opacity: 0.05,
                color: AppTheme.electricalCircuitTrace,
              ),
            ),
          ),

          // Card content
          Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildHeader(),
                const SizedBox(height: AppTheme.spacingSm),
                _buildMessage(),
                if (widget.invitation.message != null) ...[
                  const SizedBox(height: AppTheme.spacingSm),
                  _buildInviterMessage(),
                ],
                const SizedBox(height: AppTheme.spacingMd),
                _buildFooter(),
                if (widget.showActions && _shouldShowActions()) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildActions(),
                ],
              ],
            ),
          ),

          // Status badge
          Positioned(
            top: AppTheme.spacingMd,
            right: AppTheme.spacingMd,
            child: _buildStatusBadge(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        // Crew icon with electrical effect
        Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: AppTheme.electricalGradient,
            boxShadow: [
              BoxShadow(
                color: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
                blurRadius: 8,
              ),
            ],
          ),
          child: Icon(
            _getCrewIcon(),
            color: AppTheme.white,
            size: AppTheme.iconLg,
          ),
        ),

        const SizedBox(width: AppTheme.spacingMd),

        // Crew information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                widget.invitation.crewName,
                style: AppTheme.titleLarge.copyWith(
                  color: AppTheme.textPrimary,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Invited by ${widget.invitation.inviterName}',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.primaryNavy.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.primaryNavy.withValues(alpha: 0.1),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Icon(
            Icons.group_add,
            size: AppTheme.iconSm,
            color: AppTheme.primaryNavy,
          ),
          const SizedBox(width: AppTheme.spacingSm),
          Expanded(
            child: Text(
              _getStatusMessage(),
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInviterMessage() {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingSm),
      decoration: BoxDecoration(
        color: AppTheme.accentCopper.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: Border.all(
          color: AppTheme.accentCopper.withValues(alpha: 0.1),
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
                size: AppTheme.iconSm,
                color: AppTheme.accentCopper,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                'Message from ${widget.invitation.inviterName}',
                style: AppTheme.labelMedium.copyWith(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            widget.invitation.message!,
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return Row(
      children: [
        // Timestamp
        Icon(
          Icons.access_time,
          size: AppTheme.iconSm,
          color: AppTheme.textLight,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          _formatTimestamp(widget.invitation.createdAt),
          style: AppTheme.bodySmall.copyWith(
            color: AppTheme.textLight,
          ),
        ),

        const Spacer(),

        // Expiration time for pending invitations
        if (widget.invitation.status == CrewInvitationStatus.pending)
          _buildExpirationInfo(),
      ],
    );
  }

  Widget _buildExpirationInfo() {
    final hoursLeft = widget.invitation.hoursUntilExpiration;
    final Color expirationColor = hoursLeft <= 24
        ? AppTheme.errorRed
        : hoursLeft <= 48
            ? AppTheme.warningYellow
            : AppTheme.textLight;

    return Row(
      children: [
        Icon(
          Icons.timer,
          size: AppTheme.iconSm,
          color: expirationColor,
        ),
        const SizedBox(width: AppTheme.spacingXs),
        Text(
          'Expires in ${hoursLeft}h',
          style: AppTheme.bodySmall.copyWith(
            color: expirationColor,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }

  Widget _buildStatusBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(
        horizontal: AppTheme.spacingSm,
        vertical: AppTheme.spacingXs,
      ),
      decoration: BoxDecoration(
        color: _getStatusColor().withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppTheme.radiusRound),
        border: Border.all(
          color: _getStatusColor().withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _getStatusIcon(),
            size: AppTheme.iconXs,
            color: _getStatusColor(),
          ),
          const SizedBox(width: 4),
          Text(
            _getStatusText(),
            style: AppTheme.labelSmall.copyWith(
              color: _getStatusColor(),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActions() {
    if (widget.isLoading) {
      return const Center(
        child: Padding(
          padding: EdgeInsets.all(AppTheme.spacingMd),
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
          ),
        ),
      );
    }

    switch (widget.invitation.status) {
      case CrewInvitationStatus.pending:
        return Row(
          children: [
            Expanded(
              child: _buildActionButton(
                text: 'Decline',
                onPressed: widget.onDecline,
                isSecondary: true,
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: _buildActionButton(
                text: 'Accept',
                onPressed: widget.onAccept,
                isPrimary: true,
              ),
            ),
          ],
        );
      case CrewInvitationStatus.accepted:
      case CrewInvitationStatus.declined:
        return SizedBox(
          width: double.infinity,
          child: _buildActionButton(
            text: 'View Crew',
            onPressed: () => _navigateToCrew(),
            isPrimary: true,
          ),
        );
      default:
        return const SizedBox.shrink();
    }
  }

  Widget _buildActionButton({
    required String text,
    required VoidCallback? onPressed,
    bool isPrimary = false,
    bool isSecondary = false,
  }) {
    return Container(
      height: 44,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        border: isSecondary
            ? Border.all(
                color: AppTheme.primaryNavy,
                width: AppTheme.borderWidthMedium,
              )
            : null,
        gradient: isPrimary
            ? AppTheme.electricalGradient
            : isSecondary
                ? null
                : LinearGradient(
                    colors: [
                      AppTheme.textLight.withValues(alpha: 0.1),
                      AppTheme.textLight.withValues(alpha: 0.05),
                    ],
                  ),
        boxShadow: isPrimary
            ? [
                BoxShadow(
                  color: AppTheme.electricalGlowInfo.withValues(alpha: 0.3),
                  blurRadius: 8,
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
            child: Text(
              text,
              style: AppTheme.buttonMedium.copyWith(
                color: isPrimary
                    ? AppTheme.white
                    : isSecondary
                        ? AppTheme.primaryNavy
                        : AppTheme.textSecondary,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ),
      ),
    );
  }

  bool _shouldShowActions() {
    return widget.invitation.status == CrewInvitationStatus.pending ||
           widget.invitation.status == CrewInvitationStatus.accepted ||
           widget.invitation.status == CrewInvitationStatus.declined;
  }

  LinearGradient? _getCardGradient() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return LinearGradient(
          colors: [
            AppTheme.successGreen.withValues(alpha: 0.05),
            AppTheme.successGreen.withValues(alpha: 0.02),
          ],
        );
      case CrewInvitationStatus.declined:
      case CrewInvitationStatus.cancelled:
      case CrewInvitationStatus.expired:
        return LinearGradient(
          colors: [
            AppTheme.errorRed.withValues(alpha: 0.05),
            AppTheme.errorRed.withValues(alpha: 0.02),
          ],
        );
      default:
        return null; // Use default white background
    }
  }

  Color _getBorderColor() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return AppTheme.successGreen;
      case CrewInvitationStatus.declined:
      case CrewInvitationStatus.cancelled:
      case CrewInvitationStatus.expired:
        return AppTheme.errorRed;
      default:
        return AppTheme.accentCopper;
    }
  }

  Color _getShadowColor() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return AppTheme.successGreen;
      case CrewInvitationStatus.declined:
      case CrewInvitationStatus.cancelled:
      case CrewInvitationStatus.expired:
        return AppTheme.errorRed;
      default:
        return AppTheme.accentCopper;
    }
  }

  IconData _getCrewIcon() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return Icons.check_circle;
      case CrewInvitationStatus.declined:
        return Icons.cancel;
      case CrewInvitationStatus.cancelled:
        return Icons.highlight_off;
      case CrewInvitationStatus.expired:
        return Icons.timer_off;
      default:
        return Icons.group_add;
    }
  }

  Color _getStatusColor() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return AppTheme.successGreen;
      case CrewInvitationStatus.declined:
        return AppTheme.errorRed;
      case CrewInvitationStatus.cancelled:
        return AppTheme.textLight;
      case CrewInvitationStatus.expired:
        return AppTheme.warningOrange;
      default:
        return AppTheme.accentCopper;
    }
  }

  IconData _getStatusIcon() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return Icons.check_circle;
      case CrewInvitationStatus.declined:
        return Icons.cancel;
      case CrewInvitationStatus.cancelled:
        return Icons.highlight_off;
      case CrewInvitationStatus.expired:
        return Icons.timer_off;
      default:
        return Icons.pending;
    }
  }

  String _getStatusText() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return 'Accepted';
      case CrewInvitationStatus.declined:
        return 'Declined';
      case CrewInvitationStatus.cancelled:
        return 'Cancelled';
      case CrewInvitationStatus.expired:
        return 'Expired';
      default:
        return 'Pending';
    }
  }

  String _getStatusMessage() {
    switch (widget.invitation.status) {
      case CrewInvitationStatus.accepted:
        return 'You accepted this invitation and joined the crew';
      case CrewInvitationStatus.declined:
        return 'You declined this invitation';
      case CrewInvitationStatus.cancelled:
        return 'This invitation was cancelled by the sender';
      case CrewInvitationStatus.expired:
        return 'This invitation has expired';
      default:
        return 'You\'ve been invited to join this crew';
    }
  }

  String _formatTimestamp(Timestamp timestamp) {
    final date = timestamp.toDate();
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inMinutes < 1) {
      return 'Just now';
    } else if (difference.inHours < 1) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inDays < 1) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return DateFormat('MMM d, yyyy').format(date);
    }
  }

  void _navigateToCrew() {
    // Navigate to crew details
    // This would typically use the app's navigation system
    // For now, we'll just print a message
    print('Navigate to crew: ${widget.invitation.crewId}');
  }
}