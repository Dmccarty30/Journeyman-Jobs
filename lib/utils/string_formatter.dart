/// Converts any string to Title Case, handling various separators
String toTitleCase(String? text) {
  if (text == null || text.isEmpty) return '';

  // Replace common separators with spaces
  String normalized = text
      .replaceAll('_', ' ')
      .replaceAll('-', ' ')
      .replaceAll(RegExp(r'\s+'), ' ')
      .trim();

  // Convert to title case
  return normalized.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

/// Specific formatter for job classifications
String formatClassification(String? classification) {
  if (classification == null || classification.isEmpty) return 'N/A';
  return toTitleCase(classification);
}

/// Specific formatter for company names
String formatCompanyName(String? company) {
  if (company == null || company.isEmpty) return 'N/A';
  return toTitleCase(company);
}

/// Specific formatter for location names
String formatLocation(String? location) {
  if (location == null || location.isEmpty) return 'N/A';
  return toTitleCase(location);
}

/// Formats phone numbers for display
String formatPhoneNumber(String? phone) {
  if (phone == null || phone.isEmpty) return 'N/A';
  // Remove all non-digit characters
  String digits = phone.replaceAll(RegExp(r'\D'), '');

  // Format as (XXX) XXX-XXXX if 10 digits
  if (digits.length == 10) {
    return '(${digits.substring(0, 3)}) ${digits.substring(3, 6)}-${digits.substring(6)}';
  }

  // Return original if not 10 digits
  return phone;
}

/// Formats currency values
String formatCurrency(double? amount, {String symbol = '\$'}) {
  if (amount == null) return 'N/A';
  return '$symbol${amount.toStringAsFixed(2)}';
}

/// Formats hourly wage
String formatWage(double? wage) {
  if (wage == null) return 'N/A';
  return '\$${wage.toStringAsFixed(2)}/hr';
}
