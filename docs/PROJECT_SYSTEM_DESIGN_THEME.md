# Project System Design Theme Document

This document outlines the core system design principles and architectural layers of the project, focusing on state management with Riverpod, backend integration with Firestore, and a consistent application theme. Adherence to these guidelines is crucial for maintaining a unified, performant, and maintainable codebase.

## 1. State Management: Riverpod

Riverpod is the chosen state management solution, providing a robust, testable, and compile-time safe approach to managing application state. It ensures that all data flows are predictable and reactive, enabling efficient UI updates.

### Core Principles

* **Provider-centric**: All application state and services are exposed via Riverpod providers.
* **Immutable State**: State objects are immutable, with changes handled by creating new state instances.
* **Auto-disposal**: Providers are configured for auto-disposal where appropriate, optimizing resource usage.
* **Code Generation**: `@riverpod` annotations and `build_runner` are used to generate provider code, reducing boilerplate and improving type safety.

### Key Providers

* [`AppStateNotifier`](lib/providers/riverpod/app_state_riverpod_provider.dart): Manages global application state, including connectivity, initialization status, and performance metrics. It orchestrates the initialization of other services and handles global error reporting.
* [`AuthNotifier`](lib/providers/riverpod/auth_riverpod_provider.dart): Handles user authentication state, including sign-in/sign-out operations and tracking user sessions. It integrates with `AuthService` for Firebase Authentication.
* [`JobsNotifier`](lib/providers/riverpod/jobs_riverpod_provider.dart): Manages the fetching, filtering, and pagination of job listings. It utilizes `ResilientFirestoreService` for data access and `BoundedJobCache` for efficient in-memory caching.
* [`LocalsNotifier`](lib/providers/riverpod/locals_riverpod_provider.dart): Manages the fetching and searching of local union data, integrating with `ResilientFirestoreService` for data retrieval.
* [`JobFilterNotifier`](lib/providers/riverpod/job_filter_riverpod_provider.dart): Manages job filter criteria, presets, and recent searches, persisting them using `SharedPreferences`. It provides computed providers for various filter-related states.

### Benefits

* **Fine-grained Reactivity**: Widgets only rebuild when the specific data they depend on changes, leading to optimized performance.
* **Compile-time Safety**: Errors related to provider usage are caught at compile time, improving developer experience.
* **Testability**: Providers are easily mockable and testable in isolation, simplifying unit and widget testing.
* **Reduced Boilerplate**: Code generation significantly reduces the amount of manual code required for state management.

For detailed migration examples and usage patterns, refer to [`lib/providers/riverpod/README.md`](lib/providers/riverpod/README.md).

## 2. Backend Integration: Firestore

Firestore serves as the primary NoSQL backend database for the project, offering real-time data synchronization and scalable data storage. All data interactions are abstracted through a layered service architecture to ensure resilience, performance, and maintainability.

### Core Services

* [`FirestoreService`](lib/services/firestore_service.dart): The foundational service for interacting directly with Firebase Firestore. It defines basic CRUD operations for collections like `users`, `jobs`, and `locals`, and handles pagination.
* [`ResilientFirestoreService`](lib/services/resilient_firestore_service.dart): A wrapper around `FirestoreService` that enhances reliability and performance with:
  * **Automatic Retry Logic**: For transient network failures and service unavailability.
  * **Exponential Backoff**: To prevent overwhelming the backend during retries.
  * **Circuit Breaker Pattern**: To prevent cascading failures during prolonged service outages.
  * **Intelligent Caching**: Utilizes `CacheService` for frequently accessed data (e.g., user data, popular jobs) to reduce Firestore reads and improve response times.
  * **Advanced Filtering**: Provides `getJobsWithFilter` for complex job search criteria.
* [`GeographicFirestoreService`](lib/services/geographic_firestore_service.dart): Extends `ResilientFirestoreService` to implement geographic data sharding. It organizes `locals` and `jobs` data into regional subcollections (e.g., `northeast`, `southeast`) to optimize regional queries and reduce query scope. It includes mechanisms for state-to-region mapping and cross-regional search fallbacks.
* [`SearchOptimizedFirestoreService`](lib/services/search_optimized_firestore_service.dart): Further extends `ResilientFirestoreService` to provide advanced full-text search capabilities for `LocalsRecord`. Features include multi-term search, relevance ranking, search response optimization, and caching of search results.

### Firestore Security Rules

The Firestore security rules (`firebase/firestore.rules`) enforce strict access control:

* **`jobs` collection**: Read-only for authenticated users; write access is restricted to Cloud Functions (admin only).
* **`locals` collection**: Publicly readable; write access is restricted to Cloud Functions (admin only).
* **`users` collection**: Users can only read and create their own data. Updates are restricted to prevent changing `uid` or `email` directly. Deletion is not allowed directly by users.
* **`notifications` collection**: Users can only read, create, update, and delete their own notifications.
* **`test` collection**: Read/write access for authenticated users (development only).

## 3. App Theme and UI Consistency

A consistent application theme is paramount for a cohesive and professional user experience. The design system is centralized in `lib/design_system/app_theme.dart` and `lib/design_system/popup_theme.dart`, ensuring that all UI elements adhere to a unified visual language.

### Core Principles

* **Single Source of Truth**: All design tokens (colors, fonts, spacing, border radii, shadows, animations) are defined in `AppTheme` and `PopupTheme`.
* **Strict Adherence**: Every UI/UX widget, feature, function, screen, card, button, etc., MUST strictly follow the defined theme constants. No hardcoded values are allowed for visual properties.
* **Consistency Across All Elements**: Animations, border radii, colors, and fonts must be consistent throughout the entire application.

### Key Theme Components

* [`AppTheme`](lib/design_system/app_theme.dart):
  * **Colors**: Defines a comprehensive palette including primary, secondary, neutral, status, and electrical-specific colors (e.g., `primaryNavy`, `accentCopper`, `successGreen`, `groundBrown`).
  * **Gradients**: Pre-defined linear gradients for elements like splash screens, buttons, and cards (e.g., `splashGradient`, `buttonGradient`).
  * **Spacing**: Standardized spacing values (e.g., `spacingXs`, `spacingMd`, `spacingLg`) for consistent layout and padding.
  * **Font Sizes**: Defined font sizes (e.g., `fontSizeXs`, `fontSizeSm`) for scalable typography.
  * **Border Radius**: Consistent border radii (e.g., `radiusXs`, `radiusMd`, `radiusLg`) for all rounded corners.
  * **Shadows**: Pre-defined `BoxShadow` lists (e.g., `shadowXs`, `shadowMd`, `shadowCard`) for consistent depth and elevation.
  * **Icon Sizes**: Standardized icon sizes (e.g., `iconXs`, `iconMd`, `iconXl`).
  * **Typography**: Uses `GoogleFonts.inter` with defined `TextStyle` for display, headline, title, body, label, and button text, ensuring consistent font families, weights, and heights.
  * **ThemeData**: Provides `lightTheme` and `darkTheme` configurations, applying all defined constants to Flutter's `ThemeData` for `AppBarTheme`, `ElevatedButtonTheme`, `InputDecorationTheme`, `CardTheme`, `ChipTheme`, `BottomNavigationBarTheme`, `TextTheme`, `ProgressIndicatorTheme`, `DividerTheme`, `IconTheme`, and `FloatingActionButtonTheme`.
* [`PopupTheme`](lib/design_system/popup_theme.dart):
  * An `InheritedWidget` that provides consistent theming for all popup implementations (Dialogs, BottomSheets, Snackbars, Toasts, Modals, Tooltips, Dropdowns).
  * Defines various factory constructors for specific popup types (e.g., `PopupThemeData.alertDialog()`, `PopupThemeData.bottomSheet()`, `PopupThemeData.snackBar()`), each configured with `AppTheme` constants for elevation, border radius, colors, padding, and shadows.
  * Includes a `PopupThemeExtension` on `BuildContext` for easy access to theme data and a `showThemedDialog` helper.

### UI Component Implementation

* [`JobCard`](lib/design_system/components/job_card.dart) and [`JobCardImplementation`](lib/design_system/components/job_card_implementation.dart): These components demonstrate the application of the theme to complex UI elements, ensuring consistent styling for job listings.
* [`ELECTRICAL_THEME_MIGRATION.md`](lib/design_system/ELECTRICAL_THEME_MIGRATION.md): Provides a detailed guide on migrating UI components to the enhanced electrical theme, including instructions for replacing AppBars, adding circuit pattern backgrounds, updating cards, and using electrical loading states. It also covers performance, accessibility, and testing considerations for theme integration.

## Conclusion

This document serves as the foundational guide for the project's system design, emphasizing a cohesive and efficient development approach. By strictly adhering to the principles outlined for Riverpod state management, Firestore backend integration, and the unified application theme, we ensure a high-quality, scalable, and maintainable application. All future code additions and modifications must conform to this document to maintain consistency and prevent technical debt.
