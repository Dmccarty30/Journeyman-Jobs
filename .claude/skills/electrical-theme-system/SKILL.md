# Electrical Theme System Skill

**Domain**: Frontend
**Category**: Visual Design
**Used By**: Theme Stylist, Electrical UI Specialist

## Skill Description
Comprehensive theming system tailored for electrical trade aesthetics, featuring copper accents, industrial colors, and safety-focused design.

## Color System

### Primary Palette
```dart
class ElectricalColors {
  // Copper tones (primary brand)
  static const copper = Color(0xFFB87333);
  static const copperLight = Color(0xFFD4915C);
  static const copperDark = Color(0xFF8B5A2B);

  // Safety colors
  static const safetyYellow = Color(0xFFFFC107);
  static const cautionOrange = Color(0xFFFF9800);
  static const dangerRed = Color(0xFFF44336);
  static const safeGreen = Color(0xFF4CAF50);

  // Industrial grays
  static const steel = Color(0xFF616161);
  static const concrete = Color(0xFF424242);
  static const charcoal = Color(0xFF212121);
}
```

### Voltage-Based Color Coding
```dart
Color getVoltageColor(double voltage) {
  if (voltage <= 50) return Colors.green;      // Low voltage
  if (voltage <= 250) return Colors.yellow;    // Medium voltage
  if (voltage <= 600) return Colors.orange;    // High voltage
  return Colors.red;                           // Extra high voltage
}
```

## Typography System
```dart
TextTheme electricalTextTheme = TextTheme(
  headline1: TextStyle(
    fontFamily: 'Industrial',
    fontWeight: FontWeight.bold,
    fontSize: 32,
    letterSpacing: -1.5,
  ),
  bodyText1: TextStyle(
    fontFamily: 'Roboto',
    fontSize: 16,
    height: 1.5,
    fontWeight: FontWeight.w400,
  ),
  // Monospace for technical data
  caption: TextStyle(
    fontFamily: 'RobotoMono',
    fontSize: 12,
  ),
);
```

## Dark Mode Optimization
```dart
ThemeData darkElectricalTheme = ThemeData(
  brightness: Brightness.dark,
  primaryColor: copper,
  scaffoldBackgroundColor: Color(0xFF0A0A0A),
  cardColor: Color(0xFF1A1A1A),

  // High contrast for field visibility
  textTheme: TextTheme(
    bodyText1: TextStyle(
      color: Colors.white.withValues(alpha:0.95),
      fontSize: 16,
    ),
  ),
);
```

## Special Effects

### Copper Shimmer Animation
```dart
ShaderMask copperShimmer = ShaderMask(
  shaderCallback: (bounds) => LinearGradient(
    colors: [copperDark, copper, copperLight],
    stops: [0.0, 0.5, 1.0],
  ).createShader(bounds),
);
```

### Circuit Pattern Overlays
- Animated circuit paths
- Glowing connection points
- Electrical flow visualization

## Icon System
- Custom electrical symbols
- Tool icons library
- Safety equipment indicators
- Certification badges

## Integration Points
- Works with: [[high-contrast-mode]]
- Enhances: [[trade-specific-widgets]]
- Supports: All UI components

## Accessibility
- WCAG 2.1 AA contrast ratios
- Color-blind safe palettes
- Clear visual hierarchy
- Consistent interaction patterns