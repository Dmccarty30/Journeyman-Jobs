# Project Coding Rules (Non-Obvious Only)

- Firebase initialization must check `if (Firebase.apps.isEmpty)` before calling `Firebase.initializeApp()` in main.dart
- Firestore settings require explicit offline persistence: `persistenceEnabled: true, cacheSizeBytes: 100 * 1024 * 1024`
- App must be wrapped in `ProviderScope` for Riverpod, main widget extends `ConsumerWidget`
- Navigation uses `AppRouter.router` from go_router package
- All UI components must use JJ-prefixed variants: `JJButton`, `JJCard`, `JJTextField` instead of standard Flutter widgets
- Theme values are NEVER hardcoded - always reference `AppTheme` constants from `lib/design_system/app_theme.dart`
- Prime Design System in `.roo/rules/1-prime.md` is mandatory for all UI work - NO EXCEPTIONS
- Test files mirror `lib/` structure in `test/` directory exactly
- Widget tests must cover: rendering, user interaction, state management, error handling minimum
