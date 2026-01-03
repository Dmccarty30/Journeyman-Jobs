# Verification Before Completion

Evidence before claims, always. Claiming work is complete without verification is a failure of process.

## The Iron Law
**NO COMPLETION CLAIMS WITHOUT FRESH VERIFICATION EVIDENCE.**

## The Gate Function
Before claiming success or satisfaction:
1. **Identify**: What command or test proves this claim?
2. **Run**: Execute the FULL, fresh command.
3. **Read**: Inspect the full output, exit codes, and failure counts.
4. **Verify**: Does the output explicitly confirm the claim?
5. **State**: Report the result WITH the evidence.

## When to Apply
- Before saying "Done", "Fixed", or "Passed".
- Before committing code or creating a Pull Request.
- Before moving to the next task in a plan.
- Before delegating to another agent.

## Red Flags
- Using words like "should", "probably", or "seems to".
- Expressing satisfaction ("Great!", "Perfect!") before running the verification.
- Relying on a previous run or a partial check.
- Trusting an agent's success report without checking the diff or running tests yourself.

## Common Claim Requirements
- **Tests pass**: Requires current test command output showing 0 failures.
- **Linter clean**: Requires current linter output showing 0 errors.
- **Bug fixed**: Requires running the test that originally failed to prove it now passes.
- **Requirements met**: Requires a line-by-line check against the original plan or task.

**No shortcuts. Run the command. Read the output. THEN claim the result.**
