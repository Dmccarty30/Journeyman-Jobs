# DynamicContainerRow - Developer Quick Reference

## Quick Import
```dart
import 'package:journeyman_jobs/features/crews/widgets/dynamic_container_row.dart';
```

## Basic Usage

### Standard Variant (Text Only)
```dart
DynamicContainerRow(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  selectedIndex: _currentTabIndex,
  onTap: (index) {
    setState(() => _currentTabIndex = index);
  },
)
```

### Icon Variant
```dart
DynamicContainerRowWithIcons(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  icons: [
    Icons.feed_outlined,
    Icons.work_outline,
    Icons.chat_bubble_outline,
    Icons.group_outlined,
  ],
  selectedIndex: _currentTabIndex,
  onTap: (index) {
    setState(() => _currentTabIndex = index);
  },
)
```

## Parameters

| Parameter | Type | Required | Default | Description |
|-----------|------|----------|---------|-------------|
| `labels` | `List<String>` | ✅ Yes | - | Exactly 4 labels for containers |
| `selectedIndex` | `int` | No | 0 | Currently selected container (0-3) |
| `onTap` | `ValueChanged<int>?` | No | null | Callback when container tapped |
| `height` | `double?` | No | 60.0 / 80.0* | Custom container height |
| `spacing` | `double?` | No | 8.0 | Space between containers |

*80.0 default for icon variant, 60.0 for standard

## Common Patterns

### 1. With TabController (Recommended)
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicContainerRow(
          labels: ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: _selectedTab,
          onTap: (index) => _tabController.animateTo(index),
        ),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [
              FeedTab(),
              JobsTab(),
              ChatTab(),
              MembersTab(),
            ],
          ),
        ),
      ],
    );
  }
}
```

### 2. Simple State Management
```dart
class MyScreen extends StatefulWidget {
  @override
  State<MyScreen> createState() => _MyScreenState();
}

class _MyScreenState extends State<MyScreen> {
  int _currentIndex = 0;

  final _screens = [FeedScreen(), JobsScreen(), ChatScreen(), MembersScreen()];

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        DynamicContainerRow(
          labels: ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
        ),
        Expanded(child: _screens[_currentIndex]),
      ],
    );
  }
}
```

### 3. With Riverpod State Management
```dart
final selectedTabProvider = StateProvider<int>((ref) => 0);

class MyScreen extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final selectedTab = ref.watch(selectedTabProvider);

    return Column(
      children: [
        DynamicContainerRow(
          labels: ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: selectedTab,
          onTap: (index) => ref.read(selectedTabProvider.notifier).state = index,
        ),
        Expanded(child: _getTabContent(selectedTab)),
      ],
    );
  }
}
```

### 4. Custom Height and Spacing
```dart
DynamicContainerRow(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  selectedIndex: 0,
  height: 80.0,        // Custom height
  spacing: 12.0,       // Custom spacing
  onTap: (index) {
    // Handle tap
  },
)
```

### 5. Disabled State (No Interaction)
```dart
DynamicContainerRow(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  selectedIndex: _currentIndex,
  onTap: null,  // No callback = no interaction
)
```

## Constraints and Validation

### ✅ Valid Usage
```dart
// Exactly 4 labels (required)
labels: ['Feed', 'Jobs', 'Chat', 'Members']

// Index within bounds
selectedIndex: 0  // or 1, 2, 3

// Null callback is valid (disables interaction)
onTap: null
```

### ❌ Invalid Usage (Will Throw AssertionError)
```dart
// Too few labels
labels: ['Feed', 'Jobs', 'Chat']  // Only 3

// Too many labels
labels: ['Feed', 'Jobs', 'Chat', 'Members', 'Extra']  // 5

// Index out of bounds (will not throw, but won't visually select)
selectedIndex: 5
```

## Styling Customization

### Default Theme Integration
The widget automatically uses AppTheme values:
- Border radius: `AppTheme.radiusMd` (12.0)
- Border width: `AppTheme.borderWidthCopper` (2.5)
- Border color: `AppTheme.accentCopper` (#B45309)
- Shadow: `AppTheme.shadowMd`
- Typography: `AppTheme.labelMedium`

### No Custom Styling Needed
The widget is designed to match the electrical theme automatically. If you need custom colors, consider creating a new widget variant rather than modifying this one.

## Performance Tips

### ✅ Good Practices
```dart
// 1. Use const for labels when possible
const labels = ['Feed', 'Jobs', 'Chat', 'Members'];

// 2. Avoid rebuilding parent unnecessarily
// Use keys or separate state management

// 3. Keep onTap handlers lightweight
onTap: (index) {
  ref.read(tabProvider.notifier).state = index; // Fast
}
```

### ❌ Avoid
```dart
// 1. Don't create new lists on every build
labels: ['Feed', 'Jobs', 'Chat', 'Members'],  // Creates new list each time

// 2. Don't do heavy work in onTap
onTap: (index) async {
  await fetchData();  // BAD - do this elsewhere
  setState(() => _index = index);
}
```

## Testing

### Widget Test Example
```dart
testWidgets('tapping container calls callback with correct index', (tester) async {
  int? tappedIndex;

  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: DynamicContainerRow(
          labels: ['Feed', 'Jobs', 'Chat', 'Members'],
          selectedIndex: 0,
          onTap: (index) => tappedIndex = index,
        ),
      ),
    ),
  );

  await tester.tap(find.text('Chat'));
  await tester.pumpAndSettle();

  expect(tappedIndex, equals(2));
});
```

### Integration Test
```dart
// In tailboard_screen_test.dart
testWidgets('DynamicContainerRow switches tabs', (tester) async {
  await tester.pumpWidget(MyApp());

  // Initial state
  expect(find.text('Feed Content'), findsOneWidget);

  // Tap Jobs tab
  await tester.tap(find.text('Jobs'));
  await tester.pumpAndSettle();

  expect(find.text('Jobs Content'), findsOneWidget);
  expect(find.text('Feed Content'), findsNothing);
});
```

## Accessibility Enhancements (Recommended)

### Add Semantic Labels
```dart
// Wrap in Semantics for screen reader support
Semantics(
  label: '${labels[index]} tab, ${isSelected ? 'selected' : 'not selected'}',
  button: true,
  selected: isSelected,
  child: DynamicContainerRow(...)
)
```

### Add Haptic Feedback
```dart
import 'package:flutter/services.dart';

onTap: (index) {
  HapticFeedback.selectionClick();
  setState(() => _currentIndex = index);
}
```

## Common Issues and Solutions

### Issue 1: Containers Not Updating
**Problem:** Selected index changes but containers don't update
**Solution:** Ensure widget rebuilds when state changes
```dart
// BAD
DynamicContainerRow(
  selectedIndex: 0,  // Hard-coded, never changes
)

// GOOD
DynamicContainerRow(
  selectedIndex: _currentIndex,  // State variable
)
```

### Issue 2: Text Overflow
**Problem:** Long labels don't fit
**Solution:** Widget automatically truncates with ellipsis. Use shorter labels or increase container width.
```dart
// Short, descriptive labels work best
labels: ['Feed', 'Jobs', 'Chat', 'Members']  // ✅

// Avoid very long labels
labels: ['Activity Feed', 'Job Postings', 'Chat Messages', 'Team Members']  // ⚠️
```

### Issue 3: Touch Not Registering
**Problem:** onTap callback not firing
**Solution:** Check if callback is null or widget is overlapped
```dart
// Ensure callback is not null
onTap: (index) {
  print('Tapped: $index');  // Debug
  setState(() => _index = index);
}

// Check for overlapping widgets in DevTools
```

## Migration from Other Tab Widgets

### From Flutter TabBar
```dart
// BEFORE
TabBar(
  tabs: [
    Tab(text: 'Feed'),
    Tab(text: 'Jobs'),
    Tab(text: 'Chat'),
    Tab(text: 'Members'),
  ],
)

// AFTER
DynamicContainerRow(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  selectedIndex: _tabController.index,
  onTap: (index) => _tabController.animateTo(index),
)
```

### From BottomNavigationBar
```dart
// BEFORE
BottomNavigationBar(
  currentIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
  items: [
    BottomNavigationBarItem(icon: Icon(Icons.feed), label: 'Feed'),
    BottomNavigationBarItem(icon: Icon(Icons.work), label: 'Jobs'),
    BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
    BottomNavigationBarItem(icon: Icon(Icons.group), label: 'Members'),
  ],
)

// AFTER (icon variant)
DynamicContainerRowWithIcons(
  labels: ['Feed', 'Jobs', 'Chat', 'Members'],
  icons: [Icons.feed, Icons.work, Icons.chat, Icons.group],
  selectedIndex: _currentIndex,
  onTap: (index) => setState(() => _currentIndex = index),
)
```

## Variants Comparison

| Feature | DynamicContainerRow | DynamicContainerRowWithIcons |
|---------|-------------------|----------------------------|
| Icons | ❌ No | ✅ Yes |
| Default Height | 60.0 | 80.0 |
| Parameters | 5 | 6 (adds `icons`) |
| Use Case | Text-only navigation | Icon + text navigation |
| Visual Density | Compact | Standard |

## Real-World Example (Tailboard Screen)

```dart
class TailboardScreen extends ConsumerStatefulWidget {
  @override
  ConsumerState<TailboardScreen> createState() => _TailboardScreenState();
}

class _TailboardScreenState extends ConsumerState<TailboardScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _selectedTab = 0;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 4, vsync: this);
    _tabController.addListener(() {
      setState(() => _selectedTab = _tabController.index);
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          // Header
          CrewHeader(),

          // Navigation (DynamicContainerRow)
          DynamicContainerRow(
            labels: ['Feed', 'Jobs', 'Chat', 'Members'],
            selectedIndex: _selectedTab,
            onTap: (index) => _tabController.animateTo(index),
          ),

          // Content
          Expanded(
            child: TabBarView(
              controller: _tabController,
              children: [
                FeedTab(),
                JobsTab(),
                ChatTab(),
                MembersTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
```

## Resources

- **Widget Source:** `lib/features/crews/widgets/dynamic_container_row.dart`
- **Tests:** `test/features/crews/widgets/dynamic_container_row_test.dart`
- **Design System:** `lib/design_system/app_theme.dart`
- **Example Usage:** `lib/features/crews/screens/tailboard_screen.dart`

## Version History

- **v1.0** (Current) - Initial release with standard and icon variants
- Supports exactly 4 containers
- Electrical theme integration
- Full test coverage

---

**Last Updated:** January 6, 2025
**Component:** DynamicContainerRow
**Platform:** Journeyman Jobs - IBEW Electrical Workers
