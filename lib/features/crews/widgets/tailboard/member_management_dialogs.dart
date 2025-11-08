// Flutter & Dart imports
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

// Journeyman Jobs - Absolute imports
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/models/crew_member.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/core_providers.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart' as auth_providers;
import 'package:journeyman_jobs/widgets/electrical_circuit_background.dart';

// Tailboard widget imports
import 'electrical_dialog_background.dart';
import 'electrical_text_field.dart';
import 'dialog_actions.dart';

/// Dialog for changing crew member roles with dropdown selection
class ChangeMemberRoleDialog extends ConsumerStatefulWidget {
  final CrewMember member;
  final Function(String?) onRoleChanged;

  const ChangeMemberRoleDialog({
    super.key,
    required this.member,
    required this.onRoleChanged,
  });

  @override
  ConsumerState<ChangeMemberRoleDialog> createState() => _ChangeMemberRoleDialogState();
}

class _ChangeMemberRoleDialogState extends ConsumerState<ChangeMemberRoleDialog> {
  String? selectedRole;

  // Available roles for crew members
  final List<String> availableRoles = [
    'foreman',
    'lead',
    'journeyman',
    'apprentice',
    'safety_officer',
    'equipment_operator',
  ];

  @override
  void initState() {
    super.initState();
    // Initialize with current role
    selectedRole = widget.member.role.toString().split('.').last;
  }

  @override
  Widget build(BuildContext context) {
    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Change Member Role',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Update role for ${widget.member.customTitle ?? widget.member.role.toString().split('.').last}',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
          ),
          const SizedBox(height: 24),

          // Member preview
          _buildMemberRolePreview(),

          const SizedBox(height: 24),

          // Role dropdown
          _buildRoleDropdownButton(),

          const SizedBox(height: 24),

          // Actions
          DialogActions(
            onConfirm: () {
              if (selectedRole != null) {
                widget.onRoleChanged(selectedRole);
                Navigator.pop(context);
              }
            },
            confirmText: 'Update Role',
          ),
        ],
      ),
    );
  }

  /// Build member preview with current role
  Widget _buildMemberRolePreview() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.secondaryNavy.withValues(alpha: 0.3),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.borderCopper.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Row(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppTheme.accentCopper.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                _getMemberInitials(),
                style: TextStyle(
                  color: AppTheme.accentCopper,
                  fontWeight: FontWeight.w600,
                  fontSize: 18,
                ),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.member.customTitle ?? 'Crew Member',
                  style: TextStyle(
                    color: AppTheme.textOnDark,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Current role: ${widget.member.role.toString().split('.').last.toUpperCase()}',
                  style: TextStyle(
                    color: AppTheme.mediumGray,
                    fontSize: 14,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  /// Build role selection dropdown
  Widget _buildRoleDropdownButton() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Select New Role',
          style: TextStyle(
            color: AppTheme.textOnDark,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.borderCopper.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<String>(
            initialValue: selectedRole,
            decoration: InputDecoration(
              labelText: 'Role',
              labelStyle: TextStyle(color: AppTheme.mediumGray),
              filled: true,
              fillColor: AppTheme.secondaryNavy.withValues(alpha: 0.2),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: AppTheme.secondaryNavy,
            style: TextStyle(color: AppTheme.textOnDark),
            items: availableRoles.map<DropdownMenuItem<String>>((String role) {
              return DropdownMenuItem<String>(
                value: role,
                child: Row(
                  children: [
                    Icon(
                      _getRoleIcon(role),
                      color: AppTheme.accentCopper,
                      size: 20,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      role.toUpperCase(),
                      style: TextStyle(color: AppTheme.textOnDark),
                    ),
                  ],
                ),
              );
            }).toList(),
            onChanged: (String? newValue) {
              setState(() {
                selectedRole = newValue;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Get member initials for avatar
  String _getMemberInitials() {
    final name = widget.member.customTitle ?? 'Crew Member';
    final parts = name.split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return name.isNotEmpty ? name[0].toUpperCase() : 'CM';
  }

  /// Get icon for role
  IconData _getRoleIcon(String role) {
    switch (role.toLowerCase()) {
      case 'foreman':
        return Icons.engineering;
      case 'lead':
        return Icons.star;
      case 'journeyman':
        return Icons.work;
      case 'apprentice':
        return Icons.school;
      case 'safety_officer':
        return Icons.health_and_safety;
      case 'equipment_operator':
        return Icons.construction;
      default:
        return Icons.person;
    }
  }
}

/// Dialog for composing new messages to crew members
class NewMessageDialog extends ConsumerStatefulWidget {
  final Function(String, String) onSendMessage;

  const NewMessageDialog({
    super.key,
    required this.onSendMessage,
  });

  @override
  ConsumerState<NewMessageDialog> createState() => _NewMessageDialogState();
}

class _NewMessageDialogState extends ConsumerState<NewMessageDialog> {
  final TextEditingController _messageController = TextEditingController();
  final TextEditingController _subjectController = TextEditingController();
  CrewMember? _selectedRecipient;

  @override
  void dispose() {
    _messageController.dispose();
    _subjectController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final selectedCrew = ref.watch(selectedCrewProvider);
    final crewMembersAsync = ref.watch(crewMembersStreamProvider(selectedCrew?.id ?? ''));

    return ElectricalCircuitBackground(
      child: Padding(
        padding: EdgeInsets.only(
          top: 16,
          left: 16,
          right: 16,
          bottom: MediaQuery.of(context).viewInsets.bottom + 16,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'New Message to Crew',
              style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                color: AppTheme.textOnDark,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 24),

            // Subject field
            _buildMessageTextField(
              controller: _subjectController,
              labelText: 'Subject',
              hintText: 'Enter message subject...',
              maxLines: 1,
            ),

            const SizedBox(height: 16),

            // Message field
            _buildMessageTextField(
              controller: _messageController,
              labelText: 'Message',
              hintText: 'Type your message here...',
              maxLines: 5,
            ),

            const SizedBox(height: 16),

            // Recipient selection
            crewMembersAsync.when(
              data: (members) {
                if (members.isEmpty) {
                  return Text(
                    'No crew members available.',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: AppTheme.mediumGray,
                    ),
                  );
                }
                return _buildRecipientDropdown(members);
              },
              loading: () => const Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                ),
              ),
              error: (error, stack) => Text(
                'Error loading crew members',
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: AppTheme.errorRed,
                ),
              ),
            ),

            const SizedBox(height: 24),

            // Actions
            DialogActions(
              onConfirm: () => _handleSendMessage(),
              confirmText: 'Send Message',
            ),
          ],
        ),
      ),
    );
  }

  /// Build message text field
  Widget _buildMessageTextField({
    required TextEditingController controller,
    required String labelText,
    required String hintText,
    required int maxLines,
  }) {
    return ElectricalTextField(
      controller: controller,
      maxLines: maxLines,
      labelText: labelText,
      hintText: hintText,
    );
  }

  /// Build recipient selection dropdown
  Widget _buildRecipientDropdown(List<CrewMember> members) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recipient (Optional)',
          style: TextStyle(
            color: AppTheme.textOnDark,
            fontWeight: FontWeight.w500,
            fontSize: 16,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppTheme.radiusMd),
            border: Border.all(
              color: AppTheme.borderCopper.withValues(alpha: 0.5),
              width: 1,
            ),
          ),
          child: DropdownButtonFormField<CrewMember>(
            initialValue: _selectedRecipient,
            decoration: InputDecoration(
              labelText: 'Select Recipient',
              labelStyle: TextStyle(color: AppTheme.mediumGray),
              filled: true,
              fillColor: AppTheme.secondaryNavy.withValues(alpha: 0.2),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
            dropdownColor: AppTheme.secondaryNavy,
            style: TextStyle(color: AppTheme.textOnDark),
            items: [
              const DropdownMenuItem<CrewMember>(
                value: null,
                child: Text('All Crew Members', style: TextStyle(color: AppTheme.textOnDark)),
              ),
              ...members.map((member) {
                return DropdownMenuItem<CrewMember>(
                  value: member,
                  child: Text(
                    member.customTitle ?? member.role.toString().split('.').last.toUpperCase(),
                    style: const TextStyle(color: AppTheme.textOnDark),
                  ),
                );
              }),
            ],
            onChanged: (CrewMember? member) {
              setState(() {
                _selectedRecipient = member;
              });
            },
          ),
        ),
      ],
    );
  }

  /// Handle sending message
  void _handleSendMessage() async {
    final subject = _subjectController.text.trim();
    final message = _messageController.text.trim();

    if (subject.isEmpty || message.isEmpty) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please fill in both subject and message fields.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    final selectedCrew = ref.read(selectedCrewProvider);
    if (selectedCrew == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'Please select a crew first.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    final currentUser = ref.read(auth_providers.currentUserProvider);
    if (currentUser == null) {
      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: 'User not authenticated. Please log in.',
        type: ElectricalNotificationType.error,
      );
      return;
    }

    try {
      await widget.onSendMessage(subject, message);

      if (!mounted) return;

      JJElectricalNotifications.showElectricalToast(
        context: context,
        message: _selectedRecipient != null
            ? 'Message sent to ${_selectedRecipient!.customTitle ?? 'crew member'}!'
            : 'Message sent to all crew members!',
        type: ElectricalNotificationType.success,
      );

      Navigator.pop(context);
    } catch (e) {
      if (mounted) {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Failed to send message: ${e.toString()}',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }
}