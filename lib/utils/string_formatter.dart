
String toTitleCase(String text) {
  if (text.isEmpty) {
    return '';
  }

  return text
      .split(RegExp(r'[\s_-]+'))
      .map((word) {
        if (word.isEmpty) {
          return '';
        }
        return word[0].toUpperCase() + word.substring(1).toLowerCase();
      })
      .join(' ');
}
