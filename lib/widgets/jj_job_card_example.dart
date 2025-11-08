import 'package:flutter/material.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/widgets/jj_job_card.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';

/// Example screen demonstrating JJJobCard variants
class JJJobCardExampleScreen extends StatelessWidget {
  const JJJobCardExampleScreen({Key? key}) : super(key: key);

  // Sample job data
  static final _sampleJob = Job(
    id: '1',
    sharerId: 'test-sharer',
    company: 'PowerGrid Solutions',
    wage: 45.50,
    local: 124,
    classification: 'Journeyman Lineman',
    location: 'Houston, TX',
    jobDetails: {
      'title': 'Transmission Line Technician',
      'description': 'Installing and maintaining high-voltage transmission lines',
      'isStormWork': true,
      'imageUrl': 'https://example.com/company-logo.jpg',
    },
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('JJJobCard Examples'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: Colors.white,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const Text(
            'Compact Variant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          JJJobCard(
            job: _sampleJob,
            variant: JJJobCardVariant.compact,
            onTap: () {
              print('Compact card tapped');
            },
            onBookmark: (bookmarked) {
              print('Job bookmarked: $bookmarked');
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Standard Variant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          JJJobCard(
            job: _sampleJob,
            variant: JJJobCardVariant.standard,
            onTap: () {
              print('Standard card tapped');
            },
            onBookmark: (bookmarked) {
              print('Job bookmarked: $bookmarked');
            },
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Detailed Variant',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          JJJobCard(
            job: _sampleJob,
            variant: JJJobCardVariant.detailed,
            onTap: () {
              print('Detailed card tapped');
            },
            onBookmark: (bookmarked) {
              print('Job bookmarked: $bookmarked');
            },
            isSelected: true,
            footer: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppTheme.primaryNavy.withValues(alpha:0.1),
                borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(16),
                  bottomRight: Radius.circular(16),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  TextButton(
                    onPressed: () {},
                    child: Text(
                      'Share',
                      style: TextStyle(color: AppTheme.primaryNavy),
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.accentCopper,
                      foregroundColor: Colors.white,
                    ),
                    child: const Text('Apply Now'),
                  ),
                ],
              ),
            ),
          ),
          
          const SizedBox(height: 24),
          
          const Text(
            'Custom Configuration',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 8),
          JJJobCard(
            job: _sampleJob,
            variant: JJJobCardVariant.standard,
            config: const JJJobCardConfig(
              showBookmark: false,
              showStormBadge: true,
              showWage: true,
              showUnionLocal: true,
              showStatus: true,
              animate: true,
              showCircuitPattern: true,
            ),
            onTap: () {
              print('Custom config card tapped');
            },
          ),
        ],
      ),
    );
  }
}