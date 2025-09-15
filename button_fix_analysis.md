# Button Compilation Error Analysis

## Problem
Flutter compilation errors indicating missing required 'size' parameter for:
- JJPrimaryButton
- JJSecondaryButton

## Root Cause
The button component definitions in `lib/design_system/components/reusable_components.dart` have been updated to require a `size` parameter, but existing usages haven't been updated.

## Expected Button Structure
```dart
enum ButtonSize {
  small,
  medium,
  large,
}

class JJPrimaryButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonSize size; // This is now required
  // ... other parameters
}
```

## Files Needing Updates
1. `lib/screens/onboarding/welcome_screen.dart` - Use ButtonSize.large for CTAs
2. `lib/screens/auth/forgot_password_screen.dart` - Use ButtonSize.medium for forms
3. `lib/screens/settings/feedback/feedback_screen.dart` - Use ButtonSize.medium
4. `lib/screens/tools/electrical_calculators_screen.dart` - Use ButtonSize.medium
5. `lib/screens/notifications/notifications_screen.dart` - Use ButtonSize.medium
6. `lib/screens/settings/notification_settings_screen.dart` - Use ButtonSize.medium
7. `lib/screens/settings/app_settings_screen.dart` - Use ButtonSize.medium
8. `lib/services/notification_permission_service.dart` - Use ButtonSize.small for dialogs

## Fix Pattern
Replace:
```dart
JJPrimaryButton(
  text: 'Button Text',
  onPressed: () {},
)
```

With:
```dart
JJPrimaryButton(
  text: 'Button Text',
  size: ButtonSize.{appropriate_size},
  onPressed: () {},
)
```

## Size Guidelines
- **Large**: Welcome screens, main CTAs, primary actions
- **Medium**: Settings, forms, standard interactions
- **Small**: Dialogs, secondary actions, compact spaces