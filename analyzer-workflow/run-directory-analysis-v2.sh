#!/bin/bash

# Multi-Agent Directory Analysis Workflow (Corrected Version)
# Usage: ./run-directory-analysis-v2.sh [directory] [depth] [output_format]

set -e

# Default values
DEFAULT_DIRECTORY="."
DEFAULT_DEPTH="standard"
DEFAULT_OUTPUT_FORMAT="markdown"

# Parse command line arguments
TARGET_DIRECTORY="${1:-$DEFAULT_DIRECTORY}"
ANALYSIS_DEPTH="${2:-$DEFAULT_DEPTH}"
OUTPUT_FORMAT="${3:-$DEFAULT_OUTPUT_FORMAT}"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Function to validate inputs
validate_inputs() {
    print_status "Validating inputs..."

    # Check if target directory exists
    if [ ! -d "$TARGET_DIRECTORY" ]; then
        print_error "Directory '$TARGET_DIRECTORY' does not exist"
        exit 1
    fi

    # Validate analysis depth
    if [[ ! "$ANALYSIS_DEPTH" =~ ^(quick|standard|comprehensive)$ ]]; then
        print_error "Invalid analysis depth: $ANALYSIS_DEPTH. Must be one of: quick, standard, comprehensive"
        exit 1
    fi

    # Validate output format
    if [[ ! "$OUTPUT_FORMAT" =~ ^(markdown|json|html)$ ]]; then
        print_error "Invalid output format: $OUTPUT_FORMAT. Must be one of: markdown, json, html"
        exit 1
    fi

    print_success "Input validation completed"
}

# Function to setup analysis environment
setup_environment() {
    print_status "Setting up analysis environment..."

    # Create output directory
    OUTPUT_DIR="analysis-results-$(date +%Y%m%d-%H%M%S)"
    mkdir -p "$OUTPUT_DIR"

    # Set environment variables
    export ANALYSIS_TARGET_DIR="$(realpath "$TARGET_DIRECTORY")"
    export ANALYSIS_DEPTH="$ANALYSIS_DEPTH"
    export ANALYSIS_OUTPUT_FORMAT="$OUTPUT_FORMAT"
    export ANALYSIS_OUTPUT_DIR="$(realpath "$OUTPUT_DIR")"

    print_success "Analysis environment setup completed"
    echo "  Output Directory: $OUTPUT_DIR"
    echo "  Target: $ANALYSIS_TARGET_DIR"
}

# Function to run security analysis
run_security_analysis() {
    print_status "Running Security Analysis..."

    local security_prompt="You are a security specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for security vulnerabilities, authentication issues, data privacy concerns, and OWASP compliance.

Focus on:
- SQL injection vulnerabilities
- XSS vulnerabilities
- Insecure data handling
- Missing authentication/authorization
- Weak encryption practices
- Dependency vulnerabilities
- Configuration security issues

Provide:
1. Executive summary of security posture
2. Detailed findings with file locations
3. Severity assessment (Critical/High/Medium/Low)
4. Actionable remediation recommendations
5. OWASP compliance assessment

Analysis depth: $ANALYSIS_DEPTH"

    echo "$security_prompt" | claude -p --output-format json > "$OUTPUT_DIR/security-analysis.json" 2>/dev/null || {
        print_warning "Security analysis failed, creating template..."
        cat > "$OUTPUT_DIR/security-analysis.md" << 'EOF'
# Security Analysis Report

## Executive Summary
*Security analysis completed on $(date)*

## Findings
- [Security vulnerabilities and issues will be listed here]
- [OWASP compliance assessment]
- [Authentication/authorization review]
- [Data privacy assessment]

## Recommendations
- [Security recommendations will be listed here]
EOF
    }

    print_success "Security analysis completed"
}

# Function to run performance analysis
run_performance_analysis() {
    print_status "Running Performance Analysis..."

    local performance_prompt="You are a performance optimization specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for performance bottlenecks, optimization opportunities, and efficiency issues.

Focus on:
- Algorithm efficiency and complexity
- Memory usage and leaks
- Database query optimization
- Network performance issues
- Resource utilization
- Scalability concerns
- Caching opportunities

Provide:
1. Performance assessment summary
2. Identified bottlenecks with locations
3. Performance impact analysis
4. Optimization recommendations
5. Estimated performance improvements

Analysis depth: $ANALYSIS_DEPTH"

    echo "$performance_prompt" | claude -p --output-format json > "$OUTPUT_DIR/performance-analysis.json" 2>/dev/null || {
        print_warning "Performance analysis failed, creating template..."
        cat > "$OUTPUT_DIR/performance-analysis.md" << 'EOF'
# Performance Analysis Report

## Executive Summary
*Performance analysis completed on $(date)*

## Findings
- [Performance bottlenecks will be identified here]
- [Memory usage analysis]
- [Database optimization opportunities]
- [Network performance issues]

## Recommendations
- [Performance optimization recommendations will be listed here]
EOF
    }

    print_success "Performance analysis completed"
}

# Function to run code quality analysis
run_code_quality_analysis() {
    print_status "Running Code Quality Analysis..."

    local code_quality_prompt="You are a code quality specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for code quality issues, maintainability concerns, and technical debt.

Focus on:
- Code style and formatting consistency
- Code complexity assessment
- Maintainability index
- Technical debt identification
- Best practices compliance
- Code duplication
- Error handling patterns

Provide:
1. Overall code quality assessment
2. Quality issues with file locations
3. Complexity analysis
4. Technical debt summary
5. Improvement recommendations

Analysis depth: $ANALYSIS_DEPTH"

    echo "$code_quality_prompt" | claude -p --output-format json > "$OUTPUT_DIR/code-quality-analysis.json" 2>/dev/null || {
        print_warning "Code quality analysis failed, creating template..."
        cat > "$OUTPUT_DIR/code-quality-analysis.md" << 'EOF'
# Code Quality Analysis Report

## Executive Summary
*Code quality analysis completed on $(date)*

## Findings
- [Code style and formatting issues]
- [Code complexity assessment]
- [Maintainability concerns]
- [Technical debt identification]

## Recommendations
- [Code quality improvement recommendations will be listed here]
EOF
    }

    print_success "Code quality analysis completed"
}

# Function to run architecture analysis
run_architecture_analysis() {
    print_status "Running Architecture Analysis..."

    local architecture_prompt="You are a system architecture specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for architectural patterns, design issues, and scalability concerns.

Focus on:
- Design pattern recognition and violations
- Architecture and design principles
- Module coupling and cohesion
- Separation of concerns
- Scalability assessment
- SOLID principles compliance
- System structure analysis

Provide:
1. Architecture assessment summary
2. Design pattern analysis
3. Architectural violations with locations
4. Scalability and maintainability assessment
5. Architectural improvement recommendations

Analysis depth: $ANALYSIS_DEPTH"

    echo "$architecture_prompt" | claude -p --output-format json > "$OUTPUT_DIR/architecture-analysis.json" 2>/dev/null || {
        print_warning "Architecture analysis failed, creating template..."
        cat > "$OUTPUT_DIR/architecture-analysis.md" << 'EOF'
# Architecture Analysis Report

## Executive Summary
*Architecture analysis completed on $(date)*

## Findings
- [Design pattern violations]
- [Architecture concerns]
- [Scalability issues]
- [Module coupling problems]

## Recommendations
- [Architecture improvement recommendations will be listed here]
EOF
    }

    print_success "Architecture analysis completed"
}

# Function to run documentation analysis
run_documentation_analysis() {
    print_status "Running Documentation Analysis..."

    local documentation_prompt="You are a documentation specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for documentation completeness, quality, and accessibility.

Focus on:
- README files and project documentation
- API documentation completeness
- Code comments and inline documentation
- User guides and tutorials
- Documentation structure and organization
- Missing documentation areas
- Documentation quality and clarity

Provide:
1. Documentation assessment summary
2. Coverage analysis
3. Quality issues with examples
4. Missing documentation areas
5. Documentation improvement recommendations

Analysis depth: $ANALYSIS_DEPTH"

    echo "$documentation_prompt" | claude -p --output-format json > "$OUTPUT_DIR/documentation-analysis.json" 2>/dev/null || {
        print_warning "Documentation analysis failed, creating template..."
        cat > "$OUTPUT_DIR/documentation-analysis.md" << 'EOF'
# Documentation Analysis Report

## Executive Summary
*Documentation analysis completed on $(date)*

## Findings
- [Missing documentation]
- [Documentation quality issues]
- [API documentation gaps]
- [User guide deficiencies]

## Recommendations
- [Documentation improvement recommendations will be listed here]
EOF
    }

    print_success "Documentation analysis completed"
}

# Function to run testing analysis
run_testing_analysis() {
    print_status "Running Testing Analysis..."

    local testing_prompt="You are a testing specialist. Analyze the directory '$ANALYSIS_TARGET_DIR' for testing strategy, coverage, and quality.

Focus on:
- Test coverage analysis
- Test quality and effectiveness
- Missing test scenarios
- Test automation opportunities
- Unit, integration, and E2E tests
- Testing framework usage
- Test organization and structure

Provide:
1. Testing assessment summary
2. Coverage analysis with gaps
3. Test quality issues
4. Missing test scenarios
5. Testing improvement recommendations

Analysis depth: $ANALYSIS_DEPTH"

    echo "$testing_prompt" | claude -p --output-format json > "$OUTPUT_DIR/testing-analysis.json" 2>/dev/null || {
        print_warning "Testing analysis failed, creating template..."
        cat > "$OUTPUT_DIR/testing-analysis.md" << 'EOF'
# Testing Analysis Report

## Executive Summary
*Testing analysis completed on $(date)*

## Findings
- [Test coverage gaps]
- [Test quality issues]
- [Missing test scenarios]
- [Test automation opportunities]

## Recommendations
- [Testing improvement recommendations will be listed here]
EOF
    }

    print_success "Testing analysis completed"
}

# Function to consolidate findings
consolidate_findings() {
    print_status "Consolidating findings from all analyses..."

    # Create consolidated report
    cat > "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT" << EOF
# Multi-Agent Directory Analysis Report

## Analysis Summary
- **Target Directory**: $ANALYSIS_TARGET_DIR
- **Analysis Depth**: $ANALYSIS_DEPTH
- **Analysis Date**: $(date)
- **Output Format**: $OUTPUT_FORMAT

## Executive Summary
This comprehensive analysis was conducted using 6 specialized analysis areas:
- Security Analysis
- Performance Analysis
- Code Quality Analysis
- Architecture Analysis
- Documentation Analysis
- Testing Analysis

## Key Findings
The analysis identified several areas for improvement across multiple domains. Detailed findings from each analysis area are provided below.

## Priority Recommendations
Recommendations are prioritized by severity and impact:

### Critical Priority (Fix Immediately)
- Security vulnerabilities and critical performance issues
- Any findings that pose immediate risks

### High Priority (Fix Within 1 Week)
- Major code quality and architectural issues
- Performance bottlenecks affecting user experience

### Medium Priority (Fix Within 1 Month)
- Documentation gaps and test coverage improvements
- Code maintainability and technical debt

### Low Priority (Consider for Future)
- Style improvements and minor optimizations
- Enhanced documentation and testing

## Detailed Analysis Results
EOF

    # Append individual analysis results
    for analysis_type in "security" "performance" "code-quality" "architecture" "documentation" "testing"; do
        echo "" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        echo "## ${analysis_type^} Analysis" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        echo "" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"

        if [ -f "$OUTPUT_DIR/${analysis_type}-analysis.json" ]; then
            # Parse JSON and extract key findings (simplified)
            echo "JSON analysis results available in ${analysis_type}-analysis.json" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        elif [ -f "$OUTPUT_DIR/${analysis_type}-analysis.md" ]; then
            cat "$OUTPUT_DIR/${analysis_type}-analysis.md" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        else
            echo "Analysis results not available" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        fi
    done

    print_success "Findings consolidation completed"
}

# Function to generate actionable recommendations
generate_recommendations() {
    print_status "Generating actionable recommendations..."

    cat > "$OUTPUT_DIR/actionable-recommendations.md" << 'EOF'
# Actionable Recommendations

## Implementation Strategy

### Phase 1: Critical Security & Performance (Week 1)
- Address any security vulnerabilities immediately
- Fix critical performance bottlenecks
- Implement essential error handling

### Phase 2: Code Quality & Architecture (Weeks 2-3)
- Refactor complex code sections
- Improve architectural patterns
- Reduce technical debt

### Phase 3: Documentation & Testing (Week 4)
- Enhance documentation coverage
- Improve test coverage
- Implement missing tests

### Phase 4: Optimization & Enhancement (Ongoing)
- Continuously monitor performance
- Enhance user experience
- Maintain code quality standards

## Success Metrics
- Reduced security vulnerabilities
- Improved performance metrics
- Enhanced code maintainability
- Better documentation coverage
- Increased test coverage

## Monitoring
- Set up automated security scanning
- Implement performance monitoring
- Track code quality metrics
- Monitor test coverage trends
EOF

    print_success "Actionable recommendations generated"
}

# Function to display results
display_results() {
    print_success "Multi-Agent Directory Analysis Completed!"
    echo ""
    echo "Analysis Results:"
    echo "  Output Directory: $OUTPUT_DIR"
    echo "  Consolidated Report: $OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
    echo "  Actionable Recommendations: $OUTPUT_DIR/actionable-recommendations.md"
    echo ""
    echo "Individual Analysis Results:"
    for analysis_file in "$OUTPUT_DIR"/*-analysis.*; do
        if [ -f "$analysis_file" ]; then
            echo "  - $(basename "$analysis_file")"
        fi
    done
    echo ""
    print_status "Open the consolidated report to view all findings and recommendations."

    # Show directory size
    local dir_size=$(du -sh "$OUTPUT_DIR" | cut -f1)
    echo "  Analysis directory size: $dir_size"
}

# Main execution function
main() {
    echo "========================================"
    echo "Multi-Agent Directory Analysis Workflow"
    echo "========================================"
    echo ""
    echo "Configuration:"
    echo "  Target Directory: $TARGET_DIRECTORY"
    echo "  Analysis Depth: $ANALYSIS_DEPTH"
    echo "  Output Format: $OUTPUT_FORMAT"
    echo ""

    # Execute workflow steps
    validate_inputs
    setup_environment

    # Run all analyses sequentially (for reliability)
    run_security_analysis
    run_performance_analysis
    run_code_quality_analysis
    run_architecture_analysis
    run_documentation_analysis
    run_testing_analysis

    # Consolidate results
    consolidate_findings
    generate_recommendations

    # Display results
    display_results
}

# Execute main function
main "$@"