---
After completing every task you must performe each step of this workflow to ensure app theme consistency.
---

# App Theme Assurance

## Purpose

This document serves as the comprehensive design system primer for the Journeyman Jobs Flutter application. When assigned any task involving UI creation, modification, or enhancement, you **MUST** reference this document to ensure perfect consistency with the existing app design.

**CRITICAL**: Every screen, component, animation, color, spacing, and interaction must follow these guidelines exactly. There are **NO EXCEPTIONS**. Failure to adhere to this system will result in UI inconsistencies that require extensive rework.

## 1. Electrical Theme Foundation

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
