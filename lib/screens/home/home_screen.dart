import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../design_system/popup_theme.dart';
import '../../navigation/app_router.dart';
import '../../providers/riverpod/jobs_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../models/job_model.dart';
import '../../legacy/flutterflow/schema/jobs_record.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/condensed_job_card.dart';
import 'electrical_demo_screen.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobsNotifierProvider.notifier).loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: AppTheme.buttonGradient,
                shape: BoxShape.circle,
              ),
              child: Padding(
                padding: const EdgeInsets.all(6),
                child: Icon(
                  Icons.construction,
                  size: 20,
                  color: AppTheme.white,
                ),
              ),
            ),
            const SizedBox(width: AppTheme.spacingSm),
            Text(
              'Journeyman Jobs',
              style: AppTheme.headlineMedium.copyWith(color: AppTheme.white),
            ),
          ],
        ),
        actions: [
          NotificationBadge(
            iconColor: AppTheme.white,
            showPopupOnTap: false,
            onTap: () {
              context.push(AppRouter.notifications);
            },
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: () => ref.read(jobsNotifierProvider.notifier).refreshJobs(),
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppTheme.spacingMd),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Consumer(
                builder: (context, ref, child) {
                  final authState = ref.watch(authNotifierProvider);
                  if (!authState.isAuthenticated) {
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Welcome back!',
                          style: AppTheme.headlineMedium.copyWith(
                            color: AppTheme.primaryNavy,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: AppTheme.spacingSm),
                        Text(
                          'Guest User',
                          style: AppTheme.bodyLarge.copyWith(
                            color: AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    );
                  }

                  final displayName = authState.user?.displayName ?? 'User';
                  final photoUrl = authState.user?.photoURL;
                  final userInitial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';

                  return Row(
                    children: [
                      CircleAvatar(
                        radius: 30,
                        backgroundColor: AppTheme.primaryNavy,
                        backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                        child: photoUrl == null
                            ? Text(
                                userInitial,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              )
                            : null,
                      ),
                      const SizedBox(width: AppTheme.spacingMd),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Welcome back!',
                              style: AppTheme.headlineMedium.copyWith(
                                color: AppTheme.primaryNavy,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            Text(
                              displayName,
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingLg),

              Text(
                'Quick Actions',
                style: AppTheme.headlineSmall.copyWith(
                  color: AppTheme.primaryNavy,
                ),
              ),
              const SizedBox(height: AppTheme.spacingMd),

              Row(
                children: [
                  Expanded(
                    child: _buildElectricalActionCard(
                      'Electrical calc',
                      Icons.calculate_outlined,
                      () {
                        context.push(AppRouter.electricalCalculators);
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Suggested Jobs',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  TextButton(
                    onPressed: () {
                      context.push(AppRouter.jobs);
                    },
                    child: Text(
                      'View All',
                      style: AppTheme.bodyMedium.copyWith(
                        color: AppTheme.accentCopper,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: AppTheme.spacingMd),

              Consumer(
                builder: (context, ref, child) {
                  final jobsState = ref.watch(jobsNotifierProvider);
                  if (jobsState.isLoading) {
                    return const Center(
                      child: Padding(
                        padding: EdgeInsets.all(AppTheme.spacingLg),
                        child: CircularProgressIndicator(
                          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                        ),
                      ),
                    );
                  }

                  if (jobsState.error != null) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        child: Column(
                          children: [
                            Text(
                              'Error loading jobs',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.errorRed,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            ElevatedButton(
                              onPressed: () => ref.read(jobsNotifierProvider.notifier).refreshJobs(),
                              child: const Text('Retry'),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  if (jobsState.jobs.isEmpty) {
                    return Center(
                      child: Padding(
                        padding: const EdgeInsets.all(AppTheme.spacingLg),
                        child: Column(
                          children: [
                            Icon(
                              Icons.work_off_outlined,
                              size: 48,
                              color: AppTheme.textSecondary,
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            Text(
                              'No jobs available at the moment',
                              style: AppTheme.bodyLarge.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingSm),
                            TextButton(
                              onPressed: () => ref.read(jobsNotifierProvider.notifier).refreshJobs(),
                              child: Text(
                                'Refresh',
                                style: AppTheme.bodyMedium.copyWith(
                                  color: AppTheme.accentCopper,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }

                  return Column(
                    children: jobsState.jobs.take(5).map((job) {
                      return CondensedJobCard(
                        job: job,
                        onTap: () => _showJobDetailsDialog(context, job),
                      );
                    }).toList(),
                  );
                },
              ),

              const SizedBox(height: AppTheme.spacingXxl),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (context) => const ElectricalDemoScreen(),
            ),
          );
        },
        backgroundColor: AppTheme.accentCopper,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.electrical_services),
        label: const Text('⚡ Electrical Demo'),
        tooltip: 'Try the new electrical theme!',
      ),
    );
  }

  Widget _buildElectricalActionCard(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        decoration: BoxDecoration(
          color: AppTheme.white,
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
          boxShadow: [AppTheme.shadowSm],
          border: Border.all(
            color: AppTheme.lightGray,
            width: 1,
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: AppTheme.primaryNavy,
              size: AppTheme.iconLg,
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              title,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.primaryNavy,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }


  void _showJobDetailsDialog(BuildContext context, dynamic job) {
    final jobModel = job is JobsRecord ? _convertJobsRecordToJob(job) : job as Job;
    
    showDialog(
      context: context,
      barrierColor: PopupThemeData.alertDialog().barrierColor,
      builder: (BuildContext context) => PopupTheme(
        data: PopupThemeData.alertDialog(),
        child: AlertDialog(
          backgroundColor: PopupThemeData.alertDialog().backgroundColor,
          shape: RoundedRectangleBorder(
            borderRadius: PopupThemeData.alertDialog().borderRadius,
            side: BorderSide(
              color: PopupThemeData.alertDialog().borderColor,
              width: PopupThemeData.alertDialog().borderWidth,
            ),
          ),
          elevation: PopupThemeData.alertDialog().elevation,
          contentPadding: PopupThemeData.alertDialog().padding,
          title: Text(
            jobModel.company,
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          content: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildDetailRow('Local', jobModel.local?.toString() ?? 'N/A'),
                _buildDetailRow('Classification', jobModel.classification ?? 'N/A'),
                _buildDetailRow('Location', jobModel.location),
                _buildDetailRow('Hours', '${jobModel.hours ?? 'N/A'} hours/week'),
                _buildDetailRow('Wage', jobModel.wage != null ? '\$${jobModel.wage}/hr' : 'N/A'),
                _buildDetailRow('Per Diem', jobModel.perDiem?.isNotEmpty == true ? 'Yes' : 'No'),
                _buildDetailRow('Start Date', jobModel.startDate ?? 'N/A'),
                _buildDetailRow('Duration', jobModel.duration ?? 'N/A'),
                if (jobModel.jobDescription?.isNotEmpty == true) ...[
                  const SizedBox(height: AppTheme.spacingMd),
                  Text(
                    'Description',
                    style: AppTheme.bodyLarge.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingSm),
                  Text(
                    jobModel.jobDescription!,
                    style: AppTheme.bodyMedium,
                  ),
                ],
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text(
                'Close',
                style: TextStyle(color: AppTheme.textSecondary),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.of(context).pop();
                _submitJobApplication(jobModel);
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.primaryNavy,
                foregroundColor: AppTheme.white,
              ),
              child: const Text('Apply'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingXs),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              '$label:',
              style: AppTheme.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  void _submitJobApplication(Job job) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'Application submitted for ${job.classification ?? 'the position'}!',
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: AppTheme.primaryNavy,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  Job _convertJobsRecordToJob(JobsRecord jobsRecord) {
    return Job(
      id: jobsRecord.reference.id,
      reference: jobsRecord.reference,
      company: jobsRecord.company,
      location: jobsRecord.location,
      classification: jobsRecord.classification,
      local: jobsRecord.local,
      wage: jobsRecord.wage,
      hours: jobsRecord.hours,
      perDiem: jobsRecord.perDiem,
      typeOfWork: jobsRecord.typeOfWork,
      startDate: jobsRecord.startDate,
      duration: jobsRecord.duration,
      jobDescription: jobsRecord.jobDescription,
    );
  }
}
