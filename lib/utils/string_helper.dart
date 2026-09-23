class StringHelper {
  StringHelper._();

  static String titleCase(String? value) {
    if (value == null || value.trim().isEmpty) {
      return '-';
    }

    return value
        .trim()
        .split(RegExp(r'\s+'))
        .map((word) {
          if (word.isEmpty) return '';

          final lower = word.toLowerCase();

          return '${lower[0].toUpperCase()}${lower.substring(1)}';
        })
        .join(' ');
  }
}