# Project Context

## Purpose

Journeyman Jobs is a comprehensive Flutter mobile application designed specifically for IBEW (International Brotherhood of Electrical Workers) members and electrical industry workers. The app serves as a unified platform connecting skilled electrical workers with job opportunities, storm work response teams, and union resources across the United States.

**Core Mission**: Streamline job referrals and emergency storm work coordination for electrical workers (journeymen, linemen, wiremen, operators, and tree trimmers) while providing critical weather monitoring and crew management capabilities.

**Primary Goals**:

- Connect workers with electrical job opportunities through AI-powered matching
- Provide real-time storm work coordination and emergency response capabilities
- Offer comprehensive IBEW local union directory and integration
- Deliver critical weather monitoring for storm response teams
- Enable crew formation and management for large-scale projects
- Maintain full offline functionality for field work scenarios

## Tech Stack

### Frontend & Mobile

- **Flutter 3.6.0+** with null safety (cross-platform mobile development)
- **Dart 3.8.0+** programming language
- **Flutter Riverpod** with code generation for state management
- **go_router** for type-safe navigation and routing
- **shadcn_ui** components with custom electrical design system

### Backend & Cloud Services

- **Firebase** as primary backend infrastructure:
  - Firebase Authentication (Google Sign-In, Apple Sign-In)
  - Cloud Firestore (NoSQL database)
  - Firebase Storage (file storage)
  - Firebase Cloud Functions (serverless backend)
  - Firebase Cloud Messaging (push notifications)
  - Firebase Analytics, Performance Monitoring, Crashlytics

### External APIs & Services

- **NOAA/National Weather Service** APIs (no API key required)
- **Google Generative AI (Gemini)** for intelligent job matching
- **Stream Chat** for real-time messaging and crew communication
- **OpenStreetMap** with flutter_map for location services
- **Geolocator** for GPS and location tracking

### Development & Quality Tools

- **Testing**: Comprehensive test suite (unit, widget, integration tests)
- **Code Generation**: freezed, json_serializable, riverpod_generator
- **Mocking**: mockito, mocktail, fake_cloud_firestore
- **Performance**: Firebase Performance Monitoring + custom benchmarks
- **CI/CD**: GitHub Actions with automated deployment

## Project Conventions

### Code Style

**Naming Conventions**:

- **Files**: snake_case (e.g., `job_service.dart`, `user_model.dart`)
- **Classes**: PascalCase (e.g., `JobService`, `UserModel`)
- **Variables**: camelCase (e.g., `currentUser`, `jobListings`)
- **Constants**: UPPER_SNAKE_CASE (e.g., `API_BASE_URL`, `DEFAULT_TIMEOUT`)
- **Private members**: Prefix with underscore (`_internalMethod`)

**Dart/Flutter Specific**:

- Use `final` for immutable variables, `const` for compile-time constants
- Prefer `async`/`await` over `.then()` for asynchronous operations
- Always handle exceptions with try-catch blocks
- Use null-aware operators (`?.`, `??`) extensively
- Implement proper widget lifecycle management (`dispose`, `initState`)

**Documentation Requirements**:

- Every public class, method, and parameter must have comprehensive documentation
- Include usage examples for complex components
- Document Firebase collection schemas and field types
- Add performance notes for heavy operations

### Architecture Patterns

**Feature-Based Architecture**:

```dart
lib/
├── features/                    # Feature modules
│   ├── auth/                   # Authentication feature
│   ├── jobs/                   # Job management
│   ├── crews/                  # Crew management
│   └── weather/                # Weather monitoring
├── design_system/              # Shared UI components
├── services/                   # Business logic
├── models/                     # Data models
└── navigation/                 # Routing configuration
```

**State Management Pattern**:

- **Riverpod** providers for dependency injection
- **Repository Pattern** for data access abstraction
- **Service Layer** for business logic encapsulation
- **Provider Pattern** for state management and DI

**Data Flow**:

```dart
UI (Widgets) → Riverpod Providers → Services → Repositories → Firebase
```

**Key Architectural Principles**:

- Single Responsibility Principle for all classes
- Dependency Injection via Riverpod providers
- Immutable state objects with freezed
- Offline-first design with local caching
- Separation of concerns between UI, business logic, and data access

### Testing Strategy

**Test Pyramid Structure**:

- **Unit Tests** (70%): Test individual functions and classes in isolation
- **Widget Tests** (20%): Test Flutter widgets and UI components
- **Integration Tests** (10%): Test end-to-end user flows

**Test Organization**:

```dart
test/
├── unit/                       # Pure function tests
├── widget/                     # UI component tests
├── integration/                # End-to-end flows
├── mocks/                      # Test doubles and fixtures
└── helpers/                    # Test utilities
```

**Testing Requirements**:

- Minimum 80% code coverage for all new features
- All Firebase operations must have mock implementations
- Widget tests must cover user interactions and state changes
- Integration tests must validate critical user journeys
- Performance tests for 60+ FPS validation

**Test Tools**:

- `flutter_test` for unit and widget tests
- `integration_test` for end-to-end testing
- `mockito` and `mocktail` for mocking dependencies
- `fake_cloud_firestore` for Firebase testing
- Golden tests for UI regression testing

### Git Workflow

**Branching Strategy**:

- `main` - Production-ready code (protected branch)
- `develop` - Integration branch for features
- `feature/*` - Individual feature development
- `hotfix/*` - Critical production fixes

**Commit Message Format**:

```dart
type(scope): brief description

Detailed explanation (optional)

Fixes #issue-number
```

**Types**:

- `feat`: New feature
- `fix`: Bug fix
- `docs`: Documentation
- `style`: Code formatting (no functional change)
- `refactor`: Code refactoring
- `test`: Test addition/modification
- `chore`: Build process or dependency changes

**Example**:

```dart
feat(auth): add biometric authentication

Implement fingerprint and face recognition for secure login
using local_auth package with fallback to password.

Fixes #123
```

## Domain Context

### Electrical Industry Domain

**Target User Profiles**:

- **Journeyman Wiremen**: Power line workers specializing in transmission/distribution
- **Journeyman Wiremen**: Inside wiremen working on building electrical systems
- **Operators**: Heavy equipment operators for electrical construction
- **Tree Trimmers**: Vegetation management workers for utility companies

**IBEW Structure**:

- **797+ Local Unions** across the United States
- **Hierarchical Organization**: International → District → Local → Members
- **Jurisdiction System**: Geographic work territories by local union
- **Classification System**: Worker skill levels and specialties

**Work Types**:

- **Construction**: New electrical installation projects
- **Maintenance**: Existing system upgrades and repairs
- **Storm Work**: Emergency power restoration after disasters
- **Industrial**: Manufacturing and facility electrical work
- **Residential**: Home electrical systems and repairs

### Job Matching Algorithm Context

**Key Matching Factors**:

- Geographic proximity and travel willingness
- Skill classification and certification level
- IBEW local jurisdiction compatibility
- Wage requirements and availability dates
- Storm work experience and emergency response training

**Union Rules and Regulations**:

- **Jurisdiction Boundaries**: Workers must belong to local union serving the work area
- **Prevailing Wage**: Union-mandated minimum wages based on location and classification
- **Hiring Hall Priority**: Union members receive priority over non-union workers
- **Work Rules**: Specific conditions for overtime, travel pay, and per diem

## Important Constraints

### Technical Constraints

**Performance Requirements**:

- **60+ FPS** for all UI animations and scrolling
- **Cold Start Time**: Under 2 seconds on typical mobile devices
- **Memory Usage**: Under 150MB during normal operation
- **Battery Impact**: Less than 15% drain per hour of active use

**Platform Limitations**:

- **iOS**: App Store review guidelines and API restrictions
- **Android**: Google Play policies and API level compatibility
- **Firebase Quotas**: Document limits, query rates, and storage costs
- **Network**: Offline functionality required for poor connectivity areas

**Security Requirements**:

- **Encryption**: All data encrypted in transit and at rest
- **Authentication**: Multi-factor authentication for sensitive operations
- **Location Privacy**: User consent required for location tracking
- **Data Minimization**: Collect only necessary user information

### Business Constraints

**Regulatory Compliance**:

- **IBEW Agreements**: Must comply with union contracts and bylaws
- **Labor Laws**: Federal and state employment regulations
- **Privacy Laws**: GDPR/CCPA compliance for user data
- **Accessibility**: WCAG 2.1 AA compliance for disabled users

**Operational Constraints**:

- **Union Approval**: Changes affecting union operations require IBEW approval
- **Emergency Response**: Storm work features must have 99.9% uptime
- **Data Accuracy**: Job listings and union information must be current
- **User Support**: Must handle peak usage during storm seasons

## External Dependencies

### Firebase Services

- **Authentication**: User identity and access management
- **Firestore**: Primary database for jobs, users, and application data
- **Storage**: File storage for user avatars and document uploads
- **Cloud Functions**: Serverless backend for complex business logic
- **Hosting**: Web application deployment and CDN
- **Analytics**: User behavior tracking and business intelligence

### Third-Party APIs

- **NOAA Weather**: Real-time weather data and alerts (no API key required)
- **Google Maps API**: Location services and mapping functionality
- **Stream Chat API**: Real-time messaging and crew communication
- **Google Generative AI**: Job matching algorithms and content recommendations

### Critical Dependencies

- **Flutter Framework**: Core application framework and SDK updates
- **Firebase SDK**: Backend service integration and updates
- **Riverpod**: State management framework updates
- **Stream Chat SDK**: Real-time messaging service updates

### Service Level Agreements

- **Firebase**: 99.95% uptime for core services
- **NOAA APIs**: Best-effort availability during severe weather
- **Push Notifications**: 99.9% delivery rate for critical alerts
- **Weather Data**: Real-time updates with 5-minute refresh intervals

**Dependency Management Strategy**:

- Regular dependency updates with automated security scanning
- Compatibility testing for all major dependency updates
- Fallback mechanisms for critical external service failures
- Local caching and offline support for unreliable network conditions
