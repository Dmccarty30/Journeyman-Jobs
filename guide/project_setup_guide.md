# Journeyman Jobs - Design System & Splash Screen Setup Guide

## 📁 File Structure

Create the following files in your Flutter project:

```tree
lib/
├── main.dart                          # Main app entry point
├── design_system/
│   ├── app_theme.dart                 # Complete design system
│   └── components/
│       └── reusable_components.dart   # All reusable UI components
├── screens/
│   ├── splash/
│   │   └── splash_screen.dart         # Splash screen with animations
│   ├── home/
│   │   └── home_screen.dart          # Main job listings screen
│   └── jobs/
│       └── job_details_screen.dart   # Individual job details
└── widgets/
    └── common/                       # Additional shared widgets
```

## 🎨 Design System Features

### **Colors & Gradients**

- **Primary Navy**: `#1a202c` - Headers, backgrounds
- **Accent Copper**: `#b45309` - Buttons, highlights, branding
- **Splash Gradient**: Navy to Copper transition
- **Status Colors**: Success, Warning, Error, Info
- **Neutral Grays**: Complete grayscale palette

### **Typography System**

- **Google Fonts Inter**: Modern, professional typeface
- **Complete Text Styles**: Display, Headline, Title, Body, Label variants
- **Button Text Styles**: Optimized for different button sizes
- **Responsive Sizing**: Scales appropriately for tablets

### **Spacing & Layout**

- **Consistent Spacing**: XS (4px) to XXXL (64px)
- **Border Radius**: Multiple radius options from XS to Round
- **Shadows**: Small, Medium, Large shadow variants
- **Icon Sizes**: Standardized icon sizing system

## 🚀 Component Library

### **Buttons**

- `JJPrimaryButton` - Gradient background, primary actions
- `JJSecondaryButton` - Outlined style, secondary actions  
- `JJIconButton` - Icon-only buttons with tooltips

### **Cards & Containers**

- `JJCard` - Basic card container with shadows
- `JJJobCard` - Specialized job listing card with all job info

### **Input Fields**

- `JJTextField` - Standard form input with validation
- `JJSearchField` - Search input with clear functionality

### **Navigation**

- `JJAppBar` - Branded app bar with consistent styling
- `JJBottomNavigationBar` - Bottom navigation with proper theming

### **Feedback & States**

- `JJLoadingIndicator` - Branded loading spinner
- `JJEmptyState` - Empty state with icon and call-to-action
- `JJBottomSheet` - Modal bottom sheet with title bar

### **Tags & Filters**

- `JJChip` - Selectable filter chips with active states

## 💫 Splash Screen Features

### **Two Splash Screen Options**

1. **`SplashScreen`** - Clean, minimal design
   - App icon with scale animation
   - Fade-in text
   - Loading indicator
   - 3-second duration

2. **`ElectricalSplashScreen`** - Themed with electrical elements
   - Circuit pattern background
   - Icon glow effects
   - Electrical-themed loading text
   - Advanced animations using flutter_animate

### **Animation Features**

- **Scale Animation**: Icon grows with elastic curve
- **Fade Animation**: Text fades in smoothly
- **Circuit Pattern**: Custom painter for electrical theme
- **Responsive Design**: Adapts to tablet screen sizes

## 🔧 Implementation Steps

### **Step 1: Add Dependencies**

Ensure these packages are in your `pubspec.yaml` (already present):

```yaml
flutter_animate: ^4.5.2
google_fonts: ^6.2.1
font_awesome_flutter: ^10.8.0
```

### **Step 2: Create Design System Files**

1. Create `lib/design_system/app_theme.dart`
2. Create `lib/design_system/components/reusable_components.dart`

### **Step 3: Create Splash Screen**

1. Create `lib/screens/splash/splash_screen.dart`
2. Choose between `SplashScreen` or `ElectricalSplashScreen`

### **Step 4: Update Main App**

1. Replace your `main.dart` with the provided version
2. Apply the `AppTheme.lightTheme` to your MaterialApp
3. Set the splash screen as your home screen

### **Step 5: Verify Asset Path**

Ensure your app icon is located at:

```
assets/images/app_launcher_icon.png
```

## 🎯 Usage Examples

### **Using the Design System**

```dart
// Apply theme to your MaterialApp
MaterialApp(
  theme: AppTheme.lightTheme,
  home: YourHomeScreen(),
)

// Use design system colors
Container(
  color: AppTheme.primaryNavy,
  child: Text(
    'Hello World',
    style: AppTheme.headlineMedium.copyWith(
      color: AppTheme.white,
    ),
  ),
)

// Use consistent spacing
Padding(
  padding: EdgeInsets.all(AppTheme.spacingMd),
  child: YourWidget(),
)
```

### **Using Components**

```dart
// Primary action button
JJPrimaryButton(
  text: 'Apply Now',
  icon: Icons.send,
  onPressed: () => handleApply(),
)

// Job listing card
JJJobCard(
  jobTitle: 'Journeyman Lineman',
  company: 'Texas Power & Light',
  location: 'Dallas, TX',
  wage: '\$45.50/hr',
  tags: ['Transmission', 'Overtime'],
  onTap: () => navigateToDetails(),
)

// Search with filters
JJSearchField(
  hintText: 'Search jobs...',
  onChanged: (value) => performSearch(value),
)
```

### **Navigation Integration**

```dart
// Replace splash screen after loading
Navigator.of(context).pushReplacement(
  PageRouteBuilder(
    pageBuilder: (context, animation, _) => HomeScreen(),
    transitionsBuilder: (context, animation, _, child) {
      return FadeTransition(opacity: animation, child: child);
    },
    transitionDuration: Duration(milliseconds: 500),
  ),
);
```

## 🎨 Customization Options

### **Color Customization**

- Modify `AppTheme.primaryNavy` and `AppTheme.accentCopper`
- Update gradients in `AppTheme.splashGradient`
- Adjust status colors for your brand

### **Splash Screen Customization**

- Change animation duration in `_startAnimations()`
- Modify the circuit pattern in `CircuitPatternPainter`
- Add your own electrical-themed elements
- Update the tagline text

### **Component Styling**

- Adjust border radius values
- Modify shadow intensities
- Change button heights and padding
- Customize card elevation and styling

## ✅ Benefits

### **Consistency**

- All components follow the same design language
- Consistent spacing, colors, and typography
- Unified user experience across screens

### **Maintainability**

- Centralized theming in `AppTheme`
- Reusable components reduce code duplication
- Easy to update designs globally

### **Professional Polish**

- Smooth animations and transitions
- IBEW-appropriate electrical theming
- Responsive design for different screen sizes
- Accessibility considerations built-in

### **Developer Efficiency**

- Pre-built components speed up development
- Clear component API with documentation
- Easy to extend and customize
- Follows Flutter best practices

## 🚀 Next Steps

1. **Implement the file structure** in your project
2. **Test the splash screen** with your app icon
3. **Build your first screen** using the component library
4. **Customize colors** to match your exact brand requirements
5. **Add additional components** as needed for your specific features

The design system is built to grow with your project - add new components following the same patterns and maintain consistency throughout your app development.
