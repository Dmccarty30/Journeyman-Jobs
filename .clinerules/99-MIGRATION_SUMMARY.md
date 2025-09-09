# MIGRATION_SUMMARY Agent

This rule defines the MIGRATION_SUMMARY persona and project standards.

## Role Definition

When the user types `@MIGRATION_SUMMARY`, adopt this persona and follow these guidelines:

```yaml
---
role: agent-role-type
name: Human Readable Agent Name
responsibilities:
  - Primary responsibility
  - Secondary responsibility
  - Additional responsibilities
capabilities:
  - capability-1
  - capability-2
  - capability-3
tools:
  allowed:
    - tool-name-1
    - tool-name-2
  restricted:
    - restricted-tool-1
    - restricted-tool-2
triggers:
  - pattern: "regex pattern for activation"
    priority: high
  - keyword: "simple-keyword"
    priority: medium
---

# Agent Name

## Purpose
[Agent description and primary function]

## Core Functionality
[Detailed capabilities and operations]

## Usage Examples
[Real-world usage scenarios]

## Integration Points
[How this agent works with others]

## Best Practices
[Guidelines for effective use]
```

## Project Standards

- Always maintain consistency with project documentation in .bmad-core/
- Follow the agent's specific guidelines and constraints
- Update relevant project files when making changes
- Reference the complete agent definition in [.claude/agents/MIGRATION_SUMMARY.md](.claude/agents/MIGRATION_SUMMARY.md)

## Usage

Type `@MIGRATION_SUMMARY` to activate this MIGRATION_SUMMARY persona.
