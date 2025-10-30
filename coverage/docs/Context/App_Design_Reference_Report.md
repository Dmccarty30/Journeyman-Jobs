# App Design Reference Report

## Introduction

This report serves as the definitive reference guide for the Journeyman Jobs app's design system. The app, tailored for IBEW electrical professionals, adopts an electrical-themed aesthetic inspired by the trade's tools, circuits, and union heritage. The design emphasizes functionality, safety, and authenticity, using copper accents (symbolizing wiring), navy bases (evoking industrial reliability), and subtle circuit patterns for visual depth.

The system ensures uniformity across the app, promoting maintainability and user trust. All elements draw from the core [`AppTheme` class](lib/design_system/app_theme.dart:8), which defines colors, typography, spacing, and electrical-specific configurations. Popups use a dedicated [`PopupTheme` system](lib/design_system/popup_theme.dart:4) for consistent overlays.

Key principles:

- **Consistency**: Use theme constants; avoid hardcoding.
- **Accessibility**: WCAG 2.1 AA compliance with high contrast, semantics, and keyboard navigation.
- **Performance**: Optimized with RepaintBoundary for custom paints and lazy loading for lists.
- **Branding**: IBEW-inspired (e.g., hard hat icons, voltage indicators) while maintaining professional neutrality.

This guide covers all app-wide elements, with code snippets for implementation. For migration to enhanced electrical features, see [ELECTRICAL_THEME_MIGRATION.md](lib/design_system/ELECTRICAL_THEME_MIGRATION.md:1).

## Primary App Theme

The primary theme is a light mode with electrical accents, built on Material Design 3. It uses navy for structure, copper for highlights, and neutrals for readability. Dark mode support is planned but not implemented.

### Theme Configuration

The app's root theme is defined in [`main.dart`](lib/main.dart) via `MaterialApp.theme`:

```dart
// lib/main.dart (approximate implementation)
final lightTheme = AppTheme.lightTheme;
MaterialApp(
  theme: lightTheme,
  // ...
);
```

Core [`lightTheme`](lib/design_system/app_theme.dart:498) from `AppTheme`:

```dart
// lib/design_system/app_theme.dart:498-805 (excerpt)
static ThemeData get lightTheme {
  return ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: accentCopper, // Copper as primary seed
      primary: primaryNavy,
      secondary: secondaryCopper,
      surface: surface,
      background: offWhite,
      error: errorRed,
      brightness: Brightness.light,
    ),
    // Typography via Google Fonts Inter
    textTheme: TextTheme(
      displayLarge: displayLarge,
      headlineLarge: headlineLarge,
      bodyLarge: bodyLarge,
      // ... (all styles defined)
    ),
    // AppBar, cards, buttons use theme colors
    appBarTheme: AppBarTheme(
      backgroundColor: primaryNavy,
      foregroundColor: white,
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
    cardTheme: CardTheme(
      color: white,
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(radiusMd),
      ),
      shadowColor: Colors.black.withValues(alpha: 0.1),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: accentCopper,
        foregroundColor: white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusSm),
        ),
        elevation: 2,
      ),
    ),
    // Electrical-specific overrides
    extensions: <ThemeExtension<dynamic>>[
      ElectricalThemeExtension(electricalTheme),
    ],
  );
}
```

- **Seed Color**: Copper (`accentCopper`) for Material 3 harmony.
- **Brightness**: Light (dark mode via system preference).
- **Extensions**: Custom `ElectricalThemeExtension` for JJElectricalComponents configs (e.g., glow effects, circuit densities).

### Theme Extension for Electrical Components

Electrical elements use a custom extension:

```dart
// lib/design_system/app_theme.dart:433 (excerpt)
static const Map<String, dynamic> electricalTheme = {
  'backgroundColor': electricalBackground, // Navy circuit base
  'circuitTraceColor': electricalCircuitTrace, // Copper traces
  // ... (full config for glows, animations, etc.)
};
```

Apply via `Theme.of(context).extension<ElectricalThemeExtension>()!`.

## Popup Themes

Popups (dialogs, bottom sheets, toasts) use [`PopupTheme`](lib/design_system/popup_theme.dart:4), an InheritedWidget for context-aware theming. It ensures overlays match the app's electrical style without prop drilling.

### PopupTheme Widget Usage

Wrap the app or subtree:

```dart
// lib/main.dart (recommended at root)
MaterialApp(
  builder: (context, child) => PopupTheme(
    data: PopupThemeData.standard(), // Default
    child: child,
  ),
  // ...
);
```

Access via `PopupTheme.of(context)` or extension `context.popupTheme`.

### PopupThemeData Factories

Predefined variants using AppTheme constants (no hardcoding):

- **Standard** (default fallback): White background, copper border, medium padding.

  ```dart
  // lib/design_system/popup_theme.dart:42
  factory PopupThemeData.standard() => const PopupThemeData(
    elevation: 2,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );
  ```

- **AlertDialog**: Higher elevation, larger padding for decisions.

  ```dart
  // lib/design_system/popup_theme.dart:53
  factory PopupThemeData.alertDialog() => PopupThemeData(
    elevation: 4,
    borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: const EdgeInsets.all(AppTheme.spacingLg),
    shadows: const <BoxShadow>[AppTheme.shadowMd],
    barrierColor: AppTheme.black.withValues(alpha: 0.5),
  );
  ```

- **BottomSheet**: Rounded top, extra top padding for drag handle.

  ```dart
  // lib/design_system/popup_theme.dart:63
  factory PopupThemeData.bottomSheet() => const PopupThemeData(
    elevation: 8,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusXl)),
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.fromLTRB(AppTheme.spacingLg, AppTheme.spacingXl, AppTheme.spacingLg, AppTheme.spacingLg),
    shadows: <BoxShadow>[AppTheme.shadowLg],
    borderWidth: 0,
  );
  ```

- **CustomPopup** (for tooltips/LocalCard): Matches card styling.

  ```dart
  // lib/design_system/popup_theme.dart:81
  factory PopupThemeData.customPopup() => const PopupThemeData(
    elevation: 2,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );
  ```

- **SnackBar**: Navy background for notifications.

  ```dart
  // lib/design_system/popup_theme.dart:91
  factory PopupThemeData.snackBar() => const PopupThemeData(
    elevation: 1,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.primaryNavy,
    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
    shadows: <BoxShadow>[AppTheme.shadowXs],
    borderWidth: 0,
  );
  ```

- **Modal**: Full-screen/large content, max dimensions.

  ```dart
  // lib/design_system/popup_theme.dart:106
  factory PopupThemeData.modal() => const PopupThemeData(
    elevation: 8,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusXl)),
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingXl),
    shadows: <BoxShadow>[AppTheme.shadowLg],
    maxWidth: 600,
    maxHeight: 800,
  );
  ```

- **Toast**: Brief notifications, transparent barrier.

  ```dart
  // lib/design_system/popup_theme.dart:121
  factory PopupThemeData.toast() => PopupThemeData(
    elevation: 2,
    borderRadius: const BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
    borderColor: AppTheme.accentCopper,
    backgroundColor: AppTheme.white,
    padding: const EdgeInsets.symmetric(horizontal: AppTheme.spacingMd, vertical: AppTheme.spacingSm),
    shadows: const <BoxShadow>[AppTheme.shadowSm],
    barrierColor: Colors.transparent,
  );
  ```

- **Dropdown**: Compact for menus.

  ```dart
  // lib/design_system/popup_theme.dart:134
  factory PopupThemeData.dropdown() => const PopupThemeData(
    elevation: 1,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusMd)),
    borderColor: AppTheme.neutralGray300,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.symmetric(horizontal: AppTheme.spacingSm, vertical: AppTheme.spacingXs),
    shadows: <BoxShadow>[AppTheme.shadowXs],
  );
  ```

- **Tooltip**: Dark, small for context.

  ```dart
  // lib/design_system/popup_theme.dart:148
  factory PopupThemeData.tooltip() => const PopupThemeData(
    elevation: 1,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusSm)),
    borderColor: Colors.transparent,
    backgroundColor: AppTheme.secondaryNavy,
    padding: EdgeInsets.all(AppTheme.spacingXs),
    shadows: <BoxShadow>[AppTheme.shadowXs],
    borderWidth: 0,
  );
  ```

- **State Variants** (Primary, Success, Warning, Error): Accent borders for feedback.

  ```dart
  // lib/design_system/popup_theme.dart:160 (excerpt for success)
  factory PopupThemeData.success() => const PopupThemeData(
    elevation: 2,
    borderRadius: BorderRadius.all(Radius.circular(AppTheme.radiusLg)),
    borderColor: AppTheme.successGreen,
    backgroundColor: AppTheme.white,
    padding: EdgeInsets.all(AppTheme.spacingMd),
    shadows: <BoxShadow>[AppTheme.shadowSm],
  );
  ```

### Usage Example

For a themed dialog:

```dart
// In a screen or widget
showThemedDialog(
  theme: PopupThemeData.alertDialog(),
  builder: (context) => AlertDialog(
    title: Text('Confirm Action', style: AppTheme.headlineSmall),
    content: Text('Are you sure?', style: AppTheme.bodyMedium),
    actions: [
      TextButton(onPressed: () => Navigator.pop(context), child: Text('Cancel')),
      ElevatedButton(onPressed: () => Navigator.pop(context, true), child: Text('Confirm')),
    ],
  ),
);
```

Consistency: All popups inherit from `PopupTheme.of(context)`, ensuring electrical accents (e.g., copper borders) and shadows match the app theme.

## Color Palettes

The palette is electrical-inspired: navy for stability, copper for energy, neutrals for readability. Defined in [`AppTheme`](lib/design_system/app_theme.dart:9).

### Primary Palette

- **Navy (Primary)**: `primaryNavy` (0xFF1A202C) - Headers, backgrounds.
- **Copper (Accent)**: `accentCopper` (0xFFB45309) - Buttons, highlights, borders.
- **Secondary Navy**: `secondaryNavy` (0xFF2D3748) - Cards, secondary elements.
- **Secondary Copper**: `secondaryCopper` (0xFFD69E2E) - Light accents, gradients.

### Neutral Palette

- **White**: `white` (0xFFFFFFFF) - Surfaces.
- **Off-White**: `offWhite` (0xFFF7FAFC) - Elevated surfaces.
- **Light Gray**: `lightGray` (0xFFE2E8F0) - Dividers, subtle backgrounds.
- **Medium Gray**: `mediumGray` (0xFF718096) - Secondary text.
- **Dark Gray**: `darkGray` (0xFF4A5568) - Borders, icons.
- **Black**: `black` (0xFF000000) - Primary text.

### Status Palette

- **Success**: `successGreen` (0xFF38A169) - Confirmations, loaded states.
- **Warning**: `warningYellow` (0xFFD69E2E) - Cautions, pending.
- **Error**: `errorRed` (0xFFE53E3E) - Failures, alerts.
- **Info**: `infoBlue` (0xFF3182CE) - Informational, links.
- **Ground**: `groundBrown` (0xFF8B4513) - Electrical grounding elements.

### Electrical-Specific Palette

- **Background**: `electricalBackground` (0xFF1A202C) - Circuit navy base.
- **Surface**: `electricalSurface` (0xFF2D3748) - Component navy.
- **Circuit Trace**: `electricalCircuitTrace` (0xFFB45309) - Copper lines.
- **Circuit Trace Light**: `electricalCircuitTraceLight` (0xFFD69E2E) - Subtle traces.
- **Success**: `electricalSuccess` (0xFF10B981) - Power indicators.
- **Warning**: `electricalWarning` (0xFFFFD700) - Caution lights.
- **Error**: `electricalError` (0xFFDC2626) - Danger signals.
- **Info**: `electricalInfo` (0xFF00D4FF) - Flow indicators.

### Gradients

Used for depth and energy flow:

- **SplashGradient**: Navy to copper diagonal [`splashGradient`](lib/design_system/app_theme.dart:65).
- **ButtonGradient**: Horizontal copper [`buttonGradient`](lib/design_system/app_theme.dart:74).
- **CardGradient**: Subtle white to off-white [`cardGradient`](lib/design_system/app_theme.dart:83).
- **ElectricalGradient**: Copper flow [`electricalGradient`](lib/design_system/app_theme.dart:92).

Example usage:

```dart
// lib/widgets/enhanced_job_card.dart (example)
Container(
  decoration: BoxDecoration(
    gradient: AppTheme.electricalGradient,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
  ),
  child: Text('Job Title', style: AppTheme.titleLarge.copyWith(color: AppTheme.white)),
);
```

Consistency Rule: Always use theme gradients for buttons/cards; avoid custom colors to maintain copper/navy harmony.

## Typography

Typography uses Google Fonts Inter for modern, readable text. Scales follow Material 3 guidelines, with consistent line heights (1.2-1.5) for legibility on mobile.

### Type Scale

Defined in [`AppTheme`](lib/design_system/app_theme.dart:312):

- **Display Large**: 32pt, w700, height 1.2 - Hero titles (e.g., app name on splash).

  ```dart
  // lib/design_system/app_theme.dart:313
  static TextStyle displayLarge = GoogleFonts.inter(
    fontSize: 32, fontWeight: FontWeight.w700, height: 1.2, letterSpacing: -0.5,
  );
  ```

- **Headline Large**: 22pt, w600, height 1.3 - Screen titles (e.g., "Jobs Near You").
- **Title Large**: 16pt, w600, height 1.5 - Card headers (e.g., job company name).
- **Body Large**: 16pt, w400, height 1.5 - Main content (e.g., job descriptions).
- **Label Large**: 14pt, w500, height 1.4 - Form labels, buttons.
- **Button**: 16pt w600 - Action text, uppercase for emphasis.

Full scale in code; all inherit from Inter for sans-serif consistency.

### Usage Guidelines

- **Hierarchy**: Display for branding, Headline for sections, Body for text, Label for UI elements.
- **Color**: Primary text on light backgrounds (`textPrimary`), white on dark (`textOnDark`).
- **Responsive**: Scale with `MediaQuery.textScaleFactorOf(context)` for accessibility.
- **Electrical Variant**: For toasts/snackbars, use `copyWith(color: electricalSuccess)` for status.

Example:

```dart
// lib/screens/home/home_screen.dart (example)
Text(
  'Welcome, Journeyman!',
  style: AppTheme.headlineLarge.copyWith(color: AppTheme.primaryNavy),
),
```

Consistency: No custom fonts; use theme styles to ensure 1.3-1.5 line heights prevent cramped text.

## Iconography

Icons are Material Design with electrical customizations from `lib/electrical_components` (e.g., hard_hat_icon.dart, transmission_tower_icon.dart).

### Standard Icons

- Use `Icons` class for general (e.g., `Icons.work` for jobs, `Icons.warning` for alerts).
- Size: `iconMd` (24dp) default; scale with theme (`iconXs` to `iconXxl`).
- Color: `accentCopper` for interactive, `mediumGray` for inactive.

### Custom Electrical Icons

- **Hard Hat**: Safety branding [`hard_hat_icon.dart`](lib/electrical_components/hard_hat_icon.dart).
- **Transmission Tower**: Storm work [`transmission_tower_icon.dart`](lib/electrical_components/transmission_tower_icon.dart).
- **Circuit Breaker**: Toggle switches [`jj_circuit_breaker_switch.dart`](lib/electrical_components/jj_circuit_breaker_switch.dart).
- **Power Line Loader**: Animations [`power_line_loader.dart`](lib/electrical_components/power_line_loader.dart).

Example:

```dart
// lib/widgets/job_card.dart (example)
Icon(
  Icons.electrical_services, // Material icon
  color: AppTheme.accentCopper,
  size: AppTheme.iconMd,
)
CustomIcon( // Custom
  HardHatIcon(),
  color: AppTheme.successGreen,
  size: AppTheme.iconLg,
);
```

Consistency: Custom icons for domain (e.g., voltage symbols); Material for UI. Ensure 24dp baseline, copper tint for accents.

## Layouts

Layouts are mobile-first, using Scaffold for structure, Stack for overlays (e.g., circuit backgrounds), and responsive widgets.

### Core Layout Patterns

- **Scaffold**: AppBar (enhanced with electrical gradient), body (circuit background), bottom nav for main screens.

  ```dart
  // lib/screens/home/home_screen.dart (example)
  Scaffold(
    appBar: EnhancedAppBar(title: 'Home'), // From migration guide
    body: CircuitPatternBackground( // Subtle electrical pattern
      child: Column(
        children: [
          Expanded(child: JobList()), // Virtual scrolling
          BottomNavigationBar(...),
        ],
      ),
    ),
  );
  ```

- **Responsive Grids**: GridView.builder for job lists, with SliverGrid for scrolling.
- **Cards**: Rounded (radiusMd), elevated shadows, copper borders for focus.
- **Forms**: Column with padding (spacingMd), labels above fields.

### Navigation Layout

- ShellRoute for persistent nav bar (5 tabs: Home, Jobs, Crews, Storm, Profile).
- Stacked routes for deep linking (e.g., /jobs/:id/details).

Consistency: 16dp min padding, max 600dp width for modals, Stack for layered electrical effects (e.g., glows over cards).

## Reusable Components

Reusable components are in `lib/widgets` and `lib/electrical_components`, using theme constants.

### General Components

- **JobCard**: Displays job info with variants (condensed, full) [`enhanced_job_card.dart`](lib/widgets/enhanced_job_card.dart).
  - Features: Copper accents, status badges, tap to details.
  - States: Loading skeleton, error retry.

- **OfflineIndicator**: Shows connectivity status [`offline_indicator.dart`](lib/widgets/offline_indicator.dart).
  - Layout: Top banner with warning color.

- **NotificationBadge**: For unread counts [`notification_badge.dart`](lib/widgets/notification_badge.dart).
  - Copper background, white number.

### Electrical Components

- **JJCircuitBreakerSwitch**: Interactive toggle [`jj_circuit_breaker_switch.dart`](lib/electrical_components/jj_circuit_breaker_switch.dart).
  - Animations: Flip with spark effect.
  - States: On (green glow), Off (red), Disabled (gray).

- **JJElectricalToast**: Themed notifications [`jj_electrical_toast.dart`](lib/electrical_components/jj_electrical_toast.dart).
  - Variants: Success (green circuit), Error (red flash).

- **PowerLineLoader**: Animated loader [`power_line_loader.dart`](lib/electrical_components/power_line_loader.dart).
  - Copper line pulsing.

Example Usage:

```dart
// lib/screens/jobs/jobs_screen.dart (example)
ListView.builder(
  itemBuilder: (context, index) => EnhancedJobCard(
    job: jobs[index],
    variant: JobCardVariant.full,
    onTap: () => Navigator.pushNamed(context, '/jobs/${jobs[index].id}'),
  ),
);
```

Consistency: All components use `Consumer` for state, theme extensions for styling, and Semantics for accessibility.

## Animations and Interactions

Animations enhance electrical feel without overwhelming; durations from theme.

### Animation System

- **Durations**: Toast (3s), Glow (2s), Spark (800ms), Slide (400ms), Lightning (300ms) [`durationElectricalToast`](lib/design_system/app_theme.dart:232) etc.
- **Curves**: ElasticOut for slides, EaseInOut for glows [`curveElectricalSlide`](lib/design_system/app_theme.dart:240).
- **Implementation**: AnimationController with Tween for sparks/glows in CustomPainter.

Examples:

- **Job Card Entry**: Staggered fade-in with copper glow (Hero for transitions).
- **Toggle Switch**: Rotation + spark on flip in JJCircuitBreakerSwitch.
- **Loading**: Power line pulsing in PowerLineLoader.

Interactions:

- **Gestures**: LongPressDraggable for reordering crews, GestureDetector for taps with haptic feedback.
- **Feedback**: Snackbars/toasts with electrical themes (e.g., success green glow).
- **Transitions**: PageRouteBuilder with electrical slide (curves from theme).

Consistency: Animate state changes (loading to success with glow fade); limit to 60fps with RepaintBoundary.

## Responsive Design Principles

Mobile-first (iOS/Android), with adaptive layouts.

- **Breakpoints**: Use MediaQuery for small (<600px width: compact), large (tablet: expanded lists).
- **Flexible Layouts**: Expanded/Flex for dynamic sizing; LayoutBuilder for custom.
- **Orientation**: Portrait default; landscape expands grids (e.g., 2-column jobs).
- **Scaling**: Text scales with system settings; icons clamp to iconMd max.

Example:

```dart
// Responsive job list
LayoutBuilder(
  builder: (context, constraints) {
    final crossAxisCount = constraints.maxWidth > 600 ? 2 : 1;
    return GridView.builder(
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: crossAxisCount),
      itemBuilder: (context, index) => JobCard(job: jobs[index]),
    );
  },
);
```

Consistency: Test on 4" to 12" screens; use SafeArea for notches.

## Accessibility Guidelines

Follow WCAG 2.1 AA; integrated via theme and components.

- **Contrast**: Minimum 4.5:1 (e.g., white on navy checked).
- **Semantics**: Semantics widget for custom icons (e.g., "Hard hat safety icon").
- **Navigation**: Keyboard focus with visible outlines (copper border on focus).
- **Screen Readers**: Alt text for illustrations, live regions for notifications.
- **High Contrast**: Migration guide supports mode detection; increase trace opacity.
- **Haptics**: Subtle feedback for switches (HapticFeedback.lightImpact).

Example:

```dart
Semantics(
  label: 'Job at IBEW Local 123, $wage/hour',
  hint: 'Double tap to apply',
  child: GestureDetector(
    onTap: onApply,
    child: JobCard(...),
  ),
);
```

Consistency: Audit with TalkBack/VoiceOver; 100% semantic coverage for interactive elements.

## Branding Elements

- **Logo**: IBEW-inspired hard hat with copper glow (assets/logo.png).
- **Icons**: Custom electrical set (hard hat, tower) alongside Material.
- **Palette**: Copper/navy for union professionalism.
- **Typography**: Inter for modern readability.
- **Patterns**: Subtle circuits (opacity 0.03-0.1) for backgrounds, not overwhelming text.

Usage: Logo in AppBar; patterns in non-text areas.

## Consistency Rules Across States

Ensure uniform feedback across loading, error, success, normal states.

### Normal State

- Default: Circuit background (low opacity), copper accents.
- Example: Job list with standard cards.

### Loading State

- Indicators: PowerLineLoader or ThreePhaseSineWaveLoader with copper animation.
- Skeleton: JobCardSkeleton with gray placeholders.
- Rule: No text; pulse opacity 0.5-1.0.

```dart
// lib/widgets/job_card_skeleton.dart (example)
Shimmer.fromColors(
  baseColor: AppTheme.mediumGray,
  highlightColor: AppTheme.lightGray,
  child: Container(
    height: 120,
    decoration: BoxDecoration(
      color: AppTheme.surface,
      borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    ),
  ),
);
```

### Error State

- UI: JJElectricalToast with error theme (red glow, lightning effect).
- Retry: Copper button with "Retry" label.
- Rule: Sanitized messages (no raw errors); barrier dismissible false for critical.

```dart
// Error handling example
if (error != null) {
  JJElectricalToast.showError(
    context,
    message: 'Failed to load jobs. Check connection.',
    theme: AppTheme.electricalErrorTheme,
  );
}
```

### Success State

- UI: Green glow toast/snackbar with check icon.
- Animation: Fade-in spark effect.
- Rule: Auto-dismiss after 3s; haptic success feedback.

Consistency: States use theme variants (e.g., electricalSuccess for green); maintain layout structure.

## Additional Conventions and Standards

- **No Hardcoding**: All values from AppTheme (e.g., `AppTheme.spacingMd` not 16.0).
- **Material 3 Compliance**: useMaterial3: true; dynamic color support planned.
- **Performance**: CustomPaint in RepaintBoundary; virtual lists for >50 items.
- **File Organization**: Components in electrical_components/widgets; themes in design_system.
- **Versioning**: ThemeData.copyWith for overrides; changelog in MIGRATION.md.
- **Testing**: Components tested for states (e.g., toggle on/off); coverage >80%.
- **Dark Mode Prep**: ThemeData.darkTheme stub; system mode detection.

For updates, reference this report and validate against theme constants. Contact design lead for custom deviations.
