import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:io';
import 'journal_entry.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'add_memory_screen.dart';
import 'dart:convert';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'journal_detail_screen.dart';

class MemoryScreen extends StatefulWidget {
  const MemoryScreen({Key? key}) : super(key: key);

  @override
  _MemoryScreenState createState() => _MemoryScreenState();
}

class _MemoryScreenState extends State<MemoryScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<JournalEntry> favoriteEntries = [];
  List<JournalEntry> memories = [];
  String searchQuery = '';

  @override
  void initState() {
    super.initState();
    _loadEntries();
  }

  Future<void> _loadEntries() async {
    final prefs = await SharedPreferences.getInstance();
    final savedMemories = prefs.getStringList('memories') ?? [];

    final allKeys = await secureStorage.readAll();
    List<JournalEntry> allEntries = allKeys.entries.map((e) {
      final values = e.value.split('|');

      String title = values.isNotEmpty ? values[0] : '';
      String content = values.length > 1 ? values[1] : '';
      String imagePath = values.length > 2 ? values[2] : '';
      bool isFavorite = values.length > 3 ? values[3] == 'true' : false;
      String mood = values.length > 4 ? values[4] : '';
      List<String> tags = values.length > 5 ? values[5].split(',') : [];

      DateTime date;
      try {
        date = DateTime.parse(e.key);
      } catch (e) {
        date = DateTime.now(); // Fallback if parsing fails
      }

      return JournalEntry(
        title: title,
        content: content,
        imagePath: imagePath,
        isFavorite: isFavorite,
        mood: mood,
        tags: tags,
        date: date,
      );
    }).toList();

    List<JournalEntry> favoriteJournals = allEntries.where((entry) => entry.isFavorite).toList();

    setState(() {
      memories = savedMemories.map((e) => JournalEntry.fromMap(jsonDecode(e))).toList();
      favoriteEntries = favoriteJournals;
    });
  }


  Future<void> _saveEntries() async {
    final prefs = await SharedPreferences.getInstance();
    prefs.setStringList(
      'memories',
      memories.map((e) => jsonEncode(e.toMap())).toList(),
    );
  }

  void _navigateToAddMemoryScreen() async {
    final newMemory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMemoryScreen()),
    );

    if (newMemory != null) {
      setState(() {
        memories.add(
          JournalEntry(
            title: newMemory['title'] ?? 'Untitled Memory',
            content: newMemory['content'] ?? '',
            date: newMemory['date'] ?? DateTime.now(),
            imagePath: newMemory['imagePath'] ?? '',
            isFavorite: newMemory['isFavorite'] ?? false,
            mood: newMemory['mood'] ?? '',
            tags: newMemory['tags'] ?? [],
          ),
        );
      });

      _saveEntries();
    }
  }

  void _deleteMemory(JournalEntry entry) async {
    setState(() {
      memories.remove(entry);
      favoriteEntries.remove(entry);
    });

    await _saveEntries();
  }

  void _confirmDelete(JournalEntry entry) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Memory"),
          content: Text("Are you sure you want to delete this memory?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteMemory(entry);
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  void _updateSearchQuery(String query) {
    setState(() {
      searchQuery = query.toLowerCase();
    });
  }

  void _showFullImage(BuildContext context, String imagePath) {
    if (imagePath.isEmpty) return;

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.black,
          child: Stack(
            children: [
              Positioned.fill(
                child: Image.file(
                  File(imagePath),
                  fit: BoxFit.contain,
                  errorBuilder: (context, error, stackTrace) =>
                      Center(child: Icon(Icons.broken_image, size: 100, color: Colors.grey)),
                ),
              ),
              Positioned(
                top: 10,
                right: 10,
                child: IconButton(
                  icon: Icon(Icons.close, color: Colors.white, size: 30),
                  onPressed: () => Navigator.pop(context),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
  void _deleteImage(List<JournalEntry> entries, int index) async {
    setState(() {
      entries[index].imagePath = ""; // Remove image path from the entry
    });

    await _saveEntries(); // Save updated entries
  }
  void _confirmDeleteImage(List<JournalEntry> entries, int index) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text("Delete Image"),
          content: Text("Are you sure you want to delete this image?"),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text("Cancel"),
            ),
            TextButton(
              onPressed: () {
                _deleteImage(entries, index);
                Navigator.pop(context);
              },
              child: Text("Delete", style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }

  List<JournalEntry> getFilteredMemories() {
    return memories.where((entry) {
      return entry.title.toLowerCase().contains(searchQuery) ||
          entry.content.toLowerCase().contains(searchQuery) ||
          entry.tags.any((tag) => tag.toLowerCase().contains(searchQuery));
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Memories ❤️')),
      floatingActionButton: FloatingActionButton(
        onPressed: _navigateToAddMemoryScreen,
        child: Icon(Icons.add),
        backgroundColor: Colors.pinkAccent,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              onChanged: _updateSearchQuery,
              decoration: InputDecoration(
                prefixIcon: Icon(Icons.search),
                hintText: "Search memories...",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSectionTitle("Photo Gallery", Icons.image),
                  _buildImageGrid(getFilteredMemories()),
                  _buildSectionTitle("Favorite Journals", Icons.favorite),
                  _buildFavoriteJournals(favoriteEntries),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title, IconData icon) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Icon(icon, color: Colors.pink, size: 24),
          SizedBox(width: 8),
          Text(
            title,
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.pinkAccent),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoriteJournals(List<JournalEntry> favoriteEntries) {
    if (favoriteEntries.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No favorite journals!", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return Column(
      children: favoriteEntries.map((entry) {
        return Card(
          margin: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          elevation: 4,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          child: ListTile(
            leading: Icon(Icons.favorite, color: Colors.pinkAccent),
            title: Text(
              entry.title,
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink.shade800),
            ),
            subtitle: Text(DateFormat('MMM dd, yyyy • hh:mm a').format(entry.date)),
            trailing: IconButton(
              icon: Icon(Icons.delete, color: Colors.red),
              onPressed: () => _confirmDelete(entry),
            ),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => JournalDetailScreen(entry: entry)),
              );
            },
          ),
        );
      }).toList(),
    );
  }

  Widget _buildImageGrid(List<JournalEntry> entries) {
    List<String> images = entries
        .map((e) => e.imagePath)
        .whereType<String>() // Ensures only non-null values are in the list
        .where((path) => path.isNotEmpty) // Removes empty image paths
        .toList();

    if (images.isEmpty) {
      return Center(
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Text("No images yet!", style: TextStyle(fontSize: 16, color: Colors.grey)),
        ),
      );
    }

    return GridView.builder(
      shrinkWrap: true,
      physics: NeverScrollableScrollPhysics(),
      itemCount: images.length,
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 3),
      itemBuilder: (context, index) {
        return Stack(
          children: [
            Positioned.fill(
              child: GestureDetector(
                onTap: () => _showFullImage(context, images[index]),
                child: Image.file(File(images[index]), fit: BoxFit.cover),
              ),
            ),
            Positioned(
              top: 5,
              right: 5,
              child: IconButton(
                icon: Icon(Icons.delete, color: Colors.red, size: 24),
                onPressed: () => _confirmDeleteImage(entries, index), // Delete function
              ),
            ),
          ],
        );
      },
    );
  }

}
