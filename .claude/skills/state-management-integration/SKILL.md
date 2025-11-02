# State Management Integration Skill

**Domain**: Frontend
**Category**: State Integration
**Used By**: Widget Specialist, Frontend Orchestrator

## Skill Description
Expertise in connecting Flutter UI components with Riverpod state management, implementing reactive patterns and efficient state consumption.

## Key Techniques

### 1. ConsumerWidget Pattern
```dart
class JobListView extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final jobs = ref.watch(jobsProvider);
    final filters = ref.watch(filterProvider);

    return jobs.when(
      data: (data) => ListView.builder(...),
      loading: () => CircularProgressIndicator(),
      error: (err, stack) => ErrorWidget(err),
    );
  }
}
```

### 2. Selective Rebuilds
```dart
// Only rebuild when specific state changes
final selectedJob = ref.watch(
  jobsProvider.select((jobs) => jobs.selectedJob)
);
```

### 3. State Modification Patterns
```dart
// Modify state through notifiers
ElevatedButton(
  onPressed: () {
    ref.read(jobsProvider.notifier).addJob(newJob);
  },
  child: Text('Add Job'),
)
```

### 4. Provider Scoping
```dart
ProviderScope(
  overrides: [
    // Override for specific widget tree
    userProvider.overrideWithValue(specificUser),
  ],
  child: JobDetailsScreen(),
)
```

## Integration Patterns

### Async State Handling
- Loading states with skeletons
- Error boundary implementation
- Retry mechanisms
- Optimistic updates

### Performance Optimization
- Use select() for granular updates
- Implement provider caching
- Dispose providers when not needed
- Use family modifiers for parameterized state

## Widget Patterns
```dart
// Hook for complex state logic
class ComplexWidget extends HookConsumerWidget {
  Widget build(BuildContext context, WidgetRef ref) {
    final controller = useTextEditingController();
    final isLoading = useState(false);

    // Combine hooks with providers
    final data = ref.watch(dataProvider);

    return ...;
  }
}
```

## Best Practices
- Separate UI from business logic
- Keep widgets pure when possible
- Handle disposal properly
- Test state changes in isolation

## Integration Points
- Connects: UI layer to state layer
- Works with: [[riverpod-provider-patterns]]
- Enhances: [[flutter-widget-architecture]]

## Performance Metrics
- State update latency: < 16ms
- Unnecessary rebuilds: 0
- Memory leaks: None
- Provider overhead: < 5%