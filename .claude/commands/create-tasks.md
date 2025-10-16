---
allowed-tools: Bash, Read, SlashCommand
description: Initiates comprehensive multi-agent workflow for task creation from codebase analysis
---

# create-tasks

This command launches a comprehensive multi-agent workflow that analyzes the codebase using specialized agents and generates actionable task lists for implementation.

## Workflow Overview

1. **Parallel Agent Execution**: Runs auth-expert, backend-architect, and database-optimizer simultaneously for comprehensive analysis
2. **Report Synthesis**: codebase-coordinator merges all individual reports into unified comprehensive analysis
3. **Task Generation**: task-expert converts the comprehensive report into executable task list
4. **Agent Orchestration**: Spawns relevant subagents for implementation based on task requirements

## Execution Instructions

When `/create-tasks` is invoked:

### Phase 1: Parallel Analysis

- Execute *enhanced-auth-eval on auth-expert for authentication system analysis
- Execute backend analysis on backend-architect for API/service architecture review
- Execute *optimize on database-optimizer for Firestore performance and data modeling analysis
- All three agents run in parallel and generate individual markdown reports

### Phase 2: Report Coordination

- codebase-coordinator ingests all three reports
- Synthesizes findings into comprehensive HTML and Markdown report using COMPREHENSIVE_CODEBASE_REPORT.md format
- Includes unified priorities, dependencies, and implementation roadmap

### Phase 3: Task Creation

- task-expert processes the comprehensive report
- Generates prioritized task list with agent assignments
- Each task includes technical details, validation criteria, and dependencies

### Phase 4: Implementation Orchestration

- Claude Code reviews task list and spawns appropriate subagents
- Tasks marked [P] for parallel execution run concurrently
- Sequential tasks execute in dependency order
- Progress tracked with completion checkboxes

## Context Files to Load

Reading these files provides complete understanding of agent capabilities and workflow:

- @.claude/agents/auth-expert.md - Authentication specialist with *enhanced-auth-eval command
- @.claude/agents/backend-architect.md - API and service architecture expert
- @.claude/agents/database-optimizer.md - Firebase/Firestore optimization expert
- @.claude/agents/codebase-coordinator.md - Report synthesis and prioritization
- @.claude/agents/task-expert.md - Task creation from reports

## Expected Deliverables

1. **Individual Agent Reports**: auth-report.md, backend-report.md, database-report.md
2. **Comprehensive Report**: COMPREHENSIVE_CODEBASE_REPORT.md (both HTML and Markdown versions)
3. **Task List**: TASK_LIST.md with prioritized implementation tasks

## Quality Assurance

- All analysis based on current codebase state
- Reports include specific file paths, line numbers, and technical details
- Tasks are actionable with clear success criteria
- Parallel execution maximized for workflow efficiency
