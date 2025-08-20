# Journeyman Jobs - Development Commands

## Flutter Binary Location
- **Primary**: `/mnt/c/flutter/flutter/bin/flutter`
- **System**: Linux (WSL2) environment
- **Environment**: Development in Windows Subsystem for Linux

## Essential Development Commands

### Project Setup
```bash
# Install dependencies
flutter pub get

# Generate code (Riverpod, build_runner)
flutter pub run build_runner build

# Clean and regenerate
flutter pub run build_runner build --delete-conflicting-outputs

# Update dependencies
flutter pub upgrade
```

### Development & Running
```bash
# Run on iOS simulator
flutter run -d ios

# Run on Android emulator  
flutter run -d android

# Run in debug mode (default)
flutter run

# Run in release mode
flutter run --release

# Run in profile mode
flutter run --profile

# Hot restart
# Press 'R' in terminal or 'r' for hot reload
```

### Code Quality & Analysis
```bash
# Static analysis
flutter analyze

# Run linter
dart analyze

# Format code
dart format .
dart format lib/

# Check for outdated dependencies
flutter pub outdated
```

### Testing Commands
```bash
# Run all tests
flutter test

# Run specific test categories
flutter test test/data/
flutter test test/presentation/
flutter test test/performance/

# Run specific test file
flutter test test/data/models/job_model_test.dart

# Run tests with coverage
flutter test --coverage

# Run widget tests
flutter test test/presentation/widgets/

# Run integration tests
flutter test integration_test/
```

### Building for Production
```bash
# Build iOS release
flutter build ios --release

# Build Android APK
flutter build apk --release

# Build Android App Bundle (recommended for Play Store)
flutter build appbundle --release

# Build with flavor/environment
flutter build apk --flavor production --release
```

### Firebase Commands
```bash
# Initialize Firebase (if needed)
firebase init

# Deploy Firebase rules/functions
firebase deploy

# Test Firebase locally
firebase emulators:start
```

### Performance & Debugging
```bash
# Enable performance monitoring
flutter run --profile

# Analyze bundle size
flutter build apk --analyze-size

# Debug performance
flutter run --trace-startup --profile

# Check app size
flutter build apk --target-platform android-arm64 --analyze-size
```

### Platform-Specific Commands
```bash
# Clean build artifacts
flutter clean

# Get Flutter doctor info
flutter doctor

# List available devices
flutter devices

# Install app without running
flutter install

# Build for specific architecture
flutter build apk --target-platform android-arm64
```

### Development Utilities
```bash
# Generate app icons
flutter pub run flutter_launcher_icons:main

# Update splash screen
flutter pub run flutter_native_splash:create

# Generate models/serialization
flutter packages pub run build_runner build
```

## File Watching & Development
- Flutter provides hot reload automatically during `flutter run`
- Hot reload: Press 'r' in terminal
- Hot restart: Press 'R' in terminal  
- Quit: Press 'q' in terminal

## Environment Variables
- `TEST_ENVIRONMENT=test` (for testing)
- `MOCK_FIREBASE=true` (for local testing)
- `ENABLE_DEBUG_LOGS=false` (production)

## Common Development Workflow
1. `flutter pub get` - Install dependencies
2. `flutter analyze` - Check for issues
3. `flutter test` - Run tests
4. `flutter run` - Start development
5. Make changes (hot reload automatically applies)
6. `flutter test` - Verify changes
7. `dart format .` - Format code
8. Commit changes

## Troubleshooting Commands
```bash
# Clear Flutter cache
flutter clean
flutter pub get

# Reset pub cache
flutter pub cache repair

# Check Flutter installation
flutter doctor -v

# Fix common issues
flutter pub deps
```

## VS Code Integration
- Flutter extension provides integrated commands
- Dart extension for language support
- Run configurations for different devices
- Integrated debugging and hot reload