#!/bin/bash
# Pre-Refactoring Quality Gate Validation

set -e
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$SCRIPT_DIR/../.." && pwd)"
cd "$PROJECT_ROOT"

echo "========================================="
echo "🔍 Pre-Refactor Quality Gates"
echo "========================================="
echo ""

FAILED_GATES=0

# GATE 1: Clean Working Directory
echo "Gate 1: Checking for uncommitted changes..."
UNCOMMITTED=$(git status --porcelain | wc -l)
if [ "$UNCOMMITTED" -ne "0" ]; then
    echo "❌ CRITICAL: $UNCOMMITTED uncommitted files"
    echo "   Action: git add . && git commit -m 'Pre-refactor snapshot'"
    FAILED_GATES=$((FAILED_GATES + 1))
else
    echo "✅ Working directory clean"
fi

# GATE 2: Tests Passing
echo "Gate 2: Running test suite..."
if flutter test --no-pub > /dev/null 2>&1; then
    echo "✅ Tests passing"
else
    echo "❌ Tests failing"
    FAILED_GATES=$((FAILED_GATES + 1))
fi

# GATE 3: Analyzer Clean
echo "Gate 3: Running analyzer..."
if flutter analyze > /dev/null 2>&1; then
    echo "✅ No analyzer warnings"
else
    echo "❌ Analyzer warnings detected"
    FAILED_GATES=$((FAILED_GATES + 1))
fi

# GATE 4: Create Backup
echo "Gate 4: Creating backup tag..."
BACKUP_TAG="pre-refactor-backup-$(date +%Y%m%d-%H%M%S)"
if git tag "$BACKUP_TAG"; then
    echo "✅ Backup: $BACKUP_TAG"
else
    echo "❌ Backup tag failed"
    FAILED_GATES=$((FAILED_GATES + 1))
fi

echo ""
echo "========================================="
if [ $FAILED_GATES -eq 0 ]; then
    echo "✅ ALL GATES PASSED - APPROVED"
    exit 0
else
    echo "❌ $FAILED_GATES GATE(S) FAILED - BLOCKED"
    exit 1
fi
