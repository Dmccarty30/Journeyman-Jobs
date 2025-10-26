# AI Documentation Q&A - haiku45

## Fetch Results

- ✅ Success: <https://docs.claude.com/en/docs/claude-code/hooks> → hooks.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/sub-agents> → sub-agents.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/skills> → skills.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/plugins> → plugins.md
- ✅ Success: <https://blog.google/technology/google-deepmind/gemini-computer-use-model/> → gemini-computer-use.md
- ✅ Success: <https://developers.openai.com/blog/realtime-api> → openai-realtime-api.md
- ✅ Success: <https://developers.openai.com/blog/responses-api> → openai-responses-api.md

## Question 1: Subagents Priority System

**Answer**: The Claude Code subagent priority system determines which subagent is used when naming conflicts occur through a three-tier hierarchy:

1. **Project-level subagents** (Highest Priority): Located in `.claude/agents/` directory, these are available only within the current project scope. They take precedence over all other subagent sources.

2. **User-level subagents** (Lower Priority): Located in `~/.claude/agents/` directory, these are available across all projects but have lower priority than project-level subagents.

3. **CLI-defined subagents** (Middle Priority): Defined dynamically using the `--agents` CLI flag in JSON format, CLI-defined subagents have lower priority than project-level subagents but higher priority than user-level subagents. They are useful for quick testing, session-specific configurations, or automation scripts.

**Specific Example Scenario**:
Consider a project developing a security tool. The developer might have:

- A user-level `code-reviewer` subagent (at `~/.claude/agents/code-reviewer.md`) that provides general code review capabilities
- A project-level `code-reviewer` subagent (at `.claude/agents/code-reviewer.md`) customized for security-focused review with specific security checks
- When Claude Code needs a code reviewer, it will automatically use the project-level version because it has the highest priority

This allows teams to customize subagents for specific projects while maintaining personal baseline subagents, and enables one-off testing via CLI flags without permanently overriding existing configurations.

## Question 2: Plugin Directory Structure

**Answer**: The complete directory structure required for a comprehensive Claude Code plugin includes:

```
my-plugin/
├── .claude-plugin/
│   └── plugin.json           # Plugin manifest (required)
├── commands/                  # Custom slash commands (optional)
│   └── hello.md
├── agents/                    # Custom agents (optional)
│   └── helper.md
├── hooks/                     # Event handlers (optional)
│   └── hooks.json
├── skills/                    # Agent Skills (optional)
│   └── skill-name/
│       └── SKILL.md
├── mcp/                       # MCP server integration (optional)
│   └── .mcp.json
├── README.md                  # Documentation (recommended)
└── other-files/              # Supporting resources (optional)
```

**Purpose of the .claude-plugin directory**:
The `.claude-plugin` directory is the metadata container for the plugin. It contains critical configuration files that Claude Code reads to understand and load the plugin.

**Required files in .claude-plugin**:

- **plugin.json**: The plugin manifest containing metadata such as:
  - name: Unique identifier for the plugin
  - description: What the plugin does
  - version: Semantic version
  - author: Plugin creator information

**Optional components**:

- **commands/**: Directory containing custom slash command definitions (markdown files with prompts)
- **agents/**: Directory with custom subagent definitions that integrate seamlessly
- **hooks/**: Event handler configuration for automation (hooks.json or custom paths specified in plugin manifest)
- **skills/**: Agent Skills that provide model-invoked capabilities
- **mcp/**: Model Context Protocol server configuration for integrating external tools

When a plugin is enabled, all components are automatically merged with user and project configurations, making them available throughout Claude Code. Plugin hooks use the `${CLAUDE_PLUGIN_ROOT}` environment variable to reference plugin files.

## Question 3: Skills vs Subagents

**Answer**: Agent Skills and subagents are distinct capabilities with important differences in invocation, context, and use cases:

### Invocation Differences

**Agent Skills**:

- **Model-invoked**: Claude autonomously decides when to use a Skill based on the request content and the Skill's description
- User doesn't explicitly invoke Skills; they activate automatically when relevant
- Invocation is implicit and context-driven

**Subagents**:

- **User-requested or auto-delegated**: Can be explicitly invoked by mentioning them ("Use the code-reviewer subagent") or automatically delegated based on task description and subagent description
- Supports both explicit and implicit invocation paths
- More direct control over when they're used

### Context Management Differences

**Agent Skills**:

- Operate within the main conversation context
- Use progressive disclosure to manage context efficiently (files loaded only when needed)
- Add capability without isolating context
- Good for preserving conversation continuity

**Subagents**:

- Operate in separate context windows independent from the main conversation
- Start with a clean slate each time invoked
- Prevent context pollution of main conversation
- Better for long sessions where context preservation is critical

### Use Cases and Preferences

**When to use Agent Skills**:

1. **Capability extension**: Adding specific expertise without isolating the agent (e.g., "PDF processing", "Excel analysis", "commit message generation")
2. **Model-driven activation**: Tasks where Claude should autonomously decide if the capability applies
3. **Context continuity**: Situations where you want the main conversation to flow naturally with added capabilities
4. **Team workflows**: Packaging reusable expertise as discoverable capabilities within projects
5. **Progressive expertise**: Building up Claude's capabilities incrementally

**Specific examples where Skills are preferred**:

- PDF text extraction and form filling
- Excel spreadsheet analysis and pivot table generation
- Git commit message generation
- Code quality verification
- Data analysis from log files

**When to use Subagents**:

1. **Specialized task delegation**: Delegating complete, focused tasks to specialized experts (e.g., "code-reviewer", "debugger", "data-scientist")
2. **Explicit control**: When you want direct control over when an agent engages
3. **Context preservation**: In long-running sessions where you need to preserve main conversation context
4. **Tool restriction**: When you want specific agents to have limited tool access
5. **Separate expertise areas**: Distinct problem-solving domains with specialized configurations

**Specific examples where Subagents are preferred**:

- A dedicated code reviewer that runs explicitly after changes
- A debugger subagent for error investigation
- A data scientist subagent for complex analysis queries
- A security specialist for vulnerability assessment
- Specialized test runners that run independently

### Comparison Summary

| Aspect                | Agent Skills                | Subagents                               |
| --------------------- | --------------------------- | --------------------------------------- |
| **Invocation**        | Model-driven (automatic)    | User-requested or auto-delegated        |
| **Context**           | Shared main context         | Separate context window                 |
| **Discovery**         | Autonomous based on request | Based on explicit mention or task match |
| **Best for**          | Adding capabilities         | Delegating specialized tasks            |
| **Context pollution** | Minimal                     | None (isolated)                         |
| **Session length**    | Good for preserving context | Better for very long sessions           |
| **Tool control**      | Limited restrictions        | Full control via tool specification     |
| **Activation**        | Implicit/automatic          | Explicit/semi-explicit                  |

The choice between Skills and Subagents depends on whether you want Claude to autonomously apply additional capabilities (Skills) or whether you want to explicitly delegate specialized tasks to dedicated agents (Subagents).
