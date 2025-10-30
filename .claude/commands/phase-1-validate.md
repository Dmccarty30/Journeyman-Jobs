# Phase 1 validater command

This command validates phase 1 findings.

## USAGE

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
