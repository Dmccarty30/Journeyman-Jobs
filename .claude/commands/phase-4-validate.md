Execute Final Validation Gate: Production Approval

---

STEP 1: KAREN ASSESSMENT
Agent: karen-reality-manager
Model: sonnet

Instruction:
"karen-reality-manager: Final production readiness assessment.

COMPLETE WORKFLOW RESULTS:
[Insert all Phase 3 and Phase 4 reports]
[Insert testing report]

FINAL REALITY CHECK:

Question 1: System Production Ready?
- Is system truly ready for production?
- All major issues resolved?
- Acceptable risk level?
Response: [Assessment]

Question 2: Overall System Health?
- System stable and performant?
- No known critical issues?
- Can handle production load?
Response: [Assessment]

Question 3: Deployment Readiness?
- Deployment procedures ready?
- Rollback plan prepared?
- Team ready to deploy?
Response: [Assessment]

Question 4: Post-Deployment Support?
- Support team prepared?
- Documentation ready?
- Monitoring in place?
Response: [Assessment]

Question 5: Final Recommendation?
- Recommend production deployment? Yes/No
- Any final concerns?
- Conditions for deployment?
Response: [Assessment]

FINAL DECISION: APPROVE / APPROVE WITH CONDITIONS / REJECT

=== KAREN'S FINAL ASSESSMENT ===
[Complete assessment]
FINAL DECISION: [APPROVE/CONDITIONS/REJECT]
=== END ==="

Save to: reports/final_karen_approval.md

---

STEP 2: Jenny ASSESSMENT
Agent: Jenny-spec-auditor
Model: opus

Instruction:
"Jenny-spec-auditor: Final specification compliance verification.

COMPLETE WORKFLOW RESULTS:
[Insert all reports]

FINAL COMPLIANCE VERIFICATION:

Question 1: ALL Issues Resolved?
- Every issue from Phase 1 addressed?
- 100% completion?
Response: [Verification]

Question 2: All Tasks Completed?
- Every task from Phase 2 executed?
- Nothing left unfinished?
Response: [Verification]

Question 3: Quality Standards Met?
- Code meets all quality standards?
- Zero issues with specifications?
Response: [Verification]

Question 4: Testing Complete?
- Comprehensive testing done?
- All scenarios covered?
Response: [Verification]

Question 5: Final Specification Compliance?
- Deliverable meets all specifications?
- All requirements satisfied?
- Production-grade quality?
Response: [Verification]

FINAL DECISION: APPROVE / APPROVE WITH CONDITIONS / REJECT

=== Jenny'S FINAL VERIFICATION ===
[Complete verification]
FINAL DECISION: [APPROVE/CONDITIONS/REJECT]
=== END ==="

Save to: reports/final_Jenny_approval.md

---

STEP 3: MASTER REPORT GENERATION
After both approvals:

/generate-master-report

END COMMAND