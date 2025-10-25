# Journeyman Jobs - AI Assistant Guidelines

## 🔄 Project Awareness & Context

- **Always read `plan.md`** at the start of a new conversation to understand the project's phases, architecture, and current implementation status.
- **Check for `TASK.md`** before starting work. If it doesn't exist, create it to track tasks with descriptions and dates.
- **Review `guide/screens.md`** for detailed screen specifications and feature requirements.
- **Understand the electrical theme** - This app serves IBEW electrical workers (journeymen, linemen, wiremen, operators, tree trimmers).
- **Use Firebase** for all backend operations (Authentication, Firestore, Storage).

## 🧱 Code Structure & Modularity

- **Follow Flutter's feature-based architecture**:

  ```dart
  lib/
  ├── screens/         # Screen widgets (home/, jobs/, unions/, etc.)
  ├── widgets/         # Reusable components (job_card.dart, union_card.dart)
  ├── services/        # Business logic (job_service.dart, union_service.dart)
  ├── providers/       # State management (job_provider.dart, user_provider.dart)
  ├── models/          # Data models (job_model.dart, union_model.dart, user_model.dart)
  ├── design_system/   # Theme and design components
  ├── electrical_components/ # Electrical-themed UI components
  └── navigation/      # Router configuration (app_router.dart)
  ```

- **Use consistent imports** - Prefer relative imports within the same feature, absolute for cross-feature.
- **Maintain electrical design theme** in all components, animations, and features.

## 📦 Job Model Architecture

**IMPORTANT**: This app uses a **single canonical Job model** with one specialized variant.

### Canonical Job Model (Primary)

**Location**: `lib/models/job_model.dart` (539 lines)
**Usage**: 99% of job operations in the app

```dart
import 'package:journeyman_jobs/models/job_model.dart';

class Job {
  final String company;        // ← Firestore field name
  final double? wage;          // ← Firestore field name
  final int? local;
  final String? classification;
  final String location;
  final Map<String, dynamic> jobDetails;
  // ... 30+ fields total
}
```

**When to Use**:
- ✅ Loading jobs from Firestore
- ✅ Displaying jobs anywhere in the app
- ✅ Job cards, lists, search, filtering
- ✅ Shared jobs in crews feature
- ✅ Job details screens
- ✅ **Default choice for all job operations**

**Schema Details**:
- 30+ fields with comprehensive job information
- Matches Firestore `jobs` collection schema exactly
- Robust parsing handles multiple data formats
- Includes `jobDetails` nested map for compatibility

### CrewJob Model (Specialized - Currently Unused)

**Location**: `lib/features/jobs/models/crew_job.dart` (108 lines)
**Usage**: Reserved for future crew-specific features

```dart
import 'package:journeyman_jobs/features/jobs/models/crew_job.dart';

class CrewJob {
  final String? companyName;   // ← Different field name!
  final double hourlyRate;     // ← Different field name!
  final String title;
  final String description;
  // ... 17 fields total (lightweight)
}
```

**When to Use**:
- ⚠️ **Currently unused** - reserved for future features
- Potential use: Lightweight crew-to-crew job forwarding
- Potential use: Quick job sharing without full details

**Key Differences**:
| Field | Canonical Job | CrewJob |
|-------|---------------|---------|
| Company | `company` | `companyName` |
| Pay | `wage` | `hourlyRate` |
| Fields | 30+ | 17 |
| Source | Firestore | Crew sharing |

### Migration History

**Date**: 2025-10-25
**Action**: Consolidated 3 competing Job models → 1 canonical + 1 specialized

**What Was Fixed**:
- ❌ Deleted `UnifiedJobModel` (239 lines dead code)
- ❌ Fixed naming collision (2 classes named "Job")
- ✅ Established clear model hierarchy
- ✅ Fixed critical SharedJob import bug

**See**: `docs/migrations/JOB_MODEL_CONSOLIDATION_COMPLETE.md` for full details

### Best Practices

**DO**:
- ✅ Use canonical `Job` model by default
- ✅ Import from `lib/models/job_model.dart`
- ✅ Check Firestore schema matches Job model
- ✅ Use `Job.fromJson()` for Firestore data
- ✅ Use `job.toFirestore()` when saving

**DON'T**:
- ❌ Don't use CrewJob unless explicitly needed
- ❌ Don't create new job models without discussion
- ❌ Don't mix field names (company vs companyName)
- ❌ Don't assume all jobs have the same schema

## 🎨 Design System & Theme

- **Primary Colors**: Navy (`#1A202C`) and Copper (`#B45309`)
- **Always use `AppTheme`** constants from `lib/design_system/app_theme.dart`
- **Typography**: Google Fonts Inter with predefined text styles
- **Component Prefix**: Use `JJ` prefix for custom components (e.g., `JJButton`, `JJElectricalLoader`)
- **Electrical Elements**: Incorporate circuit patterns, lightning bolts, and electrical symbols
- **Example Usage**:

  ```dart
  Container(
    color: AppTheme.primaryNavy,
    child: Text(
      'IBEW Local 123',
      style: AppTheme.headingLarge.copyWith(color: AppTheme.accentCopper),
    ),
  )
  ```

## 🧪 Testing & Reliability

- **Create widget tests** for all new screens and components in `/test` directory
- **Test file structure** mirrors `/lib` structure:

  ```tree
  test/
  ├── screens/
  │   ├── jobs/
  │   │   └── jobs_screen_test.dart
  │   └── unions/
  │       └── unions_screen_test.dart
  └── widgets/
      └── job_card_test.dart
  ```

- **Minimum test coverage**:
  - Widget rendering test
  - User interaction test (taps, swipes)
  - State management test
  - Error handling test
- **Example test**:

  ```dart
  testWidgets('JobCard displays job details correctly', (tester) async {
    await tester.pumpWidget(MaterialApp(
      home: JobCard(job: mockJob),
    ));
    
    expect(find.text('IBEW Local 123'), findsOneWidget);
    expect(find.byIcon(Icons.location_on), findsOneWidget);
  });
  ```

## ✅ Task Completion

- **Update `TASK.md`** with:

  ```markdown
  ## In Progress
  - [ ] Implement unions screen with local directory - Started: 2025-02-01
  
  ## Completed
  - [x] Create navigation infrastructure - Completed: 2025-01-31
  - [x] Design job card component - Completed: 2025-01-30
  
  ## Discovered During Work
  - [ ] Need to add offline caching for union data
  - [ ] Performance optimization needed for large job lists
  ```

## 📎 Flutter & Dart Conventions

- **Use Flutter 3.x** features and null safety
- **State Management**: Provider pattern (already configured)
- **Navigation**: go_router for type-safe routing
- **Firebase Integration**: Use FlutterFire packages
- **Async Operations**: Always handle loading and error states
- **Context7** - Use the Context7 MCP server tool to quickly reference the most up-to-date and accurate Flutter best practices
- **Code Style**:

  ```dart
  /// Fetches jobs based on user preferences.
  /// 
  /// Returns a list of [JobModel] sorted by relevance.
  /// Throws [FirebaseException] if network fails.
  Future<List<JobModel>> fetchPersonalizedJobs({
    required String userId,
    int limit = 20,
  }) async {
    try {
      // Implementation
    } catch (e) {
      // Error handling
    }
  }
  ```

## 📚 Documentation & Comments

- **Update `README.md`** when adding features or changing setup
- **Document Firebase collections** and their schemas
- **Widget documentation example**:
- **With every modification, addition, or iteration of any function, method, backend query, navigation, or action,
      ALWAYS include sufficiant and descriptive commenting and documentation that easily explains the code blocks purpose, functionality, and or action**

  ```dart
  /// A card displaying IBEW union local information.
  /// 
  /// Shows local number, address, and classifications.
  /// Tapping opens full details in [LocalDetailScreen].
  class UnionCard extends StatelessWidget {
    /// The union local data to display
    final UnionModel union;
    
    /// Callback when card is tapped
    final VoidCallback? onTap;
    
    const UnionCard({
      Key? key,
      required this.union,
      this.onTap,
    }) : super(key: key);
  ```

## 🔌 Electrical Theme Implementation

- **Circuit Patterns**: Use `CircuitPatternPainter` for backgrounds
- **Lightning Effects**: Apply `LightningAnimation` for loading states
- **Icons**: Prefer electrical-themed icons (bolt, plug, circuit)
- **Animations**: Use `flutter_animate` with electrical motifs
- **Example**:

  ```dart
  Container(
    decoration: BoxDecoration(
      gradient: AppTheme.splashGradient,
    ),
    child: Stack(
      children: [
        const CircuitPatternBackground(),
        Center(
          child: JJElectricalLoader(
            size: 80,
            color: AppTheme.accentCopper,
          ),
        ),
      ],
    ),
  )
  ```

## 🧠 AI Behavior Rules

- **Never assume Firebase structure** - Always check existing collections and documents
- **Respect union data sensitivity** - Handle IBEW local information professionally
- **Mobile-first approach** - Design for phones first, tablets second
- **Offline capability** - Critical features (union directory) must work offline
- **Performance matters** - Large lists (797+ locals) need optimization
- **DO NOT USE ".withValues(alpha: ) INSTEAD USE .withValues(alpha: )"**
- **Ask for clarification** on:
  - Firebase collection schemas if not documented
  - Specific IBEW terminology or classifications
  - Storm work vs regular job postings requirements
  - Union-specific features or data handling

## 🚀 Project-Specific Features

- **Job Aggregation**: Scraping from legacy union job boards
- **Bid System**: Users can bid on jobs through the app
- **Storm Work**: Users can browse through a comprehensive list of storm contractors and to access thier storm roster sign-up method,
       locate contractor show-ups, and track up-to-date outage information as well as access an interactive radar
- **Union Directory**: 797+ IBEW locals with contact integration
- **Weather Integration**:
  - NOAA radar and alerts for storm tracking
  - National Hurricane Center data
  - Storm Prediction Center outlooks
  - Location-based weather warnings
- **Classification Filtering**:
  - Inside Wireman
  - Journeyman Lineman
  - Tree Trimmer
  - Equipment Operator
  - Inside Journeyman Electrician
- **Construction Types**:
  - Commercial
  - Industrial
  - Residential
  - Utility
  - Maintenance

## 🌦️ Weather Integration Guidelines

- **NOAA Services**: Use official government weather data (no API keys needed)
  - National Weather Service API: `api.weather.gov`
  - NOAA Radar: `radar.weather.gov`
  - Hurricane Center: `nhc.noaa.gov`
- **Location Permissions**: Always request gracefully with clear explanations
- **Weather Alerts**: Filter for events relevant to electrical work
- **Safety First**: Integrate weather warnings with worker safety protocols
- **Caching**: Cache weather data for offline access during storms

## 📍 Location Services

- **Permission Handling**: Use `geolocator` package with proper fallbacks
- **Privacy**: Only use location for weather and job matching
- **Accuracy**: High accuracy for weather radar, balanced for job search
- **Background**: No background location tracking without explicit consent

## 🔐 Security & Privacy

- **Protect PII**: Never log personal information (ticket numbers, SSN)
- **Secure API Keys**: Use environment variables for sensitive data
- **Firebase Rules**: Ensure proper read/write permissions
- **Union Data**: Some local information may be member-only
- **Location Data**: Never store or transmit without encryption
