# Optimized Virtual Scrolling Skill

**Domain**: Frontend
**Category**: Performance Optimization
**Used By**: Widget Specialist, Responsive Designer

## Skill Description
Expertise in implementing efficient scrolling for large lists of jobs, workers, and tools using Flutter's ListView.builder and advanced virtualization techniques.

## Key Techniques

### 1. ListView.builder Pattern
```dart
ListView.builder(
  itemCount: jobs.length,
  itemBuilder: (context, index) {
    // Only builds visible items
    return JobCard(job: jobs[index]);
  },
  // Optimization parameters
  cacheExtent: 200, // Pixels to cache off-screen
  physics: AlwaysScrollableScrollPhysics(),
)
```

### 2. Viewport Management
- Calculate visible item range
- Pre-render upcoming items
- Dispose off-screen widgets
- Maintain scroll position on rebuild

### 3. Item Height Optimization
```dart
// Fixed height items for better performance
ListView.builder(
  itemExtent: 120.0, // Fixed height
  // 3x faster than dynamic sizing
)
```

### 4. Lazy Loading Strategy
```dart
class LazyLoadingList {
  // Load more items when approaching end
  void onScroll(ScrollPosition position) {
    if (position.pixels > position.maxScrollExtent * 0.8) {
      loadMoreItems();
    }
  }
}
```

## Performance Patterns

### Memory Management
- Release images when scrolled off-screen
- Use thumbnail placeholders
- Implement progressive image loading
- Cache frequently accessed items

### Scroll Performance
- Target 60fps during fast scrolling
- Reduce widget complexity in lists
- Use RepaintBoundary for complex items
- Implement scroll-to-top functionality

## Integration Points
- Works with: [[flutter-widget-architecture]]
- Enhances: [[mobile-optimization]]
- Supports: Large job lists, worker directories, tool catalogs

## Metrics
- Scroll jank: < 1%
- Memory usage: < 50MB for 1000 items
- Initial load: < 100ms
- Frame rate: 60fps consistent