import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/illustrations/electrical_illustrations.dart';
import '../../design_system/components/reusable_components.dart';

void main() {
  runApp(const ElectricalIllustrationsExample());
}

/// Example screen showing how to implement electrical illustrations
class ElectricalIllustrationsExample extends StatelessWidget {
  const ElectricalIllustrationsExample({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Electrical Illustrations'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
      ),
      body: SingleChildScrollView(
        
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Section 1: Loading States
            _buildSection(
              'Loading States',
              [
                _buildIllustrationCard(
                  'Circuit Board Loading',
                  ElectricalIllustration.circuitBoard,
                  'Perfect for data processing',
                ),
                _buildIllustrationCard(
                  'Job Search Loading',
                  ElectricalIllustration.jobSearch,
                  'For job-related operations',
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Section 2: Empty States
            _buildSection(
              'Empty States',
              [
                _buildIllustrationCard(
                  'No Results',
                  ElectricalIllustration.noResults,
                  'When search returns empty',
                ),
                _buildIllustrationCard(
                  'Light Bulb Ideas',
                  ElectricalIllustration.lightBulb,
                  'For inspiration or tips',
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Section 3: Success States
            _buildSection(
              'Success & Status',
              [
                _buildIllustrationCard(
                  'Success',
                  ElectricalIllustration.success,
                  'Application submitted',
                  color: AppTheme.successGreen,
                ),
                _buildIllustrationCard(
                  'Maintenance',
                  ElectricalIllustration.maintenance,
                  'System maintenance',
                  color: AppTheme.warningYellow,
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Section 4: Empty State Examples
            Text(
              'Empty State Examples',
              style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            
            // Job search empty state
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderLight),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const JJEmptyState(
                title: 'No Jobs Found',
                subtitle: 'Try adjusting your search criteria',
                context: 'jobs',
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Saved jobs empty state
            Container(
              height: 200,
              decoration: BoxDecoration(
                border: Border.all(color: AppTheme.borderLight),
                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
              ),
              child: const JJEmptyState(
                title: 'No Saved Jobs',
                subtitle: 'Save jobs to view them here',
                context: 'saved',
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSection(String title, List<Widget> children) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTheme.headlineSmall.copyWith(color: AppTheme.primaryNavy),
        ),
        const SizedBox(height: AppTheme.spacingMd),
        Wrap(
          spacing: AppTheme.spacingMd,
          runSpacing: AppTheme.spacingMd,
          children: children,
        ),
      ],
    );
  }

  Widget _buildIllustrationCard(
    String title,
    ElectricalIllustration illustration, 
    String description, {
    Color? color,
  }) {
    return Container(
      width: 160,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
      ),
      child: Column(
        children: [
          ElectricalIllustrationWidget(
            illustration: illustration,
            width: 80,
            height: 80,
            color: color,
            animate: true,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            title,
            style: AppTheme.labelLarge.copyWith(color: AppTheme.primaryNavy),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingXs),
          Text(
            description,
            style: AppTheme.bodySmall.copyWith(color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

/// Helper widget for quick illustration implementation
class QuickElectricalIllustration extends StatelessWidget {
  final ElectricalIllustration illustration;
  final double size;
  final Color? color;

  const QuickElectricalIllustration({
    super.key,
    required this.illustration,
    this.size = 60,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    return ElectricalIllustrationWidget(
      illustration: illustration,
      width: size,
      height: size,
      color: color ?? AppTheme.accentCopper,
      animate: true,
    );
  }
}

/// Extension for easy context-based illustration selection
extension ContextualIllustrations on String {
  ElectricalIllustration get electricalIllustration {
    return IllustrationHelper.getEmptyStateIllustration(this);
  }
}
