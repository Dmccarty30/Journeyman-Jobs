# Adaptive Layout Skill

**Domain**: Frontend
**Category**: Responsive Design
**Used By**: Responsive Designer, Widget Specialist

## Skill Description

Dynamic layout system that adapts to screen sizes, orientations, and device capabilities, ensuring optimal user experience across all platforms.

## Screen Size Detection

### Breakpoint System

```dart
enum ScreenSize {
  compact,  // < 600dp (phones)
  medium,   // 600-840dp (tablets, foldables)
  expanded, // > 840dp (tablets, desktop)
}

class AdaptiveLayout extends StatelessWidget {
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;

    if (width < 600) {
      return CompactLayout();
    } else if (width < 840) {
      return MediumLayout();
    } else {
      return ExpandedLayout();
    }
  }
}
```

### Orientation Handling

```dart
class OrientationAwareWidget extends StatelessWidget {
  Widget build(BuildContext context) {
    final orientation = MediaQuery.of(context).orientation;

    return orientation == Orientation.portrait
      ? PortraitLayout()
      : LandscapeLayout();
  }
}
```

## Adaptive Components

### Navigation Patterns

```dart
class AdaptiveNavigation extends StatelessWidget {
  Widget build(BuildContext context) {
    final size = getScreenSize(context);

    switch (size) {
      case ScreenSize.compact:
        return BottomNavigationBar(
          items: navigationItems,
        );

      case ScreenSize.medium:
        return NavigationRail(
          destinations: railDestinations,
          extended: false,
        );

      case ScreenSize.expanded:
        return NavigationDrawer(
          children: drawerItems,
        );
    }
  }
}
```

### Grid Systems

```dart
class AdaptiveGrid extends StatelessWidget {
  final List<Widget> children;

  int getCrossAxisCount(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    if (width < 600) return 1;  // Single column
    if (width < 900) return 2;  // Two columns
    if (width < 1200) return 3; // Three columns
    return 4;                   // Four columns
  }

  Widget build(BuildContext context) {
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: getCrossAxisCount(context),
        childAspectRatio: 1.5,
        crossAxisSpacing: 16,
        mainAxisSpacing: 16,
      ),
      itemBuilder: (context, index) => children[index],
      itemCount: children.length,
    );
  }
}
```

## Master-Detail Pattern

```dart
class AdaptiveMasterDetail extends StatelessWidget {
  final Widget master;
  final Widget? detail;

  Widget build(BuildContext context) {
    final isTablet = MediaQuery.of(context).size.width > 600;

    if (isTablet && detail != null) {
      // Side-by-side on tablets
      return Row(
        children: [
          Expanded(flex: 2, child: master),
          VerticalDivider(),
          Expanded(flex: 3, child: detail!),
        ],
      );
    } else {
      // Stack navigation on phones
      return Navigator(
        pages: [
          MaterialPage(child: master),
          if (detail != null) MaterialPage(child: detail!),
        ],
      );
    }
  }
}
```

## Foldable Device Support

```dart
class FoldableAware extends StatelessWidget {
  Widget build(BuildContext context) {
    final hinge = MediaQuery.of(context).hinge;

    if (hinge != null) {
      // Device is foldable and has a hinge
      return TwoPaneView(
        paneProportion: 0.5,
        panePriority: TwoPanePriority.both,
        pane1: LeftPane(),
        pane2: RightPane(),
      );
    }

    return StandardLayout();
  }
}
```

## Content Adaptation

### Text Scaling

```dart
Text adaptiveText(String text, BuildContext context) {
  final screenWidth = MediaQuery.of(context).size.width;
  final scaleFactor = screenWidth < 360 ? 0.85 :
                      screenWidth < 600 ? 1.0 :
                      screenWidth < 900 ? 1.15 : 1.3;

  return Text(
    text,
    style: Theme.of(context).textTheme.bodyText1!.copyWith(
      fontSize: 16 * scaleFactor,
    ),
  );
}
```

### Image Optimization

```dart
Widget adaptiveImage(String url, BuildContext context) {
  final pixelRatio = MediaQuery.of(context).devicePixelRatio;
  final width = MediaQuery.of(context).size.width;

  return Image.network(
    url,
    cacheWidth: (width * pixelRatio).toInt(),
    fit: BoxFit.cover,
  );
}
```

## Integration Points

- Works with: [[responsive-designer]]
- Enhances: [[mobile-first-design-patterns]]
- Supports: All screen sizes and orientations

## Performance Metrics

- Layout shift: < 0.1 CLS
- Adaptation time: < 100ms
- Memory efficiency: Optimized for device
- Orientation change: Smooth transition
