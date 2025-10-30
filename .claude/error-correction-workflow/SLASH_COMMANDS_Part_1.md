# CUSTOM SLASH COMMANDS - PART 1

## Workflow Start, Phase 1, and Phase 2 Commands

**Version:** 2.0  
**Last Updated:** October 29, 2025  
**Purpose:** Complete slash commands for Error Elimination Workflow execution

---

## TABLE OF CONTENTS

- [CUSTOM SLASH COMMANDS - PART 1](#custom-slash-commands---part-1)
  - [Workflow Start, Phase 1, and Phase 2 Commands](#workflow-start-phase-1-and-phase-2-commands)
  - [TABLE OF CONTENTS](#table-of-contents)
  - [/workflow-init](#workflow-init)
  - [/workflow-start](#workflow-start)
  - [/phase-1](#phase-1)
  - [/phase-1-validate](#phase-1-validate)
  - [/phase-2](#phase-2)
  - [/phase-2-validate](#phase-2-validate)
  - [/phase-2-task-generation](#phase-2-task-generation)

---

## /workflow-init

```bash
/workflow-init

Initialize Error Elimination Workflow Environment

PRE-INITIALIZATION CHECKLIST:
Verify the following are ready:
□ Target codebase identified
□ Read/write permissions verified
□ Directory structure created (.claude/agents, reports, logs, workflows)
□ All 13 agents installed in .claude/agents/
□ Task-Expert SKILL installed
□ 4-6 hours of uninterrupted time available
□ Workspace quiet and focused
□ Documentation available
□ Team available for decisions

---

INITIALIZATION STEPS:

STEP 1: VERIFY AGENTS INSTALLED
Agents required:
✓ error-eliminator.md
✓ security-vulnerability-hunter.md
✓ root-cause-analysis-expert.md
✓ dead-code-eliminator.md
✓ identifier-and-relational-expert.md
✓ dependency-inconsistency-resolver.md
✓ performance-optimization-wizard.md
✓ codebase-refactorer.md
✓ standards-enforcer.md
✓ codebase-composer.md
✓ testing-and-validation-specialist.md
✓ karen-reality-manager.md
✓ Jenny-spec-auditor.md

Check: Display list of installed agents in .claude/agents/
If any missing: Install from Part 1 documentation before proceeding.

---

STEP 2: VERIFY DIRECTORY STRUCTURE
Required directories:
✓ .claude/agents/ (agents directory)
✓ .claude/skills/ (skills directory)
✓ reports/ (for generated reports)
✓ logs/ (for execution logs)
✓ workflows/ (documentation)

Check: Verify all directories exist with write permissions
If missing: Create using provided directory structure

---

STEP 3: ENVIRONMENT SETUP
Create workflow environment:
- Initialize execution log: logs/error_elimination.log
- Create workflow state file: logs/workflow_state.json
- Verify codebase accessible
- Verify all files readable

---

STEP 4: PRE-WORKFLOW VALIDATION
Final checks before starting:
- Codebase is version controlled (recommend backup)
- No uncommitted changes (recommend clean state)
- Documentation accessible
- All stakeholders aware

---

STEP 5: GENERATE INITIALIZATION REPORT
Create: logs/workflow_initialization.log

Report contents:
- Initialization timestamp
- Agents verified: ✓ All 13 installed
- Directory structure: ✓ Complete
- Permissions: ✓ Verified
- Codebase state: [committed/clean]
- Status: ✓ READY TO START

---

STEP 6: DISPLAY INITIALIZATION SUMMARY

Output:
"
╔═══════════════════════════════════════════════════════════╗
║  ERROR ELIMINATION WORKFLOW - INITIALIZATION COMPLETE ✅   ║
╚═══════════════════════════════════════════════════════════╝

✓ All 13 agents installed
✓ Directory structure complete
✓ Permissions verified
✓ Codebase ready
✓ Documentation accessible

WORKFLOW STATUS: READY TO START

Estimated Duration: 4-6 hours
- Phase 1: 2-3 hours
- Phase 2: 2-3 hours
- Phase 3: 4-6 hours
- Phase 4: 1-2 hours

Next Command: /workflow-start
"

---

If any issues found, resolve them before proceeding to /workflow-start

END COMMAND
```

---

## /workflow-start

```bash
/workflow-start

START ERROR ELIMINATION WORKFLOW - FULL ORCHESTRATION

WORKFLOW START SEQUENCE:

STEP 1: ANNOUNCE WORKFLOW START
Display:
"
╔═══════════════════════════════════════════════════════════╗
║     ERROR ELIMINATION WORKFLOW - PHASE 1 STARTING        ║
╚═══════════════════════════════════════════════════════════╝

Beginning comprehensive 4-phase error elimination workflow.
All 10 specialist agents will be coordinated.
Karen and Jenny will validate at each gate.

Target Codebase: [target]
Duration Estimate: 4-6 hours
Status: STARTING PHASE 1...
"

---

STEP 2: INITIALIZE PHASE 1
Proceed directly to: /phase-1

Include context:
- Current workflow state: PHASE 1 START
- All prior initialization complete
- Ready to begin Phase 1 analysis

END COMMAND
```

---

## /phase-1

```bash
/phase-1

Execute Phase 1: Initial Threat & Error Assessment

PHASE 1 OVERVIEW:
This phase invokes 3 specialist agents in PARALLEL to scan the codebase
and identify security threats, errors/exceptions, and dead code.

Duration: 2-3 hours
Agents: 3 (parallel execution)
Output: Phase 1 Report with all findings

---

STEP 1: DISPLAY PHASE 1 START BANNER
"
╔═══════════════════════════════════════════════════════════╗
║  PHASE 1: INITIAL THREAT & ERROR ASSESSMENT              ║
║  Duration: 2-3 hours                                      ║
║  Agents: 3 (security, errors, dead code)                 ║
╚═══════════════════════════════════════════════════════════╝

Invocation Order: PARALLEL (all 3 agents simultaneously)
├─ Agent 1: security-vulnerability-hunter
├─ Agent 2: root-cause-analysis-expert  
└─ Agent 3: dead-code-eliminator

Coordination: Error Eliminator Commander
Status: PHASE 1 ANALYSIS BEGINNING...
"

---

STEP 2: INVOKE AGENT 1 - SECURITY VULNERABILITY HUNTER
Agent Name: security-vulnerability-hunter
Model: Opus
Priority: CRITICAL

Instruction (exact):

"security-vulnerability-hunter: Begin comprehensive security vulnerability audit.

MISSION: Scan entire codebase for all security vulnerabilities and weaknesses.

TARGET CODEBASE: [path/to/codebase]

VULNERABILITY CATEGORIES (search exhaustively for all):
1. SQL Injection - Unsanitized database queries
2. Cross-Site Scripting (XSS) - Unescaped output, DOM manipulation
3. Authentication Flaws - Weak password storage, insecure token handling
4. Authorization Bypasses - Missing permission checks, role bypass
5. Cryptographic Weaknesses - Weak algorithms, poor key management
6. Data Exposure - Sensitive data logging, cleartext transmission
7. Insecure Deserialization - Untrusted input deserialization
8. Command Injection - OS command execution from user input
9. Path Traversal - Directory traversal in file operations
10. Denial of Service - Resource exhaustion, infinite loops

ANALYSIS REQUIREMENTS:
- Scan ENTIRE codebase completely
- Identify EVERY vulnerability found
- No vulnerability too minor to report
- Provide specific file paths and line numbers
- Explain severity and impact clearly

OUTPUT FORMAT - For each vulnerability:
├─ Location: [file path:line number]
├─ Vulnerability Type: [Category from above]
├─ Severity: CRITICAL / HIGH / MEDIUM / LOW
├─ Description: [Clear explanation]
├─ Attack Vector: [How attacker could exploit]
├─ Impact: [Potential damage if exploited]
├─ Proof of Concept: [Attack scenario if applicable]
├─ Remediation: [Specific fix with code example]
└─ Confidence Level: HIGH / MEDIUM / LOW

CONSTRAINTS:
- Report ACTUAL vulnerabilities only (security implications required)
- Provide specific locations and line numbers
- Explain security impact clearly
- Provide proof-of-concept or attack vector
- Focus on REAL risks not theoretical concerns

DELIVERABLE:
Generate comprehensive security vulnerability report.
Include executive summary with:
- Total vulnerabilities found: [X]
- By severity: CRITICAL [X], HIGH [X], MEDIUM [X], LOW [X]
- Vulnerability categories affected: [list]
- Overall security risk level: CRITICAL / HIGH / MEDIUM / LOW

Save report as: SECURITY_VULNERABILITIES_ANALYSIS.md

Begin security audit immediately.
Scan entire codebase.
Report all vulnerabilities found.
Be thorough and complete."

Wait for completion and save output to: reports/security_vulnerabilities.md

---

STEP 3: INVOKE AGENT 2 - ROOT CAUSE ANALYSIS EXPERT
Agent Name: root-cause-analysis-expert
Model: Opus
Priority: CRITICAL

Instruction (exact):

"root-cause-analysis-expert: Begin comprehensive error and exception analysis.

MISSION: Analyze entire codebase for all errors, exceptions, and logical flaws.
Trace each to its root cause.

TARGET CODEBASE: [path/to/codebase]

ERROR CATEGORIES (search exhaustively):
1. Null pointer exceptions and undefined references
2. Type mismatches and casting errors
3. Off-by-one errors and boundary conditions
4. Missing null checks and validation
5. Incorrect algorithmic logic
6. Resource leaks (file handles, connections, memory)
7. Exception handling gaps
8. Race conditions and concurrency issues
9. Infinite loops or stack overflows
10. Incorrect state transitions

ANALYSIS REQUIREMENTS:
- Analyze ENTIRE codebase completely
- Find EVERY error and logical flaw
- Trace to ROOT CAUSES (not just symptoms)
- Provide specific locations and line numbers
- Analyze error chains and cascades

OUTPUT FORMAT - For each error:
├─ Location: [file path:line number(s)]
├─ Error Type: [Category from above]
├─ Symptom: [What goes wrong]
├─ Root Cause: [Why does it go wrong]
├─ Call Stack: [Function chain leading to error]
├─ Contributing Factors: [Conditions enabling error]
├─ Impact: [What breaks downstream]
├─ Reproducibility: [How to trigger error consistently]
├─ Solution Approach: [How to fix it]
└─ Confidence Level: HIGH / MEDIUM / LOW

CONSTRAINTS:
- Report ACTUAL errors (not potential issues)
- Trace to root causes precisely
- Provide specific locations
- Include call stack and error chains
- Focus on real bugs and flaws

DELIVERABLE:
Generate comprehensive error analysis report.
Include executive summary with:
- Total errors found: [X]
- By severity: CRITICAL [X], HIGH [X], MEDIUM [X], LOW [X]
- Error categories: [list]
- Overall error risk level: CRITICAL / HIGH / MEDIUM / LOW

Save report as: ERROR_ANALYSIS_REPORT.md

Begin error analysis immediately.
Analyze entire codebase.
Report all errors found.
Trace to root causes.
Be thorough and complete."

Wait for completion and save output to: reports/errors_analysis.md

---

STEP 4: INVOKE AGENT 3 - DEAD CODE ELIMINATOR
Agent Name: dead-code-eliminator
Model: Sonnet
Priority: HIGH

Instruction (exact):

"dead-code-eliminator: Begin comprehensive dead code inventory.

MISSION: Identify all dead code and unused artifacts in codebase.
Create complete cleanup inventory.

TARGET CODEBASE: [path/to/codebase]

DEAD CODE CATEGORIES (search for all):
1. Unused imports and includes
2. Unused functions and methods (never called)
3. Unused variables and parameters
4. Unreachable code paths (dead branches)
5. Unused classes and interfaces
6. Commented-out code
7. Obsolete/deprecated functionality
8. Dead assignments (assigned but never read)
9. Unused exception handlers
10. Unused constants

ANALYSIS REQUIREMENTS:
- Scan ENTIRE codebase completely
- Find EVERY piece of dead code
- Classify by type
- Assess safety of removal
- Identify dependencies

OUTPUT FORMAT - For each dead code item:
├─ Location: [file path:line number(s)]
├─ Type: [Category from above]
├─ Item Name: [Function/variable/class name]
├─ Scope: [Where defined]
├─ Safety Analysis: [Safe to remove? Any dependencies?]
├─ Removal Risk: NONE / LOW / MEDIUM / HIGH
├─ Dependencies: [What depends on this item]
└─ Recommendation: REMOVE / KEEP / REVIEW

CONSTRAINTS:
- Flag items with unclear dependencies as REVIEW
- Identify cross-module dependencies
- Check for reflection-based access
- Verify no external dependencies
- Be conservative with risky items

DELIVERABLE:
Generate comprehensive dead code inventory.
Include executive summary with:
- Total dead code items: [X]
- By type: Imports [X], Functions [X], Variables [X], etc.
- Safe to remove: [X] items
- Requires review: [X] items
- Overall cleanup potential: [X% code reduction possible]

Save report as: DEAD_CODE_INVENTORY.md

Begin dead code scan immediately.
Scan entire codebase.
Report all dead code found.
Be thorough and complete."

Wait for completion and save output to: reports/dead_code_inventory.md

---

STEP 5: CONSOLIDATE PHASE 1 FINDINGS
After all 3 agents complete (parallel execution):

Create consolidated Phase 1 Report: reports/phase_1_report.md

Consolidated Report Structure:
"
# PHASE 1 REPORT: Initial Threat & Error Assessment

## Executive Summary
- Scan date: [timestamp]
- Total issues identified: X
- By severity: CRITICAL [X], HIGH [X], MEDIUM [X], LOW [X]
- Overall risk assessment: [CRITICAL / HIGH / MEDIUM / LOW]

## 1. Security Vulnerabilities
[From security-vulnerability-hunter]
- Total vulnerabilities: X
- Critical: X | High: X | Medium: X | Low: X
- Top vulnerability categories: [list]

## 2. Errors & Exceptions
[From root-cause-analysis-expert]
- Total errors found: X
- Critical: X | High: X | Medium: X | Low: X
- Most common error types: [list]
- Root causes identified: X

## 3. Dead Code Inventory
[From dead-code-eliminator]
- Total dead code items: X
- Safe to remove: X items
- Requires review: X items
- Estimated code reduction: X%

## Phase 1 Findings Summary
- All findings attributed to source agent
- All findings with specific locations
- All findings prioritized by severity
- All findings documented

Phase 1 Status: ✅ COMPLETE
"

---

STEP 6: PHASE 1 COMPLETION
Display:
"
✅ PHASE 1 COMPLETE: Initial Threat & Error Assessment

Phase 1 Report: reports/phase_1_report.md

Findings Summary:
- Security vulnerabilities: X identified
- Errors & exceptions: X identified
- Dead code items: X identified
- Total issues: X

All findings consolidated and attributed to source agent.

Ready for Validation Gate 1

Next Command: /phase-1-validate
"

END COMMAND
```

---

## /phase-1-validate

```bash
/phase-1-validate

Execute Validation Gate 1: Phase 1 Findings Verification

VALIDATION GATE 1 OVERVIEW:
Karen and Jenny assess Phase 1 findings for feasibility and completeness.

---

STEP 1: INVOKE KAREN - PROJECT REALITY MANAGER
Agent Name: karen-reality-manager
Model: Sonnet
Priority: CRITICAL

Instruction (exact):

"karen-reality-manager: Pragmatic feasibility assessment of Phase 1 findings.

PHASE 1 REPORT:
[Insert complete Phase 1 Report from reports/phase_1_report.md]

YOUR MISSION: Reality check Phase 1 findings
Question: Will these findings actually help improve the codebase?
Focus: Implementation feasibility and risk

ASSESSMENT CRITERIA:

Question 1: Issue Identification Realistic?
- Are identified issues actually real?
- Could these issues actually break the codebase?
- Are severity assessments realistic?
- Any obvious issues missed?
Assess: [Your evaluation]

Question 2: Prioritization Realistic?
- Is Critical severity appropriate for these issues?
- Would fixing High priority issues truly improve system?
- Does prioritization make practical sense?
Assess: [Your evaluation]

Question 3: Implementation Feasibility?
- Can identified issues actually be fixed?
- Are any issues impossible to resolve?
- Are proposed fixes technically viable?
- Any blockers or dependencies?
Assess: [Your evaluation]

Question 4: Resource Requirements Realistic?
- How much effort to address Phase 1 findings?
- Do we have necessary resources/skills?
- Is timeline realistic for fixes?
- Will this require external help?
Assess: [Your evaluation]

Question 5: Risk Assessment?
- Are critical risks identified in findings?
- Are there hidden risks not mentioned?
- Could Phase 1 findings cause problems if implemented?
- Any unintended consequences?
Assess: [Your evaluation]

SCORING:
Rate overall assessment 0-10:
10 = Fully realistic, completely feasible
8-9 = Realistic with minor concerns
6-7 = Mostly realistic, some concerns
4-5 = Partially realistic, significant concerns
2-3 = Questionable feasibility
0-1 = Not realistic/feasible

FINAL DECISION:
Based on your assessment, provide clear decision:
PASS = Phase 1 findings are realistic and feasible
CAUTION = Generally okay but proceed with noted concerns
REWORK = Significant issues require Phase 1 re-analysis

PROVIDE:
1. Detailed feasibility assessment
2. Scoring (0-10)
3. Clear PASS / CAUTION / REWORK decision
4. Reasoning for decision

Your assessment is the reality check.
Be pragmatic.
Report honest evaluation."

Wait for completion and save to: reports/gate_1_karen_assessment.md

---

STEP 2: INVOKE Jenny - SENIOR SOFTWARE ENGINEERING AUDITOR
Agent Name: Jenny-spec-auditor
Model: Opus
Priority: CRITICAL

Instruction (exact):

"Jenny-spec-auditor: Specification compliance audit of Phase 1 findings.

PHASE 1 REPORT:
[Insert complete Phase 1 Report from reports/phase_1_report.md]

YOUR MISSION: Audit Phase 1 completeness and compliance
Question: Are the findings complete and do they meet specifications?
Focus: Coverage, comprehensiveness, specification alignment

AUDIT CRITERIA:

Question 1: Security Coverage Complete?
- Did security-vulnerability-hunter cover all OWASP categories?
- Are common vulnerability types included?
- Security audit appears thorough and complete?
- Any obvious security categories missed?
Audit: [Your evaluation]

Question 2: Error Analysis Complete?
- Did root-cause-analysis-expert find all error types?
- Error root causes clearly traced?
- Analysis depth sufficient for planning fixes?
- Any error categories obviously missing?
Audit: [Your evaluation]

Question 3: Dead Code Identification Complete?
- Did dead-code-eliminator find all unused code types?
- Is dead code safely identifiable for removal?
- Are dependencies properly assessed?
- Any dead code categories obviously missed?
Audit: [Your evaluation]

Question 4: Attribution & Traceability Complete?
- Can each finding be traced to source agent?
- Is reasoning clear and justified?
- Documentation adequate and clear?
- Is traceability complete?
Audit: [Your evaluation]

Question 5: Specification Alignment?
- Do findings align with expected analysis scope?
- Are findings relevant to codebase?
- Is nothing out of scope?
- Does Phase 1 match expected deliverables?
Audit: [Your evaluation]

SCORING:
Rate overall audit 0-10:
10 = Comprehensive, well-documented, fully aligned
8-9 = Very good, minor gaps only
6-7 = Adequate coverage, some gaps
4-5 = Significant gaps identified
2-3 = Major gaps in coverage
0-1 = Severely incomplete

FINAL DECISION:
Based on your audit, provide clear decision:
PASS = Phase 1 findings are complete and compliant
CONCERN = Adequate but with noted gaps/concerns
FAIL = Significant gaps require Phase 1 re-analysis

PROVIDE:
1. Detailed compliance audit
2. Scoring (0-10)
3. Clear PASS / CONCERN / FAIL decision
4. Reasoning for decision

Your audit is the completeness check.
Be rigorous.
Report honest evaluation."

Wait for completion and save to: reports/gate_1_Jenny_audit.md

---

STEP 3: CONSOLIDATE GATE 1 DECISION
Decision Matrix:

Karen + Jenny both PASS = ✅ PASS GATE 1
Karen PASS + Jenny CONCERN = ✅ PASS WITH CAUTION
Karen CONCERN + Jenny PASS = ✅ PASS WITH CAUTION
Both CONCERN = ⚠️ PROCEED WITH CAUTION
Either FAIL / Disagreement = ❌ REWORK REQUIRED

---

STEP 4: ANNOUNCE GATE 1 DECISION
Display:

If PASS:
"
✅ VALIDATION GATE 1 PASSED

Karen Assessment: [Score/X10] - PASS
Jenny Assessment: [Score/X10] - PASS

Phase 1 findings are realistic, feasible, complete, and compliant.

Ready to proceed to Phase 2: Relational Analysis & Task Generation

Next Command: /phase-2
"

If CAUTION:
"
✅ VALIDATION GATE 1 PASSED WITH CAUTION

Karen Assessment: [Score/X10] - [Status]
Jenny Assessment: [Score/X10] - [Status]

Noted Concerns:
[List Karen and Jenny concerns]

Proceeding to Phase 2 with these concerns noted.
Monitor closely.

Next Command: /phase-2
"

If REWORK:
"
❌ VALIDATION GATE 1 FAILED - REWORK REQUIRED

Issues identified:
[Specific failures noted]

Action Required:
- Address identified issues
- Re-run Phase 1 analysis
- Re-validate

After rework, repeat: /phase-1-validate
"

END COMMAND
```

---

## /phase-2

```bash
/phase-2

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
```

---

## /phase-2-validate

```bash
/phase-2-validate

Execute Validation Gate 2: Phase 2 Task Feasibility & Completeness

VALIDATION GATE 2 OVERVIEW:
Karen and Jenny assess Phase 2 findings and task list for feasibility and
completeness before implementation begins.

---

STEP 1: INVOKE KAREN - PROJECT REALITY MANAGER
Agent Name: karen-reality-manager
Model: Sonnet
Priority: CRITICAL

Instruction (exact):

"karen-reality-manager: Assess Phase 2 task list feasibility and resource requirements.

PHASE 2 REPORTS:
[Insert complete Phase 2 Report]
[Insert Phase 2 Task List]

YOUR MISSION: Reality check the task list
Question: Are these tasks actually doable within our constraints?
Focus: Feasibility, resources, timeline

ASSESSMENT CRITERIA:

Question 1: Task Clarity & Actionability?
- Are tasks clear and specific?
- Can developers understand what needs doing?
- Are acceptance criteria defined?
- Actionable by team?
Assess: [Your evaluation]

Question 2: Implementation Sequencing Logical?
- Is task ordering logical?
- Are dependencies properly identified?
- Can tasks execute in proposed order?
- Any sequencing issues?
Assess: [Your evaluation]

Question 3: Effort Estimation Realistic?
- Are time estimates realistic?
- Account for testing?
- Grounded in reality?
- Any over/under estimates?
Assess: [Your evaluation]

Question 4: Resource Requirements Met?
- Can we execute with available resources?
- Are there skill gaps?
- Is timeline achievable?
- Will we need external help?
Assess: [Your evaluation]

Question 5: Rework & Risk?
- What's risk of task failure?
- Are mitigation strategies evident?
- How many tasks might fail?
- Overall risk level?
Assess: [Your evaluation]

SCORING:
Rate overall feasibility 0-10

FINAL DECISION:
PASS = Tasks are feasible and realistic
CAUTION = Generally feasible but proceed with concerns
REWORK = Significant feasibility issues require revision

PROVIDE:
1. Detailed feasibility assessment
2. Scoring (0-10)
3. Clear decision: PASS / CAUTION / REWORK
4. Specific concerns if any

Your assessment determines if we proceed."

Wait for completion and save to: reports/gate_2_karen_assessment.md

---

STEP 2: INVOKE Jenny - SENIOR SOFTWARE ENGINEERING AUDITOR
Agent Name: Jenny-spec-auditor
Model: Opus
Priority: CRITICAL

Instruction (exact):

"Jenny-spec-auditor: Audit Phase 2 task completeness and specification alignment.

PHASE 2 REPORTS:
[Insert complete Phase 2 Report]
[Insert Phase 2 Task List]
[Insert Phase 1 Report for reference]

YOUR MISSION: Audit task list completeness
Question: Do these tasks address ALL identified issues?
Focus: Coverage, completeness, specification alignment

AUDIT CRITERIA:

Question 1: Issue Coverage Complete?
- Do tasks address ALL Phase 1 findings?
- Every security issue represented?
- Every error represented?
- Every dead code item represented?
Audit: [Your evaluation]

Question 2: Task Comprehensiveness?
- Does each task have sufficient detail?
- Root causes explained?
- Solutions justified?
- Verification criteria defined?
Audit: [Your evaluation]

Question 3: Specification Alignment?
- Do tasks align with specifications?
- All requirements addressed?
- Nothing out of scope?
- Scope appropriate?
Audit: [Your evaluation]

Question 4: Documentation Quality?
- Are task descriptions clear?
- Documentation adequate?
- Can someone execute these tasks?
- Understandable?
Audit: [Your evaluation]

Question 5: Tier Grouping & Priority?
- Are tasks appropriately grouped?
- Prioritization justified?
- Tier sequencing sensible?
- Implementation order logical?
Audit: [Your evaluation]

SCORING:
Rate overall completeness 0-10

FINAL DECISION:
PASS = Tasks are complete and address all issues
CONCERN = Mostly complete with minor gaps
FAIL = Significant gaps require task list revision

PROVIDE:
1. Detailed completeness audit
2. Scoring (0-10)
3. Clear decision: PASS / CONCERN / FAIL
4. Specific gaps if any

Your audit ensures completeness."

Wait for completion and save to: reports/gate_2_Jenny_audit.md

---

STEP 3: CONSOLIDATE GATE 2 DECISION
Decision Matrix:

Karen + Jenny both PASS = ✅ PASS GATE 2
Karen PASS + Jenny CONCERN = ✅ PASS WITH CAUTION
Karen CONCERN + Jenny PASS = ✅ PASS WITH CAUTION
Both CONCERN = ⚠️ PROCEED WITH CAUTION
Either FAIL / Disagreement = ❌ REWORK REQUIRED

---

STEP 4: ANNOUNCE GATE 2 DECISION
Display:

If PASS:
"
✅ VALIDATION GATE 2 PASSED

Karen Assessment: [Score/X10] - PASS
Jenny Assessment: [Score/X10] - PASS

Phase 2 task list is feasible, complete, and ready for implementation.

Ready to proceed to Phase 3: Implementation Execution

Phase 3 will execute tasks in 4 tiers:
- Tier 1: Security Hardening (X tasks)
- Tier 2: Error & Dependency Fixes (X tasks)
- Tier 3: Optimization & Refactoring (X tasks)
- Tier 4: Standards & Cleanup (X tasks)

Next Command: /phase-3-tier-1
"

If CAUTION:
"
✅ VALIDATION GATE 2 PASSED WITH CAUTION

Karen Assessment: [Score/X10] - [Status]
Jenny Assessment: [Score/X10] - [Status]

Noted Concerns:
[List concerns]

Proceeding to Phase 3 implementation.
Monitor task execution closely.

Next Command: /phase-3-tier-1
"

If REWORK:
"
❌ VALIDATION GATE 2 FAILED - REWORK REQUIRED

Issues identified:
[Specific failures]

Action Required:
- Regenerate task list addressing issues
- Re-sequence if needed
- Clarify task definitions

After rework, repeat: /phase-2-validate
"

END COMMAND
```

---

## /phase-2-task-generation

```bash
/phase-2-task-generation

Re-generate Phase 2 task list (if needing to regenerate)

Usage when: Tasks need to be regenerated, clarified, or re-sequenced

Invokes Task-Expert skill with Phase 2 findings.

Generates updated: reports/phase_2_task_list.md

Then run: /phase-2-validate

END COMMAND
```

---

- **End of Part 1 - Workflow Start, Phase 1, and Phase 2 Commands Ready**

Continue to Complete Slash Commands - Part 2 for Phase 3 and Phase 4 commands.
