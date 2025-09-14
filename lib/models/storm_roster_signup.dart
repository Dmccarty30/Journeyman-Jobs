
// Enum to represent different types of sign-up information
sealed class SignUpInfo {
  const SignUpInfo();
}

class UrlSignUp extends SignUpInfo {
  final String url;
  const UrlSignUp({required this.url});
}

class TextSignUp extends SignUpInfo {
  final String phoneNumber;
  final String message;
  const TextSignUp({required this.phoneNumber, required this.message});
}

class PhoneSignUp extends SignUpInfo {
  final String phoneNumber;
  const PhoneSignUp({required this.phoneNumber});
}

class EmailSignUp extends SignUpInfo {
  final String email;
  const EmailSignUp({required this.email});
}

class MixedSignUp extends SignUpInfo {
  final String text;
  final String? url;
  const MixedSignUp({required this.text, this.url});
}

class UnknownSignUp extends SignUpInfo {
  final String details;
  const UnknownSignUp({required this.details});
}

// Model for a storm contractor
class RosterContractor {
  final String companyName;
  final String onlineForm;
  final String website;
  final SignUpInfo signUpInfo;

  RosterContractor({
    required this.companyName,
    required this.onlineForm,
    required this.website,
    required this.signUpInfo,
  });

  // Factory constructor to parse data from CSV row
  factory RosterContractor.fromCsv(List<String> row) {
    if (row.length != 3) {
      throw FormatException('CSV row must have exactly 3 columns.');
    }

    final companyName = row[0].trim();
    final onlineForm = row[1].trim();
    final website = row[2].trim();

    // Parse the sign-up info based on the onlineForm and website fields
    final signUpInfo = _parseSignUpInfo(onlineForm, website);

    return RosterContractor(
      companyName: companyName,
      onlineForm: onlineForm,
      website: website,
      signUpInfo: signUpInfo,
    );
  }

  // Helper to parse sign-up information
  static SignUpInfo _parseSignUpInfo(String onlineForm, String website) {
    // Prioritize website if it looks like a direct sign-up link
    if (website.isNotEmpty && (website.startsWith('http://') || website.startsWith('https://'))) {
      // Check if website itself contains sign-up keywords
      if (website.toLowerCase().contains('signup') || website.toLowerCase().contains('roster') || website.toLowerCase().contains('join')) {
        return UrlSignUp(url: website);
      }
      // If it's just a general website, we might not consider it a direct sign-up action
      // unless the onlineForm provides more specific instructions.
    }

    // Check onlineForm for phone numbers and text instructions
    if (onlineForm.isNotEmpty) {
      // Regex to find phone numbers (basic pattern)
      final phoneMatch = RegExp(r'(\(?\d{3}\)?[-.\s]?\d{3}[-.\s]?\d{4})').firstMatch(onlineForm);
      if (phoneMatch != null) {
        final phoneNumber = phoneMatch.group(1)!;
        // Extract message if present
        final messageMatch = RegExp(r'Text ["\']?([^"\']+)["\']? to').firstMatch(onlineForm);
        return TextSignUp(phoneNumber: phoneNumber, message: messageMatch.group(1)!);
            }

      // Check for email addresses
      final emailMatch = RegExp(r'[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}').firstMatch(onlineForm);
      if (emailMatch != null) {
        return EmailSignUp(email: emailMatch.group(0)!);
      }

      // Check for mixed instructions (e.g., website link within text)
      if (website.isNotEmpty && onlineForm.contains(website)) {
         return MixedSignUp(text: onlineForm.replaceAll(website, '').trim(), url: website);
      }

      // If it's just text instructions without a clear phone/email/URL
      return MixedSignUp(text: onlineForm);
    }

    // If no specific pattern is found, return UnknownSignUp
    return const UnknownSignUp(details: 'No specific sign-up instructions found.');
  }
}
