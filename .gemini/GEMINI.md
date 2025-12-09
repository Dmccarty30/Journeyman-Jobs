# Journeyman Jobs - Gemini AI Assistant Guidelines

## 🚀 Project Overview

Journeyman Jobs is a Flutter mobile application for IBEW electrical professionals (journeymen, linemen, wiremen, operators, tree trimmers). Its primary purpose is to centralize job discovery, facilitate storm work opportunities, and enable crew collaboration.

**Target Users**: Inside Wiremen, Journeyman Linemen, Tree Trimmers, Equipment Operators, Inside Journeyman Electricians.

## 🛠️ Technical Stack & Architecture

* **Frontend**: Flutter 3.6+ with Dart, Riverpod for state management, `go_router` for navigation.
* **Backend**: Firebase (Authentication, Firestore, Storage, Cloud Functions).
* **Data Aggregation**: Backend services for job scraping, normalization, and caching.
* **Mobile Features**: Push Notifications (FCM), Offline Capability (local SQLite), Location Services (GPS), Biometric Authentication.

## 🎨 Design & Theme

* **Electrical Theme**: Incorporate circuit patterns, lightning bolts, and electrical symbols.
* **Primary Colors**: Navy (`#1A202C`) and Copper (`#B45309`).
* **Typography**: Google Fonts Inter.
* **Custom Components**: Use `JJ` prefix (e.g., `JJButton`).
* **Theme Constants**: Always use `AppTheme` from `lib/design_system/app_theme.dart`.

## 📂 Code Structure & Modularity

* **Feature-based architecture**:

    ```dart
    lib/
    ├── screens/
    ├── widgets/
    ├── services/
    ├── providers/
    ├── models/
    ├── design_system/
    ├── electrical_components/
    └── navigation/
    ```

* **Imports**

* Always use package imports (package:journeyman_jobs/...) for any file inside lib/.
* Never use relative imports (../..) inside lib/ (except in main.dart or very rare cases).
* Relative imports are only allowed inside the test/ folder or when a file in lib/ imports something outside lib/ (e.g., lib/main.dart importing src/ or gen/).

Correct examples:

```Dart
import 'package:journeyman_jobs/core/utils/extensions.dart';
import 'package:journeyman_jobs/design_system/components/button.dart';
import 'package:journeyman_jobs/features/auth/presentation/login_screen.dart';
import 'package:journeyman_jobs/features/profile/data/profile_repository.dart';
```

Incorrect (forbidden inside lib/):

```Dart
import '../../core/utils/extensions.dart';
import '../../../design_system/components/button.dart';
import '../data/profile_repository.dart';
```

## 🧪 Testing Guidelines

* **Widget tests**: For all new screens and components in `/test` directory, mirroring `/lib` structure.
* **Coverage**: Widget rendering, user interaction, state management, error handling.

## 🚦 Operational Guidelines for Gemini

1. **Context First**: Always refer to for project context, current status, and requirements.
2. **Adhere to Conventions**: Strictly follow Flutter/Dart conventions, project's code style, and architectural patterns.
3. **Firebase Focus**: All backend interactions will be with Firebase. Do not assume other backend services.
4. **Electrical Theme**: Maintain the electrical design theme in all UI/UX considerations.
5. **Error Handling**: Prioritize robust error handling, logging, and user feedback.
6. **Security & Privacy**: Be mindful of PII, location data, and union data sensitivity. Ensure Firebase Security Rules are considered.
7. **Mobile-First**: Design and implement with a mobile-first approach.
8. **Offline Capability**: Consider offline support for critical features.
9. **Performance**: Optimize for performance, especially for large datasets (e.g., 797+ union locals).
10. **Clarification**: Ask for clarification on Firebase schemas, IBEW terminology, or ambiguous requirements.

## 📝 Task Management

* **Update `TASK.md`**: Reflect progress, completion, and any new discoveries.
* **Troubleshoot**: After completing any task run "Flutter Analyze" on the files that you have modified to identify any errors and correct them BEFORE marking that tasks as complete.

This `GEMINI.md` will serve as my primary reference for understanding and contributing to the Journeyman Jobs project.
