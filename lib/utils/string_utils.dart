/// Utility functions for string manipulation and normalization
class StringUtils {
  /// Normalizes job titles and classifications by:
  /// - Removing hyphens, dashes, and underscores
  /// - Splitting into words
  /// - Capitalizing the first letter of each word
  /// - Joining with spaces
  ///
  /// Examples:
  /// - "journeyman-lineman" -> "Journeyman Lineman"
  /// - "JOURNEYMAN_LINEMAN" -> "Journeyman Lineman"
  /// - "journeyman lineman" -> "Journeyman Lineman"
  static String normalizeJobTitle(String? input) {
    if (input == null || input.trim().isEmpty) {
      return '';
    }

    // Remove hyphens, dashes, and underscores, then split by spaces
    final cleaned = input
        .replaceAll('-', ' ')
        .replaceAll('_', ' ')
        .replaceAll('/', ' ')
        .split(' ')
        .where((word) => word.isNotEmpty) // Remove empty strings from multiple spaces
        .map((word) {
          // Handle acronyms and special cases
          if (word.length <= 4 && word.length >= 2 && _isLikelyAcronym(word)) {
            // Convert likely acronyms to uppercase (like "cdl" -> "CDL", "cpr" -> "CPR")
            return word.toUpperCase();
          } else {
            // Capitalize first letter, lowercase rest
            return word[0].toUpperCase() + word.substring(1).toLowerCase();
          }
        })
        .join(' ');

    return cleaned;
  }

  /// Checks if a string needs normalization
  static bool needsNormalization(String? input) {
    if (input == null || input.isEmpty) return false;

    // Check for hyphens, underscores, or inconsistent capitalization
    return input.contains('-') ||
           input.contains('_') ||
           input.contains('/') ||
           _hasInconsistentCapitalization(input);
  }

  /// Checks if a string has inconsistent capitalization
  static bool _hasInconsistentCapitalization(String input) {
    final words = input.split(' ');
    if (words.length <= 1) return false;

    // Check if some words are all caps and others aren't
    bool hasAllCaps = false;
    bool hasTitleCase = false;

    for (final word in words) {
      if (word.toUpperCase() == word && word.isNotEmpty) {
        hasAllCaps = true;
      } else if (word.isNotEmpty &&
                 word[0] == word[0].toUpperCase() &&
                 word.substring(1) == word.substring(1).toLowerCase()) {
        hasTitleCase = true;
      }
    }

    return hasAllCaps && hasTitleCase;
  }

  /// Checks if a word is likely an acronym that should be uppercase
  static bool _isLikelyAcronym(String word) {
    if (word.length < 2 || word.length > 4) return false;

    // Common acronyms in electrical/utility industry
    const commonAcronyms = {'cdl', 'cpr', 'fa', 'osha', 'nec', 'iec', 'nema', 'ieee'};
    if (commonAcronyms.contains(word.toLowerCase())) return true;

    // Check if word consists only of consonants (likely acronym)
    final consonants = RegExp(r'^[bcdfghjklmnpqrstvwxyz]+$');
    return consonants.hasMatch(word.toLowerCase());
  }
}
