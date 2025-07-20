# Journeyman Jobs - AI Assistant Guidelines

## 🔄 Project Awareness & Context

- **Always read `plan.md`** at the start of a new conversation to understand the project's phases, architecture, and current implementation status.
- **Check for `TASK.md`** before starting work. If it doesn't exist, create it to track tasks with descriptions and dates.
- **Review `guide/screens.md`** for detailed screen specifications and feature requirements.
- **Understand the electrical theme** - This app serves IBEW electrical workers (journeymen, linemen, wiremen, operators, tree trimmers).
- **Use Firebase** for all backend operations (Authentication, Firestore, Storage).

## 🧱 Code Structure & Modularity

- **Follow Flutter's feature-based architecture**:

  ```tree
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
- **Ask for clarification** on:
  - Firebase collection schemas if not documented
  - Specific IBEW terminology or classifications
  - Storm work vs regular job postings requirements
  - Union-specific features or data handling

## 🚀 Project-Specific Features

- **Job Aggregation**: Scraping from legacy union job boards
- **Bid System**: Users can bid on jobs through the app
- **Storm Work**: Emergency restoration jobs get priority highlighting
- **Union Directory**: 797+ IBEW locals with contact integration
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

## 🔐 Security & Privacy

- **Protect PII**: Never log personal information (ticket numbers, SSN)
- **Secure API Keys**: Use environment variables for sensitive data
- **Firebase Rules**: Ensure proper read/write permissions
- **Union Data**: Some local information may be member-only
