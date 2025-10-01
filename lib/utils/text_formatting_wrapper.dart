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

/// A wrapper class for formatting job-related text data consistently.
///
/// This class provides a centralized place to format job data, ensuring that
/// all job-related text is displayed in a consistent format (Title Case)
/// throughout the app.
class JobDataFormatter {
  /// Formats the job classification to Title Case.
  ///
  /// Use this method to format job classifications before displaying them.
  /// Returns 'N/A' if the input is null or empty.
  static String formatClassification(String? classification) {
    if (classification == null || classification.isEmpty) {
      return 'N/A';
    }
    return toTitleCase(classification);
  }

  /// Formats the company name to Title Case.
  ///
  /// Use this method to format company names before displaying them.
  /// Returns 'N/A' if the input is null or empty.
  static String formatCompany(String? company) {
    if (company == null || company.isEmpty) {
      return 'N/A';
    }
    return toTitleCase(company);
  }

  /// Formats the job location to Title Case.
  ///
  /// Use this method to format job locations before displaying them.
  /// Returns 'N/A' if the input is null or empty.
  static String formatLocation(String? location) {
    if (location == null || location.isEmpty) {
      return 'N/A';
    }
    return toTitleCase(location);
  }

  /// Formats the type of work to Title Case.
  ///
  /// Use this method to format the type of work before displaying it.
  /// Returns 'N/A' if the input is null or empty.
  static String formatTypeOfWork(String? typeOfWork) {
    if (typeOfWork == null || typeOfWork.isEmpty) {
      return 'N/A';
    }
    return toTitleCase(typeOfWork);
  }

  /// A generic formatter for any job-related field to Title Case.
  ///
  /// Use this method for any other job-related text field that needs to be
  /// formatted to Title Case. Returns an empty string if the input is null or empty.
  static String formatAnyJobField(String? field) {
    if (field == null || field.isEmpty) {
      return '';
    }
    return toTitleCase(field);
  }
}