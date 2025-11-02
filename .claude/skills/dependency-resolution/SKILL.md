---
name: dependency-resolution
description: Analyzes cross-domain task dependencies in Journeyman Jobs development. Creates dependency graphs, detects circular dependencies, sequences execution order, identifies parallel work opportunities. Critical for multi-phase features across Flutter, Riverpod, Firebase, and Debug domains.
---

# Dependency Resolution

## Purpose

Analyze and sequence inter-domain dependencies to ensure correct execution order, prevent coordination failures, and maximize parallel execution opportunities.

## When To Use

- Multi-phase feature development
- Cross-domain dependencies (State needs Backend, UI needs State)
- Parallel work planning  
- Integration sequencing
- Deadlock detection
- Circular dependency issues

## Dependency Patterns

### Common Dependency Chain

```dart
Firebase (Data Layer)
    ↓
Riverpod (State Layer)
    ↓
Flutter (UI Layer)
    ↓
Debug (Testing Layer)
```

### Parallel Execution Opportunities

```dart
Independent Tracks:
├─ Firebase: Set up collections
├─ Flutter: Build UI mockups (with mock data)
└─ Debug: Write test scaffolds

Convergence: Integration phase
```

## Analysis Framework

### Step 1: Identify Dependencies

For each task, determine:

- **Requires**: What must exist before this task starts
- **Provides**: What this task creates for others
- **Blocks**: What tasks cannot proceed without this

**Example**:

```dart
Task: Create JobDetailsProvider (Riverpod)

REQUIRES:
- Job model definition (Firebase schema)
- Firestore jobs collection structure

PROVIDES:
- JobDetailsProvider for UI consumption
- Job state management logic

BLOCKS:
- JobDetailsScreen widget (Flutter)
- Job detail tests (Debug)
```

### Step 2: Build Dependency Graph

Map relationships between tasks:

```dart
[Firebase: Job Model] 
    ↓
[Riverpod: JobDetailsProvider]
    ↓
[Flutter: JobDetailsScreen]
    ↓
[Debug: Job Detail Tests]
```

### Step 3: Detect Issues

Check for problems:

- **Circular dependencies**: A → B → A (impossible to resolve)
- **Missing dependencies**: Task requires non-existent resource
- **Deadlocks**: Tasks mutually blocking each other
- **Implicit dependencies**: Undocumented assumptions

### Step 4: Determine Sequence

Create optimal execution order:

1. **Level 0**: Tasks with no dependencies (start immediately)
2. **Level 1**: Tasks depending only on Level 0
3. **Level 2**: Tasks depending on Level 0 or Level 1
4. **Level N**: Continue until all tasks sequenced

## Dependency Types

### Hard Dependencies (Blocking)

Must complete before next task can start:

```dart
HARD: Firebase collection structure → Riverpod provider
REASON: Provider needs exact field names and types
ACTION: Sequential execution required
```

### Soft Dependencies (Informative)

Helpful but not strictly required:

```dart
SOFT: UI mockup → Riverpod state design
REASON: Seeing UI helps inform state design, but not blocking
ACTION: Can proceed in parallel, reconverge for integration
```

### Circular Dependencies (Error)

Impossible to resolve without intervention:

```dart
ERROR: Flutter needs Riverpod → Riverpod needs Flutter
REASON: Mutual blocking - neither can proceed
SOLUTION: Identify true dependency direction or create interface
```

## Resolution Strategies

### Strategy 1: Sequential Execution

When dependencies are strictly linear:

```dart
Phase 1: Firebase (foundation)
  ↓ (wait for completion)
Phase 2: Riverpod (state layer)
  ↓ (wait for completion)
Phase 3: Flutter (UI layer)
  ↓ (wait for completion)
Phase 4: Debug (testing layer)

TIMELINE: Serial - each phase waits for previous
BENEFIT: Simple, no coordination complexity
DRAWBACK: Longer overall timeline
```

### Strategy 2: Parallel with Convergence

When tasks have independent dependencies:

```dart
PARALLEL TRACKS:
├─ Firebase: Set up auth
├─ Flutter: Build login UI (mock auth)
└─ Riverpod: Design auth state

CONVERGENCE POINT:
└─ Integrate: Wire real auth flow together

TIMELINE: Parallel - all tracks start simultaneously
BENEFIT: Faster completion
DRAWBACK: Integration phase critical
```

### Strategy 3: Progressive Building

For complex features with multiple iterations:

```dart
ITERATION 1: Minimum viable functionality
├─ Firebase: Simple job queries
├─ Riverpod: Basic job list provider
└─ Flutter: Simple job list

ITERATION 2: Add features incrementally
├─ Firebase: Add filters, pagination
├─ Riverpod: Add filter state, pagination logic
└─ Flutter: Add filter UI, infinite scroll

TIMELINE: Iterative - working feature at each iteration
BENEFIT: Early validation, reduced risk
DRAWBACK: More coordination checkpoints
```

### Strategy 4: Interface-First

For unclear or evolving dependencies:

```dart
STEP 1: Define interfaces (contracts)
├─ Firebase: API contract (what Firestore returns)
├─ Riverpod: Provider interface (what Flutter expects)
└─ Flutter: Widget contracts (what props needed)

STEP 2: Implement against interfaces
└─ All domains work in parallel

STEP 3: Integration
└─ Wire implementations together

TIMELINE: Parallel after interface agreement
BENEFIT: Maximum parallelization, clear contracts
DRAWBACK: Requires upfront design coordination
```

## Journeyman Jobs Specific Patterns

### Job Aggregation Feature

```dart
DEPENDENCY GRAPH:

[Firebase: Job scraping Cloud Function]
    ↓
[Firebase: jobs collection + composite indexes]
    ↓
[Riverpod: JobsProvider + FilterProvider]
    ↓ 
[Flutter: JobListScreen + OptimizedJobCard]
    ↓
[Debug: Job list integration tests]

PARALLEL OPPORTUNITIES:
- Firebase scraping logic + Flutter UI mockups (independent)
- Riverpod provider architecture + Firebase schema design (soft dependency)

CRITICAL PATH:
Firebase jobs collection → Riverpod providers → Flutter widgets
```

### Crews Feature

```dart
DEPENDENCY GRAPH:

PHASE 1 (Foundation):
[Firebase: crews collection] ──┐
[Firebase: crew_members collection] ──┤
[Firebase: crew_invitations collection] ──┤
[Firebase: security rules] ──┤
                              ├→ [Riverpod: Crew state management]
[Firebase: Cloud Functions] ──┘
                              ↓
                       [Flutter: Crew UI components]
                              ↓
                       [Debug: Crew integration tests]

CRITICAL PATH:
All Firebase collections + rules must exist before Riverpod providers

PARALLEL OPPORTUNITY:
- Firebase Cloud Functions can develop in parallel with Riverpod providers
- Flutter mockups can start before Riverpod (using mock data)
```

### Offline Support

```dart
DEPENDENCY GRAPH:

[Firebase: Persistence config] ──┐
                                  ├→ [Riverpod: Offline state management]
[Riverpod: Connectivity service]─┘
                                  ↓
                           [Flutter: Offline indicators + retry UI]
                                  ↓
                           [Debug: Offline scenario tests]

NOTE: 
Offline state has TWO hard dependencies:
1. Firebase persistence configuration
2. Connectivity monitoring service

SEQUENCING:
1. Firebase persistence + Connectivity service (parallel)
2. Offline state management (waits for both #1)
3. UI + Testing (waits for #2)
```

### Hierarchical Initialization

```dart
DEPENDENCY GRAPH:

LEVEL 0 (No dependencies):
├─ Firebase Core initialization
├─ Local storage initialization
└─ Error manager initialization

LEVEL 1 (Depends on Level 0):
├─ Firebase Auth initialization
├─ Connectivity service
└─ Analytics initialization

LEVEL 2 (Depends on Level 1):
├─ User session management
├─ App settings service
└─ Notification permissions

LEVEL 3 (Depends on Level 2):
├─ Firestore service initialization
├─ User data loading
└─ App state hydration

LEVEL 4 (Depends on Level 3):
└─ UI ready state

SEQUENCING: Strictly sequential by level, parallel within level
```

## Conflict Detection

### Circular Dependency Example

```dart
DETECTED CYCLE:
- Flutter JobDetailsScreen needs JobDetailsProvider
- JobDetailsProvider needs JobDetailsScreen.preferredFields

ANALYSIS:
Impossible - who defines preferred fields first?

ROOT CAUSE:
Provider trying to adapt to UI instead of UI consuming provider state

RESOLUTION:
1. Identify true direction: Riverpod provides data, Flutter consumes
2. Break cycle: JobDetailsProvider defines available data
3. Flutter reads available data and displays what's present
4. Sequence: Riverpod first, then Flutter

FIXED DEPENDENCY:
JobDetailsProvider → JobDetailsScreen ✓
```

### Missing Dependency Example

```dart
DETECTED ISSUE:
- Flutter JobDetailsScreen wants to display job details
- No JobDetailsProvider exists
- No Job model defined

ANALYSIS:
Cannot build UI without state layer

RESOLUTION:
1. Add missing tasks:
   - Create Job model (Firebase domain)
   - Create JobDetailsProvider (Riverpod domain)
2. Update sequence:
   Job model → JobDetailsProvider → JobDetailsScreen
3. Update coordination plan with new tasks
```

### Deadlock Example

```dart
DETECTED DEADLOCK:
- Firebase team waiting for Riverpod to define state structure
- Riverpod team waiting for Firebase to define data structure

ANALYSIS:
Mutual blocking - neither can proceed without the other

ROOT CAUSE:
No agreed interface between domains

RESOLUTION:
1. Pause both teams
2. Joint design session to define data/state interface
3. Document interface contract
4. Once agreed, both teams proceed in parallel
5. Integration phase to wire together

TIMELINE:
Design session (1 day) → Parallel work (3 days) → Integration (1 day)
```

## Best Practices

### 1. Early Dependency Mapping

Map dependencies BEFORE starting implementation work:

**Benefits**:

- Prevents rework from wrong sequencing
- Identifies parallel work opportunities early
- Surfaces blocking issues before they block
- Enables accurate timeline estimation

**When**: During feature planning and task breakdown

### 2. Document Assumptions

Make implicit dependencies explicit:

```dart
EXAMPLE:

ASSUMPTION: Job model will have 'location' field with LatLng type
DEPENDENCY: JobCardMap component needs location for map display
RISK: If assumption wrong, UI component rework required
VALIDATION: Confirm with Firebase team before starting UI work
```

### 3. Interface-Driven Design

Define clear interfaces before implementation:

**Benefits**:

- Reduces coupling between domains
- Enables parallel work safely
- Makes testing easier (mock interfaces)
- Documents contracts explicitly

**Example**:

```dart
// Interface defined first
abstract class JobProvider {
  Stream<List<Job>> watchJobs(FilterCriteria filters);
  Future<Job?> getJobById(String id);
  Future<void> favoriteJob(String id);
}

// Firebase and Riverpod teams can now work in parallel
```

### 4. Incremental Validation

Validate dependencies at each phase completion:

```dart
✓ Phase 1 complete: 
  - Verify Firestore structure matches provider expectations
  - Test sample queries return expected shape
  
✓ Phase 2 complete: 
  - Test provider methods with real Firebase data
  - Verify state updates propagate correctly
  
✓ Phase 3 complete: 
  - UI integration test with real providers
  - Verify data flows end-to-end
```

### 5. Version Dependencies

Track which version of dependencies are required:

```dart
EXAMPLE:

Task: Build JobCardV2 widget
REQUIRES:
  - Job model v2.0+ (with 'payRate' field)
  - JobsProvider v1.5+ (with filtering support)
  
If older versions present, widget will fail at runtime.
Document version requirements explicitly.
```

## Integration with Task Distributor

The dependency resolution skill is used by the Task Distributor agent to:

1. **Analyze** feature breakdowns for dependency chains
2. **Detect** circular dependencies and conflicts early
3. **Sequence** tasks in optimal execution order
4. **Identify** parallel work opportunities
5. **Validate** coordination plans before execution
6. **Recommend** resolution strategies for conflicts

The Task Distributor uses this skill to create executable, well-sequenced task plans that prevent coordination failures and maximize development velocity.
