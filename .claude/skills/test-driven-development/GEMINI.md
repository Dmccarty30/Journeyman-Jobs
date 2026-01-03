# Test-Driven Development (TDD)

Write the test first. Watch it fail. Write minimal code to pass.

**Core principle: If you didn't watch the test fail, you don't know if it tests the right thing.**

## The Iron Law
**NO PRODUCTION CODE WITHOUT A FAILING TEST FIRST.**
If you write code before the test, delete it and start over.

## The Red-Green-Refactor Cycle

### 1. RED: Write Failing Test
Write one minimal test showing what should happen.
- Focus on one behavior.
- Use a clear, descriptive name.
- Use real code (avoid mocks if possible).

**Verify RED**: Run the test and confirm it fails for the expected reason (feature missing, not a typo).

### 2. GREEN: Minimal Code
Write the simplest code possible to pass the test.
- Don't add extra features ("YAGNI" - You Ain't Gonna Need It).
- Don't refactor or "improve" other code yet.

**Verify GREEN**: Run the test and confirm it passes, along with all other tests.

### 3. REFACTOR: Clean Up
Improve the code while keeping the tests green.
- Remove duplication.
- Improve variable/function names.
- Extract helpers.
- **Stay Green**: Ensure tests still pass after refactoring.

## Why Order Matters
Tests written after code (Tests-After) often just verify that the code does what you already built, not what was actually required. Tests-First force you to discover edge cases and design the API before implementation.

## Red Flags - STOP and Start Over
- Code before test.
- Test passes immediately (proves nothing).
- Test after implementation.
- "I already manually tested it."
- "Deleting this code is wasteful" (Sunk cost fallacy).

## Verification Checklist
- [ ] Every new function/method has a test.
- [ ] Watched each test fail before implementing.
- [ ] Wrote minimal code to pass each test.
- [ ] All tests pass and output is clean.
- [ ] Edge cases and errors are covered.

Never fix bugs without a test. The test proves the fix and prevents future regressions.
