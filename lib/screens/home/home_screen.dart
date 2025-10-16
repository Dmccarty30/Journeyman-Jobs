import '../../utils/text_formatting_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../navigation/app_router.dart';
import '../../providers/riverpod/jobs_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../providers/riverpod/user_preferences_riverpod_provider.dart';
import '../../widgets/dialogs/user_job_preferences_dialog.dart';
import '../../models/user_job_preferences.dart';
import '../../features/crews/providers/crews_riverpod_provider.dart';
import '../../models/job_model.dart';
import '../../legacy/flutterflow/schema/jobs_record.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/condensed_job_card.dart';
import '../../widgets/dialogs/job_details_dialog.dart';

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
      final prefsState = ref.read(userPreferencesProvider);
      if (prefsState.preferences != UserJobPreferences.empty()) {
        final filter = prefsState.preferences.toFilterCriteria();
        ref.read(jobsProvider.notifier).loadJobs(filter: filter);
      } else {
        ref.read(jobsProvider.notifier).loadJobs();
      }
    });
    // Listen for preference changes to reload jobs with new filter
    ref.listen(userPreferencesProvider, (previous, next) {
      if (next.preferences != UserJobPreferences.empty()) {
        final filter = next.preferences.toFilterCriteria();
        ref.read(jobsProvider.notifier).loadJobs(filter: filter);
      }
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
      body: Stack(
        children: [
          ElectricalCircuitBackground(
            opacity: 0.08,
            componentDensity: ComponentDensity.high,
          ),
          RefreshIndicator(
            onRefresh: () => ref.read(jobsProvider.notifier).refreshJobs(),
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Consumer(
                    builder: (context, ref, child) {
                      final authState = ref.watch(authProvider);
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
                  Consumer(
                    builder: (context, ref, child) {
                      final prefsState = ref.watch(userPreferencesProvider);
                      final hasPrefs = prefsState.preferences != UserJobPreferences.empty();
                      if (!hasPrefs) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: AppTheme.spacingLg),
                          child: ElevatedButton(
                            onPressed: () async {
                              final authState = ref.read(authProvider);
                              final result = await showDialog<bool>(
                                context: context,
                                builder: (_) => UserJobPreferencesDialog(
                                  isFirstTime: true,
                                  userId: authState.user?.uid ?? '',
                                ),
                              );
                            if (result == true) {
                              final newPrefs = ref.read(userPreferencesProvider).preferences;
                              final filter = newPrefs.toFilterCriteria();
                                ref.read(jobsProvider.notifier).loadJobs(filter: filter);
                              }
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppTheme.accentCopper,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                              ),
                            ),
                            child: Text(
                              'Set Preferences',
                              style: AppTheme.buttonMedium.copyWith(color: AppTheme.white),
                            ),
                          ),
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

                  Text(
                    'Quick Actions',
                    style: AppTheme.headlineSmall.copyWith(
                      color: AppTheme.primaryNavy,
                    ),
                  ),
                  const SizedBox(height: AppTheme.spacingLg),

                  Consumer(
                    builder: (context, ref, child) {
                      final userCrews = ref.watch(userCrewsProvider);
                      if (userCrews.isNotEmpty) {
                        return Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Active Crews',
                              style: AppTheme.headlineSmall.copyWith(
                                color: AppTheme.primaryNavy,
                              ),
                            ),
                            const SizedBox(height: AppTheme.spacingMd),
                            _buildActiveCrewsWidget(userCrews),
                            const SizedBox(height: AppTheme.spacingLg),
                          ],
                        );
                      }
                      return const SizedBox.shrink();
                    },
                  ),

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
                      final jobsState = ref.watch(jobsProvider);
                      if (jobsState.isLoading) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingMd),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(
                                  color: AppTheme.accentCopper,
                                  width: AppTheme.borderWidthCopper,
                                ),
                                boxShadow: [
                                  AppTheme.shadowElectricalInfo,
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  SizedBox(
                                    width: 40,
                                    height: 40,
                                    child: CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                                      strokeWidth: 3,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  Text(
                                    'Loading electrical opportunities...',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.primaryNavy,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (jobsState.error != null) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(
                                  color: AppTheme.errorRed,
                                  width: AppTheme.borderWidthCopper,
                                ),
                                boxShadow: [
                                  AppTheme.shadowElectricalError,
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.error_outline,
                                    size: 48,
                                    color: AppTheme.errorRed,
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  Text(
                                    'Circuit malfunction detected',
                                    style: AppTheme.headlineSmall.copyWith(
                                      color: AppTheme.primaryNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  Text(
                                    'Unable to load electrical opportunities. Please check your connection and try again.',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.buttonGradient,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(
                                        color: AppTheme.accentCopper,
                                        width: AppTheme.borderWidthCopper,
                                      ),
                                      boxShadow: [
                                        AppTheme.shadowElectricalInfo,
                                      ],
                                    ),
                                    child: ElevatedButton(
                                      onPressed: () => ref.read(jobsProvider.notifier).refreshJobs(),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: Colors.transparent,
                                        shadowColor: Colors.transparent,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                        ),
                                      ),
                                      child: Text(
                                        '🔄 Reconnect Power',
                                        style: AppTheme.buttonMedium.copyWith(
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }

                      if (jobsState.jobs.isEmpty) {
                        return Center(
                          child: Padding(
                            padding: const EdgeInsets.all(AppTheme.spacingLg),
                            child: Container(
                              padding: const EdgeInsets.all(AppTheme.spacingLg),
                              decoration: BoxDecoration(
                                color: AppTheme.white.withValues(alpha: 0.9),
                                borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                border: Border.all(
                                  color: AppTheme.warningYellow,
                                  width: AppTheme.borderWidthCopper,
                                ),
                                boxShadow: [
                                  AppTheme.shadowElectricalWarning,
                                ],
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Icon(
                                    Icons.flash_off_outlined,
                                    size: 48,
                                    color: AppTheme.warningYellow,
                                  ),
                                  const SizedBox(height: AppTheme.spacingMd),
                                  Text(
                                    'Power Grid Status: Standby',
                                    style: AppTheme.headlineSmall.copyWith(
                                      color: AppTheme.primaryNavy,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  const SizedBox(height: AppTheme.spacingSm),
                                  Text(
                                    'No electrical opportunities available right now. Check back soon for new connections.',
                                    style: AppTheme.bodyMedium.copyWith(
                                      color: AppTheme.textSecondary,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                  const SizedBox(height: AppTheme.spacingLg),
                                  Container(
                                    width: double.infinity,
                                    height: 48,
                                    decoration: BoxDecoration(
                                      gradient: AppTheme.buttonGradient,
                                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                      border: Border.all(
                                        color: AppTheme.accentCopper,
                                        width: AppTheme.borderWidthCopper,
                                      ),
                                      boxShadow: [
                                        AppTheme.shadowElectricalInfo,
                                      ],
                                    ),
                                    child: TextButton(
                                      onPressed: () => ref.read(jobsProvider.notifier).refreshJobs(),
                                      style: TextButton.styleFrom(
                                        foregroundColor: AppTheme.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                                        ),
                                      ),
                                      child: Text(
                                        '🔄 Scan for Power',
                                        style: AppTheme.buttonMedium.copyWith(
                                          color: AppTheme.white,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
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
        ],
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
          boxShadow: [
            AppTheme.shadowSm,
            AppTheme.shadowElectricalInfo,
          ],
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopper,
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

  Widget _buildActiveCrewsWidget(List<dynamic> userCrews) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          AppTheme.shadowSm,
          AppTheme.shadowElectricalInfo,
        ],
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthCopper,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                Icons.group,
                color: AppTheme.accentCopper,
                size: AppTheme.iconMd,
              ),
              const SizedBox(width: AppTheme.spacingSm),
              Text(
                '${userCrews.length} Active Crew${userCrews.length == 1 ? '' : 's'}',
                style: AppTheme.bodyLarge.copyWith(
                  color: AppTheme.primaryNavy,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Collaborate with your team on shared jobs and opportunities.',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: () {
                // Navigate to Crews tab
                context.go(AppRouter.crews);
              },
              icon: const Icon(Icons.arrow_forward),
              label: const Text('View Crews'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(vertical: 12),
                textStyle: AppTheme.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusSm),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }


  void _showJobDetailsDialog(BuildContext context, dynamic job) {
    final jobModel = job is JobsRecord ? _convertJobsRecordToJob(job) : job as Job;
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(job: jobModel),
    );
  }


  Job _convertJobsRecordToJob(JobsRecord jobsRecord) {
    return Job(
      id: jobsRecord.reference.id,
      reference: jobsRecord.reference,
      sharerId: jobsRecord.reference.id, // Using the document ID as sharerId
      jobDetails: {
        'company': jobsRecord.company,
        'location': jobsRecord.location,
        'classification': jobsRecord.classification,
        'local': jobsRecord.local,
        'wage': jobsRecord.wage,
        'hours': jobsRecord.hours,
        'perDiem': jobsRecord.perDiem,
        'typeOfWork': jobsRecord.typeOfWork,
        'startDate': jobsRecord.startDate,
        'duration': jobsRecord.duration,
        'jobDescription': jobsRecord.jobDescription,
      },
      company: toTitleCase(jobsRecord.company),
      location: toTitleCase(jobsRecord.location),
      classification: toTitleCase(jobsRecord.classification),
      local: jobsRecord.local,
      wage: jobsRecord.wage,
      hours: jobsRecord.hours,
      perDiem: jobsRecord.perDiem,
      typeOfWork: toTitleCase(jobsRecord.typeOfWork),
      startDate: jobsRecord.startDate,
      duration: jobsRecord.duration,
      jobDescription: jobsRecord.jobDescription,
    );
  }
}
