import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/providers/jobs_filter_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog for filtering jobs by classification
///
/// Shows a bottom sheet with 6 classification options:
/// - Commercial
/// - Industrial
/// - Residential
/// - Transmission
/// - Distribution
/// - Sub-Station
/// Updates the JobsFilterProvider with the selected classification.
class ClassificationFilterDialog extends ConsumerWidget {
  const ClassificationFilterDialog({super.key});

  static const List<String> _classifications = [
    'Commercial',
    'Industrial',
    'Residential',
    'Transmission',
    'Distribution',
    'Sub-Station',
  ];

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ElectricalDialogBackground(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            'Filter by Classification',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ..._classifications.map((classification) => ListTile(
            leading: Icon(Icons.business, color: AppTheme.accentCopper),
            title: Text(classification, style: TextStyle(color: AppTheme.textOnDark)),
            onTap: () {
              Navigator.pop(context);
              // Update filter state using the jobs filter provider
              ref.read(jobsFilterProvider.notifier).setClassification(classification);
              JJElectricalNotifications.showElectricalToast(
                context: context,
                message: 'Filtering by $classification',
                type: ElectricalNotificationType.success,
              );
            },
          )),
        ],
      ),
    );
  }
}