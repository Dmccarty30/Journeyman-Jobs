# Journeyman Jobs - Code Structure & Architecture

## Root Directory Structure
```
/mnt/c/Users/david/Desktop/Journeyman-Jobsv3/
├── android/                 # Android platform configuration
├── ios/                     # iOS platform configuration  
├── assets/                  # Static assets (images, fonts)
├── lib/                     # Main source code
├── test/                    # Test files
├── docs/                    # Documentation
├── guide/                   # Development guides
├── firebase/                # Firebase configuration
├── coverage/                # Test coverage reports
├── pubspec.yaml            # Dependencies and project config
├── analysis_options.yaml  # Linter configuration
├── README.md              # Project documentation
├── CLAUDE.md              # AI assistant guidelines
└── WARP.md                # Additional project info
```

## lib/ Directory Architecture (Feature-Based)
```
lib/
├── main.dart                    # App entry point
├── main_riverpod.dart          # Riverpod-specific entry point
├── firebase_options.dart       # Firebase configuration
├── navigation/                  # Router configuration
│   └── app_router.dart         # go_router setup
├── screens/                     # Screen widgets (UI layer)
│   ├── home/                   # Home dashboard
│   ├── jobs/                   # Job listings and details
│   ├── locals/                 # Union directory
│   ├── storm/                  # Storm work hub with weather radar
│   ├── auth/                   # Authentication screens
│   ├── onboarding/            # Welcome and setup flows
│   ├── settings/               # User preferences and account
│   │   ├── account/           # Profile and certificates
│   │   ├── support/           # Help and calculators
│   │   │   └── calculators/   # Electrical calculators
│   │   └── feedback/          # User feedback
│   ├── notifications/          # Notification management
│   ├── tools/                  # Electrical tools and calculators
│   ├── splash/                 # App startup
│   └── admin/                  # Admin dashboard
├── widgets/                     # Reusable UI components
│   ├── popups/                 # Modal and popup components
│   ├── storm/                  # Storm work specific widgets
│   └── weather/                # Weather radar components
├── services/                    # Business logic and API calls
│   ├── auth_service.dart       # Authentication
│   ├── firestore_service.dart  # Database operations
│   ├── location_service.dart   # GPS and location
│   ├── noaa_weather_service.dart # NOAA weather integration
│   ├── notification_service.dart # Push notifications
│   ├── analytics_service.dart  # User analytics
│   └── [28 other services]     # Comprehensive service layer
├── providers/                   # State management
│   └── riverpod/               # Riverpod-based providers
│       ├── auth_riverpod_provider.dart     # Authentication state
│       ├── jobs_riverpod_provider.dart     # Job listings state
│       ├── app_state_riverpod_provider.dart # Global app state
│       └── [other providers]    # Domain-specific providers
├── models/                      # Data models
│   ├── job_model.dart          # Job posting structure
│   ├── user_model.dart         # User profile
│   ├── locals_record.dart      # IBEW local information
│   ├── storm_event.dart        # Storm work events
│   └── notification/           # Notification models
├── data/                        # Data layer
│   └── repositories/           # Data access patterns
│       └── job_repository.dart # Job data operations
├── domain/                      # Business logic layer
│   ├── enums/                  # Domain enumerations
│   ├── use_cases/              # Business use cases
│   └── utils/                  # Domain utilities
├── design_system/               # Theme and styling
│   ├── app_theme.dart          # Colors, typography, spacing
│   ├── popup_theme.dart        # Modal styling
│   ├── components/             # Design system components
│   └── illustrations/          # Electrical themed graphics
├── electrical_components/       # Custom electrical UI elements
│   ├── circuit_breaker_toggle.dart
│   ├── electrical_loader.dart
│   ├── power_line_loader.dart
│   ├── transformer_trainer/    # Complex electrical training component
│   │   ├── animations/        # Electrical animations
│   │   ├── models/            # Training models
│   │   ├── painters/          # Custom painting
│   │   ├── utils/             # Performance optimization
│   │   └── widgets/           # Training UI components
│   └── [15+ electrical components] # Comprehensive electrical UI library
├── utils/                       # Utility functions
│   ├── error_handling.dart     # Error management
│   ├── memory_management.dart  # Performance optimization
│   ├── structured_logging.dart # Logging utilities
│   └── [12+ utility files]     # Core utilities
└── legacy/                      # Legacy FlutterFlow code
    └── flutterflow/            # Original FlutterFlow implementation
        └── schema/             # Database schemas
```

## Test Directory Structure
```
test/
├── core/                       # Core functionality tests
├── data/                       # Data layer tests
│   ├── models/                # Model tests
│   ├── repositories/          # Repository tests
│   └── services/              # Service tests
├── domain/                     # Business logic tests
├── presentation/               # UI layer tests
│   ├── screens/               # Screen widget tests
│   ├── widgets/               # Widget component tests
│   └── providers/             # State management tests
├── performance/                # Performance benchmarks
├── fixtures/                   # Mock data and constants
├── helpers/                    # Test utilities
└── README.md                  # Testing documentation
```

## Key Architecture Patterns
- **Feature-Based Organization**: Each major feature (jobs, locals, storm) has its own directory
- **Clean Architecture**: Separation of concerns with data, domain, and presentation layers
- **Component Hierarchy**: Reusable widgets in `/widgets`, screen-specific in `/screens`
- **Service Layer**: Business logic abstracted into services
- **State Management**: Riverpod providers for reactive state management
- **Design System**: Centralized theming and component library

## Import Conventions
- **Relative Imports**: Within the same feature directory
- **Absolute Imports**: Cross-feature dependencies
- **Barrel Exports**: Organized exports from electrical_components/

## Custom Component Prefix
- All custom components use `JJ` prefix (e.g., `JJButton`, `JJElectricalLoader`)
- Electrical-themed components prioritize safety and industry standards