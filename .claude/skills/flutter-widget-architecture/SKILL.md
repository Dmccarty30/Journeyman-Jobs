---
name: jj-flutter-widget-architecture
description: Build production-ready Flutter widgets optimized for IBEW electrical workers in field conditions. Handles mobile-first design, electrical theming, glove-compatible touch (≥48dp), high-contrast outdoor visibility, Riverpod integration, offline states, and battery-efficient rendering. Use when creating screens, components, job cards, or any UI element.
---

# JJ Flutter Widget Architecture

## Purpose

Design and build Flutter UI components optimized for electrical field workers using mobile devices in challenging conditions (outdoor work sites, work gloves, intermittent connectivity, 8-12 hour shifts).

## When To Use

- Creating new screens or page layouts
- Building reusable UI components (cards, lists, forms)
- Implementing electrical-themed styling
- Integrating with Riverpod state management
- Adding offline/loading states
- Optimizing for field worker usability

## Core Principles

### 1. Mobile-First Field Worker Design

**Target Users**: IBEW electrical workers on job sites

**Device Reality**:

- Budget Android phones (2-4GB RAM)
- Worn work gloves (thick touch targets needed)
- Bright outdoor sunlight (high contrast required)
- Intermittent connectivity (offline-first UI)
- 8-12 hour shifts without charging (battery optimization)

**Design Requirements**:

- Touch targets ≥48dp (glove-compatible)
- Text sizes ≥16sp body, ≥24sp headers
- High-contrast themes (WCAG AAA)
- Battery-efficient rendering
- Offline-friendly loading states

### 2. Electrical Theme System

**Color Palette**:

```dart
// High visibility for outdoor work
const electricalYellow = Color(0xFFFFD700);  // Primary accent
const safetyOrange = Color(0xFFFF6B35);      // Warnings, CTAs
const conductorBlue = Color(0xFF1E88E5);     // Primary actions
const groundGreen = Color(0xFF4CAF50);       // Success states
const neutralGray = Color(0xFF9E9E9E);       // Disabled, secondary
const hotRed = Color(0xFFE53935);            // Danger, storm work

// Dark mode for night shifts
const darkBackground = Color(0xFF1A202C);
const darkSurface = Color(0xFF2D3748);
```

**Typography**:

```dart
// Readable in sunlight, accessible for all workers
headlineLarge: 32sp, bold     // Screen titles
headlineSmall: 24sp, bold     // Section headers
bodyLarge: 18sp, regular      // Main content
bodySmall: 16sp, regular      // Secondary content (minimum)
```

### 3. Component Architecture Patterns

**Base Structure**:

```dart
// Every component follows this hierarchy
Widget → StatelessWidget/ConsumerWidget
  ├─ Scaffold (for screens)
  ├─ ElectricalCircuitBackground (theme wrapper)
  ├─ SafeArea (respects device notches)
  └─ Content (actual UI)
```

## Essential Widget Patterns

### Pattern 1: Job Card (Core Component)

**Purpose**: Display job listings optimized for quick scanning on job sites

```dart
class JobCard extends ConsumerWidget {
  final Job job;
  final VoidCallback? onTap;
  
  const JobCard({
    Key? key,
    required this.job,
    this.onTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = Theme.of(context);
    
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(16),  // Glove-compatible padding
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Title - Large and bold for outdoor readability
              Text(
                job.title,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 8),
              
              // Location - Icon + text for quick recognition
              Row(
                children: [
                  Icon(Icons.location_on, size: 20, color: conductorBlue),
                  const SizedBox(width: 4),
                  Expanded(
                    child: Text(
                      '${job.city}, ${job.state}',
                      style: theme.textTheme.bodyLarge,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              
              // Details - High-contrast chips
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  // Trade classification
                  _DetailChip(
                    icon: Icons.build,
                    label: job.tradeClassification,
                    color: electricalYellow,
                  ),
                  // Pay scale
                  if (job.payScale != null)
                    _DetailChip(
                      icon: Icons.attach_money,
                      label: job.payScale!,
                      color: groundGreen,
                    ),
                  // Storm work indicator
                  if (job.isStormWork)
                    _DetailChip(
                      icon: Icons.warning,
                      label: 'STORM WORK',
                      color: hotRed,
                    ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Supporting widget - Reusable detail chip
class _DetailChip extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  
  const _DetailChip({
    required this.icon,
    required this.label,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: color, width: 1),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 16, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 2: Virtual Job List (Performance Optimized)

**Purpose**: Efficient scrolling for hundreds of job listings

```dart
class VirtualJobList extends ConsumerWidget {
  const VirtualJobList({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobsAsync = ref.watch(filteredJobsProvider);
    
    return jobsAsync.when(
      // Loading state - Skeleton UI
      loading: () => ListView.builder(
        itemCount: 5,
        itemExtent: 140,  // Fixed height for performance
        itemBuilder: (context, index) => const JobCardSkeleton(),
      ),
      
      // Error state - User-friendly message
      error: (error, stack) => Center(
        child: ErrorRecoveryWidget(
          error: error,
          onRetry: () => ref.refresh(filteredJobsProvider),
        ),
      ),
      
      // Success state - Optimized list
      data: (jobs) {
        if (jobs.isEmpty) {
          return Center(
            child: EmptyStateWidget(
              icon: Icons.work_off,
              message: 'No jobs found',
              actionLabel: 'Clear Filters',
              onAction: () => ref.read(jobFilterProvider.notifier).clearAll(),
            ),
          );
        }
        
        return ListView.builder(
          itemCount: jobs.length,
          itemExtent: 140,  // CRITICAL: Fixed height improves scroll performance
          cacheExtent: 280,  // Cache 2 items above/below viewport
          itemBuilder: (context, index) {
            final job = jobs[index];
            return JobCard(
              key: ValueKey(job.id),  // Preserve state during updates
              job: job,
              onTap: () => _navigateToJobDetails(context, job),
            );
          },
        );
      },
    );
  }
  
  void _navigateToJobDetails(BuildContext context, Job job) {
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => JobDetailsScreen(jobId: job.id),
      ),
    );
  }
}
```

### Pattern 3: Offline Indicator (Network Awareness)

**Purpose**: Show connectivity status for field workers

```dart
class OfflineIndicator extends ConsumerWidget {
  const OfflineIndicator({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final isOnline = ref.watch(connectivityProvider);
    
    if (isOnline) return const SizedBox.shrink();
    
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      color: safetyOrange,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.cloud_off, color: Colors.white, size: 20),
          const SizedBox(width: 8),
          const Text(
            'Offline Mode - Changes will sync when connected',
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
              fontSize: 14,
            ),
          ),
        ],
      ),
    );
  }
}
```

### Pattern 4: Skeleton Loading (Perceived Performance)

**Purpose**: Show content structure while data loads

```dart
class JobCardSkeleton extends StatelessWidget {
  const JobCardSkeleton({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Title shimmer
            _ShimmerBox(width: 200, height: 24),
            const SizedBox(height: 8),
            // Location shimmer
            _ShimmerBox(width: 150, height: 18),
            const SizedBox(height: 12),
            // Details shimmer
            Row(
              children: [
                _ShimmerBox(width: 80, height: 32),
                const SizedBox(width: 8),
                _ShimmerBox(width: 100, height: 32),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ShimmerBox extends StatelessWidget {
  final double width;
  final double height;
  
  const _ShimmerBox({required this.width, required this.height});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: Colors.grey[300],
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }
}
```

## Riverpod Integration

### Consumer Widget Pattern

**Always use ConsumerWidget for Riverpod integration**:

```dart
// ✅ Correct - ConsumerWidget for state access
class JobsScreen extends ConsumerWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    // ... rest of widget
  }
}

// ❌ Wrong - StatelessWidget can't access Riverpod
class JobsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    // No ref available!
  }
}
```

### State Watching Patterns

```dart
// Watch entire provider - rebuilds on any change
final jobs = ref.watch(jobsProvider);

// Watch specific field - rebuilds only when that field changes
final hasFilters = ref.watch(
  jobFilterProvider.select((filter) => filter.hasActiveFilters)
);

// Read provider once - no rebuilds
final notifier = ref.read(jobsProvider.notifier);
notifier.addJob(newJob);
```

## Screen Architecture

### Standard Screen Structure

```dart
class JobsScreen extends ConsumerWidget {
  const JobsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      // AppBar with electrical theme
      appBar: AppBar(
        title: const Text('Available Jobs'),
        backgroundColor: conductorBlue,
        actions: [
          // Filter icon with badge
          IconButton(
            icon: Badge(
              isLabelVisible: ref.watch(hasActiveFiltersProvider),
              child: const Icon(Icons.filter_list),
            ),
            onPressed: () => _showFilterSheet(context, ref),
            iconSize: 28,  // Glove-compatible
          ),
        ],
      ),
      
      // Body with offline indicator
      body: Column(
        children: [
          const OfflineIndicator(),
          Expanded(
            child: RefreshIndicator(
              onRefresh: () => ref.refresh(jobsProvider.future),
              child: const VirtualJobList(),
            ),
          ),
        ],
      ),
      
      // FAB with electrical accent
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _navigateToJobSearch(context),
        backgroundColor: electricalYellow,
        foregroundColor: Colors.black,
        icon: const Icon(Icons.search),
        label: const Text('Find Jobs'),
      ),
    );
  }
}
```

## Accessibility & Field Worker Optimization

### Touch Target Sizing

```dart
// ✅ Glove-compatible - 48dp minimum
ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: const Size(48, 48),  // Minimum touch target
    padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
  ),
  onPressed: () {},
  child: const Text('Apply'),
);

// ❌ Too small for gloves
IconButton(
  icon: const Icon(Icons.favorite),
  iconSize: 20,  // Too small!
  onPressed: () {},
);
```

### Text Readability

```dart
// ✅ Readable in sunlight
Text(
  'Electrician Needed',
  style: const TextStyle(
    fontSize: 24,  // Large enough
    fontWeight: FontWeight.bold,  // High contrast
    height: 1.4,  // Good line spacing
  ),
);

// ❌ Too small for outdoor reading
Text(
  'Electrician Needed',
  style: const TextStyle(fontSize: 12),  // Too small!
);
```

### High Contrast Mode

```dart
// Use theme-aware colors
final theme = Theme.of(context);
final textColor = theme.brightness == Brightness.dark
    ? Colors.white
    : Colors.black87;

// Or use semantic colors
final primaryColor = theme.colorScheme.primary;
final onPrimary = theme.colorScheme.onPrimary;
```

## Performance Optimization

### Const Constructors

```dart
// ✅ Const wherever possible - reduces rebuilds
const SizedBox(height: 16);
const Icon(Icons.work);
const Padding(padding: EdgeInsets.all(8), child: ...);

// ❌ Non-const when const is possible
SizedBox(height: 16);  // Should be const!
```

### Key Usage

```dart
// ✅ ValueKey for list items - preserves state
ListView.builder(
  itemBuilder: (context, index) {
    return JobCard(
      key: ValueKey(jobs[index].id),  // Preserves state during reordering
      job: jobs[index],
    );
  },
);
```

### Image Optimization

```dart
// ✅ Cached network images with size limits
CachedNetworkImage(
  imageUrl: job.companyLogoUrl,
  width: 64,  // Limit size
  height: 64,
  fit: BoxFit.cover,
  memCacheWidth: 128,  // Limit memory cache size
  placeholder: (context, url) => const CircularProgressIndicator(),
  errorWidget: (context, url, error) => const Icon(Icons.business),
);
```

## Testing Checklist

Before merging any UI component:

- [ ] Test with thick work gloves on actual device
- [ ] Verify outdoor visibility in bright sunlight
- [ ] Check offline behavior (airplane mode)
- [ ] Profile with Flutter DevTools (60fps target)
- [ ] Test on low-end Android device (2-4GB RAM)
- [ ] Verify battery impact during 1-hour test
- [ ] Check text readability at arm's length
- [ ] Validate touch target sizes (≥48dp)
- [ ] Test with poor network (throttled 3G)

## Common Mistakes

### ❌ Mistake 1: Tiny Touch Targets

```dart
// Too small for gloves
IconButton(icon: Icon(Icons.favorite), iconSize: 16);
```

### ✅ Fix: Minimum 48dp

```dart
IconButton(
  icon: const Icon(Icons.favorite),
  iconSize: 28,  // Larger icon
  constraints: const BoxConstraints(minWidth: 48, minHeight: 48),
);
```

### ❌ Mistake 2: No Offline State

```dart
// Fails silently when offline
FutureBuilder(
  future: fetchJobs(),
  builder: (context, snapshot) => snapshot.hasData ? ... : ...
);
```

### ✅ Fix: Explicit Offline Handling

```dart
Consumer(
  builder: (context, ref, child) {
    final isOnline = ref.watch(connectivityProvider);
    if (!isOnline) return OfflineIndicator();
    
    final jobsAsync = ref.watch(jobsProvider);
    return jobsAsync.when(...);
  },
);
```

### ❌ Mistake 3: Poor Scrolling Performance

```dart
// No itemExtent - janky scrolling
ListView.builder(
  itemBuilder: (context, index) => JobCard(jobs[index]),
);
```

### ✅ Fix: Fixed Item Height

```dart
ListView.builder(
  itemExtent: 140,  // Fixed height for smooth scrolling
  cacheExtent: 280,  // Pre-cache 2 items
  itemBuilder: (context, index) => JobCard(jobs[index]),
);
```

## Resources

**Flutter Documentation**:

- [Material Design](https://material.io/design)
- [Accessibility](https://docs.flutter.dev/development/accessibility-and-localization/accessibility)
- [Performance Best Practices](https://docs.flutter.dev/perf/best-practices)

**Project Files**:

- `/mnt/project/lib/widgets/` - Existing widgets
- `/mnt/project/lib/screens/` - Screen implementations
- `/mnt/project/lib/themes/` - Theme system

---

**Skill Version**: 1.0.0  
**Last Updated**: 2025-10-31  
**Status**: ✅ Production Ready
