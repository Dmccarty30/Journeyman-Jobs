import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';

import '../../utils/text_formatting_wrapper.dart';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../design_system/app_theme.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../navigation/app_router.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import '../../models/job_model.dart';
import '../../legacy/flutterflow/schema/jobs_record.dart';
import '../../widgets/notification_badge.dart';
import '../../widgets/condensed_job_card.dart';
import '../../widgets/dialogs/job_details_dialog.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';


class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  String? _ticketNumber;


  @override
  void initState() {
    super.initState();
    _loadUserData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      ref.read(jobsProvider.notifier).loadJobs();
    });
  }

  Future<void> _loadUserData() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .get();
        
        if (doc.exists && mounted) {
          setState(() {
            _ticketNumber = doc.data()?['ticket_number']?.toString();
          });
        } else if (mounted) {
          setState(() {
          });
        }
      } catch (e) {
        if (mounted) {
          setState(() {
          });
        }
      }
    } else {
      setState(() {
      });
    }
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
              context.push(AppRouter.notificationSettings);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          ElectricalCircuitBackground(
            opacity: 0.35,
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
                      final userModelAsync = ref.watch(userModelStreamProvider);

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
                              _ticketNumber != null ? 'Ticket #$_ticketNumber' : 'IBEW Member',
                              style: AppTheme.bodyMedium.copyWith(
                                color: AppTheme.textSecondary,
                              ),
                            ),
                          ],
                        );
                      }

                      final photoUrl = authState.user?.photoURL;
                      
                      return userModelAsync.when(
                        data: (userModel) {
                          final displayName = '${userModel.firstName} ${userModel.lastName}'.trim();
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
                                      'Welcome back${displayName.isNotEmpty ? ', $displayName' : ', IBEW Member'}!', // Combined personalized greeting
                                      style: AppTheme.headlineMedium.copyWith(
                                        color: AppTheme.primaryNavy,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: AppTheme.spacingSm),
                                    // Removed the separate Text(displayName) widget
                                    Text(
                                      _ticketNumber != null ? 'Ticket #$_ticketNumber' : 'IBEW Member',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
                        loading: () => const CircularProgressIndicator(),
                        error: (err, stack) {
                           return Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundColor: AppTheme.primaryNavy,
                                backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
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
                                      _ticketNumber != null ? 'Ticket #$_ticketNumber' : 'IBEW Member',
                                      style: AppTheme.bodyMedium.copyWith(
                                        color: AppTheme.textSecondary,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          );
                        },
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
                  const SizedBox(height: AppTheme.spacingLg),

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
                                  onPressed: () => ref.read(jobsProvider.notifier).refreshJobs(),
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
                                  onPressed: () => ref.read(jobsProvider.notifier).refreshJobs(),
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

                  const SizedBox(height: AppTheme.spacingXl),
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
          boxShadow: [AppTheme.shadowSm],
          border: Border.all(
            color: AppTheme.accentCopper,
            width: AppTheme.borderWidthCopperThin,
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
