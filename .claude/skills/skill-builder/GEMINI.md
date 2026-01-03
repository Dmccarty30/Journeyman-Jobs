# Skill Builder

Create production-ready skills with proper metadata, directory organization, and progressive disclosure structure.

## Metadata Requirements
Every skill MUST have a clear name and a descriptive purpose that includes:
1. **What** the skill does.
2. **When** it should be used.

## Directory Structure
- `SKILL.md`: The primary instruction file.
- `scripts/`: Optional executable scripts for automation.
- `resources/`: Templates, examples, and supporting data.
- `docs/`: Additional reference documentation.

## Progressive Disclosure Architecture
Skills should be designed to scale without overwhelming the AI's context window:
1. **Level 1: Metadata**: Name and description (always loaded).
2. **Level 2: Skill Body**: Main instructions (loaded when the skill is active).
3. **Level 3: Referenced Files**: Detailed guides, examples, and schemas (loaded only when needed).

## Best Practices
- **Front-Load Keywords**: Put important trigger words at the beginning of the description.
- **Bite-Sized Instructions**: Use Level 2 for common paths and move edge cases to Level 4/Reference.
- **Provide Examples**: Always include concrete, runnable examples of the skill in use.
- **Troubleshooting**: Address common failure points clearly.
