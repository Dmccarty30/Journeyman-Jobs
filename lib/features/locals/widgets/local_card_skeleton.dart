import 'package:flutter/material.dart';
import '../../../design_system/app_theme.dart';

/// Skeleton loader for LocalCard component
///
/// Displays a placeholder card with animated shimmer effect
/// while actual data is loading. Improves perceived performance
/// by showing content structure immediately.
///
/// Uses the same dimensions and layout as the actual LocalCard
/// to prevent layout shift when real content loads.
class LocalCardSkeleton extends StatefulWidget {
  /// Creates a skeleton loader for a local card
  const LocalCardSkeleton({super.key});

  @override
  State<LocalCardSkeleton> createState() => _LocalCardSkeletonState();
}

class _LocalCardSkeletonState extends State<LocalCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create shimmer animation
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );

    _animation = Tween<double>(begin: -2.0, end: 2.0).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutSine,
      ),
    );

    // Start repeating animation
    _animationController.repeat();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.only(bottom: AppTheme.spacingMd),
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppTheme.radiusLg),
        side: BorderSide(
          color: AppTheme.accentCopper.withAlpha(77),
          width: AppTheme.borderWidthThin,
        ),
      ),
      child: Container(
        padding: const EdgeInsets.all(AppTheme.spacingLg),
        height: 180, // Match approximate LocalCard height
        child: AnimatedBuilder(
          animation: _animation,
          builder: (context, child) {
            return Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header row
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              // Local number
                              _buildShimmerBox(
                                width: 120,
                                height: 24,
                                borderRadius: AppTheme.radiusSm,
                              ),
                              const SizedBox(height: AppTheme.spacingXs),
                              // City, State
                              _buildShimmerBox(
                                width: 150,
                                height: 16,
                                borderRadius: AppTheme.radiusSm,
                              ),
                            ],
                          ),
                        ),
                        // Arrow icon skeleton
                        Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: AppTheme.lightGray,
                            borderRadius: BorderRadius.circular(AppTheme.radiusRound),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: AppTheme.spacingMd),
                    // Content rows
                    _buildInfoRowSkeleton(),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildInfoRowSkeleton(),
                    const SizedBox(height: AppTheme.spacingSm),
                    _buildInfoRowSkeleton(),
                  ],
                ),
                // Shimmer overlay
                Positioned.fill(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
                    child: _buildShimmerGradient(),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  /// Builds a single skeleton info row (icon + text)
  Widget _buildInfoRowSkeleton() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Icon skeleton
        Container(
          width: AppTheme.iconMd,
          height: AppTheme.iconMd,
          decoration: BoxDecoration(
            color: AppTheme.lightGray,
            borderRadius: BorderRadius.circular(AppTheme.radiusSm),
          ),
        ),
        const SizedBox(width: AppTheme.spacingSm),
        // Text skeleton
        Expanded(
          child: _buildShimmerBox(
            width: double.infinity,
            height: 14,
            borderRadius: AppTheme.radiusSm,
          ),
        ),
      ],
    );
  }

  /// Builds a shimmer box with specified dimensions
  Widget _buildShimmerBox({
    required double width,
    required double height,
    required double borderRadius,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(borderRadius),
      ),
    );
  }

  /// Builds the animated shimmer gradient overlay
  Widget _buildShimmerGradient() {
    final value = _animation.value;

    return Transform.translate(
      offset: Offset(value * MediaQuery.of(context).size.width, 0),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Colors.transparent,
              AppTheme.white.withAlpha(26),
              AppTheme.white.withAlpha(51),
              AppTheme.white.withAlpha(26),
              Colors.transparent,
            ],
            stops: const [0.0, 0.4, 0.5, 0.6, 1.0],
          ),
        ),
      ),
    );
  }
}

/// Skeleton loader grid for multiple LocalCards
///
/// Displays a list of skeleton cards while data loads.
/// Automatically handles scroll behavior.
class LocalsListSkeleton extends StatelessWidget {
  /// Number of skeleton cards to display
  final int itemCount;

  /// Creates a skeleton list with specified number of items
  const LocalsListSkeleton({
    super.key,
    this.itemCount = 5,
  });

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      physics: const NeverScrollableScrollPhysics(),
      shrinkWrap: true,
      itemCount: itemCount,
      itemBuilder: (context, index) {
        return const LocalCardSkeleton();
      },
    );
  }
}
