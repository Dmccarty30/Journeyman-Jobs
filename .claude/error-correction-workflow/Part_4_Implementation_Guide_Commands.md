# ENHANCED ERROR ELIMINATION WORKFLOW
## Part 4: Implementation Guide & Commands

**Document Version:** 2.0 (Enhanced)  
**Last Updated:** October 29, 2025  
**Purpose:** Practical setup instructions, CLI commands, execution procedures, and troubleshooting guide

---

## TABLE OF CONTENTS

1. [Prerequisites & Setup](#prerequisites--setup)
2. [Agent Installation](#agent-installation)
3. [Skill Installation](#skill-installation)
4. [Execution Commands](#execution-commands)
5. [Phase-by-Phase Commands](#phase-by-phase-commands)
6. [Validation Gate Commands](#validation-gate-commands)
7. [Troubleshooting & Common Issues](#troubleshooting--common-issues)
8. [Reference: Complete Command Library](#reference-complete-command-library)

---

## PREREQUISITES & SETUP

### System Requirements

```
Required:
  ✓ Claude or Claude Code access
  ✓ Access to target codebase
  ✓ Project directory with read/write permissions
  ✓ Sufficient token allocation for multi-phase analysis

Recommended:
  ✓ 4+ hours uninterrupted workflow time
  ✓ Quiet, focused environment
  ✓ Project documentation available
  ✓ Team members available for decisions if needed
```

### Directory Structure

Create this structure before starting:

```
project-root/
├── .claude/
│   ├── agents/                    # Agent definitions
│   │   ├── error-eliminator.md
│   │   ├── security-vulnerability-hunter.md
│   │   ├── root-cause-analysis-expert.md
│   │   ├── dead-code-eliminator.md
│   │   ├── identifier-and-relational-expert.md
│   │   ├── dependency-inconsistency-resolver.md
│   │   ├── performance-optimization-wizard.md
│   │   ├── codebase-refactorer.md
│   │   ├── standards-enforcer.md
│   │   ├── codebase-composer.md
│   │   ├── testing-and-validation-specialist.md
│   │   ├── karen-reality-manager.md
│   │   └── Jenny-spec-auditor.md
│   └── skills/                    # Skill files
│       ├── task-generator.md      # Generates task lists
│       └── validation-gate.md     # Validation procedures
│
├── workflows/                     # Workflow documentation
│   ├── Part_1_Agent_Definitions.md
│   ├── Part_2_Orchestration.md
│   ├── Part_3_Validation.md
│   └── Part_4_Implementation.md
│
├── reports/                       # Generated reports
│   ├── phase_1_report.md
│   ├── phase_2_report.md
│   ├── phase_3_tier1_report.md
│   ├── phase_3_tier2_report.md
│   ├── phase_3_tier3_report.md
│   ├── phase_3_tier4_report.md
│   ├── phase_4_final_report.md
│   └── master_error_elimination_report.md
│
├── logs/                          # Execution logs
│   └── error_elimination.log
│
└── [your codebase files]
```

### Pre-Workflow Checklist

```
Before starting the workflow, verify:

□ All agents installed in .claude/agents/
□ All skills installed in .claude/skills/
□ Project root directory identified
□ Read access to all source files
□ Write access to reports/ and logs/ directories
□ Workspace prepared and quiet
□ No conflicting Claude sessions
□ Documentation and team available

Once all items checked, ready to proceed.
```

---

## AGENT INSTALLATION

### Installing Individual Agents

Each agent requires two files: agent definition and system prompt.

#### Agent Definition File Format

```yaml
---
name: [agent-name]
description: [Clear description of purpose]
tools: [Tool list]
model: [opus/sonnet/haiku]
color: [red/orange/yellow/green/blue/etc]
priority: [critical/high/medium/low]
---

# [AGENT NAME]

[Agent system prompt below - detailed instructions]
```

#### Installation Steps

**Step 1: Create Agent File**

```bash
# Create agents directory if doesn't exist
mkdir -p .claude/agents

# Create agent definition file (for each agent)
# Copy the agent definition from Part 1 into:
# .claude/agents/[agent-name].md
```

**Step 2: Verify Installation**

```bash
# List installed agents
ls -la .claude/agents/

# Check specific agent is readable
cat .claude/agents/error-eliminator.md

# Expected output: YAML frontmatter + system prompt
```

**Step 3: Agent Registration** (if using Claude Code)

```bash
# Claude Code auto-discovers agents in .claude/agents/
# No additional registration needed
# Available immediately for invocation
```

### Quick Agent Installation Script

```bash
#!/bin/bash
# install_agents.sh

AGENTS=(
  "error-eliminator"
  "security-vulnerability-hunter"
  "root-cause-analysis-expert"
  "dead-code-eliminator"
  "identifier-and-relational-expert"
  "dependency-inconsistency-resolver"
  "performance-optimization-wizard"
  "codebase-refactorer"
  "standards-enforcer"
  "codebase-composer"
  "testing-and-validation-specialist"
  "karen-reality-manager"
  "Jenny-spec-auditor"
)

# Create directory
mkdir -p .claude/agents

# Verify each agent file exists
for agent in "${AGENTS[@]}"; do
  if [ -f ".claude/agents/$agent.md" ]; then
    echo "✓ $agent installed"
  else
    echo "✗ $agent missing - install from Part 1 documentation"
  fi
done

echo "Installation check complete"
```

---

## SKILL INSTALLATION

### Task-Expert Skill

The Task-Expert skill converts analysis findings into actionable task lists.

**Installation:**

```bash
# Create skills directory
mkdir -p .claude/skills

# Create task-generator.md skill file
# Use the Task-Expert SKILL from previous conversations
```

**Skill Invocation:**

```bash
# When needed in Phase 2
> Task-Expert: Convert the following Phase 2 findings into a structured 
  task list with priorities, complexity estimates, and dependencies:
  
  [Insert consolidated Phase 2 findings]
```

---

## EXECUTION COMMANDS

### Starting the Workflow

#### Initiating Error Eliminator

**Command to begin workflow:**

```
Error Eliminator: Conduct a comprehensive full-stack codebase audit and 
error elimination workflow.

Target Codebase: [path/to/codebase]

Workflow Scope:
1. Phase 1: Initial threat and error assessment (3 agents in parallel)
2. Phase 2: Relational analysis and task generation (5 agents sequential)
3. Phase 3: Implementation execution (4 tiers)
4. Phase 4: Final validation and delivery

Requirements:
- Invoke ALL 10 specialist agents completely
- Perform complete Phase 1 security, error, and dead code analysis
- Generate comprehensive task list in Phase 2
- Implement all tasks through coordinated tiers
- Conduct thorough testing and validation in Phase 4
- Produce final Master Error Elimination Report

Deliverables Expected:
- Phase 1 Report: Security/Error/Dead Code findings
- Phase 2 Report: Tasks + Prioritization
- Phase 3 Reports: Implementation results per tier
- Phase 4 Report: Final validation and approval
- Master Report: Complete summary and recommendations

Begin immediately.
```

### Checking Workflow Status

```bash
# Mid-workflow status check
# (Use if pausing between phases)

> Error Eliminator: Provide status update.
  
  What is the current workflow state?
  - Which phase are we in?
  - What has been completed?
  - What's pending?
  - Any blockers or concerns?
  
  Provide brief update summary.
```

---

## PHASE-BY-PHASE COMMANDS

### PHASE 1: Initial Threat & Error Assessment

#### Starting Phase 1

```
PHASE 1 START

Error Eliminator: Begin Phase 1 analysis.

Invoke in parallel:
1. security-vulnerability-hunter - Comprehensive security scan
2. root-cause-analysis-expert - Full error and logic analysis
3. dead-code-eliminator - Complete dead code inventory

Each agent should:
- Analyze the entire codebase
- Generate comprehensive findings
- Report with specific file locations and line numbers
- Provide severity/priority assessments
- Submit independent findings report

Consolidate all Phase 1 findings into single Phase 1 Report.

Duration Target: 2-3 hours
Status: Report location = reports/phase_1_report.md
```

#### Phase 1 Completion & Validation

```
PHASE 1 COMPLETION - VALIDATION GATE 1

Error Eliminator: Phase 1 analysis complete.

Invoke Karen and Jenny for assessment:

Karen: "Provide pragmatic feasibility assessment of Phase 1 findings:
  - Are the identified issues realistic?
  - Could they actually break the codebase?
  - Is effort required realistic?
  - Are there hidden risks?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Provide specification compliance audit of Phase 1 findings:
  - Did security-vulnerability-hunter cover all categories?
  - Did root-cause-analysis-expert trace all errors?
  - Did dead-code-eliminator find all unused code?
  - Is everything properly documented?
  
  Provide: PASS / CAUTION / REWORK decision"

After both assessments:
- If both PASS: Proceed to Phase 2
- If CAUTION: Proceed with noted concerns
- If REWORK: Address concerns in Phase 1, re-validate
```

### PHASE 2: Relational Analysis & Task Generation

#### Starting Phase 2

```
PHASE 2 START

Error Eliminator: Begin Phase 2 analysis.

Input: Phase 1 Report findings

Invoke sequentially:
1. identifier-and-relational-expert
   - Map all module relationships
   - Analyze dependencies
   - Identify change impacts

2. dependency-inconsistency-resolver
   - Audit all dependencies (internal & external)
   - Identify version conflicts
   - Find breaking changes

3. performance-optimization-wizard
   - Find algorithmic inefficiencies
   - Identify memory leaks
   - Locate bottlenecks

4. codebase-refactorer
   - Recommend design patterns
   - Identify code duplication
   - Suggest architectural improvements

5. standards-enforcer
   - Audit naming consistency
   - Check formatting
   - Verify best practices

After all agents complete:
Invoke Task-Expert skill to generate comprehensive task list.

Duration Target: 2-3 hours
Status: Reports in reports/phase_2_report.md
```

#### Phase 2 Completion & Validation

```
PHASE 2 COMPLETION - VALIDATION GATE 2

Error Eliminator: Phase 2 analysis complete.

Invoke Karen and Jenny for assessment:

Karen: "Assess Phase 2 task feasibility:
  - Are tasks clear and actionable?
  - Is implementation sequencing logical?
  - Are effort estimates realistic?
  - Can we actually execute these tasks?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Audit Phase 2 task completeness:
  - Do tasks address ALL Phase 1 findings?
  - Is every issue represented?
  - Are tasks technically sound?
  - Are acceptance criteria defined?
  
  Provide: PASS / CAUTION / REWORK decision"

After both assessments:
- If both PASS: Proceed to Phase 3
- If CAUTION: Proceed with monitoring
- If REWORK: Generate new task list, re-validate
```

### PHASE 3: Implementation Execution

#### Tier 1 Execution

```
PHASE 3 - TIER 1: SECURITY HARDENING

Error Eliminator: Execute Tier 1 security hardening.

Input: All SEC-* priority tasks from Phase 2

Codebase-Composer: Orchestrate security fix implementation
- Review all security tasks
- Implement security fixes in order
- Maintain code integrity throughout
- Document all changes

Execute:
- Fix authentication vulnerabilities
- Resolve authorization issues
- Patch data exposure risks
- Apply cryptographic fixes
- Remove security anti-patterns

Duration Target: 1-2 hours
Status: Report location = reports/phase_3_tier1_report.md

Upon completion: Proceed to Validation Gate 3A
```

#### Tier 1 Validation

```
TIER 1 VALIDATION - GATE 3A

Karen: "Security implementation reality check:
  - Are security fixes actually effective?
  - Is code stable after changes?
  - No new vulnerabilities introduced?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Security specification audit:
  - Were all SEC-* tasks implemented?
  - Do solutions match specifications?
  - Is everything properly tested?
  
  Provide: PASS / CAUTION / REWORK decision"

- If PASS: Proceed to Tier 2
- If CAUTION: Proceed with monitoring
- If REWORK: Fix issues, re-validate
```

#### Tier 2 Execution

```
PHASE 3 - TIER 2: ERROR & DEPENDENCY FIXES

Error Eliminator: Execute Tier 2 error corrections.

Input: All Error Resolution + Dependency tasks

Codebase-Composer: Orchestrate error fix implementation
- Review all error resolution tasks
- Fix null pointers, type errors, logic issues
- Resolve dependency conflicts
- Integrate changes

Execute:
- Fix all identified errors
- Resolve version conflicts
- Update incompatible imports
- Fix circular dependencies

Duration Target: 1-2 hours
Status: Report location = reports/phase_3_tier2_report.md

Upon completion: Proceed to Validation Gate 3B
```

#### Tier 2 Validation

```
TIER 2 VALIDATION - GATE 3B

Karen: "Error implementation reality check:
  - Do error fixes actually work?
  - Is system stable and runnable?
  - Dependencies actually resolved?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Error specification audit:
  - Were all error tasks completed?
  - Are all dependencies resolved?
  - Properly integrated?
  
  Provide: PASS / CAUTION / REWORK decision"

- If PASS: Proceed to Tier 3
- If CAUTION: Proceed with monitoring
- If REWORK: Fix issues, re-validate
```

#### Tier 3 Execution

```
PHASE 3 - TIER 3: OPTIMIZATION & REFACTORING

Error Eliminator: Execute Tier 3 optimizations.

Input: All Performance + Refactoring tasks

Codebase-Composer: Orchestrate optimization implementation
- Review all optimization tasks
- Implement algorithmic improvements
- Apply design patterns
- Refactor code structures

Execute:
- Implement performance optimizations
- Apply design patterns
- Refactor large functions
- Restructure modules
- Improve architecture

Duration Target: 1-2 hours
Status: Report location = reports/phase_3_tier3_report.md

Upon completion: Proceed to Validation Gate 3C
```

#### Tier 3 Validation

```
TIER 3 VALIDATION - GATE 3C

Karen: "Optimization implementation reality check:
  - Are performance improvements real?
  - Is refactored code maintainable?
  - Backward compatibility maintained?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Optimization specification audit:
  - Were all optimization tasks completed?
  - Does refactoring match specifications?
  - Quality standards met?
  
  Provide: PASS / CAUTION / REWORK decision"

- If PASS: Proceed to Tier 4
- If CAUTION: Proceed with monitoring
- If REWORK: Fix issues, re-validate
```

#### Tier 4 Execution

```
PHASE 3 - TIER 4: STANDARDS & CLEANUP

Error Eliminator: Execute Tier 4 standards and cleanup.

Input: All Standards + Cleanup tasks

Codebase-Composer: Orchestrate standards implementation
- Review all standards tasks
- Apply naming standards
- Fix formatting violations
- Remove dead code
- Update documentation

Execute:
- Fix naming inconsistencies
- Correct formatting
- Remove all dead code
- Update documentation
- Apply linting standards

Duration Target: 0.5-1 hour
Status: Report location = reports/phase_3_tier4_report.md

Upon completion: Proceed to Validation Gate 3D
```

#### Tier 4 Validation

```
TIER 4 VALIDATION - GATE 3D

Karen: "Standards implementation reality check:
  - Is codebase production-ready?
  - All issues resolved?
  - System stable?
  
  Provide: PASS / CAUTION / REWORK decision"

Jenny: "Standards specification audit:
  - Were all standards tasks completed?
  - Is dead code removed?
  - Documentation complete?
  
  Provide: PASS / CAUTION / REWORK decision"

- If PASS: Proceed to Phase 4
- If CAUTION: Proceed with caution
- If REWORK: Fix issues, re-validate
```

### PHASE 4: Final Validation & Delivery

#### Starting Phase 4

```
PHASE 4 START: FINAL VALIDATION

Error Eliminator: Begin Phase 4 final validation.

Input: Complete implemented codebase with all Phase 3 changes

Testing-and-Validation-Specialist: Conduct comprehensive testing
- Unit testing of all changes
- Integration testing across tiers
- Security testing of fixes
- Performance testing of optimizations
- Regression testing for existing features
- End-to-end workflow testing

Generate comprehensive test report.

Duration Target: 1-2 hours
Status: Report location = reports/phase_4_final_report.md
```

#### Final Validation Gate

```
FINAL VALIDATION - GATE 4 (PRODUCTION APPROVAL)

Karen: "Final production readiness assessment:
  - Is system stable and performant?
  - Ready for production deployment?
  - All risks acceptable?
  
  Provide: APPROVE / APPROVE WITH CONDITIONS / REJECT"

Jenny: "Final specification compliance audit:
  - Have ALL issues been resolved?
  - Do all implementations meet specifications?
  - Quality standards met?
  
  Provide: APPROVE / APPROVE WITH CONDITIONS / REJECT"

After both assessments:
- If both APPROVE: Generate Master Report, workflow complete
- If CONDITIONS: Generate Master Report with conditions noted
- If REJECT: Identify issues, rework required
```

#### Master Report Generation

```
FINAL: GENERATE MASTER ERROR ELIMINATION REPORT

Error Eliminator: Create comprehensive Master Report

The Master Report should contain:
1. Executive Summary
   - Workflow duration
   - Issues identified vs resolved
   - Overall quality metrics

2. Issues by Severity
   - Critical, High, Medium, Low
   - Status of each

3. Issues by Category
   - Security, Performance, Code Quality, Standards
   - Count by category

4. Implementation Summary
   - Tier 1-4 results
   - Changes made

5. Quality Metrics
   - Test coverage
   - Performance improvement
   - Code quality metrics

6. Validation Results
   - Karen assessments
   - Jenny assessments
   - Final approval status

7. Recommendations
   - Follow-up items
   - Ongoing improvements

Location: reports/master_error_elimination_report.md

Workflow Complete!
```

---

## VALIDATION GATE COMMANDS

### Explicit Validation Gate Invocation

```
# When validation gate needs to be repeated

> Karen: Perform reality check assessment on [phase/tier] deliverables.
  
  Review the following findings/implementation:
  [Insert findings or implementation details]
  
  Assess feasibility, implementation risk, and resource requirements.
  
  Decision: PASS / CAUTION / REWORK
  
  Provide detailed assessment report.

> Jenny: Perform specification compliance audit on [phase/tier] deliverables.
  
  Review the following findings/implementation:
  [Insert findings or implementation details]
  
  Audit completeness, compliance, and quality standards.
  
  Decision: PASS / CAUTION / REWORK
  
  Provide detailed audit report.
```

### Disagreement Resolution

```
# When Karen and Jenny disagree

> Error Eliminator: Karen and Jenny assessments disagree.
  
  Karen Assessment: [Karen's decision and reasoning]
  Jenny Assessment: [Jenny's decision and reasoning]
  
  Points of disagreement:
  [Specific areas where they diverge]
  
  As workflow commander, make final decision:
  - Option A: [Option based on Karen's concerns]
  - Option B: [Option based on Jenny's concerns]
  - Option C: [Compromise option]
  
  Provide decision with reasoning.
```

---

## TROUBLESHOOTING & COMMON ISSUES

### Issue: Agent Not Invoking Completely

**Symptom:** Agent output seems incomplete or skipped sections

**Diagnosis:**
```
Check if:
1. Agent file is properly installed
2. Agent name is spelled correctly in command
3. System prompt is complete and clear
4. Input context is being passed properly
5. Token budget is sufficient
```

**Solution:**
```
1. Reinstall agent from Part 1 specifications
2. Use explicit agent name in commands
3. Break analysis into smaller sections if context overflow
4. Reference agent explicitly: "[Agent Name]: [Detailed instruction]"
5. If token budget exceeded, process in smaller batches
```

### Issue: Validation Gate Keeps Failing

**Symptom:** Karen or Jenny repeatedly reject work

**Root Causes:**
```
Karen failures typically mean:
- Implementation is not practical
- Resource/time estimates unrealistic
- Hidden risks not identified
- Code quality concerns

Jenny failures typically mean:
- Specifications not met
- Issues left unaddressed
- Documentation incomplete
- Quality standards not followed
```

**Resolution Process:**
```
1. Ask Karen/Jenny: "What specifically needs to change?"
2. Get concrete, actionable feedback
3. Address root cause, not just symptom
4. Re-execute affected phase/tier completely
5. Re-validate
6. If still fails after 2 attempts, escalate to Error Eliminator
```

### Issue: Workflow Stalling or Not Progressing

**Symptom:** Stuck on same phase/tier, no progress

**Diagnosis:**
```
Check:
1. Is it in rework loop?
2. Is a validation gate blocking?
3. Is context being preserved between agents?
4. Are dependencies blocking execution?
```

**Solution:**
```
1. Pause and explicitly summarize state:
   "Current workflow state: [Phase X, Tier Y, findings/issues]"
   
2. Break workflow into smaller segments:
   - One phase at a time
   - One tier at a time
   - Individual agent invocations
   
3. Explicitly pass context between phases:
   "Here is the complete Phase 1 output: [paste output]"
   
4. For blocked dependencies:
   - Identify what's blocking
   - Address blocker first
   - Then continue workflow
```

### Issue: Token Budget Exceeded

**Symptom:** Running out of tokens mid-workflow

**Prevention:**
```
Estimate token usage:
- Phase 1: ~15,000 tokens
- Phase 2: ~20,000 tokens
- Phase 3: ~25,000 tokens (per tier)
- Phase 4: ~10,000 tokens

Total: ~95,000-120,000 tokens

Reserve extra 20% buffer.
```

**Recovery if exceeded:**
```
1. Save current state/progress
2. Document what's been completed
3. Identify remaining work
4. Start fresh session
5. Reference prior output in new session
6. Continue from where left off
```

### Issue: Validation Takes Too Long

**Symptom:** Karen and Jenny assessments taking excessive time

**Optimization:**
```
1. Provide more specific context: "Focus assessment on X only"
2. Pre-summarize findings: "Here's 3-page summary of work"
3. Ask for quicker assessment: "Provide 2-minute assessment"
4. Break into multiple smaller gates: One tier at a time
5. Sequential assessment: Karen first, then Jenny (faster)
```

### Issue: Quality Keeps Improving But Gate Still Fails

**Symptom:** Work getting better but validation still rejecting

**Analysis:**
```
This usually means:
1. Gate criteria misunderstood
2. Different expectation than implied
3. Specification gap or ambiguity
4. Risk tolerance different than expected
```

**Resolution:**
```
1. Ask explicitly: "What specific acceptance criteria are not met?"
2. Get measurable, specific requirements
3. Address exact criteria, not general quality
4. Document criteria for future phases
5. If criteria unreasonable, escalate to Error Eliminator
```

---

## REFERENCE: COMPLETE COMMAND LIBRARY

### Quick Command Reference

```
╔════════════════════════════════════════════════════════════════╗
║            ERROR ELIMINATION WORKFLOW COMMANDS                 ║
╚════════════════════════════════════════════════════════════════╝

WORKFLOW START
└─ Error Eliminator: Begin comprehensive error elimination workflow...

PHASE 1: ANALYSIS
├─ Phase 1 Start: Begin security/error/deadcode analysis
├─ Status Check: Report Phase 1 progress
└─ Phase 1 Complete: Validation Gate 1 (Karen + Jenny)

PHASE 2: TASK GENERATION
├─ Phase 2 Start: Begin relational analysis
├─ Task-Expert: Generate task list from Phase 2 findings
└─ Phase 2 Complete: Validation Gate 2 (Karen + Jenny)

PHASE 3: TIER IMPLEMENTATION
├─ Tier 1 (Security): Execute security hardening
│  └─ Tier 1 Complete: Validation Gate 3A (Karen + Jenny)
├─ Tier 2 (Errors): Execute error & dependency fixes
│  └─ Tier 2 Complete: Validation Gate 3B (Karen + Jenny)
├─ Tier 3 (Optimization): Execute optimization & refactoring
│  └─ Tier 3 Complete: Validation Gate 3C (Karen + Jenny)
└─ Tier 4 (Standards): Execute standards & cleanup
   └─ Tier 4 Complete: Validation Gate 3D (Karen + Jenny)

PHASE 4: FINAL VALIDATION
├─ Phase 4 Start: Begin comprehensive testing
├─ Final Validation Gate: Gate 4 (Karen + Jenny)
└─ Master Report: Generate final comprehensive report

VALIDATION
├─ Karen Assessment: Pragmatic reality check
├─ Jenny Assessment: Specification compliance audit
└─ Escalation: If Karen/Jenny disagree

SPECIAL COMMANDS
├─ Rework: Address failed validation gate
├─ Status: Get workflow state update
└─ Escalate: Escalate to Error Eliminator Commander
```

### Command Templates

```
TEMPLATE: Starting Phase
═══════════════════════════════════════════════════════════
[Agent Name]: Execute Phase X [description].

Input: [What findings/context is being used]
Target: [What code/scope being analyzed]
Duration: [Expected time]

Deliver: [What report/output expected]
Status: Save results to reports/[report_file.md]
```

```
TEMPLATE: Validation Gate
═══════════════════════════════════════════════════════════
Karen: Assess [phase/tier] feasibility and risk.

Provide assessment on:
1. Implementation feasibility
2. Resource requirements
3. Risk level and mitigations
4. Timeline realism

Decision: PASS / CAUTION / REWORK

Jenny: Audit [phase/tier] specification compliance.

Provide assessment on:
1. Specification match
2. Completeness
3. Quality standards
4. Documentation

Decision: PASS / CAUTION / REWORK
```

---

## EXECUTION CHECKLIST

### Pre-Workflow

```
□ Read all 4 parts of documentation
□ Create project directory structure
□ Install all 13 agents
□ Install task-generator skill
□ Verify agent files readable
□ Prepare codebase (no uncommitted changes recommended)
□ Ensure quiet, focused environment
□ Allocate 4-6 hours
□ Have team/documentation available
```

### During Workflow

```
□ Follow phase-by-phase sequence strictly
□ Pass context between phases completely
□ Invoke all agents in each phase (no shortcuts)
□ Wait for validation gates to complete
□ Document any issues or concerns
□ Save all reports to reports/ directory
□ Track progress in execution log
```

### Post-Workflow

```
□ Generate Master Error Elimination Report
□ Get final approval from Karen and Jenny
□ Review recommendations
□ Plan implementation and deployment
□ Archive all reports and findings
□ Document lessons learned
□ Schedule follow-up improvements
```

---

## FINAL SUCCESS CRITERIA

Workflow is successfully complete when:

1. ✅ All 4 phases executed sequentially
2. ✅ All 10 specialist agents invoked completely
3. ✅ Karen validated at each gate
4. ✅ Jenny validated at each gate
5. ✅ All rework resolved (if any)
6. ✅ Phase 3 all 4 tiers completed
7. ✅ Phase 4 comprehensive testing complete
8. ✅ Master Report generated
9. ✅ Final approval granted
10. ✅ All issues identified and addressed

**When all criteria met: Workflow is production-ready!**

---

**End of Part 4: Implementation Guide & Commands**

---

## APPENDIX: Quick Setup Script

```bash
#!/bin/bash
# error_elimination_setup.sh
# Run this to create directory structure and verify setup

set -e

echo "🔧 Setting up Error Elimination Workflow..."

# Create directories
mkdir -p .claude/agents
mkdir -p .claude/skills
mkdir -p workflows
mkdir -p reports
mkdir -p logs

echo "✓ Directory structure created"

# Create .gitignore
cat > .claude/.gitignore <<EOF
# Claude workspace
*.log
*.tmp
EOF

echo "✓ .gitignore created"

# Verify agents installed
echo ""
echo "🔍 Checking agent installation..."

AGENTS=(
  "error-eliminator"
  "security-vulnerability-hunter"
  "root-cause-analysis-expert"
  "dead-code-eliminator"
  "identifier-and-relational-expert"
  "dependency-inconsistency-resolver"
  "performance-optimization-wizard"
  "codebase-refactorer"
  "standards-enforcer"
  "codebase-composer"
  "testing-and-validation-specialist"
  "karen-reality-manager"
  "Jenny-spec-auditor"
)

MISSING=0
for agent in "${AGENTS[@]}"; do
  if [ -f ".claude/agents/$agent.md" ]; then
    echo "✓ $agent"
  else
    echo "✗ $agent (MISSING)"
    MISSING=$((MISSING + 1))
  fi
done

echo ""
if [ $MISSING -eq 0 ]; then
  echo "✅ All agents installed!"
  echo ""
  echo "🚀 Ready to start Error Elimination Workflow"
  echo ""
  echo "Next steps:"
  echo "1. Review Part 1: Agent Definitions"
  echo "2. Review Part 2: Workflow Orchestration"
  echo "3. Review Part 3: Validation Gates"
  echo "4. Review Part 4: Implementation Guide"
  echo "5. Run: Error Eliminator: [Start command from Part 4]"
else
  echo "⚠️  $MISSING agents missing"
  echo "Install agents from Part 1 documentation before starting workflow"
fi
```

---

**Complete Error Elimination Workflow Documentation**  
**Version 2.0 (Enhanced)**  
**All 4 Parts Created Successfully**

