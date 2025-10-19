import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/widgets/jj_skeleton_loader.dart';

/// Skeleton loading screen for Jobs/Home screen.
///
/// Displays animated placeholders while auth initializes and job data loads.
/// Maintains electrical theme and matches HomeScreen layout structure.
///
/// This skeleton screen:
/// - Prevents flash of permission denied errors during auth initialization
/// - Provides immediate visual feedback that content is loading
/// - Maintains identical layout to actual HomeScreen for smooth transition
/// - Uses electrical-themed animations (shimmer, circuit patterns)
///
/// Automatically shown by HomeScreen when authInitializationProvider
/// is in loading state.
class HomeSkeletonScreen extends StatelessWidget {
  const HomeSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: Row(
          children: [
            // App icon skeleton
            JJSkeletonLoader(
              width: 32,
              height: 32,
              borderRadius: 16,
            ),
            const SizedBox(width: AppTheme.spacingSm),
            // App title skeleton
            const JJSkeletonLoader(
              width: 140,
              height: 24,
              borderRadius: 4,
            ),
          ],
        ),
        actions: [
          // Notification badge skeleton
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: JJSkeletonLoader(
              width: 40,
              height: 40,
              borderRadius: 20,
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Welcome header skeleton
              // Matches "Welcome Back, [Name]!" text
              const JJSkeletonLoader(
                width: 200,
                height: 28,
                borderRadius: 4,
                margin: EdgeInsets.only(bottom: 8),
              ),

              // User subtitle skeleton
              const JJSkeletonLoader(
                width: 150,
                height: 16,
                borderRadius: 4,
                margin: EdgeInsets.only(bottom: 24),
              ),

              // Quick Actions section title skeleton
              const JJSkeletonLoader(
                width: 120,
                height: 20,
                borderRadius: 4,
                margin: EdgeInsets.only(bottom: 16),
              ),

              // Quick action cards skeleton
              // Matches the two-column action card layout
              Row(
                children: [
                  Expanded(
                    child: _ActionCardSkeleton(),
                  ),
                  const SizedBox(width: AppTheme.spacingMd),
                  Expanded(
                    child: _ActionCardSkeleton(),
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingLg),

              // "Suggested Jobs" section header skeleton
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const JJSkeletonLoader(
                    width: 120,
                    height: 20,
                    borderRadius: 4,
                  ),
                  JJSkeletonLoader(
                    width: 70,
                    height: 16,
                    borderRadius: 4,
                  ),
                ],
              ),

              const SizedBox(height: AppTheme.spacingMd),

              // Job cards skeleton
              // Shows 5 placeholder job cards
              ...List.generate(
                5,
                (index) => Padding(
                  padding: const EdgeInsets.only(bottom: 12.0),
                  child: _JobCardSkeleton(),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

/// Individual job card skeleton.
///
/// Replicates the CondensedJobCard structure with shimmer placeholders
/// for job title, company, local info, and job details.
class _JobCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Job title and wage badge skeleton
          Row(
            children: [
              Expanded(
                child: JJSkeletonLoader(
                  width: double.infinity,
                  height: 20,
                  borderRadius: 4,
                  showCircuitPattern: true,
                ),
              ),
              const SizedBox(width: 12),
              // Wage badge skeleton
              JJSkeletonLoader(
                width: 60,
                height: 24,
                borderRadius: 12,
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Local info row skeleton
          // Avatar + text layout
          Row(
            children: [
              // Local avatar skeleton
              JJSkeletonLoader(
                width: 40,
                height: 40,
                borderRadius: 20,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Company name skeleton
                    JJSkeletonLoader(
                      width: double.infinity,
                      height: 14,
                      borderRadius: 4,
                    ),
                    const SizedBox(height: 6),
                    // Local number skeleton
                    JJSkeletonLoader(
                      width: 120,
                      height: 12,
                      borderRadius: 4,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: 12),

          // Location detail skeleton
          Row(
            children: [
              JJSkeletonLoader(
                width: 16,
                height: 16,
                borderRadius: 2,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: JJSkeletonLoader(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Classification detail skeleton
          Row(
            children: [
              JJSkeletonLoader(
                width: 16,
                height: 16,
                borderRadius: 2,
              ),
              const SizedBox(width: 6),
              Expanded(
                child: JJSkeletonLoader(
                  width: double.infinity,
                  height: 12,
                  borderRadius: 4,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

/// Action card skeleton for Quick Actions section.
///
/// Replicates the electrical action card design with
/// icon and text placeholders.
class _ActionCardSkeleton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        boxShadow: [
          AppTheme.shadowSm,
        ],
        border: Border.all(
          color: AppTheme.accentCopper,
          width: AppTheme.borderWidthCopper,
        ),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon skeleton
          JJSkeletonLoader(
            width: AppTheme.iconLg,
            height: AppTheme.iconLg,
            borderRadius: 4,
          ),
          const SizedBox(height: AppTheme.spacingSm),
          // Text skeleton
          JJSkeletonLoader(
            width: 80,
            height: 14,
            borderRadius: 4,
          ),
        ],
      ),
    );
  }
}
