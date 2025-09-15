# Button Compilation Error Fix Guide

## Problem
Flutter compilation errors due to missing required `size` parameter for `JJPrimaryButton` and `JJSecondaryButton` components.

## Solution
Add the `size` parameter to all button instances across the affected files.

## Files to Fix

### 1. lib/screens/onboarding/welcome_screen.dart
**Size to use:** `ButtonSize.large` (main CTAs)

**Find:**
```dart
JJPrimaryButton(
  text: 'Create Account',
  onPressed: () => context.go('/onboarding'),
)
```

**Replace with:**
```dart
JJPrimaryButton(
  text: 'Create Account',
  size: ButtonSize.large,
  onPressed: () => context.go('/onboarding'),
)
```

**Find:**
```dart
JJSecondaryButton(
  text: 'Sign In',
  onPressed: () => context.go('/signin'),
)
```

**Replace with:**
```dart
JJSecondaryButton(
  text: 'Sign In',
  size: ButtonSize.large,
  onPressed: () => context.go('/signin'),
)
```

### 2. lib/screens/auth/forgot_password_screen.dart
**Size to use:** `ButtonSize.medium` (form actions)

Add `size: ButtonSize.medium,` to all `JJPrimaryButton` and `JJSecondaryButton` instances.

### 3. lib/screens/settings/feedback/feedback_screen.dart
**Size to use:** `ButtonSize.medium` (standard actions)

Add `size: ButtonSize.medium,` to all button instances.

### 4. lib/screens/tools/electrical_calculators_screen.dart
**Size to use:** `ButtonSize.medium` (tool actions)

Add `size: ButtonSize.medium,` to all button instances.

### 5. lib/screens/notifications/notifications_screen.dart
**Size to use:** `ButtonSize.medium` (standard actions)

Add `size: ButtonSize.medium,` to all button instances.

### 6. lib/screens/settings/notification_settings_screen.dart
**Size to use:** `ButtonSize.medium` (settings actions)

Add `size: ButtonSize.medium,` to all button instances.

### 7. lib/screens/settings/app_settings_screen.dart
**Size to use:** `ButtonSize.medium` (settings actions)

Add `size: ButtonSize.medium,` to all button instances.

### 8. lib/services/notification_permission_service.dart
**Size to use:** `ButtonSize.small` (dialog actions)

Add `size: ButtonSize.small,` to all button instances.

## Button Size Guidelines

- **`ButtonSize.large`**: Main CTAs, welcome screens, primary actions
- **`ButtonSize.medium`**: Settings, forms, standard interactions
- **`ButtonSize.small`**: Dialogs, secondary actions, compact spaces

## Quick Fix Commands

### Using find and replace in your IDE:

1. **Find:** `JJPrimaryButton(`
   **Replace:** `JJPrimaryButton(\n      size: ButtonSize.{SIZE},`

2. **Find:** `JJSecondaryButton(`
   **Replace:** `JJSecondaryButton(\n      size: ButtonSize.{SIZE},`

Replace `{SIZE}` with the appropriate size from the guidelines above.

## Alternative: Use the Shell Script

Run the provided `fix_button_errors.sh` script to automatically fix all files:

```bash
chmod +x fix_button_errors.sh
./fix_button_errors.sh
```

## After Fixing

1. Run `flutter pub get`
2. Run `flutter build` to verify compilation
3. Run `dart format lib/` to clean up formatting
4. Test the app to ensure buttons work correctly

## ButtonSize Enum Location

If the `ButtonSize` enum is not available, ensure it's defined in your button components file:

```dart
enum ButtonSize {
  small,
  medium,
  large,
}
```