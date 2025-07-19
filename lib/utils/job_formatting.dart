/// Utility class for formatting job-related data
class JobFormatting {
  /// Formats a job title from database format to display format
  /// Example: "journeyman-lineman" -> "Journeyman Lineman"
  static String formatJobTitle(String? title) {
    if (title == null || title.isEmpty) return '';
    
    // Replace hyphens and underscores with spaces
    String formatted = title.replaceAll('-', ' ').replaceAll('_', ' ');
    
    // Capitalize each word
    formatted = formatted.split(' ').map((word) {
      if (word.isEmpty) return '';
      // Handle special cases
      if (word.toUpperCase() == 'TT') return 'TT';
      if (word.toUpperCase() == 'IBEW') return 'IBEW';
      if (word.toUpperCase() == 'JL') return 'JL';
      if (word.toUpperCase() == 'CDL') return 'CDL';
      
      // Standard capitalization
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
    
    return formatted.trim();
  }
  
  /// Formats a classification string
  /// Example: "10_8_2024" -> "10/8/2024"
  static String formatClassification(String? classification) {
    if (classification == null || classification.isEmpty) return '';
    
    // Check if it's a date format (e.g., "10_8_2024")
    if (RegExp(r'^\d+_\d+_\d+$').hasMatch(classification)) {
      return classification.replaceAll('_', '/');
    }
    
    // Otherwise format as title
    return formatJobTitle(classification);
  }
  
  /// Formats wage for display
  /// Ensures proper formatting with dollar sign and /hr suffix
  static String formatWage(double? wage) {
    if (wage == null) return '';
    return '\$${wage.toStringAsFixed(2)}/hr';
  }
  
  /// Formats hours for display
  /// Handles various hour formats (CDL, fa/cpr, etc.)
  static String formatHours(dynamic hours) {
    if (hours == null) return '';
    
    if (hours is int) {
      return '$hours hrs';
    }
    
    if (hours is String) {
      // If it's already formatted (like "CDL, fa/cpr"), return as is
      if (hours.contains(',') || hours.contains('/')) {
        return hours;
      }
      // Try to parse as number
      final parsed = int.tryParse(hours);
      if (parsed != null) {
        return '$parsed hrs';
      }
      // Return as is if can't parse
      return hours;
    }
    
    return hours.toString();
  }
  
  /// Formats location for display
  /// Ensures proper capitalization
  static String formatLocation(String? location) {
    if (location == null || location.isEmpty) return '';
    
    // Handle "Various" as special case
    if (location.toLowerCase() == 'various') return 'Various';
    
    // Capitalize each word
    return location.split(' ').map((word) {
      if (word.isEmpty) return '';
      // Handle state abbreviations
      if (word.length == 2 && word.toUpperCase() == word) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }
  
  /// Truncates text to a maximum length with ellipsis
  static String truncateText(String text, int maxLength) {
    if (text.length <= maxLength) return text;
    return '${text.substring(0, maxLength - 3)}...';
  }
}