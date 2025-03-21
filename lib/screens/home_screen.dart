import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:audioplayers/audioplayers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'settings_screen.dart';
import 'journal_entry.dart';
import 'add_entry_screen.dart';
import 'journal_detail_screen.dart';
import 'edit_entry_screen.dart'; // Import the new edit screen
import 'package:intl/intl.dart';
import 'add_memory_screen.dart'; // Import the Add Memory screen
import 'memory_screen.dart'; // Import MemoryScreen
import 'profile_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final FlutterSecureStorage secureStorage = FlutterSecureStorage();
  List<JournalEntry> entries = [];
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool isPlaying = false;
  bool isSoundEnabled = true;
  String selectedTone = "romantic1.mp3";
  int _selectedIndex = 0;
  bool isDarkMode = false; // ✅ Define dark mode variable


  final List<Map<String, String>> images = [
    {"path": "assets/love1.jpg"},
    {"path": "assets/love2.jpg"},
    {"path": "assets/love3.jpg"},
  ];

  @override
  void initState() {
    super.initState();
    _loadEntries();
    _loadUserPreferences();
  }

  Future<void> _loadUserPreferences() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = prefs.getBool('isSoundEnabled') ?? true;
      selectedTone = prefs.getString('selectedTone') ?? "romantic1.mp3";
      isDarkMode = prefs.getBool('isDarkMode') ?? false; // ✅ Load dark mode
    });
    if (isSoundEnabled) _playBackgroundMusic();
  }

  Future<void> _saveThemePreference(bool isDark) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  void _toggleFavorite(JournalEntry entry) async {
    setState(() {
      entry.isFavorite = !entry.isFavorite; // Toggle favorite status
    });

    // ✅ Save the updated entry back to secure storage
    await secureStorage.write(
      key: entry.date.toIso8601String(),
      value: "${entry.title}|${entry.content}|${entry.imagePath ?? ''}|${entry.isFavorite}",
    );

    _loadEntries(); // Reload to reflect changes
  }


  void _playBackgroundMusic() async {
    if (!isSoundEnabled) return; // Don't play if sound is disabled

    try {
      await _audioPlayer.stop(); // Stop any currently playing music
      await _audioPlayer.setSource(AssetSource("sounds/$selectedTone"));
      await _audioPlayer.setReleaseMode(ReleaseMode.loop);
      await _audioPlayer.resume();
      setState(() => isPlaying = true);
    } catch (e) {
      print("Error playing audio: $e");
    }
  }


  void _stopBackgroundMusic() {
    _audioPlayer.stop();
  }

  void _openSettings() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SettingsScreen(
          isSoundEnabled: isSoundEnabled,
          selectedTone: selectedTone,
          isDarkMode: isDarkMode, // ✅ Pass isDarkMode to SettingsScreen
          onSettingsChanged: (bool soundEnabled, String tone) {
            setState(() {
              isSoundEnabled = soundEnabled;
              selectedTone = tone;
            });

            _saveUserPreferences(soundEnabled, tone);

            if (isSoundEnabled) {
              _playBackgroundMusic();
            } else {
              _stopBackgroundMusic();
            }
          },
          onThemeChanged: (bool isDark) { // ✅ Added theme change function
            setState(() {
              isDarkMode = isDark;
            });

            _saveThemePreference(isDark);
          },
        ),
      ),
    );
  }

  Future<void> _saveUserPreferences(bool soundEnabled, String tone) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnabled', soundEnabled);
    await prefs.setString('selectedTone', tone);
  }

  Future<void> _saveEntry(JournalEntry entry) async {
    await secureStorage.write(
      key: entry.date.toIso8601String(),
      value: "${entry.title}|${entry.content}|${entry.imagePath ?? ''}|${entry.isFavorite}", // ✅ Now saves isFavorite
    );
    _loadEntries();
  }

  Future<void> _deleteEntry(JournalEntry entry) async {
    String keyIso = entry.date.toIso8601String(); // Key format with "T"
    String keyString = entry.date.toString();     // Key format without "T"

    print("Attempting to delete entry with keys: $keyIso and $keyString"); // Debugging

    await secureStorage.delete(key: keyIso);
    await secureStorage.delete(key: keyString);

    Map<String, String> allEntries = await secureStorage.readAll();
    print("After deletion, remaining entries: $allEntries"); // Debugging

    _loadEntries(); // Reload the entries after deletion
  }
  void _loadEntries() async {
    Map<String, String> allEntries = await secureStorage.readAll();

    print("Loaded entries from storage: $allEntries"); // Debugging

    setState(() {
      entries = allEntries.entries
          .where((e) => _isValidDateTimeKey(e.key)) // ✅ Ignore non-journal keys
          .map((e) {
        List<String> parts = e.value.split('|');

        return JournalEntry(
          title: parts.isNotEmpty ? parts[0] : '',
          content: parts.length > 1 ? parts[1] : '',
          date: DateTime.tryParse(e.key) ?? DateTime.now(),
          imagePath: (parts.length > 2 && parts[2].isNotEmpty) ? parts[2] : null,
          isFavorite: parts.length > 3 ? parts[3] == 'true' : false, // ✅ Load favorite status
        );
      }).toList();
    });
  }
  /// ✅ Helper function to check if a key is a valid DateTime
  bool _isValidDateTimeKey(String key) {
    try {
      DateTime.parse(key);
      return true;
    } catch (e) {
      return false;
    }
  }



  void _editEntry(JournalEntry entry) async {
    final updatedEntry = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditEntryScreen(entry: entry),
      ),
    );

    if (updatedEntry != null) {
      await _saveEntry(updatedEntry);
    }
  }
  void _navigateToAddMemoryScreen(BuildContext context) async {
    final memory = await Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => AddMemoryScreen()),
    );

    if (memory != null) {
      // Handle the returned memory (e.g., add it to a list)
      print("New Memory Added: $memory");
    }
  }

  Widget _buildEntryCard(JournalEntry entry) {
    return GestureDetector(
      onTap: () => _editEntry(entry), // Tap to edit
      child: Card(
        elevation: 6,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: EdgeInsets.symmetric(horizontal: 15, vertical: 10),
        color: Colors.white,
        child: Container(
          padding: EdgeInsets.all(15),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(20),
            gradient: LinearGradient(
              colors: [Colors.pink.shade100, Colors.white],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
          child: Row(
            children: [
              // 🧸 Cute Teddy Icon
              Icon(Icons.child_care, size: 50, color: Colors.pinkAccent),
              SizedBox(width: 12),
              // 📌 Entry Content
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      entry.title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                        color: Colors.pink.shade800,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    SizedBox(height: 5),
                    Text(
                      DateFormat('MMM dd, yyyy • hh:mm a').format(entry.date),
                      style: TextStyle(color: Colors.grey.shade600, fontSize: 14),
                    ),
                    SizedBox(height: 5),
                    Text(
                      entry.content,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(fontSize: 16, color: Colors.black87),
                    ),
                  ],
                ),
              ),
              SizedBox(width: 8),
              // ❤️ Favorite, 🗑 Delete & 👀 Read Mode Icons
              Column(
                children: [
                  IconButton(
                    icon: Icon(
                      entry.isFavorite ? Icons.favorite : Icons.favorite_border,
                      color: entry.isFavorite ? Colors.redAccent : Colors.grey,
                      size: 26,
                    ),
                    onPressed: () {
                      _toggleFavorite(entry);
                    },
                  ),
                  IconButton(
                    icon: Icon(Icons.delete, color: Colors.red, size: 24),
                    onPressed: () => _deleteEntry(entry),
                  ),
                  IconButton(
                    icon: Icon(Icons.remove_red_eye, color: Colors.purple, size: 24), // 👀 Read Mode Icon
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => JournalDetailScreen(entry: entry),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Love Journal ❤️', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22)),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
        actions: [
          IconButton(icon: Icon(Icons.settings, color: Colors.white), onPressed: _openSettings),
        ],
      ),
      body: Stack(
        children: [
          Positioned.fill(
            child: CarouselSlider(
              options: CarouselOptions(
                height: double.infinity,
                viewportFraction: 1.0,
                autoPlay: true,
                autoPlayInterval: Duration(seconds: 6),
                enableInfiniteScroll: true,
              ),
              items: images.map((img) => Container(
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(img["path"] ?? "assets/default_image.jpg"),
                    fit: BoxFit.cover,
                  ),
                ),
              )).toList(),
            ),
          ),
          Column(
            children: [
              Expanded(
                child: entries.isEmpty
                    ? Center(child: Text("No journal entries yet.", style: TextStyle(color: Colors.white, fontSize: 18)))
                    : ListView.builder(
                  itemCount: entries.length,
                  itemBuilder: (context, index) {
                    return _buildEntryCard(entries[index]);
                  },
                ),
              ),
            ],
          ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.book), label: 'Journal'),
          BottomNavigationBarItem(icon: Icon(Icons.favorite), label: 'Memories'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.pink,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _selectedIndex = index;
            if (index == 1) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MemoryScreen()), // ✅ Fixed
              );
            } else if (index == 2) {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) =>
                    ProfileScreen()), // ✅ Navigate to Profile
              );
            }
          });
        },
      ),
      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Left Button: Add Memory (Image)
          Padding(
            padding: const EdgeInsets.only(left: 30), // Adjust position
            child: FloatingActionButton(
              backgroundColor: Colors.pinkAccent, // Different color for differentiation
              heroTag: "btn_add_memory", // Unique tag
              child: Icon(Icons.add_a_photo, color: Colors.white),
              onPressed: () => _navigateToAddMemoryScreen(context),
            ),
          ),

          // Right Button: Add Journal Entry
          FloatingActionButton(
            backgroundColor: Colors.pinkAccent,
            heroTag: "btn_add_entry", // Unique tag
            child: Icon(Icons.add, color: Colors.white),
            onPressed: () async {
              final newEntry = await Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => AddEntryScreen()),
              );

              if (newEntry != null) {
                _saveEntry(JournalEntry(
                  title: newEntry['title'],
                  content: newEntry['content'],
                  date: DateTime.now(),
                  imagePath: newEntry['imagePath'],
                ));
              }
            },
          ),
        ],
      ),
    );
  }

}
