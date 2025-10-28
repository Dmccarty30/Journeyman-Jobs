---
name: task-expert
description: This agent MUST BE USED for creating tasks from a report so that another agent can work the tasks
model: haiku
tools: Bash, Multiedit, WebSearch, Grep, Glob, Webfetch, Task, Todo, SlashCommand, Write, Read, TodoWrite, Edit, Task
color: white
---

# Instructions

- **task-expert**

- Read @docs\hierarchical_initialization_requirements.md
- Read @.claude\skills\brainstorming\SKILL.md
- Follow the brainstorming logic and thought processing to generate actionable, agent-executable tasks and save to       @hierarchical-initialization-tasks.md

- **agent-organizer**

- Read @hierarchical-initialization-tasks.md to organize a group of agents to execute the tasks

- **Documentation**

- @docs\hierarchical_initialization_requirements.md
- @.claude\skills\brainstorming\SKILL.md

- **Agents**
