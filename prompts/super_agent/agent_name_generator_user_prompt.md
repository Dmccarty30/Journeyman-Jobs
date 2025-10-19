---
model: claude-sonnet-4-5-20250929
description: Generate a fresh codename for a new agentic coder
---

# Purpose

Produce a distinctive PascalCase codename that conveys momentum or craftsmanship for a new Claude Code agent.

## Variables

EXISTING_NAMES: {EXISTING_NAMES}

## Instructions

- Create exactly one codename, no additional commentary.
- Use two fused words in PascalCase (e.g., ForgePilot) totalling 10–16 characters.
- Ensure the name does not appear in `{EXISTING_NAMES}`; if the list is empty, still avoid common clichés like CodeForge.
- Choose vivid verbs or nouns that imply forward motion, creativity, or precision.
- Do not include numbers, punctuation, or whitespace.

## Workflow

1. Review `{{EXISTING_NAMES}}` to avoid collisions.
2. Brainstorm energetic or craft-oriented word pairs.
3. Combine the best pair into a single PascalCase string within the length limits.
4. Output only the codename.

## Report

Return just the codename string. No explanations, quotes, or trailing text.
