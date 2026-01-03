# Writing Plans

Write comprehensive implementation plans assuming the engineer has zero context for our codebase. Document everything: which files to touch, specific code to add, and how to verify.

## Bite-Sized Task Granularity
Each step should represent a 2-5 minute action:
1. "Write the failing test"
2. "Run it to verify failure"
3. "Implement minimal code to pass"
4. "Verify pass"
5. "Commit"

## Plan Structure
Every plan MUST include:
- **Goal**: One sentence describing the outcome.
- **Architecture**: 2-3 sentences about the approach.
- **Tech Stack**: Key technologies and libraries.
- **Task N**: Specific action blocks with:
    - **Files**: Exact paths to create/modify/test.
    - **Step-by-step**: Implementation and verification commands.
    - **Expected Output**: What successful verification looks like.

## Key Principles
- **Exact paths always**: Never use vague descriptions.
- **Complete code**: Provide the exact snippet to be added.
- **TDD first**: Always include the failing test before implementation.
- **DRY & YAGNI**: Keep the solution simple and avoid over-engineering.

## Saving Plans
Save all plans to `docs/plans/YYYY-MM-DD-<feature-name>.md`.
