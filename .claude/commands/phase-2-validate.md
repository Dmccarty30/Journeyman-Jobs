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