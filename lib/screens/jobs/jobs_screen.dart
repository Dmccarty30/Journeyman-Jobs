import 'package:flutter/material.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/components/reusable_components.dart';

class JobsScreen extends StatefulWidget {
  const JobsScreen({super.key});

  @override
  State<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends State<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  String _selectedFilter = 'All';
  final List<String> _filterOptions = [
    'All',
    'Journeyman Lineman',
    'Journeyman Electrician',
    'Journeyman Wireman',
    'Low Voltage',
    'Medium Voltage',
    'High Voltage',
    'Extra High Voltage',
    'Storm Work',
    'Transmission',
    'Distribution',
    'Substation',
  ];

  final List<Job> _sampleJobs = [
    Job(
      id: '1',
      title: 'Journeyman Lineman - Storm Work',
      company: 'IBEW Local 369',
      location: 'Louisville, KY',
      payRate: '\$52.50/hr',
      type: 'Storm Work',
      classification: 'Journeyman Lineman',
      voltageLevel: 'High Voltage',
      description: 'Emergency restoration work following severe weather. Overtime available.',
      requirements: ['Valid CDL', 'Hot stick certified', 'Storm experience preferred'],
      benefits: ['Per diem \$85/day', 'Travel pay', 'Overtime'],
      isUrgent: true,
      postedDate: DateTime.now().subtract(const Duration(hours: 2)),
    ),
    Job(
      id: '2',
      title: 'Journeyman Electrician - Data Center',
      company: 'IBEW Local 613',
      location: 'Atlanta, GA',
      payRate: '\$48.75/hr',
      type: 'Industrial',
      classification: 'Journeyman Electrician',
      voltageLevel: 'Low Voltage',
      description: 'New data center construction. Long-term project with growth opportunities.',
      requirements: ['Industrial experience', 'Conduit bending', 'Blueprint reading'],
      benefits: ['Health insurance', 'Pension', 'Annuity'],
      isUrgent: false,
      postedDate: DateTime.now().subtract(const Duration(days: 1)),
    ),
    Job(
      id: '3',
      title: 'Journeyman Wireman - Transmission',
      company: 'IBEW Local 712',
      location: 'Denver, CO',
      payRate: '\$54.20/hr',
      type: 'Transmission',
      classification: 'Journeyman Wireman',
      voltageLevel: 'Extra High Voltage',
      description: 'High voltage transmission line construction. Mountain work environment.',
      requirements: ['HV experience', 'Climbing certified', 'Physical fitness'],
      benefits: ['Altitude pay', 'Travel allowance', 'Medical'],
      isUrgent: false,
      postedDate: DateTime.now().subtract(const Duration(days: 3)),
    ),
    Job(
      id: '4',
      title: 'Journeyman Lineman - Distribution',
      company: 'IBEW Local 77',
      location: 'Seattle, WA',
      payRate: '\$56.10/hr',
      type: 'Distribution',
      classification: 'Journeyman Lineman',
      voltageLevel: 'Medium Voltage',
      description: 'Distribution system maintenance and construction. Day shift available.',
      requirements: ['CDL Class A', 'Distribution experience', 'Pole climbing'],
      benefits: ['Full benefits', 'Overtime opportunities', 'Local work'],
      isUrgent: false,
      postedDate: DateTime.now().subtract(const Duration(days: 5)),
    ),
  ];

  List<Job> get _filteredJobs {
    if (_selectedFilter == 'All') {
      return _sampleJobs;
    }
    return _sampleJobs.where((job) =>
      job.type == _selectedFilter ||
      job.title.contains(_selectedFilter) ||
      job.voltageLevel == _selectedFilter).toList();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _showFilterBottomSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      builder: (context) {
        return Container(
          padding: const EdgeInsets.all(AppTheme.spacingLg),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    'Filter Jobs',
                    style: AppTheme.headlineMedium.copyWith(color: AppTheme.primaryNavy),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),
              Wrap(
                spacing: AppTheme.spacingSm,
                runSpacing: AppTheme.spacingSm,
                children: _filterOptions.map((filter) {
                  final isSelected = _selectedFilter == filter;
                  return FilterChip(
                    label: Text(filter),
                    selected: isSelected,
                    onSelected: (selected) {
                      setState(() {
                        _selectedFilter = filter;
                      });
                      Navigator.pop(context);
                    },
                    backgroundColor: AppTheme.lightGray,
                    selectedColor: AppTheme.accentCopper,
                    labelStyle: TextStyle(
                      color: isSelected ? AppTheme.white : AppTheme.textPrimary,
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: AppTheme.spacingLg),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Text(
          'Job Opportunities',
          style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list, color: AppTheme.white),
            onPressed: _showFilterBottomSheet,
          ),
        ],
      ),
      body: Column(
        children: [
          // Search and filter bar
          Container(
            color: AppTheme.primaryNavy,
            padding: const EdgeInsets.fromLTRB(
              AppTheme.spacingMd,
              0,
              AppTheme.spacingMd,
              AppTheme.spacingMd,
            ),
            child: Row(
              children: [
                Expanded(
                  child: Container(
                    height: 44,
                    decoration: BoxDecoration(
                      color: AppTheme.white,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: TextField(
                      controller: _searchController,
                      decoration: InputDecoration(
                        hintText: 'Search jobs, locations, locals...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingMd,
                          vertical: AppTheme.spacingSm,
                        ),
                      ),
                      onChanged: (value) {
                        setState(() {});
                      },
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Container(
                  height: 44,
                  width: 44,
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper,
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.tune, color: AppTheme.white),
                    onPressed: _showFilterBottomSheet,
                  ),
                ),
              ],
            ),
          ),

          // Active filter indicator
          if (_selectedFilter != 'All')
            Container(
              width: double.infinity,
              color: AppTheme.accentCopper.withOpacity(0.1),
              padding: const EdgeInsets.symmetric(
                horizontal: AppTheme.spacingMd,
                vertical: AppTheme.spacingSm,
              ),
              child: Row(
                children: [
                  const Icon(Icons.filter_list, size: 16, color: AppTheme.accentCopper),
                  const SizedBox(width: AppTheme.spacingSm),
                  Text(
                    'Filtered by: $_selectedFilter',
                    style: AppTheme.bodySmall.copyWith(color: AppTheme.accentCopper),
                  ),
                  const Spacer(),
                  GestureDetector(
                    onTap: () => setState(() => _selectedFilter = 'All'),
                    child: const Icon(Icons.close, size: 16, color: AppTheme.accentCopper),
                  ),
                ],
              ),
            ),

          // Job count
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Text(
              '${_filteredJobs.length} jobs available',
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.textSecondary),
            ),
          ),

          // Job list
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
              itemCount: _filteredJobs.length,
              itemBuilder: (context, index) {
                final job = _filteredJobs[index];
                return JobCard(job: job);
              },
            ),
          ),
        ],
      ),
    );
  }
}

class Job {
  final String id;
  final String title;
  final String company;
  final String location;
  final String payRate;
  final String type;
  final String classification;
  final String? voltageLevel;
  final String description;
  final List<String> requirements;
  final List<String> benefits;
  final bool isUrgent;
  final DateTime postedDate;

  Job({
    required this.id,
    required this.title,
    required this.company,
    required this.location,
    required this.payRate,
    required this.type,
    required this.classification,
    this.voltageLevel,
    required this.description,
    required this.requirements,
    required this.benefits,
    required this.isUrgent,
    required this.postedDate,
  });
}

class JobCard extends StatelessWidget {
  final Job job;

  const JobCard({super.key, required this.job});

  String get _timeAgo {
    final now = DateTime.now();
    final difference = now.difference(job.postedDate);
    
    if (difference.inDays > 0) {
      return '${difference.inDays}d ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inMinutes}m ago';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [AppTheme.shadowSm],
        border: job.isUrgent ? Border.all(color: AppTheme.warningYellow, width: 2) : null,
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          onTap: () {
            _showJobDetails(context, job);
          },
          child: Padding(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Header row
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (job.isUrgent)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: AppTheme.spacingSm,
                                vertical: 2,
                              ),
                              decoration: BoxDecoration(
                                color: AppTheme.warningYellow,
                                borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                              ),
                              child: Text(
                                'URGENT',
                                style: AppTheme.labelSmall.copyWith(
                                  color: AppTheme.white,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          if (job.isUrgent) const SizedBox(height: AppTheme.spacingSm),
                          Text(
                            job.title,
                            style: AppTheme.headlineSmall.copyWith(
                              color: AppTheme.primaryNavy,
                            ),
                          ),
                          const SizedBox(height: AppTheme.spacingXs),
                          Text(
                            job.company,
                            style: AppTheme.bodyMedium.copyWith(
                              color: AppTheme.accentCopper,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        Text(
                          job.payRate,
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          _timeAgo,
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textLight,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Location and type
                Row(
                  children: [
                    Icon(
                      Icons.location_on,
                      size: 16,
                      color: AppTheme.textSecondary,
                    ),
                    const SizedBox(width: AppTheme.spacingXs),
                    Text(
                      job.location,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textSecondary,
                      ),
                    ),
                    const SizedBox(width: AppTheme.spacingMd),
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppTheme.spacingSm,
                        vertical: AppTheme.spacingXs,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                      ),
                      child: Text(
                        job.type,
                        style: AppTheme.labelSmall.copyWith(
                          color: AppTheme.textPrimary,
                        ),
                      ),
                    ),
                    if (job.voltageLevel != null) ...[
                      const SizedBox(width: AppTheme.spacingSm),
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: AppTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: JobCard._getVoltageLevelColor(job.voltageLevel!).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          border: Border.all(
                            color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                            width: 1,
                          ),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              Icons.bolt,
                              size: 14,
                              color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                            ),
                            const SizedBox(width: 4),
                            Text(
                              job.voltageLevel!,
                              style: AppTheme.labelSmall.copyWith(
                                color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Description
                Text(
                  job.description,
                  style: AppTheme.bodyMedium.copyWith(
                    color: AppTheme.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                
                const SizedBox(height: AppTheme.spacingMd),
                
                // Benefits preview
                if (job.benefits.isNotEmpty)
                  Wrap(
                    spacing: AppTheme.spacingSm,
                    children: job.benefits.take(3).map((benefit) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppTheme.spacingSm,
                          vertical: AppTheme.spacingXs,
                        ),
                        decoration: BoxDecoration(
                          color: AppTheme.accentCopper.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                        ),
                        child: Text(
                          benefit,
                          style: AppTheme.labelSmall.copyWith(
                            color: AppTheme.accentCopper,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  static Color _getVoltageLevelColor(String voltageLevel) {
    switch (voltageLevel) {
      case 'Low Voltage':
        return Colors.green;
      case 'Medium Voltage':
        return Colors.orange;
      case 'High Voltage':
        return Colors.red;
      case 'Extra High Voltage':
        return Colors.deepPurple;
      default:
        return AppTheme.textSecondary;
    }
  }

  void _showJobDetails(BuildContext context, Job job) {
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(AppTheme.radiusLg)),
      ),
      isScrollControlled: true,
      builder: (context) {
        return DraggableScrollableSheet(
          initialChildSize: 0.9,
          maxChildSize: 0.9,
          minChildSize: 0.5,
          builder: (context, scrollController) {
            return JobDetailsSheet(job: job, scrollController: scrollController);
          },
        );
      },
    );
  }
}

class JobDetailsSheet extends StatelessWidget {
  final Job job;
  final ScrollController scrollController;

  const JobDetailsSheet({
    super.key,
    required this.job,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingLg),
      child: SingleChildScrollView(
        controller: scrollController,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Handle
            Center(
              child: Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: AppTheme.textLight,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Header
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (job.isUrgent)
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: AppTheme.spacingSm,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppTheme.warningYellow,
                            borderRadius: BorderRadius.circular(AppTheme.radiusXs),
                          ),
                          child: Text(
                            'URGENT HIRING',
                            style: AppTheme.labelSmall.copyWith(
                              color: AppTheme.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      if (job.isUrgent) const SizedBox(height: AppTheme.spacingSm),
                      Text(
                        job.title,
                        style: AppTheme.displaySmall.copyWith(
                          color: AppTheme.primaryNavy,
                        ),
                      ),
                      const SizedBox(height: AppTheme.spacingXs),
                      Text(
                        job.company,
                        style: AppTheme.headlineSmall.copyWith(
                          color: AppTheme.accentCopper,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () => Navigator.pop(context),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Classification and voltage level
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.primaryNavy.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.build,
                        size: 16,
                        color: AppTheme.primaryNavy,
                      ),
                      const SizedBox(width: AppTheme.spacingSm),
                      Text(
                        job.classification,
                        style: AppTheme.bodyMedium.copyWith(
                          color: AppTheme.primaryNavy,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
                if (job.voltageLevel != null) ...[
                  const SizedBox(width: AppTheme.spacingSm),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingSm,
                    ),
                    decoration: BoxDecoration(
                      color: JobCard._getVoltageLevelColor(job.voltageLevel!).withOpacity(0.2),
                      borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                      border: Border.all(
                        color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.bolt,
                          size: 16,
                          color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                        ),
                        const SizedBox(width: AppTheme.spacingSm),
                        Text(
                          job.voltageLevel!,
                          style: AppTheme.bodyMedium.copyWith(
                            color: JobCard._getVoltageLevelColor(job.voltageLevel!),
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Pay and location
            Row(
              children: [
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.successGreen.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Pay Rate',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.successGreen,
                          ),
                        ),
                        Text(
                          job.payRate,
                          style: AppTheme.headlineLarge.copyWith(
                            color: AppTheme.successGreen,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: Container(
                    padding: const EdgeInsets.all(AppTheme.spacingMd),
                    decoration: BoxDecoration(
                      color: AppTheme.lightGray,
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Location',
                          style: AppTheme.labelMedium.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                        Text(
                          job.location,
                          style: AppTheme.headlineSmall.copyWith(
                            color: AppTheme.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Description
            Text(
              'Job Description',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              job.description,
              style: AppTheme.bodyLarge.copyWith(
                color: AppTheme.textPrimary,
                height: 1.6,
              ),
            ),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Requirements
            Text(
              'Requirements',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ...job.requirements.map((req) => Padding(
              padding: const EdgeInsets.only(bottom: AppTheme.spacingSm),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.check_circle,
                    size: 16,
                    color: AppTheme.successGreen,
                  ),
                  const SizedBox(width: AppTheme.spacingSm),
                  Expanded(
                    child: Text(
                      req,
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.textPrimary,
                      ),
                    ),
                  ),
                ],
              ),
            )),
            
            const SizedBox(height: AppTheme.spacingLg),
            
            // Benefits
            Text(
              'Benefits',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Wrap(
              spacing: AppTheme.spacingSm,
              runSpacing: AppTheme.spacingSm,
              children: job.benefits.map((benefit) {
                return Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppTheme.spacingMd,
                    vertical: AppTheme.spacingSm,
                  ),
                  decoration: BoxDecoration(
                    color: AppTheme.accentCopper.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  ),
                  child: Text(
                    benefit,
                    style: AppTheme.bodyMedium.copyWith(
                      color: AppTheme.accentCopper,
                    ),
                  ),
                );
              }).toList(),
            ),
            
            const SizedBox(height: AppTheme.spacingXl),
            
            // Apply button
            JJPrimaryButton(
              text: 'Apply Now',
              icon: Icons.send,
              onPressed: () {
                Navigator.pop(context);
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Application submitted successfully!',
                );
              },
              isFullWidth: true,
            ),
            
            const SizedBox(height: AppTheme.spacingMd),
            
            // Save job button
            JJSecondaryButton(
              text: 'Save Job',
              icon: Icons.bookmark_outline,
              onPressed: () {
                JJSnackBar.showSuccess(
                  context: context,
                  message: 'Job saved to your favorites',
                );
              },
              isFullWidth: true,
            ),
          ],
        ),
      ),
    );
  }
}