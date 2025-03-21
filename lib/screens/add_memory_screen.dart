import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert'; // Needed for encoding and decoding JSON
import 'memory_screen.dart'; // Import MemoryScreen

class AddMemoryScreen extends StatefulWidget {
  @override
  _AddMemoryScreenState createState() => _AddMemoryScreenState();
}

class _AddMemoryScreenState extends State<AddMemoryScreen> {
  late TextEditingController _titleController;
  File? _selectedImage;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController();
  }

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        _selectedImage = File(pickedFile.path);
      });
    }
  }

  /// **🔹 Save memory using SharedPreferences**
  Future<void> _saveMemory() async {
    if (_titleController.text.isNotEmpty && _selectedImage != null) {
      final memory = {
        'title': _titleController.text,
        'imagePath': _selectedImage!.path,
        'date': DateTime.now().toIso8601String(),
      };

      print("Saving Memory: $memory"); // Debugging log

      SharedPreferences prefs = await SharedPreferences.getInstance();
      List<String> storedMemories = prefs.getStringList('memories') ?? [];

      // Add new memory to the list
      storedMemories.add(jsonEncode(memory));
      await prefs.setStringList('memories', storedMemories);

      // ✅ Navigate back to MemoryScreen
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => MemoryScreen()),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Please select an image and enter a title")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Add Memory"),
        backgroundColor: Colors.pinkAccent,
        elevation: 0,
      ),
      resizeToAvoidBottomInset: true, // ✅ Prevents UI overflow when keyboard appears
      body: SingleChildScrollView( // ✅ Allows scrolling when keyboard is open
        child: Padding(
          padding: EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                child: Padding(
                  padding: EdgeInsets.all(10),
                  child: TextField(
                    controller: _titleController,
                    decoration: InputDecoration(
                      labelText: "Memory Title",
                      border: InputBorder.none,
                    ),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Center(
                child: _selectedImage != null
                    ? ClipRRect(
                  borderRadius: BorderRadius.circular(12),
                  child: Image.file(
                    _selectedImage!,
                    height: 200,
                    width: double.infinity,
                    fit: BoxFit.cover,
                  ),
                )
                    : Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Center(
                    child: Text("No image selected", style: TextStyle(color: Colors.black54)),
                  ),
                ),
              ),
              SizedBox(height: 10),

              Center(
                child: ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: Icon(Icons.image),
                  label: Text("Choose Image"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
              SizedBox(height: 20),

              Center(
                child: ElevatedButton(
                  onPressed: _saveMemory,
                  child: Text("Save Memory"),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.pinkAccent,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
