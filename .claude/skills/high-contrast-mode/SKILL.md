# High Contrast Mode Skill

**Domain**: Frontend
**Category**: Accessibility & Field Optimization
**Used By**: Theme Stylist, Responsive Designer

## Skill Description
Specialized high-contrast theming for outdoor visibility, ensuring electrical workers can use the app in bright sunlight, dusty conditions, and while wearing safety glasses.

## Contrast Strategies

### Outdoor Mode
```dart
ThemeData outdoorTheme = ThemeData(
  // Maximum contrast ratios
  textTheme: TextTheme(
    bodyText1: TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.w600, // Bolder text
      fontSize: 18, // Larger default size
    ),
  ),

  // Pure white backgrounds
  scaffoldBackgroundColor: Colors.white,
  cardColor: Color(0xFFF5F5F5),

  // Bold borders
  cardTheme: CardTheme(
    shape: RoundedRectangleBorder(
      side: BorderSide(color: Colors.black, width: 2),
      borderRadius: BorderRadius.circular(8),
    ),
  ),
);
```

### Safety Glasses Mode
```dart
// Compensate for tinted safety glasses
ThemeData safetyGlassesTheme = ThemeData(
  // Increased saturation
  primaryColor: Color(0xFFFF6B00), // Vibrant orange
  accentColor: Color(0xFFFFD700),  // Bright gold

  // Higher contrast text
  textTheme: TextTheme(
    bodyText1: TextStyle(
      color: Color(0xFF000000),
      shadows: [
        Shadow(
          color: Colors.white,
          blurRadius: 2,
        ),
      ],
    ),
  ),
);
```

## Visibility Enhancements

### Text Optimization
```dart
class HighContrastText extends StatelessWidget {
  final String text;
  final bool critical;

  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(4),
      decoration: critical
        ? BoxDecoration(
            color: Colors.yellow,
            border: Border.all(color: Colors.black, width: 2),
          )
        : null,
      child: Text(
        text,
        style: TextStyle(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
```

### Button Visibility
```dart
ElevatedButton highContrastButton = ElevatedButton(
  style: ElevatedButton.styleFrom(
    minimumSize: Size(64, 64), // Large touch targets
    side: BorderSide(color: Colors.black, width: 3),
    elevation: 8, // Strong shadows
  ),
  onPressed: () {},
  child: Text('ACTION', style: TextStyle(fontSize: 18)),
);
```

## Environmental Adaptations

### Brightness Detection
```dart
void adaptToEnvironment(double brightness) {
  if (brightness > 50000) {
    // Direct sunlight
    activateMaximumContrast();
  } else if (brightness > 10000) {
    // Bright outdoor
    activateHighContrast();
  } else {
    // Indoor/shade
    useStandardTheme();
  }
}
```

### Dust/Dirt Compensation
- Larger UI elements
- Increased spacing
- Bold outlines
- Reduced detail in icons

## Performance Considerations
- Simplified gradients (solid colors preferred)
- Reduced animations in bright mode
- Cached theme switching
- Battery-efficient white backgrounds

## Integration Points
- Works with: [[electrical-theme-system]]
- Enhances: [[mobile-optimization]]
- Supports: Field work scenarios

## Accessibility Metrics
- Contrast ratio: > 7:1 (WCAG AAA)
- Touch target size: > 48x48dp
- Text readability: 100% at arm's length
- Glare resistance: Optimized