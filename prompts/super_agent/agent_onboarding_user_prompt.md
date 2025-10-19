---
model: claude-sonnet-4-5-20250929
description: Onboard a new agentic coder session
---

# Purpose

Bring the fresh Claude Code session online and confirm readiness for upcoming assignments.

## Variables

AGENT_NAME: "{AGENT_NAME}"
AGENT_TYPE: "{AGENT_TYPE}"

## Instructions

- Address the agent by `{AGENT_NAME}` and clarify their role as `{AGENT_TYPE}`.
- Request that the agent wait for mission details and operator log information.
- Ask for a brief confirmation of readiness—no lengthy introduction needed.

## Workflow

1. Introduce the agent by name and role.
2. Explain that tasks and operator log locations will follow.
3. Prompt the agent to acknowledge readiness with a short confirmation.

## Report

Return a single, well-structured message containing the introduction and readiness request.
