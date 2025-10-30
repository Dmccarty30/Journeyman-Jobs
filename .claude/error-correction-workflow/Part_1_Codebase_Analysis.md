# PART 1: CODEBASE ANALYSIS

> Complete step-by-step instructions for conducting comprehensive codebase analysis with Error Eliminator workflow and 10 specialist agents

---

## TABLE OF CONTENTS

1. [System Overview & Architecture](#system-overview--architecture)
2. [Pre-Workflow Setup & Verification](#pre-workflow-setup--verification)
3. [PHASE 1: Codebase Analysis](#phase-1-codebase-analysis)
4. [Command Reference for Analysis](#command-reference-for-analysis)

---

## SYSTEM OVERVIEW & ARCHITECTURE

### The Complete Agent Ecosystem

```
┌─────────────────────────────────────────────────────────────┐
│ ANALYSIS LAYER (Error Eliminator + 10 Specialists)         │
│ → Identifies all issues, bugs, security flaws, etc.        │
│ → Produces comprehensive report with 50-200 findings       │
└─────────────────────────────────────────────────────────────┘
                              ↓
┌─────────────────────────────────────────────────────────────┐
│ VALIDATION GATE 1: Karen & Jenny (Reality Check)           │
│ → Karen: Is analysis real? Do findings make sense?         │
│ → Jenny: Do findings match actual codebase?                │
│ → Decision: Proceed or rework analysis                     │
└─────────────────────────────────────────────────────────────┘
```

### Agent Roles at a Glance

| Agent | Layer | Role | Triggers |
|-------|-------|------|----------|
| **Error Eliminator** | Analysis | Orchestrate analysis, identify all issues | Start of workflow |
| **Karen** | Validation | Reality check - does it actually work? | After analysis |
| **Jenny** | Validation | Spec compliance check - match requirements? | After analysis |
| **10 Specialist Agents** | Analysis | Conduct specialized analysis | When invoked by Error Eliminator |

**Specialist Agents (10 total):**
- root-cause-analysis-expert
- identifier-and-relational-expert
- codebase-refactorer
- codebase-composer
- dead-code-eliminator
- dependency-inconsistency-resolver
- performance-optimization-wizard
- security-vulnerability-hunter
- standards-enforcer
- testing-and-validation-specialist

---

## PRE-WORKFLOW SETUP & VERIFICATION

### Checklist Before Starting

#### Agent Verification

```
Before invoking any workflows, verify all agents exist:

□ Error Eliminator: .claude/agents/error-eliminator.md
□ Karen: .claude/agents/karen.md
□ Jenny: .claude/agents/Jenny.md

Specialist Agents (10 total):
□ root-cause-analysis-expert
□ identifier-and-relational-expert
□ codebase-refactorer
□ codebase-composer
□ dead-code-eliminator
□ dependency-inconsistency-resolver
□ performance-optimization-wizard
□ security-vulnerability-hunter
□ standards-enforcer
□ testing-and-validation-specialist
```

#### Skill Framework Verification

```
Verify task generation framework:

□ .claude/skills/task-generation/SKILL.md (1,255 lines)
□ .claude/skills/task-generation/INTEGRATION_GUIDE.md (471 lines)
□ .claude/skills/task-generation/README.md (600 lines)
□ .claude/skills/task-generation/QUICK_START.md (700 lines)
```

#### Codebase Preparation

```
Before analyzing codebase:

□ All source files are in accessible directory
□ Git repository is initialized (for tracking changes)
□ No uncommitted breaking changes
□ All environment files (.env, config) are accessible
□ Project structure is clear and organized
□ README or documentation exists showing project structure
```

#### Documentation Review

```
Gather project requirements:

□ Project specifications (CLAUDE.md, requirements.md, etc.)
□ Architecture documentation
□ API specifications (if applicable)
□ Database schema documentation (if applicable)
□ Deployment/infrastructure documentation
```

### Pre-Flight Command

**Run this FIRST to verify everything is ready:**

```bash
> SYSTEM VERIFICATION: Before starting the comprehensive codebase
> improvement workflow, I need you to verify all systems are in place.

> Check:
> 1. All 13 agents exist (.claude/agents/ directory)
> 2. All skill frameworks exist (.claude/skills/task-generation/)
> 3. Project specifications are available and documented
> 4. Codebase is in a clean state
> 5. Key documentation files are accessible

> Provide summary of verification results with any missing components.
```

---

## PHASE 1: CODEBASE ANALYSIS

### Purpose

Conduct comprehensive analysis of the codebase to identify ALL issues, bugs, security vulnerabilities, performance problems, architectural issues, and improvement opportunities.

### Input Requirements

- ✓ Target codebase path
- ✓ Project specifications (if available)
- ✓ Architecture documentation (if available)
- ✓ Specific areas of concern (optional)

### Output

- Report with 8 sections
- 50-200+ findings organized by domain
- Recommended approaches for each finding

### The Command

**Copy and paste this exact command:**

```bash
Error Eliminator: Conduct comprehensive full-stack codebase audit.

TARGET CODEBASE: [your-codebase-path]
[e.g., /path/to/your/src, ./src, ~/projects/journeyman-jobs]

ORCHESTRATION: Invoke all 10 specialist agents in systematic 4-phase
sequence as documented in your instructions:

PHASE 1 (PARALLEL EXECUTION):
  - Use security-vulnerability-hunter to conduct comprehensive security analysis.
    Identify SQL injection, XSS, authentication flaws, data exposure risks,
    and all OWASP Top 10 vulnerabilities.

  - Use root-cause-analysis-expert to analyze for all errors, exceptions,
    logical flaws, runtime issues. Trace each to root cause with specific
    file:line references.

  - Use dead-code-eliminator to scan for unused imports, unreachable code,
    unused functions/variables, obsolete functionality. Create complete inventory.

PHASE 2 (SEQUENTIAL - Depends on Phase 1):
  - Use identifier-and-relational-expert to map hidden connections between
    identified issues. Show how issues cascade across modules and dependencies.

  - Use dependency-inconsistency-resolver to audit all external libraries,
    packages, internal module dependencies. Identify version conflicts,
    unused/missing dependencies, inconsistencies.

  - Use performance-optimization-wizard to analyze for: slow algorithms,
    memory leaks, inefficient data structures, bottlenecks, resource misuse.

PHASE 3 (SEQUENTIAL - Depends on Phase 2):
  - Use standards-enforcer to audit for style consistency, naming conventions,
    formatting standards, documentation adherence. Create violations report.

  - Use codebase-refactorer to analyze code structure and organization.
    Recommend refactoring opportunities, design patterns, architectural improvements.

PHASE 4 (SEQUENTIAL - Depends on Phases 1-3):
  - Use codebase-composer to create comprehensive implementation plan addressing
    ALL findings from Phases 1-3. Design for seamless integration.

  - Use testing-and-validation-specialist to design comprehensive test suites
    covering all identified issues. Ensure test coverage prevents regressions.

REQUIREMENT: ALL 10 agents MUST be explicitly invoked and fully execute their
specialized analysis. No shortcuts or omissions.

OUTPUT FORMAT: Master Error Elimination Report with all findings organized into:
1. Security Findings (with OWASP classification)
2. Root Cause & Error Analysis (with traces)
3. Dependency & Relationship Mapping (with cascade analysis)
4. Performance & Optimization (with bottleneck ranking)
5. Code Quality & Standards (with violations list)
6. Architectural Improvements (with recommendations)
7. Dead Code Inventory (with file:line references)
8. Testing & Validation Strategy (with test categories)

Each finding must include:
- Clear description of the issue
- Specific file paths and line numbers
- Code snippets showing the problem
- Why it matters (severity and impact)
- Recommended approach to fix
- Which agent identified this

Provide the COMPLETE report with every section populated.
```

### What to Expect

**Timing**: 30-45 minutes for comprehensive analysis
**Output Size**: 5,000-10,000 words
**Number of Findings**: 50-200+ issues across all domains

**Report Structure**:

```
┌─ SECTION 1: Security Findings
│  ├─ SQL Injection vulnerabilities
│  ├─ XSS vulnerabilities
│  ├─ Authentication bypass risks
│  └─ [More security issues]
│
├─ SECTION 2: Root Cause Analysis
│  ├─ Error origins with traces
│  ├─ Logical flaws
│  └─ Runtime issues
│
├─ SECTION 3: Dependencies & Relationships
│  ├─ Dependency graph
│  ├─ Version conflicts
│  └─ Cross-module impacts
│
├─ SECTION 4: Performance Issues
│  ├─ Bottlenecks ranked by impact
│  ├─ Memory leaks
│  └─ Algorithm inefficiencies
│
├─ SECTION 5: Code Quality & Standards
│  ├─ Style violations
│  ├─ Naming inconsistencies
│  └─ Documentation gaps
│
├─ SECTION 6: Architectural Issues
│  ├─ Structure recommendations
│  ├─ Design pattern suggestions
│  └─ Refactoring opportunities
│
├─ SECTION 7: Dead Code Inventory
│  ├─ Unused imports (with file:line)
│  ├─ Unused functions (with file:line)
│  └─ Unreachable code (with file:line)
│
└─ SECTION 8: Testing Strategy
   ├─ Test coverage gaps
   ├─ Test categories needed
   └─ Regression prevention approach
```

### Success Criteria for Phase 1

- ✅ Report has all 8 sections populated
- ✅ Each section has multiple findings
- ✅ Findings include specific file:line references
- ✅ Security findings are well-documented
- ✅ Root causes are traced to origins
- ✅ All 10 agents contributed findings
- ✅ Recommendations are specific and actionable
- ✅ Report is organized and readable

---

## COMMAND REFERENCE FOR ANALYSIS

### Quick Copy-Paste Commands

#### Phase 1: Analysis

```bash
Error Eliminator: Conduct comprehensive full-stack codebase audit.

TARGET CODEBASE: [your-codebase-path]

ORCHESTRATION: Invoke all 10 specialist agents in systematic 4-phase sequence...

[Use full command from PHASE 1 section above]
```

### Pre-Flight Verification

```bash
SYSTEM VERIFICATION: Before starting the comprehensive codebase improvement workflow, verify all systems are in place.

Check:
1. All 13 agents exist (.claude/agents/ directory)
2. All skill frameworks exist (.claude/skills/task-generation/)
3. Project specifications are available and documented
4. Codebase is in a clean state
5. Key documentation files are accessible

Provide summary of verification results with any missing components.
```

---

## NEXT STEPS

After completing Phase 1 (Codebase Analysis):

1. **Proceed to Part 2: Analysis Validation**
   - Run Karen's reality assessment
   - Run Jenny's specification verification
   - Validate findings are accurate and actionable

2. **Validation Success Criteria**
   - Karen confirms findings are real issues
   - Jenny confirms findings match actual codebase
   - Ready to proceed to Task Creation phase

---

**Part 1 Complete: You now have everything needed to conduct comprehensive codebase analysis with the Error Eliminator workflow and 10 specialist agents.**