# Journeyman Workflow Orchestrator - Usage Guide

## Quick Start

The Journeyman Workflow Orchestrator skill combines your most frequently used command patterns into a single, powerful workflow tool.

## Most Common Use Cases

### 1. Complete Codebase Error Elimination

**Based on your most frequent scratchpad commands:**

```bash
# Original pattern you used:
# workflow-init --uc --ultrathink --all-mcp --persona-architect --analyze --verbose "i need for you to invoke the error-eliminator so he can summon his team of specialists to fix my codebase"

# New unified command:
/journeyman-workflow-orchestrator --mode error-elimination --scope @lib --deep-scan --parallel --uc
```

### 2. Deep Feature Analysis

**Based on your crews feature analysis pattern:**

```bash
# Original pattern you used:
# /ultra-think --uc --ultrathink --parsona-architect --deep-dive --seq "i need for you to perform a deep analysis to identify missing components..."

# New unified command:
/journeyman-workflow-orchestrator --mode analysis --feature "crews" --identify-missing --implementation-guide --persona-architect --uc
```

### 3. Multi-Agent Task Execution

**Based on your swarm orchestration patterns:**

```bash
# Original pattern you used:
# npx claude-flow@alpha hive-mind "Invoke @error-eliminator.md and have that agent unleash it's team..." --auto-spawn --queen-type tactical --max-workers 10

# New unified command:
/journeyman-workflow-orchestrator --mode swarm-orchestration --tasks @hierarchical-initialization-tasks.md --queen-type tactical --max-workers 10 --auto-spawn
```

### 4. Analysis to Task Pipeline

**Based on your task generation patterns:**

```bash
# Original pattern you used:
# /agent-task-prep --uc --ultrathink ---all-mcp --persona-architect --iterations 5 --plan --feature

# New unified command:
/journeyman-workflow-orchestrator --mode pipeline --input @ANALYSIS_REPORT.md --output hierarchical-initialization-tasks.md --agent-expert --persona-architect
```

## Command Reference

### Error Elimination Mode

```bash
/journeyman-workflow-orchestrator --mode error-elimination [OPTIONS]
```

- `--scope @lib`: Target the entire lib directory
- `--deep-scan`: Comprehensive codebase analysis
- `--parallel`: Run specialists in parallel
- `--uc`: Enable Ultra-Think analysis
- `--queen-type tactical|strategic|specialist`: Coordination type
- `--max-workers 1-20`: Number of parallel agents

### Analysis Mode

```bash
/journeyman-workflow-orchestrator --mode analysis [OPTIONS]
```

- `--feature "name"`: Specific feature to analyze
- `--identify-missing`: Find gaps and missing components
- `--implementation-guide`: Generate detailed implementation guide
- `--persona architect|frontend|backend`: Specialist perspective

### Swarm Orchestration Mode

```bash
/journeyman-workflow-orchestrator --mode swarm-orchestration [OPTIONS]
```

- `--tasks @file.md`: Task file to execute
- `--auto-spawn`: Automatically spawn specialized agents
- `--queen-type strategic|tactical|specialist`: Leadership style
- `--max-workers N`: Maximum parallel agents

### Pipeline Mode

```bash
/journeyman-workflow-orchestrator --mode pipeline [OPTIONS]
```

- `--input @analysis.md`: Input analysis document
- `--output tasks.md`: Output task file
- `--agent-expert`: Use task generation specialist
- `--validation`: Enable output validation

## Your Personalized Templates

### Template 1: Emergency Code Correction (Your Most Used Pattern)

```bash
# Complete codebase correction with 10 specialists
/journeyman-workflow-orchestrator \
  --mode error-elimination \
  --scope @lib \
  --deep-scan \
  --parallel \
  --uc \
  --queen-type tactical \
  --max-workers 10 \
  --validation
```

### Template 2: Feature Deep Dive (Your Second Most Used Pattern)

```bash
# Complete feature analysis and implementation guide
/journeyman-workflow-orchestrator \
  --mode analysis \
  --feature "crews" \
  --identify-missing \
  --implementation-guide \
  --persona-architect \
  --uc
```

### Template 3: Multi-Agent Task Execution (Your Swarm Pattern)

```bash
# Execute complex task list with specialized agents
/journeyman-workflow-orchestrator \
  --mode swarm-orchestration \
  --tasks @hierarchical-initialization-tasks.md \
  --queen-type strategic \
  --max-workers 8 \
  --auto-spawn \
  --parallel
```

### Template 4: Analysis to Tasks (Your Planning Pattern)

```bash
# Convert analysis into actionable tasks
/journeyman-workflow-orchestrator \
  --mode pipeline \
  --input @ANALYSIS_REPORT.md \
  --output hierarchical-initialization-tasks.md \
  --agent-expert \
  --persona-architect \
  --validation
```

## Quick Reference Card

### For Error Correction

```bash
/journeyman-workflow-orchestrator --mode error-elimination --scope @lib --deep-scan --parallel
```

### For Feature Analysis

```bash
/journeyman-workflow-orchestrator --mode analysis --feature "name" --identify-missing --implementation-guide
```

### For Task Execution

```bash
/journeyman-workflow-orchestrator --mode swarm-orchestration --tasks @file.md --auto-spawn --max-workers 8
```

### For Analysis to Tasks

```bash
/journeyman-workflow-orchestrator --mode pipeline --input @analysis.md --output tasks.md --agent-expert
```

## Tips

1. **Always use `--uc`** for complex analysis (your preferred pattern)
2. **Start with `--scope @lib`** for comprehensive codebase work
3. **Use `--queen-type tactical`** for error correction (your preference)
4. **Use `--queen-type strategic`** for feature implementation
5. **Always include `--validation`** for production work
6. **Use `--parallel`** for faster execution on complex tasks

This skill consolidates your most frequent command patterns from the scratchpad into a unified, powerful workflow tool.
