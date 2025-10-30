# ENHANCED ERROR ELIMINATION WORKFLOW
## Part 2: Workflow Orchestration & Process Flow

**Document Version:** 2.0 (Enhanced)  
**Last Updated:** October 29, 2025  
**Purpose:** Comprehensive 4-phase orchestration strategy with detailed process flows

---

## TABLE OF CONTENTS

1. [Workflow Overview](#workflow-overview)
2. [Phase 1: Initial Threat & Error Assessment](#phase-1-initial-threat--error-assessment)
3. [Phase 2: Relational Analysis & Task Generation](#phase-2-relational-analysis--task-generation)
4. [Phase 3: Implementation Execution](#phase-3-implementation-execution)
5. [Phase 4: Final Validation & Delivery](#phase-4-final-validation--delivery)
6. [State Management Between Phases](#state-management-between-phases)
7. [Orchestration Rules & Constraints](#orchestration-rules--constraints)

---

## WORKFLOW OVERVIEW

The Error Elimination Workflow operates as a 4-phase systematic audit designed to identify, categorize, and resolve all issues within a codebase. Each phase builds on previous findings and progressively increases the scope and complexity of analysis.

### Workflow Architecture

```
┌─────────────────────────────────────────────────────────────┐
│         ERROR ELIMINATION WORKFLOW (4-PHASE)                │
├─────────────────────────────────────────────────────────────┤
│                                                              │
│  PHASE 1: Initial Assessment        [Duration: 2-3 hours]   │
│  ├─ Security Vulnerability Scan                             │
│  ├─ Root Cause Analysis                                     │
│  └─ Dead Code Identification                                │
│       ↓ (Findings consolidated)                             │
│  🔍 VALIDATION GATE 1: Karen + Jenny Assessment             │
│       ↓ (Pass/Fail decision)                                │
│                                                              │
│  PHASE 2: Relational Analysis        [Duration: 2-3 hours]   │
│  ├─ Module Relationships Mapping                            │
│  ├─ Dependency Inconsistency Analysis                       │
│  ├─ Performance Bottleneck Identification                   │
│  ├─ Code Refactoring Opportunities                          │
│  └─ Standards Compliance Audit                              │
│       ↓ (Findings + Task generation)                        │
│  🔍 VALIDATION GATE 2: Karen + Jenny Assessment             │
│       ↓ (Pass/Fail decision)                                │
│                                                              │
│  PHASE 3: Implementation Execution   [Duration: 4-6 hours]   │
│  ├─ Tier 1: Security Hardening                              │
│  ├─ Tier 2: Error & Dependency Fixes                        │
│  ├─ Tier 3: Optimization & Refactoring                      │
│  └─ Tier 4: Standards & Cleanup                             │
│       ↓ (After each tier completion)                        │
│  🔍 VALIDATION GATES 3A, 3B, 3C: Karen + Jenny Assessment   │
│       ↓ (Pass/Fail decision after each tier)                │
│                                                              │
│  PHASE 4: Final Validation & Delivery [Duration: 1-2 hours] │
│  ├─ Comprehensive Testing                                   │
│  ├─ Documentation Review                                    │
│  └─ Final Quality Assurance                                 │
│       ↓ (Final findings)                                    │
│  🔍 VALIDATION GATE 4: Karen + Jenny Final Assessment        │
│       ↓ (Final approval)                                    │
│                                                              │
│  ✅ WORKFLOW COMPLETE: Master Report Generated              │
│                                                              │
└─────────────────────────────────────────────────────────────┘
```

### Key Principles

1. **Sequential Phases**: Phases execute in order (1 → 2 → 3 → 4)
2. **Parallel Within Phase 1**: First three agents run in parallel for efficiency
3. **Sequential Within Phase 2-3**: Agents coordinate with previous findings
4. **Validation Gates**: Karen + Jenny validate before proceeding
5. **State Accumulation**: Each phase inherits findings from prior phases
6. **Full Traceability**: Every finding attributed to source agent

---

## PHASE 1: INITIAL THREAT & ERROR ASSESSMENT

### Duration: 2-3 hours
### Parallel Execution: YES
### Status: Foundation Analysis

### Phase Objective

Conduct an initial comprehensive scan of the codebase to identify immediate threats, obvious errors, and dead code. This phase establishes the foundation for deeper analysis in subsequent phases.

### Phase 1 Agents (Execute in Parallel)

**Agent 1: security-vulnerability-hunter**
**Agent 2: root-cause-analysis-expert**
**Agent 3: dead-code-eliminator**

### Orchestration Sequence

```
START PHASE 1
├─ TRIGGER: security-vulnerability-hunter
│  └─ Scan entire codebase for security vulnerabilities
│     ├─ SQL injection risks
│     ├─ XSS vulnerabilities
│     ├─ Authentication/Authorization flaws
│     ├─ Data exposure risks
│     └─ Cryptographic weaknesses
│
├─ TRIGGER: root-cause-analysis-expert
│  └─ Analyze errors and trace root causes
│     ├─ Null pointer exceptions
│     ├─ Type mismatches
│     ├─ Logic errors
│     ├─ Exception handling gaps
│     └─ Resource management issues
│
├─ TRIGGER: dead-code-eliminator
│  └─ Scan for unused code
│     ├─ Unused imports
│     ├─ Unreachable code paths
│     ├─ Unused functions/variables
│     ├─ Dead branches
│     └─ Obsolete functionality
│
└─ CONSOLIDATE: Compile findings into Phase 1 Report
   └─ All findings attributed to source agent
```

### Phase 1 Deliverables

Each agent produces:

**Security Vulnerability Hunter Output:**
- Vulnerability list with severity levels
- Specific file locations and line numbers
- Attack vector descriptions
- Proposed remediations
- Confidence levels for each finding

**Root Cause Analysis Expert Output:**
- Error catalog with root causes
- Call stack analysis for each error
- Contributing factors identified
- Cascade effect analysis
- Solution approaches

**Dead Code Eliminator Output:**
- Dead code inventory (classified by type)
- Safety assessment per item
- Dependency analysis
- Removal risk assessment

### Consolidated Phase 1 Report Format

```markdown
# PHASE 1 REPORT: Initial Threat & Error Assessment

## Executive Summary
- Total issues identified: X
- Critical severity: X
- High severity: X
- Medium severity: X
- Low severity: X

## 1. Security Vulnerabilities
[List from security-vulnerability-hunter]

## 2. Root Cause Analysis
[List from root-cause-analysis-expert]

## 3. Dead Code Inventory
[List from dead-code-eliminator]

## Recommended Phase 2 Focus Areas
[Priority ranking of findings]
```

---

## PHASE 2: RELATIONAL ANALYSIS & TASK GENERATION

### Duration: 2-3 hours
### Parallel Execution: NO (Sequential with context passing)
### Status: Analysis Deepening

### Phase Objective

Deepen the analysis by understanding how components relate, depend on each other, and impact each other. Generate comprehensive task list based on Phase 1 findings and Phase 2 analysis.

### Phase 2 Agents (Execute Sequentially)

**Agent 4: identifier-and-relational-expert** (First)
**Agent 5: dependency-inconsistency-resolver** (Uses relational context)
**Agent 6: performance-optimization-wizard** (Builds on error context)
**Agent 7: codebase-refactorer** (Uses all prior analysis)
**Agent 8: standards-enforcer** (Final analysis pass)

### Orchestration Sequence

```
START PHASE 2 (Using Phase 1 findings as context)
│
├─ STEP 1: TRIGGER identifier-and-relational-expert
│  Input: Phase 1 findings
│  └─ Map all module relationships
│     ├─ Identify dependencies
│     ├─ Discover hidden connections
│     ├─ Analyze ripple effects
│     └─ Map change impact
│  Output: Relational map
│
├─ STEP 2: TRIGGER dependency-inconsistency-resolver
│  Input: Phase 1 findings + Relational map
│  └─ Analyze all dependencies
│     ├─ Version conflicts
│     ├─ Missing dependencies
│     ├─ Breaking changes
│     ├─ Transitive issues
│     └─ License compatibility
│  Output: Dependency audit report
│
├─ STEP 3: TRIGGER performance-optimization-wizard
│  Input: Phase 1 findings + Relational context
│  └─ Identify performance issues
│     ├─ Algorithmic inefficiencies
│     ├─ Memory leaks
│     ├─ Bottlenecks
│     ├─ N+1 patterns
│     └─ Caching opportunities
│  Output: Performance optimization plan
│
├─ STEP 4: TRIGGER codebase-refactorer
│  Input: All prior Phase 2 outputs + Phase 1 findings
│  └─ Recommend structural improvements
│     ├─ Design patterns
│     ├─ Code deduplication
│     ├─ Architectural improvements
│     ├─ Decomposition opportunities
│     └─ Inheritance improvements
│  Output: Refactoring recommendations
│
├─ STEP 5: TRIGGER standards-enforcer
│  Input: All prior Phase 2 outputs + Phase 1 findings
│  └─ Audit standards compliance
│     ├─ Naming consistency
│     ├─ Formatting violations
│     ├─ Documentation gaps
│     ├─ Best practice violations
│     └─ Error handling patterns
│  Output: Standards violations report
│
└─ CONSOLIDATE: Generate Task List
   ├─ Synthesize all Phase 2 findings
   ├─ Generate comprehensive task list (using Task-Expert SKILL)
   ├─ Prioritize by severity and impact
   ├─ Group related tasks
   └─ Estimate implementation complexity
```

### Phase 2 Deliverables

**identifier-and-relational-expert:**
- Dependency graph (ASCII or text representation)
- Critical dependency paths
- Circular dependencies (if any)
- Change ripple analysis

**dependency-inconsistency-resolver:**
- Version conflict report
- Missing dependency list
- Deprecation warnings
- Security advisory list
- Resolution recommendations

**performance-optimization-wizard:**
- Bottleneck analysis
- Algorithmic inefficiency report
- Memory profile issues
- Optimization opportunities
- Implementation complexity per optimization

**codebase-refactorer:**
- Design pattern recommendations
- Code duplication analysis
- Refactoring opportunities
- Architectural improvements
- Estimated complexity per refactoring

**standards-enforcer:**
- Naming inconsistencies
- Formatting violations
- Documentation gaps
- Best practice violations
- Automation opportunities

### Task Generation Process

After all Phase 2 agents complete:

1. **Task-Expert SKILL** processes all findings
2. Generates comprehensive task list with structure:
   ```
   Task ID: [PREFIX-###]
   Title: [Clear action-oriented title]
   Priority: Critical / High / Medium / Low
   Type: [Security/Error/Performance/Refactoring/Standards/Dependency]
   Complexity: Simple / Medium / Complex / Very Complex
   Estimated Duration: X hours
   
   Description: [What needs to be done?]
   Root Cause: [Why does this exist?]
   Solution: [How to fix it?]
   Dependencies: [Other tasks that must complete first]
   Verification: [How to verify it's fixed?]
   ```

3. **Grouping and Ordering**
   - Tasks grouped by implementation phase (Tier)
   - Dependencies honored in sequencing
   - Related tasks grouped together

### Consolidated Phase 2 Report Format

```markdown
# PHASE 2 REPORT: Relational Analysis & Task Generation

## Executive Summary
- New findings: X
- Total tasks generated: X
- By priority: Critical X, High X, Medium X, Low X
- By type: Security X, Error X, Performance X, Refactoring X

## Task Inventory
[Complete task list by priority and type]

## Implementation Strategy
- Tier 1: Security Hardening (X tasks, Y hours estimated)
- Tier 2: Error & Dependency Fixes (X tasks, Y hours estimated)
- Tier 3: Optimization & Refactoring (X tasks, Y hours estimated)
- Tier 4: Standards & Cleanup (X tasks, Y hours estimated)

## Dependency Analysis
[Task dependencies and sequencing constraints]
```

---

## PHASE 3: IMPLEMENTATION EXECUTION

### Duration: 4-6 hours (varies by codebase size)
### Parallel Execution: NO (Tier-based sequential)
### Status: Active Remediation

### Phase Objective

Execute all tasks generated in Phase 2 through a coordinated tier-based approach. Maintain code integrity throughout implementation and verify each tier before proceeding.

### Phase 3 Structure: Tier-Based Execution

**Tier 1: Security Hardening** (Duration: 1-2 hours)
- Execute all Security (SEC-*) tasks
- Apply all Critical security fixes
- Validate security improvements

**Tier 2: Error & Dependency Fixes** (Duration: 1-2 hours)
- Execute all Error Resolution tasks
- Apply all Dependency fixes
- Resolve all exceptions and logical errors

**Tier 3: Optimization & Refactoring** (Duration: 1-2 hours)
- Execute all Performance optimization tasks
- Apply all Refactoring recommendations
- Restructure code per design patterns

**Tier 4: Standards & Cleanup** (Duration: 0.5-1 hour)
- Execute all Standards enforcement tasks
- Remove all dead code
- Apply formatting and naming standards

### Orchestration Sequence

```
START PHASE 3: TIER-BASED IMPLEMENTATION
│
├─ TIER 1: SECURITY HARDENING
│  Input: All SEC-* priority tasks from Phase 2
│  Agents: codebase-composer (coordination)
│  └─ Execute all security improvements
│     ├─ Fix authentication vulnerabilities
│     ├─ Resolve authorization issues
│     ├─ Patch data exposure issues
│     ├─ Implement cryptographic fixes
│     └─ Remove security anti-patterns
│  Output: Security-hardened codebase
│  
│  🔍 VALIDATION GATE 3A: Karen + Jenny Assessment
│     ├─ Karen: "Does this actually improve security?"
│     ├─ Jenny: "Are all security findings addressed?"
│     └─ Decision: PASS / FAIL / REWORK
│
├─ TIER 2: ERROR & DEPENDENCY FIXES
│  Input: All Error + Dependency tasks from Phase 2
│  Agents: codebase-composer (coordination)
│  └─ Execute error corrections and dependency resolution
│     ├─ Fix null pointer exceptions
│     ├─ Resolve type mismatches
│     ├─ Correct logic errors
│     ├─ Fix dependency version conflicts
│     ├─ Resolve circular dependencies
│     └─ Update incompatible imports
│  Output: Error-free, dependency-consistent codebase
│  
│  🔍 VALIDATION GATE 3B: Karen + Jenny Assessment
│     ├─ Karen: "Do the fixes actually work?"
│     ├─ Jenny: "Are all errors resolved?"
│     └─ Decision: PASS / FAIL / REWORK
│
├─ TIER 3: OPTIMIZATION & REFACTORING
│  Input: All Optimization + Refactoring tasks from Phase 2
│  Agents: codebase-composer (coordination)
│  └─ Execute performance and architectural improvements
│     ├─ Implement algorithmic optimizations
│     ├─ Resolve memory leaks
│     ├─ Apply design patterns
│     ├─ Refactor large functions
│     ├─ Restructure modules
│     └─ Improve code architecture
│  Output: Optimized, well-structured codebase
│  
│  🔍 VALIDATION GATE 3C: Karen + Jenny Assessment
│     ├─ Karen: "Will this perform better in production?"
│     ├─ Jenny: "Does refactoring match specifications?"
│     └─ Decision: PASS / FAIL / REWORK
│
├─ TIER 4: STANDARDS & CLEANUP
│  Input: All Standards + Cleanup tasks from Phase 2
│  Agents: codebase-composer (coordination)
│  └─ Execute standards and cleanup
│     ├─ Fix naming inconsistencies
│     ├─ Correct formatting violations
│     ├─ Remove dead code
│     ├─ Update documentation
│     ├─ Apply linting standards
│     └─ Complete cleanup
│  Output: Clean, standards-compliant codebase
│
│  🔍 VALIDATION GATE 3D: Karen + Jenny Assessment
│     ├─ Karen: "Is everything production-ready?"
│     ├─ Jenny: "Are all standards satisfied?"
│     └─ Decision: PASS / FAIL / REWORK
│
└─ END TIER IMPLEMENTATION
```

### Codebase Composer Role (Phase 3)

The codebase-composer agent serves as orchestration lead for Phase 3:

1. **Pre-Implementation Planning**
   - Review all tasks for this tier
   - Identify dependencies and constraints
   - Plan implementation order
   - Assess risks and mitigation

2. **Implementation Coordination**
   - Coordinate task execution
   - Manage changes across modules
   - Maintain code integrity
   - Track implementation progress
   - Address conflicts/issues

3. **Cross-Tier Integration**
   - Ensure changes from prior tiers still work
   - Verify no regressions introduced
   - Update dependent code
   - Maintain consistency

4. **Documentation**
   - Document all changes made
   - Update API documentation
   - Update architecture documentation
   - Maintain change log

### Phase 3 Validation Gates

Each tier completion triggers validation:

**Gate 3A (After Tier 1: Security)**
```
Karen Assessment:
- Do security fixes actually prevent vulnerabilities?
- Are there implementation risks or breakages?
- Is the code stable post-security-fixes?

Jenny Assessment:
- Are all identified security issues addressed?
- Do solutions match security specifications?
- Is documentation updated?
```

**Gate 3B (After Tier 2: Errors & Dependencies)**
```
Karen Assessment:
- Do error fixes actually resolve the issues?
- Are there edge cases that still fail?
- Is the codebase more stable?

Jenny Assessment:
- Are all errors eliminated?
- Do dependencies all resolve correctly?
- Is everything integrated properly?
```

**Gate 3C (After Tier 3: Optimization & Refactoring)**
```
Karen Assessment:
- Are performance improvements real and measurable?
- Does refactored code maintain backward compatibility?
- Are there any performance regressions?

Jenny Assessment:
- Does refactoring follow design specifications?
- Is architectural improvement sound?
- Is code quality improved?
```

**Gate 3D (After Tier 4: Standards & Cleanup)**
```
Karen Assessment:
- Is codebase truly production-ready?
- Are there any remaining blockers?
- Is performance stable?

Jenny Assessment:
- Are all standards applied?
- Is dead code completely removed?
- Is documentation complete and accurate?
```

### Rework Protocol

If any validation gate FAILS:

```
VALIDATION FAILS
    ↓
Identify specific failures
    ↓
Classify as:
  - Implementation Error (fix and re-execute)
  - Design Issue (requires redesign)
  - Specification Gap (clarify requirements)
    ↓
Make corrections or redesign
    ↓
Re-execute tier from beginning
    ↓
Re-validate with Karen + Jenny
    ↓
If still fails, escalate to Error Eliminator Commander
```

---

## PHASE 4: FINAL VALIDATION & DELIVERY

### Duration: 1-2 hours
### Parallel Execution: NO
### Status: Quality Assurance

### Phase Objective

Conduct comprehensive final validation and quality assurance. Verify all implementations are correct, complete, and production-ready. Generate final master report.

### Phase 4 Agents

**Agent 10: testing-and-validation-specialist** (Primary)
**Supporting: codebase-composer** (For any final adjustments)

### Orchestration Sequence

```
START PHASE 4: FINAL VALIDATION & DELIVERY
│
├─ STEP 1: TRIGGER testing-and-validation-specialist
│  Input: Complete implemented codebase + All Phase 3 changes
│  └─ Conduct comprehensive testing
│     ├─ Unit testing for all changes
│     ├─ Integration testing across tiers
│     ├─ Security testing of security fixes
│     ├─ Performance testing of optimizations
│     ├─ Regression testing for existing functionality
│     └─ End-to-end testing of workflows
│  Output: Comprehensive test report
│
├─ STEP 2: DOCUMENTATION REVIEW
│  ├─ Review and update all documentation
│  ├─ API documentation for changes
│  ├─ Architecture documentation updates
│  ├─ Deployment notes and procedures
│  └─ Rollback procedures (if needed)
│
├─ STEP 3: GENERATE MASTER REPORT
│  Input: All findings from all phases
│  └─ Consolidate all results
│     ├─ Executive summary
│     ├─ Original issues identified
│     ├─ Issues resolved
│     ├─ Recommendations implemented
│     ├─ Test results
│     ├─ Performance improvements
│     ├─ Security improvements
│     └─ Lessons learned
│
└─ 🔍 FINAL VALIDATION GATE: Karen + Jenny Assessment
   ├─ Karen: "Is this truly production-ready?"
   ├─ Jenny: "Is everything complete and correct?"
   └─ Decision: APPROVE / REWORK / ESCALATE
```

### Final Testing Scope

**Unit Testing**
- All modified functions/methods
- Edge cases and boundary conditions
- Error handling paths
- New functionality

**Integration Testing**
- Cross-module functionality
- API contracts
- Database interactions
- External service calls

**Security Testing**
- Security fix verification
- No new vulnerabilities introduced
- Access control validation
- Data protection verification

**Performance Testing**
- Optimization improvements verified
- No performance regressions
- Load testing if applicable
- Memory profiling

**Regression Testing**
- Existing functionality still works
- No breaking changes
- Backward compatibility maintained

### Master Report Structure

```markdown
# FINAL MASTER ERROR ELIMINATION REPORT

## Executive Summary
- Workflow duration: X hours
- Issues identified: X (Phases 1-2)
- Issues resolved: X (Phase 3)
- Test coverage: X%
- Production readiness: Yes/No

## 1. Issues by Severity
### Critical Issues (X total, X resolved)
[List each with status]

### High Priority Issues (X total, X resolved)
[List each with status]

### Medium Priority Issues (X total, X resolved)
[List each with status]

### Low Priority Issues (X total, X resolved)
[List each with status]

## 2. Issues by Category
### Security (X identified, X resolved)
[Details]

### Performance (X identified, X resolved)
[Details]

### Code Quality (X identified, X resolved)
[Details]

### Standards (X identified, X resolved)
[Details]

## 3. Implementation Summary
### Tier 1: Security (Status: Complete/In-Progress/Failed)
[Summary of work]

### Tier 2: Errors & Dependencies (Status: Complete/In-Progress/Failed)
[Summary of work]

### Tier 3: Optimization & Refactoring (Status: Complete/In-Progress/Failed)
[Summary of work]

### Tier 4: Standards & Cleanup (Status: Complete/In-Progress/Failed)
[Summary of work]

## 4. Quality Metrics
- Test coverage: X%
- Performance improvement: X%
- Security vulnerabilities resolved: X
- Code duplication reduced: X%
- Standards compliance: X%

## 5. Recommendations for Future
[Ongoing improvements]

## 6. Approval Status
- Karen (Reality Manager): APPROVED / CONCERNS / REJECTED
- Jenny (Spec Auditor): APPROVED / CONCERNS / REJECTED
```

---

## STATE MANAGEMENT BETWEEN PHASES

### Context Preservation

Each phase requires context from previous phases:

**Phase 1 → Phase 2 Handoff**
- All security vulnerabilities identified in Phase 1
- All errors and root causes from Phase 1
- All dead code inventory from Phase 1
- Prioritization of findings
- Status tracking: which issues are critical?

**Phase 2 → Phase 3 Handoff**
- Comprehensive task list with priorities
- Task dependencies and ordering
- Implementation complexity estimates
- Risk assessments per task
- Resource requirements
- Success criteria for each task

**Phase 3 → Phase 4 Handoff**
- Implemented code changes
- Change documentation
- Testing strategy from Phase 3
- Performance baseline measurements
- Security audit results

### State Tracking Format

```yaml
WorkflowState:
  Phase: 1|2|3|4
  Status: InProgress|Complete|Failed|OnHold
  StartTime: [timestamp]
  EstimatedCompletion: [timestamp]
  LastValidationGate: {gate_id, status, issues_raised}
  
  Phase1Results:
    SecurityFindings: [list]
    ErrorAnalysis: [list]
    DeadCodeInventory: [list]
    
  Phase2Results:
    TaskList: [list]
    Dependencies: [mapping]
    Tiers: [tier_breakdown]
    
  Phase3Progress:
    CurrentTier: 1-4
    CompletedTasks: [list]
    PendingTasks: [list]
    FailedTasks: [list]
    
  Phase4Results:
    TestResults: [list]
    FinalApproval: pending|approved|rejected
```

---

## ORCHESTRATION RULES & CONSTRAINTS

### Rule 1: Sequential Phase Execution
- Phase 1 must complete before Phase 2 starts
- Phase 2 must complete before Phase 3 starts
- Phase 3 must complete before Phase 4 starts
- **Exception**: None. Phases are strictly sequential.

### Rule 2: Validation Gate Requirements
- Each phase ends with a validation gate
- Karen AND Jenny must both assess
- Both must agree to proceed
- If disagreement, Error Eliminator Commander decides
- Failed gates require rework before proceeding

### Rule 3: Agent Invocation Completeness
- All Phase 1 agents must be invoked
- All Phase 2 agents must be invoked in order
- All Phase 3 agents (composer-based) must execute
- All Phase 4 agents must execute
- No agent can be skipped or partially invoked

### Rule 4: Context Preservation
- Each phase must reference all prior phase findings
- Task list must address all Phase 1 findings
- Implementation must resolve all Phase 2 tasks
- Final report must account for all changes

### Rule 5: Output Attribution
- Every finding attributed to source agent
- Every task traced to original issue
- Every implementation documented
- Every change justified and explained

### Rule 6: Rework Protocol
- If validation fails, identify root cause
- Classify as implementation, design, or specification issue
- Address root cause (not just symptom)
- Re-execute from beginning of failed phase
- Re-validate before proceeding

### Rule 7: Escalation
- Error Eliminator Commander ultimate authority
- Unresolved disputes escalated immediately
- Major blockers escalated without delay
- Final approval only from Error Eliminator

---

**End of Part 2: Workflow Orchestration & Process Flow**
