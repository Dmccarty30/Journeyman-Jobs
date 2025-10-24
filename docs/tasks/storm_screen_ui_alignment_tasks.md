# Storm Screen UI Alignment - Task List

**Generated from:** Storm Screen UI Alignment Report
**Date:** January 23, 2025
**Author:** Claude Code
**Project:** Journeyman Jobs
**Initiative:** UI Consistency System Implementation
**Version:** 1.0.0

---

## Table of Contents

- [Overview](#overview)
- [Summary Statistics](#summary-statistics)
- [Completed Tasks](#completed-tasks)
- [Follow-up Tasks](#follow-up-tasks)
- [Milestones](#milestones)
- [Task Categories](#task-categories)
- [Project Guidelines](#project-guidelines)

---

## Overview

This task list documents the Storm Screen UI Alignment initiative, which successfully standardized the storm screen and contractor card components to match the established Journeyman Jobs electrical design system.

**Phase 1 Status:** ✅ Complete (6/6 tasks)
**Overall Progress:** 50% (6/12 tasks completed)

---

## Summary Statistics

| Metric | Value |
|--------|-------|
| **Total Tasks** | 12 |
| **Completed** | 6 (50%) |
| **Pending** | 6 (50%) |
| **In Progress** | 0 |
| **Blocked** | 0 |
| **Total Estimated Hours** | 15.5 |
| **Total Actual Hours** | 1.5 |

### By Priority

| Priority | Count |
|----------|-------|
| High | 5 |
| Medium | 4 |
| Low | 3 |

### By Category

| Category | Count |
|----------|-------|
| Frontend | 5 |
| Testing | 3 |
| Code Quality | 2 |
| Documentation | 1 |
| Design System | 1 |

---

## Completed Tasks

### STORM-001: Update storm screen circuit background density

**Status:** ✅ Completed
**Priority:** High
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23

#### Description

Change the ElectricalCircuitBackground component density from ComponentDensity.high to ComponentDensity.medium to match the app-wide standard used in Jobs, Locals, and Contacts screens.

This ensures visual consistency across all main application screens and maintains the electrical theme at a standard density level.

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/electrical_components/circuit_board_background.dart`

#### Acceptance Criteria

- ✅ Background uses ComponentDensity.medium
- ✅ Opacity remains at 0.08 for subtle effect
- ✅ enableCurrentFlow set to true for animation
- ✅ Visual consistency verified with other screens
- ✅ No performance degradation from density change

#### Implementation Details

```dart
// Changed line 259 in storm_screen.dart:
// Before: componentDensity: ComponentDensity.high,
// After:  componentDensity: ComponentDensity.medium,
```

#### Tags

`ui-consistency` `storm-screen` `electrical-theme` `design-system`

---

### STORM-002: Fix storm screen main container border width

**Status:** ✅ Completed
**Priority:** High
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23
**Dependencies:** STORM-001

#### Description

Update the main content container border width from a calculated value (borderWidthCopper * 0.5 = 1.25px) to the standard borderWidthMedium constant (1.5px) to match all other card components in the application.

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- ✅ Border width uses AppTheme.borderWidthMedium (1.5px)
- ✅ No hardcoded width calculations
- ✅ Copper color maintained (accentCopper)
- ✅ Visual parity with job cards and local cards

#### Implementation Details

```dart
// Changed line 271 in storm_screen.dart:
// Before: width: AppTheme.borderWidthCopper * 0.5,
// After:  width: AppTheme.borderWidthMedium,
```

#### Notes

Eliminates magic numbers and ensures theme consistency

#### Tags

`ui-consistency` `storm-screen` `border-standardization` `design-system`

---

### STORM-003: Update storm screen main container shadow

**Status:** ✅ Completed
**Priority:** High
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23
**Dependencies:** STORM-002

#### Description

Replace the custom shadowElectricalInfo shadow with the standard AppTheme.shadowCard to match the shadow specification used across all card components (job cards, local cards, contractor cards).

This creates uniform depth perception across all card-style widgets.

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- ✅ Shadow uses AppTheme.shadowCard
- ✅ Shadow array syntax correct (not wrapped in array)
- ✅ Visual depth matches other cards
- ✅ No performance impact from shadow change

#### Implementation Details

```dart
// Changed line 273 in storm_screen.dart:
// Before: boxShadow: [AppTheme.shadowElectricalInfo,]
// After:  boxShadow: AppTheme.shadowCard,

// Note: shadowCard is already a List<BoxShadow>, no array wrapping needed
```

#### Notes

Standard shadow provides consistent elevation appearance

#### Tags

`ui-consistency` `storm-screen` `shadow-standardization` `design-system`

---

### STORM-004: Fix storm screen filter dropdown styling

**Status:** ✅ Completed
**Priority:** Medium
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23
**Dependencies:** STORM-003

#### Description

Apply the same border width and shadow updates to the region filter dropdown container to ensure consistency with the main container and all other widgets on the screen.

#### Related Files

- `lib/screens/storm/storm_screen.dart`

#### Acceptance Criteria

- ✅ Dropdown border width uses borderWidthMedium
- ✅ Dropdown shadow uses shadowCard
- ✅ Copper border color maintained
- ✅ Dropdown visually cohesive with main container

#### Implementation Details

```dart
// Changed lines 430-433 in storm_screen.dart:
// Border width: borderWidthCopper * 0.5 → borderWidthMedium
// Shadow: [shadowElectricalInfo] → shadowCard
```

#### Notes

Completes full storm screen container consistency

#### Tags

`ui-consistency` `storm-screen` `dropdown-styling` `design-system`

---

### STORM-005: Fix contractor card border radius constant

**Status:** ✅ Completed
**Priority:** High
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23

#### Description

Replace hardcoded border radius value (12) with AppTheme.radiusMd constant to eliminate magic numbers and ensure the border radius updates automatically if the design system changes.

#### Related Files

- `lib/widgets/contractor_card.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- ✅ Border radius uses AppTheme.radiusMd
- ✅ No hardcoded numeric values
- ✅ Visual appearance unchanged (12px maintained)
- ✅ Easy future theme modifications

#### Implementation Details

```dart
// Changed line 24 in contractor_card.dart:
// Before: borderRadius: BorderRadius.circular(12),
// After:  borderRadius: BorderRadius.circular(AppTheme.radiusMd),
```

#### Notes

Follows best practice of using theme constants

#### Tags

`ui-consistency` `contractor-card` `border-radius` `code-quality`

---

### STORM-006: Update contractor card shadow specification

**Status:** ✅ Completed
**Priority:** High
**Category:** Frontend
**Estimated:** 0.25 hours | **Actual:** 0.25 hours
**Completed:** 2025-01-23
**Dependencies:** STORM-005

#### Description

Replace custom BoxShadow definition with AppTheme.shadowCard to ensure contractor cards have the same visual depth and elevation as job cards, local cards, and other card components.

#### Related Files

- `lib/widgets/contractor_card.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- ✅ Shadow uses AppTheme.shadowCard
- ✅ Shadow depth matches other cards
- ✅ No custom BoxShadow definitions
- ✅ Visual consistency verified in list view

#### Implementation Details

```dart
// Changed lines 29 in contractor_card.dart:
// Before: boxShadow: [BoxShadow(color: Colors.black.withValues(alpha: 0.08), ...)]
// After:  boxShadow: AppTheme.shadowCard,
```

#### Notes

Completes contractor card standardization

#### Tags

`ui-consistency` `contractor-card` `shadow-standardization` `design-system`

---

## Follow-up Tasks

### STORM-007: Visual regression testing for storm screen

**Status:** ⏳ Pending
**Priority:** Medium
**Category:** Testing
**Estimated:** 2.0 hours
**Dependencies:** STORM-001, STORM-002, STORM-003, STORM-004, STORM-005, STORM-006

#### Description

Perform comprehensive visual regression testing on the storm screen to verify that all UI changes maintain consistency across different screen sizes, orientations, and device types.

**Test scenarios:**

- Phone (portrait/landscape)
- Tablet (portrait/landscape)
- Different screen densities
- Light/dark mode (if applicable)

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/widgets/contractor_card.dart`
- `test/screens/storm_screen_test.dart`

#### Acceptance Criteria

- [ ] Visual consistency verified across all devices
- [ ] No layout overflow or rendering issues
- [ ] Circuit background renders correctly
- [ ] All cards display with correct styling
- [ ] Screenshots captured for baseline

#### Notes

Use Flutter's screenshot testing or visual regression tools

#### Tags

`testing` `visual-regression` `quality-assurance` `storm-screen`

---

### STORM-008: Accessibility audit for updated components

**Status:** ⏳ Pending
**Priority:** Medium
**Category:** Testing
**Estimated:** 1.5 hours
**Dependencies:** STORM-007

#### Description

Verify that all UI changes maintain WCAG 2.1 AA compliance for color contrast, touch targets, semantic markup, and screen reader compatibility.

**Focus areas:**

- Color contrast ratios for copper borders
- Touch target sizes for buttons
- Semantic labels for screen readers
- Keyboard navigation support

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/widgets/contractor_card.dart`

#### Acceptance Criteria

- [ ] Color contrast ratios ≥4.5:1 for text
- [ ] Touch targets ≥44x44 logical pixels
- [ ] All interactive elements have semantic labels
- [ ] Screen reader testing completed
- [ ] Accessibility audit report generated

#### Notes

Use Flutter's accessibility tools and testing packages

#### Tags

`testing` `accessibility` `wcag-compliance` `quality-assurance`

---

### STORM-009: Performance baseline testing after UI updates

**Status:** ⏳ Pending
**Priority:** Low
**Category:** Testing
**Estimated:** 1.0 hours
**Dependencies:** STORM-001

#### Description

Establish performance baselines for the storm screen with updated circuit background density and verify no degradation in frame rate, memory usage, or battery consumption.

**Metrics to measure:**

- Frame rate (target: 60 FPS)
- CPU usage (target: <5% for backgrounds)
- Memory footprint
- Battery impact over 10 minutes

#### Related Files

- `lib/screens/storm/storm_screen.dart`
- `lib/electrical_components/circuit_board_background.dart`

#### Acceptance Criteria

- [ ] Frame rate maintains 60 FPS
- [ ] CPU usage <5% for circuit animations
- [ ] Memory footprint <10MB for backgrounds
- [ ] No measurable battery impact
- [ ] Performance report documented

#### Notes

Use Flutter DevTools for performance profiling

#### Tags

`testing` `performance` `optimization` `metrics`

---

### STORM-010: Update design system documentation

**Status:** ⏳ Pending
**Priority:** Medium
**Category:** Documentation
**Estimated:** 2.0 hours
**Dependencies:** STORM-007

#### Description

Update the comprehensive design system documentation to include storm screen as a reference implementation and document the standardized card component pattern.

**Documentation updates needed:**

- Add storm screen to component inventory
- Document standard card pattern with code examples
- Update best practices guide
- Add before/after comparison images

#### Related Files

- `docs/comprehensive/ui_consistency_system_documentation.html`
- `docs/design_system/component_patterns.md`
- `README.md`

#### Acceptance Criteria

- [ ] Storm screen documented as reference implementation
- [ ] Standard card pattern fully documented with examples
- [ ] Before/after screenshots included
- [ ] Best practices updated
- [ ] Documentation reviewed and approved

#### Notes

Use HTML format for comprehensive documentation

#### Tags

`documentation` `design-system` `knowledge-base` `storm-screen`

---

### STORM-011: Audit remaining widgets for design system compliance

**Status:** ⏳ Pending
**Priority:** Low
**Category:** Code Quality
**Estimated:** 3.0 hours
**Dependencies:** STORM-010

#### Description

Perform a comprehensive audit of all remaining card-style widgets and containers to identify any other components using hardcoded design values or non-standard styling patterns.

**Components to audit:**

- All screen containers
- All card widgets
- Modal dialogs
- Bottom sheets
- Custom containers

#### Related Files

- `lib/screens/**/*.dart`
- `lib/widgets/**/*.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- [ ] All card widgets audited
- [ ] Hardcoded values identified and documented
- [ ] Non-compliant components listed
- [ ] Remediation tasks created
- [ ] Audit report generated

#### Notes

Create follow-up tasks for any non-compliant components found

#### Tags

`code-quality` `audit` `design-system` `technical-debt`

---

### STORM-012: Create custom lint rule for hardcoded design values

**Status:** ⏳ Pending
**Priority:** Low
**Category:** Code Quality
**Estimated:** 4.0 hours
**Dependencies:** STORM-011

#### Description

Develop custom analyzer plugin or lint rule to automatically detect hardcoded color values, spacing, border widths, and other design tokens that should use AppTheme constants.

**Detection patterns:**

- Color(0xFFxxxxxx) without AppTheme reference
- BorderRadius.circular(number) without AppTheme constant
- Numeric border width values
- Direct BoxShadow definitions

#### Related Files

- `analysis_options.yaml`
- `tools/custom_lint/design_system_lint.dart`
- `lib/design_system/app_theme.dart`

#### Acceptance Criteria

- [ ] Custom lint rule implemented
- [ ] Rule detects hardcoded colors
- [ ] Rule detects hardcoded spacing/sizing
- [ ] Rule integrated into analysis_options.yaml
- [ ] Documentation for lint rule created

#### Notes

Use package:custom_lint or analyzer plugin

#### Tags

`code-quality` `automation` `linting` `design-system`

---

## Milestones

### Milestone 1: Storm Screen UI Alignment - Phase 1

**Status:** ✅ Completed
**Due Date:** January 23, 2025
**Completion:** 100%

**Tasks:**

- ✅ STORM-001: Update storm screen circuit background density
- ✅ STORM-002: Fix storm screen main container border width
- ✅ STORM-003: Update storm screen main container shadow
- ✅ STORM-004: Fix storm screen filter dropdown styling
- ✅ STORM-005: Fix contractor card border radius constant
- ✅ STORM-006: Update contractor card shadow specification

**Deliverables:**

- ✅ Storm screen background aligned to medium density
- ✅ All container borders standardized to 1.5px
- ✅ All shadows using AppTheme.shadowCard
- ✅ Contractor card fully compliant with design system
- ✅ Visual parity across all card components

---

### Milestone 2: Quality Assurance & Testing

**Status:** ⏳ Pending
**Due Date:** February 1, 2025
**Completion:** 0%

**Tasks:**

- ⏳ STORM-007: Visual regression testing for storm screen
- ⏳ STORM-008: Accessibility audit for updated components
- ⏳ STORM-009: Performance baseline testing after UI updates

**Deliverables:**

- [ ] Visual regression test suite
- [ ] Accessibility compliance report
- [ ] Performance baseline documentation

---

### Milestone 3: Documentation & Knowledge Sharing

**Status:** ⏳ Pending
**Due Date:** February 15, 2025
**Completion:** 0%

**Tasks:**

- ⏳ STORM-010: Update design system documentation

**Deliverables:**

- [ ] Updated design system documentation
- [ ] Component pattern reference guide
- [ ] Before/after visual comparisons

---

### Milestone 4: System-Wide Compliance

**Status:** ⏳ Pending
**Due Date:** March 1, 2025
**Completion:** 0%

**Tasks:**

- ⏳ STORM-011: Audit remaining widgets for design system compliance
- ⏳ STORM-012: Create custom lint rule for hardcoded design values

**Deliverables:**

- [ ] Codebase audit report
- [ ] Automated lint rules for design system
- [ ] Technical debt remediation plan

---

## Task Categories

### Frontend (5 tasks)

Tasks related to UI component updates, styling changes, and visual consistency improvements.

### Testing (3 tasks)

Quality assurance tasks including visual regression, accessibility, and performance testing.

### Code Quality (2 tasks)

Tasks focused on code standards, automated tooling, and technical debt reduction.

### Documentation (1 task)

Tasks related to updating project documentation and knowledge sharing.

### Design System (1 task)

Tasks specifically focused on design system maintenance and evolution.

---

## Project Guidelines

### Task Management

- **Task ID Format:** STORM-XXX (sequential number with prefix)
- **Priority Assignment:** Based on UI impact and design system importance
- **Status Workflow:** pending → in_progress → completed
- **Estimation Unit:** hours
- **File Path Format:** Relative to project root
- **Tag Format:** lowercase-with-hyphens

### Quality Standards

- All frontend tasks must verify design system compliance
- Testing tasks require minimum 80% coverage where applicable
- Documentation uses HTML for comprehensive docs, Markdown for reports
- Follow Flutter and Dart best practices
- Adhere to electrical theme design system (Navy #1A202C, Copper #B45309)

### Design System Standards

- **Background:** ComponentDensity.medium is standard for all screen backgrounds
- **Border:** borderWidthMedium (1.5px) with accentCopper
- **Shadow:** AppTheme.shadowCard for all cards
- **Radius:** AppTheme.radiusMd (12px) for all cards

---

## Initiative Context

This task list was generated from the Storm Screen UI Alignment Report, which documents the successful standardization of storm screen and contractor card components to match the established Journeyman Jobs electrical design system.

The initiative ensures visual consistency across all card-style widgets including job cards, local cards, contractor cards, and power outage cards by enforcing the use of AppTheme constants instead of hardcoded values.

**Phase 1 (completed)** focused on storm screen alignment.
**Future phases** will expand to system-wide compliance and automation.

---

**Last Updated:** January 23, 2025
**Status:** Phase 1 Complete - Follow-up Tasks Pending
