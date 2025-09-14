#!/bin/bash
# Bash version of create-new-feature.ps1 for environments without PowerShell

set -euo pipefail

# Parse arguments
JSON_OUTPUT=false
FEATURE_DESC=""

while [[ $# -gt 0 ]]; do
    case $1 in
        -Json|--json)
            JSON_OUTPUT=true
            shift
            ;;
        *)
            FEATURE_DESC="$FEATURE_DESC $1"
            shift
            ;;
    esac
done

FEATURE_DESC=$(echo "$FEATURE_DESC" | xargs)  # Trim whitespace

if [[ -z "$FEATURE_DESC" ]]; then
    echo "Usage: ./create-new-feature.sh [-Json] <feature description>" >&2
    exit 1
fi

# Get repo root and set up directories
REPO_ROOT=$(git rev-parse --show-toplevel)
FEATURES_DIR="$REPO_ROOT/docs/features"
mkdir -p "$FEATURES_DIR"

# Find highest existing feature number
HIGHEST=0
if [[ -d "$FEATURES_DIR" ]]; then
    for dir in "$FEATURES_DIR"/*/; do
        if [[ -d "$dir" ]]; then
            BASENAME=$(basename "$dir")
            if [[ $BASENAME =~ ^([0-9]{3}) ]]; then
                NUM=${BASH_REMATCH[1]}
                if (( 10#$NUM > HIGHEST )); then
                    HIGHEST=$((10#$NUM))
                fi
            fi
        fi
    done
fi

NEXT=$((HIGHEST + 1))
FEATURE_NUM=$(printf "%03d" $NEXT)

# Create branch name from feature description
BRANCH_NAME=$(echo "$FEATURE_DESC" | tr '[:upper:]' '[:lower:]' | sed 's/[^a-z0-9]/-/g' | sed 's/-\+/-/g' | sed 's/^-\|--*$//g')
# Take first 3 words
BRANCH_NAME=$(echo "$BRANCH_NAME" | cut -d'-' -f1-3 | sed 's/-$//g')
BRANCH_NAME="$FEATURE_NUM-$BRANCH_NAME"

# Create and checkout branch
git checkout -b "$BRANCH_NAME" >/dev/null 2>&1

# Create feature directory
FEATURE_DIR="$FEATURES_DIR/$BRANCH_NAME"
mkdir -p "$FEATURE_DIR"

# Copy template file
TEMPLATE="$REPO_ROOT/.specify/templates/spec-template.md"
SPEC_FILE="$FEATURE_DIR/spec.md"

if [[ -f "$TEMPLATE" ]]; then
    cp "$TEMPLATE" "$SPEC_FILE"
else
    touch "$SPEC_FILE"
fi

# Output results
if [[ "$JSON_OUTPUT" == true ]]; then
    echo "{\"BRANCH_NAME\":\"$BRANCH_NAME\",\"SPEC_FILE\":\"$SPEC_FILE\",\"FEATURE_NUM\":\"$FEATURE_NUM\"}"
else
    echo "BRANCH_NAME: $BRANCH_NAME"
    echo "SPEC_FILE: $SPEC_FILE"
    echo "FEATURE_NUM: $FEATURE_NUM"
fi