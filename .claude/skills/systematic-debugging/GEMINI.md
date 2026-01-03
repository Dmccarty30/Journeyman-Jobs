# Systematic Debugging

Use when encountering any bug, test failure, or unexpected behavior, before proposing fixes. This four-phase framework ensures understanding before attempting solutions.

## The Iron Law

**NO FIXES WITHOUT ROOT CAUSE INVESTIGATION FIRST**

If you haven't completed Phase 1, you cannot propose fixes.

## When to Use

Use for ANY technical issue:
- Test failures
- Bugs in production
- Unexpected behavior
- Performance problems
- Build failures
- Integration issues

## The Four Phases

### Phase 1: Root Cause Investigation
**BEFORE attempting ANY fix:**
1. **Read Error Messages Carefully**: Read stack traces completely; note line numbers, file paths, and error codes.
2. **Reproduce Consistently**: Identify the exact steps to trigger the issue reliably.
3. **Check Recent Changes**: Use `git diff` to see what changed recently.
4. **Gather Evidence**: In multi-component systems, add diagnostic instrumentation (logs) to identify WHERE it breaks.
5. **Trace Data Flow**: Trace where bad values originate and how they flow through the system.

### Phase 2: Pattern Analysis
**Find the pattern before fixing:**
1. **Find Working Examples**: Locate similar working code in the same codebase.
2. **Compare Against References**: Read reference implementations completely.
3. **Identify Differences**: List every difference between working and broken code.
4. **Understand Dependencies**: Check settings, config, environment, and assumptions.

### Phase 3: Hypothesis and Testing
**Scientific method:**
1. **Form Single Hypothesis**: State clearly: "I think X is the root cause because Y".
2. **Test Minimally**: Make the SMALLEST possible change to test the hypothesis.
3. **Verify Before Continuing**: If it didn't work, form a NEW hypothesis; don't stack fixes.

### Phase 4: Implementation
**Fix the root cause, not the symptom:**
1. **Create Failing Test Case**: Automated test or script that reproduces the issue.
2. **Implement Single Fix**: Address the root cause identified.
3. **Verify Fix**: Ensure the test passes and no other tests are broken.
4. **If Fix Doesn't Work**: STOP. If you've tried 3+ fixes, question the architecture.

## Red Flags - STOP and Follow Process
- "Quick fix for now, investigate later"
- "Just try changing X and see if it works"
- Proposing solutions before tracing data flow
- Trying 3+ fixes without success (indicates architectural problem)
