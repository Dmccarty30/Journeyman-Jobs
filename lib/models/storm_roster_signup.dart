
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

  /// Factory constructor to create RosterContractor from Firestore data
  factory RosterContractor.fromMap(Map<String, dynamic> data) {
    return RosterContractor(
      companyName: data['companyName'] ?? '',
      onlineForm: data['onlineForm'] ?? '',
      website: data['website'] ?? '',
      signUpInfo: _parseSignUpInfoFromMap(data['signUpInfo'] as Map<String, dynamic>? ?? {}),
    );
  }

  /// Convert RosterContractor to Map for Firestore storage
  Map<String, dynamic> toMap() {
    return {
      'companyName': companyName,
      'onlineForm': onlineForm,
      'website': website,
      'signUpInfo': _signUpInfoToMap(signUpInfo),
    };
  }

  /// Parse SignUpInfo from Map data
  static SignUpInfo _parseSignUpInfoFromMap(Map<String, dynamic> data) {
    final type = data['type'] ?? 'unknown';

    switch (type) {
      case 'url':
        return UrlSignUp(url: data['url'] ?? '');
      case 'text':
        return TextSignUp(
          phoneNumber: data['phoneNumber'] ?? '',
          message: data['message'] ?? '',
        );
      case 'phone':
        return PhoneSignUp(phoneNumber: data['phoneNumber'] ?? '');
      case 'email':
        return EmailSignUp(email: data['email'] ?? '');
      case 'mixed':
        return MixedSignUp(
          text: data['text'] ?? '',
          url: data['url'],
        );
      default:
        return UnknownSignUp(details: data['details'] ?? 'No specific sign-up instructions found.');
    }
  }

  /// Convert SignUpInfo to Map for storage
  static Map<String, dynamic> _signUpInfoToMap(SignUpInfo signUpInfo) {
    if (signUpInfo is UrlSignUp) {
      return {'type': 'url', 'url': signUpInfo.url};
    } else if (signUpInfo is TextSignUp) {
      return {
        'type': 'text',
        'phoneNumber': signUpInfo.phoneNumber,
        'message': signUpInfo.message,
      };
    } else if (signUpInfo is PhoneSignUp) {
      return {'type': 'phone', 'phoneNumber': signUpInfo.phoneNumber};
    } else if (signUpInfo is EmailSignUp) {
      return {'type': 'email', 'email': signUpInfo.email};
    } else if (signUpInfo is MixedSignUp) {
      return {
        'type': 'mixed',
        'text': signUpInfo.text,
        'url': signUpInfo.url,
      };
    } else if (signUpInfo is UnknownSignUp) {
      return {'type': 'unknown', 'details': signUpInfo.details};
    }
    return {'type': 'unknown', 'details': 'Unknown sign-up type'};
  }
}
