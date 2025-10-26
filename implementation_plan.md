# Implementation Plan

## Overview
Fix the Flutter app compilation errors caused by incomplete migration from local state to RiverPod state management in the AppSettingsScreen and missing parameters in the Crew provider.

## Types
Changes to data models and state management structures to properly integrate RiverPod providers with the UI components.

## Files
- `lib/screens/settings/app_settings_screen.dart`: Remove local state variables and _saveSetting method, update UI to watch RiverPod providers and call notifier methods for updates
- `lib/features/crews/providers/crews_riverpod_provider.dart`: Add missing required parameters (visibility, maxMembers, inviteCodeCounter) to Crew constructor and import CrewVisibility enum

## Functions
- Replace _saveSetting method with direct calls to riverpod provider update methods

## Classes
- AppSettingsScreenState: Remove all private state fields (_defaultSearchRadius, _units, etc.) and replace with RiverPod provider watches

## Dependencies
No dependency changes required - all required RiverPod providers already exist.

## Testing
Run flutter build to ensure all compilation errors are resolved. Verify settings UI functionality through manual testing.

## Implementation Order
1. Fix Crew provider missing parameters
2. Remove local state fields from AppSettingsScreen
3. Update UI widgets to use ref.watch for settings values
4. Replace setState and _saveSetting calls with provider notifier method calls
5. Test compilation and fix any remaining errors
