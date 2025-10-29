Execute Phase 3 - Tier 2: Error & Dependency Fixes

PRE-TIER CHECKLIST:
✓ Tier 1 validation complete (or caution)
✓ Phase 2 task list available
✓ All ERR-* and DEP-* tasks identified
✓ Codebase-Composer ready

TIER 2 EXECUTION:

STEP 1: IDENTIFY ERROR & DEPENDENCY TASKS
Extract all ERR-* (error) and DEP-* (dependency) tasks:
- Total error tasks: [X]
- Total dependency tasks: [X]
- Critical priority: [X]
- High priority: [X]

---

STEP 2: INVOKE CODEBASE-COMPOSER FOR TIER 2
Agent: codebase-composer
Priority: CRITICAL
Model: opus

Instruction:
"codebase-composer: Orchestrate and execute Tier 2 error and dependency fixes.

TIER 2 TASKS (ERROR & DEPENDENCY):
[Insert all ERR-* and DEP-* tasks]
[Include: errors from Phase 1, dependencies from Phase 2]

ERROR & DEPENDENCY FIX ORCHESTRATION:

STEP 1: TASK SEQUENCING
├─ Analyze all error and dependency tasks
├─ Identify dependencies between tasks
├─ Sequence for optimal implementation
├─ Plan for minimal rework

STEP 2: ERROR RESOLUTION (Priority 1)
Execute error resolution tasks in order:
├─ Null pointer fixes
├─ Type mismatch corrections
├─ Logic error fixes
├─ Exception handling improvements
├─ Resource management fixes

For each error task:
├─ Implement the fix
├─ Verify error disappears
├─ Test the fix works
├─ Ensure no regressions
├─ Document change

STEP 3: DEPENDENCY RESOLUTION (Priority 2)
Execute dependency resolution tasks:
├─ Update version conflicts
├─ Resolve circular dependencies
├─ Fix missing dependencies
├─ Update deprecated packages
├─ Ensure compatibility

For each dependency task:
├─ Update to compatible version
├─ Run dependency checks
├─ Verify resolution works
├─ Test integration
├─ Document version update

STEP 4: INTEGRATION VERIFICATION
├─ Verify errors no longer occur
├─ Check dependencies all resolve
├─ Test system runs without errors
├─ Validate no new errors introduced
├─ Confirm no regressions

STEP 5: DOCUMENTATION
├─ Document all fixes made
├─ List error resolutions
├─ List dependency updates
├─ Provide testing summary
├─ Update architecture docs

DELIVERABLE:
Generate comprehensive Tier 2 report:
- Error tasks completed: X/[Total]
- Dependency tasks completed: X/[Total]
- Errors fixed and verified
- Dependencies updated and tested
- Files modified list
- Integration testing results
- Status: COMPLETE / ISSUES

OUTPUT: Save as reports/phase_3_tier2_implementation.md

Execute tier 2 error and dependency fixes now."

---

STEP 3: TIER 2 COMPLETION
After implementation completes:

Display:
"✅ Tier 2 (Error & Dependency Fixes) Execution Complete

Implementation Report: reports/phase_3_tier2_implementation.md
Error Tasks: [X/Total] completed
Dependency Tasks: [X/Total] completed

Improvements Made:
- Error count reduced: X → 0
- Dependency conflicts: X resolved
- System now runs error-free

Ready for Validation Gate 3B

Next Command: /phase-3-tier-2-validate"

END COMMAND