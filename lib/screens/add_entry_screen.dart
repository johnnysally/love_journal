import 'package:flutter/material.dart';

class AddEntryScreen extends StatefulWidget {
  final Map<String, dynamic>? entry; // Optional entry for editing

  AddEntryScreen({this.entry});

  @override
  _AddEntryScreenState createState() => _AddEntryScreenState();
}

class _AddEntryScreenState extends State<AddEntryScreen> {
  late TextEditingController _titleController;
  late TextEditingController _contentController;

  @override
  void initState() {
    super.initState();
    _titleController = TextEditingController(text: widget.entry?['title'] ?? '');
    _contentController = TextEditingController(text: widget.entry?['content'] ?? '');
  }

  void _saveEntry() {
    if (_titleController.text.isNotEmpty && _contentController.text.isNotEmpty) {
      final entry = {
        'title': _titleController.text,
        'content': _contentController.text,
      };

      print("Saving Entry: $entry"); // Debugging line

      Navigator.pop(context, entry); // Return entry to HomeScreen
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.entry != null ? "Edit Entry" : "New Journal Entry"),
        backgroundColor: Color(0xFFE75480),
        elevation: 0,
      ),
      body: SingleChildScrollView(
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
                    labelText: "Title",
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
            SizedBox(height: 10),
            Card(
              elevation: 4,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Container(
                height: 200, // Set the desired height
                padding: EdgeInsets.all(10),
                child: TextField(
                  controller: _contentController,
                  decoration: InputDecoration(
                    labelText: "Write about your memory...",
                    border: InputBorder.none,
                  ),
                  maxLines: null, // Allows the text field to expand if needed
                  keyboardType: TextInputType.multiline,
                ),
              ),
            ),

            SizedBox(height: 15),
            Center(
              child: ElevatedButton(
                onPressed: _saveEntry,
                child: Text(widget.entry != null ? "Update Entry" : "Save Entry"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Color(0xFFE75480),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
