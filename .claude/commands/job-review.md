---
allowed-tools: Bash, Read
description: Read, analyze, compare, and review multiple files and provide a detailed report on given criteria listed below.
---

# File Review

This command loads essential context for a new agent session by examining the codebase structure and reading multiple files then providing

## Instructions

- Run `git ls-files` to understand the codebase structure and file organization
- Read the CLAUDE.md to understand the project purpose, setup instructions, and key information
- Provide a concise report of each of the files listed below under Documentation
- For every file listed below generate a report addressing the topics listed below
- Report Topics:
  - Is this file currently in active use in the app?
  - Out of all of the files listed, how does this file benefit the app as a whole?
  - If used in the app would this file help or hurt the app?
  - What about this file makes it a good candidate for implementation?
- Finally, after you have completed the individual reports, generate a comprehensive report that brings all of the individual reports together by addressing these topics:
  - Out of all of the files reviewed, categorize, rank, and explain your reasoning
  - After analyzing each file, what files would you recommend be used in the app to better enhance the UI-UX regarding the jobs feature, the cornerstone and bedrock of the app?

## Context

- Codebase structure git accessible: !`git ls-files`
- Codebase structure all: !`eza . --tree`
- Project context: @CLAUDE.md
- Documentation:
  - @lib\utils\job_formatting.dart
  - @lib\widgets\virtual_job_list.dart
  - @lib\widgets\optimized_virtual_job_list.dart
  - @lib\widgets\rich_text_job_card.dart
  - @lib\design_system\components\job_card_implementation.dart
  - @lib\design_system\components\job_card.dart
  - @lib\models\job_model.dart
  - @lib\providers\riverpod\jobs_riverpod_provider.dart
  - @lib\providers\riverpod\job_filter_riverpod_provider.dart
  - @lib\legacy\flutterflow\schema\jobs_record.dart

IMPORTANT: Use Serena to search through the codebase
