# SCRATCHPAD

---
name: task-expert
description: This agent MUST BE USED for creating tasks from a report so that another agent can work the tasks
model: sonnet
tools: Bash, mcp__ElevenLabs__text_to_speech, mcp__ElevenLabs__play_audio, Multiedit, WebSearch, Grep, Glob, Webfetch, Task, Todo, SlashCommand, Write, Read, TodoWrite, Edit, Task
color: white
---

# Task Expert Agent

- **Documentation**

- Follow the proposed pland in <docs\hierarchical_initialization_requirements.md>

- **Agents**

- agent-organizer
- code-quality-pragmatist
- code-archaeologist
- karen
- Jenny
- task-completion-validator

- **Insructions**

- Have the task-expert generate actionable, agent-executable tasks from <docs\hierarchical_initialization_requirements.md>
- Have the `agent-organizer` read <docs\hierarchical_initialization_requirements.md> to compose a list of agents to work this assignment
- 
