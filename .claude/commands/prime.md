---
allowed-tools: Bash, Read
description: Load context for a new agent session by analyzing codebase structure and README
---

# Prime

This command loads essential context for a new agent session by examining the codebase structure and reading the project README.

## Instructions

- Run `git ls-files` to understand the codebase structure and file organization
- Read the README.md to understand the project purpose, setup instructions, and key information
- Provide a concise overview of the project based on the gathered context
- Read ai_docs\anthropic_docs_subagents.md, ai_docs\claude-code-implementation-guide.md and ai_docs\claude-code-master-guide.md

## Context

- Codebase structure git accessible: !`git ls-files`
- Codebase structure all: !`eza . --tree`
- Project README: @README.md
- Documentation:
  - @ai_docs/cc_hooks_docs.md
  - @ai_docs/uv-single-file-scripts.md
  - @ai_docs/anthropic_custom_slash_commands_2025-08-02.md

IMPORTANT: Use Serena to search through the codebase
