import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/providers/jobs_filter_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_text_field.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/dialog_actions.dart';

/// Dialog for filtering jobs by IBEW local number
///
/// Shows a bottom sheet with a number input field for IBEW local numbers.
/// Validates the input and updates the JobsFilterProvider with the selected local.
class LocalFilterDialog extends ConsumerStatefulWidget {
  const LocalFilterDialog({super.key});

  @override
  ConsumerState<LocalFilterDialog> createState() => _LocalFilterDialogState();
}

class _LocalFilterDialogState extends ConsumerState<LocalFilterDialog> {
  final TextEditingController localController = TextEditingController();

  @override
  void dispose() {
    localController.dispose();
    super.dispose();
  }

  void _handleApplyFilter() {
    final local = localController.text.trim();
    Navigator.pop(context);
    if (local.isNotEmpty) {
      final localNumber = int.tryParse(local);
      if (localNumber != null) {
        // Update filter state using the jobs filter provider
        ref.read(jobsFilterProvider.notifier).setLocalNumber(localNumber);
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Filtering by Local $localNumber',
          type: ElectricalNotificationType.success,
        );
      } else {
        JJElectricalNotifications.showElectricalToast(
          context: context,
          message: 'Please enter a valid local number',
          type: ElectricalNotificationType.error,
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter by Local',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'Enter IBEW local number to filter jobs',
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppTheme.mediumGray,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          ElectricalTextField(
            controller: localController,
            keyboardType: TextInputType.number,
            labelText: 'Local Number',
            hintText: 'e.g., 46, 134, 58',
          ),
          const SizedBox(height: 16),
          DialogActions(
            confirmText: 'Apply Filter',
            onConfirm: _handleApplyFilter,
          ),
        ],
      ),
    );
  }
}