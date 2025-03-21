import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _storage = FlutterSecureStorage();
  final _nameController = TextEditingController();
  final _bioController = TextEditingController();
  String? _profileImagePath;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  /// Load Profile Data
  Future<void> _loadProfile() async {
    String? name = await _storage.read(key: "user_name");
    String? bio = await _storage.read(key: "user_bio");
    String? profileImage = await _storage.read(key: "profile_image");

    setState(() {
      _nameController.text = name ?? "Your Name";
      _bioController.text = bio ?? "Add a short bio...";
      _profileImagePath = profileImage;
    });
  }

  /// Save Profile Data
  Future<void> _saveProfile() async {
    await _storage.write(key: "user_name", value: _nameController.text);
    await _storage.write(key: "user_bio", value: _bioController.text);
    if (_profileImagePath != null) {
      await _storage.write(key: "profile_image", value: _profileImagePath);
    }
    setState(() => _isEditing = false); // Exit edit mode
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text("Profile updated!")),
    );
  }

  /// Pick Profile Image
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _profileImagePath = pickedFile.path;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // 🎨 Background Gradient
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [Colors.pinkAccent, Colors.deepPurpleAccent],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: SingleChildScrollView( // ✅ Allow Scrolling
              child: Padding(
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    // 📸 Profile Image with Border
                    GestureDetector(
                      onTap: _isEditing ? _pickImage : null,
                      child: CircleAvatar(
                        radius: 60,
                        backgroundColor: Colors.white,
                        child: CircleAvatar(
                          radius: 55,
                          backgroundImage: _profileImagePath != null
                              ? FileImage(File(_profileImagePath!))
                              : AssetImage("assets/default_profile.jpg") as ImageProvider,
                          child: _profileImagePath == null
                              ? Icon(Icons.camera_alt, size: 40, color: Colors.white70)
                              : null,
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 📌 Profile Card
                    Card(
                      elevation: 8,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // 📝 Name Field
                            _buildEditableField(
                              controller: _nameController,
                              label: "Name",
                              icon: Icons.person,
                            ),

                            SizedBox(height: 15),

                            // 🏷 Bio Field
                            _buildEditableField(
                              controller: _bioController,
                              label: "Bio",
                              icon: Icons.info_outline,
                              maxLines: 2,
                            ),
                          ],
                        ),
                      ),
                    ),

                    SizedBox(height: 20),

                    // 🛠 Edit / Save Button
                    ElevatedButton.icon(
                      onPressed: () {
                        if (_isEditing) {
                          _saveProfile();
                        } else {
                          setState(() => _isEditing = true);
                        }
                      },
                      icon: Icon(_isEditing ? Icons.save : Icons.edit, size: 22),
                      label: Text(_isEditing ? "Save Profile" : "Edit Profile"),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.purpleAccent,
                        padding: EdgeInsets.symmetric(horizontal: 30, vertical: 12),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
                        textStyle: TextStyle(fontSize: 18),
                      ),
                    ),

                    SizedBox(height: 15),

                    // 🔙 Back Button
                    TextButton.icon(
                      onPressed: () => Navigator.pop(context),
                      icon: Icon(Icons.arrow_back, color: Colors.white),
                      label: Text("Back", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// 🎨 Custom Editable Field Widget
  Widget _buildEditableField({
    required TextEditingController controller,
    required String label,
    required IconData icon,
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      enabled: _isEditing,
      maxLines: maxLines,
      style: TextStyle(fontSize: 18, color: Colors.black87),
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon, color: Colors.pinkAccent),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        filled: true,
        fillColor: Colors.white70,
        enabledBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.grey.shade300),
          borderRadius: BorderRadius.circular(12),
        ),
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(color: Colors.pinkAccent),
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }
}
