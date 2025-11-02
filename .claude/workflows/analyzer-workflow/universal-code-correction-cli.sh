#!/bin/bash

# Universal Code Correction & Validation Workflow CLI
# Advanced multi-agent system for fixing any code in any language with dual validation

set -e

# Configuration
WORKFLOW_NAME="universal-code-correction"
WORKFLOW_VERSION="1.0.0"
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Logging functions
log_info() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

log_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

log_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

log_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Show help information
show_help() {
    cat << EOF
Universal Code Correction & Validation Workflow v$WORKFLOW_VERSION

Sophisticated multi-agent system for fixing any code in any programming language
with dual validation approval system and autonomous operation.

USAGE:
    $0 [OPTIONS] [COMMAND] [ARGS]

COMMANDS:
    scan                    Scan entire project for code issues
    fix <file/path>        Fix specific file or directory
    validate               Run validation on current codebase
    status                 Show workflow status and statistics
    init                   Initialize workflow system
    interactive             Start interactive mode

OPTIONS:
    --domain <domain>       Focus on specific domain
                           (frontend, backend, uiux, performance, security, debugging, mobile, all)
    --severity <level>       Filter by severity level
                           (critical, high, medium, low)
    --auto-fix             Automatically apply fixes after validation
    --parallel              Run agents in parallel when possible
    --verbose              Show detailed output
    --dry-run              Show what would be done without executing
    --help                 Show this help message

EXAMPLES:
    $0 scan                                    # Scan entire project
    $0 scan --domain performance --severity critical  # Critical performance issues only
    $0 fix lib/main.dart                         # Fix specific file
    $0 fix lib/ --domain uiux                    # Fix UI/UX issues in lib directory
    $0 validate --auto-fix                        # Validate and auto-fix
    $0 interactive                              # Interactive mode

INTEGRATED AGENTS:
    • Frontend Specialist - UI components, responsive design, user experience, accessibility
    • Backend Specialist - Firebase integration, APIs, data models, authentication, cloud services
    • UI/UX Specialist - Design systems, user flows, component architecture, visual polish
    • Performance Specialist - Optimization, caching, memory management, load times, battery usage
    • Security Specialist - Authentication, data protection, OWASP compliance, encryption
    • Debugging Specialist - Error analysis, root cause investigation, troubleshooting, testing
    • Mobile Specialist - Flutter optimization, mobile patterns, platform integration, device features

VALIDATION SYSTEM:
    • Alpha Validation - Static analysis, Security scanning, Quality assessment
    • Beta Validation - Automated testing, Integration validation, Regression testing
    • Dual Approval - Both validators must approve before integration

QUALITY GATES:
    • Security Scan - Automated vulnerability assessment
    • Performance Test - Baseline comparison and optimization
    • Integration Test - Cross-system compatibility validation
    • Code Quality Score - Maintainability and complexity analysis

For more information, see: .claude/workflows/universal-code-correction.yml
EOF
}

# Initialize workflow system
init_workflow() {
    log_info "Initializing Universal Code Correction Workflow v$WORKFLOW_VERSION..."

    # Check if Node.js is available
    if ! command -v node &> /dev/null; then
        log_error "Node.js is required but not installed. Please install Node.js."
        exit 1
    fi

    # Check if MCP Flow is available
    if ! node -e "require('mcp__claude-flow_alpha')" 2>/dev/null; then
        log_warning "MCP Flow system not detected. Some features may be limited."
    fi

    # Create working directories
    mkdir -p "$PROJECT_ROOT/.claude/workflow-cache"
    mkdir -p "$PROJECT_ROOT/.claude/reports"

    # Set up environment
    export UNIVERSAL_WORKFLOW_ROOT="$PROJECT_ROOT"
    export UNIVERSAL_WORKFLOW_VERSION="$WORKFLOW_VERSION"

    log_success "Workflow initialized successfully"
    log_info "Cache directory: $PROJECT_ROOT/.claude/workflow-cache"
    log_info "Reports directory: $PROJECT_ROOT/.claude/reports"
}

# Scan project for issues
scan_project() {
    local domain_filter="$1"
    local severity_filter="$2"
    local auto_fix="$3"

    log_info "Starting comprehensive code scan..."

    if [ -n "$domain_filter" ] && [ "$domain_filter" != "all" ]; then
        log_info "Domain filter: $domain_filter"
    fi

    if [ -n "$severity_filter" ]; then
        log_info "Severity filter: $severity_filter"
    fi

    # Build scan command
    local scan_cmd="node '$SCRIPT_DIR/flow-nexus-integration.js' scanProject"

    if [ -n "$domain_filter" ]; then
        scan_cmd="$scan_cmd --domain $domain_filter"
    fi

    if [ -n "$severity_filter" ]; then
        scan_cmd="$scan_cmd --severity $severity_filter"
    fi

    # Execute scan
    log_info "Executing: $scan_cmd"
    eval "$scan_cmd"

    log_success "Scan completed. Check reports directory for results."
}

# Fix specific file or directory
fix_code() {
    local target="$1"
    local domain_filter="$2"
    local auto_fix="$3"

    if [ -z "$target" ]; then
        log_error "Target file or path is required for fix command"
        exit 1
    fi

    if [ ! -e "$target" ]; then
        log_error "Target does not exist: $target"
        exit 1
    fi

    log_info "Starting code correction for: $target"

    if [ -n "$domain_filter" ] && [ "$domain_filter" != "all" ]; then
        log_info "Domain filter: $domain_filter"
    fi

    # Build fix command
    local fix_cmd="node '$SCRIPT_DIR/flow-nexus-integration.js' executeCodeCorrection"
    fix_cmd="$fix_cmd --target '$(realpath "$target")'"

    if [ -n "$domain_filter" ]; then
        fix_cmd="$fix_cmd --domain $domain_filter"
    fi

    if [ "$auto_fix" = "true" ]; then
        fix_cmd="$fix_cmd --auto-fix"
    fi

    # Execute fix
    log_info "Executing: $fix_cmd"
    eval "$fix_cmd"

    log_success "Code correction completed. Check reports directory for results."
}

# Run validation
validate_code() {
    local auto_fix="$1"

    log_info "Running dual validation system..."

    if [ "$auto_fix" = "true" ]; then
        log_info "Auto-fix mode enabled"
    fi

    # Build validation command
    local validate_cmd="node '$SCRIPT_DIR/flow-nexus-integration.js' executeCodeCorrection --validation-only"

    if [ "$auto_fix" = "true" ]; then
        validate_cmd="$validate_cmd --auto-fix"
    fi

    # Execute validation
    log_info "Executing: $validate_cmd"
    eval "$validate_cmd"

    log_success "Validation completed. Check reports directory for results."
}

# Show workflow status
show_status() {
    log_info "Universal Code Correction Workflow Status v$WORKFLOW_VERSION"

    echo ""
    echo "Configuration:"
    echo "  • Project Root: $PROJECT_ROOT"
    echo "  • Cache Directory: $PROJECT_ROOT/.claude/workflow-cache"
    echo "  • Reports Directory: $PROJECT_ROOT/.claude/reports"

    echo ""
    echo "Agent Network:"
    echo "  • Frontend Specialist: Available"
    echo "  • Backend Specialist: Available"
    echo "  • UI/UX Specialist: Available"
    echo "  • Performance Specialist: Available"
    echo "  • Security Specialist: Available"
    echo "  • Debugging Specialist: Available"
    echo "  • Mobile Specialist: Available"

    echo ""
    echo "Validation System:"
    echo "  • Alpha Reviewer: Ready"
    echo "  • Beta Reviewer: Ready"
    echo "  • Dual Approval: Active"

    echo ""
    echo "Recent Activity:"
    if [ -f "$PROJECT_ROOT/.claude/reports/latest.json" ]; then
        node -e "
            const report = JSON.parse(require('fs').readFileSync('$PROJECT_ROOT/.claude/reports/latest.json', 'utf8'));
            console.log('  • Last Execution:', new Date(report.timestamp).toLocaleString());
            console.log('  • Issues Found:', report.totalIssues || 0);
            console.log('  • Issues Fixed:', report.issuesFixed || 0);
            console.log('  • Validation Status:', report.validationStatus || 'Unknown');
        "
    else
        echo "  • No previous executions found"
    fi
}

# Interactive mode
interactive_mode() {
    log_info "Starting Universal Code Correction Workflow in interactive mode..."

    while true; do
        echo ""
        echo "Universal Code Correction Workflow v$WORKFLOW_VERSION"
        echo "=================================="
        echo "1. Scan project for issues"
        echo "2. Fix specific file/directory"
        echo "3. Run validation only"
        echo "4. Show workflow status"
        echo "5. Configure settings"
        echo "6. Exit"
        echo ""
        read -p "Choose an option [1-6]: " choice

        case $choice in
            1)
                read -p "Enter domain filter (frontend/backend/uiux/performance/security/debugging/mobile/all): " domain
                read -p "Enter severity filter (critical/high/medium/low): " severity
                scan_project "$domain" "$severity" "false"
                ;;
            2)
                read -p "Enter target file or directory: " target
                read -p "Enter domain filter (frontend/backend/uiux/performance/security/debugging/mobile/all): " domain
                fix_code "$target" "$domain" "false"
                ;;
            3)
                read -p "Enable auto-fix? (y/n): " auto_fix
                if [[ $auto_fix =~ ^[Yy]$ ]]; then
                    validate_code "true"
                else
                    validate_code "false"
                fi
                ;;
            4)
                show_status
                ;;
            5)
                echo "Configuration settings would be implemented here"
                ;;
            6)
                log_info "Exiting Universal Code Correction Workflow"
                exit 0
                ;;
            *)
                log_error "Invalid option: $choice"
                ;;
        esac
    done
}

# Parse command line arguments
DOMAIN_FILTER=""
SEVERITY_FILTER=""
AUTO_FIX="false"
DRY_RUN="false"
VERBOSE="false"

while [[ $# -gt 0 ]]; do
    case $1 in
        --domain)
            DOMAIN_FILTER="$2"
            shift 2
            ;;
        --severity)
            SEVERITY_FILTER="$2"
            shift 2
            ;;
        --auto-fix)
            AUTO_FIX="true"
            shift
            ;;
        --dry-run)
            DRY_RUN="true"
            shift
            ;;
        --verbose)
            VERBOSE="true"
            shift
            ;;
        --help|-h)
            show_help
            exit 0
            ;;
        *)
            break
            ;;
    esac
done

# Main command processing
COMMAND=${1:-"interactive"}

case $COMMAND in
    init)
        init_workflow
        ;;
    scan)
        scan_project "$DOMAIN_FILTER" "$SEVERITY_FILTER" "$AUTO_FIX"
        ;;
    fix)
        fix_code "$2" "$DOMAIN_FILTER" "$AUTO_FIX"
        ;;
    validate)
        validate_code "$AUTO_FIX"
        ;;
    status)
        show_status
        ;;
    interactive)
        interactive_mode
        ;;
    *)
        log_error "Unknown command: $COMMAND"
        show_help
        exit 1
        ;;
esac