---
name: Journeyman Workflow Orchestrator
description: Comprehensive workflow orchestration skill for Journeyman Jobs development, combining error elimination, deep analysis, multi-agent coordination, and task generation
author: Journeyman Jobs Development Team
version: 1.0.0
category: workflow-orchestration
tags: [orchestration, error-correction, analysis, multi-agent, task-generation]
dependencies: []
mcp_servers: [claude-flow, flow-nexus, ruv-swarm]
---

# Journeyman Workflow Orchestrator

A comprehensive workflow orchestration skill that combines the most commonly used command patterns from your development workflow. This skill unifies error elimination, deep analysis, multi-agent coordination, and task generation into a single, powerful orchestration tool.

## Core Features

### 🔥 Error Elimination & Code Correction

- Summon the elite error-eliminator team
- Comprehensive codebase analysis and correction
- Multi-specialist agent coordination
- Automated fix validation

### 🧠 Deep Analysis & Ultra-Think

- Deep architectural analysis
- Missing component identification
- Dependency mapping
- Logic flow analysis

### 🐝 Multi-Agent Swarm Orchestration

- Auto-spawn specialized agents
- Hierarchical coordination (Queen/Worker pattern)
- Parallel task execution
- Strategic tactical oversight

### 📋 Task Generation & Management

- Comprehensive task creation from analysis
- Hierarchical task breakdown
- Agent assignment and validation
- Progress tracking and completion validation

## Usage Patterns

### Pattern 1: Complete Codebase Correction

```bash
/journeyman-workflow-orchestrator --mode error-elimination --scope @lib --deep-scan --parallel
```

### Pattern 2: Deep Feature Analysis

```bash
/journeyman-workflow-orchestrator --mode analysis --feature "crews" --identify-missing --implementation-guide
```

### Pattern 3: Multi-Agent Task Execution

```bash
/journeyman-workflow-orchestrator --mode swarm-orchestration --tasks @hierarchical-initialization-tasks.md --queen-type strategic --max-workers 8
```

### Pattern 4: Analysis to Task Pipeline

```bash
/journeyman-workflow-orchestrator --mode pipeline --input @ANALYSIS_REPORT.md --output hierarchical-initialization-tasks.md
```

## Command Parameters

### Core Parameters

- `--mode`: Operation mode (error-elimination, analysis, swarm-orchestration, pipeline)
- `--scope`: Target scope (@lib, @docs, specific files, directories)
- `--deep-scan`: Enable comprehensive analysis
- `--parallel`: Enable parallel execution
- `--uc`: Ultra-Think mode enabled

### Analysis Parameters

- `--feature`: Specific feature to analyze (crews, authentication, etc.)
- `--identify-missing`: Identify missing components and dependencies
- `--implementation-guide`: Generate detailed implementation instructions
- `--persona`: Specialist persona to use (architect, frontend, backend)

### Swarm Parameters

- `--queen-type`: Coordination type (tactical, strategic, specialist)
- `--max-workers`: Maximum number of parallel agents (1-20)
- `--auto-spawn`: Automatically spawn specialized agents
- `--tasks`: Task file or list to execute

### Pipeline Parameters

- `--input`: Input analysis file
- `--output`: Output task file
- `--validation`: Enable output validation
- `--agent-expert`: Use task expert agent for generation

## Workflow Templates

### Template A: Complete Feature Implementation

1. **Analysis Phase**: Deep analysis of current state
2. **Gap Identification**: Missing components and dependencies
3. **Task Generation**: Comprehensive task breakdown
4. **Agent Assignment**: Specialized agent assignment
5. **Parallel Execution**: Multi-agent task completion
6. **Validation**: Karen validation of completed work

### Template B: Emergency Code Correction

1. **Error Detection**: Comprehensive error scan
2. **Specialist Deployment**: Deploy 10 specialist agents
3. **Parallel Correction**: Simultaneous error fixing
4. **Integration**: System-wide integration testing
5. **Validation**: End-to-end functionality verification

### Template C: Feature Analysis & Planning

1. **Feature Analysis**: Deep dive into specific feature
2. **Architecture Review**: System architecture analysis
3. **Dependency Mapping**: Identify all dependencies
4. **Implementation Guide**: Create detailed guide
5. **Task Breakdown**: Generate actionable tasks

## Integration Points

### Error Eliminator Team

- Root-cause analyst
- Relational expert
- Refactorer
- Composer
- Dead-code eliminator
- Dependency resolver
- Performance optimizer
- Security auditor
- Standards enforcer
- Testing specialist

### Multi-Agent Swarm Types

- Researcher agents
- Coder agents
- Analyst agents
- Optimizer agents
- Coordinator agents

### Task Generation Framework

- Atomic task creation
- Sequential task ordering
- Agent assignment optimization
- Progress tracking
- Completion validation

## Quality Assurance

### Validation Gates

1. **Analysis Validation**: Verify analysis completeness
2. **Task Validation**: Ensure task quality and clarity
3. **Implementation Validation**: Verify code corrections
4. **Integration Validation**: End-to-end testing
5. **Karen Review**: Final functionality verification

### Quality Metrics

- Error reduction rate
- Task completion accuracy
- Code quality improvement
- System integration success
- Feature functionality verification

## Example Usages

### Complete Codebase Overhaul

```bash
# Summon error eliminator team for comprehensive codebase correction
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

### Feature Implementation Pipeline

```bash
# Complete feature implementation from analysis to working code
/journeyman-workflow-orchestrator \
  --mode pipeline \
  --feature "crews" \
  --identify-missing \
  --implementation-guide \
  --task-generation \
  --swarm-execution \
  --karen-validation
```

### Emergency Bug Fix Session

```bash
# Rapid deployment of specialist team for critical bug fixing
/journeyman-workflow-orchestrator \
  --mode swarm-orchestration \
  --tasks @critical-bugs.md \
  --queen-type strategic \
  --max-workers 8 \
  --auto-spawn \
  --parallel \
  --validation
```

### Analysis to Task Conversion

```bash
# Convert comprehensive analysis into actionable tasks
/journeyman-workflow-orchestrator \
  --mode pipeline \
  --input @ANALYSIS_REPORT.md \
  --output hierarchical-initialization-tasks.md \
  --agent-expert \
  --validation \
  --persona-architect
```

## Best Practices

### Before Running

1. Ensure all analysis documents are up to date
2. Verify task files are properly formatted
3. Check agent availability and MCP connections
4. Validate input parameters and scopes

### During Execution

1. Monitor agent progress and coordination
2. Validate intermediate results
3. Handle agent failures gracefully
4. Maintain audit trail of all changes

### After Completion

1. Run comprehensive validation
2. Verify all tasks are completed
3. Test system functionality end-to-end
4. Document all changes and improvements

## Troubleshooting

### Common Issues

- **Agent Communication Failures**: Check MCP server connections
- **Task Generation Errors**: Validate input analysis format
- **Parallel Execution Conflicts**: Reduce max workers or add locks
- **Validation Failures**: Check dependencies and integration points

### Recovery Procedures

1. **Partial Failures**: Re-run with failed tasks only
2. **Complete Failures**: Reset and start with smaller scope
3. **Validation Failures**: Run targeted validation on specific components
4. **Integration Issues**: Rollback changes and retry with sequential execution

## Configuration

### Environment Variables

- `JOURNEYMAN_SWARM_SIZE`: Default maximum agents (default: 8)
- `JOURNEYMAN_VALIDATION_LEVEL`: Validation strictness (default: comprehensive)
- `JOURNEYMAN_PARALLEL_LIMIT`: Parallel execution limit (default: 10)
- `JOURNEYMAN_QUEEN_TYPE`: Default queen type (default: tactical)

### Agent Configuration

- Specialist agent capabilities
- Swarm topology preferences
- Communication protocols
- Validation thresholds

## Monitoring & Logging

### Metrics Collection

- Agent performance metrics
- Task completion rates
- Error correction success rates
- System integration results

### Logging Levels

- **DEBUG**: Detailed agent communication
- **INFO**: Task progress and milestones
- **WARN**: Non-critical issues and retries
- **ERROR**: Failures and intervention required

## Extension Points

### Custom Agent Types

- Domain-specific specialists
- Custom analysis patterns
- Specialized validation routines

### Workflow Templates

- Project-specific workflows
- Team-specific coordination patterns
- Custom validation gates

### Integration Hooks

- External CI/CD pipeline integration
- Custom reporting systems
- Third-party monitoring tools

---

This skill represents the culmination of your most common workflow patterns, providing a unified interface for complex development orchestration tasks. It combines error elimination, deep analysis, multi-agent coordination, and comprehensive task management into a single, powerful tool that can handle everything from emergency bug fixes to complete feature implementations.
