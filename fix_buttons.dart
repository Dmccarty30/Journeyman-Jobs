import 'dart:io';

/// Dart script to fix button compilation errors by adding required size parameters
void main() {
  print('🔧 Fixing button compilation errors...\n');

  // File mappings with appropriate button sizes
  final fileFixes = {
    'lib/screens/onboarding/welcome_screen.dart': 'large',
    'lib/screens/auth/forgot_password_screen.dart': 'medium',
    'lib/screens/settings/feedback/feedback_screen.dart': 'medium',
    'lib/screens/tools/electrical_calculators_screen.dart': 'medium',
    'lib/screens/notifications/notifications_screen.dart': 'medium',
    'lib/screens/settings/notification_settings_screen.dart': 'medium',
    'lib/screens/settings/app_settings_screen.dart': 'medium',
    'lib/services/notification_permission_service.dart': 'small',
  };

  int fixedFiles = 0;
  int totalChanges = 0;

  for (final entry in fileFixes.entries) {
    final filePath = entry.key;
    final buttonSize = entry.value;

    try {
      final file = File(filePath);
      if (!file.existsSync()) {
        print('⚠️  File not found: $filePath');
        continue;
      }

      String content = file.readAsStringSync();
      String originalContent = content;

      // Fix JJPrimaryButton instances
      content = content.replaceAllMapped(
        RegExp(r'JJPrimaryButton\s*\('),
        (match) => 'JJPrimaryButton(\n      size: ButtonSize.$buttonSize,',
      );

      // Fix JJSecondaryButton instances
      content = content.replaceAllMapped(
        RegExp(r'JJSecondaryButton\s*\('),
        (match) => 'JJSecondaryButton(\n      size: ButtonSize.$buttonSize,',
      );

      if (content != originalContent) {
        // Create backup
        final backupPath = '$filePath.backup';
        File(backupPath).writeAsStringSync(originalContent);

        // Write fixed content
        file.writeAsStringSync(content);

        final changes = _countChanges(originalContent, content);
        totalChanges += changes;
        fixedFiles++;

        print('✅ Fixed $filePath ($changes changes, backup: $backupPath)');
      } else {
        print('ℹ️  No changes needed in $filePath');
      }
    } catch (e) {
      print('❌ Error fixing $filePath: $e');
    }
  }

  print('\n📊 Summary:');
  print('   Files fixed: $fixedFiles');
  print('   Total changes: $totalChanges');
  print('\n🚀 Next steps:');
  print('   1. Run: flutter pub get');
  print('   2. Run: flutter build');
  print('   3. Run: dart format lib/');
  print('   4. Test the app functionality');
  print('\n💡 If you need to revert changes, use the .backup files created.');
}

int _countChanges(String original, String modified) {
  final originalLines = original.split('\n');
  final modifiedLines = modified.split('\n');

  int changes = 0;
  final maxLength = [originalLines.length, modifiedLines.length].reduce((a, b) => a > b ? a : b);

  for (int i = 0; i < maxLength; i++) {
    final originalLine = i < originalLines.length ? originalLines[i] : '';
    final modifiedLine = i < modifiedLines.length ? modifiedLines[i] : '';

    if (originalLine != modifiedLine) {
      changes++;
    }
  }

  return changes;
}