import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';

// Copy of the problematic code for testing
sealed class SignUpInfo {
  const SignUpInfo();
}

class TextSignUp extends SignUpInfo {
  final String phoneNumber;
  final String message;
  const TextSignUp({required this.phoneNumber, required this.message});
}

class RosterContractor {
  // Helper to parse sign-up information
  static SignUpInfo _parseSignUpInfo(String onlineForm, String website) {
    // Check onlineForm for phone numbers and text instructions
    if (onlineForm.isNotEmpty) {
      // Regex to find phone numbers (basic pattern)
      final phoneMatch = RegExp(r'(\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})').firstMatch(onlineForm);
      if (phoneMatch != null) {
        final phoneNumber = phoneMatch.group(1)!;
        // Extract message if present
        final messageMatch = RegExp(r'Text ["\';;;]?([^"']+)["\']? to').firstMatch(onlineForm);
        return TextSignUp(phoneNumber: phoneNumber, message: messageMatch.group(1)!); // BUG HERE!
      }
    }
    return const TextSignUp(phoneNumber: 'unknown', message: 'unknown');
  }
}

void main() {
  // Test case 1: Phone number with message (should work)
  print('Test 1: Phone with message');
  try {
    final result1 = RosterContractor._parseSignUpInfo('Text "Hello World" to 555-123-4567', '');
    print('SUCCESS: $result1');
  } catch (e) {
    print('ERROR: $e');
  }

  // Test case 2: Phone number without message (will crash)
  print('\nTest 2: Phone without message');
  try {
    final result2 = RosterContractor._parseSignUpInfo('Call 555-123-4567 for signup', '');
    print('SUCCESS: $result2');
  } catch (e) {
    print('ERROR: $e');
  }

  // Test case 3: Suspicious regex with ;;; 
  print('\nTest 3: Testing suspicious regex');
  final regex = RegExp(r'Text ["\';;;]?([^"']+)["\']? to');
  final testString = 'Text "Hello World" to 555-123-4567';
  final match = regex.firstMatch(testString);
  print('Regex match: $match');
  if (match != null) {
    print('Group 1: ${match.group(1)}');
  }
}