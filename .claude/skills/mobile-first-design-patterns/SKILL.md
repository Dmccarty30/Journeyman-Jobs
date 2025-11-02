# mobile-first-design-patterns

**Skill Type**: Design Strategy | **Domain**: Frontend Development | **Complexity**: Intermediate

## Purpose

Implement mobile-first responsive design patterns optimized for electrical field workers with focus on usability, accessibility, and performance in outdoor/industrial environments.

## Core Capabilities

### 1. Field Worker Optimization
- **Large Touch Targets**: Minimum 48x48dp for glove compatibility
- **High Contrast**: Outdoor visibility in bright sunlight
- **Offline First**: Graceful degradation without connectivity
- **Battery Optimization**: Minimize resource usage for long shifts

### 2. Progressive Enhancement Strategy
```dart
Breakpoints:
- Mobile: 0-599dp (default, primary focus)
- Tablet: 600-839dp (enhanced layouts)
- Desktop: 840dp+ (adaptive multi-column)

Design Priority: Mobile → Tablet → Desktop
```

### 3. Responsive Layout Patterns
- **Single Column**: Default mobile layout
- **Adaptive Grids**: LayoutBuilder-based responsive grids
- **Bottom Sheets**: Mobile-optimized modal interactions
- **Floating Actions**: Primary actions always accessible

### 4. Touch-Optimized Interactions
- **Gesture Navigation**: Swipe, long-press, pull-to-refresh
- **Contextual Actions**: Bottom sheets over dropdowns
- **Quick Actions**: Floating action buttons for primary tasks
- **Haptic Feedback**: Tactile confirmation for actions

## Implementation Patterns

### Responsive Layout Builder
```dart
class ResponsiveLayout extends StatelessWidget {
  final Widget mobile;
  final Widget? tablet;
  final Widget? desktop;

  const ResponsiveLayout({
    Key? key,
    required this.mobile,
    this.tablet,
    this.desktop,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        if (constraints.maxWidth >= 840 && desktop != null) {
          return desktop!;
        } else if (constraints.maxWidth >= 600 && tablet != null) {
          return tablet!;
        }
        return mobile;
      },
    );
  }
}
```

### Touch-Optimized Button
```dart
class FieldButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final bool isPrimary;

  const FieldButton({
    Key? key,
    required this.label,
    this.onPressed,
    this.icon,
    this.isPrimary = false,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56, // Minimum touch target for gloves
      child: ElevatedButton.icon(
        onPressed: onPressed,
        icon: icon != null ? Icon(icon, size: 28) : SizedBox.shrink(),
        label: Text(
          label,
          style: TextStyle(
            fontSize: 18, // Large text for outdoor readability
            fontWeight: isPrimary ? FontWeight.bold : FontWeight.normal,
          ),
        ),
        style: ElevatedButton.styleFrom(
          padding: EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          elevation: isPrimary ? 4 : 2,
        ),
      ),
    );
  }
}
```

### Adaptive Grid System
```dart
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;
  final double spacing;

  const AdaptiveGrid({
    Key? key,
    required this.children,
    this.spacing = 16,
  }) : super(key: key);

  int _getColumnCount(double width) {
    if (width >= 840) return 3; // Desktop
    if (width >= 600) return 2; // Tablet
    return 1; // Mobile
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final columns = _getColumnCount(constraints.maxWidth);

        return GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: columns,
            crossAxisSpacing: spacing,
            mainAxisSpacing: spacing,
            childAspectRatio: 1.5,
          ),
          itemCount: children.length,
          itemBuilder: (context, index) => children[index],
        );
      },
    );
  }
}
```

### Bottom Sheet Modal Pattern
```dart
class MobileActionSheet {
  static Future<T?> show<T>({
    required BuildContext context,
    required String title,
    required List<ActionSheetItem<T>> actions,
  }) {
    return showModalBottomSheet<T>(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Padding(
              padding: EdgeInsets.all(16),
              child: Text(
                title,
                style: Theme.of(context).textTheme.titleLarge,
              ),
            ),
            Divider(height: 1),
            ...actions.map((action) => ListTile(
              leading: Icon(action.icon, size: 28),
              title: Text(
                action.label,
                style: TextStyle(fontSize: 18),
              ),
              onTap: () => Navigator.pop(context, action.value),
              minVerticalPadding: 16, // Large touch target
            )),
          ],
        ),
      ),
    );
  }
}

class ActionSheetItem<T> {
  final String label;
  final IconData icon;
  final T value;

  const ActionSheetItem({
    required this.label,
    required this.icon,
    required this.value,
  });
}
```

### Pull-to-Refresh Pattern
```dart
class RefreshableList<T> extends StatelessWidget {
  final List<T> items;
  final Future<void> Function() onRefresh;
  final Widget Function(BuildContext, T) itemBuilder;

  const RefreshableList({
    Key? key,
    required this.items,
    required this.onRefresh,
    required this.itemBuilder,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: onRefresh,
      strokeWidth: 3, // Visible indicator
      displacement: 60, // Extra space for visibility
      child: ListView.builder(
        physics: AlwaysScrollableScrollPhysics(), // Enable pull even when empty
        itemCount: items.length,
        itemBuilder: (context, index) => itemBuilder(context, items[index]),
      ),
    );
  }
}
```

## Best Practices

### Touch Target Guidelines
```dart
const kMinTouchTarget = 48.0; // Minimum for glove compatibility
const kRecommendedTouchTarget = 56.0; // Recommended for field work
const kIconSize = 28.0; // Visible in bright sunlight
const kSpacingUnit = 16.0; // Consistent spacing
```

### Typography for Outdoor Visibility
```dart
class FieldTextTheme {
  static const headlineLarge = TextStyle(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    height: 1.2,
  );

  static const titleLarge = TextStyle(
    fontSize: 22,
    fontWeight: FontWeight.w600,
    height: 1.3,
  );

  static const bodyLarge = TextStyle(
    fontSize: 18, // Larger than standard for outdoor readability
    height: 1.5,
  );

  static const labelLarge = TextStyle(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5, // Improved clarity
  );
}
```

### Spacing System
```dart
class FieldSpacing {
  static const xs = 4.0;
  static const sm = 8.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
  static const xxl = 48.0;

  // Touch-safe margins
  static const touchSafe = 12.0; // Prevent accidental edge taps
}
```

### Offline-First Patterns
```dart
class OfflineIndicator extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<bool>(
      stream: ConnectivityService().isOnline,
      builder: (context, snapshot) {
        final isOnline = snapshot.data ?? false;

        if (isOnline) return SizedBox.shrink();

        return Container(
          width: double.infinity,
          padding: EdgeInsets.symmetric(vertical: 8),
          color: Colors.orange.shade800,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(Icons.cloud_off, color: Colors.white, size: 20),
              SizedBox(width: 8),
              Text(
                'Offline Mode - Changes will sync when connected',
                style: TextStyle(color: Colors.white, fontSize: 14),
              ),
            ],
          ),
        );
      },
    );
  }
}
```

## Performance Optimization

### Battery-Conscious Practices
- **Minimize Animations**: Use simple transitions, avoid continuous animations
- **Lazy Loading**: Load content on demand with ListView.builder
- **Image Optimization**: Cache and compress images, use thumbnails
- **Background Tasks**: Batch sync operations, respect battery state

### Memory Management
```dart
class OptimizedImageWidget extends StatelessWidget {
  final String imageUrl;
  final double? width;
  final double? height;

  @override
  Widget build(BuildContext context) {
    return CachedNetworkImage(
      imageUrl: imageUrl,
      memCacheWidth: width?.toInt(),
      memCacheHeight: height?.toInt(),
      placeholder: (context, url) => Container(
        color: Colors.grey.shade300,
        child: Icon(Icons.image, color: Colors.grey.shade600),
      ),
      errorWidget: (context, url, error) => Icon(Icons.error),
    );
  }
}
```

## Accessibility Features

### Screen Reader Support
```dart
class AccessibleCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      label: '$title. $description',
      button: true,
      onTap: onTap,
      child: Card(
        child: InkWell(
          onTap: onTap,
          child: Padding(
            padding: EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: Theme.of(context).textTheme.titleMedium),
                SizedBox(height: 8),
                Text(description),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

## Quality Standards

- **Touch Targets**: Minimum 48dp, recommended 56dp for field work
- **Font Sizes**: Minimum 16sp for body text, 18sp recommended
- **Contrast Ratio**: Minimum 4.5:1, 7:1 recommended for outdoor use
- **Performance**: Maintain 60fps, optimize for battery life
- **Offline Support**: Core features work without connectivity

## Related Skills
- `flutter-widget-architecture` - Component structure and composition
- `high-contrast-mode` - Outdoor visibility optimization
- `mobile-optimization` - Performance and battery optimization
- `adaptive-layout` - Multi-screen responsive patterns
