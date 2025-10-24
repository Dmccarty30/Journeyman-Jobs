# SuperClaude Framework - Complete User Guide

## Table of Contents

1. [Introduction](#introduction)
2. [Getting Started](#getting-started)
3. [Core Concepts](#core-concepts)
4. [Command System](#command-system)
5. [Persona System](#persona-system)
6. [MCP Server Integration](#mcp-server-integration)
7. [Flag System](#flag-system)
8. [Operational Modes](#operational-modes)
9. [Best Practices](#best-practices)
10. [Advanced Workflows](#advanced-workflows)
11. [Troubleshooting](#troubleshooting)

---

## Introduction

SuperClaude is a sophisticated AI assistant framework for Claude Code that provides specialized expertise, intelligent routing, and advanced orchestration capabilities for professional software development.

### Key Features

- **19 Professional Commands** with intelligent workflows
- **11 Specialized Personas** for domain expertise
- **4 MCP Servers** for enhanced capabilities
- **Universal Flag System** with auto-activation
- **Wave Orchestration** for complex multi-stage operations
- **Evidence-Based Methodology** with measurable outcomes

### Philosophy

SuperClaude operates on three core principles:

1. **Evidence > Assumptions** - All claims verified through testing, metrics, or documentation
2. **Code > Documentation** - Prioritize working implementations
3. **Efficiency > Verbosity** - Concise, actionable outputs

---

## Getting Started

### Quick Start

The simplest way to use SuperClaude is through slash commands:

```bash
# Example: Analyze your codebase
/analyze --code --architecture

# Example: Build a new React component
/build --react --magic --tdd

# Example: Security audit
/scan --security --owasp --deps
```

### Basic Workflow

1. **Choose a command** based on your task
2. **Add relevant flags** to customize behavior
3. **Let SuperClaude auto-activate** the right persona and MCP servers
4. **Review the execution plan** (use `--plan` flag)
5. **Execute and validate** the results

---

## Core Concepts

### Task-First Approach

SuperClaude follows a structured approach:

1. **Understand** - Analyze requirements and context
2. **Plan** - Create execution strategy
3. **Execute** - Implement with quality gates
4. **Validate** - Verify outcomes with evidence

### Task Management

SuperClaude uses a multi-tier task management system:

- **TodoWrite/TodoRead** - Session-level task tracking
- `/task` Command - Multi-session project management
- `/spawn` Command - Parallel task orchestration
- `/loop` Command - Iterative refinement workflows

### Quality Gates

Every operation passes through an 8-step validation cycle:

1. **Syntax** - Language parsers + Context7 validation
2. **Type Safety** - Sequential analysis + type compatibility
3. **Linting** - Code quality analysis
4. **Security** - Vulnerability assessment + OWASP compliance
5. **Testing** - Coverage analysis (≥80% unit, ≥70% integration)
6. **Performance** - Benchmarking + optimization
7. **Documentation** - Completeness validation
8. **Integration** - Deployment validation

---

## Command System

### Command Categories

#### Development Commands (3)

- **`/build`** - Universal project builder
  - `--init` - Initialize new project
  - `--feature` - Implement features
  - `--react` - React with Vite + TypeScript
  - `--api` - Express.js API
  - `--fullstack` - Complete React + Node.js

- **`/dev-setup`** - Development environment configuration
  - `--install` - Install dependencies
  - `--ci` - CI/CD pipelines
  - `--monitor` - Observability setup

- **`/test`** - Comprehensive testing framework
  - `--e2e` - End-to-end testing
  - `--coverage` - Coverage analysis
  - `--performance` - Performance testing

#### Analysis & Improvement Commands (5)

- **`/review`** - AI-powered code review
  - `--files` - Review specific files
  - `--commit` - Review commits
  - `--quality` - Quality focus
  - `--evidence` - Include sources

- **`/analyze`** - Multi-dimensional analysis
  - `--code` - Code quality
  - `--architecture` - System design
  - `--profile` - Performance profiling

- **`/troubleshoot`** - Professional debugging
  - `--investigate` - Systematic analysis
  - `--five-whys` - Root cause analysis
  - `--prod` - Production debugging

- **`/improve`** - Enhancement & optimization
  - `--quality` - Code structure
  - `--performance` - Performance boost
  - `--iterate` - Iterative improvement

- **`/explain`** - Technical documentation
  - `--depth` - Complexity level
  - `--visual` - Include diagrams
  - `--examples` - Code examples

#### Operations Commands (6)

- **`/deploy`** - Application deployment
- **`/migrate`** - Database & code migration
- **`/scan`** - Security & validation
- **`/estimate`** - Project estimation
- **`/cleanup`** - Project maintenance
- **`/git`** - Git workflow management

#### Design & Architecture (1)

- **`/design`** - System architecture design

#### Workflow Commands (4)

- **`/spawn`** - Specialized agent orchestration
- **`/document`** - Professional documentation
- **`/load`** - Project context loading
- **`/task`** - Complex feature management

### Command Examples

```bash
# Full-stack feature development
/design --api --ddd --persona-architect
/build --fullstack --tdd --magic
/test --coverage --e2e --pup
/deploy --env staging --validate

# Security-first development
/scan --security --owasp --deps
/analyze --security --forensic --seq
/improve --security --validate --strict

# Performance optimization
/analyze --profile --deep --persona-performance
/troubleshoot --perf --investigate --pup
/improve --performance --iterate --threshold 90%
```

---

## Persona System

SuperClaude includes 11 specialized personas that provide domain expertise:

### Technical Specialists

#### `--persona-architect`
- **Expertise**: Systems design, scalability, long-term architecture
- **Best For**: Architectural decisions, system design
- **Priority**: Maintainability > scalability > performance
- **MCP**: Sequential (primary), Context7 (secondary)

#### `--persona-frontend`
- **Expertise**: UI/UX, accessibility, performance-conscious development
- **Best For**: User interfaces, component design
- **Priority**: User needs > accessibility > performance
- **MCP**: Magic (primary), Playwright (secondary)

#### `--persona-backend`
- **Expertise**: APIs, databases, reliability engineering
- **Best For**: Server architecture, data modeling
- **Priority**: Reliability > security > performance
- **MCP**: Context7 (primary), Sequential (secondary)

#### `--persona-security`
- **Expertise**: Threat modeling, vulnerability assessment
- **Best For**: Security audits, compliance
- **Priority**: Security > compliance > reliability
- **MCP**: Sequential (primary), Context7 (secondary)

#### `--persona-performance`
- **Expertise**: Optimization, profiling, bottleneck elimination
- **Best For**: Performance tuning, optimization
- **Priority**: Measure first > optimize critical path > UX
- **MCP**: Playwright (primary), Sequential (secondary)

### Process & Quality Experts

#### `--persona-analyzer`
- **Expertise**: Root cause analysis, evidence-based investigation
- **Best For**: Complex debugging, investigations
- **Priority**: Evidence > systematic approach > thoroughness
- **MCP**: Sequential (primary), Context7 (secondary)

#### `--persona-qa`
- **Expertise**: Testing, quality assurance, edge cases
- **Best For**: Quality validation, test coverage
- **Priority**: Prevention > detection > correction
- **MCP**: Playwright (primary), Sequential (secondary)

#### `--persona-refactorer`
- **Expertise**: Code quality, technical debt management
- **Best For**: Code cleanup, refactoring
- **Priority**: Simplicity > maintainability > readability
- **MCP**: Sequential (primary), Context7 (secondary)

#### `--persona-devops`
- **Expertise**: Infrastructure, deployment, reliability
- **Best For**: Deployments, infrastructure
- **Priority**: Automation > observability > reliability
- **MCP**: Sequential (primary), Context7 (secondary)

### Knowledge & Communication

#### `--persona-mentor`
- **Expertise**: Educational guidance, knowledge transfer
- **Best For**: Documentation, learning
- **Priority**: Understanding > knowledge transfer > teaching
- **MCP**: Context7 (primary), Sequential (secondary)

#### `--persona-scribe=lang`
- **Expertise**: Professional writing, documentation, localization
- **Best For**: Technical writing, documentation
- **Priority**: Clarity > audience needs > cultural sensitivity
- **MCP**: Context7 (primary), Sequential (secondary)
- **Languages**: en, es, fr, de, ja, zh, pt, it, ru, ko

### Auto-Activation

Personas automatically activate based on:

- **Keywords** (30%) - Domain-specific terms
- **Context** (40%) - Project phase, complexity
- **History** (20%) - Past preferences
- **Metrics** (10%) - System state, bottlenecks

---

## MCP Server Integration

SuperClaude integrates with 4 MCP (Model Context Protocol) servers for enhanced capabilities:

### Context7 - Documentation & Research

**Purpose**: Official library documentation, code examples, best practices

**When to Use**:
- External library integration
- Framework pattern research
- API documentation lookup
- Version compatibility checking

**Auto-Activates**:
- External library imports detected
- Framework-specific questions
- Scribe persona active

**Example Commands**:
```bash
/analyze --c7
/build --react --c7
/explain --c7
```

### Sequential - Complex Analysis

**Purpose**: Multi-step problem solving, architectural analysis

**When to Use**:
- Complex system design
- Root cause analysis
- Performance investigation
- Architecture review

**Auto-Activates**:
- Complex debugging scenarios
- System design questions
- Any `--think` flags

**Example Commands**:
```bash
/analyze --seq
/troubleshoot --seq
/design --seq --ultrathink
```

### Magic - UI Components

**Purpose**: UI component generation, design system integration

**When to Use**:
- React/Vue component building
- Design system implementation
- UI pattern consistency
- Rapid prototyping

**Auto-Activates**:
- UI component requests
- Design system queries
- Frontend persona active

**Example Commands**:
```bash
/build --react --magic
/design --magic
/improve --accessibility --magic
```

### Playwright - Browser Automation

**Purpose**: E2E testing, performance validation, browser automation

**When to Use**:
- End-to-end testing
- Performance monitoring
- Visual validation
- User interaction testing

**Auto-Activates**:
- Testing workflows
- Performance monitoring requests
- QA persona active

**Example Commands**:
```bash
/test --e2e --pup
/analyze --performance --pup
/scan --validate --pup
```

### MCP Control Flags

```bash
--c7 / --context7      # Enable Context7
--seq / --sequential   # Enable Sequential
--magic                # Enable Magic
--play / --playwright  # Enable Playwright
--all-mcp              # Enable all servers
--no-mcp               # Disable all servers
--no-[server]          # Disable specific server
```

---

## Flag System

### Universal Flags (Available on ALL Commands)

#### Thinking Depth Control

- **`--think`** - Multi-file analysis (~4K tokens)
- **`--think-hard`** - Architecture-level analysis (~10K tokens)
- **`--ultrathink`** - Critical system analysis (~32K tokens)

#### Token Optimization

- **`--uc` / `--ultracompressed`** - 30-50% token reduction

#### Planning & Execution

- **`--plan`** - Show execution plan before running
- **`--dry-run`** - Preview changes without execution
- **`--watch`** - Continuous monitoring
- **`--interactive`** - Step-by-step guided process
- **`--force`** - Override safety checks

#### Quality & Validation

- **`--validate`** - Pre-execution safety checks
- **`--security`** - Security-focused analysis
- **`--coverage`** - Coverage analysis
- **`--strict`** - Zero-tolerance mode

#### Analysis & Introspection

- **`--introspect`** - Self-aware analysis with cognitive transparency

### Sub-Agent Delegation Flags

- **`--delegate [files|folders|auto]`** - Enable parallel processing via sub-agents
  - Auto-activates: >7 directories or >50 files
  - Performance gain: 40-70% time savings

- **`--concurrency [n]`** - Control max concurrent sub-agents (default: 7, range: 1-15)

### Wave Orchestration Flags

- **`--wave-mode [auto|force|off]`** - Control wave orchestration
  - `auto`: Auto-activates (complexity >0.8 + files >20 + operation_types >2)
  - `force`: Override auto-detection
  - `off`: Disable wave mode

- **`--wave-strategy [progressive|systematic|adaptive|enterprise]`**
  - `progressive`: Iterative enhancement
  - `systematic`: Methodical analysis
  - `adaptive`: Dynamic configuration
  - `enterprise`: Large-scale orchestration (>100 files)

### Iterative Improvement Flags

- **`--loop`** - Enable iterative improvement mode
  - Auto-activates: polish, refine, enhance keywords
  - Default: 3 iterations with validation

- **`--iterations [n]`** - Control iteration count (range: 1-10)
- **`--interactive`** - User confirmation between iterations

### Scope & Focus Flags

- **`--scope [file|module|project|system]`** - Analysis scope
- **`--focus [performance|security|quality|architecture|accessibility|testing]`** - Domain focus

### Flag Precedence Rules

1. Safety flags (`--safe-mode`) > optimization flags
2. Explicit flags > auto-activation
3. Thinking depth: `--ultrathink` > `--think-hard` > `--think`
4. `--no-mcp` overrides all individual MCP flags
5. Scope: system > project > module > file
6. Wave mode: `--wave-mode off` > `--wave-mode force` > `--wave-mode auto`
7. Sub-Agent delegation: explicit `--delegate` > auto-detection
8. Loop mode: explicit `--loop` > auto-detection
9. `--uc` auto-activation overrides verbose flags

---

## Operational Modes

### Task Management Mode

SuperClaude provides multi-tier task management:

#### Layer 1: TodoWrite/TodoRead
- **Scope**: Current session
- **States**: pending, in_progress, completed, blocked
- **Capacity**: 3-20 tasks per session

#### Layer 2: /task Command
- **Scope**: Multi-session features (days to weeks)
- **Operations**:
  - `/task:create [description]` - Create with auto-breakdown
  - `/task:status [id]` - Check progress
  - `/task:resume [id]` - Resume after break
  - `/task:update [id]` - Update progress
  - `/task:complete [id]` - Mark as done

#### Layer 3: /spawn Command
- **Scope**: Complex multi-domain operations
- **Features**: Parallel/sequential coordination

#### Layer 4: /loop Command
- **Scope**: Progressive refinement workflows
- **Features**: Iteration cycles with validation

### Introspection Mode

Meta-cognitive analysis for self-awareness and optimization.

**Activation**: `--introspect` flag or automatic for complex debugging

**Capabilities**:
- Reasoning analysis
- Action sequence review
- Meta-cognitive self-assessment
- Framework compliance checks
- Retrospective analysis

**Analysis Markers**:
- 🧠 Reasoning Analysis
- 🔄 Action Sequence Review
- 🎯 Self-Assessment
- 📊 Pattern Recognition
- 🔍 Framework Compliance
- 💡 Retrospective Insight

### Token Efficiency Mode

Intelligent token optimization achieving 30-50% reduction.

**Activation**:
- Manual: `--uc` flag
- Automatic: Context usage >75% or large-scale operations

**Symbol System**:
- `→` leads to, implies
- `⇒` transforms to
- `&` and, combine
- `|` separator, or
- `»` sequence, then
- `✅` completed
- `⚡` performance
- `🔍` analysis
- `🛡️` security

**Compression Levels**:
1. **Minimal** (0-40%) - Full detail
2. **Efficient** (40-70%) - Balanced compression
3. **Compressed** (70-85%) - Aggressive optimization
4. **Critical** (85-95%) - Maximum compression
5. **Emergency** (95%+) - Ultra-compression

---

## Best Practices

### Evidence-Based Development

**Required Language**: may, could, potentially, typically, measured, documented

**Prohibited Language**: best, optimal, faster, secure, better, always, never

**Evidence Requirements**:
- Testing confirms
- Metrics show
- Benchmarks prove
- Data indicates
- Documentation states

### Command Selection

1. **Let SuperClaude suggest automatically** based on context
2. **Use personas for specialized expertise**
3. **Combine MCP servers for maximum capability**
4. **Progressive thinking for complex tasks**

### Validation Best Practices

**High-Risk Operations**: Always use `--validate` or `--dry-run`

```bash
/deploy --env prod --validate --plan
/migrate --database --dry-run --backup
```

**Documentation Tasks**: Enable `--c7` for library lookups

```bash
/document --api --examples --c7
```

**Complex Analysis**: Use `--seq` for reasoning

```bash
/troubleshoot --investigate --seq
```

**UI Development**: Enable `--magic` for AI components

```bash
/build --react --magic
```

**Testing**: Use `--pup` for browser automation

```bash
/test --e2e --pup --coverage
```

### Performance Guidelines

- **Simple tasks** → Sonnet
- **Complex tasks** → Sonnet-4
- **Critical tasks** → Opus-4
- **Native tools > MCP** for simple tasks
- **Parallel execution** for independent operations

---

## Advanced Workflows

### Full-Stack Development

```bash
# 1. Design architecture
/design --api --ddd --persona-architect

# 2. Build application
/build --fullstack --tdd --magic

# 3. Comprehensive testing
/test --coverage --e2e --pup

# 4. Deploy to staging
/deploy --env staging --validate
```

### Security-First Development

```bash
# 1. Security scan
/scan --security --owasp --deps --persona-security

# 2. Deep security analysis
/analyze --security --forensic --seq

# 3. Security hardening
/improve --security --validate --strict

# 4. Security testing
/test --security --coverage
```

### Performance Optimization

```bash
# 1. Profile performance
/analyze --profile --deep --persona-performance

# 2. Investigate bottlenecks
/troubleshoot --perf --investigate --pup

# 3. Optimize iteratively
/improve --performance --iterate --threshold 90%

# 4. Validate improvements
/test --performance --load
```

### Quality Assurance

```bash
# 1. Comprehensive review
/review --quality --evidence --persona-qa

# 2. Code quality improvement
/improve --quality --refactor --strict

# 3. Quality validation
/scan --validate --quality

# 4. Comprehensive testing
/test --coverage --mutation
```

### Wave-Based Comprehensive Improvement

```bash
# Enterprise-scale system improvement
/improve --wave-mode auto --wave-strategy enterprise --comprehensive

# Progressive performance optimization
/analyze --wave-mode force --wave-strategy progressive --performance

# Systematic security audit
/scan --wave-mode auto --wave-strategy systematic --security --owasp
```

---

## Troubleshooting

### Common Issues

#### Performance Issues

**Symptoms**: Slow execution, high resource usage

**Solution**:
```bash
# Enable token compression
/analyze --uc

# Use delegation for large codebases
/analyze --delegate auto

# Disable unnecessary MCP servers
/analyze --no-magic --no-pup
```

#### Quality Issues

**Symptoms**: Incomplete validation, missing evidence

**Solution**:
```bash
# Enable strict validation
/improve --quality --validate --strict

# Request evidence
/review --quality --evidence

# Use quality-focused persona
/analyze --persona-qa --coverage
```

#### Context Overload

**Symptoms**: Token limits, incomplete analysis

**Solution**:
```bash
# Enable ultra-compressed mode
/analyze --uc

# Use focused scope
/analyze --scope module --focus performance

# Delegate to sub-agents
/analyze --delegate folders
```

### Getting Help

1. **Check execution plan**: Use `--plan` flag
2. **Enable introspection**: Use `--introspect` flag
3. **Review documentation**: `/explain --depth expert`
4. **Use mentor persona**: `--persona-mentor`

### Resource Management Zones

- **Green** (0-60%): Full operations
- **Yellow** (60-75%): Optimization suggested
- **Orange** (75-85%): Warning alerts
- **Red** (85-95%): Forced efficiency modes
- **Critical** (95%+): Emergency protocols

---

## Conclusion

SuperClaude provides a comprehensive, evidence-based framework for professional software development with:

- **Intelligent Automation**: Auto-activation of personas and MCP servers
- **Quality Assurance**: 8-step validation cycle
- **Flexibility**: 19 commands with universal flags
- **Scalability**: Wave orchestration for complex operations
- **Efficiency**: Token optimization and parallel processing

### Quick Reference

**Most Used Commands**:
```bash
/analyze --code --architecture
/build --feature --tdd
/test --coverage --e2e
/improve --quality --iterate
/deploy --env prod --validate
```

**Most Useful Flags**:
```bash
--plan              # Preview execution
--validate          # Safety checks
--uc                # Token optimization
--persona-[name]    # Specialized expertise
--seq               # Complex analysis
```

**Emergency Operations**:
```bash
/troubleshoot --prod --five-whys --seq
/deploy --rollback --env prod
/scan --security --owasp --strict
```

---

**SuperClaude Framework v2.0.1**
Professional AI-Assisted Development | Evidence-Based Methodology | Intelligent Orchestration

For technical specifications, see `SuperClaude_Technical_Docs.yaml`
For integrated summary, see `SuperClaude_Integrated_Summary.html`
