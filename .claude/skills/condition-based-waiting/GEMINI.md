# Condition-Based Waiting

Stop guessing at timing. Arbitrary delays create flaky tests that pass on fast machines but fail under load.

## Core Principle
**Wait for the actual condition or state change you care about, not for a timer to expire.**

## When to Use
- Tests use `setTimeout`, `sleep`, or `time.sleep()`.
- Tests are "flaky" (pass/fail inconsistently).
- Tests fail specifically in CI or under high CPU load.
- You are waiting for async operations, file system changes, or event arrivals.

## Core Pattern
```typescript
// ❌ BAD: Guessing at timing
await sleep(50);
expect(result).toBeDefined();

// ✅ GOOD: Waiting for the state
await waitFor(() => result !== undefined, "result to be defined");
expect(result).toBeDefined();
```

## Quick Reference Patterns
- **Wait for Event**: `waitFor(() => events.find(e => e.type === 'DONE'))`
- **Wait for State**: `waitFor(() => machine.state === 'ready')`
- **Wait for Count**: `waitFor(() => items.length >= 5)`
- **Wait for File**: `waitFor(() => fs.existsSync(path))`

## Best Practices
- **Poll Frequency**: Poll every 10-20ms to avoid wasting CPU.
- **Timeouts**: Always include a max timeout (e.g., 5000ms) with a clear error message.
- **Fresh Data**: Ensure your condition check fetches fresh data inside the loop.

**Only use arbitrary timeouts when testing actual timing-based behavior (like debounce or throttle), and always document WHY it's necessary.**
