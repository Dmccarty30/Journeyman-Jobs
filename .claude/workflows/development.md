---
command: "/dev-workflow"
category: "Development & Quality"
purpose: "Phased development workflow from documentation to audited implementation"
wave-enabled: true
performance-profile: "complex"
---

# Development Workflow - Concept to Creation

Comprehensive, phased approach to feature development with built-in quality gates and automated reviews.

## Workflow Overview

**Five Distinct Phases:**

1. **DOCUMENTATION** → Navigate and document issues objectively
2. **PLANNING** → Generate comprehensive documentation and task lists
3. **ORGANIZATION** → Prioritize and structure tasks with detailed implementation guidance
4. **EXECUTION** → Implement tasks in dependency order with critical-first prioritization
5. **AUDIT/REVIEW** → Automated code review with pass/fail validation and mandatory rewrites

---

## Phase 1: DOCUMENTATION PHASE

### Objective

Navigate the application documenting issues, concerns, and observations without opinion or influence.

### Guidelines

**You are in DOCUMENTATION PHASE** - Your role is to observe and document only.

- Be descriptive and detailed
- Document what you see, not what you think should be done
- No suggestions, opinions, or solutions
- Focus on facts: current state, behaviors, patterns, inconsistencies
- Document file locations, code blocks, and specific issues

**Tools to Use:**

- Read: Examine code files
- Grep: Search for patterns
- Glob: Find related files
- Bash: Run the app and observe behavior

### Output Format

Create or update `DOCUMENTATION.md`:

```markdown
# Documentation Phase - [Feature/Area Name]

## Date: [Current Date]

### Observed Issues

#### [Area 1]
- **Location**: `lib/path/to/file.dart:123-145`
- **Observation**: [Detailed description of what exists]
- **Current Behavior**: [What happens now]
- **Context**: [Surrounding code, dependencies, relationships]

### Code Patterns Observed

#### Pattern 1: [Pattern Name]
- **Locations**: [List of files where pattern appears]
- **Description**: [How the pattern is currently implemented]
- **Frequency**: [How often this pattern occurs]

### Dependencies Noted

#### Dependency 1:
- **Component**: [Component name]
- **Depends On**: [List of dependencies]
- **Impact**: [What breaks if this changes]

### End of Documentation Phase
```

**Phase Completion:**

- Say "DOCUMENTATION PHASE COMPLETE"
- Ask user: "Ready to proceed to PLANNING PHASE?"
- Wait for explicit user confirmation before proceeding

---

## Phase 2: PLANNING PHASE

### Objective

Transform observations into actionable plans with comprehensive documentation and task breakdown.

### Guidelines

**You are in PLANNING PHASE** - Your role is to analyze documentation and create comprehensive plans.

**Process:**

1. Review DOCUMENTATION.md - Read all observations from Phase 1
2. Outline Core Concepts - Identify the main ideas and dependencies
3. Generate Comprehensive Documentation - Create detailed technical specifications
4. Create Task List - Break down into specific, actionable tasks

**Auto-Activate:**

- `--persona-architect` for system design
- `--persona-analyzer` for dependency analysis
- `--seq` for structured planning
- `--c7` for framework best practices

### Output Format

Create or update `PLANNING.md`:

```markdown
# Planning Phase - [Feature/Area Name]

## Date: [Current Date]

## Core Concepts

### Concept 1: [Name]
- **Purpose**: [Why this is needed]
- **Dependencies**: [What this relies on]
- **Impact**: [What this affects]

## Technical Specifications

### Architecture Changes
- [Detailed architecture modifications]
- [Component relationships]
- [Data flow diagrams if needed]

### Implementation Approach
- [High-level approach]
- [Key decisions and rationale]
- [Risk assessment]

## Task Breakdown

### Task Group 1: [Group Name]

#### Task 1.1: [Task Name]
- **Type**: [Feature/Bugfix/Refactor/Enhancement]
- **Priority**: [Critical/High/Medium/Low]
- **Estimated Effort**: [Hours/Days]
- **Dependencies**: [List of dependent tasks]
- **Description**: [Detailed description]

## Risk Assessment

### Risk 1: [Risk Name]
- **Probability**: [High/Medium/Low]
- **Impact**: [High/Medium/Low]
- **Mitigation**: [How to address]

## End of Planning Phase
```

**Phase Completion:**

- Say "PLANNING PHASE COMPLETE"
- Ask user: "Ready to proceed to ORGANIZATION PHASE?"
- Wait for explicit user confirmation

---

## Phase 3: ORGANIZATION PHASE

### Objective

Organize tasks with detailed implementation guidance including code locations, snippets, and examples.

### Guidelines

**You are in ORGANIZATION PHASE** - Your role is to create a detailed, executable task plan.

**Process:**

1. Read PLANNING.md - Review all tasks from Phase 2
2. Prioritize Tasks - Order by criticality and dependencies
3. Group by Domain - Organize into logical groups (UI, Backend, Services, etc.)
4. Create Hierarchy - Establish parent-child relationships
5. Add Implementation Details - Include exact code locations, snippets, and examples

**Auto-Activate:**

- `--persona-architect` for task organization
- `--seq` for dependency analysis
- Domain-specific personas based on task groups

### Output Format

Create `TASK.md`:

```markdown
# Task Implementation Plan - [Feature/Area Name]

## Date: [Current Date]

## Organization Strategy

- **Primary Ordering**: Critical → High → Medium → Low
- **Domain Groups**: [List of domain groups identified]
- **Dependency Chains**: [Overview of task dependencies]

---

## CRITICAL PRIORITY TASKS

### Group: [Domain Name] (e.g., Core Services)

#### Task C1: [Task Name]
- **Priority**: Critical
- **Domain**: [Domain]
- **Dependencies**: None (or list)
- **Estimated Effort**: [X hours/days]
- **Affects**: [What depends on this]

**Implementation Details:**

**Location**: `lib/path/to/file.dart`

**Current Code** (Lines 123-145):
```dart
// Current implementation
class ExampleService {
  void oldMethod() {
    // existing code
  }
}
```

**Required Changes**:

```dart
// New implementation
class ExampleService {
  // Add new method
  Future<Result> newMethod({
    required String param1,
    int? optionalParam,
  }) async {
    try {
      // Implementation here
      return Result.success(data);
    } catch (e) {
      return Result.failure(e.toString());
    }
  }
}
```

**Related Files to Modify**:

- `lib/providers/example_provider.dart:45-67` - Update provider to use new method
- `lib/screens/example_screen.dart:89-112` - Update UI to reflect changes

**Testing Requirements**:

- Unit test for `newMethod`
- Integration test with provider
- Widget test for screen updates

**Acceptance Criteria**:

- [ ] New method implemented with error handling
- [ ] Provider integration complete
- [ ] UI reflects changes correctly
- [ ] All tests pass
- [ ] Documentation updated

---

## Dependency Graph

```text
C1 → H1 → M1
  ↘ H2 → M2 → L1
C2 → H3 → M3
```

## Implementation Order

Based on dependencies and priority:

1. C1, C2 (Critical, no dependencies)
2. H1 (depends on C1)
3. H2 (depends on C1)
4. H3 (depends on C2)
5. M1 (depends on H1)
6. M2 (depends on H2)
7. M3 (depends on H3)
8. L1 (depends on M2)

## End of Organization Phase

```

**Phase Completion:**

- Say "ORGANIZATION PHASE COMPLETE"
- Display task summary: "X Critical, Y High, Z Medium, W Low tasks identified"
- Ask user: "Ready to proceed to EXECUTION PHASE?"
- Wait for explicit user confirmation

---

## Phase 4: EXECUTION PHASE

### Objective

Implement tasks in dependency order, starting with critical priority.

### Guidelines

**You are in EXECUTION PHASE** - Your role is to implement tasks following the established plan.

**Process:**

1. Load TASK.md - Review implementation plan
2. Start with Critical Tasks - Always begin with highest priority
3. Follow Dependency Order - Respect task dependencies
4. Track Progress - Use TodoWrite to track each task
5. Implement with Quality - Follow all coding standards and best practices

**Auto-Activate:**

- Domain-specific personas based on task type
- `--validate` for safety checks
- `--c7` for framework best practices
- `--seq` for complex implementations
- `--magic` for UI components

**Execution Rules:**

1. **One Task at a Time**: Complete current task before starting next
2. **Follow Implementation Details**: Use provided code locations and examples
3. **Test as You Go**: Run tests after each task completion
4. **Document Changes**: Update relevant documentation
5. **Mark Complete**: Only mark task as done when fully tested

**After Each Task:**

1. Run relevant tests: `flutter test test/path/to/test.dart`
2. Update TASK.md with completion status
3. Document any issues or deviations
4. Mark todo as complete
5. Move to next task

**Group Completion:**

When all tasks in a priority group are complete:

1. Say "GROUP COMPLETE: [Group Name] - All [Priority] tasks implemented"
2. Update TASK.md with completion summary
3. Ask user: "Ready to proceed to AUDIT/REVIEW PHASE for [Group Name]?"
4. Wait for explicit user confirmation

---

## Phase 5: AUDIT/REVIEW PHASE

### Objective
Comprehensive code review with pass/fail validation and mandatory rewrites for failures.

### Guidelines

**You are in AUDIT/REVIEW PHASE** - Your role is to ensure code quality meets standards.

**Process:**
1. Invoke Code Review Agent - Delegate to specialized review agent
2. Comprehensive Analysis - Review all implemented code from current group
3. Pass/Fail Decision - Agent decides if code meets standards
4. Mandatory Rewrites - Failed tasks must be reimplemented
5. Re-audit - Failed tasks are re-reviewed after rewrite

**Auto-Activate:**
- `--persona-qa` for quality assessment
- `--persona-security` for security review
- `--seq` for systematic analysis
- `--play` for automated testing

### Audit Criteria

**Code Quality**
- [ ] Follows Flutter/Dart best practices
- [ ] Adheres to project architecture
- [ ] Proper error handling
- [ ] Comprehensive documentation
- [ ] Consistent with electrical theme

**Testing**
- [ ] Unit tests pass
- [ ] Widget tests pass
- [ ] Integration tests pass (if applicable)
- [ ] Edge cases covered
- [ ] Error scenarios tested

**Security**
- [ ] No security vulnerabilities
- [ ] Proper data validation
- [ ] Safe Firebase operations
- [ ] Privacy requirements met

**Performance**
- [ ] No performance regressions
- [ ] Efficient algorithms
- [ ] Proper state management
- [ ] Optimized UI rendering

**Documentation**
- [ ] Code comments adequate
- [ ] TASK.md updated
- [ ] README updated (if needed)
- [ ] Breaking changes documented

### Audit Workflow

1. Invoke code-reviewer agent with task group details
2. Agent performs comprehensive review
3. Agent provides pass/fail decision
4. If PASS:
   - Update TASK.md with ✅ for all tasks in group
   - Say "AUDIT PASSED: [Group Name] - Ready for next group"
   - If more groups exist, return to EXECUTION PHASE
   - If all groups complete, say "ALL PHASES COMPLETE - Feature Ready"
5. If FAIL:
   - Update TASK.md with ❌ for failed tasks
   - Return to EXECUTION PHASE for failed tasks only
   - Re-implement failed tasks
   - Re-run AUDIT/REVIEW for rewritten tasks
   - Repeat until PASS

**Re-audit Process:**

For failed tasks that have been rewritten:
1. Say "RE-AUDIT: [Task Name]"
2. Invoke code-reviewer agent for specific task
3. Agent provides pass/fail decision
4. If still FAIL: Repeat rewrite
5. If PASS: Mark complete and continue

---

## Workflow State Management

Track current phase and progress:

```markdown
# WORKFLOW STATE

**Current Phase**: [PHASE NAME]
**Feature/Area**: [Name]
**Started**: [Date]
**Last Updated**: [Date]

## Phase Completion Status

- [x] DOCUMENTATION PHASE - Completed: [Date]
- [x] PLANNING PHASE - Completed: [Date]
- [x] ORGANIZATION PHASE - Completed: [Date]
- [ ] EXECUTION PHASE - In Progress
  - [x] Critical Priority - Completed: [Date]
  - [ ] High Priority - In Progress
  - [ ] Medium Priority - Pending
  - [ ] Low Priority - Pending
- [ ] AUDIT/REVIEW PHASE - Pending

## Current Task

**Task ID**: H1
**Task Name**: [Name]
**Status**: in_progress
**Started**: [Date/Time]
```

---

## Usage

**Start the workflow:**

```bash
/dev-workflow [feature-name]
```

**Example:**

```bash
/dev-workflow dark-mode-implementation
```

**Resume a workflow:**

```bash
/dev-workflow resume [feature-name]
```

**Check status:**

```bash
/dev-workflow status
```

---

## Phase Transition Rules

1. **Explicit Confirmation Required**: User must explicitly confirm before moving to next phase
2. **No Skipping**: All phases must be completed in order
3. **Quality Gates**: AUDIT phase must PASS before considering work complete
4. **State Persistence**: Workflow state saved between sessions
5. **Rollback Support**: Can return to previous phase if issues discovered

---

## Integration with SuperClaude Framework

**Personas Auto-Activated:**

- DOCUMENTATION: analyzer, mentor
- PLANNING: architect, analyzer
- ORGANIZATION: architect, domain specialists
- EXECUTION: Domain-specific (frontend, backend, qa, etc.)
- AUDIT: qa, security, performance, code-reviewer

**MCP Servers:**

- Context7: Framework best practices, documentation patterns
- Sequential: Complex analysis, systematic planning
- Magic: UI component generation
- Playwright: Automated testing and validation

**Flags:**

- `--validate`: Enabled for all phases
- `--seq`: Enabled for complex analysis
- `--c7`: Enabled for framework integration
- Domain flags: Auto-activated based on task type

**Quality Gates:**

- All 8 SuperClaude quality gates applied during AUDIT phase
- Mandatory pass before proceeding to next group
- Evidence-based validation required

---

## Best Practices

1. **Be Patient**: Each phase builds on the previous one
2. **Don't Rush**: Quality over speed
3. **Trust the Process**: The structure prevents mistakes
4. **Document Everything**: Future you will thank you
5. **Test Early, Test Often**: Don't wait until audit phase
6. **Accept Failures**: Failed audits are learning opportunities
7. **Iterate**: Rewriting is part of the process

---

## End of Workflow
