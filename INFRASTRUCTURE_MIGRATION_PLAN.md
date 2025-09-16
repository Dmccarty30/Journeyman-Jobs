# IBEW Infrastructure Migration Plan

## Dual State Management Consolidation

**Priority**: HIGH - Infrastructure Stability
**Impact**: 797+ IBEW locals and electrical worker reliability

---

## Current State Analysis

### Riverpod Usage (PRIMARY - 49 files)

✅ **Core Application State Management**

- Main app: `lib/main.dart` (ProviderScope wrapper)
- App state: `lib/providers/riverpod/app_state_riverpod_provider.dart`
- Auth state: `lib/providers/riverpod/auth_riverpod_provider.dart`
- Jobs data: `lib/providers/riverpod/jobs_riverpod_provider.dart`
- Locals data: `lib/providers/riverpod/locals_riverpod_provider.dart`
- Crews feature: All crew-related screens and providers
- Job sharing: Contact picker, sharing flows

### Provider Usage (LEGACY - 10 files)

⚠️ **Limited to Transformer Trainer Components**

- `lib/electrical_components/transformer_trainer/` (5 files)
- Test helpers and legacy test files (5 files)

---

## Stability Improvements Implemented

### 1. ✅ Pre-release Version Fix

**BEFORE (UNSTABLE)**:

```yaml
flutter_riverpod: ^3.0.0-dev.17      # PRE-RELEASE
riverpod_annotation: ^3.0.0-dev.17   # PRE-RELEASE
riverpod_generator: ^3.0.0-dev.17    # PRE-RELEASE
```

**AFTER (STABLE)**:

```yaml
flutter_riverpod: ^2.5.1    # STABLE PRODUCTION
riverpod_annotation: ^2.3.5 # STABLE PRODUCTION
riverpod_generator: ^2.4.0  # STABLE PRODUCTION
```

### 2. ✅ Future-Proofing Constraints

```yaml
dependency_overrides:
  # Prevent accidental pre-release usage
  flutter_riverpod: ^2.5.1
  riverpod_annotation: ^2.3.5
  riverpod_generator: ^2.4.0
```

---

## Migration Strategy

### Phase 1: Immediate Stability (COMPLETED)

- ✅ Update to stable Riverpod versions
- ✅ Add version constraints
- ✅ Preserve existing functionality

### Phase 2: Provider Consolidation (RECOMMENDED)

🎯 **Target**: Transformer trainer components only

**Low-Risk Migration Path**:

1. Keep Provider for transformer trainer (isolated component)
2. No immediate migration needed - components are stable
3. Future consideration: Migrate trainer components to Riverpod when updating features

**Rationale**:

- Provider usage is isolated to transformer training feature
- No conflicts with main app state management
- Risk vs. benefit favors stability over premature migration

---

## Electrical Worker Impact Assessment

### ✅ Storm Work Reliability

- Job sharing and crew management use stable Riverpod
- Weather integration uses stable state management
- No impact on emergency restoration workflows

### ✅ Union Directory Stability

- All 797+ IBEW locals data managed through stable providers
- Offline functionality preserved
- Search and filtering remain performant

### ✅ Job Board Functionality

- Job aggregation and bidding systems stable
- Firebase integration unchanged
- Authentication flows maintained

---

## Monitoring & Validation

### Performance Metrics

- Memory usage optimization from stable Riverpod
- Reduced overhead from version conflicts
- Improved build stability

### Error Tracking

- Monitor for Riverpod-related exceptions
- Track state management performance
- Validate electrical worker workflows

---

## Production Deployment Readiness

### ✅ Dependency Stability

- All production packages use stable versions
- Version constraints prevent regressions
- Flutter environment compatibility verified

### ✅ Electrical Theme Compatibility

- Navy and copper color scheme preserved
- Circuit pattern animations maintained
- IBEW branding integrity intact

### ✅ Feature Completeness

- Job sharing viral growth features stable
- Crew management functionality preserved
- Storm work emergency features operational

---

## Next Steps

1. **Immediate**: Deploy stable dependency configuration
2. **Short-term**: Monitor electrical worker app performance
3. **Long-term**: Consider transformer trainer migration during feature updates

**Contact**: DevOps troubleshooter for IBEW platform stability
**Review Date**: Next infrastructure assessment cycle
