---
name: jj-dependency-resolver
description: Resolve and sequence cross-domain dependencies in Journeyman Jobs development. Analyzes task dependencies between Flutter, Riverpod, Firebase, and Debug domains. Creates dependency graphs, detects circular dependencies, determines optimal execution order. Use when coordinating multi-phase features or managing complex inter-domain relationships.
---

# JJ Dependency Resolver

## Purpose

Analyze and sequence inter-domain dependencies to ensure correct execution order and prevent coordination failures.

## When To Use

- Multi-phase feature development
- Cross-domain dependencies (State needs Backend, UI needs State)
- Parallel work planning
- Integration sequencing
- Deadlock detection

## Dependency Patterns

### Common Dependency Chain
```
Firebase (Data Layer)
    ↓
Riverpod (State Layer)
    ↓
Flutter (UI Layer)
    ↓
Debug (Testing Layer)
```

### Parallel Execution Opportunities
```
Independent Tracks:
├─ Firebase: Set up collections
├─ Flutter: Build UI mockups (with mock data)
└─ Debug: Write test scaffolds

Convergence: Integration phase
```

## Analysis Framework

### Step 1: Identify Dependencies
For each task, determine:
- **Requires**: What must exist before this task
- **Provides**: What this task creates
- **Blocks**: What tasks cannot proceed without this

Example:
```
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
```
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
- **Circular dependencies**: A → B → A
- **Missing dependencies**: Task requires non-existent resource
- **Deadlocks**: Tasks mutually blocking each other

### Step 4: Determine Sequence
Create optimal execution order:
1. Tasks with no dependencies (start immediately)
2. Tasks depending only on (1)
3. Tasks depending on (1) or (2)
4. Continue until all tasks sequenced

## Dependency Types

### Hard Dependencies (Blocking)
Must complete before next task:
```
HARD: Firebase collection structure → Riverpod provider
REASON: Provider needs exact field names and types
```

### Soft Dependencies (Informative)
Helpful but not required:
```
SOFT: UI mockup → Riverpod state design
REASON: Seeing UI helps design state, but not strictly required
```

### Circular Dependencies (Error)
Impossible to resolve:
```
ERROR: Flutter needs Riverpod → Riverpod needs Flutter
SOLUTION: Identify true dependency direction, create interface
```

## Resolution Strategies

### Strategy 1: Sequential Execution
When dependencies are linear:
```
Phase 1: Firebase (foundation)
  ↓ (wait)
Phase 2: Riverpod (state)
  ↓ (wait)
Phase 3: Flutter (UI)
  ↓ (wait)
Phase 4: Debug (testing)
```

### Strategy 2: Parallel with Convergence
When tasks are independent:
```
Parallel:
├─ Firebase: Set up auth
├─ Flutter: Build login UI (mock auth)
└─ Riverpod: Design auth state

Convergence:
└─ Integrate: Wire auth flow together
```

### Strategy 3: Progressive Building
For complex features:
```
Iteration 1: Basic functionality
├─ Firebase: Simple job queries
├─ Riverpod: Basic job list provider
└─ Flutter: Simple job list

Iteration 2: Add features
├─ Firebase: Add filters, pagination
├─ Riverpod: Add filter state
└─ Flutter: Add filter UI
```

### Strategy 4: Interface-First
For unclear dependencies:
```
Step 1: Define interfaces
├─ Firebase: API contract (what Firestore returns)
├─ Riverpod: Provider interface (what Flutter expects)
└─ Flutter: Widget contracts (what props needed)

Step 2: Implement against interfaces
└─ All domains can work in parallel
```

## Journeyman Jobs Specific Patterns

### Job Aggregation Feature
```
DEPENDENCY GRAPH:

[Firebase: Job scraping service]
    ↓
[Firebase: jobs collection + indexes]
    ↓
[Riverpod: JobsProvider + filtering]
    ↓ 
[Flutter: JobListScreen + JobCard]
    ↓
[Debug: Job list integration tests]

PARALLEL OPPORTUNITIES:
- Firebase scraping + UI mockups (independent)
- Riverpod provider design + Firebase schema design (can inform each other)
```

### Crews Feature
```
DEPENDENCY GRAPH:

Phase 1 (Foundation):
[Firebase: crew tables] ──┐
[Firebase: invite logic] ──┤
                           ├→ [Riverpod: Crew state]
[Firebase: security rules]─┘
                           ↓
                    [Flutter: Crew UI]
                           ↓
                    [Debug: Crew tests]

CRITICAL PATH:
Firebase tables must exist before Riverpod providers
```

### Offline Support
```
DEPENDENCY GRAPH:

[Firebase: Persistence config] ──┐
                                  ├→ [Riverpod: Offline state]
[Riverpod: Connectivity service]─┘
                                  ↓
                           [Flutter: Offline UI]
                                  ↓
                           [Debug: Offline tests]

NOTE: Offline state depends on BOTH Firebase config AND connectivity
```

## Conflict Detection

### Circular Dependency Example
```
DETECTED:
- Flutter needs Riverpod provider
- Riverpod provider needs Flutter widget

ANALYSIS:
This is impossible - who creates what?

RESOLUTION:
1. Identify true direction: Riverpod provides data, Flutter consumes
2. Break cycle: Riverpod defines interface, Flutter implements
3. Sequence: Riverpod first, then Flutter
```

### Missing Dependency Example
```
DETECTED:
- Flutter wants to display job details
- No JobDetailsProvider exists
- No Job model defined

RESOLUTION:
1. Add missing tasks: Create Job model, Create JobDetailsProvider
2. Sequence: Model → Provider → UI
3. Update coordination plan
```

### Deadlock Example
```
DETECTED:
- Firebase waiting for Riverpod to define state structure
- Riverpod waiting for Firebase to define data structure

RESOLUTION:
1. Neither can proceed alone
2. Solution: Joint design session to define interface
3. Once interface agreed, both can work in parallel
```

## Best Practices

### Early Dependency Mapping
Map dependencies BEFORE starting work:
- Prevents rework
- Identifies parallel opportunities
- Surfaces issues early

### Document Assumptions
Make implicit dependencies explicit:
```
ASSUMPTION: Job model will have 'location' field
DEPENDENCY: UI component needs location for map display
RISK: If assumption wrong, UI rework required
```

### Interface-Driven Design
Define interfaces before implementation:
- Reduces coupling
- Enables parallel work
- Makes testing easier

### Incremental Validation
Validate dependencies at each phase:
```
✓ Phase 1 complete: Verify Firestore structure
✓ Phase 2 complete: Test provider queries
✓ Phase 3 complete: UI integration check
```

## Integration with Master Coordinator

The dependency resolver supports the master coordinator by:
1. Analyzing coordination plans for dependency issues
2. Suggesting optimal execution sequences
3. Identifying parallel work opportunities
4. Detecting potential deadlocks early

The master coordinator uses these analyses to create effective coordination plans.
