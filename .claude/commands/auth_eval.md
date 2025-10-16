---
allowed-tools: Bash, Read
description: Load context for a new agent session by analyzing codebase structure
---

# auth_eval

This command loads essential context for a new agent session by examining the codebase structure and reading the project README.

## Instructions

- Run `git ls-files` to understand the codebase structure and file organization
- Read the README.md to understand the project purpose, setup instructions, and key information
- Provide a concise overview of the project based on the gathered context
- Read docs\Context\architecture_2.0.md, docs\Context\auth-report_2.0.md, docs\Context\PROJECT_SPECS_2.0.md, docs\Context\PROJECT_OVERVIEW_REPORT_2.0.md, docs\Context\continuous-user-authorization-guide_2.0.md, and docs\reports\AUTHENTICATION-SYSTEM-OVERVIEW.md

## Context

- Codebase structure git accessible: !`git ls-files`
- Codebase structure all: !`eza . --tree`
- Project README: @README.md
- Documentation:
  - @docs\reports\AUTHENTICATION-SYSTEM-OVERVIEW.md
  - @docs\Context\architecture_2.0.md
  - @docs\Context\auth-report_2.0.md
  - @docs\Context\PROJECT_SPECS_2.0.md
  - @docs\Context\PROJECT_OVERVIEW_REPORT_2.0.md
  - @docs\Context\continuous-user-authorization-guide_2.0.md

IMPORTANT: Use Serena to search through the codebase
