# Writing Skills

**Writing skills is Test-Driven Development applied to process documentation.**

## Core Principle
If you didn't watch an agent fail without the skill, you don't know if the skill teaches the right thing.

## The TDD Cycle for Documentation

### 1. RED: Write Failing Test (Baseline)
Run a pressure scenario with a subagent WITHOUT the skill.
- Document exact behavior and verbatim rationalizations used by the agent to skip steps or ignore rules.
- Identify the exact points where the agent "fails".

### 2. GREEN: Write Minimal Skill
Write a skill that addresses those specific rationalizations and failures.
- **YAML Frontmatter**: `name` and `description` (Max 1024 chars).
- **Description**: Must start with "Use when..." and include specific trigger conditions.
- **Third Person**: Always write in the third person.

**Verify GREEN**: Run the same scenarios WITH the skill. The agent should now comply.

### 3. REFACTOR: Close Loopholes
Identify new rationalizations that emerged even with the skill present.
- **Explicit Counters**: Forbid specific workarounds (e.g., "Don't keep it as reference").
- **Rationalization Table**: Map common excuses to reality.
- **Red Flags**: List symptoms that signal the agent is about to violate the rule.

## Metadata Best Practices
- **Keywords**: Use error messages, symptoms, and tools that an AI would search for.
- **Conciseness**: Aim for <200 words for frequently-loaded skills to save context tokens.
- **Active Naming**: Use verb-first names like `creating-skills` or `root-cause-tracing`.

## Directory Structure
- `SKILL.md`: Main reference.
- `scripts/`: Reusable tools or scripts.
- `resources/`: Supporting templates or examples.

**No skill without a failing test first. No exceptions.**
