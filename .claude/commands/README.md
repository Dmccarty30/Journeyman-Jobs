# Custom Claude Code Slash Commands

## Overview

Two powerful commands for comprehensive codebase evaluation and repair.

## Installation

### Project-Specific (Recommended)

```bash
# Copy commands to your project
mkdir -p .claude/commands
cp claude-commands/*.md .claude/commands/
```

### Personal Commands

```bash
# Copy to your home directory for use across all projects
mkdir -p ~/.claude/commands
cp claude-commands/*.md ~/.claude/commands/
```

## Command 1: Deep Dive Codebase Evaluation

### Usage

```
/deep-dive-codebase /path/to/your/project
```

### What It Does

- Exhaustively tests every navigation element, button, function, and feature
- Identifies all broken components with detailed documentation
- Creates a comprehensive report with severity ratings
- Tests edge cases and error scenarios
- Provides a complete inventory of what works and what doesn't

### Output

Creates a detailed report in `deep-dive-reports/` with:

- Executive summary of findings
- Detailed failure documentation for each broken component
- Repair priority matrix (Critical/High/Medium/Low)
- Resource assessment for fixes

## Command 2: Repair Broken Features

### Usage

```
/repair-broken-features /path/to/deep-dive-report.md
```

### What It Does

- Reads the deep dive report
- Creates a strategic repair plan
- Systematically fixes each broken component
- Follows established code patterns
- Verifies each fix works correctly
- Documents all changes made

### Output

Creates a fix summary report in `repair-reports/` with:

- Executive summary of repairs
- Detailed fix log with code changes
- Test results for each fix
- Recommendations for future improvements

## Workflow Example

1. **Evaluate the codebase**

   ```
   /deep-dive-codebase ~/projects/my-app
   ```

   This will test everything and create a report of all issues.

2. **Review the report**
   Check `deep-dive-reports/my-app-[timestamp].md` to see all findings.

3. **Run repairs**

   ```
   /repair-broken-features deep-dive-reports/my-app-[timestamp].md
   ```

   This will systematically fix all identified issues.

4. **Review fixes**
   Check `repair-reports/my-app-fixes-[timestamp].md` for all changes made.

## Key Features

### ULTRATHINK Phase

Both commands include a comprehensive planning phase where the AI:

- Analyzes the entire scope of work
- Creates a detailed execution plan
- Identifies patterns and dependencies
- Optimizes the approach for efficiency

### Comprehensive Testing (Deep Dive)

- Navigation and routing verification
- Form submission with valid/invalid data
- API endpoint testing
- State management validation
- Animation and transition checks
- Responsive design verification
- Accessibility compliance
- Performance bottleneck identification

### Systematic Repairs

- Follows existing code patterns
- Implements proper error handling
- Adds null safety checks
- Prevents memory leaks
- Includes comprehensive testing
- Documents all changes

## Tips for Best Results

1. **Clean Working Directory**: Ensure your project builds successfully before running deep dive
2. **Version Control**: Create a new branch before running repairs
3. **Incremental Fixes**: The repair command commits fixes in logical batches
4. **Review Changes**: Always review the generated fixes before merging

## Customization

Feel free to modify these commands for your specific needs:

- Add framework-specific testing patterns
- Include custom severity ratings
- Modify the report format
- Add integration with your CI/CD pipeline

## Support

These commands are designed to work with any codebase but work best with:

- Web applications (React, Vue, Angular, etc.)
- Mobile apps (React Native, Flutter)
- Desktop applications (Electron)
- API services (Node.js, Python, Go)

The commands will adapt their testing and repair strategies based on the detected framework and language.
