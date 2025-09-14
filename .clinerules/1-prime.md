# Prime Design System Documentation

## Purpose

This document serves as the comprehensive design system primer for the Journeyman Jobs Flutter application. When assigned any task involving UI creation, modification, or enhancement, you **MUST** reference this document to ensure perfect consistency with the existing app design.

**CRITICAL**: Every screen, component, animation, color, spacing, and interaction must follow these guidelines exactly. There are **NO EXCEPTIONS**. Failure to adhere to this system will result in UI inconsistencies that require extensive rework.

## Core Design Principles

### 1. Electrical Theme Foundation

- **Primary Identity**: The app embodies electrical/utility worker aesthetics with copper wiring, navy uniforms, and electrical components
- **Color Philosophy**: Copper (#B45309) and Navy (#1A202C) as primary colors, representing electrical conductivity and professional uniforms
- **Visual Metaphor**: All UI elements should evoke electrical systems - circuits, connections, power flows, and mechanical precision

### 2. Material Design 3 Integration

- **Base Framework**: Built on Material 3 principles with custom electrical-themed overrides
- **Consistency**: All components use `AppTheme` constants exclusively - **NEVER** hardcode values
- **Accessibility**: Proper contrast ratios, touch targets, and semantic color usage

### 3. Animation Philosophy

- **Electrical Feel**: Animations should feel mechanical, electrical, or physical
- **Performance**: Smooth 60fps animations with electrical-themed effects (lightning, sparks, circuit connections)
- **Purpose-Driven**: Animations enhance UX, not decorate - page transitions, loading states, interactions

### 4. Component Architecture

- **Reusable Library**: All UI elements are standardized components from `lib/design_system/components/`
- **Electrical Components**: Specialized widgets in `lib/electrical_components/` for unique app features
- **Consistency Enforcement**: Every button, card, input field follows identical styling rules

## Color Palette

### Primary Colors

```dart
// From lib/design_system/app_theme.dart
static const Color primaryNavy = Color(0xFF1A202C);    // Deep navy - primary brand
static const Color accentCopper = Color(0xFFB45309);   // Copper orange - electrical accent
```

### Secondary Colors

```dart
static const Color secondaryNavy = Color(0xFF2D3748);    // Lighter navy for surfaces
static const Color secondaryCopper = Color(0xFFD69E2E);  // Light copper for highlights
```

### Neutral Colors

```dart
static const Color white = Color(0xFFFFFFFF);
static const Color black = Color(0xFF000000);
static const Color darkGray = Color(0xFF4A5568);
static const Color mediumGray = Color(0xFF718096);
static const Color lightGray = Color(0xFFE2E8F0);
static const Color offWhite = Color(0xFFF7FAFC);
```

### Status Colors

```dart
static const Color successGreen = Color(0xFF38A169);
static const Color warningYellow = Color(0xFFD69E2E);
static const Color warningOrange = Color(0xFFED8936);
static const Color errorRed = Color(0xFFE53E3E);
static const Color infoBlue = Color(0xFF3182CE);
```

### Electrical Colors

```dart
// From lib/electrical_components/jj_electrical_theme.dart
static const electricBlue = Color(0xFF00D4FF);    // Electric blue for highlights
static const copperOrange = Color(0xFFB45309);    // Copper for electrical elements
static const darkNavy = Color(0xFF1A202C);        // Navy for backgrounds
static const warningYellow = Color(0xFFFFD700);   // Warning indicators
static const dangerRed = Color(0xFFDC2626);       // Danger states
static const successGreen = Color(0xFF10B981);    // Success states
```

### Gradients

```dart
// Button gradient - copper to light copper
static const LinearGradient buttonGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFB45309), Color(0xFFD69E2E)],
);

// Electrical gradient - same as button
static const LinearGradient electricalGradient = LinearGradient(
  begin: Alignment.centerLeft,
  end: Alignment.centerRight,
  colors: [Color(0xFFB45309), Color(0xFFD69E2E)],
);

// Splash screen gradient
static const LinearGradient splashGradient = LinearGradient(
  begin: Alignment.topLeft,
  end: Alignment.bottomRight,
  colors: [Color(0xFFB45309), Color(0xFF1A202C)],
);
```

## Typography

### Font Family

- **Primary Font**: Google Fonts Inter
- **Usage**: All text uses Inter for consistency and readability

### Text Styles Hierarchy

#### Display Styles (Large Headlines)

```dart
static TextStyle displayLarge = GoogleFonts.inter(
  fontSize: 32,
  fontWeight: FontWeight.w700,
  height: 1.2,
  letterSpacing: -0.5,
);

static TextStyle displayMedium = GoogleFonts.inter(
  fontSize: 28,
  fontWeight: FontWeight.w600,
  height: 1.25,
  letterSpacing: -0.25,
);

static TextStyle displaySmall = GoogleFonts.inter(
  fontSize: 24,
  fontWeight: FontWeight.w600,
  height: 1.3,
);
```

#### Headline Styles (Section Headers)

```dart
static TextStyle headlineLarge = GoogleFonts.inter(
  fontSize: 22,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

static TextStyle headlineMedium = GoogleFonts.inter(
  fontSize: 20,
  fontWeight: FontWeight.w600,
  height: 1.3,
);

static TextStyle headlineSmall = GoogleFonts.inter(
  fontSize: 18,
  fontWeight: FontWeight.w600,
  height: 1.4,
);
```

#### Title Styles (Component Headers)

```dart
static TextStyle titleLarge = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.5,
);

static TextStyle titleMedium = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.4,
);

static TextStyle titleSmall = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  height: 1.4,
);
```

#### Body Styles (Content Text)

```dart
static TextStyle bodyLarge = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w400,
  height: 1.5,
);

static TextStyle bodyMedium = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w400,
  height: 1.4,
);

static TextStyle bodySmall = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w400,
  height: 1.4,
);
```

#### Label Styles (Form Labels, Buttons)

```dart
static TextStyle labelLarge = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w500,
  height: 1.4,
);

static TextStyle labelMedium = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w500,
  height: 1.4,
);

static TextStyle labelSmall = GoogleFonts.inter(
  fontSize: 10,
  fontWeight: FontWeight.w500,
  height: 1.4,
  letterSpacing: 0.5,
);
```

#### Button Text Styles

```dart
static TextStyle buttonLarge = GoogleFonts.inter(
  fontSize: 16,
  fontWeight: FontWeight.w600,
  height: 1.25,
);

static TextStyle buttonMedium = GoogleFonts.inter(
  fontSize: 14,
  fontWeight: FontWeight.w600,
  height: 1.25,
);

static TextStyle buttonSmall = GoogleFonts.inter(
  fontSize: 12,
  fontWeight: FontWeight.w600,
  height: 1.25,
);
```

## Spacing System

### Spacing Scale

```dart
// From lib/design_system/app_theme.dart
static const double spacingXxs = 2.0;    // Tiny gaps
static const double spacingXs = 4.0;     // Small gaps
static const double spacingSm = 8.0;     // Component internal padding
static const double spacingMd = 16.0;    // Standard padding
static const double spacingLg = 24.0;    // Large padding
static const double spacingXl = 32.0;    // Section spacing
static const double spacingXxl = 48.0;   // Major section breaks
static const double spacingXxxl = 64.0;  // Screen-level spacing
```

### Usage Guidelines

- **Component Padding**: Use `spacingMd` (16.0) for internal component padding
- **Element Spacing**: Use `spacingSm` (8.0) between related elements
- **Section Spacing**: Use `spacingLg` (24.0) between major sections
- **Screen Margins**: Use `spacingMd` (16.0) for screen edge margins
- **List Items**: Use `spacingSm` (8.0) between list items

## Border Radius System

```dart
static const double radiusXs = 4.0;    // Small elements
static const double radiusSm = 8.0;    // Buttons, inputs
static const double radiusMd = 12.0;   // Cards, dialogs
static const double radiusLg = 16.0;   // Large cards
static const double radiusXl = 20.0;   // Bottom sheets
static const double radiusXxl = 24.0;  // Modals
static const double radiusRound = 50.0; // Chips, pills
```

## Shadow System

```dart
static const BoxShadow shadowXs = BoxShadow(
  color: Color(0x0F000000),
  blurRadius: 2,
  offset: Offset(0, 1),
);

static const BoxShadow shadowSm = BoxShadow(
  color: Color(0x1A000000),
  blurRadius: 4,
  offset: Offset(0, 1),
);

static const BoxShadow shadowMd = BoxShadow(
  color: Color(0x1A000000),
  blurRadius: 8,
  offset: Offset(0, 4),
);

static const BoxShadow shadowLg = BoxShadow(
  color: Color(0x1A000000),
  blurRadius: 16,
  offset: Offset(0, 8),
);

static const List<BoxShadow> shadowCard = [
  BoxShadow(
    color: Color(0x0F000000),
    blurRadius: 10,
    offset: Offset(0, 4),
  ),
];
```

## Component Library

### Buttons

#### JJButton Component

**Location**: `lib/design_system/components/reusable_components.dart`

**Variants**:

- `JJButtonVariant.primary`: Copper gradient background, white text
- `JJButtonVariant.secondary`: White background, navy text, navy border
- `JJButtonVariant.outline`: Transparent background, copper text, copper border
- `JJButtonVariant.danger`: Red background, white text

**Sizes**:

- `JJButtonSize.small`: 40px height, small text
- `JJButtonSize.medium`: 48px height, medium text (default)
- `JJButtonSize.large`: 56px height, large text

**Usage Example**:

```dart
// Primary button (most common)
JJButton(
  text: 'Submit Job',
  icon: Icons.send,
  onPressed: () => submitJob(),
  variant: JJButtonVariant.primary,
  size: JJButtonSize.medium,
)

// Secondary button
JJButton(
  text: 'Cancel',
  onPressed: () => cancel(),
  variant: JJButtonVariant.secondary,
)

// Full width button
JJButton(
  text: 'Continue',
  onPressed: () => nextStep(),
  isFullWidth: true,
)
```

**Styling Rules**:

- Always use `AppTheme.radiusMd` (12.0) border radius
- Primary buttons use `AppTheme.buttonGradient`
- All buttons have consistent padding: `spacingLg` horizontal, `spacingMd` vertical
- Icons are `AppTheme.iconSm` (20.0) size
- Loading state shows circular progress indicator

### Cards

#### JJCard Component

**Location**: `lib/design_system/components/reusable_components.dart`

**Features**:

- White background with subtle shadow
- `AppTheme.radiusLg` (16.0) border radius
- `AppTheme.shadowSm` elevation
- Configurable padding and margins

**Usage Example**:

```dart
JJCard(
  padding: const EdgeInsets.all(AppTheme.spacingMd),
  margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
  child: Column(
    children: [
      Text('Job Details', style: AppTheme.titleLarge),
      SizedBox(height: AppTheme.spacingSm),
      Text('Description here...', style: AppTheme.bodyMedium),
    ],
  ),
)
```

### Text Fields

#### JJTextField Component

**Location**: `lib/design_system/components/reusable_components.dart`

**Features**:

- Label above input field
- Consistent styling with app theme
- Support for icons, validation, formatting
- Uses `AppTheme.inputDecorationTheme`

**Usage Example**:

```dart
JJTextField(
  label: 'Job Title',
  hintText: 'Enter job title...',
  controller: titleController,
  validator: (value) => value?.isEmpty ?? true ? 'Required' : null,
  prefixIcon: Icons.work,
)
```

### Popups and Dialogs

#### Popup Theme System

**Location**: `lib/design_system/popup_theme.dart`

**Available Themes**:

1. **Standard Popup** (`PopupThemeData.standard()`)
   - Copper border, white background
   - `radiusLg` corners, `shadowSm`
   - For general information display

2. **Alert Dialog** (`PopupThemeData.alertDialog()`)
   - Higher elevation (4), copper border
   - Larger padding (`spacingLg`)
   - For critical decisions and confirmations

3. **Bottom Sheet** (`PopupThemeData.bottomSheet()`)
   - Top-rounded corners (`radiusXl`)
   - Extra top padding for drag handle
   - For selections, forms, filters

4. **SnackBar** (`PopupThemeData.snackBar()`)
   - Navy background, white text
   - Minimal elevation, compact padding
   - For transient messages

5. **Modal** (`PopupThemeData.modal()`)
   - Highest elevation (8), max dimensions
   - For full-screen content

6. **Toast** (`PopupThemeData.toast()`)
   - Copper accent, rounded corners
   - Auto-dismiss behavior

**Usage Example**:

```dart
// Show alert dialog
context.showThemedDialog(
  builder: (context) => AlertDialog(
    title: Text('Confirm Action'),
    content: Text('Are you sure?'),
    actions: [
      JJButton(text: 'Cancel', variant: JJButtonVariant.secondary),
      JJButton(text: 'Confirm', variant: JJButtonVariant.primary),
    ],
  ),
  theme: PopupThemeData.alertDialog(),
);

// Show bottom sheet
showModalBottomSheet(
  context: context,
  backgroundColor: PopupThemeData.bottomSheet().backgroundColor,
  shape: RoundedRectangleBorder(
    borderRadius: PopupThemeData.bottomSheet().borderRadius,
  ),
  builder: (context) => Container(
    padding: PopupThemeData.bottomSheet().padding,
    child: Column(...),
  ),
);
```

## Animations and Transitions

### Page Transitions

**Location**: `lib/electrical_components/jj_electrical_page_transitions.dart`

#### Lightning Transition

- Dramatic entrance with electrical bolts
- 600ms duration, scale and fade effects
- Multiple lightning bolts across screen

#### Circuit Slide Transition

- Slides in like connecting circuits
- Elastic animation curve
- Circuit connection lines drawn during transition

#### Spark Reveal Transition

- Circular reveal with electrical sparks
- Sparks radiate from center
- 500ms duration

#### Power Surge Transition

- Content surges with electric glow
- Blue glow effect around content
- 450ms duration

**Usage Example**:

```dart
// Navigate with lightning transition
Navigator.push(
  context,
  JJElectricalPageTransitions.lightningTransition(
    child: NewScreen(),
    settings: RouteSettings(name: '/new-screen'),
  ),
);

// Navigate with circuit slide
Navigator.push(
  context,
  JJElectricalPageTransitions.circuitSlideTransition(
    child: NewScreen(),
    settings: RouteSettings(name: '/new-screen'),
    direction: SlideDirection.fromRight,
  ),
);
```

### Loading Animations

**Location**: `lib/electrical_components/`

#### Electrical Rotation Meter

- Rotating meter with electrical styling
- Shows progress or loading state

#### Power Line Loader

- Animated power lines
- Electrical-themed loading indicator

#### Three Phase Sine Wave Loader

- Animated sine waves representing three-phase power
- Technical electrical loading animation

**Usage Example**:

```dart
// Show electrical loader
const ElectricalLoader(
  size: 48.0,
  color: AppTheme.accentCopper,
)

// Show power line loader
const PowerLineLoader(
  height: 4.0,
  color: AppTheme.electricBlue,
)
```

## Electrical Theme Components

### Background Components

**Location**: `lib/electrical_components/circuit_board_background.dart`

#### Electrical Circuit Background

- Animated circuit board pattern
- Configurable opacity and density
- Optional interactive components

**Usage Example**:

```dart
// Wrap screen with electrical background
Scaffold(
  body: Stack(
    children: [
      ElectricalCircuitBackground(
        opacity: 0.12,
        componentDensity: ComponentDensity.high,
        animationSpeed: 1.5,
        enableCurrentFlow: true,
        enableInteractiveComponents: true,
      ),
      // Your screen content here
    ],
  ),
);
```

### Notifications

**Location**: `lib/electrical_components/jj_electrical_notifications.dart`

#### Electrical Toast

- Toast notifications with lightning effects
- Success, warning, error, info variants

#### Electrical SnackBar

- SnackBar with electrical styling

**Usage Example**:

```dart
// Show success toast
JJElectricalNotifications.showElectricalToast(
  context: context,
  message: 'Job submitted successfully!',
  type: ElectricalNotificationType.success,
  showLightning: true,
);

// Show error snackbar
JJElectricalNotifications.showElectricalSnackBar(
  context: context,
  message: 'Failed to save changes',
  type: ElectricalNotificationType.error,
);
```

## Code Patterns and Best Practices

### Always Use Theme Constants

```dart
// ✅ CORRECT
Container(
  padding: const EdgeInsets.all(AppTheme.spacingMd),
  margin: const EdgeInsets.symmetric(vertical: AppTheme.spacingSm),
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    boxShadow: [AppTheme.shadowSm],
  ),
)

// ❌ WRONG - Never hardcode values
Container(
  padding: const EdgeInsets.all(16.0),
  margin: const EdgeInsets.symmetric(vertical: 8.0),
  decoration: BoxDecoration(
    color: Colors.white,
    borderRadius: BorderRadius.circular(12.0),
    boxShadow: [BoxShadow(...)],
  ),
)
```

### Component Usage Priority

1. **JJButton** for all buttons
2. **JJCard** for all card-like containers
3. **JJTextField** for all text inputs
4. **PopupThemeData** variants for all popups
5. **Electrical components** for specialized electrical UI

### Screen Structure Template

```dart
class UserStatsScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('User Statistics', style: AppTheme.headlineMedium),
        backgroundColor: AppTheme.primaryNavy,
      ),
      body: Padding(
        padding: const EdgeInsets.all(AppTheme.spacingMd),
        child: Column(
          children: [
            JJCard(
              padding: const EdgeInsets.all(AppTheme.spacingMd),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Statistics Overview', style: AppTheme.titleLarge),
                  SizedBox(height: AppTheme.spacingMd),
                  // Stats content here
                ],
              ),
            ),
            SizedBox(height: AppTheme.spacingLg),
            Row(
              children: [
                Expanded(
                  child: JJButton(
                    text: 'Refresh',
                    icon: Icons.refresh,
                    onPressed: () => refreshStats(),
                    variant: JJButtonVariant.secondary,
                  ),
                ),
                SizedBox(width: AppTheme.spacingMd),
                Expanded(
                  child: JJButton(
                    text: 'Export',
                    icon: Icons.download,
                    onPressed: () => exportStats(),
                    variant: JJButtonVariant.primary,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
```

### Animation Guidelines

- Use electrical transitions for navigation
- Show loading states with electrical loaders
- Animate state changes smoothly (200-300ms)
- Use `Curves.elasticOut` for playful transitions
- Use `Curves.easeOut` for standard transitions

### Color Usage Rules

- **Primary Navy**: App bars, primary buttons, text on light backgrounds
- **Accent Copper**: Primary actions, highlights, electrical elements
- **White**: Card backgrounds, button text on colored backgrounds
- **Light Gray**: Secondary text, borders, disabled states
- **Success Green/Warning Orange/Error Red**: Status indicators only

### Typography Hierarchy

- **Display**: Screen titles, major headings
- **Headline**: Section headers, important information
- **Title**: Card headers, form labels
- **Body**: Content text, descriptions
- **Label**: Button text, small labels
- **Button**: Button text (always medium weight)

## Implementation Checklist

When creating any new screen or component:

- [ ] Used only `AppTheme` constants for colors, spacing, typography
- [ ] Applied electrical background where appropriate
- [ ] Used standardized components (JJButton, JJCard, etc.)
- [ ] Implemented proper popup themes for dialogs
- [ ] Added electrical-themed animations and transitions
- [ ] Ensured proper contrast and accessibility
- [ ] Tested on different screen sizes
- [ ] Followed spacing and layout guidelines
- [ ] Used appropriate electrical components for domain-specific UI

**REMEMBER**: This document ensures UI consistency. Any deviation requires explicit approval and will likely require rework. Always reference this document first when implementing any UI changes.
