import 'package:flutter/material.dart';

// Bảng màu mới
const Color kGreen = Color(0xFFA5B68D); // Xanh nhạt
const Color kBeige = Color(0xFFECDFCC); // Be
const Color kCream = Color(0xFFFCFAEE); // Trắng kem
const Color kOrange = Color(0xFFDA8359); // Cam đất

final ThemeData highlandsTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kGreen,
  scaffoldBackgroundColor: kCream,
  appBarTheme: const AppBarTheme(
    backgroundColor: kGreen,
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: kOrange),
    titleTextStyle: TextStyle(
      color: kOrange,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kGreen,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: Color(0xFF4B2B1B)),
    bodyMedium: TextStyle(fontSize: 14, color: Color(0xFF4B2B1B)),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(color: kGreen),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kBeige,
    selectedItemColor: kOrange,
    unselectedItemColor: kGreen,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kOrange,
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: kBeige,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: kGreen),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: kOrange, width: 2),
    ),
    labelStyle: TextStyle(color: kGreen),
  ),
  dividerColor: kBeige,
  cardColor: kCream,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: kOrange,
    contentTextStyle: TextStyle(color: Colors.white),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kOrange,
    foregroundColor: Colors.white,
  ),
);
