import 'package:app_selldrinks/screens/login_Screen.dart';
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
      title: 'HG Coffee was founded by G5',
      debugShowCheckedModeBanner: false,
      theme: highlandsTheme,
      home: LoginScreen(),
    );
  }
}
