# Project Architecture & Style Rules

## 1. Feature-First Directory Structure
To improve maintainability and scalability, the project follows a **Feature-First** architecture. Code should be organized by *business feature* rather than by technical layer.

### Rule
- **Do NOT** put all widgets in a top-level `widgets/` folder, or all models in a `models/` folder.
- **DO** group all related files for a specific feature (screens, widgets, models, providers, services) within a dedicated directory under `lib/features/`.

### Example Structure
```text
lib/
├── features/
│   ├── crews/
│   │   ├── models/           # Data models specific to Crews
│   │   ├── providers/        # State management (Riverpod) for Crews
│   │   ├── screens/          # Full page views for Crews
│   │   ├── widgets/          # Reusable UI components specific to Crews
│   │   └── crews.dart        # Barrel file
│   ├── jobs/
│   │   ├── ...
│   │   └── jobs.dart
│   └── ...
```

## 2. Barrel File Imports
To reduce import clutter ("import mess"), use **Barrel Files** (`filename.dart`) at the root of each feature directory.

### Rule
- Each feature directory must have a matching dart file (e.g., `crews/crews.dart`) that exports the public API of that feature.
- External files should import the feature via this barrel file, not individual files inside the feature.

### Example
**Bad:**
```dart
import 'package:app/features/crews/models/crew_member.dart';
import 'package:app/features/crews/widgets/crew_card.dart';
```

**Good:**
```dart
import 'package:app/features/crews/crews.dart';
```
