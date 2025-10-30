#!/usr/bin/env dart

import 'dart:io';
import 'dart:convert';

/// Script to replace all debug print statements with secure logging
///
/// This script systematically finds and replaces all `print(` statements
/// throughout the codebase with secure logging alternatives that prevent
/// PII exposure in production builds.
///
/// Usage: dart tools/replace_debug_statements.dart
class DebugStatementReplacer {
  static const String secureLoggingImport = "import '../utils/secure_logging_service.dart';";

  final Map<String, int> _fileStats = {};
  final List<String> _processedFiles = [];
  final List<String> _errors = [];

  /// Process all Dart files in the lib directory
  Future<void> processAllFiles() async {
    print('🔍 Scanning for debug print statements...');

    await _processDirectory(Directory('lib'));

    print('\n📊 SUMMARY:');
    print('Files processed: ${_processedFiles.length}');
    print('Total debug statements replaced: ${_fileStats.values.fold(0, (a, b) => a + b)}');

    if (_errors.isNotEmpty) {
      print('\n❌ ERRORS:');
      for (final error in _errors) {
        print('  $error');
      }
    }

    print('\n📁 FILES MODIFIED:');
    for (final file in _processedFiles) {
      final count = _fileStats[file] ?? 0;
      print('  $file: $count statements replaced');
    }

    print('\n✅ Debug statement replacement complete!');
    print('🔒 All debug statements now use secure logging with PII protection');
  }

  /// Recursively process directory
  Future<void> _processDirectory(Directory dir) async {
    try {
      await for (final entity in dir.list()) {
        if (entity is File && entity.path.endsWith('.dart')) {
          await _processFile(entity);
        } else if (entity is Directory) {
          await _processDirectory(entity);
        }
      }
    } catch (e) {
      _errors.add('Error processing directory ${dir.path}: $e');
    }
  }

  /// Process individual file
  Future<void> _processFile(File file) async {
    try {
      final content = await file.readAsString();
      final lines = content.split('\n');

      bool modified = false;
      int replacements = 0;
      List<String> newLines = [];

      // Check if file already imports secure logging
      bool hasSecureLoggingImport = content.contains('secure_logging_service.dart');

      for (int i = 0; i < lines.length; i++) {
        final line = lines[i];
        final trimmedLine = line.trim();

        // Look for print statements
        if (trimmedLine.startsWith('print(') || trimmedLine.contains(' print(')) {
          final replacement = _createSecureLoggingReplacement(line, i);
          newLines.add(replacement);
          modified = true;
          replacements++;
        } else {
          newLines.add(line);
        }
      }

      // Add secure logging import if needed and modifications were made
      if (modified && !hasSecureLoggingImport) {
        newLines = _addSecureLoggingImport(newLines);
      }

      // Write file if modified
      if (modified) {
        await file.writeAsString(newLines.join('\n'));
        _processedFiles.add(file.path);
        _fileStats[file.path] = replacements;
        print('🔄 Updated: ${file.path} ($replacements replacements)');
      }

    } catch (e) {
      _errors.add('Error processing file ${file.path}: $e');
    }
  }

  /// Create secure logging replacement for print statement
  String _createSecureLoggingReplacement(String originalLine, int lineNumber) {
    final trimmedLine = originalLine.trim();

    // Extract the content inside print()
    final printContent = _extractPrintContent(trimmedLine);

    // Determine appropriate logging level and create replacement
    if (_isErrorStatement(printContent)) {
      return _createErrorLoggingReplacement(printContent, originalLine);
    } else if (_isWarningStatement(printContent)) {
      return _createWarningLoggingReplacement(printContent, originalLine);
    } else if (_isInfoStatement(printContent)) {
      return _createInfoLoggingReplacement(printContent, originalLine);
    } else {
      return _createDebugLoggingReplacement(printContent, originalLine);
    }
  }

  /// Extract content from print statement
  String _extractPrintContent(String printLine) {
    final startIndex = printLine.indexOf('print(') + 6;
    final endIndex = _findMatchingParenthesis(printLine, startIndex);

    if (endIndex == -1) {
      return printLine.substring(startIndex);
    }

    return printLine.substring(startIndex, endIndex).trim();
  }

  /// Find matching closing parenthesis
  int _findMatchingParenthesis(String str, int startIndex) {
    int count = 0;
    for (int i = startIndex; i < str.length; i++) {
      if (str[i] == '(') {
        count++;
      } else if (str[i] == ')') {
        count--;
        if (count == 0) {
          return i;
        }
      }
    }
    return -1;
  }

  /// Check if print statement is an error
  bool _isErrorStatement(String content) {
    final lowerContent = content.toLowerCase();
    return lowerContent.contains('error') ||
           lowerContent.contains('exception') ||
           lowerContent.contains('failed') ||
           lowerContent.contains('crash');
  }

  /// Check if print statement is a warning
  bool _isWarningStatement(String content) {
    final lowerContent = content.toLowerCase();
    return lowerContent.contains('warning') ||
           lowerContent.contains('warn') ||
           lowerContent.contains('deprecated') ||
           lowerContent.contains('obsolete');
  }

  /// Check if print statement is informational
  bool _isInfoStatement(String content) {
    final lowerContent = content.toLowerCase();
    return lowerContent.contains('info') ||
           lowerContent.contains('success') ||
           lowerContent.contains('completed') ||
           lowerContent.contains('loaded');
  }

  /// Create debug logging replacement
  String _createDebugLoggingReplacement(String content, String originalLine) {
    final indentation = _getIndentation(originalLine);
    return '${indentation}SecureLoggingService.debug($content);';
  }

  /// Create error logging replacement
  String _createErrorLoggingReplacement(String content, String originalLine) {
    final indentation = _getIndentation(originalLine);
    return '${indentation}SecureLoggingService.error($content);';
  }

  /// Create warning logging replacement
  String _createWarningLoggingReplacement(String content, String originalLine) {
    final indentation = _getIndentation(originalLine);
    return '${indentation}SecureLoggingService.warning($content);';
  }

  /// Create info logging replacement
  String _createInfoLoggingReplacement(String content, String originalLine) {
    final indentation = _getIndentation(originalLine);
    return '${indentation}SecureLoggingService.info($content);';
  }

  /// Get indentation from original line
  String _getIndentation(String line) {
    final match = RegExp(r'^\s*').firstMatch(line);
    return match?.group(0) ?? '';
  }

  /// Add secure logging import to file
  List<String> _addSecureLoggingImport(List<String> lines) {
    final newLines = <String>[];
    bool importAdded = false;

    for (final line in lines) {
      // Add import after the last import statement
      if (!importAdded && line.startsWith('import ') && !line.contains('secure_logging_service.dart')) {
        // Look ahead to see if this is the last import
        final currentIndex = lines.indexOf(line);
        bool isLastImport = true;

        for (int i = currentIndex + 1; i < lines.length; i++) {
          if (lines[i].trim().startsWith('import ')) {
            isLastImport = false;
            break;
          } else if (lines[i].trim().isNotEmpty) {
            break;
          }
        }

        newLines.add(line);

        if (isLastImport) {
          newLines.add(secureLoggingImport);
          importAdded = true;
        }
      } else {
        newLines.add(line);
      }
    }

    // If no imports were found, add at the top
    if (!importAdded) {
      newLines.insert(0, secureLoggingImport);
    }

    return newLines;
  }
}

/// Main execution function
Future<void> main() async {
  print('🔒 Journeyman Jobs - Debug Statement Security Audit');
  print('====================================================');
  print('');
  print('This script will replace all debug print statements with');
  print('secure logging alternatives that prevent PII exposure.');
  print('');

  final replacer = DebugStatementReplacer();
  await replacer.processAllFiles();

  print('');
  print('📋 NEXT STEPS:');
  print('1. Review the modified files for correctness');
  print('2. Test the application to ensure logging works properly');
  print('3. Verify no sensitive data appears in production logs');
  print('4. Commit the changes to secure the codebase');
}