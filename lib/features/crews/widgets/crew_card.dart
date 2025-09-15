import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../../design_system/app_theme.dart';
import '../../../electrical_components/circuit_pattern_painter.dart';
import '../../../electrical_components/electrical_icons.dart';
import '../models/crew.dart';
import '../models/crew_enums.dart';

/// A visually striking card displaying electrical worker crew information.
/// 
/// Features IBEW electrical styling with circuit patterns, copper accents,
/// and professional crew data display. Supports tap navigation and quick actions.
class CrewCard extends StatefulWidget {
  /// The crew data to display
  final Crew crew;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when card is long pressed
  final VoidCallback? onLongPress;

  /// Whether to show quick action buttons
  final bool showQuickActions;

  const CrewCard({
    Key? key,
    required this.crew,
    this.onTap,
    this.onLongPress,
    this.showQuickActions = false,
  }) : super(key: key);

  @override
  State<CrewCard> createState() => _CrewCardState();
}

class _CrewCardState extends State<CrewCard>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  bool _isPressed = false;
  bool _isImageLoading = false;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 150),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: 0.98,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeInOut,
    ));
    
    // Simulate image loading for crews with imageUrl
    if (widget.crew.imageUrl != null && widget.crew.imageUrl!.isNotEmpty) {
      _isImageLoading = true;
      // Simulate loading delay
      Future.delayed(const Duration(milliseconds: 500), () {
        if (mounted) {
          setState(() {
            _isImageLoading = false;
          });
        }
      });
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _handleTapDown(TapDownDetails details) {
    setState(() => _isPressed = true);
    _animationController.forward();
  }

  void _handleTapUp(TapUpDetails details) {
    setState(() => _isPressed = false);
    _animationController.reverse();
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _isPressed = false);
    _animationController.reverse();
  }

  @override
  Widget build(BuildContext context) {
    final memberCount = widget.crew.memberIds.length;
    final crewName = widget.crew.name.isNotEmpty ? widget.crew.name : 'Unnamed Crew';
    
    return Semantics(
      label: 'Crew card for $crewName with $memberCount members',
      button: true,
      onTap: widget.onTap,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                color: AppTheme.white,
                elevation: _isPressed ? 2.0 : 8.0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: _getStatusBorderColor(),
                    width: 2,
                  ),
                ),
                child: InkWell(
                  onTapDown: _handleTapDown,
                  onTapUp: _handleTapUp,
                  onTapCancel: _handleTapCancel,
                  onLongPress: widget.onLongPress,
                  borderRadius: BorderRadius.circular(16),
                  child: Container(
                    decoration: BoxDecoration(
                      gradient: _buildCardGradient(),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(14),
                      child: Stack(
                        children: [
                          _buildCircuitBackground(),
                          _buildCardContent(),
                          if (widget.crew.availableForStormWork) _buildStormIndicator(),
                          _buildStatusBadge(),
                          if (_isImageLoading) _buildLoadingIndicator(),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return const Positioned.fill(
      child: Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      ),
    );
  }

  LinearGradient _buildCardGradient() {
    final baseColor = _isPressed 
        ? AppTheme.primaryNavy.withOpacity(0.95)
        : AppTheme.primaryNavy.withOpacity(0.9);
    
    return LinearGradient(
      begin: Alignment.topLeft,
      end: Alignment.bottomRight,
      colors: [
        baseColor,
        baseColor.withOpacity(0.8),
        AppTheme.primaryNavy.withOpacity(0.85),
      ],
    );
  }

  Color _getStatusBorderColor() {
    if (widget.crew.isActive) {
      return AppTheme.accentCopper;
    } else if (widget.crew.isFull) {
      return const Color(0xFF6B7280); // Gray for full crews
    } else {
      return const Color(0xFF10B981); // Green for recruiting
    }
  }

  Widget _buildCircuitBackground() {
    return Positioned.fill(
      child: CustomPaint(
        painter: CircuitPatternPainter(
          color: AppTheme.accentCopper.withOpacity(0.1),
          strokeWidth: 1,
          spacing: 40,
        ),
      ),
    );
  }

  Widget _buildCardContent() {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(),
          const SizedBox(height: 12),
          _buildMemberInfo(),
          const SizedBox(height: 12),
          _buildCrewStats(),
          const SizedBox(height: 8),
          _buildClassificationBadges(),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Row(
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(
                    Icons.electrical_services,
                    color: AppTheme.accentCopper,
                    size: 20,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      widget.crew.name.isNotEmpty ? widget.crew.name : 'Unnamed Crew',
                      style: AppTheme.headingMedium.copyWith(
                        color: Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              if (widget.crew.homeLocal != null)
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      color: AppTheme.accentCopper.withOpacity(0.8),
                      size: 14,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      'IBEW Local ${widget.crew.homeLocal}',
                      style: AppTheme.bodySmall.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
            ],
          ),
        ),
        if (widget.crew.availableForStormWork)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: const Color(0xFFEF4444),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  Icons.flash_on,
                  color: Colors.white,
                  size: 14,
                ),
                const SizedBox(width: 2),
                Text(
                  'Storm Specialist',
                  style: AppTheme.labelSmall.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildMemberInfo() {
    final memberCount = widget.crew.memberIds.length;
    
    return Row(
      children: [
        _buildMemberAvatars(),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '$memberCount ${memberCount == 1 ? 'Member' : 'Members'}',
                style: AppTheme.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
                ),
              ),
              Text(
                'Created by ${_getCreatorName()}',
                style: AppTheme.bodySmall.copyWith(
                  color: Colors.white.withOpacity(0.8),
                ),
              ),
            ],
          ),
        ),
        _buildActivityIndicator(),
      ],
    );
  }

  Widget _buildMemberAvatars() {
    final maxAvatars = 4;
    final memberCount = widget.crew.memberIds.length;
    final avatarsToShow = memberCount > maxAvatars ? maxAvatars - 1 : memberCount;
    final extraCount = memberCount > maxAvatars ? memberCount - avatarsToShow : 0;

    return SizedBox(
      height: 32,
      width: avatarsToShow * 20 + (extraCount > 0 ? 32 : 12),
      child: Stack(
        children: [
          // Member avatars
          for (int i = 0; i < avatarsToShow; i++)
            Positioned(
              left: i * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppTheme.accentCopper, width: 2),
                  gradient: LinearGradient(
                    colors: [
                      AppTheme.accentCopper.withOpacity(0.8),
                      AppTheme.accentCopper.withOpacity(0.6),
                    ],
                  ),
                ),
                child: Icon(
                  Icons.person,
                  color: Colors.white,
                  size: 16,
                ),
              ),
            ),
          // Extra count indicator
          if (extraCount > 0)
            Positioned(
              left: avatarsToShow * 20.0,
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: AppTheme.accentCopper,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Center(
                  child: Text(
                    '+$extraCount',
                    style: AppTheme.labelSmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildActivityIndicator() {
    final isActive = widget.crew.isActive;
    
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isActive 
            ? const Color(0xFF10B981).withOpacity(0.2)
            : Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isActive 
              ? const Color(0xFF10B981)
              : Colors.grey,
          width: 1,
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: isActive 
                  ? const Color(0xFF10B981)
                  : Colors.grey,
            ),
          ),
          const SizedBox(width: 4),
          Text(
            isActive ? 'Active' : 'Idle',
            style: AppTheme.labelSmall.copyWith(
              color: isActive 
                  ? const Color(0xFF10B981)
                  : Colors.grey,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCrewStats() {
    return Row(
      children: [
        _buildStatItem(
          icon: Icons.work_outline,
          label: 'Total Jobs',
          value: '${widget.crew.totalJobs}',
        ),
        const SizedBox(width: 16),
        _buildStatItem(
          icon: Icons.trending_up,
          label: 'Rating',
          value: '${widget.crew.averageRating.toStringAsFixed(1)}',
        ),
        const Spacer(),
        Text(
          _formatLastActivity(widget.crew.lastActivityAt ?? widget.crew.updatedAt),
          style: AppTheme.bodySmall.copyWith(
            color: Colors.white.withOpacity(0.7),
          ),
        ),
      ],
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(
          icon,
          color: AppTheme.accentCopper.withOpacity(0.8),
          size: 16,
        ),
        const SizedBox(width: 4),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              value,
              style: AppTheme.bodySmall.copyWith(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              label,
              style: AppTheme.labelSmall.copyWith(
                color: Colors.white.withOpacity(0.7),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildClassificationBadges() {
    if (widget.crew.classifications.isEmpty) {
      return const SizedBox.shrink();
    }

    return Wrap(
      spacing: 6,
      runSpacing: 4,
      children: widget.crew.classifications.take(3).map((classification) {
        return Chip(
          label: Text(
            _getClassificationDisplayName(classification),
            style: AppTheme.labelSmall.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.w500,
            ),
          ),
          backgroundColor: AppTheme.accentCopper.withOpacity(0.2),
          side: BorderSide(
            color: AppTheme.accentCopper.withOpacity(0.5),
            width: 1,
          ),
          padding: EdgeInsets.zero,
          materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
        );
      }).toList(),
    );
  }

  Widget _buildStormIndicator() {
    return Positioned(
      top: 0,
      right: 0,
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: const Color(0xFFEF4444),
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(14),
            bottomLeft: Radius.circular(20),
          ),
        ),
        child: const Icon(
          Icons.flash_on,
          color: Colors.white,
          size: 20,
        ),
      ).animate(onPlay: (controller) => controller.repeat())
          .shimmer(duration: 2000.ms)
          .then()
          .shake(hz: 2, curve: Curves.easeInOut),
    );
  }

  Widget _buildStatusBadge() {
    String statusText;
    Color statusColor;
    
    if (widget.crew.isFull) {
      statusText = 'Full';
      statusColor = const Color(0xFF6B7280);
    } else if (widget.crew.isActive) {
      statusText = 'Active';
      statusColor = const Color(0xFF10B981);
    } else {
      statusText = 'Recruiting';
      statusColor = const Color(0xFF3B82F6);
    }
    
    return Positioned(
      bottom: 12,
      right: 12,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: statusColor.withOpacity(0.9),
          borderRadius: BorderRadius.circular(8),
          border: Border.all(
            color: statusColor,
            width: 1,
          ),
        ),
        child: Text(
          statusText,
          style: AppTheme.labelSmall.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  String _getCreatorName() {
    // In a real implementation, you'd look up the creator by ID
    return 'Crew Leader';
  }

  String _formatLastActivity(DateTime lastActivity) {
    final now = DateTime.now();
    final difference = now.difference(lastActivity);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  String _getClassificationDisplayName(String classification) {
    // Map internal classification IDs to display names
    final displayNames = {
      'inside_wireman': 'Inside Wireman',
      'journeyman_lineman': 'Lineman',
      'tree_trimmer': 'Tree Trimmer',
      'equipment_operator': 'Operator',
      'inside_journeyman': 'Journeyman',
      'insideWireman': 'Inside Wireman',
      'journeymanLineman': 'Lineman',
      'treeTrimmer': 'Tree Trimmer',
      'equipmentOperator': 'Operator',
      'insideJourneymanElectrician': 'Journeyman',
    };
    return displayNames[classification] ?? classification;
  }
}
