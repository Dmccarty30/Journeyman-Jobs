import 'dart:async'; // Added for Timer (performance optimization: search debouncing)
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
import '../../electrical_components/jj_electrical_toast.dart';
import '../../navigation/app_router.dart';
import '../../utils/text_formatting_wrapper.dart';

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

  // PERFORMANCE OPTIMIZATION: Add debounce timer for search operations
  // Reduces unnecessary re-renders and Firestore queries during typing
  Timer? _searchDebounceTimer;

  // Filter categories for electrical jobs
  final List<String> _filterCategories = [
    'All Jobs',
    'Journeyman Lineman',
    'Journeyman Electrician',
    'Journeyman Wireman',
    'Transmission',
    'Distribution',
    'Substation',
  ];


  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    // Manually trigger initial load if not already loading
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final jobsState = ref.read(jobsProvider);
      if (!jobsState.isLoading && jobsState.jobs.isEmpty) {
        ref.read(jobsProvider.notifier).loadJobs(isRefresh: true);
      }
    });
  }

  @override
  void dispose() {
    // PERFORMANCE OPTIMIZATION: Cancel debounce timer to prevent memory leaks
    _searchDebounceTimer?.cancel();
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

  void _applyFilters() {
    // Trigger a new search with current filters
    ref.invalidate(jobsProvider);
  }

  /// PERFORMANCE OPTIMIZATION: Debounced search handler
  /// Prevents excessive re-renders and filtering operations during typing
  /// Uses 300ms delay - optimal balance between responsiveness and performance
  void _onSearchChanged(String value) {
    // Cancel any pending timer
    _searchDebounceTimer?.cancel();

    // For empty search, update immediately (fast clear)
    if (value.isEmpty) {
      setState(() {
        _searchQuery = '';
      });
      return;
    }

    // Otherwise, debounce the update
    _searchDebounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  void _showJobDetails(Job job) {
    showDialog(
      context: context,
      builder: (context) => JobDetailsDialog(job: job),
    );
  }

  void _handleBidAction(Job job) {
    // TODO: Handle bid action
    JJElectricalToast.showInfo(context: context, message: 'Bidding on job at ${job.company}');
  }

  List<Job> _getFilteredJobs(List<Job> jobs) {
    List<Job> filtered = jobs;

    // Apply search query - search only by local union number
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.trim();
      filtered = filtered.where((job) {
        final localNumber = job.localNumber?.toString() ?? job.local?.toString() ?? '';
        return localNumber.contains(query);
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
              label: Text(toTitleCase(category)),
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
              toTitleCase('Advanced Filters'),
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
                  child: Text(toTitleCase('Clear All')),
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
                  child: Text(toTitleCase('Apply')),
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
              toTitleCase('Error loading jobs'),
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
              child: Text(toTitleCase('Retry')),
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
              toTitleCase('No jobs found'),
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
                child: Text(toTitleCase('Clear Filters')),
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
              
              // Local Union Search Bar
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                child: TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search For A Specific Local',
                    prefixIcon: Icon(
                      Icons.search,
                      color: AppTheme.accentCopper,
                    ),
                    filled: true,
                    fillColor: AppTheme.white,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(
                        color: AppTheme.accentCopper.withValues(alpha: 0.5),
                        width: AppTheme.borderWidthCopperThin,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                      borderSide: BorderSide(
                        color: AppTheme.accentCopper,
                        width: AppTheme.borderWidthCopper,
                      ),
                    ),
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppTheme.spacingMd,
                      vertical: AppTheme.spacingMd,
                    ),
                  ),
                  keyboardType: TextInputType.number,
                  // PERFORMANCE OPTIMIZATION: Use debounced search handler
                  onChanged: _onSearchChanged,
                  onSubmitted: (_) {
                    _applyFilters();
                  },
                ),
              ),
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
                  // PERFORMANCE OPTIMIZATION: Add itemExtent for fixed-height job cards
                  // RichTextJobCard has approximately consistent height (~200-220px)
                  // This enables the framework to avoid expensive layout calculations
                  itemExtent: 210.0, // Average card height measured from UI
                  // PERFORMANCE OPTIMIZATION: Add cacheExtent for better scroll performance
                  // Renders items slightly off-screen to reduce frame drops during scroll
                  cacheExtent: 500.0,
                  itemBuilder: (context, index) {
                    final job = filteredJobs[index];
                    return RichTextJobCard(
                      // PERFORMANCE OPTIMIZATION: Add stable key for efficient widget recycling
                      // ValueKey based on job ID ensures widgets are reused correctly
                      key: ValueKey<String>(job.id),
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
