import 'package:flutter/material.dart';
import '../design_system/components/standardized_card.dart';
import '../design_system/app_theme.dart';

/// Demo widget to test and showcase the StandardizedCard component
/// This demonstrates how the component should be used with sample job data
class StandardizedCardDemo extends StatelessWidget {
  const StandardizedCardDemo({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Standardized Card Demo'),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Standardized Card Component Demo',
              style: AppTheme.headlineMedium,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'This demonstrates the standardized card format with column-row structure, icons, rich text, and vertical dividers.',
              style: AppTheme.bodyMedium,
            ),
            const SizedBox(height: AppTheme.spacingLg),

            // Demo 1: Job Card with 2 columns
            Text('Demo 1: Job Card (2 Columns)', style: AppTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingSm),
            _buildJobCardDemo(),

            const SizedBox(height: AppTheme.spacingXl),

            // Demo 2: Locals Card with 3 columns
            Text('Demo 2: Locals Card (3 Columns)', style: AppTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingSm),
            _buildLocalsCardDemo(),

            const SizedBox(height: AppTheme.spacingXl),

            // Demo 3: Simple card with 1 column
            Text('Demo 3: Simple Card (1 Column)', style: AppTheme.titleLarge),
            const SizedBox(height: AppTheme.spacingSm),
            _buildSimpleCardDemo(),
          ],
        ),
      ),
    );
  }

  /// Demo of a job card with typical job information
  Widget _buildJobCardDemo() {
    return StandardizedCard(
      header: 'Electrical Maintenance Technician',
      columns: [
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.business,
              label: 'Company',
              value: 'ABC Electric Services',
            ),
            CardRowData(
              icon: Icons.location_on,
              label: 'Location',
              value: 'Springfield, IL',
            ),
            CardRowData(
              icon: Icons.group,
              label: 'Local',
              value: 'Local 123',
            ),
          ],
        ),
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.attach_money,
              label: 'Wage',
              value: '\$28.50/hr',
              valueColor: AppTheme.accentCopper,
            ),
            CardRowData(
              icon: Icons.schedule,
              label: 'Hours',
              value: '40 hrs/week',
            ),
            CardRowData(
              icon: Icons.calendar_today,
              label: 'Posted',
              value: '2 days ago',
            ),
          ],
        ),
      ],
      onTap: () => debugPrint('Job card tapped'),
    );
  }

  /// Demo of a locals card with union information
  Widget _buildLocalsCardDemo() {
    return StandardizedCard(
      header: 'IBEW Local 123',
      columns: [
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.location_city,
              label: 'City',
              value: 'Springfield',
            ),
            CardRowData(
              icon: Icons.flag,
              label: 'State',
              value: 'Illinois',
            ),
          ],
        ),
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.people,
              label: 'Members',
              value: '2,450',
            ),
            CardRowData(
              icon: Icons.business_center,
              label: 'Business Manager',
              value: 'John Smith',
            ),
          ],
        ),
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.phone,
              label: 'Phone',
              value: '(555) 123-4567',
            ),
            CardRowData(
              icon: Icons.email,
              label: 'Email',
              value: 'info@local123.org',
            ),
          ],
        ),
      ],
      onTap: () => debugPrint('Locals card tapped'),
    );
  }

  /// Demo of a simple card with just one column
  Widget _buildSimpleCardDemo() {
    return StandardizedCard(
      header: 'Quick Info',
      columns: [
        CardColumnData(
          rows: [
            CardRowData(
              icon: Icons.info,
              label: 'Status',
              value: 'Active',
              valueColor: AppTheme.successGreen,
            ),
            CardRowData(
              icon: Icons.access_time,
              label: 'Last Updated',
              value: '5 minutes ago',
            ),
            CardRowData(
              icon: Icons.person,
              label: 'Updated By',
              value: 'System Admin',
            ),
          ],
        ),
      ],
      onTap: () => debugPrint('Simple card tapped'),
    );
  }
}