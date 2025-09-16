import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../design_system/app_theme.dart';
import '../../../electrical_components/electrical_loader.dart';
import '../../../electrical_components/circuit_pattern_painter.dart';
import '../../../electrical_components/electrical_icons.dart';
import '../models/crew.dart';
import '../models/crew_enums.dart';
import '../providers/crew_provider.dart';
import '../widgets/crew_card.dart';

/// Main screen displaying user's crews with IBEW electrical worker styling.
/// 
/// Features real-time crew updates, classification filtering, storm work
/// prioritization, and professional electrical industry theming throughout.
/// Designed for mobile field workers with offline support and accessibility.
class CrewListScreen extends ConsumerStatefulWidget {
  const CrewListScreen({super.key});

  @override
  ConsumerState<CrewListScreen> createState() => _CrewListScreenState();
}

class _CrewListScreenState extends ConsumerState<CrewListScreen> 
    with TickerProviderStateMixin {
  late final TextEditingController _searchController;
  late final ScrollController _scrollController;
  late final AnimationController _animationController;
  
  String _searchQuery = '';
  String? _selectedClassification;
  bool _showStormCrewsOnly = false;
  
  // IBEW Classifications for filtering
  static const List<String> _ibewClassifications = [
    'Inside Wireman',
    'Journeyman Lineman',
    'Tree Trimmer',
    'Equipment Operator',
  ];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _scrollController = ScrollController();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    
    // Initialize crew data
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _initializeCrewData();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.dispose();
    _animationController.dispose();
    super.dispose();
  }

  /// Initialize crew data for current user
  void _initializeCrewData() {
    // TODO: Get actual user ID from auth provider
    const String currentUserId = 'current-user-id';
    ref.read(crewProvider.notifier).initializeUserCrews(currentUserId);
  }

  /// Handle search query changes with debouncing
  void _onSearchChanged(String query) {
    setState(() {
      _searchQuery = query.toLowerCase();
    });
    
    if (query.isNotEmpty) {
      ref.read(crewProvider.notifier).searchCrews(query);
    }
  }

  /// Filter crews based on search and classification
  List<Crew> _filterCrews(List<Crew> crews) {
    var filteredCrews = crews;

    // Apply text search filter
    if (_searchQuery.isNotEmpty) {
      filteredCrews = filteredCrews.where((crew) {
        return crew.name.toLowerCase().contains(_searchQuery) ||
               (crew.description?.toLowerCase().contains(_searchQuery) ?? false) ||
               (crew.homeLocal?.toLowerCase().contains(_searchQuery) ?? false);
      }).toList();
    }

    // Apply classification filter
    if (_selectedClassification != null) {
      filteredCrews = filteredCrews.where((crew) {
        return crew.classifications.contains(_selectedClassification);
      }).toList();
    }

    // Apply storm work filter
    if (_showStormCrewsOnly) {
      filteredCrews = filteredCrews.where((crew) {
        return crew.availableForStormWork;
      }).toList();
    }

    // Sort: Storm crews first, then by recent activity
    filteredCrews.sort((a, b) {
      // Storm crews have priority
      if (a.availableForStormWork && !b.availableForStormWork) return -1;
      if (!a.availableForStormWork && b.availableForStormWork) return 1;
      
      // Then by last activity (handle null safely)
      final aActivity = a.lastActivityAt ?? a.updatedAt;
      final bActivity = b.lastActivityAt ?? b.updatedAt;
      return bActivity.compareTo(aActivity);
    });

    return filteredCrews;
  }

  /// Handle refresh gesture for field workers
  Future<void> _onRefresh() async {
    HapticFeedback.lightImpact();
    
    try {
      await ref.read(crewProvider.notifier).refreshUserCrews();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to refresh crews: ${e.toString()}'),
            backgroundColor: AppTheme.primaryNavy,
            action: SnackBarAction(
              label: 'Retry',
              textColor: AppTheme.accentCopper,
              onPressed: _onRefresh,
            ),
          ),
        );
      }
    }
  }

  /// Navigate to crew detail screen
  void _onCrewTap(Crew crew) {
    HapticFeedback.selectionClick();
    ref.read(crewProvider.notifier).selectCrew(crew);
    context.push('/crews/${crew.id}');
  }

  /// Navigate to create crew screen
  void _onCreateCrew() {
    HapticFeedback.mediumImpact();
    context.push('/crews/create');
  }

  /// Handle crew long press for quick actions
  void _onCrewLongPress(Crew crew) {
    HapticFeedback.heavyImpact();
    
    showModalBottomSheet(
      context: context,
      backgroundColor: AppTheme.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => _buildCrewActionsSheet(crew),
    );
  }

  /// Build crew actions bottom sheet
  Widget _buildCrewActionsSheet(Crew crew) {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Handle bar
          Container(
            width: 40,
            height: 4,
            margin: const EdgeInsets.only(bottom: 16),
            decoration: BoxDecoration(
              color: AppTheme.mediumGray,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          
          // Crew name
          Text(
            crew.name,
            style: AppTheme.headingMedium.copyWith(
              color: AppTheme.primaryNavy,
            ),
            textAlign: TextAlign.center,
          ),
          
          const SizedBox(height: 16),
          
          // Actions
          ListTile(
            leading: const Icon(Icons.info_outline, color: AppTheme.accentCopper),
            title: const Text('View Details'),
            onTap: () {
              Navigator.pop(context);
              _onCrewTap(crew);
            },
          ),
          
          ListTile(
            leading: const Icon(Icons.share, color: AppTheme.accentCopper),
            title: const Text('Share Crew'),
            onTap: () {
              Navigator.pop(context);
              // TODO: Implement crew sharing
            },
          ),
          
          if (crew.isAdmin('current-user-id'))
            ListTile(
              leading: const Icon(Icons.edit, color: AppTheme.accentCopper),
              title: const Text('Edit Crew'),
              onTap: () {
                Navigator.pop(context);
                context.push('/crews/${crew.id}/edit');
              },
            ),
          
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final crewState = ref.watch(crewProvider);
    final filteredCrews = _filterCrews(crewState.userCrews);
    
    return Scaffold(
      backgroundColor: AppTheme.white,
      appBar: AppBar(
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        centerTitle: true,
        title: const Text(
          'My Crews',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
        elevation: 0,
        actions: [
          // Search toggle
          IconButton(
            icon: const Icon(Icons.search),
            onPressed: () {
              HapticFeedback.lightImpact();
              // Toggle search visibility - for now just focus search field
            },
            tooltip: 'Search crews',
          ),
          
          // Filter toggle
          IconButton(
            icon: Icon(
              _selectedClassification != null || _showStormCrewsOnly
                  ? Icons.filter_alt
                  : Icons.filter_alt_outlined,
            ),
            onPressed: () {
              HapticFeedback.lightImpact();
              _showFilterDialog();
            },
            tooltip: 'Filter crews',
          ),
        ],
      ),
      
      body: RefreshIndicator(
        onRefresh: _onRefresh,
        color: AppTheme.accentCopper,
        backgroundColor: AppTheme.white,
        child: Column(
          children: [
            // Search bar
            _buildSearchBar(),
            
            // Filter chips
            if (_selectedClassification != null || _showStormCrewsOnly)
              _buildFilterChips(),
            
            // Content area
            Expanded(
              child: _buildContent(crewState, filteredCrews),
            ),
          ],
        ),
      ),
      
      floatingActionButton: FloatingActionButton(
        onPressed: _onCreateCrew,
        backgroundColor: AppTheme.accentCopper,
        foregroundColor: AppTheme.white,
        tooltip: 'Create new crew',
        child: const Icon(Icons.add, size: 28),
      ),
    );
  }

  /// Build search bar with electrical styling
  Widget _buildSearchBar() {
    return Container(
      margin: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppTheme.lightGray,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: AppTheme.mediumGray.withValues(alpha: 0.3),
        ),
      ),
      child: TextField(
        controller: _searchController,
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search crews, locals, classifications...',
          hintStyle: TextStyle(
            color: AppTheme.mediumGray,
            fontSize: 16,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppTheme.accentCopper,
          ),
          suffixIcon: _searchQuery.isNotEmpty
              ? IconButton(
                  icon: const Icon(Icons.clear, color: AppTheme.mediumGray),
                  onPressed: () {
                    _searchController.clear();
                    _onSearchChanged('');
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 16,
            vertical: 12,
          ),
        ),
      ),
    );
  }

  /// Build filter chips for active filters
  Widget _buildFilterChips() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Wrap(
        spacing: 8,
        children: [
          if (_selectedClassification != null)
            FilterChip(
              label: Text(_selectedClassification!),
              selected: true,
              selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentCopper,
              onSelected: (_) {
                setState(() {
                  _selectedClassification = null;
                });
              },
            ),
          
          if (_showStormCrewsOnly)
            FilterChip(
              label: const Text('Storm Work Only'),
              selected: true,
              selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
              checkmarkColor: AppTheme.accentCopper,
              avatar: const Icon(Icons.flash_on, size: 16),
              onSelected: (_) {
                setState(() {
                  _showStormCrewsOnly = false;
                });
              },
            ),
        ],
      ),
    );
  }

  /// Build main content based on state
  Widget _buildContent(CrewState state, List<Crew> filteredCrews) {
    if (state.isLoading && state.userCrews.isEmpty) {
      return _buildLoadingState();
    }
    
    if (state.errorMessage != null && state.userCrews.isEmpty) {
      return _buildErrorState(state.errorMessage!);
    }
    
    if (filteredCrews.isEmpty) {
      return _buildEmptyState();
    }
    
    return _buildCrewList(filteredCrews);
  }

  /// Build electrical-themed loading state
  Widget _buildLoadingState() {
    return const Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          JJElectricalLoader(
            size: 60,
            color: AppTheme.accentCopper,
          ),
          SizedBox(height: 16),
          Text(
            'Loading your crews...',
            style: TextStyle(
              fontSize: 16,
              color: AppTheme.mediumGray,
            ),
          ),
        ],
      ),
    );
  }

  /// Build error state with retry option
  Widget _buildErrorState(String errorMessage) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Error icon with electrical theme
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.electrical_services_outlined,
                size: 48,
                color: AppTheme.accentCopper,
              ),
            ),
            
            const SizedBox(height: 16),
            
            Text(
              'Connection Issue',
              style: AppTheme.headingMedium.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Text(
              errorMessage,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
              ),
            ),
            
            const SizedBox(height: 24),
            
            ElevatedButton.icon(
              onPressed: _initializeCrewData,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppTheme.accentCopper,
                foregroundColor: AppTheme.white,
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 12,
                ),
              ),
              icon: const Icon(Icons.refresh),
              label: const Text('Try Again'),
            ),
            
            const SizedBox(height: 16),
            
            if (errorMessage.toLowerCase().contains('offline') ||
                errorMessage.toLowerCase().contains('network'))
              Text(
                'Working offline - some features may be limited',
                style: TextStyle(
                  color: AppTheme.mediumGray,
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
          ],
        ),
      ),
    );
  }

  /// Build empty state with IBEW messaging
  Widget _buildEmptyState() {
    final hasFilters = _selectedClassification != null || _showStormCrewsOnly;
    
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Electrical-themed illustration
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppTheme.accentCopper.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.groups_outlined,
                size: 64,
                color: AppTheme.accentCopper,
              ),
            ),
            
            const SizedBox(height: 24),
            
            Text(
              hasFilters ? 'No crews match filters' : 'No crews yet',
              style: AppTheme.headingLarge.copyWith(
                color: AppTheme.primaryNavy,
              ),
            ),
            
            const SizedBox(height: 12),
            
            Text(
              hasFilters
                  ? 'Try adjusting your search or filter settings'
                  : 'Create your first crew to get started with IBEW teamwork',
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppTheme.mediumGray,
                fontSize: 16,
                height: 1.4,
              ),
            ),
            
            if (!hasFilters) ...[
              const SizedBox(height: 16),
              
              Text(
                'Perfect for storm work, job coordination, and union local collaboration',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AppTheme.mediumGray.withValues(alpha: 0.8),
                  fontSize: 14,
                  fontStyle: FontStyle.italic,
                ),
              ),
              
              const SizedBox(height: 32),
              
              ElevatedButton.icon(
                onPressed: _onCreateCrew,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.accentCopper,
                  foregroundColor: AppTheme.white,
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                icon: const Icon(Icons.add_circle_outline),
                label: const Text(
                  'Create First Crew',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
            
            if (hasFilters) ...[
              const SizedBox(height: 24),
              
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    _selectedClassification = null;
                    _showStormCrewsOnly = false;
                    _searchController.clear();
                    _searchQuery = '';
                  });
                },
                style: TextButton.styleFrom(
                  foregroundColor: AppTheme.accentCopper,
                ),
                icon: const Icon(Icons.clear_all),
                label: const Text('Clear All Filters'),
              ),
            ],
          ],
        ),
      ),
    );
  }

  /// Build crew list with cards
  Widget _buildCrewList(List<Crew> crews) {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.only(
        left: 16,
        right: 16,
        bottom: 80, // Account for FAB
      ),
      itemCount: crews.length,
      itemBuilder: (context, index) {
        final crew = crews[index];
        
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: CrewCard(
            crew: crew,
            onTap: () => _onCrewTap(crew),
            onLongPress: () => _onCrewLongPress(crew),
            showQuickActions: false,
          ),
        );
      },
    );
  }

  /// Show filter dialog
  void _showFilterDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text(
          'Filter Crews',
          style: TextStyle(color: AppTheme.primaryNavy),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Classification filter
            const Text(
              'IBEW Classification',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: AppTheme.primaryNavy,
              ),
            ),
            
            const SizedBox(height: 8),
            
            Wrap(
              spacing: 8,
              children: _ibewClassifications.map((classification) {
                return FilterChip(
                  label: Text(classification),
                  selected: _selectedClassification == classification,
                  selectedColor: AppTheme.accentCopper.withValues(alpha: 0.2),
                  checkmarkColor: AppTheme.accentCopper,
                  onSelected: (selected) {
                    setState(() {
                      _selectedClassification = selected ? classification : null;
                    });
                  },
                );
              }).toList(),
            ),
            
            const SizedBox(height: 16),
            
            // Storm work filter
            CheckboxListTile(
              title: const Row(
                children: [
                  Icon(Icons.flash_on, color: AppTheme.accentCopper, size: 20),
                  SizedBox(width: 8),
                  Text('Storm Work Only'),
                ],
              ),
              value: _showStormCrewsOnly,
              activeColor: AppTheme.accentCopper,
              onChanged: (value) {
                setState(() {
                  _showStormCrewsOnly = value ?? false;
                });
              },
              contentPadding: EdgeInsets.zero,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                _selectedClassification = null;
                _showStormCrewsOnly = false;
              });
              Navigator.pop(context);
            },
            child: const Text('Clear'),
          ),
          
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AppTheme.accentCopper,
              foregroundColor: AppTheme.white,
            ),
            child: const Text('Apply'),
          ),
        ],
      ),
    );
  }
}
