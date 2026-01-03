# GitHub Code Review Skill

AI-powered code review that deploys specialized agents to perform comprehensive, intelligent analysis of pull requests.

## Core Features
- **Multi-Agent Review**: Parallel analysis by specialized agents (security, performance, architecture, style).
- **Security Agent**: Identifies vulnerabilities (OWASP, CVE, secrets) and suggests fixes.
- **Performance Agent**: Analyzes Big O complexity, memory patterns, and network optimizations.
- **Architecture Agent**: Evaluates SOLID principles, coupling, cohesion, and design patterns.
- **Style Agent**: Enforces coding standards, naming conventions, and documentation.

## How to Review a PR
1. **Initialize Review**:
   ```bash
   gh pr view <pr_number> --json files,diff | npx ruv-swarm github review-init --pr <pr_number>
   ```
2. **Specialized Security Review**:
   ```bash
   npx ruv-swarm github review-security --pr <pr_number> --check "owasp,secrets" --suggest-fixes
   ```
3. **Performance Analysis**:
   ```bash
   npx ruv-swarm github review-performance --pr <pr_number> --profile "cpu,memory" --suggest-optimizations
   ```

## PR Comment Commands
Execute commands directly from PR comments:
- `/swarm review --agents security,performance`
- `/swarm status`

## Automated Workflows
Integrate with GitHub Actions to trigger reviews automatically on PR creation or update. Use the GitHub CLI (`gh`) to fetch PR data, diffs, and post comments or reviews.

## Best Practices
- **Actionable Feedback**: Provide specific, constructive suggestions with code examples.
- **Quality Gates**: Define thresholds for blocking PRs (e.g., block on critical security issues).
- **Incremental Reviews**: Use for large PRs to keep the review process manageable.
