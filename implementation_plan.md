# Implementation Plan - Build Fixes

[Overview]
The goal is to resolve build errors preventing the Flutter application from running.
The issues involve a syntax error in a UI screen, an incorrect import path pointing to an empty package, and a type casting error in debug logging.
Fixing these will allow the `build_runner` to successfully generate the necessary Riverpod code, resolving the cascading type errors.

[Types]
No changes to the type system itself, but we will fix type casting for `DocumentSnapshot.data()`.

[Files]
Modified files:

- `lib/screens/onboarding/onboarding_steps_screen.dart`: Fix unbalanced parentheses in `_buildStep1` (or verify and fix structure).
- `lib/providers/riverpod/jobs_riverpod_provider.dart`:
  - Update `LocalModelService` import to point to `lib/services/local_model_service.dart`.
  - Fix `Object?` casting error for `data().keys`.

[Functions]

- `_buildStep1` in `onboarding_steps_screen.dart`: Ensure proper closure of `SingleChildScrollView` and `Column`.
- `loadJobs` in `JobsNotifier`: Cast `data()` to `Map<String, dynamic>` before accessing `keys`.

[Classes]
No class structure changes.

[Dependencies]
No changes to `pubspec.yaml` required for this fix, although `local_ai_model` remains an empty local package (unused after import fix).

[Implementation Order]

1. **Fix Syntax**: Correct the `SingleChildScrollView` closure in `lib/screens/onboarding/onboarding_steps_screen.dart`.
2. **Fix Import & Cast**: Update `lib/providers/riverpod/jobs_riverpod_provider.dart` to use the correct `LocalModelService` import and fix the debug log type error.
3. **Generate Code**: Run `flutter pub run build_runner build --delete-conflicting-outputs` to regenerate Riverpod providers.
4. **Verify**: Run `flutter run` to confirm the application builds and launches.

task_progress Items:

- [ ] Fix syntax error in `lib/screens/onboarding/onboarding_steps_screen.dart`
- [ ] Update import and fix type casting in `lib/providers/riverpod/jobs_riverpod_provider.dart`
- [ ] Run `flutter pub run build_runner build --delete-conflicting-outputs`
- [ ] Verify build with `flutter run` (dry run or compilation check)
