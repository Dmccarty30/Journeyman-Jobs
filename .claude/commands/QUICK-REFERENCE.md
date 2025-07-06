# Claude Code Commands - Quick Reference

## 🔍 Deep Dive Codebase Evaluation

```
/deep-dive-codebase [project-path]
```

**Purpose**: Test everything, find all broken features  
**Output**: `deep-dive-reports/[project]-[timestamp].md`

## 🔧 Repair Broken Features  

```
/repair-broken-features [report-path]
```

**Purpose**: Fix all issues found in deep dive  
**Output**: `repair-reports/[project]-fixes-[timestamp].md`

## 📋 Quick Setup

```bash
# For current project
mkdir -p .claude/commands
cp claude-commands/*.md .claude/commands/

# For all projects
cp claude-commands/*.md ~/.claude/commands/
```

## 🎯 Typical Workflow

1. `/deep-dive-codebase ~/my-app` → Find all issues
2. Review report → Understand problems  
3. `/repair-broken-features [report]` → Fix everything
4. Review fixes → Verify solutions

## 💡 Remember

- Both commands include **ULTRATHINK** planning phase
- Deep dive tests EVERYTHING systematically
- Repair follows your code patterns
- All changes are documented
- Version control recommended
