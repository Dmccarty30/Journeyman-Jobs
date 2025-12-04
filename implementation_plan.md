# Implementation Plan

Fix Dart syntax error "Expected to find ')'" at line 834 in lib/screens/onboarding/onboarding_steps_screen.dart caused by malformed widget tree nesting in the build() method's Stack > Column structure.

The error occurs due to extra/misplaced closing brackets `],` after the Column widget in the Stack children list. The Progress Container's inner Column is properly closed, but there's an extra closing sequence breaking the outer Column and Stack.

The fix involves a targeted replace_in_file to remove the malformed closing lines and ensure proper widget nesting.

[Types]
No type changes required. The fix is pure syntax correction in existing widget tree.

[Files]
Modify 1 existing file:
- lib/screens/onboarding/onboarding_steps_screen.dart: Fix malformed Column/Stack nesting in build() method around line 834.

No new files, deletions, or config changes.

[Functions]
No function changes required. The error is in widget build method structure, not function logic.

[Classes]
No class changes required. Syntax fix only.

[Dependencies]
No dependency changes required.

[Testing]
Run `flutter analyze lib/screens/onboarding/onboarding_steps_screen.dart` after fix to verify no syntax errors remain. Success criteria: "No issues found".

[Implementation Order]
1. Use replace_in_file with precise SEARCH/REPLACE block targeting the Progress Container to Stack closing malformation
2. Run `flutter analyze lib/screens/onboarding/onboarding_steps_screen.dart` to confirm fix
3. If clean, task complete. If issues remain, iterate with new replace_in_file
