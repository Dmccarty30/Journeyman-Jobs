# Storm Screen Design System Reference

**Reference**: STORM-010 - Design system documentation update
**Date**: January 23, 2025
**Version**: 1.0.0
**Status**: ✅ Complete

---

## Overview

The Storm Screen serves as a **reference implementation** for the Journeyman Jobs electrical design system, demonstrating best practices for:

- Circuit background integration with `ComponentDensity.medium`
- Standardized card component patterns
- Consistent border widths, shadows, and border radius
- Accessibility compliance (WCAG 2.1 AA)
- Performance optimization for complex animated UIs

---

## Design System Compliance

### Component Inventory

#### 1. Circuit Background

**Component**: `ElectricalCircuitBackground`
**Location**: `lib/electrical_components/circuit_board_background.dart`
**Usage in Storm Screen**: `lib/screens/storm/storm_screen.dart:259`

```dart
ElectricalCircuitBackground(
  componentDensity: ComponentDensity.medium,  // Standard density
  opacity: 0.08,                               // Subtle effect
  enableCurrentFlow: true,                     // Animation enabled
  child: SingleChildScrollView(...),
)
```

**Design System Standards**:

- ✅ `ComponentDensity.medium` - App-wide standard (Jobs, Locals, Contacts, Storm)
- ✅ `opacity: 0.08` - Ensures background doesn't overpower content
- ✅ `enableCurrentFlow: true` - Maintains electrical theme consistency

**Performance Baseline** (STORM-009):

- Frame rate: 953-1347 FPS ✅
- Initial build: 676-784ms ✅
- UI responsiveness: 119-140ms ✅

---

#### 2. Main Container Pattern

**Component**: Standard card container
**Location**: `lib/screens/storm/storm_screen.dart:265-276`

```dart
Container(
  margin: EdgeInsets.all(AppTheme.spacingMd),
  padding: EdgeInsets.all(AppTheme.spacingLg),
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusLg),
    border: Border.all(
      color: AppTheme.accentCopper,
      width: AppTheme.borderWidthMedium,  // 1.5px standard
    ),
    boxShadow: AppTheme.shadowCard,       // Standard card shadow
  ),
  child: Column(...),
)
```

**Design System Standards**:

- ✅ `borderWidthMedium: 1.5px` - Eliminates magic numbers (`borderWidthCopper * 0.5`)
- ✅ `shadowCard` - Replaces custom `shadowElectricalInfo`
- ✅ `accentCopper` - Maintains electrical theme color palette
- ✅ `radiusLg: 16px` - Consistent with other main containers

**Visual Parity**: Matches job cards, local cards, and contractor cards

---

#### 3. Filter Dropdown Pattern

**Component**: Styled dropdown container
**Location**: `lib/screens/storm/storm_screen.dart:425-436`

```dart
Container(
  padding: EdgeInsets.symmetric(
    horizontal: AppTheme.spacingMd,
    vertical: AppTheme.spacingSm,
  ),
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: AppTheme.accentCopper,
      width: AppTheme.borderWidthMedium,  // 1.5px standard
    ),
    boxShadow: AppTheme.shadowCard,       // Standard card shadow
  ),
  child: DropdownButton<String>(...),
)
```

**Design System Standards**:

- ✅ Same `borderWidthMedium` and `shadowCard` as main container
- ✅ `radiusMd: 12px` - Appropriate for smaller UI elements
- ✅ Visual cohesion with parent container

---

#### 4. Contractor Card Pattern

**Component**: `ContractorCard`
**Location**: `lib/widgets/contractor_card.dart:24-29`

```dart
Container(
  margin: const EdgeInsets.only(bottom: 16),
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),  // 12px
    border: Border.all(
      color: AppTheme.accentCopper,
      width: AppTheme.borderWidthThin,  // 1px for nested cards
    ),
    boxShadow: AppTheme.shadowCard,     // Consistent depth
  ),
  child: Column(...),
)
```

**Design System Standards**:

- ✅ `radiusMd: 12px` - Replaces hardcoded `12`
- ✅ `shadowCard` - Replaces custom `BoxShadow(color: Colors.black.withValues(alpha: 0.08), ...)`
- ✅ `borderWidthThin: 1px` - Thinner border for nested elements

**Before/After Comparison**:

| Aspect | Before (Hardcoded) | After (Design System) |
|--------|-------------------|----------------------|
| Border Radius | `12` | `AppTheme.radiusMd` |
| Shadow | `BoxShadow(color: Colors.black.withValues(alpha: 0.08), ...)` | `AppTheme.shadowCard` |
| Maintainability | Low (magic numbers) | High (theme constants) |

---

## Accessibility Compliance (STORM-008)

### WCAG 2.1 AA Standards

**Color Contrast Ratios**:

- ✅ Copper border on white: **5.02:1** (target: ≥3:1)
- ✅ Primary navy text: **16.32:1** (target: ≥4.5:1)
- ✅ Secondary text: **7.53:1** (target: ≥4.5:1)
- ✅ Success green: **3.25:1** (target: ≥3:1)
- ✅ Error red badge: **4.13:1** (target: ≥3:1)

**Touch Target Sizes**:

- ✅ Notification IconButton: **48×48px** (target: ≥44×44px)
- ✅ Contractor card buttons: **48px height** (target: ≥44px)
- ✅ Weather radar button: **56px height** (JJPrimaryButton default)

**Semantic Labels**:

- ✅ AppBar title for screen readers
- ✅ Interactive elements have tap feedback
- ✅ Region filter dropdown accessible
- ✅ Keyboard navigation support
- ✅ Text scaling to 200% without overflow

**Implementation Details**:

```dart
// Notification IconButton with WCAG-compliant touch target
IconButton(
  iconSize: 24,
  constraints: const BoxConstraints(
    minWidth: 48,   // WCAG 2.1 AA minimum
    minHeight: 48,
  ),
  padding: const EdgeInsets.all(12),
  icon: Icon(Icons.notifications_outlined),
  onPressed: () {...},
)

// Contractor card buttons with minimum height
ElevatedButton.styleFrom(
  backgroundColor: AppTheme.primaryNavy,
  foregroundColor: AppTheme.white,
  minimumSize: const Size(0, 48),  // WCAG compliance
  padding: const EdgeInsets.symmetric(
    horizontal: 16,
    vertical: 12,
  ),
)
```

---

## Standard Card Pattern

### Component Structure

```dart
/// Standard card pattern for all card-style widgets
///
/// Ensures visual consistency across:
/// - Job cards (lib/widgets/job_card.dart)
/// - Local cards (lib/widgets/local_card.dart)
/// - Contractor cards (lib/widgets/contractor_card.dart)
/// - Power outage cards (lib/widgets/outage_card.dart)
Container(
  margin: EdgeInsets.all(AppTheme.spacingMd),      // Consistent spacing
  padding: EdgeInsets.all(AppTheme.spacingLg),     // Generous internal padding
  decoration: BoxDecoration(
    color: AppTheme.white,                         // Clean background
    borderRadius: BorderRadius.circular(
      AppTheme.radiusMd,                           // 12px for cards
    ),
    border: Border.all(
      color: AppTheme.accentCopper,                // Electrical theme
      width: AppTheme.borderWidthMedium,           // 1.5px standard
    ),
    boxShadow: AppTheme.shadowCard,                // Elevation effect
  ),
  child: Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      // Card content
    ],
  ),
)
```

### Nested Card Variant

For cards within cards (e.g., contractor cards in storm screen):

```dart
Container(
  margin: const EdgeInsets.only(bottom: 16),       // Stack spacing
  decoration: BoxDecoration(
    color: AppTheme.white,
    borderRadius: BorderRadius.circular(AppTheme.radiusMd),
    border: Border.all(
      color: AppTheme.accentCopper,
      width: AppTheme.borderWidthThin,             // 1px for nested cards
    ),
    boxShadow: AppTheme.shadowCard,
  ),
  child: // Content
)
```

**Design Rationale**: Thinner border (`borderWidthThin: 1px`) for nested cards prevents visual clutter

---

## Best Practices

### 1. Always Use Theme Constants

❌ **BAD**:

```dart
borderRadius: BorderRadius.circular(12),
border: Border.all(width: 1.5, color: Color(0xFFB45309)),
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
],
```

✅ **GOOD**:

```dart
borderRadius: BorderRadius.circular(AppTheme.radiusMd),
border: Border.all(
  width: AppTheme.borderWidthMedium,
  color: AppTheme.accentCopper,
),
boxShadow: AppTheme.shadowCard,
```

**Benefits**:

- Centralized theme management
- Easy global updates
- Eliminates magic numbers
- Type-safe constants

---

### 2. Circuit Background Consistency

✅ **Always use `ComponentDensity.medium`** across all screens:

- `lib/screens/home/home_screen.dart`
- `lib/screens/jobs/jobs_screen.dart`
- `lib/screens/locals/locals_screen.dart`
- `lib/screens/contacts/contacts_screen.dart`
- `lib/screens/storm/storm_screen.dart`

❌ **Don't use `ComponentDensity.high`** - causes visual inconsistency

---

### 3. Shadow Hierarchy

**Main Containers**: `AppTheme.shadowCard`

```dart
boxShadow: AppTheme.shadowCard,
```

**Elevated Elements** (modals, floating buttons): `AppTheme.shadowLg`

```dart
boxShadow: AppTheme.shadowLg,
```

**Subtle Elements** (dividers, inactive states): `AppTheme.shadowSm`

```dart
boxShadow: AppTheme.shadowSm,
```

---

### 4. Border Width Standards

| Element Type | Border Width | Constant | Use Case |
|-------------|--------------|----------|----------|
| Main containers | 1.5px | `borderWidthMedium` | Storm screen container, job cards |
| Nested cards | 1px | `borderWidthThin` | Contractor cards, outage cards |
| Accents | 2.5px | `borderWidthCopper` | Special electrical-themed elements |
| Dividers | 1px | `borderWidthThin` | Section separators |

---

### 5. Accessibility Guidelines

**Color Contrast**:

- Normal text: ≥4.5:1 contrast ratio
- Large text (18pt+ or 14pt+ bold): ≥3:1 contrast ratio
- UI components/graphics: ≥3:1 contrast ratio

**Touch Targets**:

- Minimum size: **48×48 logical pixels** (exceeds WCAG 2.1 AA 44×44 requirement)
- Use `IconButton` constraints or button `minimumSize` properties

**Text Scaling**:

- Support up to 200% text scaling without overflow
- Use `Expanded` widgets to prevent text overflow in rows
- Wrap text in `TextAlign.center` when appropriate

---

## Performance Considerations

### Optimization Techniques

**1. RepaintBoundary for Animations** (recommended for circuit background):

```dart
RepaintBoundary(
  child: ElectricalCircuitBackground(
    componentDensity: ComponentDensity.medium,
    opacity: 0.08,
    enableCurrentFlow: true,
    child: content,
  ),
)
```

**Benefits**: Isolates animation repaints, prevents UI blocking

---

**2. Lazy Loading for Long Lists**:

```dart
ListView.builder(
  itemCount: contractors.length,
  itemBuilder: (context, index) => ContractorCard(
    contractor: contractors[index],
  ),
)
```

**Benefits**: Only builds visible cards, reduces memory footprint

---

**3. Widget Tree Optimization**:

- Target: <700 widgets per screen
- Storm screen actual: 623 widgets ✅
- Use `const` constructors wherever possible
- Extract repeated widget patterns into reusable components

---

## Code Examples

### Complete Storm Screen Pattern

```dart
import 'package:flutter/material.dart';
import 'package:journeyman_jobs/design_system/app_theme.dart';
import 'package:journeyman_jobs/electrical_components/circuit_board_background.dart';

class StormScreen extends StatelessWidget {
  const StormScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Storm Work'),
        backgroundColor: AppTheme.primaryNavy,
        foregroundColor: AppTheme.white,
        actions: [
          IconButton(
            iconSize: 24,
            constraints: const BoxConstraints(
              minWidth: 48,
              minHeight: 48,
            ),
            padding: const EdgeInsets.all(12),
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {
              // Notification handler
            },
          ),
        ],
      ),
      body: ElectricalCircuitBackground(
        componentDensity: ComponentDensity.medium,
        opacity: 0.08,
        enableCurrentFlow: true,
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(AppTheme.spacingMd),
            padding: EdgeInsets.all(AppTheme.spacingLg),
            decoration: BoxDecoration(
              color: AppTheme.white,
              borderRadius: BorderRadius.circular(AppTheme.radiusLg),
              border: Border.all(
                color: AppTheme.accentCopper,
                width: AppTheme.borderWidthMedium,
              ),
              boxShadow: AppTheme.shadowCard,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Screen content
              ],
            ),
          ),
        ),
      ),
    );
  }
}
```

---

## Testing Requirements

### Visual Regression Testing (STORM-007)

- Test across phone/tablet, portrait/landscape orientations
- Validate circuit background rendering at `ComponentDensity.medium`
- Verify border widths, shadows, and border radius consistency
- Capture golden file screenshots for baseline comparison

**Test Location**: `test/presentation/screens/storm/storm_screen_visual_test.dart`

---

### Accessibility Testing (STORM-008)

- Color contrast validation using W3C luminance formula
- Touch target size verification (IconButton constraints, button minimumSize)
- Semantic labels and screen reader support
- Keyboard navigation and text scaling to 200%

**Test Location**: `test/accessibility/storm_screen_accessibility_test.dart`

---

### Performance Testing (STORM-009)

- Frame rate: ≥55-58 FPS during scrolling and animations
- Initial build: <1000ms
- UI responsiveness: <150ms for complex animations
- Memory leak detection across multiple rebuilds
- Widget tree size: <700 widgets

**Test Location**: `test/performance/storm_screen_performance_test.dart`

---

## Migration Guide

### Updating Existing Screens to Design System

**Step 1**: Replace hardcoded border widths

```dart
// Before
border: Border.all(width: 1.5, color: Color(0xFFB45309))

// After
border: Border.all(
  width: AppTheme.borderWidthMedium,
  color: AppTheme.accentCopper,
)
```

---

**Step 2**: Replace custom shadows

```dart
// Before
boxShadow: [
  BoxShadow(
    color: Colors.black.withValues(alpha: 0.08),
    blurRadius: 8,
    offset: Offset(0, 2),
  ),
]

// After
boxShadow: AppTheme.shadowCard,
```

---

**Step 3**: Replace hardcoded border radius

```dart
// Before
borderRadius: BorderRadius.circular(12)

// After
borderRadius: BorderRadius.circular(AppTheme.radiusMd)
```

---

**Step 4**: Update circuit background density

```dart
// Before
ElectricalCircuitBackground(
  componentDensity: ComponentDensity.high,  // ❌ Inconsistent
  ...
)

// After
ElectricalCircuitBackground(
  componentDensity: ComponentDensity.medium,  // ✅ Standard
  ...
)
```

---

**Step 5**: Verify accessibility compliance

- Run color contrast tests
- Check touch target sizes (≥48×48px)
- Validate text scaling support
- Test keyboard navigation

---

## Related Documentation

- **UI Consistency Report**: `docs/reports/storm_screen_ui_alignment_report.md`
- **Task List**: `docs/tasks/storm_screen_ui_alignment_tasks.md`
- **Test Reports**:
  - `test/presentation/screens/storm/storm_screen_visual_test.dart`
  - `test/accessibility/storm_screen_accessibility_test.dart`
  - `test/performance/storm_screen_performance_test.dart`
- **Design System**: `lib/design_system/app_theme.dart`

---

## Version History

| Version | Date | Changes | Author |
|---------|------|---------|--------|
| 1.0.0 | 2025-01-23 | Initial documentation - STORM-010 complete | Claude Code |

---

**Last Updated**: 2025-01-23
**Status**: ✅ Production-Ready
**Reviewed By**: Code-reviewer agent (A+ rating for STORM-007/008/009)
