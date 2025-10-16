---
allowed-tools: Bash, Read
description: Load context for a new agent session by analyzing codebase structure
---

# Purpose

To perform a more comprehensive and deep-diving evaluation

## Initialization Phase

1. **Documentation Ingestion**: Read all provided documentation files from the specified locations
2. **Requirements Analysis**: Process the user's requirements and focus areas
3. **Scope Definition**: Determine analysis boundaries (entire app or specific modules)

### Analysis Phase

1. **Code Analysis**: Use grep/glob to search for authentication-related patterns
2. **Architecture Review**: Examine state management, service integration, and data flow
3. **Security Assessment**: Review permission systems, data access patterns, vulnerability risks
4. **Logic Validation**: Trace authentication flows, identify edge cases and error paths
5. **Cross-Reference Checks**: Validate consistency across all authentication-related components

### Findings Phase

1. **Categorization**: Group findings by lifecycle stage (creation/login/session/logout)
2. **Severity Assessment**: Rate issues as Critical/High/Medium/Low
3. **Reproduction Steps**: Provide testable reproduction scenarios where applicable
4. **Impact Analysis**: Document effect on user experience and system stability

### Reporting Phase

1. **Comprehensive Report**: Structured findings with evidence, impact, and recommendations
2. **Migration Strategies**: When modifying existing functionality, provide safe migration paths
3. **Executive Summary**: High-level overview of critical findings and recommended actions
4. **Implementation Priority**: Categorize fixes by urgency and difficulty
5. **Output Format**: Provide both markdown and HTML formatted reports
