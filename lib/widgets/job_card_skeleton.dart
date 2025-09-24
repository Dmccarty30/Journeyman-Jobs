import 'package:flutter/material.dart';
import '../design_system/app_theme.dart';

/// Skeleton loading card for job listings
/// Matches the design from assets/job-card-skeleton.png
class JobCardSkeleton extends StatefulWidget {
  const JobCardSkeleton({super.key});

  @override
  State<JobCardSkeleton> createState() => _JobCardSkeletonState();
}

class _JobCardSkeletonState extends State<JobCardSkeleton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
    _animationController.repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: AppTheme.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: AppTheme.black.withValues(alpha: 26/255),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Top row with two skeleton blocks
              Row(
                children: [
                  _buildSkeletonBlock(
                    width: 80,
                    height: 20,
                    opacity: _animation.value,
                  ),
                  const Spacer(),
                  _buildSkeletonBlock(
                    width: 60,
                    height: 20,
                    opacity: _animation.value,
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Full width title block
              _buildSkeletonBlock(
                width: double.infinity,
                height: 24,
                opacity: _animation.value,
              ),
              const SizedBox(height: 8),
              
              // Medium width subtitle block
              _buildSkeletonBlock(
                width: MediaQuery.of(context).size.width * 0.6,
                height: 16,
                opacity: _animation.value,
              ),
              const SizedBox(height: 12),
              
              // Bottom row with three blocks
              Row(
                children: [
                  _buildSkeletonBlock(
                    width: 70,
                    height: 16,
                    opacity: _animation.value,
                  ),
                  const SizedBox(width: 12),
                  _buildSkeletonBlock(
                    width: 90,
                    height: 16,
                    opacity: _animation.value,
                  ),
                  const SizedBox(width: 12),
                  _buildSkeletonBlock(
                    width: 80,
                    height: 16,
                    opacity: _animation.value,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildSkeletonBlock({
    required double width,
    required double height,
    required double opacity,
  }) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: AppTheme.lightGray.withValues(alpha: opacity),
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
