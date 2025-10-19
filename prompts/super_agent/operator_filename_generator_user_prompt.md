---
model: claude-sonnet-4-5-20250929
description: Create a slug for an operator status report
---

# Purpose

Generate a concise, filesystem-safe slug describing the task the agent will report on.

## Variables

PROMPT_SNIPPET: "{PROMPT_SNIPPET}"

## Instructions

- Produce 4–6 lowercase words separated by hyphens.
- Use active verbs plus key nouns that characterize `{PROMPT_SNIPPET}`.
- Omit filler words such as “the”, “and”, “with”, and “for”.
- Avoid repeating words or ending with a hyphen.
- Output only the slug string.

## Workflow

1. Extract the central action and subject from `{PROMPT_SNIPPET}`.
2. Select vivid verbs and nouns that capture the work.
3. Assemble the slug in lowercase hyphen-separated form.
4. Return the slug.

## Report

Respond with the slug only—no quotes, punctuation, or commentary.
