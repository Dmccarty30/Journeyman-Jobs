Execute Phase 3 - Tier 4: Standards & Cleanup

PRE-TIER CHECKLIST:
✓ Tier 3 validation complete
✓ All STD-* (standards) and CLN-* (cleanup) tasks identified
✓ Codebase-Composer ready

TIER 4 EXECUTION:

STEP 1: EXTRACT STANDARDS & CLEANUP TASKS
- Total standards tasks: [X]
- Total cleanup tasks: [X]

---

STEP 2: INVOKE CODEBASE-COMPOSER FOR TIER 4
Agent: codebase-composer
Priority: MEDIUM
Model: opus

Instruction:
"codebase-composer: Orchestrate Tier 4 standards and cleanup.

TIER 4 TASKS (STANDARDS & CLEANUP):
[Insert all STD-* and CLN-* tasks]

STANDARDS & CLEANUP ORCHESTRATION:

STEP 1: STANDARDS ENFORCEMENT (Priority 1)
Apply all code standards:
├─ Fix naming inconsistencies
├─ Correct formatting violations
├─ Update comments and documentation
├─ Apply linting standards
├─ Enforce consistent patterns

For each standards task:
├─ Identify violations
├─ Apply corrections
├─ Verify standards met
├─ Run linting tools
├─ Document changes

STEP 2: DEAD CODE REMOVAL (Priority 2)
Remove all dead code:
├─ Delete unused imports
├─ Remove unused functions
├─ Delete unused variables
├─ Remove dead branches
├─ Clean up obsolete code

For each cleanup task:
├─ Verify safe to remove
├─ Remove the code
├─ Test nothing breaks
├─ Verify removal complete
├─ Document removal

STEP 3: FINAL VERIFICATION
├─ All standards applied
├─ Dead code completely removed
├─ Codebase clean and consistent
├─ No obvious quality issues remaining

STEP 4: DOCUMENTATION
├─ Document standards applied
├─ Record dead code removed
├─ Update codebase documentation
├─ Final cleanup summary

DELIVERABLE:
Generate comprehensive Tier 4 report:
- Standards tasks: X/[Total] completed
- Cleanup tasks: X/[Total] completed
- Standards compliance: [%]
- Dead code removed: X items
- Files cleaned
- Status: COMPLETE

OUTPUT: Save as reports/phase_3_tier4_implementation.md

Execute tier 4 standards and cleanup now."

---

STEP 3: TIER 4 COMPLETION
Display:
"✅ Tier 4 (Standards & Cleanup) Execution Complete

Implementation Report: reports/phase_3_tier4_implementation.md
Standards Tasks: [X/Total]
Cleanup Tasks: [X/Total]

Codebase State:
- Standards compliance: [%]
- Dead code removed: X items
- Codebase quality: [Excellent/Good/Acceptable]

All Phase 3 Tiers Complete!

Ready for Validation Gate 3D (Final Tier Approval)

Next Command: /phase-3-tier-4-validate"

END COMMAND