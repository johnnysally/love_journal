import 'package:flutter/material.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';

class PinScreen extends StatefulWidget {
  final VoidCallback onAuthenticated;

  PinScreen({required this.onAuthenticated});

  @override
  _PinScreenState createState() => _PinScreenState();
}

class _PinScreenState extends State<PinScreen> {
  final _storage = FlutterSecureStorage();
  final _pinController = TextEditingController();
  String? _savedPin;
  bool _isSettingPin = false;

  @override
  void initState() {
    super.initState();
    _loadPin();
  }

  // Load the saved PIN
  Future<void> _loadPin() async {
    String? savedPin = await _storage.read(key: "user_pin");
    setState(() {
      _savedPin = savedPin;
      _isSettingPin = savedPin == null; // If no PIN is set, prompt to set one
    });
  }

  // Verify entered PIN
  void _verifyPin() {
    if (_pinController.text == _savedPin) {
      widget.onAuthenticated(); // Unlock app
    } else {
      _showError("Incorrect PIN. Try again.");
    }
  }

  // Save a new PIN
  Future<void> _setPin() async {
    if (_pinController.text.length < 4) {
      _showError("PIN must be at least 4 digits.");
      return;
    }

    await _storage.write(key: "user_pin", value: _pinController.text);
    setState(() {
      _savedPin = _pinController.text;
      _isSettingPin = false;
    });
    widget.onAuthenticated(); // Unlock app after setting PIN
  }

  // Show an error message
  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  // Reset PIN (for later use)
  Future<void> _resetPin() async {
    await _storage.delete(key: "user_pin");
    setState(() {
      _savedPin = null;
      _isSettingPin = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.pink[50], // Soft romantic theme
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                _isSettingPin ? "Set Your PIN" : "Enter PIN",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _pinController,
                keyboardType: TextInputType.number,
                obscureText: true,
                maxLength: 6,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Enter PIN",
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _isSettingPin ? _setPin : _verifyPin,
                child: Text(_isSettingPin ? "Set PIN" : "Unlock"),
              ),
              if (!_isSettingPin) ...[
                TextButton(
                  onPressed: _resetPin,
                  child: Text("Forgot PIN? Reset"),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
