# AI Documentation Q&A - sonnet45

## Fetch Results

- ✅ Success: <https://docs.anthropic.com/en/docs/claude-code/hooks> → ai_docs/sonnet45/claude-code-hooks.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/sub-agents> → ai_docs/sonnet45/claude-code-sub-agents.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/skills> → ai_docs/sonnet45/claude-code-skills.md
- ✅ Success: <https://docs.claude.com/en/docs/claude-code/plugins> → ai_docs/sonnet45/claude-code-plugins.md
- ✅ Success: <https://blog.google/technology/google-deepmind/gemini-computer-use-model/> → ai_docs/sonnet45/gemini-25-computer-use.md
- ✅ Success: <https://developers.openai.com/blog/realtime-api> → ai_docs/sonnet45/openai-realtime-api.md
- ✅ Success: <https://developers.openai.com/blog/responses-api> → ai_docs/sonnet45/openai-responses-api.md

## Question 1: Subagents Priority System

Based on the fetched documentation, the subagents documentation describes two storage locations for subagents:

1. **Project-level**: `.claude/agents/` - Stored within the project repository
2. **User-level**: `~/.claude/agents/` - Stored in the user's home directory

However, the documentation summary does not explicitly describe three distinct priority levels or a detailed priority resolution system for handling naming conflicts between project-level, user-level, and CLI-defined subagents.

The documentation mentions that:

- Subagents can be configured at both project and user levels
- Project-level subagents can be version controlled for team collaboration
- Claude Code can both automatically delegate to subagents based on task descriptions and accept explicit invocation

**Limitation**: The specific priority hierarchy and conflict resolution mechanism when multiple subagents with the same name exist at different levels is not detailed in the fetched documentation summary. A complete answer would require access to more detailed sections of the original documentation that may not have been captured in the summary.

**Example scenario (based on available information)**: If a team has a "code-reviewer" subagent in `.claude/agents/code-reviewer.md` for project-specific code standards, and a developer has their own "code-reviewer" in `~/.claude/agents/code-reviewer.md` with personal preferences, the documentation doesn't explicitly specify which takes precedence.

## Question 2: Plugin Directory Structure

Based on the Claude Code Plugins documentation, a complete plugin requires the following directory structure:

```
plugin-name/
├── .claude-plugin/
│   ├── plugin.json          # Required: Plugin metadata
│   └── marketplace.json      # Required for distribution: Marketplace manifest
├── commands/                 # Optional: Custom slash commands
│   └── command-name.md      # Markdown files defining commands
├── agents/                   # Optional: Custom agent definitions
│   └── agent-name.md        # Agent configuration with YAML frontmatter
├── skills/                   # Optional: Agent Skills
│   └── SKILL.md             # Skill definitions with instructions
└── hooks/                    # Optional: Event handlers
    └── hooks.json           # Hook configurations
```

### Purpose of `.claude-plugin` Directory

The `.claude-plugin` directory is the **required identifier** that marks a directory as a Claude Code plugin. It must contain:

1. **`plugin.json`** (Required): Contains plugin metadata including:
   - Plugin name
   - Description
   - Version information
   - Author details
   - Dependencies

2. **`marketplace.json`** (Required for distribution): Contains marketplace-specific information for plugin discovery and installation:
   - Marketplace name
   - Distribution settings
   - Compatibility information

Without the `.claude-plugin` directory and its `plugin.json` file, Claude Code will not recognize the directory as a valid plugin. This directory serves as the plugin's manifest and configuration hub, while the other directories (`commands/`, `agents/`, `skills/`, `hooks/`) contain the actual functionality components that are optional based on the plugin's purpose.

## Question 3: Skills vs Subagents

Agent Skills and Subagents differ fundamentally in their invocation, context management, and use cases:

### Invocation Differences

**Agent Skills:**

- **Autonomous/Model-Invoked**: Claude automatically recognizes when to activate a Skill based on the task description and the Skill's metadata
- User does not need to explicitly request the Skill
- Triggered based on relevance to the user's request
- Invoked through the Skill tool based on description matching

**Subagents:**

- **Explicit or Automatic Delegation**: Can be invoked explicitly by name ("Use the code-reviewer subagent...") or Claude can automatically delegate based on task-description matching
- Supports both user-requested and autonomous invocation
- More deliberate handoff of control to a specialized agent

### Context Management

**Agent Skills:**

- Operate within the same conversation context
- Do not create separate context windows
- Extend Claude's capabilities in-place with focused instructions
- Lightweight additions to the current workflow

**Subagents:**

- **Isolated Context**: Each subagent operates in its own context window
- Prevents context pollution of the main conversation
- Maintains focus on high-level objectives in main thread
- Each has its own custom system prompt and tool access configuration

### When to Use Each

**Use Agent Skills when:**

1. You need a **lightweight, focused capability** that doesn't require isolation
2. The task should be **automatically recognized** without explicit invocation
3. You want to extend Claude's behavior with **specific procedures or templates**
4. The functionality is **modular but doesn't need separate context**
5. Example: Generating standardized documentation, following specific code formatting rules, or applying consistent review checklists

**Use Subagents when:**

1. You need **context isolation** to prevent polluting the main conversation
2. The task requires **specialized expertise** with detailed domain-specific instructions
3. You want to **restrict tool access** to specific capabilities for security or focus
4. The workflow is **complex enough to benefit from dedicated attention**
5. You need **explicit delegation** for particular types of work
6. Example: Code review workflows that need to examine large diffs in isolation, security auditing with restricted tools, or specialized refactoring tasks

### Specific Use Case Examples

**Skills Preferred:**

- Applying team-specific code formatting standards across files
- Generating API documentation following company templates
- Running standardized checklists for PR reviews
- Creating test cases following project patterns

**Subagents Preferred:**

- Deep code analysis requiring review of multiple large files
- Security auditing where tool access should be limited
- Complex refactoring workflows that benefit from isolated planning
- Task-specific operations that would clutter the main conversation context
