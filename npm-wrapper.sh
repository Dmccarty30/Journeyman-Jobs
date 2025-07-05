#!/bin/bash
# Universal wrapper script for npm/npx to bypass config issues

# Create a temporary directory for npm operations
TEMP_DIR="/tmp/npm-wrapper-$$"
mkdir -p "$TEMP_DIR"

# Change to temp directory to avoid project .npmrc
cd "$TEMP_DIR"

# Create empty npm config files
touch ".npmrc"

export NPM_CONFIG_USERCONFIG="$TEMP_DIR/.npmrc"
export NPM_CONFIG_PREFIX="$TEMP_DIR/npm-prefix"
export NPM_CONFIG_CACHE="$TEMP_DIR/npm-cache"
export HOME="$TEMP_DIR"

# Create the directories
mkdir -p "$NPM_CONFIG_PREFIX"
mkdir -p "$NPM_CONFIG_CACHE"

# Clean up on exit
trap "rm -rf $TEMP_DIR" EXIT

# Use the npx from nvm with passed arguments
exec /home/david/.nvm/versions/node/v22.14.0/bin/npx "$@"