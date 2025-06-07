import 'package:app_selldrinks/screens/home_screen.dart';
import 'package:app_selldrinks/screens/search_screen.dart';
import 'package:flutter/material.dart';
import './themes/highland_theme.dart'; // Import theme

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Highlands Coffee',
      theme: highlandsTheme,
      home: HomeScreen(),
    );
  }
}
