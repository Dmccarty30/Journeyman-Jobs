# PART 5: TASK EXECUTION

> Complete procedures for executing validated tasks across all tiers with Agent-Organizer coordination and specialist agent implementation

---

## TABLE OF CONTENTS

1. [Task Execution Overview](#task-execution-overview)
2. [Tier 1: Critical Task Execution](#tier-1-critical-task-execution)
3. [Tier 2: High Priority Task Execution](#tier-2-high-priority-task-execution)
4. [Tier 3 & 4: Refinement & Polish Execution](#tier-3--4-refinement--polish-execution)
5. [Status Tracking & Progress Management](#status-tracking--progress-management)
6. [Command Reference Library](#command-reference-library)

---

## TASK EXECUTION OVERVIEW

### Purpose

Execute all validated tasks in a systematic, tier-based approach with proper agent coordination, progress tracking, and quality assurance at each stage.

### Prerequisites

- ✅ VALIDATION GATE 2 has passed
- ✅ Karen confirmed tasks are realistic
- ✅ Jenny confirmed tasks address findings
- ✅ Master task list is finalized and validated

### Execution Strategy

**Tier-by-Tier Approach:**
- **Tier 1 (Critical)**: Security vulnerabilities, system failures, data protection
- **Tier 2 (High Priority)**: Performance bottlenecks, architectural improvements
- **Tier 3 (Medium Priority)**: Code quality, maintainability improvements
- **Tier 4 (Low Priority)**: Polish, documentation, nice-to-haves

**Agent Coordination:**
- **Agent-Organizer**: Distributes tasks, manages dependencies, tracks progress
- **Specialist Agents**: Execute assigned tasks based on domain expertise
- **Validation Agents**: Karen and Jenny validate after each tier

### Execution Flow

```
┌─ Validated Task List Ready ─────────────────────┐
│                                                 │
├─ Agent-Organizer: Execute Tier 1 (Critical)     │
│  ├─ Distribute tasks to specialists              │
│  ├─ Manage dependencies and sequencing          │
│  ├─ Track progress and status updates           │
│  └─ Coordinate parallel execution               │
│                                                 │
├─ Validation Gate 3A: Tier 1 Completion          │
│  ├─ Karen: Do implementations work?             │
│  ├─ Jenny: Do they match specifications?       │
│  └─ Decision: Continue or rework                │
│                                                 │
├─ Agent-Organizer: Execute Tier 2 (High)         │
│  ├─ Build upon Tier 1 foundations               │
│  ├─ Execute foundational improvements           │
│  └─ Maintain quality and integration            │
│                                                 │
├─ Validation Gate 3B: Tier 2 Completion          │
│  ├─ Karen: Do implementations integrate well?   │
│  ├─ Jenny: Do they complement Tier 1?           │
│  └─ Decision: Continue or rework                │
│                                                 │
├─ Agent-Organizer: Execute Tier 3 & 4            │
│  ├─ Execute refinement and polish tasks         │
│  ├─ Parallel execution where possible          │
│  └─ Complete all remaining improvements         │
│                                                 │
└─ Final Validation: Complete Project Review     │
   ├─ Karen: Is project production-ready?        │
   ├─ Jenny: Are all specifications met?         │
   └─ Decision: Complete or additional work      │
```

---

## TIER 1: CRITICAL TASK EXECUTION

### Tier 1 Characteristics

- **Critical Severity** - Must fix immediately
- **Blocking Issues** - Prevent other work from proceeding
- **Security Vulnerabilities** - Active exploit paths
- **System Failures** - Complete breakage scenarios
- **Data Loss Risks** - Could damage data

### Initial Tier 1 Kickoff Command

**Copy and paste this:**

```bash
Agent-Organizer: Execute TIER 1 (CRITICAL) tasks from the master task list.

TIER 1 SCOPE:
Execute all tasks marked as CRITICAL severity from
hierarchical-initialization-tasks.md

DISTRIBUTION STRATEGY:
Route tasks to specialist agents based on task domain:
- SEC-* (Security) → security-vulnerability-hunter
- ROOT-* (Root Cause) → root-cause-analysis-expert
- ARCH-* (Architecture) → codebase-refactorer
- [Route other tasks to appropriate agents]

EXECUTION APPROACH:
1. For each CRITICAL task, provide:
   - Task ID and title
   - Full task specifications
   - Acceptance criteria
   - Estimated effort
   - Dependencies (other Tier 1 tasks that must complete first)

2. Route tasks respecting dependencies:
   - Start with tasks that have no Tier 1 dependencies
   - As tasks complete, unblock dependent tasks
   - Maintain parallel execution where possible

3. For each task assignment, say:
   "[Agent-name]: Execute this task:
   [Task ID]: [Title]
   [Full task specification from master list]

   Success criteria:
   - [Acceptance criterion 1]
   - [Acceptance criterion 2]
   - [etc]

   Status: Starting
   Assigned to: [Agent name]"

CRITICAL EXECUTION RULES:
- Execute tasks in dependency order
- Start with "Level 0" prerequisites first
- Move to "Level 1" foundational tasks after Level 0
- Verify each task actually completes before moving next
- Update task status as progress occurs

PARALLEL OPPORTUNITIES:
[Identify which Tier 1 tasks can run in parallel]

CRITICAL PATH:
The sequence of Tier 1 tasks that determines minimum timeline

EXPECTED DURATION: [X hours based on task estimates]

BEGIN TIER 1 EXECUTION - Start with first non-dependent task.
```

### Parallel Task Execution Format

**For tasks that can run in parallel, invoke multiple agents:**

```bash
[security-vulnerability-hunter]: Execute SEC-001
[root-cause-analysis-expert]: Execute ROOT-001 (parallel to SEC-001)
[codebase-refactorer]: Execute ARCH-001 (parallel to ROOT-001)
```

### Individual Task Assignment Template

**Template for specialist agent task assignment:**

```bash
[Agent-name]: Execute Task [TASK-ID]: [Task Title]

TASK SPECIFICATION:
[Full task details from master list including:
- Issue description
- Solution specification
- Implementation steps
- Code examples
- Acceptance criteria]

SUCCESS INDICATORS (you're done when):
- [ ] Acceptance criterion 1 is met
- [ ] Acceptance criterion 2 is met
- [ ] Tests pass for this task
- [ ] No new errors introduced
- [ ] Code follows project standards

STATUS UPDATE REQUIRED:
When complete, provide:
1. What was changed (files modified)
2. How you verified success (tests passed, etc.)
3. Any blockers encountered
4. Any issues discovered in implementation
5. Status: [Completed | Incomplete | Blocked]
```

### Real Example: Tier 1 Task Execution

```bash
security-vulnerability-hunter: Execute Task SEC-001

TASK: SEC-001: Fix SQL injection in getUserById function

ISSUE DESCRIPTION:
The getUserById function in auth/user-service.ts (line 87) constructs
SQL queries using string concatenation, allowing SQL injection attacks.

Current (vulnerable):
const query = `SELECT * FROM users WHERE id = ${userId}`;

SOLUTION:
Replace string concatenation with parameterized queries.

IMPLEMENTATION STEPS:
1. Open auth/user-service.ts
2. Locate getUserById function (line 87)
3. Replace string concatenation with parameterized query
4. Pass userId as separate parameter
5. Add type validation for userId
6. Run security tests

ACCEPTANCE CRITERIA:
- [ ] Code uses parameterized queries with parameter binding
- [ ] SQL injection test passes
- [ ] No new security warnings
- [ ] Existing tests still pass
- [ ] Code review approved

STATUS: Please execute and report results.
```

### Status Tracking for Tier 1

**After each Tier 1 task completes:**

```bash
[Agent-Name]: Task [TASK-ID] Status Update

TASK: [Task-ID]: [Task Title]
ASSIGNED: [Agent Name]
STATUS: Completed

WHAT WAS CHANGED:
- [File 1] - [Brief description of changes]
- [File 2] - [Brief description of changes]
- [Configuration] - [Brief description of changes]

VERIFICATION:
- [ ] Acceptance criterion 1 met
- [ ] Acceptance criterion 2 met
- [ ] Tests passing
- [ ] No regressions detected
- [ ] Code review ready

BLOCKERS: None | [List if any]
ISSUES FOUND: None | [List if any]

Ready for: Next task | Validation
```

### Tier 1 Execution Progression

**Tasks execute following this pattern:**

```
Tier 1 Begins
    ↓
├─ Level 0 Prerequisites (Start these)
│  ├─ SEC-001: Fix SQL injection vulnerability
│  ├─ ROOT-001: Fix database connection leak
│  └─ ARCH-001: Resolve circular dependency
│       ↓
│   [These must complete before Level 1]
│       ↓
├─ Level 1 Foundational (Start after Level 0)
│  ├─ PERF-001: Optimize critical query
│  ├─ SEC-002: Fix authentication bypass
│  └─ [Other foundational tasks]
│       ↓
│   [These must complete before validation]
│       ↓
    Tier 1 Complete → Ready for Validation Gate 3A
```

---

## TIER 2: HIGH PRIORITY TASK EXECUTION

### Tier 2 Characteristics

- **High Priority** - Important but not blocking
- **Foundational** - Architectural changes and important features
- **Performance** - Significant optimizations
- **Quality** - Major code quality improvements

### Tier 2 Kickoff Command

**Copy and paste this:**

```bash
Agent-Organizer: Execute TIER 2 (HIGH PRIORITY) tasks from the master
task list.

TIER 2 SCOPE:
Execute all tasks marked as HIGH severity from
hierarchical-initialization-tasks.md

PREREQUISITES MET:
- [X] Tier 1 is complete and validated
- [X] All Tier 1 fixes are working
- [X] Ready to proceed to foundational work

DISTRIBUTION:
Route HIGH severity tasks to appropriate specialists:
- PERF-* (Performance) → performance-optimization-wizard
- DEP-* (Dependencies) → dependency-inconsistency-resolver
- ARCH-* (Architecture) → codebase-refactorer
- [Route others to appropriate agents]

EXECUTION STRATEGY:
1. Execute Tier 2 tasks following dependency order
2. Respect any dependencies on Tier 1 work
3. Start with Level 1 foundational tasks
4. Proceed to Level 2 core implementation
5. Maintain parallel execution where possible

STATUS TRACKING:
Update status for each task:
- Starting: When task begins execution
- In Progress: During implementation
- Completed: When acceptance criteria met
- Blocked: If unable to proceed

EXPECTED DURATION: [X hours based on task estimates]

BEGIN TIER 2 EXECUTION.
```

### Tier 2 Execution Progression

**Tasks execute following this pattern:**

```
Tier 2 Begins (after Tier 1 validation)
    ↓
├─ Level 1 Foundational Tasks (Start these)
│  ├─ ARCH-001: Refactor module structure
│  ├─ DEP-001: Update dependencies
│  └─ [Other foundational tasks]
│       ↓
│   [These must complete before Level 2]
│       ↓
├─ Level 2 Implementation (Start after Level 1)
│  ├─ PERF-001: Optimize queries
│  ├─ ARCH-002: Restructure components
│  └─ [Other implementation tasks]
│       ↓
│    Tier 2 Complete → Ready for Validation Gate 3B
```

### Status Tracking for Tier 2

**Same format as Tier 1:**

```bash
[Agent-Name]: Task [TASK-ID] Status Update

TASK: [Task-ID]: [Task Title]
ASSIGNED: [Agent Name]
STATUS: Completed

[Detailed status update following Tier 1 format]
```

---

## TIER 3 & 4: REFINEMENT & POLISH EXECUTION

### Tier 3 & 4 Characteristics

**Tier 3 (Medium Priority):**
- Code quality and standards enforcement
- Performance optimizations (non-critical path)
- Dead code removal
- Minor architectural improvements
- Test coverage improvement

**Tier 4 (Low Priority):**
- Additional test coverage
- Documentation improvements
- Code cleanup and polish
- Optional optimizations
- Nice-to-have refactoring

### Tier 3 & 4 Kickoff Command

**Copy and paste this:**

```bash
Agent-Organizer: Execute TIER 3 & 4 (REFINEMENT & POLISH) tasks.

TIER 3 SCOPE: MEDIUM PRIORITY - Code quality and refinement
TIER 4 SCOPE: LOW PRIORITY - Polish and nice-to-haves

EXECUTION:
1. Execute Tier 3 MEDIUM priority tasks
2. Validate with Karen & Jenny after Tier 3
3. If validation passes, execute Tier 4 LOW priority tasks
4. Final validation before completion

TIER 3 TASKS INCLUDE:
- Code style and standards enforcement
- Performance optimizations (non-critical path)
- Dead code removal
- Minor architectural improvements
- Test coverage improvement

TIER 4 TASKS INCLUDE:
- Additional test coverage
- Documentation improvements
- Code cleanup and polish
- Optional optimizations
- Nice-to-have refactoring

PARALLEL EXECUTION:
Many Tier 3 & 4 tasks can run in parallel since they don't depend on
each other.

EXPECTED DURATION: [X hours]

BEGIN TIER 3 & 4 EXECUTION.
```

### Parallel Tier 3 & 4 Execution

**Multiple agents work simultaneously:**

```bash
[standards-enforcer]: Execute STYLE-001, STYLE-002, STYLE-003 (parallel)
[dead-code-eliminator]: Execute DEAD-001, DEAD-002 (parallel)
[performance-optimization-wizard]: Execute PERF-002, PERF-003 (parallel)
[testing-and-validation-specialist]: Execute TEST-001, TEST-002 (parallel)
```

### Status Tracking for Tier 3/4

**Same format as Tier 1/2:**

```bash
[Agent-Name]: Task [TASK-ID] Status Update
STATUS: Completed
[Verification details following established format]
```

---

## STATUS TRACKING & PROGRESS MANAGEMENT

### Task Status Categories

**Status Types:**
- **Starting**: Task assignment initiated, work beginning
- **In Progress**: Active implementation in progress
- **Completed**: All acceptance criteria met, ready for validation
- **Blocked**: Unable to proceed due to dependencies or issues
- **Failed**: Task could not be completed as specified
- **Rework**: Task needs revision based on feedback

### Progress Tracking Template

**Standard status update format:**

```bash
[Agent-Name]: Task [TASK-ID] Status Update

TASK: [Task-ID]: [Task Title]
ASSIGNED: [Agent Name]
STATUS: [Starting | In Progress | Completed | Blocked | Failed | Rework]
STARTED: [Timestamp]
COMPLETED: [Timestamp if applicable]

PROGRESS SUMMARY:
[What has been accomplished so far]

CHANGES MADE:
- [File 1] - [Description of changes]
- [File 2] - [Description of changes]
- [Configuration changes if applicable]

VERIFICATION STATUS:
- [ ] Acceptance criterion 1: [Status]
- [ ] Acceptance criterion 2: [Status]
- [ ] Tests passing: [Status]
- [ ] No regressions: [Status]
- [ ] Code review: [Status]

BLOCKERS (if any):
- [Blocker 1] - [Description and impact]
- [Blocker 2] - [Description and impact]

ISSUES DISCOVERED (if any):
- [Issue 1] - [Description and impact]
- [Issue 2] - [Description and impact]

NEXT STEPS:
[What needs to happen next for this task]

READY FOR: [Next task | Validation | Review | Completion]
```

### Dependency Management

**When Task Dependencies Block Progress:**

```bash
[Agent-Name]: Task [TASK-ID] BLOCKED

TASK: [Task-ID]: [Task Title]
STATUS: Blocked

BLOCKING DEPENDENCIES:
- Depends on: [Prerequisite Task ID] - [Status of prerequisite]
- Waiting for: [What needs to complete first]

ESTIMATED UNBLOCK TIME: [When dependency expected to complete]

IMPACT ASSESSMENT:
- This block prevents: [What work is delayed]
- Timeline impact: [How this affects overall schedule]
- Workaround options: [If any alternative approaches exist]

REQUESTED ACTION:
[What needs to happen to unblock this task]
```

### Quality Assurance During Execution

**Self-Validation Checklist for Agents:**

```
Before marking a task complete, verify:

☐ All acceptance criteria are objectively met
☐ Implementation matches task specifications
☐ Code changes follow project standards
☐ Tests pass and provide good coverage
☐ No regressions introduced
☐ Documentation updated if required
☐ Code review completed (if applicable)
☐ Implementation tested in realistic scenarios
```

### Risk Management During Execution

**When Issues Are Discovered:**

```bash
[Agent-Name]: ISSUE DISCOVERED in Task [TASK-ID]

TASK: [Task-ID]: [Task Title]
ISSUE TYPE: [IMPLEMENTATION CHALLENGE | UNEXPECTED COMPLEXITY |
            MISSING REQUIREMENTS | TECHNICAL LIMITATION |
            EXTERNAL DEPENDENCY | SCOPE CHANGE]

ISSUE DESCRIPTION:
[Clear description of what was discovered]

IMPACT ASSESSMENT:
- Effect on current task: [How this impacts completion]
- Effect on dependent tasks: [Cascade effects if any]
- Timeline impact: [Delay or schedule changes needed]
- Risk level: [LOW | MEDIUM | HIGH | CRITICAL]

PROPOSED SOLUTIONS:
1. [Option 1 - Description and pros/cons]
2. [Option 2 - Description and pros/cons]
3. [Option 3 - Description and pros/cons]

RECOMMENDED APPROACH:
[Which solution to pursue and why]

ADDITIONAL RESOURCES NEEDED:
[If any additional help, tools, or information required]

ESCALATION REQUIRED: [YES/NO - If yes, to whom and why]
```

### Coordination Between Agents

**When Tasks Require Cross-Agent Collaboration:**

```bash
[Agent-Name]: COLLABORATION NEEDED for Task [TASK-ID]

TASK: [Task-ID]: [Task Title]
COLLABORATION TYPE: [SHARED RESPONSIBILITY | DEPENDENT WORK |
                   COORDINATED IMPLEMENTATION | REVIEW REQUIRED]

COLLABORATING AGENTS:
- [Primary Agent]: [Role and responsibility]
- [Supporting Agent]: [Role and responsibility]
- [Review Agent]: [Role and responsibility]

COORDINATION DETAILS:
[What needs to be coordinated between agents]

SHARED DELIVERABLES:
- [Deliverable 1]: [Which agent owns, who needs to review]
- [Deliverable 2]: [Which agent owns, who needs to review]

COMMUNICATION PLAN:
- [How and when agents should coordinate]
- [Status update frequency]
- [Decision-making process]

SUCCESS CRITERIA:
- [What successful collaboration looks like]
- [How to validate collaborative work]
```

---

## COMMAND REFERENCE LIBRARY

### Quick Copy-Paste Commands

#### Tier 1 Execution

```bash
Agent-Organizer: Execute TIER 1 (CRITICAL) tasks from the master task list.

TIER 1 SCOPE:
Execute all tasks marked as CRITICAL severity from
hierarchical-initialization-tasks.md

[Use full command from Tier 1 section above]
```

#### Tier 2 Execution

```bash
Agent-Organizer: Execute TIER 2 (HIGH PRIORITY) tasks from the master
task list.

PREREQUISITES MET:
- [X] Tier 1 is complete and validated
- [X] All Tier 1 fixes are working
- [X] Ready to proceed to foundational work

[Use full command from Tier 2 section above]
```

#### Tier 3 & 4 Execution

```bash
Agent-Organizer: Execute TIER 3 & 4 (REFINEMENT & POLISH) tasks.

TIER 3 SCOPE: MEDIUM PRIORITY - Code quality and refinement
TIER 4 SCOPE: LOW PRIORITY - Polish and nice-to-haves

[Use full command from Tier 3/4 section above]
```

#### Individual Task Assignment

```bash
[Agent-name]: Execute Task [TASK-ID]: [Task Title]

TASK SPECIFICATION:
[Full task details from master list including:
- Issue description
- Solution specification
- Implementation steps
- Code examples
- Acceptance criteria]

SUCCESS INDICATORS (you're done when):
- [ ] Acceptance criterion 1 is met
- [ ] Acceptance criterion 2 is met
- [ ] Tests pass for this task
- [ ] No new errors introduced
- [ ] Code follows project standards

STATUS UPDATE REQUIRED:
When complete, provide:
1. What was changed (files modified)
2. How you verified success (tests passed, etc.)
3. Any blockers encountered
4. Any issues discovered in implementation
5. Status: [Completed | Incomplete | Blocked]
```

#### Status Update

```bash
[Agent-Name]: Task [TASK-ID] Status Update

TASK: [Task-ID]: [Task Title]
ASSIGNED: [Agent Name]
STATUS: Completed

WHAT WAS CHANGED:
- [File 1] - [Brief description of changes]
- [File 2] - [Brief description of changes]

VERIFICATION:
- [ ] Acceptance criterion 1 met
- [ ] Acceptance criterion 2 met
- [ ] Tests passing
- [ ] No regressions detected

BLOCKERS: None | [List if any]
ISSUES FOUND: None | [List if any]

Ready for: Next task | Validation
```

---

## SUCCESS CRITERIA

### Execution Success Requirements

**Per Tier:**
- ✅ All tasks in tier executed according to specifications
- ✅ Acceptance criteria met for each task
- ✅ No regressions introduced
- ✅ Dependencies properly managed
- ✅ Quality standards maintained

**Overall Project:**
- ✅ All critical issues resolved
- ✅ System stability improved
- ✅ Performance optimized
- ✅ Code quality enhanced
- ✅ Documentation updated

### Quality Metrics

- **Task Completion Rate**: 100% of tasks completed successfully
- **Acceptance Criteria Met**: 100% of criteria satisfied
- **Regression Rate**: <5% of tasks cause new issues
- **Quality Standards**: 100% compliance with project standards
- **Timeline Adherence**: Within 10% of estimated duration

---

## NEXT STEPS

After completing Task Execution:

1. **Proceed to Part 6: Task Completion Validation**
   - Karen conducts final reality assessment
   - Jenny conducts final specification verification
   - Generate comprehensive completion report

2. **Project Completion**
   - All changes committed and tested
   - Documentation updated
   - Ready for production deployment

---

**Part 5 Complete: You now have comprehensive procedures for executing validated tasks across all tiers with Agent-Organizer coordination and specialist agent implementation.**