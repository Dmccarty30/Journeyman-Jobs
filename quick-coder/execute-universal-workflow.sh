#!/bin/bash

# Universal Code Correction & Validation System - Execution Script
# Usage: ./execute-universal-workflow.sh [options]

set -e

echo "⚡ Universal Code Correction & Validation System"
echo "=============================================="
echo ""

# Check if Flow Nexus is available
if ! command -v npx &> /dev/null; then
    echo "❌ Error: npx (Node.js) not found. Please install Node.js first."
    exit 1
fi

# Default options
EXECUTION_MODE="interactive"
PRIORITY_LEVEL="all"
REPORT_FORMAT="html"

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --critical-only)
            PRIORITY_LEVEL="critical"
            echo "🔴 Mode: Critical Tasks Only"
            shift
            ;;
        --high-priority)
            PRIORITY_LEVEL="high"
            echo "🟠 Mode: High Priority Tasks"
            shift
            ;;
        --report-only)
            EXECUTION_MODE="report"
            echo "📊 Mode: Report Generation Only"
            shift
            ;;
        --dry-run)
            EXECUTION_MODE="dry-run"
            echo "🔍 Mode: Dry Run Analysis"
            shift
            ;;
        --help|-h)
            echo "Usage: $0 [options]"
            echo ""
            echo "Options:"
            echo "  --critical-only    Execute only critical priority tasks"
            echo "  --high-priority   Execute high priority and above"
            echo "  --report-only     Generate report without execution"
            echo "  --dry-run         Analyze tasks without executing"
            echo "  --help, -h        Show this help message"
            echo ""
            echo "Examples:"
            echo "  $0                    # Interactive mode with all tasks"
            echo "  $0 --critical-only    # Critical tasks only"
            echo "  $0 --dry-run          # Analyze without executing"
            exit 0
            ;;
        *)
            echo "❌ Unknown option: $1"
            echo "Use --help for usage information"
            exit 1
            ;;
    esac
done

# System status check
echo "🔍 Checking system status..."
npx claude-flow swarm status --verbose 2>/dev/null || echo "⚠️  Warning: Swarm not initialized"

# Workflow execution based on mode
case $EXECUTION_MODE in
    "interactive")
        echo "🚀 Starting interactive workflow execution..."
        echo "📋 Analyzing TODO.md for task generation..."
        npx claude-flow workflow execute universal-code-correction \
            --interactive \
            --todo-file-path "$(pwd)/TODO.md" \
            --execution-mode comprehensive \
            --quality-assurance strict \
            --reporting-level detailed
        ;;
    "report-only")
        echo "📊 Generating workflow report..."
        npx claude-flow workflow report \
            --workflow-id universal-code-correction \
            --format html \
            --output "workflow-report-$(date +%Y%m%d-%H%M%S).html"
        ;;
    "dry-run")
        echo "🔍 Running dry-run analysis..."
        npx claude-flow task analyze \
            --file "$(pwd)/TODO.md" \
            --priority-level $PRIORITY_LEVEL \
            --dry-run
        ;;
esac

echo ""
echo "✅ Universal Code Correction & Validation System execution completed!"
echo "📄 Check UNIVERSAL_CODE_CORRECTION_SYSTEM_REPORT.html for detailed results"
echo ""
echo "🔄 Next Steps:"
echo "   • Review execution report in browser"
echo "   • Check agent swarm status: npx claude-flow swarm status --verbose"
echo "   • Monitor task progress: npx claude-flow task list --active"
echo "   • Generate additional reports: npx claude-flow workflow report --format json"