---
name: jj-build-all
description: Complete Journeyman Jobs architecture - builds all remaining domains
---

# JJ Complete Build Command

Builds all remaining 57 files across 4 domains plus workflows.

## What This Creates

### Domains to Build:
- **Frontend**: 16 files (5 agents + 10 skills)
- **State Management**: 13 files (4 agents + 8 skills)
- **Backend/Firebase**: 16 files (5 agents + 10 skills)
- **Debug/Error**: 13 files (4 agents + 8 skills)
- **Workflows**: 4 workflow files

## Execution

This command triggers the PowerShell build script:
```
.\BUILD-ALL-REMAINING.ps1
```

## Multi-Agent Workflow

1. **Coordinator Agent**: Orchestrates the build process
2. **Frontend Builder**: Creates all Flutter/UI components
3. **State Builder**: Creates Riverpod state management
4. **Backend Builder**: Creates Firebase integration
5. **Debug Builder**: Creates error handling systems
6. **Workflow Builder**: Creates operational workflows

## Usage
```
/jj-build-all
```

## Time Estimate
- Manual: ~12 hours
- With CC Multi-Agent: ~5 minutes

## Verification
After completion, check:
- 21 total agents created
- 42 total skills created
- 4 workflows created
- Total: 76 files in .claude/ structure