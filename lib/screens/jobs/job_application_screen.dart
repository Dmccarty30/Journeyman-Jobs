import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class JobApplicationScreen extends StatelessWidget {
  const JobApplicationScreen({super.key});

  static String routeName = 'job-application';
  static String routePath = '/job-application';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Application'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
      ),
      body: const Padding(
        padding: EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            Text(
              'Job Application',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppTheme.primaryNavy,
              ),
            ),
            SizedBox(height: AppTheme.spacingMd),
            Text(
              'Apply for electrical jobs and storm work.',
              style: TextStyle(
                fontSize: 16,
                color: AppTheme.textSecondary,
              ),
            ),
            SizedBox(height: AppTheme.spacingLg),
            Expanded(
              child: Center(
                child: Text(
                  'Job application form will be implemented here.',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppTheme.mediumGray,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}