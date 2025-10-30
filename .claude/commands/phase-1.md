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
