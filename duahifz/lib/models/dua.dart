/// Represents a single Dua with its metadata and text.
class Dua {
  final String id;
  final String title;
  final String arabicText;
  final String translation;
  final List<String> words; // Individual words for sequential matching

  const Dua({
    required this.id,
    required this.title,
    required this.arabicText,
    required this.translation,
    required this.words,
  });

  /// Creates a Dua from full text by splitting into words
  factory Dua.fromText({
    required String id,
    required String title,
    required String arabicText,
    required String translation,
  }) {
    // Split Arabic text into words (simplified - in production, use proper Arabic word segmentation)
    final words = arabicText
        .trim()
        .split(RegExp(r'\s+'))
        .where((w) => w.isNotEmpty)
        .toList();

    return Dua(
      id: id,
      title: title,
      arabicText: arabicText,
      translation: translation,
      words: words,
    );
  }

  /// Creates a Dua from JSON map
  factory Dua.fromJson(Map<String, dynamic> json) {
    return Dua(
      id: json['id'] as String,
      title: json['title'] as String,
      arabicText: json['arabicText'] as String,
      translation: json['translation'] as String,
      words: (json['words'] as List<dynamic>)
          .map((w) => w as String)
          .toList(),
    );
  }

  /// Converts Dua to JSON map
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'arabicText': arabicText,
      'translation': translation,
      'words': words,
    };
  }
}
