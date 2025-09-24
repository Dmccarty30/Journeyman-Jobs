import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/widgets/job_details_dialog.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/design_system/popup_theme.dart';

void main() {
  testWidgets('JobDetailsDialog renders correctly', (WidgetTester tester) async {
    // Create a test job
    final testJob = Job(
      id: 'test-job-123',
      company: 'Test Electrical Company',
      location: 'New York, NY',
      jobTitle: 'Journeyman Lineman',
      classification: 'Lineman',
      local: 1249,
      wage: 45.50,
      hours: 40,
      startDate: '2024-01-15',
      perDiem: '\$150/day',
      typeOfWork: 'Distribution Line Work',
      qualifications: 'CDL required, First Aid/CPR certified',
      jobDescription: 'Looking for experienced journeyman lineman for distribution line work.',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PopupTheme(
          data: PopupThemeData.standard(),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => JobDetailsDialog(job: testJob),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify the dialog is shown
    expect(find.byType(JobDetailsDialog), findsOneWidget);
    expect(find.text('Job Details'), findsOneWidget);
    expect(find.text('Test Electrical Company'), findsOneWidget);
    expect(find.text('Journeyman Lineman'), findsOneWidget);
    expect(find.text('\$45.50/hr'), findsOneWidget);
    expect(find.text('40/week'), findsOneWidget);
    expect(find.text('CDL required, First Aid/CPR certified'), findsOneWidget);
    
    // Verify buttons are present
    expect(find.text('Close'), findsOneWidget);
    expect(find.text('Bid Now'), findsOneWidget);
  });

  testWidgets('JobDetailsDialog handles missing data gracefully', (WidgetTester tester) async {
    // Create a job with minimal data
    final minimalJob = Job(
      id: 'minimal-job-456',
      company: 'Minimal Company',
      location: 'Unknown Location',
    );

    await tester.pumpWidget(
      MaterialApp(
        home: PopupTheme(
          data: PopupThemeData.standard(),
          child: Builder(
            builder: (context) => Scaffold(
              body: Center(
                child: ElevatedButton(
                  onPressed: () {
                    showDialog(
                      context: context,
                      builder: (context) => JobDetailsDialog(job: minimalJob),
                    );
                  },
                  child: const Text('Show Dialog'),
                ),
              ),
            ),
          ),
        ),
      ),
    );

    // Tap the button to show the dialog
    await tester.tap(find.byType(ElevatedButton));
    await tester.pumpAndSettle();

    // Verify the dialog handles missing data with 'N/A'
    expect(find.byType(JobDetailsDialog), findsOneWidget);
    expect(find.text('Minimal Company'), findsOneWidget);
    expect(find.text('Unknown Location'), findsOneWidget);
    expect(find.text('N/A'), findsWidgets); // Should show N/A for missing fields
  });
}