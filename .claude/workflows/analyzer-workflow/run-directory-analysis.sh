#!/bin/bash

# Multi-Agent Directory Analysis Workflow Execution Script
# Usage: ./run-directory-analysis.sh [directory] [depth] [output_format]

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

    # Set environment variables for agents
    export ANALYSIS_TARGET_DIR="$(realpath "$TARGET_DIRECTORY")"
    export ANALYSIS_DEPTH="$ANALYSIS_DEPTH"
    export ANALYSIS_OUTPUT_FORMAT="$OUTPUT_FORMAT"
    export ANALYSIS_OUTPUT_DIR="$(realpath "$OUTPUT_DIR")"

    print_success "Analysis environment setup completed"
}

# Function to spawn security analyst
spawn_security_analyst() {
    print_status "Spawning Security Analyst..."

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

    # Use Task tool to spawn security analyst
    claude --task "Analyze security vulnerabilities in $ANALYSIS_TARGET_DIR. Focus on authentication, data handling, and OWASP compliance. Generate detailed security findings and recommendations." \
           --agent security-specialist \
           --output "$OUTPUT_DIR/security-detailed-analysis.md" &

    SECURITY_PID=$!
    print_success "Security Analyst spawned (PID: $SECURITY_PID)"
}

# Function to spawn performance analyst
spawn_performance_analyst() {
    print_status "Spawning Performance Analyst..."

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

    # Use Task tool to spawn performance analyst
    claude --task "Analyze performance bottlenecks in $ANALYSIS_TARGET_DIR. Focus on code efficiency, memory usage, and optimization opportunities. Generate detailed performance findings and recommendations." \
           --agent performance-specialist \
           --output "$OUTPUT_DIR/performance-detailed-analysis.md" &

    PERFORMANCE_PID=$!
    print_success "Performance Analyst spawned (PID: $PERFORMANCE_PID)"
}

# Function to spawn code quality analyst
spawn_code_quality_analyst() {
    print_status "Spawning Code Quality Analyst..."

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

    # Use Task tool to spawn code quality analyst
    claude --task "Analyze code quality in $ANALYSIS_TARGET_DIR. Focus on maintainability, technical debt, code complexity, and best practices. Generate detailed quality findings and recommendations." \
           --agent code-quality-specialist \
           --output "$OUTPUT_DIR/code-quality-detailed-analysis.md" &

    CODE_QUALITY_PID=$!
    print_success "Code Quality Analyst spawned (PID: $CODE_QUALITY_PID)"
}

# Function to spawn architecture analyst
spawn_architecture_analyst() {
    print_status "Spawning Architecture Analyst..."

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

    # Use Task tool to spawn architecture analyst
    claude --task "Analyze system architecture in $ANALYSIS_TARGET_DIR. Focus on design patterns, module coupling, scalability, and architectural violations. Generate detailed architecture findings and recommendations." \
           --agent architecture-specialist \
           --output "$OUTPUT_DIR/architecture-detailed-analysis.md" &

    ARCHITECTURE_PID=$!
    print_success "Architecture Analyst spawned (PID: $ARCHITECTURE_PID)"
}

# Function to spawn documentation analyst
spawn_documentation_analyst() {
    print_status "Spawning Documentation Analyst..."

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

    # Use Task tool to spawn documentation analyst
    claude --task "Analyze documentation quality in $ANALYSIS_TARGET_DIR. Focus on README files, code comments, API documentation, and user guides. Generate detailed documentation findings and recommendations." \
           --agent documentation-specialist \
           --output "$OUTPUT_DIR/documentation-detailed-analysis.md" &

    DOCUMENTATION_PID=$!
    print_success "Documentation Analyst spawned (PID: $DOCUMENTATION_PID)"
}

# Function to spawn testing analyst
spawn_testing_analyst() {
    print_status "Spawning Testing Analyst..."

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

    # Use Task tool to spawn testing analyst
    claude --task "Analyze testing strategy and coverage in $ANALYSIS_TARGET_DIR. Focus on test coverage, test quality, missing scenarios, and automation opportunities. Generate detailed testing findings and recommendations." \
           --agent testing-specialist \
           --output "$OUTPUT_DIR/testing-detailed-analysis.md" &

    TESTING_PID=$!
    print_success "Testing Analyst spawned (PID: $TESTING_PID)"
}

# Function to wait for all agents to complete
wait_for_agents() {
    print_status "Waiting for all agents to complete analysis..."

    # Array of agent PIDs
    AGENT_PIDS=($SECURITY_PID $PERFORMANCE_PID $CODE_QUALITY_PID $ARCHITECTURE_PID $DOCUMENTATION_PID $TESTING_PID)

    # Wait for all agents to complete
    for pid in "${AGENT_PIDS[@]}"; do
        wait $pid
        print_success "Agent process $pid completed"
    done

    print_success "All agents have completed their analysis"
}

# Function to consolidate findings
consolidate_findings() {
    print_status "Consolidating findings from all agents..."

    # Create consolidated report
    cat > "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT" << EOF
# Multi-Agent Directory Analysis Report

## Analysis Summary
- **Target Directory**: $ANALYSIS_TARGET_DIR
- **Analysis Depth**: $ANALYSIS_DEPTH
- **Analysis Date**: $(date)
- **Output Format**: $OUTPUT_FORMAT

## Executive Summary
This comprehensive analysis was conducted using 6 specialized agents:
- Security Analyst
- Performance Analyst
- Code Quality Analyst
- Architecture Analyst
- Documentation Analyst
- Testing Analyst

## Key Findings
[Key findings from all agents will be consolidated here]

## Priority Recommendations
[High-priority recommendations from all agents]

## Detailed Analysis
EOF

    # Append individual analysis results
    for analysis_file in "$OUTPUT_DIR"/*-analysis.md; do
        if [ -f "$analysis_file" ]; then
            echo "" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
            echo "## $(basename "$analysis_file" .md | sed 's/-/ /g' | sed 's/\b\w/\U&/g')" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
            cat "$analysis_file" >> "$OUTPUT_DIR/consolidated-analysis-report.$OUTPUT_FORMAT"
        fi
    done

    print_success "Findings consolidation completed"
}

# Function to generate actionable recommendations
generate_recommendations() {
    print_status "Generating actionable recommendations..."

    cat > "$OUTPUT_DIR/actionable-recommendations.md" << 'EOF'
# Actionable Recommendations

## Critical Priority (Fix Immediately)
- [Critical recommendations will be listed here]

## High Priority (Fix Within 1 Week)
- [High priority recommendations will be listed here]

## Medium Priority (Fix Within 1 Month)
- [Medium priority recommendations will be listed here]

## Low Priority (Consider for Future)
- [Low priority recommendations will be listed here]

## Implementation Roadmap
[Step-by-step implementation plan will be provided here]
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
    echo "Individual Agent Reports:"
    for analysis_file in "$OUTPUT_DIR"/*-detailed-analysis.md; do
        if [ -f "$analysis_file" ]; then
            echo "  - $(basename "$analysis_file")"
        fi
    done
    echo ""
    print_status "Open the consolidated report to view all findings and recommendations."
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

    # Spawn all agents in parallel
    spawn_security_analyst
    spawn_performance_analyst
    spawn_code_quality_analyst
    spawn_architecture_analyst
    spawn_documentation_analyst
    spawn_testing_analyst

    # Wait for all agents to complete
    wait_for_agents

    # Consolidate results
    consolidate_findings
    generate_recommendations

    # Display results
    display_results
}

# Execute main function
main "$@"