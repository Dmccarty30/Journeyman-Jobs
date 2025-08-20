# Job Filter Provider Migration to Riverpod

This document explains the migration from the Provider-based `JobFilterProvider` to the new Riverpod-based `JobFilterNotifier`.

## What Changed

### Old Architecture (Provider)

- Used `ChangeNotifier` with manual state management
- Required `MultiProvider` setup in widget tree
- Used `Consumer<JobFilterProvider>` or `context.read<JobFilterProvider>()`

### New Architecture (Riverpod)

- Uses `@Riverpod` annotations with code generation
- Provides fine-grained reactivity with computed providers
- Uses `ConsumerWidget` and `ref.watch()`

## Migration Guide

### 1. Widget Usage

**Old Way (Provider):**

```dart
class MyWidget extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Consumer<JobFilterProvider>(
      builder: (context, filterProvider, child) {
        final currentFilter = filterProvider.currentFilter;
        final hasActiveFilters = filterProvider.hasActiveFilters;
        
        return Column(
          children: [
            Text('Filters: ${filterProvider.activeFilterCount}'),
            ElevatedButton(
              onPressed: () => filterProvider.clearAllFilters(),
              child: Text('Clear All'),
            ),
          ],
        );
      },
    );
  }
}
```

**New Way (Riverpod):**

```dart
class MyWidget extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentFilter = ref.watch(currentJobFilterProvider);
    final hasActiveFilters = ref.watch(hasActiveFiltersProvider);
    final activeFilterCount = ref.watch(activeFilterCountProvider);
    final notifier = ref.watch(jobFilterNotifierProvider.notifier);
    
    return Column(
      children: [
        Text('Filters: $activeFilterCount'),
        ElevatedButton(
          onPressed: () => notifier.clearAllFilters(),
          child: Text('Clear All'),
        ),
      ],
    );
  }
}
```

### 2. Available Providers

#### State Providers

- `jobFilterNotifierProvider` - Main state and notifier
- `jobFilterNotifierProvider.notifier` - Access to state mutation methods

#### Computed Providers (Auto-update when state changes)

- `currentJobFilterProvider` - Current filter criteria
- `filterPresetsProvider` - List of filter presets
- `recentSearchesProvider` - Recent search queries
- `pinnedPresetsProvider` - Pinned presets only
- `recentPresetsProvider` - Recently used presets
- `hasActiveFiltersProvider` - Boolean indicating active filters
- `activeFilterCountProvider` - Number of active filters
- `quickFilterSuggestionsProvider` - Suggested quick filters

### 3. State Mutations

**Old Way:**

```dart
final filterProvider = context.read<JobFilterProvider>();
filterProvider.updateSearchQuery('electrician');
filterProvider.updateLocationFilter(city: 'Chicago', maxDistance: 50);
filterProvider.clearAllFilters();
```

**New Way:**

```dart
final notifier = ref.read(jobFilterNotifierProvider.notifier);
notifier.updateSearchQuery('electrician');
notifier.updateLocationFilter(city: 'Chicago', maxDistance: 50);
notifier.clearAllFilters();
```

### 4. Listening to Specific Changes

**Old Way (Provider):**

```dart
// Had to listen to entire provider, even for single property changes
Consumer<JobFilterProvider>(
  builder: (context, filterProvider, child) {
    // Rebuilds for ANY filter change
    return Text('Has filters: ${filterProvider.hasActiveFilters}');
  },
);
```

**New Way (Riverpod):**

```dart
// Can listen to specific computed values
Consumer(
  builder: (context, ref, child) {
    // Only rebuilds when hasActiveFilters changes
    final hasActiveFilters = ref.watch(hasActiveFiltersProvider);
    return Text('Has filters: $hasActiveFilters');
  },
);
```

### 5. Error Handling

**Old Way:**

```dart
// Error handling was mixed in with the provider state
if (filterProvider.error != null) {
  // Handle error
}
```

**New Way:**

```dart
final filterState = ref.watch(jobFilterNotifierProvider);
if (filterState.error != null) {
  // Handle error
  // Can also call: ref.read(jobFilterNotifierProvider.notifier).clearError();
}
```

## Benefits of Migration

### Performance

- **Fine-grained reactivity**: Widgets only rebuild when the specific data they care about changes
- **Automatic optimization**: Riverpod automatically handles provider caching and disposal
- **Reduced rebuilds**: Computed providers prevent unnecessary widget rebuilds

### Developer Experience

- **Better IntelliSense**: Strong typing with generated providers
- **Compile-time safety**: Catches provider usage errors at compile time
- **Less boilerplate**: No need for Consumer widgets in many cases

### Testing

- **Easier mocking**: Providers can be overridden for testing
- **Isolated testing**: Each provider can be tested independently
- **Better test setup**: ProviderScope makes test setup simpler

## Files Involved in Migration

### New Files

- `lib/providers/riverpod/job_filter_riverpod_provider.dart` - Main Riverpod provider
- `lib/providers/riverpod/job_filter_riverpod_provider.g.dart` - Generated code
- `lib/providers/job_filter_migration_example.dart` - Migration example

### Modified Files

- `lib/main.dart` - Added ProviderScope, removed old Provider setup

### Deprecated Files

- `lib/providers/job_filter_provider.dart` - Can be removed after migration complete

## Breaking Changes

1. **Widget Type**: Widgets using job filters must extend `ConsumerWidget` or `ConsumerStatefulWidget`
2. **Context Access**: Replace `context.read<JobFilterProvider>()` with `ref.read(jobFilterNotifierProvider.notifier)`
3. **State Access**: Replace direct property access with provider-specific providers

## Migration Checklist

- [ ] Update all widgets using job filters to `ConsumerWidget`
- [ ] Replace `Consumer<JobFilterProvider>` with provider-specific watches
- [ ] Update all filter mutations to use the notifier
- [ ] Test all filter functionality
- [ ] Remove old `JobFilterProvider` import statements
- [ ] Run `flutter pub run build_runner build` to generate provider code
- [ ] Remove `lib/providers/job_filter_provider.dart` (optional, after verification)

## Example Migration

See `lib/providers/job_filter_migration_example.dart` for a complete example showing before/after usage patterns.
