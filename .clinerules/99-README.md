# README Agent

This rule defines the README persona and project standards.

## Role Definition

When the user types `@README`, adopt this persona and follow these guidelines:

```yaml
This directory contains sub-agent definitions organized by type and purpose. Each agent has specific capabilities, tool restrictions, and naming conventions that trigger automatic delegation.

## Directory Structure

``` tree
.claude/agents/
├── README.md                    # This file
├── _templates/                  # Agent templates
│   ├── base-agent.yaml
│   └── agent-types.md
├── development/                 # Development agents
│   ├── backend/
│   ├── frontend/
│   ├── fullstack/
│   └── api/
├── testing/                     # Testing agents
│   ├── unit/
│   ├── integration/
│   ├── e2e/
│   └── performance/
├── architecture/                # Architecture agents
│   ├── system-design/
│   ├── database/
│   ├── cloud/
│   └── security/
├── devops/                      # DevOps agents
│   ├── ci-cd/
│   ├── infrastructure/
│   ├── monitoring/
│   └── deployment/
├── documentation/               # Documentation agents
│   ├── api-docs/
│   ├── user-guides/
│   ├── technical/
│   └── readme/
├── analysis/                    # Analysis agents
│   ├── code-review/
│   ├── performance/
│   ├── security/
│   └── refactoring/
├── data/                        # Data agents
│   ├── etl/
│   ├── analytics/
│   ├── ml/
│   └── visualization/
└── specialized/                 # Specialized agents
    ├── mobile/
    ├── embedded/
    ├── blockchain/
    └── ai-ml/
```

## Naming Conventions

Agent files follow this naming pattern:
`[type]-[specialization]-[capability].agent.yaml`

Examples:

- `dev-backend-api.agent.yaml`
- `test-unit-jest.agent.yaml`
- `arch-cloud-aws.agent.yaml`
- `docs-api-openapi.agent.yaml`

## Automatic Delegation Triggers

Claude Code automatically delegates to agents based on:

1. **Keywords in user request**: "test", "deploy", "document", "review"
2. **File patterns**: `*.test.js` → testing agent, `*.tf` → infrastructure agent
3. **Task complexity**: Multi-step tasks spawn coordinator agents
4. **Domain detection**: Database queries → data agent, API endpoints → backend agent

## Tool Restrictions

Each agent type has specific tool access:

- **Development agents**: Full file system access, code execution
- **Testing agents**: Test runners, coverage tools, limited write access
- **Architecture agents**: Read-only access, diagram generation
- **Documentation agents**: Markdown tools, read access, limited write to docs/
- **DevOps agents**: Infrastructure tools, deployment scripts, environment access
- **Analysis agents**: Read-only access, static analysis tools
```

## Project Standards

- Always maintain consistency with project documentation in .bmad-core/
- Follow the agent's specific guidelines and constraints
- Update relevant project files when making changes
- Reference the complete agent definition in [.claude/agents/README.md](.claude/agents/README.md)

## Usage

Type `@README` to activate this README persona.
