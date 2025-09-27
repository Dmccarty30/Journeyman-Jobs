import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../design_system/app_theme.dart';
import '../../models/job_model.dart';
import '../../providers/riverpod/jobs_riverpod_provider.dart';
import '../../widgets/rich_text_job_card.dart';
import '../../widgets/job_card_skeleton.dart';
import '../../widgets/dialogs/job_details_dialog.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../navigation/app_router.dart';

class JobsScreen extends ConsumerStatefulWidget {
  const JobsScreen({super.key});

  static String routeName = 'jobs';
  static String routePath = '/jobs';

  @override
  ConsumerState<JobsScreen> createState() => _JobsScreenState();
}

class _JobsScreenState extends ConsumerState<JobsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  String _selectedFilter = 'All Jobs';
  String _searchQuery = '';
  bool _showAdvancedFilters = false;

  // Filter categories for electrical jobs
  final List<String> _filterCategories = [
    'All Jobs',
    'Journeyman Lineman',
    'Journeyman Electrician',
    'Journeyman Wireman',
    'Transmission',
    'Distribution',
    'Substation',
    'Storm Work',
  ];

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Manually trigger initial load if not already loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!ref.read(jobsProvider).isLoading && ref.read(jobsProvider).jobs.isEmpty) {
        ref.read(jobsProvider.notifier).loadJobs(isRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      // Load more jobs when reaching the bottom
      ref.read(jobsProvider.notifier).loadMoreJobs();
    }
  }

  void _showSearchDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(
          'Search Jobs',
          style: AppTheme.headlineSmall.copyWith(
            color: AppTheme.primaryNavy,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by company, location, or classification...',
                prefixIcon: Icon(Icons.search, color: AppTheme.primaryNavy),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide(color: AppTheme.primaryNavy, width: 2),
                ),
              ),
              onChanged: (value) {
                setState(() {
                  _searchQuery = value;
                });
              },
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _searchQuery = '';
                _searchController.clear();
              });
            },
            child: Text('Clear', style: TextStyle(color: AppTheme.textSecondary)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _applyFilters();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.primaryNavy,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Search'),
          ),
        ],
      ),
    );
  }

  void _applyFilters() {
    // Trigger a new search with current filters
    ref.invalidate(jobsProvider);
  }

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(job: job),
    );
  }

  void _handleBidAction(Job job) {
    // TODO: Handle bid action
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Bidding on job at ${job.company}'),
        backgroundColor: AppTheme.accentCopper,
      ),
    );
  }

  List<Job> _getFilteredJobs(List<Job> jobs) {
    List<Job> filtered = jobs;

    // Apply search query
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((job) {
        return job.company.toLowerCase().contains(query) ||
               job.location.toLowerCase().contains(query) ||
               (job.classification?.toLowerCase().contains(query) ?? false) ||
               (job.jobTitle?.toLowerCase().contains(query) ?? false);
      }).toList();
    }

    // Apply category filter
    if (_selectedFilter != 'All Jobs') {
      filtered = filtered.where((job) {
        final classification = job.classification?.toLowerCase() ?? '';
        final jobTitle = job.jobTitle?.toLowerCase() ?? '';
        final typeOfWork = job.typeOfWork?.toLowerCase() ?? '';
        final filterLower = _selectedFilter.toLowerCase();

        return classification.contains(filterLower) ||
               jobTitle.contains(filterLower) ||
               typeOfWork.contains(filterLower);
      }).toList();
    }

    return filtered;
  }

  Widget _buildFilterChips() {
    return SizedBox(
      height: 40,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: _filterCategories.length,
        itemBuilder: (context, index) {
          final category = _filterCategories[index];
          final isSelected = _selectedFilter == category;
          
              return Padding(
                padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(category),
              selected: isSelected,
              onSelected: (selected) {
                setState(() {
                  _selectedFilter = selected ? category : 'All Jobs';
                });
                _applyFilters();
              },
              selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentCopper,
              labelStyle: TextStyle(
                color: isSelected ? AppTheme.accentCopper : AppTheme.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildAdvancedFilters() {
    if (!_showAdvancedFilters) return const SizedBox.shrink();
    
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Advanced Filters',
            style: AppTheme.headlineSmall.copyWith(
              color: AppTheme.primaryNavy,
            ),
          ),
          const SizedBox(height: 12),
          // Add more advanced filter options here
          Row(
            children: [
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _selectedFilter = 'All Jobs';
                      _searchQuery = '';
                      _searchController.clear();
                    });
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.textSecondary,
                    foregroundColor: AppTheme.white,
                  ),
                  child: const Text('Clear All'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showAdvancedFilters = false;
                    });
                    _applyFilters();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryNavy,
                    foregroundColor: AppTheme.white,
                  ),
                  child: const Text('Apply'),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLoadingIndicator() {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 8, // Show 8 skeleton cards while loading
      itemBuilder: (context, index) {
        return const JobCardSkeleton();
      },
    );
  }

  Widget _buildErrorState(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'Error loading jobs',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              error,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () => ref.invalidate(jobsProvider),
              child: const Text('Retry'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.work_outline,
              size: 64,
              color: AppTheme.textSecondary,
            ),
            const SizedBox(height: 16),
            Text(
              'No jobs found',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty || _selectedFilter != 'All Jobs'
                  ? 'Try adjusting your search or filters'
                  : 'Check back later for new job postings',
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
            if (_searchQuery.isNotEmpty || _selectedFilter != 'All Jobs') ...[
              const SizedBox(height: 16),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    _selectedFilter = 'All Jobs';
                    _searchQuery = '';
                    _searchController.clear();
                  });
                  _applyFilters();
                },
                child: const Text('Clear Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final jobsState = ref.watch(jobsProvider);
    
    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppTheme.accentCopper, AppTheme.accentCopper.withValues(alpha: 0.8)],
                ),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.electrical_services,
                size: 20,
                color: AppTheme.white,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              'Job Opportunities',
              style: AppTheme.headlineMedium.copyWith(
                color: AppTheme.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        elevation: 0,
        actions: [
          // Notification icon only
          IconButton(
            icon: const Icon(Icons.notifications),
            onPressed: () {
              context.push(AppRouter.notifications);
            },
            tooltip: 'Notifications',
          ),
        ],
      ),
      body: Stack(
        children: [
          // Electrical circuit background
          ElectricalCircuitBackground(
            opacity: 0.35,
            animationSpeed: 4.0,
            componentDensity: ComponentDensity.high,
            enableCurrentFlow: true,
            enableInteractiveComponents: true,
          ),
          Column(
            children: [
              // Filter chips
              const SizedBox(height: 16),
              _buildFilterChips(),
              const SizedBox(height: 8),
              
              // Advanced filters
              _buildAdvancedFilters(),
              
              // Jobs list
          Expanded(
            child: () {
              if (jobsState.error != null) {
                return _buildErrorState(jobsState.error!);
              }
              
              if (jobsState.isLoading && jobsState.jobs.isEmpty) {
                return _buildLoadingIndicator();
              }
              
              final filteredJobs = _getFilteredJobs(jobsState.jobs);
              
              if (filteredJobs.isEmpty) {
                return _buildEmptyState();
              }
              
              return RefreshIndicator(
                onRefresh: () async {
                  ref.invalidate(jobsProvider);
                },
                child: ListView.builder(
                  controller: _scrollController,
                  padding: const EdgeInsets.all(16),
                  itemCount: filteredJobs.length,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return RichTextJobCard(
                      job: job,
                      onDetails: () => _showJobDetails(job),
                      onBid: () => _handleBidAction(job),
                    );
                  },
                ),
              );
            }(),
          ),
            ],
          ),
        ],
      ),
    );
  }
}
