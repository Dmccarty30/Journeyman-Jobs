# Parallel Execution Plan - Journeyman Jobs

**Generated:** 2025-10-24
**Strategy:** Multi-agent parallel execution for maximum efficiency
**Coordination:** Task-based agent specialization with dependency management

---

## 🎯 Execution Strategy

### Wave 1: Independent Critical Fixes (Parallel)

**Duration:** 2-3 days
**Agents:** 4 concurrent
**Dependencies:** None - all tasks can execute in parallel

### Wave 2: Dependent Features (Sequential within parallel streams)

**Duration:** 3-4 days
**Agents:** 3 concurrent
**Dependencies:** Requires Wave 1 completion

### Wave 3: UX Enhancements (Parallel)

**Duration:** 2-3 days
**Agents:** 3 concurrent
**Dependencies:** Partial - some require Wave 2

### Wave 4: Polish & Optimization (Parallel)

**Duration:** 2-3 days
**Agents:** 2-3 concurrent
**Dependencies:** None for most tasks

---

## 🌊 Wave 1: Critical Fixes (PARALLEL EXECUTION)

### Agent Stream A: Database Optimizer

**Primary Agent:** database-optimizer
**Tasks:** 2 critical tasks
**Total Effort:** 7-9 hours

#### Task 4.2: Fix Firestore Index for Suggested Jobs [P1]

- **Priority:** 🔴 Critical
- **Blocking:** Task 4.3
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/providers/jobs_riverpod_provider.dart`, Firebase Console
- **Deliverables:**
  - Firestore composite index created
  - Query optimized for index usage
  - Error handling implemented
  - Debug logs added

#### Task 10.7: Implement User Preferences Firestore Persistence [P1]

- **Priority:** 🔴 Critical
- **Blocking:** Settings screen functionality
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/widgets/dialogs/user_job_preferences_dialog.dart`, `lib/models/user_model.dart`
- **Deliverables:**
  - User document schema implemented
  - Firestore write operation working
  - Data validation added
  - Success/error notifications

---

### Agent Stream B: Auth Expert

**Primary Agent:** auth-expert
**Tasks:** 1 critical task
**Total Effort:** 8-12 hours

#### Task 1.1: Implement Session Grace Period System [P1]

- **Priority:** 🔴 Critical
- **Blocking:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/services/auth_service.dart`, `lib/providers/auth_provider.dart`
- **Deliverables:**
  - Idle detection system
  - 5-minute grace period timer
  - Activity reset mechanism
  - Warning notifications at 4-minute mark
  - Cross-platform session handling

---

### Agent Stream C: Flutter Expert #1

**Primary Agent:** flutter-expert
**Tasks:** 1 critical task
**Total Effort:** 3-5 hours

#### Task 6.1: Fix Contractor Cards Display [P1]

- **Priority:** 🔴 Critical
- **Blocking:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/screens/storm/storm_screen.dart`
- **Deliverables:**
  - Root cause identified
  - Contractor data loading fixed
  - Widget rendering corrected
  - Loading/error states added

---

### Agent Stream D: Database Optimizer + Auth Expert

**Primary Agent:** database-optimizer
**Support Agent:** auth-expert
**Tasks:** 1 critical task
**Total Effort:** 3-4 hours

#### Task 8.1: Fix Crew Preferences Save Error [P1]

- **Priority:** 🔴 Critical
- **Blocking:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/widgets/dialogs/user_job_preferences_dialog.dart`
- **Deliverables:**
  - Firestore write operation debugged
  - Permission issues resolved
  - Error logging implemented
  - Success feedback working

---

## 🌊 Wave 2: High Priority Features (PARALLEL WITH DEPENDENCIES)

**Wait for:** Task 4.2 completion before starting Task 4.3

### Agent Stream A: Flutter Expert + Database Optimizer

**Primary Agent:** flutter-expert
**Support Agent:** database-optimizer
**Tasks:** 2 tasks
**Total Effort:** 7-10 hours

#### Task 4.3: Implement Missing Methods for Suggested Jobs [P2]

- **Priority:** 🔴 Critical
- **Dependencies:** ✅ Task 4.2 must complete first
- **Parallel Safe:** ⚠️ No - waits for Task 4.2
- **Files:** `lib/providers/jobs_riverpod_provider.dart`, `docs/plans/MISSING_METHODS_IMPLEMENTATION.dart`
- **Deliverables:**
  - `loadSuggestedJobs()` implemented
  - Preference-based filtering working
  - Query performance optimized
  - Offline caching added

#### Task 4.1: Fix Home Screen User Name Display [P2]

- **Priority:** 🟢 High
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/screens/storm/home_screen.dart`
- **Deliverables:**
  - First/last name extraction from user document
  - Greeting text updated
  - Null handling implemented

---

### Agent Stream B: Flutter Expert #2

**Primary Agent:** flutter-expert
**Tasks:** 2 tasks
**Total Effort:** 2-3 hours

#### Task 7.1: Fix Tailboard Screen Overflow Error [P2]

- **Priority:** 🟢 High
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/features/crews/screens/tailboard_screen.dart:357`
- **Deliverables:**
  - Row overflow fixed
  - Responsive layout verified
  - Multi-device testing completed

#### Task 5.1: Apply Title Case to Job Details Dialog [P2]

- **Priority:** 🟡 Medium
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/screens/storm/jobs_screen.dart`
- **Deliverables:**
  - Title case formatter applied
  - Consistency with job cards verified

---

## 🌊 Wave 3: UX Enhancements (PARALLEL EXECUTION)

### Agent Stream A: Database Optimizer + Flutter Expert

**Primary Agent:** database-optimizer
**Support Agent:** flutter-expert
**Tasks:** 2 tasks
**Total Effort:** 8-10 hours

#### Task 8.2: Implement Feed Tab Message Display [P3]

- **Priority:** 🟢 High
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** Crew feed components
- **Deliverables:**
  - Firestore write for messages
  - Real-time listener implemented
  - Optimistic UI updates
  - Message ordering by timestamp

#### Task 8.3: Implement Chat Tab Message Display [P3]

- **Priority:** 🟢 High
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** Crew chat components
- **Deliverables:**
  - Firestore write for chat messages
  - Real-time listener implemented
  - Chat UI updates
  - Auto-scroll to latest message

---

### Agent Stream B: Flutter Expert

**Primary Agent:** flutter-expert
**Tasks:** 1 task
**Total Effort:** 6-8 hours

#### Task 2.1: Implement Dark Mode Theme [P3]

- **Priority:** 🟡 Medium
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/design_system/app_theme.dart`, all screens
- **Deliverables:**
  - Dark mode color palette
  - Theme switching mechanism
  - Theme persistence
  - WCAG AA compliance verification

---

## 🌊 Wave 4: Polish & Optimization (PARALLEL EXECUTION)

### Agent Stream A: Flutter Expert

**Primary Agent:** flutter-expert
**Tasks:** Multiple UI polish tasks
**Total Effort:** 6-8 hours

#### Tasks (All Parallel Safe)

- Task 3.1: Remove dark mode from onboarding (2-3 hours)
- Task 10.1: Remove welcome message from settings (15 min)
- Task 10.2: Fix preferences dialog overflow (1 hour)
- Task 10.3-10.6: Settings screen refinements (2-3 hours)
- Task 11.1-11.3: Resources screen links (3-4 hours)

---

### Agent Stream B: Database Optimizer + Flutter Expert

**Primary Agent:** database-optimizer
**Support Agent:** flutter-expert
**Tasks:** 1 task
**Total Effort:** 4-6 hours

#### Task 9.1: Optimize Locals Screen Performance [P4]

- **Priority:** 🟡 Medium
- **Dependencies:** None
- **Parallel Safe:** ✅ Yes
- **Files:** `lib/screens/storm/locals_screen.dart`
- **Deliverables:**
  - Virtualized list rendering
  - Pagination/lazy loading
  - Search optimization
  - Offline caching

---

## 📊 Execution Metrics

### Total Timeline: 9-13 days

- **Wave 1:** 2-3 days (parallel)
- **Wave 2:** 3-4 days (partial parallel)
- **Wave 3:** 2-3 days (parallel)
- **Wave 4:** 2-3 days (parallel)

### Agent Utilization

- **database-optimizer:** 7 tasks (30 hours)
- **flutter-expert:** 13 tasks (36 hours)
- **auth-expert:** 3 tasks (12 hours)

### Parallelization Benefits

- **Sequential Execution:** ~78 hours (16 days @ 5hr/day)
- **Parallel Execution:** ~72 hours (9-13 days)
- **Time Savings:** ~3-7 days (25-45% faster)

---

## 🔗 Dependency Graph

```markdown
Wave 1 (All Parallel)
├─ Task 4.2 (Firestore Index) → Blocks Task 4.3
├─ Task 10.7 (Preferences Persistence) → Independent
├─ Task 1.1 (Session Grace Period) → Independent
├─ Task 6.1 (Contractor Cards) → Independent
└─ Task 8.1 (Crew Preferences Save) → Independent

Wave 2 (Parallel with dependency)
├─ Task 4.3 (Suggested Jobs) → Waits for Task 4.2
├─ Task 4.1 (User Name Display) → Independent
├─ Task 7.1 (Tailboard Overflow) → Independent
└─ Task 5.1 (Title Case) → Independent

Wave 3 (All Parallel)
├─ Task 8.2 (Feed Messages) → Independent
├─ Task 8.3 (Chat Messages) → Independent
└─ Task 2.1 (Dark Mode) → Independent

Wave 4 (All Parallel)
├─ Settings UI Polish (6 tasks) → Independent
├─ Resources Links (3 tasks) → Independent
└─ Task 9.1 (Locals Optimization) → Independent
```

---

## 🚦 Coordination Protocol

### Communication Between Agents

- **Shared Context:** TASK.md, PARALLEL_EXECUTION_PLAN.md
- **Status Updates:** Mark tasks as in_progress/completed in TASK.md
- **Conflict Resolution:** File-level locking (no two agents edit same file)
- **Code Integration:** Git branches per wave, merge after wave completion

### Quality Gates

- Each task must pass acceptance criteria before completion
- Wave completion requires all tasks in wave to pass
- Integration testing between waves
- Performance regression testing after Wave 3 & 4

### Risk Mitigation

- **Blocker Detection:** Daily check for blocked tasks
- **Resource Conflicts:** File-level task assignment prevents conflicts
- **Dependency Failures:** Task 4.3 has fallback if Task 4.2 delayed
- **Quality Issues:** Each agent runs tests before marking complete

---

## 🎯 Success Criteria

### Wave 1 Success

- ✅ All 4 critical bugs fixed
- ✅ Firestore index operational
- ✅ Session grace period working
- ✅ Preferences saving to Firestore

### Wave 2 Success

- ✅ Suggested jobs displaying correctly
- ✅ User name showing on home screen
- ✅ All layout overflow errors resolved

### Wave 3 Success

- ✅ Real-time messaging working (feed & chat)
- ✅ Dark mode implemented and accessible

### Wave 4 Success

- ✅ All UI polish completed
- ✅ Performance optimized for 797+ locals
- ✅ All external links functional

### Overall Success

- ✅ 23/23 tasks completed
- ✅ All acceptance criteria met
- ✅ Integration tests passing
- ✅ No regressions introduced
- ✅ Performance benchmarks achieved
