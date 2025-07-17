import 'package:flutter/material.dart';

// Bảng màu mới dựa trên hình ảnh
const Color kDarkGray = Color(0xFF383838); // Dark Gray
const Color kMediumGray = Color(0xFF808080); // Medium Gray
const Color kLightGray = Color(0xFFF5F5F5); // Light Gray (White smoke)
const Color kWhite = Color(0xFFFFFFFF); // White

final ThemeData highlandsTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: kDarkGray,
  scaffoldBackgroundColor: kLightGray,
  appBarTheme: const AppBarTheme(
    backgroundColor: kWhite,
    foregroundColor: kDarkGray,
    elevation: 0,
    iconTheme: IconThemeData(color: kDarkGray),
    titleTextStyle: TextStyle(
      color: kDarkGray,
      fontWeight: FontWeight.w600,
      fontSize: 18,
    ),
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: kDarkGray,
    ),
    titleMedium: TextStyle(
      fontSize: 18,
      fontWeight: FontWeight.w600,
      color: kDarkGray,
    ),
    bodyLarge: TextStyle(fontSize: 16, color: kDarkGray),
    bodyMedium: TextStyle(fontSize: 14, color: kMediumGray),
    bodySmall: TextStyle(fontSize: 12, color: kMediumGray),
    labelLarge: TextStyle(
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: kWhite,
    ),
    labelMedium: TextStyle(
      fontSize: 14,
      fontWeight: FontWeight.w500,
      color: kDarkGray,
    ),
  ),
  iconTheme: const IconThemeData(color: kDarkGray),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: kWhite,
    selectedItemColor: kDarkGray,
    unselectedItemColor: kMediumGray,
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
    type: BottomNavigationBarType.fixed,
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: kDarkGray,
      foregroundColor: kWhite,
      textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
      elevation: 0,
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: kWhite,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: kMediumGray),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: kMediumGray),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(8)),
      borderSide: BorderSide(color: kDarkGray, width: 2),
    ),
    labelStyle: TextStyle(color: kMediumGray),
    hintStyle: TextStyle(color: kMediumGray),
  ),
  dividerColor: kMediumGray,
  cardColor: kWhite,
  snackBarTheme: const SnackBarThemeData(
    backgroundColor: kDarkGray,
    contentTextStyle: TextStyle(color: kWhite),
  ),
  floatingActionButtonTheme: const FloatingActionButtonThemeData(
    backgroundColor: kDarkGray,
    foregroundColor: kWhite,
  ),
  chipTheme: ChipThemeData(
    backgroundColor: kLightGray,
    selectedColor: kDarkGray,
    labelStyle: const TextStyle(color: kDarkGray),
    shape: RoundedRectangleBorder(
      borderRadius: BorderRadius.circular(20),
      side: const BorderSide(color: kMediumGray),
    ),
  ),
  expansionTileTheme: const ExpansionTileThemeData(
    iconColor: kDarkGray,
    collapsedIconColor: kDarkGray,
    textColor: kDarkGray,
    collapsedTextColor: kDarkGray,
  ),
);
