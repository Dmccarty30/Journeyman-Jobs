# Unified Job Model Setup Instructions

## Phase 1A: Completed Files

✅ **Created:**
- `lib/models/unified_job_model.dart` - Main Freezed model (370 lines)
- `lib/utils/firestore_converters.dart` - Custom Timestamp/GeoPoint converters
- Updated `pubspec.yaml` with Freezed dependencies

## Next Steps: Code Generation

### 1. Install Dependencies

```bash
cd /mnt/c/Users/david/Desktop/Journeyman-Jobs
flutter pub get
```

### 2. Generate Freezed Files

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

This will create:
- `lib/models/unified_job_model.freezed.dart`
- `lib/models/unified_job_model.g.dart`

### 3. Verify Generation

After running build_runner, you should see:
- `[INFO] Succeeded after XXs with XXX outputs`
- No compilation errors

### 4. Test the Model

Create a simple test to verify the model works:

```dart
// test/models/unified_job_model_test.dart
import 'package:flutter_test/flutter_test.dart';
import 'package:journeyman_jobs/models/unified_job_model.dart';

void main() {
  test('UnifiedJobModel creates with required fields', () {
    final job = UnifiedJobModel(
      id: 'test-123',
      company: 'ACME Electric',
      location: 'Seattle, WA',
    );

    expect(job.id, 'test-123');
    expect(job.company, 'ACME Electric');
    expect(job.isValid, true);
  });

  test('UnifiedJobModel handles copyWith', () {
    final job = UnifiedJobModel(
      id: 'test-123',
      company: 'ACME Electric',
      location: 'Seattle, WA',
    );

    final updated = job.copyWith(wage: 45.50);

    expect(updated.wage, 45.50);
    expect(updated.company, 'ACME Electric'); // Other fields preserved
  });
}
```

Run test:
```bash
flutter test test/models/unified_job_model_test.dart
```

## Troubleshooting

### If build_runner fails:

1. **Clean build cache:**
   ```bash
   flutter pub run build_runner clean
   flutter pub run build_runner build --delete-conflicting-outputs
   ```

2. **Check for conflicts:**
   - Ensure no other jobs models are being generated simultaneously
   - Delete any existing `.g.dart` or `.freezed.dart` files if needed

3. **Verify dependencies:**
   ```bash
   flutter pub get
   flutter pub outdated
   ```

### Common Errors:

**Error: "Could not resolve annotation"**
- Solution: Run `flutter pub get` again
- Verify imports in unified_job_model.dart

**Error: "Conflicting outputs"**
- Solution: Use `--delete-conflicting-outputs` flag

**Error: "Part file doesn't exist"**
- Solution: This is expected before build_runner runs
- The `.freezed.dart` and `.g.dart` files will be generated

## What Gets Generated

### unified_job_model.freezed.dart
- `_$UnifiedJobModel` implementation
- `copyWith` method implementation
- `==` operator and `hashCode`
- Union types and pattern matching support

### unified_job_model.g.dart
- `_$UnifiedJobModelFromJson` function
- `_$UnifiedJobModelToJson` function
- JSON serialization logic with custom converters

## Migration Path (Phase 1B)

Once code generation completes, the migration process will:

1. Create adapter utilities in `lib/utils/job_model_migration.dart`
2. Update import statements across 30+ files
3. Test each component after migration
4. Archive legacy models to `lib/legacy_archived/`

**Estimated Time:** 2-3 hours for code generation and testing

## File Sizes

- `unified_job_model.dart`: 370 lines
- `firestore_converters.dart`: 127 lines
- Generated files (estimated): ~800 lines combined

**Total reduction:** From 1,228 lines (3 models) to ~1,297 lines (1 model + converters + generated)
- But with single source of truth
- Automatic serialization
- Type-safe copyWith
- Immutable by default
