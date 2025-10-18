#!/bin/bash
# Post-Migration Quality Gate Validation
# Run this after completing each refactoring phase

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"

cd "$PROJECT_ROOT"

echo "========================================="
echo "🔍 Post-Migration Quality Gates"
echo "========================================="
echo ""

FAILED_GATES=0
WARNINGS=0

# ============================================================================
# GATE 1: Test Coverage
# ============================================================================
echo "Gate 1: Verifying test coverage..."
flutter test --coverage > /dev/null 2>&1

if [ -f "coverage/lcov.info" ]; then
    # Extract coverage percentage (requires lcov tool)
    if command -v lcov &> /dev/null; then
        COVERAGE=$(lcov --summary coverage/lcov.info 2>/dev/null | grep "lines" | awk '{print $2}' | tr -d '%')
        
        if (( $(echo "$COVERAGE >= 80" | bc -l) )); then
            echo "✅ Test coverage: ${COVERAGE}% (≥80% target)"
        else
            echo "❌ FAILURE: Test coverage ${COVERAGE}% below 80% threshold"
            FAILED_GATES=$((FAILED_GATES + 1))
        fi
    else
        echo "⚠️  WARNING: lcov not installed, coverage percentage unknown"
        echo "   Action: Install lcov to verify coverage"
        WARNINGS=$((WARNINGS + 1))
    fi
else
    echo "❌ FAILURE: No coverage report generated"
    FAILED_GATES=$((FAILED_GATES + 1))
fi
echo ""

# ============================================================================
# GATE 2: All Tests Passing
# ============================================================================
echo "Gate 2: Running full test suite..."
if flutter test --no-pub; then
    echo "✅ All tests passing"
else
    echo "❌ FAILURE: Tests failing after migration"
    echo "   Action: Fix failing tests before proceeding"
    FAILED_GATES=$((FAILED_GATES + 1))
fi
echo ""

# ============================================================================
# GATE 3: No Analyzer Warnings
# ============================================================================
echo "Gate 3: Running analyzer..."
ANALYZER_OUTPUT=$(flutter analyze 2>&1)
if echo "$ANALYZER_OUTPUT" | grep -q "No issues found"; then
    echo "✅ No analyzer warnings"
else
    WARNING_COUNT=$(echo "$ANALYZER_OUTPUT" | grep -c "warning" || echo "0")
    ERROR_COUNT=$(echo "$ANALYZER_OUTPUT" | grep -c "error" || echo "0")
    
    if [ "$ERROR_COUNT" -gt "0" ]; then
        echo "❌ FAILURE: $ERROR_COUNT analyzer errors detected"
        FAILED_GATES=$((FAILED_GATES + 1))
    fi
    
    if [ "$WARNING_COUNT" -gt "0" ]; then
        echo "⚠️  WARNING: $WARNING_COUNT analyzer warnings detected"
        WARNINGS=$((WARNINGS + 1))
    fi
fi
echo ""

# ============================================================================
# GATE 4: No Type Errors
# ============================================================================
echo "Gate 4: Checking for type errors..."
TYPE_ERRORS=$(grep -r "type.*error\|cast.*error" lib/ --include="*.dart" || echo "")
if [ -z "$TYPE_ERRORS" ]; then
    echo "✅ No obvious type errors in source"
else
    echo "⚠️  WARNING: Potential type errors detected in source comments"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================================
# GATE 5: Legacy Code Archived
# ============================================================================
echo "Gate 5: Verifying legacy code archived..."
if [ -d "lib/legacy_archived" ]; then
    LEGACY_FILES=$(find lib/legacy_archived -name "*.dart" 2>/dev/null | wc -l)
    echo "✅ Legacy archive exists with $LEGACY_FILES files"
else
    echo "⚠️  WARNING: No legacy_archived directory found"
    echo "   Action: Archive old implementations before marking complete"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================================
# GATE 6: Documentation Updated
# ============================================================================
echo "Gate 6: Checking documentation updates..."
if grep -q "Migration" CHANGELOG.md 2>/dev/null; then
    echo "✅ CHANGELOG.md updated"
else
    echo "⚠️  WARNING: CHANGELOG.md missing migration notes"
    WARNINGS=$((WARNINGS + 1))
fi
echo ""

# ============================================================================
# GATE 7: Performance Benchmarks (if available)
# ============================================================================
echo "Gate 7: Running performance checks..."
if [ -f "integration_test/performance_test.dart" ]; then
    echo "   Running performance tests..."
    if flutter test integration_test/performance_test.dart; then
        echo "✅ Performance tests passing"
    else
        echo "❌ FAILURE: Performance regression detected"
        FAILED_GATES=$((FAILED_GATES + 1))
    fi
else
    echo "⚠️  INFO: No performance tests found (optional)"
fi
echo ""

# ============================================================================
# FINAL SUMMARY
# ============================================================================
echo "========================================="
echo "📊 Post-Migration Summary"
echo "========================================="
echo ""

if [ $FAILED_GATES -eq 0 ]; then
    if [ $WARNINGS -eq 0 ]; then
        echo "✅ ALL QUALITY GATES PASSED - NO WARNINGS"
        echo ""
        echo "🚀 APPROVED for merge to main"
        echo ""
        echo "Next steps:"
        echo "  1. Create PR with detailed description"
        echo "  2. Request 2+ senior developer reviews"
        echo "  3. Ensure CI/CD pipeline passes"
        echo "  4. Plan gradual rollout with feature flags"
        echo ""
        exit 0
    else
        echo "✅ ALL QUALITY GATES PASSED - $WARNINGS WARNING(S)"
        echo ""
        echo "⚠️  CONDITIONAL APPROVAL - Address warnings before merge"
        echo ""
        echo "Review warnings above and update documentation"
        echo ""
        exit 0
    fi
else
    echo "❌ $FAILED_GATES QUALITY GATE(S) FAILED"
    if [ $WARNINGS -gt 0 ]; then
        echo "⚠️  $WARNINGS WARNING(S) detected"
    fi
    echo ""
    echo "🛑 MERGE BLOCKED - FIX FAILURES FIRST"
    echo ""
    echo "Do NOT proceed to PR until all gates pass"
    echo ""
    exit 1
fi
