import 'package:flutter/material.dart';
import 'job_details_dialog.dart';
import '../models/job_model.dart';
import '../design_system/popup_theme.dart';

/// Example demonstrating how to use JobDetailsDialog with different popup themes
class JobDetailsDialogExample extends StatelessWidget {
  const JobDetailsDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    // Create a sample job for demonstration
    final sampleJob = Job(
      id: 'demo-job-789',
      company: 'Metro Electric Co.',
      location: 'Downtown District, NY',
      jobTitle: 'Master Electrician',
      classification: 'Master',
      local: 1249,
      wage: 52.75,
      hours: 40,
      startDate: '2024-01-22',
      startTime: '7:00 AM',
      perDiem: '\$175/day',
      typeOfWork: 'Commercial Installation',
      duration: '6 months',
      voltageLevel: '480V',
      qualifications: 'Master license required, OSHA 30 certified, First Aid/CPR',
      jobDescription: 'Seeking experienced Master Electrician for large commercial installation project. Must have experience with high-voltage systems and commercial wiring.',
      numberOfJobs: '3',
      agreement: 'IBEW Local 1249',
    );

    return Scaffold(
      appBar: AppBar(
        title: const Text('Job Details Dialog Examples'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Job Details Dialog Theme Examples',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            
            // Standard popup theme
            _buildThemeButton(
              context,
              'Standard Theme',
              'Clean, professional appearance with copper accent',
              PopupThemeData.standard(),
              sampleJob,
            ),
            
            const SizedBox(height: 12),
            
            // Alert dialog theme
            _buildThemeButton(
              context,
              'Alert Theme',
              'Enhanced elevation and padding for important decisions',
              PopupThemeData.alertDialog(),
              sampleJob,
            ),
            
            const SizedBox(height: 12),
            
            // Modal theme
            _buildThemeButton(
              context,
              'Modal Theme',
              'Large content display with max dimensions',
              PopupThemeData.modal(),
              sampleJob,
            ),
            
            const SizedBox(height: 12),
            
            // Custom popup theme
            _buildThemeButton(
              context,
              'Custom Theme',
              'Matches LocalCard styling exactly',
              PopupThemeData.customPopup(),
              sampleJob,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildThemeButton(
    BuildContext context,
    String title,
    String description,
    PopupThemeData theme,
    Job job,
  ) {
    return Card(
      elevation: 2,
      child: InkWell(
        onTap: () => _showJobDetailsWithTheme(context, theme, job),
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(
                  fontSize: 14,
                  color: Colors.grey[600],
                ),
              ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  Text(
                    'Tap to preview',
                    style: TextStyle(
                      fontSize: 12,
                      color: Theme.of(context).primaryColor,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(width: 4),
                  Icon(
                    Icons.open_in_new,
                    size: 16,
                    color: Theme.of(context).primaryColor,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showJobDetailsWithTheme(
    BuildContext context,
    PopupThemeData theme,
    Job job,
  ) {
    // Use the themed dialog method from PopupThemeExtension
    context.showThemedDialog(
      theme: theme,
      builder: (context) => JobDetailsDialog(job: job),
    );
  }
}

/// Usage example in your app:
/// 
/// ```dart
/// // In your widget build method:
/// final job = Job(/* your job data */);
/// 
/// // Show with standard theme:
/// context.showThemedDialog(
///   builder: (context) => JobDetailsDialog(job: job),
/// );
/// 
/// // Show with custom theme:
/// context.showThemedDialog(
///   theme: PopupThemeData.alertDialog(),
///   builder: (context) => JobDetailsDialog(job: job),
/// );
/// 
/// // Or use the traditional way:
/// showDialog(
///   context: context,
///   builder: (context) => JobDetailsDialog(job: job),
/// );