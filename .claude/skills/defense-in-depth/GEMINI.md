# Defense-in-Depth Validation

Validate at EVERY layer data passes through. Make the bug structurally impossible.

## Why Multiple Layers
Single validation checks can be bypassed by different code paths, refactoring, or mocks. Multiple layers ensure that if one check fails, another catches it.

## The Four Layers

### Layer 1: Entry Point Validation
**Purpose**: Reject obviously invalid input at the API boundary.
- Check for null/undefined/empty values.
- Verify types and formats.
- Check file existence/permissions if applicable.

### Layer 2: Business Logic Validation
**Purpose**: Ensure data makes sense for the specific operation.
- Validate state prerequisites.
- Check logical constraints (e.g., start date < end date).

### Layer 3: Environment Guards
**Purpose**: Prevent dangerous operations in specific contexts (e.g., tests vs. production).
- Prevent destructive actions in test environments.
- Enforce sandbox constraints.

### Layer 4: Debug Instrumentation
**Purpose**: Capture context for forensics.
- Log inputs, outputs, and stack traces *before* dangerous operations.
- Ensure logs are visible in the relevant context (e.g., use `console.error` for tests).

## Applying the Pattern
1. **Trace Data Flow**: Identify where data comes from and where it goes.
2. **Map Checkpoints**: List every component the data passes through.
3. **Add Validation**: Implement checks at each checkpoint.
4. **Test Each Layer**: Verify that if one layer is bypassed, the next one catches the issue.
