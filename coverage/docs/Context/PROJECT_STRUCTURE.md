# Journeyman Jobs - Comprehensive Project Structure Documentation

> **Generated**: 2025-10-24
> **Version**: 1.0.0
> **Framework**: Flutter 3.8.0+
> **State Management**: Flutter Riverpod 3.0.0-dev.17

## 📋 Table of Contents

- [Project Overview](#project-overview)
- [Architecture Patterns](#architecture-patterns)
- [Directory Structure](#directory-structure)
- [Core Components](#core-components)
- [Feature Modules](#feature-modules)
- [Service Layer](#service-layer)
- [Data Models](#data-models)
- [Design System](#design-system)
- [Testing Infrastructure](#testing-infrastructure)
- [Build & Configuration](#build--configuration)
- [External Integrations](#external-integrations)
- [Development Workflow](#development-workflow)

---

## 🎯 Project Overview

**Journeyman Jobs** is a comprehensive Flutter mobile application designed for IBEW (International Brotherhood of Electrical Workers) members. The app streamlines job referrals, storm work opportunities, union directory access, and weather tracking for electrical workers across the United States.

### Key Technologies

- **Frontend**: Flutter 3.8.0+ with null safety
- **State Management**: Flutter Riverpod with code generation
- **Navigation**: go_router for type-safe routing
- **Backend**: Firebase (Auth, Firestore, Storage, FCM, Analytics)
- **AI**: Google Generative AI (Gemini)
- **Weather**: NOAA/NWS APIs
- **Maps**: flutter_map with OpenStreetMap

### Application Type

- **Platform**: Cross-platform mobile (iOS, Android)
- **Architecture**: Feature-based modular architecture
- **Design Pattern**: Clean Architecture with MVVM
- **Dependency Injection**: Riverpod providers

---

## 🏗️ Architecture Patterns

### Clean Architecture Layers

```dart
┌─────────────────────────────────────────┐
│         Presentation Layer              │
│  (Screens, Widgets, Providers)          │
├─────────────────────────────────────────┤
│         Domain Layer                     │
│  (Use Cases, Entities, Interfaces)      │
├─────────────────────────────────────────┤
│         Data Layer                       │
│  (Repositories, Services, Models)       │
└─────────────────────────────────────────┘
```

### State Management Architecture

- **Riverpod Providers**: Global state management
- **StateNotifier**: Complex state objects
- **FutureProvider**: Async data fetching
- **StreamProvider**: Real-time data streams
- **Provider**: Simple value providers

### Navigation Architecture

- **go_router**: Type-safe routing
- **Shell Routes**: Nested navigation with bottom navigation
- **Route Guards**: Authentication protection
- **Deep Linking**: URL-based navigation

---

## 📁 Directory Structure

### Root Level

```dart
journeyman-jobs/
├── lib/                    # Main Flutter application source
├── android/                # Android platform configuration
├── ios/                    # iOS platform configuration
├── test/                   # Test suites (unit, widget, integration)
├── firebase/               # Firebase configuration and rules
├── functions/              # Firebase Cloud Functions (Node.js/TypeScript)
├── scraping_scripts/       # Data collection and import scripts
├── assets/                 # Static assets (images, fonts)
├── docs/                   # Project documentation
├── guide/                  # User and developer guides
├── tools/                  # Development utilities
├── .github/                # GitHub Actions workflows
├── pubspec.yaml            # Flutter dependencies
├── firebase.json           # Firebase project configuration
├── analysis_options.yaml   # Dart analyzer configuration
└── README.md               # Project readme
```

### lib/ Directory Structure (Detailed)

```dart
lib/
├── main.dart                           # App entry point (Provider-based)
├── main_riverpod.dart                  # App entry point (Riverpod-based)
├── firebase_options.dart               # Firebase configuration (auto-generated)
│
├── architecture/                       # Architecture documentation
│   └── README.md                       # Architecture guidelines
│
├── data/                              # Data layer (repositories, data sources)
│   ├── repositories/                  # Repository implementations
│   │   ├── auth_repository.dart
│   │   ├── job_repository.dart
│   │   └── user_repository.dart
│   └── data_sources/                 # Remote and local data sources
│
├── domain/                           # Domain layer (business logic)
│   ├── enums/                        # Domain enumerations
│   │   ├── invitation_status.dart    # Crew invitation statuses
│   │   └── permission.dart           # User permissions
│   ├── exceptions/                   # Domain-specific exceptions
│   │   ├── crew_exception.dart       # Crew-related errors
│   │   └── member_exception.dart     # Member-related errors
│   └── use_cases/                    # Business use cases
│       ├── get_jobs_use_case.dart
│       └── authenticate_user_use_case.dart
│
├── features/                         # Feature modules
│   ├── crews/                        # Crew management feature
│   │   ├── models/
│   │   ├── providers/
│   │   ├── screens/
│   │   ├── services/
│   │   └── widgets/
│   └── jobs/                         # Job browsing feature
│       ├── models/
│       ├── providers/
│       ├── screens/
│       └── widgets/
│
├── models/                           # Data models (DTOs)
│   ├── contractor_model.dart         # Electrical contractor data
│   ├── conversation_model.dart       # Chat conversation structure
│   ├── crew_model.dart               # Storm crew team data
│   ├── filter_criteria.dart          # Job filter configuration
│   ├── filter_preset.dart            # Saved filter presets
│   ├── job_model.dart                # Job posting structure
│   ├── jobs_record.dart              # Firestore job record
│   ├── locals_record.dart            # IBEW local union data
│   ├── message_model.dart            # Chat message structure
│   ├── post_model.dart               # Social post structure
│   ├── power_grid_status.dart        # Power outage tracking
│   ├── storm_event.dart              # Storm work event data
│   ├── transformer_models.dart       # Electrical transformer data
│   ├── user_job_preferences.dart     # User job preferences
│   ├── user_model.dart               # User profile data
│   ├── users_record.dart             # Firestore user record
│   └── notification/
│       └── notification_preferences_model.dart
│
├── providers/                        # State management providers
│   ├── core_providers.dart           # Core app-wide providers
│   └── riverpod/                     # Riverpod-specific providers
│       ├── app_state_riverpod_provider.dart
│       ├── auth_riverpod_provider.dart
│       ├── contractor_provider.dart
│       ├── job_filter_riverpod_provider.dart
│       ├── jobs_riverpod_provider.dart
│       └── locals_riverpod_provider.dart
│
├── services/                         # Business logic services (32 files)
│   ├── analytics_service.dart        # Firebase Analytics integration
│   ├── auth_service.dart             # Authentication logic
│   ├── avatar_service.dart           # User avatar management
│   ├── cache_service.dart            # Offline data caching
│   ├── connectivity_service.dart     # Network status monitoring
│   ├── contractor_service.dart       # Contractor data management
│   ├── database_service.dart         # Database operations
│   ├── enhanced_notification_service.dart
│   ├── fcm_service.dart              # Firebase Cloud Messaging
│   ├── feed_service.dart             # Social feed management
│   ├── firestore_service.dart        # Firestore operations
│   ├── geographic_firestore_service.dart # Location-based queries
│   ├── local_notification_service.dart
│   ├── location_service.dart         # GPS and location services
│   ├── noaa_weather_service.dart     # NOAA weather API integration
│   ├── notification_manager.dart     # Notification coordination
│   ├── notification_permission_service.dart
│   ├── notification_service.dart     # Core notification service
│   ├── offline_data_service.dart     # Offline data management
│   ├── onboarding_service.dart       # User onboarding flow
│   ├── performance_monitoring_service.dart
│   ├── power_outage_service.dart     # Power grid monitoring
│   ├── resilient_firestore_service.dart
│   ├── search_analytics_service.dart # Search behavior analytics
│   ├── search_optimized_firestore_service.dart
│   ├── storage_service.dart          # File storage management
│   ├── usage_report_service.dart     # Usage analytics
│   ├── user_analytics_service.dart   # User behavior tracking
│   └── weather_radar_service.dart    # Weather radar functionality
│
├── screens/                          # Screen widgets (feature-based)
│   ├── admin/                        # Admin dashboard screens
│   ├── auth/                         # Authentication screens
│   │   └── forgot_password_screen.dart
│   ├── home/                         # Home screen and dashboard
│   ├── jobs/                         # Job browsing screens
│   ├── locals/                       # IBEW locals directory screens
│   ├── notifications/                # Notification center screens
│   ├── onboarding/                   # User onboarding flow
│   │   └── components/               # Onboarding sub-components
│   ├── settings/                     # Settings and preferences
│   │   ├── account/                  # Account settings
│   │   ├── feedback/                 # User feedback screens
│   │   └── support/                  # Support and help
│   │       └── calculators/          # Electrical calculators
│   ├── splash/                       # Splash screen
│   │   └── splash_screen.dart
│   ├── storm/                        # Storm work screens
│   ├── tools/                        # Electrical tools and utilities
│   │   ├── electrical_components_showcase_screen.dart
│   │   ├── transformer_bank_screen.dart
│   │   ├── transformer_reference_screen.dart
│   │   └── transformer_workbench_screen.dart
│   ├── nav_bar_page.dart             # Main navigation shell
│   └── sync_settings_screen.dart     # Sync settings screen
│
├── widgets/                          # Reusable UI components
│   ├── dialogs/                      # Dialog components
│   │   └── job_details_dialog.dart
│   ├── popups/                       # Popup components
│   │   └── firestore_query_popup.dart
│   ├── storm/                        # Storm-related widgets
│   │   └── power_outage_card.dart
│   ├── weather/                      # Weather widgets
│   │   └── noaa_radar_map.dart
│   ├── chat_input.dart               # Chat input widget
│   ├── emoji_reaction_picker.dart    # Emoji reaction selector
│   ├── enhanced_job_card.dart        # Advanced job display card
│   ├── generic_connection_point.dart # Generic connection widget
│   ├── job_card_skeleton.dart        # Loading skeleton
│   ├── job_details_dialog.dart       # Job details modal
│   ├── like_animation.dart           # Like button animation
│   ├── message_bubble.dart           # Chat message bubble
│   ├── notification_badge.dart       # Notification indicator
│   ├── notification_popup.dart       # Notification overlay
│   ├── offline_indicator.dart        # Offline status indicator
│   ├── optimized_selector_widgets.dart
│   └── virtual_job_list.dart         # Virtualized list for performance
│
├── navigation/                       # Routing configuration
│   └── app_router.dart               # go_router configuration
│
├── utils/                            # Utility functions and helpers
│   ├── background_wrapper.dart       # Background task wrapper
│   ├── collection_extensions.dart    # Collection helper methods
│   ├── color_extensions.dart         # Color manipulation utilities
│   ├── compressed_state_manager.dart # State compression utilities
│   ├── concurrent_operations.dart    # Parallel processing helpers
│   ├── crew_utils.dart               # Crew management utilities
│   ├── enum_utils.dart               # Enum conversion utilities
│   ├── error_handling.dart           # Error management utilities
│   ├── error_sanitizer.dart          # Error sanitization
│   ├── filter_performance.dart       # Filter optimization utilities
│   ├── firebase_test.dart            # Firebase testing utilities
│   ├── job_formatting.dart           # Job display formatting
│   ├── lat_lng.dart                  # Geographic coordinate utilities
│   ├── memory_management.dart        # Memory optimization utilities
│   ├── structured_logging.dart       # Advanced logging system
│   ├── text_formatting_wrapper.dart  # Text formatting utilities
│   ├── type_utils.dart               # Type checking utilities
│   └── validation.dart               # Input validation utilities
│
├── design_system/                    # Design system components
│   ├── accessibility/                # Accessibility utilities
│   ├── components/                   # Reusable design components
│   │   └── reusable_components.dart
│   ├── illustrations/                # Illustration assets
│   ├── layout/                       # Layout components
│   ├── app_theme.dart                # Theme configuration
│   ├── electrical_theme.dart         # Electrical-specific theming
│   └── ELECTRICAL_THEME_MIGRATION.md # Theme migration guide
│
├── electrical_components/            # Electrical-themed UI components
│   ├── transformer_trainer/          # Transformer training module
│   │   └── README.md
│   ├── INTEGRATION.md                # Integration guide
│   ├── README.md                     # Component documentation
│   └── README_ENHANCEMENTS.md        # Enhancement documentation
│
├── shims/                            # Compatibility shims
│   └── flutterflow_shims.dart        # FlutterFlow compatibility layer
│
└── legacy/                           # Legacy FlutterFlow code
    ├── flutterflow/                  # FlutterFlow-generated code
    │   └── schema/
    │       ├── index.dart
    │       └── preferences_record.md
    └── utils/
        └── lat_lng.dart              # Legacy coordinate utilities
```

---

## 🎨 Core Components

### Entry Points

#### main.dart

**Purpose**: Primary app entry point using Provider state management
**Key Features**:

- Firebase initialization
- App-wide error handling
- Theme configuration
- Material app setup

#### main_riverpod.dart

**Purpose**: Alternative entry point using Riverpod state management
**Key Features**:

- ProviderScope wrapper
- Riverpod-based app initialization
- Observer setup for debugging
- Enhanced error boundaries

### Firebase Configuration

#### firebase_options.dart

**Purpose**: Auto-generated Firebase configuration
**Generated By**: FlutterFire CLI
**Contains**:

- Platform-specific Firebase configurations
- API keys and project IDs
- App IDs for iOS and Android

---

## 🧩 Feature Modules

### Crews Feature (`lib/features/crews/`)

**Purpose**: Storm crew team management and coordination

**Components**:

- **Models**: Crew data structures, member roles, permissions
- **Providers**: Crew state management, real-time updates
- **Screens**: Crew list, crew details, member management
- **Services**: Crew CRUD operations, invitation system
- **Widgets**: Crew cards, member lists, permission controls

**Key Files**:

- `crew_model.dart` - Crew data structure
- `crew_service.dart` - Crew business logic
- `crew_provider.dart` - State management

### Jobs Feature (`lib/features/jobs/`)

**Purpose**: Job browsing, filtering, and application management

**Components**:

- **Models**: Job postings, filter criteria, search parameters
- **Providers**: Job state, filter state, search state
- **Screens**: Job list, job details, job search
- **Widgets**: Job cards, filter panels, search bars

**Key Files**:

- `job_model.dart` - Job data structure
- `jobs_riverpod_provider.dart` - Job state management
- `job_filter_riverpod_provider.dart` - Filter state

---

## 🔧 Service Layer

### Core Services (32 total)

#### Authentication Services

- **auth_service.dart** - Firebase Authentication wrapper
- **avatar_service.dart** - User avatar upload/management

#### Data Services

- **firestore_service.dart** - Base Firestore operations
- **resilient_firestore_service.dart** - Retry logic and error handling
- **search_optimized_firestore_service.dart** - Optimized search queries
- **geographic_firestore_service.dart** - Location-based queries
- **database_service.dart** - Database abstraction layer

#### Notification Services

- **notification_service.dart** - Core notification logic
- **enhanced_notification_service.dart** - Advanced notification features
- **local_notification_service.dart** - Local notification handling
- **notification_manager.dart** - Notification coordination
- **notification_permission_service.dart** - Permission management
- **fcm_service.dart** - Firebase Cloud Messaging integration

#### Weather Services

- **noaa_weather_service.dart** - NOAA API integration
- **weather_radar_service.dart** - Radar map functionality
- **power_outage_service.dart** - Power grid status monitoring

#### Analytics Services

- **analytics_service.dart** - Firebase Analytics wrapper
- **user_analytics_service.dart** - User behavior tracking
- **search_analytics_service.dart** - Search behavior analytics
- **usage_report_service.dart** - Feature usage reporting
- **performance_monitoring_service.dart** - Performance tracking

#### Utility Services

- **cache_service.dart** - Offline data caching
- **offline_data_service.dart** - Offline mode management
- **connectivity_service.dart** - Network status monitoring
- **location_service.dart** - GPS and location services
- **storage_service.dart** - File storage management
- **contractor_service.dart** - Contractor data management
- **feed_service.dart** - Social feed management
- **onboarding_service.dart** - User onboarding flow

---

## 📊 Data Models

### Core Models (21 total)

#### User & Authentication

- **user_model.dart** - User profile data
- **users_record.dart** - Firestore user document
- **user_job_preferences.dart** - Job matching preferences

#### Jobs & Contractors

- **job_model.dart** - Job posting structure
- **jobs_record.dart** - Firestore job document
- **contractor_model.dart** - Contractor information
- **filter_criteria.dart** - Job filter configuration
- **filter_preset.dart** - Saved filter presets

#### Unions & Locals

- **locals_record.dart** - IBEW local union data

#### Storm & Weather

- **storm_event.dart** - Storm work event data
- **power_grid_status.dart** - Power outage tracking
- **transformer_models.dart** - Electrical equipment data

#### Crew Management

- **crew_model.dart** - Storm crew structure
- **message_model.dart** - Chat message structure
- **conversation_model.dart** - Chat conversation data
- **post_model.dart** - Social post structure

#### Notifications

- **notification_preferences_model.dart** - User notification settings

---

## 🎨 Design System

### Structure

```dart
lib/design_system/
├── accessibility/          # WCAG compliance utilities
├── components/             # Reusable design components
├── illustrations/          # Vector illustrations
├── layout/                 # Layout templates
├── app_theme.dart          # Main theme configuration
├── electrical_theme.dart   # Electrical-specific styling
└── ELECTRICAL_THEME_MIGRATION.md
```

### Theme System

**Primary Colors**:

- Navy: `#1A202C`
- Copper: `#B45309`

**Typography**:

- Font: Google Fonts Inter
- Predefined text styles: `headingLarge`, `bodyMedium`, etc.

**Component Standards**:

- Border radius: 12px
- Border width: 1.5px
- Shadow: `AppTheme.shadowCard`
- Density: `ComponentDensity.medium`

**Electrical Components** (`lib/electrical_components/`):

- Circuit pattern backgrounds
- Lightning bolt animations
- Electrical symbol icons
- Power meter indicators
- Transformer training tools

---

## 🧪 Testing Infrastructure

### Test Structure

```dart
test/
├── data/                           # Data layer tests
│   ├── models/                     # Model validation tests
│   │   ├── job_model_test.dart
│   │   └── user_model_test.dart
│   ├── repositories/               # Repository tests
│   │   └── job_repository_test.dart
│   └── services/                   # Service layer tests
│       ├── auth_service_test.dart
│       ├── cache_service_test.dart
│       ├── connectivity_service_test.dart
│       └── firestore_service_test.dart
│
├── domain/                         # Business logic tests
│   └── use_cases/
│       └── get_jobs_use_case_test.dart
│
├── features/                       # Feature-specific tests
│   └── crews/
│       ├── unit/                   # Unit tests
│       │   ├── crew_model_test.dart
│       │   ├── crew_service_test.dart
│       │   ├── database_service_test.dart
│       │   ├── job_model_test.dart
│       │   ├── message_model_test.dart
│       │   ├── message_service_test.dart
│       │   └── post_model_test.dart
│       ├── integration/            # Integration tests
│       │   └── tailboard_service_test.dart
│       ├── services/               # Service tests
│       │   ├── crew_service_test.dart
│       │   └── crews_service_test.dart
│       └── tailboard_screen_test.dart
│
├── presentation/                   # UI layer tests
│   ├── providers/                  # Provider tests
│   │   ├── app_state_provider_test.dart
│   │   └── job_filter_provider_test.dart
│   ├── screens/                    # Screen tests
│   │   ├── auth/
│   │   │   └── auth_screen_test.dart
│   │   ├── home/
│   │   │   └── home_screen_test.dart
│   │   ├── jobs/
│   │   │   └── jobs_screen_test.dart
│   │   ├── locals/
│   │   │   └── locals_screen_test.dart
│   │   ├── splash/
│   │   │   └── splash_screen_test.dart
│   │   └── storm/
│   │       └── README_VISUAL_TESTS.md
│   └── widgets/
│       └── electrical_components/
│           ├── electrical_rotation_meter_test.dart
│           ├── jj_circuit_breaker_switch_test.dart
│           └── power_line_loader_test.dart
│
├── performance/                    # Performance tests
│   ├── backend_performance_test.dart
│   └── firestore_load_test.dart
│
├── integration_test/               # E2E integration tests
│   ├── crew_flow_test.dart
│   └── tailboard_flow_test.dart
│
├── helpers/                        # Test utilities
│   └── test_helpers.dart
│
├── fixtures/                       # Test data
│   └── test_constants.dart
│
├── utils/                          # Test utilities
│   └── crew_utils_test.dart
│
├── services/                       # Additional service tests
│   ├── counter_service_test.dart
│   ├── crews_service_test.dart
│   └── user_profile_service_test.dart
│
├── job_details_dialog_test.dart
└── README.md
```

### Testing Tools

- **mockito**: Mock generation for unit tests
- **mocktail**: Alternative mocking library
- **fake_cloud_firestore**: Mock Firestore for testing
- **firebase_auth_mocks**: Mock Firebase Auth
- **flutter_test**: Widget testing framework
- **integration_test**: E2E testing framework

### Test Coverage Goals

- **Unit Tests**: ≥80%
- **Integration Tests**: ≥70%
- **Widget Tests**: All critical UI components
- **E2E Tests**: Main user flows

---

## ⚙️ Build & Configuration

### Configuration Files

#### pubspec.yaml

**Purpose**: Flutter dependency management
**Contains**:

- 50+ dependencies (Firebase, Riverpod, UI libraries)
- Dev dependencies (testing, code generation)
- Asset configuration
- App launcher icon settings

#### analysis_options.yaml

**Purpose**: Dart static analysis configuration
**Features**:

- flutter_lints rule set
- Custom lint rules
- Strict mode settings

#### firebase.json

**Purpose**: Firebase project configuration
**Contains**:

- Hosting settings
- Function deployment config
- Firestore rules path
- Storage rules path

#### firestore.indexes.json

**Purpose**: Firestore composite index definitions
**Contains**:

- Search optimization indexes
- Query performance indexes

---

## 🔌 External Integrations

### Firebase Services

- **Authentication**: Email, Google, Apple Sign-In
- **Firestore**: Real-time database
- **Cloud Storage**: File uploads
- **Cloud Messaging**: Push notifications
- **Analytics**: User behavior tracking
- **Performance**: Performance monitoring
- **Crashlytics**: Crash reporting

### Weather APIs

- **NOAA/NWS**: Weather alerts and forecasts
- **Radar Stations**: Live radar imagery
- **National Hurricane Center**: Storm tracking
- **Storm Prediction Center**: Severe weather outlooks

### AI Integration

- **Google Generative AI**: Job matching and recommendations
- **Gemini Models**: Natural language processing

### Maps & Location

- **flutter_map**: Interactive map rendering
- **OpenStreetMap**: Map tile provider
- **Geolocator**: GPS and location services

---

## 🛠️ Development Workflow

### Code Generation

```bash
# Generate Riverpod providers
flutter pub run build_runner build --delete-conflicting-outputs

# Generate Freezed models
flutter pub run build_runner build

# Watch mode for development
flutter pub run build_runner watch
```

### Running Tests

```bash
# All tests
flutter test

# Specific test file
flutter test test/data/services/auth_service_test.dart

# With coverage
flutter test --coverage

# Integration tests
flutter test integration_test/
```

### Building

```bash
# Debug build
flutter run

# Release build (Android)
flutter build apk --release

# Release build (iOS)
flutter build ios --release
```

### Firebase Deployment

```bash
# Deploy functions
cd functions && npm install && firebase deploy --only functions

# Deploy Firestore rules
firebase deploy --only firestore:rules

# Deploy all
firebase deploy
```

---

## 📚 Additional Documentation

### Key Documentation Files

- **README.md** - Project overview and setup
- **CLAUDE.md** - AI assistant guidelines
- **TASK.md** - Task tracking
- **CHANGELOG.md** - Version history
- **guide/screens.md** - Screen specifications
- **guide/settings.md** - Settings documentation
- **guide/instructions.md** - Development instructions
- **docs/WEATHER_API.md** - Weather integration guide
- **docs/Context/** - Project context documentation
- **docs/tailboard/** - Crew management documentation
- **docs/reports/** - Feature reports

### Architecture Documentation

- **lib/architecture/README.md** - Architecture guidelines
- **lib/design_system/ELECTRICAL_THEME_MIGRATION.md** - Theme migration
- **lib/electrical_components/INTEGRATION.md** - Component integration
- **lib/providers/riverpod/README.md** - Riverpod patterns
- **test/README.md** - Testing guidelines

---

## 🔗 Cross-References

### Related Documentation

- [Firebase Setup Guide](../firebase/FIREBASE_SETUP.md)
- [Weather API Documentation](../docs/WEATHER_API.md)
- [Testing Guide](../test/README.md)
- [Electrical Components](../lib/electrical_components/README.md)
- [Design System Migration](../lib/design_system/ELECTRICAL_THEME_MIGRATION.md)

### Screen Specifications

- [Screen Specifications](../guide/screens.md)
- [Settings Documentation](../guide/settings.md)
- [Onboarding Flow](../docs/ONBOARDING_FLOW_ARCHITECTURE.md)

### Development Guides

- [Development Instructions](../guide/instructions.md)
- [AI Assistant Guidelines](../CLAUDE.md)
- [Troubleshooting Guide](../docs/TROUBLESHOOTING_GUIDE.md)

---

## 📈 Project Statistics

- **Total Dart Files**: 200+ files
- **Services**: 32 service files
- **Models**: 21 model files
- **Screens**: 17 screen directories
- **Widgets**: 30+ reusable widgets
- **Test Files**: 50+ test files
- **Dependencies**: 50+ packages
- **Supported Platforms**: iOS, Android

---

## 🎯 Quick Navigation

### For New Developers

1. Start with [README.md](../README.md)
2. Read [CLAUDE.md](../CLAUDE.md) for AI guidelines
3. Review [guide/screens.md](../guide/screens.md) for features
4. Check [lib/architecture/README.md](../lib/architecture/README.md)

### For Feature Development

1. Review feature module structure in `lib/features/`
2. Check existing models in `lib/models/`
3. Review service layer in `lib/services/`
4. Follow design system in `lib/design_system/`
5. Write tests in corresponding `test/` directories

### For Testing

1. Review [test/README.md](../test/README.md)
2. Check test structure above
3. Use test helpers in `test/helpers/`
4. Follow testing patterns in existing tests

---

**Document Version**: 1.0.0
**Last Updated**: 2025-10-24
**Maintainer**: Development Team
