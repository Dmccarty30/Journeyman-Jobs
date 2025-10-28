#!/bin/bash

# Hierarchical Task Orchestration - Task Validation Script
# Validates task structure, dependencies, and quality metrics

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Configuration
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
SKILL_DIR="$(dirname "$SCRIPT_DIR")"
TEMPLATE_DIR="$SKILL_DIR/templates"

# Default values
VERBOSE=false
STRICT=false
TASK_FILES=()
OUTPUT_FORMAT="text"

# Help function
show_help() {
    cat << EOF
Hierarchical Task Orchestration - Task Validation Script

USAGE:
    $0 [OPTIONS] [TASK_FILES...]

OPTIONS:
    -v, --verbose          Enable verbose output
    -s, --strict           Enable strict validation mode
    -f, --format FORMAT    Output format: text|json|yaml (default: text)
    -h, --help            Show this help message

EXAMPLES:
    $0 task1.yaml task2.yaml
    $0 --verbose --strict tasks/*.yaml
    $0 --format json --strict task.yaml

DESCRIPTION:
    This script validates task files against the hierarchical task orchestration
    specification. It checks for required fields, validates dependencies,
    ensures proper formatting, and assesses task quality metrics.

    Validation checks include:
    - Required field presence and format
    - Dependency consistency and circular dependency detection
    - Priority and complexity scoring validation
    - Quality gate threshold verification
    - Agent assignment compatibility
    - Risk assessment completeness

EXIT CODES:
    0   All validations passed
    1   Validation errors found
    2   Configuration or usage error
    3   System or runtime error

EOF
}

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

log_debug() {
    if [[ "$VERBOSE" == "true" ]]; then
        echo -e "${BLUE}[DEBUG]${NC} $1"
    fi
}

# Parse command line arguments
parse_args() {
    while [[ $# -gt 0 ]]; do
        case $1 in
            -v|--verbose)
                VERBOSE=true
                shift
                ;;
            -s|--strict)
                STRICT=true
                shift
                ;;
            -f|--format)
                OUTPUT_FORMAT="$2"
                shift 2
                ;;
            -h|--help)
                show_help
                exit 0
                ;;
            -*)
                log_error "Unknown option: $1"
                show_help
                exit 2
                ;;
            *)
                TASK_FILES+=("$1")
                shift
                ;;
        esac
    done

    # Validate output format
    if [[ ! "$OUTPUT_FORMAT" =~ ^(text|json|yaml)$ ]]; then
        log_error "Invalid output format: $OUTPUT_FORMAT"
        exit 2
    fi
}

# Check dependencies
check_dependencies() {
    log_debug "Checking script dependencies..."

    # Check for required tools
    local missing_tools=()

    if ! command -v yq &> /dev/null; then
        missing_tools+=("yq")
    fi

    if ! command -v jq &> /dev/null; then
        missing_tools+=("jq")
    fi

    if [[ ${#missing_tools[@]} -gt 0 ]]; then
        log_error "Missing required tools: ${missing_tools[*]}"
        log_info "Install missing tools:"
        log_info "  yq: https://github.com/mikefarah/yq#install"
        log_info "  jq: https://stedolan.github.io/jq/download/"
        exit 3
    fi

    log_debug "All dependencies satisfied"
}

# Validate YAML syntax
validate_yaml_syntax() {
    local file="$1"
    log_debug "Validating YAML syntax for: $file"

    if ! yq eval '.' "$file" > /dev/null 2>&1; then
        log_error "Invalid YAML syntax in: $file"
        return 1
    fi

    return 0
}

# Validate required fields
validate_required_fields() {
    local file="$1"
    local errors=0
    log_debug "Validating required fields for: $file"

    # List of required fields
    local required_fields=(
        "task_id"
        "task_name"
        "task_type"
        "priority"
        "domain"
        "description"
        "acceptance_criteria"
        "complexity_score"
        "risk_level"
    )

    for field in "${required_fields[@]}"; do
        if ! yq eval ".$field" "$file" > /dev/null 2>&1; then
            log_error "Missing required field '$field' in: $file"
            ((errors++))
        else
            local value
            value=$(yq eval ".$field" "$file")
            if [[ "$value" == "null" || "$value" == "" ]]; then
                log_error "Required field '$field' is empty in: $file"
                ((errors++))
            fi
        fi
    done

    return $errors
}

# Validate field formats and values
validate_field_formats() {
    local file="$1"
    local errors=0
    log_debug "Validating field formats for: $file"

    # Validate task_type
    local task_type
    task_type=$(yq eval '.task_type' "$file")
    if [[ ! "$task_type" =~ ^(strategic|tactical|operational)$ ]]; then
        log_error "Invalid task_type '$task_type' in: $file (must be: strategic, tactical, or operational)"
        ((errors++))
    fi

    # Validate priority
    local priority
    priority=$(yq eval '.priority' "$file")
    if [[ ! "$priority" =~ ^(critical|high|medium|low)$ ]]; then
        log_error "Invalid priority '$priority' in: $file (must be: critical, high, medium, or low)"
        ((errors++))
    fi

    # Validate complexity_score
    local complexity_score
    complexity_score=$(yq eval '.complexity_score' "$file")
    if ! [[ "$complexity_score" =~ ^0\.[0-9]+$|^1\.0$ ]] || (( $(echo "$complexity_score < 0 || $complexity_score > 1" | bc -l) )); then
        log_error "Invalid complexity_score '$complexity_score' in: $file (must be between 0.0 and 1.0)"
        ((errors++))
    fi

    # Validate risk_level
    local risk_level
    risk_level=$(yq eval '.risk_level' "$file")
    if [[ ! "$risk_level" =~ ^(low|medium|high|critical)$ ]]; then
        log_error "Invalid risk_level '$risk_level' in: $file (must be: low, medium, high, or critical)"
        ((errors++))
    fi

    # Validate domain
    local domain
    domain=$(yq eval '.domain' "$file")
    if [[ ! "$domain" =~ ^(frontend|backend|architecture|security|performance|qa|infrastructure)$ ]]; then
        log_error "Invalid domain '$domain' in: $file"
        ((errors++))
    fi

    return $errors
}

# Validate dependencies
validate_dependencies() {
    local file="$1"
    local errors=0
    log_debug "Validating dependencies for: $file"

    # Check for circular dependencies
    local task_id
    task_id=$(yq eval '.task_id' "$file")

    # Extract dependency task IDs
    local deps
    deps=$(yq eval '.dependencies.hard_dependencies[].task_id' "$file" 2>/dev/null || true)

    if [[ -n "$deps" && "$deps" != "null" ]]; then
        while IFS= read -r dep_id; do
            if [[ "$dep_id" == "$task_id" ]]; then
                log_error "Circular dependency detected: task '$task_id' depends on itself in: $file"
                ((errors++))
            fi
        done <<< "$deps"
    fi

    # Validate dependency structure
    local dep_count
    dep_count=$(yq eval '.dependencies.hard_dependencies | length' "$file" 2>/dev/null || echo "0")

    if [[ "$dep_count" -gt 10 ]]; then
        log_warning "High dependency count ($dep_count) in: $file - consider breaking down task"
    fi

    return $errors
}

# Validate quality gates
validate_quality_gates() {
    local file="$1"
    local errors=0
    log_debug "Validating quality gates for: $file"

    # Check quality gate thresholds
    local code_quality_threshold
    code_quality_threshold=$(yq eval '.quality_gates.code_quality_threshold' "$file" 2>/dev/null || echo "0.85")

    if ! [[ "$code_quality_threshold" =~ ^0\.[0-9]+$|^1\.0$ ]] || (( $(echo "$code_quality_threshold < 0 || $code_quality_threshold > 1" | bc -l) )); then
        log_error "Invalid code_quality_threshold '$code_quality_threshold' in: $file"
        ((errors++))
    fi

    local test_coverage_minimum
    test_coverage_minimum=$(yq eval '.quality_gates.test_coverage_minimum' "$file" 2>/dev/null || echo "0.80")

    if ! [[ "$test_coverage_minimum" =~ ^0\.[0-9]+$|^1\.0$ ]] || (( $(echo "$test_coverage_minimum < 0 || $test_coverage_minimum > 1" | bc -l) )); then
        log_error "Invalid test_coverage_minimum '$test_coverage_minimum' in: $file"
        ((errors++))
    fi

    # In strict mode, validate higher thresholds
    if [[ "$STRICT" == "true" ]]; then
        if (( $(echo "$code_quality_threshold < 0.85" | bc -l) )); then
            log_error "code_quality_threshold too low ($code_quality_threshold) in strict mode for: $file"
            ((errors++))
        fi

        if (( $(echo "$test_coverage_minimum < 0.80" | bc -l) )); then
            log_error "test_coverage_minimum too low ($test_coverage_minimum) in strict mode for: $file"
            ((errors++))
        fi
    fi

    return $errors
}

# Validate agent assignment
validate_agent_assignment() {
    local file="$1"
    local errors=0
    log_debug "Validating agent assignment for: $file"

    local assigned_agent
    assigned_agent=$(yq eval '.assigned_agent' "$file" 2>/dev/null || echo "")

    if [[ -n "$assigned_agent" && "$assigned_agent" != "null" ]]; then
        # Validate against known agent types
        local valid_agents=(
            "frontend-developer"
            "backend-developer"
            "architect"
            "security-auditor"
            "performance-engineer"
            "qa"
            "infrastructure"
        )

        local agent_valid=false
        for agent in "${valid_agents[@]}"; do
            if [[ "$assigned_agent" == "$agent" ]]; then
                agent_valid=true
                break
            fi
        done

        if [[ "$agent_valid" == "false" ]]; then
            log_warning "Unknown agent type '$assigned_agent' in: $file"
        fi
    else
        log_warning "No agent assigned for: $file - agent assignment recommended"
    fi

    return $errors
}

# Validate business logic
validate_business_logic() {
    local file="$1"
    local errors=0
    log_debug "Validating business logic for: $file"

    # Check complexity vs task type alignment
    local task_type
    local complexity_score
    task_type=$(yq eval '.task_type' "$file")
    complexity_score=$(yq eval '.complexity_score' "$file")

    case "$task_type" in
        "strategic")
            if (( $(echo "$complexity_score < 0.7" | bc -l) )); then
                log_warning "Strategic task with low complexity ($complexity_score) in: $file"
            fi
            ;;
        "tactical")
            if (( $(echo "$complexity_score < 0.4" | bc -l) )); then
                log_warning "Tactical task with very low complexity ($complexity_score) in: $file"
            fi
            if (( $(echo "$complexity_score > 0.8" | bc -l) )); then
                log_warning "Tactical task with very high complexity ($complexity_score) - consider splitting in: $file"
            fi
            ;;
        "operational")
            if (( $(echo "$complexity_score > 0.6" | bc -l) )); then
                log_warning "Operational task with high complexity ($complexity_score) - consider breaking down in: $file"
            fi
            ;;
    esac

    # Check priority vs risk alignment
    local priority
    local risk_level
    priority=$(yq eval '.priority' "$file")
    risk_level=$(yq eval '.risk_level' "$file")

    # Convert priority and risk to numeric values for comparison
    local priority_value
    local risk_value

    case "$priority" in
        "critical") priority_value=4 ;;
        "high") priority_value=3 ;;
        "medium") priority_value=2 ;;
        "low") priority_value=1 ;;
    esac

    case "$risk_level" in
        "critical") risk_value=4 ;;
        "high") risk_value=3 ;;
        "medium") risk_value=2 ;;
        "low") risk_value=1 ;;
    esac

    if [[ $priority_value -lt $risk_value ]]; then
        log_warning "Priority ($priority) lower than risk level ($risk_level) in: $file"
    fi

    return $errors
}

# Validate single task file
validate_task_file() {
    local file="$1"
    local total_errors=0

    log_info "Validating task file: $file"

    # Check if file exists
    if [[ ! -f "$file" ]]; then
        log_error "Task file not found: $file"
        return 1
    fi

    # Run all validation checks
    validate_yaml_syntax "$file" || ((total_errors++))
    validate_required_fields "$file" || ((total_errors++))
    validate_field_formats "$file" || ((total_errors++))
    validate_dependencies "$file" || ((total_errors++))
    validate_quality_gates "$file" || ((total_errors++))
    validate_agent_assignment "$file" || ((total_errors++))
    validate_business_logic "$file" || ((total_errors++))

    if [[ $total_errors -eq 0 ]]; then
        log_success "Task validation passed: $file"
    else
        log_error "Task validation failed with $total_errors error(s): $file"
    fi

    return $total_errors
}

# Generate validation report
generate_report() {
    local results=("$@")
    local total_files=${#results[@]}
    local passed_files=0
    local failed_files=0

    for result in "${results[@]}"; do
        if [[ $result -eq 0 ]]; then
            ((passed_files++))
        else
            ((failed_files++))
        fi
    done

    echo
    log_info "Validation Summary:"
    echo "  Total files: $total_files"
    echo "  Passed: $passed_files"
    echo "  Failed: $failed_files"
    echo "  Success rate: $(( (passed_files * 100) / total_files ))%"

    if [[ $failed_files -eq 0 ]]; then
        log_success "All task validations passed!"
        return 0
    else
        log_error "Validation failed for $failed_files file(s)"
        return 1
    fi
}

# Main execution
main() {
    parse_args "$@"

    # Check dependencies
    check_dependencies

    # If no task files provided, look for them in current directory
    if [[ ${#TASK_FILES[@]} -eq 0 ]]; then
        log_info "No task files specified, searching for *.yaml files..."
        mapfile -t TASK_FILES < <(find . -maxdepth 1 -name "*.yaml" -o -name "*.yml" | head -20)

        if [[ ${#TASK_FILES[@]} -eq 0 ]]; then
            log_error "No task files found"
            exit 2
        fi

        log_info "Found ${#TASK_FILES[@]} task file(s)"
    fi

    # Validate each task file
    local validation_results=()
    for task_file in "${TASK_FILES[@]}"; do
        validate_task_file "$task_file"
        validation_results+=($?)
    done

    # Generate final report
    generate_report "${validation_results[@]}"
}

# Execute main function
main "$@"