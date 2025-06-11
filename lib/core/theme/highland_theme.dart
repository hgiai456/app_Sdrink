import 'package:flutter/material.dart';

final Color _primaryRed = Color(0xFFA10F1A); // Đỏ Highlands
final Color _brown = Color(0xFF4A2C13); // Nâu Highlands
final Color _background = Color(0xFFF5F5F5); // Nền xám nhạt
final Color _white = Color(0xFFFFFFFF);
final Color _grey = Color(0xFFBDBDBD); // Xám nhạt

final ThemeData highlandsTheme = ThemeData(
  primaryColor: _primaryRed,
  scaffoldBackgroundColor: _background,
  colorScheme: ColorScheme(
    brightness: Brightness.light,
    primary: _primaryRed,
    onPrimary: Colors.white,
    secondary: _brown,
    onSecondary: Colors.white,
    error: Colors.red,
    onError: Colors.white,
    background: _background,
    onBackground: _brown,
    surface: _white,
    onSurface: _brown,
  ),
  appBarTheme: AppBarTheme(
    backgroundColor: _primaryRed,
    foregroundColor: Colors.white,
    elevation: 0,
    iconTheme: IconThemeData(color: Colors.white),
    titleTextStyle: TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 20,
    ),
    centerTitle: true,
  ),
  bottomNavigationBarTheme: BottomNavigationBarThemeData(
    backgroundColor: _white,
    selectedItemColor: _primaryRed,
    unselectedItemColor: _grey,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.bold),
    type: BottomNavigationBarType.fixed,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: _primaryRed,
      foregroundColor: Colors.white,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      textStyle: TextStyle(fontWeight: FontWeight.bold),
    ),
  ),
  cardTheme: CardTheme(
    color: _white,
    elevation: 2,
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(12),
    ),
  ),
  inputDecorationTheme: InputDecorationTheme(
    filled: true,
    fillColor: Color(0xFFF5F3F0),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: _grey),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(24),
      borderSide: BorderSide(color: _primaryRed, width: 2),
    ),
    prefixIconColor: _grey,
    hintStyle: TextStyle(color: _grey),
  ),
  iconTheme: IconThemeData(color: _brown),
  textTheme: TextTheme(
    titleLarge: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.bold,
      color: _brown,
    ),
    titleMedium: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.bold,
      color: _brown,
    ),
    bodyLarge: TextStyle(
      fontSize: 15,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      fontSize: 13,
      color: Colors.black54,
    ),
    labelLarge: TextStyle(
      fontSize: 12,
      color: _primaryRed,
      fontWeight: FontWeight.bold,
    ),
  ),
); 