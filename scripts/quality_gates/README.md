# Quality Gates - Automated Validation Scripts

## Purpose

Prevent production outages during refactoring through automated quality validation.

## Usage

### Before Starting Refactoring

```bash
./scripts/quality_gates/pre_refactor_check.sh
```

**This script MUST pass before ANY refactoring work begins.**

Validates:
- ✅ Clean git working directory (no uncommitted files)
- ✅ All existing tests passing
- ✅ No analyzer warnings
- ✅ Backup tag created for rollback

**If this fails:** Fix the issues before proceeding. Do NOT skip validation.

---

### After Completing Migration

```bash
./scripts/quality_gates/post_migration_validation.sh
```

Validates:
- ✅ Test coverage ≥80%
- ✅ All tests passing
- ✅ No analyzer errors
- ✅ Legacy code archived
- ✅ Documentation updated
- ✅ Performance benchmarks (if available)

**If this fails:** Do NOT create PR until all gates pass.

---

## Exit Codes

- `0` = All gates passed (success)
- `1` = One or more gates failed (blocked)

## Integration

These scripts are designed to be run:
- Manually by developers before/after refactoring
- In CI/CD pipeline (see `.github/workflows/quality-gates.yml`)
- As git hooks (pre-commit, pre-push)

## Configuration Risk Alert

**CRITICAL:** 722 uncommitted files detected in current project state.

This represents the #1 configuration vulnerability. The pre-refactor script will FAIL until this is resolved.

**Required action:**
```bash
# Review uncommitted changes
git status

# Commit work in progress
git add .
git commit -m "Pre-refactor snapshot: $(date +%Y%m%d)"

# Verify clean state
git status  # Should show "working tree clean"
```

## Common Failures

### "Uncommitted files detected"
**Cause:** Changes not committed to git  
**Fix:** Commit or stash all changes before refactoring  
**Why:** Impossible to rollback without clean baseline

### "Tests failing"
**Cause:** Existing tests broken before refactoring started  
**Fix:** Fix failing tests first, establish clean baseline  
**Why:** Cannot distinguish new failures from pre-existing issues

### "Analyzer warnings"
**Cause:** Code quality issues in codebase  
**Fix:** Run `flutter analyze` and fix warnings  
**Why:** Refactoring may introduce more warnings, hiding new issues

### "Test coverage below 80%"
**Cause:** Insufficient test coverage after migration  
**Fix:** Add tests for newly consolidated code  
**Why:** Quality gates require ≥80% coverage to prevent regressions

## Magic Number Validation

When reviewing configuration changes, ask:

1. **Justification:** Why this specific value?
2. **Load Testing:** Tested under production-like load?
3. **Boundaries:** What happens at limits?
4. **Monitoring:** How detect problems?
5. **Rollback:** How quickly revert?

## Support

Questions? See `QUALITY_GATES_REPORT.html` for comprehensive documentation.

---

**Remember:** These gates exist to prevent outages. Do not bypass them.
