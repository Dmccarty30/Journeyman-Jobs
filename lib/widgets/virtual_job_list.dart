import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../design_system/app_theme.dart';
import '../design_system/components/job_card.dart';
import '../models/job_model.dart';
import '../providers/riverpod/app_state_riverpod_provider.dart';
import '../providers/riverpod/jobs_riverpod_provider.dart';
import '../services/connectivity_service.dart';

/// High-performance virtual scrolling job list with infinite loading
/// 
/// Optimized for large datasets with efficient memory management,
/// smooth scrolling, and automatic load-more functionality.
class VirtualJobList extends ConsumerStatefulWidget {
  /// List of jobs to display
  final List<Job> jobs;
  
  /// Callback when more jobs need to be loaded
  final VoidCallback? onLoadMore;
  
  /// Whether loading indicator should be shown
  final bool isLoading;
  
  /// Whether there are more jobs to load
  final bool hasMore;
  
  /// Card variant to use for job display
  final JobCardVariant variant;
  
  /// Custom item height for performance optimization
  final double? itemHeight;
  
  /// Scroll threshold for triggering load more (0.0 to 1.0)
  final double loadMoreThreshold;
  
  /// Custom empty state widget
  final Widget? emptyWidget;
  
  /// Custom error widget
  final Widget? errorWidget;
  
  /// Error message if any
  final String? error;
  
  /// Whether to show offline indicators
  final bool showOfflineIndicators;

  const VirtualJobList({
    super.key,
    required this.jobs,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.variant = JobCardVariant.full,
    this.itemHeight,
    this.loadMoreThreshold = 0.8,
    this.emptyWidget,
    this.errorWidget,
    this.error,
    this.showOfflineIndicators = true,
  });

  @override
  ConsumerState<VirtualJobList> createState() => _VirtualJobListState();
}

class _VirtualJobListState extends ConsumerState<VirtualJobList> with AutomaticKeepAliveClientMixin {
  late ScrollController _scrollController;
  bool _isLoadingMore = false;
  
  // Performance optimization - estimated item heights
  static const double _loadMoreHeight = 80.0;
  
  @override
  bool get wantKeepAlive => true;

  @override
  void initState() {
    super.initState();
    _scrollController = ScrollController();
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    super.dispose();
  }

  /// Handle scroll events for infinite loading
  void _onScroll() {
    if (_isLoadingMore || !widget.hasMore || widget.onLoadMore == null) return;
    
    final position = _scrollController.position;
    final threshold = position.maxScrollExtent * widget.loadMoreThreshold;
    
    if (position.pixels >= threshold) {
      _loadMore();
    }
  }

  /// Trigger load more with debouncing
  void _loadMore() async {
    if (_isLoadingMore) return;
    
    setState(() {
      _isLoadingMore = true;
    });
    
    // Add small delay to prevent rapid firing
    await Future.delayed(const Duration(milliseconds: 100));
    
    widget.onLoadMore?.call();
    
    // Reset loading state after a reasonable delay
    if (mounted) {
      await Future.delayed(const Duration(milliseconds: 500));
      if (mounted) {
        setState(() {
          _isLoadingMore = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    
    // Handle error state
    if (widget.error != null) {
      return widget.errorWidget ?? _buildErrorState();
    }
    
    // Handle empty state
    if (widget.jobs.isEmpty && !widget.isLoading) {
      return widget.emptyWidget ?? _buildEmptyState();
    }
    
    // Handle loading state for initial load
    if (widget.jobs.isEmpty && widget.isLoading) {
      return _buildLoadingState();
    }
    
    return _buildJobList();
  }

  /// Build the main job list with virtual scrolling
  Widget _buildJobList() {
    final itemCount = widget.jobs.length + (widget.hasMore ? 1 : 0);
    
    return CustomScrollView(
      controller: _scrollController,
      physics: const AlwaysScrollableScrollPhysics(),
      slivers: [
        // Offline indicator at top if needed
        if (widget.showOfflineIndicators)
          Consumer(
            builder: (context, ref, child) {
              final connectivity = ref.watch(connectivityServiceProvider);
              if (connectivity.isOffline) {
                return SliverToBoxAdapter(
                  child: Container(
                    padding: const EdgeInsets.all(12),
                    margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppTheme.warningYellow.withOpacity(0.1),
                      border: Border.all(color: AppTheme.warningYellow),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      children: [
                        Icon(Icons.offline_bolt, color: AppTheme.warningYellow, size: 16),
                        const SizedBox(width: 8),
                        Text(
                          'Showing cached jobs (offline)',
                          style: AppTheme.bodySmall.copyWith(
                            color: AppTheme.textDark,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }
              return const SliverToBoxAdapter(child: SizedBox.shrink());
            },
          ),
        
        // Main job list
        SliverList.builder(
          itemCount: itemCount,
          itemBuilder: (context, index) {
            // Load more indicator
            if (index == widget.jobs.length) {
              return _buildLoadMoreIndicator();
            }
            
            // Job card
            return _buildJobItem(widget.jobs[index], index);
          },
        ),
      ],
    );
  }

  /// Build individual job item with optimizations
  Widget _buildJobItem(Job job, int index) {
    return RepaintBoundary(
      key: ValueKey(job.id),
      child: Container(
        margin: const EdgeInsets.symmetric(
          horizontal: AppTheme.spacingMd,
          vertical: AppTheme.spacingSm,
        ),
        child: JobCard(
          job: job,
          variant: widget.variant,
          onTap: () => _handleJobTap(job, index),
          onViewDetails: () => _handleJobDetails(job, index),
          onBidNow: () => _handleJobBid(job, index),
          onFavorite: () => _handleJobFavorite(job, index),
          isFavorited: false, // TODO: Implement favorites tracking
        ),
      ),
    );
  }

  /// Build load more indicator
  Widget _buildLoadMoreIndicator() {
    return Container(
      height: _loadMoreHeight,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      child: Center(
        child: widget.isLoading || _isLoadingMore
            ? _buildLoadingSpinner()
            : _buildLoadMoreButton(),
      ),
    );
  }

  /// Build loading spinner
  Widget _buildLoadingSpinner() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SizedBox(
          width: 20,
          height: 20,
          child: CircularProgressIndicator(
            strokeWidth: 2,
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
          ),
        ),
        const SizedBox(width: 12),
        Text(
          'Loading more jobs...',
          style: AppTheme.bodyMedium.copyWith(
            color: AppTheme.textSecondary,
          ),
        ),
      ],
    );
  }

  /// Build load more button
  Widget _buildLoadMoreButton() {
    return ElevatedButton.icon(
      onPressed: widget.hasMore ? _loadMore : null,
      icon: Icon(Icons.refresh, size: 16),
      label: Text(widget.hasMore ? 'Load More Jobs' : 'No More Jobs'),
      style: ElevatedButton.styleFrom(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppTheme.radiusMd),
        ),
      ),
    );
  }

  /// Build initial loading state
  Widget _buildLoadingState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
          ),
          const SizedBox(height: AppTheme.spacingMd),
          Text(
            'Loading job opportunities...',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.textSecondary,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Finding the best matches for you',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textLight,
            ),
          ),
        ],
      ),
    );
  }

  /// Build empty state
  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.work_off_outlined,
            size: 80,
            color: AppTheme.textLight,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'No Jobs Available',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.textDark,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            'Check back later for new opportunities\nor adjust your search filters',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () => _refreshJobs(),
            icon: Icon(Icons.refresh),
            label: const Text('Refresh'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state
  Widget _buildErrorState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.error_outline,
            size: 80,
            color: AppTheme.errorRed,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          Text(
            'Unable to Load Jobs',
            style: AppTheme.headlineMedium.copyWith(
              color: AppTheme.errorRed,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: AppTheme.spacingSm),
          Text(
            widget.error ?? 'Please check your connection and try again',
            style: AppTheme.bodyMedium.copyWith(
              color: AppTheme.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppTheme.spacingLg),
          ElevatedButton.icon(
            onPressed: () => _refreshJobs(),
            icon: Icon(Icons.refresh),
            label: const Text('Retry'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.errorRed,
              foregroundColor: AppTheme.white,
            ),
          ),
        ],
      ),
    );
  }

  /// Handle job tap
  void _handleJobTap(Job job, int index) {
    // Navigate to job details
    // TODO: Implement navigation
    debugPrint('Job tapped: ${job.id}');
  }

  /// Handle job details
  void _handleJobDetails(Job job, int index) {
    // Show job details modal/sheet
    // TODO: Implement job details
    debugPrint('Job details: ${job.id}');
  }

  /// Handle job bid
  void _handleJobBid(Job job, int index) {
    // Navigate to bidding interface
    // TODO: Implement bidding
    debugPrint('Job bid: ${job.id}');
  }

  /// Handle job favorite
  void _handleJobFavorite(Job job, int index) {
    // Toggle favorite status
    // TODO: Implement favorites
    debugPrint('Job favorite: ${job.id}');
  }

  /// Refresh job list
  void _refreshJobs() {
    ref.read(jobsNotifierProvider.notifier).refreshJobs();
  }
}

/// Optimized job list item for better performance
class OptimizedJobListItem extends StatelessWidget {
  final Job job;
  final JobCardVariant variant;
  final VoidCallback? onTap;
  final VoidCallback? onViewDetails;
  final VoidCallback? onBidNow;
  final VoidCallback? onFavorite;
  final bool isFavorited;

  const OptimizedJobListItem({
    super.key,
    required this.job,
    this.variant = JobCardVariant.full,
    this.onTap,
    this.onViewDetails,
    this.onBidNow,
    this.onFavorite,
    this.isFavorited = false,
  });

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: JobCard(
        job: job,
        variant: variant,
        onTap: onTap,
        onViewDetails: onViewDetails,
        onBidNow: onBidNow,
        onFavorite: onFavorite,
        isFavorited: isFavorited,
      ),
    );
  }
}

/// Sliver version for CustomScrollView integration
class SliverVirtualJobList extends StatelessWidget {
  final List<Job> jobs;
  final VoidCallback? onLoadMore;
  final bool isLoading;
  final bool hasMore;
  final JobCardVariant variant;
  final double loadMoreThreshold;

  const SliverVirtualJobList({
    super.key,
    required this.jobs,
    this.onLoadMore,
    this.isLoading = false,
    this.hasMore = true,
    this.variant = JobCardVariant.full,
    this.loadMoreThreshold = 0.8,
  });

  @override
  Widget build(BuildContext context) {
    final itemCount = jobs.length + (hasMore ? 1 : 0);
    
    return SliverList.builder(
      itemCount: itemCount,
      itemBuilder: (context, index) {
        if (index == jobs.length) {
          // Load more indicator
          return Container(
            height: 80,
            padding: const EdgeInsets.all(16),
            child: Center(
              child: isLoading
                  ? CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
                    )
                  : ElevatedButton(
                      onPressed: hasMore ? onLoadMore : null,
                      child: Text(hasMore ? 'Load More' : 'No More Jobs'),
                    ),
            ),
          );
        }
        
        // Job item
        return OptimizedJobListItem(
          job: jobs[index],
          variant: variant,
        );
      },
    );
  }
}
