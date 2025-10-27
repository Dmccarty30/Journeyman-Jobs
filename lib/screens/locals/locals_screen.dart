import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../models/locals_record.dart';
import '../../design_system/app_theme.dart';
import '../../providers/riverpod/locals_riverpod_provider.dart';
import '../../providers/riverpod/auth_riverpod_provider.dart';
import 'dart:io' show Platform;
import '../../widgets/notification_badge.dart';
import 'package:go_router/go_router.dart';
import '../../navigation/app_router.dart';
import '../../utils/text_formatting_wrapper.dart';
import '../../electrical_components/circuit_board_background.dart';
import '../../widgets/rich_text_local_card.dart';
import 'locals_skeleton_screen.dart';

class LocalsScreen extends ConsumerStatefulWidget {
  const LocalsScreen({super.key});

  @override
  ConsumerState<LocalsScreen> createState() => _LocalsScreenState();
}

class _LocalsScreenState extends ConsumerState<LocalsScreen> {
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  Timer? _debounceTimer;
  String? _selectedState;

  @override
  void initState() {
    super.initState();
    // NOTE: Data loading removed from initState to prevent permission errors
    // during auth initialization. Data is now loaded in build() after
    // authInitializationProvider confirms auth is ready.
    // Only set up scroll listener here.
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _searchController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent) {
      ref.read(localsProvider.notifier).loadLocals(loadMore: true);
    }
  }

  void _onSearchChanged(String value) {
    _debounceTimer?.cancel();
    if (value.isEmpty) {
      // Immediate clear for empty search
      ref.read(localsProvider.notifier).searchLocals('');
      return;
    }
    _debounceTimer = Timer(const Duration(milliseconds: 500), () {
      ref.read(localsProvider.notifier).searchLocals(value);
    });
  }


  @override
  Widget build(BuildContext context) {
    // Watch auth initialization status
    // If auth is still initializing, show skeleton screen to prevent
    // flash of permission denied errors when accessing Firestore
    final authInit = ref.watch(authInitializationProvider);

    // Show skeleton screen while auth initializes
    if (authInit.isLoading) {
      return const LocalsSkeletonScreen();
    }

    // Auth initialized - now safe to load data
    // Router will handle redirect if user is not authenticated
    // Load locals data once when auth is ready (not in initState)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final localsState = ref.read(localsProvider);
      // Only load if not already loaded and not currently loading
      if (localsState.locals.isEmpty && !localsState.isLoading) {
        ref.read(localsProvider.notifier).loadLocals();
      }
    });

    return Scaffold(
      backgroundColor: AppTheme.offWhite,
      appBar: AppBar(
        title: const Text('IBEW Locals Directory'),
        backgroundColor: AppTheme.primaryNavy,
        elevation: 0,
        actions: [
          NotificationBadge(
            iconColor: AppTheme.white,
            showPopupOnTap: false,
            onTap: () {
              context.push(AppRouter.notifications);
            },
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(80),
          child: Container(
            padding: const EdgeInsets.all(AppTheme.spacingMd),
            child: TextField(
              controller: _searchController,
              style: AppTheme.bodyMedium.copyWith(color: AppTheme.white),
              decoration: InputDecoration(
                hintText: 'Search by local number, city, or state...',
                hintStyle: AppTheme.bodyMedium.copyWith(
                  color: AppTheme.white.withAlpha(179)
                ),
                prefixIcon: const Icon(Icons.search, color: AppTheme.white),
                filled: true,
                fillColor: AppTheme.white.withAlpha(26),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: BorderSide.none,
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
                  borderSide: const BorderSide(
                    color: AppTheme.accentCopper, 
                    width: 2
                  ),
                ),
              ),
              onChanged: _onSearchChanged,
            ),
          ),
        ),
      ),
      body: Stack(
        children: [
          // PERFORMANCE: Reduced complexity for better scroll performance
          // ElectricalCircuitBackground at high density uses 30-45% CPU
          // Using RepaintBoundary to isolate from list rebuilds
          RepaintBoundary(
            child: const ElectricalCircuitBackground(
              opacity: 0.25, // Reduced opacity for subtler effect
              animationSpeed: 6.0, // Slower animation = less CPU
              componentDensity: ComponentDensity.low, // Reduced density
              enableCurrentFlow: false, // Disabled animation
              enableInteractiveComponents: false, // Disabled interaction
            ),
          ),
          Column(
            children: [
              // State filter dropdown
              Container(
                width: double.infinity,
                padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd),
                child: DropdownButton<String>(
                  value: _selectedState,
                  hint: const Text('Filter by State'),
                  isExpanded: true,
                  items: [
                    const DropdownMenuItem<String>(
                      value: null,
                      child: Text('All States'),
                    ),
                    // Common states - you can expand this list
                    ...['CA', 'TX', 'NY', 'FL', 'PA', 'IL', 'OH', 'GA', 'NC', 'MI']
                        .map((state) => DropdownMenuItem<String>(
                              value: state,
                              child: Text(state),
                            )),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedState = value;
                    });
                    ref.read(localsProvider.notifier).loadLocals();
                  },
                ),
              ),
              const SizedBox(height: AppTheme.spacingSm),
              // Locals list
              Expanded(
                child: Consumer(
                  builder: (context, ref, child) {
                    final localsState = ref.watch(localsProvider);
                    return _buildLocalsList(localsState);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildLocalsList(LocalsState localsState) {
    if (localsState.isLoading && localsState.locals.isEmpty) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
        ),
      );
    }

    if (localsState.error != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: AppTheme.iconXxl,
              color: AppTheme.errorRed,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'Error loading locals',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.errorRed
              ),
            ),
            const SizedBox(height: AppTheme.spacingSm),
            Text(
              localsState.error!,
              style: AppTheme.bodyMedium.copyWith(
                color: AppTheme.textSecondary
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            ElevatedButton(
              onPressed: () => ref.read(localsProvider.notifier).loadLocals(),
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    // Use filtered locals from the provider
    List<LocalsRecord> filteredLocals = localsState.filteredLocals;

    if (filteredLocals.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.location_city,
              size: AppTheme.iconXxl,
              color: AppTheme.mediumGray,
            ),
            const SizedBox(height: AppTheme.spacingMd),
            Text(
              'No locals found',
              style: AppTheme.headlineSmall.copyWith(
                color: AppTheme.textLight
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.all(AppTheme.spacingMd),
      itemCount: filteredLocals.length + (localsState.isLoading && filteredLocals.isNotEmpty ? 1 : 0),
      // PERFORMANCE: itemExtent removed to allow dynamic card heights
      // Cards will size based on content (address, phone, email availability)
      physics: const AlwaysScrollableScrollPhysics(),
      itemBuilder: (context, index) {
        // Show loading indicator at the end while loading more
        if (index == filteredLocals.length && localsState.isLoading) {
          return const Padding(
            padding: EdgeInsets.all(AppTheme.spacingLg),
            child: Center(
              child: CircularProgressIndicator(
                valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
              ),
            ),
          );
        }

        final local = filteredLocals[index];
        return RichTextLocalCard(
          // PERFORMANCE: Add stable key for better widget recycling
          key: ValueKey<String>(local.id),
          local: local,
          onDetails: () => _showLocalDetails(context, local),
        );
      },
    );
  }

  void _showLocalDetails(BuildContext context, LocalsRecord local) {
    showDialog(
      context: context,
      builder: (context) => LocalDetailsDialog(local: local),
    );
  }
}

// LocalCard widget removed - replaced with RichTextLocalCard to fix overflow issue

// LocalDetailsDialog removed - now handled in RichTextLocalCard widget
