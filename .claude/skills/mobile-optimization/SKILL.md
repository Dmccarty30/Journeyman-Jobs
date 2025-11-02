# Mobile Optimization Skill

**Domain**: Frontend
**Category**: Performance & Usability
**Used By**: Responsive Designer, Widget Specialist

## Skill Description
Comprehensive mobile optimization strategies for electrical field workers, including glove compatibility, battery efficiency, and one-handed operation.

## Glove Compatibility

### Touch Target Optimization
```dart
class GloveOptimizedButton extends StatelessWidget {
  // Minimum 56x56dp for gloved hands (vs 48x48dp standard)
  static const double minSize = 56.0;

  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      child: Container(
        minimum: Size(minSize, minSize),
        padding: EdgeInsets.all(12),
        // Extra tap padding for imprecise touches
        child: Padding(
          padding: EdgeInsets.all(-8),
          child: child,
        ),
      ),
    );
  }
}
```

### Gesture Enhancements
```dart
GestureDetector(
  // Increased hit test margins
  behavior: HitTestBehavior.opaque,
  // Longer press duration for gloves
  onLongPress: () => handleLongPress(),
  onTap: () => handleTap(),
  // Swipe gestures for navigation
  onHorizontalDragEnd: (details) {
    if (details.velocity.pixelsPerSecond.dx > 300) {
      navigateBack();
    }
  },
)
```

## Battery Efficiency

### Render Optimization
```dart
class BatteryEfficientWidget extends StatefulWidget {
  @override
  _State createState() => _State();
}

class _State extends State<BatteryEfficientWidget>
    with AutomaticKeepAliveClientMixin {

  @override
  bool get wantKeepAlive => true;

  // Reduce rebuild frequency
  bool shouldRebuild(oldWidget) {
    return hasSignificantChange(oldWidget);
  }

  // Lazy loading for off-screen content
  Widget build(BuildContext context) {
    return VisibilityDetector(
      onVisibilityChanged: (info) {
        if (info.visibleFraction < 0.1) {
          pauseAnimations();
        }
      },
      child: buildContent(),
    );
  }
}
```

### Network Efficiency
```dart
class OptimizedNetworkImage {
  // Progressive image loading
  static Widget load(String url) {
    return Image.network(
      url,
      cacheWidth: 400, // Limit resolution
      cacheHeight: 400,
      loadingBuilder: (context, child, progress) {
        return progress == null
          ? child
          : LinearProgressIndicator(
              value: progress.expectedTotalBytes != null
                ? progress.cumulativeBytesLoaded /
                  progress.expectedTotalBytes!
                : null,
            );
      },
    );
  }
}
```

## One-Handed Operation

### Reachability Zones
```dart
class ReachableLayout extends StatelessWidget {
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;

    return Column(
      children: [
        // Top 30% - Information only
        Expanded(
          flex: 3,
          child: InfoDisplay(),
        ),
        // Middle 40% - Primary content
        Expanded(
          flex: 4,
          child: MainContent(),
        ),
        // Bottom 30% - All interactive elements
        Expanded(
          flex: 3,
          child: ActionButtons(),
        ),
      ],
    );
  }
}
```

### Quick Actions
```dart
// Bottom sheet for common actions
void showQuickActions(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => Container(
      height: 200,
      child: GridView.count(
        crossAxisCount: 3,
        children: [
          QuickAction('Clock In', Icons.timer),
          QuickAction('Find Job', Icons.search),
          QuickAction('Tools', Icons.build),
          QuickAction('Safety', Icons.shield),
          QuickAction('Messages', Icons.message),
          QuickAction('Emergency', Icons.warning),
        ],
      ),
    ),
  );
}
```

## Performance Optimizations
- Debounced input handling
- Cached computed values
- Simplified animations in low-power mode
- Offline-first architecture
- Background task limitation

## Integration Points
- Works with: [[responsive-designer]]
- Enhances: [[high-contrast-mode]]
- Supports: Field work scenarios

## Metrics
- Battery drain: < 2%/hour active use
- Touch accuracy: > 95% with gloves
- One-handed reach: 100% critical actions
- App size: < 50MB