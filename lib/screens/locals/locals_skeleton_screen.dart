import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/widgets/jj_skeleton_loader.dart';

/// Skeleton loading screen for IBEW Locals directory.
///
/// Displays animated placeholders while auth initializes and locals data loads.
/// Maintains electrical theme with circuit pattern overlays and shimmer effects.
///
/// This skeleton screen:
/// - Prevents flash of permission denied errors during auth initialization
/// - Provides visual feedback that content is loading
/// - Maintains layout structure identical to actual LocalsScreen
/// - Uses electrical-themed animations consistent with app design
///
/// Automatically shown by LocalsScreen when authInitializationProvider
/// is in loading state.
class LocalsSkeletonScreen extends StatelessWidget {
  const LocalsSkeletonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        title: const JJSkeletonLoader(
          width: 120,
          height: 24,
          borderRadius: 4,
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Search bar skeleton
            // Mimics the search TextField in LocalsScreen AppBar bottom
            const JJSkeletonLoader(
              width: double.infinity,
              height: 56,
              borderRadius: 12,
              margin: EdgeInsets.only(bottom: 16),
            ),

            // State filter dropdown skeleton
            // Matches the dropdown in LocalsScreen
            const JJSkeletonLoader(
              width: double.infinity,
              height: 48,
              borderRadius: 12,
              margin: EdgeInsets.only(bottom: 16),
            ),

            const SizedBox(height: 8),

            // Locals list skeleton
            // Shows 8 placeholder cards to fill viewport
            Expanded(
              child: ListView.builder(
                itemCount: 8,
                itemBuilder: (context, index) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12.0),
                    child: _LocalCardSkeleton(),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Individual local card skeleton.
///
/// Replicates the structure of LocalCard widget with shimmer placeholders
/// for all text and icon elements. Uses circuit pattern overlay on the
/// local number to enhance electrical theme.
class _LocalCardSkeleton extends StatelessWidget {
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
          // Local number skeleton with circuit pattern
          // Matches "Local ###" text in actual card
          JJSkeletonLoader(
            width: 100,
            height: 20,
            borderRadius: 4,
            showCircuitPattern: true,
          ),

          const SizedBox(height: 8),

          // Local name/city skeleton
          // Matches city, state display
          const JJSkeletonLoader(
            width: double.infinity,
            height: 16,
            borderRadius: 4,
          ),

          const SizedBox(height: 12),

          // Location row skeleton
          // Mimics address info row with icon
          Row(
            children: [
              JJSkeletonLoader(
                width: 16,
                height: 16,
                borderRadius: 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: JJSkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Phone row skeleton
          Row(
            children: [
              JJSkeletonLoader(
                width: 16,
                height: 16,
                borderRadius: 2,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: JJSkeletonLoader(
                  width: double.infinity,
                  height: 14,
                  borderRadius: 4,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Classification chips skeleton
          // Matches classification badges in actual card
          Row(
            children: List.generate(
              3,
              (index) => Padding(
                padding: const EdgeInsets.only(right: 6.0),
                child: JJSkeletonLoader(
                  width: 60,
                  height: 24,
                  borderRadius: 12,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
