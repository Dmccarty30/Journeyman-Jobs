# Gradient Splash Screen Implementation

## Overview
Two gradient splash screen options inspired by Ten Percent Happier's design, adapted for Journeyman Jobs with Navy/Copper color scheme.

## 🎨 Design Comparison

### Original (Ten Percent Happier)
- Yellow to pink/purple gradient
- White circle logo with curved line
- Clean typography
- Progress bar at bottom
- Attribution footer

### Journeyman Jobs Adaptation
- **Option 1**: Copper to Navy static gradient
- **Option 2**: Animated flowing gradient with circuit pattern
- JJ app icon with glow effect
- IBEW-focused messaging
- Professional electrical theme

## 📦 Implementation

### Option 1: Static Gradient Splash
```dart
import 'package:journeyman_jobs/screens/splash/gradient_splash_screen.dart';

// In your main.dart or app router
home: const GradientSplashScreen(),
```

**Features:**
- Smooth copper-to-navy gradient
- Animated app icon with elastic curve
- Loading progress bar
- Clean, professional appearance

### Option 2: Animated Gradient Splash
```dart
import 'package:journeyman_jobs/screens/splash/gradient_splash_screen.dart';

// In your main.dart or app router
home: const AnimatedGradientSplashScreen(),
```

**Features:**
- Dynamic gradient animation
- Electrical circuit pattern overlay
- Animated loading dots
- More engaging and dynamic

## 🎯 Key Components

### Gradient Colors
```dart
// Option 1 - Static Gradient
colors: [
  Color(0xFFFFD700),  // Golden yellow
  Color(0xFFFF6B6B),  // Coral pink  
  Color(0xFF4A5568),  // Deep blue-gray
]

// Option 2 - Animated Gradient
colors: [
  AppTheme.accentCopper.withOpacity(0.9),
  Color(0xFFE67E22),  // Darker orange
  AppTheme.primaryNavy.withOpacity(0.8),
  Color(0xFF2C3E50),  // Darker navy
]
```

### Animation Timing
- Icon scale animation: 800-1000ms with elastic curve
- Text fade-in: 600-800ms with slide
- Total duration: 4 seconds before navigation
- Progress bar: Linear animation over 3 seconds

### Status Bar Styling
```dart
SystemChrome.setSystemUIOverlayStyle(
  const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.dark,
    statusBarBrightness: Brightness.light,
  ),
);
```

## 🔧 Customization Options

### Change Animation Duration
```dart
// In initState()
Future.delayed(const Duration(seconds: 4), () {
  // Change to desired duration
});
```

### Modify Gradient Direction
```dart
// Static gradient
gradient: LinearGradient(
  begin: Alignment.topLeft,     // Change start point
  end: Alignment.bottomRight,   // Change end point
  colors: [...],
)

// Animated gradient
_topAlignmentAnimation = TweenSequence<Alignment>([
  // Modify animation sequence
]).animate(_gradientController);
```

### Update Text Content
```dart
// App name
Text(
  'Journeyman',
  style: AppTheme.displaySmall.copyWith(...),
),
Text(
  'Jobs',
  style: AppTheme.displayMedium.copyWith(...),
),

// Tagline (Option 2)
Text(
  'IBEW Job Referral',
  style: AppTheme.headlineSmall.copyWith(...),
),
Text(
  'Made Simple',
  style: AppTheme.displaySmall.copyWith(...),
),
```

## 🚀 Integration Steps

1. **Add splash screen to your app:**
   ```dart
   // main.dart
   class MyApp extends StatelessWidget {
     @override
     Widget build(BuildContext context) {
       return MaterialApp(
         home: const GradientSplashScreen(), // or AnimatedGradientSplashScreen
       );
     }
   }
   ```

2. **Setup navigation after splash:**
   ```dart
   // In splash screen initState()
   Future.delayed(const Duration(seconds: 4), () {
     if (mounted) {
       Navigator.of(context).pushReplacement(
         MaterialPageRoute(
           builder: (context) => const MainNavigationScreen(),
         ),
       );
     }
   });
   ```

3. **Add Hero animation (optional):**
   ```dart
   // Wrap logo in Hero widget
   Hero(
     tag: 'app_logo',
     child: Container(
       // Logo container
     ),
   )
   ```

## 🎭 Visual Effects

### Glow Effect
```dart
boxShadow: [
  BoxShadow(
    color: AppTheme.white.withOpacity(0.5),
    blurRadius: 30,
    spreadRadius: 10,
  ),
]
```

### Circuit Pattern (Option 2)
- Subtle electrical circuit lines
- Animated dots at connection points
- Opacity: 5% for subtle effect

### Loading Indicators
- **Option 1**: Progress bar with fractional sizing
- **Option 2**: Three animated dots with staggered fade

## ✅ Checklist

- [ ] Choose between static or animated gradient
- [ ] Verify app icon path: `assets/images/app_launcher_icon.png`
- [ ] Update navigation destination after splash
- [ ] Test on different screen sizes
- [ ] Verify gradient colors match brand
- [ ] Check animation performance on older devices
- [ ] Ensure status bar styling is correct

## 📱 Screen Compatibility

Both splash screens are responsive and work on:
- All iPhone models (including notched devices)
- Android phones and tablets
- iPad (scales appropriately)
- Landscape orientation (centers content)

The gradient and animations automatically adjust to screen size while maintaining visual appeal.
