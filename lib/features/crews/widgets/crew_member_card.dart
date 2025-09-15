import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../../design_system/app_theme.dart';
import '../models/crew_member.dart';
import '../models/crew_enums.dart';

/// A card widget displaying crew member details with IBEW protocol support
///
/// Shows member information, role, availability, and provides
/// interactive features for crew coordination and communication.
class CrewMemberCard extends StatelessWidget {
  const CrewMemberCard({
    super.key,
    required this.member,
    required this.currentUserRole,
    this.onTap,
    this.onRoleChange,
    this.onRemove,
    this.onContact,
    this.showActions = true,
    this.compact = false,
  });

  /// The crew member to display
  final CrewMember member;

  /// Current user's role for permission checking
  final CrewRole currentUserRole;

  /// Callback when card is tapped
  final VoidCallback? onTap;

  /// Callback when role is changed (foreman/lead only)
  final Function(CrewRole)? onRoleChange;

  /// Callback when member is removed (foreman/lead only)
  final VoidCallback? onRemove;

  /// Callback for contact actions
  final Function(String contactType)? onContact;

  /// Whether to show action buttons
  final bool showActions;

  /// Whether to use compact layout
  final bool compact;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: compact ? 8 : 16,
        vertical: compact ? 4 : 8,
      ),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        border: Border.all(
          color: _getBorderColor(),
          width: AppTheme.borderWidthMedium,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: compact ? 4 : 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(compact ? 8 : 12),
        child: Padding(
          padding: EdgeInsets.all(compact ? 12 : 16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildHeader(),
              if (!compact) ...[
                const SizedBox(height: 12),
                _buildMemberInfo(),
                const SizedBox(height: 12),
                _buildStatusInfo(),
                if (showActions) ...[
                  const SizedBox(height: 16),
                  _buildActionButtons(context),
                ],
              ] else if (showActions) ...[
                const SizedBox(height: 8),
                _buildCompactActions(context),
              ],
            ],
          ),
        ),
      ),
    );
  }

  /// Build the header with profile, name, and role
  Widget _buildHeader() {
    return Row(
      children: [
        // Profile picture with electrical trade badge
        Stack(
          children: [
            CircleAvatar(
              radius: compact ? 20 : 24,
              backgroundColor: AppTheme.lightGray,
              backgroundImage: member.profileImageUrl != null
                  ? NetworkImage(member.profileImageUrl!)
                  : null,
              child: member.profileImageUrl == null
                  ? Icon(
                      Icons.person,
                      size: compact ? 20 : 24,
                      color: AppTheme.darkGray,
                    )
                  : null,
            ),
            // Trade classification badge
            if (_getPrimaryClassification() != null)
              Positioned(
                bottom: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.all(2),
                  decoration: const BoxDecoration(
                    color: AppTheme.accentCopper,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    _getClassificationIcon(),
                    size: compact ? 12 : 14,
                    color: AppTheme.white,
                  ),
                ),
              ),
          ],
        ),
        const SizedBox(width: 12),
        // Name and role information
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                member.displayName ?? 'Unknown Member',
                style: compact
                    ? AppTheme.titleSmall.copyWith(color: AppTheme.textDark)
                    : AppTheme.titleMedium.copyWith(color: AppTheme.textDark),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
              const SizedBox(height: 2),
              Row(
                children: [
                  // Role badge
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: _getRoleColor().withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: _getRoleColor(),
                        width: 1,
                      ),
                    ),
                    child: Text(
                      member.role.displayName,
                      style: AppTheme.labelSmall.copyWith(
                        color: _getRoleColor(),
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  // IBEW Local badge
                  if (member.localNumber != null)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryNavy.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        'IBEW ${member.localNumber}',
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
        ),
        // Availability indicator
        _buildAvailabilityIndicator(),
      ],
    );
  }

  /// Build member information section
  Widget _buildMemberInfo() {
    return Column(
      children: [
        // Row 1: Classification | Experience
        if (_getPrimaryClassification() != null || member.yearsExperience != null)
          _buildTwoColumnRow(
            leftLabel: 'Classification',
            leftValue: _getPrimaryClassification() ?? 'N/A',
            rightLabel: 'Experience',
            rightValue: member.yearsExperience != null
                ? '${member.yearsExperience} years'
                : 'N/A',
          ),
        const SizedBox(height: 8),
        // Row 2: Contact | Rating
        _buildTwoColumnRow(
          leftLabel: 'Contact',
          leftValue: _getPreferredContact(),
          rightLabel: 'Rating',
          rightValue: member.rating != null
              ? '${member.rating!.toStringAsFixed(1)}/5.0'
              : 'No rating',
          rightValueColor: member.rating != null && member.rating! >= 4.0
              ? AppTheme.successGreen
              : null,
        ),
      ],
    );
  }

  /// Build status information section
  Widget _buildStatusInfo() {
    return Column(
      children: [
        // Row 1: Availability | Jobs Completed
        _buildTwoColumnRow(
          leftLabel: 'Status',
          leftValue: member.availability.displayName,
          leftValueColor: _getAvailabilityColor(),
          rightLabel: 'Jobs Completed',
          rightValue: '${member.jobsCompleted}',
        ),
        const SizedBox(height: 8),
        // Row 2: Last Active | Emergency Contact
        _buildTwoColumnRow(
          leftLabel: 'Last Active',
          leftValue: _formatLastActive(),
          rightLabel: 'Emergency Contact',
          rightValue: member.hasEmergencyContact ? 'Available' : 'None',
          rightValueColor: member.hasEmergencyContact
              ? AppTheme.successGreen
              : AppTheme.warningOrange,
        ),
        // Certifications and skills
        if (member.certifications.isNotEmpty || member.skills.isNotEmpty) ...[
          const SizedBox(height: 8),
          _buildTagsRow(),
        ],
      ],
    );
  }

  /// Build certifications and skills tags
  Widget _buildTagsRow() {
    final allTags = [...member.certifications, ...member.skills];
    if (allTags.isEmpty) return const SizedBox.shrink();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Certifications & Skills',
          style: AppTheme.labelSmall.copyWith(
            color: AppTheme.textDark,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 4),
        Wrap(
          spacing: 4,
          runSpacing: 4,
          children: allTags.take(compact ? 3 : 6).map((tag) => Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: AppTheme.lightGray,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(
              tag,
              style: AppTheme.labelSmall.copyWith(
                color: AppTheme.textDark,
                fontSize: 10,
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  /// Build action buttons for full layout
  Widget _buildActionButtons(BuildContext context) {
    return Row(
      children: [
        // Contact button
        Expanded(
          child: OutlinedButton.icon(
            onPressed: () => _showContactOptions(context),
            icon: const Icon(Icons.phone, size: 16),
            label: const Text('Contact'),
            style: OutlinedButton.styleFrom(
              foregroundColor: AppTheme.primaryNavy,
              side: const BorderSide(color: AppTheme.primaryNavy),
              padding: const EdgeInsets.symmetric(vertical: 8),
            ),
          ),
        ),
        if (_canModifyMember()) ...[
          const SizedBox(width: 8),
          // Role change button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRoleChangeDialog(context),
              icon: const Icon(Icons.admin_panel_settings, size: 16),
              label: const Text('Role'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.accentCopper,
                side: const BorderSide(color: AppTheme.accentCopper),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
          const SizedBox(width: 8),
          // Remove button
          Expanded(
            child: OutlinedButton.icon(
              onPressed: () => _showRemoveConfirmation(context),
              icon: const Icon(Icons.remove_circle_outline, size: 16),
              label: const Text('Remove'),
              style: OutlinedButton.styleFrom(
                foregroundColor: AppTheme.errorRed,
                side: const BorderSide(color: AppTheme.errorRed),
                padding: const EdgeInsets.symmetric(vertical: 8),
              ),
            ),
          ),
        ],
      ],
    );
  }

  /// Build compact action buttons
  Widget _buildCompactActions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        IconButton(
          onPressed: () => _showContactOptions(context),
          icon: const Icon(Icons.phone),
          iconSize: 20,
          color: AppTheme.primaryNavy,
          padding: const EdgeInsets.all(4),
          constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
        ),
        if (_canModifyMember()) ...[
          IconButton(
            onPressed: () => _showRoleChangeDialog(context),
            icon: const Icon(Icons.admin_panel_settings),
            iconSize: 20,
            color: AppTheme.accentCopper,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
          IconButton(
            onPressed: () => _showRemoveConfirmation(context),
            icon: const Icon(Icons.remove_circle_outline),
            iconSize: 20,
            color: AppTheme.errorRed,
            padding: const EdgeInsets.all(4),
            constraints: const BoxConstraints(minWidth: 32, minHeight: 32),
          ),
        ],
      ],
    );
  }

  /// Build availability status indicator
  Widget _buildAvailabilityIndicator() {
    return Container(
      width: 12,
      height: 12,
      decoration: BoxDecoration(
        color: _getAvailabilityColor(),
        shape: BoxShape.circle,
        border: Border.all(color: AppTheme.white, width: 2),
      ),
    );
  }

  /// Helper method to build two-column info rows
  Widget _buildTwoColumnRow({
    required String leftLabel,
    required String leftValue,
    required String rightLabel,
    required String rightValue,
    Color? leftValueColor,
    Color? rightValueColor,
  }) {
    return Row(
      children: [
        // Left column
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$leftLabel: ',
                  style: AppTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextSpan(
                  text: leftValue,
                  style: AppTheme.labelSmall.copyWith(
                    color: leftValueColor ?? AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        // Right column
        Expanded(
          child: RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: '$rightLabel: ',
                  style: AppTheme.labelSmall.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppTheme.textDark,
                  ),
                ),
                TextSpan(
                  text: rightValue,
                  style: AppTheme.labelSmall.copyWith(
                    color: rightValueColor ?? AppTheme.textLight,
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  /// Show contact options bottom sheet
  void _showContactOptions(BuildContext context) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Contact ${member.displayName ?? "Member"}',
              style: AppTheme.titleMedium.copyWith(color: AppTheme.textDark),
            ),
            const SizedBox(height: 16),
            if (member.phone != null)
              ListTile(
                leading: const Icon(Icons.phone, color: AppTheme.primaryNavy),
                title: const Text('Call'),
                subtitle: Text(member.phone!),
                onTap: () {
                  Navigator.pop(context);
                  _launchPhone(member.phone!);
                },
              ),
            if (member.phone != null)
              ListTile(
                leading: const Icon(Icons.message, color: AppTheme.accentCopper),
                title: const Text('Text Message'),
                subtitle: Text(member.phone!),
                onTap: () {
                  Navigator.pop(context);
                  _launchSMS(member.phone!);
                },
              ),
            if (member.email != null)
              ListTile(
                leading: const Icon(Icons.email, color: AppTheme.primaryNavy),
                title: const Text('Email'),
                subtitle: Text(member.email!),
                onTap: () {
                  Navigator.pop(context);
                  _launchEmail(member.email!);
                },
              ),
            const SizedBox(height: 16),
          ],
        ),
      ),
    );
  }

  /// Show role change dialog
  void _showRoleChangeDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Change Member Role'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: CrewRole.values.map((role) => ListTile(
            title: Text(role.displayName),
            leading: Radio<CrewRole>(
              value: role,
              groupValue: member.role,
              onChanged: (CrewRole? value) {
                if (value != null && value != member.role) {
                  Navigator.pop(context);
                  onRoleChange?.call(value);
                }
              },
              activeColor: AppTheme.accentCopper,
            ),
          )).toList(),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
        ],
      ),
    );
  }

  /// Show remove confirmation dialog
  void _showRemoveConfirmation(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remove Member'),
        content: Text(
          'Are you sure you want to remove ${member.displayName ?? "this member"} from the crew?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              onRemove?.call();
            },
            style: TextButton.styleFrom(
              foregroundColor: AppTheme.errorRed,
            ),
            child: const Text('Remove'),
          ),
        ],
      ),
    );
  }

  /// Launch phone dialer
  void _launchPhone(String phoneNumber) async {
    final uri = Uri.parse('tel:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    onContact?.call('phone');
  }

  /// Launch SMS app
  void _launchSMS(String phoneNumber) async {
    final uri = Uri.parse('sms:$phoneNumber');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    onContact?.call('sms');
  }

  /// Launch email app
  void _launchEmail(String email) async {
    final uri = Uri.parse('mailto:$email');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
    onContact?.call('email');
  }

  /// Helper methods for styling and data
  Color _getBorderColor() {
    switch (member.availability) {
      case MemberAvailability.available:
        return AppTheme.successGreen;
      case MemberAvailability.busy:
      case MemberAvailability.onJob:
        return AppTheme.warningYellow;
      case MemberAvailability.unavailable:
      case MemberAvailability.sick:
        return AppTheme.errorRed;
      default:
        return AppTheme.accentCopper;
    }
  }

  Color _getRoleColor() {
    switch (member.role) {
      case CrewRole.foreman:
        return AppTheme.accentCopper;
      case CrewRole.leadJourneyman:
        return AppTheme.primaryNavy;
      case CrewRole.safetyCoordinator:
        return AppTheme.errorRed;
      case CrewRole.qualityInspector:
        return AppTheme.infoBlue;
      default:
        return AppTheme.darkGray;
    }
  }

  Color _getAvailabilityColor() {
    switch (member.availability) {
      case MemberAvailability.available:
        return AppTheme.successGreen;
      case MemberAvailability.busy:
      case MemberAvailability.onJob:
        return AppTheme.warningYellow;
      case MemberAvailability.onVacation:
        return AppTheme.infoBlue;
      case MemberAvailability.sick:
      case MemberAvailability.unavailable:
        return AppTheme.errorRed;
      case MemberAvailability.offline:
        return AppTheme.mediumGray;
    }
  }

  IconData _getClassificationIcon() {
    final classification = _getPrimaryClassification()?.toLowerCase();
    if (classification == null) return Icons.electrical_services;

    if (classification.contains('lineman') || classification.contains('line')) {
      return Icons.power_outlined;
    } else if (classification.contains('inside') || classification.contains('wireman')) {
      return Icons.home_repair_service;
    } else if (classification.contains('operator')) {
      return Icons.engineering;
    } else if (classification.contains('tree')) {
      return Icons.nature;
    } else {
      return Icons.electrical_services;
    }
  }

  String? _getPrimaryClassification() {
    return member.classifications.isNotEmpty ? member.classifications.first : null;
  }

  String _getPreferredContact() {
    if (member.phone != null) return 'Phone available';
    if (member.email != null) return 'Email only';
    return 'No contact info';
  }

  String _formatLastActive() {
    if (member.lastActiveAt == null) return 'Unknown';

    final now = DateTime.now();
    final difference = now.difference(member.lastActiveAt!);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else if (difference.inDays < 7) {
      return '${difference.inDays}d ago';
    } else {
      return '${(difference.inDays / 7).floor()}w ago';
    }
  }

  bool _canModifyMember() {
    return currentUserRole == CrewRole.foreman ||
           currentUserRole == CrewRole.leadJourneyman;
  }
}