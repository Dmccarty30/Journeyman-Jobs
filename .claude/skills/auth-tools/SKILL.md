---
name: Auth Tools
description: Utilities for auth debugging: token validation, rule checks. Use proactively for auth errors like 'permission denied'.
allowed-tools: Read, Grep, Glob, Bash
---

# Auth Tools

## Instructions

When auth issues arise:

1. Validate tokens: Use Bash to check env vars (e.g., !`echo $FIREBASE_TOKEN`).
2. Grep for rules: Search Firestore rules with Grep.
3. Test endpoints: Simulate with Bash curls.

## Script Example

See validate_token.sh for token checks.
