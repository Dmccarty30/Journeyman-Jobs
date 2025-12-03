# Electrical Theme Migration Guide

This guide helps you migrate from the basic theme to the enhanced electrical theme components.

## Quick Migration Steps

### 1. Import Enhanced Backgrounds

```dart
import '../../design_system/components/enhanced_backgrounds.dart';
```

### 2. Replace AppBar

**Before:**

```dart
AppBar(
  backgroundColor: AppTheme.primaryNavy,
  title: Text('Title'),
)
```

**After:**

```dart
EnhancedBackgrounds.enhancedAppBar(
  title: 'Title',
  actions: [...],
)
```

### 3. Add Circuit Pattern Background

**Before:**

```dart
Scaffold(
  backgroundColor: AppTheme.offWhite,
  body: child,
)
```

**After:**

```dart
Scaffold(
  backgroundColor: AppTheme.offWhite,
  body: EnhancedBackgrounds.circuitPatternBackground(
    opacity: 0.03,
    child: child,
  ),
)
```

### 4. Replace Cards

**Before:**

```dart
Container(
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    boxShadow: [AppTheme.shadowMd],
  ),
  child: child,
)
```

**After:**

```dart
EnhancedBackgrounds.enhancedCardBackground(
  showCircuitPattern: true,
  child: child,
)
```

### 5. Update Loading States

**Before:**

```dart
CircularProgressIndicator()
```

**After:**

```dart
EnhancedBackgrounds.sparkEffectBackground(
  child: CircularProgressIndicator(
    valueColor: AlwaysStoppedAnimation<Color>(AppTheme.accentCopper),
  ),
)
```

## Component Updates

### Home Screen

- ✅ Enhanced AppBar with electrical icon
- ✅ Circuit pattern background
- ✅ Enhanced card backgrounds for all sections
- ✅ Electrical-themed stat cards
- ✅ Gradient quick action buttons
- ✅ Spark effect loading states

### Jobs Screen

- ✅ Enhanced search bar with gradient accent
- ✅ Animated filter section
- ✅ Electrical loading indicator with rotating power flow
- ✅ Enhanced empty state with electrical theme
- ✅ Staggered card animations
- ✅ Circuit pattern overlay

### Job Cards

- ✅ Enhanced electrical headers
- ✅ Voltage level indicators
- ✅ Status gradients for storm work
- ✅ Electrical detail sections
- ✅ Classification icons
- ✅ Enhanced action buttons

## Performance Considerations

### RepaintBoundary Usage

All custom painters are wrapped in RepaintBoundary:

```dart
RepaintBoundary(
  child: CustomPaint(
    painter: CircuitPatternPainter(...),
  ),
)
```

### Animation Controllers

Dispose animation controllers properly:

```dart
@override
void dispose() {
  _sparkController.dispose();
  super.dispose();
}
```

### Conditional Rendering

Use conditional rendering for expensive widgets:

```dart
showCircuitPattern
  ? Stack([pattern, child])
  : child
```

## Accessibility Updates

### Enhanced Focus States

```dart
Material(
  child: InkWell(
    focusColor: AppTheme.accentCopper.withValues(alpha: 0.1),
    hoverColor: AppTheme.accentCopper.withValues(alpha: 0.05),
    child: child,
  ),
)
```

### Semantic Labels

```dart
Semantics(
  label: 'IBEW Local ${job.local}',
  hint: 'Tap to view job details',
  child: child,
)
```

### High Contrast Support

```dart
// Check for high contrast mode
final isHighContrast = MediaQuery.of(context).accessibleNavigation;
final patternOpacity = isHighContrast ? 0.0 : 0.03;
```

## Testing Updates

### Widget Tests

```dart
testWidgets('Enhanced job card displays electrical theme', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: EnhancedJobCard(
      job: mockJob,
      variant: JobCardVariant.full,
    ),
  ));
  
  expect(find.byIcon(Icons.electrical_services), findsOneWidget);
  expect(find.text('IBEW Local'), findsOneWidget);
  expect(find.byType(CustomPaint), findsWidgets); // Circuit patterns
});
```

### Performance Tests

```dart
testWidgets('Circuit pattern does not cause excessive rebuilds', (tester) async {
  var paintCount = 0;
  await tester.pumpWidget(
    MaterialApp(
      home: TestCircuitPattern(
        onPaint: () => paintCount++,
      ),
    ),
  );
  
  expect(paintCount, lessThan(5));
});
```

## File Structure Updates

```
lib/design_system/components/
├── enhanced_backgrounds.dart      # New electrical backgrounds
├── enhanced_job_card.dart         # Enhanced job card
├── job_card.dart                  # Original job card (keep for compatibility)
└── reusable_components.dart       # Original components
```

## Migration Checklist

- [ ] Import enhanced_backgrounds.dart in target files
- [ ] Replace AppBar with EnhancedBackgrounds.enhancedAppBar
- [ ] Add circuitPatternBackground to Scaffold body
- [ ] Replace Container cards with enhancedCardBackground
- [ ] Update loading states with sparkEffectBackground
- [ ] Add voltage status indicators where appropriate
- [ ] Update job cards to use enhanced variant
- [ ] Test accessibility with screen readers
- [ ] Verify performance on older devices
- [ ] Update widget tests for new components

## Common Issues

### Issue: Circuit patterns not showing

**Solution:** Check opacity value and ensure RepaintBoundary is used

### Issue: Animations causing performance issues

**Solution:** Reduce animation frequency or add fps limiting

### Issue: Cards not responding to taps

**Solution:** Ensure InkWell is properly configured with onTap

### Issue: Gradient colors not displaying correctly

**Solution:** Verify color values and gradient stop positions

## Rollback Plan

To rollback to original theme:

1. Remove enhanced_backgrounds.dart imports
2. Replace enhanced components with original ones
3. Remove circuit pattern backgrounds
4. Restore original AppBar implementations
5. Update tests to match original behavior
