# Toast Migration Guide

## Overview

This guide provides comprehensive instructions for migrating existing toast and snackbar implementations to use the electrical-themed components from `lib/electrical_components/`. All toasts and snackbars must use these standardized components to ensure consistent theming across the application.

### Why Migrate?

- **Consistent Theming**: Electrical-themed components provide a unified visual experience
- **Enhanced UX**: Specialized toast types for different message categories
- **Maintainability**: Centralized toast logic and styling
- **Brand Alignment**: Components align with the electrical/utilities theme

## Migration Patterns

### Old Pattern vs New Pattern

**❌ Old Pattern:**

```dart
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Operation completed successfully'),
    backgroundColor: Colors.green,
  ),
);
```

**✅ New Pattern:**

```dart
JJElectricalToast.showSuccess(
  context: context,
  message: 'Operation completed successfully',
);
```

## Available Methods

### JJElectricalToast Methods

- `JJElectricalToast.showSuccess()` - For success messages and positive feedback
- `JJElectricalToast.showError()` - For error messages and failed operations
- `JJElectricalToast.showWarning()` - For warnings and cautionary messages
- `JJElectricalToast.showInfo()` - For informational messages
- `JJElectricalToast.showPower()` - For electrical-themed messages and power-related notifications

### JJSnackBar Methods

Similar methods are available on `JJSnackBar`:

- `JJSnackBar.showSuccess()` - Success snackbar messages
- `JJSnackBar.showError()` - Error snackbar messages
- `JJSnackBar.showWarning()` - Warning snackbar messages (amber background, warning icon)
- `JJSnackBar.showInfo()` - Informational snackbar messages

## Search Commands

Use these enhanced regex patterns to find existing toast/snackbar implementations that need migration:

### Find ScaffoldMessenger Usage (Primary Migration Target)

```bash
# Find all ScaffoldMessenger.showSnackBar calls
grep -r "ScaffoldMessenger\.of\(context\)\.showSnackBar" lib/ --include="*.dart"

# Find with context variations
grep -r "ScaffoldMessenger\.of\(.*\)\.showSnackBar" lib/ --include="*.dart"
```

### Find SnackBar Constructor Calls (Secondary Migration Target)

```bash
# Find direct SnackBar constructor usage
grep -r "SnackBar(" lib/ --include="*.dart"

# Find SnackBar with specific properties
grep -r "SnackBar\s*(" lib/ --include="*.dart" -A 3

# Find SnackBar with backgroundColor property (common migration pattern)
grep -r "backgroundColor.*Colors\." lib/ --include="*.dart" -B 1 -A 2
```

### Find Toast Library Usage

```bash
# Find FlutterToast usage
grep -r "FlutterToast" lib/ --include="*.dart"

# Find toast library imports
grep -r "import.*toast" lib/ --include="*.dart"

# Find any .show() method calls that might be toast-related
grep -r "\.show(" lib/ --include="*.dart" | grep -v "showDialog\|showModal\|showBottomSheet"
```

### Advanced Search Patterns

```bash
# Find files with multiple toast/snackbar patterns (high priority)
grep -l "ScaffoldMessenger\|SnackBar" lib/**/*.dart | xargs grep -l "showSnackBar\|show("

# Find toast-related error handling patterns
grep -r "catch.*{" lib/ --include="*.dart" -A 5 | grep -B 5 -A 5 "SnackBar\|ScaffoldMessenger"

# Find toast usage in try-catch blocks (common pattern)
grep -r "try\s*{" lib/ --include="*.dart" -A 10 | grep -A 10 "SnackBar\|ScaffoldMessenger"
```

### Verification Commands

```bash
# Count total instances found
grep -r "ScaffoldMessenger\.of\(context\)\.showSnackBar" lib/ --include="*.dart" | wc -l

# List files with most instances (prioritize these first)
grep -r "ScaffoldMessenger\.of\(context\)\.showSnackBar" lib/ --include="*.dart" | cut -d: -f1 | sort | uniq -c | sort -nr
```

## Examples

### Success Message After Form Submission

**❌ Before:**

```dart
try {
  await _submitForm();
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Form submitted successfully!'),
      backgroundColor: Colors.green,
      duration: Duration(seconds: 3),
    ),
  );
} catch (e) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text('Failed to submit form: $e'),
      backgroundColor: Colors.red,
    ),
  );
}
```

**✅ After:**

```dart
try {
  await _submitForm();
  JJElectricalToast.showSuccess(
    context: context,
    message: 'Form submitted successfully!',
  );
} catch (e) {
  JJElectricalToast.showError(
    context: context,
    message: 'Failed to submit form: $e',
  );
}
```

### Error Message for Failed Operations

**❌ Before:**

```dart
if (!await _validateConnection()) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Connection failed. Please check your network.'),
      backgroundColor: Colors.orange,
    ),
  );
}
```

**✅ After:**

```dart
if (!await _validateConnection()) {
  JJElectricalToast.showWarning(
    context: context,
    message: 'Connection failed. Please check your network.',
  );
}
```

### Warning for Validation Issues

**❌ Before:**

```dart
if (formKey.currentState?.validate() == false) {
  ScaffoldMessenger.of(context).showSnackBar(
    const SnackBar(
      content: Text('Please fix the errors in the form'),
      backgroundColor: Colors.amber,
    ),
  );
}
```

**✅ After:**

```dart
if (formKey.currentState?.validate() == false) {
  JJElectricalToast.showWarning(
    context: context,
    message: 'Please fix the errors in the form',
  );
}
```

## Migration Checklist

### Files Requiring Migration

**High Priority (Multiple instances):**
- [ ] `lib/screens/sync_settings_screen.dart` - 6 ScaffoldMessenger calls for sync operations
- [ ] `lib/widgets/offline_indicator.dart` - 3 ScaffoldMessenger calls for connectivity status
- [ ] `lib/features/crews/widgets/job_match_card.dart` - 4 ScaffoldMessenger calls for job actions
- [ ] `lib/features/crews/screens/join_crew_screen.dart` - 3 ScaffoldMessenger calls for crew operations

**Medium Priority (1-2 instances):**
- [ ] `lib/widgets/job_details_dialog.dart` - 2 ScaffoldMessenger calls for job sharing
- [ ] `lib/design_system/components/reusable_components.dart` - 3 ScaffoldMessenger calls for reusable components
- [ ] `lib/screens/tools/transformer_workbench_screen.dart` - 1 ScaffoldMessenger call for validation messages
- [ ] `lib/electrical_components/jj_electrical_notifications.dart` - 1 ScaffoldMessenger call in electrical notifications
- [ ] `lib/electrical_components/transformer_trainer/modes/quiz_mode.dart` - 1 ScaffoldMessenger call for quiz feedback
- [ ] `lib/widgets/dialogs/job_details_dialog.dart` - 1 ScaffoldMessenger call for local data errors
- [ ] `lib/features/crews/widgets/activity_card.dart` - 1 ScaffoldMessenger call for activity status
- [ ] `lib/features/crews/widgets/announcement_card.dart` - 1 ScaffoldMessenger call for reaction feedback

**Lower Priority (No current instances found):**
- [x] `lib/screens/auth_screen.dart` - No migration needed
- [x] `lib/screens/jobs/jobs_screen.dart` - No migration needed
- [x] `lib/screens/settings/app_settings_screen.dart` - No migration needed
- [x] `lib/services/notification_service.dart` - No migration needed
- [x] `lib/widgets/job_card.dart` - No migration needed
- [x] `lib/providers/*/provider.dart` - No migration needed

### Migration Progress

- [x] **Phase 1**: Identify all existing toast/snackbar usage ✅ **COMPLETED**
  - Found 27 ScaffoldMessenger calls across 12 files
  - Identified 39 SnackBar constructor calls
  - Prioritized files by migration complexity
- [ ] **Phase 2**: Replace ScaffoldMessenger calls with JJElectricalToast
- [ ] **Phase 3**: Replace SnackBar constructors with appropriate toast types
- [ ] **Phase 4**: Update error handling patterns
- [ ] **Phase 5**: Test all migrated toast implementations
- [ ] **Phase 6**: Remove unused SnackBar imports

## Common Pitfalls and Solutions

### Context Issues
**Problem:** `Looking up a deactivated widget's ancestor is unsafe` errors when showing toasts from dialogs or after navigation.

**Solution:**
```dart
// ❌ Unsafe - context may be invalid
Navigator.of(context).pop();
ScaffoldMessenger.of(context).showSnackBar(...); // ERROR!

// ✅ Safe - check if context is mounted
if (context.mounted) {
  JJElectricalToast.showSuccess(context: context, message: '...');
}
```

### Duration Problems
**Problem:** Toasts disappearing too quickly for users to read, especially for error messages.

**Solution:**
```dart
// Use appropriate durations based on message type
JJElectricalToast.showError(
  context: context,
  message: 'This is an important error message that needs more time',
  duration: const Duration(seconds: 5), // Longer for errors
);
```

### Import Conflicts
**Problem:** Conflicting imports when both old SnackBar and new electrical components are used.

**Solution:**
```dart
// ❌ Conflicting imports
import 'package:flutter/material.dart'; // Has SnackBar
import 'package:your_app/electrical_components/jj_electrical_toast.dart';

// ✅ Use alias for Material SnackBar if still needed temporarily
import 'package:flutter/material.dart' as material;
import 'package:your_app/electrical_components/jj_electrical_toast.dart';
```

### Theme Inconsistencies
**Problem:** Mixed styling when some toasts use old colors and others use electrical theme.

**Solution:**
```dart
// ❌ Mixed styling
ScaffoldMessenger.of(context).showSnackBar(
  SnackBar(
    content: Text('Mixed styling!'),
    backgroundColor: Colors.green, // Old color
  ),
);

// ✅ Consistent electrical theme
JJElectricalToast.showSuccess(
  context: context,
  message: 'Consistent electrical styling!',
);
```

### Accessibility Issues
**Problem:** Screen readers not announcing toast messages properly.

**Solution:**
```dart
// The electrical toast components include proper semantics
// No additional setup needed - they handle accessibility automatically
JJElectricalToast.showInfo(
  context: context,
  message: 'This message will be announced to screen readers',
);
```

### Testing Checklist

- [ ] Verify all success messages use `showSuccess()`
- [ ] Verify all error messages use `showError()`
- [ ] Verify all warnings use `showWarning()`
- [ ] Verify all info messages use `showInfo()`
- [ ] Test toast positioning and styling
- [ ] Verify accessibility features work correctly
- [ ] Test with different screen sizes and orientations

## Testing Scenarios and Edge Cases

### Unit Testing Examples

**Testing Toast Method Selection:**
```dart
void main() {
  group('Toast Migration Tests', () {
    test('Success messages use showSuccess method', () {
      // Verify success scenarios use appropriate method
      expect(() => JJElectricalToast.showSuccess(context: context, message: 'Success!'),
             isNot(throwsException));
    });

    test('Error messages use showError method', () {
      // Verify error scenarios use appropriate method
      expect(() => JJElectricalToast.showError(context: context, message: 'Error!'),
             isNot(throwsException));
    });

    test('Warning messages use showWarning method', () {
      // Verify warning scenarios use appropriate method
      expect(() => JJElectricalToast.showWarning(context: context, message: 'Warning!'),
             isNot(throwsException));
    });
  });
}
```

### Integration Testing Scenarios

**Dialog Context Testing:**
```dart
testWidgets('Toast works correctly in dialog context', (WidgetTester tester) async {
  await tester.pumpWidget(
    MaterialApp(
      home: Scaffold(
        body: Builder(
          builder: (context) => ElevatedButton(
            onPressed: () => showDialog(
              context: context,
              builder: (context) => AlertDialog(
                actions: [
                  TextButton(
                    onPressed: () {
                      // This should work without context errors
                      if (context.mounted) {
                        JJElectricalToast.showSuccess(
                          context: context,
                          message: 'Success in dialog!',
                        );
                      }
                    },
                    child: const Text('Show Toast'),
                  ),
                ],
              ),
            ),
            child: const Text('Open Dialog'),
          ),
        ),
      ),
    ),
  );

  await tester.tap(find.text('Open Dialog'));
  await tester.pumpAndSettle();

  await tester.tap(find.text('Show Toast'));
  await tester.pumpAndSettle();

  // Verify toast appears and disappears correctly
  expect(find.text('Success in dialog!'), findsOneWidget);
});
```

### Edge Cases to Test

**1. Rapid Successive Toasts:**
```dart
// Test multiple toasts in quick succession
await _performAction1();
JJElectricalToast.showSuccess(context: context, message: 'Action 1 complete');

await _performAction2();
JJElectricalToast.showSuccess(context: context, message: 'Action 2 complete');

// Verify both messages are shown (second should replace first)
```

**2. Long Error Messages:**
```dart
// Test with lengthy error messages
JJElectricalToast.showError(
  context: context,
  message: 'This is a very long error message that should wrap properly and be fully readable by users with sufficient time to read it completely',
  duration: const Duration(seconds: 8),
);
```

**3. Special Characters and Emojis:**
```dart
// Test with special characters and emojis
JJElectricalToast.showInfo(
  context: context,
  message: '✅ Operation completed! Check: ✓ • ● ○ ►',
);
```

**4. Network Failure Recovery:**
```dart
// Test toast behavior during network issues
if (!await _checkConnectivity()) {
  JJElectricalToast.showWarning(
    context: context,
    message: '⚠️ No internet connection. Some features may not work.',
  );
}

// Later, when connection is restored
if (await _checkConnectivity()) {
  JJElectricalToast.showSuccess(
    context: context,
    message: '🌐 Connection restored!',
  );
}
```

**5. Orientation Changes:**
```dart
// Test toast behavior during orientation changes
// 1. Show toast in portrait mode
// 2. Rotate device to landscape
// 3. Verify toast still displays correctly
// 4. Rotate back to portrait
// 5. Verify toast behavior is consistent
```

**6. Memory Pressure:**
```dart
// Test under low memory conditions
// 1. Allocate significant memory
// 2. Show multiple toasts
// 3. Verify no memory leaks or crashes
// 4. Verify proper cleanup
```

### Automated Testing Commands

```bash
# Run toast-related tests
flutter test test/*toast*test.dart

# Run integration tests for UI components
flutter test integration_test/*toast*test.dart

# Test with different screen densities
flutter test --device-id emulator-5584 test/toast_accessibility_test.dart

# Performance testing for rapid toast scenarios
flutter test test/performance/toast_performance_test.dart
```

## Additional Resources

- [Electrical Components Documentation](../electrical_components/README.md)
- [Theme Integration Guide](../design_system/ELECTRICAL_THEME_MIGRATION.md)
- [Component Examples](../electrical_components/electrical_illustrations_example.dart)

## Support

For questions or issues during migration, refer to the electrical components documentation or create an issue in the project repository.
