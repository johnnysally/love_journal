import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart'; // For saving settings
import 'package:audioplayers/audioplayers.dart'; // For playing preview sounds

class SettingsScreen extends StatefulWidget {
  final bool isSoundEnabled;
  final String selectedTone;
  final bool isDarkMode; // ✅ Accept isDarkMode
  final Function(bool, String) onSettingsChanged;
  final Function(bool) onThemeChanged; // Callback for dark mode

  SettingsScreen({
    required this.isSoundEnabled,
    required this.selectedTone,
    required this.isDarkMode, // ✅ Required parameter
    required this.onSettingsChanged,
    required this.onThemeChanged, // Accept theme change function
  });

  @override
  _SettingsScreenState createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late bool isSoundEnabled;
  late String selectedTone;
  late bool isDarkMode; // Dark mode state

  //final AudioPlayer _audioPlayer = AudioPlayer();

  final Map<String, String> tones = {
    "Romantic Melody": "romantic1.mp3",
    "Soft Piano": "romantic2.mp3",
    "Love Guitar": "romantic3.mp3",
  };

  @override
  void initState() {
    super.initState();
    isDarkMode = widget.isDarkMode; // ✅ Initialize from widget
    isSoundEnabled = widget.isSoundEnabled;
    selectedTone = widget.selectedTone;
    _loadSettings(); // Load saved settings
  }

  // Save settings using SharedPreferences
  Future<void> _saveSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isSoundEnabled', isSoundEnabled);
    await prefs.setString('selectedTone', selectedTone);
    widget.onSettingsChanged(isSoundEnabled, selectedTone);
  }

  // Load settings from SharedPreferences
  Future<void> _loadSettings() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isSoundEnabled = prefs.getBool('isSoundEnabled') ?? widget.isSoundEnabled;
      selectedTone = prefs.getString('selectedTone') ?? tones["Romantic Melody"]!;
      isDarkMode = prefs.getBool('isDarkMode') ?? false; // ✅ Load dark mode
    });
  }
  Future<void> _saveDarkMode(bool value) async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', value);
    widget.onThemeChanged(value); // Notify parent to update theme
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Settings")),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView(
          children: [
            SwitchListTile(
              title: Text("Enable Background Music"),
              value: isSoundEnabled,
              onChanged: (value) {
                setState(() => isSoundEnabled = value);
                _saveSettings();
              },
            ),
            SwitchListTile(
              title: Text("Dark Mode"),
              value: isDarkMode,
              onChanged: (value) {
                setState(() => isDarkMode = value);
                _saveDarkMode(value); // Save preference
              },
            ),
            ListTile(
              title: Text("Select Background Tone"),
              subtitle: Text(tones.keys.firstWhere(
                    (key) => tones[key] == selectedTone,
                orElse: () => "Romantic Melody",
              )),
              trailing: Icon(Icons.music_note),
              onTap: () async {
                String? newTone = await showDialog<String>(
                  context: context,
                  builder: (context) => AlertDialog(
                    title: Text("Choose a tone"),
                    content: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: tones.keys.map((key) {
                        return RadioListTile(
                          title: Text(key),
                          value: tones[key],
                          groupValue: selectedTone,
                          onChanged: (value) {
                            if (value != null) {
                              //_playPreview(value); // Only call if value is not null
                              Navigator.pop(context, value);
                            }
                          },
                          secondary: selectedTone == tones[key]
                              ? Icon(Icons.check, color: Colors.green)
                              : null, // Show checkmark for selected tone
                        );
                      }).toList(),
                    ),
                  ),
                );
                if (newTone != null) {
                  setState(() => selectedTone = newTone);
                  _saveSettings();
                }
              },
            ),
          ],
        ),
      ),
    );
  }
}
