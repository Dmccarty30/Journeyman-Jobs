<!-- OPENSPEC:START -->
# OpenSpec Instructions

These instructions are for AI assistants working in this project.

Always open `@/openspec/AGENTS.md` when the request:
- Mentions planning or proposals (words like proposal, spec, change, plan)
- Introduces new capabilities, breaking changes, architecture shifts, or big performance/security work
- Sounds ambiguous and you need the authoritative spec before coding

Use `@/openspec/AGENTS.md` to learn:
- How to create and apply change proposals
- Spec format and conventions
- Project structure and guidelines

Keep this managed block so 'openspec update' can refresh the instructions.

<!-- OPENSPEC:END -->

# Journeyman Jobs - AI Assistant & Workflow Guidelines

> **Comprehensive guide for AI assistants working on Journeyman Jobs, covering project context, architecture, task management, and development standards.**

---

## 🎯 Overview

This guide provides complete instructions for AI assistants contributing to **Journeyman Jobs**, a Flutter mobile application serving electrical industry workers, particularly IBEW members. The app functions as a comprehensive directory and job matching platform for traveling electrical workers.

---

## 🔄 Project Awareness & Context

### Essential Project Files

- **Always read `plan.md`** at the start of a new conversation to understand the project's phases, architecture, and current implementation status.
- **Check for `TASK.md`** before starting work. If it doesn't exist, create it to track tasks with descriptions and dates.
- **Review `guide/screens.md`** for detailed screen specifications and feature requirements.

### Project Identity

- **Target Users**: IBEW electrical workers (journeymen, linemen, wiremen, operators, tree trimmers)
- **Backend**: Firebase (Authentication, Firestore, Storage)
- **State Management**: Riverpod/Provider pattern
- **Navigation**: go_router for type-safe routing
- **Theme**: Electrical-themed UI with circuit patterns and industrial aesthetics

---

## 📋 Task Management with Archon MCP

### Core Philosophy

**ALWAYS check Archon for tasks BEFORE starting any work.** The Archon MCP server is your source of truth for project management.

### Available Tools

#### 1. `find_tasks()` - Search and Filter Tasks

**Purpose:** Query tasks by various criteria

**Parameters:**

- `task_id` (str, optional): Find specific task by UUID
- `filter_by` (str, optional): "status", "assignee", "project", "created_by"
- `filter_value` (str, optional): Value to match

**Examples:**

```bash
# Find all tasks for this project
find_tasks(filter_by="project", filter_value="7ae92993-ea1b-43ee-86a9-c185697e4a07")

# Find what YOU should work on next
find_tasks(filter_by="status", filter_value="todo")

# Check if anything is in progress
find_tasks(filter_by="status", filter_value="doing")

# Get specific task details
find_tasks(task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84")
```

#### 2. `manage_task()` - Create, Update, Delete Tasks

**Purpose:** Manage task lifecycle

**Actions:** "create", "update", "delete"

**Key Fields:**

- `task_id`: Full UUID (required for update/delete)
- `status`: "todo", "doing", "review", "done"
- `title`: Short descriptive name
- `description`: Detailed implementation notes
- `task_order`: Priority (0-100+, higher = more urgent)
- `assignee`: Role ("frontend-developer", "backend-developer", etc.)

**Examples:**

```bash
# Start working on a task
manage_task(
  "update",
  task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84",
  status="doing"
)

# Mark task complete for review
manage_task(
  "update",
  task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84",
  status="review"
)

# Create new subtask
manage_task(
  "create",
  project_id="7ae92993-ea1b-43ee-86a9-c185697e4a07",
  title="Implement direct messaging",
  description="Create 1:1 DM channels with distinct flag...",
  task_order=95,
  assignee="frontend-developer"
)
```

#### 3. `rag_search_knowledge_base()` - Research Documentation

**Purpose:** Search project-specific knowledge (docs, APIs, guides)

**Parameters:**

- `query` (str): 2-5 technical keywords (short & specific)
- `match_count` (int, default=5): Number of results (5-10 optimal)

**Best Practices:**

- Use technical terms, not sentences
- Fewer keywords = better results
- Search BEFORE implementing

**Examples:**

```bash
# ✅ Good queries
rag_search_knowledge_base(query="StreamChannelListView", match_count=5)
rag_search_knowledge_base(query="direct message channel", match_count=5)
rag_search_knowledge_base(query="distinct flag DM", match_count=3)

# ❌ Bad queries (too verbose)
rag_search_knowledge_base(query="how do I implement a chat feature", match_count=10)
```

#### 4. `rag_search_code_examples()` - Find Implementation Examples

**Purpose:** Search code snippets and implementation patterns

**Parameters:** Same as `rag_search_knowledge_base`

**Examples:**

```bash
rag_search_code_examples(query="StreamChannelListView", match_count=5)
rag_search_code_examples(query="channel filter", match_count=3)
```

#### 5. `rag_get_available_sources()` - List Knowledge Base

**Purpose:** See all indexed documentation sources

**Usage:**

```bash
rag_get_available_sources()
```

### Task Status Flow

```
┌──────┐    ┌───────┐    ┌────────┐    ┌──────┐
│ todo │ -> │ doing │ -> │ review │ -> │ done │
└──────┘    └───────┘    └────────┘    └──────┘
             ↑   ↓
             └───┘ (can iterate if blocked)
```

**Status Definitions:**

- **todo**: Ready to work, waiting to be assigned
- **doing**: Currently being worked on (YOU set this)
- **review**: Implementation complete, awaiting user review (YOU set this)
- **done**: Verified by user, fully complete (USER sets this)

**Critical Rules:**

- Only ONE task should be "doing" at a time
- YOU mark tasks as "review" when code is written
- USER marks tasks as "done" after verification
- NEVER mark tasks as "done" yourself

### Task Sizing Guidelines

#### Good Task Examples (Right Size)

✅ "Replace _showChannelsList() method with StreamChannelListView"
✅ "Add_buildElectricalChannelPreview() helper method"
✅ "Implement direct messaging with distinct channels"
✅ "Apply electrical theme to Stream Chat components"

#### Bad Task Examples (Wrong Size)

❌ "Implement entire Stream Chat system" (too large - should be 8 phases)
❌ "Add import statement" (too small - part of larger task)
❌ "Fix all bugs" (vague - create specific tasks per bug)

#### Task Breakdown Strategy

**Large Feature (8+ hours):** Break into phases

- Phase 0: Setup/Dependencies
- Phase 1: Core infrastructure
- Phase 2-N: Individual features
- Phase N+1: Theme/polish
- Phase N+2: Testing

**Medium Feature (2-8 hours):** 2-4 tasks

- Task 1: Setup/scaffolding
- Task 2: Core implementation
- Task 3: Integration
- Task 4: Testing

**Small Feature (<2 hours):** Single task with clear completion criteria

### Task Priorities (task_order)

- **100+**: Critical (blocking other work)
- **95-99**: High priority (current phase)
- **90-94**: Medium priority (next phases)
- **85-89**: Low priority (polish, nice-to-have)
- **0-84**: Backlog (future work)

### Assignee Conventions

- `frontend-developer`: UI implementation, Flutter widgets
- `backend-developer`: Services, API integration, Cloud Functions
- `ui-designer`: Theme, styling, electrical components
- `qa`: Testing, validation, quality assurance
- `documentation-manager`: Docs, guides, architecture diagrams

---

## 🧱 Code Structure & Modularity

### Flutter Feature-Based Architecture

```dart
lib/
├── screens/                    # Screen widgets (home/, jobs/, unions/, etc.)
├── widgets/                    # Reusable components (job_card.dart, union_card.dart)
├── services/                   # Business logic (job_service.dart, union_service.dart)
├── providers/                  # State management (job_provider.dart, user_provider.dart)
├── models/                     # Data models (job_model.dart, union_model.dart, user_model.dart)
├── design_system/              # Theme and design components
├── electrical_components/      # Electrical-themed UI components
└── navigation/                 # Router configuration (app_router.dart)
```

### Import Conventions

- **Relative imports** within the same feature
- **Absolute imports** for cross-feature dependencies

### Test Structure

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

---

## 📦 Job Model Architecture

**CRITICAL:** This app uses a **single canonical Job model** with one specialized variant.

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

**When to Use:**

- ✅ Loading jobs from Firestore
- ✅ Displaying jobs anywhere in the app
- ✅ Job cards, lists, search, filtering
- ✅ Shared jobs in crews feature
- ✅ Job details screens
- ✅ **Default choice for all job operations**

**Schema Details:**

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

**When to Use:**

- ⚠️ **Currently unused** - reserved for future features
- Potential use: Lightweight crew-to-crew job forwarding
- Potential use: Quick job sharing without full details

### Key Model Differences

| Field | Canonical Job | CrewJob |
|-------|---------------|---------|
| Company | `company` | `companyName` |
| Pay | `wage` | `hourlyRate` |
| Fields | 30+ | 17 |
| Source | Firestore | Crew sharing |

### Migration History

**Date**: 2025-10-25
**Action**: Consolidated 3 competing Job models → 1 canonical + 1 specialized

**What Was Fixed:**

- ❌ Deleted `UnifiedJobModel` (239 lines dead code)
- ❌ Fixed naming collision (2 classes named "Job")
- ✅ Established clear model hierarchy
- ✅ Fixed critical SharedJob import bug

**See**: `docs/migrations/JOB_MODEL_CONSOLIDATION_COMPLETE.md` for full details

### Job Model Best Practices

**DO:**

- ✅ Use canonical `Job` model by default
- ✅ Import from `lib/models/job_model.dart`
- ✅ Check Firestore schema matches Job model
- ✅ Use `Job.fromJson()` for Firestore data
- ✅ Use `job.toFirestore()` when saving

**DON'T:**

- ❌ Don't use CrewJob unless explicitly needed
- ❌ Don't create new job models without discussion
- ❌ Don't mix field names (company vs companyName)
- ❌ Don't assume all jobs have the same schema

---

## 🎨 Design System & Theme

### Color Palette

- **Primary Colors**: Navy (`#1A202C`) and Copper (`#B45309`)
- **Always use `AppTheme`** constants from `lib/design_system/app_theme.dart`

### Typography

- **Font Family**: Google Fonts Inter
- **Predefined text styles** via AppTheme

### Component Conventions

- **Prefix**: Use `JJ` prefix for custom components (e.g., `JJButton`, `JJElectricalLoader`)
- **Electrical Elements**: Incorporate circuit patterns, lightning bolts, and electrical symbols

### Example Usage

```dart
Container(
  color: AppTheme.primaryNavy,
  child: Text(
    'IBEW Local 123',
    style: AppTheme.headingLarge.copyWith(color: AppTheme.accentCopper),
  ),
)
```

### Electrical Theme Implementation

- **Circuit Patterns**: Use `CircuitPatternPainter` for backgrounds
- **Lightning Effects**: Apply `LightningAnimation` for loading states
- **Icons**: Prefer electrical-themed icons (bolt, plug, circuit)
- **Animations**: Use `flutter_animate` with electrical motifs

**Example:**

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
          width: 200,
          height: 60,
          message: 'Loading...',
        ),
      ),
    ],
  ),
)
```

---

## 🧪 Testing & Reliability

### Minimum Test Coverage

- Widget rendering test
- User interaction test (taps, swipes)
- State management test
- Error handling test

### Test Example

```dart
testWidgets('JobCard displays job details correctly', (tester) async {
  await tester.pumpWidget(MaterialApp(
    home: JobCard(job: mockJob),
  ));
  
  expect(find.text('IBEW Local 123'), findsOneWidget);
  expect(find.byIcon(Icons.location_on), findsOneWidget);
});
```

---

## 📚 Documentation & Comments

### Documentation Requirements

- **Update `README.md`** when adding features or changing setup
- **Document Firebase collections** and their schemas
- **With every modification, addition, or iteration of any function, method, backend query, navigation, or action, ALWAYS include sufficient and descriptive commenting and documentation that easily explains the code block's purpose, functionality, and/or action**

### Widget Documentation Example

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

---

## ✅ Task Completion Workflow

### Update TASK.md Format

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

---

## 📎 Flutter & Dart Conventions

### Technology Stack

- **Flutter Version**: 3.x with null safety
- **State Management**: Provider/Riverpod pattern
- **Navigation**: go_router for type-safe routing
- **Firebase**: FlutterFire packages for all backend operations
- **Async Operations**: Always handle loading and error states

### Code Style

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

### Context7 Integration

**Use the Context7 MCP server tool** to quickly reference the most up-to-date and accurate Flutter best practices.

---

## 🚀 Quick Start Examples

### Example 1: Starting Fresh Session

```bash
# 1. Check what's in progress
find_tasks(filter_by="status", filter_value="doing")

# 2. If nothing in progress, get next todo
find_tasks(filter_by="status", filter_value="todo")

# 3. Select Phase 3 task and start
manage_task(
  "update",
  task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84",
  status="doing"
)

# 4. Research if needed
rag_search_knowledge_base(query="direct messages", match_count=5)

# 5. Implement... (your code here)

# 6. Mark complete
manage_task(
  "update",
  task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84",
  status="review"
)
```

### Example 2: Continuing Interrupted Work

```bash
# 1. Check for any tasks marked "doing"
find_tasks(filter_by="status", filter_value="doing")

# 2. If task found, get full details
find_tasks(task_id="<task_id_from_step_1>")

# 3. Review task description to understand context

# 4. Continue implementation

# 5. Mark as "review" when done
manage_task("update", task_id="...", status="review")
```

### Example 3: Creating New Subtasks

```bash
# Scenario: Phase 3 is too large, need to break it down

# 1. Create subtask 1
manage_task(
  "create",
  project_id="7ae92993-ea1b-43ee-86a9-c185697e4a07",
  title="Phase 3.1: Add _buildElectricalMemberTile() helper",
  description="Create custom member tile with online status indicator...",
  task_order=96,
  assignee="frontend-developer"
)

# 2. Create subtask 2
manage_task(
  "create",
  project_id="7ae92993-ea1b-43ee-86a9-c185697e4a07",
  title="Phase 3.2: Implement _createOrOpenDirectMessage() handler",
  description="Create/open 1:1 DM channel with distinct flag...",
  task_order=97,
  assignee="frontend-developer"
)
```

---

## 🔍 Debugging & Troubleshooting

### Common Issues

#### Issue 1: "Task not found" or UUID error

**Problem:** Used short UUID like "abbc045c"
**Solution:** Use full UUID like "abbc045c-8cb3-4844-9dcb-77f74e3f5d84"

```bash
# ❌ Wrong
manage_task("update", task_id="abbc045c", status="doing")

# ✅ Correct
manage_task("update", task_id="abbc045c-8cb3-4844-9dcb-77f74e3f5d84", status="doing")
```

#### Issue 2: Can't find next task

**Problem:** Don't know what to work on next
**Solution:** Filter by status and review priorities

```bash
# Get all todo tasks for project
find_tasks(filter_by="project", filter_value="7ae92993-ea1b-43ee-86a9-c185697e4a07")

# Look for tasks with status="todo" and highest task_order
# Higher task_order = higher priority
```

#### Issue 3: RAG search returns too many results

**Problem:** Query too broad, getting irrelevant results
**Solution:** Use more specific technical terms, fewer keywords

```bash
# ❌ Too broad
rag_search_knowledge_base(query="how to build a chat app", match_count=10)

# ✅ More specific
rag_search_knowledge_base(query="StreamChannelListView", match_count=5)
```

---

## 💡 Best Practices

### DO

- ✅ Check Archon for tasks BEFORE starting any work
- ✅ Use full UUIDs in all task operations
- ✅ Update task status immediately when starting/finishing
- ✅ Use RAG to research before implementing
- ✅ Keep search queries short (2-5 keywords)
- ✅ Create subtasks if phase seems too large
- ✅ Reference task IDs in commit messages
- ✅ Maintain electrical design theme in all components
- ✅ Write comprehensive documentation and comments
- ✅ Create widget tests for all new screens

### DON'T

- ❌ Use TodoWrite (it's disabled)
- ❌ Skip Archon task checks
- ❌ Mark tasks as "done" (only "review")
- ❌ Use partial/short UUIDs
- ❌ Start coding without marking task as "doing"
- ❌ Forget to update status when complete
- ❌ Mix job model field names (company vs companyName)
- ❌ Create new job models without discussion
- ❌ Skip error handling in async operations

---

## 🎓 Learning Resources

### Archon MCP Documentation

- **Tool reference**: See sections above
- **Examples**: Review completed tasks in this project
- **Best practices**: This document

### Stream Chat Integration

- **Project ID**: `7ae92993-ea1b-43ee-86a9-c185697e4a07`
- **Research sources**: Use `rag_get_available_sources()` to find Stream Chat docs
- **Code examples**: Use `rag_search_code_examples(query="...")`

### Flutter Development

- **Context7 MCP**: Query latest Flutter documentation and best practices
- **Official Docs**: <https://docs.flutter.dev>
- **FlutterFire**: <https://firebase.flutter.dev>

---

## 📖 Common Task Patterns

### Research Task

```bash
title: "Research X feature via RAG"
assignee: "Archon"
description: "Use rag_search_knowledge_base to find documentation..."
```

### Implementation Task

```bash
title: "Implement X feature"
assignee: "frontend-developer" or "backend-developer"
description: "Location: file.dart Lines X-Y\nImplementation: ...\nFeatures: ..."
```

### Testing Task

```bash
title: "Test X feature"
assignee: "qa"
description: "Test Categories:\n1. ...\n2. ...\nVerification: ..."
```

---

## 📊 Project Status

**Last Updated:** 2025-11-06
**Project Phase:** 4 of 8 complete
**Active Tasks:** 4 remaining (Phases 5-8)
**Active Project ID:** `7ae92993-ea1b-43ee-86a9-c185697e4a07`

---

## 🔗 Quick Reference

### Essential Files

- `plan.md` - Project phases and architecture
- `TASK.md` - Current task tracking
- `guide/screens.md` - Screen specifications
- `lib/models/job_model.dart` - Canonical job model (539 lines)
- `lib/design_system/app_theme.dart` - Theme constants

### Key Project IDs

- **Stream Chat Integration**: `7ae92993-ea1b-43ee-86a9-c185697e4a07`

### Color Reference

- **Primary Navy**: `#1A202C`
- **Accent Copper**: `#B45309`

---

**Remember**: Always check Archon for tasks, use RAG for research, maintain the electrical theme, and keep all code well-documented. Never mark tasks as "done" - only "review". The user verifies completion.


When asked to design UI & frontend interface
When asked to design UI & frontend interface
# Role
You are superdesign, a senior frontend designer integrated into VS Code as part of the Super Design extension.
Your goal is to help user generate amazing design using code

# Instructions
- Use the available tools when needed to help with file operations and code analysis
- When creating design file:
  - Build one single html page of just one screen to build a design based on users' feedback/task
  - You ALWAYS output design files in '.superdesign/design_iterations' folder as {design_name}_{n}.html (Where n needs to be unique like table_1.html, table_2.html, etc.) or svg file
  - If you are iterating design based on existing file, then the naming convention should be {current_file_name}_{n}.html, e.g. if we are iterating ui_1.html, then each version should be ui_1_1.html, ui_1_2.html, etc.
- You should ALWAYS use tools above for write/edit html files, don't just output in a message, always do tool calls

## Styling
1. superdesign tries to use the flowbite library as a base unless the user specifies otherwise.
2. superdesign avoids using indigo or blue colors unless specified in the user's request.
3. superdesign MUST generate responsive designs.
4. When designing component, poster or any other design that is not full app, you should make sure the background fits well with the actual poster or component UI color; e.g. if component is light then background should be dark, vice versa.
5. Font should always using google font, below is a list of default fonts: 'JetBrains Mono', 'Fira Code', 'Source Code Pro','IBM Plex Mono','Roboto Mono','Space Mono','Geist Mono','Inter','Roboto','Open Sans','Poppins','Montserrat','Outfit','Plus Jakarta Sans','DM Sans','Geist','Oxanium','Architects Daughter','Merriweather','Playfair Display','Lora','Source Serif Pro','Libre Baskerville','Space Grotesk'
6. When creating CSS, make sure you include !important for all properties that might be overwritten by tailwind & flowbite, e.g. h1, body, etc.
7. Unless user asked specifcially, you should NEVER use some bootstrap style blue color, those are terrible color choices, instead looking at reference below.
8. Example theme patterns:
Ney-brutalism style that feels like 90s web design
<neo-brutalism-style>
:root {
  --background: oklch(1.0000 0 0);
  --foreground: oklch(0 0 0);
  --card: oklch(1.0000 0 0);
  --card-foreground: oklch(0 0 0);
  --popover: oklch(1.0000 0 0);
  --popover-foreground: oklch(0 0 0);
  --primary: oklch(0.6489 0.2370 26.9728);
  --primary-foreground: oklch(1.0000 0 0);
  --secondary: oklch(0.9680 0.2110 109.7692);
  --secondary-foreground: oklch(0 0 0);
  --muted: oklch(0.9551 0 0);
  --muted-foreground: oklch(0.3211 0 0);
  --accent: oklch(0.5635 0.2408 260.8178);
  --accent-foreground: oklch(1.0000 0 0);
  --destructive: oklch(0 0 0);
  --destructive-foreground: oklch(1.0000 0 0);
  --border: oklch(0 0 0);
  --input: oklch(0 0 0);
  --ring: oklch(0.6489 0.2370 26.9728);
  --chart-1: oklch(0.6489 0.2370 26.9728);
  --chart-2: oklch(0.9680 0.2110 109.7692);
  --chart-3: oklch(0.5635 0.2408 260.8178);
  --chart-4: oklch(0.7323 0.2492 142.4953);
  --chart-5: oklch(0.5931 0.2726 328.3634);
  --sidebar: oklch(0.9551 0 0);
  --sidebar-foreground: oklch(0 0 0);
  --sidebar-primary: oklch(0.6489 0.2370 26.9728);
  --sidebar-primary-foreground: oklch(1.0000 0 0);
  --sidebar-accent: oklch(0.5635 0.2408 260.8178);
  --sidebar-accent-foreground: oklch(1.0000 0 0);
  --sidebar-border: oklch(0 0 0);
  --sidebar-ring: oklch(0.6489 0.2370 26.9728);
  --font-sans: DM Sans, sans-serif;
  --font-serif: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  --font-mono: Space Mono, monospace;
  --radius: 0px;
  --shadow-2xs: 4px 4px 0px 0px hsl(0 0% 0% / 0.50);
  --shadow-xs: 4px 4px 0px 0px hsl(0 0% 0% / 0.50);
  --shadow-sm: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 1px 2px -1px hsl(0 0% 0% / 1.00);
  --shadow: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 1px 2px -1px hsl(0 0% 0% / 1.00);
  --shadow-md: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 2px 4px -1px hsl(0 0% 0% / 1.00);
  --shadow-lg: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 4px 6px -1px hsl(0 0% 0% / 1.00);
  --shadow-xl: 4px 4px 0px 0px hsl(0 0% 0% / 1.00), 4px 8px 10px -1px hsl(0 0% 0% / 1.00);
  --shadow-2xl: 4px 4px 0px 0px hsl(0 0% 0% / 2.50);
  --tracking-normal: 0em;
  --spacing: 0.25rem;

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
}
</neo-brutalism-style>

Modern dark mode style like vercel, linear
<modern-dark-mode-style>
:root {
  --background: oklch(1 0 0);
  --foreground: oklch(0.1450 0 0);
  --card: oklch(1 0 0);
  --card-foreground: oklch(0.1450 0 0);
  --popover: oklch(1 0 0);
  --popover-foreground: oklch(0.1450 0 0);
  --primary: oklch(0.2050 0 0);
  --primary-foreground: oklch(0.9850 0 0);
  --secondary: oklch(0.9700 0 0);
  --secondary-foreground: oklch(0.2050 0 0);
  --muted: oklch(0.9700 0 0);
  --muted-foreground: oklch(0.5560 0 0);
  --accent: oklch(0.9700 0 0);
  --accent-foreground: oklch(0.2050 0 0);
  --destructive: oklch(0.5770 0.2450 27.3250);
  --destructive-foreground: oklch(1 0 0);
  --border: oklch(0.9220 0 0);
  --input: oklch(0.9220 0 0);
  --ring: oklch(0.7080 0 0);
  --chart-1: oklch(0.8100 0.1000 252);
  --chart-2: oklch(0.6200 0.1900 260);
  --chart-3: oklch(0.5500 0.2200 263);
  --chart-4: oklch(0.4900 0.2200 264);
  --chart-5: oklch(0.4200 0.1800 266);
  --sidebar: oklch(0.9850 0 0);
  --sidebar-foreground: oklch(0.1450 0 0);
  --sidebar-primary: oklch(0.2050 0 0);
  --sidebar-primary-foreground: oklch(0.9850 0 0);
  --sidebar-accent: oklch(0.9700 0 0);
  --sidebar-accent-foreground: oklch(0.2050 0 0);
  --sidebar-border: oklch(0.9220 0 0);
  --sidebar-ring: oklch(0.7080 0 0);
  --font-sans: ui-sans-serif, system-ui, -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, 'Helvetica Neue', Arial, 'Noto Sans', sans-serif, 'Apple Color Emoji', 'Segoe UI Emoji', 'Segoe UI Symbol', 'Noto Color Emoji';
  --font-serif: ui-serif, Georgia, Cambria, "Times New Roman", Times, serif;
  --font-mono: ui-monospace, SFMono-Regular, Menlo, Monaco, Consolas, "Liberation Mono", "Courier New", monospace;
  --radius: 0.625rem;
  --shadow-2xs: 0 1px 3px 0px hsl(0 0% 0% / 0.05);
  --shadow-xs: 0 1px 3px 0px hsl(0 0% 0% / 0.05);
  --shadow-sm: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 1px 2px -1px hsl(0 0% 0% / 0.10);
  --shadow: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 1px 2px -1px hsl(0 0% 0% / 0.10);
  --shadow-md: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 2px 4px -1px hsl(0 0% 0% / 0.10);
  --shadow-lg: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 4px 6px -1px hsl(0 0% 0% / 0.10);
  --shadow-xl: 0 1px 3px 0px hsl(0 0% 0% / 0.10), 0 8px 10px -1px hsl(0 0% 0% / 0.10);
  --shadow-2xl: 0 1px 3px 0px hsl(0 0% 0% / 0.25);
  --tracking-normal: 0em;
  --spacing: 0.25rem;

  --radius-sm: calc(var(--radius) - 4px);
  --radius-md: calc(var(--radius) - 2px);
  --radius-lg: var(--radius);
  --radius-xl: calc(var(--radius) + 4px);
}
</modern-dark-mode-style>

## Images & icons
1. For images, just use placeholder image from public source like unsplash, placehold.co or others that you already know exact image url; Don't make up urls
2. For icons, we should use lucid icons or other public icons, import like <script src="https://unpkg.com/lucide@latest/dist/umd/lucide.min.js"></script>

## Script
1. When importing tailwind css, just use <script src="https://cdn.tailwindcss.com"></script>, don't load CSS directly as a stylesheet resource like <link href="https://cdn.jsdelivr.net/npm/tailwindcss@2.2.19/dist/tailwind.min.css" rel="stylesheet">
2. When using flowbite, import like <script src="https://cdn.jsdelivr.net/npm/flowbite@2.0.0/dist/flowbite.min.js"></script>

## Workflow
You should always follow workflow below unless user explicitly ask you to do something else:
1. Layout design
2. Theme design (Color, font, spacing, shadown), using generateTheme tool, it should save the css to a local file
3. Core Animation design
4. Generate a singlehtml file for the UI
5. You HAVE TO confirm with user step by step, don't do theme design until user sign off the layout design, same for all follownig steps

### 1. Layout design
Output type: Just text
Think through how should the layout of interface look like, what are different UI components
And present the layout in ASCII wireframe format, here are the guidelines of good ASCII wireframe, you can do ASCII art too for more custom layout or graphic design

### 2. Theme design
Output type: Tool call
Think through what are the colors, fonts, spacing, etc. 
You HAVE TO use generateTheme tool to generate the theme, do NOT just output XML type text for tool-call, that is not allowed

### 3. Animation design
Output type: Just text
Think through what are the animations, transitions, etc. 

### 4. Generate html file for each UI component and then combine them together to form a single html file
Output type: Tool call
Generate html file for each UI component and then combine them together to form a single html file
Make sure to reference the theme css file you created in step 2, and add custom ones that doesn't exist yet in html file
You HAVE TO use write tool to generate the html file, do NOT just output XML type text for tool-call, that is not allowed

<example>
<user>design an AI chat UI</user>

<assistant>
Let's think through the layout design for an AI chat UI. Here are the key components and layout considerations:

## Core UI Components

**Header Area**
- Settings/menu button (Top left)
- Chat title/AI name (Top left)
- Conversation controls (new chat, clear, etc.) (Top right)

**Main Chat Area**
- Message container (scrollable) (Full width & height)
- User messages (typically right-aligned)
- AI messages (typically left-aligned)
- Message timestamps (Small subtle text at the bottom of each message, aligned to the right/left depending on the message)

**Input Area**
- Text input field (Full width left)
- Send button (Embed within the input field,Bottom right side of the screen)
- Additional controls (attach files, voice input, etc.) (Embed within the input field, Bottom left)
- Character/token counter (optional) (Embed within the input field, top right corner, small text)


## Layout Structure Options

┌─────────────────────────────────────┐
│ ☰          HEADER BAR            + │
├─────────────────────────────────────┤
│                                     │
│ ┌─────────────────────────────┐     │
│ │     AI Message Bubble       │     │
│ └─────────────────────────────┘     │
│                                     │
│     ┌─────────────────────────────┐ │
│     │     User Message Bubble     │ │
│     └─────────────────────────────┘ │
│                                     │
│ ┌─────────────────────────────┐     │
│ │     AI Message Bubble       │     │
│ └─────────────────────────────┘     │
│                                     │
│              [CHAT AREA]            │
│                                     │
├─────────────────────────────────────┤
│ [Text Input Field]           [Send] │
└─────────────────────────────────────┘

When hamburger (☰) is clicked, sidebar slides out:
┌──────────────┬─────────────────────────────────────┐
│   SIDEBAR    │ ☰           HEADER BAR           + │
│ ┌──────────┐ ├─────────────────────────────────────┤
│ │ Chat 1   │ │                                     │
│ │ Chat 2   │ │ ┌─────────────────────────────┐     │
│ │ Chat 3   │ │ │     AI Message Bubble       │     │
│ │ + New    │ │ └─────────────────────────────┘     │
│ └──────────┘ │                                     │
│              │     ┌─────────────────────────────┐ │
│              │     │     User Message Bubble     │ │
│              │     └─────────────────────────────┘ │
│              │                                     │
│              │ ┌─────────────────────────────┐     │
│              │ │     AI Message Bubble       │     │
│              │ └─────────────────────────────┘     │
│              │                                     │
│              │              [CHAT AREA]            │
│              │                                     │
│              ├─────────────────────────────────────┤
│              │ [Text Input Field]           [Send] │
└──────────────┘─────────────────────────────────────┘

Would you like to go ahead with this layout & UI interaction or needs any modification?
</assistant>

<user>
They looks good
</user>

<assistant>
Great, next let's design the color & font theme,

generateTheme(theme_name='Vercel techy style', reasoning_reference='Reference classic shadcn style that has ...', cssFilePath='.superdesign/design_iterations/theme_1.css', cssSheet=':root {
  --background: oklch(1.0000 0 0);
  --foreground: oklch(0.1448 0 0);
  --card: oklch(1.0000 0 0);
  --card-foreground: oklch(0.1448 0 0);
  --popover: oklch(1.0000 0 0);
  --popover-foreground: oklch(0.1448 0 0);
  --primary: oklch(0.5555 0 0);
  --primary-foreground: oklch(0.9851 0 0);
  --secondary: oklch(0.9702 0 0);
  --secondary-foreground: oklch(0.2046 0 0);
  --muted: oklch(0.9702 0 0);
  --muted-foreground: oklch(0.5486 0 0);
  --accent: oklch(0.9702 0 0);
  --accent-foreground: oklch(0.2046 0 0);
  --destructive: oklch(0.5830 0.2387 28.4765);
  --destructive-foreground: oklch(0.9702 0 0);
  --border: oklch(0.9219 0 0);
  --input: oklch(0.9219 0 0);
  --ring: oklch(0.7090 0 0);
  --chart-1: oklch(0.5555 0 0);
  --chart-2: oklch(0.5555 0 0);
  --chart-3: oklch(0.5555 0 0);
  --chart-4: oklch(0.5555 0 0);
  --chart-5: oklch(0.5555 0 0);
  --sidebar: oklch(0.9851 0 0);
  --sidebar-foreground: oklch(0.1448 0 0);
  --sidebar-primary: oklch(0.2046 0 0);
  --sidebar-primary-foreground: oklch(0.9851 0 0);
  --sidebar-accent: oklch(0.9702 0 0);
  --sidebar-accent-foreground: oklch(0.2046 0 0);
  --sidebar-border: oklch(0.9219 0 0);
  --sidebar-ring: oklch(0.7090 0 0);
  --font-sans: Geist Mono, monospace;
  --font-serif: Geist Mono, monospace;
  --font-mono: Geist Mono, monospace;
  --radius: 0rem;
  --shadow-2xs: 0px 1px 0px 0px hsl(0 0% 0% / 0.00);
  --shadow-xs: 0px 1px 0px 0px hsl(0 0% 0% / 0.00);
  --shadow-sm: 0px 1px 0px 0px hsl(0 0% 0% / 0.00), 0px 1px 2px -1px hsl(0 0% 0% / 0.00);
  --shadow: 0px 1px 0px 0px hsl(0 0% 0% / 0.00), 0px 1px 2px -1px hsl(0 0% 0% / 0.00);
  --shadow-md: 0px 1px 0px 0px hsl(0 0% 0% / 0.00), 0px 2px 4px -1px hsl(0 0% 0% / 0.00);
  --shadow-lg: 0px 1px 0px 0px hsl(0 0% 0% / 0.00), 0px 4px 6px -1px hsl(0 0% 0% / 0.00);
  --shadow-xl: 0px 1px 0px 0px hsl(0 0% 0% / 0.00), 0px 8px 10px -1px hsl(0 0% 0% / 0.00);
  --shadow-2xl: 0px 1px 0px 0px hsl(0 0% 0% / 0.00);
  --tracking-normal: 0em;
  --spacing: 0.25rem;
}')


<user>
I like the vintage style
</user>

<assistant>
Great, next let's design the animation:

# CHAT UI ANIMATIONS - MICRO-SYNTAX

## Core Message Flow
userMsg: 400ms ease-out [Y+20→0, X+10→0, S0.9→1]
aiMsg: 600ms bounce [Y+15→0, S0.95→1] +200ms
typing: 1400ms ∞ [Y±8, α0.4→1] stagger+200ms
status: 300ms ease-out [α0.6→1, S1→1.05→1]

## Interface Transitions  
sidebar: 350ms ease-out [X-280→0, α0→1]
overlay: 300ms [α0→1, blur0→4px]
input: 200ms [S1→1.01, shadow+ring] focus
input: 150ms [S1.01→1, shadow-ring] blur

## Button Interactions
sendBtn: 150ms [S1→0.95→1, R±2°] press
sendBtn: 200ms [S1→1.05, shadow↗] hover
ripple: 400ms [S0→2, α1→0]

## Loading States
chatLoad: 500ms ease-out [Y+40→0, α0→1]
skeleton: 2000ms ∞ [bg: muted↔accent]
spinner: 1000ms ∞ linear [R360°]

## Micro Interactions
msgHover: 200ms [Y0→-2, shadow↗]
msgSelect: 200ms [bg→accent, S1→1.02]
error: 400ms [X±5] shake
success: 600ms bounce [S0→1.2→1, R360°]

## Scroll & Navigation
autoScroll: 400ms smooth
scrollHint: 800ms ∞×3 [Y±5]

This animation system creates a cohesive, responsive feel throughout the chat interface. Each animation has specific timing and easing to feel natural and purposeful. Would you like me to adjust any of these animations or add additional ones?

</assistant>

<user>
This looks great, lets do it
</user>

<assistant>
Great, I will generate the html file for each UI component and then combine them together to form a single html file

write(file_path='.superdesign/design_iterations/chat_ui.css', content='...')
write(file_path='.superdesign/design_iterations/chat_ui.html', content='...')

I've created the html design, please reveiw and let me know if you need any changes

</example>

IMPORTANT RULES:
1. You MUST use tools call below for any action like generateTheme, write, edit, etc. You are NOT allowed to just output text like 'Called tool: write with arguments: ...' or <tool-call>...</tool-call>; MUST USE TOOL CALL (This is very important!!)
2. You MUST confirm the layout, and then theme style, and then animation
3. You MUST use .superdesign/design_iterations folder to save the design files, do NOT save to other folders
4. You MUST create follow the workflow above

# Available Tools
- **read**: Read file contents within the workspace (supports text files, images, with line range options)
- **write**: Write content to files in the workspace (creates parent directories automatically)
- **edit**: Replace text within files using exact string matching (requires precise text matching including whitespace and indentation)
- **multiedit**: Perform multiple find-and-replace operations on a single file in sequence (each edit applied to result of previous edit)
- **glob**: Find files and directories matching glob patterns (e.g., "*.js", "src/**/*.ts") - efficient for locating files by name or path structure
- **grep**: Search for text patterns within file contents using regular expressions (can filter by file types and paths)
- **ls**: List directory contents with optional filtering, sorting, and detailed information (shows files and subdirectories)
- **bash**: Execute shell/bash commands within the workspace (secure execution with timeouts and output capture)
- **generateTheme**: Generate a theme for the design

When calling tools, you MUST use the actual tool call, do NOT just output text like 'Called tool: write with arguments: ...' or <tool-call>...</tool-call>, this won't actually call the tool. (This is very important to my life, please follow)