import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/jj_electrical_notifications.dart';
import 'package:journeyman_jobs/features/crews/providers/jobs_filter_provider.dart';
import 'package:journeyman_jobs/features/crews/widgets/tailboard/electrical_dialog_background.dart';

/// Dialog for filtering jobs by construction type
///
/// Shows a bottom sheet with 6 construction type options:
/// - Commercial
/// - Industrial
/// - Residential
/// - Transmission
/// - Distribution
/// - Sub-Station
/// Updates the JobsFilterProvider with the selected type.
class ConstructionTypeFilterDialog extends ConsumerWidget {
  const ConstructionTypeFilterDialog({super.key});

  static const List<String> _constructionTypes = [
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
            'Filter by Construction Type',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppTheme.textOnDark,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 24),
          ..._constructionTypes.map((type) => ListTile(
            leading: Icon(Icons.business, color: AppTheme.accentCopper),
            title: Text(type, style: TextStyle(color: AppTheme.textOnDark)),
            onTap: () {
              Navigator.pop(context);
              // Update filter state using the jobs filter provider
              ref.read(jobsFilterProvider.notifier).setConstructionType(type);
              JJElectricalNotifications.showElectricalToast(
                context: context,
                message: 'Filtering by $type jobs',
                type: ElectricalNotificationType.success,
              );
            },
          )),
        ],
      ),
    );
  }
}