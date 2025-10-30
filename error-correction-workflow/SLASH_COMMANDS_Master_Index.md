# CUSTOM SLASH COMMANDS - MASTER INDEX & QUICK REFERENCE

**Version:** 2.0  
**Last Updated:** October 29, 2025  
**Status:** Production Ready for Claude Code

---

## OVERVIEW

This is your complete command library for executing the Error Elimination Workflow in Claude Code. All commands are detailed, explicit, and ready to copy-paste directly into Claude Code.

**Total Commands:** 20+  
**Complete Coverage:** Workflow start through final report  
**Documentation:** ~6,000+ lines of detailed command specifications

---

## COMMAND STRUCTURE

All commands follow this structure:

```bash
/command-name

DESCRIPTION of what the command does

[Detailed steps with:
- Pre-checks and requirements
- Agent invocations with complete instructions
- Expected outputs
- Next steps]
```

Copy the entire command (from `/command-name` to `END COMMAND`) and paste into Claude Code.

---

## QUICK COMMAND REFERENCE

### WORKFLOW SETUP COMMANDS

| Command | Purpose | Duration | File |
|---------|---------|----------|------|
| `/workflow-init` | Initialize workflow environment | 10 min | Part 1 |
| `/workflow-start` | Begin complete workflow | Immediate | Part 1 |
| `/workflow-status` | Check current workflow state | 2 min | Part 2 |

### PHASE 1: INITIAL THREAT ASSESSMENT

| Command | Purpose | Duration | File |
|---------|---------|----------|------|
| `/phase-1` | Execute Phase 1 analysis (3 agents in parallel) | 2-3 hrs | Part 1 |
| `/phase-1-validate` | Validation Gate 1 (Karen + Jenny) | 45 min | Part 1 |

**Phase 1 Agents:**

- security-vulnerability-hunter
- root-cause-analysis-expert
- dead-code-eliminator

### PHASE 2: RELATIONAL ANALYSIS & TASK GENERATION

| Command | Purpose | Duration | File |
|---------|---------|----------|------|
| `/phase-2` | Execute Phase 2 analysis (5 agents sequential) | 2-3 hrs | Part 1 |
| `/phase-2-task-generation` | Regenerate task list if needed | 30 min | Part 1 |
| `/phase-2-validate` | Validation Gate 2 (Karen + Jenny) | 60 min | Part 1 |

**Phase 2 Agents:**

- identifier-and-relational-expert
- dependency-inconsistency-resolver
- performance-optimization-wizard
- codebase-refactorer
- standards-enforcer
- Task-Expert SKILL (task generation)

### PHASE 3: IMPLEMENTATION EXECUTION (4 TIERS)

| Command | Purpose | Duration | File |
|---------|---------|----------|------|
| `/phase-3-tier-1` | Execute Tier 1: Security Hardening | 1-2 hrs | Part 2 |
| `/phase-3-tier-1-validate` | Validation Gate 3A (Karen + Jenny) | 45 min | Part 2 |
| `/phase-3-tier-2` | Execute Tier 2: Error & Dependency Fixes | 1-2 hrs | Part 2 |
| `/phase-3-tier-2-validate` | Validation Gate 3B (Karen + Jenny) | 45 min | Part 2 |
| `/phase-3-tier-3` | Execute Tier 3: Optimization & Refactoring | 1-2 hrs | Part 2 |
| `/phase-3-tier-3-validate` | Validation Gate 3C (Karen + Jenny) | 45 min | Part 2 |
| `/phase-3-tier-4` | Execute Tier 4: Standards & Cleanup | 0.5-1 hr | Part 2 |
| `/phase-3-tier-4-validate` | Validation Gate 3D (Karen + Jenny) | 45 min | Part 2 |

**Phase 3 Agent:**

- codebase-composer (orchestrates all tiers)

### PHASE 4: FINAL VALIDATION & DELIVERY

| Command | Purpose | Duration | File |
|---------|---------|----------|------|
| `/phase-4` | Execute Phase 4 comprehensive testing | 1-2 hrs | Part 2 |
| `/phase-4-validate` | Final Validation Gate (Karen + Jenny approval) | 60 min | Part 2 |
| `/generate-master-report` | Generate final Master Report | 30 min | Part 2 |

**Phase 4 Agent:**

- testing-and-validation-specialist

### VALIDATION & SPECIAL COMMANDS

| Command | Purpose | Usage | File |
|---------|---------|-------|------|
| `/validation-gate` | Generic validation gate assessment | When needing manual assessment | Part 2 |
| `/rework` | Handle failed validation gates | When validation fails | Part 2 |
| `/escalate` | Escalate to Error Eliminator Commander | When Karen & Jenny disagree | Part 2 |

---

## EXECUTION PATH

### Normal Workflow Execution

```bash
1. /workflow-init
   ↓
2. /workflow-start → /phase-1
   ↓
3. /phase-1-validate (PASS)
   ↓
4. /phase-2
   ↓
5. /phase-2-validate (PASS)
   ↓
6. /phase-3-tier-1
   ↓
7. /phase-3-tier-1-validate (PASS)
   ↓
8. /phase-3-tier-2
   ↓
9. /phase-3-tier-2-validate (PASS)
   ↓
10. /phase-3-tier-3
    ↓
11. /phase-3-tier-3-validate (PASS)
    ↓
12. /phase-3-tier-4
    ↓
13. /phase-3-tier-4-validate (PASS)
    ↓
14. /phase-4
    ↓
15. /phase-4-validate (APPROVE)
    ↓
16. /generate-master-report
    ↓
✅ WORKFLOW COMPLETE
```

### If Validation Fails

```bash
At any validation gate:

If FAIL:
   → Use /rework to address issues
   → Re-run the phase
   → Re-run the validation gate
   → If still fails after 2 attempts:
      → Use /escalate to Error Eliminator Commander
```

---

## COMMAND FILE LOCATIONS

### Part 1: Workflow Start, Phase 1, Phase 2

**File:** `SLASH_COMMANDS_Part_1.md`

Commands:

- /workflow-init
- /workflow-start
- /phase-1
- /phase-1-validate
- /phase-2
- /phase-2-task-generation
- /phase-2-validate

### Part 2: Phase 3 & 4, Special Commands

**File:** `COMPLETE_SLASH_COMMANDS_Library.md`

Commands:

- /phase-3-tier-1 through /phase-3-tier-4 (+ validations)
- /phase-4
- /phase-4-validate
- /generate-master-report
- /validation-gate
- /rework
- /workflow-status
- /escalate

---

## HOW TO USE THESE COMMANDS

### Step 1: COPY THE COMMAND

Find the command in the appropriate file and copy the entire command block:

```bash
From: /command-name
To: END COMMAND
```

Copy everything including the slash command line and the END COMMAND marker.

### Step 2: PASTE INTO CLAUDE CODE

Open Claude Code and paste the entire command into the chat.

### Step 3: ALLOW EXECUTION

Let Claude Code execute the command fully. Don't interrupt mid-execution.

### Step 4: REVIEW OUTPUT

After command completes, review the output and next steps.

### Step 5: PROCEED TO NEXT COMMAND

Follow the "Next Command" instruction in the output.

---

## COMMAND DETAILS BY PHASE

### PHASE 1 WORKFLOW

```bash
/phase-1
├─ Invokes security-vulnerability-hunter (parallel)
├─ Invokes root-cause-analysis-expert (parallel)
├─ Invokes dead-code-eliminator (parallel)
├─ Consolidates findings into Phase 1 Report
└─ Next: /phase-1-validate

/phase-1-validate
├─ Invokes Karen (reality check)
├─ Invokes Jenny (specification audit)
├─ Makes decision: PASS / CAUTION / REWORK
└─ Next: /phase-2 (if PASS)
```

**Phase 1 Duration:** ~3 hours (2-3 hrs analysis + 45 min validation)

### PHASE 2 WORKFLOW

```bash
/phase-2
├─ Invokes identifier-and-relational-expert
├─ Invokes dependency-inconsistency-resolver
├─ Invokes performance-optimization-wizard
├─ Invokes codebase-refactorer
├─ Invokes standards-enforcer
├─ Invokes Task-Expert SKILL (generates task list)
├─ Consolidates findings into Phase 2 Report
└─ Next: /phase-2-validate

/phase-2-validate
├─ Invokes Karen (feasibility check)
├─ Invokes Jenny (completeness audit)
├─ Makes decision: PASS / CAUTION / REWORK
└─ Next: /phase-3-tier-1 (if PASS)
```

**Phase 2 Duration:** ~3-4 hours (2-3 hrs analysis + 60 min validation)

### PHASE 3 WORKFLOW

```bash
/phase-3-tier-1 → /phase-3-tier-1-validate ✓
   ↓
/phase-3-tier-2 → /phase-3-tier-2-validate ✓
   ↓
/phase-3-tier-3 → /phase-3-tier-3-validate ✓
   ↓
/phase-3-tier-4 → /phase-3-tier-4-validate ✓
   ↓
Next: /phase-4
```

**Phase 3 Duration:** ~6-8 hours total (4-6 hrs implementation + 3 hrs validation)

### PHASE 4 WORKFLOW

```bash
/phase-4
├─ Invokes testing-and-validation-specialist
├─ Comprehensive testing of all changes
└─ Next: /phase-4-validate

/phase-4-validate
├─ Invokes Karen (final readiness)
├─ Invokes Jenny (final compliance)
├─ Makes decision: APPROVE / CONDITIONS / REJECT
└─ Next: /generate-master-report (if APPROVE)

/generate-master-report
├─ Generates comprehensive Master Report
├─ Summary of entire workflow
└─ ✅ WORKFLOW COMPLETE
```

**Phase 4 Duration:** ~2-3 hours (1-2 hrs testing + 60 min validation + 30 min report)

---

## TOTAL WORKFLOW TIME

- **Estimated Total Duration: 14-18 hours**

This can be broken across multiple sessions:

- **Option 1: Full 1-Day Session**

- Phase 1 + Validation: 3 hours
- Phase 2 + Validation: 3-4 hours
- Break: 1 hour
- Phase 3 + Validation: 6-8 hours
- Phase 4 + Report: 2-3 hours
- Total: ~15-18 hours

- **Option 2: Multi-Day Sessions**

- Day 1: Phase 1 + Phase 2 (6-7 hours)
- Day 2: Phase 3 (6-8 hours)
- Day 3: Phase 4 + Report (2-3 hours)

---

## KAREN & JENNY VALIDATION

All validation gates invoke:

1. **Karen** (Project Reality Manager - Sonnet model)
   - Focuses on: Pragmatic feasibility, resource requirements, risks
   - Scoring: 0-10 scale
   - Decision: PASS / CAUTION / REWORK (or similar)

2. **Jenny** (Senior Software Engineering Auditor - Opus model)
   - Focuses on: Specification compliance, completeness, quality
   - Scoring: 0-10 scale
   - Decision: PASS / CONCERN / FAIL (or similar)

**Decision Matrix:**

```bash
Both PASS/COMPLIANT    → ✅ PROCEED
One PASS, One CONCERN  → ⚠️ CAUTION
Either FAIL/DISAGREE   → ❌ REWORK
```

---

## ERROR HANDLING

### If Command Incomplete

If a command doesn't complete fully:

1. Check the error/issue reported
2. Address the specific error
3. Re-run the command

### If Validation Failss

1. Use `/rework` command
2. Fix the identified issues
3. Re-run the failed validation

### If Karen & Jenny Disagree

1. They present their reasoning
2. They attempt reconciliation
3. If unresolved: Use `/escalate` for Error Eliminator arbitration

---

## BEST PRACTICES

### 1. FOLLOW SEQUENCE STRICTLY

Do NOT skip phases or tiers. Execute in strict order:
Phase 1 → Phase 2 → Tier 1-4 → Phase 4

### 2. COMPLETE VALIDATION BEFORE PROCEEDING

Never proceed to next phase without validation passing.

### 3. SAVE OUTPUTS

All outputs are saved to `reports/` directory. These are your audit trail.

### 4. DOCUMENT DECISIONS

If using `/rework` or `/escalate`, document what was changed and why.

### 5. VALIDATE THOROUGHLY

Don't rush validation gates. Let Karen and Jenny complete full assessments.

### 6. TAKE BREAKS

This is 14-18 hours of work. Break it into manageable sessions.

---

## TROUBLESHOOTING

### Command Not Found

Ensure you're copying the ENTIRE command including `/command-name` line.

### Agent Not Responding

- Check agent is installed in `.claude/agents/`
- Verify agent filename matches exactly
- Try re-running the command

### Validation Keeps Failing

- Use `/rework` to identify root cause
- Address the fundamental issue (not just symptom)
- Re-run from beginning of failed phase

### Memory/Token Issues

- Break into multiple sessions
- Run one phase at a time
- Save outputs between sessions

### Lost Track of Progress

Use `/workflow-status` to check current state and see what's complete.

---

## COMMAND QUICK COPY REFERENCE

For quick access, here are abbreviated command names:

```bash
Initialization:
  /workflow-init              Initialize environment
  /workflow-start             Begin workflow

Phase 1:
  /phase-1                   Execute Phase 1 analysis
  /phase-1-validate          Phase 1 validation gate

Phase 2:
  /phase-2                   Execute Phase 2 analysis
  /phase-2-task-generation   Regenerate task list
  /phase-2-validate          Phase 2 validation gate

Phase 3 - Tier by Tier:
  /phase-3-tier-1            Execute Tier 1 (Security)
  /phase-3-tier-1-validate   Validate Tier 1
  /phase-3-tier-2            Execute Tier 2 (Errors)
  /phase-3-tier-2-validate   Validate Tier 2
  /phase-3-tier-3            Execute Tier 3 (Optimization)
  /phase-3-tier-3-validate   Validate Tier 3
  /phase-3-tier-4            Execute Tier 4 (Standards)
  /phase-3-tier-4-validate   Validate Tier 4

Phase 4:
  /phase-4                   Execute Phase 4 testing
  /phase-4-validate          Final validation gate
  /generate-master-report    Generate final report

Special:
  /workflow-status           Check progress
  /validation-gate           Manual validation
  /rework                    Handle failures
  /escalate                  Escalate to Commander
```

---

## SUCCESS CRITERIA

Your workflow execution is successful when:

✅ All phases complete in order  
✅ All agents invoked completely  
✅ All validation gates PASS  
✅ All tier implementations complete  
✅ Final approval granted by Karen and Jenny  
✅ Master Report generated  
✅ Zero blocking issues at workflow end  

---

## FILE REFERENCES

### Command Files

- `SLASH_COMMANDS_Part_1.md` - Workflow init through Phase 2
- `COMPLETE_SLASH_COMMANDS_Library.md` - Phase 3, Phase 4, special commands

### Workflow Documentation

- `Part_1_Agent_Definitions_System_Prompts.md` - Agent specifications
- `Part_2_Workflow_Orchestration_Process_Flow.md` - Workflow strategy
- `Part_3_Validation_Gates_Quality_Assurance.md` - Validation procedures
- `Part_4_Implementation_Guide_Commands.md` - Implementation details

### Generated Reports (saved during workflow)

- `reports/phase_1_report.md`
- `reports/phase_2_report.md`
- `reports/phase_2_task_list.md`
- `reports/phase_3_tier1_implementation.md`
- `reports/phase_3_tier2_implementation.md`
- `reports/phase_3_tier3_implementation.md`
- `reports/phase_3_tier4_implementation.md`
- `reports/phase_4_testing_report.md`
- `reports/master_error_elimination_report.md`

---

## FINAL NOTES

These custom slash commands are designed to:

✓ Be completely explicit and detailed  
✓ Require no interpretation or improvisation  
✓ Handle all aspects of the workflow  
✓ Include validation at every step  
✓ Ensure nothing is missed  
✓ Produce comprehensive documentation  
✓ Be copy-paste ready for Claude Code  

**Simply copy each command, paste into Claude Code, and let it execute.**

The workflow will unfold systematically, with Karen and Jenny validating at each gate, ensuring your codebase is comprehensively analyzed and improved.

---

**READY TO START?**

1. Open Claude Code
2. Copy `/workflow-init` from SLASH_COMMANDS_Part_1.md
3. Paste into Claude Code chat
4. Follow the sequence
5. Let the workflow complete

**Good luck with your Error Elimination Workflow!** 🚀

---

**Custom Slash Commands - Complete Library**  
**Version 2.0 - Production Ready**  
**~6,000+ lines of explicit command specifications**
