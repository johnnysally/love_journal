import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'screens/home_screen.dart';
import 'screens/pin_screen.dart'; // Import your PIN screen


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  await Hive.openBox('journalBox'); // Open Hive storage
  await Hive.openBox('settingsBox'); // Box to store settings like PIN

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool isAuthenticated = false; // Track if user is authenticated

  void _onAuthenticated() {
    setState(() {
      isAuthenticated = true; // Mark as authenticated
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Love Journal',
      home: isAuthenticated
          ? HomeScreen() // Show home screen if authenticated
          : PinScreen(onAuthenticated: _onAuthenticated), // Pass the function
    );
  }
}
