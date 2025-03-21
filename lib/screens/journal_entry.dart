class JournalEntry {
  String title;
  String content;
  DateTime date;
  String? imagePath; // Nullable image path
  bool isFavorite;
  String mood; // ✅ New mood field
  List<String> tags; // ✅ New tags field

  JournalEntry({
    required this.title,
    required this.content,
    required this.date,
    this.imagePath, // Optional
    this.isFavorite = false,
    this.mood = '', // Default to empty
    this.tags = const [], // Default empty list
  });

  // Convert JournalEntry to a map (for storage)
  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'content': content,
      'date': date.toIso8601String(),
      'imagePath': imagePath ?? '', // Ensure no null errors in SharedPreferences
      'isFavorite': isFavorite,
      'mood': mood, // ✅ Save mood
      'tags': tags, // ✅ Save tags
    };
  }

  // Convert map to JournalEntry (for retrieval)
  static JournalEntry fromMap(Map<String, dynamic> map) {
    return JournalEntry(
      title: map['title'] ?? 'Untitled', // Default title if missing
      content: map['content'] ?? '', // Default content if missing
      date: DateTime.tryParse(map['date'] ?? '') ?? DateTime.now(), // Prevent parsing errors
      imagePath: map['imagePath']?.isNotEmpty == true ? map['imagePath'] : null, // Handle empty string as null
      isFavorite: map['isFavorite'] ?? false,
      mood: map['mood'] ?? '', // ✅ Load mood
      tags: List<String>.from(map['tags'] ?? []), // ✅ Load tags safely
    );
  }
}
