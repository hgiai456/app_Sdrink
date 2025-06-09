import 'package:flutter/material.dart';

final ThemeData highlandsTheme = ThemeData(
  brightness: Brightness.light,
  primaryColor: const Color(0xFFA10F1A), // Đỏ Highlands
  scaffoldBackgroundColor: const Color(0xFFF5F5F5), // Nền sáng nhạt
  appBarTheme: const AppBarTheme(
    backgroundColor: Color(0xFFA10F1A),
    foregroundColor: Colors.white,
    elevation: 0,
  ),
  textTheme: const TextTheme(
    titleLarge: TextStyle(
      // Ví dụ: "Sản phẩm bán chạy"
      fontSize: 20,
      fontWeight: FontWeight.bold,
      color: Color(0xFF4B2B1B),
    ),
    bodyLarge: TextStyle(
      // Nội dung bình thường
      fontSize: 16,
      color: Colors.black87,
    ),
    bodyMedium: TextStyle(
      // Văn bản phụ hoặc nhãn nhỏ
      fontSize: 14,
      color: Color(0xFF4B2B1B),
    ),
    labelLarge: TextStyle(
      // Chữ trên nút
      fontSize: 16,
      fontWeight: FontWeight.w600,
      color: Colors.white,
    ),
  ),
  iconTheme: const IconThemeData(color: Color(0xFF4B2B1B)),
  bottomNavigationBarTheme: const BottomNavigationBarThemeData(
    backgroundColor: Color(0xFFEFEAE5), // Nền đáy thanh nav
    selectedItemColor: Color(0xFFA10F1A), // Màu icon đã chọn
    unselectedItemColor: Color(0xFF9E9E9E), // Màu icon chưa chọn
    selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
  ),
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ElevatedButton.styleFrom(
      backgroundColor: const Color(0xFFA10F1A),
      foregroundColor: Colors.white,
      textStyle: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    ),
  ),
  inputDecorationTheme: const InputDecorationTheme(
    filled: true,
    fillColor: Colors.white,
    border: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFCCCCCC)),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.all(Radius.circular(10)),
      borderSide: BorderSide(color: Color(0xFFA10F1A), width: 2),
    ),
    labelStyle: TextStyle(color: Color(0xFF4B2B1B)),
  ),
);
