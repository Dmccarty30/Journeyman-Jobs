Execute Phase 2: Relational Analysis & Task Generation

PHASE 2 OVERVIEW:
This phase invokes 5 specialist agents SEQUENTIALLY to perform deeper analysis
and generate comprehensive task list.

Duration: 2-3 hours
Agents: 5 (sequential execution with context passing)
Output: Phase 2 Report + Comprehensive Task List

---

STEP 1: DISPLAY PHASE 2 START BANNER
"
╔═══════════════════════════════════════════════════════════╗
║  PHASE 2: RELATIONAL ANALYSIS & TASK GENERATION          ║
║  Duration: 2-3 hours                                      ║
║  Agents: 5 (sequential with context passing)             ║
╚═══════════════════════════════════════════════════════════╝

Invocation Order: SEQUENTIAL (each builds on prior)
├─ Agent 1: identifier-and-relational-expert
├─ Agent 2: dependency-inconsistency-resolver
├─ Agent 3: performance-optimization-wizard
├─ Agent 4: codebase-refactorer
└─ Agent 5: standards-enforcer

Plus: Task-Expert Skill (generates task list from findings)

Coordination: Error Eliminator Commander
Status: PHASE 2 ANALYSIS BEGINNING...
"

---

STEP 2: INVOKE AGENT 1 - IDENTIFIER & RELATIONAL EXPERT
Agent Name: identifier-and-relational-expert
Model: Opus
Priority: HIGH

Instruction (exact):

"identifier-and-relational-expert: Map all module relationships and dependencies.

INPUT CONTEXT:
Phase 1 Findings: [Insert Phase 1 Report]

MISSION: Discover and map all connections, relationships, and dependencies
in the codebase. Identify how components interact and impact each other.

TARGET CODEBASE: [path/to/codebase]

RELATIONSHIP MAPPING SCOPE:
1. Module dependencies - Who imports whom
2. Service-to-service communication
3. Database entity relationships
4. API contracts and dependencies
5. Data flow between components
6. Event/message passing patterns
7. Configuration dependencies
8. Cross-cutting concerns (logging, auth, etc.)

ANALYSIS REQUIREMENTS:
- Map ENTIRE codebase relationships
- Identify ALL connections
- Analyze dependency strength
- Find hidden dependencies
- Assess coupling levels
- Identify critical paths

OUTPUT FORMAT - For each relationship:
├─ Source Module: [Component initiating]
├─ Target Module: [Component depended upon]
├─ Relationship Type: [Import/API/DB/Event/etc]
├─ Strength: CRITICAL / HIGH / MEDIUM / LOW
├─ Ripple Analysis: [What breaks if target changes]
├─ Coupling Assessment: TIGHT / LOOSE / DECOUPLED
├─ Improvement Path: [How to decouple if too tight]
└─ Priority: [Priority of improvement]

DELIVERABLE:
Generate comprehensive relational analysis report:

1. Dependency Graph: Visual representation of all relationships
2. Critical Paths: Most important dependencies
3. Circular Dependencies: Any cycles found?
4. Hidden Dependencies: Non-obvious relationships
5. Bottleneck Analysis: Components over-relied upon
6. Change Impact Assessment: If X changes, what's affected?
7. Improvement Recommendations: Decouple tight relationships

Save report as: RELATIONAL_ANALYSIS_REPORT.md

Begin relationship mapping immediately.
Map entire codebase.
Report all relationships.
Be thorough and complete."

Wait for completion and save to: reports/relational_analysis.md

---

STEP 3: INVOKE AGENT 2 - DEPENDENCY INCONSISTENCY RESOLVER
Agent Name: dependency-inconsistency-resolver
Model: Sonnet
Priority: HIGH

Instruction (exact):

"dependency-inconsistency-resolver: Audit all dependencies for conflicts and issues.

INPUT CONTEXT:
Phase 1 Findings: [Insert Phase 1 Report]
Relational Analysis: [Insert relational_analysis.md]

MISSION: Audit all dependencies (external and internal) for conflicts,
inconsistencies, incompatibilities, and version issues.

TARGET: [path/to/codebase]

DEPENDENCY AUDIT SCOPE:
1. Package versions and version conflicts
2. Missing dependencies
3. Transitive dependency issues
4. Version pinning vs. flexible versioning
5. Breaking changes in dependencies
6. License compatibility
7. Security advisories on dependencies
8. Dependency deprecation warnings
9. Platform/environment incompatibilities
10. Internal module version mismatches

ANALYSIS REQUIREMENTS:
- Audit ALL dependencies completely
- Identify ALL conflicts
- Analyze compatibility
- Assess security risks
- Find resolution paths

OUTPUT FORMAT - For each issue:
├─ Location: [Where dependency declared]
├─ Dependency Name: [Package/module name]
├─ Current Version: [Installed version]
├─ Conflict Type: [Version/missing/deprecated/etc]
├─ Affected Components: [What uses this]
├─ Severity: CRITICAL / HIGH / MEDIUM / LOW
├─ Resolution Path: [How to fix]
├─ Resolution Risk: NONE / LOW / MEDIUM / HIGH
└─ Recommended Version: [What to upgrade to]

DELIVERABLE:
Generate comprehensive dependency audit report:

1. Dependency List: All external dependencies with versions
2. Conflict Report: All version conflicts and incompatibilities
3. Missing Dependencies: Unreachable or missing packages
4. Deprecation Warnings: Deprecated packages still in use
5. Security Issues: Known CVEs in dependencies
6. Update Recommendations: Safe versions to upgrade to
7. Resolution Plan: Step-by-step resolution strategy

Save report as: DEPENDENCY_AUDIT_REPORT.md

Begin dependency audit immediately.
Audit all dependencies.
Report all issues.
Be thorough and complete."

Wait for completion and save to: reports/dependency_audit.md

---

STEP 4: INVOKE AGENT 3 - PERFORMANCE OPTIMIZATION WIZARD
Agent Name: performance-optimization-wizard
Model: Opus
Priority: HIGH

Instruction (exact):

"performance-optimization-wizard: Identify all performance issues and optimizations.

INPUT CONTEXT:
Phase 1 Errors: [Insert Error Analysis]
Relational Analysis: [Insert relational_analysis.md]
Dependency Audit: [Insert dependency_audit.md]

MISSION: Conduct comprehensive performance analysis. Identify algorithmic
inefficiencies, memory issues, bottlenecks, and optimization opportunities.

TARGET CODEBASE: [path/to/codebase]

PERFORMANCE ANALYSIS SCOPE:
1. Algorithmic inefficiencies (O(n²) where O(n) possible)
2. Memory leaks and resource management
3. Unnecessary object allocations
4. Inefficient data structures
5. N+1 query patterns
6. Missing caching opportunities
7. Synchronous operations where async beneficial
8. Blocking operations
9. Inefficient string operations
10. Database query optimization

ANALYSIS REQUIREMENTS:
- Scan ENTIRE codebase for performance issues
- Identify ALL inefficiencies
- Analyze algorithmic complexity
- Assess actual performance impact
- Suggest specific optimizations

OUTPUT FORMAT - For each issue:
├─ Location: [File path:line numbers]
├─ Issue Type: [Category from above]
├─ Current Behavior: [What's happening]
├─ Performance Impact: [How slow is it?]
├─ Algorithmic Complexity: [Big O analysis]
├─ Root Cause: [Why is it inefficient?]
├─ Optimization Strategy: [How to improve]
├─ Expected Improvement: [Estimated gain]
├─ Implementation Complexity: SIMPLE / MEDIUM / COMPLEX
└─ Priority: CRITICAL / HIGH / MEDIUM / LOW

DELIVERABLE:
Generate comprehensive performance analysis report:

1. Bottleneck Analysis: Slowest parts of codebase
2. Memory Profiling: Memory usage issues
3. Algorithm Analysis: Algorithmic inefficiencies
4. Data Structure Review: Suboptimal data structures
5. Optimization Recommendations: Specific improvements
6. Priority Ranking: By performance impact
7. Implementation Difficulty: For each optimization

Save report as: PERFORMANCE_ANALYSIS_REPORT.md

Begin performance analysis immediately.
Analyze entire codebase.
Report all performance issues.
Be thorough and complete."

Wait for completion and save to: reports/performance_analysis.md

---

STEP 5: INVOKE AGENT 4 - CODEBASE REFACTORER
Agent Name: codebase-refactorer
Model: Opus
Priority: HIGH

Instruction (exact):

"codebase-refactorer: Recommend structural improvements and design patterns.

INPUT CONTEXT:
Phase 1 & Prior Analysis: [Insert all prior reports]

MISSION: Analyze code structure and recommend improvements. Suggest design
patterns, architectural improvements, and code readability enhancements.

TARGET CODEBASE: [path/to/codebase]

REFACTORING ANALYSIS SCOPE:
1. Design pattern implementation (Factory, Strategy, Observer, etc.)
2. Code duplication elimination
3. Function decomposition (large functions)
4. Class responsibility realignment
5. Inheritance hierarchy improvements
6. Interface segregation
7. Composition over inheritance
8. Architectural layering improvements
9. Module organization optimization
10. Code readability improvements

ANALYSIS REQUIREMENTS:
- Analyze ENTIRE codebase structure
- Identify ALL refactoring opportunities
- Recommend design patterns
- Suggest architectural improvements
- Assess impact and benefits

OUTPUT FORMAT - For each opportunity:
├─ Location: [File path and sections]
├─ Current Structure: [How organized now]
├─ Issue: [What's wrong with structure]
├─ Refactoring Approach: [Recommended design pattern]
├─ Benefits: [Maintainability/readability/testability gains]
├─ Complexity: SIMPLE / MEDIUM / COMPLEX
├─ Risk Level: NONE / LOW / MEDIUM / HIGH
├─ Testing Requirements: [What needs testing]
└─ Priority: CRITICAL / HIGH / MEDIUM / LOW

DELIVERABLE:
Generate comprehensive refactoring recommendations report:

1. Structural Issues: Code structure problems identified
2. Design Pattern Recommendations: Patterns to implement
3. Code Duplication: Areas of repeated code
4. Large Functions: Functions to decompose
5. Architectural Improvements: Layering, module organization
6. Readability Issues: Naming, comment, clarity problems
7. Refactoring Priority: By business value and complexity
8. Implementation Strategy: Step-by-step approach

Save report as: REFACTORING_RECOMMENDATIONS_REPORT.md

Begin refactoring analysis immediately.
Analyze entire codebase.
Report all refactoring opportunities.
Be thorough and complete."

Wait for completion and save to: reports/refactoring_recommendations.md

---

STEP 6: INVOKE AGENT 5 - STANDARDS ENFORCER
Agent Name: standards-enforcer
Model: Sonnet
Priority: MEDIUM

Instruction (exact):

"standards-enforcer: Audit code standards and consistency.

INPUT CONTEXT:
Phase 1 & Prior Analysis: [Insert all prior reports]

MISSION: Audit codebase for standards compliance. Ensure consistency in
formatting, naming, best practices, and project standards.

TARGET CODEBASE: [path/to/codebase]

STANDARDS AUDIT SCOPE:
1. Naming conventions (camelCase, snake_case, PascalCase)
2. Formatting and indentation (spaces vs. tabs)
3. File organization and structure
4. Import/include statement ordering
5. Documentation comments and inline comments
6. Error handling patterns
7. Logging patterns and levels
8. Configuration management
9. Environment variable usage
10. Testing conventions

ANALYSIS REQUIREMENTS:
- Audit ENTIRE codebase for standards
- Identify ALL violations
- Assess scope of violations
- Suggest fixes where possible
- Identify automation opportunities

OUTPUT FORMAT - For each violation:
├─ Location: [File path:line numbers]
├─ Standard: [Which standard violated]
├─ Current State: [What's the violation]
├─ Expected State: [What should it be]
├─ Scope: [How many instances?]
├─ Severity: CRITICAL / HIGH / MEDIUM / LOW
├─ Automated Fix Possible: YES / NO / PARTIAL
├─ Tooling Available: [Linter, formatter, etc]
└─ Priority: [Priority for fixing]

DELIVERABLE:
Generate comprehensive standards audit report:

1. Naming Inconsistencies: Variables, functions, classes
2. Formatting Issues: Indentation, spacing, line length
3. Documentation Gaps: Missing or inadequate comments
4. Error Handling Violations: Inconsistent exception handling
5. Best Practice Violations: Anti-patterns in use
6. Configuration Issues: Environment/config management
7. Testing Gaps: Missing or inadequate tests
8. Automation Opportunities: Standards that can be auto-fixed

Save report as: STANDARDS_AUDIT_REPORT.md

Begin standards audit immediately.
Audit entire codebase.
Report all violations.
Be thorough and complete."

Wait for completion and save to: reports/standards_audit.md

---

STEP 7: INVOKE TASK-EXPERT SKILL - GENERATE TASK LIST
Skill: task-generator (or Task-Expert SKILL)

Instruction (exact):

"Task-Expert: Convert all Phase 2 analysis findings into comprehensive task list.

PHASE 2 FINDINGS:
[Insert all 5 agent reports:
- relational_analysis.md
- dependency_audit.md
- performance_analysis.md
- refactoring_recommendations.md
- standards_audit.md
]

PLUS Phase 1 FINDINGS:
[Insert Phase 1 Report with all security, error, and dead code findings]

MISSION: Generate a comprehensive, structured task list from all findings.
Prioritize tasks.
Group related tasks.
Identify dependencies.
Estimate complexity.

TASK GENERATION REQUIREMENTS:

For each issue/recommendation from all reports:
Create structured task with:
├─ Task ID: [Unique identifier: SEC-001, ERR-001, PERF-001, etc]
├─ Title: [Clear, action-oriented title]
├─ Priority: CRITICAL / HIGH / MEDIUM / LOW
├─ Type: [Security/Error/Performance/Refactoring/Standards/Dependency/Cleanup]
├─ Complexity: SIMPLE / MEDIUM / COMPLEX / VERY COMPLEX
├─ Estimated Duration: [X hours or days]
├─ Description: [What needs to be done?]
├─ Root Cause: [Why does this exist?]
├─ Solution: [How to fix it?]
├─ Dependencies: [Other tasks that must complete first]
├─ Verification: [How to verify it's fixed?]
└─ Acceptance Criteria: [How to know it's done]

TIER GROUPING:
Group tasks into implementation tiers:

Tier 1 (Security Hardening):
- All SEC-* tasks (security issues)
- Critical priority
- Must execute first

Tier 2 (Error & Dependency Fixes):
- All ERR-* tasks (error fixes)
- All DEP-* tasks (dependency resolution)
- High priority
- Must execute after Tier 1

Tier 3 (Optimization & Refactoring):
- All PERF-* tasks (performance)
- All REF-* tasks (refactoring)
- Medium priority
- Must execute after Tier 2

Tier 4 (Standards & Cleanup):
- All STD-* tasks (standards)
- All CLN-* tasks (cleanup)
- Lower priority
- Execute after Tier 3

TASK SEQUENCING:
Within each tier:
- Identify task dependencies
- Sequence for optimal implementation
- Group related tasks together
- Minimize rework

DELIVERABLE:
Generate comprehensive task list document:

Format:
# PHASE 2 TASK LIST - GENERATED

## Executive Summary
- Total tasks: X
- By priority: CRITICAL [X], HIGH [X], MEDIUM [X], LOW [X]
- By type: Security [X], Error [X], Performance [X], etc
- Total estimated effort: [X hours/days]

## Tier 1: Security Hardening (X tasks, Y hours)
[SEC-001 through SEC-XXX with full details]

## Tier 2: Error & Dependency Fixes (X tasks, Y hours)
[ERR-001 through ERR-XXX and DEP-001 through DEP-XXX]

## Tier 3: Optimization & Refactoring (X tasks, Y hours)
[PERF-001 through PERF-XXX and REF-001 through REF-XXX]

## Tier 4: Standards & Cleanup (X tasks, Y hours)
[STD-001 through STD-XXX and CLN-001 through CLN-XXX]

## Dependency Analysis
[Task dependencies and sequencing constraints]

## Implementation Strategy
[Recommended order and approach]

Save report as: PHASE_2_TASK_LIST.md

Generate complete task list now."

Wait for completion and save to: reports/phase_2_task_list.md

---

STEP 8: CONSOLIDATE PHASE 2 FINDINGS
Create consolidated Phase 2 Report: reports/phase_2_report.md

Structure:
"
# PHASE 2 REPORT: Relational Analysis & Task Generation

## Executive Summary
- Analysis date: [timestamp]
- New findings: X (additional to Phase 1)
- Total tasks generated: X
- By priority: CRITICAL [X], HIGH [X], MEDIUM [X], LOW [X]
- Estimated implementation effort: [X hours]

## Task Inventory by Tier

### Tier 1: Security Hardening
Tasks: X | Estimated: Y hours | Priority: CRITICAL

### Tier 2: Error & Dependency Fixes
Tasks: X | Estimated: Y hours | Priority: HIGH

### Tier 3: Optimization & Refactoring
Tasks: X | Estimated: Y hours | Priority: MEDIUM

### Tier 4: Standards & Cleanup
Tasks: X | Estimated: Y hours | Priority: LOWER

## Implementation Strategy
[Recommended approach and sequencing]

## Dependency Analysis
[Critical dependencies and constraints]

Phase 2 Status: ✅ COMPLETE
"

---

STEP 9: PHASE 2 COMPLETION
Display:
"
✅ PHASE 2 COMPLETE: Relational Analysis & Task Generation

Phase 2 Report: reports/phase_2_report.md
Task List: reports/phase_2_task_list.md

Phase 2 Findings:
- Relational dependencies: X analyzed
- Dependency conflicts: X identified
- Performance issues: X found
- Refactoring opportunities: X identified
- Standards violations: X found

Task Generation:
- Total tasks: X
- Tier 1 (Security): X tasks
- Tier 2 (Errors/Deps): X tasks
- Tier 3 (Optimization): X tasks
- Tier 4 (Standards): X tasks

Estimated implementation effort: X hours

Ready for Validation Gate 2

Next Command: /phase-2-validate
"

END COMMAND