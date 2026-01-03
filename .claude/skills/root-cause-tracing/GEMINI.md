# Root Cause Tracing

Use when errors occur deep in execution and you need to trace back to find the original trigger. Systematically traces bugs backward through the call stack to identify the source of invalid data or incorrect behavior.

**Core principle: ALWAYS trace backward through the call chain until you find the original trigger, then fix at the source.**

## When to Use
- Error happens deep in execution (not at entry point).
- Stack trace shows a long call chain.
- Unclear where invalid data originated.
- Need to find which test/code triggers the problem.

## The Tracing Process

1. **Observe the Symptom**: Note the exact error message (e.g., `git init failed in /wrong/path`).
2. **Find Immediate Cause**: Identify the code directly causing the error (e.g., `execFileAsync('git', ['init'], { cwd: projectDir })`).
3. **Ask: What Called This?**: Trace one level up.
4. **Keep Tracing Up**: Look at the values being passed. If `projectDir` is empty, find out why.
5. **Find Original Trigger**: Continue tracing until you find where the bad value originated (e.g., a variable initialized too early).

## Adding Stack Traces
When you can't trace manually, add instrumentation:

```typescript
// Before the problematic operation
async function someOperation(param: string) {
  const stack = new Error().stack;
  console.error('DEBUG tracing:', { param, stack });
  // ... rest of the code
}
```

- Use `console.error()` to ensure it shows up in test outputs.
- Log BEFORE the dangerous operation.
- Include context: parameters, environment variables, timestamps.

## Finding Which Test Causes Pollution
If something appears during tests but you don't know which test is the polluter, run tests one-by-one to isolate it.

## Key Principle
**NEVER fix just where the error appears.** Fixing the symptom leaves the root cause intact, which will likely cause other bugs later.

1. Found immediate cause.
2. Trace one level up.
3. Is this the source? (If no, keep going).
4. Fix at source.
5. Add validation at each layer (Defense-in-Depth).
