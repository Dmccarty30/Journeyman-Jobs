# Multi-Agent Directory Analysis Workflow

A comprehensive workflow for analyzing, inspecting, and identifying problems in any directory using multiple specialized AI agents.

## Overview

This workflow orchestrates 6 specialized agents to perform comprehensive analysis of codebases, projects, or directories:

1. **Security Analyst** - Vulnerability detection and security assessment
2. **Performance Analyst** - Bottleneck identification and optimization opportunities
3. **Code Quality Analyst** - Maintainability, technical debt, and best practices
4. **Architecture Analyst** - Design patterns, system structure, and scalability
5. **Documentation Analyst** - Documentation completeness and quality
6. **Testing Analyst** - Test coverage and quality assessment

## Quick Start

### Unix/Linux/macOS

```bash
# Basic usage (analyze current directory)
./.claude/workflows/run-directory-analysis.sh

# Analyze specific directory
./.claude/workflows/run-directory-analysis.sh /path/to/project

# Custom analysis depth and output format
./.claude/workflows/run-directory-analysis.sh /path/to/project comprehensive json
```

### Windows

```cmd
# Basic usage (analyze current directory)
.claude\workflows\run-directory-analysis.bat

# Analyze specific directory
.claude\workflows\run-directory-analysis.bat C:\path\to\project

# Custom analysis depth and output format
.claude\workflows\run-directory-analysis.bat C:\path\to\project comprehensive html
```

## Configuration Options

### Analysis Depth

- **quick**: Fast surface-level analysis (~5-10 minutes)
- **standard**: Comprehensive analysis (~30-45 minutes) - **default**
- **comprehensive**: Deep dive analysis (~1-2 hours)

### Output Formats

- **markdown**: Human-readable reports - **default**
- **json**: Machine-readable structured data
- **html**: Interactive web reports

### Focus Areas

You can specify which areas to focus on:

- `security` - Security vulnerabilities and compliance
- `performance` - Performance bottlenecks and optimization
- `code_quality` - Code maintainability and technical debt
- `architecture` - System design and structure
- `documentation` - Documentation completeness and quality
- `testing` - Test coverage and quality

## Output Structure

The workflow generates a timestamped output directory with the following structure:

```dart
analysis-results-YYYYMMDD-HHMMSS/
├── consolidated-analysis-report.{md|json|html}  # Main consolidated report
├── actionable-recommendations.md                 # Prioritized recommendations
├── security-detailed-analysis.md                 # Security findings
├── performance-detailed-analysis.md              # Performance findings
├── code-quality-detailed-analysis.md             # Code quality findings
├── architecture-detailed-analysis.md             # Architecture findings
├── documentation-detailed-analysis.md            # Documentation findings
├── testing-detailed-analysis.md                  # Testing findings
└── analysis-summary.md                           # Quick overview
```

## Agent Specializations

### Security Analyst

**Focus**: Security vulnerabilities, authentication, authorization, data privacy
**Capabilities**:

- Static code security analysis
- Dependency vulnerability scanning
- OWASP compliance checking
- Authentication/authorization review
- Data privacy assessment

**Typical Findings**:

- SQL injection vulnerabilities
- XSS vulnerabilities
- Insecure data handling
- Missing authentication
- Weak encryption practices

### Performance Analyst

**Focus**: Performance bottlenecks, optimization opportunities
**Capabilities**:

- Code performance analysis
- Memory usage optimization
- Database query optimization
- Network performance review
- Resource utilization assessment

**Typical Findings**:

- Inefficient algorithms
- Memory leaks
- Slow database queries
- Network latency issues
- Resource contention

### Code Quality Analyst

**Focus**: Code maintainability, technical debt, best practices
**Capabilities**:

- Code style and formatting analysis
- Code complexity assessment
- Maintainability index calculation
- Technical debt identification
- Best practices compliance

**Typical Findings**:

- Code style inconsistencies
- High cyclomatic complexity
- Poor naming conventions
- Code duplication
- Missing error handling

### Architecture Analyst

**Focus**: System design, patterns, scalability
**Capabilities**:

- Design pattern recognition
- Architecture violation detection
- Module coupling analysis
- Scalability assessment
- System design review

**Typical Findings**:

- Tight coupling between modules
- Violation of SOLID principles
- Poor separation of concerns
- Scalability bottlenecks
- Missing architectural patterns

### Documentation Analyst

**Focus**: Documentation completeness and quality
**Capabilities**:

- API documentation review
- Code comment analysis
- README completeness check
- Inline documentation assessment
- User guide evaluation

**Typical Findings**:

- Missing API documentation
- Outdated README files
- Insufficient code comments
- Missing user guides
- Poor documentation structure

### Testing Analyst

**Focus**: Test coverage and quality
**Capabilities**:

- Test coverage analysis
- Test quality assessment
- Test strategy review
- Missing test identification
- Test automation evaluation

**Typical Findings**:

- Low test coverage
- Missing edge case tests
- Poor test quality
- Lack of automated tests
- Missing integration tests

## Report Sections

### Executive Summary

High-level overview of the analysis:

- Overall project health score
- Critical issues summary
- Key recommendations
- Estimated effort to address issues

### Detailed Findings

Comprehensive findings from each agent:

- Issue description and severity
- Location of issues (file paths, line numbers)
- Impact assessment
- Root cause analysis

### Actionable Recommendations

Prioritized, actionable recommendations:

- **Critical**: Security vulnerabilities, critical performance issues
- **High**: Major code quality issues, architectural violations
- **Medium**: Documentation gaps, test coverage improvements
- **Low**: Style improvements, minor optimizations

### Implementation Roadmap

Step-by-step implementation plan:

- Phase 1: Critical security and performance fixes
- Phase 2: Code quality and architecture improvements
- Phase 3: Documentation and testing enhancements
- Phase 4: Long-term ma intenance and monitoring

## Customization

### Modifying Agent Behavior

Edit the workflow configuration file:

```yaml
# .claude/workflows/multi-agent-directory-analysis.yml
agents:
  - name: "custom-analyst"
    type: "custom-specialist"
    description: "Your custom analysis"
    capabilities:
      - "custom-analysis-1"
      - "custom-analysis-2"
```

### Adding New Analysis Types

1. Define new agent in the YAML configuration
2. Add corresponding section in execution scripts
3. Create output template for the new analysis type

### Customizing Output Formats

Modify the output section in the YAML configuration:

```yaml
outputs:
  - name: "custom_report"
    type: file
    description: "Custom report format"
    format: "custom"
```

## Troubleshooting

### Common Issues

1. **Agents not spawning**
   - Ensure Claude Code is properly installed
   - Check network connectivity
   - Verify API credentials

2. **Incomplete analysis**
   - Check target directory permissions
   - Verify sufficient disk space
   - Monitor system resources

3. **Output formatting issues**
   - Check output format parameter
   - Verify write permissions in output directory
   - Check available disk space

### Performance Optimization

1. **For large codebases (>10,000 files)**
   - Use `quick` analysis depth initially
   - Consider focusing on specific directories
   - Increase system resources (RAM, CPU)

2. **For slow networks**
   - Run analysis locally
   - Use cached results where possible
   - Consider incremental analysis

## Integration with CI/CD

### GitHub Actions Example

```yaml
name: Multi-Agent Analysis
on: [push, pull_request]

jobs:
  analyze:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v2
      - name: Run Multi-Agent Analysis
        run: ./.claude/workflows/run-directory-analysis.sh . standard json
      - name: Upload Results
        uses: actions/upload-artifact@v2
        with:
          name: analysis-results
          path: analysis-results-*/
```

### Jenkins Pipeline Example

```groovy
pipeline {
    agent any
    stages {
        stage('Multi-Agent Analysis') {
            steps {
                sh './.claude/workflows/run-directory-analysis.sh ${WORKSPACE} comprehensive json'
            }
            post {
                always {
                    archiveArtifacts artifacts: 'analysis-results-*/**', fingerprint: true
                }
            }
        }
    }
}
```

## Best Practices

1. **Regular Analysis**: Run analysis weekly for ongoing projects
2. **Before Releases**: Run comprehensive analysis before major releases
3. **After Major Changes**: Analyze after significant code changes
4. **Team Reviews**: Discuss findings in team meetings
5. **Track Progress**: Monitor how issues are resolved over time

## Limitations

1. **Static Analysis Only**: Cannot detect runtime-only issues
2. **Context Dependent**: Some findings may need human interpretation
3. **Resource Intensive**: Large codebases require significant resources
4. **Language Specific**: Some analysis may be language-dependent

## Support

For issues or questions:

1. Check the troubleshooting section above
2. Review the generated logs in the output directory
3. Verify all prerequisites are installed
4. Test with a small directory first

## Version History

- **v1.0.0**: Initial release with 6 specialized agents
- Support for multiple output formats
- Cross-platform compatibility (Unix/Windows)
- Configurable analysis depth and focus areas
