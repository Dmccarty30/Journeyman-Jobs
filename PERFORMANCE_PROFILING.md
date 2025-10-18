# Performance Profiling Guide

## Overview
This guide provides step-by-step instructions for diagnosing performance issues (frame skipping/jank) in the Journeyman Jobs Flutter app using Flutter DevTools.

## Preparation

### 1. Use a Physical Device
- Connect a physical Android or iOS device for realistic performance data
- Emulators often have different performance characteristics

### 2. Run in Profile Mode
```bash
flutter run --profile
```
Profile mode provides optimized performance with debugging information intact.

## Starting DevTools

### Option A: From Terminal
```bash
dart devtools
```
Open the provided URL in your browser and connect to the running app.

### Option B: From IDE
- **VS Code**: Command Palette → "Flutter: Open DevTools"
- **Android Studio**: Flutter Inspector → "Open DevTools"

## Performance Analysis Workflow

### 1. Record Performance Data
1. Open DevTools and navigate to the **Performance** tab
2. Click **Start Recording** 🔴
3. Reproduce the frame skipping scenario in your app:
   - Navigate between screens
   - Scroll through job lists
   - Interact with complex UI elements
4. Click **Stop Recording** ⏹️

### 2. Analyze the Flame Chart
Look for these performance indicators:

#### Frame Time Analysis
- **Green bars**: Good frames (< 16.67ms for 60fps)
- **Yellow bars**: Slow frames (16.67-33.33ms)
- **Red bars**: Janky frames (> 33.33ms)

#### Thread Analysis
- **UI Thread**: Dart code execution, widget building
- **Raster Thread**: GPU rendering, painting

### 3. Identify Common Issues

#### Build Performance Issues
- **Long build phases**: Large widget trees rebuilding unnecessarily
- **Expensive computations**: Heavy operations in build methods
- **Solution**: Use `const` constructors, memoization, or `RepaintBoundary`

#### Layout Performance Issues
- **Deep widget nesting**: Complex layout calculations
- **Intrinsic dimensions**: Widgets that require multiple layout passes
- **Solution**: Flatten widget hierarchy, use `Flexible` instead of `IntrinsicWidth`

#### Paint Performance Issues
- **Overdraw**: Multiple layers painting over each other
- **Complex shapes**: Heavy clipping, gradients, or shadows
- **Solution**: Use `RepaintBoundary`, optimize decorations

#### Asset Loading Issues
- **Image loading**: Large images loaded synchronously
- **Font loading**: Custom fonts causing layout shifts
- **Solution**: Pre-cache images, use `precacheImage()`

### 4. Shader Compilation Issues
Look for shader compilation spikes (common cause of first-run jank):
- **Symptoms**: Sharp spikes in frame time on first interaction
- **Solution**: Capture and bundle SkSL warmups for release builds

## Advanced Profiling Tools

### Flutter Performance Overlay
Add runtime performance visualization:
```dart
import 'package:flutter/rendering.dart';

// In main() or debug builds
debugPaintSizeEnabled = true; // Shows widget boundaries
```

Or use the performance overlay:
```bash
flutter run --profile --enable-performance-overlay
```

### Widget Inspector
- Enable **Select Widget Mode** to understand widget hierarchy
- Use **Widget Details Tree** to identify expensive rebuilds

## Actionable Performance Fixes

### For Journeyman Jobs App Specifically:

1. **Job List Optimization**
   - Use `ListView.builder` for large lists
   - Implement pagination with `NotificationListener`
   - Cache job card widgets with `AutomaticKeepAliveClientMixin`

2. **Image Optimization**
   - Pre-cache company logos and user avatars
   - Use `CachedNetworkImage` for remote images
   - Implement progressive image loading

3. **State Management Performance**
   - Minimize Riverpod provider rebuilds
   - Use `select()` for specific state slices
   - Implement proper `keys` for list items

4. **UI Thread Optimization**
   - Move heavy computations to `compute()` isolates
   - Use `Builder` widgets to minimize rebuild scope
   - Implement lazy loading for off-screen content

## Validation Checklist

After implementing fixes:
- [ ] Frame times consistently under 16ms during normal usage
- [ ] No red bars in DevTools timeline during common interactions
- [ ] Smooth scrolling in job lists and detailed views
- [ ] No visible jank during navigation transitions
- [ ] Shader compilation spikes eliminated in release builds

## Continuous Monitoring

Consider integrating performance monitoring:
- **Firebase Performance**: Track real-world app performance
- **Custom metrics**: Track specific user flows
- **Automated testing**: Include performance tests in CI/CD

## Additional Resources

- [Flutter Performance Best Practices](https://flutter.dev/docs/perf/best-practices)
- [Identifying Performance Problems](https://flutter.dev/docs/perf/ui-performance)
- [DevTools Performance Tab](https://flutter.dev/docs/development/tools/devtools/performance)