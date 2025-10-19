---
name: fix-auth
description: Run full auth fix workflow for errors like 'permission denied'.
allowed-tools: Read, Edit, Write, Grep, Glob, Bash, Sequential, Context7, Magic, Playwright
argument-hint: [error details]
---

Full auth fix workflow for $ARGUMENTS.
Use phased-auth output style.

1. Invoke auth-analyzer to analyze/troubleshoot.
2. It will chain to auth-fixer for improve/implement.
3. Then to auth-tester for test/deploy.
Use sub-agents proactively; delegate tasks sequentially.
Reference auth-tools skill as needed.
Apply full flags: --wave-mode force --wave-strategy systematic --wave-delegation tasks --persona-security --persona-backend --persona-analyzer --ultrathink --seq --c7 --all-mcp --loop --iterations 5 --delegate auto --security --validate --strict --safe-mode --scope system --focus security --plan --evidence --introspect --uc.
