# AGENTS.md

This file provides guidance to agents when working with code in this repository.

## Project Overview

This is a Flutter application called "Journeyman Jobs" for IBEW electrical workers. It serves electrical journeymen, linemen, wiremen, operators, and tree trimmers with job referrals, union directory, weather integration, and crew management features.

## Stack & Architecture

- **Language**: Dart 3.6.0+
- **Framework**: Flutter with Material Design 3
- **State Management**: Riverpod (flutter_riverpod)
- **Navigation**: go_router
- **Backend**: Firebase (Auth, Firestore, Storage, Cloud Functions)
- **Architecture**: Feature-based with providers, services, and widgets

## Critical Non-Obvious Patterns

### Firebase Initialization

- Always check `if (Firebase.apps.isEmpty)` before initializing Firebase in main.dart
- Firestore uses 100MB cache for offline persistence: `cacheSizeBytes: 100 * 1024 * 1024`

### Design System (MANDATORY)

- **NEVER hardcode values** - Always use `AppTheme` constants from `lib/design_system/app_theme.dart`
- **JJ-prefixed components only**: Use `JJButton`, `JJCard`, `JJTextField` instead of standard Flutter components
- **Electrical theme enforcement**: All UI must follow copper (#B45309) and navy (#1A202C) color scheme
- **Prime Design System**: Reference `.roo/rules/1-prime.md` for complete design guidelines - NO EXCEPTIONS

### State Management

- App wrapped in `ProviderScope` for Riverpod
- Main app is `ConsumerWidget` to access providers
- Use `AppRouter.router` for navigation

### Testing Structure

- Test files mirror `lib/` structure in `test/` directory
- Minimum coverage: widget rendering, user interaction, state management, error handling

## Commands

### Development

```bash
flutter run                    # Run on connected device/emulator
flutter run --debug            # Debug mode
flutter run --profile          # Profile mode
flutter run --release          # Release mode
```

### Testing

```bash
flutter test                    # Run all tests
flutter test test/widgets/      # Run widget tests only
flutter test --coverage         # Generate coverage report
```

### Building

```bash
flutter build apk              # Build Android APK
flutter build ios              # Build iOS app
flutter build web              # Build web app
```

### Analysis & Linting

```bash
flutter analyze                # Static analysis
flutter format .               # Format code
```

## Code Style Guidelines

### Imports

- Prefer relative imports within features
- Absolute imports for cross-feature dependencies
- Group imports: Flutter, third-party, local

### Naming Conventions

- Classes: PascalCase
- Methods/functions: camelCase
- Variables: camelCase
- Constants: UPPER_SNAKE_CASE
- Files: snake_case.dart

### Error Handling

```dart
try {
  // Implementation
} catch (e) {
  // Handle specific exceptions
  // Log errors appropriately
}
```

### Async Operations

- Always handle loading and error states
- Use proper error boundaries
- Show user feedback for operations

## Firebase Integration

### Collections Structure

- Jobs, Users, Unions, Crews, etc.
- Use Firestore security rules
- Implement offline persistence where needed

### Authentication

- Google Sign-In and Apple Sign-In support
- Proper permission handling
- Secure token management

## Weather Integration

### NOAA Services

- Use official government APIs (no keys needed)
- `api.weather.gov` for weather data
- `radar.weather.gov` for radar images
- Cache data for offline access during storms

### Location Services

- Request permissions gracefully
- Use `geolocator` package
- Respect user privacy

## Job Sharing Features

### Viral Growth

- Email/SMS sharing with deep linking
- Quick signup flow (< 2 minutes)
- Crew management and coordination
- Analytics tracking for viral coefficient

### Contact Integration

- `contacts_service` for phone contacts
- Permission handling
- Smart user detection

## Union Directory

### Data Management

- 797+ IBEW locals with contact info
- Offline caching critical
- Performance optimization for large lists
- Some data may be member-only

## Security & Privacy

### Data Protection

- Never log PII (ticket numbers, SSN)
- Encrypt sensitive data
- Secure Firebase rules
- Location data never stored without encryption

### Union Data Sensitivity

- Handle IBEW local information professionally
- Respect member-only content
- Proper access controls

## AI Assistant Rules

### Serena MCP Server (MANDATORY)

For code analysis, debugging, documentation, testing, architecture, and performance tasks:

- Use Serena MCP server tools first
- Located at `C:\Users\david\Documents\Cline\MCP\serena\`
- Document when Serena is used or unavailable

### Task Tracking

- Update `TASK.md` with progress
- Mark completed tasks with dates
- Note discovered issues during work

### Code Quality

- Create widget tests for all new screens
- Follow electrical theme in all components
- Use standardized JJ-prefixed components
- Reference Prime Design System for UI consistency

## Performance Considerations

### Mobile Optimization

- Large job lists need virtualization
- Image caching with `cached_network_image`
- Efficient state management
- Battery-conscious location services

### Offline Capability

- Critical features work offline
- Firestore persistence enabled
- Weather data caching
- Graceful degradation

## Development Workflow

1. Read `plan.md` for project phases
2. Check `TASK.md` for current tasks
3. Reference `docs/PROJECT_SYSTEM_DESIGN_THEME.md` for specs
4. Follow Prime Design System for UI
5. Create/update tests for new features
6. Update documentation as needed

## Common Gotchas

- Firebase initialization requires app check
- Weather APIs have rate limits
- Union data requires careful permission handling
- Electrical theme must be consistent across all screens
- JJ components replace standard Flutter widgets
- Theme constants are mandatory, no hardcoding allowed
