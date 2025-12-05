import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';
import 'package:journeyman_jobs/features/crews/providers/crews_riverpod_provider.dart';
import 'package:journeyman_jobs/legacy/flutterflow/schema/jobs_record.dart';
import 'package:journeyman_jobs/models/job_model.dart';
import 'package:journeyman_jobs/models/user_model.dart';
import 'package:journeyman_jobs/navigation/app_router.dart';
import 'package:journeyman_jobs/providers/riverpod/auth_riverpod_provider.dart';
import 'package:journeyman_jobs/providers/riverpod/jobs_riverpod_provider.dart';
import 'package:journeyman_jobs/utils/text_formatting_wrapper.dart';
import 'package:journeyman_jobs/widgets/condensed_job_card.dart';
import 'package:journeyman_jobs/widgets/dialogs/job_details_dialog.dart';
import 'package:journeyman_jobs/widgets/notification_badge.dart';
import 'package:journeyman_jobs/screens/component_demo_screen.dart';
import 'package:journeyman_jobs/widgets/jj_button.dart';

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
      ref.read(jobsProvider.notifier).loadJobs();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: _buildAppBar(context),
      body: Stack(
        children: [
          const ElectricalCircuitBackground(
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
                  _buildWelcomeSection(ref),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildQuickActions(context, ref),
                  const SizedBox(height: AppTheme.spacingLg),
                  _buildSuggestedJobsHeader(context),
                  const SizedBox(height: AppTheme.spacingMd),
                  _buildSuggestedJobsList(ref),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  AppBar _buildAppBar(BuildContext context) {
    return AppBar(
      backgroundColor: AppTheme.primaryNavy,
      elevation: 0,
      title: Row(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: const BoxDecoration(
              gradient: AppTheme.buttonGradient,
              shape: BoxShape.circle,
            ),
            child: const Padding(
              padding: EdgeInsets.all(6),
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
    );
  }

  Widget _buildWelcomeSection(WidgetRef ref) {
    final authState = ref.watch(authProvider);
    final userModelAsync = ref.watch(userModelStreamProvider);

    if (!authState.isAuthenticated) {
      return _buildGuestWelcome();
    }

    return userModelAsync.when(
      data: (userModel) => _buildUserWelcome(userModel),
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, stack) => _buildErrorWelcome(),
    );
  }

  Widget _buildGuestWelcome() {
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
          'IBEW Member',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  Widget _buildUserWelcome(UserModel userModel) {
    final photoUrl = userModel.avatarUrl;
    final displayName = '${userModel.firstName} ${userModel.lastName}'.trim();
    final userInitial =
        displayName.isNotEmpty ? displayName[0].toUpperCase() : 'U';
    final ticketNumber = userModel.ticketNumber;

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
              if (displayName.isNotEmpty) ...[
                const SizedBox(height: AppTheme.spacingXs),
                Text(
                  displayName,
                  style: AppTheme.titleMedium.copyWith(
                    color: AppTheme.primaryNavy,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
              const SizedBox(height: AppTheme.spacingSm),
              Text(
                ticketNumber.isNotEmpty
                    ? 'Ticket #$ticketNumber'
                    : 'IBEW Member',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildErrorWelcome() {
    return Row(
      children: [
        const CircleAvatar(
          radius: 30,
          backgroundColor: AppTheme.primaryNavy,
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
                'IBEW Member',
                style: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.textSecondary,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildQuickActions(BuildContext context, WidgetRef ref) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        const SizedBox(height: AppTheme.spacingLg),
        Row(
          children: [
            Expanded(
              child: _buildElectricalActionCard(
                'Electrical Calc',
                Icons.calculate_outlined,
                () => context.push(AppRouter.electricalCalculators),
              ),
            ),
            const SizedBox(width: AppTheme.spacingMd),
            Expanded(
              child: Consumer(
                builder: (context, ref, child) {
                  final userCrews = ref.watch(userCrewsProvider);
                  if (userCrews.isNotEmpty) {
                    return _buildElectricalActionCard(
                      'View Crews',
                      Icons.group_outlined,
                      () => context.push(AppRouter.crews),
                    );
                  }
                  return const SizedBox();
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: AppTheme.spacingMd),
        JJButton(
          text: 'View Component Demo',
          icon: Icons.design_services,
          variant: JJButtonVariant.secondary,
          isFullWidth: true,
          onPressed: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => const ComponentDemoScreen(),
              ),
            );
          },
        ),
      ],
    );
  }

  Widget _buildElectricalActionCard(
      String title, IconData icon, VoidCallback onTap) {
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

  Widget _buildSuggestedJobsHeader(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          'Suggested Jobs',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        TextButton(
          onPressed: () => context.push(AppRouter.jobs),
          child: Text(
            'View All',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.accentCopper,
              fontWeight: FontWeight.bold,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildSuggestedJobsList(WidgetRef ref) {
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
              const Icon(
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
  }

  void _showJobDetailsDialog(BuildContext context, dynamic job) {
    final jobModel =
        job is JobsRecord ? _convertJobsRecordToJob(job) : job as Job;
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(job: jobModel),
    );
  }

  Job _convertJobsRecordToJob(JobsRecord jobsRecord) {
    return Job(
      id: jobsRecord.reference.id,
      reference: jobsRecord.reference,
      sharerId: jobsRecord.reference.id,
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
